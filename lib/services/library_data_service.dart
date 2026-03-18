import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/library.dart';

class LibraryDataService {
  static final LibraryDataService _instance = LibraryDataService._internal();
  factory LibraryDataService() => _instance;
  LibraryDataService._internal();

  static const String _apiUrl =
      'https://api.librarydata.uk/libraries';
  static const String _cacheFileName = 'libraries.json';

  List<Library> _libraries = [];
  List<Library> get libraries => List.unmodifiable(_libraries);

  /// Get the local cache file reference.
  Future<File> get _cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_cacheFileName');
  }

  /// Load libraries, using the network when online and falling back to cache.
  Future<List<Library>> getLibraries() async {
    final isOnline = await _hasConnectivity();

    if (isOnline) {
      try {
        _libraries = await _fetchFromNetwork();
        await _saveToCache(_libraries);
      } catch (_) {
        // Network request failed despite connectivity — use cache
        _libraries = await _loadFromCache();
      }
    } else {
      _libraries = await _loadFromCache();
    }

    return libraries;
  }

  /// Fetch library data from the remote API.
  Future<List<Library>> _fetchFromNetwork() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode != 200) {
      throw HttpException('Failed to fetch libraries: ${response.statusCode}');
    }

    final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
    return jsonList
        .map((item) => Library.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Save the library list to a local JSON cache file.
  Future<void> _saveToCache(List<Library> libraries) async {
    final file = await _cacheFile;
    final jsonString =
        json.encode(libraries.map((lib) => lib.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  /// Load the library list from the local JSON cache file.
  Future<List<Library>> _loadFromCache() async {
    final file = await _cacheFile;
    if (!await file.exists()) {
      return [];
    }

    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((item) => Library.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Check whether the device currently has network connectivity.
  Future<bool> _hasConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((status) => status != ConnectivityResult.none);
  }
}
