import '../audio/voice_sample_config.dart';

class AppStrings {
  AppStrings._();

  /// Fills `{0}`, `{1}` … in [template] with [values].
  ///
  /// Keeps sentences in one place instead of splitting them across the widget.
  static String fill(String template, List<Object?> values) {
    var result = template;
    for (var index = 0; index < values.length; index++) {
      result = result.replaceAll('{$index}', '${values[index]}');
    }
    return result;
  }

  // Home
  static const String homeTitle = 'VietVoice Studio';
  static const String homeWelcome = 'Chào mừng đến với VietVoice Studio';
  static const String homeSubtitle =
      'Biến kịch bản thành giọng đọc cho video của bạn';
  static const String homeNewScript = 'Tạo kịch bản mới';
  static const String homeRecentProjects = 'Dự án gần đây';
  static const String homeNoRecentProjects = 'Chưa có dự án nào';
  static const String homeViewAll = 'Xem tất cả';
  static const String homeQuickGenerate = 'Tạo nhanh';
  static const String homeContinueEditing = 'Tiếp tục chỉnh sửa';

  // Script Editor
  static const String editorTitle = 'Soạn kịch bản';
  static const String editorHint =
      'Nhập hoặc dán văn bản tiếng Việt tại đây...';
  static const String editorClear = 'Xóa';
  static const String editorPaste = 'Dán';
  static const String editorCopy = 'Sao chép';
  static const String editorUndo = 'Hoàn tác';
  static const String editorRedo = 'Làm lại';
  static const String editorWordCount = 'Số từ';
  static const String editorCharCount = 'Số ký tự';
  static const String editorEstimatedDuration = 'Thời gian ước tính';
  static const String editorMaxChars = 'Tối đa 5000 ký tự';
  static const String editorEmptyScript = 'Vui lòng nhập kịch bản';
  static const String editorScriptTooLong =
      'Kịch bản vượt quá giới hạn 5000 ký tự';
  static const String editorPreprocess = 'Tiền xử lý';
  static const String editorPreprocessSuccess = 'Đã tiền xử lý văn bản';

  // Voice Selector
  static const String voiceSelectorTitle = 'Chọn giọng đọc';
  static const String voiceSelectorSearch = 'Tìm kiếm giọng đọc...';
  static const String voiceSelectorNoResults =
      'Không tìm thấy giọng đọc phù hợp';
  static const String voiceSelectorFemale = 'Nữ';
  static const String voiceSelectorMale = 'Nam';
  static const String voiceSelectorAll = 'Tất cả';
  static const String voiceSelectorPreview = 'Nghe thử';
  static const String voiceSelectorPreviewPlaying = 'Đang phát...';
  static const String voiceSelectorFilterAll = 'Tất cả';
  static const String voiceSelectorFilterFemale = 'Nữ';
  static const String voiceSelectorFilterMale = 'Nam';
  static const String voiceSelectorFilterCloned = 'Giọng nhân bản';

  /// Short badge label for the voice card, where the row is already narrow.
  static const String voiceSelectorClonedBadge = 'Nhân bản';
  static const String voiceSelectorFilterMine = 'Giọng của tôi';
  static const String voiceSelectorFilterFavorites = 'Yêu thích';
  static const String voiceSelectorSectionMine = 'Giọng của tôi';
  static const String voiceSelectorSectionProvider =
      'Giọng gốc từ nhà cung cấp';
  static const String voiceSelectorCreateVoice = 'Tạo giọng';
  static const String voiceSelectorLoading = 'Đang tải giọng đọc...';
  static const String voiceSelectorRetry = 'Thử lại';
  static const String voiceSelectorSelected = 'Đang chọn';
  static const String voiceSelectorMenuSelect = 'Chọn giọng này';
  static const String voiceSelectorMenuDelete = 'Xóa giọng';
  static const String voiceSelectorMenuPreview = 'Nghe thử';
  static const String voiceSelectorMenuFavorite = 'Yêu thích';
  static const String voiceSelectorMenuUnfavorite = 'Bỏ yêu thích';
  static const String voiceSelectorDeleteTitle = 'Xóa giọng đọc?';
  static const String voiceSelectorDeleteDesc =
      'Giọng đọc này sẽ bị xóa vĩnh viễn.';
  static const String voiceSelectorEmptyMine =
      'Bạn chưa có giọng nào.\nHãy tạo giọng đầu tiên!';
  static const String voiceSelectorPreviewSample =
      'Xin chào! Tôi là giọng đọc mẫu. Rất vui được gặp bạn.';

  // Voice Cloning
  static const String cloningTitle = 'Nhân bản giọng nói';
  static const String cloningUploadAudio = 'Tải lên tệp âm thanh';
  static const String cloningRecordAudio = 'Ghi âm';
  static const String cloningRecording = 'Đang ghi âm...';
  static const String cloningStopRecording = 'Dừng ghi âm';
  static const String cloningStartRecording = 'Bắt đầu ghi âm';
  static const String cloningVoiceName = 'Tên giọng nói';
  static const String cloningVoiceNameHint = 'Nhập tên cho giọng nói của bạn';
  static const String cloningDescription = 'Mô tả';
  static const String cloningDescriptionHint = 'Mô tả ngắn về giọng nói';
  /// The sample window is the one the sidecar enforces, so these read the real
  /// limits instead of repeating numbers that drifted away from them.
  static final String cloningMinDuration =
      'Tối thiểu ${recordVoiceMinDuration.inSeconds} giây';
  static final String cloningMaxDuration =
      'Tối đa ${recordVoiceMaxDuration.inSeconds} giây';
  static const String cloningRecommendedQuality =
      'Chất lượng đề xuất: WAV, 22.05kHz, 16-bit, mono';
  static const String cloningSubmit = 'Tạo giọng nói';
  static const String cloningCancel = 'Hủy';
  static const String cloningSuccess = 'Nhân bản giọng nói thành công!';
  static const String cloningProcessing = 'Đang xử lý âm thanh...';
  static const String cloningProgress = 'Tiến độ';
  static const String cloningAgreement =
      'Tôi xác nhận có quyền sử dụng âm thanh này';
  static const String cloningAgreementRequired =
      'Vui lòng xác nhận quyền sử dụng âm thanh';
  static const String cloningScreenTitle = 'Tạo giọng của tôi';
  static const String cloningTabRecord = 'Thu âm trực tiếp';
  static const String cloningTabFile = 'Chọn file audio';
  static const String cloningRecordTitle = 'Thu âm giọng của bạn';
  static const String cloningInstructionQuiet =
      'Nên thu giọng trong phòng yên tĩnh';
  static const String cloningInstructionNatural = 'Nói tự nhiên, rõ ràng';
  static const String cloningInstructionSingleSpeaker = 'Chỉ một người nói';
  static const String cloningInstructionNoMusic = 'Không nhạc nền';
  static const String cloningInstructionNoEcho = 'Không vọng phòng';
  static const String cloningInstructionStableVolume = 'Giữ âm lượng ổn định';
  static const String cloningChecklistTitle = 'Kiểm tra chất lượng';
  static const String cloningChecklistQuiet = 'Nổi trong phòng yên tĩnh';
  static const String cloningChecklistSingleSpeaker = 'Chỉ một người nói';
  static const String cloningChecklistNoMusic = 'Không nhạc nền';
  static const String cloningChecklistStableVolume = 'Giữ âm lượng ổn định';
  static final String cloningChecklistNatural =
      'Nội dung tự nhiên, rõ ràng (${recordVoiceMinDuration.inSeconds}-${recordVoiceMaxDuration.inSeconds} giây)';
  static const String cloningTranscript = 'Văn bản mẫu (tùy chọn)';
  static const String cloningTranscriptHint =
      'Nội dung bản ghi âm để tăng độ chính xác';
  static const String cloningPrivacyNotice =
      'Giọng mẫu sẽ được gửi tới nhà cung cấp TTS để tạo giọng mô phỏng.';
  static const String cloningConfirmation =
      'Bạn xác nhận đây là giọng của bạn hoặc bạn có quyền sử dụng giọng này.';
  static const String cloningConfirmationRequired =
      'Vui lòng xác nhận quyền sử dụng giọng';
  static const String cloningUploading = 'Đang tải âm thanh lên...';
  static const String cloningCloning = 'Đang tạo giọng mô phỏng...';
  static const String cloningSuccessDesc = 'Giọng của bạn đã sẵn sàng sử dụng.';
  static const String cloningDone = 'Xong';
  static const String cloningRetry = 'Thử lại';
  static const String cloningSelectFile = 'Chọn file audio';
  static final String cloningRecordingLimit =
      'Tối đa ${recordVoiceMaxDuration.inSeconds} giây';
  static const String cloningAudioReady = 'Âm thanh đã sẵn sàng';
  static const String cloningChangeAudio = 'Chọn lại';
  static const String cloningNameRequired = 'Vui lòng nhập tên giọng';
  static const String cloningAudioRequired =
      'Vui lòng thu âm hoặc chọn file audio';
  static const String cloningFileFormat = 'Định dạng';
  static const String cloningFileSize = 'Kích thước';
  static const String cloningFileDuration = 'Thời lượng';

  // Generation
  static const String generationTitle = 'Tạo giọng nói';
  static const String generationStart = 'Bắt đầu tạo';
  static const String generationCancel = 'Hủy bỏ';
  static const String generationProcessing = 'Đang tạo giọng nói...';
  static const String generationQueued = 'Đang chờ xử lý...';
  static const String generationProgress = 'Tiến độ';
  static const String generationEstimatedTime = 'Thời gian còn lại';
  static const String generationComplete = 'Hoàn thành!';
  static const String generationFailed = 'Tạo giọng nói thất bại';
  static const String generationRetry = 'Thử lại';
  static const String generationDownload = 'Tải xuống';
  static const String generationShare = 'Chia sẻ';
  static const String generationPlay = 'Phát';
  static const String generationPause = 'Tạm dừng';
  static const String generationStop = 'Dừng';
  static const String generationRegenerate = 'Tạo lại';
  static const String generationSpeed = 'Tốc độ phát';
  static const String generationVolume = 'Âm lượng';
  static const String generationValidating = 'Đang chuẩn bị...';
  static const String generationUploading = 'Đang tải lên...';
  static const String generationGenerating = 'Đang tạo giọng...';
  static const String generationDownloading = 'Đang tải audio...';
  static const String generationFinishing = 'Đang hoàn tất...';
  static const String generationCancelled = 'Đã hủy';
  static const String generationScreenTitle = 'Đang tạo giọng...';
  /// A local clone is rendered by XTTS on the CPU, where even a short script
  /// takes minutes. Naming that is more use than a bare "quá thời gian", which
  /// reads as a broken connection and invites a retry that will be just as slow.
  static const String generationTimeoutLocal =
      'Máy chủ vẫn đang chạy mô hình giọng nói trên CPU nên lâu hơn dự kiến.\n'
      'Hãy rút ngắn kịch bản, hoặc chuyển sang giọng Edge/ElevenLabs để tạo nhanh hơn.';
  static const String generationVoiceLabel = 'Giọng đọc';
  static const String generationCharacterCount = 'Số ký tự';
  static const String generationCancelConfirmTitle = 'Hủy tạo giọng?';
  static const String generationCancelConfirmDesc =
      'Tiến trình hiện tại sẽ bị dừng.';
  static const String generationCancelConfirm = 'Hủy';
  static const String generationKeepWaiting = 'Tiếp tục chờ';

  // Result
  static const String resultTitle = 'Kết quả';
  static const String resultPlay = 'Phát';
  static const String resultPause = 'Tạm dừng';
  static const String resultDownload = 'Tải xuống';
  static const String resultShare = 'Chia sẻ';
  static const String resultSaveToLibrary = 'Lưu vào thư viện';
  static const String resultSaved = 'Đã lưu vào thư viện';
  static const String resultDuration = 'Thời lượng';
  static const String resultFileSize = 'Kích thước';
  static const String resultFormat = 'Định dạng';
  static const String resultCreatedAt = 'Tạo lúc';
  static const String resultScript = 'Kịch bản';
  static const String resultVoice = 'Giọng đọc';
  static const String resultSuccess = 'Đã tạo giọng đọc';
  static const String resultFileName = 'Tên tệp';
  static const String resultDownloadMp3 = 'Tải xuống MP3';
  static const String resultDownloadWav = 'Tải WAV';
  static const String resultKeep = 'Giữ lại';
  static const String resultRegenerate = 'Tạo lại';
  static const String resultBack15s = 'Lùi 15 giây';
  static const String resultForward15s = 'Tới 15 giây';
  static const String resultSpeedLabel = 'Tốc độ phát';
  static const String resultShareSuccess = 'Đã chia sẻ tệp âm thanh';
  static const String resultDownloadStarted = 'Đã bắt đầu tải xuống';
  static const String resultDownloadComplete = 'Tải xuống hoàn tất';
  static String resultSavedTo(String location) => 'Đã lưu vào $location';
  static const String resultPlaybackError = 'Không thể phát âm thanh';

