import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

/// A reusable dropdown search widget function.
/// Usage: `buildSearchableDropdown(context, itemsList)`
Widget buildSearchableDropdown(BuildContext context, List<String> items) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: DropdownSearch<String>(
      items: items,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Select an item",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      onChanged: (value) {
        print("Selected: $value");
      },
    ),
  );
}
