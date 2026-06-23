import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBankAcceptedOrderScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic>? initialData;

  const BloodBankAcceptedOrderScreen({
    super.key,
    required this.bookingId,
    this.initialData,
  });

  @override
  State<BloodBankAcceptedOrderScreen> createState() => _BloodBankAcceptedOrderScreenState();
}

class _BloodBankAcceptedOrderScreenState extends State<BloodBankAcceptedOrderScreen> {
  final _apiClient = OnMintApiClient();
  bool _isLoading = true;
  Map<String, dynamic>? _booking;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _booking = widget.initialData;
      _isLoading = false;
    } else {
      _loadBooking();
    }
  }

  Future<void> _loadBooking() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/realtime/${widget.bookingId}');
      if (mounted) {
        setState(() {
          _booking = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading order details: $e')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await _apiClient.patch('/realtime/${widget.bookingId}/status', data: {'status': newStatus});
      await _loadBooking();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  Future<void> _handleConnectWithPatient(String phoneNumber, String patientName) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    
    // Update status to in_progress before calling
    await _updateStatus('in_progress');
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
      
      // Show call log confirmation dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Call Completed'),
            content: Text('Called $patientName successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Reload booking to show updated timeline
                  _loadBooking();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1A1A60))),
      );
    }

    if (_booking == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(child: Text('Order not found', style: TextStyle(color: Colors.black))),
      );
    }

    final patientData = _booking!['patientDetails'] ?? _booking!['patient'];
    final patient = (patientData is Map) ? patientData : {};
    
    final fullName = patient['fullName'] ?? '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'.trim();
    final displayName = fullName.isEmpty ? 'Rahul Verma' : fullName;
    final age = patient['age']?.toString() ?? '35';
    final gender = patient['gender'] ?? 'Male';
    final phone = patient['phone'] ?? '';
    
    // Bloodbank specific
    final units = _booking!['unitsRequired']?.toString() ?? '2';
    final isEmergency = _booking!['isEmergency'] ?? true;
    final emergencyNote = _booking!['notes'] ?? 'Urgent requirement for surgery.\nPlease help.';
    
    final locationData = _booking!['location'];
    String address;
    if (locationData is Map) {
      final addr = locationData['address'];
      if (addr is Map) {
        address = addr['address']?.toString() ?? addr['street']?.toString() ?? 'Location not specified';
      } else if (addr != null) {
        address = addr.toString();
      } else {
        address = locationData['street']?.toString() ?? locationData['city']?.toString() ?? 'Location not specified';
      }
    } else if (locationData is String && locationData.isNotEmpty) {
      address = locationData;
    } else {
      address = _booking!['hospitalName'] ?? _booking!['address']?.toString() ?? 'Location not specified';
    }

    // Dates
    String dateStr = '13 May 2025';
    String timeStr = '10:00 AM';
    if (_booking!['scheduledTime'] != null) {
      final dt = DateTime.tryParse(_booking!['scheduledTime']);
      if (dt != null) {
        dateStr = DateFormat('dd MMM yyyy').format(dt);
        timeStr = DateFormat('hh:mm a').format(dt);
      }
    }

    final status = _booking!['status'] ?? 'accepted';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A60)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Booking',
          style: TextStyle(
            color: Color(0xFF1A1A60),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: Color(0xFF1A1A60)),
            onPressed: () {
              if (phone.isNotEmpty) _makePhoneCall(phone);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadBooking,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    // User / Request Header Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            // Replace with actual avatar image
                            child: Image.asset('assets/images/male_profile.png',
                              errorBuilder: (context, _, __) => const Icon(Icons.person, size: 30, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A60),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$age Years / $gender',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.business, color: Colors.redAccent, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        address,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Patient Details Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patient Details',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRowItem(Icons.person_outline, 'Patient Name', displayName),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Color(0xFFF0F0F0), height: 1),
                          ),
                          _buildRowItem(Icons.people_outline, 'Age / Gender', '$age Years / $gender'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Color(0xFFF0F0F0), height: 1),
                          ),
                          _buildRowItem(Icons.business, 'Hospital Name', address),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Request Details Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRowItem(Icons.calendar_today_outlined, 'Date', dateStr),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Color(0xFFF0F0F0), height: 1),
                          ),
                          _buildRowItem(Icons.access_time, 'Time', timeStr),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Color(0xFFF0F0F0), height: 1),
                          ),
                          _buildRowItem(
                            Icons.shopping_bag_outlined, 
                            'Units Required', 
                            '$units Units',
                            valueColor: Colors.red,
                            valueWeight: FontWeight.bold,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Color(0xFFF0F0F0), height: 1),
                          ),
                          _buildRowItem(
                            Icons.water_drop_outlined, 
                            'Emergency Type', 
                            isEmergency ? 'Urgent' : 'Normal',
                            valueColor: isEmergency ? Colors.red : Colors.green,
                            valueWeight: FontWeight.bold,
                            iconColor: Colors.red,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Color(0xFFF0F0F0), height: 1),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.sticky_note_2_outlined, color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Emergency Note',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      emergencyNote,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Timeline
                    _buildHorizontalTimeline(status),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Action Buttons - Always Visible
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Row(
              children: [
                // Reject Button
                if (status == 'accepted' || status == 'requested')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Reject Request?'),
                            content: const Text('Are you sure you want to reject this blood request?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _updateStatus('rejected');
                                  Future.delayed(const Duration(milliseconds: 500), () {
                                    Navigator.pop(context);
                                  });
                                },
                                child: const Text('Reject', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.red.shade300, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade500,
                        ),
                      ),
                    ),
                  ),
                if (status == 'accepted' || status == 'requested')
                  const SizedBox(width: 12),
                // Accept / Call / Complete Button
                Expanded(
                  child: status == 'completed'
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
                          label: const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey.shade50,
                            side: BorderSide(color: Colors.grey.shade300, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        )
                      : status == 'accepted' || status == 'requested'
                          ? OutlinedButton.icon(
                              onPressed: () => _handleConnectWithPatient(phone, displayName),
                              icon: const Icon(Icons.phone_outlined, color: Color(0xFF0047CB)),
                              label: const Text(
                                'Call Patient',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0047CB),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFF0047CB), width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => _updateStatus('completed'),
                              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                              label: const Text(
                                'Mark Complete',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.green, width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(
    IconData icon, 
    String label, 
    String value, {
    Color? valueColor,
    FontWeight? valueWeight,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? const Color(0xFF5A6684), size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: valueWeight ?? FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalTimeline(String status) {
    int currentIndex = 0;
    if (status == 'on_the_way' || status == 'sample_collected' || status == 'in_progress') {
      currentIndex = 1;
    } else if (status == 'completed') {
      currentIndex = 2;
    }

    return Stack(
      children: [
        // Background lines
        Positioned(
          top: 11, // half of 24px circle
          left: 40,
          right: 40,
          child: Row(
            children: [
              Expanded(child: Container(height: 2, color: 0 < currentIndex ? Colors.green : Colors.grey.shade300)),
              Expanded(child: Container(height: 2, color: 1 < currentIndex ? Colors.green : Colors.grey.shade300)),
            ],
          ),
        ),
        // Nodes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildTimelineNode('Accepted', 0 <= currentIndex)),
            Expanded(child: _buildTimelineNode('Connect with Patient', 1 <= currentIndex)),
            Expanded(child: _buildTimelineNode('Completed', 2 <= currentIndex)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineNode(String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.green : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: isActive
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.green : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
