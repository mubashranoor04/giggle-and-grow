import '../../domain/repository/auth_repository.dart';
import '../model/LoginModel.dart';
import '../services/remote/auth_services.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthServices _remoteService = AuthServices();

  @override
  Future<String?> signInWithEmailAndPassword(LoginModel loginModel) {
    return _remoteService.signInWithEmail(loginModel.email, loginModel.password);
  }

  @override
  Future<String?> createUserWithEmailAndPassword(String email, String password, String name) {
    return _remoteService.signUpWithEmail(email, password, name);
  }

  @override
  Future<String?> sendPasswordResetEmail(String email) {
    return _remoteService.sendPasswordResetEmail(email);
  }
}
