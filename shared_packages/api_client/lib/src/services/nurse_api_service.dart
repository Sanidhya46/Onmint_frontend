import '../api_client_base.dart';
import '../models/models.dart';

class NurseApiService {
  final ApiClient _client;

  NurseApiService(this._client);

  // Profile Management
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.put('/nurse/profile', data: data);
    return User.fromJson(response.data['data']);
  }

  // Service Management
  Future<void> updateServices(List<Map<String, dynamic>> servicesOffered) async {
    await _client.put('/nurse/services', data: {
      'servicesOffered': servicesOffered,
    });
  }

  // Availability Management
  Future<void> setAvailability(List<Map<String, dynamic>> availability) async {
    await _client.put('/nurse/availability', data: {
      'availability': availability,
    });
  }

  // Booking Management
  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.get('/nurse/bookings', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    return response.data;
  }

  Future<void> acceptBooking(String bookingId) async {
    await _client.post('/nurse/bookings/$bookingId/accept');
  }

  Future<void> rejectBooking(String bookingId, {String? reason}) async {
    await _client.post('/nurse/bookings/$bookingId/reject', data: {
      if (reason != null) 'reason': reason,
    });
  }

  Future<void> startVisit(String bookingId) async {
    await _client.post('/nurse/bookings/$bookingId/start');
  }

  Future<void> completeVisit(String bookingId, {String? notes}) async {
    await _client.post('/nurse/bookings/$bookingId/complete', data: {
      if (notes != null) 'notes': notes,
    });
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _client.get('/nurse/dashboard');
    return response.data['data'];
  }

  // Get booking details
  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    final response = await _client.get('/nurse/bookings/$bookingId');
    return response.data['data'];
  }

  // Location Update (NEW - Added April 19, 2026)
  /// Update nurse's current location for distance-based search
  /// Should be called when nurse opens app or location changes significantly
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.put('/nurse/location', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.data['data'];
  }

  // Real-time Booking Management (NEW - Added for instant bookings)
  /// Get real-time booking requests sent to all nearby nurses
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
}
