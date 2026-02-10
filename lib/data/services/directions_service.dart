import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsResult {
  final List<LatLng> polyline;
  final int? distanceMeters;
  final int? durationSeconds;

  const DirectionsResult({
    required this.polyline,
    this.distanceMeters,
    this.durationSeconds,
  });
}

class DirectionsService {
  Future<DirectionsResult> getOptimizedRoute({
    required List<LatLng> stops,
    required String apiKey,
  }) async {
    if (stops.length < 2) {
      throw Exception('At least two stops are required.');
    }

    final origin = _formatLatLng(stops.first);
    final destination = _formatLatLng(stops.last);

    final waypointStops = stops.sublist(1, stops.length - 1);
    final waypoints = waypointStops.isEmpty
        ? null
        : 'optimize:true|${waypointStops.map(_formatLatLng).join('|')}';

    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': origin,
      'destination': destination,
      if (waypoints != null) 'waypoints': waypoints,
      'key': apiKey,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Directions API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String?;
    if (status != 'OK') {
      throw Exception('Directions API status: $status');
    }

    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      throw Exception('No routes found.');
    }

    final overview = routes.first['overview_polyline'] as Map<String, dynamic>;
    final points = overview['points'] as String;

    int totalDistance = 0;
    int totalDuration = 0;
    final legs = routes.first['legs'] as List<dynamic>;
    for (final leg in legs) {
      totalDistance += (leg['distance']['value'] as int?) ?? 0;
      totalDuration += (leg['duration']['value'] as int?) ?? 0;
    }

    return DirectionsResult(
      polyline: _decodePolyline(points),
      distanceMeters: totalDistance,
      durationSeconds: totalDuration,
    );
  }

  String _formatLatLng(LatLng latLng) =>
      '${latLng.latitude},${latLng.longitude}';

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
