import 'package:car_dealer_portfolio/theme/app_theme.dart';
import 'package:car_dealer_portfolio/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/car_model.dart';

class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({super.key, required this.car});

  String get _coverImage {
    return car.imagePaths.isNotEmpty
        ? car.imagePaths.first
        : 'assets/images/cars_placeholder.png';
  }

  @override
  Widget build(BuildContext context) {
    final fuelStyle = getFuelTypeStyle(car.fuelType);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,        // ← prevents column expanding to full height
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 1.35,
              child: Image.asset(
                _coverImage,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.directions_car, size: 52),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,  // ← same here
              children: [
                Text(
                  car.brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  car.model,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _InfoChip(
                      text: '${car.mileage.toString()} mi',
                      backgroundColor: const Color(0xFFE3F2FD),
                      textColor: const Color(0xFF1E88E5),
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      text: car.fuelType,
                      backgroundColor: fuelStyle.backgroundColor,
                      textColor: fuelStyle.textColor,
                    ),
                  ],
                ),
                //const SizedBox(height: 4),
                Text(
                  '\$${PriceUtils.formatPrice(car.price)}',
                  style: AppTheme.priceStyle,

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _InfoChip({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class FuelTypeStyle {
  final Color backgroundColor;
  final Color textColor;

  const FuelTypeStyle({
    required this.backgroundColor,
    required this.textColor,
  });
}

FuelTypeStyle getFuelTypeStyle(String fuelType) {
  switch (fuelType.toLowerCase()) {
    case 'electric':
      return const FuelTypeStyle(
        backgroundColor: Color(0xFFE3F2FD),
        textColor: Color(0xFF1E88E5),
      );
    case 'hybrid':
      return const FuelTypeStyle(
        backgroundColor: Color(0xFFE8F5E9),
        textColor: Color(0xFF43A047),
      );
    case 'gas':
      return const FuelTypeStyle(
        backgroundColor: Color(0xFFFFEBEE),
        textColor: Color(0xFFE53935),
      );
    case 'diesel':
      return const FuelTypeStyle(
        backgroundColor: Color(0xFFFFF3E0),
        textColor: Color(0xFFFB8C00),
      );
    default:
      return FuelTypeStyle(
        backgroundColor: Colors.grey.shade200,
        textColor: Colors.grey.shade700,
      );
  }
}