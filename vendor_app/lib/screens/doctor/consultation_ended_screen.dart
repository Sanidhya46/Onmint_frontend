import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'upload_prescription_screen.dart';

class ConsultationEndedScreen extends StatefulWidget {
  final String bookingId;
  final String patientName;
  final int duration; // seconds
  final Map<String, dynamic>? appointment;

  const ConsultationEndedScreen({
    super.key,
    required this.bookingId,
    required this.patientName,
    required this.duration,
    this.appointment,
  });

  @override
  State<ConsultationEndedScreen> createState() =>
      _ConsultationEndedScreenState();
}

class _ConsultationEndedScreenState extends State<ConsultationEndedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _checkController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  void _goToPrescription() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UploadPrescriptionScreen(
          appointmentId: widget.bookingId,
          appointment: widget.appointment,
        ),
      ),
    );
  }

  void _goToDashboard() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated checkmark
              ScaleTransition(
                scale: _checkAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade700,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Consultation Completed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF152238),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your session with ${widget.patientName} has ended.',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      Icons.person,
                      'Patient',
                      widget.patientName,
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      Icons.timer,
                      'Duration',
                      _formatDuration(widget.duration),
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      Icons.videocam,
                      'Type',
                      'Video Consultation',
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      Icons.check_circle,
                      'Status',
                      'Completed',
                      valueColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Upload prescription info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.blue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please upload the prescription for the patient to complete the consultation process.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Upload Prescription Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _goToPrescription,
                  icon: const Icon(Icons.upload_file),
                  label: const Text(
                    'Upload Prescription',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF107C41),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Dashboard
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _goToDashboard,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1565C0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? const Color(0xFF152238),
          ),
        ),
      ],
    );
  }
}
