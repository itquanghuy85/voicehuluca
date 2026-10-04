import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = AppColorScheme.of(brightness);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.toColorScheme(brightness),
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: AppTypography.textTheme(
        colorScheme.textPrimary,
        colorScheme.textSecondary,
        colorScheme.textTertiary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTypography.title,
        toolbarHeight: AppSizes.appBarHeight,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeAll,
          side: BorderSide(color: colorScheme.divider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(0, AppSizes.buttonMedium),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          elevation: 0,
          textStyle: AppTypography.label,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(0, AppSizes.buttonMedium),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          side: BorderSide(color: colorScheme.divider),
          textStyle: AppTypography.label,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(0, AppSizes.buttonMedium),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: AppTypography.label,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(color: colorScheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(color: colorScheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: AppTypography.body.copyWith(color: colorScheme.textTertiary),
        labelStyle: AppTypography.body.copyWith(
          color: colorScheme.textSecondary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.divider,
        thickness: AppSizes.dividerThickness,
        space: AppSizes.dividerHeight,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.textSecondary,
        size: AppSizes.iconLarge,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.textSecondary,
        textColor: colorScheme.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minVerticalPadding: AppSpacing.sm,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.textSecondary,
        indicatorColor: colorScheme.primary,
        labelStyle: AppTypography.label.copyWith(
          color: colorScheme.textPrimary,
        ),
        unselectedLabelStyle: AppTypography.body.copyWith(
          color: colorScheme.textSecondary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        labelStyle: AppTypography.bodySmall.copyWith(
          color: colorScheme.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pillAll,
          side: BorderSide(color: colorScheme.divider),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colorScheme.card : colorScheme.textPrimary,
        contentTextStyle: AppTypography.body.copyWith(
          color: isDark ? colorScheme.textPrimary : colorScheme.surface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
        titleTextStyle: AppTypography.title.copyWith(
          color: colorScheme.textPrimary,
        ),
        contentTextStyle: AppTypography.body.copyWith(
          color: colorScheme.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.extraLarge),
            topRight: Radius.circular(AppRadius.extraLarge),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        focusElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );
  }
}
