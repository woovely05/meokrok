import '../constants/app_constants.dart';

/// 칼로리 섭취 피드백 메시지를 반환합니다.
/// [brief]: true면 홈 화면용 2줄 요약, false면 분석 화면용 상세 문장.
String generateCalorieFeedback({
  required double calories,
  required double calGoal,
  bool brief = false,
}) {
  if (calories == 0) {
    return brief
        ? '식사를 기록하면\n분석 결과를 알려드려요! 🥗'
        : '오늘 아직 기록된 식사가 없어요. 식사를 기록해 영양 분석을 받아보세요! 🥗';
  }
  final ratio = calGoal > 0 ? calories / calGoal : 0.0;
  if (ratio > AppConstants.calorieHighRatio) {
    return brief
        ? '오늘은 평소보다\n든든하게 드셨네요! 💪'
        : '오늘 권장 칼로리를 ${((ratio - 1) * 100).toStringAsFixed(0)}% 초과했어요. '
            '내일은 가벼운 식단으로 균형을 맞춰보는 건 어떨까요? 💪';
  }
  if (ratio < AppConstants.calorieLowRatio) {
    return brief
        ? '조금 더 챙겨 드셔도\n좋을 것 같아요! 🍽️'
        : '오늘 섭취량이 권장량의 ${(ratio * 100).toStringAsFixed(0)}%에 불과해요. '
            '충분한 영양 섭취가 건강 유지에 중요해요! 🍽️';
  }
  return brief
      ? '아주 적절한 식습관을\n유지하고 계시네요! ✨'
      : '오늘 권장 칼로리에 맞춰 적절하게 식사하셨네요! 꾸준한 식습관 관리가 건강의 첫걸음이에요. 훌륭해요! ✨';
}
