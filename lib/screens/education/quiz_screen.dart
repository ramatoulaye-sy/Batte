import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/education_content_model.dart';
import '../../providers/education_provider.dart';
import '../../widgets/custom_button.dart';

/// Écran de quiz
class QuizScreen extends StatefulWidget {
  final EducationContentModel content;
  
  const QuizScreen({Key? key, required this.content}) : super(key: key);
  
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic>? _quizData;
  final Map<String, dynamic> _answers = {};
  bool _isLoading = false;
  bool _isSubmitted = false;
  int? _score;
  
  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }
  
  Future<void> _loadQuiz() async {
    setState(() => _isLoading = true);
    
    final provider = Provider.of<EducationProvider>(context, listen: false);
    final data = await provider.getQuiz(widget.content.id);
    
    setState(() {
      _quizData = data;
      _isLoading = false;
    });
  }
  
  Future<void> _submitQuiz() async {
    setState(() => _isLoading = true);
    
    final provider = Provider.of<EducationProvider>(context, listen: false);
    final result = await provider.submitQuiz(widget.content.id, _answers);
    
    setState(() {
      _isSubmitted = true;
      _score = result?['score'] as int?;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.title),
        backgroundColor: BatteColors.purple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSubmitted
              ? _buildResultScreen()
              : _buildQuizScreen(),
    );
  }
  
  Widget _buildQuizScreen() {
    if (_quizData == null) {
      return const Center(child: Text('Erreur de chargement'));
    }
    
    final questions = _quizData!['questions'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value as Map<String, dynamic>;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BatteColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: BatteColors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question['question'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(question['options'] as List<dynamic>).map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _answers[question['id']],
                      activeColor: BatteColors.purple,
                      onChanged: (value) {
                        setState(() {
                          _answers[question['id']] = value;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          CustomButton(
            text: 'Soumettre',
            onPressed: _answers.length == questions.length
                ? _submitQuiz
                : null,
            backgroundColor: BatteColors.purple,
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: BatteColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: BatteColors.success,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz terminé !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: ${_score ?? 0}/100',
              style: const TextStyle(
                fontSize: 24,
                color: BatteColors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+${widget.content.points} points',
              style: const TextStyle(
                fontSize: 20,
                color: BatteColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'Retour',
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: BatteColors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