  // Segment Editor
  static const String segmentEditorTitle = 'Chỉnh sửa kịch bản theo đoạn';
  static const String segmentTabText = 'Văn bản';
  static const String segmentTabSegments = 'Chia đoạn';
  static const String segmentAdd = 'Thêm đoạn';
  static const String segmentAutoSplit = 'Tự động chia đoạn';
  static const String segmentAutoSplitDesc =
      'Tự động chia kịch bản thành các đoạn nhỏ theo câu';
  static const String segmentRetry = 'Thử lại';
  static const String segmentEdit = 'Chỉnh sửa';
  static const String segmentPlay = 'Phát';
  static const String segmentDelete = 'Xóa';
  static const String segmentDuration = 'Thời lượng';
  static const String segmentNumber = 'Đoạn';
  static const String segmentEmpty = 'Chưa có đoạn nào';
  static const String segmentEmptyHint =
      'Nhấn "Thêm đoạn" hoặc bật tự động chia đoạn';
  static const String segmentSave = 'Lưu';
  static const String segmentCancel = 'Hủy';
  static const String segmentTextHint = 'Nhập nội dung đoạn...';
  static const String segmentRegenerate = 'Tạo lại đoạn';
  static const String segmentGenerating = 'Đang tạo...';
  static const String segmentFailed = 'Thất bại';
  static const String segmentReady = 'Sẵn sàng';
  static const String segmentAutoSplitConfirmTitle = 'Tự động chia đoạn?';
  static const String segmentAutoSplitConfirmDesc =
      'Kịch bản hiện tại sẽ được chia thành các đoạn theo câu.';
  static const String segmentDeleteConfirmTitle = 'Xóa đoạn này?';
  static const String segmentDeleteConfirmDesc = 'Nội dung đoạn sẽ bị xóa.';
  static const String segmentRegenerateConfirmTitle = 'Tạo lại đoạn này?';
  static const String segmentRegenerateConfirmDesc =
      'Đoạn này sẽ được tạo lại từ đầu.';
  static const String segmentSaveSuccess = 'Đã lưu các thay đổi';
  static const String segmentRegenerateSuccess = 'Đã tạo lại đoạn';
  static const String segmentAutoSplitSuccess = 'Đã chia kịch bản thành đoạn';

  // Library
  static const String libraryTitle = 'Thư viện';
  static const String libraryEmpty = 'Thư viện trống';
  static const String libraryEmptyHint = 'Tạo giọng nói đầu tiên của bạn';
  static const String librarySearch = 'Tìm kiếm...';
  static const String libraryFilterAll = 'Tất cả';
  static const String libraryFilterFavorites = 'Yêu thích';
  static const String libraryFilterRecent = 'Gần đây';
  static const String librarySortByName = 'Theo tên';
  static const String librarySortByDate = 'Theo ngày';
  static const String librarySortByDuration = 'Theo thời lượng';
  static const String libraryDelete = 'Xóa';
  static const String libraryDeleteConfirm = 'Bạn có chắc muốn xóa?';
  static const String libraryDeleteConfirmDesc =
      'Hành động này không thể hoàn tác.';
  static const String libraryCancel = 'Hủy';
  static const String libraryConfirm = 'Xóa';
  static const String libraryRename = 'Đổi tên';
  static const String libraryExport = 'Xuất';
  static const String libraryImport = 'Nhập';
  static const String libraryFavorite = 'Yêu thích';
  static const String libraryUnfavorite = 'Bỏ yêu thích';
  static const String libraryItems = 'mục';

  // Settings
  static const String settingsTitle = 'Cài đặt';
  static const String settingsAppearance = 'Giao diện';
  static const String settingsTheme = 'Giao diện';
  static const String settingsThemeLight = 'Sáng';
  static const String settingsThemeDark = 'Tối';
  static const String settingsThemeSystem = 'Theo hệ thống';
  static const String settingsLanguage = 'Ngôn ngữ';
  static const String settingsLanguageVietnamese = 'Tiếng Việt';
  static const String settingsLanguageEnglish = 'English';
  static const String settingsAudio = 'Âm thanh';
  static const String settingsAutoPlay = 'Tự động phát';
  static const String settingsAutoPlayDesc = 'Tự động phát khi tạo xong';
  static const String settingsDownloadOnGenerate = 'Tải xuống khi tạo';
  static const String settingsDownloadOnGenerateDesc =
      'Tự động lưu vào thiết bị';
  static const String settingsDefaultVoice = 'Giọng mặc định';
  static const String settingsDefaultSpeed = 'Tốc độ mặc định';
  static const String settingsQuality = 'Chất lượng';
  static const String settingsQualityLow = 'Thấp';
  static const String settingsQualityMedium = 'Trung bình';
  static const String settingsQualityHigh = 'Cao';
  static const String settingsNetwork = 'Mạng';
  static const String settingsWifiOnly = 'Chỉ tải qua Wi-Fi';
  static const String settingsWifiOnlyDesc = 'Tránh sử dụng dữ liệu di động';
  static const String settingsStorage = 'Lưu trữ';
  static const String settingsClearCache = 'Xóa bộ nhớ đệm';
  static const String settingsClearCacheConfirm = 'Xóa bộ nhớ đệm?';
  static const String settingsClearCacheDesc = 'Dung lượng sẽ được giải phóng';
  static const String settingsCacheCleared = 'Đã xóa bộ nhớ đệm';
  static const String settingsStorageUsed = 'Dung lượng đã dùng';
  static const String settingsAccount = 'Tài khoản';
  static const String settingsLogout = 'Đăng xuất';
  static const String settingsLogoutConfirm = 'Bạn có chắc muốn đăng xuất?';
  // Backend address (LAN)
  static const String settingsBackendTitle = 'Máy chủ giọng nói';
  static const String settingsBackendDesc =
      'Địa chỉ máy đang chạy backend. Gõ IP của máy đó, hoặc bấm "Dò trong mạng LAN" để app tự tìm.';
  static const String settingsBackendUrlLabel = 'Địa chỉ máy chủ';
  static const String settingsBackendUrlHint = '192.168.1.20:3000';
  static const String settingsDeviceLabel = 'Thiết bị này';
  static const String settingsDeviceHint = 'iPhone của bạn (địa chỉ Wi-Fi)';
  static const String settingsBackendLabel = 'Máy chủ giọng nói';
  static const String settingsBackendPortLabel = 'Cổng';
  static const String settingsBackendLatencyLabel = 'Độ trễ';
  static const String settingsBackendProviderLabel = 'Nhà cung cấp';
  static const String settingsBackendStatusConnected = 'Đã kết nối';
  static const String settingsBackendStatusNotConnected = 'Không kết nối';
  static const String settingsBackendSave = 'Lưu';
  static const String settingsBackendSaved = 'Đã lưu địa chỉ máy chủ.';
  static const String settingsBackendReset = 'Dùng mặc định';
  static const String settingsBackendNotSet =
      'Chưa có địa chỉ. Bấm "Dò trong mạng LAN" hoặc nhập IP máy chủ.';
  static const String settingsBackendScan = 'Dò mạng LAN';
  static const String settingsBackendScanning = 'Đang dò {0}/{1}...';
  static const String settingsBackendScanFound = 'Tìm thấy {0} máy chủ.';
  static const String settingsBackendScanNone =
      'Không tìm thấy backend nào. Hãy kiểm tra máy chủ đã bật và cùng một mạng Wi-Fi.';
  static const String settingsBackendScanNoAddress =
      'Không lấy được địa chỉ IP của máy. Hãy nhập địa chỉ thủ công.';
  static const String settingsBackendScanNoLanPermission =
      'VietVoice Studio chưa được phép truy cập mạng nội bộ. Mở Cài đặt → Quyền riêng tư & Bảo mật → Mạng nội bộ → VietVoice Studio → Bật, rồi thử lại.';
  static const String settingsBackendOpenSettings = 'Mở Cài đặt';
  static const String settingsBackendScanLocalNetwork =
      'Ứng dụng cần quyền Mạng nội bộ để tìm máy chủ trong Wi-Fi. Nếu đã từng từ chối, mở Cài đặt → VietVoice Studio → Mạng nội bộ. Bạn vẫn có thể nhập IP thủ công ở ô trên.';
  static const String settingsBackendScanIfaceReport =
      'Giao diện mạng: {0}';
  static const String settingsBackendScanTried = 'Đã dò quanh {0}';
  static const String settingsBackendScanManualHint =
      'Nhập IP máy chủ thủ công vẫn dùng được trong mọi trường hợp.';
  static const String settingsBackendScanTitle = 'Máy chủ trong mạng LAN';
  static const String settingsBackendScanHint = 'Chạm để dùng máy chủ này';
  static const String settingsBackendCheck = 'Kiểm tra';
  static const String settingsBackendEnterAddress = 'Nhập địa chỉ máy chủ';
  static const String settingsBackendChecking = 'Đang kiểm tra...';
  static const String settingsBackendCheckOk = 'Kết nối được ({0} ms).';
  static const String settingsBackendCheckFailed =
      'Không kết nối được máy chủ này.';
  static const String settingsBackendCheckRefused =
      'Đã tới máy chủ nhưng cổng {1} không nhận kết nối tại {0}. Backend chưa chạy hoặc tường lửa đang chặn.';
  static const String settingsBackendCheckTimeout =
      'Máy chủ không phản hồi tại {0} (quá thời gian). Backend có thể đã tắt hoặc Wi-Fi chặn kết nối giữa các thiết bị.';
  static const String settingsBackendCheckUnreachable =
      'Không có đường tới {0}. Điện thoại và máy chạy backend phải cùng một mạng Wi-Fi.';
  static const String settingsBackendCheckHttp =
      'Backend trả về HTTP {0}. {1}';
  static const String settingsBackendCheckHttpNotFound =
      'Backend đang chạy nhưng endpoint sai (HTTP 404). Kiểm tra địa chỉ có dạng http://<ip>:3000/v1.';
  static const String settingsBackendCheckHttpAuth =
      'Backend yêu cầu xác thực (HTTP {0}). Kiểm tra API key trong Cài đặt → Kết nối dịch vụ.';
  static const String settingsBackendCheckHttpServer =
      'Backend gặp lỗi nội bộ (HTTP {0}). Kiểm tra log backend / provider.';
  static const String settingsBackendCheckWrongService =
      'Máy chủ tại {0} phản hồi nhưng không phải VietVoice backend.';
  static const String settingsBackendCurrent = 'Đang dùng';
  static const String settingsBackendClose = 'Đóng';

  static const String settingsAbout = 'Giới thiệu';
  static const String settingsVersion = 'Phiên bản';
  static const String settingsPrivacyPolicy = 'Chính sách bảo mật';
  static const String settingsTermsOfService = 'Điều khoản dịch vụ';
  static const String settingsContact = 'Liên hệ hỗ trợ';

  // Errors
  static const String errorNetwork =
      'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.';

  /// The backend is self-hosted, so a failed call almost always means the
  /// server is not running (or the address is wrong), not a device problem.
  static const String errorBackendUnreachable =
      'Không kết nối được máy chủ giọng nói. Kiểm tra backend đang chạy và địa chỉ trong Cài đặt → Kết nối dịch vụ.';

  /// Same failure, but naming the address that was actually dialled. A
  /// self-hosted backend is reached by IP, so the address is the thing that is
  /// almost always wrong.
  static String errorBackendUnreachableAt(String endpoint) =>
      'Không kết nối được máy chủ giọng nói tại $endpoint.\n'
      'Kiểm tra backend đang chạy và địa chỉ trong Cài đặt → Kết nối dịch vụ.';

  /// Nothing was dialled because no address has been set. Distinct from
  /// [errorBackendUnreachable]: the fix is to give the app an address, not to go
  /// and start a server.
  static const String errorBackendNotConfigured =
      'Chưa có địa chỉ máy chủ giọng nói. Mở Cài đặt → Kết nối dịch vụ, bấm "Dò trong mạng LAN" hoặc nhập IP của máy đang chạy backend.';

  // ---- Backend reachability, one message per actual cause ----
  // Every one of these used to be reported as "không kết nối được", which is
  // true for all of them and points at the right fix for none.

  static String errorBackendRefused(String endpoint) =>
      'Máy chủ từ chối kết nối tại $endpoint.\n'
      'Cổng 3000 không có gì lắng nghe: backend chưa chạy, hoặc tường lửa '
      'Windows chặn kết nối từ mạng LAN.';

  static String errorBackendTimedOut(String endpoint) =>
      'Máy chủ không phản hồi tại $endpoint (quá thời gian).\n'
      'Backend có thể đã tắt, hoặc mạng Wi-Fi đang chặn kết nối giữa các thiết bị.';

  static String errorBackendUnreachableRoute(String endpoint) =>
      'Không có đường tới $endpoint.\n'
      'Điện thoại và máy chạy backend phải cùng một mạng Wi-Fi. Nếu router bật '
      '"AP isolation"/"Client isolation", hãy tắt hoặc dùng hotspot.';

  static String errorBackendDns(String endpoint) =>
      'Không phân giải được tên máy chủ trong $endpoint.\n'
      'Backend chạy trong LAN nên hãy nhập IP, ví dụ 192.168.1.20:3000.';

  static String errorBackendTls(String endpoint) =>
      'Không thiết lập được kết nối bảo mật tới $endpoint.\n'
      'Backend trong LAN dùng http://, hãy nhập địa chỉ bắt đầu bằng http://.';

  static String errorBackendClient(int statusCode, String detail) =>
      'Máy chủ từ chối yêu cầu (HTTP $statusCode).\n$detail';

  static String errorBackendServer(int statusCode, String detail) =>
      'Máy chủ gặp lỗi (HTTP $statusCode).\n$detail';

  /// Health-check failures keep their HTTP meaning: 404 is a wrong endpoint,
  /// 401/403 is auth, 5xx is the server/provider — never a generic message.
  static String errorBackendHealthHttp(int statusCode, String endpoint) {
    if (statusCode == 404) return AppStrings.settingsBackendCheckHttpNotFound;
    if (statusCode == 401 || statusCode == 403) {
      return AppStrings.fill(AppStrings.settingsBackendCheckHttpAuth, [
        statusCode,
      ]);
    }
    if (statusCode >= 500) {
      return AppStrings.fill(AppStrings.settingsBackendCheckHttpServer, [
        statusCode,
      ]);
    }
    return AppStrings.fill(AppStrings.settingsBackendCheckHttp, [
      statusCode,
      endpoint,
    ]);
  }

