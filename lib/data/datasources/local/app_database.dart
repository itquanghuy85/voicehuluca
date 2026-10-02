import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/project.dart';
import '../../models/script.dart';
import '../../models/script_segment.dart';
import '../../models/voice.dart';
import '../../models/voice_reference.dart';
import '../../models/audio_asset.dart';
import '../../models/generation_job.dart';
import '../../models/app_settings.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Projects,
    Scripts,
    ScriptSegments,
    Voices,
    VoiceReferences,
    AudioAssets,
    GenerationJobs,
    AppSettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(DatabaseConnection connection) : super(connection);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(appSettingsTable).insert(
        const AppSettingsTableCompanion(
          id: Value(1),
          themeMode: Value('system'),
          defaultSpeed: Value(1.0),
          defaultFormat: Value('mp3'),
          autoNormalize: Value(true),
          autoSplit: Value(true),
          warningThreshold: Value(1000),
        ),
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(appSettingsTable, appSettingsTable.ttsProvider);
      }
      if (from < 3) {
        await m.addColumn(appSettingsTable, appSettingsTable.backendUrl);
      }
    },
  );

  // Project CRUD
  Future<List<Project>> getAllProjects() => select(projects).get();

  Stream<List<Project>> watchAllProjects() => select(projects).watch();

  Future<Project?> getProject(int id) =>
      (select(projects)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertProject(ProjectsCompanion entry) =>
      into(projects).insert(entry);

  Future<bool> updateProject(ProjectsCompanion entry) =>
      update(projects).replace(entry);

  Future<int> deleteProject(int id) =>
      (delete(projects)..where((t) => t.id.equals(id))).go();

  // Script CRUD
  Future<List<Script>> getAllScripts() => select(scripts).get();

  Stream<List<Script>> watchAllScripts() => select(scripts).watch();

  Future<List<Script>> getScriptsByProject(int projectId) =>
      (select(scripts)..where((t) => t.projectId.equals(projectId))).get();

  Stream<List<Script>> watchScriptsByProject(int projectId) =>
      (select(scripts)..where((t) => t.projectId.equals(projectId))).watch();

  Future<Script?> getScript(int id) =>
      (select(scripts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertScript(ScriptsCompanion entry) =>
      into(scripts).insert(entry);

  Future<bool> updateScript(ScriptsCompanion entry) =>
      update(scripts).replace(entry);

  Future<int> deleteScript(int id) =>
      (delete(scripts)..where((t) => t.id.equals(id))).go();

  // ScriptSegment CRUD
  Future<List<ScriptSegment>> getAllSegments() => select(scriptSegments).get();

  Stream<List<ScriptSegment>> watchAllSegments() =>
      select(scriptSegments).watch();

  Future<List<ScriptSegment>> getSegmentsByScript(int scriptId) =>
      (select(scriptSegments)..where((t) => t.scriptId.equals(scriptId))).get();

  Stream<List<ScriptSegment>> watchSegmentsByScript(int scriptId) => (select(
    scriptSegments,
  )..where((t) => t.scriptId.equals(scriptId))).watch();

  Future<ScriptSegment?> getSegment(int id) =>
      (select(scriptSegments)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertSegment(ScriptSegmentsCompanion entry) =>
      into(scriptSegments).insert(entry);

  Future<bool> updateSegment(ScriptSegmentsCompanion entry) =>
      update(scriptSegments).replace(entry);

  Future<int> deleteSegment(int id) =>
      (delete(scriptSegments)..where((t) => t.id.equals(id))).go();

  Future<int> deleteSegmentsByScript(int scriptId) =>
      (delete(scriptSegments)..where((t) => t.scriptId.equals(scriptId))).go();

  // Voice CRUD
  Future<List<Voice>> getAllVoices() => select(voices).get();

  Stream<List<Voice>> watchAllVoices() => select(voices).watch();

  Future<List<Voice>> getVoicesByProvider(String provider) =>
      (select(voices)..where((t) => t.provider.equals(provider))).get();

  Future<List<Voice>> getFavoriteVoices() =>
      (select(voices)..where((t) => t.isFavorite.equals(true))).get();

  Stream<List<Voice>> watchFavoriteVoices() =>
      (select(voices)..where((t) => t.isFavorite.equals(true))).watch();

  Future<Voice?> getVoice(int id) =>
      (select(voices)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Voice?> getVoiceByProviderId(
    String provider,
    String providerVoiceId,
  ) =>
      (select(voices)..where(
            (t) =>
                t.provider.equals(provider) &
                t.providerVoiceId.equals(providerVoiceId),
          ))
          .getSingleOrNull();

  Future<int> insertVoice(VoicesCompanion entry) => into(voices).insert(entry);

  Future<bool> updateVoice(VoicesCompanion entry) =>
      update(voices).replace(entry);

  Future<int> updateVoiceFavorite(int voiceId, bool isFavorite) {
    return (update(voices)..where((t) => t.id.equals(voiceId))).write(
      VoicesCompanion(isFavorite: Value(isFavorite)),
    );
  }

  Future<int> deleteVoice(int id) =>
      (delete(voices)..where((t) => t.id.equals(id))).go();

  // VoiceReference CRUD
  Future<List<VoiceReference>> getAllVoiceReferences() =>
      select(voiceReferences).get();

  Future<List<VoiceReference>> getReferencesByVoice(int voiceId) =>
      (select(voiceReferences)..where((t) => t.voiceId.equals(voiceId))).get();

  Future<VoiceReference?> getVoiceReference(int id) => (select(
    voiceReferences,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertVoiceReference(VoiceReferencesCompanion entry) =>
      into(voiceReferences).insert(entry);

  Future<bool> updateVoiceReference(VoiceReferencesCompanion entry) =>
      update(voiceReferences).replace(entry);

  Future<int> deleteVoiceReference(int id) =>
      (delete(voiceReferences)..where((t) => t.id.equals(id))).go();

  Future<int> deleteReferencesByVoice(int voiceId) =>
      (delete(voiceReferences)..where((t) => t.voiceId.equals(voiceId))).go();

  // AudioAsset CRUD
  Future<List<AudioAsset>> getAllAudioAssets() => select(audioAssets).get();

  Stream<List<AudioAsset>> watchAllAudioAssets() => select(audioAssets).watch();

  Future<List<AudioAsset>> getAudioByProject(int projectId) =>
      (select(audioAssets)..where((t) => t.projectId.equals(projectId))).get();

  Future<List<AudioAsset>> getAudioByScript(int scriptId) =>
      (select(audioAssets)..where((t) => t.scriptId.equals(scriptId))).get();

  Future<List<AudioAsset>> getAudioBySegment(int segmentId) =>
      (select(audioAssets)..where((t) => t.segmentId.equals(segmentId))).get();

  Future<List<AudioAsset>> getAudioByVoice(int voiceId) =>
      (select(audioAssets)..where((t) => t.voiceId.equals(voiceId))).get();

  Future<List<AudioAsset>> getFavoriteAudio() =>
      (select(audioAssets)..where((t) => t.isFavorite.equals(true))).get();

  Stream<List<AudioAsset>> watchFavoriteAudio() =>
      (select(audioAssets)..where((t) => t.isFavorite.equals(true))).watch();

  Future<AudioAsset?> getAudioAsset(int id) =>
      (select(audioAssets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertAudioAsset(AudioAssetsCompanion entry) =>
      into(audioAssets).insert(entry);

  Future<bool> updateAudioAsset(AudioAssetsCompanion entry) =>
      update(audioAssets).replace(entry);

  Future<int> deleteAudioAsset(int id) =>
      (delete(audioAssets)..where((t) => t.id.equals(id))).go();

  Future<int> deleteAudioByProject(int projectId) =>
      (delete(audioAssets)..where((t) => t.projectId.equals(projectId))).go();

  // GenerationJob CRUD
  Future<List<GenerationJob>> getAllGenerationJobs() =>
      select(generationJobs).get();

  Stream<List<GenerationJob>> watchAllGenerationJobs() =>
      select(generationJobs).watch();

  Future<List<GenerationJob>> getJobsByProject(int projectId) => (select(
    generationJobs,
  )..where((t) => t.projectId.equals(projectId))).get();

  Future<List<GenerationJob>> getJobsByStatus(String status) =>
      (select(generationJobs)..where((t) => t.status.equals(status))).get();

  Future<GenerationJob?> getGenerationJob(int id) =>
      (select(generationJobs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertGenerationJob(GenerationJobsCompanion entry) =>
      into(generationJobs).insert(entry);

  Future<bool> updateGenerationJob(GenerationJobsCompanion entry) =>
      update(generationJobs).replace(entry);

  Future<int> deleteGenerationJob(int id) =>
      (delete(generationJobs)..where((t) => t.id.equals(id))).go();

  Future<int> deleteJobsByProject(int projectId) => (delete(
    generationJobs,
  )..where((t) => t.projectId.equals(projectId))).go();

  // AppSettings CRUD
  Future<AppSettings> getSettings() async {
    final data = await (select(
      appSettingsTable,
    )..where((t) => t.id.equals(1))).getSingle();
    return AppSettings.fromData(data);
  }

  Stream<AppSettings> watchSettings() {
    return (select(appSettingsTable)..where((t) => t.id.equals(1)))
        .watchSingle()
        .map((data) => AppSettings.fromData(data));
  }

  Future<bool> updateSettings(AppSettingsTableCompanion entry) =>
      update(appSettingsTable).replace(entry);

  // Transaction helpers
  Future<void> deleteProjectCascade(int projectId) async {
    await transaction(() async {
      final scriptsInProject = await getScriptsByProject(projectId);
      for (final script in scriptsInProject) {
        await deleteSegmentsByScript(script.id);
      }
      await (delete(scripts)..where((t) => t.projectId.equals(projectId))).go();
      await deleteAudioByProject(projectId);
      await deleteJobsByProject(projectId);
      await deleteProject(projectId);
    });
  }

  Future<void> deleteVoiceCascade(int voiceId) async {
    await transaction(() async {
      await deleteReferencesByVoice(voiceId);
      await deleteVoice(voiceId);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vietvoice_studio.db'));
    return NativeDatabase.createInBackground(file);
  });
}

/// The one database connection for the whole app.
///
/// Two `AppDatabase`s on the same file fight over the write lock, which surfaces
/// as `SqliteException(5): database is locked` while a migration is running.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
