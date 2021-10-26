import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui/src/library.dart';

/// Tooltips, succinctly describe how to use controls without shifting
/// people’s focus away from the primary interface. Tooltips appear when
/// the user positions the pointer over a control for a few seconds. A
/// tooltip remains visible for 10 seconds, or until the pointer moves
/// away from the control.
///
/// The tooltip can respond to long press, on mobile, and to pointer events,
/// on desktop.
///
/// ![Tooltip Preview](https://developer.apple.com/design/human-interface-guidelines/macos/images/help_Tooltip.png)
///
/// See also:
///   * [TooltipThemeData], used to define how the tooltip will look like
class MacosTooltip extends StatefulWidget {
  /// Creates a tooltip.
  ///
  /// Wrap any widget in a [MacosTooltip] to show a message on mouse hover or
  /// long press event
  const MacosTooltip({
    Key? key,
    required this.message,
    this.child,
    this.style,
    this.excludeFromSemantics = false,
    this.useMousePosition = true,
  }) : super(key: key);

  /// The text to display in the tooltip.
  final String message;

  /// The widget the tooltip will be displayed, either above or below,
  /// when the mouse is hovering or whenever it gets long pressed.
  final Widget? child;

  /// The style of the tooltip. If non-null, it's mescled with
  /// [ThemeData.tooltipThemeData]
  final TooltipThemeData? style;

  /// Whether the tooltip's [message] should be excluded from the
  /// semantics tree.
  ///
  /// Defaults to false. A tooltip will add a [Semantics] label that
  /// is set to [MacosTooltip.message]. Set this property to true if the
  /// app is going to provide its own custom semantics label.
  final bool excludeFromSemantics;

  /// Whether the current mouse position should be used to render the
  /// tooltip on the screen. If no mouse is connected, this value is
  /// ignored.
  ///
  /// Defaults to true. A tooltip will show the tooltip on the current
  /// mouse position and the tooltip will be removed as soon as the
  /// pointer exit the [child].
  final bool useMousePosition;

  @override
  _MacosTooltipState createState() => _MacosTooltipState();
}

