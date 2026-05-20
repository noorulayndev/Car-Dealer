import 'package:flutter/material.dart';
import '../models/test_drive_booking.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
class TestDriveBookingsScreen extends StatelessWidget {
  const TestDriveBookingsScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
    backgroundColor:  AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.royalNavy,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Test Drive Appointments',
          style: AppTheme.titleTextStyle,
        ),
      ),
      body: StreamBuilder<List<TestDriveBooking>>(
        stream: firebaseService.getMyBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Text('No test drive bookings found.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.directions_car,
                    color: Colors.blue,
                  ),
                  title: Text(
                    booking.carName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${booking.bookingDate} • ${booking.bookingTime}',
                  ),
                  trailing: Text(
                    booking.status,
                    style: TextStyle(
                      color: _statusColor(booking.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}