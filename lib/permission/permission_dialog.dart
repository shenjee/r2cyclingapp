import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r2cyclingapp/permission/r2_permission_model.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';

class PermissionDialog extends StatelessWidget {
  final _permisson = R2PermissionModels();

   Future<void> show(BuildContext context) async {
    bool granted = false;//await _permisson.requestPermissions();
    granted = false;
    if (!granted) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.all(20),
          child: Stack (
            alignment: Alignment.center,
            children: <Widget>[
              Column(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children:<Widget> [
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Text('需要获取以下权限', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                  ),
                  _permissionitem('assets/icons/bluetooth.png','蓝牙','连接您的智能头盔'),
                  _permissionitem('assets/icons/mic.png', '麦克风', '打开麦克风进行网络对讲'),
                  _permissionitem('assets/icons/location.png', '位置信息', '位置信息发送给你的紧急联系人'),
                  SizedBox(height: 50),
                  R2FlatButton(
                    text: '确定',
                    onPressed: () async {
                        await _permisson.requestPermissions();
                        Navigator.of(context).pop(0);
                        },
                  ),
                  SizedBox(height: 50),
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
  Widget _permissionitem(String icon, String title, String subtitle) {
     return Column (
       mainAxisAlignment: MainAxisAlignment.center,
       crossAxisAlignment: CrossAxisAlignment.center,
       mainAxisSize: MainAxisSize.min,
       children: <Widget>[
         Row (
           children: <Widget>[
             Padding(
                 padding: EdgeInsets.fromLTRB(100, 20, 0, 0),
                 child: Image.asset(icon, width: 29, height: 29)
             ),
             Padding(
               padding: EdgeInsets.fromLTRB(5, 20, 0, 0),
               child: Text(title, style: TextStyle(fontSize: 20)),
             )
           ]
         ),
         Padding(
           padding: EdgeInsets.all(10.0),
           child: Text(subtitle, style: TextStyle(fontSize: 18)),
         )
       ],
     );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      child: Stack (
          alignment: Alignment.center,
          children: <Widget>[
            Column(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children:<Widget> [
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Text('需要获取以下权限', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                ),
                _permissionitem('assets/icons/bluetooth.png','蓝牙','连接您的智能头盔'),
                _permissionitem('assets/icons/mic.png', '麦克风', '打开麦克风进行网络对讲'),
                _permissionitem('assets/icons/location.png', '位置信息', '位置信息发送给你的紧急联系人'),
                SizedBox(height: 50),
                R2FlatButton(
                  text: '确定',
                  onPressed: () async {
                    await _permisson.requestPermissions();
                    Navigator.of(context).pop(0);
                  },
                ),
                SizedBox(height: 50),
              ],
            ),
          ]
      ),
    );
  }
}