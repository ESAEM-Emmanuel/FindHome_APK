// // lib/pages/property_map_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
// import '../services/property_service.dart';
// import '../services/town_service.dart';
// import '../services/category_service.dart';
// import '../models/property_model.dart';
// import '../models/town.dart';
// import '../models/category.dart';
// import '../providers/settings_provider.dart';
// import '../constants/app_translations.dart';
// import '../constants/app_themes.dart';

// class PropertyMapPage extends StatefulWidget {
//   const PropertyMapPage({super.key});

//   @override
//   State<PropertyMapPage> createState() => _PropertyMapPageState();
// }

// class _PropertyMapPageState extends State<PropertyMapPage> {
//   final PropertyService _propertyService = PropertyService();
//   final TownService _townService = TownService();
//   final CategoryService _categoryService = CategoryService();
//   final MapController _mapController = MapController();

//   List<Property> _properties = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   Position? _userPosition;
//   bool _locationLoading = true;
//   double _currentZoom = 13.0;

//   // Filtres
//   double _maxPrice = 500000;
//   final Map<String, dynamic> _filters = {
//     'status': 'free',
//     'town_id': '',
//     'category_property_id': '',
//     'certified': '',
//     'active': 'true',
//   };

//   @override
//   void initState() {
//     super.initState();
//     _initializeLocationAndProperties();
//   }

//   Future<void> _initializeLocationAndProperties() async {
//     try {
//       await _getUserLocation();
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
//       // Préparer les filtres pour l'API
//       final Map<String, dynamic> apiFilters = {
//         'status': _filters['status'],
//         'active': _filters['active'],
//       };

//       // Ajouter les filtres optionnels seulement s'ils sont définis
//       if (_filters['town_id']?.isNotEmpty == true) {
//         apiFilters['town_id'] = _filters['town_id'];
//       }
//       if (_filters['category_property_id']?.isNotEmpty == true) {
//         apiFilters['category_property_id'] = _filters['category_property_id'];
//       }
//       if (_filters['certified']?.isNotEmpty == true) {
//         apiFilters['certified'] = _filters['certified'];
//       }

//       final response = await _propertyService.getPropertiesWithFilters({
//         'page': 1,
//         'limit': 100,
//         ...apiFilters,
//       });

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

//   List<Property> get _filteredProperties {
//     return _properties.where((property) {
//       if (property.monthlyPrice > _maxPrice) return false;
//       return true;
//     }).toList();
//   }

//   double? _calculateDistance(Property property) {
//     if (_userPosition == null || !property.hasValidLocation) return null;
//     final userLatLng = LatLng(_userPosition!.latitude, _userPosition!.longitude);
//     final propertyLatLng = LatLng(property.latitude!, property.longitude!);
//     const Distance distance = Distance();
//     return distance(userLatLng, propertyLatLng) / 1000;
//   }

//   void _centerOnUserLocation() {
//     if (_userPosition != null) {
//       _mapController.move(
//         LatLng(_userPosition!.latitude, _userPosition!.longitude),
//         _currentZoom,
//       );
//     }
//   }

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

//   void _showPropertyDetails(BuildContext context, Property property) {
//     Navigator.of(context).pushNamed(
//       '/property-detail',
//       arguments: {'id': property.id},
//     );
//   }