  static const String errorLocalNetworkPermission =
      'VietVoice Studio chưa được phép truy cập mạng nội bộ.\n'
      'Mở Cài đặt → Quyền riêng tư & Bảo mật → Mạng nội bộ → VietVoice Studio → Bật.';

  static const String errorUnauthorized =
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
  static const String errorQuotaExceeded =
      'Bạn đã vượt quá hạn mức sử dụng. Vui lòng nâng cấp gói.';
  static const String errorTimeout = 'Yêu cầu quá thời gian. Vui lòng thử lại.';
  static const String errorProviderUnavailable =
      'Dịch vụ tạm thời gián đoạn. Vui lòng thử lại sau.';
  static const String errorEdgeUnavailable =
      'Microsoft Edge TTS đang tạm thời không phản hồi (thường do bị giới hạn tần suất). Hãy thử lại sau vài giây, đổi giọng khác hoặc dùng ElevenLabs.';
  static const String errorInvalidAudio =
      'Tệp âm thanh không hợp lệ hoặc bị hỏng.';
  static const String errorCloningFailed =
      'Nhân bản giọng nói thất bại. Vui lòng thử lại với âm thanh chất lượng tốt hơn.';
  static const String errorFileNotFound = 'Không tìm thấy tệp.';
  static const String errorFileTooLarge =
      'Tệp quá lớn. Kích thước tối đa: 50MB.';
  static const String errorUnsupportedFormat = 'Định dạng không được hỗ trợ.';
  static const String errorStorageFull =
      'Bộ nhớ đầy. Vui lòng xóa bớt dữ liệu.';
  static const String errorUnknown = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const String errorServer = 'Lỗi máy chủ. Vui lòng thử lại sau.';
  static const String errorValidation =
      'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
  static const String errorPermissionDenied =
      'Quyền bị từ chối. Vui lòng cấp quyền trong Cài đặt.';
  static const String errorMicrophonePermission =
      'Cần quyền truy cập micrô để ghi âm.';
  static const String errorStoragePermission =
      'Cần quyền truy cập bộ nhớ để lưu tệp.';
  static final String errorRecordingTooShort =
      'Bản ghi quá ngắn. Tối thiểu ${recordVoiceMinDuration.inSeconds} giây.';
  static final String errorRecordingTooLong =
      'Bản ghi quá dài. Tối đa ${recordVoiceMaxDuration.inSeconds} giây.';
  static const String errorNoInternet = 'Không có kết nối internet.';
  static const String errorSsl = 'Lỗi chứng chỉ bảo mật.';
  static const String errorParsing = 'Lỗi xử lý dữ liệu phản hồi.';
  static const String errorCancelled = 'Yêu cầu đã bị hủy.';
  static const String errorRateLimit =
      'Quá nhiều yêu cầu. Vui lòng chờ một chút.';
  static const String errorPaymentRequired =
      'Cần thanh toán để sử dụng tính năng này.';
  static const String errorMaintenance =
      'Hệ thống đang bảo trì. Vui lòng quay lại sau.';
  static const String errorTokenExpired = 'Phiên làm việc đã hết hạn.';
  static const String errorInvalidCredentials =
      'Thông tin đăng nhập không chính xác.';
  static const String errorAccountLocked =
      'Tài khoản đã bị khóa. Vui lòng liên hệ hỗ trợ.';
  static const String errorVoiceNotFound = 'Không tìm thấy giọng đọc.';
  static const String errorProjectNotFound = 'Không tìm thấy dự án.';
  static const String errorExportFailed = 'Xuất tệp thất bại.';
  static const String errorImportFailed = 'Nhập tệp thất bại.';
  static const String errorShareFailed = 'Chia sẻ thất bại.';
  static const String errorDownloadFailed = 'Tải xuống thất bại.';
  static const String errorPlaybackFailed = 'Phát âm thanh thất bại.';
  static const String errorInvalidUrl = 'Đường dẫn không hợp lệ.';
  static const String errorOversizedResponse = 'Phản hồi quá lớn.';
  static const String errorSocket = 'Lỗi kết nối thời gian thực.';
  static const String errorTimeoutConnection =
      'Kết nối thời gian thực bị gián đoạn.';
  static const String errorInvalidState = 'Trạng thái không hợp lệ.';
  static const String errorOperationNotSupported =
      'Thao tác không được hỗ trợ.';
  static const String errorInsufficientCredits =
      'Không đủ tín dụng. Vui lòng nạp thêm.';
  static const String errorConcurrentLimit = 'Đã đạt giới hạn tạo đồng thời.';
  static const String errorAudioDecode = 'Không thể giải mã âm thanh.';
  static const String errorAudioEncode = 'Không thể mã hóa âm thanh.';
  static const String errorFileCorrupted = 'Tệp bị hỏng.';
  static const String errorPathNotFound = 'Đường dẫn không tồn tại.';
  static const String errorDiskFull = 'Ổ đĩa đầy.';
  static const String errorMemory = 'Không đủ bộ nhớ.';
  static const String errorPlatform = 'Lỗi nền tảng.';
  static const String errorPluginNotAvailable = 'Plugin không khả dụng.';
  static const String errorFeatureNotAvailable =
      'Tính năng chưa khả dụng trên thiết bị này.';
  static const String errorUpdateRequired = 'Cần cập nhật ứng dụng.';
  static const String errorServiceUnavailable =
      'Dịch vụ tạm thời không khả dụng.';
  static const String errorGateway = 'Lỗi cổng kết nối.';
  static const String errorBadGateway = 'Cổng kết nối phản hồi không hợp lệ.';
  static const String errorConflict = 'Xung đột dữ liệu.';
  static const String errorPreconditionFailed =
      'Điều kiện tiên quyết không đáp ứng.';
  static const String errorNotImplemented = 'Tính năng chưa được triển khai.';
  static const String errorInternal = 'Lỗi nội bộ.';
  static const String errorDatabase = 'Lỗi cơ sở dữ liệu.';
  static const String errorCache = 'Lỗi bộ nhớ đệm.';
  static const String errorSerialization = 'Lỗi tuần tự hóa dữ liệu.';
  static const String errorDeserialization = 'Lỗi giải tuần tự hóa dữ liệu.';
  static const String errorEncryption = 'Lỗi mã hóa.';
  static const String errorDecryption = 'Lỗi giải mã.';
  static const String errorCompression = 'Lỗi nén dữ liệu.';
  static const String errorDecompression = 'Lỗi giải nén dữ liệu.';
  static const String errorHashMismatch = 'Dữ liệu không khớp.';
  static const String errorChecksum = 'Lỗi kiểm tra tổng.';
  static const String errorInvalidFormat = 'Định dạng không hợp lệ.';
  static const String errorMissingField = 'Thiếu trường dữ liệu bắt buộc.';
  static const String errorInvalidField = 'Trường dữ liệu không hợp lệ.';
  static const String errorDuplicate = 'Dữ liệu trùng lặp.';
  static const String errorExpired = 'Đã hết hạn.';
  static const String errorNotAllowed = 'Không được phép.';
  static const String errorForbidden = 'Truy cập bị từ chối.';
  static const String errorNotFound = 'Không tìm thấy.';
  static const String errorAlreadyExists = 'Đã tồn tại.';
  static const String errorGone = 'Tài nguyên không còn tồn tại.';
  static const String errorTooManyRequests = 'Quá nhiều yêu cầu.';
  static const String errorRequestEntityTooLarge = 'Dữ liệu gửi lên quá lớn.';
  static const String errorUnsupportedMediaType =
      'Loại phương tiện không được hỗ trợ.';
  static const String errorExpectationFailed = 'Kỳ vọng thất bại.';
  static const String errorUnprocessable = 'Không thể xử lý.';
  static const String errorFailedDependency = 'Phụ thuộc thất bại.';
  static const String errorUpgradeRequired = 'Cần nâng cấp.';
  static const String errorPreconditionRequired = 'Cần điều kiện tiên quyết.';
  static const String errorRequestHeaderTooLarge = 'Header yêu cầu quá lớn.';
  static const String errorUnavailableForLegalReasons =
      'Không khả dụng vì lý do pháp lý.';
  static const String errorClientClosed = 'Máy khách đã đóng kết nối.';
  static const String errorNetworkAuthRequired = 'Cần xác thực mạng.';
  static const String errorNetworkTimeout = 'Mạng quá thời gian.';
  static const String errorNetworkConnect = 'Lỗi kết nối mạng.';
  static const String errorNetworkRead = 'Lỗi đọc mạng.';
  static const String errorNetworkWrite = 'Lỗi ghi mạng.';
  static const String errorNetworkReceive = 'Lỗi nhận mạng.';
  static const String errorNetworkSend = 'Lỗi gửi mạng.';
  static const String errorNetworkReset = 'Mạng bị đặt lại.';
  static const String errorNetworkAborted = 'Mạng bị hủy.';
  static const String errorNetworkUnavailable = 'Mạng không khả dụng.';
  static const String errorNetworkSocket = 'Lỗi socket mạng.';
  static const String errorNetworkProtocol = 'Lỗi giao thức mạng.';
  static const String errorNetworkAddress = 'Lỗi địa chỉ mạng.';
  static const String errorNetworkBind = 'Lỗi ràng buộc mạng.';
  static const String errorNetworkListen = 'Lỗi lắng nghe mạng.';
  static const String errorNetworkAccept = 'Lỗi chấp nhận mạng.';
  static const String errorNetworkConnectTimeout =
      'Kết nối mạng quá thời gian.';
  static const String errorNetworkConnectionRefused =
      'Kết nối mạng bị từ chối.';
  static const String errorNetworkConnectionReset = 'Kết nối mạng bị đặt lại.';
  static const String errorNetworkConnectionAborted = 'Kết nối mạng bị hủy.';
  static const String errorNetworkHostDown = 'Máy chủ tắt.';
  static const String errorNetworkHostUnreachable =
      'Không thể truy cập máy chủ.';
  static const String errorNetworkProtocolNotSupported =
      'Giao thức mạng không được hỗ trợ.';
  static const String errorNetworkFamilyNotSupported =
      'Họ địa chỉ không được hỗ trợ.';
  static const String errorNetworkAddressNotAvailable =
      'Địa chỉ không khả dụng.';
  static const String errorNetworkAddressInUse = 'Địa chỉ đang được sử dụng.';
  static const String errorNetworkNoBufferSpace = 'Không đủ bộ nhớ đệm mạng.';
  static const String errorNetworkNoData = 'Không có dữ liệu mạng.';
  static const String errorNetworkNotConnected = 'Chưa kết nối mạng.';
  static const String errorNetworkNotSocket = 'Không phải socket mạng.';
  static const String errorNetworkOperationNotSupported =
      'Thao tác mạng không được hỗ trợ.';
  static const String errorNetworkShutdown = 'Mạng đã tắt.';
  static const String errorNetworkTimedOut = 'Mạng quá thời gian.';
  static const String errorNetworkWouldBlock = 'Mạng sẽ bị chặn.';
  static const String errorNetworkWriteProtected = 'Mạng được bảo vệ ghi.';
  static const String errorNetworkTryAgain = 'Thử lại mạng.';
  static const String errorNetworkNoRecovery = 'Không thể phục hồi mạng.';
  static const String errorNetworkStack = 'Lỗi ngăn xếp mạng.';
  static const String errorNetworkSoftware = 'Lỗi phần mềm mạng.';
  static const String errorNetworkNoLink = 'Không có liên kết mạng.';
  static const String errorNetworkProtocolWrongType =
      'Sai loại giao thức mạng.';
  static const String errorNetworkProtocolNoProtocol =
      'Không có giao thức mạng.';
  static const String errorNetworkProtocolNotAvailable =
      'Giao thức mạng không khả dụng.';
  static const String errorNetworkSocketTypeNotSupported =
      'Loại socket không được hỗ trợ.';
  static const String errorNetworkProtocolFamilyNotSupported =
      'Họ giao thức không được hỗ trợ.';
  static const String errorNetworkAddressFamilyNotSupported =
      'Họ địa chỉ không được hỗ trợ.';
  static const String errorNetworkNetworkDown = 'Mạng tắt.';
  static const String errorNetworkNetworkUnreachable =
      'Mạng không thể truy cập.';
  static const String errorNetworkNetworkReset = 'Mạng bị đặt lại.';
  static const String errorNetworkConnectionAborted2 = 'Kết nối bị hủy.';
  static const String errorNetworkConnectionReset2 = 'Kết nối bị đặt lại.';
  static const String errorNetworkNoBufferSpace2 = 'Không đủ bộ nhớ đệm.';
  static const String errorNetworkIsConnected = 'Đã kết nối.';
  static const String errorNetworkNotConnected2 = 'Chưa kết nối.';
  static const String errorNetworkShutdown2 = 'Đã tắt.';
  static const String errorNetworkTimedOut2 = 'Quá thời gian.';
  static const String errorNetworkConnectionRefused2 = 'Kết nối bị từ chối.';
  static const String errorNetworkHostDown2 = 'Máy chủ tắt.';
  static const String errorNetworkHostUnreachable2 =
      'Không thể truy cập máy chủ.';
  static const String errorNetworkAlreadyInProgress = 'Đang trong quá trình.';
  static const String errorNetworkAlreadyConnected = 'Đã kết nối.';
  static const String errorNetworkInvalidArgument = 'Đối số không hợp lệ.';
  static const String errorNetworkInvalidHandle = 'Handle không hợp lệ.';
  static const String errorNetworkInvalidData = 'Dữ liệu không hợp lệ.';
  static const String errorNetworkInvalidName = 'Tên không hợp lệ.';
  static const String errorNetworkInvalidPassword = 'Mật khẩu không hợp lệ.';
  static const String errorNetworkInvalidPort = 'Cổng không hợp lệ.';
  static const String errorNetworkInvalidService = 'Dịch vụ không hợp lệ.';
  static const String errorNetworkInvalidSocket = 'Socket không hợp lệ.';
  static const String errorNetworkInvalidAddress = 'Địa chỉ không hợp lệ.';
  static const String errorNetworkInvalidBuffer = 'Bộ đệm không hợp lệ.';
  static const String errorNetworkInvalidFlag = 'Cờ không hợp lệ.';
  static const String errorNetworkInvalidOption = 'Tùy chọn không hợp lệ.';
  static const String errorNetworkInvalidParameter = 'Tham số không hợp lệ.';
  static const String errorNetworkInvalidState = 'Trạng thái không hợp lệ.';
  static const String errorNetworkInvalidOperation = 'Thao tác không hợp lệ.';
  static const String errorNetworkInvalidRequest = 'Yêu cầu không hợp lệ.';
  static const String errorNetworkInvalidResponse = 'Phản hồi không hợp lệ.';
  static const String errorNetworkInvalidMessage = 'Tin nhắn không hợp lệ.';
  static const String errorNetworkInvalidPacket = 'Gói tin không hợp lệ.';
  static const String errorNetworkInvalidFrame = 'Khung không hợp lệ.';
  static const String errorNetworkInvalidSegment = 'Đoạn không hợp lệ.';
  static const String errorNetworkInvalidBlock = 'Khối không hợp lệ.';
  static const String errorNetworkInvalidCell = 'Ô không hợp lệ.';
  static const String errorNetworkInvalidField2 = 'Trường không hợp lệ.';
  static const String errorNetworkInvalidRecord = 'Bản ghi không hợp lệ.';
  static const String errorNetworkInvalidFile = 'Tệp không hợp lệ.';
  static const String errorNetworkInvalidDirectory = 'Thư mục không hợp lệ.';
  static const String errorNetworkInvalidPath = 'Đường dẫn không hợp lệ.';
  static const String errorNetworkInvalidDevice = 'Thiết bị không hợp lệ.';
  static const String errorNetworkInvalidDriver =
      'Trình điều khiển không hợp lệ.';
  static const String errorNetworkInvalidModule = 'Mô-đun không hợp lệ.';
  static const String errorNetworkInvalidProcess = 'Tiến trình không hợp lệ.';
  static const String errorNetworkInvalidThread = 'Luồng không hợp lệ.';
  static const String errorNetworkInvalidTask = 'Tác vụ không hợp lệ.';
  static const String errorNetworkInvalidJob = 'Công việc không hợp lệ.';
  static const String errorNetworkInvalidQueue = 'Hàng đợi không hợp lệ.';
  static const String errorNetworkInvalidEvent = 'Sự kiện không hợp lệ.';
  static const String errorNetworkInvalidSignal = 'Tín hiệu không hợp lệ.';
  static const String errorNetworkInvalidTimer =
      'Bộ đếm thời gian không hợp lệ.';
  static const String errorNetworkInvalidCounter = 'Bộ đếm không hợp lệ.';
  static const String errorNetworkInvalidMeter = 'Đồng hồ không hợp lệ.';
  static const String errorNetworkInvalidGauge = 'Đồng hồ đo không hợp lệ.';
  static const String errorNetworkInvalidIndicator = 'Chỉ báo không hợp lệ.';
  static const String errorNetworkInvalidDisplay = 'Hiển thị không hợp lệ.';
  static const String errorNetworkInvalidControl = 'Điều khiển không hợp lệ.';
  static const String errorNetworkInvalidWidget = 'Widget không hợp lệ.';
  static const String errorNetworkInvalidComponent = 'Thành phần không hợp lệ.';
  static const String errorNetworkInvalidElement = 'Phần tử không hợp lệ.';
  static const String errorNetworkInvalidObject = 'Đối tượng không hợp lệ.';
  static const String errorNetworkInvalidInstance = 'Thể hiện không hợp lệ.';
  static const String errorNetworkInvalidClass = 'Lớp không hợp lệ.';
  static const String errorNetworkInvalidType = 'Loại không hợp lệ.';
  static const String errorNetworkInvalidValue = 'Giá trị không hợp lệ.';
  static const String errorNetworkInvalidKey = 'Khóa không hợp lệ.';
  static const String errorNetworkInvalidIndex = 'Chỉ mục không hợp lệ.';
  static const String errorNetworkInvalidPosition = 'Vị trí không hợp lệ.';
  static const String errorNetworkInvalidSize = 'Kích thước không hợp lệ.';
  static const String errorNetworkInvalidLength = 'Độ dài không hợp lệ.';
  static const String errorNetworkInvalidWidth = 'Chiều rộng không hợp lệ.';
  static const String errorNetworkInvalidHeight = 'Chiều cao không hợp lệ.';
  static const String errorNetworkInvalidDepth = 'Chiều sâu không hợp lệ.';
  static const String errorNetworkInvalidRadius = 'Bán kính không hợp lệ.';
  static const String errorNetworkInvalidAngle = 'Góc không hợp lệ.';
  static const String errorNetworkInvalidRotation = 'Xoay không hợp lệ.';
  static const String errorNetworkInvalidScale = 'Tỷ lệ không hợp lệ.';
  static const String errorNetworkInvalidOffset = 'Độ lệch không hợp lệ.';
  static const String errorNetworkInvalidMargin = 'Lề không hợp lệ.';
  static const String errorNetworkInvalidPadding = 'Đệm không hợp lệ.';
  static const String errorNetworkInvalidBorder = 'Viền không hợp lệ.';
  static const String errorNetworkInvalidBackground = 'Nền không hợp lệ.';
  static const String errorNetworkInvalidForeground = 'Tiền cảnh không hợp lệ.';
  static const String errorNetworkInvalidColor = 'Màu không hợp lệ.';
  static const String errorNetworkInvalidFont = 'Phông chữ không hợp lệ.';
  static const String errorNetworkInvalidStyle = 'Kiểu không hợp lệ.';
  static const String errorNetworkInvalidAlignment = 'Căn chỉnh không hợp lệ.';
  static const String errorNetworkInvalidOrientation = 'Hướng không hợp lệ.';
  static const String errorNetworkInvalidDirection = 'Chiều không hợp lệ.';
  static const String errorNetworkInvalidOrder = 'Thứ tự không hợp lệ.';
  static const String errorNetworkInvalidPriority = 'Ưu tiên không hợp lệ.';
  static const String errorNetworkInvalidWeight = 'Trọng lượng không hợp lệ.';
  static const String errorNetworkInvalidCapacity = 'Sức chứa không hợp lệ.';
  static const String errorNetworkInvalidLimit = 'Giới hạn không hợp lệ.';
  static const String errorNetworkInvalidThreshold = 'Ngưỡng không hợp lệ.';
  static const String errorNetworkInvalidTolerance = 'Dung sai không hợp lệ.';
  static const String errorNetworkInvalidPrecision =
      'Độ chính xác không hợp lệ.';
  static const String errorNetworkInvalidAccuracy =
      'Độ chính xác không hợp lệ.';
  static const String errorNetworkInvalidResolution =
      'Độ phân giải không hợp lệ.';
  static const String errorNetworkInvalidFrequency = 'Tần số không hợp lệ.';
  static const String errorNetworkInvalidAmplitude = 'Biên độ không hợp lệ.';
  static const String errorNetworkInvalidPhase = 'Pha không hợp lệ.';
  static const String errorNetworkInvalidWavelength = 'Bước sóng không hợp lệ.';
  static const String errorNetworkInvalidVelocity = 'Vận tốc không hợp lệ.';
  static const String errorNetworkInvalidAcceleration = 'Gia tốc không hợp lệ.';
  static const String errorNetworkInvalidForce = 'Lực không hợp lệ.';
  static const String errorNetworkInvalidEnergy = 'Năng lượng không hợp lệ.';
  static const String errorNetworkInvalidPower = 'Công suất không hợp lệ.';
  static const String errorNetworkInvalidPressure = 'Áp suất không hợp lệ.';
  static const String errorNetworkInvalidTemperature = 'Nhiệt độ không hợp lệ.';
  static const String errorNetworkInvalidHumidity = 'Độ ẩm không hợp lệ.';
  static const String errorNetworkInvalidDensity = 'Mật độ không hợp lệ.';
  static const String errorNetworkInvalidVolume = 'Thể tích không hợp lệ.';
  static const String errorNetworkInvalidMass = 'Khối lượng không hợp lệ.';
  static const String errorNetworkInvalidDistance = 'Khoảng cách không hợp lệ.';
  static const String errorNetworkInvalidArea = 'Diện tích không hợp lệ.';
  static const String errorNetworkInvalidSpeed = 'Tốc độ không hợp lệ.';
  static const String errorNetworkInvalidTime = 'Thời gian không hợp lệ.';
  static const String errorNetworkInvalidDate = 'Ngày không hợp lệ.';
  static const String errorNetworkInvalidDateTime = 'Ngày giờ không hợp lệ.';
  static const String errorNetworkInvalidTimestamp =
      'Dấu thời gian không hợp lệ.';
  static const String errorNetworkInvalidDuration = 'Thời lượng không hợp lệ.';
  static const String errorNetworkInvalidInterval =
      'Khoảng thời gian không hợp lệ.';
  static const String errorNetworkInvalidPeriod = 'Chu kỳ không hợp lệ.';
  static const String errorNetworkInvalidCycle = 'Chu kỳ không hợp lệ.';
  static const String errorNetworkInvalidLoop = 'Vòng lặp không hợp lệ.';
  static const String errorNetworkInvalidIteration = 'Lặp không hợp lệ.';
  static const String errorNetworkInvalidRecursion = 'Đệ quy không hợp lệ.';
  static const String errorNetworkInvalidSequence = 'Chuỗi không hợp lệ.';
  static const String errorNetworkInvalidSeries = 'Loạt không hợp lệ.';
  static const String errorNetworkInvalidArray = 'Mảng không hợp lệ.';
  static const String errorNetworkInvalidList = 'Danh sách không hợp lệ.';
  static const String errorNetworkInvalidStack = 'Ngăn xếp không hợp lệ.';
  static const String errorNetworkInvalidQueue2 = 'Hàng đợi không hợp lệ.';
  static const String errorNetworkInvalidTree = 'Cây không hợp lệ.';
  static const String errorNetworkInvalidGraph = 'Đồ thị không hợp lệ.';
  static const String errorNetworkInvalidHash = 'Băm không hợp lệ.';
  static const String errorNetworkInvalidMap = 'Bản đồ không hợp lệ.';
  static const String errorNetworkInvalidSet = 'Tập hợp không hợp lệ.';
  static const String errorNetworkInvalidCollection =
      'Bộ sưu tập không hợp lệ.';
  static const String errorNetworkInvalidIterator = 'Bộ lặp không hợp lệ.';
  static const String errorNetworkInvalidGenerator = 'Bộ sinh không hợp lệ.';
  static const String errorNetworkInvalidCoroutine = 'Đồng tuyến không hợp lệ.';
  static const String errorNetworkInvalidFuture = 'Tương lai không hợp lệ.';
  static const String errorNetworkInvalidPromise = 'Lời hứa không hợp lệ.';
  static const String errorNetworkInvalidAsync = 'Không đồng bộ không hợp lệ.';
  static const String errorNetworkInvalidAwait = 'Chờ không hợp lệ.';
  static const String errorNetworkInvalidYield = 'Sản xuất không hợp lệ.';
  static const String errorNetworkInvalidReturn = 'Trả về không hợp lệ.';
  static const String errorNetworkInvalidBreak = 'Ngắt không hợp lệ.';
  static const String errorNetworkInvalidContinue = 'Tiếp tục không hợp lệ.';
  static const String errorNetworkInvalidThrow = 'Ném không hợp lệ.';
  static const String errorNetworkInvalidCatch = 'Bắt không hợp lệ.';
  static const String errorNetworkInvalidTry = 'Thử không hợp lệ.';
  static const String errorNetworkInvalidFinally = 'Cuối cùng không hợp lệ.';
  static const String errorNetworkInvalidSwitch = 'Chuyển không hợp lệ.';
  static const String errorNetworkInvalidCase = 'Trường hợp không hợp lệ.';
  static const String errorNetworkInvalidDefault = 'Mặc định không hợp lệ.';
  static const String errorNetworkInvalidIf = 'Nếu không hợp lệ.';
  static const String errorNetworkInvalidElse = 'Không thì không hợp lệ.';
  static const String errorNetworkInvalidWhile = 'Trong khi không hợp lệ.';
  static const String errorNetworkInvalidFor = 'Với không hợp lệ.';
  static const String errorNetworkInvalidDo = 'Làm không hợp lệ.';
  static const String errorNetworkInvalidFunction = 'Hàm không hợp lệ.';
  static const String errorNetworkInvalidMethod = 'Phương thức không hợp lệ.';
  static const String errorNetworkInvalidConstructor = 'Hàm tạo không hợp lệ.';
  static const String errorNetworkInvalidDestructor = 'Hàm hủy không hợp lệ.';
  static const String errorNetworkInvalidOperator = 'Toán tử không hợp lệ.';
  static const String errorNetworkInvalidExpression = 'Biểu thức không hợp lệ.';
  static const String errorNetworkInvalidStatement = 'Câu lệnh không hợp lệ.';
  static const String errorNetworkInvalidDeclaration = 'Khai báo không hợp lệ.';
  static const String errorNetworkInvalidDefinition =
      'Định nghĩa không hợp lệ.';
  static const String errorNetworkInvalidAssignment = 'Gán không hợp lệ.';
  static const String errorNetworkInvalidInitialization =
      'Khởi tạo không hợp lệ.';
  static const String errorNetworkInvalidInstantiation =
      'Khởi tạo thể hiện không hợp lệ.';
  static const String errorNetworkInvalidInvocation = 'Gọi không hợp lệ.';
  static const String errorNetworkInvalidCall = 'Gọi không hợp lệ.';
  static const String errorNetworkInvalidReference = 'Tham chiếu không hợp lệ.';
  static const String errorNetworkInvalidPointer = 'Con trỏ không hợp lệ.';
  static const String errorNetworkInvalidAddress2 = 'Địa chỉ không hợp lệ.';
  static const String errorNetworkInvalidDereference =
      'Giải tham chiếu không hợp lệ.';
  static const String errorNetworkInvalidCast = 'Ép kiểu không hợp lệ.';
  static const String errorNetworkInvalidConversion =
      'Chuyển đổi không hợp lệ.';
  static const String errorNetworkInvalidPromotion = 'Thăng cấp không hợp lệ.';
  static const String errorNetworkInvalidDemotion = 'Hạ cấp không hợp lệ.';
  static const String errorNetworkInvalidCoercion = 'Ép buộc không hợp lệ.';
  static const String errorNetworkInvalidBoxing = 'Đóng gói không hợp lệ.';
  static const String errorNetworkInvalidUnboxing = 'Mở gói không hợp lệ.';
  static const String errorNetworkInvalidNullable = 'Có thể null không hợp lệ.';
  static const String errorNetworkInvalidOptional = 'Tùy chọn không hợp lệ.';
  static const String errorNetworkInvalidRequired = 'Bắt buộc không hợp lệ.';
  static const String errorNetworkInvalidConst = 'Hằng không hợp lệ.';
  static const String errorNetworkInvalidStatic = 'Tĩnh không hợp lệ.';
  static const String errorNetworkInvalidFinal = 'Cuối không hợp lệ.';
  static const String errorNetworkInvalidAbstract = 'Trừu tượng không hợp lệ.';
  static const String errorNetworkInvalidInterface = 'Giao diện không hợp lệ.';
  static const String errorNetworkInvalidClass2 = 'Lớp không hợp lệ.';
  static const String errorNetworkInvalidStruct = 'Cấu trúc không hợp lệ.';
  static const String errorNetworkInvalidEnum = 'Liệt kê không hợp lệ.';
  static const String errorNetworkInvalidUnion = 'Hợp nhất không hợp lệ.';
  static const String errorNetworkInvalidNamespace =
      'Không gian tên không hợp lệ.';
  static const String errorNetworkInvalidModule2 = 'Mô-đun không hợp lệ.';
  static const String errorNetworkInvalidPackage = 'Gói không hợp lệ.';
  static const String errorNetworkInvalidImport = 'Nhập không hợp lệ.';
  static const String errorNetworkInvalidExport = 'Xuất không hợp lệ.';
  static const String errorNetworkInvalidInclude = 'Bao gồm không hợp lệ.';
  static const String errorNetworkInvalidUsing = 'Sử dụng không hợp lệ.';
  static const String errorNetworkInvalidAlias = 'Bí danh không hợp lệ.';
  static const String errorNetworkInvalidTemplate = 'Mẫu không hợp lệ.';
  static const String errorNetworkInvalidGeneric = 'Tổng quát không hợp lệ.';
  static const String errorNetworkInvalidConstraint = 'Ràng buộc không hợp lệ.';
  static const String errorNetworkInvalidConcept = 'Khái niệm không hợp lệ.';
  static const String errorNetworkInvalidRequirement = 'Yêu cầu không hợp lệ.';
  static const String errorNetworkInvalidException = 'Ngoại lệ không hợp lệ.';
  static const String errorNetworkInvalidError = 'Lỗi không hợp lệ.';
  static const String errorNetworkInvalidWarning = 'Cảnh báo không hợp lệ.';
  static const String errorNetworkInvalidNotice = 'Thông báo không hợp lệ.';
  static const String errorNetworkInvalidInfo = 'Thông tin không hợp lệ.';
  static const String errorNetworkInvalidDebug = 'Gỡ lỗi không hợp lệ.';
  static const String errorNetworkInvalidTrace = 'Vết không hợp lệ.';
  static const String errorNetworkInvalidLog = 'Nhật ký không hợp lệ.';
  static const String errorNetworkInvalidMetric = 'Số liệu không hợp lệ.';
  static const String errorNetworkInvalidSpan = 'Khoảng không hợp lệ.';
  static const String errorNetworkInvalidContext = 'Ngữ cảnh không hợp lệ.';
  static const String errorNetworkInvalidScope = 'Phạm vi không hợp lệ.';
  static const String errorNetworkInvalidDomain = 'Miền không hợp lệ.';
  static const String errorNetworkInvalidRange = 'Phạm vi không hợp lệ.';
  static const String errorNetworkInvalidBoundary = 'Biên giới không hợp lệ.';
  static const String errorNetworkInvalidEdge = 'Cạnh không hợp lệ.';
  static const String errorNetworkInvalidVertex = 'Đỉnh không hợp lệ.';
  static const String errorNetworkInvalidFace = 'Mặt không hợp lệ.';
  static const String errorNetworkInvalidCell2 = 'Ô không hợp lệ.';
  static const String errorNetworkInvalidNode = 'Nút không hợp lệ.';
  static const String errorNetworkInvalidLink = 'Liên kết không hợp lệ.';
  static const String errorNetworkInvalidRoot = 'Gốc không hợp lệ.';
  static const String errorNetworkInvalidLeaf = 'Lá không hợp lệ.';
  static const String errorNetworkInvalidBranch = 'Nhánh không hợp lệ.';
  static const String errorNetworkInvalidTrunk = 'Thân không hợp lệ.';
  static const String errorNetworkInvalidStem = 'Thân cây không hợp lệ.';
  static const String errorNetworkInvalidFlower = 'Hoa không hợp lệ.';
  static const String errorNetworkInvalidFruit = 'Quả không hợp lệ.';
  static const String errorNetworkInvalidSeed = 'Hạt giống không hợp lệ.';
  static const String errorNetworkInvalidSoil = 'Đất không hợp lệ.';
  static const String errorNetworkInvalidWater = 'Nước không hợp lệ.';
  static const String errorNetworkInvalidSunlight =
      'Ánh sáng mặt trời không hợp lệ.';
  static const String errorNetworkInvalidAir = 'Không khí không hợp lệ.';
  static const String errorNetworkInvalidWind = 'Gió không hợp lệ.';
  static const String errorNetworkInvalidRain = 'Mưa không hợp lệ.';
  static const String errorNetworkInvalidSnow = 'Tuyết không hợp lệ.';
  static const String errorNetworkInvalidIce = 'Băng không hợp lệ.';
  static const String errorNetworkInvalidCloud = 'Mây không hợp lệ.';
  static const String errorNetworkInvalidStorm = 'Bão không hợp lệ.';
  static const String errorNetworkInvalidThunder = 'Sấm sét không hợp lệ.';
  static const String errorNetworkInvalidLightning = 'Tia chớp không hợp lệ.';
  static const String errorNetworkInvalidRainbow = 'Cầu vồng không hợp lệ.';
  static const String errorNetworkInvalidFog = 'Sương mù không hợp lệ.';
  static const String errorNetworkInvalidMist = 'Sương không hợp lệ.';
  static const String errorNetworkInvalidDew = 'Sương mai không hợp lệ.';
  static const String errorNetworkInvalidFrost = 'Sương giá không hợp lệ.';
  static const String errorNetworkInvalidHail = 'Mưa đá không hợp lệ.';
  static const String errorNetworkInvalidSleet = 'Mưa tuyết không hợp lệ.';
  static const String errorNetworkInvalidBlizzard = 'Bão tuyết không hợp lệ.';
  static const String errorNetworkInvalidAvalanche =
      'Lở đất tuyết không hợp lệ.';
  static const String errorNetworkInvalidLandslide = 'Lở đất không hợp lệ.';
  static const String errorNetworkInvalidEarthquake = 'Động đất không hợp lệ.';
  static const String errorNetworkInvalidTsunami = 'Sóng thần không hợp lệ.';
  static const String errorNetworkInvalidVolcano = 'Núi lửa không hợp lệ.';
  static const String errorNetworkInvalidEruption = 'Phun trào không hợp lệ.';
  static const String errorNetworkInvalidLava = 'Dung nham không hợp lệ.';
  static const String errorNetworkInvalidMagma = 'Dung dịch không hợp lệ.';
  static const String errorNetworkInvalidAsh = 'Tro không hợp lệ.';
  static const String errorNetworkInvalidSmoke = 'Khói không hợp lệ.';
  static const String errorNetworkInvalidDust = 'Bụi không hợp lệ.';
  static const String errorNetworkInvalidSand = 'Cát không hợp lệ.';
  static const String errorNetworkInvalidRock = 'Đá không hợp lệ.';
  static const String errorNetworkInvalidStone = 'Đá không hợp lệ.';
  static const String errorNetworkInvalidPebble = 'Đá cuội không hợp lệ.';
  static const String errorNetworkInvalidBoulder = 'Tảng đá không hợp lệ.';
  static const String errorNetworkInvalidMountain = 'Núi không hợp lệ.';
  static const String errorNetworkInvalidHill = 'Đồi không hợp lệ.';
  static const String errorNetworkInvalidValley = 'Thung lũng không hợp lệ.';
  static const String errorNetworkInvalidCanyon = 'Hẻm núi không hợp lệ.';
  static const String errorNetworkInvalidCave = 'Hang động không hợp lệ.';
  static const String errorNetworkInvalidCliff = 'Vách đá không hợp lệ.';
  static const String errorNetworkInvalidPlateau = 'Cao nguyên không hợp lệ.';
  static const String errorNetworkInvalidPlain = 'Đồng bằng không hợp lệ.';
  static const String errorNetworkInvalidDesert = 'Sa mạc không hợp lệ.';
  static const String errorNetworkInvalidOasis = 'Ốc đảo không hợp lệ.';
  static const String errorNetworkInvalidDune = 'Cồn cát không hợp lệ.';
  static const String errorNetworkInvalidMirage = 'Ảo ảnh không hợp lệ.';
  static const String errorNetworkInvalidIsland = 'Đảo không hợp lệ.';
  static const String errorNetworkInvalidPeninsula = 'Bán đảo không hợp lệ.';
  static const String errorNetworkInvalidArchipelago = 'Quần đảo không hợp lệ.';
  static const String errorNetworkInvalidAtoll = 'Đảo san hô không hợp lệ.';
  static const String errorNetworkInvalidReef = 'Rạn san hô không hợp lệ.';
  static const String errorNetworkInvalidLagoon = 'Đầm phá không hợp lệ.';
  static const String errorNetworkInvalidBay = 'Vịnh không hợp lệ.';
  static const String errorNetworkInvalidGulf = 'Vịnh lớn không hợp lệ.';
  static const String errorNetworkInvalidStrait = 'Eo biển không hợp lệ.';
  static const String errorNetworkInvalidChannel = 'Kênh biển không hợp lệ.';
  static const String errorNetworkInvalidSound = 'Biển không hợp lệ.';
  static const String errorNetworkInvalidInlet = 'Cửa biển không hợp lệ.';
  static const String errorNetworkInvalidEstuary = 'Cửa sông không hợp lệ.';
  static const String errorNetworkInvalidDelta = 'Đồng bằng sông không hợp lệ.';
  static const String errorNetworkInvalidRiver = 'Sông không hợp lệ.';
  static const String errorNetworkInvalidStream = 'Suối không hợp lệ.';
  static const String errorNetworkInvalidBrook = 'Suối nhỏ không hợp lệ.';
  static const String errorNetworkInvalidCreek = 'Suối không hợp lệ.';
  static const String errorNetworkInvalidTributary = 'Sông nhánh không hợp lệ.';
  static const String errorNetworkInvalidBranch2 = 'Nhánh không hợp lệ.';
  static const String errorNetworkInvalidFork = 'Đường rẽ không hợp lệ.';
  static const String errorNetworkInvalidConfluence = 'Nối lưu không hợp lệ.';
  static const String errorNetworkInvalidMouth = 'Cửa sông không hợp lệ.';
  static const String errorNetworkInvalidSource = 'Nguồn không hợp lệ.';
  static const String errorNetworkInvalidSpring2 = 'Suối nguồn không hợp lệ.';
  static const String errorNetworkInvalidWell = 'Giếng không hợp lệ.';
  static const String errorNetworkInvalidFountain =
      'Đài phun nước không hợp lệ.';
  static const String errorNetworkInvalidWaterfall = 'Thác nước không hợp lệ.';
  static const String errorNetworkInvalidRapids = 'Dòng xiết không hợp lệ.';
  static const String errorNetworkInvalidWhirlpool = 'Xoáy nước không hợp lệ.';
  static const String errorNetworkInvalidEddy = 'Xoáy nước không hợp lệ.';
  static const String errorNetworkInvalidCurrent = 'Dòng chảy không hợp lệ.';
  static const String errorNetworkInvalidTide = 'Thủy triều không hợp lệ.';
  static const String errorNetworkInvalidWave = 'Sóng không hợp lệ.';
  static const String errorNetworkInvalidRipple = 'Gợn sóng không hợp lệ.';
  static const String errorNetworkInvalidFoam = 'Bọt không hợp lệ.';
  static const String errorNetworkInvalidSpray = 'Sương phun không hợp lệ.';
  static const String errorNetworkInvalidSplash = 'Nước bắn không hợp lệ.';
  static const String errorNetworkInvalidDroplet = 'Giọt nước không hợp lệ.';
  static const String errorNetworkInvalidBubble = 'Bong bóng không hợp lệ.';
  static const String errorNetworkInvalidIceberg = 'Núi băng không hợp lệ.';
  static const String errorNetworkInvalidGlacier = 'Sông băng không hợp lệ.';
  static const String errorNetworkInvalidPermafrost =
      'Đất đóng băng vĩnh cửu không hợp lệ.';
  static const String errorNetworkInvalidTundra = 'Lãnh nguyên không hợp lệ.';
  static const String errorNetworkInvalidTaiga = 'Rừng taiga không hợp lệ.';
  static const String errorNetworkInvalidSteppe = 'Thảo nguyên không hợp lệ.';
  static const String errorNetworkInvalidPrairie = 'Đồng cỏ không hợp lệ.';
  static const String errorNetworkInvalidSavanna = 'Xavan không hợp lệ.';
  static const String errorNetworkInvalidPampas = 'Pampas không hợp lệ.';
  static const String errorNetworkInvalidVeldt = 'Veldt không hợp lệ.';
  static const String errorNetworkInvalidMoor = 'Đất lầy không hợp lệ.';
  static const String errorNetworkInvalidHeath = 'Đất heath không hợp lệ.';
  static const String errorNetworkInvalidFen = 'Đầm lầy không hợp lệ.';
  static const String errorNetworkInvalidBog = 'Đầm lầy than không hợp lệ.';
  static const String errorNetworkInvalidSwamp = 'Đầm lầy không hợp lệ.';
  static const String errorNetworkInvalidMarsh = 'Đầm lầy không hợp lệ.';
  static const String errorNetworkInvalidWetland =
      'Vùng đất ngập nước không hợp lệ.';
  static const String errorNetworkInvalidMangrove =
      'Rừng ngập mặn không hợp lệ.';
  static const String errorNetworkInvalidCoral = 'San hô không hợp lệ.';
  static const String errorNetworkInvalidKelp = 'Tảo bẹ không hợp lệ.';
  static const String errorNetworkInvalidSeagrass = 'Cỏ biển không hợp lệ.';
  static const String errorNetworkInvalidAlgae = 'Tảo không hợp lệ.';
  static const String errorNetworkInvalidPlankton = 'Phù du không hợp lệ.';
  static const String errorNetworkInvalidKrill = 'Tôm nhỏ không hợp lệ.';
  static const String errorNetworkInvalidJellyfish = 'Sứa không hợp lệ.';
  static const String errorNetworkInvalidSquid = 'Mực không hợp lệ.';
  static const String errorNetworkInvalidOctopus = 'Bạch tuộc không hợp lệ.';
  static const String errorNetworkInvalidCuttlefish = 'Mực nang không hợp lệ.';
  static const String errorNetworkInvalidNautilus = 'Ốc anh vũ không hợp lệ.';
  static const String errorNetworkInvalidClam = 'Nghêu không hợp lệ.';
  static const String errorNetworkInvalidOyster = 'Hàu không hợp lệ.';
  static const String errorNetworkInvalidMussel = 'Vẹm không hợp lệ.';
  static const String errorNetworkInvalidScallop = 'Sò điệp không hợp lệ.';
  static const String errorNetworkInvalidSnail = 'Ốc sên không hợp lệ.';
  static const String errorNetworkInvalidSlug = 'Sên không hợp lệ.';
  static const String errorNetworkInvalidWorm = 'Giun không hợp lệ.';
  static const String errorNetworkInvalidLeech = 'Đỉa không hợp lệ.';
  static const String errorNetworkInvalidCentipede = 'Rết không hợp lệ.';
  static const String errorNetworkInvalidMillipede =
      'Con rết trâu không hợp lệ.';
  static const String errorNetworkInvalidSpider = 'Nhện không hợp lệ.';
  static const String errorNetworkInvalidScorpion = 'Bọ cạp không hợp lệ.';
  static const String errorNetworkInvalidTick = 'Bét không hợp lệ.';
  static const String errorNetworkInvalidMite = 'Bét nhỏ không hợp lệ.';
  static const String errorNetworkInvalidFlea = 'Bọ chét không hợp lệ.';
  static const String errorNetworkInvalidLouse = 'Rận không hợp lệ.';
  static const String errorNetworkInvalidBedbug = 'Rệp giường không hợp lệ.';
  static const String errorNetworkInvalidCockroach = 'Gián không hợp lệ.';
  static const String errorNetworkInvalidTermite = 'Mối không hợp lệ.';
  static const String errorNetworkInvalidAnt = 'Kiến không hợp lệ.';
  static const String errorNetworkInvalidBee = 'Ong không hợp lệ.';
  static const String errorNetworkInvalidWasp = 'Ong bắp cày không hợp lệ.';
  static const String errorNetworkInvalidHornet = 'Ong vò vẽ không hợp lệ.';
  static const String errorNetworkInvalidYellowjacket =
      'Ong vàng không hợp lệ.';
  static const String errorNetworkInvalidButterfly = 'Bướm không hợp lệ.';
  static const String errorNetworkInvalidMoth = 'Bướm đêm không hợp lệ.';
  static const String errorNetworkInvalidDragonfly =
      'Chuồn chuồn không hợp lệ.';
  static const String errorNetworkInvalidDamselfly =
      'Chuồn chuồn ký sinh không hợp lệ.';
  static const String errorNetworkInvalidGrasshopper =
      'Châu chấu không hợp lệ.';
  static const String errorNetworkInvalidCricket = 'Dế không hợp lệ.';
  static const String errorNetworkInvalidKatydid = 'Dế mèn không hợp lệ.';
  static const String errorNetworkInvalidCicada = 'Ve không hợp lệ.';
  static const String errorNetworkInvalidLeafhopper = 'Rầy không hợp lệ.';
  static const String errorNetworkInvalidAphid = 'Rệp không hợp lệ.';
  static const String errorNetworkInvalidWhitefly = 'Rệp trắng không hợp lệ.';
  static const String errorNetworkInvalidMealybug = 'Rệp bông không hợp lệ.';
  static const String errorNetworkInvalidPsyllid = 'Rệp lá không hợp lệ.';
  static const String errorNetworkInvalidThrips = 'Bọ trĩ không hợp lệ.';
  static const String errorNetworkInvalidLacewing = 'Bọ ngựa không hợp lệ.';
  static const String errorNetworkInvalidLadybug = 'Bọ rùa không hợp lệ.';
  static const String errorNetworkInvalidFirefly = 'Đom đóm không hợp lệ.';
  static const String errorNetworkInvalidBeetle = 'Bọ cánh cứng không hợp lệ.';
  static const String errorNetworkInvalidWeevil = 'Mọt đậu không hợp lệ.';
  static const String errorNetworkInvalidStag = 'Nai cánh cứng không hợp lệ.';
  static const String errorNetworkInvalidRhinoceros = 'Giác lửa không hợp lệ.';
  static const String errorNetworkInvalidDung = 'Bọ phân không hợp lệ.';
  static const String errorNetworkInvalidCarrion = 'Bọ xác không hợp lệ.';
  static const String errorNetworkInvalidLonghorn = 'Bọ cánh dài không hợp lệ.';
  static const String errorNetworkInvalidJewel = 'Bọ ngọc không hợp lệ.';
  static const String errorNetworkInvalidTiger = 'Bọ hổ không hợp lệ.';
  static const String errorNetworkInvalidGround = 'Bọ đất không hợp lệ.';
  static const String errorNetworkInvalidDarkling = 'Bọ đen không hợp lệ.';
  static const String errorNetworkInvalidMealworm = 'Sâu mì không hợp lệ.';
  static const String errorNetworkInvalidSuperworm = 'Sâu mì lớn không hợp lệ.';
  static const String errorNetworkInvalidWaxworm = 'Sâu sáp không hợp lệ.';
  static const String errorNetworkInvalidHornworm = 'Sâu sừng không hợp lệ.';
  static const String errorNetworkInvalidSilkworm = 'Tằm tơ không hợp lệ.';
  static const String errorNetworkInvalidCaterpillar = 'Sâu bướm không hợp lệ.';
  static const String errorNetworkInvalidInchworm = 'Sâu đo không hợp lệ.';
  static const String errorNetworkInvalidLooper = 'Sâu cuộn không hợp lệ.';
  static const String errorNetworkInvalidArmyworm = 'Sâu hành không hợp lệ.';
  static const String errorNetworkInvalidCutworm = 'Sâu cắt không hợp lệ.';
  static const String errorNetworkInvalidBollworm = 'Sâu bông không hợp lệ.';
  static const String errorNetworkInvalidCorn = 'Sâu ngô không hợp lệ.';
  static const String errorNetworkInvalidEarworm = 'Sâu tai không hợp lệ.';
  static const String errorNetworkInvalidTobacco = 'Sâu thuốc lá không hợp lệ.';
  static const String errorNetworkInvalidTomato = 'Sâu cà chua không hợp lệ.';
  static const String errorNetworkInvalidHorn =
      'Sâu sừng cà chua không hợp lệ.';
  static const String errorNetworkInvalidTent = 'Sâu lều không hợp lệ.';
  static const String errorNetworkInvalidFall = 'Sâu thu không hợp lệ.';
  static const String errorNetworkInvalidSpring = 'Sâu xuân không hợp lệ.';
  static const String errorNetworkInvalidCanker = 'Sâu loét không hợp lệ.';
  static const String errorNetworkInvalidPin = 'Sâu kim không hợp lệ.';
  static const String errorNetworkInvalidShoot = 'Sâu mầm không hợp lệ.';
  static const String errorNetworkInvalidMiner = 'Sâu đào lá không hợp lệ.';
  static const String errorNetworkInvalidSkeletonizer =
      'Sâu xương lá không hợp lệ.';
  static const String errorNetworkInvalidSerpentine =
      'Sâu rắn lá không hợp lệ.';
  static const String errorNetworkInvalidTortrix = 'Sâu cuộn lá không hợp lệ.';
  static const String errorNetworkInvalidLeafroller =
      'Sâu cuộn lá không hợp lệ.';
  static const String errorNetworkInvalidLeaftier = 'Sâu ghép lá không hợp lệ.';
  static const String errorNetworkInvalidLeafperforator =
      'Sâu đục lá không hợp lệ.';
  static const String errorNetworkInvalidPepper = 'Sâu ớt không hợp lệ.';
  static const String errorNetworkInvalidSphinx = 'Sâu đêm không hợp lệ.';
  static const String errorNetworkInvalidHawk = 'Sâu diều hâu không hợp lệ.';
  static const String errorNetworkInvalidOwl = 'Sâu cú mèo không hợp lệ.';
  static const String errorNetworkInvalidClearwing =
      'Sâu cánh trong không hợp lệ.';
  static const String errorNetworkInvalidWasp2 = 'Sâu ong không hợp lệ.';
  static const String errorNetworkInvalidHornet2 =
      'Sâu ong vò vẽ không hợp lệ.';
  static const String errorNetworkInvalidSawfly = 'Sâu cưa không hợp lệ.';
  static const String errorNetworkInvalidWood = 'Sâu gỗ không hợp lệ.';
  static const String errorNetworkInvalidHorntail =
      'Sâu đuôi sừng không hợp lệ.';
  static const String errorNetworkInvalidSiricid = 'Sâu siricid không hợp lệ.';
  static const String errorNetworkInvalidCephid = 'Sâu cephid không hợp lệ.';
  static const String errorNetworkInvalidArgid = 'Sâu argid không hợp lệ.';
  static const String errorNetworkInvalidPamphiliid =
      'Sâu pamphiliid không hợp lệ.';
  static const String errorNetworkInvalidMegalodontid =
      'Sâu megalodontid không hợp lệ.';
  static const String errorNetworkInvalidOrussid = 'Sâu orussid không hợp lệ.';
  static const String errorNetworkInvalidApocritan =
      'Sâu apocritan không hợp lệ.';
  static const String errorNetworkInvalidAculeate =
      'Sâu aculeate không hợp lệ.';
  static const String errorNetworkInvalidParasitoid =
      'Sâu ký sinh không hợp lệ.';
  static const String errorNetworkInvalidCuckoo = 'Sâu cúc cu không hợp lệ.';
  static const String errorNetworkInvalidVelvet = 'Sâu nhung không hợp lệ.';
  static const String errorNetworkInvalidSpider2 = 'Sâu nhện không hợp lệ.';
  static const String errorNetworkInvalidAntlion =
      'Sâu kiến sư tử không hợp lệ.';
  static const String errorNetworkInvalidOwl2 = 'Sâu cú mèo không hợp lệ.';
  static const String errorNetworkInvalidLacewing2 =
      'Sâu bọ ngựa không hợp lệ.';
  static const String errorNetworkInvalidDobsonfly = 'Sâu dobson không hợp lệ.';
  static const String errorNetworkInvalidFishfly = 'Sâu cá không hợp lệ.';
  static const String errorNetworkInvalidAlderfly = 'Sâu alder không hợp lệ.';
  static const String errorNetworkInvalidSnakefly = 'Sâu rắn không hợp lệ.';
  static const String errorNetworkInvalidMantis = 'Sâu bọ ngựa không hợp lệ.';
  static const String errorNetworkInvalidStick = 'Sâu gậy không hợp lệ.';
  static const String errorNetworkInvalidLeaf2 = 'Sâu lá không hợp lệ.';
  static const String errorNetworkInvalidTimema = 'Sâu timema không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattid =
      'Sâu grylloblattid không hợp lệ.';
  static const String errorNetworkInvalidWebspinner =
      'Sâu quăn tơ không hợp lệ.';
  static const String errorNetworkInvalidEmbiopteran =
      'Sâu embiopteran không hợp lệ.';
  static const String errorNetworkInvalidZorapteran =
      'Sâu zorapteran không hợp lệ.';
  static const String errorNetworkInvalidDermapteran =
      'Sâu dermapteran không hợp lệ.';
  static const String errorNetworkInvalidEarwig = 'Sâu tai không hợp lệ.';
  static const String errorNetworkInvalidPlecopteran =
      'Sâu plecopteran không hợp lệ.';
  static const String errorNetworkInvalidStonefly = 'Sâu đá không hợp lệ.';
  static const String errorNetworkInvalidNotopteran =
      'Sâu notopteran không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatid =
      'Sâu mantophasmatid không hợp lệ.';
  static const String errorNetworkInvalidHeelwalker =
      'Sâu heelwalker không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodean =
      'Sâu grylloblattodean không hợp lệ.';
  static const String errorNetworkInvalidMantodean =
      'Sâu mantodean không hợp lệ.';
  static const String errorNetworkInvalidBlattodean =
      'Sâu blattodean không hợp lệ.';
  static const String errorNetworkInvalidIsopteran =
      'Sâu isopteran không hợp lệ.';
  static const String errorNetworkInvalidTermite2 = 'Sâu mối không hợp lệ.';
  static const String errorNetworkInvalidZoraptera =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera2 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera2 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera2 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera2 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera2 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea2 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea2 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea2 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea2 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera2 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera3 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera3 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera3 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera3 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera3 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea3 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea3 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea3 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea3 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera3 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera4 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera4 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera4 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera4 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera4 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea4 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea4 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea4 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea4 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera4 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera5 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera5 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera5 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera5 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera5 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea5 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea5 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea5 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea5 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera5 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera6 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera6 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera6 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera6 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera6 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea6 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea6 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea6 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea6 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera6 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera7 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera7 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera7 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera7 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera7 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea7 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea7 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea7 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea7 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera7 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera8 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera8 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera8 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera8 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera8 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea8 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea8 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea8 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea8 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera8 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera9 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera9 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera9 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera9 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera9 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea9 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea9 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea9 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea9 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera9 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera10 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera10 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera10 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera10 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera10 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea10 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea10 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea10 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea10 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera10 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera11 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera11 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera11 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera11 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera11 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea11 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea11 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea11 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea11 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera11 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera12 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera12 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera12 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera12 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera12 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea12 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea12 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea12 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea12 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera12 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera13 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera13 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera13 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera13 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera13 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea13 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea13 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea13 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea13 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera13 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera14 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera14 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera14 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera14 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera14 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea14 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea14 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea14 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea14 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera14 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera15 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera15 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera15 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera15 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera15 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea15 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea15 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea15 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea15 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera15 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera16 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera16 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera16 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera16 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera16 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea16 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea16 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea16 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea16 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera16 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera17 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera17 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera17 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera17 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera17 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea17 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea17 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea17 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea17 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera17 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera18 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera18 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera18 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera18 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera18 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea18 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea18 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea18 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea18 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera18 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera19 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera19 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera19 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera19 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera19 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea19 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea19 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea19 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea19 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera19 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera20 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera20 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera20 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera20 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera20 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea20 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea20 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea20 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea20 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera20 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera21 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera21 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera21 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera21 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera21 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea21 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea21 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea21 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea21 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera21 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera22 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera22 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera22 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera22 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera22 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea22 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea22 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea22 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea22 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera22 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera23 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera23 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera23 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera23 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera23 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea23 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea23 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea23 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea23 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera23 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera24 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera24 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera24 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera24 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera24 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea24 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea24 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea24 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea24 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera24 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera25 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera25 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera25 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera25 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera25 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea25 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea25 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea25 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea25 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera25 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera26 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera26 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera26 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera26 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera26 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea26 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea26 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea26 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea26 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera26 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera27 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera27 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera27 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera27 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera27 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea27 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea27 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea27 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea27 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera27 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera28 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera28 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera28 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera28 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera28 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea28 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea28 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea28 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea28 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera28 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera29 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera29 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera29 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera29 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera29 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea29 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea29 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea29 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea29 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera29 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera30 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera30 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera30 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera30 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera30 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea30 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea30 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea30 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea30 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera30 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera31 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera31 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera31 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera31 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera31 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea31 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea31 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea31 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea31 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera31 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera32 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera32 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera32 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera32 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera32 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea32 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea32 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea32 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea32 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera32 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera33 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera33 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera33 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera33 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera33 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea33 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea33 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea33 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea33 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera33 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera34 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera34 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera34 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera34 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera34 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea34 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea34 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea34 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea34 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera34 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera35 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera35 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera35 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera35 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera35 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea35 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea35 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea35 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea35 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera35 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera36 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera36 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera36 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera36 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera36 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea36 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea36 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea36 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea36 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera36 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera37 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera37 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera37 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera37 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera37 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea37 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea37 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea37 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea37 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera37 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera38 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera38 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera38 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera38 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera38 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea38 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea38 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea38 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea38 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera38 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera39 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera39 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera39 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera39 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera39 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea39 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea39 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea39 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea39 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera39 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera40 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera40 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera40 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera40 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera40 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea40 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea40 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea40 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea40 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera40 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera41 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera41 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera41 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera41 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera41 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea41 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea41 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea41 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea41 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera41 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera42 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera42 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera42 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera42 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera42 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea42 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea42 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea42 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea42 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera42 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera43 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera43 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera43 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera43 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera43 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea43 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea43 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea43 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea43 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera43 =
      'Sâu isoptera không hợp lệ.';
  static const String errorNetworkInvalidZoraptera44 =
      'Sâu zoraptera không hợp lệ.';
  static const String errorNetworkInvalidEmbioptera44 =
      'Sâu embioptera không hợp lệ.';
  static const String errorNetworkInvalidDermaptera44 =
      'Sâu dermaptera không hợp lệ.';
  static const String errorNetworkInvalidPlecoptera44 =
      'Sâu plecoptera không hợp lệ.';
  static const String errorNetworkInvalidNotoptera44 =
      'Sâu notoptera không hợp lệ.';
  static const String errorNetworkInvalidMantophasmatodea44 =
      'Sâu mantophasmatodea không hợp lệ.';
  static const String errorNetworkInvalidGrylloblattodea44 =
      'Sâu grylloblattodea không hợp lệ.';
  static const String errorNetworkInvalidMantodea44 =
      'Sâu mantodea không hợp lệ.';
  static const String errorNetworkInvalidBlattodea44 =
      'Sâu blattodea không hợp lệ.';
  static const String errorNetworkInvalidIsoptera44 =
      'Sâu isoptera không hợp lệ.';

