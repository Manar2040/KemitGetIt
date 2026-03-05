import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../data/models/place.dart';
import '../../../data/services/places_service.dart';
import '../../../data/models/guide.dart';
import '../../../data/services/guides_service.dart';
import 'place_details_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<Place> _allPlaces = [];
  List<Place> _places = [];
  List<Guide> _guides = [];

  // Filter state for guides
  String? _selectedLocation;
  double _minRating = 0.0;
  List<String> _selectedInterests = [];

  final List<String> _locations = ['Cairo', 'Luxor', 'Aswan', 'Alexandria', 'Giza'];
  final List<String> _allInterests = ['History', 'Photography', 'Food', 'Archaeology', 'Culture', 'Nature', 'Sailing', 'Nubian Culture', 'Sea', 'Shopping', 'Nightlife'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allPlaces = PlacesService.getRecommendedPlaces() + PlacesService.getFamousPlaces();
    _places = List.from(_allPlaces);
    _guides = GuidesService.getDummyGuides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Guides', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any Location')),
                      ..._locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))),
                    ],
                    onChanged: (val) {
                      setStateBottomSheet(() {
                        _selectedLocation = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  Text('Minimum Rating: ${_minRating.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Slider(
                    value: _minRating,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    activeColor: const Color(0xFF6366F1),
                    onChanged: (val) {
                      setStateBottomSheet(() {
                        _minRating = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  const Text('Shared Interests', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
                        checkmarkColor: const Color(0xFF6366F1),
                        onSelected: (selected) {
                          setStateBottomSheet(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Apply filter
                        setState(() {
                          _guides = GuidesService.getDummyGuides().where((guide) {
                            if (_selectedLocation != null && guide.location != _selectedLocation) return false;
                            if (guide.rating < _minRating) return false;
                            if (_selectedInterests.isNotEmpty) {
                              if (!_selectedInterests.every((interest) => guide.sharedInterests.contains(interest))) {
                                return false;
                              }
                            }
                            return true;
                          }).toList();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Search', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6366F1),
          tabs: const [
            Tab(text: 'Places'),
            Tab(text: 'Guides'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                if (value.isEmpty) {
                                  _places = List.from(_allPlaces);
                                } else {
                                  _places = _allPlaces.where((place) => 
                                    place.name.toLowerCase().contains(value.toLowerCase()) || 
                                    place.location.toLowerCase().contains(value.toLowerCase())
                                  ).toList();
                                }
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'What are the most famous places...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, child) {
                    if (_tabController.index == 1) {
                      return Row(
                        children: [
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: _showFilterBottomSheet,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.filter_list, color: Color(0xFF6366F1)),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlacesGrid(),
                _buildGuidesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: _places.length,
        itemBuilder: (context, index) {
          final place = _places[index];
          final double height = (index % 3 == 0) ? 250 : ((index % 2 == 0) ? 200 : 150);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceDetailsView(place: place),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildNetworkImageWithFallback(place.imageUrl, height),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuidesList() {
    if (_guides.isEmpty) {
      return const Center(child: Text('No guides found matching your filters.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _guides.length,
      itemBuilder: (context, index) {
        final guide = _guides[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(guide.imageUrl),
                  onBackgroundImageError: (_, __) => const Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guide.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(guide.location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const Spacer(),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(guide.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(' (${guide.reviews})', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: guide.sharedInterests.map((interest) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(interest, style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1))),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkImageWithFallback(String url, double height) {
    return Image.network(
      url,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.image_not_supported)),
        );
      },
    );
  }
}
