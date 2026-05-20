class TestDriveBooking {
  final String id;
  final String userId;
  final String carId;
  final String carName;
  final String bookingDate;
  final String bookingTime;
  final String status;
  final String place;

  TestDriveBooking({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carName,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    required this.place,
  });

  factory TestDriveBooking.fromMap(String id, Map<String, dynamic> data) {
    return TestDriveBooking(
      id: id,
      userId: data['userId'] ?? '',
      carId: data['carId'] ?? '',
      carName: data['carModel'] ?? '',
      bookingDate: data['date'] ?? '',
      bookingTime: data['time'] ?? '',
      status: data['status'] ?? 'Pending',
      place: data['showroom'] ?? ''
    );
  }
}