import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MyAutoComplete extends StatelessWidget {
  const MyAutoComplete({
    super.key,
    this.initialValue,
    required this.asyncSuggestions,
    this.autofocus = false,
    this.decoration,
    this.onSelected,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingValue? initialValue;

  final FutureOr<Iterable<String>> Function(TextEditingValue) asyncSuggestions;
  final InputDecoration? decoration;

  final void Function(String)? onSelected;
  final void Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: initialValue,
      optionsBuilder: asyncSuggestions,
      onSelected: onSelected,
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          autofocus: autofocus,
          controller: textEditingController,
          focusNode: focusNode,
          onSubmitted: (value) => {
            onFieldSubmitted(),
            onSubmitted?.call(value),
          },
          onChanged: onChanged,
          decoration: decoration,
          style: TextStyle(fontSize: 13),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 40, maxHeight: 250, maxWidth: 250),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Builder(
                      builder: (context) {
                        final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                        if (highlight) {
                          SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                            Scrollable.ensureVisible(context, alignment: 0.5);
                          });
                        }
                        return Container(
                          color: highlight ? Theme.of(context).focusColor : null,
                          padding: const EdgeInsets.all(16.0),
                          child: Text(option, style: TextStyle(fontSize: 12)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
