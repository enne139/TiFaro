// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modelli_dao.dart';

// ignore_for_file: type=lint
mixin _$ModelliDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArgomentiTable get argomenti => attachedDatabase.argomenti;
  $TipologieTable get tipologie => attachedDatabase.tipologie;
  $ModelliTable get modelli => attachedDatabase.modelli;
  $VociModelloTable get vociModello => attachedDatabase.vociModello;
  $ElencoAttivitaTable get elencoAttivita => attachedDatabase.elencoAttivita;
  ModelliDaoManager get managers => ModelliDaoManager(this);
}

class ModelliDaoManager {
  final _$ModelliDaoMixin _db;
  ModelliDaoManager(this._db);
  $$ArgomentiTableTableManager get argomenti =>
      $$ArgomentiTableTableManager(_db.attachedDatabase, _db.argomenti);
  $$TipologieTableTableManager get tipologie =>
      $$TipologieTableTableManager(_db.attachedDatabase, _db.tipologie);
  $$ModelliTableTableManager get modelli =>
      $$ModelliTableTableManager(_db.attachedDatabase, _db.modelli);
  $$VociModelloTableTableManager get vociModello =>
      $$VociModelloTableTableManager(_db.attachedDatabase, _db.vociModello);
  $$ElencoAttivitaTableTableManager get elencoAttivita =>
      $$ElencoAttivitaTableTableManager(
        _db.attachedDatabase,
        _db.elencoAttivita,
      );
}
