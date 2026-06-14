

import '../../data/model/LoginModel.dart';
import '../../data/repositoryImp/auth_repository_imp.dart';
import '../repository/auth_repository.dart';

class SignInUseCase {
  SignInUseCase();

  final AuthRepository _repository = AuthRepositoryImpl();

  Future<String?> call(LoginModel loginModel) {
    return _repository.signInWithEmailAndPassword(loginModel);
  }
}