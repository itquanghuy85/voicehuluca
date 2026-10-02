import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> cardHover = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> elevatedHigh = [
    BoxShadow(color: Color(0x26000000), blurRadius: 32, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(color: Color(0x1A6366F1), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> buttonPressed = [
    BoxShadow(color: Color(0x0D6366F1), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> cardDark = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> elevatedDark = [
    BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> fab = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> fabDark = [
    BoxShadow(color: Color(0x26000000), blurRadius: 12, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> dropdown = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> dropdownDark = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 32, offset: Offset(0, 16)),
  ];

  static const List<BoxShadow> modalDark = [
    BoxShadow(color: Color(0x2E000000), blurRadius: 32, offset: Offset(0, 16)),
  ];

  static const List<BoxShadow> tooltip = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> tooltipDark = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];
}
