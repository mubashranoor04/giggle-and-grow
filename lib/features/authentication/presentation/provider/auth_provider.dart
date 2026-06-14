import 'package:flutter/material.dart';
import '../../data/model/LoginModel.dart';
import '../../domain/usecase/signin_usecase.dart';
import '../../domain/usecase/signup_usecase.dart';
import '../../domain/usecase/send_password_reset_usecase.dart';

class AuthNotifier extends ChangeNotifier {
  final SignInUseCase _signIn = SignInUseCase();
  final SignUpUseCase _signUp = SignUpUseCase();
  final SendPasswordResetUseCase _reset = SendPasswordResetUseCase();

  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  bool _isValidGmail(String email) => email.trim().toLowerCase().endsWith('@gmail.com');

  Future<bool> signIn(String email, String password) async {
    if (!_isValidGmail(email)) return _fail("Please use a valid @gmail.com address.");

    _startLoading();
    final result = await _signIn.call(LoginModel(email: email.trim(), password: password));
    return _finish(result);
  }

  Future<bool> signUp(String email, String password, String name) async {
    if (!_isValidGmail(email)) return _fail("Registration is restricted to @gmail.com.");

    _startLoading();
    final result = await _signUp.call(email.trim(), password, name);
    return _finish(result);
  }

  Future<bool> sendPasswordReset(String email) async {
    if (!_isValidGmail(email)) return _fail("Enter a valid @gmail.com to reset.");

    _startLoading();
    final result = await _reset.call(email.trim());
    _finish(result, successMsg: "Reset link sent to your Gmail!");
    return result == null;
  }

  // State Helpers
  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  bool _fail(String msg) {
    _errorMessage = msg;
    notifyListeners();
    return false;
  }

  bool _finish(String? err, {String? successMsg}) {
    _isLoading = false;
    _errorMessage = err;
    _infoMessage = err == null ? successMsg : null;
    notifyListeners();
    return err == null;
  }
}