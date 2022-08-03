import 'dart:io';

import 'diretorio.dart' as dir;
import 'arquivo.dart' as arq;
import 'constantes.dart';

void main(List<String> arguments) async {
  dir.Diretorio diretorioOrigem = dir.Diretorio(ORIGEM);
  for (String i in diretorioOrigem.listaDeArquivos) {
    arq.Arquivo arquivoOrigem = arq.Arquivo(i);
    if (FORMATOS.contains(arquivoOrigem.formato.toLowerCase())) {
      var dataDosArquivos = await arquivoOrigem.dataCriacao;
      dir.Diretorio.criar(dataDosArquivos);
      arquivoOrigem.copiar();
      arquivoOrigem.criaThumb();
    }
  }
  executaServidorWeb();
}

void executaServidorWeb() {
  String ipLocal =
      Process.runSync('hostname', ['-I']).stdout.toString().split(' ')[0];
  print('\nExecutando servidor: ');
  print('http://$ipLocal:$PORTA\n');
  Process.runSync(
      'python3', ['-m', 'http.server', PORTA, '--directory', DESTINO]);
}
