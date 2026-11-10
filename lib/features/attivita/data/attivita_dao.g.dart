// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attivita_dao.dart';

// ignore_for_file: type=lint
mixin _$AttivitaDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArgomentiTable get argomenti => attachedDatabase.argomenti;
  $TipologieTable get tipologie => attachedDatabase.tipologie;
  $ElencoAttivitaTable get elencoAttivita => attachedDatabase.elencoAttivita;
  $ElencoFotoTable get elencoFoto => attachedDatabase.elencoFoto;
  AttivitaDaoManager get managers => AttivitaDaoManager(this);
}

class AttivitaDaoManager {
  final _$AttivitaDaoMixin _db;
  AttivitaDaoManager(this._db);
  $$ArgomentiTableTableManager get argomenti =>
      $$ArgomentiTableTableManager(_db.attachedDatabase, _db.argomenti);
  $$TipologieTableTableManager get tipologie =>
      $$TipologieTableTableManager(_db.attachedDatabase, _db.tipologie);
  $$ElencoAttivitaTableTableManager get elencoAttivita =>
      $$ElencoAttivitaTableTableManager(
        _db.attachedDatabase,
        _db.elencoAttivita,
      );
  $$ElencoFotoTableTableManager get elencoFoto =>
      $$ElencoFotoTableTableManager(_db.attachedDatabase, _db.elencoFoto);
}
