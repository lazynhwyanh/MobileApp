import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlashcardReviewPage extends StatefulWidget {
  final List<Map<String, dynamic>> flashcards;

  const FlashcardReviewPage({super.key, required this.flashcards});

  @override
  State<FlashcardReviewPage> createState() => _FlashcardReviewPageState();
}

class _FlashcardReviewPageState extends State<FlashcardReviewPage> {
  late List<Map<String, dynamic>> flashcards;
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    flashcards = List.from(widget.flashcards);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _shuffleCards() {
    setState(() {
      flashcards.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ôn tập flashcard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Đảo ngẫu nhiên',
            onPressed: _shuffleCards,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: flashcards.length,
        onPageChanged: (index) => setState(() => currentIndex = index),
        itemBuilder: (context, index) {
          final card = flashcards[index];

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FlipCard(
                front: FlashCardFace(
                  text: card['word'] ?? '',
                  color: Colors.indigo.shade200,
                ),
                back: FlashCardFace(
                  text:
                      '${card['meaning'] ?? ''}\n\n[${card['phonetic'] ?? ''}]',
                  color: Colors.orange.shade100,
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Thẻ ${currentIndex + 1} / ${flashcards.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class FlashCardFace extends StatelessWidget {
  final String text;
  final Color color;

  const FlashCardFace({required this.text, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
