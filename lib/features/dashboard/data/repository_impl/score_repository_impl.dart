import '../../domain/repository/score_repository.dart';
import '../services/remote/score_service.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final ScoreService _scoreService = ScoreService();

  @override
  Stream<int> getScore() => _scoreService.getScoreStream();

  @override
  Future<void> addPoints(int points, String gameId) => _scoreService.updateScore(points, gameId);
}
