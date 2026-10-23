
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import 'detail_screen.dart';

class RandomPortalScreen extends StatefulWidget {
const RandomPortalScreen({super.key});

@override
State<RandomPortalScreen> createState() =>
_RandomPortalScreenState();
}

class _RandomPortalScreenState
extends State<RandomPortalScreen> {
static const Color background = Color(0xFF090D16);
static const Color surface = Color(0xFF151C2B);
static const Color portalGreen = Color(0xFFB7F34D);
static const Color muted = Color(0xFF9BA8BA);

final ApiService _api = ApiService();

Character? _character;
bool _loading = false;
bool _favorite = false;
bool _savingFavorite = false;
String? _error;

Future<void> _openPortal() async {
if (_loading || _savingFavorite) return;

setState(() {
_loading = true;
_error = null;
});

try {
final character = await _api.getRandomCharacter();

final isFavorite = await DatabaseHelper.instance
    .isFavorite(character.id);

if (!mounted) return;

setState(() {
_character = character;
_favorite = isFavorite;
_loading = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_loading = false;
_error = 'No se pudo abrir el portal. '
'Revisa tu conexión e inténtalo de nuevo.';
});
}
}

Future<void> _toggleFavorite() async {
final character = _character;

if (character == null || _savingFavorite) return;

setState(() {
_savingFavorite = true;
});

try {
if (_favorite) {
await DatabaseHelper.instance.removeFavorite(
character.id,
);
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
_favorite = !_favorite;
_savingFavorite = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
_favorite
? '${character.name} se agregó a tus favoritos.'
    : '${character.name} se quitó de tus favoritos.',
),
behavior: SnackBarBehavior.floating,
backgroundColor: surface,
),
);
} catch (e) {
if (!mounted) return;

setState(() {
_savingFavorite = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'No se pudo actualizar tu colección.',
),
),
);
}
}

String _statusText(String status) {
switch (status.toLowerCase()) {
case 'alive':
return 'Vivo';
case 'dead':
return 'Muerto';
default:
return 'Desconocido';
}
}

Color _statusColor(String status) {
switch (status.toLowerCase()) {
case 'alive':
return portalGreen;
case 'dead':
return Colors.redAccent;
default:
return Colors.orangeAccent;
}
}

@override
Widget build(BuildContext context) {
final character = _character;

return Scaffold(
backgroundColor: background,
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
const Text(
'MULTIVERSO DETECTADO',
textAlign: TextAlign.center,
style: TextStyle(
color: portalGreen,
fontSize: 11,
letterSpacing: 3,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
const Text(
'Portal aleatorio',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white,
fontSize: 29,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 10),
const Text(
'Cruza el portal y descubre quién aparece '
'desde otra dimensión.',
textAlign: TextAlign.center,
style: TextStyle(
color: muted,
fontSize: 14,
height: 1.5,
),
),
const SizedBox(height: 28),

// Portal animado.
Center(
child: SizedBox(
width: 190,
height: 190,
child: TweenAnimationBuilder<double>(
key: ValueKey(_loading),
tween: Tween<double>(
begin: 0,
end: _loading ? 2 * pi : pi / 8,
),
duration: const Duration(seconds: 2),
builder: (context, angle, child) {
return Transform.rotate(
angle: angle,
child: child,
);
},
child: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color: portalGreen,
width: 3,
),
boxShadow: [
BoxShadow(
color: portalGreen.withValues(
alpha: 0.28,
),
blurRadius: 30,
spreadRadius: 6,
),
],
gradient: RadialGradient(
colors: [
portalGreen.withValues(alpha: 0.32),
const Color(0xFF173D35),
const Color(0xFF101827),
],
),
),
child: const Icon(
Icons.blur_circular_rounded,
color: portalGreen,
size: 125,
),
),
),
),
),

const SizedBox(height: 24),

if (_loading) ...[
const Center(
child: CircularProgressIndicator(
color: portalGreen,
),
),
const SizedBox(height: 12),
const Text(
'Buscando en el multiverso...',
textAlign: TextAlign.center,
style: TextStyle(color: muted),
),
] else if (_error != null) ...[
Text(
_error!,
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.redAccent,
height: 1.5,
),
),
] else if (character == null) ...[
const Text(
'¿Estás listo para conocer a alguien nuevo?',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white,
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
],

if (character != null) ...[
const SizedBox(height: 8),
_characterCard(character),
],

const SizedBox(height: 22),

ElevatedButton.icon(
onPressed: _loading ? null : _openPortal,
style: ElevatedButton.styleFrom(
backgroundColor: portalGreen,
foregroundColor: Colors.black,
disabledBackgroundColor:
portalGreen.withValues(alpha: 0.35),
minimumSize: const Size.fromHeight(54),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
icon: Icon(
character == null
? Icons.auto_awesome
    : Icons.refresh_rounded,
),
label: Text(
character == null
? 'ACTIVAR PORTAL'
    : 'OTRO PERSONAJE',
style: const TextStyle(
fontWeight: FontWeight.w900,
letterSpacing: 1,
),
),
),
],
),
),
),
);
}

