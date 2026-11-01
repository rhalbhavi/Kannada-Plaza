const double cityCanvasWidth = 1678;
const double cityCanvasHeight = 937;

class CityLocation {
  const CityLocation({
    required this.name,
    required this.mapAsset,
    required this.destinationFile,
    required this.characterAsset,
    this.destinationBackground,
  });

  final String name;
  final String mapAsset;
  final String destinationFile;
  final String characterAsset;
  final String? destinationBackground;
}

const cityLocations = <CityLocation>[
  CityLocation(
    name: 'Airport / Travel',
    mapAsset: 'assets/images/map/flying_map.png',
    destinationFile: 'flying_bg.png',
    characterAsset: 'assets/images/characters/travel_bg.png',
  ),
  CityLocation(
    name: 'Transport',
    mapAsset: 'assets/images/map/transport_map.png',
    destinationFile: 'transport_bg.dart',
    characterAsset: 'assets/images/characters/transport_bg.png',
  ),
  CityLocation(
    name: 'Food',
    mapAsset: 'assets/images/map/food_map.png',
    destinationFile: 'food_bg.dart',
    characterAsset: 'assets/images/characters/food_bg.png',
  ),
  CityLocation(
    name: 'Tourism',
    mapAsset: 'assets/images/map/tourism_map.png',
    destinationFile: 'tourism_bg.dart',
    characterAsset: 'assets/images/characters/tourism_bg.png',
    destinationBackground: 'assets/images/bg/tourism_bg.png',
  ),
  CityLocation(
    name: 'Work',
    mapAsset: 'assets/images/map/work_map.png',
    destinationFile: 'work_bg.dart',
    characterAsset: 'assets/images/characters/work_bg.png',
    destinationBackground: 'assets/images/bg/work_bg.png',
  ),
  CityLocation(
    name: 'Education',
    mapAsset: 'assets/images/map/education_map.png',
    destinationFile: 'education_bg.dart',
    characterAsset: 'assets/images/characters/education_bg.png',
  ),
  CityLocation(
    name: 'Health',
    mapAsset: 'assets/images/map/health_map.png',
    destinationFile: 'health_bg.dart',
    characterAsset: 'assets/images/characters/health_bg.png',
    destinationBackground: 'assets/images/bg/health_bg.png',
  ),
  CityLocation(
    name: 'Shopping',
    mapAsset: 'assets/images/map/shopping_map.png',
    destinationFile: 'shopping_bg.dart',
    characterAsset: 'assets/images/characters/shopping_bg.png',
    destinationBackground: 'assets/images/bg/shopping_bg.png',
  ),
];
