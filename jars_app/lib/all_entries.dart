import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'theme_manager.dart';

class AllEntriesPage extends StatefulWidget {
  final List<Map<String, String>> diaryEntries;
  final String currentMood;
  final Color baseMoodColor;
  final ThemeManager themeManager;

  const AllEntriesPage({
    super.key,
    required this.diaryEntries,
    required this.currentMood,
    required this.baseMoodColor,
    required this.themeManager,
  });

  @override
  State<AllEntriesPage> createState() => _AllEntriesPageState();
}

class _AllEntriesPageState extends State<AllEntriesPage> {
  late List<Map<String, String>> _filteredEntries;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredEntries = List.from(widget.diaryEntries);
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return const Color(0xFFFFD166);
      case 'sad':
        return const Color(0xFF6A9AB0);
      case 'angry':
        return const Color(0xFFEF476F);
      case 'fear':
        return const Color(0xFF9C89B8);
      default:
        return const Color(0xFF6C757D);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEntries = widget.diaryEntries.where((entry) {
        // mood filter
        if (_selectedFilter != 'all' && 
            entry['emotion']?.toLowerCase() != _selectedFilter) {
          return false;
        }

        // search filter
        if (_searchQuery.isNotEmpty) {
          final text = entry['text']?.toLowerCase() ?? '';
          final emotion = entry['emotion']?.toLowerCase() ?? '';
          final date = entry['date']?.toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return text.contains(query) || 
                 emotion.contains(query) || 
                 date.contains(query);
        }

        return true;
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _applyFilters();
  }

  String _getFilterButtonText(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'happy':
        return '😊 Happy';
      case 'sad':
        return '😢 Sad';
      case 'angry':
        return '😠 Angry';
      case 'Fear':
        return '😰 Fear';
      case 'neutral':
        return '😌 Neutral';
      default:
        return filter;
    }
  }

  List<String> _getAvailableMoods() {
    final moods = <String>{'all'};
    for (var entry in widget.diaryEntries) {
      final mood = entry['emotion']?.toLowerCase();
      if (mood != null && mood.isNotEmpty) {
        moods.add(mood);
      }
    }
    return moods.toList();
  }

  Widget _buildStatsSummary() {
    final themeColor = widget.themeManager.getThemeColor(widget.baseMoodColor);
    final totalEntries = widget.diaryEntries.length;
    
    if (totalEntries == 0) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.note_add_rounded,
              size: 60,
              color: themeColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No entries yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start journaling to see your entries here',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    // Count entries by month
    final monthCounts = <String, int>{};
    for (var entry in widget.diaryEntries) {
      final dateString = entry['date'];
      if (dateString != null && dateString.length >= 7) {
        final month = dateString.substring(0, 7); // yyyy-MM
        monthCounts[month] = (monthCounts[month] ?? 0) + 1;
      }
    }

    final mostProductiveMonth = monthCounts.isNotEmpty
        ? monthCounts.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor.withOpacity(0.1),
            themeColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: themeColor),
              const SizedBox(width: 10),
              Text(
                'Journal Stats',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Entries',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalEntries',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Currently Showing',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_filteredEntries.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _filteredEntries.isEmpty ? Colors.grey : themeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (mostProductiveMonth != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: themeColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Productive Month',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(
                            DateTime.parse('${mostProductiveMonth.key}-01'),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${mostProductiveMonth.value} entries',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.themeManager.getThemeColor(widget.baseMoodColor);
    final textColor = widget.themeManager.getContrastingTextColor(themeColor);
    final availableMoods = _getAvailableMoods();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Journal Entries',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        backgroundColor: themeColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: _clearSearch,
              icon: Icon(Icons.clear, color: textColor),
            ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Search entries...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: themeColor,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: Icon(
                            Icons.clear_rounded,
                            color: themeColor,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: availableMoods.map((mood) {
                    final isSelected = _selectedFilter == mood;
                    final moodColor = mood == 'all'
                        ? themeColor
                        : widget.themeManager.getThemeColor(_getMoodColor(mood));
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = isSelected ? 'all' : mood;
                          });
                          _applyFilters();
                        },
                        label: Text(
                          _getFilterButtonText(mood),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selectedColor: moodColor,
                        backgroundColor: Colors.grey.shade100,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? moodColor : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            _buildStatsSummary(),

            Expanded(
              child: _filteredEntries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No entries found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try changing your search or filter',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilter = 'all';
                                _searchQuery = '';
                                _searchController.clear();
                                _filteredEntries = List.from(widget.diaryEntries);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Reset Filters',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: _filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _filteredEntries[index];
                        final baseEntryColor = _getMoodColor(entry['emotion'] ?? '');
                        final entryThemeColor = widget.themeManager.getThemeColor(baseEntryColor);
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            shadowColor: entryThemeColor.withOpacity(0.2),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              entryThemeColor.withOpacity(0.9),
                                              entryThemeColor.withOpacity(0.6),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            entry['emoji'] ?? '😌',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry['emotion'] ?? 'Neutral',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: entryThemeColor,
                                              ),
                                            ),
                                            Text(
                                              '${entry['date']} • ${entry['time'] ?? ''}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: entryThemeColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: entryThemeColor.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Text(
                                      entry['text'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: themeColor,
        foregroundColor: textColor,
        child: const Icon(Icons.arrow_back_rounded),
      ),
    );
  }
}