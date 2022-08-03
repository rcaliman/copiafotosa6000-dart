import 'dart:io';
import 'constantes.dart';
import 'dart:io' as io;

class Diretorio {
  final String _pathAbsoluta;

  Diretorio(this._pathAbsoluta);

  List<dynamic> get listaDeArquivos {
    List<FileSystemEntity> arquivos = io.Directory(pathAbsoluta)
        .listSync(recursive: true)
      ..toList()
      ..sort((l, r) => l.statSync().modified.compareTo(r.statSync().modified));
    List listaDeArquivos = [];
    for (FileSystemEntity item in arquivos) {
      if (item.statSync().type.toString() == 'file') {
        listaDeArquivos.add(item.path);
      }
    }
    return listaDeArquivos;
  }

  get pathAbsoluta {
    return _pathAbsoluta;
  }

  static void criar(String dataDoArquivo) async {
    String base = '$DESTINO/$dataDoArquivo';
    if (!io.Directory(base).existsSync()) {
      print("Criando diretórios do dia $dataDoArquivo");
      io.Directory(base).createSync();
      io.Directory('$base/thumbnail').createSync();
      for (String i in FORMATOS) {
        io.Directory('$base/$i').createSync();
      }
    }
  }
}
