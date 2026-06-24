import 'package:flutter/material.dart';
import 'package:kemit_get_it/routes/app_routes.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/place.dart';
import '../../features/tourist/viewmodel/places_viewmodel.dart';

class FamousPlaceCard extends StatefulWidget {
  final Place place;

  const FamousPlaceCard({
    super.key,
    required this.place,
  });

  @override
  State<FamousPlaceCard> createState() => _FamousPlaceCardState();
}

class _FamousPlaceCardState extends State<FamousPlaceCard> {
  final _wishlistVm = WishlistViewModel();
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    await _wishlistVm.loadWishlist();
    if (mounted) {
      setState(() {
        _isWishlisted = _wishlistVm.wishlist.any((p) => p.id == widget.place.id);
      });
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isWishlisted) {
      final success = await _wishlistVm.removeFromWishlist(widget.place.id);
      if (success && mounted) {
        setState(() => _isWishlisted = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from Wishlist'), duration: Duration(seconds: 1)),
        );
      }
    } else {
      final success = await _wishlistVm.addToWishlist(widget.place.id);
      if (success && mounted) {
        setState(() => _isWishlisted = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Wishlist'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  String _getFullImageUrl(String url) {
    const String placeholder = 'https://placehold.co/600x600/png';
    if (url.isEmpty) return placeholder;
    if (url.startsWith('http')) return url;
    return '${ApiConstants.baseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              _getFullImageUrl(widget.place.imageUrl),
              width: 120,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.place.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isWishlisted ? Icons.bookmark : Icons.bookmark_outline,
                          size: 20,
                          color: _isWishlisted ? const Color(0xFF6366F1) : null,
                        ),
                        onPressed: _toggleWishlist,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.place.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.place.rating.toStringAsFixed(1)}(${widget.place.reviewCount})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context,
                          AppRoutes.placeDetails,
                          arguments: widget.place,
                        );
                    },
                    child: Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendedPlaceCard extends StatelessWidget {
  final Place place;

  const RecommendedPlaceCard({
    super.key,
    required this.place,
  });

  String _getFullImageUrl(String url) {
    const String placeholder = 'https://placehold.co/600x600/png';
    if (url.isEmpty) return placeholder;
    if (url.startsWith('http')) return url;
    return '${ApiConstants.baseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.placeDetails, arguments: place);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _getFullImageUrl(place.imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}
