import 'package:flutter/widgets.dart';

/// The rectangle a share sheet should be anchored to.
///
/// iPad needs `sharePositionOrigin` and `share_plus` throws without it; iPhone
/// ignores the value. Anchoring to the screen keeps the popover on the device
/// instead of throwing at the last step of a share.
Rect? shareOriginOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}