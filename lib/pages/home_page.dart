// // lib/pages/home_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:ui';
// import '../services/property_service.dart';
// import '../services/town_service.dart';
// import '../services/category_service.dart';
// import '../models/property_model.dart';
// import '../models/town.dart';
// import '../models/category.dart';
// import '../providers/settings_provider.dart';
// import '../providers/auth_provider.dart';
// import '../constants/app_translations.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final PropertyService _propertyService = PropertyService();
//   final TownService _townService = TownService();
//   final CategoryService _categoryService = CategoryService();
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();

//   List<Property> _properties = [];
//   bool _isLoading = true;
//   bool _isPaginating = false;
//   bool _hasMoreData = true;
//   String? _errorMessage;
//   int _currentPage = 1;
//   final int _limit = 10;
//   String _currentSearchQuery = '';

//   // Variables pour les filtres
//   final Map<String, dynamic> _filters = {
//     'search': '',
//     'title': '',
//     'address': '',
//     'monthly_price': '',
//     'monthly_price_bis': '',
//     'monthly_price_operation': '',
//     'area': '',
//     'area_bis': '',
//     'area_operation': '',
//     'rooms_nb': '',
//     'rooms_nb_bis': '',
//     'rooms_nb_operation': '',
//     'bathrooms_nb': '',
//     'bathrooms_nb_bis': '',
//     'bathrooms_nb_operation': '',
//     'living_rooms_nb': '',
//     'living_rooms_nb_bis': '',
//     'living_rooms_nb_operation': '',
//     'compartment_number': '',
//     'compartment_number_bis': '',
//     'compartment_number_operation': '',
//     'status': '',
//     'water_supply': '',
//     'electrical_connection': '',
//     'town_id': '',
//     'category_property_id': '',
//     'certified': '',
//     'has_internal_kitchen': '',
//     'has_external_kitchen': '',
//     'has_a_parking': '',
//     'has_air_conditioning': '',
//     'has_security_guards': '',
//     'has_balcony': '',
//     'order': 'asc',
//   };

//   // Variables pour l'autocomplete des villes
//   final TextEditingController _townSearchController = TextEditingController();
//   List<Town> _filteredTowns = [];
//   Town? _selectedTown;
//   bool _isSearchingTowns = false;
//   bool _showTownDropdown = false;

//   // Variables pour l'autocomplete des catégories
//   final TextEditingController _categorySearchController = TextEditingController();
//   List<Category> _filteredCategories = [];
//   Category? _selectedCategory;
//   bool _isSearchingCategories = false;
//   bool _showCategoryDropdown = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadProperties(isInitialLoad: true);
//     });
    
//     _scrollController.addListener(_scrollListener);
    
//     // Initialisation des listeners pour l'autocomplete
//     _townSearchController.addListener(_onTownSearchChanged);
//     _categorySearchController.addListener(_onCategorySearchChanged);
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
//         !_isLoading && 
//         !_isPaginating && 
//         _hasMoreData) 
//     {
//       _loadProperties(isPaginating: true);
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     _searchController.dispose();
//     _townSearchController.dispose();
//     _categorySearchController.dispose();
//     super.dispose();
//   }

//   // === MÉTHODES POUR L'AUTOCOMPLETE DES VILLES ===

//   Future<void> _loadAllTowns() async {
//     try {
//       final towns = await _townService.getAllTowns();
//       setState(() {
//         _filteredTowns = towns;
//       });
//     } catch (e) {
//       print('Erreur lors du chargement des villes: $e');
//     }
//   }

//   void _onTownSearchChanged() async {
//     final query = _townSearchController.text.trim();
    
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
//       setState(() {
//         _isSearchingTowns = false;
//         _filteredTowns = [];
//       });
//       print('Erreur lors de la recherche de villes: $e');
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

//   // === MÉTHODES POUR L'AUTOCOMPLETE DES CATÉGORIES ===

//   Future<void> _loadAllCategories() async {
//     try {
//       final categories = await _categoryService.getAllCategories();
//       setState(() {
//         _filteredCategories = categories;
//       });
//     } catch (e) {
//       print('Erreur lors du chargement des catégories: $e');
//     }
//   }

//   void _onCategorySearchChanged() async {
//     final query = _categorySearchController.text.trim();
    
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
//       setState(() {
//         _isSearchingCategories = false;
//         _filteredCategories = [];
//       });
//       print('Erreur lors de la recherche de catégories: $e');
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

//   Future<void> _loadProperties({
//     bool isInitialLoad = false,
//     bool isPaginating = false,
//     String? newQuery,
//     Map<String, dynamic>? newFilters,
//   }) async {
//     if (!mounted) return;

//     final bool isNewSearch = newQuery != null;
//     final bool isNewFilter = newFilters != null;
//     final bool shouldReset = isInitialLoad || isNewSearch || isNewFilter || !isPaginating;
    
//     final int nextPage = shouldReset ? 1 : _currentPage + 1;
//     final String effectiveQuery = newQuery ?? _currentSearchQuery;

//     if (isNewFilter) {
//       _filters.addAll(newFilters!);
//     }

//     // Mettre à jour le filtre de recherche
//     _filters['search'] = effectiveQuery;

//     setState(() {
//       if (shouldReset) {
//         _properties = [];
//         _currentPage = 1;
//         _isLoading = true;
//         _hasMoreData = true;
//       } else {
//         _isPaginating = true;
//         _currentPage = nextPage;
//       }
//       _currentSearchQuery = effectiveQuery;
//       _errorMessage = null;
//     });
    
