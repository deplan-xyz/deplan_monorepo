import 'dart:typed_data';

import 'package:subdoor/widgets/body_padding.dart';
import 'package:flutter/material.dart';

class PaymentConfirmation extends StatelessWidget {
  final Uint8List? logo;
  final String label;
  final String title;
  final String description;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const PaymentConfirmation({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    required this.label,
    required this.title,
    required this.description,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xff87899B),
                foregroundColor: Colors.grey.shade300,
              ),
            ),
          ),
        ),
        BodyPadding(
          child: Column(
            children: [
              if (logo != null)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.memory(logo!),
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 15,
                ),
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey.shade300,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff87899B),
                        foregroundColor: Colors.grey.shade300,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: const Color(0xff11243E),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xff87899B),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
