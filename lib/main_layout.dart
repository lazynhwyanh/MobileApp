import 'package:flutter/material.dart';
import 'pages/exercise_level_selector.dart';
import 'pages/dictionary_page.dart';
import 'pages/flashcard_page.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ExerciseLevelSelector(), // ✨ Trang chọn level
    DictionaryPage(),
    PlaceholderWidget(title: 'Đọc hiểu'),
    FlashcardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nihongo App'), centerTitle: true),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Bài tập'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Từ điển'),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'Đọc hiểu',
          ),
          NavigationDestination(
            icon: Icon(Icons.style),
            label: 'Flashcard',
          ), // 👈
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title - đang phát triển',
        style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
      ),
    );
  }
}