class _MacosTooltipState extends State<MacosTooltip>
    with SingleTickerProviderStateMixin {
  static const double _defaultVerticalOffset = 24.0;
  static const bool _defaultPreferBelow = false;
  static const EdgeInsetsGeometry _defaultMargin = EdgeInsets.all(0.0);
  static const Duration _fadeInDuration = Duration(milliseconds: 150);
  static const Duration _fadeOutDuration = Duration(milliseconds: 75);
  static const Duration _defaultWaitDuration = Duration.zero;

  late double height;
  late EdgeInsetsGeometry padding;
  late EdgeInsetsGeometry margin;
  late Decoration decoration;
  late TextStyle textStyle;
  late double verticalOffset;
  late bool preferBelow;
  late bool excludeFromSemantics;
  late AnimationController _controller;
  OverlayEntry? _entry;
  Timer? _hideTimer;
  Timer? _showTimer;
  late Duration showDuration;
  late Duration waitDuration;
  late bool _mouseIsConnected;
  bool _longPressActivated = false;
  Offset? mousePosition;

  @override
  void initState() {
    super.initState();
    _mouseIsConnected = RendererBinding.instance!.mouseTracker.mouseIsConnected;
    _controller = AnimationController(
      duration: _fadeInDuration,
      reverseDuration: _fadeOutDuration,
      vsync: this,
    )..addStatusListener(_handleStatusChanged);
    // Listen to see when a mouse is added.
    RendererBinding.instance!.mouseTracker
        .addListener(_handleMouseTrackerChange);
    // Listen to global pointer events so that we can hide a tooltip immediately
    // if some other control is clicked on.
    GestureBinding.instance!.pointerRouter.addGlobalRoute(_handlePointerEvent);
  }

  Duration _getDefaultShowDuration() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const Duration(seconds: 10);
      default:
        return const Duration(milliseconds: 1500);
    }
  }

  // https://material.io/components/tooltips#specs
  double _getDefaultTooltipHeight() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return 24.0;
      default:
        return 32.0;
    }
  }

  EdgeInsets _getDefaultPadding() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const EdgeInsets.symmetric(horizontal: 8.0);
      default:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  double _getDefaultFontSize() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return 10.0;
      default:
        return 14.0;
    }
  }

  // Forces a rebuild if a mouse has been added or removed.
  void _handleMouseTrackerChange() {
    if (!mounted) {
      return;
    }
    final bool mouseIsConnected =
        RendererBinding.instance!.mouseTracker.mouseIsConnected;
    if (mouseIsConnected != _mouseIsConnected) {
      setState(() {
        _mouseIsConnected = mouseIsConnected;
      });
    }
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _hideTooltip(immediately: true);
    }
  }

  void _hideTooltip({bool immediately = false}) {
    _showTimer?.cancel();
    _showTimer = null;
    if (immediately) {
      _removeEntry();
      return;
    }
    if (_longPressActivated) {
      // Tool tips activated by long press should stay around for the showDuration.
      _hideTimer ??= Timer(showDuration, _controller.reverse);
    } else {
      // Tool tips activated by hover should disappear as soon as the mouse
      // leaves the control.
      _controller.reverse();
    }
    _longPressActivated = false;
  }

  void _showTooltip({bool immediately = false}) {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (immediately) {
      ensureTooltipVisible();
      return;
    }
    _showTimer ??= Timer(waitDuration, ensureTooltipVisible);
  }

  /// Shows the tooltip if it is not already visible.
  ///
  /// Returns `false` when the tooltip was already visible or if the context has
  /// become null.
  bool ensureTooltipVisible() {
    _showTimer?.cancel();
    _showTimer = null;
    if (_entry != null) {
      // Stop trying to hide, if we were.
      _hideTimer?.cancel();
      _hideTimer = null;
      _controller.forward();
      return false; // Already visible.
    }
    _createNewEntry();
    _controller.forward();
    return true;
  }

  void _createNewEntry() {
    final OverlayState overlayState = Overlay.of(
      context,
      debugRequiredFor: widget,
    )!;

    final RenderBox box = context.findRenderObject()! as RenderBox;
    Offset target = box.localToGlobal(
      box.size.center(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );
    if (_mouseIsConnected && widget.useMousePosition && mousePosition != null) {
      target = mousePosition!;
    }

    // We create this widget outside of the overlay entry's builder to prevent
    // updated values from happening to leak into the overlay when the overlay
    // rebuilds.
    final Widget overlay = Directionality(
      textDirection: Directionality.of(context),
      child: _TooltipOverlay(
        message: widget.message,
        height: height,
        padding: padding,
        margin: margin,
        decoration: decoration,
        textStyle: textStyle,
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.fastOutSlowIn,
        ),
        target: target,
        verticalOffset: verticalOffset,
        preferBelow: preferBelow,
      ),
    );
    _entry = OverlayEntry(builder: (BuildContext context) => overlay);
    overlayState.insert(_entry!);
    SemanticsService.tooltip(widget.message);
  }

  void _removeEntry() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _showTimer?.cancel();
    _showTimer = null;
    _entry?.remove();
    _entry = null;
  }

  void _handlePointerEvent(PointerEvent event) {
    if (_entry == null) {
      return;
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _hideTooltip();
    } else if (event is PointerDownEvent) {
      _hideTooltip(immediately: true);
    }
  }

  @override
  void deactivate() {
    if (_entry != null) {
      _hideTooltip(immediately: true);
    }
    _showTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    GestureBinding.instance!.pointerRouter
        .removeGlobalRoute(_handlePointerEvent);
    RendererBinding.instance!.mouseTracker
        .removeListener(_handleMouseTrackerChange);
    if (_entry != null) _removeEntry();
    _controller.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    _longPressActivated = true;
    final bool tooltipCreated = ensureTooltipVisible();
    if (tooltipCreated) Feedback.forLongPress(context);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMacosTheme(context));
    assert(Overlay.of(context, debugRequiredFor: widget) != null);
    final MacosThemeData theme = MacosTheme.of(context);
    final tooltipTheme = theme.tooltipTheme.copyWith();
    final TextStyle? defaultTextStyle;
    final BoxDecoration defaultDecoration;
    if (theme.brightness == Brightness.dark) {
      defaultTextStyle = theme.typography.body.copyWith(
        color: CupertinoColors.black,
        fontSize: _getDefaultFontSize(),
      );
      defaultDecoration = BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      );
    } else {
      defaultTextStyle = theme.typography.body.copyWith(
        color: CupertinoColors.white,
        fontSize: _getDefaultFontSize(),
      );
      defaultDecoration = BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.9),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      );
    }

    height = tooltipTheme.height ?? _getDefaultTooltipHeight();
    padding = tooltipTheme.padding ?? _getDefaultPadding();
    margin = tooltipTheme.margin ?? _defaultMargin;
    verticalOffset = tooltipTheme.verticalOffset ?? _defaultVerticalOffset;
    preferBelow = tooltipTheme.preferBelow ?? _defaultPreferBelow;
    excludeFromSemantics = widget.excludeFromSemantics;
    decoration = tooltipTheme.decoration ?? defaultDecoration;
    textStyle = tooltipTheme.textStyle ?? defaultTextStyle;
    waitDuration = tooltipTheme.waitDuration ?? _defaultWaitDuration;
    showDuration = tooltipTheme.showDuration ?? _getDefaultShowDuration();

    Widget result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: _handleLongPress,
      excludeFromSemantics: true,
      child: Semantics(
        label: excludeFromSemantics ? null : widget.message,
        child: widget.child,
      ),
    );

    // Only check for hovering if there is a mouse connected.
    if (_mouseIsConnected) {
      result = MouseRegion(
        onEnter: (PointerEnterEvent event) => _showTooltip(),
        onExit: (PointerExitEvent event) => _hideTooltip(),
        onHover: (PointerHoverEvent event) {
          mousePosition = event.position;
        },
        child: result,
      );
    }

    return result;
  }
}

