import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String? description;
  final VoidCallback? okClick;

  const SuccessDialog({Key? key, this.description, this.okClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Sukses"),
      content: Text(description!),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            okClick!();
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
