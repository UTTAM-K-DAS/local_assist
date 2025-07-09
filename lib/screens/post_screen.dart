import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key); // added key

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Help Needed';

  Future<void> submitPost() async {
    await FirebaseFirestore.instance.collection('posts').add({
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'category': _category,
      'timestamp': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Post")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'Help Needed', child: Text('Help Needed')),
                DropdownMenuItem(value: 'Offering Help', child: Text('Offering Help')),
                DropdownMenuItem(value: 'Alert', child: Text('Alert')),
                DropdownMenuItem(value: 'Event', child: Text('Event')),
              ],
              onChanged: (val) => setState(() => _category = val ?? 'Help Needed'),
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: submitPost,
              icon: const Icon(Icons.send),
              label: const Text("Submit"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
