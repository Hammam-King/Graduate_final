import 'package:flutter/material.dart';
import 'package:graduate/sqflitedb.dart';
import 'session.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final SqlDb sqlDb = SqlDb();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _technologiesController = TextEditingController();
  final TextEditingController _githubUrlController = TextEditingController();
  final TextEditingController _pdfUrlController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  // Selected values
  String _selectedCategory = 'ويب';
  String _selectedYear = '2024';
  
  // Categories and years
  final List<String> _categories = [
    'ويب', 'موبايل', 'ذكاء اصطناعي', 'أمن سيبراني', 
    'بيانات', 'ويب 3', 'تطبيقات سطح المكتب', 'أخرى'
  ];
  
  final List<String> _years = ['2024', '2023', '2022', '2021', '2020'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    _githubUrlController.dispose();
    _pdfUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitProject() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get current user ID
        int? userId = await UserSession.getUserId();
        
        if (userId == null) {
          _showError('Login first');
          return;
        }

        // Insert project into database
        int response = await sqlDb.insertData('''
          INSERT INTO projects (
            title, description, category, 
            technologies, year, user_id, github_url, pdf_url, image_url
          ) VALUES (
            '${_titleController.text}',
            '${_descriptionController.text}',
            '$_selectedCategory',
            '${_technologiesController.text}',
            '$_selectedYear',
            $userId,
            '${_githubUrlController.text}',
            '${_pdfUrlController.text}',
            '${_imageUrlController.text}'
          )
        ''');

        if (response > 0) {
          _showSuccess('Added Successfully!');
          _clearForm();
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context, true);
            print("TEST RESPONSE: $response");

          }
          );
        } else {
          _showError('Failed');
        }
      } catch (e) {
        print("Error adding project: $e");
        _showError('Error: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _technologiesController.clear();
    _githubUrlController.clear();
    _pdfUrlController.clear();
    _imageUrlController.clear();
    setState(() {
      _selectedCategory = 'ويب';
      _selectedYear = '2024';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add New Project',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearForm,
              tooltip: 'Clear Form',
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English Title
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'title here',
                  icon: Icons.title,
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required!';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                
                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'descripe your project',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required!';
                    }
                    if (value.length < 20) {
                      return '20 characters at least!';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Category and Year Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: _selectedCategory,
                        items: _categories,
                        label: 'Category',
                        icon: Icons.category,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        value: _selectedYear,
                        items: _years,
                        label: 'Year of Graduation',
                        icon: Icons.calendar_today,
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Technologies
                _buildTextField(
                  controller: _technologiesController,
                  label: 'Technologies used',
                  hint: 'eg. flutter, dart, firebase,...',
                  icon: Icons.code,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // Optional Fields Title
                const Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Can be left empty',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Cairo',
                  ),
                ),

                const SizedBox(height: 16),

                // GitHub URL
                _buildTextField(
                  controller: _githubUrlController,
                  label: 'GitHub',
                  hint: 'https://github.com/username/project',
                  icon: Icons.link,
                  maxLines: 1,
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 16),

                // PDF URL
                _buildTextField(
                  controller: _pdfUrlController,
                  label: 'PDF',
                  hint: 'https://example.com/project.pdf',
                  icon: Icons.picture_as_pdf,
                  maxLines: 1,
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 16),

                // Image URL
                _buildTextField(
                  controller: _imageUrlController,
                  label: 'Pic',
                  hint: 'https://example.com/project-image.jpg',
                  icon: Icons.image,
                  maxLines: 1,
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:(){
                       _submitProject();
                       },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Info Card
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Note',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• تأكد من صحة البيانات المدخلة\n'
                          '• يمكنك تحديث المشروع لاحقاً\n'
                          '• سيظهر المشروع في قائمة مشاريعك\n'
                          '• سيتمكن الآخرون من رؤية المشروع',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Cairo',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo'),
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Cairo'),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(icon, color: Colors.blue),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontFamily: 'Cairo')),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}