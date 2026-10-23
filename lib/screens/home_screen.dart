
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

const Color _background = Color(0xFF090D16);
const Color _surface = Color(0xFF151C2B);
const Color _portalGreen = Color(0xFFB7F34D);
const Color _muted = Color(0xFF9BA8BA);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController =
  TextEditingController();

  late Future<CharacterPageResult> _charactersFuture;

  int _currentPage = 1;
  String _searchName = '';
  bool _hasNext = false;
  bool _hasPrevious = false;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  void _loadCharacters() {
    _charactersFuture = _apiService.getCharactersPage(
      page: _currentPage,
      name: _searchName,
    );
  }

  void _search(String name) {
    setState(() {
      _searchName = name.trim();
      _currentPage = 1;
      _hasNext = false;
      _hasPrevious = false;
      _loadCharacters();
    });
  }

  void _changePage(int difference) {
    if (difference < 0 && !_hasPrevious) return;
    if (difference > 0 && !_hasNext) return;

    setState(() {
      _currentPage += difference;
      _hasNext = false;
      _hasPrevious = false;
      _loadCharacters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildSectionTitle()),
            _buildCharacters(),
            SliverToBoxAdapter(child: _buildPagination()),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _portalGreen,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: _portalGreen.withValues(alpha: 0.18),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.blur_circular,
              color: _background,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DIMENSION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'RICK & MORTY UNIVERSE',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: _portalGreen,
                ),
                SizedBox(width: 6),
                Text(
                  'EXPLORE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF202D3A),
            Color(0xFF13251F),
            Color(0xFF101724),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: _portalGreen.withValues(alpha: 0.25),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -22,
            child: Icon(
              Icons.blur_circular,
              size: 145,
              color: _portalGreen.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _portalGreen.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✦ MULTIVERSO ACTIVO',
                  style: TextStyle(
                    color: _portalGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'NINGÚN UNIVERSO\nES DEMASIADO\nEXTRAÑO.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Descubre personajes de todas las dimensiones.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _search('');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _portalGreen,
                  foregroundColor: _background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: const Icon(Icons.explore, size: 19),
                label: const Text(
                  'EXPLORAR UNIVERSO',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        textInputAction: TextInputAction.search,
        onSubmitted: _search,
        decoration: InputDecoration(
          hintText: 'Busca un personaje...',
          hintStyle: const TextStyle(
            color: _muted,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: _portalGreen,
          ),
          suffixIcon: IconButton(
            tooltip: 'Limpiar búsqueda',
            onPressed: () {
              _searchController.clear();
              _search('');
            },
            icon: const Icon(
              Icons.close,
              color: _muted,
            ),
          ),
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 17,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.white10,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: _portalGreen,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 25,
            decoration: BoxDecoration(
              color: _portalGreen,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARCHIVO MULTIVERSAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Conoce a los habitantes del universo',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.grid_view_rounded,
            color: _portalGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacters() {
    return FutureBuilder<CharacterPageResult>(
      future: _charactersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(
                color: _portalGreen,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: _message(
              Icons.wifi_off,
              'No pudimos conectar con el multiverso.',
              'Comprueba tu conexión e inténtalo de nuevo.',
              onRetry: () => setState(_loadCharacters),
            ),
          );
        }

        final result = snapshot.data;
        final characters = result?.characters ?? [];

        // Actualizar los botones con la respuesta real de la API.
        _hasNext = result?.hasNext ?? false;
        _hasPrevious = result?.hasPrevious ?? false;

        if (characters.isEmpty) {
          return SliverToBoxAdapter(
            child: _message(
              Icons.travel_explore,
              'No encontramos ese personaje.',
              'Prueba con otro nombre.',
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;

              final columns = width >= 1000
                  ? 5
                  : width >= 700
                  ? 4
                  : width >= 450
                  ? 3
                  : 2;

              return SliverGrid(
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.66,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final character = characters[index];
                    return _characterCard(character);
                  },
                  childCount: characters.length,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _characterCard(Character character) {
    final alive = character.status.toLowerCase() == 'alive';
    final dead = character.status.toLowerCase() == 'dead';

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(19),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(character: character),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'character-${character.id}',
                    child: Image.network(
                      character.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF202A38),
                        child: const Icon(
                          Icons.person,
                          color: _muted,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _background.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: alive
                                ? _portalGreen
                                : dead
                                ? Colors.redAccent
                                : Colors.orangeAccent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            character.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _background.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.open_in_new,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 11, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    character.speciesSpanish,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const Icon(
                        Icons.public,
                        size: 12,
                        color: _portalGreen,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          character.originSpanish,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Página anterior',
              onPressed: _hasPrevious
                  ? () => _changePage(-1)
                  : null,
              icon: const Icon(Icons.arrow_back_ios_new),
              color: _portalGreen,
              disabledColor: Colors.white24,
            ),
            Column(
              children: [
                const Text(
                  'DIMENSIÓN',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$_currentPage',
                  style: const TextStyle(
                    color: _portalGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            IconButton(
              tooltip: 'Página siguiente',
              onPressed: _hasNext
                  ? () => _changePage(1)
                  : null,
              icon: const Icon(Icons.arrow_forward_ios),
              color: _portalGreen,
              disabledColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(
      IconData icon,
      String title,
      String subtitle, {
        VoidCallback? onRetry,
      }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 45, color: _portalGreen),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}

