
import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  Future<List<Map<String, dynamic>>>? _favoritesFuture;
  Future<List<Map<String, dynamic>>>? _episodesFuture;
  Future<List<Map<String, dynamic>>>? _historyFuture;

  final Color _background = const Color(0xFF090D14);
  final Color _panel = const Color(0xFF151D29);
  final Color _green = const Color(0xFFB7F34D);
  final Color _muted = const Color(0xFF929DAD);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _reloadData();
  }

  void _reloadData() {
    _favoritesFuture = DatabaseHelper.instance.getFavorites();
    _episodesFuture = DatabaseHelper.instance.getSavedEpisodes();
    _historyFuture = DatabaseHelper.instance.getWatchHistory();
  }

  Future<void> _refresh() async {
    setState(_reloadData);

    try {
      await Future.wait([
        _favoritesFuture!,
        _episodesFuture!,
        _historyFuture!,
      ]);
    } catch (_) {
      // Los errores se muestran en cada pestaña.
    }
  }

  Future<void> _removeFavorite(int id) async {
    await DatabaseHelper.instance.removeFavorite(id);
    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personaje eliminado de favoritos')),
    );
  }

  Future<void> _removeEpisode(int id) async {
    await DatabaseHelper.instance.removeSavedEpisode(id);
    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Episodio eliminado de guardados')),
    );
  }

  Future<void> _deleteHistory(int id) async {
    await DatabaseHelper.instance.deleteHistoryEntry(id);
    if (!mounted) return;
    await _refresh();
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar historial'),
        content: const Text(
          '¿Quieres eliminar todo el historial de episodios?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await DatabaseHelper.instance.clearWatchHistory();
    if (!mounted) return;
    await _refresh();
  }

  Widget _empty(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: _muted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No se pudieron cargar los datos.\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }


  String _traducirEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'alive':
        return 'Vivo';
      case 'dead':
        return 'Muerto';
      default:
        return 'Desconocido';
    }
  }

  String _traducirEspecie(String especie) {
    switch (especie.toLowerCase()) {
      case 'human':
        return 'Humano';
      case 'alien':
        return 'Extraterrestre';
      case 'humanoid':
        return 'Humanoide';
      case 'animal':
        return 'Animal';
      case 'robot':
        return 'Robot';
      case 'mythological creature':
        return 'Criatura mitológica';
      case 'unknown':
        return 'Desconocida';
      default:
        return especie.isEmpty ? 'Desconocida' : especie;
    }
  }
  Widget _favoritesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _green));
        }
        if (snapshot.hasError) return _error(snapshot.error!);

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _empty('Todavía no tienes personajes favoritos.',
              Icons.favorite_border);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final id = (item['character_id'] as num).toInt();

            return Card(
              color: _panel,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['image']?.toString() ?? '',
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      color: _green,
                      size: 40,
                    ),
                  ),
                ),
                title: Text(
                  item['name']?.toString() ?? 'Personaje',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${_traducirEspecie(item['species']?.toString() ?? '')} · ${_traducirEstado(item['status']?.toString() ?? '')}',
                  style: TextStyle(color: _muted),
                ),
                trailing: IconButton(
                  tooltip: 'Quitar de favoritos',
                  icon: const Icon(Icons.favorite, color: Colors.redAccent),
                  onPressed: () => _removeFavorite(id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _episodesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _episodesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _green));
        }
        if (snapshot.hasError) return _error(snapshot.error!);

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _empty(
            'Todavía no has guardado episodios.',
            Icons.bookmark_border,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final id = (item['episode_id'] as num).toInt();

            return Card(
              color: _panel,
              child: ListTile(
                leading: Icon(Icons.movie_outlined, color: _green, size: 34),
                title: Text(
                  item['name']?.toString() ?? 'Episodio',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${item['episode_code'] ?? ''}\n${item['air_date'] ?? ''}',
                  style: TextStyle(color: _muted),
                ),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: 'Quitar de guardados',
                  icon: const Icon(Icons.bookmark, color: Color(0xFFB7F34D)),
                  onPressed: () => _removeEpisode(id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _historyTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _green));
        }
        if (snapshot.hasError) return _error(snapshot.error!);

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _empty('Tu historial de episodios está vacío.',
              Icons.history);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final id = (item['id'] as num).toInt();

            return Card(
              color: _panel,
              child: ListTile(
                leading: Icon(Icons.history, color: _green, size: 32),
                title: Text(
                  item['name']?.toString() ?? 'Episodio',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${item['episode_code'] ?? ''}\n${item['watched_at'] ?? ''}',
                  style: TextStyle(color: _muted),
                ),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: 'Eliminar del historial',
                  icon: Icon(Icons.delete_outline, color: _muted),
                  onPressed: () => _deleteHistory(id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: Column(
        children: [
          Material(
            color: _panel,
            child: TabBar(
              controller: _tabController,
              indicatorColor: _green,
              labelColor: _green,
              unselectedLabelColor: _muted,
              tabs: const [
                Tab(icon: Icon(Icons.favorite_border), text: 'Favoritos'),
                Tab(icon: Icon(Icons.bookmark_border), text: 'Guardados'),
                Tab(icon: Icon(Icons.history), text: 'Historial'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _favoritesTab(),
                _episodesTab(),
                _historyTab(),
              ],
            ),
          ),
          if (_tabController.index == 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton.icon(
                onPressed: _clearHistory,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Borrar todo el historial'),
              ),
            ),
        ],
      ),
    );
  }
}

