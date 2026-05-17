import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _carsCollection = 'cars';
  final String _leadsCollection = 'leads';

  Future<List<Car>> fetchInventory() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_carsCollection)
          .orderBy('brand')
          .get();

      return snapshot.docs
          .map((doc) => Car.fromFirestore(doc))
          .toList();
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

      if (snapshot.docs.isEmpty) {
        final List<Map<String, dynamic>> mockCars = [
          {
            'brand': 'Tesla',
            'model': 'Model S Plaid',
            'year': 2024,
            'price': 129990.0,
            'imagePath': 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800',
            'mileage': 5000,
            'fuelType': 'Electric',
            'features': [
              'Autopilot',
              'Ludicrous Mode',
              'Premium Interior',
              '21-inch Wheels',
              'Carbon Fiber Spoiler',
              'Glass Roof',
              '17-inch Touchscreen'
            ],
            'description': 'The quickest production car ever made. With tri-motor setup and advanced autopilot capabilities, experience the future of luxury electric performance.'
          },
          {
            'brand': 'BMW',
            'model': 'X7 xDrive40i',
            'year': 2024,
            'price': 89900.0,
            'imagePath': 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
            'mileage': 12000,
            'fuelType': 'Hybrid',
            'features': [
              'Premium Leather Seats',
              'Panoramic Sunroof',
              'Harman Kardon Sound',
              'Adaptive Cruise Control',
              'Wireless Charging',
              '7-Seater Configuration',
              'Ambient Lighting'
            ],
            'description': 'Ultimate luxury SUV combining spacious 7-seater comfort with BMW driving dynamics. Perfect blend of performance and family practicality.'
          },
          {
            'brand': 'Porsche',
            'model': '911 Turbo S',
            'year': 2023,
            'price': 230000.0,
            'imagePath': 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800',
            'mileage': 8500,
            'fuelType': 'Gas',
            'features': [
              'Twin-Turbo Engine',
              'Sport Chrono Package',
              'Carbon Ceramic Brakes',
              'Active Suspension',
              'Sport Exhaust',
              'Racing Seats',
              'Track Precision Package'
            ],
            'description': 'The ultimate sports car experience. 640 horsepower of pure adrenaline with legendary Porsche engineering and track-proven performance.'
          },
          {
            'brand': 'Mercedes-Benz',
            'model': 'S-Class S580',
            'year': 2024,
            'price': 115000.0,
            'imagePath': 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
            'mileage': 3200,
            'fuelType': 'Hybrid',
            'features': [
              'Massage Seats',
              'Executive Rear Package',
              'Burmester 4D Sound',
              'Air Suspension',
              'Night Vision',
              'Chauffeur Package',
              'Premium Leather Interior'
            ],
            'description': 'The pinnacle of luxury sedans. Featuring cutting-edge technology, supreme comfort, and sophisticated design for the most discerning drivers.'
          },
          {
            'brand': 'Audi',
            'model': 'e-tron GT RS',
            'year': 2024,
            'price': 149900.0,
            'imagePath': 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800',
            'mileage': 7800,
            'fuelType': 'Electric',
            'features': [
              'Quattro All-Wheel Drive',
              'Air Suspension',
              'Virtual Cockpit Plus',
              'Matrix LED Headlights',
              'Carbon Fiber Package',
              'Sport Differential',
              'Bang & Olufsen Audio'
            ],
            'description': 'Electric grand touring redefined. Combining Audi luxury with devastating performance and sustainable technology for the modern enthusiast.'
          },
          {
            'brand': 'Lamborghini',
            'model': 'Huracán EVO',
            'year': 2023,
            'price': 275000.0,
            'imagePath': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800',
            'mileage': 2100,
            'fuelType': 'Gas',
            'features': [
              'V10 Naturally Aspirated',
              'All-Wheel Steering',
              'Performance Traction Control',
              'Carbon Fiber Body',
              'Racing Suspension',
              'Alcantara Interior',
              'Launch Control'
            ],
            'description': 'Pure Italian supercar passion. 631 horsepower of naturally aspirated V10 fury wrapped in stunning aerodynamic design and race-bred technology.'
          }
        ];

        final WriteBatch batch = _firestore.batch();

        for (final carData in mockCars) {
          final DocumentReference docRef = _firestore
              .collection(_carsCollection)
              .doc();
          batch.set(docRef, carData);
        }

        await batch.commit();
        print('Successfully seeded ${mockCars.length} cars to Firestore');
      } else {
        print('Cars collection already contains data, skipping seed');
      }
    } catch (e) {
      throw Exception('Failed to seed inventory: $e');
    }
  }

  Future<void> submitInquiry({
    required String carId,
    required String carModel,
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      await _firestore.collection(_leadsCollection).add({
        'carId': carId,
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
}