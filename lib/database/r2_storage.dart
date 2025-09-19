// Copyright (c) 2025 RockRoad Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class R2Storage {
  static const _storage = FlutterSecureStorage();

  static Future<void> save(String key, String value) async {
    await _storage.write(key:key, value:value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key:key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'authtoken', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'authtoken');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'authtoken');
  }
}