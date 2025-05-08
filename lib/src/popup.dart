part of flutter_popup;

enum _ArrowDirection { top, bottom }

class CustomPopup extends StatefulWidget {
  final GlobalKey? anchorKey;
  final Widget content;
  final Widget child;
  final bool isLongPress;
  final Color? backgroundColor;
  final Color? arrowColor;
  final Color? barrierColor;
  final bool showArrow;
  final EdgeInsets contentPadding;
  final double? contentRadius;
  final BoxDecoration? contentDecoration;
  final VoidCallback? onBeforePopup;
  final ValueNotifier<dynamic>? contentNotifier;
  final Widget Function(BuildContext, dynamic)? contentBuilder;

  /// Unique identifier for the popup, used for programmatically closing it
  final String? id;

  const CustomPopup({
    super.key,
    required this.content,
    required this.child,
    this.anchorKey,
    this.isLongPress = false,
    this.backgroundColor,
    this.arrowColor,
    this.showArrow = true,
    this.barrierColor,
    this.contentPadding = const EdgeInsets.all(8),
    this.contentRadius,
    this.contentDecoration,
    this.onBeforePopup,
    this.contentNotifier,
    this.contentBuilder,
    this.id,
  });

  @override
  State<CustomPopup> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  void _show(BuildContext context) {
    final anchor = widget.anchorKey?.currentContext ?? context;
    final renderBox = anchor.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);

    widget.onBeforePopup?.call();

    Navigator.of(context).push(
      _PopupRoute(
        id: widget.id,
        targetRect: offset & renderBox.paintBounds.size,
        backgroundColor: widget.backgroundColor,
        arrowColor: widget.arrowColor,
        showArrow: widget.showArrow,
        barriersColor: widget.barrierColor,
        contentPadding: widget.contentPadding,
        contentRadius: widget.contentRadius,
        contentDecoration: widget.contentDecoration,
        child: widget.content,
        contentNotifier: widget.contentNotifier,
        contentBuilder: widget.contentBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: widget.isLongPress ? () => _show(context) : null,
      onTapUp: !widget.isLongPress ? (_) => _show(context) : null,
      child: widget.child,
    );
  }
}

class _PopupContent extends StatelessWidget {
  final Widget child;
  final GlobalKey childKey;
  final GlobalKey arrowKey;
  final _ArrowDirection arrowDirection;
  final double arrowHorizontal;
  final Color? backgroundColor;
  final Color? arrowColor;
  final bool showArrow;
  final EdgeInsets contentPadding;
  final double? contentRadius;
  final BoxDecoration? contentDecoration;

