import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'dart:io';

import '../../config/app_colors.dart';
import '../../config/app_config.dart';
import '../../data/indian_states_cities.dart';
import '../../widgets/terms_privacy_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isFetchingLocation = false;

  // Step 1 Fields
  final _formKey1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedGender;
  String? _selectedRole;
  String _selectedCountryCode = '+91';
  bool _obscurePassword = true;
  bool _termsAccepted = false;

  // Step 2 Fields
  final _formKey2 = GlobalKey<FormState>();
  // Shared step 2 (Lab/Pathology/General)
  final _labNameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _ownerController = TextEditingController();
  final _labMobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Ambulance Step 2 Fields
  final _ambulanceFormKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverMobileController = TextEditingController();
  final _driverLicenseController = TextEditingController();
  String? _selectedAmbulanceType;
  final List<String> _ambulanceTypes = [
    'Basic',
    'Advanced Life Support',
    'ICU Ambulance'
  ];

  // Blood Bank State
  final _bloodBankNameController = TextEditingController();
  final _bloodBankLicenseController = TextEditingController();
  final _bloodBankInchargeController = TextEditingController();
  final _bloodBankContactController = TextEditingController();
  final Map<String, bool> _bloodBankServicesState = {
    'Blood Collection': false,
    'Blood Component Supply': false,
    'Emergency Blood Supply': false,
    'Blood Testing': false,
  };
  XFile? _bloodBankFrontPhoto;
  XFile? _bloodBankLicenseCert;
  XFile? _bloodBankInchargeAadhaar;


  // Nurse Step 2 Fields
  final _nurseExperienceController = TextEditingController();
  final _nurseRegNumberController = TextEditingController();
  final Map<String, bool> _nurseServicesState = {
    'Home Nursing Care': true,
    'Elderly Care': true,
    'Post Surgery Care': true,
    'Patient Attendant': false,
    'Injection & Dressing': true,
    'General Nursing Care': true,
  };

  String? _selectedState;
  Position? _currentPosition;
  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  // Step 3 Fields
  XFile? _profilePhoto;
  XFile? _govId;
  XFile? _labLicense;
  XFile? _gstCert;

  // Ambulance Step 3 Fields
  XFile? _ambulanceRC;
  XFile? _drivingLicense;
  XFile? _insuranceCopy;

  // Nurse Step 3 Fields
  XFile? _nurseExperienceCert;

  // Doctor Step 2 Fields
  final _doctorExperienceController = TextEditingController();
  final _doctorRegNumberController = TextEditingController();
  final _doctorFeeController = TextEditingController();
  String? _selectedSpecialization = 'Internal Medicine';
  final List<String> _specializations = [
    'Internal Medicine',
    'General Physician',
    'Dermatology',
    'Gynecology',
    'Mental Wellness',
    'Sexology',
    'Stomach & Digestion',
    'Pediatrics',
    'Orthodpedic'
  ];
  final Map<String, bool> _doctorConsultationTypeState = {
    'Video Call': true,
    'Audio Call': true,
  };
  final Map<String, bool> _doctorLanguagesState = {
    'English': true,
    'Hindi': true,
    'Kannada': false,
    'Other': false,
  };


  // Pharmacist Step 2 Fields
  final _pharmacyNameController = TextEditingController();
  final _pharmacistNameController = TextEditingController();
  final _pharmacistRegNumberController = TextEditingController();
  final _pharmacistDrugLicenseController = TextEditingController();
  final Map<String, bool> _pharmacistServicesState = {
    'Prescription Medicines': true,
    'Generic Medicines': true,
    'Healthcare Products': true,
    'Medical Equipment': true,
  };

  // Pharmacist Step 3 Fields
  XFile? _pharmacistRegistrationCert;

  // Doctor Step 3 Fields
  XFile? _doctorDegreeCert;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _services = [
    'doctor',
    'nurse',
    'ambulance',
    'pharmacist',
    'bloodbank',
    'pathology',
    'labtest',
  ];
  final List<String> _countryCodes = [
    '+91',
    '+1',
    '+44',
    '+61',
    '+81',
    '+86',
    '+49',
    '+33',
    '+7',
    '+55'
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _labNameController.dispose();
    _licenseController.dispose();
    _ownerController.dispose();
    _labMobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();

    _vehicleNumberController.dispose();
    _driverNameController.dispose();
    _driverMobileController.dispose();

    _nurseExperienceController.dispose();
    _nurseRegNumberController.dispose();
    _pharmacyNameController.dispose();
    _pharmacistNameController.dispose();
    _pharmacistRegNumberController.dispose();
    _pharmacistDrugLicenseController.dispose();
    _driverLicenseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey1.currentState!.validate()) {
        return;
      }
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please accept terms & conditions')));
        return;
      }
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select gender')));
        return;
      }
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a service')));
        return;
      }
      if (_selectedRole != 'labtest' &&
          _selectedRole != 'pathology' &&
          _selectedRole != 'ambulance' &&
          _selectedRole != 'nurse' &&
          _selectedRole != 'pharmacist' &&
          _selectedRole != 'doctor' &&
          _selectedRole != 'bloodbank') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => Scaffold(
                    appBar: AppBar(),
                    body: const Center(child: Text('Service Coming Soon')))));
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedRole == 'ambulance') {
        if (!_ambulanceFormKey.currentState!.validate()) return;
        if (_selectedAmbulanceType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select ambulance type')));
          return;
        }
        if (_selectedState == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select state')));
          return;
        }
      } else {
        if (!_formKey2.currentState!.validate()) return;
      }
      setState(() => _currentStep = 2);
    }
  }

  Future<void> _pickImage(String type) async {
    if (type == 'profile') {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _profilePhoto = image);
      return;
    }

    fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      withData: true, // Needed for web
    );

    if (result != null && result.files.isNotEmpty) {
      final pickedFile = result.files.first;
      XFile file;

      if (pickedFile.bytes != null) {
        // Web support
        file = XFile.fromData(pickedFile.bytes!, name: pickedFile.name);
      } else if (pickedFile.path != null) {
        // Native support
        file = XFile(pickedFile.path!);
      } else {
        return;
      }

      setState(() {
        if (type == 'pharmacist_reg')
          _pharmacistRegistrationCert = file;
        else if (type == 'govid')
          _govId = file;
        else if (type == 'license')
          _labLicense = file;
        else if (type == 'gst')
          _gstCert = file;
        else if (type == 'ambulanceRC')
          _ambulanceRC = file;
        else if (type == 'drivingLicense')
          _drivingLicense = file;
        else if (type == 'insuranceCopy') 
          _insuranceCopy = file;
        else if (type == 'nurseExperience') 
          _nurseExperienceCert = file;
        else if (type == 'doctorDegree')
          _doctorDegreeCert = file;
        else if (type == 'bb_front')
          _bloodBankFrontPhoto = file;
        else if (type == 'bb_license')
          _bloodBankLicenseCert = file;
        else if (type == 'bb_aadhaar')
          _bloodBankInchargeAadhaar = file;
      });
    }
  }

  void _submit() async {
    if (_selectedRole == 'ambulance') {
      if (_profilePhoto == null ||
          _govId == null ||
          _ambulanceRC == null ||
          _drivingLicense == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please upload all mandatory documents')));
        return;
      }
    } else if (_selectedRole == 'doctor') {
      if (_profilePhoto == null || _govId == null || _labLicense == null || _doctorDegreeCert == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please upload all mandatory documents')));
        return;
      }
    } else if (_selectedRole == 'bloodbank') {
      if (_bloodBankFrontPhoto == null || _bloodBankLicenseCert == null || _bloodBankInchargeAadhaar == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please upload all mandatory documents')));
        return;
      }
    } else {
      if (_profilePhoto == null || _govId == null || _labLicense == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please upload all mandatory documents')));
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      String backendRole = _selectedRole?.toLowerCase() ?? 'pathology';
      if (backendRole == 'labtests' ||
          backendRole == 'labtest' ||
          backendRole == 'lab test' ||
          backendRole == 'lab tests') {
        backendRole = 'pathology';
      } else if (backendRole == 'pharmacy') {
        backendRole = 'pharmacist';
      }

      double lat = 0.0;
      double lng = 0.0;
      if (_currentPosition != null) {
        lat = _currentPosition!.latitude;
        lng = _currentPosition!.longitude;
      }

      final Map<String, dynamic> reqData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'role': backendRole,
        'firstName': _nameController.text.trim().split(' ').first,
        'lastName': _nameController.text.trim().split(' ').length > 1
            ? _nameController.text.trim().split(' ').last
            : '',
        'phone': '$_selectedCountryCode${_phoneController.text.trim()}',
        'city': _cityController.text.trim(),
        'state': _selectedState ?? '',
        'pincode': _pincodeController.text.trim(),
        'location[type]': 'Point',
        'location[coordinates][0]': lng.toString(),
        'location[coordinates][1]': lat.toString(),
      };

      if (backendRole == 'pharmacist') {
        reqData['pharmacyName'] = _pharmacyNameController.text.trim();
        reqData['licenseNumber'] = _licenseController.text.trim();
        reqData['pharmacistName'] = _pharmacistNameController.text.trim();
        reqData['pharmacistRegistrationNumber'] = _pharmacistRegNumberController.text.trim();
        
        // Add services
        final selectedServices = _pharmacistServicesState.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
        for (int i = 0; i < selectedServices.length; i++) {
          reqData['servicesAvailable[$i]'] = selectedServices[i];
        }
      } else if (backendRole == 'ambulance') {
        reqData['vehicleNumber'] = _vehicleNumberController.text.trim();
        reqData['vehicleType'] = _selectedAmbulanceType ?? 'Basic';
        reqData['driverName'] = _driverNameController.text.trim();
        reqData['driverMobileNumber'] =
            '+91${_driverMobileController.text.trim()}';
        reqData['driverLicense'] = _driverLicenseController.text.trim();
        reqData['currentLocation[type]'] = 'Point';
        reqData['currentLocation[coordinates][0]'] = lng.toString();
        reqData['currentLocation[coordinates][1]'] = lat.toString();
      } else if (backendRole == 'nurse') {
        reqData['experience'] = int.tryParse(_nurseExperienceController.text.trim()) ?? 0;
        reqData['licenseNumber'] = _nurseRegNumberController.text.trim();
        List<String> specializations = [];
        _nurseServicesState.forEach((key, value) {
          if (value) specializations.add(key);
        });
        for (int i = 0; i < specializations.length; i++) {
          reqData['specializations[$i]'] = specializations[i];
        }
      } else if (backendRole == 'doctor') {
        reqData['experience'] = int.tryParse(_doctorExperienceController.text.trim()) ?? 0;
        reqData['licenseNumber'] = _doctorRegNumberController.text.trim();
        reqData['specialization'] = _selectedSpecialization ?? 'Internal Medicine';
        reqData['consultationFee'] = int.tryParse(_doctorFeeController.text.trim()) ?? 0;
        
        List<String> consultationTypes = [];
        if (_doctorConsultationTypeState['Video Call'] == true) consultationTypes.add('video-call');
        if (_doctorConsultationTypeState['Audio Call'] == true) consultationTypes.add('audio-call');
        if (consultationTypes.isEmpty) consultationTypes.add('video-call');
        
        for (int i = 0; i < consultationTypes.length; i++) {
          reqData['consultationTypes[$i]'] = consultationTypes[i];
        }

        List<String> languages = [];
        _doctorLanguagesState.forEach((key, value) {
          if (value) languages.add(key);
        });
        for (int i = 0; i < languages.length; i++) {
          reqData['languages[$i]'] = languages[i];
        }
      } else if (backendRole == 'bloodbank') {
        if (_bloodBankNameController.text.trim().isEmpty || 
            _bloodBankLicenseController.text.trim().isEmpty ||
            _bloodBankInchargeController.text.trim().isEmpty ||
            _bloodBankContactController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please go back to Step 2 and fill all required details')));
          return;
        }
        reqData['bankName'] = _bloodBankNameController.text.trim();
        reqData['licenseNumber'] = _bloodBankLicenseController.text.trim();
        reqData['inchargeName'] = _bloodBankInchargeController.text.trim();
        reqData['emergencyContact'] = _bloodBankContactController.text.trim();

        final selectedBBServices = _bloodBankServicesState.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
        for (int i = 0; i < selectedBBServices.length; i++) {
          reqData['servicesAvailable[$i]'] = selectedBBServices[i];
        }
      } else {
        reqData['labName'] = _labNameController.text.trim();
        reqData['licenseNumber'] = _licenseController.text.trim();
        reqData['ownerName'] = _ownerController.text.trim();
      }

      Map<String, XFile> namedFilesToUpload = {};
      if (_profilePhoto != null) {
        namedFilesToUpload['profilePicture'] = _profilePhoto!;
      }
      if (_govId != null) namedFilesToUpload['idProof'] = _govId!;

      if (backendRole == 'ambulance') {
        if (_ambulanceRC != null)
          namedFilesToUpload['registration'] = _ambulanceRC!;
        if (_drivingLicense != null)
          namedFilesToUpload['license'] = _drivingLicense!;
        if (_insuranceCopy != null)
          namedFilesToUpload['insurance'] = _insuranceCopy!;
      } else if (backendRole == 'nurse') {
        if (_labLicense != null) namedFilesToUpload['registration'] = _labLicense!;
        if (_nurseExperienceCert != null) namedFilesToUpload['experience'] = _nurseExperienceCert!;
      } else if (backendRole == 'doctor') {
        if (_labLicense != null) namedFilesToUpload['registration'] = _labLicense!;
        if (_doctorDegreeCert != null) namedFilesToUpload['certificate'] = _doctorDegreeCert!;
      } else if (backendRole == 'bloodbank') {
        if (_bloodBankFrontPhoto != null) namedFilesToUpload['profilePicture'] = _bloodBankFrontPhoto!;
        if (_bloodBankLicenseCert != null) namedFilesToUpload['license'] = _bloodBankLicenseCert!;
        if (_bloodBankInchargeAadhaar != null) namedFilesToUpload['idProof'] = _bloodBankInchargeAadhaar!;
        if (_gstCert != null) namedFilesToUpload['certificate'] = _gstCert!;
      } else {
        if (_labLicense != null) namedFilesToUpload['license'] = _labLicense!;
        if (_gstCert != null) namedFilesToUpload['certificate'] = _gstCert!;
      }

      await authProvider.register(reqData, namedXFiles: namedFilesToUpload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')));
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        setState(() => _currentStep = 0);
        final errorMsg = e.toString()
            .replaceAll('Exception: ', '')
            .replaceAll('Registration failed: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMsg, style: const TextStyle(fontSize: 12))),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFieldContainer({
    required IconData icon,
    required String label,
    required Widget child,
    Widget? suffixWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF0033CC), size: 20),
              const SizedBox(width: 8),
              Expanded(child: child),
              if (suffixWidget != null) suffixWidget,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? prefixWidget,
    Widget? suffixWidget,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      validator: (val) => validator?.call(controller.text),
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldContainer(
              icon: icon,
              label: label,
              suffixWidget: suffixWidget,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (prefixWidget != null) prefixWidget,
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      obscureText: obscureText,
                      onChanged: (val) => state.didChange(val),
                      style: const TextStyle(fontSize: 12, height: 1.2),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        hintText: hint,
                        hintStyle: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(state.errorText ?? '',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 10)),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 0) return _buildStep1();
    if (_currentStep == 1) {
      if (_selectedRole == 'ambulance') return _buildAmbulanceStep2();
      if (_selectedRole == 'nurse') return _buildNurseStep2();
      if (_selectedRole == 'doctor') return _buildDoctorStep2();
      if (_selectedRole == 'pharmacist') return _buildPharmacistStep2();
      if (_selectedRole == 'bloodbank') return _buildBloodBankStep2();
      return _buildStep2();
    }
    if (_selectedRole == 'ambulance') return _buildAmbulanceStep3();
    if (_selectedRole == 'nurse') return _buildNurseStep3();
    if (_selectedRole == 'doctor') return _buildDoctorStep3();
    if (_selectedRole == 'pharmacist') return _buildPharmacistStep3();
    if (_selectedRole == 'bloodbank') return _buildBloodBankStep3();
    return _buildStep3();
  }

  Widget _buildStep1() {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Column(
        children: [
          Image.asset(
            'images/register_login/top_banner.jpeg',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(24), // Larger border radius
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Form(
                    key: _formKey1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0033CC),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.person_outline,
                                          color: Colors.white, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Create Your Profile',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            'Please fill in your details to continue',
                                            style: TextStyle(
                                                fontSize: 10, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 6), // Tighter gap

                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildTextField(
                                      controller: _nameController,
                                      icon: Icons.person_outline,
                                      label: 'Full Name',
                                      hint: 'Enter your full name',
                                      validator: (v) =>
                                          v!.isEmpty ? 'Required' : null,
                                    ),
                                    const SizedBox(
                                        height:
                                            4), // Drastically reduced vertical padding

                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: _buildTextField(
                                            controller: _ageController,
                                            icon: Icons.calendar_month_outlined,
                                            label: 'Age',
                                            hint: 'Enter your age',
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                v!.isEmpty ? 'Required' : null,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 5,
                                          child: _buildFieldContainer(
                                            icon: Icons.transgender,
                                            label: 'Gender',
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: _selectedGender,
                                                hint: Text('Select gender',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .grey.shade400)),
                                                items: _genders
                                                    .map((g) => DropdownMenuItem(
                                                        value: g,
                                                        child: Text(g, overflow: TextOverflow.ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12))))
                                                    .toList(),
                                                onChanged: (v) => setState(
                                                    () => _selectedGender = v),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    _buildFieldContainer(
                                      icon: Icons.favorite_border,
                                      label: 'Choose Your Service',
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: _selectedRole,
                                          hint: Text('Select a service',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade400)),
                                          items: _services
                                              .map((s) => DropdownMenuItem(
                                                  value: s,
                                                  child: Text(s.toUpperCase(), overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 12))))
                                              .toList(),
                                          onChanged: (v) =>
                                              setState(() => _selectedRole = v),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    _buildTextField(
                                      controller: _phoneController,
                                      icon: Icons.call_outlined,
                                      label: 'Mobile Number',
                                      hint: 'Enter mobile number',
                                      keyboardType: TextInputType.phone,
                                      prefixWidget: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(width: 4),
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _selectedCountryCode,
                                              items: _countryCodes
                                                  .map((c) => DropdownMenuItem(
                                                      value: c,
                                                      child: Text(c, overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xFF0033CC),
                                                              fontSize: 12))))
                                                  .toList(),
                                              onChanged: (v) => setState(() =>
                                                  _selectedCountryCode = v!),
                                              icon: const SizedBox.shrink(),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                      ),
                                      validator: (v) => v!.length != 10
                                          ? 'Enter valid 10 digit number'
                                          : null,
                                    ),
                                    const SizedBox(height: 4),

                                    _buildTextField(
                                      controller: _emailController,
                                      icon: Icons.mail_outline,
                                      label: 'Email Address',
                                      hint: 'Enter email address',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) => !v!.contains('@')
                                          ? 'Enter valid email'
                                          : null,
                                    ),
                                    const SizedBox(height: 4),

                                    _buildTextField(
                                      controller: _passwordController,
                                      icon: Icons.lock_outline,
                                      label: 'Create Password',
                                      hint: 'Enter your password',
                                      obscureText: _obscurePassword,
                                      suffixWidget: GestureDetector(
                                        onTap: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                        child: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.black87,
                                            size: 20),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty)
                                          return 'Required';
                                        if (v.length < 8) return 'Min 8 chars';
                                        if (!RegExp(r'[A-Z]').hasMatch(v))
                                          return 'Needs uppercase';
                                        if (!RegExp(r'[a-z]').hasMatch(v))
                                          return 'Needs lowercase';
                                        if (!RegExp(r'[0-9]').hasMatch(v))
                                          return 'Needs number';
                                        if (!RegExp(r'[@#$%^&*(),.?":{}|<>]')
                                            .hasMatch(v))
                                          return 'Needs special char';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _termsAccepted,
                                        onChanged: (v) =>
                                            setState(() => _termsAccepted = v!),
                                        activeColor: const Color(0xFF0033CC),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'I agree to the ',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.black87),
                                          children: [
                                            TextSpan(
                                                text: 'Terms & Conditions',
                                                style: const TextStyle(
                                                    color: Color(0xFF0033CC),
                                                    fontWeight:
                                                        FontWeight.bold),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () async {
                                                    final approved = await showTermsPrivacyDialog(context);
                                                    if (approved) {
                                                      setState(() => _termsAccepted = true);
                                                    }
                                                  },
                                            ),
                                            const TextSpan(text: ' and '),
                                            TextSpan(
                                                text: 'Privacy Policy',
                                                style: const TextStyle(
                                                    color: Color(0xFF0033CC),
                                                    fontWeight:
                                                        FontWeight.bold),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () async {
                                                    final approved = await showTermsPrivacyDialog(context, isPrivacyPolicy: true);
                                                    if (approved) {
                                                      setState(() => _termsAccepted = true);
                                                    }
                                                  },
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.visible,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            SizedBox(
                              height:
                                  42, // Slightly reduced continue button height
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0033CC),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: _nextStep,
                                child: const Text('CONTINUE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account? ',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                                InkWell(
                                  onTap: () => Navigator.pushReplacementNamed(
                                      context, '/login'),
                                  child: const Text('Login',
                                      style: TextStyle(
                                          color: Color(0xFF0033CC),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    print(
        'Captured Location: Lat: ${position.latitude}, Lng: ${position.longitude}');
    setState(() => _currentPosition = position);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Text('Location captured: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}', 
                style: TextStyle(color: Colors.red, fontSize: 11)),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.red, width: 1),
          ),
          duration: const Duration(milliseconds: 1500),
      ));
    }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }


  Widget _buildBloodBankStep2() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Blood Bank Details',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Tell us about your blood bank and license information',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Form(
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4))
                            ]),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              label: 'Blood Bank Name',
                              hint: 'Enter blood bank name',
                              controller: _bloodBankNameController,
                              icon: Icons.local_hospital_outlined,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter blood bank name' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'License Number',
                              hint: 'ex. DL-123456',
                              controller: _bloodBankLicenseController,
                              icon: Icons.description_outlined,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter license number' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Blood Bank In-charge Name',
                              hint: 'Enter in-charge name',
                              controller: _bloodBankInchargeController,
                              icon: Icons.person_outline,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter in-charge name' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Emergency Contact No.',
                              hint: 'Enter mobile number',
                              controller: _bloodBankContactController,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter contact number' : null,
                            ),
                            const SizedBox(height: 16),
                            const Text('Services Available',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const Text('Select all that apply',
                                style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _bloodBankServicesState.keys.map((service) {
                                bool isSelected = _bloodBankServicesState[service]!;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _bloodBankServicesState[service] = !isSelected;
                                    });
                                  },
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width - 84) / 2,
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          service.contains('Collection') ? Icons.water_drop_outlined :
                                          service.contains('Supply') ? Icons.bloodtype_outlined :
                                          service.contains('Emergency') ? Icons.emergency_outlined :
                                          Icons.science_outlined,
                                          color: const Color(0xFF0033CC),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(service,
                                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500)),
                                        ),
                                        Icon(
                                          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                          color: isSelected ? const Color(0xFF0033CC) : Colors.grey,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                              label: 'Address',
                              hint: 'Enter complete address',
                              controller: _addressController,
                              icon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildLocationRow(),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Current Location',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87),
                                              ),
                                              Text(
                                                'Detect your blood bank location on map',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 10, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 1,
                                          child: TextButton.icon(
                                  onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                                  icon: _isFetchingLocation 
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0033CC)))
                                      : const Icon(Icons.my_location, size: 16, color: Color(0xFF0033CC)),
                                  label: Text(
                                    _isFetchingLocation ? 'Fetching...' : 'Use Current Location',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0033CC)),
                                  ),
                                  style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blue.shade100.withOpacity(0.5
                                ),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                            'images/register_login/map_placeholder.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: _currentPosition != null
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.location_on,
                                                    color: Colors.red, size: 40),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 4)
                                                    ],
                                                  ),
                                                  child: Text(
                                                    '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                ],
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, offset: Offset(0, -2), blurRadius: 10)
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey2.currentState!.validate() && _selectedState != null) {
                    _nextStep();
                  } else if (_selectedState == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a state')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0033CC),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('NEXT',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLocationRow() {
    final cities = _selectedState != null
        ? IndianStatesData.getCitiesForState(_selectedState!)
        : <String>[];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('State',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000B22))),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Autocomplete<String>(
                  initialValue: TextEditingValue(text: _selectedState ?? ''),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) return IndianStatesData.states;
                    return IndianStatesData.states.where((s) =>
                        s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _selectedState = selection;
                      _cityController.clear();
                    });
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Search state',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: controller.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  controller.clear();
                                  setState(() { _selectedState = null; _cityController.clear(); });
                                },
                                child: Icon(Icons.close, size: 16, color: Colors.grey.shade400))
                            : const Icon(Icons.arrow_drop_down, size: 20),
                        suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                      onChanged: (val) {
                        if (!IndianStatesData.states.contains(val)) {
                          setState(() { _selectedState = null; _cityController.clear(); });
                        }
                      },
                      validator: (v) => (v == null || v.isEmpty || _selectedState == null) ? 'Required' : null,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Text(option, style: const TextStyle(fontSize: 12)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('City',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000B22))),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: _selectedState == null ? Colors.grey.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Autocomplete<String>(
                  key: ValueKey(_selectedState),
                  initialValue: TextEditingValue(text: _cityController.text),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (_selectedState == null) return const Iterable<String>.empty();
                    if (textEditingValue.text.isEmpty) return cities;
                    return cities.where((c) =>
                        c.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    setState(() { _cityController.text = selection; });
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: _selectedState != null,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: _selectedState == null ? 'Select state' : 'Search city',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: controller.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  controller.clear();
                                  setState(() { _cityController.clear(); });
                                },
                                child: Icon(Icons.close, size: 16, color: Colors.grey.shade400))
                            : const Icon(Icons.arrow_drop_down, size: 20),
                        suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                      onChanged: (val) {
                        if (!cities.contains(val)) setState(() { _cityController.text = val; });
                      },
                      validator: (v) => (v == null || v.isEmpty || _cityController.text.isEmpty) ? 'Required' : null,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Text(option, style: const TextStyle(fontSize: 12)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pincode',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000B22))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), // Match height of dropdowns
                  hintText: 'Enter pincode',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lab Details & Location',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Enter your lab information',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lab Details Section
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ]),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.science_outlined,
                              color: Color(0xFF0033CC), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text('Lab Details',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _labNameController,
                      icon: Icons.business,
                      label: 'Lab / Pathology Name',
                      hint: 'Enter lab or pathology name',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _licenseController,
                      icon: Icons.assignment_outlined,
                      label: 'License Number',
                      hint: 'ex. DL-123456',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _ownerController,
                      icon: Icons.person_outline,
                      label: 'Owner Name',
                      hint: 'Enter owner name',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _labMobileController,
                      icon: Icons.call_outlined,
                      label: 'Mobile Number',
                      hint: 'Enter mobile number',
                      keyboardType: TextInputType.phone,
                      prefixWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 4),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryCode,
                              items: _countryCodes
                                  .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0033CC),
                                              fontSize: 12))))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCountryCode = v!),
                              icon: const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                      validator: (v) =>
                          v!.length != 10 ? 'Enter 10 digits' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Service Location Section
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ]),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.location_on_outlined,
                              color: Color(0xFF0033CC), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text('Service Location',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _addressController,
                      icon: Icons.location_on_outlined,
                      label: 'Full Address',
                      hint: 'Enter full address',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildLocationRow(),
                    const SizedBox(height: 12),

                    // Current Location Box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                      text: 'Current Location ',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87),
                                      children: [
                                        TextSpan(
                                            text: '(Optional)',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey)),
                                      ]),
                                ),
                                Text('Use your current location on map',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: TextButton.icon(
                                    onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                                    icon: _isFetchingLocation 
                                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0033CC)))
                                        : const Icon(Icons.my_location, size: 16, color: Color(0xFF0033CC)),
                                    label: Text(
                                      _isFetchingLocation ? 'Fetching...' : 'Use Current Location',
                                      
                                      style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0033CC)),
                                    ),
                                    style: TextButton.styleFrom(
                                backgroundColor:
                                    Colors.blue.shade100.withOpacity(0.5
                                  ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Map Placeholder
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage(
                              'images/register_login/map_placeholder.png'), // Will fallback if not exists, but gives effect
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline,
                              size: 16, color: Color(0xFF0033CC)),
                          SizedBox(width: 8),
                          Text(
                              'Drag the pin to set your exact service location',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0033CC),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _nextStep,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('NEXT',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPharmacistStep2() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Pharmacy Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Tell us about your pharmacy and license information',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Form(
                  key: _formKey2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      _buildTextField(
                        controller: _pharmacyNameController,
                        icon: Icons.local_pharmacy_outlined,
                        label: 'Medical Store Name',
                        hint: 'Enter your store name',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _licenseController,
                        icon: Icons.description_outlined,
                        label: 'License Number',
                        hint: 'ex. DL-123456',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _pharmacistNameController,
                        icon: Icons.person_outline,
                        label: 'Registered Pharmacist Name',
                        hint: 'Enter pharmacist name',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _pharmacistRegNumberController,
                        icon: Icons.badge_outlined,
                        label: 'Pharmacist Registration Number',
                        hint: 'ex. PR-987654',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Services Available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Select all that apply', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _pharmacistServicesState.keys.map((service) {
                          bool isSelected = _pharmacistServicesState[service]!;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _pharmacistServicesState[service] = !isSelected;
                              });
                            },
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 84) / 2, // Adjusted for padding
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    service.contains('Prescription') ? Icons.medication_outlined :
                                    service.contains('Generic') ? Icons.medical_information_outlined :
                                    service.contains('Healthcare') ? Icons.health_and_safety_outlined :
                                    Icons.monitor_heart_outlined,
                                    color: const Color(0xFF0033CC),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      service,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF0033CC) : Colors.white,
                                      border: Border.all(color: isSelected ? const Color(0xFF0033CC) : Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text('Store Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _addressController,
                        icon: Icons.location_on_outlined,
                        label: '',
                        hint: 'Enter complete address',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      _buildLocationRow(),
                      const SizedBox(height: 12),
                      // Current Location Box
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Current Location',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87),
                                  ),
                                  Text('Detect your pharmacy location on map',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: TextButton.icon(
                                    onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                                    icon: _isFetchingLocation 
                                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0033CC)))
                                        : const Icon(Icons.my_location, size: 16, color: Color(0xFF0033CC)),
                                    label: Text(
                                      _isFetchingLocation ? 'Fetching...' : 'Use Current Location',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0033CC)),
                                    ),
                                    style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.blue.shade100.withOpacity(0.5
                                  ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Map Placeholder
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: AssetImage(
                                'images/register_login/map_placeholder.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: _currentPosition != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.red, size: 40),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4)
                                        ],
                                      ),
                                      child: Text(
                                        '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                    ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, offset: Offset(0, -2), blurRadius: 10)
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey2.currentState!.validate() && _selectedState != null) {
                    setState(() => _currentStep = 2);
                  } else if (_selectedState == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select state')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0033CC),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('NEXT',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacistStep3() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 1),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Documents',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Please upload the required documents\nto verify your pharmacy',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey('step3_scroll'),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    _buildDocUploadCard(
                      title: 'Store Front Photo',
                      subtitle: 'Upload clear photo of your medical store',
                      icon: Icons.store_outlined,
                      isMandatory: true,
                      file: _profilePhoto, // using profilePhoto for store front
                      onTap: () => _pickImage('profile'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'Drug License Certificate',
                      subtitle: 'Upload valid drug license certificate',
                      icon: Icons.description_outlined,
                      isMandatory: true,
                      file: _labLicense, // reusing variable
                      onTap: () => _pickImage('license'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'Pharmacist Registration Certificate',
                      subtitle: 'Upload pharmacist registration certificate',
                      icon: Icons.person_pin_outlined,
                      isMandatory: true,
                      file: _pharmacistRegistrationCert,
                      onTap: () => _pickImage('pharmacist_reg'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'Owner Aadhaar / PAN Card',
                      subtitle: 'Upload identity proof',
                      icon: Icons.badge_outlined,
                      isMandatory: true,
                      file: _govId,
                      onTap: () => _pickImage('govid'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'GST Certificate (Optional)',
                      subtitle: 'Upload if available',
                      icon: Icons.request_quote_outlined,
                      isMandatory: false,
                      file: _gstCert,
                      onTap: () => _pickImage('gst'),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified_user_outlined,
                                  color: Color(0xFF0033CC), size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                  child: Text(
                                      'Your documents are securely stored and used only for verification.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                          height: 1.4))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.black12, height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: Colors.grey.shade600, size: 20),
                              SizedBox(width: 12),
                              const Expanded(
                                  child: Text(
                                      'Verification usually takes 24-48 hours.',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black87))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 48,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0033CC),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('SUBMIT FOR VERIFICATION',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBloodBankStep3() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 1),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Documents',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Please upload the required documents\nto verify your blood bank',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey('step3_scroll'),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDocUploadCard(
                      title: 'Blood Bank Front Photo',
                      subtitle: 'Upload clear photo of your blood bank',
                      icon: Icons.storefront_outlined,
                      isMandatory: true,
                      file: _bloodBankFrontPhoto,
                      onTap: () => _pickImage('bb_front'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'Blood Bank License Certificate',
                      subtitle: 'Upload valid blood bank license certificate',
                      icon: Icons.description_outlined,
                      isMandatory: true,
                      file: _bloodBankLicenseCert,
                      onTap: () => _pickImage('bb_license'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'Owner / In-charge Aadhaar Card',
                      subtitle: 'Upload identity proof of owner or person in charge',
                      icon: Icons.badge_outlined,
                      isMandatory: true,
                      file: _bloodBankInchargeAadhaar,
                      onTap: () => _pickImage('bb_aadhaar'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'GST Certificate',
                      subtitle: 'Upload if available',
                      icon: Icons.receipt_long_outlined,
                      isMandatory: false,
                      file: _gstCert,
                      onTap: () => _pickImage('gst'),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified_user_outlined, color: Color(0xFF0033CC), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Your documents are securely stored and used only for verification.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.access_time, color: Color(0xFF0033CC), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Verification usually takes 24-48 hours.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 48,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0033CC),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('SUBMIT FOR VERIFICATION',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStep3() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 1),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Documents',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Please upload the required documents',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        key: const ValueKey('step3_scroll'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDocUploadCard(
              title: 'Profile Photo',
              subtitle: 'Upload your clear profile photo',
              icon: Icons.person,
              isMandatory: true,
              file: _profilePhoto,
              onTap: () => _pickImage('profile'),
            ),
            const SizedBox(height: 8),
            _buildDocUploadCard(
              title: 'Government ID',
              subtitle: '(Aadhaar Card or PAN Card)',
              icon: Icons.badge_outlined,
              isMandatory: true,
              file: _govId,
              onTap: () => _pickImage('govid'),
            ),
            const SizedBox(height: 8),
            _buildDocUploadCard(
              title: 'Lab License Certificate',
              subtitle: 'Upload your valid pathology/lab license certificate',
              icon: Icons.workspace_premium_outlined,
              isMandatory: true,
              file: _labLicense,
              onTap: () => _pickImage('license'),
            ),
            const SizedBox(height: 8),
            _buildDocUploadCard(
              title: 'GST Certificate',
              subtitle: 'Upload if available',
              icon: Icons.receipt_long_outlined,
              isMandatory: false,
              file: _gstCert,
              onTap: () => _pickImage('gst'),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12)),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined,
                          color: Color(0xFF0033CC)),
                      SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              'Your documents are securely stored and used only for verification.',
                              style: TextStyle(fontSize: 12))),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Color(0xFF0033CC)),
                      SizedBox(width: 12),
                      Expanded(
                          child: Text('Verification usually takes 24-48 hours.',
                              style: TextStyle(fontSize: 12))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0033CC),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('SUBMIT FOR VERIFICATION',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isMandatory,
    required XFile? file,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
          ]),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.blue.shade50, shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF0033CC), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        isMandatory ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isMandatory ? 'Mandatory' : 'Optional',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            isMandatory ? Colors.red : const Color(0xFF0033CC)),
                  ),
                )
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0033CC)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(file != null ? Icons.check : Icons.upload,
                    size: 16, color: const Color(0xFF0033CC)),
                const SizedBox(width: 4),
                Text(file != null ? 'Done' : 'Upload',
                    style: const TextStyle(color: Color(0xFF0033CC))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSimpleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator ??
              (val) => val == null || val.isEmpty ? 'Required' : null,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0033CC))),
          ),
        ),
      ],
    );
  }

  Widget _buildAmbulanceStep2() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ambulance Details & Location',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Enter ambulance details',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Form(
          key: _ambulanceFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ambulance Details Section
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ]),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.medical_services_outlined,
                              color: Color(0xFF0033CC), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text('Ambulance Details',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _vehicleNumberController,
                      icon: Icons.badge_outlined,
                      label: 'Ambulance Registration Number',
                      hint: 'ex. MH-01-AB-1234',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildFieldContainer(
                      icon: Icons.local_hospital_outlined,
                      label: 'Ambulance Type',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedAmbulanceType,
                          hint: Text('Select ambulance type',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade400)),
                          items: _ambulanceTypes
                              .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14))))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedAmbulanceType = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _driverNameController,
                      icon: Icons.person_outline,
                      label: 'Driver Name',
                      hint: 'ex. John Doe',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _driverLicenseController,
                      icon: Icons.card_membership_outlined,
                      label: 'Driver License Number',
                      hint: 'ex. DL-1234567890',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _driverMobileController,
                      icon: Icons.call_outlined,
                      label: 'Driver Mobile Number',
                      hint: 'Enter mobile number',
                      keyboardType: TextInputType.phone,
                      prefixWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 4),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryCode,
                              items: _countryCodes
                                  .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0033CC),
                                              fontSize: 12))))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCountryCode = v!),
                              icon: const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                      validator: (v) =>
                          v!.length != 10 ? 'Enter 10 digits' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Service Location Section
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ]),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.location_on_outlined,
                              color: Color(0xFF0033CC), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text('Service Location',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _addressController,
                      icon: Icons.location_on_outlined,
                      label: 'Full Address',
                      hint: 'Enter full address',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildLocationRow(),
                    const SizedBox(height: 12),

                    // Current Location Box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                      text: 'Current Location ',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87),
                                      children: [
                                        TextSpan(
                                            text: '(Optional)',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey)),
                                      ]),
                                ),
                                Text('Use your current location on map',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          TextButton.icon(
                                  onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                                  icon: _isFetchingLocation 
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0033CC)))
                                      : const Icon(Icons.my_location, size: 16, color: Color(0xFF0033CC)),
                                  label: Text(
                                    _isFetchingLocation ? 'Fetching...' : 'Use Current Location',
                                    
                                    style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0033CC)),
                                  ),
                                  style: TextButton.styleFrom(
                              backgroundColor:
                                  Colors.blue.shade100.withOpacity(0.5
                                ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Map Placeholder
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage(
                              'images/register_login/map_placeholder.png'), // Will fallback if not exists, but gives effect
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline,
                              size: 16, color: Color(0xFF0033CC)),
                          SizedBox(width: 8),
                          Text(
                              'Drag the pin to set your exact service location',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0033CC),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (_ambulanceFormKey.currentState!.validate()) {
                if (_selectedAmbulanceType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select ambulance type')));
                  return;
                }
                if (_selectedState == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select state')));
                  return;
                }
                setState(() => _currentStep = 2);
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('NEXT',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmbulanceStep3() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => setState(() => _currentStep = 1),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Documents',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            SizedBox(height: 4),
            Text('Please upload the required documents\nto verify your profile',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.grey, fontSize: 12, height: 1.2)),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('step3_scroll'),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDocUploadCard(
                    title: 'Profile Photo',
                    subtitle: 'Upload your clear profile photo',
                    icon: Icons.person,
                    isMandatory: true,
                    file: _profilePhoto,
                    onTap: () => _pickImage('profile'),
                  ),
                  const SizedBox(height: 12),

                  _buildDocUploadCard(
                    title: 'Aadhaar Card / PAN Card',
                    subtitle: 'Upload a valid Aadhaar or PAN Card',
                    icon: Icons.badge_outlined,
                    isMandatory: true,
                    file: _govId,
                    onTap: () => _pickImage('govid'),
                  ),
                  const SizedBox(height: 12),

                  _buildDocUploadCard(
                    title: 'Ambulance RC (Registration Certificate)',
                    subtitle: 'Upload the vehicle registration certificate',
                    icon: Icons.directions_car_outlined,
                    isMandatory: true,
                    file: _ambulanceRC,
                    onTap: () => _pickImage('ambulanceRC'),
                  ),
                  const SizedBox(height: 12),

                  _buildDocUploadCard(
                    title: 'Driving License',
                    subtitle: 'Upload a valid driving license',
                    icon: Icons.assignment_ind_outlined,
                    isMandatory: true,
                    file: _drivingLicense,
                    onTap: () => _pickImage('drivingLicense'),
                  ),
                  const SizedBox(height: 12),

                  _buildDocUploadCard(
                    title: 'Insurance Copy (Optional)',
                    subtitle: 'Upload insurance document if any',
                    icon: Icons.description_outlined,
                    isMandatory: false,
                    file: _insuranceCopy,
                    onTap: () => _pickImage('insuranceCopy'),
                  ),
                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_user_outlined,
                                color: Color(0xFF0033CC), size: 20),
                            SizedBox(width: 12),
                            Expanded(
                                child: Text(
                                    'Your documents are securely stored and used only for verification.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        height: 1.4))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.black12, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Colors.grey.shade600, size: 20),
                            SizedBox(width: 12),
                            const Expanded(
                                child: Text(
                                    'Verification usually takes 24-48 hours.',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black87))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bottom Button
                  Container(
                    width: double.infinity,
                    height: 48,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0033CC),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('SUBMIT FOR VERIFICATION',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNurseStep2() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Professional Details',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Tell us about your experience and services',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4))
                            ]),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Total Experience
                            const Text('Total Experience (Years)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 45,
                              child: TextFormField(
                                controller: _nurseExperienceController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Enter experience in years',
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  suffixIcon: const Icon(Icons.work_outline, color: Colors.grey, size: 18),
                                ),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Registration Number
                            const Text('Nursing Registration Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 45,
                              child: TextFormField(
                                controller: _nurseRegNumberController,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'ex. NUR-987654',
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  suffixIcon: const Icon(Icons.badge_outlined, color: Colors.grey, size: 18),
                                ),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Services Provided
                            const Text('Services You Provide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('Select all that apply', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                            const SizedBox(height: 10),
                            
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _nurseServicesState.keys.map((service) {
                                bool isSelected = _nurseServicesState[service]!;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _nurseServicesState[service] = !isSelected;
                                    });
                                  },
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width - 84) / 2, // Adjusted for padding
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          service.contains('Home') ? Icons.home_outlined :
                                          service.contains('Elderly') ? Icons.elderly_outlined :
                                          service.contains('Surgery') ? Icons.bed_outlined :
                                          service.contains('Attendant') ? Icons.person_outline :
                                          service.contains('Injection') ? Icons.vaccines_outlined :
                                          Icons.medical_services_outlined,
                                          color: const Color(0xFF0033CC),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            service,
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFF0033CC) : Colors.white,
                                            border: Border.all(color: isSelected ? const Color(0xFF0033CC) : Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Location Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.location_on_outlined,
                                      color: Color(0xFF0033CC), size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Service Location',
                                        style: TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.bold)),
                                    Text('Where will you provide your services?',
                                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _addressController,
                              icon: Icons.location_on_outlined,
                              label: 'Full Address',
                              hint: 'Enter full address',
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            _buildLocationRow(),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Current Location',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                TextButton.icon(
                                  onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                                  icon: _isFetchingLocation 
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0033CC)))
                                      : const Icon(Icons.my_location, size: 16, color: Color(0xFF0033CC)),
                                  label: Text(
                                    _isFetchingLocation ? 'Fetching...' : 'Use Current Location',
                                    
                                    style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF0033CC)),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8
                                ),
                                  ),
                                ),
                              ],
                            ),
                            const Text('Detect your current location on map',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 12),
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'images/register_login/map_placeholder.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: _currentPosition != null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.location_on,
                                              color: Colors.red, size: 40),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 4)
                                              ],
                                            ),
                                            child: Text(
                                              '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Padding for bottom button
                    ],
                  ),
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, offset: Offset(0, -2), blurRadius: 10)
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey2.currentState!.validate() && _selectedState != null) {
                    setState(() => _currentStep = 2);
                  } else if (_selectedState == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select state')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0033CC),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('NEXT',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNurseStep3() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 1),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Documents',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Please upload the required documents\nto verify your profile',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey('step3_scroll'),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDocUploadCard(
                      title: 'Profile Photo',
                      subtitle: 'Upload your clear profile photo',
                      icon: Icons.person_outline,
                      isMandatory: true,
                      file: _profilePhoto,
                      onTap: () => _pickImage('profile'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'Government ID',
                      subtitle: '(Aadhaar Card or PAN Card)',
                      icon: Icons.badge_outlined,
                      isMandatory: true,
                      file: _govId,
                      onTap: () => _pickImage('govid'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'Nursing Registration Certificate',
                      subtitle: 'Upload your valid nursing registration certificate',
                      icon: Icons.verified_user_outlined,
                      isMandatory: true,
                      file: _labLicense, // Reuse variable for registration cert
                      onTap: () => _pickImage('license'),
                    ),
                    const SizedBox(height: 12),
                    _buildDocUploadCard(
                      title: 'Experience Certificate',
                      subtitle: 'Upload if available',
                      icon: Icons.description_outlined,
                      isMandatory: false,
                      file: _nurseExperienceCert,
                      onTap: () => _pickImage('nurseExperience'),
                    ),
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified_user_outlined, color: Color(0xFF0033CC), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Your documents are securely stored and used only for verification.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.access_time, color: Color(0xFF0033CC), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Verification usually takes 24-48 hours.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 48,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0033CC),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('SUBMIT FOR VERIFICATION',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorStep2() {
// MARK_DOCTOR_START
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Professional Details',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Tell us about your experience and services',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4))
                            ]),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.person_outline,
                                      color: Color(0xFF0033CC), size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Text('Professional Details',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _doctorExperienceController,
                                    icon: Icons.work_outline,
                                    label: 'Total Experience (Years)',
                                    hint: '8',
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _doctorRegNumberController,
                                    icon: Icons.badge_outlined,
                                    label: 'Medical Registration Number',
                                    hint: 'ex. MED123456',
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFieldContainer(
                                    icon: Icons.medical_services_outlined,
                                    label: 'Specialization',
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _selectedSpecialization,
                                        items: _specializations.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)))).toList(),
                                        onChanged: (v) => setState(() => _selectedSpecialization = v),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _doctorFeeController,
                                    icon: Icons.currency_rupee,
                                    label: 'Consultation Fee',
                                    hint: '400',
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                            const Text('Consultation Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('Select all that apply', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                            const SizedBox(height: 10),
                            
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _doctorConsultationTypeState.keys.map((service) {
                                bool isSelected = _doctorConsultationTypeState[service]!;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _doctorConsultationTypeState[service] = !isSelected;
                                    });
                                  },
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width - 84) / 2, // Adjusted for padding
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          service == 'Video Call' ? Icons.videocam_outlined : Icons.call_outlined,
                                          color: const Color(0xFF0033CC),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            service,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFF0033CC) : Colors.white,
                                            border: Border.all(color: isSelected ? const Color(0xFF0033CC) : Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),

                            const Text('Languages Spoken', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('Select all that apply', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                            const SizedBox(height: 10),
                            
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _doctorLanguagesState.keys.map((lang) {
                                bool isSelected = _doctorLanguagesState[lang]!;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _doctorLanguagesState[lang] = !isSelected;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          lang,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFF0033CC) : Colors.white,
                                            border: Border.all(color: isSelected ? const Color(0xFF0033CC) : Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 10),

                            // Location Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.location_on_outlined,
                                      color: Color(0xFF0033CC), size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Practice Location',
                                        style: TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.bold)),
                                    Text('Where will you provide your services?',
                                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _addressController,
                              icon: Icons.location_on_outlined,
                              label: 'Full Address',
                              hint: 'Enter full address',
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 8),
                            _buildLocationRow(),
                            const SizedBox(height: 12),
                            
                            // Current Location Box
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                      Text.rich(
                                        TextSpan(
                                            text: 'Current Location ',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87),
                                            children: [
                                              TextSpan(
                                                  text: '(Optional)',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.grey)),
                                            ]),
                                      ),
                                      Text('Use your current location on map',
                                          style: TextStyle(
                                              fontSize: 10, color: Colors.grey)),
                                    ],
                                   ),
                                   ),
                                   TextButton.icon(
                                    onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                                    icon: _isFetchingLocation
                                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.my_location, size: 16, color: Color(0xFF0033CC)),
                                    label: Text(_isFetchingLocation ? 'Fetching...' : 'Use Current Location',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0033CC))),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue.shade100.withOpacity(0.5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Map Placeholder
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'images/register_login/map_placeholder.png'), // Will fallback if not exists, but gives effect
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: _currentPosition != null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.location_on,
                                              color: Colors.red, size: 40),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 4)
                                              ],
                                            ),
                                            child: Text(
                                              '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                children: const [
                                  Icon(Icons.info_outline,
                                      size: 16, color: Color(0xFF0033CC)),
                                  SizedBox(width: 8),
                                  Text(
                                      'Drag the pin to set your exact service location',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.black54)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8), // Padding for bottom button
                    ],
                  ),
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, offset: Offset(0, -2), blurRadius: 10)
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey2.currentState!.validate() && _selectedState != null) {
                    _nextStep();
                  } else if (_selectedState == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a state')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0033CC),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('NEXT',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK_DOCTOR_END
  Widget _buildDoctorStep3() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => setState(() => _currentStep = 1),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Documents',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Please upload the required documents\nto verify your profile',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey('step3_scroll'),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDocUploadCard(
                      title: 'Profile Photo',
                      subtitle: 'Upload a clear photo\nof your face',
                      icon: Icons.person_outline,
                      isMandatory: true,
                      file: _profilePhoto,
                      onTap: () => _pickImage('profile'),
                    ),
                    const SizedBox(height: 8),
                    _buildDocUploadCard(
                      title: 'Aadhaar Card / PAN Card',
                      subtitle: 'Upload clear copy of\nAadhaar Card or PAN Card',
                      icon: Icons.badge_outlined,
                      isMandatory: true,
                      file: _govId,
                      onTap: () => _pickImage('govid'),
                    ),
                    const SizedBox(height: 8),
                    _buildDocUploadCard(
                      title: 'Medical Registration Certificate',
                      subtitle: 'Upload your valid medical\nregistration certificate',
                      icon: Icons.verified_user_outlined,
                      isMandatory: true,
                      file: _labLicense, // Using _labLicense for medical registration
                      onTap: () => _pickImage('license'),
                    ),
                    const SizedBox(height: 8),
                    _buildDocUploadCard(
                      title: 'MBBS Degree Certificate',
                      subtitle: 'Upload your MBBS\ndegree certificate',
                      icon: Icons.school_outlined,
                      isMandatory: true,
                      file: _doctorDegreeCert,
                      onTap: () => _pickImage('doctorDegree'),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified_user_outlined, color: Color(0xFF0033CC), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Your documents are securely stored\nand used only for verification.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.access_time, color: Color(0xFF0033CC), size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Verification usually takes 24-48 hours.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bottom button
                    Container(
                      width: double.infinity,
                      height: 48,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0033CC),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('SUBMIT FOR VERIFICATION',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
