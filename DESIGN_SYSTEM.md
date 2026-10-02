# Design System

VietVoice Studio's design system provides a consistent, accessible, and beautiful user experience across light and dark themes.

---

## Design Tokens

All design values are centralized in `lib/core/design_system/`:

```
lib/core/design_system/
├── design_tokens.dart    # Barrel export
├── app_colors.dart       # Color palette
├── app_typography.dart   # Font styles
├── app_spacing.dart      # Spacing scale
├── app_radius.dart       # Border radius
├── app_sizes.dart        # Component sizes
├── app_shadows.dart      # Elevation shadows
├── app_theme.dart        # ThemeData builder
├── app_motion.dart       # Animation durations
└── app_icons.dart        # Icon definitions
```

---

## Color Palette

### Brand Colors

| Token | Value | Usage |
|-------|-------|-------|
| `primary` | `#6366F1` | Primary actions, buttons, links |
| `primaryLight` | `#818CF8` | Hover states, secondary emphasis |
| `primaryDark` | `#4F46E5` | Pressed states |
| `primaryContainer` | `#E0E7FF` | Light background accents |
| `onPrimary` | `#FFFFFF` | Text on primary color |
| `onPrimaryContainer` | `#312E81` | Text on primary container |

### Secondary Colors

| Token | Value | Usage |
|-------|-------|-------|
| `secondary` | `#8B5CF6` | Secondary actions, accents |
| `secondaryLight` | `#A78BFA` | Hover states |
| `secondaryDark` | `#7C3AED` | Pressed states |
| `secondaryContainer` | `#EDE9FE` | Light background accents |

### Semantic Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `success` | `#10B981` | `#34D399` | Success messages |
| `warning` | `#F59E0B` | `#FBBF24` | Warning messages |
| `error` | `#EF4444` | `#F87171` | Error messages |
| `info` | `#3B82F6` | `#60A5FA` | Info messages |

### Light Theme Surfaces

| Token | Value | Usage |
|-------|-------|-------|
| `background` | `#F8F9FC` | Scaffold background |
| `surface` | `#FFFFFF` | AppBar, BottomNav |
| `card` | `#FFFFFF` | Card backgrounds |
| `divider` | `#E5E7EB` | Borders, dividers |
| `textPrimary` | `#111827` | Headings, body text |
| `textSecondary` | `#6B7280` | Subtitles, captions |
| `textTertiary` | `#9CA3AF` | Hints, disabled text |
| `disabled` | `#D1D5DB` | Disabled elements |

### Dark Theme Surfaces

| Token | Value | Usage |
|-------|-------|-------|
| `background` | `#0F1117` | Scaffold background |
| `surface` | `#1A1D24` | AppBar, BottomNav |
| `card` | `#1E2129` | Card backgrounds |
| `divider` | `#2D3139` | Borders, dividers |
| `textPrimary` | `#F9FAFB` | Headings, body text |
| `textSecondary` | `#9CA3AF` | Subtitles, captions |
| `textTertiary` | `#6B7280` | Hints, disabled text |
| `disabled` | `#4B5563` | Disabled elements |

### Usage in Code

```dart
// Access colors via AppColorScheme
final colors = AppColorScheme.of(Brightness.light);

Container(
  color: colors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: colors.onPrimary),
  ),
)
```

---

## Typography Scale

Uses **Inter** font via Google Fonts for optimal readability.

| Style | Size | Weight | Letter Spacing | Line Height | Usage |
|-------|------|--------|----------------|-------------|-------|
| `display` | 32px | Bold (700) | -0.5 | 1.2 | Hero text, splash |
| `headline` | 24px | SemiBold (600) | -0.3 | 1.3 | Screen titles |
| `title` | 20px | SemiBold (600) | -0.2 | 1.4 | Section headers |
| `bodyLarge` | 16px | Normal (400) | 0 | 1.5 | Large body text |
| `body` | 14px | Normal (400) | 0 | 1.5 | Default body text |
| `bodySmall` | 12px | Normal (400) | 0 | 1.5 | Captions, metadata |
| `label` | 14px | Medium (500) | 0 | 1.4 | Buttons, labels |
| `caption` | 12px | Normal (400) | 0.1 | 1.4 | Timestamps, hints |

### TextTheme Mapping

