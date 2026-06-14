import '../repository/score_repository.dart';

class GetScoreUseCase {
  final ScoreRepository _repository;
  GetScoreUseCase(this._repository);

  Stream<int> call() => _repository.getScore();
}
