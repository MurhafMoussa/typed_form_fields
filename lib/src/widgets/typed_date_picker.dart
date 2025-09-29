import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'typed_field_wrapper.dart';

/// A pre-built date picker widget that integrates with typed form validation.
class TypedDatePicker extends StatefulWidget {
  const TypedDatePicker({
    super.key,
    required this.name,
    required this.firstDate,
    required this.lastDate,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
    this.dateFormat = 'yyyy-MM-dd',
    this.locale,
    this.selectableDayPredicate,
    this.initialDatePickerMode = DatePickerMode.day,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.keyboardType,
    this.onDateSubmitted,
    this.onChanged,
    this.debounceTime,
    this.transformValue,
  });

  final String name;
  final DateTime firstDate;
  final DateTime lastDate;
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputDecoration? decoration;
  final String dateFormat;
  final Locale? locale;
  final SelectableDayPredicate? selectableDayPredicate;
  final DatePickerMode initialDatePickerMode;
  final String? errorFormatText;
  final String? errorInvalidText;
  final String? fieldHintText;
  final String? fieldLabelText;
  final TextInputType? keyboardType;
  final ValueChanged<DateTime>? onDateSubmitted;
  final ValueChanged<DateTime?>? onChanged;
  final Duration? debounceTime;
  final DateTime Function(DateTime value)? transformValue;

  @override
  State<TypedDatePicker> createState() => _TypedDatePickerState();
}

class _TypedDatePickerState extends State<TypedDatePicker> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController {
    return widget.controller ?? _internalController!;
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypedFieldWrapper<DateTime>(
      fieldName: widget.name,
      debounceTime: widget.debounceTime,
      transformValue: widget.transformValue,
      onValueChanged: widget.onChanged,
      builder: (context, value, error, hasError, updateValue) {
        final formatter = DateFormat(widget.dateFormat);

        // Update controller text when value changes
        final displayText = value != null ? formatter.format(value) : '';
        if (_effectiveController.text != displayText) {
          _effectiveController.text = displayText;
        }

        return TextFormField(
          readOnly: true,
          controller: _effectiveController,
          decoration:
              widget.decoration?.copyWith(errorText: hasError ? error : null) ??
                  InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hintText,
                    helperText: widget.helperText,
                    prefixIcon:
                        widget.prefixIcon ?? const Icon(Icons.calendar_today),
                    suffixIcon: widget.suffixIcon,
                    errorText: hasError ? error : null,
                    border: const OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              locale: widget.locale,
              selectableDayPredicate: widget.selectableDayPredicate,
              initialDatePickerMode: widget.initialDatePickerMode,
              errorFormatText: widget.errorFormatText,
              errorInvalidText: widget.errorInvalidText,
              fieldHintText: widget.fieldHintText,
              fieldLabelText: widget.fieldLabelText,
              keyboardType: widget.keyboardType,
            );

            if (selectedDate != null) {
              updateValue(selectedDate);
              widget.onDateSubmitted?.call(selectedDate);
            }
          },
        );
      },
    );
  }
}
