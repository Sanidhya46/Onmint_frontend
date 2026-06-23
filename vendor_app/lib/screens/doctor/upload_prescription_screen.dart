import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:ui_components/ui_components.dart';
import 'package:image_picker/image_picker.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  final String appointmentId;
  final Map<String, dynamic>? appointment;

  const UploadPrescriptionScreen({
    super.key,
    required this.appointmentId,
    this.appointment,
  });

  @override
  State<UploadPrescriptionScreen> createState() =>
      _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  final _apiClient = OnMintApiClient();
  final _noteController = TextEditingController();

  XFile? _selectedFile;
  String? _fileName;
  String? _fileSize;
  bool _isUploading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (file == null) {
        return;
      }

      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File must be 5 MB or smaller.')),
          );
        }
        return;
      }

      setState(() {
        _selectedFile = file;
        _fileName = file.name;
        _fileSize = (fileSize / 1024).toStringAsFixed(2);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  Future<void> _uploadPrescription() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a prescription file to upload.')),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      await _apiClient.initialize();
      final notes = _noteController.text.trim();

      if (kIsWeb) {
        final bytes = await _selectedFile!.readAsBytes();
        await _apiClient.doctor.uploadPrescriptionFileBytes(
          widget.appointmentId,
          bytes,
          _selectedFile!.name,
          notes: notes.isNotEmpty ? notes : null,
        );
      } else {
        await _apiClient.doctor.uploadPrescriptionFile(
          widget.appointmentId,
          _selectedFile!.path,
          notes: notes.isNotEmpty ? notes : null,
        );
      }

      if (mounted) {
        ToastUtils.showSuccess('Prescription uploaded successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError('Failed to upload: $e');
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.appointment?['patient'] ?? {};
    final patientName = patient['fullName'] ?? 'Patient';
    final age = (widget.appointment?['patientAge'] ?? patient['age'] ?? '28').toString();
    final price = widget.appointment?['price'] ?? widget.appointment?['totalAmount'] ?? 300;

    String dateStr = 'N/A';
    String timeStr = 'N/A';
    if (widget.appointment?['endTime'] != null) {
      final d = DateTime.tryParse(widget.appointment!['endTime']);
      if (d != null) {
        dateStr = '${d.day} ${_getMonth(d.month)} ${d.year}';
        timeStr = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Prescription'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue[100],
                        ),
                        child: const Icon(Icons.person, size: 32, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$age years old',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Consultation Fee',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            '₹$price',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Prescription',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: _fileName != null
                        ? Column(
                            children: [
                              const Icon(Icons.check_circle, size: 48, color: Colors.green),
                              const SizedBox(height: 8),
                              Text(
                                _fileName!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '($_fileSize KB)',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _isUploading ? null : _pickFile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('Change File'),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: _isUploading ? null : _pickFile,
                            child: Column(
                              children: [
                                const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tap to select prescription image',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'JPG, PNG (Max 5 MB)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Notes (Optional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add any notes about the prescription...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadPrescription,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Upload Prescription Photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
