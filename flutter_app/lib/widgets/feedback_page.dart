import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';

/// 제작자에게 버그/기능요청 보내기 — 사진·동영상 첨부 지원.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _Attachment {
  final File file;
  final String name;
  final bool isVideo;
  double progress = 0; // 업로드 진행률(전송 시)
  _Attachment(this.file, this.isVideo) : name = file.uri.pathSegments.last;
}

class _FeedbackPageState extends State<FeedbackPage> {
  String _category = 'bug';
  final _msgCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final List<_Attachment> _files = [];
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
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
      setState(() => _files.add(_Attachment(File(x.path), video)));
    } catch (_) {
      // 데스크톱 등에서 picker 미지원 시 무시
    }
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
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

    // 2) 제출
    final ok = await FeedbackService.instance.submit(
      category: _category,
      message: _msgCtrl.text.trim(),
      contact: _contactCtrl.text,
      attachments: uploaded,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.feedbackSent)));
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
        title: Text(l.feedbackTitle,
            style: const TextStyle(fontSize: 15, letterSpacing: 0.5)),
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
          Row(children: [
            _attachBtn(Icons.photo_outlined, l.feedbackAttachPhoto,
                () => _pick(false)),
            const SizedBox(width: 10),
            _attachBtn(Icons.videocam_outlined, l.feedbackAttachVideo,
                () => _pick(true)),
          ]),
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
              child: Row(children: [
                Icon(a.value.isVideo ? Icons.videocam : Icons.image,
                    size: 16, color: AppColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.value.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.text, fontSize: 12)),
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
                    icon: const Icon(Icons.close,
                        size: 15, color: AppColors.muted),
                    onPressed: () =>
                        setState(() => _files.removeAt(a.key)),
                  ),
              ]),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Text(_error!,
                  style:
                      const TextStyle(color: AppColors.danger, fontSize: 12)),
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
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l.feedbackSend,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
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
          color: sel ? AppColors.timerOrange.withAlpha(0x33) : AppColors.surface,
          border: Border.all(
              color: sel ? AppColors.timerOrange : AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? AppColors.timerOrange : AppColors.muted,
                fontSize: 13)),
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
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(label,
                style:
                    const TextStyle(color: AppColors.muted, fontSize: 12)),
          ]),
        ),
      );

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.timerOrange)),
      );
}
