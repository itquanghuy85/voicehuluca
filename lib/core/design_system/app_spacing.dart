import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static EdgeInsets get xsAll => const EdgeInsets.all(xs);
  static EdgeInsets get smAll => const EdgeInsets.all(sm);
  static EdgeInsets get mdAll => const EdgeInsets.all(md);
  static EdgeInsets get lgAll => const EdgeInsets.all(lg);
  static EdgeInsets get xlAll => const EdgeInsets.all(xl);
  static EdgeInsets get xxlAll => const EdgeInsets.all(xxl);
  static EdgeInsets get xxxlAll => const EdgeInsets.all(xxxl);

  static EdgeInsets get xsHorizontal =>
      const EdgeInsets.symmetric(horizontal: xs);
  static EdgeInsets get smHorizontal =>
      const EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get mdHorizontal =>
      const EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get lgHorizontal =>
      const EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get xlHorizontal =>
      const EdgeInsets.symmetric(horizontal: xl);
  static EdgeInsets get xxlHorizontal =>
      const EdgeInsets.symmetric(horizontal: xxl);
  static EdgeInsets get xxxlHorizontal =>
      const EdgeInsets.symmetric(horizontal: xxxl);

  static EdgeInsets get xsVertical => const EdgeInsets.symmetric(vertical: xs);
  static EdgeInsets get smVertical => const EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets get mdVertical => const EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get lgVertical => const EdgeInsets.symmetric(vertical: lg);
  static EdgeInsets get xlVertical => const EdgeInsets.symmetric(vertical: xl);
  static EdgeInsets get xxlVertical =>
      const EdgeInsets.symmetric(vertical: xxl);
  static EdgeInsets get xxxlVertical =>
      const EdgeInsets.symmetric(vertical: xxxl);

  static EdgeInsets get xsLeft => const EdgeInsets.only(left: xs);
  static EdgeInsets get smLeft => const EdgeInsets.only(left: sm);
  static EdgeInsets get mdLeft => const EdgeInsets.only(left: md);
  static EdgeInsets get lgLeft => const EdgeInsets.only(left: lg);

  static EdgeInsets get xsRight => const EdgeInsets.only(right: xs);
  static EdgeInsets get smRight => const EdgeInsets.only(right: sm);
  static EdgeInsets get mdRight => const EdgeInsets.only(right: md);
  static EdgeInsets get lgRight => const EdgeInsets.only(right: lg);

  static EdgeInsets get xsTop => const EdgeInsets.only(top: xs);
  static EdgeInsets get smTop => const EdgeInsets.only(top: sm);
  static EdgeInsets get mdTop => const EdgeInsets.only(top: md);
  static EdgeInsets get lgTop => const EdgeInsets.only(top: lg);

  static EdgeInsets get xsBottom => const EdgeInsets.only(bottom: xs);
  static EdgeInsets get smBottom => const EdgeInsets.only(bottom: sm);
  static EdgeInsets get mdBottom => const EdgeInsets.only(bottom: md);
  static EdgeInsets get lgBottom => const EdgeInsets.only(bottom: lg);
}
