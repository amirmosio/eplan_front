import 'dart:async';


import '../errors.dart';
import '../impl.dart';

class DirUtils implements LocalStorageImpl {
  DirUtils(this.fileName, [this.path]);

  final String path, fileName;

  StreamController<Map<String, dynamic>> storage =
      StreamController<Map<String, dynamic>>();

  @override
  Future<void> clear() {
    throw PlatformNotSupportedError();
  }

  @override
  void dispose() {
    throw PlatformNotSupportedError();
  }

  @override
  Future<bool> exists() {
    throw PlatformNotSupportedError();
  }

  @override
  Future<void> flush() {
    throw PlatformNotSupportedError();
  }

  @override
  dynamic getItem(String key) {
    throw PlatformNotSupportedError();
  }

  @override
  Future<void> init([Map<String, dynamic> initialData]) {
    throw PlatformNotSupportedError();
  }

  @override
  Future<void> remove(String key) {
    throw PlatformNotSupportedError();
  }

  @override
  Future<void> setItem(String key, value) {
    throw PlatformNotSupportedError();
  }

  @override
  Stream<Map<String, dynamic>> get stream => storage.stream;
}
