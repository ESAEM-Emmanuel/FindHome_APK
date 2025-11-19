// // lib/pages/property_map_page.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
// import '../services/property_service.dart';
// import '../models/property_model.dart';
// import '../providers/settings_provider.dart';
// import '../constants/app_translations.dart';

// class PropertyMapPage extends StatefulWidget {
//   const PropertyMapPage({super.key});

//   @override
//   State<PropertyMapPage> createState() => _PropertyMapPageState();
// }

// class _PropertyMapPageState extends State<PropertyMapPage> {
//   final PropertyService _propertyService = PropertyService();
//   final MapController _mapController = MapController();

//   List<Property> _properties = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   Position? _userPosition;
//   bool _locationLoading = true;
//   double _currentZoom = 13.0;

//   // Filtres
//   String _currentSearchQuery = '';
//   double _maxPrice = 500000;
//   String _selectedCategory = 'all';

//   @override
//   void initState() {
//     super.initState();
//     _initializeLocationAndProperties();
//   }

//   Future<void> _initializeLocationAndProperties() async {
//     try {
//       // 1. Obtenir la position de l'utilisateur
//       await _getUserLocation();
      
//       // 2. Charger les propriétés
//       await _loadProperties();
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = "Erreur lors de l'initialisation: ${e.toString()}";
//           _isLoading = false;
//           _locationLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _getUserLocation() async {
//     try {
//       // Vérifier les permissions
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Permissions de localisation refusées');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Permissions de localisation définitivement refusées');
//       }

//       // Obtenir la position actuelle
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );

//       if (mounted) {
//         setState(() {
//           _userPosition = position;
//           _locationLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _locationLoading = false;
//           _errorMessage = "Impossible d'obtenir la localisation: ${e.toString()}";
//         });
//       }
//     }
//   }

//   Future<void> _loadProperties() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Charger toutes les propriétés (sans pagination pour la carte)
//       final response = await _propertyService.getProperties(
//         page: 1,
//         limit: 100, // Augmenter la limite pour la carte
//         search: _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
//       );

//       if (mounted) {
//         setState(() {
//           _properties = response.records;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = "Erreur de chargement des propriétés: ${e.toString()}";
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // Filtrer les propriétés selon les critères
//   List<Property> get _filteredProperties {
//     return _properties.where((property) {
//       // Filtre par prix
//       if (property.monthlyPrice > _maxPrice) return false;
      
//       // Filtre par catégorie
//       if (_selectedCategory != 'all' && property.category.name.toLowerCase() != _selectedCategory) {
//         return false;
//       }
      
//       return true;
//     }).toList();
//   }

//   // Calculer la distance entre l'utilisateur et une propriété
//   double? _calculateDistance(Property property) {
//     if (_userPosition == null || !property.hasValidLocation) return null;
    
//     final userLatLng = LatLng(_userPosition!.latitude, _userPosition!.longitude);
//     final propertyLatLng = LatLng(property.latitude!, property.longitude!);
    
//     final Distance distance = const Distance();
//     return distance(userLatLng, propertyLatLng) / 1000; // Conversion en kilomètres
//   }

//   // Centrer la carte sur la position de l'utilisateur
//   void _centerOnUserLocation() {
//     if (_userPosition != null) {
//       _mapController.move(
//         LatLng(_userPosition!.latitude, _userPosition!.longitude),
//         _currentZoom,
//       );
//     }
//   }

//   // Widget pour les marqueurs de propriétés
//   List<Marker> _buildPropertyMarkers(BuildContext context) {
//     return _filteredProperties.where((property) => property.hasValidLocation).map((property) {
//       final distance = _calculateDistance(property);
      
//       return Marker(
//         point: LatLng(property.latitude!, property.longitude!),
//         width: 50,
//         height: 50,
//         builder: (ctx) => GestureDetector(
//           onTap: () {
//             _showPropertyPopup(context, property, distance);
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.secondary,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//               border: Border.all(
//                 color: Colors.white,
//                 width: 2,
//               ),
//             ),
//             child: Icon(
//               _getPropertyIcon(property.category.name),
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   // Widget pour le marqueur de l'utilisateur
//   Marker? _buildUserMarker(BuildContext context) {
//     if (_userPosition == null) return null;
    
