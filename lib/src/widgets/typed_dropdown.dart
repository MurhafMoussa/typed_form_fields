import 'package:flutter/material.dart';

import 'field_wrapper.dart';

/// A pre-built dropdown widget that integrates with typed form validation.
///
/// This widget wraps a [DropdownButtonFormField] with [FieldWrapper] to provide
/// automatic form state management, validation, and error handling.
class TypedDropdown<T> extends StatelessWidget {
  const TypedDropdown({
    super.key,
    required this.name,
    required this.items,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
    this.onChanged,
    this.onTap,
    this.selectedItemBuilder,
    this.value,
    this.disabledHint,
    this.elevation = 8,
    this.style,
    this.underline,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight = kMinInteractiveDimension,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownColor,
    this.menuMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.padding,
    this.debounceTime,
    this.transformValue,
    this.itemBuilder,
  });

  /// The name of the field in the form state.
  final String name;

  /// The list of items the user can select.
  final List<T> items;

  /// The label text displayed above the field.
  final String? label;

  /// The hint text displayed when no item is selected.
  final String? hintText;

  /// The helper text displayed below the field.
  final String? helperText;

  /// An icon to display before the dropdown.
  final Widget? prefixIcon;

  /// An icon to display after the dropdown.
  final Widget? suffixIcon;

  /// The decoration to show around the dropdown.
  final InputDecoration? decoration;

  /// Called when the user selects an item.
  final ValueChanged<T?>? onChanged;

  /// Called when the dropdown button is tapped.
  final VoidCallback? onTap;

  /// A builder to customize how the selected item appears in the button.
  final DropdownButtonBuilder? selectedItemBuilder;

  /// The currently selected item.
  final T? value;

  /// A placeholder widget that is displayed by the dropdown button.
  final Widget? disabledHint;

  /// The z-coordinate at which to place the menu when open.
  final int elevation;

  /// The text style to use for text in the dropdown button and the dropdown menu.
  final TextStyle? style;

  /// The widget to use for drawing the drop-down button's underline.
  final Widget? underline;

  /// The widget to use for the drop-down button's icon.
  final Widget? icon;

  /// The color of any [Icon] descendant of [icon] if this button is disabled.
  final Color? iconDisabledColor;

  /// The color of any [Icon] descendant of [icon] if this button is enabled.
  final Color? iconEnabledColor;

  /// The size to use for the drop-down button's down arrow icon button.
  final double iconSize;

  /// Reduce the button's height.
  final bool isDense;

  /// Set the dropdown's inner contents to horizontally fill its parent.
  final bool isExpanded;

  /// If null, then the menu item heights will vary according to each menu item's intrinsic height.
  final double? itemHeight;

  /// The color for the button's [Material] when it has the input focus.
  final Color? focusColor;

  /// An optional focus node to use as the focus node for this widget.
  final FocusNode? focusNode;

  /// Whether this dropdown button should focus itself if nothing else is already focused.
  final bool autofocus;

  /// The background color of the dropdown.
  final Color? dropdownColor;

  /// The maximum height of the menu.
  final double? menuMaxHeight;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  final bool? enableFeedback;

  /// Defines how the hint or the selected item is positioned within the button.
  final AlignmentGeometry alignment;

  /// The border radius of the dropdown's menu.
  final BorderRadius? borderRadius;

  /// The padding of the dropdown's menu.
  final EdgeInsetsGeometry? padding;

  /// Time to wait before updating the form state after value changes.
  final Duration? debounceTime;

  /// Function to transform the value before storing in form state.
  final T Function(T value)? transformValue;

  /// Custom builder for dropdown items.
  final Widget Function(T item)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return FieldWrapper<T>(
      fieldName: name,
      debounceTime: debounceTime,
      transformValue: transformValue,
      onValueChanged: onChanged,
      builder: (context, value, error, hasError, updateValue) {
        return DropdownButtonFormField<T>(
          initialValue: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder?.call(item) ?? Text(item.toString()),
            );
          }).toList(),
          onChanged: updateValue,
          onTap: onTap,
          selectedItemBuilder: selectedItemBuilder,
          decoration:
              decoration?.copyWith(errorText: hasError ? error : null) ??
                  InputDecoration(
                    labelText: label,
                    hintText: hintText,
                    helperText: helperText,
                    prefixIcon: prefixIcon,
                    suffixIcon: suffixIcon,
                    errorText: hasError ? error : null,
                    border: const OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
          disabledHint: disabledHint,
          elevation: elevation,
          style: style,
          icon: icon,
          iconDisabledColor: iconDisabledColor,
          iconEnabledColor: iconEnabledColor,
          iconSize: iconSize,
          isDense: isDense,
          isExpanded: isExpanded,
          itemHeight: itemHeight,
          focusColor: focusColor,
          focusNode: focusNode,
          autofocus: autofocus,
          dropdownColor: dropdownColor,
          menuMaxHeight: menuMaxHeight,
          enableFeedback: enableFeedback,
          alignment: alignment,
          borderRadius: borderRadius,
          padding: padding,
        );
      },
    );
  }
}
