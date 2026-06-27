import 'package:flutter/material.dart';
import 'package:kemit_get_it/core/constants/app_colors.dart';
import 'package:kemit_get_it/features/tourist/view/profile_view.dart';
import '../../../core/services/token_storage.dart';
import '../viewmodel/places_viewmodel.dart';
import '../../../shared/widgets/search_field_widget.dart';
import '../../../shared/widgets/place_card_widget.dart';
import '../../../shared/widgets/section_header_widget.dart';
import 'trip_plans_view.dart';
import 'notifications_view.dart';
import 'search_view.dart';
import 'wishlist_view.dart';
import 'chats_list_view.dart';
import 'my_plan_view.dart';
import 'kemit_ai_view.dart';
import '../viewmodel/tourist_profile_viewmodel.dart';
import '../../../core/constants/api_constants.dart';
import '../../../routes/app_routes.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeView> {
  final _searchController = TextEditingController();
  final _placesVm = PlacesViewModel();
  final _profileVm = TouristProfileViewModel();
  int _selectedIndex = 0;
  String _displayName = 'Traveller';

  @override
  void initState() {
    super.initState();
    _placesVm.addListener(_onPlacesChanged);
    _profileVm.addListener(_onProfileChanged);
    _placesVm.loadPlaces();
    _profileVm.loadProfile();
    _loadUsername();
  }

  void _onPlacesChanged() {
    if (mounted) setState(() {});
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadUsername() async {
    final name = await TokenStorage.instance.username;
    if (mounted && name != null && name.isNotEmpty) {
      setState(() => _displayName = name);
    }
  }

  @override
  void dispose() {
    _placesVm.removeListener(_onPlacesChanged);
    _profileVm.removeListener(_onProfileChanged);
    _placesVm.dispose();
    _profileVm.dispose();
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $_displayName!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6366F1),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsPage(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_outline),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WishlistView(),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileView(),
                              ),
                            ).then((_) {
                              _profileVm.loadProfile();
                            });
                          },
                          child: () {
                            String? url = _profileVm.profile?.profileImageUrl;
                            if (url != null && url.isNotEmpty) {
                              if (!url.startsWith('http')) {
                                url = '${ApiConstants.baseUrl}$url';
                              }
                              return CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(url),
                              );
                            } else {
                              return CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Icons.person, color: AppColors.primary),
                              );
                            }
                          }(),
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
                  readOnly: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchView()),
                    );
                  },
                ),
                const SizedBox(height: 24),

                if (_placesVm.isLoading && _placesVm.places.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (_placesVm.errorMessage != null && _placesVm.places.isEmpty)
                  Center(child: Text(_placesVm.errorMessage!))
                else ...[
                  SectionHeader(
                    title: 'Explore the most famous places',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchView()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _placesVm.places.take(5).length,
                      itemBuilder: (context, index) {
                        final place = _placesVm.places[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < 4 ? 12 : 0,
                          ),
                          child: FamousPlaceCard(place: place),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  SectionHeader(
                    title: 'Recommended Places',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchView()),
                      );
                    },
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
                    itemCount: _placesVm.places.skip(5).take(5).length,
                    itemBuilder: (context, index) {
                      final place = _placesVm.places.skip(5).take(5).elementAt(index);
                      return RecommendedPlaceCard(place: place);
                    },
                  ),
                ],
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
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 1) { // Trips
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TripPlansPage()),
              );
              return;
            }
            if (index == 2) { // Chats
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatsListView()),
              );
              return;
            }
            if (index == 3) { // My Plans
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyPlanView(),
                ),
              );
              return;
            }
            setState(() {
              _selectedIndex = index;
            });
          },

          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFB0915E),
          unselectedItemColor: const Color(0xFF475569), // slate-600
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_outlined),
              activeIcon: Icon(Icons.account_balance),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              activeIcon: Icon(Icons.format_list_bulleted),
              label: 'Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'My Plans',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KemitAiView()),
          );
        },
        backgroundColor: const Color(0xFF6366F1),
        shape: const CircleBorder(),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),
      ),
    );
  }
}