//   void _showPropertyInfo(BuildContext context, Property property, double? distance) {
//     final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
//     final theme = Theme.of(context);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         margin: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: theme.cardColor,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header avec bouton fermer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       property.title,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.primary,
//                         fontSize: 18,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close, color: theme.colorScheme.primary),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Image
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.network(
//                   property.mainImage,
//                   height: 150,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     height: 150,
//                     color: theme.dividerColor,
//                     alignment: Alignment.center,
//                     child: Icon(Icons.home, size: 40, color: theme.hintColor),
//                   ),
//                 ),
//               ),
//             ),
            
//             // Informations
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/mois',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.secondary,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.square_foot, size: 16, color: theme.hintColor),
//                       const SizedBox(width: 4),
//                       Text('${property.area} m²'),
//                       const SizedBox(width: 16),
//                       Icon(Icons.door_front_door, size: 16, color: theme.hintColor),
//                       const SizedBox(width: 4),
//                       Text('${property.roomsNb} pièces'),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(Icons.location_city, size: 16, color: theme.hintColor),
//                       const SizedBox(width: 4),
//                       Text('${property.town.name}'),
//                       const SizedBox(width: 16),
//                       Icon(Icons.category, size: 16, color: theme.hintColor),
//                       const SizedBox(width: 4),
//                       Text(property.category.name),
//                     ],
//                   ),
//                   if (distance != null) ...[
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(Icons.location_on, size: 16, color: AppThemes.getSuccessColor(context)),
//                         const SizedBox(width: 4),
//                         Text(
//                           'À ${distance.toStringAsFixed(1)} km',
//                           style: TextStyle(
//                             color: AppThemes.getSuccessColor(context),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
            
//             // Boutons d'action
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text(AppTranslations.get('close', locale, 'Fermer')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         _showPropertyDetails(context, property);
//                       },
//                       child: Text(AppTranslations.get('view_details', locale, 'Voir détails')),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Marker> _buildPropertyMarkers(BuildContext context) {
//     return _filteredProperties.where((p) => p.hasValidLocation).map((property) {
//       final distance = _calculateDistance(property);
//       return Marker(
//         point: LatLng(property.latitude!, property.longitude!),
//         width: 50,
//         height: 50,
//         builder: (_) => GestureDetector(
//           onTap: () => _showPropertyInfo(context, property, distance),
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
//               border: Border.all(color: Colors.white, width: 2),
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

//   Marker? _buildUserMarker() {
//     if (_userPosition == null) return null;
//     return Marker(
//       point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
//       width: 40,
//       height: 40,
//       builder: (_) => Container(
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
//           border: Border.all(color: Colors.white, width: 2),
//         ),
//         child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 20),
//       ),
//     );
//   }

//   Widget _buildMapControls(BuildContext context) {
//     return Positioned(
//       top: 16,
//       right: 16,
//       child: Column(
//         children: [
//           FloatingActionButton.small(
//             heroTag: 'center_btn',
//             onPressed: _centerOnUserLocation,
//             backgroundColor: Theme.of(context).cardColor,
//             child: Icon(Icons.my_location,
//                 color: Theme.of(context).colorScheme.primary),
//           ),
//           const SizedBox(height: 8),
//           FloatingActionButton.small(
//             heroTag: 'filter_btn',
//             onPressed: _showAdvancedFilters,
//             backgroundColor: Theme.of(context).cardColor,
//             child: Icon(Icons.filter_list,
//                 color: Theme.of(context).colorScheme.primary),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAdvancedFilters() {
//     final locale = Provider.of<SettingsProvider>(context, listen: false).locale;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => _FiltersBottomSheet(
//         maxPrice: _maxPrice,
//         filters: Map.from(_filters),
//         onMaxPriceChanged: (value) => setState(() => _maxPrice = value),
//         onApplyFilters: (newFilters) {
//           setState(() {
//             _filters.clear();
//             _filters.addAll(newFilters);
//             _filters['active'] = 'true'; // Toujours true
//           });
//           _loadProperties();
//           Navigator.of(context).pop();
//         },
//         onResetFilters: () {
//           setState(() {
//             _maxPrice = 500000;
//             _filters.clear();
//             _filters['status'] = 'free';
//             _filters['active'] = 'true';
//           });
//           _loadProperties();
//           Navigator.of(context).pop();
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
//     final theme = Theme.of(context);
//     final center = _userPosition != null
//         ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
//         : const LatLng(4.0511, 9.7679); // Douala par défaut

//     return Scaffold(
//       appBar: AppBar(
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Theme.of(context).colorScheme.primary,
//                 Theme.of(context).colorScheme.primary.withOpacity(0.85),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         title: Text(AppTranslations.get('map_view', locale, 'Vue carte')),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _initializeLocationAndProperties,
//             tooltip: AppTranslations.get('refresh', locale, 'Actualiser'),
//           ),
//         ],
//       ),
//       body: _isLoading || _locationLoading
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(
//                       color: theme.colorScheme.secondary),
//                   const SizedBox(height: 16),
//                   Text(AppTranslations.get('loading', locale, 'Chargement...')),
//                 ],
//               ),
//             )
//           : _errorMessage != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.error_outline,
//                           size: 50, color: theme.colorScheme.error),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 40),
//                         child: Text(
//                           _errorMessage!,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: theme.hintColor),
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
//                     FlutterMap(
//                       mapController: _mapController,
//                       options: MapOptions(
//                         center: center,
//                         zoom: _currentZoom,
//                         onPositionChanged: (pos, hasGesture) {
//                           if (hasGesture && mounted) {
//                             setState(() => _currentZoom = pos.zoom!);
//                           }
//                         },
//                       ),
//                       children: [
//                         TileLayer(
//                           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                           userAgentPackageName: 'com.yourapp.immobilier',
//                         ),
//                         MarkerLayer(
//                           markers: [
//                             ..._buildPropertyMarkers(context),
//                             if (_buildUserMarker() != null) _buildUserMarker()!,
//                           ],
//                         ),
//                       ],
//                     ),
//                     _buildMapControls(context),
//                     Positioned(
//                       bottom: 16,
//                       left: 16,
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: theme.cardColor.withOpacity(0.9),
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
//                               '${_filteredProperties.length} ${AppTranslations.get('properties', locale, 'propriétés')}',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Zoom: ${_currentZoom.toStringAsFixed(1)}',
//                               style: TextStyle(
//                                 color: theme.hintColor, 
//                                 fontSize: 12
//                               ),
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

// class _FiltersBottomSheet extends StatefulWidget {
//   final double maxPrice;
//   final Map<String, dynamic> filters;
//   final ValueChanged<double> onMaxPriceChanged;
//   final ValueChanged<Map<String, dynamic>> onApplyFilters;
//   final VoidCallback onResetFilters;

//   const _FiltersBottomSheet({
//     required this.maxPrice,
//     required this.filters,
//     required this.onMaxPriceChanged,
//     required this.onApplyFilters,
//     required this.onResetFilters,
//   });

//   @override
//   State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
// }

// class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
//   final TownService _townService = TownService();
//   final CategoryService _categoryService = CategoryService();
  
//   late double _maxPrice;
//   late Map<String, dynamic> _filters;

//   // Variables pour la recherche de villes
//   final TextEditingController _townSearchController = TextEditingController();
//   List<Town> _filteredTowns = [];
//   bool _isSearchingTowns = false;
//   bool _showTownDropdown = false;
//   Town? _selectedTown;

//   // Variables pour la recherche de catégories
//   final TextEditingController _categorySearchController = TextEditingController();
//   List<Category> _filteredCategories = [];
//   bool _isSearchingCategories = false;
//   bool _showCategoryDropdown = false;
//   Category? _selectedCategory;

//   @override
//   void initState() {
//     super.initState();
//     _maxPrice = widget.maxPrice;
//     _filters = Map.from(widget.filters);
    
//     // Initialiser les sélections si des IDs existent
//     _initializeSelections();
//   }

//   void _initializeSelections() async {
//     // Ville
//     if (_filters['town_id']?.isNotEmpty == true) {
//       try {
//         final towns = await _townService.getAllTowns();
//         final town = towns.firstWhere(
//           (t) => t.id == _filters['town_id'],
//           orElse: () => towns.first,
//         );
//         if (town.id.isNotEmpty) {
//           setState(() {
//             _selectedTown = town;
//             _townSearchController.text = town.name;
//           });
//         }
//       } catch (e) {
//         debugPrint('Erreur initialisation ville: $e');
//       }
//     }

//     // Catégorie
//     if (_filters['category_property_id']?.isNotEmpty == true) {
//       try {
//         final categories = await _categoryService.getAllCategories();
//         final category = categories.firstWhere(
//           (c) => c.id == _filters['category_property_id'],
//           orElse: () => categories.first,
//         );
//         if (category.id.isNotEmpty) {
//           setState(() {
//             _selectedCategory = category;
//             _categorySearchController.text = category.name;
//           });
//         }
//       } catch (e) {
//         debugPrint('Erreur initialisation catégorie: $e');
//       }
//     }
//   }

//   // Méthode utilitaire pour créer une ville temporaire
//   Town _createTempTown(String id, String name) {
//     return Town(
//       id: id,
//       name: name,
//       countryId: 'temp_country_id', // Valeur temporaire
//       country: Country(id: 'temp_country_id', name: 'Temp Country'), // Valeur temporaire
//     );
//   }

//   // Méthode utilitaire pour créer une catégorie temporaire
//   Category _createTempCategory(String id, String name) {
//     return Category(
//       id: id,
//       name: name,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
    
//     return Padding(
//       padding: const EdgeInsets.all(20).copyWith(
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 AppTranslations.get('filters', locale, 'Filtres'),
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               TextButton(
//                 onPressed: _resetFilters,
//                 child: Text(AppTranslations.get('reset', locale, 'Réinitialiser')),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // Filtre par prix
//                   _buildPriceFilter(locale),
//                   const SizedBox(height: 20),
                  
//                   // Filtre par statut
//                   _buildStatusFilter(locale),
//                   const SizedBox(height: 20),
                  
//                   // Filtre par ville
//                   _buildTownFilter(locale),
//                   const SizedBox(height: 20),
                  
//                   // Filtre par catégorie
//                   _buildCategoryFilter(locale),
//                   const SizedBox(height: 20),
                  
//                   // Filtre certifié
//                   _buildCertifiedFilter(locale),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text(AppTranslations.get('cancel', locale, 'Annuler')),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: _applyFilters,
//                   child: Text(AppTranslations.get('apply_filters', locale, 'Appliquer')),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceFilter(Locale locale) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '${AppTranslations.get('max_price', locale, 'Prix max')}: ${_maxPrice.toStringAsFixed(0)} XOF',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Slider(
//             value: _maxPrice,
//             min: 50000,
//             max: 1000000,
//             divisions: 19,
//             activeColor: Theme.of(context).colorScheme.secondary,
//             inactiveColor: Theme.of(context).dividerColor,
//             onChanged: (v) => setState(() => _maxPrice = v),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('50 000 XOF', style: TextStyle(color: Theme.of(context).hintColor)),
//               Text('1 000 000 XOF', style: TextStyle(color: Theme.of(context).hintColor)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusFilter(Locale locale) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppTranslations.get('status', locale, 'Statut'),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),
//           DropdownButtonFormField<String>(
//             value: _filters['status'],
//             items: [
//               DropdownMenuItem(
//                 value: 'free',
//                 child: Text(_getStatusTranslation(locale, 'free')),
//               ),
//               DropdownMenuItem(
//                 value: 'prev_advise',
//                 child: Text(_getStatusTranslation(locale, 'prev_advise')),
//               ),
//               DropdownMenuItem(
//                 value: 'busy',
//                 child: Text(_getStatusTranslation(locale, 'busy')),
//               ),
//             ],
//             onChanged: (v) => setState(() => _filters['status'] = v ?? 'free'),
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTownFilter(Locale locale) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppTranslations.get('town', locale, 'Ville'),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),
//           TextFormField(
//             controller: _townSearchController,
//             decoration: InputDecoration(
//               hintText: AppTranslations.get('search_town', locale, 'Rechercher une ville...'),
//               prefixIcon: const Icon(Icons.location_city, color: Colors.grey),
//               suffixIcon: _selectedTown != null
//                   ? IconButton(
//                       icon: const Icon(Icons.clear, color: Colors.grey),
//                       onPressed: _clearTownSelection,
//                     )
//                   : _isSearchingTowns
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : null,
//               border: const OutlineInputBorder(),
//             ),
//             onTap: () {
//               if (_townSearchController.text.isEmpty) _loadAllTowns();
//               setState(() => _showTownDropdown = true);
//             },
//             onChanged: _onTownSearchChanged,
//           ),
//           if (_showTownDropdown && _filteredTowns.isNotEmpty)
//             Container(
//               margin: const EdgeInsets.only(top: 4),
//               constraints: const BoxConstraints(maxHeight: 150),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.1))],
//               ),
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _filteredTowns.length,
//                 itemBuilder: (_, index) {
//                   final town = _filteredTowns[index];
//                   return ListTile(
//                     leading: const Icon(Icons.location_city, size: 20),
//                     title: Text(town.name),
//                     dense: true,
//                     onTap: () => _selectTown(town),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryFilter(Locale locale) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppTranslations.get('category', locale, 'Catégorie'),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),
//           TextFormField(
//             controller: _categorySearchController,
//             decoration: InputDecoration(
//               hintText: AppTranslations.get('search_category', locale, 'Rechercher une catégorie...'),
//               prefixIcon: const Icon(Icons.category, color: Colors.grey),
//               suffixIcon: _selectedCategory != null
//                   ? IconButton(
//                       icon: const Icon(Icons.clear, color: Colors.grey),
//                       onPressed: _clearCategorySelection,
//                     )
//                   : _isSearchingCategories
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : null,
//               border: const OutlineInputBorder(),
//             ),
//             onTap: () {
//               if (_categorySearchController.text.isEmpty) _loadAllCategories();
//               setState(() => _showCategoryDropdown = true);
//             },
//             onChanged: _onCategorySearchChanged,
//           ),
//           if (_showCategoryDropdown && _filteredCategories.isNotEmpty)
//             Container(
//               margin: const EdgeInsets.only(top: 4),
//               constraints: const BoxConstraints(maxHeight: 150),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.1))],
//               ),
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _filteredCategories.length,
//                 itemBuilder: (_, index) {
//                   final category = _filteredCategories[index];
//                   return ListTile(
//                     leading: const Icon(Icons.category, size: 20),
//                     title: Text(category.name),
//                     dense: true,
//                     onTap: () => _selectCategory(category),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCertifiedFilter(Locale locale) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppTranslations.get('certified', locale, 'Certifié'),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),
//           DropdownButtonFormField<String>(
//             value: _filters['certified'],
//             items: [
//               DropdownMenuItem(
//                 value: '',
//                 child: Text(AppTranslations.get('all', locale, 'Tous')),
//               ),
//               DropdownMenuItem(
//                 value: 'true',
//                 child: Text(AppTranslations.get('yes', locale, 'Oui')),
//               ),
//               DropdownMenuItem(
//                 value: 'false',
//                 child: Text(AppTranslations.get('no', locale, 'Non')),
//               ),
//             ],
//             onChanged: (v) => setState(() => _filters['certified'] = v ?? ''),
//             decoration: const InputDecoration(
//               border: OutlineInputBorder(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getStatusTranslation(Locale locale, String status) {
//     final translations = {
//       'free': AppTranslations.get('status_free', locale, 'Libre'),
//       'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
//       'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
//     };
//     return translations[status] ?? status;
//   }

//   // Méthodes pour la gestion des villes
//   Future<void> _loadAllTowns() async {
//     try {
//       final towns = await _townService.getAllTowns();
//       setState(() => _filteredTowns = towns);
//     } catch (e) {
//       debugPrint('Erreur chargement villes: $e');
//     }
//   }

//   void _onTownSearchChanged(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _showTownDropdown = false;
//         _filteredTowns = [];
//       });
//       return;
//     }
//     setState(() {
//       _isSearchingTowns = true;
//       _showTownDropdown = true;
//     });
//     try {
//       final response = await _townService.searchTowns(query);
//       setState(() {
//         _filteredTowns = response.records;
//         _isSearchingTowns = false;
//       });
//     } catch (e) {
//       setState(() => _isSearchingTowns = false);
//     }
//   }

//   void _selectTown(Town town) {
//     setState(() {
//       _selectedTown = town;
//       _townSearchController.text = town.name;
//       _showTownDropdown = false;
//       _filters['town_id'] = town.id;
//     });
//   }

//   void _clearTownSelection() {
//     setState(() {
//       _selectedTown = null;
//       _townSearchController.clear();
//       _showTownDropdown = false;
//       _filters['town_id'] = '';
//     });
//   }

//   // Méthodes pour la gestion des catégories
//   Future<void> _loadAllCategories() async {
//     try {
//       final categories = await _categoryService.getAllCategories();
//       setState(() => _filteredCategories = categories);
//     } catch (e) {
//       debugPrint('Erreur chargement catégories: $e');
//     }
//   }

//   void _onCategorySearchChanged(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _showCategoryDropdown = false;
//         _filteredCategories = [];
//       });
//       return;
//     }
//     setState(() {
//       _isSearchingCategories = true;
//       _showCategoryDropdown = true;
//     });
//     try {
//       final response = await _categoryService.searchCategories(query);
//       setState(() {
//         _filteredCategories = response.records;
//         _isSearchingCategories = false;
//       });
//     } catch (e) {
//       setState(() => _isSearchingCategories = false);
//     }
//   }

//   void _selectCategory(Category category) {
//     setState(() {
//       _selectedCategory = category;
//       _categorySearchController.text = category.name;
//       _showCategoryDropdown = false;
//       _filters['category_property_id'] = category.id;
//     });
//   }

//   void _clearCategorySelection() {
//     setState(() {
//       _selectedCategory = null;
//       _categorySearchController.clear();
//       _showCategoryDropdown = false;
//       _filters['category_property_id'] = '';
//     });
//   }

//   void _applyFilters() {
//     widget.onMaxPriceChanged(_maxPrice);
//     widget.onApplyFilters(_filters);
//   }

//   void _resetFilters() {
//     setState(() {
//       _maxPrice = 500000;
//       _filters.clear();
//       _filters['status'] = 'free';
//       _filters['active'] = 'true';
//       _selectedTown = null;
//       _selectedCategory = null;
//       _townSearchController.clear();
//       _categorySearchController.clear();
//       _filteredTowns = [];
//       _filteredCategories = [];
//       _showTownDropdown = false;
//       _showCategoryDropdown = false;
//     });
//     widget.onResetFilters();
//   }
// }

// lib/pages/property_map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/property_service.dart';
import '../services/town_service.dart';
import '../services/category_service.dart';
import '../models/property_model.dart';
import '../models/town.dart';
import '../models/category.dart';
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
  final TownService _townService = TownService();
  final CategoryService _categoryService = CategoryService();
  final MapController _mapController = MapController();

  List<Property> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;
  Position? _userPosition;
  bool _locationLoading = true;
  double _currentZoom = 13.0;

  // Filtres
  double _maxPrice = 500000;
  final Map<String, dynamic> _filters = {
    'status': 'free',
    'town_id': '',
    'category_property_id': '',
    'certified': '',
    'active': 'true',
  };

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
      // Préparer les filtres pour l'API
      final Map<String, dynamic> apiFilters = {
        'status': _filters['status'],
        'active': _filters['active'],
      };

      // Ajouter les filtres optionnels seulement s'ils sont définis
      if (_filters['town_id']?.isNotEmpty == true) {
        apiFilters['town_id'] = _filters['town_id'];
      }
      if (_filters['category_property_id']?.isNotEmpty == true) {
        apiFilters['category_property_id'] = _filters['category_property_id'];
      }
      if (_filters['certified']?.isNotEmpty == true) {
        apiFilters['certified'] = _filters['certified'];
      }

      final response = await _propertyService.getPropertiesWithFilters({
        'page': 1,
        'limit': 100,
        ...apiFilters,
      });

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

  void _showPropertyDetails(BuildContext context, Property property) {
    Navigator.of(context).pushNamed(
      '/property-detail',
      arguments: {'id': property.id},
    );
  }

  void _showPropertyInfo(BuildContext context, Property property, double? distance) {
    final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header avec bouton fermer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      property.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Image
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  property.mainImage,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: theme.dividerColor,
                    alignment: Alignment.center,
                    child: Icon(Icons.home, size: 40, color: theme.hintColor),
                  ),
                ),
              ),
            ),
            
            // Informations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/mois',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.square_foot, size: 16, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text('${property.area} m²'),
                      const SizedBox(width: 16),
                      Icon(Icons.door_front_door, size: 16, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text('${property.roomsNb} pièces'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_city, size: 16, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text('${property.town.name}'),
                      const SizedBox(width: 16),
                      Icon(Icons.category, size: 16, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(property.category.name),
                    ],
                  ),
                  if (distance != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: AppThemes.getSuccessColor(context)),
                        const SizedBox(width: 4),
                        Text(
                          'À ${distance.toStringAsFixed(1)} km',
                          style: TextStyle(
                            color: AppThemes.getSuccessColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Boutons d'action
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppTranslations.get('close', locale, 'Fermer')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showPropertyDetails(context, property);
                      },
                      child: Text(AppTranslations.get('view_details', locale, 'Voir détails')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          onTap: () => _showPropertyInfo(context, property, distance),
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

  Marker? _buildUserMarker() {
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
      top: 80, // Ajusté pour tenir compte de l'AppBar transparente
      right: 16,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: 'center_btn',
            onPressed: _centerOnUserLocation,
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(Icons.my_location,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'filter_btn',
            onPressed: _showAdvancedFilters,
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(Icons.filter_list,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    final locale = Provider.of<SettingsProvider>(context, listen: false).locale;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FiltersBottomSheet(
        maxPrice: _maxPrice,
        filters: Map.from(_filters),
        onMaxPriceChanged: (value) => setState(() => _maxPrice = value),
        onApplyFilters: (newFilters) {
          setState(() {
            _filters.clear();
            _filters.addAll(newFilters);
            _filters['active'] = 'true'; // Toujours true
          });
          _loadProperties();
          Navigator.of(context).pop();
        },
        onResetFilters: () {
          setState(() {
            _maxPrice = 500000;
            _filters.clear();
            _filters['status'] = 'free';
            _filters['active'] = 'true';
          });
          _loadProperties();
          Navigator.of(context).pop();
        },
      ),
    );
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
        backgroundColor: Colors.transparent, // Fond transparent
        elevation: 0, // Supprime l'ombre
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.3), // Transparent avec léger dégradé
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(
          AppTranslations.get('map_view', locale, 'Vue carte'),
          style: TextStyle(
            color: Colors.white, // Texte en blanc pour meilleure visibilité
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Icônes en blanc
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeLocationAndProperties,
            tooltip: AppTranslations.get('refresh', locale, 'Actualiser'),
            color: Colors.white, // Icône en blanc
          ),
        ],
      ),
      extendBodyBehindAppBar: true, // Permet à la carte d'être derrière l'AppBar
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
                          if (hasGesture && mounted) {
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
                            if (_buildUserMarker() != null) _buildUserMarker()!,
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
                              '${_filteredProperties.length} ${AppTranslations.get('properties', locale, 'propriétés')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Zoom: ${_currentZoom.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: theme.hintColor, 
                                fontSize: 12
                              ),
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

class _FiltersBottomSheet extends StatefulWidget {
  final double maxPrice;
  final Map<String, dynamic> filters;
  final ValueChanged<double> onMaxPriceChanged;
  final ValueChanged<Map<String, dynamic>> onApplyFilters;
  final VoidCallback onResetFilters;

  const _FiltersBottomSheet({
    required this.maxPrice,
    required this.filters,
    required this.onMaxPriceChanged,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  final TownService _townService = TownService();
  final CategoryService _categoryService = CategoryService();
  
  late double _maxPrice;
  late Map<String, dynamic> _filters;

  // Variables pour la recherche de villes
  final TextEditingController _townSearchController = TextEditingController();
  List<Town> _filteredTowns = [];
  bool _isSearchingTowns = false;
  bool _showTownDropdown = false;
  Town? _selectedTown;

  // Variables pour la recherche de catégories
  final TextEditingController _categorySearchController = TextEditingController();
  List<Category> _filteredCategories = [];
  bool _isSearchingCategories = false;
  bool _showCategoryDropdown = false;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _maxPrice = widget.maxPrice;
    _filters = Map.from(widget.filters);
    
    // Initialiser les sélections si des IDs existent
    _initializeSelections();
  }

  void _initializeSelections() async {
    // Ville
    if (_filters['town_id']?.isNotEmpty == true) {
      try {
        final towns = await _townService.getAllTowns();
        final town = towns.firstWhere(
          (t) => t.id == _filters['town_id'],
          orElse: () => towns.first,
        );
        if (town.id.isNotEmpty) {
          setState(() {
            _selectedTown = town;
            _townSearchController.text = town.name;
          });
        }
      } catch (e) {
        debugPrint('Erreur initialisation ville: $e');
      }
    }

    // Catégorie
    if (_filters['category_property_id']?.isNotEmpty == true) {
      try {
        final categories = await _categoryService.getAllCategories();
        final category = categories.firstWhere(
          (c) => c.id == _filters['category_property_id'],
          orElse: () => categories.first,
        );
        if (category.id.isNotEmpty) {
          setState(() {
            _selectedCategory = category;
            _categorySearchController.text = category.name;
          });
        }
      } catch (e) {
        debugPrint('Erreur initialisation catégorie: $e');
      }
    }
  }

  // Méthode utilitaire pour créer une ville temporaire
  Town _createTempTown(String id, String name) {
    return Town(
      id: id,
      name: name,
      countryId: 'temp_country_id', // Valeur temporaire
      country: Country(id: 'temp_country_id', name: 'Temp Country'), // Valeur temporaire
    );
  }

  // Méthode utilitaire pour créer une catégorie temporaire
  Category _createTempCategory(String id, String name) {
    return Category(
      id: id,
      name: name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    
    return Padding(
      padding: const EdgeInsets.all(20).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.get('filters', locale, 'Filtres'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(AppTranslations.get('reset', locale, 'Réinitialiser')),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Filtre par prix
                  _buildPriceFilter(locale),
                  const SizedBox(height: 20),
                  
                  // Filtre par statut
                  _buildStatusFilter(locale),
                  const SizedBox(height: 20),
                  
                  // Filtre par ville
                  _buildTownFilter(locale),
                  const SizedBox(height: 20),
                  
                  // Filtre par catégorie
                  _buildCategoryFilter(locale),
                  const SizedBox(height: 20),
                  
                  // Filtre certifié
                  _buildCertifiedFilter(locale),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppTranslations.get('cancel', locale, 'Annuler')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text(AppTranslations.get('apply_filters', locale, 'Appliquer')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter(Locale locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppTranslations.get('max_price', locale, 'Prix max')}: ${_maxPrice.toStringAsFixed(0)} XOF',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Slider(
            value: _maxPrice,
            min: 50000,
            max: 1000000,
            divisions: 19,
            activeColor: Theme.of(context).colorScheme.secondary,
            inactiveColor: Theme.of(context).dividerColor,
            onChanged: (v) => setState(() => _maxPrice = v),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50 000 XOF', style: TextStyle(color: Theme.of(context).hintColor)),
              Text('1 000 000 XOF', style: TextStyle(color: Theme.of(context).hintColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(Locale locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('status', locale, 'Statut'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _filters['status'],
            items: [
              DropdownMenuItem(
                value: 'free',
                child: Text(_getStatusTranslation(locale, 'free')),
              ),
              DropdownMenuItem(
                value: 'prev_advise',
                child: Text(_getStatusTranslation(locale, 'prev_advise')),
              ),
              DropdownMenuItem(
                value: 'busy',
                child: Text(_getStatusTranslation(locale, 'busy')),
              ),
            ],
            onChanged: (v) => setState(() => _filters['status'] = v ?? 'free'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTownFilter(Locale locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('town', locale, 'Ville'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _townSearchController,
            decoration: InputDecoration(
              hintText: AppTranslations.get('search_town', locale, 'Rechercher une ville...'),
              prefixIcon: const Icon(Icons.location_city, color: Colors.grey),
              suffixIcon: _selectedTown != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearTownSelection,
                    )
                  : _isSearchingTowns
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
              border: const OutlineInputBorder(),
            ),
            onTap: () {
              if (_townSearchController.text.isEmpty) _loadAllTowns();
              setState(() => _showTownDropdown = true);
            },
            onChanged: _onTownSearchChanged,
          ),
          if (_showTownDropdown && _filteredTowns.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.1))],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredTowns.length,
                itemBuilder: (_, index) {
                  final town = _filteredTowns[index];
                  return ListTile(
                    leading: const Icon(Icons.location_city, size: 20),
                    title: Text(town.name),
                    dense: true,
                    onTap: () => _selectTown(town),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(Locale locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('category', locale, 'Catégorie'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _categorySearchController,
            decoration: InputDecoration(
              hintText: AppTranslations.get('search_category', locale, 'Rechercher une catégorie...'),
              prefixIcon: const Icon(Icons.category, color: Colors.grey),
              suffixIcon: _selectedCategory != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearCategorySelection,
                    )
                  : _isSearchingCategories
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
              border: const OutlineInputBorder(),
            ),
            onTap: () {
              if (_categorySearchController.text.isEmpty) _loadAllCategories();
              setState(() => _showCategoryDropdown = true);
            },
            onChanged: _onCategorySearchChanged,
          ),
          if (_showCategoryDropdown && _filteredCategories.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.1))],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCategories.length,
                itemBuilder: (_, index) {
                  final category = _filteredCategories[index];
                  return ListTile(
                    leading: const Icon(Icons.category, size: 20),
                    title: Text(category.name),
                    dense: true,
                    onTap: () => _selectCategory(category),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCertifiedFilter(Locale locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('certified', locale, 'Certifié'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _filters['certified'],
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(AppTranslations.get('all', locale, 'Tous')),
              ),
              DropdownMenuItem(
                value: 'true',
                child: Text(AppTranslations.get('yes', locale, 'Oui')),
              ),
              DropdownMenuItem(
                value: 'false',
                child: Text(AppTranslations.get('no', locale, 'Non')),
              ),
            ],
            onChanged: (v) => setState(() => _filters['certified'] = v ?? ''),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusTranslation(Locale locale, String status) {
    final translations = {
      'free': AppTranslations.get('status_free', locale, 'Libre'),
      'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
      'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
    };
    return translations[status] ?? status;
  }

  // Méthodes pour la gestion des villes
  Future<void> _loadAllTowns() async {
    try {
      final towns = await _townService.getAllTowns();
      setState(() => _filteredTowns = towns);
    } catch (e) {
      debugPrint('Erreur chargement villes: $e');
    }
  }

  void _onTownSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showTownDropdown = false;
        _filteredTowns = [];
      });
      return;
    }
    setState(() {
      _isSearchingTowns = true;
      _showTownDropdown = true;
    });
    try {
      final response = await _townService.searchTowns(query);
      setState(() {
        _filteredTowns = response.records;
        _isSearchingTowns = false;
      });
    } catch (e) {
      setState(() => _isSearchingTowns = false);
    }
  }

  void _selectTown(Town town) {
    setState(() {
      _selectedTown = town;
      _townSearchController.text = town.name;
      _showTownDropdown = false;
      _filters['town_id'] = town.id;
    });
  }

  void _clearTownSelection() {
    setState(() {
      _selectedTown = null;
      _townSearchController.clear();
      _showTownDropdown = false;
      _filters['town_id'] = '';
    });
  }

  // Méthodes pour la gestion des catégories
  Future<void> _loadAllCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() => _filteredCategories = categories);
    } catch (e) {
      debugPrint('Erreur chargement catégories: $e');
    }
  }

  void _onCategorySearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showCategoryDropdown = false;
        _filteredCategories = [];
      });
      return;
    }
    setState(() {
      _isSearchingCategories = true;
      _showCategoryDropdown = true;
    });
    try {
      final response = await _categoryService.searchCategories(query);
      setState(() {
        _filteredCategories = response.records;
        _isSearchingCategories = false;
      });
    } catch (e) {
      setState(() => _isSearchingCategories = false);
    }
  }

  void _selectCategory(Category category) {
    setState(() {
      _selectedCategory = category;
      _categorySearchController.text = category.name;
      _showCategoryDropdown = false;
      _filters['category_property_id'] = category.id;
    });
  }

  void _clearCategorySelection() {
    setState(() {
      _selectedCategory = null;
      _categorySearchController.clear();
      _showCategoryDropdown = false;
      _filters['category_property_id'] = '';
    });
  }

  void _applyFilters() {
    widget.onMaxPriceChanged(_maxPrice);
    widget.onApplyFilters(_filters);
  }

  void _resetFilters() {
    setState(() {
      _maxPrice = 500000;
      _filters.clear();
      _filters['status'] = 'free';
      _filters['active'] = 'true';
      _selectedTown = null;
      _selectedCategory = null;
      _townSearchController.clear();
      _categorySearchController.clear();
      _filteredTowns = [];
      _filteredCategories = [];
      _showTownDropdown = false;
      _showCategoryDropdown = false;
    });
    widget.onResetFilters();
  }
}