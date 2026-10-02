import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/app_database.dart' hide AudioAsset;
import '../../data/datasources/local/audio_local_datasource.dart';
import '../../data/models/audio_asset.dart';
import '../../data/repositories/audio_repository_impl.dart';

extension AudioRepositoryImplExt on AudioRepositoryImpl {
  Future<void> cleanupOrphanedAudio() async {}
}

enum LibraryFilter { all, recent, favorites }

/// Maps a voice id to its display name so the library can show which voice was
/// used for each audio instead of a placeholder.
final libraryVoiceNamesProvider = FutureProvider<Map<int, String>>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  final voices = await database.getAllVoices();
  return {for (final voice in voices) voice.id: voice.name};
});

class LibraryState {
  final List<AudioAsset> audios;
  final LibraryFilter filter;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const LibraryState({
    this.audios = const [],
    this.filter = LibraryFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  LibraryState copyWith({
    List<AudioAsset>? audios,
    LibraryFilter? filter,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return LibraryState(
      audios: audios ?? this.audios,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final AudioRepositoryImpl _repository;

  LibraryNotifier(this._repository) : super(const LibraryState());

  static const int _pageSize = 20;
  static const Duration _recentWindow = Duration(days: 7);

  /// Loads the list for the active filter, newest first, so the audio the user
  /// just made is always at the top.
  Future<List<AudioAsset>> _fetchAudios() async {
    final audios = state.searchQuery.isNotEmpty
        ? await _repository.searchAudio(state.searchQuery)
        : switch (state.filter) {
            LibraryFilter.all => await _repository.getAllAudio(),
            LibraryFilter.favorites => await _repository.getFavoriteAudio(),
            LibraryFilter.recent =>
              (await _repository.getAllAudio())
                  .where(
                    (a) => a.createdAt.isAfter(
                      DateTime.now().subtract(_recentWindow),
                    ),
                  )
                  .toList(),
          };

    final sorted = List<AudioAsset>.of(audios)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<void> loadLibrary({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 0,
        audios: [],
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final audios = await _fetchAudios();

      final paginated = audios.take(_pageSize).toList();
      state = state.copyWith(
        audios: paginated,
        isLoading: false,
        hasMore: audios.length > _pageSize,
        currentPage: 1,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final audios = await _fetchAudios();

      final startIndex = state.currentPage * _pageSize;
      final endIndex = startIndex + _pageSize;
      final newAudios = audios.skip(startIndex).take(_pageSize).toList();

      state = state.copyWith(
        audios: [...state.audios, ...newAudios],
        isLoadingMore: false,
        hasMore: endIndex < audios.length,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> deleteAudio(int id) async {
    try {
      await _repository.deleteAudio(id);
      state = state.copyWith(
        audios: state.audios.where((a) => a.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> renameAudio(int id, String newTitle) async {
    try {
      final audio = state.audios.firstWhere((a) => a.id == id);
      final updated = audio.copyWith(title: newTitle);
      await _repository.updateAudio(updated);
      state = state.copyWith(
        audios: state.audios.map((a) => a.id == id ? updated : a).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> toggleFavorite(int id) async {
    try {
      final audio = state.audios.firstWhere((a) => a.id == id);
      final newFavorite = !audio.isFavorite;
      final ok = await _repository.toggleFavorite(id, newFavorite);
      if (!ok) {
        state = state.copyWith(error: 'toggleFavorite failed for audio $id');
        return false;
      }
      state = state.copyWith(
        error: null,
        audios: state.audios
            .map((a) => a.id == id ? a.copyWith(isFavorite: newFavorite) : a)
            .toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refreshLibrary() async {
    await loadLibrary(refresh: true);
  }

  void setFilter(LibraryFilter filter) {
    state = state.copyWith(
      filter: filter,
      currentPage: 0,
      audios: [],
      hasMore: true,
    );
    loadLibrary(refresh: true);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 0,
      audios: [],
      hasMore: true,
    );
    loadLibrary(refresh: true);
  }
}

final audioLocalDataSourceProvider = Provider<AudioLocalDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return AudioLocalDataSource(database);
});

final audioRepositoryProvider = Provider<AudioRepositoryImpl>((ref) {
  final dataSource = ref.watch(audioLocalDataSourceProvider);
  return AudioRepositoryImpl(dataSource);
});

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((
  ref,
) {
  final repository = ref.watch(audioRepositoryProvider);
  return LibraryNotifier(repository);
});
