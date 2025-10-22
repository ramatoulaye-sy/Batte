import 'package:flutter/material.dart';
import 'dart:async';
import '../core/constants/colors.dart';

/// TextField avec validation en temps réel
/// Affiche des messages d'erreur dynamiques pendant la saisie
class ValidatedTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onSuffixIconTap;
  final String? Function(String?)? validator;
  final Future<String?> Function(String)? asyncValidator;
  final int debounceMs;

  const ValidatedTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onSuffixIconTap,
    this.validator,
    this.asyncValidator,
    this.debounceMs = 500,
  }) : super(key: key);

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorMessage;
  bool _isValidating = false;
  bool _isValid = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;

    // Annuler le timer précédent
    _debounceTimer?.cancel();

    // Si le champ est vide, réinitialiser
    if (text.isEmpty) {
      setState(() {
        _errorMessage = null;
        _isValidating = false;
        _isValid = false;
      });
      return;
    }

    // Validation synchrone immédiate
    if (widget.validator != null) {
      final syncError = widget.validator!(text);
      if (syncError != null) {
        setState(() {
          _errorMessage = syncError;
          _isValid = false;
          _isValidating = false;
        });
        return;
      }
    }

    // Validation asynchrone avec debounce
    if (widget.asyncValidator != null) {
      setState(() {
        _isValidating = true;
        _errorMessage = null;
      });

      _debounceTimer = Timer(Duration(milliseconds: widget.debounceMs), () {
        _validateAsync(text);
      });
    } else {
      // Pas de validation async, c'est valide
      setState(() {
        _isValid = true;
        _errorMessage = null;
      });
    }
  }

  Future<void> _validateAsync(String text) async {
    if (widget.asyncValidator == null) return;

    try {
      final asyncError = await widget.asyncValidator!(text);
      
      if (mounted && widget.controller.text == text) {
        setState(() {
          _errorMessage = asyncError;
          _isValid = asyncError == null;
          _isValidating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: BatteColors.primary)
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: BatteColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _getBorderColor(),
                width: 2,
              ),
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
          ),
        ),
        
        // Message d'erreur ou de succès
        if (_errorMessage != null || _isValidating || _isValid)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Row(
              children: [
                if (_isValidating)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        BatteColors.primary,
                      ),
                    ),
                  )
                else if (_isValid)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: BatteColors.success,
                  )
                else if (_errorMessage != null)
                  const Icon(
                    Icons.error,
                    size: 16,
                    color: BatteColors.destructive,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isValidating
                        ? 'Vérification...'
                        : _isValid
                            ? 'Valide ✓'
                            : _errorMessage ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isValidating
                          ? BatteColors.mutedForeground
                          : _isValid
                              ? BatteColors.success
                              : BatteColors.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null && widget.onSuffixIconTap != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon),
        onPressed: widget.onSuffixIconTap,
      );
    }
    return null;
  }

  Color _getBorderColor() {
    if (_errorMessage != null) {
      return BatteColors.destructive;
    }
    if (_isValid) {
      return BatteColors.success;
    }
    return Colors.transparent;
  }
}

