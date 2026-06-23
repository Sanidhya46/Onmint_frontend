import 'package:flutter/material.dart';

class UserConsultationEndedScreen extends StatefulWidget {
  final String bookingId;
  final String doctorName;
  final int duration; // seconds

  const UserConsultationEndedScreen({
    super.key,
    required this.bookingId,
    required this.doctorName,
    required this.duration,
  });

  @override
  State<UserConsultationEndedScreen> createState() =>
      _UserConsultationEndedScreenState();
}

class _UserConsultationEndedScreenState
    extends State<UserConsultationEndedScreen>
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

  void _goHome() {
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
                'Your session with ${widget.doctorName} has ended.',
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
                        Icons.medical_services, 'Doctor', widget.doctorName),
                    const Divider(height: 24),
                    _buildSummaryRow(Icons.timer, 'Duration',
                        _formatDuration(widget.duration)),
                    const Divider(height: 24),
                    _buildSummaryRow(
                        Icons.videocam, 'Type', 'Video Consultation'),
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

              // Prescription info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.description, color: Colors.blue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your prescription will be shared by the doctor shortly. You can check it in your bookings.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Back to Home
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
