import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutflix/constants.dart';
import 'package:flutflix/api/api.dart';
import 'package:flutflix/models/movie.dart';
import 'package:flutflix/models/cast.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String? trailerKey;
  List<Cast> castList = [];
  late YoutubePlayerController _youtubeController;
  bool isTrailerReady = false;

  @override
  void initState() {
    super.initState();
    fetchTrailerAndCast();
  }

  @override
  void dispose() {
    if (isTrailerReady) {
      _youtubeController.dispose();
    }
    super.dispose();
  }

  void fetchTrailerAndCast() async {
    final api = Api();
    final fetchedTrailerKey = await api.getTrailerKey(widget.movie.id);
    final fetchedCast = await api.getCast(widget.movie.id);

    if (fetchedTrailerKey != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: fetchedTrailerKey,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
      setState(() {
        trailerKey = fetchedTrailerKey;
        isTrailerReady = true;
      });
    }
    setState(() {
      castList = fetchedCast;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            expandedHeight: 0, // No height, no big poster
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isTrailerReady)
                    YoutubePlayer(
                      controller: _youtubeController,
                      showVideoProgressIndicator: true,
                    ),
                  const SizedBox(height: 20),
                  _buildInfoRow(),
                  const SizedBox(height: 20),
                  _buildCastList(),
                  const SizedBox(height: 20),
                  Text(
                    'Story Line',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.movie.overview,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
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

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTag('Release: ${widget.movie.releaseDate}'),
        _buildTag('Rating: ${widget.movie.voteAverage.toStringAsFixed(1)}'),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCastList() {
    return castList.isEmpty
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cast',
                style: GoogleFonts.bebasNeue(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: castList.length,
                  itemBuilder: (context, index) {
                    final cast = castList[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 80,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: cast.profilePath.isNotEmpty
                                ? Image.network(
                                    '${Constants.imagePath}${cast.profilePath}',
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 80,
                                    width: 80,
                                    color: Colors.grey,
                                    child: const Icon(Icons.person,
                                        color: Colors.white),
                                  ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cast.name,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
