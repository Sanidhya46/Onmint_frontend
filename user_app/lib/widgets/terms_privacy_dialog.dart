import 'package:flutter/material.dart';

/// Shows the ONMINT Terms & Conditions / Privacy Policy in a full-screen modal.
/// Returns `true` if the user tapped "I Agree & Continue", `false` otherwise.
Future<bool> showTermsPrivacyDialog(BuildContext context, {bool isPrivacyPolicy = false}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TermsPrivacySheet(isPrivacyPolicy: isPrivacyPolicy),
  );
  return result ?? false;
}

class _TermsPrivacySheet extends StatelessWidget {
  final bool isPrivacyPolicy;
  const _TermsPrivacySheet({this.isPrivacyPolicy = false});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D6EFD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPrivacyPolicy ? Icons.privacy_tip_outlined : Icons.description_outlined,
                    color: const Color(0xFF0D6EFD),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPrivacyPolicy ? 'Privacy Policy' : 'Terms & Conditions',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF152238),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last Updated: June 2026',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Welcome to ONMINT',
                    'By accessing or using our platform, you agree to comply with the following Terms & Conditions.',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberedSection(
                    '1',
                    'Platform Services',
                    'ONMINT is a digital healthcare platform that facilitates access to:',
                    bulletPoints: [
                      'Doctor Consultation',
                      'Nursing Services',
                      'Lab Tests & Diagnostics',
                      'Medicine Delivery',
                      'Ambulance Services',
                      'Blood Bank Services',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildNumberedSection(
                    '2',
                    'User Responsibilities',
                    'Users must provide accurate information and use the platform responsibly. Misuse of healthcare or emergency services is strictly prohibited.',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberedSection(
                    '3',
                    'Healthcare Disclaimer',
                    'ONMINT acts solely as a technology platform connecting users with independent healthcare service providers. Medical advice, treatment, laboratory reports, ambulance services, and other healthcare services are the responsibility of the respective providers.',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberedSection(
                    '4',
                    'Payments & Refunds',
                    'Service charges may vary based on location and provider availability. Refunds and cancellations are subject to applicable service policies.',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberedSection(
                    '5',
                    'Limitation of Liability',
                    'ONMINT shall not be liable for medical outcomes, service delays, provider actions, technical interruptions, or circumstances beyond its reasonable control.',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberedSection(
                    '6',
                    'Modifications',
                    'ONMINT reserves the right to update these Terms & Conditions at any time. Continued use of the platform constitutes acceptance of such updates.',
                  ),
                  const SizedBox(height: 20),
                  // Contact Us
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.contact_mail_outlined, color: Color(0xFF0D6EFD), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Contact Us',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF152238),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'onmintofficial@gmail.com',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              '+91 95654 43382',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Approve Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'I Agree & Continue',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF152238),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberedSection(String number, String title, String body, {List<String>? bulletPoints}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF0D6EFD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D6EFD),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF152238),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Text(
            body,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
        if (bulletPoints != null) ...[
          const SizedBox(height: 6),
          ...bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(left: 36, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D6EFD),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}
