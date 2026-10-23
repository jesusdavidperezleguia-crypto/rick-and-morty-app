
import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/database_helper.dart';

class DetailScreen extends StatefulWidget {
  final Character character;

  const DetailScreen({
    super.key,
    required this.character,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final result = await DatabaseHelper.instance
          .isFavorite(widget.character.id);

      if (!mounted) return;

      setState(() {
        _isFavorite = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al consultar favoritos: $e')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final character = widget.character;

      if (_isFavorite) {
        await DatabaseHelper.instance.removeFavorite(character.id);
      } else {
        await DatabaseHelper.instance.saveFavorite(
          id: character.id,
          name: character.name,
          image: character.image,
          status: character.status,
          species: character.species,
          gender: character.gender,
          originName: character.origin,
          locationName: character.location,
        );
      }

      if (!mounted) return;

      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? '${character.name} se agregó a favoritos'
                : '${character.name} se quitó de favoritos',
          ),
          backgroundColor: const Color(0xFF202127),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el favorito: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Alive') return Colors.green;
    if (status == 'Dead') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202127),
        title: Text(character.name),
        actions: [
          IconButton(
            tooltip: _isFavorite
                ? 'Quitar de favoritos'
                : 'Agregar a favoritos',
            onPressed: _isLoading || _isSaving
                ? null
                : _toggleFavorite,
            icon: _isLoading || _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? Colors.redAccent
                        : const Color(0xFF97CE4C),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              character.image,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 300,
                child: Center(
                  child: Icon(Icons.person, size: 80),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(character.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${character.statusSpanish} - ${character.speciesSpanish}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Género:', character.genderSpanish),
                  _buildInfoRow('Origen:', character.originSpanish),
                  _buildInfoRow('Ubicación:', character.locationSpanish),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading || _isSaving
                          ? null
                          : _toggleFavorite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF97CE4C),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      label: Text(
                        _isFavorite
                            ? 'Quitar de favoritos'
                            : 'Agregar a favoritos',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

