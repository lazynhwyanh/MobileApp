import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../pages/flashcard_review_page.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  List<Map<String, dynamic>> flashcards = [];
  bool isReviewMode = false;
  Set<int> flippedCards = {};
  int currentPage = 0;
  static const int pageSize = 50;

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'flashcards.db');
    return openDatabase(path);
  }

  Future<void> _loadFlashcards() async {
    final db = await _initDb();
    final cards = await db.query('flashcards', orderBy: 'addedAt DESC');

    setState(() {
      flashcards = cards;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  @override
  Widget build(BuildContext context) {
    final pagedFlashcards =
        flashcards.skip(currentPage * pageSize).take(pageSize).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed:
                flashcards.isEmpty
                    ? null
                    : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => FlashcardReviewPage(
                                flashcards: [...flashcards],
                              ),
                        ),
                      );
                    },
            icon: const Icon(Icons.play_circle_fill),
            label: const Text('Bắt đầu ôn tập'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pagedFlashcards.length,
            itemBuilder: (context, index) {
              final card = pagedFlashcards[index];
              final isFlipped = flippedCards.contains(index);

              if (!isReviewMode) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BÊN TRÁI
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Word + phonetic bên phải
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    card['word'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if ((card['phonetic'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Text(
                                      card['phonetic'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(card['meaning']),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // BÊN PHẢI: ICONS
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              tooltip: 'Chỉnh sửa',
                              onPressed: () async {
                                final updated =
                                    await showDialog<Map<String, dynamic>>(
                                      context: context,
                                      builder:
                                          (_) =>
                                              EditFlashcardDialog(data: card),
                                    );
                                if (updated != null) {
                                  final db = await _initDb();
                                  await db.update(
                                    'flashcards',
                                    updated,
                                    where: 'word = ?',
                                    whereArgs: [card['word']],
                                  );
                                  _loadFlashcards();
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              tooltip: 'Xoá',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text('Xác nhận xoá'),
                                        content: Text(
                                          'Xoá \"${card['word']}\" khỏi flashcard?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text('Xoá'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  final db = await _initDb();
                                  await db.delete(
                                    'flashcards',
                                    where: 'word = ?',
                                    whereArgs: [card['word']],
                                  );
                                  _loadFlashcards();
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isFlipped) {
                        flippedCards.remove(index);
                      } else {
                        flippedCards.add(index);
                      }
                    });
                  },
                  child: Card(
                    elevation: 4,
                    color: Colors.indigo.shade50,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isFlipped
                            ? '${card['meaning']} (${card['phonetic'] ?? ''})'
                            : card['word'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        if (flashcards.length > pageSize)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      currentPage > 0
                          ? () => setState(() => currentPage--)
                          : null,
                ),
                Text(
                  'Trang ${currentPage + 1} / ${((flashcards.length - 1) / pageSize).ceil() + 1}',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed:
                      (currentPage + 1) * pageSize < flashcards.length
                          ? () => setState(() => currentPage++)
                          : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class EditFlashcardDialog extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditFlashcardDialog({super.key, required this.data});

  @override
  State<EditFlashcardDialog> createState() => _EditFlashcardDialogState();
}

class _EditFlashcardDialogState extends State<EditFlashcardDialog> {
  late TextEditingController wordCtrl;
  late TextEditingController meaningCtrl;
  late TextEditingController phoneticCtrl;

  @override
  void initState() {
    super.initState();
    wordCtrl = TextEditingController(text: widget.data['word']);
    meaningCtrl = TextEditingController(text: widget.data['meaning']);
    phoneticCtrl = TextEditingController(text: widget.data['phonetic'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa flashcard'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: wordCtrl,
            decoration: const InputDecoration(labelText: 'Từ'),
          ),
          TextField(
            controller: meaningCtrl,
            decoration: const InputDecoration(labelText: 'Nghĩa'),
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          TextField(
            controller: phoneticCtrl,
            decoration: const InputDecoration(labelText: 'Cách đọc'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'word': wordCtrl.text,
              'meaning': meaningCtrl.text,
              'phonetic': phoneticCtrl.text,
              'addedAt': widget.data['addedAt'],
            });
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