//     return Marker(
//       point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
//       width: 40,
//       height: 40,
//       builder: (ctx) => Container(
//         decoration: BoxDecoration(
//           color: Colors.blue,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.5),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//           border: Border.all(
//             color: Colors.white,
//             width: 2,
//           ),
//         ),
//         child: const Icon(
//           Icons.person_pin_circle,
//           color: Colors.white,
//           size: 20,
//         ),
//       ),
//     );
//   }

//   // Obtenir l'icône selon la catégorie
//   IconData _getPropertyIcon(String category) {
//     switch (category.toLowerCase()) {
//       case 'appartement':
//         return Icons.apartment;
//       case 'maison':
//         return Icons.house;
//       case 'terrain':
//         return Icons.landscape;
//       case 'suite':
//         return Icons.king_bed;
//       default:
//         return Icons.home;
//     }
//   }

//   // Afficher le popup d'une propriété
//   void _showPropertyPopup(BuildContext context, Property property, double? distance) {
//     final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
    
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Text(
//             property.title,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     property.mainImage,
//                     height: 120,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Container(
//                       height: 120,
//                       color: Colors.grey.shade300,
//                       alignment: Alignment.center,
//                       child: Icon(Icons.home, size: 40, color: Colors.grey.shade500),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
                
//                 // Prix
//                 Text(
//                   '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/mois',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
                
//                 // Détails
//                 Text('${property.area} m² • ${property.roomsNb} pièces'),
//                 Text('${property.town.name} • ${property.category.name}'),
                
//                 // Distance
//                 if (distance != null) ...[
//                   const SizedBox(height: 8),
//                   Text(
//                     'À ${distance.toStringAsFixed(1)} km',
//                     style: TextStyle(
//                       color: Colors.green.shade700,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(AppTranslations.get('close', locale, 'Fermer')),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pushNamed(
//                   '/property-detail',
//                   arguments: {'id': property.id},
//                 );
//               },
//               child: Text(AppTranslations.get('view_details', locale, 'Voir détails')),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Widget pour les contrôles de la carte
//   Widget _buildMapControls(BuildContext context) {
//     return Positioned(
//       top: 16,
//       right: 16,
//       child: Column(
//         children: [
//           // Bouton de recentrage
//           FloatingActionButton.small(
//             onPressed: _centerOnUserLocation,
//             backgroundColor: Colors.white,
//             child: Icon(
//               Icons.my_location,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Bouton de filtres
//           FloatingActionButton.small(
//             onPressed: _showFiltersDialog,
//             backgroundColor: Colors.white,
//             child: Icon(
//               Icons.filter_list,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Dialog pour les filtres
//   void _showFiltersDialog() {
//     final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
    
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text(AppTranslations.get('filters', locale, 'Filtres')),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Filtre par prix maximum
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Prix maximum: ${_maxPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF'),
//                       Slider(
//                         value: _maxPrice,
//                         min: 50000,
//                         max: 1000000,
//                         divisions: 19,
//                         onChanged: (value) {
//                           setState(() {
//                             _maxPrice = value;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
                  
//                   // Filtre par catégorie
//                   DropdownButtonFormField<String>(
//                     value: _selectedCategory,
//                     items: [
//                       DropdownMenuItem(
//                         value: 'all',
//                         child: Text(AppTranslations.get('all_categories', locale, 'Toutes les catégories')),
//                       ),
//                       ..._properties.map((property) => property.category.name).toSet().map((category) {
//                         return DropdownMenuItem(
//                           value: category.toLowerCase(),
//                           child: Text(category),
//                         );
//                       }),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedCategory = value ?? 'all';
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: AppTranslations.get('category', locale, 'Catégorie'),
//                       border: const OutlineInputBorder(),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     _resetFilters();
//                   },
//                   child: Text(AppTranslations.get('reset', locale, 'Réinitialiser')),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     _loadProperties();
//                   },
//                   child: Text(AppTranslations.get('apply', locale, 'Appliquer')),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _resetFilters() {
//     setState(() {
//       _maxPrice = 500000;
//       _selectedCategory = 'all';
//     });
//     _loadProperties();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
//     final LatLng center = _userPosition != null 
//         ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
//         : const LatLng(4.0511, 9.7679); // Douala par défaut

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppTranslations.get('map_view', locale, 'Vue carte')),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _initializeLocationAndProperties,
//           ),
//         ],
//       ),
//       body: _isLoading || _locationLoading
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Chargement de la carte...'),
//                 ],
//               ),
//             )
//           : _errorMessage != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 50,
//                         color: Theme.of(context).colorScheme.error,
//                       ),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                         child: Text(
//                           _errorMessage!,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Theme.of(context).hintColor,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: _initializeLocationAndProperties,
//                         child: Text(AppTranslations.get('retry', locale, 'Réessayer')),
//                       ),
//                     ],
//                   ),
//                 )
//               : Stack(
//                   children: [
//                     // Carte principale
//                     FlutterMap(
//                       mapController: _mapController,
//                       options: MapOptions(
//                         center: center,
//                         zoom: _currentZoom,
//                         onPositionChanged: (position, hasGesture) {
//                           if (hasGesture) {
//                             setState(() {
//                               _currentZoom = position.zoom!;
//                             });
//                           }
//                         },
//                       ),
//                       children: [
//                         // Couche de tuiles OpenStreetMap
//                         TileLayer(
//                           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                           userAgentPackageName: 'com.yourapp.immobilier',
//                         ),
//                         // Marqueurs des propriétés
//                         MarkerLayer(
//                           markers: [
//                             ..._buildPropertyMarkers(context),
//                             if (_buildUserMarker(context) != null) _buildUserMarker(context)!,
//                           ],
//                         ),
//                       ],
//                     ),
                    
//                     // Contrôles de la carte
//                     _buildMapControls(context),
                    
//                     // Légende en bas
//                     Positioned(
//                       bottom: 16,
//                       left: 16,
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.9),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '${_filteredProperties.length} propriétés',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Zoom: ${_currentZoom.toStringAsFixed(1)}',
//                               style: const TextStyle(fontSize: 12, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }
// }
// lib/pages/property_map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import '../providers/settings_provider.dart';
import '../constants/app_translations.dart';
import '../constants/app_themes.dart';

