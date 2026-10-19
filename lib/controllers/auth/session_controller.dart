import 'package:flutter/foundation.dart';

import '../../shared/network/api_failure.dart';
import '../../services/auth/auth_service.dart';
import '../../models/auth/user_profile.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._auth);

  final AuthService _auth;
  String? token;
  UserProfile? user;
  bool restoring = true;
  bool busy = false;

  Future<void> restore() async {
    try {
      final saved = await _auth.savedSession();
      if (saved != null) {
        token = saved.token;
        user = await _auth.profile(saved.userId);
      }
    } catch (_) {
      token = null;
      user = null;
      await _auth.clear();
    } finally {
      restoring = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String identifier, String password) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      final result = await _auth.login(identifier, password);
      token = result.token;
      user = await _auth.profile(result.userId);
      await _auth.save(result);
    } catch (_) {
      token = null;
      user = null;
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      if (token != null) await _auth.logout();
    } catch (_) {
      // Clear local credentials even when the server cannot be reached.
    }
    token = null;
    user = null;
    notifyListeners();
    await _auth.clear();
  }

  Future<void> refresh() async {
    final id = user?.userId;
    if (id == null) return;
    try {
      user = await _auth.profile(id);
      notifyListeners();
    } on ApiFailure catch (failure) {
      if (failure.statusCode == 401) await signOut();
      rethrow;
    }
  }

  Future<void> register(String userName, String email, String password) =>
      _auth.register(userName, email, password);

  Future<void> requestReset(String identifier) =>
      _auth.requestReset(identifier);

  Future<void> confirmReset(String identifier, String code, String password) =>
      _auth.confirmReset(identifier, code, password);
}
