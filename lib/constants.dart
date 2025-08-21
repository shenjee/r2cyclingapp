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

import 'package:flutter/material.dart';

/// App-wide constants and configuration values
class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF549765);
  static const Color primaryColor200 = Color(0xFF61BC84);
  static const Color primaryColor300 = Color(0xFFC6FFE6);
  static const Color accentColor = Color(0xFF8FBC8F);
  static const Color accentColor200 = Color(0xFF345E37);
  static const Color backgroundColor = Color(0xFFF6F6F6);
  static const Color textColor = Color(0xFF646464);
  static const Color textColor200 = Color(0xFFD5D5D5);
  static const Color textColor300 = Color(0xFFFFFFFF);

  // API Configuration
  static const String httpsAPIAddress = 'rock.r2cycling.com/api';
  
  // Private constructor to prevent instantiation
  AppConstants._();
}