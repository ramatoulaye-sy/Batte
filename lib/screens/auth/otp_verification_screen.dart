import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../services/voice_service.dart';
import '../home/home_screen.dart';

/// Écran de vérification OTP
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  
  const OtpVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);
  
  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _voiceService = VoiceService();
  
  int _countdown = 60;
  Timer? _timer;
  bool _canResend = false;
  
  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    _voiceService.speak('Entrez le code de vérification à 6 chiffres');
    _startCountdown();
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    _voiceService.dispose();
    super.dispose();
  }
  
  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }
  
  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      _showError('Veuillez entrer le code complet');
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(
      email: widget.email,
      otp: otp,
    );
    
    if (mounted) {
      if (success) {
        _voiceService.speak('Connexion réussie. Bienvenue sur Battè');
        
        // Naviguer vers l'écran d'accueil
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        final error = authProvider.error ?? 'Code invalide';
        _showError(error);
      }
    }
  }
  
  Future<void> _resendOtp() async {
    if (!_canResend) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendOtp(widget.email);
    
    if (mounted) {
      if (success) {
        _voiceService.speak('Un nouveau code a été envoyé');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code renvoyé avec succès'),
            backgroundColor: BatteColors.success,
          ),
        );
        _startCountdown();
        
        // Effacer les champs
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        final error = authProvider.error ?? 'Erreur d\'envoi du code';
        _showError(error);
      }
    }
  }
  
  void _showError(String message) {
    _voiceService.speak(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BatteColors.destructive,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BatteColors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Titre
              const Text(
                'Vérification',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Un code de vérification a été envoyé à\n${widget.email}',
                style: const TextStyle(
                  fontSize: 14,
                  color: BatteColors.mutedForeground,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Champs OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpField(index)),
              ),
              
              const SizedBox(height: 32),
              
              // Timer et bouton renvoyer
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: _resendOtp,
                        child: const Text(
                          'Renvoyer le code',
                          style: TextStyle(
                            color: BatteColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : Text(
                        'Renvoyer dans $_countdown secondes',
                        style: const TextStyle(
                          fontSize: 14,
                          color: BatteColors.mutedForeground,
                        ),
                      ),
              ),
              
              const Spacer(),
              
              // Bouton de vérification
              CustomButton(
                text: 'Vérifier',
                onPressed: _verifyOtp,
                isLoading: authProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: BatteColors.inputBackground,
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
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          } else if (value.isNotEmpty && index == 5) {
            // Auto-vérifier quand le dernier chiffre est entré
            _verifyOtp();
          }
        },
      ),
    );
  }
}

