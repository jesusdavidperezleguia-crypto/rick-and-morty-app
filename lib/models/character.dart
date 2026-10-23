
class Character {
final int id;
final String name;
final String status;
final String species;
final String gender;
final String image;
final String origin;
final String location;

Character({
required this.id,
required this.name,
required this.status,
required this.species,
required this.gender,
required this.image,
required this.origin,
required this.location,
});

// Traducción del estado del personaje.
String get statusSpanish {
switch (status.toLowerCase()) {
case 'alive':
return 'Vivo';
case 'dead':
return 'Muerto';
default:
return 'Desconocido';
}
}

// Traducción de la especie.
String get speciesSpanish {
switch (species.toLowerCase()) {
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
case 'poopybutthole':
return 'Poopybutthole';
case 'cronenberg':
return 'Cronenberg';
case 'disease':
return 'Enfermedad';
case 'unknown':
return 'Desconocida';
default:
return species;
}
}

// Traducción del género.
String get genderSpanish {
switch (gender.toLowerCase()) {
case 'male':
return 'Masculino';
case 'female':
return 'Femenino';
case 'genderless':
return 'Sin género';
default:
return 'Desconocido';
}
}

// Traducción de nombres frecuentes de lugares.
String get originSpanish => _translatePlace(origin);

String get locationSpanish => _translatePlace(location);

String _translatePlace(String place) {
switch (place.toLowerCase()) {
case 'unknown':
return 'Desconocido';
case 'earth (c-137)':
return 'Tierra (C-137)';
case 'earth (replacement dimension)':
return 'Tierra (dimensión de reemplazo)';
case 'earth (unknown dimension)':
return 'Tierra (dimensión desconocida)';
case 'earth':
return 'Tierra';
case 'abadango':
return 'Abadango';
case 'citadel of ricks':
return 'Ciudadela de los Rick';
case 'worldender':
return 'Worldender';
case 'post-apocalyptic earth':
return 'Tierra postapocalíptica';
case 'nuptia 4':
return 'Nuptia 4';
default:
return place;
}
}

factory Character.fromJson(Map<String, dynamic> json) {
final originData =
json['origin'] as Map<String, dynamic>? ?? {};

final locationData =
json['location'] as Map<String, dynamic>? ?? {};

return Character(
id: json['id'] as int,
name: json['name']?.toString() ?? 'Sin nombre',
status: json['status']?.toString() ?? 'unknown',
species: json['species']?.toString() ?? 'unknown',
gender: json['gender']?.toString() ?? 'unknown',
image: json['image']?.toString() ?? '',
origin: originData['name']?.toString() ?? 'unknown',
location: locationData['name']?.toString() ?? 'unknown',
);
}
}
