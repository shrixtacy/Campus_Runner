import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/directions_service.dart';
import '../../../logic/campus_provider.dart';
import '../../../logic/task_provider.dart';

class SmartRouteScreen extends ConsumerStatefulWidget {
  const SmartRouteScreen({super.key});

  @override
  ConsumerState<SmartRouteScreen> createState() => _SmartRouteScreenState();
}

class _SmartRouteScreenState extends ConsumerState<SmartRouteScreen> {
  final Set<String> _selectedTaskIds = {};
  final DirectionsService _directionsService = DirectionsService();

  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  DirectionsResult? _result;
  bool _isLoading = false;

  LatLng get _campusCenter =>
      LatLng(AppConstants.campusCenter[0], AppConstants.campusCenter[1]);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _toggleSelection(String taskId, bool selected) {
    setState(() {
      if (selected) {
        _selectedTaskIds.add(taskId);
      } else {
        _selectedTaskIds.remove(taskId);
      }
    });
  }

  Future<void> _buildRoute(List<TaskModel> tasks) async {
    const apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (apiKey.isEmpty) {
      _showError('Missing GOOGLE_MAPS_API_KEY. Use --dart-define.');
      return;
    }

    if (tasks.isEmpty) {
      _showError('Select at least one task.');
      return;
    }

    final stops = <LatLng>[];
    for (final task in tasks) {
      final pickup = _zoneToLatLng(task.pickup);
      final drop = _zoneToLatLng(task.drop);
      if (pickup == null || drop == null) {
        _showError('Missing coordinates for ${task.pickup} or ${task.drop}.');
        return;
      }
      stops.add(pickup);
      stops.add(drop);
    }

    if (stops.length < 2) {
      _showError('At least two stops are required.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _directionsService.getOptimizedRoute(
        stops: stops,
        apiKey: apiKey,
      );

      final markers = <Marker>{};
      for (var i = 0; i < stops.length; i++) {
        markers.add(
          Marker(
            markerId: MarkerId('stop_$i'),
            position: stops[i],
            infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
          ),
        );
      }

      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: result.polyline,
        color: Colors.blueAccent,
        width: 5,
      );

      setState(() {
        _markers = markers;
        _polylines = {polyline};
        _result = result;
      });

      _fitToPolyline(result.polyline);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  LatLng? _zoneToLatLng(String zone) {
    final coords = AppConstants.zoneCoordinates[zone];
    if (coords == null || coords.length != 2) return null;
    return LatLng(coords[0], coords[1]);
  }

  void _fitToPolyline(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
  }

  String _formatDistance(int? meters) {
    if (meters == null) return '--';
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '--';
    final mins = (seconds / 60).round();
    return '$mins min';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    final campusesAsync = ref.watch(campusesStreamProvider);
    final selectedCampusId = ref.watch(selectedCampusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Route')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: campusesAsync.when(
              data: (campuses) {
                final campusItems = [
                  const DropdownMenuItem(
                    value: 'all',
                    child: Text('All campuses'),
                  ),
                  ...campuses.map(
                    (campus) => DropdownMenuItem(
                      value: campus.id,
                      child: Text(campus.name),
                    ),
                  ),
                ];

                return DropdownButtonFormField<String>(
                  initialValue: selectedCampusId ?? 'all',
                  decoration: const InputDecoration(
                    labelText: 'Filter by campus',
                    border: OutlineInputBorder(),
                  ),
                  items: campusItems,
                  onChanged: (value) {
                    ref.read(selectedCampusProvider.notifier).state =
                        value ?? 'all';
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
            ),
          ),
          SizedBox(
            height: 280,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _campusCenter,
                zoom: 16,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
              polylines: _polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Route: ${_formatDistance(_result?.distanceMeters)} • ${_formatDuration(_result?.durationSeconds)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          final data = tasksAsync.value ?? [];
                          final selected = data
                              .where(
                                (task) => _selectedTaskIds.contains(task.id),
                              )
                              .toList();
                          _buildRoute(selected);
                        },
                  icon: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.alt_route),
                  label: Text(_isLoading ? 'Routing...' : 'Optimize'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(child: Text('No open tasks.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final selected = _selectedTaskIds.contains(task.id);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (val) =>
                          _toggleSelection(task.id, val ?? false),
                      title: Text(task.title),
                      subtitle: Text('${task.pickup} -> ${task.drop}'),
                      secondary: Text('₹${task.price}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
