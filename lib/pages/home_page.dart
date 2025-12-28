import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../database/database_helper.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
@override
void initState() {
  super.initState();
  _loadNotes();
}
Future<void> _loadNotes() async {
  final data = await DatabaseHelper.instance.getNotes();

  debugPrint('DATA DARI SQLITE:');
  debugPrint(data.toString());
  setState(() {
    notes.clear();
    notes.addAll(data);
  });
}
  final List<Map<String, dynamic>> notes = [];

  void _sortNotes() {
    notes.sort((a, b) {
      final ap = a['pinned'] ?? false;
      final bp = b['pinned'] ?? false;
      if (ap && !bp) return -1;
      if (!ap && bp) return 1;
      return 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    _sortNotes();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        title: const Text(
          'CatatanKu Pro',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
        child: notes.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada catatan',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : MasonryGridView.count(
                padding: const EdgeInsets.all(12),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];

                  return _AnimatedPinnedCard(
                    title: note['title'] ?? '',
                    content: note['content'] ?? '',
                    pinned: note['pinned'] ?? false,
                    isEven: index.isEven,
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/form',
                        arguments: note,
                      );

                      if (result != null &&
                          result is Map<String, dynamic>) {
                        setState(() {
                          notes[index] = {
                            'title': result['title'],
                            'content': result['content'],
                            'pinned': note['pinned'] ?? false,
                          };
                        });
                      }
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(
                                  (note['pinned'] ?? false)
                                      ? Icons.push_pin_outlined
                                      : Icons.push_pin,
                                ),
                                title: Text(
                                  (note['pinned'] ?? false)
                                      ? 'Lepas Pin'
                                      : 'Pin Catatan',
                                ),
                                onTap: () {
                                  setState(() {
                                    note['pinned'] =
                                        !(note['pinned'] ?? false);
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Hapus Catatan'),
                                // onTap: () {
                                //   setState(() {
                                //     notes.removeAt(index);
                                //   });
                                //   Navigator.pop(context);
                                // },
                                onTap: () async {
                                  await DatabaseHelper.instance.deleteNote(note['id']);
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  _loadNotes();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF4444),
        // onPressed: () async {
        //   final result =
        //       await Navigator.pushNamed(context, '/form');

        //   if (result != null &&
        //       result is Map<String, dynamic>) {
        //     setState(() {
        //       notes.add({
        //         'title': result['title'],
        //         'content': result['content'],
        //         'pinned': false,
        //       });
        //     });
        //   }
        // },
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, '/form');

          if (result != null &&
              result is Map<String, dynamic>) {
            await DatabaseHelper.instance.insertNote({
              'title': result['title'],
              'content': result['content'],
              'created_at': DateTime.now().toIso8601String(),
            });

            _loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AnimatedPinnedCard extends StatefulWidget {
  final String title;
  final String content;
  final bool pinned;
  final bool isEven;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _AnimatedPinnedCard({
    required this.title,
    required this.content,
    required this.pinned,
    required this.isEven,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_AnimatedPinnedCard> createState() =>
      _AnimatedPinnedCardState();
}

class _AnimatedPinnedCardState extends State<_AnimatedPinnedCard> {
  double _scale = 1.0;

  void _press(bool down) {
    setState(() => _scale = down ? 0.97 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _press(true),
      onTapUp: (_) => _press(false),
      onTapCancel: () => _press(false),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: widget.isEven
                        ? const [
                            Color(0xFFF5FAFF),
                            Color(0xFFEAF2FF),
                          ]
                        : const [
                            Color(0xFFFFF5F5),
                            Color(0xFFFFEAEA),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.content,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),

                  ],
                ),
              ),
            ),
            if (widget.pinned)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.push_pin,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
