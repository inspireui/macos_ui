import 'package:flutter/foundation.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui/src/library.dart';

/// A macOS-style icon button.
class MacosIconButton extends StatefulWidget {
  /// Builds a macOS-style icon button
  const MacosIconButton({
    Key? key,
    required this.icon,
    this.backgroundColor,
    this.disabledColor,
    this.hoverColor,
    this.onPressed,
    this.pressedOpacity = 0.4,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.boxConstraints = const BoxConstraints(
      minHeight: 20,
      minWidth: 20,
      maxWidth: 30,
      maxHeight: 30,
    ),
    this.padding,
    this.mouseCursor = SystemMouseCursors.basic,
  })  : assert(pressedOpacity == null ||
            (pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        super(key: key);

  /// The widget to use as the icon.
  ///
  /// Typically an [Icon] widget.
  final Widget icon;

  /// The background color of this [MacosIconButton].
  ///
  /// Defaults to [CupertinoColors.activeBlue]. Set to [Colors.transparent] for
  /// a transparent background color.
  final Color? backgroundColor;

  /// The color of the button's background when the button is disabled.
  final Color? disabledColor;

  /// The color of the button's background when the mouse hovers over it.
  ///
  /// Set to Colors.transparent to disable the hover effect.
  final Color? hoverColor;

  /// The callback that is called when the button is tapped or otherwise activated.
  ///
  /// If this is set to null, the button will be disabled.
  final VoidCallback? onPressed;

  /// The opacity that the button will fade to when it is pressed.
  /// The button will have an opacity of 1.0 when it is not pressed.
  ///
  /// This defaults to 0.4. If null, opacity will not change on pressed if using
  /// your own custom effects is desired.
  final double? pressedOpacity;

  /// The shape to make the button.
  ///
  /// Defaults to `BoxShape.rectangle`.
  final BoxShape shape;

  /// The border radius for the button.
  ///
  /// This should only be set if setting [shape] to `BoxShape.rectangle`.
  ///
  /// Defaults to `BorderRadius.circular(7.0)`.
  final BorderRadius? borderRadius;

  ///The alignment of the button's icon.
  ///
  /// Typically buttons are sized to be just big enough to contain the child and its
  /// [padding]. If the button's size is constrained to a fixed size, for example by
  /// enclosing it with a [SizedBox], this property defines how the child is aligned
  /// within the available space.
  ///
  /// Always defaults to [Alignment.center].
  final AlignmentGeometry alignment;

  /// The box constraints for the button.
  ///
  /// Defaults to
  /// ```dart
  /// const BoxConstraints(
  ///   minHeight: 20,
  ///   minWidth: 20,
  ///   maxWidth: 30,
  ///   maxHeight: 30,
  /// ),
  ///```
  final BoxConstraints boxConstraints;

  /// The internal padding for the button's [icon].
  ///
  /// Defaults to `EdgeInsets.all(8)`.
  final EdgeInsetsGeometry? padding;

  /// The semantic label used by screen readers.
  final String? semanticLabel;

  /// The mouse cursor to use when hovering over this widget.
  final MouseCursor? mouseCursor;

  /// Whether the button is enabled or disabled. Buttons are disabled by default. To
  /// enable a button, set its [onPressed] property to a non-null value.
  bool get enabled => onPressed != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('disabledColor', disabledColor));
    properties.add(ColorProperty('hoverColor', hoverColor));
    properties.add(DoubleProperty('pressedOpacity', pressedOpacity));
    properties.add(DiagnosticsProperty('alignment', alignment));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(StringProperty('semanticLabel', semanticLabel));
  }

  @override
  MacosIconButtonState createState() => MacosIconButtonState();
}

