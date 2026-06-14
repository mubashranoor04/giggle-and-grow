import '../../domain/entity/login_entity.dart';

class LoginModel implements LoginEntity {
  @override
  String email;
  @override
  String password;

  LoginModel({required this.email, required this.password});

  // Helper to ensure we always work with clean strings
  void sanitize() {
    email = email.trim().toLowerCase();
  }
}