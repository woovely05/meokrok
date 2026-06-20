import 'dart:io';
import 'package:path_provider/path_provider.dart';

const _kModelUrl =
    'https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/main/gemma-4-E2B-it-Q4_K_M.gguf';
const _kModelFilename = 'gemma-4-E2B-it-Q4_K_M.gguf';

Future<String> getModelFilePath() async {
  final dir = await getApplicationSupportDirectory();
  return '${dir.path}/models/$_kModelFilename';
}

Future<bool> isModelReady() async {
  final path = await getModelFilePath();
  final file = File(path);
  return file.existsSync() && file.lengthSync() > 100 * 1024 * 1024;
}

/// (받은 바이트, 전체 바이트) 스트림. total이 -1이면 크기 불명.
Stream<(int received, int total)> downloadModel() async* {
  final path = await getModelFilePath();
  final tmpPath = '$path.tmp';

  await Directory(File(path).parent.path).create(recursive: true);

  final client = HttpClient()..autoUncompress = false;
  try {
    final request = await client.getUrl(Uri.parse(_kModelUrl));
    request.headers.set('User-Agent', 'meokrok/1.0');
    final response = await request.close();

    int received = 0;
    final total = response.contentLength;
    final sink = File(tmpPath).openWrite();

    try {
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        yield (received, total);
      }
    } finally {
      await sink.close();
    }

    final finalFile = File(path);
    if (finalFile.existsSync()) await finalFile.delete();
    await File(tmpPath).rename(path);
  } finally {
    client.close();
  }
}
