import 'package:anime_verse/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/favorite_anime_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          "Favorite Anime",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: (screenWidth * 0.06).clamp(18.0, 26.0),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0, // Fixed padding, not used %
              vertical: 12.0,
            ),
            child: Container(
              width: screenWidth - 32, // Ensure tidak overflow (16px * 2)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Consumer<AppStateProvider>(
                builder: (context, provider, child) {
                  return TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      provider.setFavoriteSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Anime Title",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: (screenWidth * 0.038).clamp(13.0, 16.0),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: (screenWidth * 0.055).clamp(20.0, 24.0),
                      ),
                      suffixIcon: provider.favoriteSearchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: (screenWidth * 0.05).clamp(18.0, 22.0),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          provider.setFavoriteSearchQuery("");
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0b395e),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: (screenWidth * 0.038).clamp(13.0, 16.0),
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 8),

          // Favorite Anime List - Dynamic with Provider
          Expanded(
            child: Consumer<AppStateProvider>(
              builder: (context, favoriteProvider, child) {
                // Filter favorites using provider's favorite search query
                final filteredFavorites = favoriteProvider.getFilteredFavorites();

                // Empty state
                if (filteredFavorites.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: (screenWidth * 0.18).clamp(60.0, 100.0),
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              favoriteProvider.favoriteSearchQuery.isNotEmpty
                                  ? 'No favorites found'
                                  : 'No favorites yet',
                              style: TextStyle(
                                fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 12),
                            Text(
                              favoriteProvider.favoriteSearchQuery.isNotEmpty
                                  ? 'Try a different search keyword.'
                                  : 'Add some anime to your favorites!',
                              style: TextStyle(
                                fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // List of filtered favorites
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredFavorites.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final anime = filteredFavorites[index];

                    // Wrap card dengan SizedBox untuk constrain width
                    return SizedBox(
                      width: screenWidth - 32, // 16px padding * 2
                      child: FavoriteAnimeCard(
                        id: anime.id,
                        title: anime.title,
                        genre: anime.genre,
                        rating: anime.rating,
                        imagePath: anime.imagePath,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}