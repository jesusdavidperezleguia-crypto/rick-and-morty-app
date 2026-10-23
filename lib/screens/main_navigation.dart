
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'collection_screen.dart';
import 'episodes_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'random_portal_screen.dart';

class MainNavigation extends StatefulWidget {
const MainNavigation({super.key});

@override
State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
int _currentIndex = 0;

static const Color portalGreen = Color(0xFF97CE4C);
static const Color appBackground = Color(0xFF12141A);
static const Color surfaceColor = Color(0xFF20232B);

final List<Widget> _screens = const [
HomeScreen(),
EpisodesScreen(),
CollectionScreen(),
RandomPortalScreen(),
];

String get _tituloActual {
switch (_currentIndex) {
case 0:
return 'Personajes';
case 1:
return 'Episodios';
case 2:
return 'Mi colección';
case 3:
return 'Portal aleatorio';
default:
return 'Rick and Morty';
}
}

Future<void> _cerrarSesion() async {
final confirmar = await showDialog<bool>(
context: context,
builder: (dialogContext) => AlertDialog(
backgroundColor: surfaceColor,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(22),
),
icon: const Icon(
Icons.logout_rounded,
color: portalGreen,
size: 34,
),
title: const Text(
'Cerrar sesión',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
content: const Text(
'¿Estás seguro de que quieres salir de tu cuenta?',
style: TextStyle(
color: Colors.white70,
height: 1.5,
),
),
actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
actions: [
TextButton(
onPressed: () => Navigator.pop(dialogContext, false),
child: const Text(
'Cancelar',
style: TextStyle(color: Colors.white70),
),
),
ElevatedButton.icon(
style: ElevatedButton.styleFrom(
backgroundColor: portalGreen,
foregroundColor: Colors.black,
),
onPressed: () => Navigator.pop(dialogContext, true),
icon: const Icon(Icons.logout_rounded),
label: const Text('Salir'),
),
],
),
);

if (confirmar != true || !mounted) return;

try {
await AuthService().logout();

if (!mounted) return;

Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute(
builder: (_) => LoginScreen(),
),
(route) => false,
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('No se pudo cerrar la sesión: $e'),
behavior: SnackBarBehavior.floating,
),
);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: appBackground,
appBar: AppBar(
backgroundColor: appBackground,
titleSpacing: 16,
title: Row(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: portalGreen.withValues(alpha: 0.12),
borderRadius: BorderRadius.circular(14),
border: Border.all(
color: portalGreen.withValues(alpha: 0.35),
),
),
child: const Icon(
Icons.public_rounded,
color: portalGreen,
size: 25,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
_tituloActual,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 19,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 2),
const Text(
'RICK AND MORTY UNIVERSE',
style: TextStyle(
color: portalGreen,
fontSize: 9,
letterSpacing: 1.4,
fontWeight: FontWeight.w700,
),
),
],
),
),
],
),
actions: [
IconButton(
tooltip: 'Cerrar sesión',
onPressed: _cerrarSesion,
icon: const Icon(
Icons.logout_rounded,
color: Colors.white70,
),
),
const SizedBox(width: 6),
],
),
body: IndexedStack(
index: _currentIndex,
children: _screens,
),
bottomNavigationBar: Container(
decoration: const BoxDecoration(
color: surfaceColor,
border: Border(
top: BorderSide(
color: Color(0xFF30343D),
width: 0.7,
),
),
),
child: NavigationBar(
selectedIndex: _currentIndex,
backgroundColor: surfaceColor,
indicatorColor: portalGreen.withValues(alpha: 0.18),
elevation: 0,
height: 72,
labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
onDestinationSelected: (index) {
setState(() {
_currentIndex = index;
});
},
destinations: [
NavigationDestination(
icon: Icon(
Icons.people_outline_rounded,
color: _currentIndex == 0
? portalGreen
    : Colors.white60,
),
selectedIcon: const Icon(
Icons.people_rounded,
color: portalGreen,
),
label: 'Personajes',
),
NavigationDestination(
icon: Icon(
Icons.movie_outlined,
color: _currentIndex == 1
? portalGreen
    : Colors.white60,
),
selectedIcon: const Icon(
Icons.movie_rounded,
color: portalGreen,
),
label: 'Episodios',
),
NavigationDestination(
icon: Icon(
Icons.collections_bookmark_outlined,
color: _currentIndex == 2
? portalGreen
    : Colors.white60,
),
selectedIcon: const Icon(
Icons.collections_bookmark_rounded,
color: portalGreen,
),
label: 'Mi colección',
),
NavigationDestination(
icon: Icon(
Icons.blur_circular_rounded,
color: _currentIndex == 3
? portalGreen
    : Colors.white60,
),
selectedIcon: const Icon(
Icons.auto_awesome,
color: portalGreen,
),
label: 'Portal',
),
],
),
),
);
}
}
