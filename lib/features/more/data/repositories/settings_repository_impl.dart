import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../sources/settings_remote_data_source.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.read(settingsRemoteDataSourceProvider));
});

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;

  SettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<AppSettings> getSettings() async {
    return await _remoteDataSource.getSettings();
  }

  @override
  Future<AppSettings> updateSettings({String? appLanguage, String? themeMode}) async {
    return await _remoteDataSource.updateSettings(
      appLanguage: appLanguage,
      themeMode: themeMode,
    );
  }
}
