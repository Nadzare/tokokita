import 'package:flutter/material.dart';

class WarningDialog extends StatelessWidget {
  final String? description;
  final VoidCallback? okClick;

  const WarningDialog({Key? key, this.description, this.okClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Warning"),
      content: Text(description!),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (okClick != null) okClick!();
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
