/// Scattare o scegliere le foto da allegare.
library;

import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

/// Lato massimo delle foto, in pixel: abbastanza per leggere un foglio
/// fotografato, molto meno dei 4000 e passa di una fotocamera moderna.
const double _latoMassimo = 2000;

/// Qualità JPEG: a occhio non si distingue dall'originale e pesa un terzo.
const int _qualita = 85;

/// Se questo dispositivo ha una fotocamera usabile (su Linux no).
bool get fotocameraDisponibile =>
    _picker.supportsImageSource(ImageSource.camera);

/// Scatta una foto e ne restituisce il percorso temporaneo; vuoto se si
/// annulla.
Future<List<String>> scattaFoto() async {
  final XFile? foto = await _picker.pickImage(
    source: ImageSource.camera,
    maxWidth: _latoMassimo,
    maxHeight: _latoMassimo,
    imageQuality: _qualita,
  );
  return foto == null ? const <String>[] : <String>[foto.path];
}

/// Sceglie una o più foto dalla galleria e ne restituisce i percorsi
/// temporanei.
Future<List<String>> scegliDallaGalleria() async {
  final List<XFile> foto = await _picker.pickMultiImage(
    maxWidth: _latoMassimo,
    maxHeight: _latoMassimo,
    imageQuality: _qualita,
  );
  return foto.map((XFile f) => f.path).toList();
}
