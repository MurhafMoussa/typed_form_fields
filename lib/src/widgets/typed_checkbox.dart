import 'package:flutter/material.dart';

import 'field_wrapper.dart';

/// A pre-built checkbox widget that integrates with typed form validation.
///
/// This widget wraps a [CheckboxListTile] with [FieldWrapper] to provide
/// automatic form state management, validation, and error handling.
class TypedCheckbox extends StatelessWidget {
  const TypedCheckbox({
    super.key,
    required this.name,
    required this.title,
    this.subtitle,
    this.secondary,
    this.isThreeLine = false,
    this.dense,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.autofocus = false,
    this.contentPadding,
    this.tristate = false,
    this.shape,
    this.selectedTileColor,
    this.onChanged,
    this.checkColor,
    this.activeColor,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.enableFeedback,
    this.debounceTime,
    this.transformValue,
  });

  /// The name of the field in the form state.
  final String name;

  /// The primary content of the list item.
  final Widget title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// A widget to display on the opposite side of the tile from the checkbox.
  final Widget? secondary;

  /// Whether this list item is intended to display three lines of text.
  final bool isThreeLine;

  /// Whether this list item is part of a vertically dense list.
  final bool? dense;

  /// If this tile is also enabled then icons and text are rendered with the same color.
  final bool selected;

  /// Where to place the control relative to the text.
  final ListTileControlAffinity controlAffinity;

  /// Whether this checkbox should focus itself if nothing else is already focused.
  final bool autofocus;

  /// The tile's internal padding.
  final EdgeInsetsGeometry? contentPadding;

  /// If true, the checkbox's value can be true, false, or null.
  final bool tristate;

  /// The shape of the checkbox's [Material].
  final ShapeBorder? shape;

  /// The color for the tile's [Material] when it has the input focus.
  final Color? selectedTileColor;

  /// Called when the value of the checkbox should change.
  final ValueChanged<bool?>? onChanged;

  /// The color to use when this checkbox is checked.
  final Color? checkColor;

  /// The color to use when this checkbox is checked.
  final Color? activeColor;

  /// The color that fills the checkbox.
  final WidgetStateProperty<Color?>? fillColor;

  /// The color for the checkbox's focus state.
  final Color? focusColor;

  /// The color for the checkbox's hover state.
  final Color? hoverColor;

  /// The color for the checkbox's overlay.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The splash radius of the checkbox.
  final double? splashRadius;

  /// Configures the minimum size of the tap target.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// Defines how compact the checkbox's layout will be.
  final VisualDensity? visualDensity;

  /// An optional focus node to use as the focus node for this widget.
  final FocusNode? focusNode;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  final bool? enableFeedback;

  /// Time to wait before updating the form state after value changes.
  final Duration? debounceTime;

  /// Function to transform the value before storing in form state.
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
            CheckboxListTile(
              title: title,
              subtitle: subtitle,
              secondary: secondary,
              isThreeLine: isThreeLine,
              dense: dense,
              selected: selected,
              controlAffinity: controlAffinity,
              autofocus: autofocus,
              contentPadding: contentPadding,
              tristate: tristate,
              shape: shape,
              selectedTileColor: selectedTileColor,
              value: value ?? false,
              onChanged: (newValue) => updateValue(newValue ?? false),
              checkColor: checkColor,
              activeColor: activeColor,
              fillColor: fillColor,
              hoverColor: hoverColor,
              overlayColor: overlayColor,
              splashRadius: splashRadius,
              materialTapTargetSize: materialTapTargetSize,
              visualDensity: visualDensity,
              focusNode: focusNode,
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
