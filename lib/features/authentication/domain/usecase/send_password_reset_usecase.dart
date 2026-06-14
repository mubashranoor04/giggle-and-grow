
import '../../data/repositoryImp/auth_repository_imp.dart';
import '../repository/auth_repository.dart';

class SendPasswordResetUseCase {
  SendPasswordResetUseCase();

  final AuthRepository _repository = AuthRepositoryImpl();

  Future<String?> call(String email) {
    return _repository.sendPasswordResetEmail(email);
  }
}