  // Home Screen
  static const String homeScriptLabel = 'Kịch bản';
  static const String homeScriptHint = 'Dán nội dung video của bạn...';
  static const String homeQuickActions = 'Thao tác nhanh';
  static const String homePasteFromClipboard = 'Dán từ clipboard';
  static const String homeImportFile = 'Nhập file .txt';
  static const String homeSampleScript = 'Mẫu kịch bản';
  static const String homeVoiceLabel = 'Giọng đọc';
  static const String homeSpeedLabel = 'Tốc độ';
  static const String homeGenerate = 'Tạo giọng nói';
  static const String homeNoVoiceSelected = 'Chưa chọn giọng';
  static const String homeSelectVoice = 'Chọn giọng';
  static const String homeLoadingVoices = 'Đang tải giọng đọc...';
  static const String homeErrorLoadingVoices = 'Không thể tải giọng đọc';
  static const String homeRetry = 'Thử lại';
  static const String homeWordsLabel = 'từ';
  static const String homeCharactersLabel = 'ký tự';
  static const String homeMinutesLabel = 'phút';
  static const String homeSecondsLabel = 'giây';
  static const String homePasteSuccess = 'Đã dán từ clipboard';
  static const String homePasteFailed = 'Không thể dán từ clipboard';
  static const String homeFileImportSuccess = 'Đã nhập nội dung từ file';
  static const String homeFileImportFailed = 'Không thể nhập file';
  static const String homeClearConfirmTitle = 'Xóa nội dung?';
  static const String homeClearConfirmDesc =
      'Toàn bộ nội dung kịch bản sẽ bị xóa.';
  static const String homeCancel = 'Hủy';
  static const String homeConfirmClear = 'Xóa';
  static const String homeEmptyScriptError = 'Vui lòng nhập kịch bản';
  static const String homeVoiceRequiredError = 'Vui lòng chọn giọng đọc';
  static const String homeGenerating = 'Đang tạo giọng nói...';
  static const String homeGenerationSuccess = 'Tạo giọng nói thành công!';
  static const String homeGenerationFailed = 'Tạo giọng nói thất bại';
  static const String homeSampleScriptContent =
      'Chào mừng bạn đến với VietVoice Studio! '
      'Đây là công cụ tạo giọng nói tiếng Việt dành cho người sáng tạo nội dung TikTok. '
      'Hãy dán kịch bản của bạn vào ô bên trên, chọn giọng đọc yêu thích, '
      'điều chỉnh tốc độ phát và nhấn nút Tạo giọng nói để bắt đầu. '
      'Bạn có thể nhập file .txt hoặc sử dụng các mẫu kịch bản có sẵn để tiết kiệm thời gian. '
      'Chúc bạn tạo ra những video tuyệt vời!';

