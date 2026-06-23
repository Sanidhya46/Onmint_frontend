import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';

import 'package:vendor_app/screens/doctor/doctor_active_consultation_screen.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final _apiClient = OnMintApiClient();
  Map<String, dynamic>? _appointment;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiClient.doctor.getAppointmentDetails(widget.appointmentId);
      setState(() {
        _appointment = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('404') || errorMsg.contains('not found')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This appointment is no longer available.')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading appointment: $e')),
          );
        }
      }
    }
  }

  Future<void> _acceptAppointment() async {
    setState(() => _isProcessing = true);
    try {
      await _apiClient.doctor.acceptAppointment(widget.appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment accepted')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorActiveConsultationScreen(
              appointmentId: widget.appointmentId,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('404') ||
            errorMsg.contains('409') ||
            errorMsg.contains('410') ||
            errorMsg.contains('not found') ||
            errorMsg.contains('already been accepted') ||
            errorMsg.contains('expired')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This appointment has already been accepted or is no longer available.')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _rejectAppointment() async {
    setState(() => _isProcessing = true);
    try {
      await _apiClient.doctor.rejectAppointment(
        widget.appointmentId,
        reason: 'Provider busy',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment rejected')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Booking Request Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : _appointment == null
              ? const Center(child: Text('Appointment not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompactDetails(),
                      const SizedBox(height: 12),
                      if (_appointment!['status'] == 'requested' ||
                          _appointment!['status'] == 'pending')
                        _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCompactDetails() {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 380 ? screenWidth / 380.0 : 1.0;
    final headingSize = 15.75 * scale; // 14 * 1.125
    final subFontSize = 12.375 * scale; // 11 * 1.125
    final patient = _appointment!['patient'] ?? {};
    final patientName = patient['fullName'] ?? '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'.trim();
    final gender = patient['gender'] ?? 'Male';
    final age = _calculateAge(patient['dateOfBirth']);
    final dateStr = _appointment!['createdAt'] ?? _appointment!['scheduledTime'];
    final formattedDate = _formatDate(dateStr);
    final formattedTime = _formatTime(dateStr);
    final problem = _appointment!['requirements']?['description'] ?? _appointment!['notes'] ?? 'Fever, Cold';
    final consultationType = _appointment!['consultationType'] ?? 'General Physician';
    
    String addressText = 'H-101, Shanti Nagar,\nGovindpuram, Ghaziabad,\nUttar Pradesh - 201013';
    if (_appointment!['location']?['address'] != null) {
      addressText = _appointment!['location']['address'];
    }

    return Column(
      children: [
        // 1. Request Summary
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Request Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.75, color: Color(0xFF152238))),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue.shade50,
                    backgroundImage: patient['profilePicture'] != null ? NetworkImage(patient['profilePicture']) : null,
                    child: patient['profilePicture'] == null ? const Icon(Icons.person, color: Colors.blue, size: 24) : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patientName.isEmpty ? 'Patient' : patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text('${age.replaceAll(" Years", " Years")} / $gender', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text('Request Date & Time', style: TextStyle(color: Colors.blue.shade700, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('$formattedDate, $formattedTime', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // 2. Patient Details
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Patient Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.75, color: Color(0xFF152238))),
              const SizedBox(height: 8),
              _buildIconRow(Icons.person_outline, 'Name', patientName.isEmpty ? 'Patient' : patientName),
              const Divider(height: 12, color: Color(0xFFF0F0F0)),
              _buildIconRow(Icons.contact_page_outlined, 'Age / Gender', '${age.replaceAll(" Years", " Years")} / $gender'),
              const Divider(height: 12, color: Color(0xFFF0F0F0)),
              _buildIconRow(Icons.location_on_outlined, 'Address', addressText),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // 3. Consultation Details
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Consultation Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.75, color: Color(0xFF152238))),
              const SizedBox(height: 8),
              _buildIconRow(Icons.medical_services_outlined, 'Consultation Type', consultationType),
              const Divider(height: 12, color: Color(0xFFF0F0F0)),
              _buildIconRow(Icons.description_outlined, 'Reason / Symptoms', problem),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 4. Request Details
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Request Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.75, color: Color(0xFF152238))),
              const SizedBox(height: 8),
              _buildIconRow(Icons.calendar_today_outlined, 'Request Date', formattedDate),
              const Divider(height: 12, color: Color(0xFFF0F0F0)),
              _buildIconRow(Icons.access_time_outlined, 'Request Time', formattedTime),
              const SizedBox(height: 8),
              
              // Additional Notes Box
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 14),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Additional Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF152238))),
                          SizedBox(height: 2),
                          Text(
                            'Once accepted, patient details will be shared with you and consultation status can be updated from your panel.',
                            style: TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconRow(IconData icon, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth < 380 ? screenWidth / 380.0 : 1.0;
    final baseFontLabel = 12.375 * scale; // 11 * 1.125
    final baseFontValue = 12.375 * scale; // 11 * 1.125
    final iconSize = 15.75 * scale; // 14 * 1.125
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize, color: Colors.blue.shade700),
        const SizedBox(width: 9), // 8 * 1.125
        SizedBox(
          width: 112, // 100 * 1.125 ≈ 112
          child: Text(label, style: TextStyle(color: Colors.black54, fontSize: baseFontLabel)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: baseFontValue, color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildCompactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1565C0)),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Divider(color: Colors.grey[200], height: 1),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : _rejectAppointment,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE52329)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE52329))),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: Color(0xFFE52329), size: 18),
                          SizedBox(width: 8),
                          Text('Reject Request', style: TextStyle(color: Color(0xFFE52329), fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : _acceptAppointment,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF43A047)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF43A047))),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Color(0xFF43A047), size: 18),
                          SizedBox(width: 8),
                          Text('Accept Request', style: TextStyle(color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _formatDateFull(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${date.day} ${months[date.month - 1]}\n${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return 'N/A';
    }
  }

  String _calculateAge(dynamic dateOfBirth) {
    if (dateOfBirth == null) return 'N/A';
    try {
      final birthDate = DateTime.parse(dateOfBirth.toString());
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return '$age Years';
    } catch (e) {
      return 'N/A';
    }
  }
}