| Material Style | Custom Style | Color |
|----------------|--------------|-------|
| `displayLarge/Small` | `display` | `textPrimary` |
| `headlineLarge/Small` | `headline` | `textPrimary` |
| `titleLarge/Medium` | `title` | `textPrimary` |
| `titleSmall` | `title` | `textSecondary` |
| `bodyLarge` | `bodyLarge` | `textPrimary` |
| `bodyMedium` | `body` | `textPrimary` |
| `bodySmall` | `bodySmall` | `textSecondary` |
| `labelLarge` | `label` | `textPrimary` |
| `labelMedium` | `label` | `textSecondary` |
| `labelSmall` | `caption` | `textTertiary` |

### Usage in Code

```dart
// Direct style access
Text('Title', style: AppTypography.title)

// Via TextTheme
Text('Body', style: Theme.of(context).textTheme.bodyLarge)
```

---

## Spacing System

Base unit: **4px**

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Tight gaps, icon padding |
| `sm` | 8px | Compact spacing |
| `md` | 12px | Default internal padding |
| `lg` | 16px | Standard padding |
| `xl` | 20px | Section spacing |
| `xxl` | 24px | Large section gaps |
| `xxxl` | 32px | Screen-level spacing |

### Convenience Getters

```dart
// All sides
AppSpacing.lgAll        // EdgeInsets.all(16)

// Horizontal / Vertical
AppSpacing.lgHorizontal // EdgeInsets.symmetric(horizontal: 16)
AppSpacing.lgVertical   // EdgeInsets.symmetric(vertical: 16)

// Single side
AppSpacing.lgLeft       // EdgeInsets.only(left: 16)
AppSpacing.lgRight      // EdgeInsets.only(right: 16)
AppSpacing.lgTop        // EdgeInsets.only(top: 16)
AppSpacing.lgBottom     // EdgeInsets.only(bottom: 16)
```

---

## Radius System

| Token | Value | Usage |
|-------|-------|-------|
| `small` | 8px | Chips, small elements |
| `medium` | 12px | Buttons, inputs, cards |
| `large` | 16px | Cards, dialogs |
| `extraLarge` | 20px | Bottom sheets, large containers |
| `pill` | 999px | Avatars, pill buttons |

### Variants

```dart
// All corners
AppRadius.mediumAll

// Top only (for cards in lists)
AppRadius.largeTop

// Bottom only
AppRadius.largeBottom

// Left / Right only
AppRadius.mediumLeft
AppRadius.mediumRight
```

---

## Component Sizes

### Buttons

| Size | Height | Usage |
|------|--------|-------|
| `buttonSmall` | 36px | Compact buttons, chips |
| `buttonMedium` | 44px | Default buttons |
| `buttonLarge` | 52px | Prominent CTAs |

### Icons

| Size | Value | Usage |
|------|-------|-------|
| `iconSmall` | 16px | Inline icons |
| `iconMedium` | 20px | List tile icons |
| `iconLarge` | 24px | AppBar actions |
| `iconExtraLarge` | 32px | Feature icons |

### Touch Targets

| Size | Value | Usage |
|------|-------|-------|
| `touchTarget` | 44px | Minimum tap target |
| `touchTargetLarge` | 48px | Comfortable tap target |

### Other Components

| Component | Value |
|-----------|-------|
| `appBarHeight` | 56px |
| `bottomNavHeight` | 64px |
| `tabBarHeight` | 48px |
| `listTileHeight` | 56px |
| `cardMinHeight` | 80px |
| `inputHeight` | 48px |
| `inputLargeHeight` | 56px |
| `fabSize` | 56px |
| `fabMiniSize` | 40px |
| `avatarSmall` | 32px |
| `avatarMedium` | 40px |
| `avatarLarge` | 56px |
| `avatarExtraLarge` | 80px |

---

## Shadow System

### Light Theme Shadows

| Token | Blur | Offset | Color | Usage |
|-------|------|--------|-------|-------|
| `card` | 8px | (0, 2) | 6% black | Default cards |
| `cardHover` | 16px | (0, 4) | 8% black | Card hover state |
| `elevated` | 24px | (0, 8) | 10% black | Elevated cards |
| `elevatedHigh` | 32px | (0, 12) | 15% black | High elevation |
| `button` | 8px | (0, 4) | 10% primary | Primary buttons |
| `buttonPressed` | 4px | (0, 2) | 5% primary | Pressed buttons |
| `fab` | 12px | (0, 6) | 10% black | FAB |
| `dropdown` | 16px | (0, 4) | 8% black | Dropdown menus |
| `modal` | 32px | (0, 16) | 10% black | Dialogs |
| `tooltip` | 4px | (0, 2) | 5% black | Tooltips |