  // Bottom Navigation
  static const String navHome = 'Trang chủ';
  static const String navLibrary = 'Thư viện';
  static const String navVoices = 'Giọng';
  static const String navSettings = 'Cài đặt';

  // Library Screen
  static const String libraryTitleAudio = 'Thư viện audio';
  static const String libraryEmptyAudio = 'Chưa có audio nào';
  static const String libraryEmptyAudioHint =
      'Mỗi audio bạn tạo sẽ xuất hiện ở đây.';
  static const String libraryCreateFirst = 'Tạo audio đầu tiên';
  static const String libraryItemsCount = 'audio';
  static const String libraryRenameTitle = 'Đổi tên audio';
  static const String libraryRenameHint = 'Nhập tên mới cho audio';
  static const String libraryRenameSuccess = 'Đã đổi tên audio';
  static const String libraryDeleteSuccess = 'Đã xóa audio';
  static const String libraryFavoriteAdded = 'Đã thêm vào yêu thích';
  static const String libraryFavoriteRemoved = 'Đã bỏ yêu thích';
  static const String libraryShareTitle = 'Chia sẻ audio';
  static const String libraryExportSuccess = 'Đã xuất audio';
  static String libraryExportedTo(String location) => 'Đã xuất vào $location';
  static const String libraryFavoriteFailed = 'Không lưu được yêu thích';
  static const String libraryExportFailed = 'Không xuất được audio';
  static const String libraryEmptyFavorites = 'Chưa có audio yêu thích';
  static const String libraryEmptyFavoritesHint =
      'Bấm vào ⋮ trên một audio để thêm vào yêu thích.';
  static const String libraryNoSearchResult = 'Không tìm thấy audio';
  static const String homeNewAudio = 'Audio mới';
  static const String libraryNoSearchResultHint =
      'Thử một từ khoá khác hoặc xoá bộ lọc.';
  static const String libraryLoadingMore = 'Đang tải thêm...';
  static const String libraryLoadMore = 'Tải thêm';
  static const String libraryPlay = 'Phát audio';
  static const String libraryPause = 'Tạm dừng audio';
  static const String libraryVoiceUnknown = 'Không xác định';

