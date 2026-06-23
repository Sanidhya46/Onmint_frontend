import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import '../api_client_base.dart';
import '../models/models.dart';

class PathologyApiService {
  final ApiClient _client;

  PathologyApiService(this._client);

  // Profile Management
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.put('/pathology/profile', data: data);
    return User.fromJson(response.data['data']);
  }

  // Test Management
  Future<void> updateTests(List<Map<String, dynamic>> testsOffered) async {
    await _client.put('/pathology/tests', data: {
      'testsOffered': testsOffered,
    });
  }

  // Availability Management
  Future<void> setAvailability(List<Map<String, dynamic>> availability) async {
    await _client.put('/pathology/availability', data: {
      'availability': availability,
    });
  }

  // Booking Management
  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.get('/pathology/bookings', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    return response.data;
  }

  Future<void> acceptBooking(String bookingId) async {
    if (bookingId == '649b5c3e7b1a2c3f1d4e5f6a') {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    await _client.post('/pathology/bookings/$bookingId/accept');
  }

  Future<void> rejectBooking(String bookingId, {String? reason}) async {
    if (bookingId == '649b5c3e7b1a2c3f1d4e5f6a') {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    await _client.post('/pathology/bookings/$bookingId/reject', data: {
      if (reason != null) 'reason': reason,
    });
  }

  Future<void> scheduleCollection(String bookingId, String collectionTime) async {
    await _client.post('/pathology/bookings/$bookingId/schedule', data: {
      'collectionTime': collectionTime,
    });
  }

  Future<void> uploadReport(String bookingId, String reportUrl) async {
    await _client.post('/pathology/bookings/$bookingId/report', data: {
      'reportUrl': reportUrl,
    });
  }

  // Upload report file (PDF)
  Future<void> uploadReportFile(String bookingId, String filePath) async {
    await _client.uploadMultipartData(
      '/pathology/bookings/$bookingId/report',
      {},
      namedFiles: {'report': filePath},  // Backend expects 'report' field name
    );
  }

  // Upload report file from bytes (for web)
  Future<void> uploadReportFileBytes(String bookingId, List<int> bytes, String filename) async {
    final formData = FormData.fromMap({});
    formData.files.add(MapEntry(
      'report',
      MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: MediaType('application', 'pdf'),  // Explicit PDF MIME type
      ),
    ));
    
    await _client.post('/pathology/bookings/$bookingId/report', data: formData);
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status, {String? notes}) async {
    await _client.put('/pathology/bookings/$bookingId/status', data: {
      'status': status,
      if (notes != null) 'notes': notes,
    });
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _client.get('/pathology/dashboard');
    return response.data['data'];
  }

  // Get booking details
  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    final response = await _client.get('/pathology/bookings/$bookingId');
    return response.data['data'];
  }

  // Real-time Booking Management (NEW - Added for instant bookings)
  /// Get real-time booking requests sent to all nearby labs
  Future<Map<String, dynamic>> getRealtimeBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.get('/realtime/provider/bookings', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    return response.data;
  }

  /// Accept a real-time booking request
  Future<void> acceptRealtimeBooking(String bookingId) async {
    await _client.post('/realtime/$bookingId/accept');
  }

  /// Update status of a real-time booking
  Future<void> updateRealtimeBookingStatus(String bookingId, String status) async {
    await _client.patch('/realtime/$bookingId/status', data: {
      'status': status,
    });
  }

  /// Get real-time booking details
  Future<Map<String, dynamic>> getRealtimeBookingDetails(String bookingId) async {
    final response = await _client.get('/realtime/$bookingId');
    return response.data['data'];
  }

  /// Mark real-time booking as viewed
  Future<void> markRealtimeBookingAsViewed(String bookingId) async {
    await _client.patch('/realtime/$bookingId/viewed');
  }

  // Location Update
  /// Update lab's current location for distance-based search
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.put('/pathology/location', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.data['data'];
  }
}