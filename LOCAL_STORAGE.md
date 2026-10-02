# Local Storage

VietVoice Studio uses **Drift** (SQLite) for local data persistence and **flutter_secure_storage** for sensitive data.

---

## Overview

### Storage Strategy

| Data Type | Storage | Reason |
|-----------|---------|--------|
| Projects, Scripts, Voices, Audio | Drift (SQLite) | Structured, queryable, relational |
| API Keys, Tokens | flutter_secure_storage | Encrypted, platform-secured |
| Theme, Preferences | Drift (SQLite) | Consistent with other settings |
| Audio Files | File system | Large binary data |

### Database Location

| Platform | Path |
|----------|------|
| **iOS** | `Documents/vietvoice_studio.db` |
| **Android** | `app_flutter/vietvoice_studio.db` |

---

## Database Schema

### Entity Relationship Diagram

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│  Projects    │     │   Scripts    │     │ ScriptSegments   │
├──────────────┤     ├──────────────┤     ├──────────────────┤
│ id (PK)      │←───┤│ id (PK)      │←───┤│ id (PK)          │
│ name         │     │ project_id   │     │ script_id        │
│ created_at   │     │ content      │     │ text             │
│ updated_at   │     │ created_at   │     │ order_index      │
└──────────────┘     │ updated_at   │     │ created_at       │
                     └──────────────┘     └──────────────────┘
                            │
                            │
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│    Voices    │     │VoiceReferences│    │  AudioAssets     │
├──────────────┤     ├──────────────┤     ├──────────────────┤
│ id (PK)      │←───┤│ id (PK)      │     │ id (PK)          │
│ provider     │     │ voice_id     │     │ project_id (FK)  │
│ provider_voice_id  │ file_path    │     │ script_id (FK)   │
│ name         │     │ file_type    │     │ segment_id (FK)  │
│ description  │     │ created_at   │     │ voice_id (FK)    │
│ language     │     └──────────────┘     │ title            │
│ gender       │                          │ file_path        │
│ accent       │                          │ format           │
│ is_cloned    │                          │ duration_ms      │
│ is_favorite  │                          │ file_size        │
│ created_at   │                          │ created_at       │
│ updated_at   │                          │ updated_at       │
└──────────────┘                          │ is_favorite      │
                                          └──────────────────┘
                                                   │
┌──────────────┐     ┌──────────────────────────────┐
│GenerationJobs│     │       AppSettings            │
├──────────────┤     ├──────────────────────────────┤
│ id (PK)      │     │ id (PK, always 1)            │
│ project_id   │     │ theme_mode                   │
│ status       │     │ default_voice_id             │
│ provider     │     │ default_speed                │
│ voice_id     │     │ default_format               │
│ character_count    │ auto_normalize               │
│ started_at   │     │ auto_split                   │
│ completed_at │     │ warning_threshold            │
│ error_code   │     └──────────────────────────────┘
└──────────────┘
```

---

## Tables and Relationships

### Projects

Stores user projects for organizing content.

```dart
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique project ID |
| `name` | TEXT | NOT NULL, 1-255 chars | Project name |
| `created_at` | DATETIME | DEFAULT NOW | Creation timestamp |
| `updated_at` | DATETIME | DEFAULT NOW | Last update timestamp |

### Scripts

Stores text scripts linked to projects.