  // Audio Detail Screen
  static const String audioDetailTitle = 'Chi tiết audio';
  static const String audioDetailFileInfo = 'Thông tin tệp';
  static const String audioDetailTitleLabel = 'Tiêu đề';
  static const String audioDetailDuration = 'Thời lượng';
  static const String audioDetailSize = 'Kích thước';
  static const String audioDetailFormat = 'Định dạng';
  static const String audioDetailVoice = 'Giọng đọc';
  static const String audioDetailCreated = 'Ngày tạo';
  static const String audioDetailBack15s = 'Lùi 15s';
  static const String audioDetailForward15s = 'Tới 15s';
  static const String audioDetailSpeed = 'Tốc độ phát';
  static const String audioDetailWaveform = 'Sóng âm thanh';
  static const String audioDetailRenameTitle = 'Đổi tên audio';
  static const String audioDetailRenameHint = 'Nhập tên mới cho audio';
  static const String audioDetailRenameSuccess = 'Đã đổi tên audio';
  static const String audioDetailDeleteConfirm = 'Xóa audio này?';
  static const String audioDetailDeleteDesc =
      'Hành động này không thể hoàn tác.';
  static const String audioDetailDeleteSuccess = 'Đã xóa audio';
  static const String audioDetailShareTitle = 'Chia sẻ audio';
  static const String audioDetailExportSuccess = 'Đã xuất audio';
  static const String audioDetailFavoriteAdded = 'Đã thêm vào yêu thích';
  static const String audioDetailFavoriteRemoved = 'Đã bỏ yêu thích';
  static const String audioDetailLoading = 'Đang tải audio...';
  static const String audioDetailErrorLoading = 'Không thể tải audio';
  static const String audioDetailRetry = 'Thử lại';