//     try {
//       final response = await _propertyService.getPropertiesWithFilters({
//         'page': nextPage,
//         'limit': _limit,
//         ..._filters,
//       });
      
//       if (mounted) {
//         setState(() {
//           _properties.addAll(response.records);
//           _hasMoreData = response.currentPage < response.totalPages;
//           _isLoading = false;
//           _isPaginating = false;
//         });
//       }
//     } catch (e) {
//       print('ERREUR API DÉTAILLÉE: $e');
//       if (mounted) {
//         String message = AppTranslations.get('data_loading_error', const Locale('fr'), 'Erreur de chargement des données.');
//         if (e.toString().contains('Connection refused') || e.toString().contains('host lookup')) {
//              message = AppTranslations.get('api_connection_error', const Locale('fr'), 'Impossible de se connecter à l\'API. Vérifiez l\'adresse du serveur.');
//         } else if (e.toString().contains('Exception: Échec du chargement')) {
//              message = e.toString().substring(e.toString().indexOf(':') + 1).trim();
//         }

//         setState(() {
//           _errorMessage = message;
//           _isLoading = false;
//           _isPaginating = false;
//           if (isPaginating) _currentPage--;
//         });
//       }
//     }
//   }

//   // === MÉTHODES POUR LE STATUT ===

//   String _getStatusTranslation(Locale locale, String status) {
//     final translations = {
//       'free': AppTranslations.get('status_free', locale, 'Libre'),
//       'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
//       'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
//     };
//     return translations[status] ?? status;
//   }

//   Color _getStatusColor(BuildContext context, String status) {
//     switch (status) {
//       case 'free':
//         return Colors.green;
//       case 'busy':
//         return Colors.red;
//       case 'prev_advise':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status) {
//       case 'free':
//         return Icons.check_circle;
//       case 'busy':
//         return Icons.do_not_disturb;
//       case 'prev_advise':
//         return Icons.access_time;
//       default:
//         return Icons.help_outline;
//     }
//   }

//   // Barre de Recherche et Filtres
//   Widget _buildSearchAndFilter(BuildContext context, Locale locale) {
//     final Color accentColor = Theme.of(context).colorScheme.secondary;

//     return Padding(
//       padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 10),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               onSubmitted: (query) {
//                 _loadProperties(newQuery: query);
//               },
//               decoration: InputDecoration(
//                 hintText: AppTranslations.get('search_placeholder', locale, 'Rechercher un logement...'), 
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 suffixIcon: _currentSearchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear, color: Colors.grey),
//                         onPressed: () {
//                           _searchController.clear();
//                           _loadProperties(newQuery: '');
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Theme.of(context).cardColor,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Container(
//             decoration: BoxDecoration(
//               color: accentColor,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.tune, color: Colors.white),
//               onPressed: () {
//                 _showFilterBottomSheet(context, locale);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // BottomSheet pour les filtres avancés
//   void _showFilterBottomSheet(BuildContext context, Locale locale) {
//     // Variables locales pour les filtres
//     final Map<String, dynamic> localFilters = Map.from(_filters);
    
//     // Contrôleurs pour les champs numériques
//     final TextEditingController priceMinController = TextEditingController(text: localFilters['monthly_price']?.toString() ?? '');
//     final TextEditingController priceMaxController = TextEditingController(text: localFilters['monthly_price_bis']?.toString() ?? '');
//     final TextEditingController areaMinController = TextEditingController(text: localFilters['area']?.toString() ?? '');
//     final TextEditingController areaMaxController = TextEditingController(text: localFilters['area_bis']?.toString() ?? '');
//     final TextEditingController roomsMinController = TextEditingController(text: localFilters['rooms_nb']?.toString() ?? '');
//     final TextEditingController roomsMaxController = TextEditingController(text: localFilters['rooms_nb_bis']?.toString() ?? '');
//     final TextEditingController bathroomsMinController = TextEditingController(text: localFilters['bathrooms_nb']?.toString() ?? '');
//     final TextEditingController bathroomsMaxController = TextEditingController(text: localFilters['bathrooms_nb_bis']?.toString() ?? '');

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               padding: const EdgeInsets.all(20),
//               height: MediaQuery.of(context).size.height * 0.9,
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         AppTranslations.get('filters', locale, 'Filtres'),
//                         style: Theme.of(context).textTheme.titleLarge,
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           // Réinitialiser tous les filtres
//                           localFilters.clear();
//                           _selectedTown = null;
//                           _selectedCategory = null;
//                           _townSearchController.clear();
//                           _categorySearchController.clear();
//                           priceMinController.clear();
//                           priceMaxController.clear();
//                           areaMinController.clear();
//                           areaMaxController.clear();
//                           roomsMinController.clear();
//                           roomsMaxController.clear();
//                           bathroomsMinController.clear();
//                           bathroomsMaxController.clear();
                          
//                           setState(() {});
//                         },
//                         child: Text(AppTranslations.get('reset', locale, 'Réinitialiser')),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
                  
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Filtre par ville
//                           _buildTownFilterSection(context, locale, setState),

//                           // Filtre par catégorie
//                           _buildCategoryFilterSection(context, locale, setState),

//                           // Filtre par statut
//                           _buildFilterSection(
//                             context,
//                             AppTranslations.get('status', locale, 'Statut'),
//                             [
//                               _buildStatusFilterChip(
//                                 context,
//                                 '',
//                                 AppTranslations.get('all_status', locale, 'Tous'),
//                                 (localFilters['status'] ?? '') == '',
//                                 (value) {
//                                   setState(() {
//                                     localFilters['status'] = '';
//                                   });
//                                 },
//                               ),
//                               _buildStatusFilterChip(
//                                 context,
//                                 'free',
//                                 _getStatusTranslation(locale, 'free'),
//                                 localFilters['status'] == 'free',
//                                 (value) {
//                                   setState(() {
//                                     localFilters['status'] = 'free';
//                                   });
//                                 },
//                               ),
//                               _buildStatusFilterChip(
//                                 context,
//                                 'prev_advise',
//                                 _getStatusTranslation(locale, 'prev_advise'),
//                                 localFilters['status'] == 'prev_advise',
//                                 (value) {
//                                   setState(() {
//                                     localFilters['status'] = 'prev_advise';
//                                   });
//                                 },
//                               ),
//                               _buildStatusFilterChip(
//                                 context,
//                                 'busy',
//                                 _getStatusTranslation(locale, 'busy'),
//                                 localFilters['status'] == 'busy',
//                                 (value) {
//                                   setState(() {
//                                     localFilters['status'] = 'busy';
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),

