import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/dictionary_db.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  // 1. State variables
  String input = '';
  Map<String, dynamic>? meaning;
  bool loading = false;
  bool isSaved = false;
  // 2. Business logic
  Future<void> _lookup() async {
    if (input.trim().isEmpty) return;

    setState(() {
      loading = true;
      meaning = null;
    });

    final result = await searchWord(input.trim());

    setState(() {
      loading = false;
      meaning = result;
    });
  }

  String _parseField(dynamic content) {
    if (content == null || content.toString().trim().isEmpty) {
      return ' ';
    }

    try {
      // Nếu content không phải String, toString nó trước
      final decoded = jsonDecode(content.toString());

      if (decoded is List) {
        return decoded.join(', ');
      } else if (decoded is Map && decoded.containsKey('word')) {
        return (decoded['word'] as List).join(', ');
      }
      return decoded.toString();
    } catch (e) {
      // Nếu content không phải JSON thì trả lại raw text
      return content.toString();
    }
  }

  String _formatMeanField(dynamic meanField) {
    if (meanField is List) {
      return meanField
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .join('\n');
    }
    return meanField?.toString() ?? '';
  }

  List<String> _parseSynsetsWords(dynamic content) {
    if (content == null || content.toString().trim().isEmpty) return [];

    try {
      final List<dynamic> synsets = jsonDecode(content.toString());
      final words = <String>[];

      for (var group in synsets) {
        final entries = group['entry'] as List<dynamic>?;
        if (entries == null) continue;

        for (var entry in entries) {
          final synonyms = entry['synonym'] as List<dynamic>?;
          if (synonyms == null) continue;

          words.addAll(synonyms.map((e) => e.toString()));
        }
      }

      return words;
    } catch (_) {
      return [];
    }
  }

  List<String> _extractWords(dynamic content) {
    if (content == null || content.toString().trim().isEmpty) return [];

    try {
      final raw = content.toString().trim();

      // ✅ Kiểm tra định dạng trước khi decode
      if (!(raw.startsWith('[') || raw.startsWith('{'))) return [];

      final decoded = jsonDecode(raw);

      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      } else if (decoded is Map && decoded.containsKey('word')) {
        return (decoded['word'] as List).map((e) => e.toString()).toList();
      }
    } catch (_) {
      // có thể log lỗi ở đây nếu cần
    }

    return [];
  }

  void _saveToFlashcard(Map<String, dynamic> wordData) {
    print('Đã lưu từ: ${wordData['base']}');
    // TODO: Sau này lưu vào local storage (Hive, SharedPreferences...)
  }

  // 3. UI helpers
  Widget _buildWordLinks(List<String> words) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          words.map((word) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  input = word;
                });
                _lookup(); // gọi lại tra cứu
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  word,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 63, 81, 181),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCombinedDefinitionCard(Map<String, dynamic> data) {
    List<Map<String, dynamic>> fields = [
      {
        'icon': Icons.translate,
        'title': 'Nghĩa',
        'value': _formatMeanField(data['mean']), // ép về String
      },
      {
        'icon': Icons.record_voice_over,
        'title': 'Cách đọc',
        'value': data['phonetic']?.toString() ?? '',
      },
      {
        'icon': Icons.sync_alt,
        'title': 'Trái nghĩa',
        'value': _parseField(data['opposite']),
      },
      {
        'icon': Icons.link,
        'title': 'Đồng nghĩa',
        'valueWidget': _buildWordLinks(_parseSynsetsWords(data['synsets'])),
      },
      {
        'icon': Icons.scatter_plot,
        'title': 'Liên quan',
        'valueWidget': _buildWordLinks(_extractWords(data['related'])),
      },
    ];

    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👇 Từ khóa
                Text(
                  data['base'] ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 12),

                // 👇 Các trường như Nghĩa, Cách đọc, v.v.
                ...fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(field['icon'], size: 20, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              field.containsKey('valueWidget')
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${field['title']}:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      field['valueWidget'],
                                    ],
                                  )
                                  : RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '${field['title']}:\n',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: field['value']),
                                      ],
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        // 👇 ICON LƯU FLASHCARD
        Positioned(
          top: 12,
          right: 12,
          child: IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color:
                  isSaved
                      ? const Color.fromARGB(
                        255,
                        63,
                        81,
                        181,
                      ) // vàng olive nổi bật
                      : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                isSaved = !isSaved;
                if (isSaved) {
                  _saveToFlashcard(data); // bạn có thể viết hàm lưu sau
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu vào flashcard')),
                  );
                }
              });
            },
          ),
        ),
      ],
    );
  }

  // 4. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Từ điển Nhật - Việt'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => input = value,
              onSubmitted: (_) => _lookup(),
              decoration: InputDecoration(
                hintText: 'Nhập từ tiếng Nhật...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _lookup,
              icon: const Icon(Icons.translate),
              label: const Text('Tra nghĩa'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: CircularProgressIndicator(),
              )
            else if (meaning != null)
              Expanded(
                child: SingleChildScrollView(
                  child: _buildCombinedDefinitionCard(meaning!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
