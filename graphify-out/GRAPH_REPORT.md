# Graph Report - voicehuluca  (2026-10-03)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 4707 nodes · 5949 edges · 160 communities (114 shown, 46 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 9 edges (avg confidence: 0.85)
- Token cost: 6,205 input · 1,730 output

## Graph Freshness
- Built from commit: `f6ea29cf`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Audio Detail
- Database Settings
- Backend Management
- Icons
- TTS Cloning
- Segment Editor
- Utilities
- Audio Analysis
- Colors
- Player UI
- Settings Screen
- Audio Generation
- Download Screen
- Sizes
- Cloning Providers
- Backend Services
- Local Data
- Spacing
- Constants
- Library UI
- TTS Repository
- Database
- Voice Recording
- Local TTS Provider
- Home Screen
- Voice Cloning
- Audio Player
- Audio Recorder
- Audio Repository
- TTS Multi Provider
- Audio Detail Provider
- Script Editor
- TTS Service
- Network Client
- Generation Jobs
- Project Config
- Image Utils
- App Settings
- Voice Card
- TTS Repository
- Generation Screen
- App Errors
- Audio Asset
- Backend Discovery
- Local TTS Datasource
- Voice Repository
- Voice Model
- Audio Player Service
- Scripts
- TTS Options
- Border Radius
- Flutter Tests
- TTS Providers
- App Constants
- Audio Datasource
- Flutter Core
- Audio Datasource
- Google TTS
- Voice Selector
- Data Models
- Projects
- Audio URL
- Secure Storage
- Shadows
- Audio Asset Model
- Voice Model
- Design Tokens
- TypeScript Config
- Voice Repository
- Audio File Service
- Audio Analyzer
- MainActivity
- Database Settings
- Settings Datasource
- Script Segment
- Motion Effects
- Script Editor
- Network Failure
- Audio Export
- TTS Remote Datasource
- Generation Job
- TTS Provider Registry
- Audio Repository
- Home Provider
- File Namer
- Text Preprocessor
- Flutter Widgets
- Script Model
- Typography
- Pronunciation
- Voice Card
- Voice Reference
- Network Info
- Error Handler
- Consumer State
- Project Model
- API Client
- Settings Repository
- Duration Estimator
- Settings UI
- JSON Serialization
- Backend Configuration
- Audio Cloning
- App Constants
- App Settings
- Database Tables
- Audio Detail Screen
- Settings Screen
- Dependencies
- Voice Recording Config
- App Icons
- Dev Dependencies
- Scripts
- Main App
- Audio Analysis
- Cloning Management
- App Color Scheme
- High Density Launcher Icon
- Extra High Density Foreground Icon
- Extra High Density Monochrome Icon
- Extra High Density Rounded Icon
- Extra Extra High Density Launcher Icon
- Extra Extra High Density Foreground Icon
- Extra Extra High Density Monochrome Icon
- High Density Foreground Icon
- High Density Monochrome Icon
- High Density Rounded Icon
- Medium Density Launcher Icon
- Medium Density Foreground Icon
- Medium Density Monochrome Icon
- Medium Density Rounded Icon
- Extra High Density Launcher Icon

## God Nodes (most connected - your core abstractions)
1. `_` - 137 edges
2. `_` - 69 edges
3. `AppError` - 29 edges
4. `LocalTtsProvider` - 22 edges
5. `SidecarError` - 19 edges
6. `compilerOptions` - 14 edges
7. `generationProvider` - 12 edges
8. `_` - 12 edges
9. `_` - 11 edges
10. `libraryProvider` - 11 edges

