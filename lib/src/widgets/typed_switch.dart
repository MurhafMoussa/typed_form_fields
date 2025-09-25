import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'field_wrapper.dart';

/// A pre-built switch widget that integrates with typed form validation.
class TypedSwitch extends StatelessWidget {
  const TypedSwitch({
    super.key,
    required this.name,
    required this.title,
    this.subtitle,
    this.secondary,
    this.isThreeLine = false,
    this.dense,
    this.contentPadding,
    this.selected = false,
    this.autofocus = false,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.activeThumbImage,
    this.inactiveThumbImage,
    this.materialTapTargetSize,
    this.dragStartBehavior = DragStartBehavior.start,
    this.mouseCursor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.focusNode,
    this.onFocusChange,
    this.enableFeedback,
    this.onChanged,
    this.debounceTime,
    this.transformValue,
  });

  final String name;
  final Widget title;
  final Widget? subtitle;
  final Widget? secondary;
  final bool isThreeLine;
  final bool? dense;
  final EdgeInsetsGeometry? contentPadding;
  final bool selected;
  final bool autofocus;
  final ListTileControlAffinity controlAffinity;
  final Color? activeColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final ImageProvider? activeThumbImage;
  final ImageProvider? inactiveThumbImage;
  final MaterialTapTargetSize? materialTapTargetSize;
  final DragStartBehavior dragStartBehavior;
  final MouseCursor? mouseCursor;
  final Color? focusColor;
  final Color? hoverColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool? enableFeedback;
  final ValueChanged<bool?>? onChanged;
  final Duration? debounceTime;
  final bool Function(bool value)? transformValue;

  @override
  Widget build(BuildContext context) {
    return FieldWrapper<bool>(
      fieldName: name,
      debounceTime: debounceTime,
      transformValue: transformValue,
      onValueChanged: onChanged,
      builder: (context, value, error, hasError, updateValue) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: title,
              subtitle: subtitle,
              secondary: secondary,
              isThreeLine: isThreeLine,
              dense: dense,
              contentPadding: contentPadding,
              selected: selected,
              autofocus: autofocus,
              controlAffinity: controlAffinity,
              value: value ?? false,
              onChanged: (newValue) => updateValue(newValue),
              activeThumbColor: activeColor,
              activeTrackColor: activeTrackColor,
              inactiveThumbColor: inactiveThumbColor,
              inactiveTrackColor: inactiveTrackColor,
              activeThumbImage: activeThumbImage,
              inactiveThumbImage: inactiveThumbImage,
              materialTapTargetSize: materialTapTargetSize,
              dragStartBehavior: dragStartBehavior,
              mouseCursor: mouseCursor,
              hoverColor: hoverColor,
              overlayColor: overlayColor,
              splashRadius: splashRadius,
              focusNode: focusNode,
              onFocusChange: onFocusChange,
              enableFeedback: enableFeedback,
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
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
