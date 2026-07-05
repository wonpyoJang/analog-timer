import 'package:flutter/material.dart';

/// 데스크톱/웹용 스텁 — Android/iOS 가드 뒤에서만 노출되므로 실제 호출되지 않는다.
Widget buildQrScanner({
  required void Function(String code) onDetect,
  required VoidCallback onCancel,
}) => const SizedBox.shrink();
