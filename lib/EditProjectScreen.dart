// screens/edit_project_screen.dart
import 'package:flutter/material.dart';
import 'package:graduate/sqflitedb.dart';

class EditProjectScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  
  const EditProjectScreen({
    super.key,
    required this.project,
  });

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  SqlDb sqlDb = SqlDb();
  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;
  late TextEditingController technologiesController;
  late TextEditingController yearController;

  @override
  void initState() {
    super.initState();
    
    // Initialize with current project data
    titleController = TextEditingController(text: widget.project['title']?.toString() ?? '');
    descriptionController = TextEditingController(text: widget.project['description']?.toString() ?? '');
    categoryController = TextEditingController(text: widget.project['category']?.toString() ?? '');
    technologiesController = TextEditingController(text: widget.project['technologies']?.toString() ?? '');
    yearController = TextEditingController(text: widget.project['year']?.toString() ?? '2024');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تعديل المشروع',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteDialog,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Project Title (English)
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Project Title',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter project title';
                    }
                    return null;
                  },
                ),
                
                
                const SizedBox(height: 15),
                
                // Description
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 15),
                
                // Category
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter category';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 15),
                
                // Technologies
                TextFormField(
                  controller: technologiesController,
                  decoration: InputDecoration(
                    labelText: 'Technologies',
                    hintText: 'Flutter, Dart, Firebase',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.code),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter technologies';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 15),
                
                // Year
                TextFormField(
                  controller: yearController,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    hintText: '2024',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter year';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 25),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _updateProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'حفظ التغييرات',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Cairo',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // UPDATE METHOD
  Future<void> _updateProject() async {
    if (_formKey.currentState!.validate()) {
      try {
        int projectId = widget.project['project_id'];
        
        int response = await sqlDb.updateData('''
          UPDATE projects SET
            title = '${titleController.text}',
            description = '${descriptionController.text}',
            category = '${categoryController.text}',
            technologies = '${technologiesController.text}',
            year = '${yearController.text}'
          WHERE project_id = $projectId
        ''');

        if (response > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث المشروع بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Go back with success signal
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في تحديث المشروع'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error updating project: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // DELETE METHOD
  Future<void> _showDeleteDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المشروع', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا المشروع؟', 
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProject();
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject() async {
    try {
      int projectId = widget.project['project_id'];
      
      int response = await sqlDb.deleteData('''
        DELETE FROM projects WHERE project_id = $projectId
      ''');

      if (response > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المشروع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back with success signal
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error deleting project: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الحذف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    technologiesController.dispose();
    yearController.dispose();
    super.dispose();
  }
}