import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Map<String, dynamic>) {
      titleController.text = args['title'] ?? '';
      contentController.text = args['content'] ?? '';
    }
  }

  // void saveNote() {

  //   if (titleController.text.trim().isEmpty ||
  //       contentController.text.trim().isEmpty) {
  //     return;
  //   }

  //   Navigator.pop(context, {
  //     'title': titleController.text.trim(),
  //     'content': contentController.text.trim(),
  //   });
  // }
void saveNote() {
  if (titleController.text.trim().isEmpty ||
      contentController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Judul dan isi tidak boleh kosong'),
      ),
    );
    return;
  }

  Navigator.pop(context, {
    'title': titleController.text.trim(),
    'content': contentController.text.trim(),
  });
}

@override
void dispose() {
  titleController.dispose();
  contentController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: const Text('Catatan'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFEF4444), 
                Color(0xFF3B82F6), 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEF4444),
              Color(0xFF3B82F6),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Catatan',
                          filled: true,
                          fillColor: Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: contentController,
                        minLines: 3,
                        maxLines: null, 
                        decoration: const InputDecoration(
                          labelText: 'Isi Catatan',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: saveNote,
                          child: const Text(
                            'Simpan',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
