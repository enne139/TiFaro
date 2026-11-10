// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendario_dao.dart';

// ignore_for_file: type=lint
mixin _$CalendarioDaoMixin on DatabaseAccessor<AppDatabase> {
  $EventiCalendarioTable get eventiCalendario =>
      attachedDatabase.eventiCalendario;
  CalendarioDaoManager get managers => CalendarioDaoManager(this);
}

class CalendarioDaoManager {
  final _$CalendarioDaoMixin _db;
  CalendarioDaoManager(this._db);
  $$EventiCalendarioTableTableManager get eventiCalendario =>
      $$EventiCalendarioTableTableManager(
        _db.attachedDatabase,
        _db.eventiCalendario,
      );
}
