import 'package:flutter/material.dart';
import '../data/hold_requests_data.dart';

class HoldRequestsList extends StatelessWidget {
  const HoldRequestsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: holdRequests.map((req) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 250, 250, 250),
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Request from: ${req.from}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(req.timeLeft, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 30,
                    width: 95,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(),
                      child: const Text(
                        "Review",
                        style: TextStyle(color: Color(0xFFB9975B)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
