import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/localization/app_strings.dart';
import '../../core/network/backend_discovery.dart';
import '../../core/network/backend_endpoint.dart';
import '../../data/services/tts_provider.dart';
import '../voice/voice_provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _backendController = TextEditingController();
  final LanBackendScanner _scanner = const LanBackendScanner();
  bool _isScanning = false;
  bool _isChecking = false;
  int _scannedHosts = 0;
  int _scanTotal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).loadSettings();
      // The stored address may still be loading, so seed the field now and let
      // the listener in build() keep it in sync afterwards.
      _backendController.text = ref.read(backendUrlProvider);
    });
  }

  @override
  void dispose() {
    _backendController.dispose();
    super.dispose();
  }

  String _formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showThemeSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(AppStrings.settingsTheme),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateTheme('system');
              Navigator.pop(context);
            },
            child: const Text(AppStrings.settingsThemeSystem),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateTheme('light');
              Navigator.pop(context);
            },
            child: const Text(AppStrings.settingsThemeLight),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateTheme('dark');
              Navigator.pop(context);
            },
            child: const Text(AppStrings.settingsThemeDark),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.settingsCancel),
        ),
      ),
    );
  }

  void _showVoiceSelector() {
    final voices = ref.read(settingsProvider).voices;
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(AppStrings.settingsDefaultVoice),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateDefaultVoice(null);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.settingsNoVoices),
          ),
          ...voices.map(
            (voice) => CupertinoActionSheetAction(
              onPressed: () {
                ref
                    .read(settingsProvider.notifier)
                    .updateDefaultVoice(voice.id);
                Navigator.pop(context);
              },
              child: Text(voice.name),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.settingsCancel),
        ),
      ),
    );
  }

  void _showSpeedSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(AppStrings.settingsDefaultSpeed),
        actions: AppConstants.supportedSpeechRates.map((speed) {
          return CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateDefaultSpeed(speed);
              Navigator.pop(context);
            },
            child: Text('${speed}x'),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.settingsCancel),
        ),
      ),
    );
  }

  void _showFormatSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(AppStrings.settingsDefaultFormat),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateDefaultFormat('mp3');
              Navigator.pop(context);
            },
            child: const Text('MP3'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateDefaultFormat('wav');
              Navigator.pop(context);
            },
            child: const Text('WAV'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.settingsCancel),
        ),
      ),
    );
  }

  void _showThresholdSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(AppStrings.settingsWarningThreshold),
        actions: [100, 500, 1000, 5000, 10000].map((threshold) {
          return CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .updateWarningThreshold(threshold);
              Navigator.pop(context);
            },
            child: Text('$threshold credits'),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.settingsCancel),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(AppStrings.settingsClearCacheConfirm),
        content: const Text(AppStrings.settingsClearCacheDesc),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.settingsCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(settingsProvider.notifier).clearCache();
              Navigator.pop(context);
              _showSnackBar(AppStrings.settingsCacheCleared);
            },
            child: const Text(AppStrings.settingsConfirm),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(AppStrings.settingsDeleteAllConfirm),
        content: const Text(AppStrings.settingsDeleteAllDesc),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.settingsCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(settingsProvider.notifier).deleteAllData();
              Navigator.pop(context);
              _showSnackBar(AppStrings.settingsDeleteAllSuccess);
            },
            child: const Text(AppStrings.settingsConfirm),
          ),
        ],
      ),
    );
  }

  void _showConnectServiceDialog() {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(AppStrings.settingsConnectService),
        content: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: CupertinoTextField(
            controller: controller,
            placeholder: AppStrings.settingsApiKeyHint,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.settingsCancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(settingsProvider.notifier)
                    .saveApiKey(controller.text.trim());
                Navigator.pop(context);
                _showSnackBar(AppStrings.settingsApiKeySaved);
              }
            },
            child: const Text(AppStrings.settingsSave),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final colorScheme = AppColorScheme.of(Theme.of(context).brightness);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        duration: AppConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final colorScheme = AppColorScheme.of(Theme.of(context).brightness);

    // Picking a server from the LAN sheet changes the provider; mirror it here.
    ref.listen<String>(backendUrlProvider, (_, next) {
      if (next != _backendController.text) {
        _backendController.text = next;
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            Expanded(child: _buildContent(state, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.settingsTitle,
              style: AppTypography.headline.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SettingsState state, AppColorScheme colorScheme) {
    if (state.isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        _buildVoiceServiceSection(state, colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildBackendSection(colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildTtsProviderSection(state, colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildDefaultVoiceSection(state, colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildDefaultSpeedSection(state, colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildDefaultFormatSection(state, colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildThemeSection(state, colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildTextProcessingSection(state, colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildCostWarningSection(state, colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildStorageSection(state, colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildAboutSection(colorScheme),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
    AppColorScheme? colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme?.card,
        borderRadius: AppRadius.largeAll,
        border: Border.all(color: colorScheme?.divider ?? Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.label.copyWith(
              color: colorScheme?.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme?.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  /// Lets the user point the app at the machine that runs the backend, either by
  /// typing its address or by letting the app find it on the same Wi-Fi.
  Widget _buildBackendSection(AppColorScheme colorScheme) {
    final activeUrl = ref.watch(backendUrlProvider);
    // A build without --dart-define carries no address, so "no address" and
    // "the address this build was compiled with" are both just an empty string.
    final notConfigured = activeUrl.isEmpty;
    final usingDefault = notConfigured || activeUrl == AppConstants.apiBaseUrl;

    return _buildSection(
      title: AppStrings.settingsBackendTitle,
      description: AppStrings.settingsBackendDesc,
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _backendController,
            placeholder: AppStrings.settingsBackendUrlHint,
            keyboardType: TextInputType.url,
            autocorrect: false,
            onSubmitted: (_) => _saveBackendUrl(),
            style: AppTypography.body.copyWith(color: colorScheme.textPrimary),
            placeholderStyle: AppTypography.body.copyWith(
              color: colorScheme.textTertiary,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AppRadius.mediumAll,
              border: Border.all(color: colorScheme.divider),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                AppIcons.server,
                size: AppSizes.iconSmall,
                color: colorScheme.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  notConfigured
                      ? AppStrings.settingsBackendNotSet
                      : usingDefault
                      ? '${AppStrings.settingsBackendCurrent}: $activeUrl'
                      : activeUrl,
                  style: AppTypography.bodySmall.copyWith(
                    color: notConfigured
                        ? colorScheme.error
                        : colorScheme.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: _isScanning ? null : _scanLan,
                  color: colorScheme.primary,
                  borderRadius: AppRadius.mediumAll,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    _isScanning
                        ? AppStrings.fill(AppStrings.settingsBackendScanning, [
                            _scannedHosts,
                            _scanTotal,
                          ])
                        : AppStrings.settingsBackendScan,
                    style: AppTypography.label.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CupertinoButton(
                  onPressed: _isChecking ? null : _checkBackendUrl,
                  color: colorScheme.surface,
                  borderRadius: AppRadius.mediumAll,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: _isChecking
                      ? const CupertinoActivityIndicator()
                      : Text(
                          AppStrings.settingsBackendCheck,
                          style: AppTypography.label.copyWith(
                            color: colorScheme.textPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: _saveBackendUrl,
                  color: colorScheme.secondary,
                  borderRadius: AppRadius.mediumAll,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    AppStrings.settingsBackendSave,
                    style: AppTypography.label.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (!notConfigured)
                CupertinoButton(
                  onPressed: _resetBackendUrl,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    AppStrings.settingsBackendReset,
                    style: AppTypography.label.copyWith(
                      color: colorScheme.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveBackendUrl() async {
    final parsed = BackendEndpoint.parse(_backendController.text);
    if (parsed.url == null) {
      _showSnackBar(
        parsed.message ?? BackendEndpoint.invalidMessage,
        isError: true,
      );
      return;
    }
    await ref.read(backendUrlProvider.notifier).setUrl(parsed.url!);
    _backendController.text = parsed.url!;
    _showSnackBar(AppStrings.settingsBackendSaved);
    // Reload the voice list against the new server straight away.
    ref.invalidate(voiceListProvider);
  }

  Future<void> _resetBackendUrl() async {
    await ref.read(backendUrlProvider.notifier).reset();
    _backendController.text = AppConstants.apiBaseUrl;
    _showSnackBar(AppStrings.settingsBackendSaved);
    ref.invalidate(voiceListProvider);
  }

  /// Pings whatever is in the field without saving it.
  Future<void> _checkBackendUrl() async {
    final parsed = BackendEndpoint.parse(_backendController.text);
    if (parsed.url == null) {
      _showSnackBar(
        parsed.message ?? BackendEndpoint.invalidMessage,
        isError: true,
      );
      return;
    }
    setState(() => _isChecking = true);
    final latency = await _scanner.ping(parsed.url!);
    if (!mounted) return;
    setState(() => _isChecking = false);
    _showSnackBar(
      latency == null
          ? AppStrings.settingsBackendCheckFailed
          : AppStrings.fill(AppStrings.settingsBackendCheckOk, [latency]),
      isError: latency == null,
    );
  }

  /// Walks the local /24 and offers every backend that answers.
  Future<void> _scanLan() async {
    final addresses = await LanBackendScanner.localAddresses();
    if (addresses.isEmpty) {
      await _showScanFailure(AppStrings.settingsBackendScanNoAddress);
      return;
    }

    setState(() {
      _isScanning = true;
      _scannedHosts = 0;
      _scanTotal = 0;
    });

    final found = await _scanner.scan(
      addresses: addresses,
      onProgress: (checked, total) {
        if (mounted) {
          setState(() {
            _scannedHosts = checked;
            _scanTotal = total;
          });
        }
      },
    );

    if (!mounted) return;
    setState(() => _isScanning = false);
    if (found.isEmpty) {
      await _showScanFailure(
        AppStrings.settingsBackendScanNone,
        tried: addresses.join(', '),
      );
      return;
    }
    _showDiscoveredSheet(found);
  }

  /// A failed scan has to say what the platform reported, otherwise the user
  /// cannot tell a missing permission from a missing server. Manual entry stays
  /// available in every one of these cases.
  Future<void> _showScanFailure(String message, {String? tried}) async {
    final report = await LanBackendScanner.interfaceReport();
    if (!mounted) return;
    _showSnackBar(
      [
        message,
        AppStrings.settingsBackendScanLocalNetwork,
        if (tried != null)
          AppStrings.fill(AppStrings.settingsBackendScanTried, [tried]),
        AppStrings.fill(AppStrings.settingsBackendScanIfaceReport, [report]),
        AppStrings.settingsBackendScanManualHint,
      ].join('\n'),
      isError: true,
    );
  }

  void _showDiscoveredSheet(List<DiscoveredBackend> found) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(AppStrings.settingsBackendScanTitle),
        message: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(AppStrings.settingsBackendScanHint),
        ),
        actions: [
          for (final server in found)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _backendController.text = server.baseUrl;
                _saveBackendUrl();
              },
              child: Text(
                '${server.baseUrl}  ·  ${server.latencyMs} ms',
                style: AppTypography.body,
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(
            AppStrings.settingsBackendClose,
            style: AppTypography.label,
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceServiceSection(
    SettingsState state,
    AppColorScheme colorScheme,
  ) {
    final activeProvider = ref
        .read(ttsProviderRegistryProvider)
        .resolve(state.ttsProviderId);
    return _buildSection(
      title: AppStrings.settingsVoiceService,
      description: AppStrings.settingsVoiceServiceDesc,
      colorScheme: colorScheme,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                AppIcons.voice,
                size: AppSizes.iconMedium,
                color: colorScheme.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  activeProvider.name,
                  style: AppTypography.body.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: state.isConnected
                      ? colorScheme.success.withOpacity(0.1)
                      : colorScheme.error.withOpacity(0.1),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  state.isConnected
                      ? AppStrings.settingsConnected
                      : AppStrings.settingsNotConnected,
                  style: AppTypography.bodySmall.copyWith(
                    color: state.isConnected
                        ? colorScheme.success
                        : colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.isUsageLoading)
            const Center(child: CupertinoActivityIndicator())
          else if (state.usage != null)
            _buildUsageBlock(state, colorScheme)
          else
            Text(
              AppStrings.providerUsageUnavailable,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: state.isTestingConnection
                      ? null
                      : () async {
                          final success = await ref
                              .read(settingsProvider.notifier)
                              .testConnection();
                          _showSnackBar(
                            success
                                ? AppStrings.settingsConnectionSuccess
                                : AppStrings.settingsConnectionFailed,
                          );
                        },
                  color: colorScheme.primary,
                  borderRadius: AppRadius.mediumAll,
                  child: state.isTestingConnection
                      ? const CupertinoActivityIndicator()
                      : Text(
                          AppStrings.settingsTestConnection,
                          style: AppTypography.label.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              if (!state.hasApiKey) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CupertinoButton(
                    onPressed: _showConnectServiceDialog,
                    color: colorScheme.secondary,
                    borderRadius: AppRadius.mediumAll,
                    child: Text(
                      AppStrings.settingsConnectService,
                      style: AppTypography.label.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBlock(SettingsState state, AppColorScheme colorScheme) {
    final usage = state.usage!;
    final used = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(usage.charactersUsed);
    final limit = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(usage.charactersLimit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.providerUsageCharacters,
          style: AppTypography.caption.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$used / $limit',
          style: AppTypography.label.copyWith(color: colorScheme.textPrimary),
        ),
        if (usage.tier != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            usage.tier!,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTtsProviderSection(
    SettingsState state,
    AppColorScheme colorScheme,
  ) {
    final registry = ref.read(ttsProviderRegistryProvider);
    final selected = state.ttsProviderId;
    // Real readiness from the backend (null = not known yet, e.g. offline).
    final availability = ref.watch(providerAvailabilityProvider).valueOrNull;

    return _buildSection(
      title: AppStrings.providerSectionTitle,
      description: AppStrings.providerSectionDesc,
      colorScheme: colorScheme,
      child: Column(
        children: [
          for (final provider in registry.all)
            _ProviderOptionTile(
              provider: provider,
              isSelected: provider.id == selected,
              isBackendAvailable: availability?[provider.id],
              colorScheme: colorScheme,
              onTap: () => _selectProvider(provider),
            ),
        ],
      ),
    );
  }

  Future<void> _selectProvider(TtsProvider provider) async {
    if (provider.id == ref.read(settingsProvider).ttsProviderId) {
      return;
    }
    final success = await ref
        .read(settingsProvider.notifier)
        .updateTtsProvider(provider.id);
    if (!success) {
      _showSnackBar(AppStrings.errorUnknown);
      return;
    }
    _showSnackBar(
      AppStrings.providerSwitchedSnack.replaceFirst(
        '{provider}',
        provider.name,
      ),
    );
  }

  Widget _buildDefaultVoiceSection(
    SettingsState state,
    AppColorScheme colorScheme,
  ) {
    final selectedVoiceName = state.voices
        .where((v) => v.id == state.settings.defaultVoiceId)
        .map((v) => v.name)
        .firstOrNull;

    return _buildSection(
      title: AppStrings.settingsDefaultVoice,
      description: AppStrings.settingsDefaultVoiceDesc,
      colorScheme: colorScheme,
      child: GestureDetector(
        onTap: _showVoiceSelector,
        child: Row(
          children: [
            Icon(
              AppIcons.voice,
              size: AppSizes.iconMedium,
              color: colorScheme.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                selectedVoiceName ?? AppStrings.settingsNoVoices,
                style: AppTypography.body.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: AppSizes.iconMedium,
              color: colorScheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultSpeedSection(
    SettingsState state,
    AppColorScheme colorScheme,
  ) {
    return _buildSection(
      title: AppStrings.settingsDefaultSpeed,
      description: AppStrings.settingsDefaultSpeedDesc,
      colorScheme: colorScheme,
      child: GestureDetector(
        onTap: _showSpeedSelector,
        child: Row(
          children: [
            Icon(
              AppIcons.speed,
              size: AppSizes.iconMedium,
              color: colorScheme.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${state.settings.defaultSpeed}x',
                style: AppTypography.body.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: AppSizes.iconMedium,
              color: colorScheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultFormatSection(
    SettingsState state,
    AppColorScheme colorScheme,
  ) {
    return _buildSection(
      title: AppStrings.settingsDefaultFormat,
      description: AppStrings.settingsDefaultFormatDesc,
      colorScheme: colorScheme,
      child: GestureDetector(
        onTap: _showFormatSelector,
        child: Row(
          children: [
            Icon(
              AppIcons.audio,
              size: AppSizes.iconMedium,
              color: colorScheme.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                state.settings.defaultFormat.toUpperCase(),
                style: AppTypography.body.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: AppSizes.iconMedium,
              color: colorScheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(SettingsState state, AppColorScheme colorScheme) {
    String themeLabel;
    switch (state.settings.themeMode) {
      case 'light':
        themeLabel = AppStrings.settingsThemeLight;
        break;
      case 'dark':
        themeLabel = AppStrings.settingsThemeDark;
        break;
      default:
        themeLabel = AppStrings.settingsThemeSystem;
    }

    return _buildSection(
      title: AppStrings.settingsTheme,
      description: AppStrings.settingsThemeDesc,
      colorScheme: colorScheme,
      child: GestureDetector(
        onTap: _showThemeSelector,
        child: Row(
          children: [
            Icon(
              AppIcons.tune,
              size: AppSizes.iconMedium,
              color: colorScheme.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                themeLabel,
                style: AppTypography.body.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: AppSizes.iconMedium,
              color: colorScheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextProcessingSection(
    SettingsState state,
    AppColorScheme colorScheme,
  ) {
    return _buildSection(
      title: AppStrings.settingsTextProcessing,
      description: AppStrings.settingsTextProcessingDesc,
      colorScheme: colorScheme,
      child: Row(
        children: [
          Icon(
            AppIcons.text,
            size: AppSizes.iconMedium,
            color: colorScheme.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.settingsAutoNormalize,
              style: AppTypography.body.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
          ),
          CupertinoSwitch(
            value: state.settings.autoNormalize,
            activeColor: colorScheme.primary,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateAutoNormalize(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCostWarningSection(
    SettingsState state,
    AppColorScheme colorScheme,
  ) {
    return _buildSection(
      title: AppStrings.settingsCostWarning,
      description: AppStrings.settingsCostWarningDesc,
      colorScheme: colorScheme,
      child: GestureDetector(
        onTap: _showThresholdSelector,
        child: Row(
          children: [
            Icon(
              AppIcons.warning,
              size: AppSizes.iconMedium,
              color: colorScheme.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${state.settings.warningThreshold} credits',
                style: AppTypography.body.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: AppSizes.iconMedium,
              color: colorScheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection(SettingsState state, AppColorScheme colorScheme) {
    return _buildSection(
      title: AppStrings.settingsStorage,
      description: AppStrings.settingsStorageDesc,
      colorScheme: colorScheme,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                AppIcons.save,
                size: AppSizes.iconMedium,
                color: colorScheme.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.settingsStorageUsed,
                  style: AppTypography.body.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
              ),
              Text(
                _formatStorageSize(state.storageUsed),
                style: AppTypography.body.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: _showClearCacheDialog,
                  color: colorScheme.surface,
                  borderRadius: AppRadius.mediumAll,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.mediumAll,
                      border: Border.all(color: colorScheme.divider),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      AppStrings.settingsClearCache,
                      style: AppTypography.body.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: CupertinoButton(
                  onPressed: _showDeleteAllDialog,
                  color: colorScheme.surface,
                  borderRadius: AppRadius.mediumAll,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.mediumAll,
                      border: Border.all(color: colorScheme.error),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      AppStrings.settingsDeleteAll,
                      style: AppTypography.body.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(AppColorScheme colorScheme) {
    return _buildSection(
      title: AppStrings.settingsAbout,
      description: AppStrings.settingsAboutDesc,
      colorScheme: colorScheme,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                AppIcons.info,
                size: AppSizes.iconMedium,
                color: colorScheme.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.settingsAppVersion,
                  style: AppTypography.body.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
              ),
              Text(
                AppConstants.appVersion,
                style: AppTypography.body.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderOptionTile extends StatelessWidget {
  const _ProviderOptionTile({
    required this.provider,
    required this.isSelected,
    required this.isBackendAvailable,
    required this.colorScheme,
    required this.onTap,
  });

  final TtsProvider provider;
  final bool isSelected;

  /// Readiness reported by the backend; null when unknown.
  final bool? isBackendAvailable;
  final AppColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Icon(
                isSelected
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                size: AppSizes.iconMedium,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          provider.name,
                          style: AppTypography.body.copyWith(
                            color: colorScheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isBackendAvailable == false) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _Badge(
                          label: AppStrings.providerNotConfigured,
                          color: colorScheme.error,
                        ),
                      ] else if (provider.supportsVoiceCloning) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _Badge(
                          label: AppStrings.providerSupportsCloning,
                          color: colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _descriptionFor(provider),
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _descriptionFor(TtsProvider provider) {
    switch (provider.id) {
      case TtsProviderIds.google:
        return AppStrings.providerGoogleDesc;
      case TtsProviderIds.elevenLabs:
        return AppStrings.providerElevenLabsDesc;
      default:
        return AppStrings.providerLocalDesc;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(label, style: AppTypography.caption.copyWith(color: color)),
    );
  }
}
