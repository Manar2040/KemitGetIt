import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/widgets/hold_requests_list.dart';

class HoldRequestScreen extends StatefulWidget {
  const HoldRequestScreen({super.key});

  @override
  State<HoldRequestScreen> createState() => _HoldRequestScreenState();
}

class _HoldRequestScreenState extends State<HoldRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Hold Requests",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [SizedBox(height: 32), HoldRequestsList()]),
        ),
      ),
    );
  }
}
