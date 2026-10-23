
import 'package:flutter/material.dart';

import '../models/episode.dart';
import '../services/api_service.dart';
import 'episode_detail_screen.dart';

class EpisodesScreen extends StatefulWidget {
  const EpisodesScreen({super.key});

  @override
  State<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends State<EpisodesScreen> {
  final ApiService _apiService = ApiService();

  late Future<List<Episode>> _episodesFuture;
  int? _selectedSeason;

  static const Color background = Color(0xFF090D14);
  static const Color panel = Color(0xFF151D29);
  static const Color green = Color(0xFFB7F34D);
  static const Color muted = Color(0xFF929DAD);

  @override
  void initState() {
    super.initState();
    _episodesFuture = _apiService.getEpisodes();
  }

  // Obtiene el numero de temporada desde el codigo S01E01.
  int? _getSeason(Episode episode) {
    final match = RegExp(
      r'^S(\d+)E\d+$',
    ).firstMatch(episode.episode);

    if (match == null) return null;

    return int.tryParse(match.group(1)!);
  }

  String _formatSeason(int season) {
    return 'Temporada $season';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rick and Morty',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar episodios',
            onPressed: () {
              setState(() {
                _selectedSeason = null;
                _episodesFuture = _apiService.getEpisodes();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Episode>>(
        future: _episodesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: green),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: green,
                      size: 55,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudieron cargar los episodios',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _episodesFuture = _apiService.getEpisodes();
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final episodes = snapshot.data ?? [];

          if (episodes.isEmpty) {
            return const Center(
              child: Text(
                'No hay episodios disponibles',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Descubre las temporadas que vienen desde la API.
          final seasons = episodes
              .map(_getSeason)
              .whereType<int>()
              .toSet()
              .toList()
            ..sort();

          if (seasons.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron temporadas.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Selecciona la primera temporada al abrir la pantalla.
          final selectedSeason =
          seasons.contains(_selectedSeason)
              ? _selectedSeason!
              : seasons.first;

          final seasonEpisodes = episodes
              .where((episode) =>
          _getSeason(episode) == selectedSeason)
              .toList()
            ..sort((a, b) => a.id.compareTo(b.id));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 4),
                child: Text(
                  'EXPLORA EL MULTIVERSO',
                  style: TextStyle(
                    color: green,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: Text(
                  'Temporadas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              // TARJETAS DE TEMPORADAS
              SizedBox(
                height: 112,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: seasons.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final season = seasons[index];
                    final isSelected = season == selectedSeason;
                    final count = episodes
                        .where((episode) =>
                    _getSeason(episode) == season)
                        .length;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSeason = season;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 145,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? green : panel,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? green
                                : const Color(0xFF283344),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.live_tv_rounded,
                              color: isSelected ? background : green,
                              size: 25,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatSeason(season),
                              style: TextStyle(
                                color: isSelected
                                    ? background
                                    : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$count episodios',
                              style: TextStyle(
                                color: isSelected
                                    ? background
                                    : muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // TITULO DE LA TEMPORADA SELECCIONADA
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatSeason(selectedSeason),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${seasonEpisodes.length} episodios',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // LISTA DE EPISODIOS DE ESA TEMPORADA
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: seasonEpisodes.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final episode = seasonEpisodes[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF253142),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            episode.episode.replaceAll('S', '').replaceAll('E', '.'),
                            style: const TextStyle(
                              color: green,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        title: Text(
                          episode.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Estreno: ${episode.airDate}',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: green,
                          size: 17,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EpisodeDetailScreen(
                                episode: episode,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}