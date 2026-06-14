import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecase/get_score_usecase.dart';
import '../../domain/usecase/add_points_usecase.dart';
import '../../data/repository_impl/score_repository_impl.dart';

class ScoreProvider extends ChangeNotifier {
  final GetScoreUseCase _getScoreUseCase = GetScoreUseCase(ScoreRepositoryImpl());
  final AddPointsUseCase _addPointsUseCase = AddPointsUseCase(ScoreRepositoryImpl());

  int _totalScore = 0;
  int get totalScore => _totalScore;

  StreamSubscription<int>? _scoreSubscription;
  StreamSubscription<User?>? _authSubscription;

  ScoreProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initScoreListener();
      } else {
        _scoreSubscription?.cancel();
        _totalScore = 0;
        notifyListeners();
      }
    });
  }

  void _initScoreListener() {
    _scoreSubscription?.cancel();
    _scoreSubscription = _getScoreUseCase.call().listen((score) {
      _totalScore = score;
      notifyListeners();
    });
  }

  Future<void> addScore(int points, String gameId) async {
    try {
      await _addPointsUseCase.call(points, gameId);
    } catch (e) {
      debugPrint("Error updating score: $e");
    }
  }

  @override
  void dispose() {
    _scoreSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
