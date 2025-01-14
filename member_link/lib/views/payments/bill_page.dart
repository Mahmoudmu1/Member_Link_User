// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:member_link/models/user.dart';
import 'package:member_link/myconfig.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class BillScreen extends StatefulWidget {
  final double totalprice;
  final User user;
  final String checkoutType; // "product" or "membership"
  final List<dynamic>? selectedItems; // For product checkout
  final Map<String, dynamic>? membershipDetails; // For membership checkout

  const BillScreen({
    super.key,
    required this.totalprice,
    required this.user,
    required this.checkoutType,
    this.selectedItems,
    this.membershipDetails,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  bool isLoading = true; // To manage the loading spinner
  late WebViewController controller;
  String? paymentUrl;

  @override
  void initState() {
    super.initState();
    fetchPaymentUrl();
  }

  // Fetch Payment URL from Backend
  void fetchPaymentUrl() async {
    try {
      final Uri url =
          Uri.parse("${MyConfig.servername}/memberlink/api/payment.php")
              .replace(
        queryParameters: {
          "userid": widget.user.adminId.toString(),
          "amount": widget.totalprice.toStringAsFixed(2),
          "checkout_type": widget.checkoutType,
          if (widget.checkoutType == "membership")
            "membership_id":
                widget.membershipDetails?["membership_id"].toString(),
          if (widget.checkoutType == "product")
            "selected_items": jsonEncode(widget.selectedItems),
        },
      );

      debugPrint("Payment API URL: $url");

      final response = await http.get(url);
      debugPrint("Payment API Response: ${response.body}");

      final data = jsonDecode(response.body);

      if (data["status"] == "success" && data["payment_url"] != null) {
        setState(() {
          paymentUrl = data["payment_url"];
          initializeWebView(paymentUrl!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to load payment URL: ${data['message']}")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error fetching payment URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error fetching payment URL. Please try again.")),
      );
      Navigator.pop(context);
    }
  }

  // Initialize WebView to display the payment page
  void initializeWebView(String url) {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
          onNavigationRequest: (request) {
            debugPrint("Redirected URL: ${request.url}");
            if (request.url.contains("payment_success")) {
              handlePaymentSuccess();
              return NavigationDecision.prevent;
            } else if (request.url.contains("payment_failed")) {
              handlePaymentFailure();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  // Handle Payment Success
  void handlePaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Successful'),
          content: const Text(
              'Your membership purchase has been successfully completed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back to membership page
              },
              child: const Text('Return to Membership Page'),
            ),
          ],
        );
      },
    );
  }

  // Handle Payment Failure
  void handlePaymentFailure() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Failed'),
          content: const Text(
              'Unfortunately, your payment was not successful. Please try again or contact support if needed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back to membership page
              },
              child: const Text('Return to Membership Page'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color.fromARGB(255, 93, 91, 89),
      ),
      body: Stack(
        children: [
          if (paymentUrl == null)
            const Center(child: CircularProgressIndicator())
          else
            WebViewWidget(controller: controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