Widget _characterCard(Character character) {
return Container(
decoration: BoxDecoration(
color: surface,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: portalGreen.withValues(alpha: 0.35),
),
),
clipBehavior: Clip.antiAlias,
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Stack(
children: [
AspectRatio(
aspectRatio: 1.12,
child: Image.network(
character.image,
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) {
return const ColoredBox(
color: surface,
child: Icon(
Icons.person,
color: muted,
size: 90,
),
);
},
loadingBuilder: (
context,
child,
loadingProgress,
) {
if (loadingProgress == null) return child;

return const Center(
child: CircularProgressIndicator(
color: portalGreen,
),
);
},
),
),
Positioned(
top: 12,
right: 12,
child: Container(
decoration: BoxDecoration(
color: background.withValues(alpha: 0.9),
shape: BoxShape.circle,
),
child: IconButton(
tooltip: _favorite
? 'Quitar de favoritos'
    : 'Agregar a favoritos',
onPressed: _savingFavorite
? null
    : _toggleFavorite,
icon: Icon(
_favorite
? Icons.favorite
    : Icons.favorite_border,
color: _favorite
? Colors.redAccent
    : Colors.white,
size: 29,
),
),
),
),
Positioned(
left: 12,
bottom: 12,
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 7,
),
decoration: BoxDecoration(
color: background.withValues(alpha: 0.92),
borderRadius: BorderRadius.circular(30),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 8,
height: 8,
decoration: BoxDecoration(
color: _statusColor(character.status),
shape: BoxShape.circle,
),
),
const SizedBox(width: 7),
Text(
_statusText(character.status),
style: const TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
fontSize: 12,
),
),
],
),
),
),
],
),

Padding(
padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
character.name,
style: const TextStyle(
color: Colors.white,
fontSize: 24,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 14),

_infoRow(
Icons.science_outlined,
'Especie',
character.species,
),
const SizedBox(height: 10),

_infoRow(
Icons.transgender_rounded,
'Género',
character.gender,
),
const SizedBox(height: 10),

_infoRow(
Icons.public_rounded,
'Origen',
character.origin,
),
const SizedBox(height: 10),

_infoRow(
Icons.location_on_outlined,
'Ubicación',
character.location,
),

const SizedBox(height: 20),

OutlinedButton.icon(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => DetailScreen(
character: character,
),
),
);
},
style: OutlinedButton.styleFrom(
foregroundColor: portalGreen,
side: const BorderSide(
color: portalGreen,
),
minimumSize: const Size.fromHeight(48),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
icon: const Icon(Icons.open_in_new_rounded),
label: const Text('VER DETALLES'),
),
],
),
),
],
),
);
}

Widget _infoRow(
IconData icon,
String label,
String value,
) {
return Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
icon,
color: portalGreen,
size: 20,
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
label,
style: const TextStyle(
color: muted,
fontSize: 12,
),
),
const SizedBox(height: 2),
Text(
value,
style: const TextStyle(
color: Colors.white,
fontSize: 14,
fontWeight: FontWeight.w600,
),
),
],
),
),
],
);
}
}

