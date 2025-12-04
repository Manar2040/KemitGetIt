import 'package:flutter/material.dart';
import 'package:kemit_get_it/data/models/user.dart';
import '../../data/services/places_service.dart';
import '../../data/models/place.dart';
import '../../widgets/search_field_widget.dart';
import '../../widgets/place_card_widget.dart';
import '../../widgets/section_header_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required User user});

  @override
  State<HomeView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeView> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;
  late List<Place> _famousPlaces;
  late List<Place> _recommendedPlaces;

  @override
  void initState() {
    super.initState();
    _famousPlaces = PlacesService.getFamousPlaces();
    _recommendedPlaces = PlacesService.getRecommendedPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, William!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_outline),
                          onPressed: () {},
                        ),
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SearchField(
                  controller: _searchController,
                  hintText: 'search',
                ),
                const SizedBox(height: 24),

                const SectionHeader(title: 'Explore the most famous places'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _famousPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _famousPlaces[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < _famousPlaces.length - 1 ? 12 : 0,
                        ),
                        child: FamousPlaceCard(place: place),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                SectionHeader(
                  title: 'Recommended Places',
                  onSeeAll: () {},
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _recommendedPlaces.length,
                  itemBuilder: (context, index) {
                    final place = _recommendedPlaces[index];
                    return RecommendedPlaceCard(place: place);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}
