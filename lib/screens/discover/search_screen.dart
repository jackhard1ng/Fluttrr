import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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

  String _query = '';
  SearchTab _activeTab = SearchTab.events;
  final List<String> _recentSearches = ['Board games', 'Coffee meetup', 'Hiking'];

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
                              decoration: InputDecoration(
                                hintText: 'Search events, people, places...',
                                hintStyle: TextStyle(color: AppColors.mediumGrey),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() => _query = value);
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
    // Mock results - in real app would fetch from API
    return const Center(
      child: NoResultsState(),
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
