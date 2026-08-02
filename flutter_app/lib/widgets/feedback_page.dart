import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';
import '../services/telemetry_service.dart';
import '../services/review_prompt_service.dart';

/// 제작자에게 버그/기능요청 보내기 — 사진·동영상 첨부 지원.
class FeedbackPage extends StatefulWidget {
  /// 초기 선택 카테고리 — 후기 유도 진입은 'other', 기본은 'bug'.
  final String initialCategory;
  const FeedbackPage({super.key, this.initialCategory = 'bug'});
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _Attachment {
  final File file;
  final String name;
  final String kind; // image | video | audio
  double progress = 0; // 업로드 진행률(전송 시)
  _Attachment(this.file, this.kind) : name = file.uri.pathSegments.last;

  IconData get icon => switch (kind) {
    'video' => Icons.videocam,
    'audio' => Icons.mic,
    _ => Icons.image,
  };
}

class _FeedbackPageState extends State<FeedbackPage> {
  late String _category = widget.initialCategory;
  final _msgCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final List<_Attachment> _files = [];
  bool _sending = false;
  bool _includeLogs = true; // 진단 로그 동봉 (기본 ON, 사용자가 끌 수 있음)
  String? _error;

  // ── 음성 녹음 상태 ──────────────────────────────────────────
  final AudioRecorder _recorder = AudioRecorder();
  bool _recording = false;
  Duration _recElapsed = Duration.zero;
  Timer? _recTimer;

