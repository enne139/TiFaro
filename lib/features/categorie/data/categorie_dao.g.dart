// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorie_dao.dart';

// ignore_for_file: type=lint
mixin _$CategorieDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArgomentiTable get argomenti => attachedDatabase.argomenti;
  $TipologieTable get tipologie => attachedDatabase.tipologie;
  $ModelliTable get modelli => attachedDatabase.modelli;
  $ElencoAttivitaTable get elencoAttivita => attachedDatabase.elencoAttivita;
  $VociModelloTable get vociModello => attachedDatabase.vociModello;
  CategorieDaoManager get managers => CategorieDaoManager(this);
}

class CategorieDaoManager {
  final _$CategorieDaoMixin _db;
  CategorieDaoManager(this._db);
  $$ArgomentiTableTableManager get argomenti =>
      $$ArgomentiTableTableManager(_db.attachedDatabase, _db.argomenti);
  $$TipologieTableTableManager get tipologie =>
      $$TipologieTableTableManager(_db.attachedDatabase, _db.tipologie);
  $$ModelliTableTableManager get modelli =>
      $$ModelliTableTableManager(_db.attachedDatabase, _db.modelli);
  $$ElencoAttivitaTableTableManager get elencoAttivita =>
      $$ElencoAttivitaTableTableManager(
        _db.attachedDatabase,
        _db.elencoAttivita,
      );
  $$VociModelloTableTableManager get vociModello =>
      $$VociModelloTableTableManager(_db.attachedDatabase, _db.vociModello);
}
