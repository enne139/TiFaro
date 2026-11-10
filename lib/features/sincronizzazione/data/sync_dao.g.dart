// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncDaoMixin on DatabaseAccessor<AppDatabase> {
  $NoteSyncTable get noteSync => attachedDatabase.noteSync;
  $PreferenzeTable get preferenze => attachedDatabase.preferenze;
  SyncDaoManager get managers => SyncDaoManager(this);
}

class SyncDaoManager {
  final _$SyncDaoMixin _db;
  SyncDaoManager(this._db);
  $$NoteSyncTableTableManager get noteSync =>
      $$NoteSyncTableTableManager(_db.attachedDatabase, _db.noteSync);
  $$PreferenzeTableTableManager get preferenze =>
      $$PreferenzeTableTableManager(_db.attachedDatabase, _db.preferenze);
}
