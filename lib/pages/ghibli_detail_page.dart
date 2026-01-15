import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GhibliDetailPage extends StatefulWidget {
  final Map<String, dynamic> film;

  const GhibliDetailPage({super.key, required this.film});

  @override
  State<GhibliDetailPage> createState() => _GhibliDetailPageState();
}

class _GhibliDetailPageState extends State<GhibliDetailPage> {
  List<Map<String, dynamic>> _characters = [];
  bool _isLoadingCharacters = true;

  @override
  void initState() {
    super.initState();
    _fetchCharacters();
  }

  Future<void> _fetchCharacters() async {
    try {
      // Fetch both People and Species concurrently
      final responses = await Future.wait([
        http.get(Uri.parse('https://ghibliapi.vercel.app/people')),
        http.get(Uri.parse('https://ghibliapi.vercel.app/species')),
      ]);

      final peopleResponse = responses[0];
      final speciesResponse = responses[1];
      
      if (peopleResponse.statusCode == 200 && speciesResponse.statusCode == 200) {
        final List<dynamic> allPeople = json.decode(peopleResponse.body);
        final List<dynamic> allSpecies = json.decode(speciesResponse.body);
        
        // Create a Map for fast Species lookup: URL -> Name
        final Map<String, String> speciesMap = {};
        for (var species in allSpecies) {
          speciesMap[species['url']] = species['name'];
          // Also map by ID just in case
          speciesMap['https://ghibliapi.vercel.app/species/${species['id']}'] = species['name'];
          speciesMap[species['id']] = species['name'];
        }

        final String currentFilmId = widget.film['id'];
        final String currentFilmUrl = widget.film['url'] ?? '';

        final List<Map<String, dynamic>> matchedCharacters = [];

        for (var person in allPeople) {
          final List<dynamic> personFilms = person['films'] ?? [];
          
          bool isMatch = personFilms.any((filmUrl) {
            final String urlString = filmUrl.toString();
            return urlString.contains(currentFilmId) || 
                   (currentFilmUrl.isNotEmpty && urlString == currentFilmUrl);
          });

          if (isMatch) {
            final Map<String, dynamic> charData = person as Map<String, dynamic>;
            final String speciesUrl = charData['species'] ?? '';
            // unexpected result: species sometimes is a list or string, typically string url
            // API doc says string url.
            
            String speciesName = 'Unknown';
            if (speciesMap.containsKey(speciesUrl)) {
              speciesName = speciesMap[speciesUrl]!;
            } else {
               // Try to extract ID from URL and lookup
               // speciesUrl like ".../species/ID"
               // Not strictly necessary if we mapped URLs, but good fallback
            }

            charData['species_name'] = speciesName;
            matchedCharacters.add(charData);
          }
        }

        if (mounted) {
          setState(() {
            _characters = matchedCharacters;
            _isLoadingCharacters = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingCharacters = false);
        }
      }
    } catch (e) {
      debugPrint('Error fetching characters: $e');
      if (mounted) {
        setState(() => _isLoadingCharacters = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          widget.film['title'] ?? 'Detail Film',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0288D1),
                Color(0xFF4FC3F7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.film['image'] != null)
              Center(
                child: Hero(
                  tag: widget.film['id'],
                  child: Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(widget.film['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              widget.film['title'] ?? 'Unknown Title',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              widget.film['original_title'] ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today, 'Released: ${widget.film['release_date']}'),
            _buildInfoRow(Icons.timer, 'Runtime: ${widget.film['running_time']} min'),
            const SizedBox(height: 24),
            const Text(
              'Creators',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                   BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCreatorRow('Director', widget.film['director']),
                  const Divider(height: 24),
                  _buildCreatorRow('Producer', widget.film['producer']),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Synopsis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.film['description'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF4B5563),
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            
            // Characters Section
            if (_isLoadingCharacters)
              const Center(child: CircularProgressIndicator())
            else if (_characters.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Characters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _characters.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final person = _characters[index];
                      // Use the exact fields requested: name, gender, age, hair color, eye color
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              person['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCharacterDetail('Gender', person['gender']),
                            _buildCharacterDetail('Age', person['age']),
                            _buildCharacterDetail('Species', person['species_name']), // Added Species
                            _buildCharacterDetail('Hair Color', person['hair_color']),
                            _buildCharacterDetail('Eye Color', person['eye_color']),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Color(0xFF374151)),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF0288D1)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorRow(String role, String name) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0288D1), // Ocean Blue
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
