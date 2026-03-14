import 'package:native_geofence/native_geofence.dart';
import 'package:permission_handler/permission_handler.dart';

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

  /// Create sample geofences for testing
  Future<void> createGeofences() async {
    // Example geofence - British Library, London
    final britishLibrary = Geofence(
      id: 'british_library',
      location: Location(
        latitude: 51.5299,
        longitude: -0.1277,
      ),
      radiusMeters: 200,
      triggers: {
        GeofenceEvent.enter,
        GeofenceEvent.exit,
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

    // Example geofence - Birmingham Library
    final birminghamLibrary = Geofence(
      id: 'birmingham_library',
      location: Location(
        latitude: 52.4797,
        longitude: -1.9061,
      ),
      radiusMeters: 200,
      triggers: {
        GeofenceEvent.enter,
        GeofenceEvent.exit,
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

    try {
      await NativeGeofenceManager.instance.createGeofence(
        britishLibrary,
        geofenceCallback,
      );
      await NativeGeofenceManager.instance.createGeofence(
        birminghamLibrary,
        geofenceCallback,
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

/// Callback function for geofence events
/// This must be a top-level function
@pragma('vm:entry-point')
Future<void> geofenceCallback(GeofenceCallbackParams params) async {
  // Handle the geofence event
  // In a real app, you might show a notification or update app state
  print('Geofence triggered: ${params.geofences.map((g) => g.id).join(", ")}');
  print('Event: ${params.event}');
  print('Location: ${params.location?.latitude}, ${params.location?.longitude}');
}
