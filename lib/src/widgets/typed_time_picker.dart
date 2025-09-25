import 'package:flutter/material.dart';

import 'field_wrapper.dart';

/// A pre-built time picker widget that integrates with typed form validation.
class TypedTimePicker extends StatefulWidget {
  const TypedTimePicker({
    super.key,
    required this.name,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
    this.use24HourFormat = false,
    this.onTimeSubmitted,
    this.onChanged,
    this.debounceTime,
    this.transformValue,
  });

  final String name;
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputDecoration? decoration;
  final bool use24HourFormat;
  final ValueChanged<TimeOfDay>? onTimeSubmitted;
  final ValueChanged<TimeOfDay?>? onChanged;
  final Duration? debounceTime;
  final TimeOfDay Function(TimeOfDay value)? transformValue;

  @override
  State<TypedTimePicker> createState() => _TypedTimePickerState();
}

class _TypedTimePickerState extends State<TypedTimePicker> {
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
    return FieldWrapper<TimeOfDay>(
      fieldName: widget.name,
      debounceTime: widget.debounceTime,
      transformValue: widget.transformValue,
      onValueChanged: widget.onChanged,
      builder: (context, value, error, hasError, updateValue) {
        // Update controller text when value changes
        final displayText = value != null ? value.format(context) : '';
        if (_effectiveController.text != displayText) {
          _effectiveController.text = displayText;
        }

        return TextFormField(
          readOnly: true,
          controller: _effectiveController,
          decoration: widget.decoration
                  ?.copyWith(errorText: hasError ? error : null) ??
              InputDecoration(
                labelText: widget.label,
                hintText: widget.hintText,
                helperText: widget.helperText,
                prefixIcon: widget.prefixIcon ?? const Icon(Icons.access_time),
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
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: value ?? TimeOfDay.now(),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat: widget.use24HourFormat,
                  ),
                  child: child!,
                );
              },
            );

            if (selectedTime != null) {
              updateValue(selectedTime);
              widget.onTimeSubmitted?.call(selectedTime);
            }
          },
        );
      },
    );
  }
}
