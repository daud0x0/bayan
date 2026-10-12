import 'package:flutter/material.dart';
import '../../hadith/views/hadith_index_view.dart';
import '../../quran/views/quran_index_view.dart';

/// Combined Read screen hosting the Holy Quran and Hadith library.
/// Complies with Section 4.2 of the Product Plan.
class ReadView extends StatefulWidget {
  const ReadView({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<ReadView> createState() => _ReadViewState();
}

class _ReadViewState extends State<ReadView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              icon: Icon(Icons.menu_book_rounded, size: 20),
              text: 'Holy Quran',
            ),
            Tab(
              icon: Icon(Icons.auto_stories_rounded, size: 20),
              text: 'Hadith Collections',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          QuranIndexView(showAppBar: false),
          HadithIndexView(showAppBar: false),
        ],
      ),
    );
  }
}
