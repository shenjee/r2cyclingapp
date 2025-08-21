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

class R2Group {
  final int _groupId;
  String _groupCode;
  R2Group({
    required int groupId,
    String? groupCode,
  })
      : _groupId = groupId,
        _groupCode = groupCode ?? 'G$groupId';

  int get groupId => _groupId;

  String get groupCode => _groupCode;
  set groupCode(String value) {
    _groupCode = value;
  }

  // Convert R2Group to Map
  Map<String, dynamic> toMap() {
    return {
      'groupId': _groupId,
      'groupCode': _groupCode ?? 'G$_groupId',
    };
  }

  // Create R2Account from Map
  factory R2Group.fromMap(Map<String, dynamic> map) {
    return R2Group(groupId: map['groupId'])
      ..groupCode = map['groupCode'];
  }
}