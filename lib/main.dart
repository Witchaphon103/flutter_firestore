import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
      home: const StudentListScreen(),
    );
  }
}

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student app'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No student records found.'),
            );
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index].data();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    student['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'ID: ${student['student_id']}\nYear: ${student['year']}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('students')
                          .doc(students[index].id)
                          .delete();
                    },
                  ),
                  onTap: () {
                    _showStudentDialog(context, students[index]);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showStudentDialog(context, null);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

void _showStudentDialog(BuildContext context, DocumentSnapshot? student) {
  TextEditingController nameController =
      TextEditingController(text: student?.get('name') ?? '');
  TextEditingController studentIdController =
      TextEditingController(text: student?.get('student_id') ?? '');
  TextEditingController yearController =
      TextEditingController(text: student?.get('year') ?? '');
  TextEditingController branchController =
      TextEditingController(text: student?.get('branch') ?? '');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(student == null ? 'Add New Student' : 'Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Name'),
              const SizedBox(height: 12),
              _buildTextField(studentIdController, 'Student ID'),
              const SizedBox(height: 12),
              _buildTextField(yearController, 'Year'),
              const SizedBox(height: 12),
              _buildTextField(branchController, 'Branch'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              var data = {
                'name': nameController.text,
                'student_id': studentIdController.text,
                'year': yearController.text,
                'branch': branchController.text,
              };

              if (student == null) {
                FirebaseFirestore.instance.collection('students').add(data);
              } else {
                FirebaseFirestore.instance
                    .collection('students')
                    .doc(student.id)
                    .update(data);
              }

              Navigator.of(context).pop();
            },
            child: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildTextField(TextEditingController controller, String label) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.blueAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    ),
  );
}
