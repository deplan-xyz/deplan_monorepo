import 'package:deplan/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final String? hintText;
  final Function(String value)? onSubmitted;
  final Function(String value)? onChanged;

  const SearchTextField({
    super.key,
    this.hintText,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(
        fontSize: 16,
      ),
      maxLines: 1,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: COLOR_GRAY,
        ),
        contentPadding: const EdgeInsets.only(bottom: 4),
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
