import '../../data/model/LoginModel.dart';

abstract class AuthRepository {
  Future<String?> signInWithEmailAndPassword(LoginModel loginModel);
  Future<String?> createUserWithEmailAndPassword(String email, String password, String name);
  Future<String?> sendPasswordResetEmail(String email);
}
