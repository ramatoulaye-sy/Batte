import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_button.dart';

/// Écran de sélection de méthode de retrait
class WithdrawalMethodsScreen extends StatefulWidget {
  const WithdrawalMethodsScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawalMethodsScreen> createState() => _WithdrawalMethodsScreenState();
}

class _WithdrawalMethodsScreenState extends State<WithdrawalMethodsScreen> {
  String? _selectedMethod;
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'orange_money',
      'name': 'Orange Money',
      'icon': Icons.phone_android,
      'color': Colors.orange,
      'minAmount': 5000.0,
      'maxAmount': 2000000.0,
      'fee': 0.01, // 1%
    },
    {
      'id': 'mtn_money',
      'name': 'MTN Mobile Money',
      'icon': Icons.phone_iphone,
      'color': Colors.yellow[700],
      'minAmount': 5000.0,
      'maxAmount': 2000000.0,
      'fee': 0.01,
    },
    {
      'id': 'moov_money',
      'name': 'Moov Money',
      'icon': Icons.smartphone,
      'color': Colors.blue,
      'minAmount': 5000.0,
      'maxAmount': 2000000.0,
      'fee': 0.01,
    },
    {
      'id': 'bank_transfer',
      'name': 'Virement bancaire',
      'icon': Icons.account_balance,
      'color': BatteColors.primary,
      'minAmount': 20000.0,
      'maxAmount': 10000000.0,
      'fee': 0.02, // 2%
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final balance = user?.balance ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirer mes gains'),
        backgroundColor: BatteColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Solde disponible
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [BatteColors.primary, BatteColors.success],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Solde disponible',
                      style: TextStyle(
                        color: BatteColors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      Helpers.formatCurrency(balance),
                      style: const TextStyle(
                        color: BatteColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sélection de la méthode
              const Text(
                'Choisissez votre méthode de retrait',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ..._methods.map((method) => _buildMethodCard(method)),

              const SizedBox(height: 24),

              // Formulaire si méthode sélectionnée
              if (_selectedMethod != null) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildWithdrawalForm(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    final color = method['color'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : BatteColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(method['icon'] as IconData, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : BatteColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Min: ${Helpers.formatCurrency(method['minAmount'])} - '
                    'Frais: ${(method['fee'] * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: BatteColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalForm() {
    final method = _methods.firstWhere((m) => m['id'] == _selectedMethod);
    final isMobileMoney = _selectedMethod != 'bank_transfer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails du retrait',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Montant
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Montant à retirer',
            hintText: 'Ex: 50000',
            prefixIcon: const Icon(Icons.payments_rounded),
            suffix: const Text('GNF'),
            filled: true,
            fillColor: BatteColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Montant requis';
            }
            final amount = double.tryParse(value);
            if (amount == null) {
              return 'Montant invalide';
            }
            if (amount < method['minAmount']) {
              return 'Minimum ${Helpers.formatCurrency(method['minAmount'])}';
            }
            final user = Provider.of<AuthProvider>(context, listen: false).user;
            if (amount > (user?.balance ?? 0)) {
              return 'Solde insuffisant';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Numéro de téléphone (Mobile Money) ou compte bancaire
        if (isMobileMoney)
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: '+224 XXX XX XX XX',
              prefixIcon: const Icon(Icons.phone),
              filled: true,
              fillColor: BatteColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Numéro requis';
              }
              return null;
            },
          )
        else
          TextFormField(
            controller: _accountController,
            decoration: InputDecoration(
              labelText: 'Numéro de compte bancaire',
              hintText: 'GN XXXX XXXX XXXX',
              prefixIcon: const Icon(Icons.account_balance),
              filled: true,
              fillColor: BatteColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Numéro de compte requis';
              }
              return null;
            },
          ),

        const SizedBox(height: 24),

        // Résumé
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BatteColors.muted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Montant demandé', _amountController.text.isNotEmpty
                  ? Helpers.formatCurrency(double.tryParse(_amountController.text) ?? 0)
                  : '0 GNF'),
              const Divider(),
              _buildSummaryRow(
                'Frais (${(method['fee'] * 100).toStringAsFixed(0)}%)',
                _amountController.text.isNotEmpty
                    ? Helpers.formatCurrency((double.tryParse(_amountController.text) ?? 0) * method['fee'])
                    : '0 GNF',
              ),
              const Divider(),
              _buildSummaryRow(
                'Vous recevrez',
                _amountController.text.isNotEmpty
                    ? Helpers.formatCurrency((double.tryParse(_amountController.text) ?? 0) * (1 - method['fee']))
                    : '0 GNF',
                isBold: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Bouton de soumission
        CustomButton(
          text: 'Confirmer le retrait',
          onPressed: _submitWithdrawal,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? BatteColors.primary : BatteColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final method = _methods.firstWhere((m) => m['id'] == _selectedMethod);
      final fee = amount * (method['fee'] as double);
      final netAmount = amount - fee;

      final isMobileMoney = _selectedMethod != 'bank_transfer';
      final recipient = isMobileMoney ? _phoneController.text : _accountController.text;

      // Créer la demande de retrait
      final result = await SupabaseService.processWithdrawal(
        amount: amount,
        description: 'Retrait via ${method['name']} - $recipient',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Retrait demandé avec succès !'),
            backgroundColor: BatteColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur : ${e.toString()}'),
            backgroundColor: BatteColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

