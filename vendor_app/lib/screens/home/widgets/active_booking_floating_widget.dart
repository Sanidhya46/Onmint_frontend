import 'package:flutter/material.dart';

class ActiveBookingFloatingWidget extends StatefulWidget {
  final String serviceType;
  final Map<String, dynamic> bookingDetails;
  final VoidCallback onTap;

  const ActiveBookingFloatingWidget({
    super.key,
    required this.serviceType,
    required this.bookingDetails,
    required this.onTap,
  });

  @override
  State<ActiveBookingFloatingWidget> createState() => _ActiveBookingFloatingWidgetState();
}

class _ActiveBookingFloatingWidgetState extends State<ActiveBookingFloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Color get _activeThemeColor {
    switch (widget.serviceType) {
      case 'ambulance':
        return Colors.red;
      case 'doctor':
        return Colors.blue;
      case 'nurse':
        return Colors.blue;
      case 'lab_test':
        return Colors.teal;
      default:
        return const Color(0xFF0D47A1);
    }
  }

  IconData get _activeIcon {
    switch (widget.serviceType) {
      case 'ambulance':
        return Icons.airport_shuttle;
      case 'doctor':
        return Icons.person;
      case 'nurse':
        return Icons.local_hospital;
      case 'lab_test':
        return Icons.science;
      default:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating Border
                Transform.rotate(
                  angle: _rotationController.value * 2 * 3.141592653589793,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                        width: 3,
                      ),
                      gradient: SweepGradient(
                        colors: [
                          _activeThemeColor.withOpacity(0.1),
                          _activeThemeColor,
                        ],
                      ),
                    ),
                  ),
                ),
                // Inner white circle to hide the middle of gradient
                Container(
                  width: 59,
                  height: 59,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                // Icon
                Icon(_activeIcon, color: _activeThemeColor, size: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
