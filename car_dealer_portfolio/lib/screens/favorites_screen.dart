import 'package:car_dealer_portfolio/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/car_model.dart';
import '../services/favorite_service.dart';
import '../widgets/car_card.dart';
import 'car_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.carsFuture,
  });

  final Future<List<Car>> carsFuture;

  String _carId(Car car) {
    return car.id.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'My Favorites',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Car>>(
              future: carsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _EmptyFavoritesMessage(
                    icon: Icons.error_outline,
                    title: 'Could not load favorites',
                    message: 'Please check Firebase and try again.',
                  );
                }

                final cars = snapshot.data ?? <Car>[];

                return ValueListenableBuilder<Set<String>>(
                  valueListenable: FavoriteService.favoriteIds,
                  builder: (context, favoriteIds, _) {
                    final favoriteCars = cars
                        .where((car) => favoriteIds.contains(_carId(car)))
                        .toList();

                    if (favoriteCars.isEmpty) {
                      return const _EmptyFavoritesMessage(
                        icon: Icons.favorite_border,
                        title: 'No Favorites Yet',
                        message: 'Tap the heart icon on a vehicle to save it here.',
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: favoriteCars.length,
                        itemBuilder: (context, index) {
                          final car = favoriteCars[index];
                          final carId = _carId(car);

                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CarDetailScreen(car: car),
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
                                    icon: const Icon(Icons.favorite),
                                    color: Colors.redAccent,
                                    onPressed: () {
                                      FavoriteService.removeFavorite(carId);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavoritesMessage extends StatelessWidget {
  const _EmptyFavoritesMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(
          icon,
          size: 64,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