//                           // Filtre par prix
//                           _buildRangeFilterSection(
//                             context,
//                             locale,
//                             AppTranslations.get('monthly_price', locale, 'Prix mensuel'),
//                             'monthly_price',
//                             'monthly_price_bis',
//                             'monthly_price_operation',
//                             localFilters,
//                             priceMinController,
//                             priceMaxController,
//                             setState,
//                             isCurrency: true,
//                           ),

//                           // Filtre par surface
//                           _buildRangeFilterSection(
//                             context,
//                             locale,
//                             AppTranslations.get('area', locale, 'Surface'),
//                             'area',
//                             'area_bis',
//                             'area_operation',
//                             localFilters,
//                             areaMinController,
//                             areaMaxController,
//                             setState,
//                             unit: 'm²',
//                           ),

//                           // Filtre par nombre de chambres
//                           _buildRangeFilterSection(
//                             context,
//                             locale,
//                             AppTranslations.get('rooms', locale, 'Nombre de chambres'),
//                             'rooms_nb',
//                             'rooms_nb_bis',
//                             'rooms_nb_operation',
//                             localFilters,
//                             roomsMinController,
//                             roomsMaxController,
//                             setState,
//                           ),

//                           // Filtre par nombre de salles de bain
//                           _buildRangeFilterSection(
//                             context,
//                             locale,
//                             AppTranslations.get('bathrooms', locale, 'Salles de bain'),
//                             'bathrooms_nb',
//                             'bathrooms_nb_bis',
//                             'bathrooms_nb_operation',
//                             localFilters,
//                             bathroomsMinController,
//                             bathroomsMaxController,
//                             setState,
//                           ),

//                           // Filtre par équipements
//                           _buildEquipmentFilterSection(context, locale, localFilters, setState),

//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Boutons d'action
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text(AppTranslations.get('cancel', locale, 'Annuler')),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // Appliquer les filtres
//                             _loadProperties(newFilters: localFilters, isInitialLoad: true);
//                             Navigator.pop(context);
//                           },
//                           child: Text(AppTranslations.get('apply_filters', locale, 'Appliquer')),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 60),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTownFilterSection(BuildContext context, Locale locale, Function setState) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '${AppTranslations.get('town', locale, 'Ville')}',
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
//                       onPressed: () => _clearTownSelection(),
//                     )
//                   : _isSearchingTowns
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : null,
//             ),
//             onTap: () {
//               if (_townSearchController.text.isEmpty) {
//                 _loadAllTowns();
//               }
//               setState(() {
//                 _showTownDropdown = true;
//               });
//             },
//           ),
          
//           if (_showTownDropdown && _filteredTowns.isNotEmpty)
//             Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     blurRadius: 4,
//                     color: Colors.black.withOpacity(0.1),
//                   ),
//                 ],
//               ),
//               margin: const EdgeInsets.only(top: 4),
//               constraints: const BoxConstraints(maxHeight: 150),
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _filteredTowns.length,
//                 itemBuilder: (context, index) {
//                   final town = _filteredTowns[index];
//                   return ListTile(
//                     leading: const Icon(Icons.location_city, size: 20),
//                     title: Text(town.name),
//                     onTap: () => _selectTown(town),
//                     dense: true,
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryFilterSection(BuildContext context, Locale locale, Function setState) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '${AppTranslations.get('category', locale, 'Catégorie')}',
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
//                       onPressed: () => _clearCategorySelection(),
//                     )
//                   : _isSearchingCategories
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : null,
//             ),
//             onTap: () {
//               if (_categorySearchController.text.isEmpty) {
//                 _loadAllCategories();
//               }
//               setState(() {
//                 _showCategoryDropdown = true;
//               });
//             },
//           ),
          
