import 'package:flutter/material.dart';
import 'package:member_link/models/membership.dart';

class PaymentPage extends StatelessWidget {
  final Membership membership;

  const PaymentPage({super.key, required this.membership});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Payment"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You are purchasing ${membership.name}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text("Price: RM${membership.price}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  // Simulate Payment and Navigate Back
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment Successful!")),
                  );
                  Navigator.pop(context); // Close Payment Page
                  Navigator.pop(context); // Close Membership Detail Page
                },
                child: const Text("Confirm Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
