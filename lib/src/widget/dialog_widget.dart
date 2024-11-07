import 'package:classroom_app/src/widget/elevated_button_widget.dart';
import 'package:flutter/material.dart';

class DialogWidget extends StatelessWidget {
  final String dialogTitle;
  final String dialogContent;
  final bool? isConfirmDialog;
  final VoidCallback? onConfirm;
  const DialogWidget({required this.dialogTitle, required this.dialogContent, this.isConfirmDialog, this.onConfirm, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: SizedBox(
            width: 400,
            child: Text(
              dialogTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        content: SizedBox(
          width: 400,
          child: Wrap(
            children: [
              Text(
                dialogContent,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          SizedBox(
            width: 100,
            height: 40,
            child: TextButton(
              child: const Text('Back'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          if (isConfirmDialog != null)
            SizedBox(
              width: 100,
              height: 40,
              child: ElevatedButtonWidget(
                onPressed: onConfirm,
                text: 'Confirm',
                radius: 5,
              ),
            ),
        ],
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))));
  }
}
