// contact_widget.dart

import 'package:flutter/material.dart';

class ContactWidget extends StatefulWidget {
  final Map<String, dynamic>? contact;
  final Function(String name, String phone) onSave;
  final Function? onDelete;
  final Function? onClose;

  ContactWidget({
    this.contact,
    required this.onSave,
    this.onDelete,
    this.onClose
  });

  @override
  _ContactWidgetState createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.contact?['phone'] ?? '');
  }

  void _closeWidget() {
    if (widget.onClose != null) {
      widget.onClose!();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.contact == null ? '添加紧急联系人' : '紧急联系人',
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed:_closeWidget,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (widget.contact == null)
              const Text(
                '开启SOS紧急联络，需要添加至少一名紧急联系人。',
                style: TextStyle(fontSize: 18.0,color: Colors.grey),
              ),
            if (widget.contact == null) SizedBox(height: 20.0),
            Row(
                children: <Widget>[
                  const Text('姓名', style: TextStyle(fontSize: 16.0, color: Colors.grey),),
                  const SizedBox(width: 10.0,),
                  Expanded (
                    child:TextField(controller: _nameController,style: const TextStyle(fontSize: 22.0),),
                  ),
                ]
            ),
            const SizedBox(height: 20.0,),
            Row(
                children: <Widget>[
                  const Text('电话', style: TextStyle(fontSize: 16.0, color: Colors.grey),),
                  const SizedBox(width: 10.0,),
                  Expanded (
                    child:TextField(controller: _phoneController,style: const TextStyle(fontSize: 22.0),),
                  ),
                ]
            ),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.contact != null)
                  TextButton(
                    onPressed: () {
                      if (widget.onDelete != null) {
                        widget.onDelete!();
                      }
                    },
                    child: const Text('删除'),
                  ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () {
                      widget.onSave(_nameController.text, _phoneController.text);
                    },
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
