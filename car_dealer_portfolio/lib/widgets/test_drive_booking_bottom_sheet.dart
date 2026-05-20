import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/car_model.dart';
import '../services/firebase_service.dart';

class TestDriveBookingBottomSheet extends StatefulWidget {
  final Car car;

  const TestDriveBookingBottomSheet({
    super.key,
    required this.car,
  });

  @override
  State<TestDriveBookingBottomSheet> createState() =>
      _TestDriveBookingBottomSheetState();
}

class _TestDriveBookingBottomSheetState
    extends State<TestDriveBookingBottomSheet> {
  final FirebaseService _firebaseService = FirebaseService();

  DocumentSnapshot? _selectedSlot;
  bool _isBooking = false;

  Future<void> _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to book a test drive'),
        ),
      );
      return;
    }

    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available date and time'),
        ),
      );
      return;
    }

    final slotData = _selectedSlot!.data() as Map<String, dynamic>;

    setState(() {
      _isBooking = true;
    });

    try {
      await _firebaseService.bookTestDrive(
        slotId: _selectedSlot!.id,
        userId: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        carId: widget.car.id,
        carModel:
        '${widget.car.brand} ${widget.car.model} (${widget.car.year})',
        date: slotData['date'] ?? '',
        time: slotData['time'] ?? '',
        showroom: slotData['showroom'] ?? '',
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test drive booked successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isBooking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book test drive: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Book Test Drive',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF333333),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${widget.car.brand} ${widget.car.model} (${widget.car.year})',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
              _firebaseService.getAvailableTestDriveSlots(widget.car.id),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load available slots',
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final slots = snapshot.data?.docs ?? [];

                if (slots.isEmpty) {
                  return Center(
                    child: Text(
                      'No available test drive slots',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: slots.length,

                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final data = slot.data() as Map<String, dynamic>;

                    final bool isSelected =
                        _selectedSlot?.id == slot.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSlot = slot;
                        });
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),

                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.grey.shade50,

                          borderRadius: BorderRadius.circular(16),

                          border: Border.all(
                            color: isSelected
                                ? Colors.blue.shade600
                                : Colors.grey.shade300,

                            width: isSelected ? 2 : 1,
                          ),
                        ),

                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.blue.shade600,
                              size: 30,
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    '${data['date'] ?? ''} at ${data['time'] ?? ''}',

                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color:
                                      const Color(0xFF333333),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    data['showroom'] ?? 'Showroom',

                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Colors.blue.shade600,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          if (!isLoggedIn) ...[
            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: Colors.red.shade50,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(
                  color: Colors.red.shade200,
                ),
              ),

              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.red.shade400,
                    size: 20,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Please login first to book a test drive.',

                      style: GoogleFonts.poppins(
                        color: Colors.red.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
          ],

          SizedBox(
            width: double.infinity,
            height: 56,

            child: ElevatedButton(
              onPressed:
              (!isLoggedIn || _isBooking)
                  ? null
                  : _confirmBooking,

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,

                disabledBackgroundColor:
                Colors.grey.shade300,

                disabledForegroundColor:
                Colors.grey.shade600,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              child: _isBooking
                  ? Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,

                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    'Booking...',

                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
                  : Text(
                !isLoggedIn
                    ? 'Please Login First'
                    : 'Confirm Booking',

                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
