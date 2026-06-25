import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/trip_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';
import 'package:kemit_get_it/features/guide/widgets/mytrip.dart';

class MyTripsView extends StatefulWidget {
  const MyTripsView({super.key});

  @override
  State<MyTripsView> createState() => _MyTripsViewState();
}

class _MyTripsViewState extends State<MyTripsView> {
  String _selectedFilter = "All";

  List<ActiveTripModel> _allTrips = [];

  bool _isLoading = true;
  String? _error;

  final List<String> _filters = const [
    "All",
    "Active",
    //"Pending",
    "Completed",
    "Cancelled", // بدل Canceled
  ];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final trips = await TripService.getMyTrips();

      if (!mounted) return;

      setState(() {
        _allTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ActiveTripModel> get _filteredTrips {
    if (_selectedFilter == "All") {
      return _allTrips;
    }

    return _allTrips.where((trip) {
      return trip.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  Widget _buildFilterChip(String title) {
    final selected = title == _selectedFilter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(title),
        selected: selected,
        selectedColor: const Color(0xFFB9975B),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilter = title;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Trips",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((e) => _buildFilterChip(e)).toList(),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB9975B),
                        ),
                      )
                      : _error != null
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadTrips,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                      : _filteredTrips.isEmpty
                      ? const Center(child: Text("No trips found"))
                      : RefreshIndicator(
                        onRefresh: _loadTrips,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _filteredTrips.length,
                          itemBuilder: (context, index) {
                            return TripCard(trip: _filteredTrips[index]);
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
