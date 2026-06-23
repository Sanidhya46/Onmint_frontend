import 'dart:async';
import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:user_app/screens/booking/user_unified_tracking_screen.dart';
import 'package:user_app/screens/booking/user_video_call_screen.dart';
import 'package:user_app/screens/booking/user_active_consultation_screen.dart';

class OrderDetailFile extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic>? bookingData;

  const OrderDetailFile({
    Key? key,
    required this.bookingId,
    this.bookingData,
  }) : super(key: key);

  @override
  State<OrderDetailFile> createState() => _OrderDetailFileState();
}

class _OrderDetailFileState extends State<OrderDetailFile>
    with SingleTickerProviderStateMixin {
  final _apiClient = OnMintApiClient();
  final _socketService = SocketService();
  bool _isLoading = true;
  Map<String, dynamic>? _booking;
  late AnimationController _animationController;
  bool _isDoctorOnCall = false;
  StreamSubscription? _doctorJoinedSub;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadBookingDetails();
    _setupSocketListener();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _doctorJoinedSub?.cancel();
    _socketService.leaveBooking(widget.bookingId);
    super.dispose();
  }

  void _setupSocketListener() {
    _socketService.joinBooking(widget.bookingId);
    _doctorJoinedSub = _socketService.doctorJoined.listen((data) {
      if (data['bookingId'] == widget.bookingId && mounted) {
        setState(() => _isDoctorOnCall = true);
      }
    });
  }

  Future<void> _loadBookingDetails() async {
    setState(() => _isLoading = true);
    try {
      await _apiClient.initialize();
      // Fetch fresh details to get provider and precise status
      final booking =
          await _apiClient.patient.getBookingDetails(widget.bookingId);

      if (mounted) {
        setState(() {
          _booking = booking.toJson(); // Or just use the raw map if returned
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to passed booking data if api fails
      if (mounted) {
        setState(() {
          _booking = widget.bookingData;
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year} - ${date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour)}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _booking == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final booking = _booking ?? widget.bookingData ?? {};
    final status = booking['status']?.toString().toLowerCase() ?? 'pending';
    final isRequested = status == 'requested' || status == 'pending';
    final serviceType = booking['serviceType']?.toString().toLowerCase() ?? '';

    if (!isRequested &&
        (serviceType == 'bloodbank' || serviceType == 'blood bank')) {
      return UserUnifiedTrackingScreen(
        bookingId: widget.bookingId,
        serviceType: 'bloodbank',
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF152238)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Booking',
          style: TextStyle(
            color: Color(0xFF152238),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: isRequested
          ? _buildRequestedUI(booking)
          : _buildAcceptedUI(booking, status),
      bottomNavigationBar: _buildBottomBar(booking),
    );
  }

  Widget _buildBottomBar(Map<String, dynamic> booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (booking['report'] != null && booking['report'].toString().isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    String urlStr = booking['report'].toString().trim();
                    urlStr = urlStr.replaceAll('"', '');
                    urlStr = urlStr.replaceAll(':5000api', ':5000/api');
                    urlStr = urlStr.replaceAll('localhost', '192.168.1.6');
                    
                    if (!urlStr.startsWith('http')) {
                      urlStr = 'http://192.168.1.6:5000' + (urlStr.startsWith('/') ? urlStr : '/$urlStr');
                    }
                    
                    final uri = Uri.parse(urlStr);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      debugPrint('Could not launch $urlStr');
                    }
                  } catch (e) {
                    debugPrint('Error launching url: $e');
                  }
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('View Lab Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0),
                side: const BorderSide(color: Color(0xFF1565C0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Need help?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestedUI(Map<String, dynamic> booking) {
    final createdAt = booking['createdAt']?.toString() ??
        booking['scheduledTime']?.toString() ??
        '';
    final patient = (booking['patient'] is Map) ? booking['patient'] : {};
    final serviceType =
        booking['serviceType']?.toString().toLowerCase() ?? 'lab_test';
    final pName = patient['fullName'] ??
        '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'.trim();
    final pPhone = patient['phone'] ?? '+91 0000000000';
    final pAge = patient['age'] ?? '35';
    final address = booking['location']?['address'] ?? 'Not specified';
    final testName = (booking['tests'] != null &&
            booking['tests'] is List &&
            booking['tests'].isNotEmpty)
        ? booking['tests'][0]['name'] ?? 'Lab Test'
        : 'Lab Test';
    final bloodGroup = booking['bloodGroup']?.toString() ?? 'Unknown';
    final units = booking['units']?.toString() ?? '1';

    String topTitle;
    String waitText;
    String imagePath;
    String waitCardTitle;
    String waitCardSub;

    switch (serviceType) {
      case 'doctor':
        topTitle = 'Doctor Consultation';
        waitText = 'We are waiting for a doctor to accept\nyour request.';
        imagePath = 'assets/images/request/order/doctor.png';
        waitCardTitle = 'Waiting for doctor to accept';
        waitCardSub = 'We will notify you once a doctor accepts your request.';
        break;
      case 'nurse':
        topTitle = 'Nursing Care';
        waitText =
            'We are waiting for a nurse provider to accept\nyour request.';
        imagePath = 'assets/images/request/order/nurse.png';
        waitCardTitle = 'Waiting for nurse to accept';
        waitCardSub = 'We will notify you once a nurse accepts your request.';
        break;
      case 'ambulance':
        topTitle = 'Ambulance Booking';
        waitText =
            'We are waiting for an ambulance provider to accept\nyour request.';
        imagePath = 'assets/images/request/order/ambulance.png';
        waitCardTitle = 'Waiting for ambulance to accept';
        waitCardSub =
            'We will notify you once an ambulance accepts your request.';
        break;
      case 'bloodbank':
      case 'blood bank':
        topTitle = 'Blood Request';
        waitText = 'We are waiting for a blood unit to accept\nyour request.';
        imagePath = 'assets/images/request/order/bloodbank.png';
        waitCardTitle = 'Waiting for blood bank to accept';
        waitCardSub =
            'We will notify you once a blood bank accepts your request.';
        break;
      case 'pathology':
      case 'lab_test':
      case 'lab test':
      default:
        topTitle = 'Lab Test Booking';
        waitText = 'We are waiting for a lab partner to accept\nyour request.';
        imagePath = 'assets/images/request/order/labtest.png';
        waitCardTitle = 'Waiting for lab partner to accept';
        waitCardSub =
            'We will notify you once a technician accepts your request.';
        break;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF152238),
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Image Section
            Image.asset(
              imagePath,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to hourglass if asset missing
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * 2.0 * math.pi,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hourglass_empty,
                          size: 50,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Request Sent Successfully',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF152238),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              waitText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Booking Details Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF152238),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Patient Name', pName),
                  const SizedBox(height: 16),
                  _buildDetailRow('Phone Number', pPhone),
                  const SizedBox(height: 16),
                  _buildDetailRow('Age', '$pAge Years'),
                  if (serviceType == 'pathology' ||
                      serviceType == 'lab_test' ||
                      serviceType == 'lab test') ...[
                    const SizedBox(height: 16),
                    _buildDetailRow('Test Name', testName),
                  ],
                  if (serviceType == 'bloodbank' ||
                      serviceType == 'blood bank') ...[
                    const SizedBox(height: 16),
                    _buildDetailRow('Blood Group', bloodGroup),
                    const SizedBox(height: 16),
                    _buildDetailRow('Units', units),
                  ],
                  const SizedBox(height: 16),
                  _buildDetailRow('Location', address),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Waiting Status Card
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline,
                        color: Color(0xFF1565C0)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          waitCardTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF152238),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          waitCardSub,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedUI(Map<String, dynamic> booking, String status) {
    final providerData = booking['provider'] ?? booking['acceptedProvider'];
    final provider = (providerData is Map) ? providerData : {};
    final prName = provider['fullName'] ??
        '${provider['firstName'] ?? ''} ${provider['lastName'] ?? ''}'.trim();
    final prRating = provider['rating']?.toString() ?? '4.8';
    final prPhone = provider['phone']?.toString() ?? '';

    // Status map
    final steps = [
      {'key': 'accepted', 'title': 'Request Accepted'},
      {'key': 'on_the_way', 'title': 'On The Way'},
      {'key': 'sample_collected', 'title': 'Sample Collected'},
      {'key': 'report_ready', 'title': 'Report Ready'},
      {'key': 'completed', 'title': 'Completed'},
    ];

    int currentIndex = -1;
    if (status == 'accepted')
      currentIndex = 0;
    else if (status == 'on_the_way')
      currentIndex = 1;
    else if (status == 'sample_collected')
      currentIndex = 2;
    else if (status == 'report_ready')
      currentIndex = 3;
    else if (status == 'completed') currentIndex = 4;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Technician Card
            const Text(
              'Your Technician',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF152238),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/male_profile.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prName.isNotEmpty ? prName : 'Lab Technician',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF152238),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              prRating,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (prPhone.isNotEmpty) {
                            final uri = Uri.parse('tel:$prPhone');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.call,
                              color: Colors.green, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          // TODO: implement chat
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat,
                              color: Colors.blue, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Doctor On Call - Join Call Banner
            if (booking['serviceType']?.toString().toLowerCase() == 'doctor' &&
                (_isDoctorOnCall || booking['doctor_on_call'] == true) &&
                booking['consultation_ended'] != true)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF107C41), Color(0xFF0D6634)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Doctor is Ready — Join Call Now!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final provD = booking['provider'] ?? booking['acceptedProvider'] ?? {};
                          final drName = provD['fullName'] ??
                              '${provD['firstName'] ?? ''} ${provD['lastName'] ?? ''}'.trim();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserVideoCallScreen(
                                bookingId: widget.bookingId,
                                doctorName: drName.isEmpty ? 'Doctor' : drName,
                                doctorImage: provD['profilePicture'],
                              ),
                            ),
                          ).then((_) => _loadBookingDetails());
                        },
                        icon: const Icon(Icons.videocam, size: 20),
                        label: const Text('Join Video Call',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF107C41),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Live Status
            const Text(
              'Live Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF152238),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(steps.length, (index) {
                  final isActive = index <= currentIndex;
                  final isLast = index == steps.length - 1;
                  return _buildTimelineStep(
                    title: steps[index]['title']!,
                    isActive: isActive,
                    isLast: isLast,
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF152238),
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep(
      {required String title, required bool isActive, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? Colors.green : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? const Color(0xFF152238) : Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}
