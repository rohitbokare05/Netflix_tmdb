import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../constants.dart';
import '../screens/details_screen.dart';
import '../api/api.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Movie> allMovies = [];
  List<Movie> filteredMovies = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllMovies();
    _searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void fetchAllMovies() async {
    final trending = await Api().getTrendingMovies();
    final upcoming = await Api().getUpcomingMovies();
    final topRated = await Api().getTopRatedMovies();

    setState(() {
      allMovies = [...trending, ...upcoming, ...topRated];
      filteredMovies = allMovies;
      isLoading = false;
    });
  }

  void onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMovies = allMovies.where((movie) {
        return movie.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Search movies...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            border: InputBorder.none,
          ),
          cursorColor: Colors.redAccent,
          autofocus: true,
        ),
      ),
      body: isLoading
          ? buildShimmerLoading()
          : filteredMovies.isEmpty
              ? Center(
                  child: Text(
                    'No results found!',
                    style: GoogleFonts.roboto(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                )
              : buildGridView(),
    );
  }

  Widget buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[600]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemCount: filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = filteredMovies[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(movie: movie),
              ),
            );
          },
          child: Hero(
            tag: movie.title,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                '${Constants.imagePath}${movie.posterPath}',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        );
      },
    );
  }
}
