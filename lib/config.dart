/// Project-wide build switches.
class AppConfig {
  const AppConfig._();

  /// The Figma prototype renders a hand-drawn iOS status bar (`9:41`, signal,
  /// wifi, battery) because it lives inside a fake phone frame.
  ///
  /// On a real device the OS already draws a status bar, so leaving this on
  /// would stack two of them. It defaults to `false`; flip it to `true` when
  /// previewing in a desktop/web target that has no system bar of its own.
  static const bool showMockStatusBar = false;
}
