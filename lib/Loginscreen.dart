import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'package:graduate/sqflitedb.dart';
import 'session.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    SqlDb sqlDb=SqlDb();
  final _formKey = GlobalKey<FormState>();

  // Controllers for all form fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool hasAccount = true; // Track login/register state
  @override
  void initState() {
    super.initState();
    // Initialize with login form
    hasAccount = true;
    
  }


  Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    // Check if user exists in database
    List<Map<String, dynamic>> response = await sqlDb.readData('''
      SELECT * FROM users WHERE email = '${emailController.text}' AND password = '${passwordController.text}'
    ''');
    if (response.isNotEmpty) {
      // Login successful
      //String email = response[0]['email'];
      //await UserSession.saveEmail(email);
      await UserSession.saveUserInfo(response[0]);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اسم المستخدم أو كلمة المرور غير صحيحة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}

Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    // Check if username already exists
    List<Map> existingUser = await sqlDb.readData('''
      SELECT * FROM users WHERE email = '${emailController.text}'
    ''');
    
    if (existingUser.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اسم المستخدم موجود مسبقاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Insert new user
    int response = await sqlDb.insertData('''
      INSERT INTO users (email, password, fname, lname) 
      VALUES (
        '${emailController.text}',
        '${passwordController.text}',
        '${firstNameController.text}',
        '${lastNameController.text}'
      )
    ''');
    
    if (response > 0) {
      // Registration successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Switch to login form
      setState(() {
        hasAccount = true;
      });
      
      // Clear form
      _formKey.currentState?.reset();
    }
  }
}

  void toggleFormType() {
    setState(() {
      hasAccount = !hasAccount;
      // Clear form when switching
      _formKey.currentState?.reset();
    });

    

  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "تسجيل الدخول",
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Login to your account",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // Email Field
          TextFormField(
            controller: emailController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: "البريد الإلكتروني",
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
              ),
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "يرجى إدخال البريد";
              }
              if (!value.contains("@")) {
                return "البريد يجب أن يحتوي على @";
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          // Password Field
          TextFormField(
            controller: passwordController,
            textDirection: TextDirection.rtl,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: "كلمة المرور",
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
              ),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "يرجى إدخال كلمة المرور";
              }
              return null;
            },
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: () {
              // Add forgot password functionality
            },
            child: const Text(
              "نسيت كلمة المرور؟",
              style: TextStyle(color: Colors.blue, fontFamily: 'Cairo', fontSize: 12),
            ),
          ),

          const SizedBox(height: 20),

// Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _login();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "تسجيل الدخول",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Switch to Register
          Center(
            child: GestureDetector(
              onTap: toggleFormType,
              child: const Text(
                "ليس لديك حساب؟ إنشاء حساب",
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Cairo',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "إنشاء حساب",
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Create Account",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // First Name
          TextFormField(
            controller: firstNameController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: "الإسم الأول",
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
              ),
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "هذا الحقل مطلوب!";
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          // Last Name
          TextFormField(
            controller: lastNameController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: "إسم العائلة",
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
              ),
              prefixIcon: const Icon(Icons.people),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "هذا الحقل مطلوب!";
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          // Email Field
          TextFormField(
            controller: emailController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: "البريد الإلكتروني",
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
              ),
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),

),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "يرجى إدخال البريد";
              }
              if (!value.contains("@")) {
                return "البريد يجب أن يحتوي على @";
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          // Password Field
          TextFormField(
            controller: passwordController,
            textDirection: TextDirection.rtl,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: "كلمة المرور",
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
              ),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "يرجى إدخال كلمة المرور";
              }
              if (value.length < 6) {
                return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          // Confirm Password Field
          TextFormField(
            controller: confirmPasswordController,
            textDirection: TextDirection.rtl,
            obscureText: hideConfirmPassword,
            decoration: InputDecoration(
              labelText: "أعد كتابة كلمة المرور",
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
              ),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hideConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    hideConfirmPassword = !hideConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "يرجى تأكيد كلمة المرور";
              }
              if (value != passwordController.text) {
                return "كلمات المرور غير متطابقة";
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                 _register();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "تسجيل",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

// Switch to Login
          Center(
            child: GestureDetector(
              onTap: toggleFormType,
              child: const Text(
                "لديك حساب؟ تسجيل الدخول",
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Cairo',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Icon(
                    Icons.school,
                    size: 50,
                    color: Colors.blue.shade700,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "منصة مشاريع التخرج",
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const Text(
                  "Graduation Projects Platform",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 25),

                // White Card
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 12),
                    ],
                  ),
                  child: hasAccount ? _buildLoginForm() : _buildRegisterForm(),
                ),

                const SizedBox(height: 25),

                // Bottom tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tabButton("Students"),
                    const SizedBox(width: 15),
                    _tabButton("Supervisors"),
                    const SizedBox(width: 15),
                    _tabButton("Companies"),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}