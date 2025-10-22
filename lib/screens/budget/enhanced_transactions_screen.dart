import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/budget_provider.dart';
import '../../models/transaction_model.dart';

/// Écran d'historique amélioré avec filtres et recherche
class EnhancedTransactionsScreen extends StatefulWidget {
  const EnhancedTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedTransactionsScreen> createState() => _EnhancedTransactionsScreenState();
}

class _EnhancedTransactionsScreenState extends State<EnhancedTransactionsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'all'; // all, recycling, withdrawal
  DateTimeRange? _dateRange;
  String _sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> transactions) {
    var filtered = transactions;

    // Filtre par type
    if (_selectedType != 'all') {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }

    // Filtre par date
    if (_dateRange != null) {
      filtered = filtered.where((t) {
        return t.date.isAfter(_dateRange!.start) &&
            t.date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final query = _searchQuery.toLowerCase();
        return (t.description ?? '').toLowerCase().contains(query) ||
            (t.type ?? '').toLowerCase().contains(query);
      }).toList();
    }

    // Tri
    switch (_sortBy) {
      case 'date_desc':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        filtered.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
        break;
      case 'amount_asc':
        filtered.sort((a, b) => a.amount.abs().compareTo(b.amount.abs()));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final filteredTransactions = _getFilteredTransactions(budgetProvider.transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des transactions'),
        backgroundColor: BatteColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportTransactions,
            tooltip: 'Exporter en PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher une transaction...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: BatteColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  'Toutes',
                  _selectedType == 'all',
                  () => setState(() => _selectedType = 'all'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Recyclage',
                  _selectedType == 'recycling',
                  () => setState(() => _selectedType = 'recycling'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Retraits',
                  _selectedType == 'withdrawal',
                  () => setState(() => _selectedType = 'withdrawal'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _dateRange != null
                        ? 'Du ${Helpers.formatDate(_dateRange!.start)} au ${Helpers.formatDate(_dateRange!.end)}'
                        : 'Période',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _dateRange != null
                        ? BatteColors.primary
                        : BatteColors.mutedForeground,
                    side: BorderSide(
                      color: _dateRange != null
                          ? BatteColors.primary
                          : BatteColors.border,
                    ),
                  ),
                ),
                if (_dateRange != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => setState(() => _dateRange = null),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Trier par : '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'date_desc', child: Text('Plus récent')),
                    DropdownMenuItem(value: 'date_asc', child: Text('Plus ancien')),
                    DropdownMenuItem(value: 'amount_desc', child: Text('Montant ↓')),
                    DropdownMenuItem(value: 'amount_asc', child: Text('Montant ↑')),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
                const Spacer(),
                Text(
                  '${filteredTransactions.length} résultat(s)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: BatteColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Liste des transactions
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(
                    child: Text('Aucune transaction trouvée'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: BatteColors.muted,
      selectedColor: BatteColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: selected ? BatteColors.primary : BatteColors.foreground,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: BatteColors.primary,
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isPositive = transaction.amount >= 0;
    final color = isPositive ? BatteColors.success : BatteColors.destructive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            transaction.type == 'recycling' ? Icons.recycling : Icons.account_balance_wallet,
            color: color,
          ),
        ),
        title: Text(
          transaction.description ?? 'Transaction',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          Helpers.formatDate(transaction.date),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          '${isPositive ? '+' : ''}${Helpers.formatCurrency(transaction.amount)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: BatteColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _exportTransactions() async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final filtered = _getFilteredTransactions(budgetProvider.transactions);

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune transaction à exporter')),
      );
      return;
    }

    // TODO: Implémenter export PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export de ${filtered.length} transaction(s) - À venir'),
        backgroundColor: BatteColors.primary,
      ),
    );
  }
}

