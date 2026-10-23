
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/character.dart';
import '../models/episode.dart';

class CharacterPageResult {
final List<Character> characters;
final bool hasNext;
final bool hasPrevious;

const CharacterPageResult({
required this.characters,
required this.hasNext,
required this.hasPrevious,
});
}

class ApiService {
final String baseUrl = 'https://rickandmortyapi.com/api';

// ==========================================
// OBTENER PERSONAJES POR PÁGINA
// ==========================================

Future<CharacterPageResult> getCharactersPage({
int page = 1,
String name = '',
}) async {
final uri = Uri.parse('$baseUrl/character').replace(
queryParameters: {
'page': page.toString(),
if (name.trim().isNotEmpty) 'name': name.trim(),
},
);

final response = await http.get(uri);

if (response.statusCode == 200) {
final Map<String, dynamic> data =
json.decode(response.body);

final List results = data['results'];

final characters = results
    .map(
(item) => Character.fromJson(
Map<String, dynamic>.from(item),
),
)
    .toList();

final Map<String, dynamic> info =
Map<String, dynamic>.from(data['info']);

return CharacterPageResult(
characters: characters,
hasNext: info['next'] != null,
hasPrevious: info['prev'] != null,
);
}

if (response.statusCode == 404) {
return const CharacterPageResult(
characters: [],
hasNext: false,
hasPrevious: false,
);
}

throw Exception(
'Error al cargar personajes: ${response.statusCode}',
);
}

// ==========================================
// MÉTODO ANTERIOR, PARA COMPATIBILIDAD
// ==========================================

Future<List<Character>> getCharacters({
int page = 1,
String name = '',
}) async {
final result = await getCharactersPage(
page: page,
name: name,
);

return result.characters;
}

// ==========================================
// PERSONAJE ALEATORIO PARA EL PORTAL
// ==========================================

Future<Character> getRandomCharacter() async {
final response = await http.get(
Uri.parse('$baseUrl/character'),
);

if (response.statusCode != 200) {
throw Exception('No se pudo abrir el portal.');
}

final Map<String, dynamic> data =
json.decode(response.body);

final Map<String, dynamic> info =
Map<String, dynamic>.from(data['info']);

final int totalPages = info['pages'] as int;

if (totalPages < 1) {
throw Exception('No hay personajes disponibles.');
}

final random = Random();
final int randomPage = random.nextInt(totalPages) + 1;

final result = await getCharactersPage(
page: randomPage,
);

if (result.characters.isEmpty) {
throw Exception('No se encontró ningún personaje.');
}

return result.characters[
random.nextInt(result.characters.length)];
}

// ==========================================
// OBTENER TODOS LOS EPISODIOS
// ==========================================

Future<List<Episode>> getEpisodes() async {
final List<Episode> allEpisodes = [];

int page = 1;
int totalPages = 1;

do {
final uri = Uri.parse('$baseUrl/episode').replace(
queryParameters: {
'page': page.toString(),
},
);

final response = await http.get(uri);

if (response.statusCode != 200) {
throw Exception(
'Error al cargar episodios en la página '
'$page: ${response.statusCode}',
);
}

final Map<String, dynamic> data =
json.decode(response.body);

final List results = data['results'];

allEpisodes.addAll(
results.map(
(item) => Episode.fromJson(
Map<String, dynamic>.from(item),
),
),
);

totalPages = data['info']['pages'] as int;

page++;
} while (page <= totalPages);

allEpisodes.sort(
(a, b) => a.id.compareTo(b.id),
);

return allEpisodes;
}

// ==========================================
// OBTENER UN PERSONAJE POR SU URL
// ==========================================

Future<Character> getCharacterByUrl(String url) async {
final response = await http.get(Uri.parse(url));

if (response.statusCode == 200) {
final Map<String, dynamic> data =
json.decode(response.body);

return Character.fromJson(data);
}

throw Exception(
'Error al cargar personaje: ${response.statusCode}',
);
}
}
