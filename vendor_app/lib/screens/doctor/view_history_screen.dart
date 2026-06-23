import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import '../../config/app_colors.dart';
import 'appointment_details_screen.dart';

class ViewHistoryScreen extends StatefulWidget {
  const ViewHistoryScreen({super.key});

  @override
  State<ViewHistoryScreen> createState() => _ViewHistoryScreenState();
}

class _ViewHistoryScreenState extends State<ViewHistoryScreen> {
  final _apiClient = OnMintApiClient();
  List<Booking> _completedAppointments = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _completedAppointments = [];
      });
    }

    setState(() => _isLoading = true);

    try {
      await _apiClient.initialize();
      final response = await _apiClient.doctor.getAppointments(
        status: 'completed',
        page: _currentPage,
        limit: 20,
      );

      final appointments = (response['data'] as List?)
          ?.map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      setState(() {
        if (refresh) {
          _completedAppointments = appointments;
        } else {
          _completedAppointments.addAll(appointments);
        }
        _hasMore = appointments.length >= 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation History'),
        backgroundColor: AppColors.doctor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadHistory(refresh: true),
        child: _isLoading && _completedAppointments.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _completedAppointments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _completedAppointments.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _completedAppointments.length) {
                        return _buildLoadMoreButton();
                      }
                      return _buildAppointmentCard(_completedAppointments[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No completed consultations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your consultation history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  setState(() => _currentPage++);
                  _loadHistory();
                },
                child: const Text('Load More'),
              ),
      ),
    );
  }

  Widget _buildAppointmentCard(Booking appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailsScreen(
                appointmentId: appointment.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.success.withOpacity(0.1),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patientDetails?.fullName ?? 'Patient',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_formatDate(appointment.scheduledTime)} at ${_formatTime(appointment.scheduledTime)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              
              if (appointment.consultationType != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        appointment.consultationType?.toLowerCase() == 'video_call' ||
                                appointment.consultationType?.toLowerCase() == 'video-call'
                            ? Icons.videocam
                            : Icons.person,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.consultationType!.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (appointment.prescription != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Prescription provided',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (appointment.price > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, size: 16, color: AppColors.textSecondary),
                    Text(
                      '${appointment.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
