import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_theme.dart';

/// Android/iOS QR 스캐너. 6자리 코드가 감지되면 onDetect 호출 후 한 번만 처리한다.
Widget buildQrScanner({
  required void Function(String code) onDetect,
  required VoidCallback onCancel,
}) => _MobileQrScanner(onDetect: onDetect, onCancel: onCancel);

class _MobileQrScanner extends StatefulWidget {
  final void Function(String code) onDetect;
  final VoidCallback onCancel;
  const _MobileQrScanner({required this.onDetect, required this.onCancel});

  @override
  State<_MobileQrScanner> createState() => _MobileQrScannerState();
}

class _MobileQrScannerState extends State<_MobileQrScanner> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            if (_handled) return;
            for (final b in capture.barcodes) {
              final raw = b.rawValue?.trim();
              if (raw != null && raw.length == 6 && int.tryParse(raw) != null) {
                _handled = true;
                widget.onDetect(raw);
                return;
              }
            }
          },
        ),
        // 조준 프레임 — 페어링 코드가 짧아 화면 중앙 가이드만 있으면 충분.
        Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.timerOrange, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Center(
            child: TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ),
      ],
    );
  }
}