  const _PopupContent({
    Key? key,
    required this.child,
    required this.childKey,
    required this.arrowKey,
    required this.arrowHorizontal,
    required this.showArrow,
    this.arrowDirection = _ArrowDirection.top,
    this.backgroundColor,
    this.arrowColor,
    this.contentRadius,
    required this.contentPadding,
    this.contentDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          key: childKey,
          padding: contentPadding,
          margin: const EdgeInsets.symmetric(vertical: 10).copyWith(
            top: arrowDirection == _ArrowDirection.bottom ? 0 : null,
            bottom: arrowDirection == _ArrowDirection.top ? 0 : null,
          ),
          constraints: const BoxConstraints(minWidth: 50),
          // Remove any fixed height constraints to allow dynamic sizing
          decoration: contentDecoration ??
              BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(contentRadius ?? 10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
          child: child,
        ),
        Positioned(
          top: arrowDirection == _ArrowDirection.top ? 2 : null,
          bottom: arrowDirection == _ArrowDirection.bottom ? 2 : null,
          left: arrowHorizontal,
          child: RotatedBox(
            key: arrowKey,
            quarterTurns: arrowDirection == _ArrowDirection.top ? 2 : 4,
            child: CustomPaint(
              size: showArrow ? const Size(16, 8) : Size.zero,
              painter: _TrianglePainter(color: arrowColor ?? Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();
    paint.isAntiAlias = true;
    paint.color = color;

    path.lineTo(size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.58, size.height * 1.05, size.width * 0.42,
        size.height * 1.05, size.width * 0.34, size.height * 0.86);
    path.cubicTo(size.width * 0.34, size.height * 0.86, 0, 0, 0, 0);
    path.cubicTo(0, 0, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, size.width * 0.66, size.height * 0.86,
        size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.66, size.height * 0.86, size.width * 0.66,
        size.height * 0.86, size.width * 0.66, size.height * 0.86);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Widget that listens to a ValueNotifier and rebuilds its content when notifier value changes
class _RefreshableContent extends StatefulWidget {
  final ValueNotifier<dynamic> contentNotifier;
  final Widget initialChild;

  const _RefreshableContent({
    Key? key,
    required this.contentNotifier,
    required this.initialChild,
  }) : super(key: key);

  @override
  State<_RefreshableContent> createState() => _RefreshableContentState();
}

class _RefreshableContentState extends State<_RefreshableContent> {
  @override
  void initState() {
    super.initState();
    widget.contentNotifier.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    widget.contentNotifier.removeListener(_onContentChanged);
    super.dispose();
  }

  void _onContentChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.contentNotifier,
      builder: (context, value, child) {
        // Simply rebuild the widget when the value changes
        return widget.initialChild;
      },
    );
  }
}

class _PopupRoute extends PopupRoute<void> {
  final Rect targetRect;
  final Widget child;
  final ValueNotifier<dynamic>? contentNotifier;
  final Widget Function(BuildContext, dynamic)? contentBuilder;
  final String? id;

  static const double _margin = 10;
  static final Rect _viewportRect = Rect.fromLTWH(
    _margin,
    Screen.statusBar + _margin,
    Screen.width - _margin * 2,
    Screen.height - Screen.statusBar - Screen.bottomBar - _margin * 2,
  );

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _arrowKey = GlobalKey();
  final Color? backgroundColor;
  final Color? arrowColor;
  final bool showArrow;
  final Color? barriersColor;
  final EdgeInsets contentPadding;
  final double? contentRadius;
  final BoxDecoration? contentDecoration;

  // Add notifier to track layout changes
  final ValueNotifier<bool> _layoutNotifier = ValueNotifier<bool>(false);

  double _maxHeight = _viewportRect.height;
  _ArrowDirection _arrowDirection = _ArrowDirection.top;
  double _arrowHorizontal = 0;
  double _scaleAlignDx = 0.5;
  double _scaleAlignDy = 0.5;
  double? _bottom;
  double? _top;
  double? _left;
  double? _right;

  // Add timer for periodic repositioning
  Timer? _repositionTimer;

  // Generate a unique ID if one wasn't provided
  late final String _routeId;

  _PopupRoute({
    RouteSettings? settings,
    ImageFilter? filter,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    required this.child,
    required this.targetRect,
    this.backgroundColor,
    this.arrowColor,
    required this.showArrow,
    this.barriersColor,
    required this.contentPadding,
    this.contentRadius,
    this.contentDecoration,
    this.contentNotifier,
    this.contentBuilder,
    this.id,
  }) : super(
          settings: settings,
          filter: filter,
          traversalEdgeBehavior: traversalEdgeBehavior,
        ) {
    _routeId = id ?? 'popup_${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Color? get barrierColor => barriersColor ?? Colors.black.withOpacity(0.1);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Popup';

  @override
  TickerFuture didPush() {
    super.offstage = true;

    // Register this popup with the controller
    PopupController._registerPopup(_routeId, this);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _recalculatePosition();
      super.offstage = false;

      // Set up a listener for content changes
      if (contentNotifier != null) {
        contentNotifier!.addListener(_handleContentChange);
      }

      // Set up timer for periodic repositioning
      _repositionTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        _recalculatePosition();
        _layoutNotifier.value = !_layoutNotifier.value;
      });
    });
    return super.didPush();
  }

  @override
  void dispose() {
    // Clean up timer
    _repositionTimer?.cancel();
    _repositionTimer = null;

    // Clean up listeners
    if (contentNotifier != null) {
      contentNotifier!.removeListener(_handleContentChange);
    }
    _layoutNotifier.dispose();

    // Unregister from the controller
    PopupController._unregisterPopup(_routeId);

    super.dispose();
  }

  void _handleContentChange() {
    // When content changes, use multiple frame callbacks to ensure proper rendering
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // First, just update the state to render the new content without position changes
      _layoutNotifier.value = !_layoutNotifier.value;

      // Add a short delay to ensure the content has been properly rendered and measured
      Future.delayed(const Duration(milliseconds: 200), () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          // Now recalculate positions based on the new content dimensions
          _recalculatePosition();

          // Update the layout again with the new positions
          _layoutNotifier.value = !_layoutNotifier.value;
        });
      });
    });
  }

  void _recalculatePosition() {
    final childRect = _getRect(_childKey);
    final arrowRect = _getRect(_arrowKey);

    // Reset position values to avoid constraints from previous layout
    _top = null;
    _bottom = null;
    _left = null;
    _right = null;

    _calculateArrowOffset(arrowRect, childRect);
    _calculateChildOffset(childRect);
  }

  Rect? _getRect(GlobalKey key) {
    final currentContext = key.currentContext;
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || currentContext == null) return null;
    final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);
    var rect = offset & renderBox.paintBounds.size;

    if (Directionality.of(currentContext) == TextDirection.rtl) {
      rect = Rect.fromLTRB(0, rect.top, rect.right - rect.left, rect.bottom);
    }

    return rect;
  }

  // Calculate the horizontal position of the arrow
  void _calculateArrowOffset(Rect? arrowRect, Rect? childRect) {
    if (childRect == null || arrowRect == null) return;

    // Calculate where the arrow should point to (center of the target)
    final targetCenter = targetRect.center.dx;

    // The arrow position depends on the popup position
    double arrowX;

    // If popup is aligned to the left edge of screen
    if (_left == _margin) {
      // Calculate relative to the left edge of the popup
      arrowX = targetCenter - _margin - arrowRect.width / 2;
    }
    // If popup is aligned to the right edge of screen
    else if (_right == _margin) {
      // Calculate relative to the right edge of the popup
      arrowX = childRect.width -
          (Screen.width - targetCenter - _margin) -
          arrowRect.width / 2;
    }
    // If popup is horizontally centered on the target
    else {
      // Center the arrow
      arrowX = childRect.width / 2 - arrowRect.width / 2;
    }

    // Ensure the arrow doesn't go outside the popup boundaries
    final minArrowPos = 15.0;
    final maxArrowPos = childRect.width - 15.0 - arrowRect.width;

    _arrowHorizontal = arrowX.clamp(minArrowPos, maxArrowPos);
    _scaleAlignDx = (_arrowHorizontal + arrowRect.width / 2) / childRect.width;
  }

  // Calculate the position of the popover
  void _calculateChildOffset(Rect? childRect) {
    if (childRect == null) return;

    // Calculate the vertical position of the popover
    final topHeight = targetRect.top - _viewportRect.top;
    final bottomHeight = _viewportRect.bottom - targetRect.bottom;

    // Determine if there's enough space below the target
    final fitsBelow = childRect.height <= bottomHeight;

    // Prefer showing below if it fits, otherwise show above
    if (fitsBelow) {
      // Below the target
      _top = targetRect.bottom;
      _bottom = null;
      _arrowDirection = _ArrowDirection.top;
      _scaleAlignDy = 0;
    } else {
      // Above the target
      _top = null;
      _bottom = Screen.height - targetRect.top;
      _arrowDirection = _ArrowDirection.bottom;
      _scaleAlignDy = 1;
    }

    // Calculate max height based on available space in chosen direction
    if (_arrowDirection == _ArrowDirection.top) {
      _maxHeight = min(childRect.height, bottomHeight);
    } else {
      _maxHeight = min(childRect.height, topHeight);
    }

    // Calculate horizontal position
    // Center the popup relative to the target
    final left = targetRect.center.dx - (childRect.width / 2);

    // Check if it would go off screen
    if (left < _viewportRect.left) {
      // Align to left edge of viewport with margin
      _left = _margin;
      _right = null;
    } else if (left + childRect.width > _viewportRect.right) {
      // Align to right edge of viewport with margin
      _left = null;
      _right = _margin;
    } else {
      // Center align is fine
      _left = left;
      _right = null;
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Create dynamic content based on the contentNotifier if available
    Widget contentWidget;

    if (contentNotifier != null && contentBuilder != null) {
      contentWidget = ValueListenableBuilder<dynamic>(
        valueListenable: contentNotifier!,
        builder: (context, value, _) {
          return contentBuilder!(context, value);
        },
      );
    } else {
      contentWidget = child;
    }

    // Create the popup content with arrow
    Widget popupContent = _PopupContent(
      childKey: _childKey,
      arrowKey: _arrowKey,
      arrowHorizontal: _arrowHorizontal,
      arrowDirection: _arrowDirection,
      backgroundColor: backgroundColor,
      arrowColor: arrowColor,
      showArrow: showArrow,
      contentPadding: contentPadding,
      contentRadius: contentRadius,
      contentDecoration: contentDecoration,
      child: contentWidget,
    );

    // Apply transitions if animation is not completed
    if (!animation.isCompleted) {
      popupContent = FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          alignment: FractionalOffset(_scaleAlignDx, _scaleAlignDy),
          scale: animation,
          child: popupContent,
        ),
      );
    }

    // Wrap in a ValueListenableBuilder to react to layout changes
    return ValueListenableBuilder<bool>(
      valueListenable: _layoutNotifier,
      builder: (context, _, __) {
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              left: _left,
              right: _right,
              top: _top,
              bottom: _bottom,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                // constraints: BoxConstraints(
                //   maxWidth: _viewportRect.width,
                //   // Allow content to determine the height naturally, only constrain by available space
                //   maxHeight: _maxHeight,
                // ),
                // Use intrinsic height to properly size based on content
                child: IntrinsicHeight(
                  child: Material(
                    color: Colors.transparent,
                    type: MaterialType.transparency,
                    child: popupContent,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}