//           if (_showCategoryDropdown && _filteredCategories.isNotEmpty)
//             Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     blurRadius: 4,
//                     color: Colors.black.withOpacity(0.1),
//                   ),
//                 ],
//               ),
//               margin: const EdgeInsets.only(top: 4),
//               constraints: const BoxConstraints(maxHeight: 150),
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _filteredCategories.length,
//                 itemBuilder: (context, index) {
//                   final category = _filteredCategories[index];
//                   return ListTile(
//                     leading: const Icon(Icons.category, size: 20),
//                     title: Text(category.name),
//                     onTap: () => _selectCategory(category),
//                     dense: true,
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterSection(BuildContext context, String title, List<Widget> children) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: children,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRangeFilterSection(
//     BuildContext context,
//     Locale locale,
//     String title,
//     String minKey,
//     String maxKey,
//     String operationKey,
//     Map<String, dynamic> localFilters,
//     TextEditingController minController,
//     TextEditingController maxController,
//     Function setState, {
//     bool isCurrency = false,
//     String unit = '',
//   }) {
//     final String currentOperation = localFilters[operationKey] ?? '';

//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),

//           // Sélecteur d'opération
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               _buildOperationChip(
//                 context,
//                 '',
//                 AppTranslations.get('range', locale, 'Intervalle'),
//                 currentOperation == '',
//                 (value) {
//                   setState(() {
//                     localFilters[operationKey] = '';
//                   });
//                 },
//               ),
//               _buildOperationChip(
//                 context,
//                 'sup',
//                 AppTranslations.get('greater_than', locale, 'Supérieur à'),
//                 currentOperation == 'sup',
//                 (value) {
//                   setState(() {
//                     localFilters[operationKey] = 'sup';
//                     localFilters[maxKey] = ''; // Désactiver le max
//                     maxController.clear();
//                   });
//                 },
//               ),
//               _buildOperationChip(
//                 context,
//                 'inf',
//                 AppTranslations.get('less_than', locale, 'Inférieur à'),
//                 currentOperation == 'inf',
//                 (value) {
//                   setState(() {
//                     localFilters[operationKey] = 'inf';
//                     localFilters[maxKey] = ''; // Désactiver le max
//                     maxController.clear();
//                   });
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),

//           // Champs de saisie
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: minController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: currentOperation == 'sup' 
//                       ? AppTranslations.get('minimum', locale, 'Minimum')
//                       : AppTranslations.get('from', locale, 'De'),
//                     suffixText: isCurrency ? 'XOF' : unit,
//                     border: const OutlineInputBorder(),
//                   ),
//                   onChanged: (value) {
//                     localFilters[minKey] = value.isEmpty ? '' : int.tryParse(value) ?? 0;
//                   },
//                 ),
//               ),
//               if (currentOperation == '') ...[
//                 const SizedBox(width: 10),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   child: Text(
//                     AppTranslations.get('to', locale, 'à'),
//                     style: TextStyle(
//                       color: Theme.of(context).hintColor,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     controller: maxController,
//                     keyboardType: TextInputType.number,
//                     enabled: currentOperation == '', // Désactivé si opération choisie
//                     decoration: InputDecoration(
//                       labelText: AppTranslations.get('to', locale, 'À'),
//                       suffixText: isCurrency ? 'XOF' : unit,
//                       border: const OutlineInputBorder(),
//                     ),
//                     onChanged: (value) {
//                       localFilters[maxKey] = value.isEmpty ? '' : int.tryParse(value) ?? 0;
//                     },
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEquipmentFilterSection(
//     BuildContext context,
//     Locale locale,
//     Map<String, dynamic> localFilters,
//     Function setState,
//   ) {
//     final equipmentFilters = [
//       {
//         'key': 'has_internal_kitchen',
//         'label': AppTranslations.get('internal_kitchen', locale, 'Cuisine interne'),
//       },
//       {
//         'key': 'has_external_kitchen',
//         'label': AppTranslations.get('external_kitchen', locale, 'Cuisine externe'),
//       },
//       {
//         'key': 'has_a_parking',
//         'label': AppTranslations.get('parking', locale, 'Parking'),
//       },
//       {
//         'key': 'has_air_conditioning',
//         'label': AppTranslations.get('air_conditioning', locale, 'Climatisation'),
//       },
//       {
//         'key': 'has_security_guards',
//         'label': AppTranslations.get('security_guards', locale, 'Gardiennage'),
//       },
//       {
//         'key': 'has_balcony',
//         'label': AppTranslations.get('balcony', locale, 'Balcon'),
//       },
//     ];

//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppTranslations.get('equipment', locale, 'Équipements'),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: equipmentFilters.map((equipment) {
//               final String key = equipment['key']!;
//               final String label = equipment['label']!;
//               final String currentValue = localFilters[key]?.toString() ?? '';

//               return _buildEquipmentChip(
//                 context,
//                 key,
//                 label,
//                 currentValue,
//                 (value) {
//                   setState(() {
//                     localFilters[key] = value;
//                   });
//                 },
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusFilterChip(BuildContext context, String status, String label, bool selected, Function(bool) onSelected) {
//     final Color statusColor = _getStatusColor(context, status);
    
//     return FilterChip(
//       label: Text(
//         label,
//         style: TextStyle(
//           color: selected ? Colors.white : statusColor,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       selected: selected,
//       onSelected: onSelected,
//       backgroundColor: Colors.transparent,
//       selectedColor: statusColor,
//       checkmarkColor: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//         side: BorderSide(
//           color: statusColor,
//           width: 1.5,
//         ),
//       ),
//     );
//   }

//   Widget _buildOperationChip(BuildContext context, String operation, String label, bool selected, Function(bool) onSelected) {
//     return FilterChip(
//       label: Text(
//         label,
//         style: TextStyle(
//           color: selected ? Colors.white : Theme.of(context).colorScheme.secondary,
//         ),
//       ),
//       selected: selected,
//       onSelected: onSelected,
//       selectedColor: Theme.of(context).colorScheme.secondary,
//       checkmarkColor: Colors.white,
//     );
//   }

//   Widget _buildEquipmentChip(BuildContext context, String key, String label, String currentValue, Function(String) onSelected) {
//     final bool isSelected = currentValue == 'true';
//     final bool isExcluded = currentValue == 'false';

//     return ChoiceChip(
//       label: Text(label),
//       selected: isSelected,
//       onSelected: (selected) {
//         if (selected) {
//           onSelected('true');
//         } else if (isSelected) {
//           onSelected('false');
//         } else {
//           onSelected('');
//         }
//       },
//       selectedColor: Colors.green,
//       backgroundColor: isExcluded ? Colors.red.withOpacity(0.1) : null,
//       labelStyle: TextStyle(
//         color: isExcluded ? Colors.red : null,
//       ),
//     );
//   }

//   // Les méthodes _buildPropertyCard, _buildInfoPill, _buildBottomLoader restent identiques à votre code précédent
//   // [Inclure ici les méthodes buildPropertyCard, buildInfoPill, buildBottomLoader]

//   // Carte d'une Propriété avec badge de statut
//   Widget _buildPropertyCard(BuildContext context, Property property) {
//     final Color accentColor = Theme.of(context).colorScheme.secondary;
//     final Color primaryColor = Theme.of(context).colorScheme.primary;
//     final locale = Provider.of<SettingsProvider>(context).locale;

//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).pushNamed(
//           '/property-detail',
//           arguments: {'id': property.id},
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image principale avec badges de certification et statut
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//                   child: Image.network(
//                     property.mainImage.startsWith('http') ? property.mainImage : 'https://via.placeholder.com/600x400.png?text=Image+Indisponible', 
//                     height: 200,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Container(
//                       height: 200,
//                       color: Colors.grey.shade300,
//                       alignment: Alignment.center,
//                       child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
//                     ),
//                   ),
//                 ),
                
//                 // Badge de certification (en haut à droite)
//                 if (property.certified)
//                   Positioned(
//                     top: 10,
//                     right: 10,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.verified, color: Colors.white, size: 14),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Certifié',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
                
//                 // Badge de statut (en haut à gauche)
//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(context, property.status).withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           _getStatusIcon(property.status),
//                           color: Colors.white,
//                           size: 14,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           _getStatusTranslation(locale, property.status),
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
            
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Catégorie et Ville
//                   Text(
//                     '${property.category.name.toUpperCase()} - ${property.town.name}',
//                     style: TextStyle(
//                       color: accentColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
                  
//                   // Titre
//                   Text(
//                     property.title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).textTheme.titleLarge?.color,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // Caractéristiques (Pilules d'information)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildInfoPill(context, ' ${property.area} m²', Icons.square_foot),
//                       _buildInfoPill(context, ' ${property.roomsNb} Pcs', Icons.bed),
//                       _buildInfoPill(context, ' ${property.bathroomsNb} Bains', Icons.bathtub),
//                     ],
//                   ),
//                   const SizedBox(height: 10),

//                   // Prix et indicateur de statut
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/Mois',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w900,
//                             color: primaryColor,
//                           ),
//                         ),
//                       ),
//                       // Indicateur visuel supplémentaire du statut
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: _getStatusColor(context, property.status).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: _getStatusColor(context, property.status).withOpacity(0.3),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               _getStatusIcon(property.status),
//                               size: 12,
//                               color: _getStatusColor(context, property.status),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               _getStatusTranslation(locale, property.status),
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: _getStatusColor(context, property.status),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget utilitaire pour les pilules d'information
//   Widget _buildInfoPill(BuildContext context, String text, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: Theme.of(context).colorScheme.secondary),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12, 
//               color: Theme.of(context).colorScheme.secondary,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget pour l'indicateur de chargement en bas
//   Widget _buildBottomLoader() {
//     if (_isPaginating) {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//     if (!_hasMoreData && _properties.isNotEmpty) {
//       final locale = Provider.of<SettingsProvider>(context).locale;
//       return Padding(
//         padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
//         child: Text(
//           AppTranslations.get('end_of_list', locale, 'Fin de la liste des propriétés.'),
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;

//     return RefreshIndicator(
//       onRefresh: () => _loadProperties(isInitialLoad: true),
//       child: Column(
//         children: [
//           // Barre de Recherche et Filtres
//           _buildSearchAndFilter(context, locale), 

//           // Contenu principal (Liste des Propriétés)
//           Expanded(
//             child: _isLoading && _properties.isEmpty
//                 ? const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(),
//                         SizedBox(height: 16),
//                         Text('Chargement des propriétés...'),
//                       ],
//                     ),
//                   ) 
//                 : _errorMessage != null
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.error_outline, 
//                               size: 50, 
//                               color: Theme.of(context).colorScheme.error
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               AppTranslations.get('error', locale, 'Erreur'),
//                               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                                 color: Theme.of(context).colorScheme.error
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                               child: Text(
//                                 _errorMessage!,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 16, 
//                                   color: Theme.of(context).hintColor
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             ElevatedButton.icon(
//                               onPressed: () => _loadProperties(isInitialLoad: true),
//                               icon: const Icon(Icons.refresh),
//                               label: Text(AppTranslations.get('retry', locale, 'Réessayer')),
//                             ),
//                           ],
//                         ),
//                       )
//                     : _properties.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.search_off,
//                                   size: 60,
//                                   color: Theme.of(context).hintColor,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   _currentSearchQuery.isNotEmpty
//                                     ? AppTranslations.get('no_search_results', locale, 'Aucun résultat trouvé pour votre recherche.')
//                                     : AppTranslations.get('no_properties', locale, 'Aucune propriété trouvée pour l\'instant.'),
//                                   style: TextStyle(
//                                     fontSize: 16, 
//                                     color: Theme.of(context).hintColor
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             controller: _scrollController,
//                             itemCount: _properties.length + 1,
//                             itemBuilder: (context, index) {
//                               if (index == _properties.length) {
//                                 return _buildBottomLoader();
//                               }
//                               final property = _properties[index];
//                               return _buildPropertyCard(context, property);
//                             },
//                           ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/property_service.dart';
import '../services/town_service.dart';
import '../services/category_service.dart';
import '../models/property_model.dart';
import '../models/town.dart';
import '../models/category.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_themes.dart';
import '../constants/app_translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PropertyService _propertyService = PropertyService();
  final TownService _townService = TownService();
  final CategoryService _categoryService = CategoryService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Property> _properties = [];
  bool _isLoading = true;
  bool _isPaginating = false;
  bool _hasMoreData = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _limit = 10;
  String _currentSearchQuery = '';

  final Map<String, dynamic> _filters = {
    'search': '',
    'title': '',
    'address': '',
    'monthly_price': '',
    'monthly_price_bis': '',
    'monthly_price_operation': '',
    'area': '',
    'area_bis': '',
    'area_operation': '',
    'rooms_nb': '',
    'rooms_nb_bis': '',
    'rooms_nb_operation': '',
    'bathrooms_nb': '',
    'bathrooms_nb_bis': '',
    'bathrooms_nb_operation': '',
    'living_rooms_nb': '',
    'living_rooms_nb_bis': '',
    'living_rooms_nb_operation': '',
    'compartment_number': '',
    'compartment_number_bis': '',
    'compartment_number_operation': '',
    'status': '',
    'water_supply': '',
    'electrical_connection': '',
    'town_id': '',
    'category_property_id': '',
    'certified': '',
    'has_internal_kitchen': '',
    'has_external_kitchen': '',
    'has_a_parking': '',
    'has_air_conditioning': '',
    'has_security_guards': '',
    'has_balcony': '',
    'order': 'asc',
  };

  final TextEditingController _townSearchController = TextEditingController();
  List<Town> _filteredTowns = [];
  Town? _selectedTown;
  bool _isSearchingTowns = false;
  bool _showTownDropdown = false;

  final TextEditingController _categorySearchController = TextEditingController();
  List<Category> _filteredCategories = [];
  Category? _selectedCategory;
  bool _isSearchingCategories = false;
  bool _showCategoryDropdown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperties(isInitialLoad: true);
    });
    _scrollController.addListener(_scrollListener);
    _townSearchController.addListener(_onTownSearchChanged);
    _categorySearchController.addListener(_onCategorySearchChanged);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        !_isPaginating &&
        _hasMoreData) {
      _loadProperties(isPaginating: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    _townSearchController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  // ---------- MÉTHODES MÉTIER (INCHANGÉES) ----------
  Future<void> _loadAllTowns() async {
    try {
      final towns = await _townService.getAllTowns();
      setState(() => _filteredTowns = towns);
    } catch (e) {
      debugPrint('Erreur chargement villes: $e');
    }
  }

  void _onTownSearchChanged() async {
    final query = _townSearchController.text.trim();
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

  Future<void> _loadAllCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() => _filteredCategories = categories);
    } catch (e) {
      debugPrint('Erreur chargement catégories: $e');
    }
  }

  void _onCategorySearchChanged() async {
    final query = _categorySearchController.text.trim();
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

  Future<void> _loadProperties(
      {bool isInitialLoad = false,
      bool isPaginating = false,
      String? newQuery,
      Map<String, dynamic>? newFilters}) async {
    if (!mounted) return;

    final bool isNewSearch = newQuery != null;
    final bool isNewFilter = newFilters != null;
    final bool shouldReset = isInitialLoad || isNewSearch || isNewFilter || !isPaginating;

    final int nextPage = shouldReset ? 1 : _currentPage + 1;
    final String effectiveQuery = newQuery ?? _currentSearchQuery;

    if (isNewFilter) _filters.addAll(newFilters!);
    _filters['search'] = effectiveQuery;

    setState(() {
      if (shouldReset) {
        _properties = [];
        _currentPage = 1;
        _isLoading = true;
        _hasMoreData = true;
      } else {
        _isPaginating = true;
        _currentPage = nextPage;
      }
      _currentSearchQuery = effectiveQuery;
      _errorMessage = null;
    });

    try {
      final response = await _propertyService.getPropertiesWithFilters({
        'page': nextPage,
        'limit': _limit,
        ..._filters,
      });
      if (mounted) {
        setState(() {
          _properties.addAll(response.records);
          _hasMoreData = response.currentPage < response.totalPages;
          _isLoading = false;
          _isPaginating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isPaginating = false;
          if (isPaginating) _currentPage--;
        });
      }
    }
  }

  String _getStatusTranslation(Locale locale, String status) {
    final translations = {
      'free': AppTranslations.get('status_free', locale, 'Libre'),
      'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
      'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
    };
    return translations[status] ?? status;
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'free':
        return AppThemes.getSuccessColor(context);
      case 'busy':
        return AppThemes.getErrorColor(context);
      case 'prev_advise':
        return AppThemes.getWarningColor(context);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'free':
        return Icons.check_circle;
      case 'busy':
        return Icons.do_not_disturb;
      case 'prev_advise':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }

  // ---------- UI ----------

  Widget _buildSearchBar(BuildContext context, Locale locale) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (q) => _loadProperties(newQuery: q),
              decoration: InputDecoration(
                hintText:
                    AppTranslations.get('search_placeholder', locale, 'Rechercher…'),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _currentSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadProperties(newQuery: '');
                        })
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: accent,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _showFilterBottomSheet(context, locale),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.tune, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  //  BOTTOM SHEET COMPLET (ville, catégorie, prix, surface, chambres, etc.)
  // =========================================================================
  void _showFilterBottomSheet(BuildContext context, Locale locale) {
    final Map<String, dynamic> localFilters = Map.from(_filters);

    final priceMinCtrl = TextEditingController(text: localFilters['monthly_price']?.toString() ?? '');
    final priceMaxCtrl = TextEditingController(text: localFilters['monthly_price_bis']?.toString() ?? '');
    final areaMinCtrl = TextEditingController(text: localFilters['area']?.toString() ?? '');
    final areaMaxCtrl = TextEditingController(text: localFilters['area_bis']?.toString() ?? '');
    final roomsMinCtrl = TextEditingController(text: localFilters['rooms_nb']?.toString() ?? '');
    final roomsMaxCtrl = TextEditingController(text: localFilters['rooms_nb_bis']?.toString() ?? '');
    final bathMinCtrl = TextEditingController(text: localFilters['bathrooms_nb']?.toString() ?? '');
    final bathMaxCtrl = TextEditingController(text: localFilters['bathrooms_nb_bis']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateBS) {
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
                        onPressed: () {
                          localFilters.clear();
                          _selectedTown = null;
                          _selectedCategory = null;
                          _townSearchController.clear();
                          _categorySearchController.clear();
                          priceMinCtrl.clear();
                          priceMaxCtrl.clear();
                          areaMinCtrl.clear();
                          areaMaxCtrl.clear();
                          roomsMinCtrl.clear();
                          roomsMaxCtrl.clear();
                          bathMinCtrl.clear();
                          bathMaxCtrl.clear();
                          setStateBS(() {});
                        },
                        child: Text(AppTranslations.get('reset', locale, 'Réinitialiser')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTownFilterSection(locale, setStateBS),
                          _buildCategoryFilterSection(locale, setStateBS),
                          _buildStatusFilterChips(locale, localFilters, setStateBS),
                          _buildRangeFilterSection(
                            locale: locale,
                            title: AppTranslations.get('monthly_price', locale, 'Prix mensuel'),
                            minKey: 'monthly_price',
                            maxKey: 'monthly_price_bis',
                            operationKey: 'monthly_price_operation',
                            localFilters: localFilters,
                            minCtrl: priceMinCtrl,
                            maxCtrl: priceMaxCtrl,
                            setStateBS: setStateBS,
                            isCurrency: true,
                          ),
                          _buildRangeFilterSection(
                            locale: locale,
                            title: AppTranslations.get('area', locale, 'Surface'),
                            minKey: 'area',
                            maxKey: 'area_bis',
                            operationKey: 'area_operation',
                            localFilters: localFilters,
                            minCtrl: areaMinCtrl,
                            maxCtrl: areaMaxCtrl,
                            setStateBS: setStateBS,
                            unit: 'm²',
                          ),
                          _buildRangeFilterSection(
                            locale: locale,
                            title: AppTranslations.get('rooms', locale, 'Chambres'),
                            minKey: 'rooms_nb',
                            maxKey: 'rooms_nb_bis',
                            operationKey: 'rooms_nb_operation',
                            localFilters: localFilters,
                            minCtrl: roomsMinCtrl,
                            maxCtrl: roomsMaxCtrl,
                            setStateBS: setStateBS,
                          ),
                          _buildRangeFilterSection(
                            locale: locale,
                            title: AppTranslations.get('bathrooms', locale, 'Salles de bain'),
                            minKey: 'bathrooms_nb',
                            maxKey: 'bathrooms_nb_bis',
                            operationKey: 'bathrooms_nb_operation',
                            localFilters: localFilters,
                            minCtrl: bathMinCtrl,
                            maxCtrl: bathMaxCtrl,
                            setStateBS: setStateBS,
                          ),
                          _buildEquipmentChips(locale, localFilters, setStateBS),
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
                          onPressed: () {
                            _loadProperties(newFilters: localFilters, isInitialLoad: true);
                            Navigator.of(context).pop();
                          },
                          child: Text(AppTranslations.get('apply_filters', locale, 'Appliquer')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // -----------------------------------------------------------------
  //  WIDGETS DE FILTRE (ré-insérés tels quels depuis ton ancien code)
  // -----------------------------------------------------------------
  Widget _buildTownFilterSection(Locale locale, Function setStateBS) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
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
            ),
            onTap: () {
              if (_townSearchController.text.isEmpty) _loadAllTowns();
              setStateBS(() => _showTownDropdown = true);
            },
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

  Widget _buildCategoryFilterSection(Locale locale, Function setStateBS) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
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
            ),
            onTap: () {
              if (_categorySearchController.text.isEmpty) _loadAllCategories();
              setStateBS(() => _showCategoryDropdown = true);
            },
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

  Widget _buildStatusFilterChips(Locale locale, Map<String, dynamic> localFilters, Function setStateBS) {
    final statusList = ['', 'free', 'prev_advise', 'busy'];
    final labels = [
      AppTranslations.get('all_status', locale, 'Tous'),
      _getStatusTranslation(locale, 'free'),
      _getStatusTranslation(locale, 'prev_advise'),
      _getStatusTranslation(locale, 'busy'),
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(statusList.length, (index) {
              final status = statusList[index];
              final selected = (localFilters['status'] ?? '') == status;
              return FilterChip(
                label: Text(
                  labels[index],
                  style: TextStyle(
                    color: selected ? Colors.white : _getStatusColor(context, status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: selected,
                onSelected: (_) {
                  setStateBS(() => localFilters['status'] = status);
                },
                selectedColor: _getStatusColor(context, status),
                backgroundColor: Colors.transparent,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _getStatusColor(context, status),
                    width: 1.5,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeFilterSection({
    required Locale locale,
    required String title,
    required String minKey,
    required String maxKey,
    required String operationKey,
    required Map<String, dynamic> localFilters,
    required TextEditingController minCtrl,
    required TextEditingController maxCtrl,
    required Function setStateBS,
    bool isCurrency = false,
    String unit = '',
  }) {
    final currentOp = localFilters[operationKey] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _operationChip('',
                  AppTranslations.get('range', locale, 'Intervalle'), currentOp == '', () {
                setStateBS(() => localFilters[operationKey] = '');
              }),
              _operationChip('sup',
                  AppTranslations.get('greater_than', locale, 'Supérieur à'), currentOp == 'sup', () {
                setStateBS(() {
                  localFilters[operationKey] = 'sup';
                  localFilters[maxKey] = '';
                  maxCtrl.clear();
                });
              }),
              _operationChip('inf',
                  AppTranslations.get('less_than', locale, 'Inférieur à'), currentOp == 'inf', () {
                setStateBS(() {
                  localFilters[operationKey] = 'inf';
                  localFilters[maxKey] = '';
                  maxCtrl.clear();
                });
              }),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: currentOp == 'sup'
                        ? AppTranslations.get('minimum', locale, 'Minimum')
                        : AppTranslations.get('from', locale, 'De'),
                    suffixText: isCurrency ? 'XOF' : unit,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) =>
                      localFilters[minKey] = val.isEmpty ? '' : int.tryParse(val) ?? 0,
                ),
              ),
              if (currentOp == '') ...[
                const SizedBox(width: 10),
                Text(AppTranslations.get('to', locale, 'à'),
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: maxCtrl,
                    keyboardType: TextInputType.number,
                    enabled: currentOp == '',
                    decoration: InputDecoration(
                      labelText: AppTranslations.get('to', locale, 'À'),
                      suffixText: isCurrency ? 'XOF' : unit,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) =>
                        localFilters[maxKey] = val.isEmpty ? '' : int.tryParse(val) ?? 0,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _operationChip(String value, String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.secondary,
      backgroundColor: Colors.transparent,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildEquipmentChips(Locale locale, Map<String, dynamic> localFilters, Function setStateBS) {
    final equipment = [
      {'key': 'has_internal_kitchen', 'label': AppTranslations.get('internal_kitchen', locale, 'Cuisine interne')},
      {'key': 'has_external_kitchen', 'label': AppTranslations.get('external_kitchen', locale, 'Cuisine externe')},
      {'key': 'has_a_parking', 'label': AppTranslations.get('parking', locale, 'Parking')},
      {'key': 'has_air_conditioning', 'label': AppTranslations.get('air_conditioning', locale, 'Climatisation')},
      {'key': 'has_security_guards', 'label': AppTranslations.get('security_guards', locale, 'Gardiennage')},
      {'key': 'has_balcony', 'label': AppTranslations.get('balcony', locale, 'Balcon')},
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('equipment', locale, 'Équipements'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: equipment.map((e) {
              final key = e['key']!;
              final label = e['label']!;
              final current = localFilters[key]?.toString() ?? '';
              final isSelected = current == 'true';
              final isExcluded = current == 'false';

              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    localFilters[key] = 'true';
                  } else if (isSelected) {
                    localFilters[key] = 'false';
                  } else {
                    localFilters[key] = '';
                  }
                  setStateBS(() {});
                },
                selectedColor: Colors.green,
                backgroundColor: isExcluded ? Colors.red.withOpacity(0.1) : null,
                labelStyle: TextStyle(color: isExcluded ? Colors.red : null),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Property property) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/property-detail', arguments: {'id': property.id}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    property.mainImage.startsWith('http')
                        ? property.mainImage
                        : 'https://via.placeholder.com/600x400.png?text=Image+Indisponible ',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child:
                          const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                if (property.certified)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppThemes.getCertifiedColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Certifié',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context, property.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(property.status),
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(_getStatusTranslation(locale, property.status),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${property.category.name.toUpperCase()}  •  ${property.town.name}',
                          style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _pill(Icons.square_foot, '${property.area} m²'),
                      const SizedBox(width: 8),
                      _pill(Icons.bed, '${property.roomsNb} pcs'),
                      const SizedBox(width: 8),
                      _pill(Icons.bathtub, '${property.bathroomsNb} bains'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF / mois',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: primary),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: accent.withOpacity(.6)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: accent)),
        ],
      ),
    );
  }

  Widget _buildBottomLoader() {
    if (_isPaginating) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasMoreData && _properties.isNotEmpty) {
      final locale = Provider.of<SettingsProvider>(context).locale;
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        child: Text(
          AppTranslations.get('end_of_list', locale, 'Fin de la liste'),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadProperties(isInitialLoad: true),
        child: Column(
          children: [
            _buildSearchBar(context, locale),
            Expanded(
              child: _isLoading && _properties.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : _properties.isEmpty
                          ? Center(
                              child: Text(AppTranslations.get(
                                  'no_properties', locale, 'Aucune propriété')))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: _properties.length + 1,
                              itemBuilder: (_, index) {
                                if (index == _properties.length) {
                                  return _buildBottomLoader();
                                }
                                return _buildPropertyCard(
                                    context, _properties[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}