import '../repository/score_repository.dart';

class AddPointsUseCase {
  final ScoreRepository _repository;
  AddPointsUseCase(this._repository);

  Future<void> call(int points, String gameId) => _repository.addPoints(points, gameId);
}
