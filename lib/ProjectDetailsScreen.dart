import 'package:flutter/material.dart';
import 'package:graduate/sqflitedb.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:url_launcher/url_launcher.dart';


class ProjectDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  SqlDb sqlDb = SqlDb();
  bool isSaved = false;
  bool isLoading = true;
  String? projectOwnerName;
  String? projectOwnerEmail;
  List<Map<String, dynamic>> comments = [];
  int? _currentUserId;
  
  final TextEditingController commentController = TextEditingController();
  double rating = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('user_id');
    await _loadData();
  }

  /*Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}*/

  Future<void> _loadData() async {
    try {
      if (_currentUserId != null) {
        List<Map> savedCheck = await sqlDb.readData('''
          SELECT * FROM saved_projects 
          WHERE project_id = ${widget.project['project_id']} 
          AND user_id = $_currentUserId
        ''');
        isSaved = savedCheck.isNotEmpty;
      }
      
      if (widget.project['user_id'] != null) {
        List<Map> ownerInfo = await sqlDb.readData('''
          SELECT fname, lname, email FROM users 
          WHERE user_id = ${widget.project['user_id']}
        ''');
        if (ownerInfo.isNotEmpty) {
          projectOwnerName = '${ownerInfo[0]['fname']} ${ownerInfo[0]['lname']}';
          projectOwnerEmail = ownerInfo[0]['email'];
        }
      }
      
      List<Map> commentsData = await sqlDb.readData('''
        SELECT c.*, u.fname, u.lname FROM comments c
        LEFT JOIN users u ON c.user_id = u.user_id
        WHERE c.project_id = ${widget.project['project_id']}
        ORDER BY c.created_at DESC
      ''');
      
      setState(() {
        comments = commentsData.map((c) => c as Map<String, dynamic>).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Project Details', style: TextStyle(fontFamily: 'Cairo')),
          actions: [
            if (_currentUserId != null)
              IconButton(
                icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? Colors.blue : null),
                onPressed: _toggleSave,
              ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: Image.asset('assets/images/code.jpg')
                    ),
                    
                    const SizedBox(height: 20),
                    Text(widget.project['title']?.toString() ?? 'No Title',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    
                    const SizedBox(height: 15),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildInfoChip('Year', widget.project['year']?.toString() ?? 'N/A', Icons.calendar_today),
                                const SizedBox(width: 10),
                                _buildInfoChip('Category', widget.project['category']?.toString() ?? 'Uncategorized', Icons.category),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                            const SizedBox(height: 8),
                            Text(widget.project['description']?.toString() ?? 'No Description',
                                style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'Cairo', height: 1.6)),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    _buildTechnologiesSection(),
                    const SizedBox(height: 20),
                    _buildLinksSection(),
                    const SizedBox(height: 20),
                    _buildOwnerSection(),
                    const SizedBox(height: 30),
                    if (_currentUserId != null) _buildCommentSection(),
                    const SizedBox(height: 20),
                    _buildCommentsList(),
                  ],
                ),
              ),
      );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo')),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnologiesSection() {
    String? techString = widget.project['technologies']?.toString();
    List<String> technologies = techString?.split(',') ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Technologies Used', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: technologies.map((tech) => Chip(
            label: Text(tech.trim(), style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.green[50],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildLinksSection() {
    bool hasGithub = widget.project['github_url'] != null && widget.project['github_url'].toString().isNotEmpty;
    bool hasPdf = widget.project['pdf_url'] != null && widget.project['pdf_url'].toString().isNotEmpty;
    
    if (!hasGithub && !hasPdf) return Container();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 10),
        Row(
          children: [
            if (hasGithub) Expanded(child: ElevatedButton.icon(
              onPressed: () {
                  /*if (widget.project['github_url'] != null && widget.project['github_url'].isNotEmpty) {
                  _launchURL(widget.project['github_url']);
                  }*/
              },
              icon: const Icon(Icons.code),
              label: const Text('GitHub'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            )),
            if (hasGithub && hasPdf) const SizedBox(width: 10),
            if (hasPdf) Expanded(child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('PDF'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildOwnerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Project Owner Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            const SizedBox(height: 10),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(projectOwnerName ?? 'Unknown', style: const TextStyle(fontFamily: 'Cairo')),
              subtitle: Text(projectOwnerEmail ?? 'No Email', style: const TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Comment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Rating: ', style: TextStyle(fontFamily: 'Cairo')),
                const SizedBox(width: 10),
                ...List.generate(5, (index) => IconButton(
                  icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber),
                  onPressed: () => setState(() { rating = index + 1.0; }),
                )),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Write Your Comment Here...', hintStyle: TextStyle(fontFamily: 'Cairo'), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _addComment, child: const Text('Add Comment', style: TextStyle(fontFamily: 'Cairo'))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    if (comments.isEmpty) {
      return const Center(child: Text('No Comments Yet', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text(comments[index]['fname']?.toString().substring(0, 1) ?? 'U', style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${comments[index]['fname']} ${comments[index]['lname']}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
                      if (comments[index]['rating'] != null) Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${comments[index]['rating']}'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(comments[index]['comment']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo')),
                  if (comments[index]['created_at'] != null) const SizedBox(height: 8),
                  if (comments[index]['created_at'] != null) Text(
                    comments[index]['created_at'].toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleSave() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Log in First', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.red,
      ));
      return;
    }
    
    try {
      if (isSaved) {
        await sqlDb.deleteData('DELETE FROM saved_projects WHERE project_id = ${widget.project['project_id']} AND user_id = $_currentUserId');
      } else {
        await sqlDb.insertData('INSERT INTO saved_projects (project_id, user_id) VALUES (${widget.project['project_id']}, $_currentUserId)');
      }
      setState(() { isSaved = !isSaved; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isSaved ? 'Project saved' : 'Project Unsaved', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _addComment() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Login First', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.red,
      ));
      return;
    }
    
    if (commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please Add Comment'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    
    try {
      await sqlDb.insertData('''
        INSERT INTO comments (project_id, user_id, comment, rating)
        VALUES (${widget.project['project_id']}, $_currentUserId, '${commentController.text}', $rating)
      ''');
      commentController.clear();
      setState(() { rating = 0.0; });
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Comment Added', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}