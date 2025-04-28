import 'dart:async';
import 'package:flutflix/api/api.dart';
import 'package:flutflix/screens/searchscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie.dart';
import '../widgets/movies_slider.dart';
import '../constants.dart';
import '../screens/details_screen.dart'; // Add this for Details redirection

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Movie>> trendingMovies;
  late Future<List<Movie>> topRatedMovies;
  late Future<List<Movie>> upcomingMovies;
  late TabController _tabController;
  late PageController _pageController;
  Timer? _timer;
  int currentBannerIndex = 0;
  bool _showTitle = false;

  final List<Map<String, String>> featuredBanners = [
    {
      'title': 'The Batman',
      'image':
          'https://image.tmdb.org/t/p/original/5P8SmMzSNYikXpxil6BYzJ16611.jpg'
    },
    {
      'title': 'Joker',
      'image':
          'https://image.tmdb.org/t/p/original/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg'
    },
    {
      'title': 'Avengers Endgame',
      'image':
          'https://image.tmdb.org/t/p/original/or06FN3Dka5tukK1e9sl16pB3iy.jpg'
    },
  ];

  @override
  void initState() {
    super.initState();
    trendingMovies = Api().getTrendingMovies();
    topRatedMovies = Api().getTopRatedMovies();
    upcomingMovies = Api().getUpcomingMovies();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController(initialPage: 0);

    _showTitle = true;
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage =
            (_pageController.page!.round() + 1) % featuredBanners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavigation(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeaturedMovieBanner(),
                    _buildDotsIndicator(),
                    const SizedBox(height: 20),
                    _buildForYouSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'Netflix',
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              color: Colors.redAccent,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ));

              // You can open SearchScreen here
              print('Search button pressed');
            },
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
          Text('All', style: _navTextStyle(selected: true)),
          const SizedBox(width: 16),
          Text('Shows', style: _navTextStyle()),
          const SizedBox(width: 16),
          Text('Movies', style: _navTextStyle()),
          // const SizedBox(width: 16),
          // Text('Spor/ts', style: _navTextStyle()),
          // const Sized/Box(width: 16),
          // Text('News', style: _navTextStyle()),
        ],
      ),
    );
  }

  TextStyle _navTextStyle({bool selected = false}) {
    return GoogleFonts.roboto(
      fontSize: 16,
      color: selected ? Colors.redAccent : Colors.white70,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    );
  }

  Widget _buildFeaturedMovieBanner() {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentBannerIndex = index;
            _showTitle = false;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _showTitle = true;
              });
            }
          });
        },
        itemCount: featuredBanners.length,
        itemBuilder: (context, index) {
          final banner = featuredBanners[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  banner['image']!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _showTitle ? 1.0 : 0.0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 600),
                    offset: _showTitle ? Offset(0, 0) : Offset(0, 0.3),
                    child: Text(
                      banner['title']!,
                      style: GoogleFonts.bebasNeue(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(featuredBanners.length, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: currentBannerIndex == index ? 12 : 8,
            height: currentBannerIndex == index ? 12 : 8,
            decoration: BoxDecoration(
              color: currentBannerIndex == index
                  ? Colors.redAccent
                  : Colors.white38,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildForYouSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.redAccent,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Most Watched'),
              Tab(text: 'Recently Added'),
              Tab(text: 'Best Rated'),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: TabBarView(
              controller: _tabController,
              children: [
                buildFutureGrid(trendingMovies),
                buildFutureGrid(upcomingMovies),
                buildFutureGrid(topRatedMovies),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFutureGrid(Future<List<Movie>> future) {
    return FutureBuilder<List<Movie>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text(snapshot.error.toString(),
                  style: const TextStyle(color: Colors.white)));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent));
        } else if (snapshot.hasData) {
          final movies = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.6,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
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
                  tag: movie.title, // <- Use movie id or title as tag (unique)
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
