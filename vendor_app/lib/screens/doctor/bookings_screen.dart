import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'appointment_details_screen.dart';

/// Bookings management screen for doctors - Complete consultation flow
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  final _apiClient = OnMintApiClient();
  late TabController _tabController;
  
  List<Booking> _requestedBookings = [];
  List<Booking> _acceptedBookings = [];
  List<Booking> _completedBookings = [];
  
  bool _isLoadingRequested = true;
  bool _isLoadingAccepted = true;
  bool _isLoadingCompleted = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllBookings() async {
    setState(() {
      _isLoadingRequested = true;
      _isLoadingAccepted = true;
      _isLoadingCompleted = true;
    });

    try {
      await _apiClient.initialize();
      final response = await _apiClient.doctor.getAppointments(page: 1, limit: 100);
      final allBookings = (response['data'] as List?)
          ?.map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      setState(() {
        _requestedBookings = allBookings.where((b) {
          final s = b.status?.toLowerCase() ?? '';
          return s == 'requested' || s == 'pending';
        }).toList();
        _acceptedBookings = allBookings.where((b) {
          final s = b.status?.toLowerCase() ?? '';
          return s == 'accepted' || s == 'confirmed' || s == 'scheduled';
        }).toList();
        _completedBookings = allBookings.where((b) {
          final s = b.status?.toLowerCase() ?? '';
          return s == 'completed' || s == 'cancelled' || s == 'rejected';
        }).toList();

        _isLoadingRequested = false;
        _isLoadingAccepted = false;
        _isLoadingCompleted = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRequested = false;
        _isLoadingAccepted = false;
        _isLoadingCompleted = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Requested'),
                  if (_requestedBookings.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_requestedBookings.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Accepted'),
                  if (_acceptedBookings.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_acceptedBookings.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(_requestedBookings, _isLoadingRequested, 'requested'),
          _buildBookingsList(_acceptedBookings, _isLoadingAccepted, 'accepted'),
          _buildBookingsList(_completedBookings, _isLoadingCompleted, 'completed'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, bool isLoading, String type) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'requested' ? Icons.pending_actions : 
              type == 'accepted' ? Icons.event_available : 
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type} bookings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking, type);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, String type) {
    final patientName = booking.patientDetails?.fullName ?? 'Patient';
    final patientPhone = booking.patientDetails?.phone ?? '';
    
    // Calculate age from dateOfBirth if available
    int patientAge = 0;
    if (booking.patientDetails?.dateOfBirth != null) {
      final birthDate = booking.patientDetails!.dateOfBirth!;
      final today = DateTime.now();
      patientAge = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        patientAge--;
      }
    }
    
    final patientGender = booking.patientDetails?.gender ?? '';
    
    Color statusColor;
    IconData statusIcon;
    
    switch (type) {
      case 'requested':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailsScreen(
                appointmentId: booking.id,
              ),
            ),
          );
          if (result == true) {
            _loadAllBookings();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (patientPhone.isNotEmpty)
                          Text(
                            patientPhone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        // Show age and gender
                        if (patientAge > 0 || patientGender.isNotEmpty)
                          Text(
                            '${patientAge > 0 ? '$patientAge years' : ''} ${patientGender.isNotEmpty ? '• $patientGender' : ''}'.trim(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(booking.scheduledTime),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(booking.scheduledTime),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.notes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (booking.price > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.currency_rupee, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '₹${booking.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (type == 'requested') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _quickReject(booking.id),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _quickAccept(booking.id),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (type == 'accepted') ...[
                const SizedBox(height: 12),
                // Check if prescription exists - show Complete Appointment button
                if (booking.prescription != null)
                  ElevatedButton.icon(
                    onPressed: () => _navigateToDetails(booking.id),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Complete Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  )
                // Check if video call is completed but no prescription yet
                else if (booking.videoCallCompleted == true)
                  ElevatedButton.icon(
                    onPressed: () => _navigateToDetails(booking.id),
                    icon: const Icon(Icons.note_add, size: 18),
                    label: const Text('Create Prescription'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  )
                // Default - start consultation
                else
                  ElevatedButton.icon(
                    onPressed: () => _navigateToDetails(booking.id),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Start Consultation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _quickAccept(String bookingId) async {
    try {
      await _apiClient.doctor.acceptAppointment(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment accepted')),
        );
        _loadAllBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _quickReject(String bookingId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Appointment'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (reason != null) {
      try {
        await _apiClient.doctor.rejectAppointment(bookingId, reason: reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment rejected')),
          );
          _loadAllBookings();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _navigateToDetails(String bookingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailsScreen(
          appointmentId: bookingId,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadAllBookings();
      }
    });
  }
}
