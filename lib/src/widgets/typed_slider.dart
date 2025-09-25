import 'package:flutter/material.dart';

import 'field_wrapper.dart';

/// A pre-built slider widget that integrates with typed form validation.
class TypedSlider extends StatelessWidget {
  const TypedSlider({
    super.key,
    required this.name,
    required this.min,
    required this.max,
    this.label,
    this.divisions,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.overlayColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.focusNode,
    this.autofocus = false,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.showValue = false,
    this.debounceTime,
    this.transformValue,
  });

  final String name;
  final double min;
  final double max;
  final String? label;
  final int? divisions;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final Color? overlayColor;
  final MouseCursor? mouseCursor;
  final SemanticFormatterCallback? semanticFormatterCallback;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<double?>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final bool showValue;
  final Duration? debounceTime;
  final double Function(double value)? transformValue;

  @override
  Widget build(BuildContext context) {
    return FieldWrapper<double>(
      fieldName: name,
      debounceTime: debounceTime,
      transformValue: transformValue,
      onValueChanged: onChanged,
      builder: (context, value, error, hasError, updateValue) {
        final currentValue = value ?? min;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  label!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: currentValue.clamp(min, max),
                    min: min,
                    max: max,
                    divisions: divisions,
                    label: currentValue.toString(),
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    thumbColor: thumbColor,
                    overlayColor: overlayColor != null
                        ? WidgetStateProperty.all(overlayColor)
                        : null,
                    mouseCursor: mouseCursor,
                    semanticFormatterCallback: semanticFormatterCallback,
                    focusNode: focusNode,
                    autofocus: autofocus,
                    onChanged: updateValue,
                    onChangeStart: onChangeStart,
                    onChangeEnd: onChangeEnd,
                  ),
                ),
                if (showValue)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      currentValue.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
