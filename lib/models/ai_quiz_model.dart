class AiQuizModel {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  AiQuizModel({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory AiQuizModel.fromJson(Map<String, dynamic> json) {
    return AiQuizModel(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
    };
  }
}
