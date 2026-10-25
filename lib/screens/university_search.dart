import 'package:flutter/material.dart';
import 'package:intereasever2/services/university_service.dart';

class UniversitySearch extends StatefulWidget {
  const UniversitySearch({super.key});

  @override
  State<UniversitySearch> createState() => _UniversitySearchState();
}

class _UniversitySearchState extends State<UniversitySearch> {
  final TextEditingController _controller = TextEditingController();
  final UniversityService _universityService = UniversityService();

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  Future<void> _search() async {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results =
          await _universityService.searchUniversities(query);

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ошибка поиска: $e"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мой университет"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: "Например: ВГЛТУ",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              const CircularProgressIndicator(),

            if (!_isLoading)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final university = _results[index];

                    return Card(
                      child: ListTile(
                        title: Text(
                          university['short_name'] ?? '',
                        ),
                        subtitle: Text(
                          university['full_name'] ?? '',
                        ),
                        onTap: () {
                          Navigator.pop(
                            context,
                            university,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}