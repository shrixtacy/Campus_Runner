class AppConstants {
  // ZONES: Dropdowns for Pickup/Drop
  static const List<String> pickupZones = [
    "Main Canteen",
    "Nescafe Kiosk",
    "Admin Block",
    "Library (Central)",
    "Stationery Shop",
    "Pharmacy (Gate 1)",
  ];

  static const List<String> dropZones = [
    "Boys Hostel A",
    "Boys Hostel B",
    "Girls Hostel C",
    "Lecture Hall Complex",
    "Main Ground",
    "Library Reading Room",
  ];

  // Approx campus center (update with exact coordinates if needed)
  static const List<double> campusCenter = [23.2575, 77.4096];

  // Zone coordinates used for smart routing (update with real campus points)
  static const Map<String, List<double>> zoneCoordinates = {
    "Main Canteen": [23.2579, 77.4104],
    "Nescafe Kiosk": [23.2573, 77.4109],
    "Admin Block": [23.2584, 77.4092],
    "Library (Central)": [23.2568, 77.4098],
    "Stationery Shop": [23.2571, 77.4087],
    "Pharmacy (Gate 1)": [23.2589, 77.4079],
    "Boys Hostel A": [23.2558, 77.4116],
    "Boys Hostel B": [23.2552, 77.4122],
    "Girls Hostel C": [23.2564, 77.4129],
    "Lecture Hall Complex": [23.2581, 77.4111],
    "Main Ground": [23.2549, 77.4091],
    "Library Reading Room": [23.2569, 77.4095],
  };

  // Default campus list used when Firestore has no campuses
  static const List<Map<String, String>> defaultCampuses = [
    {'id': 'vit-bhopal', 'name': 'VIT Bhopal', 'city': 'Bhopal', 'state': 'MP'},
  ];

  static const List<String> transportModes = [
    'Walking',
    'Cycling',
    'Vehicle',
  ];

  // IMAGES (You can add real assets later)
  static const String logo = "assets/images/logo.png";
}
