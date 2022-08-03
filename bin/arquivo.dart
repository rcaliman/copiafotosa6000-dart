import 'package:exif/exif.dart' as ex;
import 'dart:io' as io;
import 'constantes.dart';
import "package:image/image.dart" as img;
import "package:path/path.dart" as path;
import "package:string_validator/string_validator.dart" as str;

class Arquivo {
  final String _pathAbsoluta;

  Arquivo(this._pathAbsoluta);

  String get pathAbsoluta {
    return _pathAbsoluta;
  }

  String get pathRelativa {
    return path.dirname(_pathAbsoluta);
  }

  String get nome {
    return _pathAbsoluta.split('/').last;
  }

  Future<String> get dataCriacao async {
    Map<String, ex.IfdTag> exif =
        await ex.readExifFromBytes(io.File(_pathAbsoluta).readAsBytesSync());
    if (exif['EXIF DateTimeOriginal'] != null) {
      return exif['EXIF DateTimeOriginal']
          .toString()
          .substring(0, 10)
          .replaceAll(':', '-');
    } else {
      return io.File(_pathAbsoluta)
          .statSync()
          .modified
          .toString()
          .substring(0, 10)
          .replaceAll(':', '-');
    }
  }

  String get formato {
    return _pathAbsoluta.split('.').last;
  }

  void copiar() async {
    String arquivoDestino =
        '$DESTINO/${await dataCriacao}/${formato.toLowerCase()}/$nome';
    String arquivoHtml =
        '$DESTINO/${await dataCriacao}/${formato.toLowerCase()}/index.html';

    if (!io.File(arquivoDestino).existsSync()) {
      print('Copiando o arquivo $nome do dia ${await dataCriacao}...');
      io.File(pathAbsoluta).copySync(arquivoDestino);
      io.File(arquivoHtml)
          .writeAsStringSync(conteudoHtml(), mode: io.FileMode.append);
    }
  }

  String conteudoHtml() {
    String link;
    if (formato.toLowerCase() == VIDEO) {
      link = nome;
    } else {
      link =
          """<img alt = "$nome" src="../thumbnail/${path.basenameWithoutExtension(nome)}.${str.isLowercase(formato) ? JPG : JPG.toUpperCase()}">""";
    }

    return """
              <center>
              <div style="background-color: #f8f8f8; width: ${IMAGEM}px; padding: 40;">
                <center>
                <a href="$nome">
                  $link
                </a>
                </center>
              </div>
              <p>
              </center>""";
  }

  void criaThumb() async {
    String arquivoDestino = '$DESTINO/${await dataCriacao}/thumbnail/$nome';
    if (formato.toLowerCase() == JPG) {
      if (!io.File(arquivoDestino).existsSync()) {
        print("Criando miniatura da imagem $nome de ${await dataCriacao}.");
        var bytes = io.File(pathAbsoluta).readAsBytesSync();
        img.Image? imagem = img.decodeImage(bytes);
        img.Image thumbnail = img.copyResize(imagem!, width: IMAGEM);
        io.File(arquivoDestino).writeAsBytesSync(img.encodeJpg(thumbnail));
      }
    }
  }
}
