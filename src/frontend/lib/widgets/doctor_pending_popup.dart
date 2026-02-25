import 'package:flutter/material.dart';

class DoctorPendingPopup extends StatelessWidget {
  const DoctorPendingPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تم استلام طلبك'),
      content: const Text(
        'طلب تسجيلك كدكتور قيد المراجعة.\n'
        'سيتم إشعارك عبر البريد الإلكتروني عند الموافقة.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('حسنًا'),
        ),
      ],
    );
  }
}