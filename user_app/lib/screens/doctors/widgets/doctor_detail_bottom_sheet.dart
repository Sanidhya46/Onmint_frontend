import 'package:flutter/material.dart';

void showDoctorDetailBottomSheet(
    BuildContext context, Map<String, dynamic> doctor) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DoctorDetailBottomSheetContent(doctor: doctor),
  );
}

class _DoctorDetailBottomSheetContent extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const _DoctorDetailBottomSheetContent({Key? key, required this.doctor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Section (Avatar + Name)
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    doctor['firstName']?.substring(0, 1) ?? 'D',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${doctor['firstName']} ${doctor['lastName']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor['specialization'] ?? 'General Physician',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Experience
            const Text(
              'EXPERIENCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${doctor['experience'] ?? 0} years experience',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '${doctor['totalConsultations'] ?? 0} online consultations completed',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            // Qualifications
            const Text(
              'QUALIFICATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (doctor['qualifications'] != null &&
                      doctor['qualifications'].isNotEmpty)
                  ? (doctor['qualifications'] as List).join(', ')
                  : 'Not provided',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 24),

            // Badges
            const Text(
              'DOCTOR BADGES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '4+',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Years with Practo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
