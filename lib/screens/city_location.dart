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
    mapAsset: 'assets/images/map/airport_map.png',
    destinationFile: 'airport_map.png',
    characterAsset: 'assets/images/characters/airport_bg.png',
    destinationBackground: 'assets/images/bg/airport_bg.png',
  ),
  CityLocation(
    name: 'Transport',
    mapAsset: 'assets/images/map/parking-zone_map.png',
    destinationFile: 'parking-zone_map.png',
    characterAsset: 'assets/images/characters/parking-zone_bg.png',
  ),
  CityLocation(
    name: 'Food',
    mapAsset: 'assets/images/map/restaurant_map.png',
    destinationFile: 'restaurant_map.png',
    characterAsset: 'assets/images/characters/restaurant_bg.png',
  ),
  CityLocation(
    name: 'Tourism',
    mapAsset: 'assets/images/map/landmark_map.png',
    destinationFile: 'landmark_map.png',
    characterAsset: 'assets/images/characters/landmark_bg.png',
    destinationBackground: 'assets/images/bg/landmark_bg.png',
  ),
  CityLocation(
    name: 'Work',
    mapAsset: 'assets/images/map/office_map.png',
    destinationFile: 'office_map.png',
    characterAsset: 'assets/images/characters/office_bg.png',
    destinationBackground: 'assets/images/bg/office_bg.png',
  ),
  CityLocation(
    name: 'Education',
    mapAsset: 'assets/images/map/campus_map.png',
    destinationFile: 'campus_map.png',
    characterAsset: 'assets/images/characters/campus_bg.png',
  ),
  CityLocation(
    name: 'Health',
    mapAsset: 'assets/images/map/hospital_map.png',
    destinationFile: 'hospital_map.png',
    characterAsset: 'assets/images/characters/hospital_bg.png',
    destinationBackground: 'assets/images/bg/hospital_bg.png',
  ),
  CityLocation(
    name: 'Shopping',
    mapAsset: 'assets/images/map/market_map.png',
    destinationFile: 'market_map.png',
    characterAsset: 'assets/images/characters/market_bg.png',
    destinationBackground: 'assets/images/bg/market_bg.png',
  ),
];
