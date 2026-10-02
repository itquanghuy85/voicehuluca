import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 20.0;
  static const double pill = 999.0;

  static BorderRadius get smallAll => BorderRadius.all(Radius.circular(small));
  static BorderRadius get mediumAll =>
      BorderRadius.all(Radius.circular(medium));
  static BorderRadius get largeAll => BorderRadius.all(Radius.circular(large));
  static BorderRadius get extraLargeAll =>
      BorderRadius.all(Radius.circular(extraLarge));
  static BorderRadius get pillAll => BorderRadius.all(Radius.circular(pill));

  static BorderRadius get smallTop => const BorderRadius.only(
    topLeft: Radius.circular(small),
    topRight: Radius.circular(small),
  );
  static BorderRadius get mediumTop => const BorderRadius.only(
    topLeft: Radius.circular(medium),
    topRight: Radius.circular(medium),
  );
  static BorderRadius get largeTop => const BorderRadius.only(
    topLeft: Radius.circular(large),
    topRight: Radius.circular(large),
  );

  static BorderRadius get smallBottom => const BorderRadius.only(
    bottomLeft: Radius.circular(small),
    bottomRight: Radius.circular(small),
  );
  static BorderRadius get mediumBottom => const BorderRadius.only(
    bottomLeft: Radius.circular(medium),
    bottomRight: Radius.circular(medium),
  );
  static BorderRadius get largeBottom => const BorderRadius.only(
    bottomLeft: Radius.circular(large),
    bottomRight: Radius.circular(large),
  );

  static BorderRadius get smallLeft => const BorderRadius.only(
    topLeft: Radius.circular(small),
    bottomLeft: Radius.circular(small),
  );
  static BorderRadius get mediumLeft => const BorderRadius.only(
    topLeft: Radius.circular(medium),
    bottomLeft: Radius.circular(medium),
  );

  static BorderRadius get smallRight => const BorderRadius.only(
    topRight: Radius.circular(small),
    bottomRight: Radius.circular(small),
  );
  static BorderRadius get mediumRight => const BorderRadius.only(
    topRight: Radius.circular(medium),
    bottomRight: Radius.circular(medium),
  );
}
