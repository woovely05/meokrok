import 'package:flutter/foundation.dart';
import 'package:llamadart/llamadart.dart';
import 'model_downloader.dart';

enum AiEstimateFailure { modelNotReady, inferenceError, parseFailed }

typedef AiResult = ({double? calories, AiEstimateFailure? failure});

LlamaEngine? _engine;

Future<LlamaEngine?> _getEngine() async {
  if (_engine != null) return _engine;

  if (!await isModelReady()) {
    debugPrint('[LocalLLM] 모델 준비 안 됨 — 앱 시작 시 자동 다운로드됩니다.');
    return null;
  }

  final modelPath = await getModelFilePath();
  try {
    debugPrint('[LocalLLM] 모델 로딩 중: $modelPath');
    final engine = LlamaEngine(LlamaBackend());
    await engine.loadModel(modelPath);
    _engine = engine;
    debugPrint('[LocalLLM] 모델 로딩 완료');
    return _engine;
  } catch (e) {
    debugPrint('[LocalLLM] 모델 로딩 실패: $e');
    return null;
  }
}

/// [foodName] [amount][unit]의 칼로리를 로컬 LLM으로 추정합니다.
/// 실패 이유는 [AiResult.failure]에 담겨 반환됩니다.
Future<AiResult> estimateCaloriesWithAI(
  String foodName,
  double amount,
  String unit,
) async {
  final engine = await _getEngine();
  if (engine == null) {
    return (calories: null, failure: AiEstimateFailure.modelNotReady);
  }

  final prompt = (unit == '개' || unit == '인분')
      ? '"$foodName" 1$unit당 칼로리는?'
      : '"$foodName" 100$unit당 칼로리는?';

  final session = ChatSession(
    engine,
    systemPrompt:
        '당신은 한국 식품 영양 전문가입니다. 한국 식품안전처 데이터 기반으로 칼로리를 추정합니다. '
        '반드시 정수 하나만 출력합니다. 단위, 설명 없이 숫자만 답하세요.',
  );

  try {
    final buffer = StringBuffer();
    await for (final chunk in session.create([LlamaTextContent(prompt)])) {
      buffer.write(chunk.choices.first.delta.content ?? '');
    }
    final text = buffer.toString().trim();
    debugPrint('[LocalLLM] 응답: "$text"');
    final match = RegExp(r'\d+').firstMatch(text);
    if (match == null) {
      return (calories: null, failure: AiEstimateFailure.parseFailed);
    }
    final val = double.tryParse(match.group(0)!);
    if (val == null) {
      return (calories: null, failure: AiEstimateFailure.parseFailed);
    }
    return (calories: val, failure: null);
  } catch (e) {
    debugPrint('[LocalLLM] 추론 오류: $e');
    return (calories: null, failure: AiEstimateFailure.inferenceError);
  }
}
