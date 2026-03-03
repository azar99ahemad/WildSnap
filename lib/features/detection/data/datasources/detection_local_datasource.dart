import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Local data source for detection-related data
abstract class DetectionLocalDatasource {
  /// Gets species information from local storage
  Future<Map<String, dynamic>> getSpeciesInfo(String speciesId);

  /// Gets all species data
  Future<Map<String, dynamic>> getAllSpeciesData();

  /// Searches species by name
  Future<List<Map<String, dynamic>>> searchSpecies(String query);
}

/// Implementation of DetectionLocalDatasource
class DetectionLocalDatasourceImpl implements DetectionLocalDatasource {
  Map<String, dynamic>? _speciesCache;

  Future<void> _ensureDataLoaded() async {
    if (_speciesCache != null) return;

    try {
      final jsonString = await rootBundle.loadString(AppConstants.speciesDataPath);
      _speciesCache = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('Failed to load species data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getSpeciesInfo(String speciesId) async {
    await _ensureDataLoaded();
    
    final normalizedId = speciesId.toLowerCase().replaceAll(' ', '_');
    final speciesData = _speciesCache!['species'] as Map<String, dynamic>?;
    
    if (speciesData == null || !speciesData.containsKey(normalizedId)) {
      return {};
    }
    
    return speciesData[normalizedId] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getAllSpeciesData() async {
    await _ensureDataLoaded();
    return _speciesCache!;
  }

  @override
  Future<List<Map<String, dynamic>>> searchSpecies(String query) async {
    await _ensureDataLoaded();
    
    final results = <Map<String, dynamic>>[];
    final speciesData = _speciesCache!['species'] as Map<String, dynamic>?;
    
    if (speciesData == null) return results;

    final lowerQuery = query.toLowerCase();
    
    for (final entry in speciesData.entries) {
      final species = entry.value as Map<String, dynamic>;
      final name = (species['name'] as String?)?.toLowerCase() ?? '';
      final scientificName = (species['scientific_name'] as String?)?.toLowerCase() ?? '';
      
      if (name.contains(lowerQuery) || scientificName.contains(lowerQuery)) {
        results.add(species);
      }
    }
    
    return results;
  }
}
