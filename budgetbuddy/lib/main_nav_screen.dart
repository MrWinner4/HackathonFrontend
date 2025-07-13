import 'package:budgetbuddy/screens/lessons/lessons.dart';
import 'package:budgetbuddy/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'screens/home/homescreen.dart';
import 'screens/chatbot/chatbot.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({Key? key}) : super(key: key);

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(
        onNavigateToChat: _goToChat,
        onNavigateToLessons: _goToLessons,
      ),
      const ChatbotPage(),
      const LessonsScreen(),
      const ProfileScreen(),
    ];
  }

  void _goToHome() {
    setState(() => _selectedIndex = 0); // Example: 1 = Lessons tab
  }

  void _goToChat() {
    setState(() => _selectedIndex = 1); // Example: 2 = Chat tab
  }

  void _goToLessons() {
    setState(() => _selectedIndex = 2); // Example: 1 = Lessons tab
  }

  void _goToSettings() {
    setState(() => _selectedIndex = 3); // Example: 3 = Progress tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.15),
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarIcon(
                    icon: Icons.home_rounded,
                    selected: _selectedIndex == 0,
                    onTap: _goToHome),
                _NavBarIcon(
                    icon: Icons.smart_toy_rounded,
                    selected: _selectedIndex == 1,
                    onTap: _goToChat),
                _NavBarIcon(
                    icon: Icons.menu_book_rounded,
                    selected: _selectedIndex == 2,
                    onTap: _goToLessons),
                _NavBarIcon(
                    icon: Icons.settings_rounded,
                    selected: _selectedIndex == 3,
                    onTap: _goToSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _NavBarIcon(
      {required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Icon(
          icon,
          size: selected ? 30 : 26,
          color: selected ? accent : Colors.grey[400],
        ),
      ),
    );
  }
}
