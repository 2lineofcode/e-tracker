import '../../../core/app_base.dart';

class LoginRepository {
  Future<void> login(String email, String password) async {
    await db.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
}
