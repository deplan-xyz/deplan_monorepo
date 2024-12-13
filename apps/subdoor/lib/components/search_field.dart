import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final Function(String) onSearch;

  const SearchField({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 22),
      width: 345,
      height: 40,
      child: TextField(
        style: const TextStyle(color: Colors.black),
        textAlignVertical: TextAlignVertical.center,
        onChanged: onSearch,
        textInputAction: TextInputAction.done,
        // inner decoration
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(
              width: 0,
              color: Colors.transparent,
            ),
          ),
          //
          contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 0),
          fillColor: const Color.fromRGBO(173, 179, 188, 0.25),
          filled: true,
          // outter decoration
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(
              width: 0,
              color: Color(0xffADB3BC),
            ),
          ),
          //
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 10, top: 3, right: 2),
            child: const Icon(
              Icons.search,
              color: Color.fromRGBO(173, 179, 188, 1),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 25,
            minHeight: 25,
          ),
          hintText: 'Search subscription',
          hintStyle: const TextStyle(
            fontFamily: 'sfui',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(173, 179, 188, 1),
          ),
        ),
      ),
    );
  }
}
