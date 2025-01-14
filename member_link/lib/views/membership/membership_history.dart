// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:member_link/models/user.dart';
import 'package:member_link/myconfig.dart';

class MembershipHistoryPage extends StatefulWidget {
  final User user;

  const MembershipHistoryPage({super.key, required this.user});

  @override
  State<MembershipHistoryPage> createState() => _MembershipHistoryPageState();
}

class _MembershipHistoryPageState extends State<MembershipHistoryPage> {
  List<dynamic> history = [];
  String status = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => isLoading = true); // Show loading state
    try {
      final response = await http.post(
        Uri.parse(
            "${MyConfig.servername}/memberlink/api/load_purchased_membership.php"),
        body: {'user_id': widget.user.adminId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null ||
            !data.containsKey('status') ||
            !data.containsKey('data')) {
          setState(() {
            status = "Invalid response from server.";
            isLoading = false;
          });
          return;
        }

        setState(() {
          if (data['status'] == 'success') {
            history = data['data'];
            if (history.isEmpty) {
              status = "No purchases found.";
            }
          } else {
            status = "Error loading history.";
          }
          isLoading = false;
        });
      } else {
        setState(() {
          status = "Error loading history: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
        isLoading = false;
      });
    }
  }

  void handleAction(String action, int purchaseId, String membershipId) {
    if (action == "receipt") {
      fetchReceipt(purchaseId);
    } else if (action == "cancel") {
      confirmCancellation(membershipId);
    }
  }

  Future<void> fetchReceipt(int purchaseId) async {
    setState(() => isLoading = true); // Show loading state
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/get_receipt.php"),
        body: {'purchase_id': purchaseId.toString()}, // Convert to string here
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final receipt = data['data'];
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Receipt'),
                content: Text(
                    'Membership: ${receipt['membership_name']}\nAmount: RM${receipt['payment_amount']}\nDate: ${receipt['purchase_date']}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'] ?? "Failed to load receipt")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false); // Hide loading state
    }
  }

  Future<void> confirmCancellation(String membershipId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Membership'),
          content:
              const Text('Are you sure you want to cancel this membership?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await cancelMembership(membershipId);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelMembership(String membershipId) async {
    setState(() => isLoading = true); // Show loading state
    try {
      final response = await http.post(
        Uri.parse(
            "${MyConfig.servername}/memberlink/api/cancel_membership.php"),
        body: {
          'membership_id': membershipId,
          'user_id': widget.user.adminId,
        },
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Membership canceled")),
        );
        loadHistory(); // Reload history after successful cancellation
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? "Failed to cancel membership")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false); // Hide loading state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership History'),
        backgroundColor: const Color.fromARGB(255, 93, 91, 89),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? Center(
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      title:
                          Text(item['membership_name'] ?? "Unknown Membership"),
                      subtitle: Text(
                          'Status: ${item['membership_status'] ?? "Unknown"}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          final int purchaseId =
                              int.tryParse(item['purchase_id'].toString()) ?? 0;
                          final String membershipId =
                              item['membership_id'].toString();
                          handleAction(value, purchaseId, membershipId);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "receipt",
                            child: Text("View Receipt"),
                          ),
                          const PopupMenuItem(
                            value: "cancel",
                            child: Text("Cancel Membership"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
