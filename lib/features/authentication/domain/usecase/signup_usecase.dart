import '../../data/repositoryImp/auth_repository_imp.dart';
import '../repository/auth_repository.dart';

class SignUpUseCase {
  SignUpUseCase();

  final AuthRepository _repository = AuthRepositoryImpl();

  Future<String?> call(String email, String password, String name) {
    return _repository.createUserWithEmailAndPassword(email, password, name);
  }
}
