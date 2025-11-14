import 'package:flutter/material.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? ontap;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.ontap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              fontFamily: "Lato",
              fontWeight: FontWeight.w700,
              color: isDisabled ? ColorsApp.Grey2 : ColorsApp.black,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Text Field
        Opacity(
          opacity: isDisabled ? 0.7 : 1.0, // efek redup saat disabled
          child: IgnorePointer(
            // cegah interaksi jika disabled
            ignoring: isDisabled,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              enabled: enabled,
              maxLines: maxLines,
              maxLength: maxLength,
              textInputAction: textInputAction,
              focusNode: focusNode,
              onFieldSubmitted: onFieldSubmitted,
              readOnly: readOnly,
              onTap: ontap,

              style: const TextStyle(
                fontSize: 13,
                fontFamily: "Lato",
                fontWeight: FontWeight.w700,
                color: ColorsApp.Grey1,
              ),
              decoration: InputDecoration(
                // Hint text
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  fontFamily: "Lato",
                  fontWeight: FontWeight.w700,
                  color: ColorsApp.Grey2,
                ),

                // Styling
                filled: true,
                fillColor: enabled ? Colors.white : ColorsApp.white1,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),

                // Border
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: ColorsApp.Grey3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: ColorsApp.Grey3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Color(0xFF4B4B4B), width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                ),

                // Icons
                prefixIcon: prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: prefixIcon,
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                suffixIcon: suffixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8, right: 16),
                        child: suffixIcon,
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),

                // Error style
                errorStyle: const TextStyle(
                  fontSize: 12,
                  fontFamily: "Lato",
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                  height: 1.2,
                ),
                errorMaxLines: 2,
              ),

              // Validation
              validator: (value) {
                if (validator != null) {
                  return validator!(value);
                }
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              },

              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
