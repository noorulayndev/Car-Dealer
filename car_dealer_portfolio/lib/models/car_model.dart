import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String imagePath;
  final int mileage;
  final String fuelType;
  final List<String> features;
  final String description;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.imagePath,
    required this.mileage,
    required this.fuelType,
    required this.features,
    required this.description,
  });

  factory Car.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Car(
      id: doc.id,
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['imagePath'] ?? '',
      mileage: data['mileage'] ?? 0,
      fuelType: data['fuelType'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'imagePath': imagePath,
      'mileage': mileage,
      'fuelType': fuelType,
      'features': features,
      'description': description,
    };
  }
}