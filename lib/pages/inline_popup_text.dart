import 'package:flutter/material.dart';
import '../data/dictionary_db.dart';
import '../data/flashcard_db.dart';
import 'package:translator/translator.dart';

class InlinePopupSelectableText extends StatefulWidget {
  final String text;
  const InlinePopupSelectableText({super.key, required this.text});

  @override
  State<InlinePopupSelectableText> createState() =>
      _InlinePopupSelectableTextState();
}

class _InlinePopupSelectableTextState extends State<InlinePopupSelectableText> {
  final GlobalKey _textKey = GlobalKey();
  OverlayEntry? _popupEntry;
  bool isSaved = false;

  Future<String> _translateWithGoogle(String text) async {
    final translator = GoogleTranslator();
    final translation = await translator.translate(text, from: 'ja', to: 'vi');
    return translation.text;
  }

  void _showPopup(String selectedWord, Offset offset) async {
    final result = await searchWord(selectedWord);
    Map<String, dynamic> wordData;

    if (result != null) {
      wordData = result;
    } else {
      final fallbackMeaning = await _translateWithGoogle(selectedWord);
      wordData = {
        'base': selectedWord,
        'mean': [fallbackMeaning],
        'phonetic': '',
        'opposite': '',
        'synsets': '',
        'related': '',
      };
    }

    final exists = await isWordInFlashcard(selectedWord);
    setState(() {
      isSaved = exists;
    });

    _removePopup();
    _popupEntry = OverlayEntry(
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Positioned(
                  left: offset.dx,
                  top: offset.dy + 30,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedWord,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isSaved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      size: 22,
                                      color:
                                          isSaved ? Colors.amber : Colors.grey,
                                    ),
                                    tooltip: 'Lưu vào flashcard',
                                    onPressed: () async {
                                      setState(() {
                                        isSaved = !isSaved;
                                      });

                                      if (isSaved) {
                                        await saveFlashcard(wordData);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '$selectedWord đã được lưu vào flashcard',
                                            ),
                                          ),
                                        );
                                      } else {
                                        await deleteFlashcard(selectedWord);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '$selectedWord đã được xóa khỏi flashcard',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: _removePopup,
                                    child: const Icon(Icons.close, size: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(wordData['mean'].join('\n')),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );

    Overlay.of(context, rootOverlay: true).insert(_popupEntry!);
  }

  void _removePopup() {
    _popupEntry?.remove();
    _popupEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _removePopup,
      child: SelectionArea(
        child: SelectableText.rich(
          TextSpan(
            text: widget.text,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          key: _textKey,
          onSelectionChanged: (selection, cause) async {
            if (cause == SelectionChangedCause.longPress ||
                cause == SelectionChangedCause.tap) {
              final start = selection.start;
              final end = selection.end;
              if (start >= 0 && end > start) {
                final selected = widget.text.substring(start, end);

                final renderBox =
                    _textKey.currentContext?.findRenderObject() as RenderBox?;
                final offset = renderBox?.localToGlobal(Offset.zero);
                if (offset != null) {
                  _showPopup(selected, offset);
                }
              }
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removePopup();
    super.dispose();
  }
}