class PropertyMapPage extends StatefulWidget {
  const PropertyMapPage({super.key});

  @override
  State<PropertyMapPage> createState() => _PropertyMapPageState();
}

class _PropertyMapPageState extends State<PropertyMapPage> {
  final PropertyService _propertyService = PropertyService();
  final MapController _mapController = MapController();

  List<Property> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;
  Position? _userPosition;
  bool _locationLoading = true;
  double _currentZoom = 13.0;

  // Filtres
  String _currentSearchQuery = '';
  double _maxPrice = 500000;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _initializeLocationAndProperties();
  }

  Future<void> _initializeLocationAndProperties() async {
    try {
      await _getUserLocation();
      await _loadProperties();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur lors de l'initialisation: ${e.toString()}";
          _isLoading = false;
          _locationLoading = false;
        });
      }
    }
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissions de localisation refusées');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissions de localisation définitivement refusées');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (mounted) {
        setState(() {
          _userPosition = position;
          _locationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _errorMessage = "Impossible d'obtenir la localisation: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _loadProperties() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _propertyService.getProperties(
        page: 1,
        limit: 100,
        search: _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
      );

      if (mounted) {
        setState(() {
          _properties = response.records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur de chargement des propriétés: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  List<Property> get _filteredProperties {
    return _properties.where((property) {
      if (property.monthlyPrice > _maxPrice) return false;
      if (_selectedCategory != 'all' &&
          property.category.name.toLowerCase() != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();
  }

  double? _calculateDistance(Property property) {
    if (_userPosition == null || !property.hasValidLocation) return null;
    final userLatLng = LatLng(_userPosition!.latitude, _userPosition!.longitude);
    final propertyLatLng = LatLng(property.latitude!, property.longitude!);
    const Distance distance = Distance();
    return distance(userLatLng, propertyLatLng) / 1000;
  }

  void _centerOnUserLocation() {
    if (_userPosition != null) {
      _mapController.move(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        _currentZoom,
      );
    }
  }

  IconData _getPropertyIcon(String category) {
    switch (category.toLowerCase()) {
      case 'appartement':
        return Icons.apartment;
      case 'maison':
        return Icons.house;
      case 'terrain':
        return Icons.landscape;
      case 'suite':
        return Icons.king_bed;
      default:
        return Icons.home;
    }
  }

  void _showPropertyPopup(BuildContext context, Property property, double? distance) {
    final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          property.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  property.mainImage,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: theme.dividerColor,
                    alignment: Alignment.center,
                    child: Icon(Icons.home,
                        size: 40, color: theme.hintColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/mois',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text('${property.area} m² • ${property.roomsNb} pièces'),
              Text('${property.town.name} • ${property.category.name}'),
              if (distance != null) ...[
                const SizedBox(height: 8),
                Text(
                  'À ${distance.toStringAsFixed(1)} km',
                  style: TextStyle(
                    color: AppThemes.getSuccessColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppTranslations.get('close', locale, 'Fermer')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                '/property-detail',
                arguments: {'id': property.id},
              );
            },
            child: Text(AppTranslations.get('view_details', locale, 'Voir détails')),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildPropertyMarkers(BuildContext context) {
    return _filteredProperties.where((p) => p.hasValidLocation).map((property) {
      final distance = _calculateDistance(property);
      return Marker(
        point: LatLng(property.latitude!, property.longitude!),
        width: 50,
        height: 50,
        builder: (_) => GestureDetector(
          onTap: () => _showPropertyPopup(context, property, distance),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              _getPropertyIcon(property.category.name),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  Marker? _buildUserMarker(BuildContext context) {
    if (_userPosition == null) return null;
    return Marker(
      point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
      width: 40,
      height: 40,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildMapControls(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: 'center',
            onPressed: _centerOnUserLocation,
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(Icons.my_location,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'filter',
            onPressed: _showFiltersDialog,
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(Icons.filter_list,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    final locale = Provider.of<SettingsProvider>(context, listen: false).locale;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(AppTranslations.get('filters', locale, 'Filtres')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppTranslations.get('max_price', locale, 'Prix max')}: ${_maxPrice.toStringAsFixed(0)} XOF',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Slider(
                  value: _maxPrice,
                  min: 50000,
                  max: 1000000,
                  divisions: 19,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  inactiveColor: Theme.of(context).dividerColor,
                  onChanged: (v) => setState(() => _maxPrice = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text(AppTranslations.get('all_categories', locale,
                          'Toutes les catégories')),
                    ),
                    ..._properties
                        .map((p) => p.category.name)
                        .toSet()
                        .map((cat) => DropdownMenuItem(
                              value: cat.toLowerCase(),
                              child: Text(cat),
                            ))
                        .toList(),
                  ],
                  onChanged: (v) => setState(() => _selectedCategory = v ?? 'all'),
                  decoration: InputDecoration(
                    labelText: AppTranslations.get('category', locale, 'Catégorie'),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetFilters();
                },
                child: Text(AppTranslations.get('reset', locale, 'Réinitialiser')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadProperties();
                },
                child: Text(AppTranslations.get('apply', locale, 'Appliquer')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _maxPrice = 500000;
      _selectedCategory = 'all';
    });
    _loadProperties();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    final theme = Theme.of(context);
    final center = _userPosition != null
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : const LatLng(4.0511, 9.7679); // Douala par défaut

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.get('map_view', locale, 'Vue carte')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeLocationAndProperties,
          ),
        ],
      ),
      body: _isLoading || _locationLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: theme.colorScheme.secondary),
                  const SizedBox(height: 16),
                  Text(AppTranslations.get('loading', locale, 'Chargement...')),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 50, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _initializeLocationAndProperties,
                        child: Text(AppTranslations.get('retry', locale, 'Réessayer')),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: center,
                        zoom: _currentZoom,
                        onPositionChanged: (pos, hasGesture) {
                          if (hasGesture) {
                            setState(() => _currentZoom = pos.zoom!);
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.yourapp.immobilier',
                        ),
                        MarkerLayer(
                          markers: [
                            ..._buildPropertyMarkers(context),
                            if (_buildUserMarker(context) != null)
                              _buildUserMarker(context)!,
                          ],
                        ),
                      ],
                    ),
                    _buildMapControls(context),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.cardColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_filteredProperties.length} ${AppTranslations.get('properties', locale)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Zoom: ${_currentZoom.toStringAsFixed(1)}',
                              style: TextStyle(color: theme.hintColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}