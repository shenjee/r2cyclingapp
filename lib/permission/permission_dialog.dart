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
import 'package:r2cyclingapp/permission/r2_permission_model.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';

class PermissionDialog extends StatelessWidget {
  final _permisson = R2PermissionModels();
  
  Future<void> show(BuildContext context) async {
    bool granted = false;//await _permisson.requestPermissions();
    granted = false;
    if (!granted) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Stack (
            alignment: Alignment.center,
            children: <Widget>[
              Column(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children:<Widget> [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Text(AppLocalizations.of(context)!.needFollowingPermissions, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                  ),
                  _permissionitem(context, 'assets/icons/bluetooth.png', AppLocalizations.of(context)!.bluetooth, AppLocalizations.of(context)!.bluetoothDesc),
                  _permissionitem(context, 'assets/icons/mic.png', AppLocalizations.of(context)!.microphone, AppLocalizations.of(context)!.microphoneDesc),
                  _permissionitem(context, 'assets/icons/location.png', AppLocalizations.of(context)!.locationInfo, AppLocalizations.of(context)!.locationDesc),
                  const SizedBox(height: 50),
                  R2FlatButton(
                    text: AppLocalizations.of(context)!.confirm,
                    onPressed: () async {
                        await _permisson.requestPermissions();
                        Navigator.of(context).pop(0);
                        },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ]
          ),
       )
      );
    }
  }

  /*
   *
   */
  Widget _permissionitem(BuildContext context, String icon, String title, String subtitle) {
     return Column (
       mainAxisAlignment: MainAxisAlignment.center,
       crossAxisAlignment: CrossAxisAlignment.center,
       mainAxisSize: MainAxisSize.min,
       children: <Widget>[
         Row (
           children: <Widget>[
             Padding(
                 padding: const EdgeInsets.fromLTRB(100, 20, 0, 0),
                 child: Image.asset(icon, width: 29, height: 29)
             ),
             Padding(
               padding: const EdgeInsets.fromLTRB(5, 20, 0, 0),
               child: Text(title, style: const TextStyle(fontSize: 20)),
             )
           ]
         ),
         Padding(
           padding: const EdgeInsets.all(10.0),
           child: Text(subtitle, style: const TextStyle(fontSize: 18)),
         )
       ],
     );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Stack (
          alignment: Alignment.center,
          children: <Widget>[
            Column(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children:<Widget> [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Text(AppLocalizations.of(context)!.needFollowingPermissions, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                ),
                _permissionitem(context, 'assets/icons/bluetooth.png', AppLocalizations.of(context)!.bluetooth, AppLocalizations.of(context)!.bluetoothDesc),
                 _permissionitem(context, 'assets/icons/mic.png', AppLocalizations.of(context)!.microphone, AppLocalizations.of(context)!.microphoneDesc),
                 _permissionitem(context, 'assets/icons/location.png', AppLocalizations.of(context)!.locationInfo, AppLocalizations.of(context)!.locationDesc),
                const SizedBox(height: 50),
                R2FlatButton(
                  text: AppLocalizations.of(context)!.confirm,
                  onPressed: () async {
                    await _permisson.requestPermissions();
                    Navigator.of(context).pop(0);
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ]
      ),
    );
  }
}