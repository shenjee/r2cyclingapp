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

import 'r2_account.dart';
import 'r2_group.dart';

class R2UserProfile {
  R2Account _account;
  R2Group _group;

  R2UserProfile({
    required R2Account account,
    required R2Group group,
  })
      : _account = account,
        _group = group;

  // Getter and Setter for account
  R2Account get account => _account;

  set account(R2Account value) {
    _account = value;
  }

  // Getter and Setter for group
  R2Group get group => _group;

  set group(R2Group value) {
    _group = value;
  }
}