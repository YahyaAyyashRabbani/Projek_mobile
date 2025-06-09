import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projek_prak_mobile/model/doa.dart'; // Import model Doa

class DoaPage extends StatefulWidget {
  const DoaPage({super.key});

  @override
  State<DoaPage> createState() => _DoaPageState();
}

  class _DoaPageState extends State<DoaPage> {
    List<Doa> doaList = []; // This will hold all fetched Doa data
    List<Doa> filteredDoaList = []; // This will hold the filtered Doa data based on search query
    String searchQuery = '';

    @override
    void initState() {
      super.initState();
      _fetchDoas();
    }

    // Fetch all Doas from the API and store them locally
    Future<void> _fetchDoas() async {
      try {
        final response = await fetchDoaList(); // Fetch Doa data from the API
        if (!mounted) return;  // Ensure the widget is still mounted before calling setState()

        setState(() {
          doaList = response;
          filteredDoaList = doaList; // Initially show all Doas when data is first loaded
        });
      } catch (e) {
        if (!mounted) return;  // Ensure the widget is still mounted before calling setState()
        
        // Handle error
        print('Error fetching Doas: $e');
        // Optionally, show a Snackbar or alert to indicate the error
      }
    }

  // Search filter function
  void _searchByTitle(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        // If search query is empty, show all Doas
        filteredDoaList = doaList;
      } else {
        // Filter based on search query
        filteredDoaList = doaList.where((doa) {
          return doa.judul.toLowerCase().contains(query.toLowerCase()); // Case-insensitive search
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: const Text(
          'Doa List',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Box
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: _searchByTitle, // Trigger search on text change
                decoration: InputDecoration(
                  labelText: 'Search by Title',
                  hintText: 'Enter a doa title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                ),
              ),
            ),
            // Display list of Doas
            Expanded(
              child: filteredDoaList.isEmpty
                  ? const Center(child: Text('No Doa found', style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                      itemCount: filteredDoaList.length,
                      itemBuilder: (context, index) {
                        final doa = filteredDoaList[index]; // Get each Doa from the filtered list
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  doa.judul,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doa.arab,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doa.indo,
                                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

  // Fetch all Doas from the API (this method should already be in your ApiService)
  static Future<List<Doa>> fetchDoaList() async {
    final url = 'https://api.myquran.com/v2/doa/semua'; // Correct endpoint URL
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      // Parse the response and return the list of Doas
      List<dynamic> data = jsonDecode(res.body)['data'];
      return data.map((doa) => Doa.fromJson(doa)).toList();
    } else {
      // Handle error if the response is not successful
      throw Exception('Failed to load Doas');
    }
  }
}
