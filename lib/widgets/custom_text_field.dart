import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/colors.dart';

/// Champ de texte personnalisé
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final String? errorText;
  
  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.errorText,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: BatteColors.mutedForeground,
              fontSize: 14,
            ),
            filled: true,
            fillColor: enabled ? BatteColors.inputBackground : BatteColors.muted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: BatteColors.mutedForeground)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: BatteColors.mutedForeground),
                    onPressed: onSuffixIconTap,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: BatteColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: BatteColors.destructive,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: BatteColors.destructive,
                width: 2,
              ),
            ),
            errorText: errorText,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

