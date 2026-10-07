import 'package:flutter/material.dart';

enum StepType {
  concept,
  diagram,
  interactiveExample,
  quiz,
}

class QuizChoice {
  final String text;
  final String? feedback;

  const QuizChoice({
    required this.text,
    this.feedback,
  });
}

class QuizQuestion {
  final String question;
  final List<QuizChoice> choices;
  final int correctIndex;
  final String explanation;
  final String hint;

  const QuizQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
    required this.hint,
  });
}

class LessonStep {
  final StepType type;
  final String title;
  final String content;
  final String? diagramType;
  final Map<String, dynamic>? interactiveData;
  final QuizQuestion? quiz;

  const LessonStep({
    required this.type,
    required this.title,
    required this.content,
    this.diagramType,
    this.interactiveData,
    this.quiz,
  });
}

class Lesson {
  final String id;
  final String levelId;
  final String title;
  final String summary;
  final int estimatedMinutes;
  final int xpReward;
  final int coinReward;
  final List<LessonStep> steps;

  const Lesson({
    required this.id,
    required this.levelId,
    required this.title,
    required this.summary,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.coinReward,
    required this.steps,
  });
}

class LearningLevel {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<Lesson> lessons;

  const LearningLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.lessons,
  });

  int get totalXp => lessons.fold(0, (sum, l) => sum + l.xpReward);
}
