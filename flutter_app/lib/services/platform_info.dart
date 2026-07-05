import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 웹 안전 플랫폼 판별 헬퍼.
///
/// Flutter 웹에서는 `dart:io` 의 [Platform] 멤버 접근이 즉시 `UnsupportedError`
/// 를 던진다. 그래서 모든 판별은 const [kIsWeb] 로 먼저 단락(`&&`)시켜, 웹에서는
/// [Platform] 을 절대 건드리지 않는다(웹 빌드에서 tree-shaking 으로 제거됨).
///
/// 앱 전역에서 `Platform.isXxx` 직접 호출 대신 이 getter 들을 쓴다.
bool get isWeb => kIsWeb;
bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isIOS => !kIsWeb && Platform.isIOS;
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isMacOS => !kIsWeb && Platform.isMacOS;
bool get isLinux => !kIsWeb && Platform.isLinux;

/// Windows/macOS/Linux 데스크톱 여부. 웹·모바일에선 false.
bool get isDesktop => isWindows || isMacOS || isLinux;
