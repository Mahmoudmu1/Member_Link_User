// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:member_link/myconfig.dart';
import 'package:member_link/views/shared/drawer.dart';
import 'package:member_link/views/auth/login_screen.dart';
import 'package:member_link/models/user.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({super.key, required this.user});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<dynamic> allNews = [];
  List<dynamic> currentNewsPage = [];
  int currentPage = 1;
  int totalPages = 1;
  int totalNews = 0;
  int limit = 6;
  bool isLoading = false;
  String searchQuery = '';
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews({int page = 1, String searchQuery = ''}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse(
          '${MyConfig.servername}/memberlink/api/load_news.php?pageno=$page&searchQuery=$searchQuery');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            currentNewsPage = List<dynamic>.from(data['data']['news']);
            totalNews = data['numberofresult'];
            totalPages = data['numofpage'];
            currentPage = page;
          });
        } else {
          showError("No news found.");
          setState(() {
            currentNewsPage.clear();
            totalNews = 0;
            totalPages = 1;
          });
        }
      } else {
        showError("Failed to load news. Status code: ${response.statusCode}");
      }
    } catch (error) {
      showError("Error fetching news: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterNews(String query) {
    setState(() {
      searchQuery = query;
      fetchNews(page: currentPage, searchQuery: searchQuery);
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> onRefresh() async {
    await fetchNews();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Newsfeed reloaded successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showNewsDetailsDialog(Map<String, dynamic> news) {
    final newsDate = DateTime.parse(news['news_date']);
    final formattedDate =
        "${newsDate.year}-${newsDate.month.toString().padLeft(2, '0')}-${newsDate.day.toString().padLeft(2, '0')} ${newsDate.hour.toString().padLeft(2, '0')}:${newsDate.minute.toString().padLeft(2, '0')}:${newsDate.second.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(news['news_title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Date: $formattedDate",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                news['news_details'],
                textAlign: TextAlign.justify,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  String calculateTimeAgo(DateTime newsDate) {
    final now = DateTime.now();
    final difference = now.difference(newsDate);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays == 1) {
      return "1 day ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  void handleLogout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(198, 25, 26, 26),
        title: isSearching
            ? Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  onChanged: (query) {
                    filterNews(query);
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    hintText: 'Search News...',
                    border: InputBorder.none,
                  ),
                ),
              )
            : const Text(
                'Member Link News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.cancel : Icons.search),
            color: Colors.white,
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  _searchController.clear();
                  filterNews('');
                }
              });
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        onLogout: handleLogout,
        user: widget.user, // Pass the user from MainScreen
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total News: $totalNews | Total Pages: $totalPages',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              child: currentNewsPage.isEmpty && !isLoading
                  ? const Center(child: Text("No news available."))
                  : ListView.builder(
                      itemCount: currentNewsPage.length,
                      itemBuilder: (context, index) {
                        final news = currentNewsPage[index];
                        final newsDate = DateTime.parse(news['news_date']);
                        final timeAgo = calculateTimeAgo(newsDate);

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                news['news_title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                timeAgo,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              onTap: () => showNewsDetailsDialog(news),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (!isSearching)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: currentPage > 1
                          ? () {
                              fetchNews(page: currentPage - 1);
                            }
                          : null,
                    ),
                    Text(
                      'Page $currentPage of $totalPages',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: currentPage < totalPages
                          ? () {
                              fetchNews(page: currentPage + 1);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
