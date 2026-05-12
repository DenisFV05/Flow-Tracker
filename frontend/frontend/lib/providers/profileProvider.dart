import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileApi _profileApi = ProfileApi();

  Map<String, dynamic> userProfile = {};
  bool profileLoading = false;
  String? error;

  Future<void> loadProfile() async {
    try {
      profileLoading = true;
      notifyListeners();
      userProfile = await _profileApi.getProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      profileLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    try {
      userProfile = await _profileApi.updateProfile(name: name, avatar: avatar);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}