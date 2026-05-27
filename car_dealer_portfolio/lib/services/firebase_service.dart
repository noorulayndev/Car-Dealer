import 'package:car_dealer_portfolio/models/test_drive_booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/car_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _carsCollection = 'cars';
  final String _leadsCollection = 'leads';
  final String _availableSlotsCollection = 'available_test_drive_slots';
  final String _testDriveBookingsCollection = 'test_drive_bookings';

  Future<List<Car>> fetchInventory() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_carsCollection)
          .orderBy('brand')
          .get();

      return snapshot.docs.map((doc) => Car.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  Future<void> seedInitialInventory() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_carsCollection)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print('Cars collection already contains data, skipping seed');
        return;
      }

      final List<Map<String, dynamic>> mockCars = [
        {
          'brand': 'Tesla',
          'model': 'Model S Plaid',
          'year': 2024,
          'price': 129990.0,
          'imagePaths': [
            'assets/images/tesla-1.jpg',
            'assets/images/tesla-2.jpg',
            'assets/images/tesla-3.jpg',
          ],
          'mileage': 5000,
          'fuelType': 'Electric',
          'features': [
            'Autopilot',
            'Ludicrous Mode',
            'Premium Interior',
            '21-inch Wheels',
            'Carbon Fiber Spoiler',
            'Glass Roof',
            '17-inch Touchscreen',
          ],
          'description':
          'The quickest production car ever made with advanced electric performance.',
        },
        {
          'brand': 'BMW',
          'model': 'X7 xDrive40i',
          'year': 2024,
          'price': 89900.0,
          'imagePaths': [
            'assets/images/bmw-1.jpg',
            'assets/images/bmw-2.jpg',
            'assets/images/bmw-3.jpg',
          ],
          'mileage': 12000,
          'fuelType': 'Hybrid',
          'features': [
            'Premium Leather Seats',
            'Panoramic Sunroof',
            'Harman Kardon Sound',
            'Adaptive Cruise Control',
            'Wireless Charging',
            '7-Seater Configuration',
            'Ambient Lighting',
          ],
          'description':
          'Ultimate luxury SUV combining spacious comfort with BMW driving dynamics.',
        },
        {
          'brand': 'Porsche',
          'model': '911 Turbo S',
          'year': 2023,
          'price': 230000.0,
          'imagePaths': [
            'assets/images/porsche-1.jpeg',
            'assets/images/porsche-2.jpeg',
            'assets/images/porsche-3.jpeg',
            'assets/images/porsche-4.jpeg',
          ],
          'mileage': 8500,
          'fuelType': 'Gas',
          'features': [
            'Twin-Turbo Engine',
            'Sport Chrono Package',
            'Carbon Ceramic Brakes',
            'Active Suspension',
            'Sport Exhaust',
            'Racing Seats',
            'Track Precision Package',
          ],
          'description':
          'The ultimate sports car experience with legendary Porsche engineering.',
        },
        {
          'brand': 'Mercedes-Benz',
          'model': 'S-Class S580',
          'year': 2024,
          'price': 115000.0,
          'imagePaths': [
            'assets/images/mercedez-1.jpeg',
            'assets/images/tesla-2.jpg',
            'assets/images/tesla-3.jpg',
          ],
          'mileage': 3200,
          'fuelType': 'Hybrid',
          'features': [
            'Massage Seats',
            'Executive Rear Package',
            'Burmester 4D Sound',
            'Air Suspension',
            'Night Vision',
            'Chauffeur Package',
            'Premium Leather Interior',
          ],
          'description':
          'The pinnacle of luxury sedans with cutting-edge comfort and technology.',
        },
        {
          'brand': 'Audi',
          'model': 'e-tron GT RS',
          'year': 2024,
          'price': 149900.0,
          'imagePaths': [
            'assets/images/audi-1.jpeg',
            'assets/images/audi-2.jpeg',
            'assets/images/audi-3.jpeg',
          ],
          'mileage': 7800,
          'fuelType': 'Electric',
          'features': [
            'Quattro All-Wheel Drive',
            'Air Suspension',
            'Virtual Cockpit Plus',
            'Matrix LED Headlights',
            'Carbon Fiber Package',
            'Sport Differential',
            'Bang & Olufsen Audio',
          ],
          'description':
          'Electric grand touring redefined with Audi luxury and performance.',
        },
        {
          'brand': 'Lamborghini',
          'model': 'Huracán EVO',
          'year': 2023,
          'price': 275000.0,
          'imagePaths': [
            'assets/images/lamborghini-1.jpeg',
            'assets/images/lamborghini-2.jpg',
            'assets/images/lamborghini-3.jpg',
          ],
          'mileage': 2100,
          'fuelType': 'Gas',
          'features': [
            'V10 Naturally Aspirated',
            'All-Wheel Steering',
            'Performance Traction Control',
            'Carbon Fiber Body',
            'Racing Suspension',
            'Alcantara Interior',
            'Launch Control',
          ],
          'description': 'Pure Italian supercar passion with race-bred technology.',
        },
        {
          'brand': 'Ferrari',
          'model': 'SF90 Stradale',
          'year': 2024,
          'price': 625000.0,
          'imagePaths': [
            'assets/images/ferrari-sf90-1.jpg',
            'assets/images/ferrari-sf90-2.jpg',
            'assets/images/ferrari-sf90-3.jpg',
          ],
          'mileage': 850,
          'fuelType': 'Hybrid',
          'features': [
            'Twin-Turbo V8 Engine',
            'Plug-in Hybrid System',
            '986 Horsepower',
            'Carbon Ceramic Brakes',
            'Adaptive Suspension',
            'Digital Cockpit',
            'Launch Control',
          ],
          'description': 'Ferrari’s revolutionary hybrid supercar delivering breathtaking speed and futuristic technology.',
        },

        {
          'brand': 'Ferrari',
          'model': '296 GTB',
          'year': 2023,
          'price': 338000.0,
          'imagePaths': [
            'assets/images/ferrari-296-1.jpg',
            'assets/images/ferrari-296-2.jpg',
            'assets/images/ferrari-296-3.jpg',
          ],
          'mileage': 1600,
          'fuelType': 'Hybrid',
          'features': [
            'V6 Twin-Turbo Hybrid',
            '830 Horsepower',
            'Rear-Wheel Drive',
            'Active Aerodynamics',
            'Carbon Fiber Trim',
            'Premium Leather Interior',
            'Advanced Driver Display',
          ],
          'description': 'A compact Ferrari supercar combining electrified performance with iconic Italian styling.',
        },

        {
          'brand': 'Ferrari',
          'model': 'Roma',
          'year': 2024,
          'price': 247000.0,
          'imagePaths': [
            'assets/images/ferrari-roma-1.jpg',
            'assets/images/ferrari-roma-2.jpg',
            'assets/images/ferrari-roma-3.jpg',
          ],
          'mileage': 3200,
          'fuelType': 'Gas',
          'features': [
            'Twin-Turbo V8',
            'Grand Touring Comfort',
            'Luxury Leather Seats',
            'Digital Instrument Cluster',
            'Adaptive Cruise Control',
            'Premium JBL Audio',
            'Launch Control',
          ],
          'description': 'Elegant grand touring Ferrari designed for both performance and luxurious everyday driving.',
        },
      ];

      final WriteBatch batch = _firestore.batch();

      for (final Map<String, dynamic> carData in mockCars) {
        final DocumentReference docRef =
        _firestore.collection(_carsCollection).doc();
        batch.set(docRef, carData);
      }

      await batch.commit();
      print('Successfully seeded ${mockCars.length} cars to Firestore');
    } catch (e) {
      throw Exception('Failed to seed inventory: $e');
    }
  }

  Future<void> submitInquiry({
    required String carId,
    required String userId,
    required String carModel,
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      await _firestore.collection(_leadsCollection).add({
        'carId': carId,
        'userId':userId,
        'carModel': carModel,
        'name': name,
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to submit inquiry: $e');
    }
  }

  Stream<QuerySnapshot> getAvailableTestDriveSlots(String carId) {
    return _firestore
        .collection(_availableSlotsCollection)
        .where('carId', isEqualTo: carId)
        .where('isBooked', isEqualTo: false)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  Future<void> bookTestDrive({
    required String slotId,
    required String userId,
    required String name,
    required String email,
    required String carId,
    required String carModel,
    required String date,
    required String time,
    required String showroom,
  }) async {
    final DocumentReference slotRef =
    _firestore.collection(_availableSlotsCollection).doc(slotId);

    final DocumentReference bookingRef =
    _firestore.collection(_testDriveBookingsCollection).doc();

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot slotSnapshot = await transaction.get(slotRef);

        if (!slotSnapshot.exists) {
          throw Exception('This slot no longer exists');
        }

        final Map<String, dynamic> slotData =
        slotSnapshot.data() as Map<String, dynamic>;

        final bool isBooked = slotData['isBooked'] == true;
        final bool isActive = slotData['isActive'] == true;

        if (isBooked) {
          throw Exception('This slot is already booked');
        }

        if (!isActive) {
          throw Exception('This slot is not available');
        }

        transaction.update(slotRef, {
          'isBooked': true,
          'bookedBy': userId,
          'bookedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.set(bookingRef, {
          'slotId': slotId,
          'userId': userId,
          'name': name,
          'email': email,
          'carId': carId,
          'carModel': carModel,
          'date': date,
          'time': time,
          'showroom': showroom,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to book test drive: $e');
    }
  }

  Future<void> generateAvailableSlots({
    required String carId,
    required String carModel,
    required String showroom,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? timeSlots,
  }) async {
    try {
      final List<String> slots = timeSlots ??
          [
            '09:00 AM',
            '11:00 AM',
            '01:00 PM',
            '03:00 PM',
            '05:00 PM',
          ];

      WriteBatch batch = _firestore.batch();
      int writeCount = 0;

      DateTime currentDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      final DateTime lastDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      );

      while (!currentDate.isAfter(lastDate)) {
        // Skip Sunday.
        if (currentDate.weekday != DateTime.sunday) {
          final String dateString = _formatDate(currentDate);

          for (final String time in slots) {
            final String slotId = _buildSlotId(
              carId: carId,
              date: dateString,
              time: time,
              showroom: showroom,
            );

            final DocumentReference docRef =
            _firestore.collection(_availableSlotsCollection).doc(slotId);

            batch.set(
              docRef,
              {
                'carId': carId,
                'carModel': carModel,
                'date': dateString,
                'time': time,
                'showroom': showroom,
                'isBooked': false,
                'isActive': true,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true),
            );

            writeCount++;

            // Firestore batch limit is 500 writes.
            if (writeCount == 450) {
              await batch.commit();
              batch = _firestore.batch();
              writeCount = 0;
            }
          }
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }

      if (writeCount > 0) {
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to generate available slots: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> fetchBookingsForUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_testDriveBookingsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs;
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String _buildSlotId({
    required String carId,
    required String date,
    required String time,
    required String showroom,
  }) {
    final String safeTime = time
        .replaceAll(' ', '_')
        .replaceAll(':', '')
        .replaceAll('/', '_')
        .toLowerCase();

    final String safeShowroom = showroom
        .replaceAll(' ', '_')
        .replaceAll('/', '_')
        .replaceAll('-', '_')
        .toLowerCase();

    return '${carId}_${date}_${safeTime}_$safeShowroom';
  }
  Future<void> seedMockAvailableSlotsForCar({
    required String carId,
    required String carModel,
  }) async {
    final slots = [
      {
        'date': '2026-05-28',
        'time': '09:00 AM',
        'showroom': 'Downtown Showroom',
      },
      {
        'date': '2026-05-28',
        'time': '11:00 AM',
        'showroom': 'Downtown Showroom',
      },
      {
        'date': '2026-05-29',
        'time': '01:00 PM',
        'showroom': 'North Branch',
      },
      {
        'date': '2026-05-29',
        'time': '03:00 PM',
        'showroom': 'Airport Road Branch',
      },
    ];

    final batch = _firestore.batch();

    for (final slot in slots) {
      final slotId =
      '${carId}_${slot['date']}_${slot['time']}'.replaceAll(' ', '_');

      final docRef = _firestore
          .collection(_availableSlotsCollection)
          .doc(slotId);

      batch.set(docRef, {
        'carId': carId,
        'carModel': carModel,
        'date': slot['date'],
        'time': slot['time'],
        'showroom': slot['showroom'],
        'isBooked': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
  Future<void> createTestDriveBooking({
    required String carId,
    required String carName,
    required String imagePath,
    required String bookingDate,
    required String bookingTime,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('test_drive_bookings').add({
      'userId': currentUser.uid,
      'carId': carId,
      'carName': carName,
      'imagePath': imagePath,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Stream<List<TestDriveBooking>> getMyBookings() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('test_drive_bookings')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TestDriveBooking.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }
}

