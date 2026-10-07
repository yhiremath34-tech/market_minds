import 'package:flutter/material.dart';

class GameInfo {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final int xpReward;
  final String badge;

  const GameInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpReward,
    required this.badge,
  });
}

class CandlestickPuzzle {
  final String patternName;
  final String description;
  final String bullishBearish;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String visualKey;

  const CandlestickPuzzle({
    required this.patternName,
    required this.description,
    required this.bullishBearish,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.visualKey,
  });
}

class SimulatorMission {
  final String id;
  final String title;
  final String goal;
  final String description;
  final int xpReward;
  final int coinReward;
  final bool isCompleted;

  const SimulatorMission({
    required this.id,
    required this.title,
    required this.goal,
    required this.description,
    required this.xpReward,
    required this.coinReward,
    this.isCompleted = false,
  });

  SimulatorMission copyWith({bool? isCompleted}) {
    return SimulatorMission(
      id: id,
      title: title,
      goal: goal,
      description: description,
      xpReward: xpReward,
      coinReward: coinReward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
