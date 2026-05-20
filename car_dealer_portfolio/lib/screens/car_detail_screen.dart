import 'package:car_dealer_portfolio/services/firebase_service.dart';
import 'package:car_dealer_portfolio/utils/utils.dart';
import 'package:car_dealer_portfolio/widgets/inquiry_bottom_sheet.dart';
import 'package:car_dealer_portfolio/widgets/test_drive_booking_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/favorite_service.dart';
import '../models/car_model.dart';

class CarDetailScreen extends StatelessWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CarImageGallery(imagePaths: car.imagePaths),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.brand,
                              style: GoogleFonts.poppins(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${car.model} (${car.year})',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5F5F5F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3FA34D),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3FA34D).withOpacity(0.35),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          '\$${PriceUtils.formatPrice(car.price)}',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  Row(
                    children: [
                      Expanded(
                        child: _SpecCard(
                          icon: Icons.speed_rounded,
                          title: 'Mileage',
                          value: '${PriceUtils.formatNumber(car.mileage)} mi',
                          color: const Color(0xFF2D9CDB),
                          backgroundColor: const Color(0xFFEAF6FF),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _SpecCard(
                          icon: Icons.bolt_rounded,
                          title: 'Fuel Type',
                          value: car.fuelType,
                          color: const Color(0xFF3FA34D),
                          backgroundColor: const Color(0xFFEFF9EF),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _SpecCard(
                          icon: Icons.calendar_month_rounded,
                          title: 'Year',
                          value: '${car.year}',
                          color: const Color(0xFF9C27B0),
                          backgroundColor: const Color(0xFFF8EAFB),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  _SectionTitle(title: 'Description'),
                  const SizedBox(height: 16),
                  Text(
                    car.description,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      height: 1.75,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                  ),

                  const SizedBox(height: 36),

                  _SectionTitle(title: 'Premium Features'),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: car.features.map((feature) {
                      return _FeaturePill(text: feature);
                    }).toList(),
                  ),

                  const SizedBox(height: 46),

                  ConsultantContactCard(car: car),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CarImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  const CarImageGallery({super.key, required this.imagePaths});
  @override
  State<CarImageGallery> createState() => _CarImageGalleryState();
}


class _CarImageGalleryState extends State<CarImageGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.imagePaths;

    if (images.isEmpty) {
      return Container(
        height: 360,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.directions_car, size: 80),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 70),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          Positioned(
            left: 28,
            top: 58,
            child: _TopButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            right: 98,
            top: 58,
            child: _TopButton(
              icon: Icons.share,
              onTap: () {},
            ),
          ),



          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 66,
        width: 66,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color backgroundColor;

  const _SpecCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF333333),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String text;

  const _FeaturePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF0FF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF1E88E5),
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E88E5),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsultantContactCard extends StatelessWidget {
  final Car car;

  const ConsultantContactCard({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xFFBBDEFB),
                child: Icon(
                  Icons.person,
                  size: 42,
                  color: Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Elite Automotive Consultant',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Certified Premium Vehicle\nSpecialist',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.3,
                        color: const Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '★★★★★',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFFB300),
                        fontSize: 20,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(

              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => InquiryBottomSheet(
                    car: car,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                elevation: 8,
                shadowColor: const Color(0xFF1E88E5).withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Inquire About Vehicle',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: OutlinedButton(
              onPressed: () async {
                await FirebaseService().seedMockAvailableSlotsForCar(
                  carId: car.id,
                  carModel: '${car.brand} ${car.model} (${car.year})',
                );

                if (!context.mounted) return;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => TestDriveBookingBottomSheet(
                    car: car,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFF1E88E5),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Book Showroom Viewing',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E88E5),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
         ,
        ],
      ),
    );
  }
}

