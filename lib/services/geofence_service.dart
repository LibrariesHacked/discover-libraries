import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:permission_handler/permission_handler.dart';

import 'library_data_service.dart';

/// Service to handle geofence operations and permissions
class GeofenceService {
  static final GeofenceService _instance = GeofenceService._internal();
  factory GeofenceService() => _instance;
  GeofenceService._internal();

  bool _geofencesEnabled = false;
  bool get geofencesEnabled => _geofencesEnabled;

  /// Initialize the service by checking for existing geofences.
  /// Call this from your widget's initState.
  Future<void> initialize() async {
    try {
      final ids = await NativeGeofenceManager.instance.getRegisteredGeofenceIds();
      _geofencesEnabled = ids.isNotEmpty;
    } catch (_) {
      _geofencesEnabled = false;
    }
  }

  /// Check and request location permissions
  Future<bool> requestLocationPermission() async {
    // First check if location services are enabled
    if (!await Permission.location.serviceStatus.isEnabled) {
      return false;
    }

    // Request "when in use" permission first
    var status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      return false;
    }

    // Request "always" permission for background geofencing
    status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  /// Check current permission status
  Future<PermissionStatus> checkPermissionStatus() async {
    return await Permission.locationAlways.status;
  }

  /// Create geofences for the 19 nearest libraries to the current location
  Future<void> createGeofences() async {
    final position = await Geolocator.getCurrentPosition();
    final libraries = await LibraryDataService().getLibraries();

    if (libraries.isEmpty) {
      throw Exception('No library data available.');
    }

    // Sort by distance from current location and take the 19 nearest
    final sorted = List.of(libraries)
      ..sort((a, b) {
        final distA = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          a.latitude,
          a.longitude,
        );
        final distB = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });

    final nearest = sorted.take(19).toList();

    // Calculate the distance to the furthest of the 19 nearest libraries
    final furthestLibrary = nearest.last;
    final furthestDistance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      furthestLibrary.latitude,
      furthestLibrary.longitude,
    );

    try {
      for (final library in nearest) {
        final geofence = Geofence(
          id: 'library_${library.id}',
          location: Location(
            latitude: library.latitude,
            longitude: library.longitude,
          ),
          radiusMeters: 150,
          triggers: {
            GeofenceEvent.enter,
          },
          iosSettings: IosGeofenceSettings(
            initialTrigger: true,
          ),
          androidSettings: AndroidGeofenceSettings(
            initialTriggers: {GeofenceEvent.enter},
            notificationResponsiveness: const Duration(minutes: 5),
            loiteringDelay: const Duration(minutes: 1),
          ),
        );

        await NativeGeofenceManager.instance.createGeofence(
          geofence,
          libraryGeofenceCallback,
        );
      }

      // Overall boundary geofence: Triggers exit when user leaves the area
      final boundaryGeofence = Geofence(
        id: 'boundary_geofence',
        location: Location(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
        radiusMeters: furthestDistance,
        triggers: {
          GeofenceEvent.exit,
        },
        iosSettings: IosGeofenceSettings(
          initialTrigger: false,
        ),
        androidSettings: AndroidGeofenceSettings(
          initialTriggers: {},
          notificationResponsiveness: const Duration(minutes: 5),
          loiteringDelay: const Duration(minutes: 1),
        ),
      );

      await NativeGeofenceManager.instance.createGeofence(
        boundaryGeofence,
        boundaryGeofenceCallback,
      );

      _geofencesEnabled = true;
    } catch (e) {
      _geofencesEnabled = false;
      rethrow;
    }
  }

  /// Remove all geofences
  Future<void> removeAllGeofences() async {
    try {
      await NativeGeofenceManager.instance.removeAllGeofences();
      _geofencesEnabled = false;
    } catch (e) {
      rethrow;
    }
  }

  /// Get list of active geofence IDs
  Future<List<String>> getActiveGeofenceIds() async {
    return await NativeGeofenceManager.instance.getRegisteredGeofenceIds();
  }

  /// Toggle geofences on/off
  Future<bool> toggleGeofences() async {
    if (_geofencesEnabled) {
      await removeAllGeofences();
      return false;
    } else {
      // Check permissions first
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw GeofencePermissionDeniedException(
          'Location permission is required to enable geofences. '
          'Please grant "Always" location permission in settings.',
        );
      }
      await createGeofences();
      return true;
    }
  }
}

/// Exception thrown when permissions are denied
class GeofencePermissionDeniedException implements Exception {
  final String message;
  GeofencePermissionDeniedException(this.message);

  @override
  String toString() => message;
}

/// Callback function for library geofence enter events
/// This must be a top-level function
@pragma('vm:entry-point')
Future<void> libraryGeofenceCallback(GeofenceCallbackParams params) async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  for (final geofence in params.geofences) {
    final isEnter = params.event == GeofenceEvent.enter;
    final title = isEnter ? 'Library Nearby' : 'Leaving Library Area';
    final body = isEnter
        ? 'You are near a library!'
        : 'You have left a library area.';

    await plugin.show(
      geofence.id.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'geofence_channel',
          'Geofence Notifications',
          channelDescription: 'Notifications for library geofence events',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}

/// Callback function for boundary geofence exit events
/// Clears and refreshes all geofences when the user leaves the monitored area
@pragma('vm:entry-point')
Future<void> boundaryGeofenceCallback(GeofenceCallbackParams params) async {
  await GeofenceService().removeAllGeofences();
  await GeofenceService().createGeofences();
}
