import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../constants/utils.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/empty_states.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  /// Maximum allowed search query length
  static const int _maxQueryLength = 100;

  String _query = '';
  SearchTab _activeTab = SearchTab.events;
  final List<String> _recentSearches = ['Board games', 'Coffee meetup', 'Hiking'];

  /// Sanitize search input to prevent injection attacks
  String _sanitizeQuery(String input) {
    if (input.isEmpty) return '';

    // Remove potentially dangerous characters
    final sanitized = input
        .replaceAll(RegExp(r'[<>"\x27%\\]'), '') // Remove <, >, ", ', %, \
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();

    // Limit length
    return sanitized.substring(0, min(sanitized.length, _maxQueryLength));
  }

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withAlpha(128),
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.mediumGrey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              maxLength: _maxQueryLength,
                              decoration: InputDecoration(
                                hintText: 'Search events, people, places...',
                                hintStyle: TextStyle(color: AppColors.mediumGrey),
                                border: InputBorder.none,
                                counterText: '', // Hide character counter
                              ),
                              onChanged: (value) {
                                setState(() => _query = _sanitizeQuery(value));
                              },
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              child: Icon(Icons.close, color: AppColors.mediumGrey, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: SearchTab.values.map((tab) {
                  final isActive = _activeTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _activeTab = tab);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isActive ? AppColors.primaryBlue : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          tab.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? AppColors.primaryBlue : AppColors.mediumGrey,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: _query.isEmpty ? _buildSuggestions() : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _recentSearches.clear());
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    setState(() => _query = search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withAlpha(128),
                      borderRadius: BorderRadius.circular(AppRadius.circular),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 16, color: AppColors.mediumGrey),
                        const SizedBox(width: 8),
                        Text(search),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular categories
          Text(
            'Popular Categories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EventCategory.values.take(8).map((cat) {
              return CategoryChip(
                category: cat,
                onTap: () {
                  _searchController.text = cat.label;
                  setState(() => _query = cat.label);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Trending
          Text(
            'Trending Now',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          ...['Friday Night Games', 'Weekend Hikes', 'Coffee & Chat'].map((trend) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.friendlyOrange.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text('🔥'),
              ),
              title: Text(trend),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.mediumGrey),
              onTap: () {
                _searchController.text = trend;
                setState(() => _query = trend);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResults() {
    // Filter results based on query and active tab
    final results = _getFilteredResults();

    if (results.isEmpty) {
      return const Center(
        child: NoResultsState(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _SearchResultItem(
          result: result,
          onTap: () {
            HapticFeedback.lightImpact();
            // Add to recent searches if not already there
            if (!_recentSearches.contains(_query)) {
              setState(() {
                _recentSearches.insert(0, _query);
                if (_recentSearches.length > 5) {
                  _recentSearches.removeLast();
                }
              });
            }
            // Navigate based on result type
            _navigateToResult(result);
          },
        );
      },
    );
  }

  List<_SearchResult> _getFilteredResults() {
    final queryLower = _query.toLowerCase();

    // Mock data - in real app would fetch from API
    final List<_SearchResult> allEvents = [
      _SearchResult(
        type: SearchTab.events,
        title: 'Friday Night Board Games',
        subtitle: 'The Game Parlor • Tomorrow, 7 PM',
        icon: Icons.casino,
      ),
      _SearchResult(
        type: SearchTab.events,
        title: 'Coffee & Chat Morning',
        subtitle: 'The Roastery • Saturday, 10 AM',
        icon: Icons.coffee,
      ),
      _SearchResult(
        type: SearchTab.events,
        title: 'Weekend Hiking Group',
        subtitle: 'Mountain Trail Park • Sunday, 8 AM',
        icon: Icons.hiking,
      ),
      _SearchResult(
        type: SearchTab.events,
        title: 'Yoga in the Park',
        subtitle: 'Central Park • Daily, 6 AM',
        icon: Icons.self_improvement,
      ),
      _SearchResult(
        type: SearchTab.events,
        title: 'Photography Walk',
        subtitle: 'Downtown • This Saturday, 3 PM',
        icon: Icons.camera_alt,
      ),
    ];

    final List<_SearchResult> allPeople = [
      _SearchResult(
        type: SearchTab.people,
        title: 'Sarah Mitchell',
        subtitle: 'Loves hiking and photography',
        icon: Icons.person,
      ),
      _SearchResult(
        type: SearchTab.people,
        title: 'Mike Johnson',
        subtitle: 'Board game enthusiast',
        icon: Icons.person,
      ),
      _SearchResult(
        type: SearchTab.people,
        title: 'Jordan Lee',
        subtitle: 'Coffee lover, yoga practitioner',
        icon: Icons.person,
      ),
    ];

    final List<_SearchResult> allPlaces = [
      _SearchResult(
        type: SearchTab.places,
        title: 'The Game Parlor',
        subtitle: 'Board game cafe • 0.5 miles away',
        icon: Icons.store,
      ),
      _SearchResult(
        type: SearchTab.places,
        title: 'The Roastery',
        subtitle: 'Coffee shop • 0.3 miles away',
        icon: Icons.store,
      ),
      _SearchResult(
        type: SearchTab.places,
        title: 'Mountain Trail Park',
        subtitle: 'Outdoor area • 5 miles away',
        icon: Icons.park,
      ),
      _SearchResult(
        type: SearchTab.places,
        title: 'Central Park',
        subtitle: 'Public park • 1.2 miles away',
        icon: Icons.park,
      ),
    ];

    List<_SearchResult> results;
    switch (_activeTab) {
      case SearchTab.events:
        results = allEvents;
        break;
      case SearchTab.people:
        results = allPeople;
        break;
      case SearchTab.places:
        results = allPlaces;
        break;
    }

    // Filter by query
    return results.where((result) {
      return result.title.toLowerCase().contains(queryLower) ||
          result.subtitle.toLowerCase().contains(queryLower);
    }).toList();
  }

  void _navigateToResult(_SearchResult result) {
    switch (result.type) {
      case SearchTab.events:
        Nav.toDiscover();
        break;
      case SearchTab.people:
        Nav.toChatList();
        break;
      case SearchTab.places:
        Nav.toDiscover();
        break;
    }
  }
}

class _SearchResult {
  final SearchTab type;
  final String title;
  final String subtitle;
  final IconData icon;

  _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _SearchResultItem extends StatelessWidget {
  final _SearchResult result;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.lightGrey.withAlpha(128),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                result.icon,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.subtitle,
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
}

enum SearchTab {
  events('Events'),
  people('People'),
  places('Places');

  final String label;
  const SearchTab(this.label);
}