  @override
  void dispose() {
    _recTimer?.cancel();
    _recorder.dispose();
    _msgCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(bool video) async {
    try {
      final picker = ImagePicker();
      final XFile? x = video
          ? await picker.pickVideo(source: ImageSource.gallery)
          : await picker.pickImage(source: ImageSource.gallery);
      if (x == null) return;
      setState(
        () => _files.add(_Attachment(File(x.path), video ? 'video' : 'image')),
      );
    } catch (_) {
      // 데스크톱 등에서 picker 미지원 시 무시
    }
  }

  /// 음성 녹음 토글 — 시작하면 m4a(AAC) 로 임시파일에 녹음, 종료 시 첨부 목록에 추가.
  Future<void> _toggleRecord() async {
    final l = AppLocalizations.of(context);
    if (_recording) {
      _recTimer?.cancel();
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _recording = false;
        if (path != null) _files.add(_Attachment(File(path), 'audio'));
      });
      return;
    }
    try {
      if (!await _recorder.hasPermission()) {
        if (!mounted) return;
        setState(() => _error = l.feedbackMicDenied);
        return;
      }
      final path =
          '${Directory.systemTemp.path}${Platform.pathSeparator}fb_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 96000),
        path: path,
      );
      if (!mounted) return;
      setState(() {
        _recording = true;
        _recElapsed = Duration.zero;
        _error = null;
      });
      _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _recElapsed += const Duration(seconds: 1));
        }
      });
    } catch (_) {
      if (mounted) setState(() => _error = l.feedbackMicDenied);
    }
  }

  String get _recLabel {
    final m = _recElapsed.inMinutes.toString().padLeft(2, '0');
    final s = (_recElapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    // 녹음 중 전송 → 녹음을 마무리해 첨부에 포함
    if (_recording) await _toggleRecord();
    if (_msgCtrl.text.trim().isEmpty) {
      setState(() => _error = l.feedbackMessageRequired);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });

    // 1) 첨부 업로드 (순차 — 진행률 표시)
    final uploaded = <Map<String, dynamic>>[];
    for (final a in _files) {
      final r = await FeedbackService.instance.uploadAttachment(
        a.file,
        onProgress: (p) {
          if (mounted) setState(() => a.progress = p);
        },
      );
      if (r == null) {
        if (!mounted) return;
        setState(() {
          _sending = false;
          _error = '${l.feedbackFailed} (${a.name})';
        });
        return;
      }
      uploaded.add(r);
    }

    // 2) 제출 (선택 시 진단 스냅샷 동봉 — 환경/최근 행동/이벤트로그)
    final diag = _includeLogs
        ? await TelemetryService.instance.diagnosticsSnapshot()
        : null;
    final ok = await FeedbackService.instance.submit(
      category: _category,
      message: _msgCtrl.text.trim(),
      contact: _contactCtrl.text,
      attachments: uploaded,
      diagnostics: diag,
    );
    if (!mounted) return;
    if (ok) {
      // 피드백을 보낸 사용자에게는 후기 유도 다이얼로그를 더 띄우지 않는다.
      unawaited(ReviewPromptService.instance.markDone());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.feedbackSent)));
      Navigator.pop(context);
    } else {
      setState(() {
        _sending = false;
        _error = l.feedbackFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(
          l.feedbackTitle,
          style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 카테고리
          Wrap(
            spacing: 8,
            children: [
              _chip('bug', l.feedbackCategoryBug),
              _chip('feature', l.feedbackCategoryFeature),
              _chip('other', l.feedbackCategoryOther),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _msgCtrl,
            maxLines: 7,
            style: const TextStyle(color: AppColors.text, fontSize: 14),
            decoration: _dec(l.feedbackMessageHint),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactCtrl,
            style: const TextStyle(color: AppColors.text, fontSize: 13),
            decoration: _dec(l.feedbackContactHint),
          ),
          const SizedBox(height: 16),
          // 첨부 버튼
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _attachBtn(
                Icons.photo_outlined,
                l.feedbackAttachPhoto,
                () => _pick(false),
              ),
              _attachBtn(
                Icons.videocam_outlined,
                l.feedbackAttachVideo,
                () => _pick(true),
              ),
              // 음성 녹음 — 녹음 중엔 빨간 점 + 경과시간 + 탭하여 종료
              GestureDetector(
                onTap: _sending ? null : _toggleRecord,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: _recording
                        ? AppColors.danger.withAlpha(0x22)
                        : AppColors.surface,
                    border: Border.all(
                      color: _recording ? AppColors.danger : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _recording
                            ? Icons.stop_circle_outlined
                            : Icons.mic_none,
                        size: 16,
                        color: _recording ? AppColors.danger : AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _recording
                            ? '${l.feedbackRecording} $_recLabel'
                            : l.feedbackRecordVoice,
                        style: TextStyle(
                          color: _recording
                              ? AppColors.danger
                              : AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 첨부 목록
          for (final a in _files.asMap().entries)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(a.value.icon, size: 16, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.value.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 12,
                          ),
                        ),
                        if (_sending)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: LinearProgressIndicator(
                              value: a.value.progress,
                              minHeight: 3,
                              backgroundColor: AppColors.border,
                              color: AppColors.timerOrange,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!_sending)
                    IconButton(
                      icon: Icon(Icons.close, size: 15, color: AppColors.muted),
                      onPressed: () => setState(() => _files.removeAt(a.key)),
                    ),
                ],
              ),
            ),
          // 진단 로그 동봉 체크박스 (기기 환경·최근 행동 흐름 — 개인정보 미포함)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: _sending
                  ? null
                  : () => setState(() => _includeLogs = !_includeLogs),
              child: Row(
                children: [
                  Icon(
                    _includeLogs
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 18,
                    color: _includeLogs
                        ? AppColors.timerOrange
                        : AppColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.feedbackIncludeLogs,
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _sending ? null : _send,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _sending
                    ? AppColors.timerOrange.withAlpha(0x66)
                    : AppColors.timerOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l.feedbackSend,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    final sel = _category == value;
    return GestureDetector(
      onTap: () => setState(() => _category = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? AppColors.timerOrange.withAlpha(0x33)
              : AppColors.surface,
          border: Border.all(
            color: sel ? AppColors.timerOrange : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel ? AppColors.timerOrange : AppColors.muted,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _attachBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: _sending ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.timerOrange),
    ),
  );
}
