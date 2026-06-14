abstract class ScoreRepository {
  Stream<int> getScore();
  Future<void> addPoints(int points, String gameId);
}
