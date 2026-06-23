import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:api_client/api_client.dart';
import 'package:ui_components/ui_components.dart';
import '../../../config/app_colors.dart';
import '../../ambulance/ride_details_screen.dart';
import '../../ambulance/ride_requests_screen.dart';

class AmbulanceDashboard extends StatefulWidget {
  const AmbulanceDashboard({super.key});

  @override
  State<AmbulanceDashboard> createState() => _AmbulanceDashboardState();
}

class _AmbulanceDashboardState extends State<AmbulanceDashboard> {
  final _apiClient = OnMintApiClient();
  DashboardStats? _dashboardData;
  List<Booking> _activeRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      await _apiClient.initialize();
      final data = await _apiClient.ambulance.getDashboard();
      final requestsData = await _apiClient.ambulance.getRideRequests(
        page: 1,
        limit: 20,
        status: 'requested', 
      );
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _activeRequests = (requestsData['data'] as List?)?.map((e) => Booking.fromJson(e)).toList() ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastUtils.showError('Failed to load dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading 
        ? const LoadingWidget(message: 'Loading dashboard...')
        : Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  // ─── RED HEADER + STATS CARD ──────────────────────────────
                  SizedBox(
                    height: 260,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Red header
                        Container(
                          width: double.infinity,
                          height: 220,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE52329),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 24, right: 24, bottom: 40),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Circular profile image
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.8),
                                          width: 2.5),
                                      image: user?.profilePicture != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  user!.profilePicture!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: user?.profilePicture == null
                                        ? const Icon(Icons.person,
                                            size: 44, color: Color(0xFFE52329),)
                                        : null,
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?.fullName ?? 'Driver',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          _getVehicleNumber(user) ?? 'Ambulance',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Stats card
                        Positioned(
                          bottom: 0,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatColumn(
                                    '${_activeRequests.length}',
                                    "Requests",
                                  ),
                                ),
                                _buildVerticalDivider(),
                                Expanded(
                                  child: _buildStatColumn(
                                    '${_dashboardData?.activeVisits ?? 0}',
                                    "Accepted",
                                  ),
                                ),
                                _buildVerticalDivider(),
                                Expanded(
                                  child: _buildStatColumn(
                                    '${_dashboardData?.completedRides ?? _dashboardData?.totalVisits ?? 0}',
                                    "Completed",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── AMBULANCE REQUESTS HEADER ───────────────────────────────
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      children: [
                      // Section Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Ambulance Booking Requests',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE52329),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${_activeRequests.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RideRequestsScreen(),
                                ),
                              ).then((_) => _loadDashboard());
                            },
                            child: const Text(
                              'View All >',
                              style: TextStyle(
                                color: Color(0xFFE52329),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (_activeRequests.isEmpty)
                        const Center(child: Text('No requests right now.'))
                      else
                        ..._activeRequests.take(3).map((r) => _buildRequestCard(r)),

                      const SizedBox(height: 20),
                      
                      ],
                    ),
                  ),
          // Manage Consultations banner at the bottom
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5), // Light red background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment, size: 32, color: Color(0xFFE52329),),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Manage Your Consultations Easily',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Check your requests, track consultations, and manage your progress all in one place.',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE52329),)),
                        const SizedBox(width: 4),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE52329),)),
                        const SizedBox(width: 4),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE52329),)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ), // End inner Column
        ), // End SingleChildScrollView
      ), // End RefreshIndicator
    ), // End Expanded
  ],
), // End outer Column
    );
  }

  String? _getVehicleNumber(User? user) {
    if (user != null && user.vehicleNumber != null) {
      return user.vehicleNumber;
    }
    return null;
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE52329),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildRequestCard(Booking request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5), // Light ice red
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Image
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              // Name and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.patientDetails?.fullName ?? 'Unknown Patient',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.notes ?? 'Medical Emergency',
                      style: const TextStyle(
                        color: Color(0xFFE52329),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request.location.address ?? '3.1 km away',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Time and Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '06:45 PM', // Format actual time
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${request.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFFE52329),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Booking Fee',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // View Details Button
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideDetailsScreen(rideId: request.id),
                  ),
                ).then((_) => _loadDashboard());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE52329),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
