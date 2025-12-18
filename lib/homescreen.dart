import 'package:flutter/material.dart';
import 'package:graduate/savedprojects.dart';
import 'package:graduate/sqflitedb.dart';
import 'session.dart';
import 'Loginscreen.dart';
import 'MyProjectsScreen.dart';
import 'ProjectDetailsScreen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  SqlDb sqlDb=SqlDb();
  String searchQuery = '';

  String? email;
  String? fname;
  String? lname;
  bool? admin;

    List get filteredProjects {
    if (searchQuery.isEmpty) {
      return allProjects;
    }
    
    // Search only in title
    return allProjects.where((project) {
      String title = project['title']?.toString().toLowerCase() ?? '';
      return title.contains(searchQuery.toLowerCase());
    }).toList();
  }



  List allProjects = [];
  bool isLoading = true;
  Future readData() async{
    List<Map> response=await  sqlDb.readData("SELECT p.*, COALESCE(c.rating, 0) as rating FROM projects p LEFT JOIN comments c ON p.project_id = c.project_id");
    if(mounted){
      setState(() {
        allProjects.clear();
        allProjects.addAll(response);
        isLoading=false;
      });
    }
 
  }

Future<void> _refreshProjects() async {
  setState(() {
    isLoading = true;
  });
  
  await readData();
  
  setState(() {
    isLoading = false;
  });
}

  final List<String> categories = ['All', 'AI', 'IoT', 'Web', 'Mobile'];
  final List<String> years = ['2025', '2024', '2023', '2022'];


  Future<void> _loadEmail() async {
  int? userId = await UserSession.getUserId(); // AWAIT here
  String? userEmail = await UserSession.getEmail(); // AWAIT here
  String? userfname = await UserSession.getFname();
  String? userlname = await UserSession.getLname();
  //bool? userAdmin = await UserSession.getUserrole();
  setState(() {
    email = userEmail; // Assign the actual value
    fname = userfname;
    lname = userlname;
    if(userId==1)
    {
      admin=true;
    }
    else
    {
      admin=false;
    }
  });
}

   @override
  void initState() {
    super.initState();
   // _loadProjects();
    readData();
    _loadEmail();
  }

  /*Future<void> _loadProjects() async {
    try {
      // Read projects from database
      List<Map> response = await sqlDb.readData('''
        SELECT * FROM projects
      ''');
      
      setState(() {
        allProjects = response.map((map) => map as Map<String, dynamic>).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading projects: $e');
      setState(() {
        isLoading = false;
      });
    }
  }*/

  // Get filtered projects based on selected category

Future<void> _logout(BuildContext context) async {
  // Show confirmation dialog
  bool confirm = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
        ),
        'Logout'
        ),
      content: const Text(
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
        ),
        'Are you sure?'
        ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              ),
            'cancel'
            ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              color: Colors.white,
              ),
            'Logout'),
        ),
      ],
    ),
  ) ?? false;

  if (confirm) {
    // Clear user session
    await UserSession.logout();
    
    // Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Remove all routes
    );
    
    // Optional: Show logout message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signed Out'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text(
            'Graduate',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                 Text(
                  fname?? 'No Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  email?? 'No email',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Drawer items

          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('My Projects'),
            onTap: () {
              Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProjectsScreen()
                  ),
                  );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Saved Projects'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedProjectsScreen()
                  ),
                  );
            },
          ),
          if(admin??false) ListTile(
            leading: const Icon(Icons.supervised_user_circle),
            title: const Text('Users'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedProjectsScreen()
                  ),
                  );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    ),
        body: RefreshIndicator(
        onRefresh: _refreshProjects,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              _buildSearchBar(),
              
              
              const SizedBox(height: 30),
              
              // All Projects Section
              _buildAllProjectsSection(),
            ],
          ),
        ),
      ),
      
    );
  }

Widget _buildSearchBar() {
  return TextField(
    autofocus: false,
    onChanged: (value) {
      setState(() {
        searchQuery = value;
      });
    },
    decoration: InputDecoration(
      hintText: 'Search by project title',
      hintStyle: const TextStyle(fontFamily: 'Cairo'),
      prefixIcon: const Icon(Icons.search),
      suffixIcon: searchQuery.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                setState(() {
                  searchQuery = '';
                });
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}


  


  Widget _buildAllProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Projects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredProjects.length,
          itemBuilder: (context, index) {
            return _buildProjectCard(filteredProjects[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return  InkWell(
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
    child:  Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              if (admin??false) Row( 
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    onPressed: () {
                      _onDeletePressed(project);
                    },
                  ),
                ],
              ),


            // Project Title and Category
            Row(
              children: [
                Text(
                  project['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    project['category'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),                
              ],
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

            const SizedBox(height: 8),

            // desciption
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
            
            // Technologies and Ratings
            
            //_buildTechRow(project),
          ],
        ),
      ),
    ),
    );
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
            allProjects.removeWhere((p) => p['project_id'] == projectId);
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