## Surprising Connections (you probably didn't know these)
- `Launch Screen Assets README` --references--> `App Icon 76x76@1x`  [EXTRACTED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
- `Launch Screen Assets README` --references--> `App Icon 76x76@2x`  [EXTRACTED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
- `Launch Screen Assets README` --references--> `App Icon 83.5x83.5@2x`  [EXTRACTED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
- `Launch Screen Assets README` --references--> `Launch Image @2x`  [EXTRACTED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png
- `Launch Screen Assets README` --references--> `Launch Image @3x`  [EXTRACTED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png

## Import Cycles
- None detected.

## Communities (160 total, 46 thin omitted)

### Community 0 - "Audio Detail"
Cohesion: 0.00
Nodes (1600): AppStrings, audioDetailBack15s, audioDetailCreated, audioDetailDeleteConfirm, audioDetailDeleteDesc, audioDetailDeleteSuccess, audioDetailDuration, audioDetailErrorLoading (+1592 more)

### Community 1 - "Database Settings"
Cohesion: 0.01
Nodes (179): _, accent, _accentMeta, actualTableName, _alias, aliasedName, allSchemaEntities, allTables (+171 more)

### Community 2 - "Backend Management"
Cohesion: 0.03
Nodes (79): _, activeTtsProviderProvider, _adoptDiscoveredBackend, apiKey, apiKeyProvider, applyFilter, BackendUrlNotifier, body (+71 more)

### Community 3 - "Icons"
Cohesion: 0.03
Nodes (74): add, AppIcons, arrowBack, arrowForward, audio, bookmark, bookmarkOutlined, check (+66 more)

### Community 4 - "TTS Cloning"
Cohesion: 0.06
Nodes (38): audio_duration_seconds(), _b64(), _brief(), _brief_text(), clone_dir(), CloneVoice, command_clone(), command_delete_clone() (+30 more)

### Community 5 - "Segment Editor"
Cohesion: 0.03
Nodes (63): addSegment, audioFilePath, autoSplit, build, characterCount, color, _confirmDelete, controller (+55 more)

### Community 6 - "Utilities"
Cohesion: 0.05
Nodes (39): isOfflineResult, TtsOperationNotSupportedException, TtsProviderException, TtsProviderUnavailableException, buildNotifier, cancelGeneration, checkHealth, cloneVoice (+31 more)

### Community 7 - "Audio Analysis"
Cohesion: 0.03
Nodes (58): analyzeWavBytes, analyzeWavFile, audible, bitsPerSample, buffer, bytesPerSample, channels, closeWindow (+50 more)

### Community 8 - "Colors"
Cohesion: 0.03
Nodes (56): AppColors, background, card, dark, darkBackground, darkCard, darkDisabled, darkDivider (+48 more)

### Community 9 - "Player UI"
Cohesion: 0.04
Nodes (51): _Header, _InfoRow, _PlayerActionButton, _PlayerCard, _PlayPauseButton, _SpeedSelector, _SuccessBanner, _WaveformCard (+43 more)

### Community 10 - "Settings Screen"
Cohesion: 0.04
Nodes (46): _backendController, _buildAboutSection, _buildContent, _buildCostWarningSection, _buildDefaultFormatSection, _buildDefaultSpeedSection, _buildDefaultVoiceSection, _buildHeader (+38 more)

### Community 11 - "Audio Generation"
Cohesion: 0.04
Nodes (49): audioAsset, AudioDurationReader, AudioFileWriter, audioLocalDataSourceProvider, _audioRepository, audioRepositoryProvider, _buildTitle, cancelGeneration (+41 more)

### Community 12 - "Download Screen"
Cohesion: 0.05
Nodes (49): dioProvider, generationProvider, build, _handleCancel, _handleRetry, asset, build, createState (+41 more)

### Community 13 - "Sizes"
Cohesion: 0.04
Nodes (49): appBarHeight, AppSizes, avatarExtraLarge, avatarLarge, avatarMedium, avatarSmall, badgeLargeSize, badgeSize (+41 more)

### Community 14 - "Cloning Providers"
Cohesion: 0.04
Nodes (50): _, all, audio, BackendHealth, canClone, characterCount, charactersLimit, charactersUsed (+42 more)

### Community 15 - "Backend Services"
Cohesion: 0.05
Nodes (19): { AppError, errorHandler }, assert, createRequest(), createResponse(), handle(), test, assert, { chunkText, GOOGLE_PUBLIC_VOICE_ID, isOfficialApiEnabled } (+11 more)

### Community 16 - "Local Data"
Cohesion: 0.04
Nodes (39): TtsUsage, _audioRepository, clearCache, copyWith, database, dataSource, deleteAllData, deleteApiKey (+31 more)

### Community 17 - "Spacing"
Cohesion: 0.04
Nodes (45): AppSpacing, lg, lgAll, lgBottom, lgHorizontal, lgLeft, lgRight, lgTop (+37 more)

### Community 18 - "Constants"
Cohesion: 0.05
Nodes (40): apiBaseUrl, apiTimeout, AppConstants, appName, appVersion, audioChunkSizeBytes, connectionTimeout, debounceDuration (+32 more)

### Community 19 - "Library UI"
Cohesion: 0.06
Nodes (34): libraryProvider, build, _buildAudioInfo, _buildAudioItem, _buildChip, _buildEmptyState, _buildError, _buildFilterChips (+26 more)

### Community 20 - "TTS Repository"
Cohesion: 0.06
Nodes (29): TtsRepositoryImpl, TtsResponse, _TtsResponse, cancelGeneration, checkHealth, cloneVoice, getHistory, getStatus (+21 more)

### Community 21 - "Database"
Cohesion: 0.07
Nodes (22): AppDatabase, appDatabaseProvider, AudioLocalDataSource, audioSource, database, main, seedAudio, seedProject (+14 more)

### Community 22 - "Voice Recording"
Cohesion: 0.05
Nodes (36): _analyzeSample, _canRetry, _canSave, color, createState, _discardSample, dispose, _elapsed (+28 more)

### Community 23 - "Local TTS Provider"
Cohesion: 0.09
Nodes (14): COMMAND_TIMEOUTS, crashedError(), defaultVoicesDir(), LOCAL_CLONE_PREFIX, LOCAL_PROVIDER_ID, LocalCloneResult, LocalSynthesisResult, LocalTtsProvider (+6 more)

### Community 24 - "Home Screen"
Cohesion: 0.06
Nodes (31): availableSpeedsProvider, homeProvider, activeIcon, build, _buildBottomNav, _buildGenerateButton, _buildHeader, _buildQuickActions (+23 more)

### Community 25 - "Voice Cloning"
Cohesion: 0.05
Nodes (35): animate, _AudioInfoRow, brightness, _CloningUnsupportedBanner, _confirmationError, _confirmed, createState, data (+27 more)

### Community 26 - "Audio Player"
Cohesion: 0.06
Nodes (34): audio, AudioDetailNotifier, AudioDetailState, _audioId, AudioPlayerService, audioPlayerServiceProvider, copyWith, delete (+26 more)

### Community 27 - "Audio Recorder"
Cohesion: 0.05
Nodes (32): audioFileName, audioFilePath, audioFileSizeBytes, build, cancelCloning, clonedVoice, CloningStatus, copyWith (+24 more)

### Community 28 - "Audio Repository"
Cohesion: 0.06
Nodes (32): AudioRepositoryImpl, audioLocalDataSourceProvider, AudioRepositoryImplExt, audioRepositoryProvider, audios, cleanupOrphanedAudio, copyWith, currentPage (+24 more)

### Community 29 - "TTS Multi Provider"
Cohesion: 0.12
Nodes (28): AppError, handleClone(), parseFiles(), supportsCloning(), upload, router, SynthesizeBody, TtsOptionsBody (+20 more)

### Community 30 - "Audio Detail Provider"
Cohesion: 0.06
Nodes (26): audioId, backgroundColor, _buildActionButton, _buildActionButtons, _buildContent, _buildError, _buildInfoRow, _buildPlayerControls (+18 more)

### Community 31 - "Script Editor"
Cohesion: 0.07
Nodes (25): _importFile, _pasteFromClipboard, build, _buildStatsBar, _clearText, color, _controller, createState (+17 more)

### Community 32 - "TTS Service"
Cohesion: 0.11
Nodes (25): handleSynthesize(), router, TtsBody, VoiceSettings, clampSpeed(), client, cloneVoice(), deleteVoice() (+17 more)

### Community 33 - "Network Client"
Cohesion: 0.07
Nodes (25): apiKey, baseUrl, bytes, checkHealth, _client, cloneVoice, deleteVoice, dispose (+17 more)

### Community 34 - "Generation Jobs"
Cohesion: 0.07
Nodes (26): GenerationJobsCompanion, audioAssetId, cancelledAt, completedAt, createdAt, errorMessage, hashCode, id (+18 more)

### Community 35 - "Project Config"
Cohesion: 0.10
Nodes (22): description, main, name, version, config, app, reqLogPath, appApiKeyAuth() (+14 more)

### Community 36 - "Image Utils"
Cohesion: 0.13
Nodes (16): adaptive_foreground(), draw_mark(), rect(), x(), y(), flat_icon(), gradient(), legacy_icon() (+8 more)

### Community 37 - "App Settings"
Cohesion: 0.07
Nodes (26): apiKey, autoSave, createdAt, customHeaders, defaultModelId, defaultOutputFormat, defaultSampleRate, defaultSpeed (+18 more)

### Community 38 - "Voice Card"
Cohesion: 0.07
Nodes (26): _avatarColor, build, _buildActions, _buildAvatar, _buildInfo, _buildTag, color, _genderLabel (+18 more)

### Community 39 - "TTS Repository"
Cohesion: 0.07
Nodes (22): cancelGeneration, checkHealth, cloneVoice, deleteVoice, getFavoriteVoices, getHistory, getLocalVoice, getStatus (+14 more)

### Community 40 - "Generation Screen"
Cohesion: 0.08
Nodes (22): _Body, _CancelButton, GenerationScreen, _Header, icon, _iconForStatus, _InfoCard, _InfoRow (+14 more)

### Community 41 - "App Errors"
Cohesion: 0.12
Nodes (17): AppError, CloningFailedError, code, InvalidAudioError, message, NetworkError, ProviderUnavailableError, QuotaExceededError (+9 more)

### Community 42 - "Audio Asset"
Cohesion: 0.08
Nodes (24): channels, createdAt, deletedAt, duration, fileName, filePath, fileSizeBytes, format (+16 more)

### Community 43 - "Backend Discovery"
Cohesion: 0.08
Nodes (24): BackendProbe, baseUrl, concurrency, debugReport, defaultPort, DiscoveredBackend, hashCode, _httpProbe (+16 more)

### Community 44 - "Local TTS Datasource"
Cohesion: 0.08
Nodes (25): d, _database, deleteReferencesByVoice, deleteVoice, deleteVoiceCascade, deleteVoiceReference, getAllVoices, getFavoriteVoices (+17 more)

### Community 45 - "Voice Repository"
Cohesion: 0.08
Nodes (22): deleteReferencesByVoice, deleteVoice, deleteVoiceCascade, deleteVoiceReference, getAllVoices, getFavoriteVoices, getVoiceById, getVoiceByProviderId (+14 more)

### Community 46 - "Voice Model"
Cohesion: 0.08
Nodes (22): accent, createdAt, description, gender, hashCode, id, isCustom, labels (+14 more)

### Community 47 - "Audio Player Service"
Cohesion: 0.08
Nodes (20): AudioPlayerService, dispose, duration, durationStream, isPlaying, pause, playBytes, _player (+12 more)

### Community 48 - "Scripts"
Cohesion: 0.09
Nodes (21): ScriptsCompanion, audioAssetId, content, createdAt, hashCode, id, isGenerated, operator (+13 more)

### Community 49 - "TTS Options"
Cohesion: 0.09
Nodes (21): extraParams, hashCode, id, modelId, operator, outputFormat, _privateConstructorUsedError, sampleRate (+13 more)

### Community 50 - "Border Radius"
Cohesion: 0.08
Nodes (21): AppRadius, extraLarge, extraLargeAll, large, largeAll, largeBottom, largeTop, medium (+13 more)

### Community 51 - "Flutter Tests"
Cohesion: 0.09
Nodes (8): main, main, url, main, main, main, main, main

### Community 52 - "TTS Providers"
Cohesion: 0.13
Nodes (15): BackendTtsProvider, ElevenLabsProvider, id, name, supportsVoiceCloning, GoogleTtsProvider, id, name (+7 more)

### Community 53 - "App Constants"
Cohesion: 0.09
Nodes (17): AppSettings, autoNormalize, autoSplit, backendUrl, copyWith, defaultFormat, defaultSpeed, defaultVoiceId (+9 more)

### Community 54 - "Audio Datasource"
Cohesion: 0.09
Nodes (19): audioFileExists, deleteAudio, deleteAudioByProject, getAllAudio, getAudioById, getAudioByProject, getAudioByScript, getAudioBySegment (+11 more)

### Community 55 - "Flutter Core"
Cohesion: 0.10
Nodes (6): Flutter, AppDelegate, SceneDelegate, RunnerTests, UIKit, XCTest

### Community 56 - "Audio Datasource"
Cohesion: 0.09
Nodes (21): audioFileExists, d, _database, deleteAudio, deleteAudioByProject, getAllAudio, getAudioById, getAudioByProject (+13 more)

### Community 57 - "Google TTS"
Cohesion: 0.17
Nodes (17): browserHeaders, chunkText(), escapeXml(), fetchPublicVoices(), getVoices(), GOOGLE_PROVIDER_ID, GOOGLE_PUBLIC_VOICE_ID, GoogleCloudVoiceResponse (+9 more)

### Community 58 - "Voice Selector"
Cohesion: 0.14
Nodes (18): _CancelledState, _ErrorState, _buildVoiceSelector, _generateVoice, _showVoicePicker, cloningProvider, _AudioReadyCard, build (+10 more)

### Community 59 - "Data Models"
Cohesion: 0.14
Nodes (15): AppSettingsTableCompanion, AppSettingsTableData, AudioAsset, AudioAssetsCompanion, DataClass, GenerationJob, Project, Script (+7 more)

### Community 60 - "Projects"
Cohesion: 0.11
Nodes (17): ProjectsCompanion, coverImageUrl, createdAt, description, hashCode, id, isArchived, name (+9 more)

### Community 61 - "Audio URL"
Cohesion: 0.11
Nodes (16): audioUrl, characterCount, createdAt, duration, errorMessage, hashCode, id, metadata (+8 more)

### Community 62 - "Secure Storage"
Cohesion: 0.11
Nodes (16): clearAll, containsKey, deleteApiToken, deleteClonedVoiceData, deleteRefreshToken, deleteUserId, getApiToken, getClonedVoiceData (+8 more)

### Community 63 - "Shadows"
Cohesion: 0.11
Nodes (17): AppShadows, button, buttonPressed, card, cardDark, cardHover, dropdown, dropdownDark (+9 more)

### Community 64 - "Audio Asset Model"
Cohesion: 0.11
Nodes (17): AudioAsset, copyWith, createdAt, durationMs, filePath, fileSize, format, fromJson (+9 more)

### Community 65 - "Voice Model"
Cohesion: 0.11
Nodes (16): accent, copyWith, createdAt, description, fromJson, gender, id, isCloned (+8 more)

### Community 66 - "Design Tokens"
Cohesion: 0.15
Nodes (4): AppTheme, _buildTheme, dark, light

### Community 67 - "TypeScript Config"
Cohesion: 0.12
Nodes (16): compilerOptions, declaration, declarationMap, esModuleInterop, forceConsistentCasingInFileNames, lib, module, outDir (+8 more)

### Community 68 - "Voice Repository"
Cohesion: 0.12
Nodes (13): cloneVoice, createVoice, deleteVoice, getAvailableLanguages, getAvailableProviders, getPreviewUrl, getVoice, getVoices (+5 more)

### Community 69 - "Audio File Service"
Cohesion: 0.12
Nodes (14): audioFileExists, AudioFileService, clearCache, deleteAudioFile, exportAudioFile, getAudioDirectory, getCacheDirectory, getExportDirectory (+6 more)

### Community 70 - "Audio Analyzer"
Cohesion: 0.12
Nodes (15): bitsPerSample, buildWav, bytes, bytesPerSample, dataLength, formatTag, main, random (+7 more)

### Community 72 - "Database Settings"
Cohesion: 0.12
Nodes (13): _database, getSettings, setAutoNormalize, setAutoSplit, setBackendUrl, setDefaultFormat, setDefaultSpeed, setDefaultVoiceId (+5 more)

### Community 73 - "Settings Datasource"
Cohesion: 0.12
Nodes (14): SettingsLocalDataSource, getSettings, _local, setAutoNormalize, setAutoSplit, setDefaultFormat, setDefaultSpeed, setDefaultVoiceId (+6 more)

### Community 74 - "Script Segment"
Cohesion: 0.12
Nodes (13): audioId, content, copyWith, createdAt, fromJson, id, normalizedText, scriptId (+5 more)

### Community 75 - "Motion Effects"
Cohesion: 0.12
Nodes (13): accelerate, AppMotion, bounce, decelerate, emphasized, extraSlow, fast, linear (+5 more)

### Community 76 - "Script Editor"
Cohesion: 0.12
Nodes (13): characterCount, clear, copyWith, cursorPosition, estimatedDurationSeconds, isDirty, isValid, ScriptEditorNotifier (+5 more)

### Community 77 - "Network Failure"
Cohesion: 0.13
Nodes (11): classifyNetworkFailure, _describe, _fromText, lower, NetworkFailure, toString, ClientExceptionLike, main (+3 more)

### Community 78 - "Audio Export"
Cohesion: 0.14
Nodes (10): _, ensurePcm16, toPcm16Bytes, WavConverter, _writeHeader, AudioExportResult, AudioExportService, exportToDownloads (+2 more)

### Community 79 - "TTS Remote Datasource"
Cohesion: 0.13
Nodes (12): TtsRemoteDatasource, cloneVoice, deleteVoice, getUsage, getVoices, id, isAvailable, name (+4 more)

### Community 80 - "Generation Job"
Cohesion: 0.13
Nodes (13): characterCount, completedAt, copyWith, errorCode, fromJson, GenerationJob, id, projectId (+5 more)

### Community 81 - "TTS Provider Registry"
Cohesion: 0.13
Nodes (12): all, available, clear, contains, getById, ids, _providers, register (+4 more)

### Community 82 - "Audio Repository"
Cohesion: 0.14
Nodes (11): AudioRepository, cleanupOrphanedAudio, deleteAudio, getAudio, getAudioData, getAudioFilePath, getAudioList, getTotalStorageUsed (+3 more)

### Community 83 - "Home Provider"
Cohesion: 0.15
Nodes (12): characterCount, copyWith, generationError, HomeNotifier, HomeState, isGenerating, scriptText, setGenerating (+4 more)

### Community 84 - "File Namer"
Cohesion: 0.14
Nodes (11): changeExtension, _defaultExtension, FileNamer, generateExportFileName, generateFileName, generateScriptFileName, generateVoiceFileName, getExtension (+3 more)

### Community 85 - "Text Preprocessor"
Cohesion: 0.14
Nodes (12): estimateDuration, formatBasicNumbers, _newlineRegex, normalizeNewlines, normalizeWhitespace, preprocess, preserveTechnicalTerms, removeRepeatedChars (+4 more)

### Community 86 - "Flutter Widgets"
Cohesion: 0.18
Nodes (3): main, main, main

### Community 87 - "Script Model"
Cohesion: 0.15
Nodes (10): copyWith, createdAt, fromJson, id, normalizedText, originalText, projectId, Script (+2 more)

### Community 88 - "Typography"
Cohesion: 0.15
Nodes (10): AppTypography, body, bodyLarge, bodySmall, caption, display, headline, label (+2 more)

### Community 89 - "Pronunciation"
Cohesion: 0.15
Nodes (9): applyRules, description, findRule, pattern, PronunciationDictionary, PronunciationRule, regex, replacement (+1 more)

### Community 90 - "Voice Card"
Cohesion: 0.15
Nodes (9): description, gender, _host, isCloned, language, main, name, now (+1 more)

### Community 91 - "Voice Reference"
Cohesion: 0.17
Nodes (10): copyWith, createdAt, durationMs, fromJson, id, localFilePath, provider, toJson (+2 more)

### Community 92 - "Network Info"
Cohesion: 0.17
Nodes (10): _checkHost, _checkPort, checkStatus, hasInternetAccess, isConnected, isMobileDataConnected, isWifiConnected, NetworkInfo (+2 more)

### Community 93 - "Error Handler"
Cohesion: 0.25
Nodes (10): BODY_PARSER_MESSAGES, ErrorBody, errorHandler(), FrameworkError, mapFrameworkError(), mapUploadError(), MULTER_MESSAGES, pickClientStatus() (+2 more)

### Community 94 - "Consumer State"
Cohesion: 0.25
Nodes (8): SegmentEditorScreen, _SegmentEditorScreenState, HomeScreen, _HomeScreenState, VoiceCloningScreen, _VoiceCloningScreenState, RecordVoiceSheet, _RecordVoiceSheetState

### Community 95 - "Project Model"
Cohesion: 0.18
Nodes (8): copyWith, createdAt, fromJson, id, name, Project, toJson, updatedAt

### Community 96 - "API Client"
Cohesion: 0.18
Nodes (7): ApiClient, close, _dio, download, _getHeaders, _secureStorage, SecureStorage

### Community 97 - "Settings Repository"
Cohesion: 0.18
Nodes (9): clearSettings, deleteApiKey, getApiKey, getSettings, hasApiKey, resetToDefaults, saveApiKey, SettingsRepository (+1 more)

### Community 98 - "Duration Estimator"
Cohesion: 0.18
Nodes (9): _charsPerSecond, DurationEstimator, estimate, estimateProgress, estimateWithSpeed, formatDuration, formatDurationShort, _maxSeconds (+1 more)

### Community 99 - "Settings UI"
Cohesion: 0.20
Nodes (9): build, _buildTextProcessingSection, _selectProvider, _showClearCacheDialog, _showDeleteAllDialog, _showFormatSelector, _showSpeedSelector, _showThemeSelector (+1 more)

### Community 100 - "JSON Serialization"
Cohesion: 0.22
Nodes (8): _, _, _, _, _, _, _, _

### Community 101 - "Backend Configuration"
Cohesion: 0.22
Nodes (6): _, BackendConfig, compiledBaseUrl, labelOf, parse, resolve

### Community 102 - "Audio Cloning"
Cohesion: 0.31
Nodes (6): CLONE_MP3_BITRATE_KBPS, CloneSample, hasFfmpeg(), pipeThroughFfmpeg(), run, toCloneMp3()

### Community 103 - "App Constants"
Cohesion: 0.22
Nodes (7): _, apiSuffix, BackendEndpoint, invalidMessage, _normalisePath, parse, resolve

### Community 104 - "App Settings"
Cohesion: 0.22
Nodes (5): channel, openAppSettings, _channel, PublicStorageService, saveToPublicDownloads

### Community 105 - "Database Tables"
Cohesion: 0.22
Nodes (8): AppSettingsTable, AudioAssets, GenerationJobs, Projects, Scripts, ScriptSegments, VoiceReferences, Voices

### Community 106 - "Audio Detail Screen"
Cohesion: 0.22
Nodes (9): audioDetailProvider, AudioDetailScreen, _AudioDetailScreenState, build, _buildFileInfo, _buildHeader, _showDeleteDialog, libraryVoiceNamesProvider (+1 more)

### Community 107 - "Settings Screen"
Cohesion: 0.22
Nodes (9): _buildBackendSection, _buildTtsProviderSection, initState, _resetBackendUrl, _saveBackendUrl, SettingsScreen, _SettingsScreenState, backendUrlProvider (+1 more)

### Community 108 - "Dependencies"
Cohesion: 0.25
Nodes (8): dependencies, axios, cors, dotenv, express, express-rate-limit, helmet, multer

### Community 109 - "Voice Recording Config"
Cohesion: 0.29
Nodes (3): recordVoiceConfig, recordVoiceMaxDuration, recordVoiceMinDuration

### Community 110 - "App Icons"
Cohesion: 0.29
Nodes (7): App Icon 76x76@1x, App Icon 76x76@2x, App Icon 83.5x83.5@2x, Launch Image @2x, Launch Image @3x, Launch Image, Launch Screen Assets README

### Community 111 - "Dev Dependencies"
Cohesion: 0.33
Nodes (6): devDependencies, ts-node, @types/cors, @types/express, @types/multer, typescript

### Community 112 - "Scripts"
Cohesion: 0.33
Nodes (6): scripts, build, dev, lint, start, test

### Community 113 - "Main App"
Cohesion: 0.33
Nodes (3): build, main, VietVoiceStudioApp

### Community 115 - "Cloning Management"
Cohesion: 0.50
Nodes (4): CloningNotifier, CloningState, ttsRepositoryProvider, _save

## Knowledge Gaps
- **3690 isolated node(s):** `CloneSample`, `LocalCloneResult`, `LocalSynthesisResult`, `PendingRequest`, `SidecarCommand` (+3685 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 3905 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **46 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_` connect `Cloning Providers` to `Network Client`, `Utilities`, `App Constants`, `App Errors`, `Network Failure`, `TTS Remote Datasource`, `Local Data`, `TTS Provider Registry`, `Audio Repository`, `TTS Providers`, `Shadows`, `Project Model`?**
  _High betweenness centrality (0.277) - this node is a cross-community bridge._
- **Why does `_` connect `Backend Management` to `Utilities`, `Player UI`, `Settings Screen`, `Cloning Providers`, `TTS Repository`, `Database`, `Home Screen`, `Audio Recorder`, `Network Client`, `Generation Screen`, `App Errors`, `Local TTS Datasource`, `Audio Player Service`, `Flutter Tests`, `TTS Providers`, `Voice Selector`, `Secure Storage`, `Settings Datasource`, `Script Segment`, `Network Failure`, `Audio Export`, `TTS Remote Datasource`, `TTS Provider Registry`, `Flutter Widgets`, `Voice Card`, `Settings Screen`, `Voice Recording Config`, `Cloning Management`?**
  _High betweenness centrality (0.052) - this node is a cross-community bridge._
- **Why does `TtsProvider` connect `TTS Providers` to `Settings Screen`, `Backend Management`, `Cloning Providers`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `CloneSample`, `LocalCloneResult`, `LocalSynthesisResult` to the rest of the system?**
  _3690 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Audio Detail` be split into smaller, more focused modules?**
  _Cohesion score 0.0012492192379762648 - nodes in this community are weakly interconnected._
- **Should `Database Settings` be split into smaller, more focused modules?**
  _Cohesion score 0.010362694300518135 - nodes in this community are weakly interconnected._
- **Should `Backend Management` be split into smaller, more focused modules?**
  _Cohesion score 0.027450980392156862 - nodes in this community are weakly interconnected._