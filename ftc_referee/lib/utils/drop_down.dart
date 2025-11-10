import 'package:flutter/material.dart';

DropdownMenu<T?> getDropdownMenu<T>(
  String name,
  List<T> entries,
  ValueChanged<T?> onChanged, {
  T? initialSelection,              // pass null for “nothing” selected
  bool includeNone = true,          // add a “None” option to the menu
  String noneLabel = 'None',
}) {
  final menuEntries = <DropdownMenuEntry<T?>>[];

  if (includeNone) {
    menuEntries.add(DropdownMenuEntry<T?>(value: null, label: noneLabel));
  }

  menuEntries.addAll(
    entries.map(
      (e) => DropdownMenuEntry<T?>(value: e, label: e.toString()),
    ),
  );

  return DropdownMenu<T?>(
    label: Text(name),
    initialSelection: initialSelection, // null => no initial value selected
    dropdownMenuEntries: menuEntries,
    onSelected: onChanged,
    
  );
}