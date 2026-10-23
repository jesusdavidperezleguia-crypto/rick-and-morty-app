
import 'package:flutter/material.dart';

import '../models/episode.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../widgets/local_video_player.dart';

class EpisodeDetailScreen extends StatefulWidget {
  final Episode episode;

  const EpisodeDetailScreen({
    super.key,
    required this.episode,
  });

  @override
  State<EpisodeDetailScreen> createState() =>
      _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<EpisodeDetailScreen> {
  final ApiService _api = ApiService();

  late Future<List<Character>> _charactersFuture;

  bool _isSaved = false;
  bool _isSaving = false;
  bool _isCheckingSaved = true;

  static const Color background = Color(0xFF090D14);
  static const Color panel = Color(0xFF151D29);
  static const Color green = Color(0xFFB7F34D);
  static const Color muted = Color(0xFF929DAD);

  @override
  void initState() {
    super.initState();
    _charactersFuture = _loadCharacters();
    _registerEpisodeHistory();
    _checkSavedEpisode();
  }

  Future<void> _registerEpisodeHistory() async {
    try {
      final episode = widget.episode;

      await DatabaseHelper.instance.addWatchHistory(
        episodeId: episode.id,
        name: episode.name,
        episodeCode: episode.episode,
      );
    } catch (e) {
      debugPrint('Error al guardar el historial: $e');
    }
  }

  Future<void> _checkSavedEpisode() async {
    try {
      final result = await DatabaseHelper.instance
          .isEpisodeSaved(widget.episode.id);

      if (!mounted) return;

      setState(() {
        _isSaved = result;
        _isCheckingSaved = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCheckingSaved = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al consultar episodios guardados: $e')),
      );
    }
  }

  Future<void> _toggleSavedEpisode() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final episode = widget.episode;

      if (_isSaved) {
        await DatabaseHelper.instance.removeSavedEpisode(episode.id);
      } else {
        await DatabaseHelper.instance.saveEpisode(
          id: episode.id,
          name: episode.name,
          episodeCode: episode.episode,
          airDate: episode.airDate,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSaved = !_isSaved;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved
                ? 'Episodio agregado a Mi colección'
                : 'Episodio eliminado de guardados',
          ),
          backgroundColor: panel,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el episodio: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<List<Character>> _loadCharacters() async {
    final List<Character> characters = [];

    for (final url in widget.episode.characters) {
      try {
        final character = await _api.getCharacterByUrl(url);
        characters.add(character);
      } catch (e) {
        debugPrint('No se pudo cargar un personaje: $e');
      }
    }

    return characters;
  }

  String? _getVideoPath(String code) {
    final match = RegExp(r'^S(\d+)E(\d+)$').firstMatch(code);

    if (match == null) return null;

    final season = int.parse(match.group(1)!);
    final episodeNumber = int.parse(match.group(2)!);

    if (season < 1 ||
        season > 5 ||
        episodeNumber < 1 ||
        episodeNumber > 11) {
      return null;
    }

    final prefix = season == 5 ? 'Episodio' : 'episodio';

    return 'assets/videos/temporada_$season/$prefix$episodeNumber.mp4';
  }


  String _getSynopsis(String code) {
    const synopses = <String, String>{
      // TEMPORADA 1
      'S01E01': 'Rick lleva a Morty a otra dimensión para conseguir semillas especiales, mientras su familia empieza a preocuparse por la influencia del científico.',
      'S01E02': 'Rick y Morty entran en los sueños de un profesor para ayudar a Morty con sus notas, mientras el perro de la familia desarrolla una inteligencia extraordinaria.',
      'S01E03': 'Rick encoge a Morty y lo introduce en un parque temático construido dentro de un ser humano, donde una visita de prueba se convierte en una peligrosa misión.',
      'S01E04': 'Rick intenta descubrir quién está detrás de una simulación alienígena diseñada para robarle información, mientras Jerry vive su propia aventura.',
      'S01E05': 'Morty pide una aventura más emocionante y ambos terminan enfrentándose a una misión que se complica por sus decisiones.',
      'S01E06': 'Una poción creada por Rick para ayudar a Morty con su vida amorosa provoca una transformación que amenaza a toda la humanidad.',
      'S01E07': 'Morty descubre que tiene un hijo después de una aventura en otro planeta, y Rick y Summer viajan allí para resolver la situación.',
      'S01E08': 'Rick instala un sistema de televisión interdimensional y la familia descubre versiones alternativas de sus vidas.',
      'S01E09': 'Rick acepta un trabajo que promete hacer realidad deseos, pero descubre que el negocio tiene consecuencias inesperadas.',
      'S01E10': 'Rick es acusado de un crimen y debe enfrentarse a otros Ricks mientras Morty descubre secretos sobre una organización interdimensional.',
      'S01E11': 'Mientras Rick deja la casa para una fiesta, Summer organiza una reunión que termina convirtiéndose en un caos interdimensional.',

      // TEMPORADA 2
      'S02E01': 'Tras jugar con el tiempo, Rick, Morty y Summer quedan atrapados en realidades temporales divididas que deben reparar para sobrevivir.',
      'S02E02': 'Morty intenta salvar a un ser alienígena y termina envuelto en una aventura que pone a prueba sus principios.',
      'S02E03': 'Rick se reencuentra con un antiguo amor que posee la capacidad de controlar otras formas de vida, y debe afrontar sentimientos del pasado.',
      'S02E04': 'La familia Smith recibe visitas que parecen formar parte de sus recuerdos, pero Morty sospecha que algo extraño está ocurriendo.',
      'S02E05': 'Una amenaza de origen extraterrestre obliga a Rick y Morty a participar en un espectáculo musical para intentar salvar la Tierra.',
      'S02E06': 'Rick necesita reparar su vehículo y revela que existe un universo diminuto dentro de una batería, con sus propios habitantes y conflictos.',
      'S02E07': 'Rick utiliza un cuerpo adolescente para infiltrarse en la escuela de Summer, mientras Beth y Jerry intentan resolver sus problemas.',
      'S02E08': 'Jerry queda atrapado en una situación médica alienígena y la familia vuelve a ver programas absurdos de otras dimensiones.',
      'S02E09': 'Rick y Morty llegan a un planeta donde la violencia está permitida durante una noche, y deben luchar para escapar con vida.',
      'S02E10': 'La familia asiste a la boda de Birdperson y Tammy, pero la celebración termina revelando una traición que cambia sus vidas.',

      // TEMPORADA 3
      'S03E01': 'Desde una prisión de la Federación Galáctica, Rick prepara una compleja estrategia para escapar y recuperar su libertad.',
      'S03E02': 'Mientras Beth y Jerry afrontan su separación, Rick lleva a Morty y Summer a un mundo de estilo posapocalíptico.',
      'S03E03': 'Rick se convierte en un pepinillo para evitar una actividad familiar, pero acaba enfrentándose a peligros que no había previsto.',
      'S03E04': 'Rick y Morty participan en una misión con un grupo de superhéroes, donde una serie de trampas convierte la aventura en una lucha por sobrevivir.',
      'S03E05': 'Rick lleva a Jerry a un parque alienígena que promete seguridad, pero ambos terminan envueltos en una conspiración peligrosa.',
      'S03E06': 'Después de una aventura agotadora, Rick y Morty intentan relajarse y descubren que separar sus emociones tiene consecuencias inesperadas.',
      'S03E07': 'Morty descubre una ciudad habitada por versiones alternativas de Ricks y Mortys, donde se desarrollan conflictos políticos y sociales.',
      'S03E08': 'Rick le muestra a Morty recuerdos de aventuras pasadas que había borrado de su memoria, revelando experiencias perturbadoras.',
      'S03E09': 'Beth se enfrenta a preguntas sobre su pasado cuando un descubrimiento relacionado con su infancia vuelve a salir a la luz.',
      'S03E10': 'Rick se enfrenta al presidente de Estados Unidos después de un desacuerdo que transforma una misión aparentemente sencilla en un conflicto.',

      // TEMPORADA 4
      'S04E01': 'Morty consulta una tecnología que le permite ver posibles futuros y toma decisiones que desencadenan una cadena de situaciones peligrosas.',
      'S04E02': 'Rick protege un lugar privado que considera suyo, pero la aparición de un visitante amenaza con revelar su secreto.',
      'S04E03': 'Rick y Morty se enfrentan a un grupo de ladrones que organizan golpes imposibles, en una competición llena de engaños y planes.',
      'S04E04': 'Morty desea tener un dragón y Rick acepta ayudarlo, aunque el vínculo mágico entre ellos termina provocando problemas.',
      'S04E05': 'Una emergencia espacial relacionada con serpientes lleva a Rick y Morty a alterar acontecimientos que generan consecuencias temporales.',
      'S04E06': 'Rick y Morty quedan atrapados en una historia que cambia de formato y cuestiona las reglas de sus propias aventuras.',
      'S04E07': 'Rick y Morty llegan a un planeta dominado por organismos alienígenas que controlan a sus habitantes y deben encontrar la forma de escapar.',
      'S04E08': 'Morty exige a Rick una solución para evitar consecuencias de sus errores, pero el invento resultante convierte su vida en un desastre.',
      'S04E09': 'Rick y la familia visitan un planeta donde Beth se enfrenta a una situación inesperada relacionada con sus decisiones personales.',
      'S04E10': 'La familia debe afrontar las consecuencias de los conflictos de Beth y la aparición de una versión espacial de ella.',

      // TEMPORADA 5
      'S05E01': 'Rick recibe la visita de su antiguo enemigo, mientras Morty intenta organizar una cita y ambas situaciones se complican.',
      'S05E02': 'Una amenaza alienígena persigue a la familia Smith, que descubre que Rick ha creado familias señuelo para protegerse.',
      'S05E03': 'Morty se enamora de una heroína comprometida con el medioambiente, mientras Rick y Summer se embarcan en una aventura destructiva.',
      'S05E04': 'Un experimento de Morty provoca una amenaza de criaturas gigantes y la familia debe intervenir para detener el peligro.',
      'S05E05': 'Beth acompaña a Rick en una salida al infierno, mientras Morty y Summer intentan impresionar a un nuevo compañero.',
      'S05E06': 'Rick y Morty celebran una fiesta inspirada en la historia estadounidense que termina convirtiéndose en un enfrentamiento peligroso.',
      'S05E07': 'Rick reúne a su familia alrededor de una nueva obsesión tecnológica y busca construir un equipo de robots gigantes.',
      'S05E08': 'Rick intenta recuperar los recuerdos de un viejo amigo, y Morty descubre partes del pasado de su abuelo que permanecían ocultas.',
      'S05E09': 'Morty y Rick se separan después de una discusión y cada uno busca un nuevo compañero para sus próximas aventuras.',
      'S05E10': 'Rick y Morty se enfrentan a revelaciones sobre el pasado de Rick, la Ciudadela y los misterios que rodean a otras versiones de ambos.',
    };

    return synopses[code] ??
        'La sinopsis de este episodio todavía no está disponible.';
  }


  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    final videoPath = _getVideoPath(episode.episode);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: const Text(
          'Detalle del episodio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: _isSaved
                ? 'Quitar de guardados'
                : 'Guardar episodio',
            onPressed: _isCheckingSaved || _isSaving
                ? null
                : _toggleSavedEpisode,
            icon: _isCheckingSaved || _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: green,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: green.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.live_tv_rounded,
                      color: green,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    episode.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      episode.episode,
                      style: const TextStyle(
                        color: background,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _infoRow(
                    Icons.calendar_month_rounded,
                    'Fecha de emisión',
                    episode.airDate,
                  ),
                  const SizedBox(height: 14),
                  _infoRow(
                    Icons.people_alt_rounded,
                    'Personajes registrados',
                    '${episode.characters.length}',
                  ),
                  const SizedBox(height: 22),
                  const Divider(color: Color(0xFF343C4B)),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: green,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'SINOPSIS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getSynopsis(episode.episode),
                    style: const TextStyle(
                      color: Color(0xFFD1D7E0),
                      fontSize: 15,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCheckingSaved || _isSaving
                          ? null
                          : _toggleSavedEpisode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        _isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_add_outlined,
                      ),
                      label: Text(
                        _isSaved
                            ? 'Quitar de guardados'
                            : 'Guardar episodio',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Reproducir episodio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Episodio ${episode.episode}',
              style: const TextStyle(color: muted, height: 1.5),
            ),
            const SizedBox(height: 14),
            if (videoPath != null)
              LocalVideoPlayer(
                key: ValueKey(episode.episode),
                assetPath: videoPath,
              )
            else
              const Text(
                'No hay un video asignado a este episodio.',
                style: TextStyle(color: muted),
              ),
            const SizedBox(height: 30),
            const Text(
              'Personajes del episodio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pulsa un personaje para consultar su información.',
              style: TextStyle(color: muted, height: 1.5),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Character>>(
              future: _charactersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(color: green),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    'No se pudieron cargar los personajes.',
                    style: TextStyle(color: Colors.white),
                  );
                }

                final characters = snapshot.data ?? [];

                if (characters.isEmpty) {
                  return const Text(
                    'No hay personajes disponibles.',
                    style: TextStyle(color: muted),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: characters.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final character = characters[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            character.image,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              width: 58,
                              height: 58,
                              child: Icon(Icons.person, color: green),
                            ),
                          ),
                        ),
                        title: Text(
                          character.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${character.species} • ${character.status}',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: green,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  _CharacterInfoScreen(character: character),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: green, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
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

class _CharacterInfoScreen extends StatelessWidget {
  final Character character;

  const _CharacterInfoScreen({required this.character});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFFB7F34D);

    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D14),
        foregroundColor: Colors.white,
        title: Text(character.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              character.image,
              width: double.infinity,
              height: 320,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 200,
                child: Center(
                  child: Icon(Icons.person, color: green, size: 80),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _detailRow('Estado', character.status),
                  _detailRow('Especie', character.species),
                  _detailRow('Género', character.gender),
                  _detailRow('Origen', character.origin),
                  _detailRow('Ubicación', character.location),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB7F34D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFFD1D7E0),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

