import 'package:flutter/material.dart';

class FileUploadProgressDialog extends StatefulWidget {
  final Future<void> Function() onCancel;
  final double progress;

  const FileUploadProgressDialog({required this.onCancel, required this.progress, super.key});

  @override
  _FileUploadProgressDialogState createState() => _FileUploadProgressDialogState();
}

class _FileUploadProgressDialogState extends State<FileUploadProgressDialog> {
  bool _isCancelled = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Uploading File"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(value: widget.progress / 100),
          const SizedBox(height: 16),
          Text("${widget.progress.toStringAsFixed(1)}% uploaded"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            setState(() {
              _isCancelled = true;
            });
            await widget.onCancel();
            if (mounted) Navigator.of(context).pop();
          },
          child: Text(_isCancelled ? "Cancelling..." : "Cancel"),
        ),
      ],
    );
  }
}