class MacosIconButtonState extends State<MacosIconButton>
    with SingleTickerProviderStateMixin {
  // Eyeballed values. Feel free to tweak.
  static const Duration kFadeOutDuration = Duration(milliseconds: 10);
  static const Duration kFadeInDuration = Duration(milliseconds: 100);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(MacosIconButton old) {
    super.didUpdateWidget(old);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity ?? 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @visibleForTesting
  bool buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!buttonHeldDown) {
      buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (buttonHeldDown) {
      buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (buttonHeldDown) {
      buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController.isAnimating) return;
    final bool wasHeldDown = buttonHeldDown;
    final TickerFuture ticker = buttonHeldDown
        ? _animationController.animateTo(1.0, duration: kFadeOutDuration)
        : _animationController.animateTo(0.0, duration: kFadeInDuration);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != buttonHeldDown) _animate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final theme = MacosIconButtonTheme.of(context);

    final Color backgroundColor =
        widget.backgroundColor ?? theme.backgroundColor!;

    final Color hoverColor = widget.hoverColor ?? theme.hoverColor!;

    final Color? disabledColor;

    if (widget.disabledColor != null) {
      disabledColor = MacosDynamicColor.resolve(
        widget.disabledColor!,
        context,
      );
    } else {
      disabledColor = theme.disabledColor;
    }

    final padding = widget.padding ?? theme.padding ?? const EdgeInsets.all(8);

    return MouseRegion(
      cursor: widget.mouseCursor!,
      onEnter: (e) {
        setState(() => _isHovered = true);
      },
      onExit: (e) {
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? _handleTapDown : null,
        onTapUp: enabled ? _handleTapUp : null,
        onTapCancel: enabled ? _handleTapCancel : null,
        onTap: widget.onPressed,
        child: Semantics(
          label: widget.semanticLabel,
          button: true,
          child: ConstrainedBox(
            constraints: widget.boxConstraints,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: widget.shape,
                  borderRadius: widget.borderRadius != null
                      ? widget.borderRadius
                      : widget.shape == BoxShape.rectangle
                          ? BorderRadius.circular(7.0)
                          : null,
                  color: !enabled
                      ? disabledColor
                      : _isHovered
                          ? hoverColor
                          : backgroundColor,
                ),
                child: Padding(
                  padding: padding,
                  child: Align(
                    alignment: widget.alignment,
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: widget.icon,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overrides the default style of its [MacosIconButton] descendants.
///
/// See also:
///
///  * [MacosIconButtonThemeData], which is used to configure this theme.
class MacosIconButtonTheme extends InheritedTheme {
  /// Builds a [MacosIconButtonTheme].
  ///
  /// The [data] parameter must not be null.
  const MacosIconButtonTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  /// The configuration of this theme.
  final MacosIconButtonThemeData data;

  /// The closest instance of this class that encloses the given context.
  ///
  /// If there is no enclosing [MacosIconButtonTheme] widget, then
  /// [MacosThemeData.macosIconButtonTheme] is used.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// final theme = MacosIconButtonTheme.of(context);
  /// ```
  static MacosIconButtonThemeData of(BuildContext context) {
    final MacosIconButtonTheme? buttonTheme =
        context.dependOnInheritedWidgetOfExactType<MacosIconButtonTheme>();
    return buttonTheme?.data ?? MacosTheme.of(context).macosIconButtonTheme;
  }

  Widget wrap(BuildContext context, Widget child) {
    return MacosIconButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(MacosIconButtonTheme oldWidget) =>
      data != oldWidget.data;
}

/// A style that overrides the default appearance of
/// [MacosIconButton]s when it's used with [MacosIconButtonTheme] or with the
/// overall [MacosTheme]'s [MacosThemeData.macosIconButtonTheme].
///
/// See also:
///
///  * [MacosIconButtonTheme], the theme which is configured with this class.
///  * [MacosThemeData.macosIconButtonTheme], which can be used to override
///  the default style for [MacosIconButton]s below the overall [MacosTheme].
class MacosIconButtonThemeData with Diagnosticable {
  /// Builds a [MacosIconButtonThemeData].
  const MacosIconButtonThemeData({
    this.backgroundColor,
    this.hoverColor,
    this.disabledColor,
    this.shape,
    this.borderRadius,
    this.boxConstraints,
    this.padding,
  });

  /// The default background color for [MacosIconButton].
  final Color? backgroundColor;

  /// The color of the button when the mouse hovers over it.
  final Color? hoverColor;

  /// The default disabled color for [MacosIconButton].
  final Color? disabledColor;

  /// The default shape for [MacosIconButton].
  final BoxShape? shape;

  /// The default border radius for [MacosIconButton].
  final BorderRadius? borderRadius;

  /// The default box constraints for [MacosIconButton].
  final BoxConstraints? boxConstraints;

  /// The default padding for [MacosIconButton].
  final EdgeInsetsGeometry? padding;

  /// Copies this [MacosIconButtonThemeData] into another.
  MacosIconButtonThemeData copyWith({
    Color? backgroundColor,
    Color? disabledColor,
    Color? hoverColor,
    BoxShape? shape,
    BorderRadius? borderRadius,
    BoxConstraints? boxConstraints,
    EdgeInsetsGeometry? padding,
  }) {
    return MacosIconButtonThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      disabledColor: disabledColor ?? this.disabledColor,
      hoverColor: hoverColor ?? this.hoverColor,
      shape: shape ?? this.shape,
      borderRadius: borderRadius ?? this.borderRadius,
      boxConstraints: boxConstraints ?? this.boxConstraints,
      padding: padding ?? this.padding,
    );
  }

  /// Linearly interpolate between two [MacosIconButtonThemeData].
  ///
  /// All the properties must be non-null.
  static MacosIconButtonThemeData lerp(
    MacosIconButtonThemeData a,
    MacosIconButtonThemeData b,
    double t,
  ) {
    return MacosIconButtonThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      disabledColor: Color.lerp(a.disabledColor, b.disabledColor, t),
      hoverColor: Color.lerp(a.hoverColor, b.hoverColor, t),
      shape: b.shape,
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      boxConstraints:
          BoxConstraints.lerp(a.boxConstraints, b.boxConstraints, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MacosIconButtonThemeData &&
          runtimeType == other.runtimeType &&
          backgroundColor?.value == other.backgroundColor?.value &&
          disabledColor?.value == other.disabledColor?.value &&
          hoverColor?.value == other.hoverColor?.value &&
          shape == other.shape &&
          borderRadius == other.borderRadius &&
          boxConstraints == other.boxConstraints &&
          padding == other.padding;

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      disabledColor.hashCode ^
      hoverColor.hashCode ^
      shape.hashCode ^
      borderRadius.hashCode ^
      boxConstraints.hashCode ^
      padding.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('disabledColor', disabledColor));
    properties.add(ColorProperty('hoverColor', hoverColor));
    properties.add(EnumProperty<BoxShape?>('shape', shape));
    properties
        .add(DiagnosticsProperty<BorderRadius?>('borderRadius', borderRadius));
    properties.add(
      DiagnosticsProperty<BoxConstraints?>('boxConstraints', boxConstraints),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>('padding', padding),
    );
  }

  MacosIconButtonThemeData merge(MacosIconButtonThemeData? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      disabledColor: other.disabledColor,
      hoverColor: other.hoverColor,
      shape: other.shape,
      borderRadius: other.borderRadius,
      boxConstraints: other.boxConstraints,
      padding: other.padding,
    );
  }
}
