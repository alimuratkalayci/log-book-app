import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/theme.dart';

class GroundTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController totalTimeController;
  const GroundTextField({super.key, required this.controller, required this.totalTimeController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(
            RegExp(r'[0-9.]')),
      ],
      controller: controller,
      style: TextStyle(color: AppTheme.TextColorWhite),
      decoration:
      _customInputDecoration('Ground').copyWith(
        suffixIcon: totalTimeController.text.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: 0.0),
            child: TextButton(
              onPressed: () {
                double currentValue =
                    double.tryParse(
                        totalTimeController
                            .text) ??
                        0.0;
                controller.text =
                    currentValue.toString();
              },
              child: Text(
                'Copy Time',
                style: TextStyle(
                    color:
                    AppTheme.TextColorWhite),
              ),
            ),
          ),
        )
            : null,
      ),
      validator: (value) {
        return null;
      },
    );
  }
  InputDecoration _customInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        color: AppTheme.TextColorWhite,
      ),
      hintText: 'Enter $labelText',
      hintStyle: const TextStyle(
        color: AppTheme.TextColorWhite,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: AppTheme.TextColorWhite,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: AppTheme.TextColorWhite,
          width: 2.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: AppTheme.Green,
          width: 2.0,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }

}