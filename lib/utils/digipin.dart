// DIGIPIN Encoder and Decoder Library in Dart
// Developed by India Post, Department of Posts (Converted from JS)
// Licensed for public use

// Usage
// void main() {
//   final digiPin = DigiPin.getDigiPin(28.61, 77.20); // Delhi coordinates
//   print('DIGIPIN: $digiPin');

//   final coords = DigiPin.getLatLngFromDigiPin(digiPin);
//   print('Latitude: ${coords['latitude']}, Longitude: ${coords['longitude']}');
// }

class DigiPin {
  static const List<List<String>> _grid = [
    ['F', 'C', '9', '8'],
    ['J', '3', '2', '7'],
    ['K', '4', '5', '6'],
    ['L', 'M', 'P', 'T'],
  ];

  static const double _minLat = 2.5;
  static const double _maxLat = 38.5;
  static const double _minLon = 63.5;
  static const double _maxLon = 99.5;

  static String getDigiPin(double lat, double lon) {
    if (lat < _minLat || lat > _maxLat) {
      throw Exception('Latitude out of range');
    }
    if (lon < _minLon || lon > _maxLon) {
      throw Exception('Longitude out of range');
    }

    double minLat = _minLat;
    double maxLat = _maxLat;
    double minLon = _minLon;
    double maxLon = _maxLon;

    StringBuffer digiPin = StringBuffer();

    for (int level = 1; level <= 10; level++) {
      final latDiv = (maxLat - minLat) / 4;
      final lonDiv = (maxLon - minLon) / 4;

      int row = 3 - ((lat - minLat) ~/ latDiv);
      int col = ((lon - minLon) ~/ lonDiv);

      row = row.clamp(0, 3);
      col = col.clamp(0, 3);

      digiPin.write(_grid[row][col]);

      if (level == 3 || level == 6) digiPin.write('-');

      maxLat = minLat + latDiv * (4 - row);
      minLat = minLat + latDiv * (3 - row);
      minLon = minLon + lonDiv * col;
      maxLon = minLon + lonDiv;
    }

    return digiPin.toString();
  }

  static Map<String, String> getLatLngFromDigiPin(String digiPin) {
    final pin = digiPin.replaceAll('-', '');
    if (pin.length != 10) {
      throw Exception('Invalid DIGIPIN');
    }

    double minLat = _minLat;
    double maxLat = _maxLat;
    double minLon = _minLon;
    double maxLon = _maxLon;

    for (int i = 0; i < 10; i++) {
      final char = pin[i];
      bool found = false;
      int row = -1, col = -1;

      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          if (_grid[r][c] == char) {
            row = r;
            col = c;
            found = true;
            break;
          }
        }
        if (found) break;
      }

      if (!found) throw Exception('Invalid character in DIGIPIN');

      final latDiv = (maxLat - minLat) / 4;
      final lonDiv = (maxLon - minLon) / 4;

      final lat1 = maxLat - latDiv * (row + 1);
      final lat2 = maxLat - latDiv * row;
      final lon1 = minLon + lonDiv * col;
      final lon2 = minLon + lonDiv * (col + 1);

      minLat = lat1;
      maxLat = lat2;
      minLon = lon1;
      maxLon = lon2;
    }

    final centerLat = ((minLat + maxLat) / 2).toStringAsFixed(6);
    final centerLon = ((minLon + maxLon) / 2).toStringAsFixed(6);

    return {'latitude': centerLat, 'longitude': centerLon};
  }
}