class TooltipThemeData with Diagnosticable {
  const TooltipThemeData({
    this.height,
    this.verticalOffset,
    this.padding,
    this.margin,
    this.preferBelow,
    this.decoration,
    this.showDuration,
    this.waitDuration,
    this.textStyle,
  });

  /// Creates a default tooltip theme.
  ///
  /// [textStyle] is usually [MacosTypography.caption2]
  factory TooltipThemeData.standard({
    required Brightness brightness,
    required TextStyle textStyle,
  }) {
    return TooltipThemeData(
      height: 32.0,
      verticalOffset: 24.0,
      preferBelow: false,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      waitDuration: const Duration(seconds: 1),
      textStyle: textStyle,
      decoration: () {
        const radius = BorderRadius.zero;
        final shadow = kElevationToShadow[4];
        if (brightness == Brightness.light) {
          return BoxDecoration(
            color: CupertinoColors.systemGrey6.color,
            borderRadius: radius,
            boxShadow: shadow,
          );
        } else {
          return BoxDecoration(
            color: CupertinoColors.systemGrey6.darkColor,
            borderRadius: radius,
            boxShadow: shadow,
          );
        }
      }(),
    );
  }

  /// Copy this tooltip with [style]
  TooltipThemeData copyWith({
    BoxDecoration? decoration,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    bool? preferBelow,
    Duration? showDuration,
    TextStyle? testStyle,
    double? verticalOffset,
    Duration? waitDuration,
  }) {
    return TooltipThemeData(
      decoration: decoration ?? this.decoration,
      height: height ?? this.height,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      preferBelow: preferBelow ?? this.preferBelow,
      showDuration: showDuration ?? this.showDuration,
      textStyle: textStyle ?? this.textStyle,
      verticalOffset: verticalOffset ?? this.verticalOffset,
      waitDuration: waitDuration ?? this.waitDuration,
    );
  }

  /// The height of the tooltip's [child].
  ///
  /// If the [child] is null, then this is the tooltip's intrinsic height.
  final double? height;

  /// The vertical gap between the widget and the displayed tooltip.
  ///
  /// When [preferBelow] is set to true and tooltips have sufficient space
  /// to display themselves, this property defines how much vertical space
  /// tooltips will position themselves under their corresponding widgets.
  /// Otherwise, tooltips will position themselves above their corresponding
  /// widgets with the given offset.
  final double? verticalOffset;

  /// The amount of space by which to inset the tooltip's [child].
  ///
  /// Defaults to 10.0 logical pixels in each direction.
  final EdgeInsetsGeometry? padding;

  /// The empty space that surrounds the tooltip.
  ///
  /// Defines the tooltip's outer [Container.margin]. By default, a long
  /// tooltip will span the width of its window. If long enough, a tooltip
  /// might also span the window's height. This property allows one to define
  /// how much space the tooltip must be inset from the edges of their display
  /// window.
  final EdgeInsetsGeometry? margin;

  /// Whether the tooltip defaults to being displayed below the widget.
  ///
  /// Defaults to true. If there is insufficient space to display the tooltip
  /// in the preferred direction, the tooltip will be displayed in the opposite
  /// direction.
  final bool? preferBelow;

  /// Specifies the tooltip's shape and background color.
  ///
  /// The tooltip shape defaults to a rounded rectangle with a border radius of 4.0.
  /// Tooltips will also default to an opacity of 90% and with the color [CupertinoColors.systemGrey]
  /// if [ThemeData.brightness] is [Brightness.dark], and [CupertinoColors.white] if
  /// it is [Brightness.light].
  final Decoration? decoration;

