import '../../../core/app_api.dart';

class LoginRepository {
  Future<void> login(String email, String password) async {
    await db.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout(String email, String password) async {
    await db.auth.signOut();
  }
}
