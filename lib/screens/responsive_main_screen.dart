import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_up/core/responsive/responsive_layout.dart';
import 'package:music_up/core/providers/theme_provider.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:music_up/screens/discogs_search_screen.dart';
import 'package:music_up/screens/album_detail_screen.dart';
import 'package:music_up/screens/edit_album_screen.dart';
import 'package:music_up/screens/settings_screen.dart';
import 'package:music_up/screens/wantlist_screen.dart';
import 'package:music_up/services/album_filter_service.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/widgets/album_filters_widget.dart';
import 'package:music_up/widgets/album_list_widget.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/counter_bar.dart';

/// Responsive main screen that adapts to different screen sizes and platforms
class ResponsiveMainScreen extends ConsumerStatefulWidget {
  final JsonService jsonService;

  const ResponsiveMainScreen({
    super.key,
    required this.jsonService,
  });

  @override
  ConsumerState<ResponsiveMainScreen> createState() => _ResponsiveMainScreenState();
}

class _ResponsiveMainScreenState extends ConsumerState<ResponsiveMainScreen> with TickerProviderStateMixin {
  final AlbumFilterService _filterService = AlbumFilterService();
  final TextEditingController _searchController = TextEditingController();

  List<Album> _albums = [];
  List<Album> _filteredAlbums = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  // Filter state
  String _searchCategory = 'Album';
  Map<String, bool> _mediumFilters = {};
  String _digitalFilter = 'All';
  bool _isAscending = true;
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _mediumFilters = _filterService.getDefaultMediumFilters();
    _loadAlbums();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);
    try {
      final albums = await widget.jsonService.loadAlbums();
      setState(() {
        _albums = albums;
        _filteredAlbums = albums;
        _counts = _filterService.calculateCounts(albums);
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.logError('Failed to load albums', e);
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAlbums = _filterService.filterAlbums(
        _albums,
        searchText: _searchController.text,
        searchCategory: _searchCategory,
        mediumFilters: _mediumFilters,
        digitalFilter: _digitalFilter,
        isAscending: _isAscending,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  /// Mobile layout with bottom navigation
  Widget _buildMobileLayout(BuildContext context) {
    final platform = ResponsiveLayout.getCurrentPlatform();
    final navigationType = PlatformAdaptive.getNavigationType(context);

    return Scaffold(
      body: _buildSelectedScreen(),
      bottomNavigationBar: navigationType == NavigationType.bottomNavigation
          ? _buildBottomNavigationBar()
          : null,
      bottomSheet: navigationType == NavigationType.tabBar
          ? _buildTabBar()
          : null,
      floatingActionButton: _selectedIndex == 0 ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Tablet layout with rail navigation
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: _getNavigationDestinations(),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildSelectedScreen()),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  /// Desktop layout with sidebar navigation
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: ResponsiveValue<double>(
              mobile: 200,
              tablet: 250,
              desktop: 280,
            ).getValue(context),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: _buildDesktopSidebar(context),
          ),
          Expanded(
            child: _buildSelectedScreen(isDesktop: true),
          ),
        ],
      ),
    );
  }

  /// Desktop sidebar with app branding and navigation
  Widget _buildDesktopSidebar(BuildContext context) {
    return Column(
      children: [
        // App header with logo and title
        Container(
          height: PlatformAdaptive.getAppBarHeight(context),
          padding: PlatformAdaptive.getPlatformPadding(context),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/icons/app_icon.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MusicUp',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Navigation items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildDesktopNavItem(
                context,
                icon: Icons.library_music,
                title: 'Albums',
                index: 0,
                badge: _counts['Total']?.toString(),
              ),
              _buildDesktopNavItem(
                context,
                icon: Icons.favorite_outline,
                title: 'Wantlist',
                index: 1,
              ),
              _buildDesktopNavItem(
                context,
                icon: Icons.search,
                title: 'Discogs Search',
                index: 2,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              _buildDesktopNavItem(
                context,
                icon: Icons.add,
                title: 'Add Album',
                index: 3,
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              _buildDesktopNavItem(
                context,
                icon: Icons.settings,
                title: 'Settings',
                index: 4,
              ),
            ],
          ),
        ),

        // Theme toggle at bottom
        Padding(
          padding: PlatformAdaptive.getPlatformPadding(context),
          child: _buildThemeToggle(),
        ),
      ],
    );
  }

  Widget _buildDesktopNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    String? badge,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: PlatformAdaptive.getPlatformBorderRadius(),
        color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer 
          : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeNotifierProvider);
        
        return SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode, size: 16),
              tooltip: 'Light Theme',
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto, size: 16),
              tooltip: 'System Theme',
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode, size: 16),
              tooltip: 'Dark Theme',
            ),
          ],
          selected: {themeMode},
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            ref.read(themeNotifierProvider.notifier).updateTheme(newSelection.first);
          },
        );
      },
    );
  }

  Widget _buildSelectedScreen({bool isDesktop = false}) {
    switch (_selectedIndex) {
      case 0:
        return _buildAlbumsScreen(isDesktop: isDesktop);
      case 1:
        return WantlistScreen(jsonService: widget.jsonService);
      case 2:
        return DiscogsSearchScreen(jsonService: widget.jsonService);
      case 3:
        return AddAlbumScreen(jsonService: widget.jsonService);
      case 4:
        return Consumer(
          builder: (context, ref, child) => SettingsScreen(
            jsonService: widget.jsonService,
            onThemeChanged: (theme) => ref.read(themeNotifierProvider.notifier).updateTheme(theme),
          ),
        );
      default:
        return _buildAlbumsScreen(isDesktop: isDesktop);
    }
  }

  Widget _buildAlbumsScreen({bool isDesktop = false}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // App bar for mobile/tablet, search bar for desktop
        if (!isDesktop) _buildAppBar(),
        
        // Search and filters
        _buildSearchAndFilters(isDesktop: isDesktop),
        
        // Counter bar
        if (_filteredAlbums.isNotEmpty)
          CounterBar(counts: _counts),
        
        // Album list
        Expanded(
          child: AlbumListWidget(
            albums: _filteredAlbums,
            onAlbumTap: _openAlbumDetail,
            onAlbumEdit: _openAlbumEdit,
            onAlbumDelete: _deleteAlbum,
            isDesktop: isDesktop,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: const Text('MusicUp'),
      elevation: PlatformAdaptive.getPlatformElevation(),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadAlbums,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters({bool isDesktop = false}) {
    return Container(
      padding: PlatformAdaptive.getPlatformPadding(context),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search albums...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: PlatformAdaptive.getPlatformBorderRadius(),
              ),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          
          const SizedBox(height: 16),
          
          // Filters
          AlbumFiltersWidget(
            searchCategory: _searchCategory,
            mediumFilters: _mediumFilters,
            digitalFilter: _digitalFilter,
            isAscending: _isAscending,
            onSearchCategoryChanged: (category) {
              setState(() => _searchCategory = category);
              _applyFilters();
            },
            onMediumFilterChanged: (medium, value) {
              setState(() => _mediumFilters[medium] = value);
              _applyFilters();
            },
            onDigitalFilterChanged: (filter) {
              setState(() => _digitalFilter = filter);
              _applyFilters();
            },
            onSortOrderChanged: (ascending) {
              setState(() => _isAscending = ascending);
              _applyFilters();
            },
            isDesktop: isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: 'Albums',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          label: 'Wantlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: TabBar(
          controller: TabController(length: 5, vsync: this),
          tabs: const [
            Tab(icon: Icon(Icons.library_music), text: 'Albums'),
            Tab(icon: Icon(Icons.favorite_outline), text: 'Wantlist'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
            Tab(icon: Icon(Icons.add), text: 'Add'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => setState(() => _selectedIndex = 3), // Navigate to Add Album
      tooltip: 'Add Album',
      child: const Icon(Icons.add),
    );
  }

  List<NavigationRailDestination> _getNavigationDestinations() {
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.library_music),
        label: Text('Albums'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.favorite_outline),
        label: Text('Wantlist'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.search),
        label: Text('Search'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.add),
        label: Text('Add'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.settings),
        label: Text('Settings'),
      ),
    ];
  }

  // Album actions
  void _openAlbumDetail(Album album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumDetailScreen(
          album: album,
          jsonService: widget.jsonService,
        ),
      ),
    );
  }

  void _openAlbumEdit(Album album) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAlbumScreen(
          album: album,
          jsonService: widget.jsonService,
        ),
      ),
    );

    if (result == true) {
      await _loadAlbums();
    }
  }

  void _deleteAlbum(Album album) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Album'),
        content: Text('Are you sure you want to delete "${album.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.jsonService.deleteAlbum(album.id);
        await _loadAlbums();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${album.title}"'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // TODO: Implement undo functionality
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete album: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}