  // Settings Screen
  static const String settingsVoiceService = 'Dịch vụ giọng nói';
  static const String settingsProvider = 'Nhà cung cấp';
  static const String settingsBackendStatus = 'Trạng thái kết nối';
  static const String settingsConnected = 'Đã kết nối';
  static const String settingsNotConnected = 'Chưa kết nối';
  static const String settingsTestConnection = 'Kiểm tra kết nối';
  static const String settingsConnectService = 'Kết nối dịch vụ';
  static const String settingsDefaultFormat = 'Định dạng mặc định';
  static const String settingsTextProcessing = 'Xử lý văn bản';
  static const String settingsAutoNormalize = 'Tự động chuẩn hóa';
  static const String settingsAutoNormalizeDesc =
      'Tự động sửa lỗi chính tả và dấu câu';
  static const String settingsCostWarning = 'Cảnh báo chi phí';
  static const String settingsWarningThreshold = 'Ngưỡng cảnh báo';
  static const String settingsWarningThresholdDesc =
      'Cảnh báo khi chi phí vượt ngưỡng';
  static const String settingsDeleteAll = 'Xóa tất cả dữ liệu';
  static const String settingsDeleteAllConfirm = 'Xóa tất cả dữ liệu?';
  static const String settingsDeleteAllDesc =
      'Toàn bộ audio, cài đặt và dữ liệu sẽ bị xóa vĩnh viễn.';
  static const String settingsDeleteAllSuccess = 'Đã xóa tất cả dữ liệu';
  static const String settingsAppInfo = 'Thông tin ứng dụng';
  static const String settingsAppVersion = 'Phiên bản';
  static const String settingsTestingConnection = 'Đang kiểm tra kết nối...';
  static const String settingsConnectionSuccess = 'Kết nối thành công';
  static const String settingsConnectionFailed = 'Kết nối thất bại';
  static const String settingsLoadingVoices = 'Đang tải giọng đọc...';
  static const String settingsNoVoices = 'Chưa có giọng đọc nào';
  static const String settingsCancel = 'Hủy';
  static const String settingsConfirm = 'Xác nhận';
  static const String settingsClose = 'Đóng';
  static const String settingsSave = 'Lưu';
  static const String settingsEdit = 'Chỉnh sửa';
  static const String settingsVoiceServiceDesc =
      'Cấu hình nhà cung cấp giọng nói';
  static const String settingsDefaultVoiceDesc =
      'Giọng đọc mặc định khi tạo audio';
  static const String settingsDefaultSpeedDesc = 'Tốc độ phát mặc định';
  static const String settingsDefaultFormatDesc = 'Định dạng file mặc định';
  static const String settingsThemeDesc = 'Chọn giao diện ứng dụng';
  static const String settingsTextProcessingDesc =
      'Tùy chọn xử lý văn bản tự động';
  static const String settingsCostWarningDesc =
      'Cảnh báo khi chi phí vượt ngưỡng';
  static const String settingsStorageDesc = 'Quản lý dung lượng lưu trữ';
  static const String settingsAboutDesc = 'Thông tin về ứng dụng';
  static const String settingsApiKeyLabel = 'API Key';
  static const String settingsApiKeyHint = 'Nhập API Key của bạn';
  static const String settingsApiKeyDesc =
      'API Key để kết nối với dịch vụ giọng nói';
  static const String settingsApiKeySaved = 'Đã lưu API Key';
  static const String settingsApiKeyDeleted = 'Đã xóa API Key';
  static const String settingsApiKeyInvalid = 'API Key không hợp lệ';
  static const String settingsEnterApiKey = 'Nhập API Key';
  static const String settingsSaveApiKey = 'Lưu API Key';
  static const String settingsDeleteApiKey = 'Xóa API Key';
  static const String settingsDeleteApiKeyConfirm = 'Xóa API Key?';
  static const String settingsDeleteApiKeyDesc =
      'Bạn sẽ cần nhập lại API Key để sử dụng dịch vụ.';
  static const String settingsDeleteApiKeySuccess = 'Đã xóa API Key';
  static const String settingsDeleteAllConfirmTitle = 'Xóa tất cả dữ liệu?';
  static const String settingsDeleteAllConfirmDesc =
      'Toàn bộ audio, cài đặt và dữ liệu sẽ bị xóa vĩnh viễn.';
  static const String settingsDeleteAllConfirmButton = 'Xóa tất cả';
  static const String settingsDeleteAllCancel = 'Hủy';
  static const String settingsClearCacheConfirmTitle = 'Xóa bộ nhớ đệm?';
  static const String settingsClearCacheConfirmDesc =
      'Dung lượng sẽ được giải phóng';
  static const String settingsClearCacheConfirmButton = 'Xóa';
  static const String settingsClearCacheCancel = 'Hủy';

