import 'dart:async';

import 'package:ex_kit/ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/app_color.dart';

class MyAutoComplete extends StatelessWidget {
  const MyAutoComplete({
    super.key,
    this.initialValue,
    required this.asyncSuggestions,
    this.autofocus = false,
    this.onSelected,
    this.onChanged,
    this.onSubmitted,
    this.prefix,
    this.suffix,
    this.hint,
  });

  final TextEditingValue? initialValue;

  final FutureOr<Iterable<String>> Function(TextEditingValue) asyncSuggestions;
  final void Function(String)? onSelected;
  final void Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool autofocus;

  /// custom
  final Widget? prefix;
  final Widget? suffix;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: initialValue,
      optionsBuilder: asyncSuggestions,
      onSelected: onSelected,
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return CupertinoTextField(
          autofocus: autofocus,
          controller: textEditingController,
          focusNode: focusNode,
          onSubmitted: (value) => {
            onFieldSubmitted(),
            onSubmitted?.call(value),
          },
          onChanged: onChanged,
          style: TextStyle(fontSize: 13, color: AppColor.textReverse),
          suffix: suffix,
          prefix: prefix,
          placeholder: hint,
          placeholderStyle: TextStyle(fontSize: 13, color: Vx.neutral500),
          clearButtonMode: OverlayVisibilityMode.editing,
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
