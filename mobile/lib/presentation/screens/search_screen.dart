import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../data/models/place_model.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/search_widgets/category_buttons.dart';
import '../widgets/search_widgets/search_result_tile.dart';
import '../widgets/common/app_bottom_sheet.dart';

/// Full-screen search interface.
///
/// Features:
/// - Autocomplete search with 400ms debounce
/// - Category shortcuts (Petrol, Mosque, Hospital…)
/// - Recent searches
/// - Tap a result to set it as the navigation destination
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      ref.read(searchProvider.notifier).clearResults();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final pos = ref.read(locationProvider).position;
      ref.read(searchProvider.notifier).search(
            value,
            lat: pos?.latitude,
            lon: pos?.longitude,
          );
    });
  }

  Future<void> _onPlaceSelected(PlaceModel place) async {
    await ref.read(searchProvider.notifier).addRecentSearch(place.name);
    final pos = ref.read(locationProvider).position;
    if (pos != null) {
      await ref.read(routeProvider.notifier).calculateRoute(
            origin: LatLon(pos.latitude, pos.longitude),
            destination: LatLon(place.lat, place.lon),
            destinationPlace: place,
          );
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search places, areas, landmarks…',
            hintStyle: TextStyle(color: Colors.white.withAlpha(153)),
            filled: false,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchProvider.notifier).clearResults();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category buttons
          CategoryButtons(
            selectedCategory: _selectedCategory,
            onCategorySelected: (cat) async {
              setState(() => _selectedCategory = cat);
              if (cat != null) {
                final pos = ref.read(locationProvider).position;
                await ref.read(searchProvider.notifier).search(
                      cat,
                      lat: pos?.latitude,
                      lon: pos?.longitude,
                    );
              } else {
                ref.read(searchProvider.notifier).clearResults();
              }
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: searchState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  )
                : searchState.results.isNotEmpty
                    ? ListView.builder(
                        itemCount: searchState.results.length,
                        itemBuilder: (context, index) => SearchResultTile(
                          place: searchState.results[index],
                          onTap: () =>
                              _onPlaceSelected(searchState.results[index]),
                        ),
                      )
                    : _EmptyState(
                        recentSearches: searchState.recentSearches,
                        onRecentTap: (q) {
                          _controller.text = q;
                          _onQueryChanged(q);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.recentSearches,
    required this.onRecentTap,
  });

  final List<String> recentSearches;
  final void Function(String) onRecentTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (recentSearches.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          ...recentSearches.map(
            (q) => ListTile(
              leading:
                  const Icon(Icons.history, color: Colors.grey, size: 20),
              title: Text(q, style: const TextStyle(fontSize: 15)),
              onTap: () => onRecentTap(q),
            ),
          ),
          const Divider(),
        ],
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Saved Places',
            style: TextStyle(
              color: AppColors.darkGray,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home, color: AppColors.primaryGreen, size: 20),
          ),
          title: const Text('Home'),
          subtitle: const Text('Not set', style: TextStyle(fontSize: 12)),
        ),
        ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.infoBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.work, color: AppColors.infoBlue, size: 20),
          ),
          title: const Text('Work'),
          subtitle: const Text('Not set', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
