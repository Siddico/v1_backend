import 'package:flutter/material.dart';
import '../../../domain/entities/notification_entity.dart';
import 'notification_message_item_widget.dart';

class NotificationPopup {
  NotificationPopup._();

  static void show(BuildContext context, NotificationEntity notification) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    bool removed = false;

    void safeRemove() {
      if (!removed && entry.mounted) {
        removed = true;
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 16,
        child: _AnimatedNotificationPopup(
          notification: notification,
          onDismissed: safeRemove,
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 4), safeRemove);
  }
}

class _AnimatedNotificationPopup extends StatefulWidget {
  final NotificationEntity notification;
  final VoidCallback onDismissed;

  const _AnimatedNotificationPopup({
    required this.notification,
    required this.onDismissed,
  });

  @override
  State<_AnimatedNotificationPopup> createState() => _AnimatedNotificationPopupState();
}

class _AnimatedNotificationPopupState extends State<_AnimatedNotificationPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  double _dragOffset = 0;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().then((_) => widget.onDismissed());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (_dismissed) return;
        setState(() => _dragOffset += details.delta.dy);
      },
      onVerticalDragEnd: (details) {
        if (_dismissed) return;
        final velocity = details.velocity.pixelsPerSecond.dy;
        // Dismiss if dragged up > 30px or flung up fast enough
        if (_dragOffset < -30 || velocity < -300) {
          _dismiss();
        } else {
          // Snap back
          setState(() => _dragOffset = 0);
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final effectiveOffset = _dragOffset < 0 ? _dragOffset : _dragOffset * 0.1; // Resist dragging down
          return Transform.translate(
            offset: Offset(0, effectiveOffset),
            child: Opacity(
              opacity: (1.0 - (effectiveOffset.abs() / 150)).clamp(0.0, 1.0) * _animation.value,
              child: child,
            ),
          );
        },
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(_animation),
          child: Material(
            color: Colors.transparent,
            child: IgnorePointer(
              ignoring: false, // Ensure inner widget can handle tap
              child: Stack(
                children: [
                  NotificationMessageItem(notification: widget.notification),
                  // Invisible overlay to catch taps and close popup before passing to NotificationMessageItem tap handler
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                         // We let the tap go through, but we also dismiss the overlay
                         _dismiss();
                         // Need a slight delay to allow the gesture to reach the child InkWell
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