  // ---- TTS providers (multi-provider) ----
  static const String providerSectionTitle = 'Nhà cung cấp giọng đọc';
  static const String providerSectionDesc =
      'Chọn nơi tạo giọng nói. Google TTS dùng miễn phí, ElevenLabs cho chất lượng cao và hỗ trợ nhân bản giọng.';
  static const String providerGoogleName = 'Google TTS';
  static const String providerGoogleDesc =
      'Mặc định. Miễn phí, ổn định, không hỗ trợ nhân bản giọng.';
  static const String providerElevenLabsName = 'ElevenLabs';
  static const String providerElevenLabsDesc =
      'Chất lượng cao, hỗ trợ nhân bản giọng. Có thể phát sinh phí.';
  static const String providerLocalName = 'TTS trên máy';
  static const String providerLocalDesc =
      'Miễn phí, không cần API key, chạy trên máy. Cần cài Python + XTTS ở máy chủ.';
  static const String providerComingSoon = 'Sắp ra mắt';
  static const String providerNotConfigured = 'Chưa cấu hình';
  static const String providerGoogleBadge = 'Mặc định';
  static const String providerSupportsCloning = 'Có nhân bản giọng';
  static const String providerNoCloning = 'Không nhân bản giọng';
  static const String providerNotReady = 'Chưa sẵn sàng';
  static const String providerUsageUnavailable =
      'Nhà cung cấp này không công bố mức sử dụng';
  static const String providerUsageTitle = 'Mức sử dụng thực tế';
  static const String providerUsageCharacters = 'Ký tự đã dùng';
  static const String providerUsageReset = 'Đặt lại';
  static const String providerServiceActive = 'Đã chuyển sang';
  static const String providerSwitchedSnack = 'Đã chuyển sang {provider}';
  static const String providerLocalUnavailableMessage =
      'TTS trên máy chưa sẵn sàng. Hãy chọn Google TTS hoặc ElevenLabs.';
  static const String providerCloningUnavailableTitle =
      'Nhà cung cấp hiện tại không hỗ trợ nhân bản giọng';
  static const String providerCloningUnavailableDesc =
      'Google TTS không có tính năng nhân bản giọng nói. Hãy chuyển sang ElevenLabs trong Cài đặt nếu bạn cần tính năng này. Ứng dụng không tạo dữ liệu giả.';
  static const String providerSwitchAction = 'Chuyển sang ElevenLabs';
  static const String providerFallbackTitle = 'Chuyển sang {fallback}?';
  static String providerFallbackTitleFor(String fallback) =>
      'Chuyển sang $fallback?';
  static String providerFallbackDescFor(String current, String fallback) =>
      '$current không tạo được âm thanh. Bạn có muốn thử lại bằng $fallback không? $fallback có thể phát sinh phí theo gói của bạn.';
  static String providerFallbackStay(String current) => 'Giữ $current';
  static const String providerFallbackAccept = 'Chuyển & thử lại';
  static const String providerSwitchedToFallback =
      'Đã chuyển sang ElevenLabs. Đang thử lại...';
  static const String errorProviderUnsupported =
      'Nhà cung cấp hiện tại không hỗ trợ thao tác này.';
  static const String errorEmptyAudio =
      'Máy chủ trả về âm thanh rỗng. Vui lòng thử lại.';
  static const String errorInvalidRequest =
      'Yêu cầu không hợp lệ. Vui lòng thử lại.';
  static const String offlineGenerateDisabled =
      'Không có kết nối mạng. Vui lòng bật mạng để tạo giọng nói.';
  static const String offlineBadge = 'Mất kết nối';
  static const String cloningUnsupportedMessage =
      'Nhà cung cấp đang chọn không hỗ trợ nhân bản giọng nói.';

  // ---- Ghi âm tạo giọng (RecordVoiceSheet) ----
  static const String recordVoiceTitle = 'Ghi âm giọng mới';
  static const String recordVoiceIntro =
      'Đọc to đoạn văn bản dưới đây bằng giọng tự nhiên của bạn. Âm thanh sẽ được lưu trên máy và dùng lại cho các video sau.';
  static const String recordVoiceSample =
      'Xin chào, hôm nay mình muốn chia sẻ một vài kinh nghiệm rất nhỏ nhưng khá hữu ích. '
      'Khi làm nội dung ngắn, điều quan trọng nhất là nói rõ, nói chậm và luôn nhìn vào ống kính. '
      'Bạn không cần phải nói quá nhanh, cứ tự nhiên là tốt nhất. '
      'Hy vọng những lời này giúp ích cho bạn trong những video sắp tới.';
  static const String recordVoiceNameLabel = 'Tên giọng';
  static const String recordVoiceNameHint = 'Ví dụ: Giọng nữ của tôi';
  static const String recordVoiceStart = 'Bắt đầu ghi âm';
  static const String recordVoiceStop = 'Dừng ghi âm';
  static const String recordVoiceRerecord = 'Ghi lại';
  static const String recordVoiceSave = 'Lưu giọng này';
  static const String recordVoiceRetry = 'Thử lại';
  static const String recordVoiceKeptSample =
      'Bản ghi vẫn được giữ, bạn không cần ghi lại.';

  /// Shown next to the kept recording so a failed clone is recoverable without
  /// re-recording: delete it, or go and point the app at a reachable backend.
  static const String recordVoiceDeleteSample = 'Xóa bản ghi';
  static const String recordVoiceChooseServer = 'Chọn máy chủ';

  /// The backend is up but the selected provider has no credentials, which is a
  /// settings problem on the PC rather than anything to do with the recording.
  static String cloneProviderUnavailable(String providerId) =>
      'Máy chủ đã phản hồi, nhưng nhà cung cấp "$providerId" chưa sẵn sàng.\n'
      'Nếu là ElevenLabs, hãy đặt ELEVENLABS_API_KEY trong backend rồi khởi động lại. '
      'Hoặc chọn "TTS trên máy" trong Cài đặt.';
  static const String recordVoiceCancel = 'Huỷ';
  static const String recordVoiceTooShort = 'Hãy ghi âm ít nhất 5 giây.';
  static const String recordVoiceSilent =
      'Không nghe thấy giọng nói trong bản ghi. Hãy kiểm tra micrô rồi ghi lại, đọc to và rõ trong khoảng 5-30 giây.';
  static const String recordVoiceUnreadable =
      'Không đọc được bản ghi vừa tạo. Hãy ghi lại, nếu vẫn bị lỗi này hãy mở lại ứng dụng.';
  static String recordVoiceNotWav(String detected) => detected.isEmpty
      ? 'Máy đã ghi ra tệp không phải WAV. Hãy ghi lại.'
      : 'Máy đã ghi ra tệp "$detected" thay vì WAV. Hãy ghi lại.';

  static String recordVoiceBadFormat(String detected) => detected.isEmpty
      ? 'Bản ghi không phải WAV 16-bit nên không dùng được cho giọng mới. Hãy ghi lại.'
      : 'Bản ghi là "$detected" thay vì WAV 16-bit nên không dùng được cho giọng mới. Hãy ghi lại.';
  static const String recordVoiceEmpty =
      'Bản ghi không có dữ liệu âm thanh. Hãy kiểm tra micrô rồi ghi lại.';
  static const String recordVoiceTooLong = 'Đã đủ 30 giây, hãy dừng ghi.';
  static const String recordVoiceNameRequired =
      'Vui lòng đặt tên cho giọng mới.';
  static const String recordVoicePermission = 'Cần quyền thu âm để tạo giọng.';
  static const String recordVoicePermissionHint =
      'VietVoice cần quyền Micrô để ghi mẫu giọng. Bấm nút bên dưới để mở Cài đặt và chọn "Chỉ cho phép khi đang dùng ứng dụng".';
  static const String recordVoiceOpenSettings = 'Mở cài đặt quyền';
  static const String recordVoiceSaved = 'Đã lưu giọng mới';
  static const String recordVoiceFailed =
      'Không tạo được giọng mới. Vui lòng thử lại.';
  static const String recordVoiceCloning =
      'Đang tạo giọng từ âm thanh của bạn...';
  static const String recordVoiceFirstRunWarning =
      'Lần đầu tiên sẽ tải mô hình khoảng 1.8GB về máy, có thể mất vài phút.';
  static const String recordVoiceUnsupported =
      'Nhà cung cấp hiện tại không hỗ trợ ghi âm tạo giọng. Hãy chọn TTS trên máy hoặc ElevenLabs trong Cài đặt.';
  static const String recordVoiceRecordedFor = 'Đã ghi âm';
  static const String recordVoiceDurationHint = 'Ghi âm từ 5 đến 30 giây';
  static const String voiceSelectorRecordNew = 'Ghi âm giọng mới';
}