```dart
class Scripts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique script ID |
| `project_id` | INTEGER | FK → Projects.id | Parent project |
| `content` | TEXT | NOT NULL | Script text content |
| `created_at` | DATETIME | DEFAULT NOW | Creation timestamp |
| `updated_at` | DATETIME | DEFAULT NOW | Last update timestamp |

### ScriptSegments

Stores individual segments of a script for granular generation.

```dart
class ScriptSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scriptId => integer().references(Scripts, #id)();
  TextColumn get text => text()();
  IntColumn get orderIndex => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique segment ID |
| `script_id` | INTEGER | FK → Scripts.id | Parent script |
| `text` | TEXT | NOT NULL | Segment text |
| `order_index` | INTEGER | NOT NULL | Order in script |
| `created_at` | DATETIME | DEFAULT NOW | Creation timestamp |

### Voices

Stores voice metadata from TTS providers.

```dart
class Voices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get provider => text().withLength(min: 1, max: 50)();
  TextColumn get providerVoiceId => text().withLength(min: 1, max: 255)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get language => text().withLength(min: 1, max: 10)();
  TextColumn get gender => text().withLength(min: 1, max: 20)();
  TextColumn get accent => text().nullable()();
  BoolColumn get isCloned => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Local voice ID |
| `provider` | TEXT | NOT NULL | Provider name (e.g., "elevenlabs") |
| `provider_voice_id` | TEXT | NOT NULL | Provider's voice ID |
| `name` | TEXT | NOT NULL | Display name |
| `description` | TEXT | NULLABLE | Voice description |
| `language` | TEXT | NOT NULL | Language code (e.g., "vi") |
| `gender` | TEXT | NOT NULL | Gender label |
| `accent` | TEXT | NULLABLE | Accent label |
| `is_cloned` | BOOLEAN | DEFAULT FALSE | Whether voice is cloned |
| `is_favorite` | BOOLEAN | DEFAULT FALSE | User favorite flag |
| `created_at` | DATETIME | DEFAULT NOW | Creation timestamp |
| `updated_at` | DATETIME | DEFAULT NOW | Last update timestamp |

### VoiceReferences

Stores file references for voice-related audio files.

```dart
class VoiceReferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get voiceId => integer().references(Voices, #id)();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique reference ID |
| `voice_id` | INTEGER | FK → Voices.id | Parent voice |
| `file_path` | TEXT | NOT NULL | Path to audio file |
| `file_type` | TEXT | NOT NULL | File type (e.g., "mp3", "wav") |
| `created_at` | DATETIME | DEFAULT NOW | Creation timestamp |

### AudioAssets

Stores metadata for generated audio files.

```dart
class AudioAssets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  IntColumn get scriptId => integer().nullable().references(Scripts, #id)();
  IntColumn get segmentId => integer().nullable().references(ScriptSegments, #id)();
  IntColumn get voiceId => integer().references(Voices, #id)();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get filePath => text().withLength(min: 1, max: 1024)();
  TextColumn get format => text().withLength(min: 1, max: 10)();
  IntColumn get durationMs => integer()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique audio ID |
| `project_id` | INTEGER | FK → Projects.id | Parent project |
| `script_id` | INTEGER | FK → Scripts.id, NULLABLE | Source script |
| `segment_id` | INTEGER | FK → ScriptSegments.id, NULLABLE | Source segment |
| `voice_id` | INTEGER | FK → Voices.id | Voice used |
| `title` | TEXT | NOT NULL | Display title |
| `file_path` | TEXT | NOT NULL | Path to audio file |
| `format` | TEXT | NOT NULL | Audio format (mp3, wav, etc.) |
| `duration_ms` | INTEGER | NOT NULL | Duration in milliseconds |
| `file_size` | INTEGER | NOT NULL | File size in bytes |
| `created_at` | DATETIME | DEFAULT NOW | Creation timestamp |
| `updated_at` | DATETIME | DEFAULT NOW | Last update timestamp |
| `is_favorite` | BOOLEAN | DEFAULT FALSE | User favorite flag |

### GenerationJobs

Tracks audio generation tasks and their status.

```dart
class GenerationJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  TextColumn get status => text().withLength(min: 1, max: 50)();
  TextColumn get provider => text().withLength(min: 1, max: 50)();
  IntColumn get voiceId => integer().references(Voices, #id)();
  IntColumn get characterCount => integer()();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get errorCode => text().nullable()();
}
```

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique job ID |
| `project_id` | INTEGER | FK → Projects.id | Parent project |
| `status` | TEXT | NOT NULL | Job status (pending, processing, completed, failed) |
| `provider` | TEXT | NOT NULL | TTS provider used |
| `voice_id` | INTEGER | FK → Voices.id | Voice used |
| `character_count` | INTEGER | NOT NULL | Characters processed |
| `started_at` | DATETIME | DEFAULT NOW | Job start time |
| `completed_at` | DATETIME | NULLABLE | Job completion time |
| `error_code` | TEXT | NULLABLE | Error code if failed |

### AppSettings

Stores application settings (single row, id=1).

```dart
class AppSettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  IntColumn get defaultVoiceId => integer().nullable()();
  RealColumn get defaultSpeed => real().withDefault(const Constant(1.0))();
  TextColumn get defaultFormat => text().withDefault(const Constant('mp3'))();
  BoolColumn get autoNormalize => boolean().withDefault(const Constant(true))();
  BoolColumn get autoSplit => boolean().withDefault(const Constant(true))();
  IntColumn get warningThreshold => integer().withDefault(const Constant(1000))();
}
```

| Column | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | INTEGER | 1 | Always 1 (singleton) |
| `theme_mode` | TEXT | 'system' | Theme mode (system, light, dark) |
| `default_voice_id` | INTEGER | NULL | Default voice selection |
| `default_speed` | REAL | 1.0 | Default speech rate |
| `default_format` | TEXT | 'mp3' | Default audio format |
| `auto_normalize` | BOOLEAN | TRUE | Auto-normalize audio |
| `auto_split` | BOOLEAN | TRUE | Auto-split long scripts |
| `warning_threshold` | INTEGER | 1000 | Character warning threshold |

---

## Relationships

### One-to-Many

| Parent | Child | Foreign Key |
|--------|-------|-------------|
| Projects | Scripts | `Scripts.project_id` |
| Projects | AudioAssets | `AudioAssets.project_id` |
| Projects | GenerationJobs | `GenerationJobs.project_id` |
| Scripts | ScriptSegments | `ScriptSegments.script_id` |
| Scripts | AudioAssets | `AudioAssets.script_id` |
| ScriptSegments | AudioAssets | `AudioAssets.segment_id` |
| Voices | VoiceReferences | `VoiceReferences.voice_id` |
| Voices | AudioAssets | `AudioAssets.voice_id` |
| Voices | GenerationJobs | `GenerationJobs.voice_id` |

### Cascade Deletes

```dart
// Deleting a project cascades to:
// → Scripts → ScriptSegments
// → AudioAssets
// → GenerationJobs

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
```

---

## Migration Strategy

### Current Version

```dart
@override
int get schemaVersion => 1;
```

### Migration Approach

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
    // Insert default settings
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
    // Future migrations go here
    // Example:
    // if (from < 2) {
    //   await m.addColumn(appSettingsTable, appSettingsTable.newColumn);
    // }
  },
);
```

### Adding a New Column (Future Migration)

```dart
// Step 1: Add column to table definition
class AppSettingsTable extends Table {
  // ... existing columns
  TextColumn get newColumn => text().nullable()();
}

// Step 2: Increment schema version
@override
int get schemaVersion => 2;

// Step 3: Add migration
onUpgrade: (m, from, to) async {
  if (from < 2) {
    await m.addColumn(appSettingsTable, appSettingsTable.newColumn);
  }
},
```

### Adding a New Table (Future Migration)

```dart
// Step 1: Add table to @DriftDatabase annotation
@DriftDatabase(
  tables: [
    // ... existing tables
    NewTable,
  ],
)

// Step 2: Increment schema version
@override
int get schemaVersion => 2;

// Step 3: Add migration
onUpgrade: (m, from, to) async {
  if (from < 2) {
    await m.createTable(newTable);
  }
},
```

---

## File Storage

### Audio Files

Audio files are stored in the app's documents directory:

```
Documents/
├── audio/
│   ├── generated/          # TTS output files
│   │   ├── {uuid}.mp3
│   │   ├── {uuid}.wav
│   │   └── {uuid}.ogg
│   └── recordings/         # User recordings for cloning
│       ├── {uuid}.m4a
│       └── {uuid}.wav
└── vietvoice_studio.db     # Drift database
```

### File Path Resolution

```dart
Future<String> getAudioPath(String fileName, AudioType type) async {
  final dir = await getApplicationDocumentsDirectory();
  final subDir = type == AudioType.generated ? 'generated' : 'recordings';
  final path = p.join(dir.path, 'audio', subDir, fileName);
  return path;
}
```

### File Naming

Files are named using UUIDs to avoid collisions:

```dart
final fileName = '${uuid.v4()}.$format';
// Example: "550e8400-e29b-41d4-a716-446655440000.mp3"
```

### Storage Limits

| Limit | Value |
|-------|-------|
| Max file size | 50 MB |
| Max total storage | 500 MB |
| Supported formats | mp3, wav, ogg, m4a |

### Cleanup

```dart
// Remove orphaned audio files (no DB reference)
Future<void> cleanupOrphanedAudio() async {
  final allAssets = await getAllAudioAssets();
  final validPaths = allAssets.map((a) => a.filePath).toSet();

  final audioDir = await getAudioDirectory();
  await for (final file in audioDir.list()) {
    if (file is File && !validPaths.contains(file.path)) {
      await file.delete();
    }
  }
}
```

---

## Secure Storage

### What Goes in Secure Storage

| Key | Value | Platform |
|-----|-------|----------|
| `api_token` | ElevenLabs API key | Keychain / EncryptedSharedPreferences |
| `refresh_token` | Backend refresh token | Keychain / EncryptedSharedPreferences |
| `user_id` | Backend user ID | Keychain / EncryptedSharedPreferences |
| `cloned_voice_data` | Cached voice clone metadata | Keychain / EncryptedSharedPreferences |

### Usage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainItemAccessibility.first_unlock_this_device,
  ),
);

