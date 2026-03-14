import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/geofence_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discover Libraries',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Discover Libraries'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GeofenceService _geofenceService = GeofenceService();
  bool _geofencesEnabled = false;
  bool _isLoading = false;
  String _statusMessage = 'Geofences are disabled';

  @override
  void initState() {
    super.initState();
    _checkGeofenceStatus();
  }

  Future<void> _checkGeofenceStatus() async {
    await _geofenceService.initialize();
    final ids = await _geofenceService.getActiveGeofenceIds();
    setState(() {
      _geofencesEnabled = ids.isNotEmpty;
      _statusMessage = _geofencesEnabled
          ? 'Geofences enabled (${ids.length} active)'
          : 'Geofences are disabled';
    });
  }

  Future<void> _toggleGeofences() async {
    setState(() => _isLoading = true);

    try {
      final enabled = await _geofenceService.toggleGeofences();
      setState(() {
        _geofencesEnabled = enabled;
        _statusMessage = enabled
            ? 'Geofences enabled successfully!'
            : 'Geofences disabled';
      });
    } on GeofencePermissionDeniedException catch (e) {
      setState(() => _statusMessage = e.message);
      _showPermissionDialog();
    } catch (e) {
      setState(() => _statusMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'To use geofencing, this app needs "Always" location permission. '
          'This allows the app to notify you when you\'re near a library, '
          'even when the app is closed.\n\n'
          'Please go to Settings and grant location permission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _geofencesEnabled ? Icons.location_on : Icons.location_off,
              size: 80,
              color: _geofencesEnabled ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _toggleGeofences,
                    icon: Icon(
                      _geofencesEnabled
                          ? Icons.notifications_off
                          : Icons.notifications_active,
                    ),
                    label: Text(
                      _geofencesEnabled
                          ? 'Disable Geofences'
                          : 'Enable Geofences',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            const Text(
              'When enabled, you\'ll receive notifications\n'
              'when you\'re near a library.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
