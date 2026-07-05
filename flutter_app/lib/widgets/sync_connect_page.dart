import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../l10n/app_localizations.dart';
import '../services/platform_info.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';

// mobile_scanner 는 Android/iOS 전용. 데스크톱 컴파일 회피를 위해 조건부 import.
// dart:io 는 데스크톱/모바일 모두 지원하므로 kIsWeb 여부는 여기서 판단하지 않는다.
// 실제 사용은 화면에서 isAndroid || isIOS 가드로 막는다.
import 'qr_scanner_stub.dart' if (dart.library.io) 'qr_scanner_mobile.dart';

/// 기기 연결(페어링) 풀스크린 화면 — 데스크탑/모바일 공용.
/// 초대(코드+QR 발급) / 코드 입력 또는 QR 스캔으로 합류 / 연결 상태·해제.
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
  bool _scanning = false;

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
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = false;
      _pairing = r;
      if (r == null) _msg = l.syncErrorNetwork;
    });
  }

  Future<void> _join() async {
    final l = AppLocalizations.of(context);
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _msg = l.syncErrorCodeLen);
      return;
    }
    await _submitCode(code);
  }

  Future<void> _submitCode(String code) async {
    setState(() {
      _busy = true;
      _msg = null;
    });
    final ok = await SyncService.instance.joinWithCode(code);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = false;
      _scanning = false;
      _msg = ok ? null : l.syncErrorCode;
    });
  }

  Future<void> _disconnect() async {
    await SyncService.instance.disconnect();
    if (!mounted) return;
    setState(() => _pairing = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_scanning) return _buildScanner(l);
    return _buildForm(l);
  }

  Widget _buildScanner(AppLocalizations l) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.text,
      elevation: 0,
      title: Text(
        l.syncScanQr,
        style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
      ),
    ),
    body: buildQrScanner(
      onDetect: _submitCode,
      onCancel: () => setState(() => _scanning = false),
    ),
  );

  Widget _buildForm(AppLocalizations l) {
    final connected = SyncService.instance.connected;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(
          l.syncPageTitle,
          style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (connected) ...[
            _card([
              Text(
                l.syncConnected,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.syncRoomLabel(SyncService.instance.roomId ?? ''),
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                l.syncRoomDesc,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              Text(
                l.syncAddDevice,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
              ),
              const SizedBox(height: 10),
              if (_busy && _pairing == null)
                const Center(child: CircularProgressIndicator())
              else if (_pairing == null)
                _btn(l.syncCreateCode, _invite)
              else
                _qrBlock(_pairing!, l),
            ]),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _disconnect,
                child: Text(
                  l.syncDisconnect,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            ),
          ] else ...[
            _card([
              Text(
                l.syncInviteTitle,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                l.syncInviteDesc,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              if (_busy && _pairing == null)
                const Center(child: CircularProgressIndicator())
              else if (_pairing == null)
                _btn(l.syncCreateCode, _invite)
              else
                _qrBlock(_pairing!, l),
            ]),
            const SizedBox(height: 16),
            _card([
              Text(
                l.syncJoinTitle,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                l.syncJoinDesc,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        letterSpacing: 4,
                      ),
                      decoration: _dec('000000'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _btn(l.syncJoinBtn, _join),
                ],
              ),
              // 모바일에서만 QR 스캐너 노출 — 데스크톱은 카메라 접근이 대체로 불가능하고
              // mobile_scanner 도 지원 안 함.
              if (isAndroid || isIOS) ...[
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: _busy
                        ? null
                        : () => setState(() => _scanning = true),
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      size: 18,
                      color: AppColors.timerOrange,
                    ),
                    label: Text(
                      l.syncScanQr,
                      style: const TextStyle(
                        color: AppColors.timerOrange,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ]),
          ],
          if (_msg != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                _msg!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _qrBlock(({String code, String roomId}) p, AppLocalizations l) =>
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: QrImageView(
              data: p.code,
              size: 160,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            p.code,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 28,
              letterSpacing: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.syncExpiry,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      );

  Widget _card(List<Widget> ch) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: ch),
  );

  Widget _btn(String label, VoidCallback onTap) => GestureDetector(
    onTap: _busy ? null : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.timerOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.muted),
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
