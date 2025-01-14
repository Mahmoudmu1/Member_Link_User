// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:member_link/models/membership.dart';
import 'package:member_link/models/user.dart';
import 'package:member_link/views/membership/membership_history.dart';
import 'package:member_link/myconfig.dart';
import 'package:member_link/views/main_screen.dart';
import 'dart:developer';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:member_link/views/shared/drawer.dart';
import 'package:member_link/views/payments/bill_page.dart';

class MembershipPage extends StatefulWidget {
  final User user;

  const MembershipPage({super.key, required this.user});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  List<Membership> memberships = [];
  late double pageWidth, pageHeight;
  String status = "Loading...";
  Map<String, dynamic>? userMembershipStatus;

  @override
  void initState() {
    super.initState();
    loadMemberships();
    loadMembershipStatus();
  }

  @override
  Widget build(BuildContext context) {
    pageWidth = MediaQuery.of(context).size.width;
    pageHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Membership Types"),
        backgroundColor: const Color.fromARGB(255, 93, 91, 89),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MainScreen(user: widget.user), // Navigate to News Page
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              loadMemberships();
              loadMembershipStatus();
              const Color.fromARGB(255, 0, 0, 0);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (userMembershipStatus != null) _buildMembershipStatus(),
          Expanded(
            child: memberships.isEmpty
                ? Center(
                    child: Text(
                      status,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : _buildGridView(),
          ),
        ],
      ),
      drawer: AppDrawer(
        user: widget.user,
        onLogout: () {
          // Handle logout logic here
          Navigator.pop(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MembershipHistoryPage(user: widget.user)),
          );
        },
        icon: const Icon(Icons.history),
        label: const Text("View History"),
        backgroundColor: const Color.fromARGB(255, 93, 91, 89),
      ),
    );
  }

  // --- Widgets ---
  Widget _buildMembershipStatus() {
    final status = userMembershipStatus?['status'] ?? "No Membership";
    final startDate = userMembershipStatus?['start_date'] ?? "-";
    final endDate = userMembershipStatus?['end_date'] ?? "-";

    return Container(
      width: double.infinity,
      color: Colors.blueGrey.shade50,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Membership Status",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Status: $status",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: status == "Active" ? Colors.green : Colors.red,
                ),
              ),
              Text(
                "Start: $startDate",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                ),
              ),
              Text(
                "End: $endDate",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: memberships.length,
      itemBuilder: (context, index) {
        return _buildCard(index);
      },
    );
  }

  Widget _buildCard(int index) {
    return Card(
      shadowColor: Colors.grey.shade300,
      color: Colors.white,
      elevation: 4,
      child: InkWell(
        onTap: () => _showDetailsDialog(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: pageHeight / 6,
              width: double.infinity,
              child: Image.network(
                "${MyConfig.servername}/memberlink/assets/membership/${memberships[index].membershipFilename}",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "assets/Not Found Image.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                memberships[index].name!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                truncateString(memberships[index].description.toString(), 45),
                style: const TextStyle(fontSize: 12, color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: RatingBar.readOnly(
                initialRating:
                    memberships[index].membershipRating?.toDouble() ?? 0.0,
                isHalfAllowed: true,
                alignment: Alignment.centerLeft,
                filledIcon: Icons.star,
                emptyIcon: Icons.star_border,
                emptyColor: const Color.fromARGB(255, 113, 113, 113),
                filledColor: const Color.fromARGB(255, 250, 179, 0),
                halfFilledColor: const Color.fromARGB(255, 162, 250, 0),
                halfFilledIcon: Icons.star_half,
                maxRating: 5,
                size: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "RM${memberships[index].price}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 16, 16, 15),
                    ),
                  ),
                  Text(
                    "${(memberships[index].membershipsold?.toInt() ?? 0)} Sold",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- API Calls ---
  Future<void> loadMemberships() async {
    try {
      final response = await http.get(
        Uri.parse("${MyConfig.servername}/memberlink/api/load_membership.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            memberships = (data['data'] as List)
                .map((item) => Membership.fromJson(item))
                .toList();
          });
        } else {
          setState(() {
            status = "No Memberships Found";
          });
        }
      } else {
        setState(() {
          status = "Error Loading Memberships";
        });
      }
    } catch (e) {
      log(e.toString());
      setState(() {
        status = "Error: $e";
      });
    }
  }

  Future<void> loadMembershipStatus() async {
    try {
      final response = await http.post(
        Uri.parse(
            "${MyConfig.servername}/memberlink/api/load_membership_status.php"),
        body: {"admin_id": widget.user.adminId}, // Updated to match `admin_id`
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            userMembershipStatus = data['data'];
          });
        } else {
          setState(() {
            userMembershipStatus = null;
          });
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // --- Dialogs ---
  void _showDetailsDialog(int index) {
    final selectedMembership = memberships[index];
    final isUpgrade = userMembershipStatus?['status'] == 'Active' &&
        userMembershipStatus?['membership_id'] != selectedMembership.id;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(selectedMembership.name!),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${selectedMembership.description}'),
                Text('Price: RM${selectedMembership.price}'),
                Text('Duration: ${selectedMembership.duration} days'),
                Text('Benefits: ${selectedMembership.benefits}'),
                Text('Terms: ${selectedMembership.terms}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                if (isUpgrade) {
                  await attemptPurchase(selectedMembership.id!, true);
                } else {
                  await attemptPurchase(selectedMembership.id!, false);
                }
              },
              child: Text(
                isUpgrade ? "Upgrade" : "Buy",
                style: TextStyle(
                  color: isUpgrade ? Colors.green : Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> attemptPurchase(String membershipId, bool isUpgrade) async {
    try {
      final selectedMembership = memberships.firstWhere(
        (m) => m.id == membershipId,
        orElse: () =>
            Membership(), // Ensure a fallback Membership object is provided
      );

      if (selectedMembership.id == null || selectedMembership.id!.isEmpty) {
        // Safely check if the ID is null or empty
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Membership not found.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return; // Exit if membership is not found
      }

      // Check if the user already has this membership active
      if (!isUpgrade && await isMembershipActive(membershipId)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Purchase Failed'),
            content: const Text(
                'You already have this membership active. Upgrade to a higher membership to proceed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Navigate to the Bill Screen for payment
      navigateToBillScreen(selectedMembership, isUpgrade);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> isMembershipActive(String membershipId) async {
    try {
      final response = await http.post(
        Uri.parse(
            "${MyConfig.servername}/memberlink/api/check_membership_status.php"),
        body: {
          'user_id': widget.user.adminId,
          'membership_id': membershipId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'active';
      }
      return false;
    } catch (e) {
      log("Error checking membership status: $e");
      return false;
    }
  }

  void navigateToBillScreen(Membership membership, bool isUpgrade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillScreen(
          totalprice: double.tryParse(membership.price!) ?? 0.0,
          membershipDetails: {
            "membership_id": membership.id,
            "name": membership.name,
          },
          checkoutType: isUpgrade ? "upgrade" : "membership",
          user: widget.user,
        ),
      ),
    );
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }
}
