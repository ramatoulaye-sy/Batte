import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/batte_logo.dart';
import '../../widgets/animated_form_reveal.dart';
import '../../services/voice_service.dart';
import '../../services/supabase_service.dart';
import 'collector_signup_screen.dart';
// OTP screen non utilisé dans le flux email+mot de passe

/// Écran de connexion
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _voiceService = VoiceService();
  
  bool _isSignup = false;
  bool _voiceEnabled = false;
  bool _obscurePassword = true;
  String? _signupType; // null au départ, puis 'user' ou 'collector' après sélection
  
  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _voiceService.dispose();
    super.dispose();
  }
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    bool success;
    if (_isSignup) {
      success = await authProvider.signup(
        email: email,
        password: password,
        name: _nameController.text.trim(),
      );
    } else {
      success = await authProvider.login(email, password);
    }
    
    if (mounted) {
      if (success) {
        // Pour le signup, se connecter automatiquement après inscription
        if (_isSignup) {
          if (_voiceEnabled) {
            await _voiceService.speak('Inscription réussie ! Connexion en cours...');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie ! Connexion en cours...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Attendre 1 seconde puis se connecter automatiquement
          await Future.delayed(const Duration(seconds: 1));
          
          // Se connecter avec les mêmes identifiants
          final loginSuccess = await authProvider.login(email, password);
          
          if (!loginSuccess) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connectez-vous maintenant avec vos identifiants'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          
          // Créer le profil selon le choix
          if (_signupType == 'collector') {
            // Inscription collecteur → Formulaire collecteur
            await SupabaseService.createProfile('collector');
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const CollectorSignupScreen(isFromSignup: true),
                ),
              );
            }
            return;
          } else {
            // Inscription utilisateur → Home
            await SupabaseService.createProfile('user');
            if (mounted) {
              if (_voiceEnabled) {
                await _voiceService.speak('Connexion réussie');
              }
              Navigator.of(context).pushReplacementNamed('/home');
            }
            return;
          }
        }
        
        // Login (pas signup) → Vérifier le profil et rediriger
        if (authProvider.isAuthenticated && mounted) {
          if (_voiceEnabled) {
            await _voiceService.speak('Connexion réussie');
          }
          
          // Vérifier le type de profil de l'utilisateur
          final profiles = await SupabaseService.getUserProfiles();
          
          if (profiles.contains('collector') && mounted) {
            // Collecteur → Dashboard collecteur
            Navigator.of(context).pushReplacementNamed('/collector-dashboard');
          } else if (mounted) {
            // Utilisateur → Home
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      } else {
        // Afficher l'erreur
        final error = authProvider.error ?? 'Une erreur s\'est produite';
        
        if (_voiceEnabled) {
          await _voiceService.speak(error);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: BatteColors.destructive,
          ),
        );
      }
    }
  }
  
  void _toggleMode() {
    setState(() {
      _isSignup = !_isSignup;
      _signupType = null; // Réinitialiser le type lors du basculement
    });
  }
  
  void _toggleVoice() {
    setState(() {
      _voiceEnabled = !_voiceEnabled;
    });
    
    if (_voiceEnabled) {
      _voiceService.speak(
        _isSignup
            ? 'Inscription. Entrez votre numéro de téléphone et votre nom'
            : 'Connexion. Entrez votre numéro de téléphone',
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // Logo et titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: BatteColors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: BatteColors.primary.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: BatteLogoMedium(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Battè',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignup ? 'Créez votre compte' : 'Bienvenue !',
                        style: const TextStyle(
                          fontSize: 16,
                          color: BatteColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Bouton d'activation vocale
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Assistance vocale',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _voiceEnabled,
                      onChanged: (_) => _toggleVoice(),
                      activeColor: BatteColors.primary,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Choix du type d'inscription (EN PREMIER)
                if (_isSignup) ...[
                  Text(
                    'Je m\'inscris en tant que',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BatteColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _signupType = 'user'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _signupType == 'user'
                                  ? BatteColors.primary.withOpacity(0.1)
                                  : BatteColors.muted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _signupType == 'user'
                                    ? BatteColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.recycling,
                                  color: _signupType == 'user'
                                      ? BatteColors.primary
                                      : BatteColors.mutedForeground,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Utilisateur',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _signupType == 'user'
                                        ? BatteColors.primary
                                        : BatteColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Je recycle',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _signupType == 'user'
                                        ? BatteColors.foreground
                                        : BatteColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _signupType = 'collector'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _signupType == 'collector'
                                  ? BatteColors.secondary.withOpacity(0.1)
                                  : BatteColors.muted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _signupType == 'collector'
                                    ? BatteColors.secondary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_shipping,
                                  color: _signupType == 'collector'
                                      ? BatteColors.secondary
                                      : BatteColors.mutedForeground,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Collecteur',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _signupType == 'collector'
                                        ? BatteColors.secondary
                                        : BatteColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Je collecte',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _signupType == 'collector'
                                        ? BatteColors.foreground
                                        : BatteColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Afficher les champs SEULEMENT si un type est sélectionné (avec animation)
                  AnimatedFormReveal(
                    show: _signupType != null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        
                        // Titre du formulaire selon le type
                        Text(
                          _signupType == 'user' 
                            ? '📝 Inscription Utilisateur' 
                            : '🚚 Inscription Collecteur',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: BatteColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Champ nom
                        CustomTextField(
                          label: 'Nom complet',
                          hint: 'Entrez votre nom',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                          validator: Validators.validateName,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
                
                // Champs email et mot de passe (uniquement si type sélectionné en mode signup, ou si mode login)
                if (!_isSignup || _signupType != null) ...[
                
                // Champ email
                CustomTextField(
                  label: 'Email',
                  hint: 'exemple@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ),
                
                const SizedBox(height: 16),
                
                // Champ mot de passe
                CustomTextField(
                  label: 'Mot de passe',
                  hint: 'Minimum 6 caractères',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  onSuffixIconTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                
                  const SizedBox(height: 20),
                ],
                
                // Bouton de soumission (visible seulement si login OU (signup ET type sélectionné))
                if (!_isSignup || _signupType != null)
                  CustomButton(
                    text: _isSignup ? 'S\'inscrire' : 'Se connecter',
                    onPressed: _submit,
                    isLoading: authProvider.isLoading,
                  ),
                
                const SizedBox(height: 12),
                
                // Lien pour basculer entre connexion et inscription
                Center(
                  child: TextButton(
                    onPressed: _toggleMode,
                    child: Text(
                      _isSignup
                          ? 'Vous avez déjà un compte ? Connectez-vous'
                          : 'Pas encore de compte ? Inscrivez-vous',
                      style: const TextStyle(
                        color: BatteColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Langues supportées
                const Text(
                  'Langues disponibles : Français, Soussou, Peulh, Malinké',
                  style: TextStyle(
                    fontSize: 12,
                    color: BatteColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

