import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';
import '../services/sync_service.dart';

/// 기기 연결(페어링) 풀스크린 화면 — 데스크탑/모바일 공용.
/// 초대(코드+QR 발급) / 코드 입력으로 합류 / 연결 상태·해제.
class SyncConnectPage extends StatefulWidget {
  const SyncConnectPage({super.key});
  @override
  State<SyncConnectPage> createState() => _SyncConnectPageState();
}

class _SyncConnectPageState extends State<SyncConnectPage> {
  ({String code, String roomId})? _pairing;
  final _codeCtrl = TextEditingController();
  bool _busy = false;
  String? _msg;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    setState(() {
      _busy = true;
      _msg = null;
    });
    final r = await SyncService.instance.createPairing();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _pairing = r;
      if (r == null) _msg = '코드 발급 실패 — 네트워크를 확인하세요';
    });
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _msg = '6자리 코드를 입력하세요');
      return;
    }
    setState(() {
      _busy = true;
      _msg = null;
    });
    final ok = await SyncService.instance.joinWithCode(code);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _msg = ok ? null : '코드가 틀리거나 만료되었습니다';
    });
  }

  Future<void> _disconnect() async {
    await SyncService.instance.disconnect();
    if (!mounted) return;
    setState(() => _pairing = null);
  }

  @override
  Widget build(BuildContext context) {
    final connected = SyncService.instance.connected;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: const Text('기기 연결',
            style: TextStyle(fontSize: 15, letterSpacing: 0.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (connected) ...[
            _card([
              const Text('✓ 연결됨',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('방 코드: ${SyncService.instance.roomId}',
                  style:
                      const TextStyle(color: AppColors.muted, fontSize: 13)),
              const SizedBox(height: 6),
              const Text('이 방의 모든 기기끼리 타이머·프리셋·설정이 동기화됩니다.',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 12, height: 1.5)),
            ]),
            const SizedBox(height: 12),
            _card([
              const Text('다른 기기 더 추가',
                  style: TextStyle(color: AppColors.text, fontSize: 14)),
              const SizedBox(height: 10),
              if (_busy && _pairing == null)
                const Center(child: CircularProgressIndicator())
              else if (_pairing == null)
                _btn('초대 코드 만들기', _invite)
              else
                _qrBlock(_pairing!),
            ]),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _disconnect,
                child: const Text('연결 해제',
                    style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ] else ...[
            _card([
              const Text('이 기기로 초대',
                  style: TextStyle(color: AppColors.text, fontSize: 14)),
              const SizedBox(height: 6),
              const Text('다른 기기에서 QR을 스캔하거나 6자리 코드를 입력하면 연결됩니다.',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 12, height: 1.5)),
              const SizedBox(height: 12),
              if (_busy && _pairing == null)
                const Center(child: CircularProgressIndicator())
              else if (_pairing == null)
                _btn('초대 코드 만들기', _invite)
              else
                _qrBlock(_pairing!),
            ]),
            const SizedBox(height: 16),
            _card([
              const Text('코드로 연결',
                  style: TextStyle(color: AppColors.text, fontSize: 14)),
              const SizedBox(height: 6),
              const Text('다른 기기에 표시된 6자리 코드를 입력하세요.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: const TextStyle(
                        color: AppColors.text, fontSize: 18, letterSpacing: 4),
                    decoration: _dec('000000'),
                  ),
                ),
                const SizedBox(width: 10),
                _btn('연결', _join),
              ]),
            ]),
          ],
          if (_msg != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(_msg!,
                  style:
                      const TextStyle(color: AppColors.danger, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _qrBlock(({String code, String roomId}) p) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: QrImageView(
                data: p.code, size: 160, backgroundColor: Colors.white),
          ),
          const SizedBox(height: 12),
          SelectableText(p.code,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('5분 안에 다른 기기에서 스캔하거나 입력하세요',
              style: TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      );

  Widget _card(List<Widget> ch) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: ch),
      );

  Widget _btn(String label, VoidCallback onTap) => GestureDetector(
        onTap: _busy ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
              color: AppColors.timerOrange,
              borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      );

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.muted),
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