  /// The length of time that a pointer must hover over a tooltip's widget before
  /// the tooltip will be shown.
  ///
  /// Once the pointer leaves the widget, the tooltip will immediately disappear.
  ///
  /// Defaults to 0 milliseconds (tooltips are shown immediately upon hover).
  final Duration? waitDuration;

  /// The length of time that the tooltip will be shown after a long press is released.
  ///
  /// If on desktop, defaults to 10 seconds, otherwise, defaults to 1.5 seconds.
  final Duration? showDuration;

  /// The style to use for the message of the tooltip.
  ///
  /// If null, [MacosTypography.caption] is used
  final TextStyle? textStyle;

  /// Linearly interpolate between two tooltip themes.
  ///
  /// All the properties must be non-null.
  static TooltipThemeData lerp(
    TooltipThemeData a,
    TooltipThemeData b,
    double t,
  ) {
    return TooltipThemeData(
      decoration: Decoration.lerp(a.decoration, b.decoration, t),
      height: t < 0.5 ? a.height : b.height,
      margin: EdgeInsetsGeometry.lerp(a.margin, b.margin, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      preferBelow: t < 0.5 ? a.preferBelow : b.preferBelow,
      showDuration: t < 0.5 ? a.showDuration : b.showDuration,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      verticalOffset: t < 0.5 ? a.verticalOffset : b.verticalOffset,
      waitDuration: t < 0.5 ? a.waitDuration : b.waitDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TooltipThemeData &&
          runtimeType == other.runtimeType &&
          height == other.height &&
          verticalOffset == other.verticalOffset &&
          padding == other.padding &&
          margin == other.margin &&
          preferBelow == other.preferBelow &&
          decoration == other.decoration &&
          waitDuration == other.waitDuration &&
          showDuration == other.showDuration &&
          textStyle == other.textStyle;

  @override
  int get hashCode =>
      height.hashCode ^
      verticalOffset.hashCode ^
      padding.hashCode ^
      margin.hashCode ^
      preferBelow.hashCode ^
      decoration.hashCode ^
      waitDuration.hashCode ^
      showDuration.hashCode ^
      textStyle.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height));
    properties.add(DoubleProperty('verticalOffset', verticalOffset));
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin),
    );
    properties.add(FlagProperty(
      'preferBelow',
      value: preferBelow,
      ifFalse: 'prefer above',
    ));
    properties.add(DiagnosticsProperty<Decoration>('decoration', decoration));
    properties.add(DiagnosticsProperty<Duration>('waitDuration', waitDuration));
    properties.add(DiagnosticsProperty<Duration>('showDuration', showDuration));
    properties.add(DiagnosticsProperty<TextStyle>('textStyle', textStyle));
  }
}

/// A delegate for computing the layout of a tooltip to be displayed above or
/// bellow a target specified in the global coordinate system.
class _TooltipPositionDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate for computing the layout of a tooltip.
  ///
  /// The arguments must not be null.
  const _TooltipPositionDelegate({
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
  });

  /// The offset of the target the tooltip is positioned near in the global
  /// coordinate system.
  final Offset target;

  /// The amount of vertical distance between the target and the displayed
  /// tooltip.
  final double verticalOffset;

  /// Whether the tooltip is displayed below its widget by default.
  ///
  /// If there is insufficient space to display the tooltip in the preferred
  /// direction, the tooltip will be displayed in the opposite direction.
  final bool preferBelow;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return positionDependentBox(
      size: size,
      childSize: childSize,
      target: target,
      verticalOffset: verticalOffset,
      preferBelow: preferBelow,
    );
  }

  @override
  bool shouldRelayout(_TooltipPositionDelegate oldDelegate) {
    return target != oldDelegate.target ||
        verticalOffset != oldDelegate.verticalOffset ||
        preferBelow != oldDelegate.preferBelow;
  }
}

class _TooltipOverlay extends StatelessWidget {
  const _TooltipOverlay({
    Key? key,
    required this.message,
    required this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.textStyle,
    required this.animation,
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
  }) : super(key: key);

  final String message;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final Animation<double> animation;
  final Offset target;
  final double verticalOffset;
  final bool preferBelow;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomSingleChildLayout(
          delegate: _TooltipPositionDelegate(
            target: target,
            verticalOffset: verticalOffset,
            preferBelow: preferBelow,
          ),
          child: FadeTransition(
            opacity: animation,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: DefaultTextStyle(
                style: MacosTheme.of(context).typography.body,
                child: Container(
                  decoration: decoration,
                  padding: padding,
                  margin: margin,
                  child: Center(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Text(
                      message,
                      style: textStyle,
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