// Write
await storage.write(key: 'api_token', value: apiKey);

// Read
final apiKey = await storage.read(key: 'api_token');

// Delete
await storage.delete(key: 'api_token');

// Clear all
await storage.deleteAll();
```

---

## Performance Considerations

### Indexes

Consider adding indexes for frequently queried columns:

```dart
// In your table definition, use .unique() or create indexes in migration
// Example: Index on AudioAssets.projectId for fast lookups
```

### Batch Operations

```dart
// Use batch for multiple inserts
await batch((b) {
  b.insertAll(audioAssets, assetList);
  b.insertAll(generationJobs, jobList);
});
```

### Lazy Loading

The database uses `LazyDatabase` for deferred initialization:

```dart
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vietvoice_studio.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

---

## Testing

### In-Memory Database

```dart
import 'package:drift/native.dart';

test('database operations', () async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());

  // Test CRUD operations
  final projectId = await db.insertProject(
    const ProjectsCompanion(name: Value('Test Project')),
  );

  final projects = await db.getAllProjects();
  expect(projects.length, 1);
  expect(projects.first.name, 'Test Project');

  await db.close();
});
```

### Test Helpers

```dart
class TestDatabaseHelper {
  static Future<AppDatabase> createTestDb() async {
    return AppDatabase.forTesting(NativeDatabase.memory());
  }

  static Future<void> seedTestData(AppDatabase db) async {
    await db.insertProject(
      const ProjectsCompanion(name: Value('Seed Project')),
    );
  }
}
```
