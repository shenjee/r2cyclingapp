// contact_widget.dart

import 'package:flutter/material.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/constants.dart';

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
                  widget.contact == null ? AppLocalizations.of(context)!.addEmergencyContact : AppLocalizations.of(context)!.emergencyContact,
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
              Text(
                AppLocalizations.of(context)!.sosEmergencyContactDesc,
                style: const TextStyle(fontSize: 18.0,color: AppConstants.textColor),
              ),
            if (widget.contact == null) const SizedBox(height: 20.0),
            Row(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.name, 
                    style: const TextStyle(fontSize: 16.0, color: AppConstants.textColor),
                    ),
                  const SizedBox(width: 10.0,),
                  Expanded (
                    child:TextField(controller: _nameController,style: const TextStyle(fontSize: 22.0),),
                  ),
                ]
            ),
            const SizedBox(height: 20.0,),
            Row(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.phone,
                    style: const TextStyle(fontSize: 16.0,color: AppConstants.textColor),
                    ),
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
                    child: Text(
                      AppLocalizations.of(context)!.delete, 
                      style: const TextStyle(fontSize: 20.0, color: AppConstants.primaryColor)
                      ),
                  ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () {
                      widget.onSave(_nameController.text, _phoneController.text);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.save, 
                      style: const TextStyle(fontSize: 20.0, color: AppConstants.primaryColor)
                      ),
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