### Dark Theme Shadows

Dark theme shadows use higher opacity for visibility:

| Token | Blur | Offset | Color |
|-------|------|--------|-------|
| `cardDark` | 8px | (0, 2) | 10% black |
| `elevatedDark` | 24px | (0, 8) | 15% black |
| `fabDark` | 12px | (0, 6) | 15% black |
| `dropdownDark` | 16px | (0, 4) | 12% black |
| `modalDark` | 32px | (0, 16) | 18% black |
| `tooltipDark` | 4px | (0, 2) | 10% black |

---

## Button System

### Button Types

| Type | Style | Usage |
|------|-------|-------|
| **ElevatedButton** | Primary filled | Main CTAs |
| **OutlinedButton** | Bordered, transparent bg | Secondary actions |
| **TextButton** | No border, no bg | Tertiary actions |
| **FloatingActionButton** | Circular, elevated | Primary action per screen |
| **IconButton** | Icon only | AppBar actions, toolbars |

### Button Theme

```dart
// ElevatedButton
ElevatedButton(
  onPressed: () {},
  child: Text('Generate'),
)
// Style: primary bg, white text, 12px radius, 44px height

// OutlinedButton
OutlinedButton(
  onPressed: () {},
  child: Text('Cancel'),
)
// Style: transparent bg, primary text, 12px radius, 44px height

// TextButton
TextButton(
  onPressed: () {},
  child: Text('Learn more'),
)
// Style: no bg, primary text, 12px radius, 44px height
```

### Button States

| State | Visual |
|-------|--------|
| Default | As defined above |
| Pressed | `buttonPressed` shadow |
| Disabled | `disabled` color, no shadow |
| Loading | Progress indicator replaces text |

---

## Card System

### Card Theme

```dart
Card(
  child: Padding(
    padding: AppSpacing.lgAll,
    child: Text('Card content'),
  ),
)
// Style: card bg, 16px radius, 1px divider border, no elevation
```

### Card Variants

| Variant | Border | Shadow | Usage |
|---------|--------|--------|-------|
| **Default** | 1px divider | None | Standard content cards |
| **Elevated** | None | `card` shadow | Featured content |
| **Interactive** | 1px divider | `cardHover` on hover | Tappable cards |
| **Outlined** | 1px primary | None | Selection indicators |

### Card Spacing

```dart
// Standard card padding
Padding(
  padding: AppSpacing.lgAll,  // 16px all sides
  child: content,
)

// Compact card padding
Padding(
  padding: AppSpacing.mdAll,  // 12px all sides
  child: content,
)
```

---

## Theme Configuration

### Material 3

The app uses Material 3 (`useMaterial3: true`) with custom color scheme:

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: colorScheme.toColorScheme(brightness),
  scaffoldBackgroundColor: colorScheme.background,
  textTheme: AppTypography.textTheme(...),
  // ... component themes
)
```

### Theme Modes

| Mode | Behavior |
|------|----------|
| `system` | Follows device setting (default) |
| `light` | Always light theme |
| `dark` | Always dark theme |

### Custom Component Themes

The theme configures all Material components:

- `appBarTheme` — Surface bg, no elevation, centered title
- `cardTheme` — Card bg, 16px radius, divider border
- `elevatedButtonTheme` — Primary bg, 12px radius
- `outlinedButtonTheme` — Divider border, 12px radius
- `textButtonTheme` — Primary text, 12px radius
- `inputDecorationTheme` — Filled, 12px radius
- `bottomNavigationBarTheme` — Surface bg, primary selected
- `tabBarTheme` — Primary indicator
- `chipTheme` — Pill shape, surface bg
- `snackBarTheme` — Floating, adaptive colors
- `dialogTheme` — Surface bg, 16px radius
- `bottomSheetTheme` — Surface bg, 20px top radius
- `floatingActionButtonTheme` — Primary bg, 16px radius

---

## Accessibility

### Color Contrast

All color combinations meet WCAG 2.1 AA standards:

- Text on background: **4.5:1** minimum
- Large text on background: **3:1** minimum
- UI components: **3:1** minimum

### Touch Targets

All interactive elements are at least **44x44px** (Apple HIG) or **48x48px** (Material).

### Font Scaling

The app respects system font size settings. Test with:
- Small (0.85x)
- Default (1.0x)
- Large (1.15x)
- Extra Large (1.3x)
