import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// State for app-level settings (language, auth).
class AppSettingsState {
  const AppSettingsState({
    this.languageCode = 'ur',
    this.accessToken,
    this.isLoggedIn = false,
  });

  final String languageCode;
  final String? accessToken;
  final bool isLoggedIn;

  AppSettingsState copyWith({
    String? languageCode,
    String? accessToken,
    bool? isLoggedIn,
  }) =>
      AppSettingsState(
        languageCode: languageCode ?? this.languageCode,
        accessToken: accessToken ?? this.accessToken,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      );
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier() : super(const AppSettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(AppConstants.prefLanguageCode) ?? 'ur';
    final token = prefs.getString(AppConstants.prefAccessToken);
    state = AppSettingsState(
      languageCode: lang,
      accessToken: token,
      isLoggedIn: token != null,
    );
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLanguageCode, code);
    state = state.copyWith(languageCode: code);
  }

  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefAccessToken, access);
    await prefs.setString(AppConstants.prefRefreshToken, refresh);
    state = state.copyWith(accessToken: access, isLoggedIn: true);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefAccessToken);
    await prefs.remove(AppConstants.prefRefreshToken);
    state = state.copyWith(accessToken: null, isLoggedIn: false);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>(
  (ref) => AppSettingsNotifier(),
);
