import 'package:flutter/material.dart';
import 'package:graduate/AddProjectScreen.dart';
import 'package:graduate/sqflitedb.dart';
import 'session.dart';
import 'EditProjectScreen.dart';
import 'ProjectDetailsScreen.dart';


class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  SqlDb sqlDb = SqlDb();
  List<Map<String, dynamic>> myProjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyProjects();
  }

  Future<void> _loadMyProjects() async {
    try {
      // Get current user ID
      int? userId = await UserSession.getUserId();
      
      if (userId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Load projects for current user
      List<Map> response = await sqlDb.readData('''
        SELECT 
    p.*,
    COALESCE(AVG(c.rating), 0) as avg_rating,
    COALESCE(COUNT(c.comment_id), 0) as total_comments
FROM projects p 
LEFT JOIN comments c ON p.project_id = c.project_id
WHERE p.user_id = $userId
GROUP BY p.project_id
ORDER BY p.project_id DESC
      ''');
      
      setState(() {
        myProjects = response.map((map) => map as Map<String, dynamic>).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _refreshProjects() {
    setState(() {
      isLoading = true;
    });
    _loadMyProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Projects',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshProjects,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, 
            MaterialPageRoute(builder: (context)=> const AddProjectScreen()),
            ).then((value){
              if(value == true) _refreshProjects();
            });
          },
          child: const Icon(Icons.add),
        ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (myProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Projects Yet',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Cairo',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'add your first project',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            /*ElevatedButton(
              onPressed: () {
                // Navigate to add project
              },
              child: const Text(
                'Add New Project',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),*/
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myProjects.length,
      itemBuilder: (context, index) {
        return _buildProjectCard(myProjects[index]);
      },
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    // Parse technologies
    List<String> techList = [];
    if (project['technologies'] != null) {
      String techString = project['technologies'].toString();
      techList = techString.split(',');
    }

    return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailsScreen(
                      project: project,
                    ),
                  ),
                );
              },
    child: Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    project['category'] ?? 'Uncategorized',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                // Edit and Delete buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: Colors.blue,
                      onPressed: () {
                        _navigateToEditScreen(project);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed: () {
                        _onDeletePressed(project);
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Title
            Text(
              project['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),

            const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/code.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
            ),
          ),
      ],
    ),
),

            const SizedBox(height: 12),

            // Year and Rating
            Row(
              children: [
                // Year
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      project['year'] ?? '2025',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${project['rating'] ?? 0}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),

            const SizedBox(height: 12),

            // Technologies
            if (techList.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: techList.map((tech) {
                  return Chip(
                    label: Text(
                      tech.trim(),
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.grey[100],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    ),
    );
  }


  // In your HomeScreen
// Add this method to your HomeScreen class
Future<void> _navigateToEditScreen(Map<String, dynamic> project) async {
  // Navigate to edit screen
  final updated = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProjectScreen(
        project: project, // Just pass the project
      ),
    ),
  );
  
  // If project was updated or deleted
  if (updated == true) {
    // Refresh projects list
     _refreshProjects(); // Your existing method
  }
}

  Future<void> _onDeletePressed(Map<String, dynamic> project) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(style: TextStyle(
          fontFamily: 'Cairo',
        ),
        'Delete'
        ),
        content: const Text(
          'Delete Project?',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('cancel', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('delete', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        int projectId = project['project_id'];
        int response = await sqlDb.deleteData('''
          DELETE FROM projects WHERE project_id = $projectId
        ''');

        if (response > 0) {
          // Remove from list
          setState(() {
            myProjects.removeWhere((p) => p['project_id'] == projectId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project Deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}