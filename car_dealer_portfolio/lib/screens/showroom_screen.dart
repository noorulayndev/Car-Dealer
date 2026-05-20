import 'package:car_dealer_portfolio/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/car_model.dart';
import '../services/firebase_service.dart';
import '../services/favorite_service.dart';
import '../widgets/car_card.dart';
import 'account_screen.dart';
import 'auth_screen.dart';
import 'car_detail_screen.dart';
import 'favorites_screen.dart';

class ShowroomScreen extends StatefulWidget {
  const ShowroomScreen({super.key});

  @override
  State<ShowroomScreen> createState() => _ShowroomScreenState();
}

class _ShowroomScreenState extends State<ShowroomScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedFilter = 'All';
  int _selectedBottomIndex = 0;

  String _searchQuery = '';

  late Future<List<Car>> _carsFuture;

  final List<String> _filterOptions = const [
    'All',
    'Electric',
    'Hybrid',
    'Gas',
  ];

  @override
  void initState() {
    super.initState();
    _carsFuture = _firebaseService.fetchInventory();
    FavoriteService.init();
  }


  List<Car> _filterCars(List<Car> cars) {
    final query = _searchQuery.trim().toLowerCase();

    return cars.where((car) {
      final matchesFuelType = _selectedFilter == 'All' ||
          car.fuelType.toLowerCase() == _selectedFilter.toLowerCase();

      final matchesSearch = query.isEmpty ||
          car.brand.toLowerCase().contains(query) ||
          car.model.toLowerCase().contains(query) ||
          car.price.toInt().toString().contains(query) ||
          car.price.toString().toLowerCase().contains(query) ||
          car.mileage.toString().contains(query);

      return matchesFuelType && matchesSearch;
    }).toList();
  }

  void _resetSearchFilters() {
    setState(() {
      _selectedFilter = 'All';
      _searchQuery = '';
    });
  }

  Future<void> _openSearchScreen() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => InventorySearchScreen(initialQuery: _searchQuery),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _searchQuery = result.trim();
      _selectedBottomIndex = 0;
    });
  }

  void _openAuthScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthScreen(
          onLoginSuccess: () {
            Navigator.pop(context);

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully signed in'),
              ),
            );

            _openAccountScreen();
          },
        ),
      ),
    );
  }

  void _openAccountScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountScreen(),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      setState(() {
        _selectedBottomIndex = 0;
      });
      return;
    }

    if (index == 1) {
      setState(() {
        _selectedBottomIndex = 1;
      });
      return;
    }

    if (index == 2) {
      final user = _auth.currentUser;

      if (user == null) {
        _openAuthScreen();
      } else {
        _openAccountScreen();
      }
    }
  }

  Future<void> _refreshInventory() async {
    setState(() {
      _carsFuture = _firebaseService.fetchInventory();
    });

    await _carsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          children: _selectedBottomIndex == 0
              ? [
            _buildHeader(),
            _buildFilterRow(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshInventory,
                child: _buildInventoryGrid(),
              ),
            ),
          ]
              : [
            Expanded(
              child: FavoritesScreen(carsFuture: _carsFuture),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          final isSignedIn = snapshot.data != null;

          return NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppTheme.royalNavy,
              indicatorColor: Colors.white.withOpacity(0.18),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                    (states) {
                  return GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: Colors.white,
                  );
                },
              ),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                    (states) {
                  return IconThemeData(
                    color: Colors.white,
                    size: states.contains(WidgetState.selected) ? 24 : 22,
                  );
                },
              ),
            ),
            child: NavigationBar(
              selectedIndex: _selectedBottomIndex,
              onDestinationSelected: _onBottomNavTap,
              height: 60,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.directions_car_outlined),
                  selectedIcon: Icon(Icons.directions_car),
                  label: 'Showroom',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(isSignedIn ? Icons.person_outline : Icons.login),
                  selectedIcon: Icon(isSignedIn ? Icons.person : Icons.login),
                  label: isSignedIn ? 'Profile' : 'Sign In',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      // width: double.infinity,
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elite Automotive',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Premium Luxury Vehicle Collection',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Discover exceptional automotive excellence',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final hasSearch = _searchQuery.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _openSearchScreen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.blue.shade700),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            hasSearch
                                ? _searchQuery
                                : 'Search by brand, model, price or mileage',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight:
                              hasSearch ? FontWeight.w600 : FontWeight.w400,
                              color: hasSearch
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (hasSearch || _selectedFilter != 'All') ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Reset search',
                  onPressed: _resetSearchFilters,
                  icon: Icon(Icons.close, color: Colors.grey.shade700),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((option) {
                final isSelected = _selectedFilter == option;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      option,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                        isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = option;
                        });
                      }
                    },
                    selectedColor: Colors.blue.shade600,
                    backgroundColor: Colors.grey.shade200,
                    elevation: isSelected ? 4 : 1,
                    shadowColor: Colors.blue.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid() {
    return FutureBuilder<List<Car>>(
      future: _carsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  //strokeWidth: 3,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading Premium Inventory...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 120),
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Error Loading Inventory',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Please check Firebase and try again.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 120),
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No Vehicles Available',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }

        final filteredCars = _filterCars(snapshot.data!);

        if (filteredCars.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 120),
              Icon(
                Icons.filter_alt_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No matching vehicles found',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            // Extra bottom padding keeps the last row visible above the bottom navigation bar.
            padding: const EdgeInsets.only(bottom: 96),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // Taller cards prevent the "BOTTOM OVERFLOWED" warning
              // when brand/model/price/button text takes more space.
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemCount: filteredCars.length,
            itemBuilder: (context, index) {
              final car = filteredCars[index];

              final carId = car.id.toString();

              return ValueListenableBuilder<Set<String>>(
                valueListenable: FavoriteService.favoriteIds,
                builder: (context, favoriteIds, _) {
                  final isFavorite = favoriteIds.contains(carId);

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarDetailScreen(car: car),
                            ),
                          );
                        },
                        child: CarCard(car: car),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                            ),
                            color: isFavorite ? Colors.redAccent : Colors.grey.shade700,
                            onPressed: () {
                              FavoriteService.toggleFavorite(carId);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class InventorySearchScreen extends StatefulWidget {
  final String initialQuery;

  const InventorySearchScreen({
    super.key,
    this.initialQuery = '',
  });

  @override
  State<InventorySearchScreen> createState() => _InventorySearchScreenState();
}

class _InventorySearchScreenState extends State<InventorySearchScreen> {
  late final TextEditingController _searchController;

  final List<String> _brand = const [
    'Audi',
    'Ferrari',
    'BMW',
    'Huracán',
    'Porsche',
    'Mercedes-Benz',
    'Lamborghini',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    Navigator.pop(context, _searchController.text.trim());
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.royalNavy,
        foregroundColor: Colors.white,
        title: Text(
          'Search Automobiles',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Search cars',
                hintText: 'Brand, model, price or mileage',
                helperText: 'Example: Ferrari, F8, 275000, 2100',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onSubmitted: (_) => _submitSearch(),
            ),
            const SizedBox(height: 18),
            Text(
              'You can search by',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Brand',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _brand.map((example) {
                return ActionChip(
                  label: Text(example),
                  onPressed: () {
                    setState(() {
                      _searchController.text = example;
                    });
                    _submitSearch();
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.royalNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHelpChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SearchHelpChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.blue.shade700),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
    );
  }
}
