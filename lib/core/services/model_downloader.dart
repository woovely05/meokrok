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
/// 이미 .tmp 파일이 있으면 Range 헤더로 이어받기를 시도합니다.
Stream<(int received, int total)> downloadModel() async* {
  final path = await getModelFilePath();
  final tmpPath = '$path.tmp';

  await Directory(File(path).parent.path).create(recursive: true);

  final tmpFile = File(tmpPath);
  int existingBytes = 0;
  if (await tmpFile.exists()) {
    existingBytes = await tmpFile.length();
  }

  final client = HttpClient()..autoUncompress = false;
  try {
    final request = await client.getUrl(Uri.parse(_kModelUrl));
    request.headers.set('User-Agent', 'meokrok/1.0');
    if (existingBytes > 0) {
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=$existingBytes-');
    }

    final response = await request.close();

    // 서버가 Range를 지원하지 않으면 (200 OK) 처음부터 다시 받기
    if (existingBytes > 0 && response.statusCode == HttpStatus.ok) {
      existingBytes = 0;
      if (await tmpFile.exists()) await tmpFile.delete();
    }

    int received = existingBytes;
    final contentLength = response.contentLength;
    final total = contentLength > 0 ? contentLength + existingBytes : -1;

    final sink = tmpFile.openWrite(
      mode: existingBytes > 0 ? FileMode.append : FileMode.write,
    );
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
    if (await finalFile.exists()) await finalFile.delete();
    await File(tmpPath).rename(path);
  } finally {
    client.close();
  }
}
