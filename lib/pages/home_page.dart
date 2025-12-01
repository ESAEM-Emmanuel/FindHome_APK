// // lib/pages/home_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/property_service.dart';
// import '../services/town_service.dart';
// import '../services/category_service.dart';
// import '../models/property_model.dart';
// import '../models/town.dart';
// import '../models/category.dart';
// import '../providers/settings_provider.dart';
// import '../providers/auth_provider.dart';
// import '../constants/app_themes.dart';
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
//   String? _togglingFavoriteId;

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

//   // Variables locales pour le bottom sheet
//   List<Town> _filteredTowns = [];
//   Town? _selectedTown;
//   bool _isSearchingTowns = false;
//   bool _showTownDropdown = false;

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
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent * 0.8 &&
//         !_isLoading &&
//         !_isPaginating &&
//         _hasMoreData) {
//       _loadProperties(isPaginating: true);
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ---------- MÉTHODES MÉTIER AMÉLIORÉES ----------
//   Future<void> _loadAllTowns() async {
//     try {
//       final towns = await _townService.getAllTowns();
//       _filteredTowns = towns;
//     } catch (e) {
//       debugPrint('Erreur chargement villes: $e');
//     }
//   }

//   void _onTownSearchChanged(String query, Function setStateBS) async {
//     if (query.isEmpty) {
//       setStateBS(() {
//         _showTownDropdown = false;
//         _filteredTowns = [];
//       });
//       return;
//     }
//     setStateBS(() {
//       _isSearchingTowns = true;
//       _showTownDropdown = true;
//     });
//     try {
//       final response = await _townService.searchTowns(query);
//       setStateBS(() {
//         _filteredTowns = response.records;
//         _isSearchingTowns = false;
//       });
//     } catch (e) {
//       setStateBS(() => _isSearchingTowns = false);
//     }
//   }

//   void _selectTown(Town town, Function setStateBS, Map<String, dynamic> localFilters, TextEditingController townController) {
//     setStateBS(() {
//       _selectedTown = town;
//       _showTownDropdown = false;
//       localFilters['town_id'] = town.id;
//       townController.text = town.name;
//     });
//   }

//   void _clearTownSelection(Function setStateBS, Map<String, dynamic> localFilters, TextEditingController townController) {
//     setStateBS(() {
//       _selectedTown = null;
//       _showTownDropdown = false;
//       localFilters['town_id'] = '';
//       townController.clear();
//     });
//   }

//   Future<void> _loadAllCategories() async {
//     try {
//       final categories = await _categoryService.getAllCategories();
//       _filteredCategories = categories;
//     } catch (e) {
//       debugPrint('Erreur chargement catégories: $e');
//     }
//   }

//   void _onCategorySearchChanged(String query, Function setStateBS) async {
//     if (query.isEmpty) {
//       setStateBS(() {
//         _showCategoryDropdown = false;
//         _filteredCategories = [];
//       });
//       return;
//     }
//     setStateBS(() {
//       _isSearchingCategories = true;
//       _showCategoryDropdown = true;
//     });
//     try {
//       final response = await _categoryService.searchCategories(query);
//       setStateBS(() {
//         _filteredCategories = response.records;
//         _isSearchingCategories = false;
//       });
//     } catch (e) {
//       setStateBS(() => _isSearchingCategories = false);
//     }
//   }

//   void _selectCategory(Category category, Function setStateBS, Map<String, dynamic> localFilters, TextEditingController categoryController) {
//     setStateBS(() {
//       _selectedCategory = category;
//       _showCategoryDropdown = false;
//       localFilters['category_property_id'] = category.id;
//       categoryController.text = category.name;
//     });
//   }

//   void _clearCategorySelection(Function setStateBS, Map<String, dynamic> localFilters, TextEditingController categoryController) {
//     setStateBS(() {
//       _selectedCategory = null;
//       _showCategoryDropdown = false;
//       localFilters['category_property_id'] = '';
//       categoryController.clear();
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
//       _filters.clear();
//       _filters.addAll(newFilters!);
//     }
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
//       final Map<String, dynamic> queryParams = {
//         'page': nextPage,
//         'limit': _limit,
//       };

//       // MODIFICATION ICI : Filtrer les paramètres pour n'inclure que les équipements à true
//       _filters.forEach((key, value) {
//         if (value != null && value.toString().isNotEmpty) {
//           // Pour les champs d'équipements, on n'envoie que si la valeur est 'true'
//           if (key.startsWith('has_')) {
//             if (value == 'true') {
//               queryParams[key] = value;
//             }
//             // On n'ajoute pas le paramètre si la valeur est 'false' ou vide
//           } else {
//             // Pour tous les autres champs, on garde le comportement actuel
//             queryParams[key] = value;
//           }
//         }
//       });

//       debugPrint('Requête API avec filtres: $queryParams');

//       final response = await _propertyService.getPropertiesWithFilters(queryParams);
      
//       if (mounted) {
//         setState(() {
//           _properties.addAll(response.records);
//           _hasMoreData = response.currentPage < response.totalPages;
//           _isLoading = false;
//           _isPaginating = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = "Erreur de chargement: ${e.toString()}";
//           _isLoading = false;
//           _isPaginating = false;
//           if (isPaginating) _currentPage--;
//         });
//       }
//     }
//   }

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
//         return AppThemes.getSuccessColor(context);
//       case 'busy':
//         return AppThemes.getErrorColor(context);
//       case 'prev_advise':
//         return AppThemes.getWarningColor(context);
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

//   // Méthode pour vérifier les permissions de modification
//   bool _canEditProperty(Property property) {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final currentUser = authProvider.currentUser;
    
//     if (currentUser == null) {
//       return false;
//     }

//     final isOwner = currentUser.id == property.ownerId;
//     final isAdmin = currentUser.role == 'admin';
//     final isStaff = currentUser.isStaff == true;

//     return isOwner || isAdmin || isStaff;
//   }

//   // ---------- UI ----------

//   Widget _buildSearchBar(BuildContext context, Locale locale) {
//     final accent = Theme.of(context).colorScheme.secondary;
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               onSubmitted: (q) => _loadProperties(newQuery: q),
//               decoration: InputDecoration(
//                 hintText:
//                     AppTranslations.get('search_placeholder', locale, 'Rechercher…'),
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 suffixIcon: _currentSearchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           _loadProperties(newQuery: '');
//                         })
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Theme.of(context).cardColor,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Material(
//             color: accent,
//             borderRadius: BorderRadius.circular(30),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(30),
//               onTap: () => _showFilterBottomSheet(context, locale),
//               child: const Padding(
//                 padding: EdgeInsets.all(12),
//                 child: Icon(Icons.tune, color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFilterBottomSheet(BuildContext context, Locale locale) {
//     final Map<String, dynamic> localFilters = Map.from(_filters);

//     final townSearchController = TextEditingController();
//     final categorySearchController = TextEditingController();
//     final priceMinCtrl = TextEditingController(text: localFilters['monthly_price']?.toString() ?? '');
//     final priceMaxCtrl = TextEditingController(text: localFilters['monthly_price_bis']?.toString() ?? '');
//     final areaMinCtrl = TextEditingController(text: localFilters['area']?.toString() ?? '');
//     final areaMaxCtrl = TextEditingController(text: localFilters['area_bis']?.toString() ?? '');
//     final roomsMinCtrl = TextEditingController(text: localFilters['rooms_nb']?.toString() ?? '');
//     final roomsMaxCtrl = TextEditingController(text: localFilters['rooms_nb_bis']?.toString() ?? '');
//     final bathMinCtrl = TextEditingController(text: localFilters['bathrooms_nb']?.toString() ?? '');
//     final bathMaxCtrl = TextEditingController(text: localFilters['bathrooms_nb_bis']?.toString() ?? '');

//     if (_selectedTown != null) {
//       townSearchController.text = _selectedTown!.name;
//     }
//     if (_selectedCategory != null) {
//       categorySearchController.text = _selectedCategory!.name;
//     }

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return StatefulBuilder(
//           builder: (context, setStateBS) {
//             return Padding(
//               padding: const EdgeInsets.all(20).copyWith(
//                 bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
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
//                           final Map<String, dynamic> resetFilters = {
//                             'search': '',
//                             'title': '',
//                             'address': '',
//                             'monthly_price': '',
//                             'monthly_price_bis': '',
//                             'monthly_price_operation': '',
//                             'area': '',
//                             'area_bis': '',
//                             'area_operation': '',
//                             'rooms_nb': '',
//                             'rooms_nb_bis': '',
//                             'rooms_nb_operation': '',
//                             'bathrooms_nb': '',
//                             'bathrooms_nb_bis': '',
//                             'bathrooms_nb_operation': '',
//                             'living_rooms_nb': '',
//                             'living_rooms_nb_bis': '',
//                             'living_rooms_nb_operation': '',
//                             'compartment_number': '',
//                             'compartment_number_bis': '',
//                             'compartment_number_operation': '',
//                             'status': '',
//                             'water_supply': '',
//                             'electrical_connection': '',
//                             'town_id': '',
//                             'category_property_id': '',
//                             'certified': '',
//                             'has_internal_kitchen': '',
//                             'has_external_kitchen': '',
//                             'has_a_parking': '',
//                             'has_air_conditioning': '',
//                             'has_security_guards': '',
//                             'has_balcony': '',
//                             'order': 'asc',
//                           };

//                           _selectedTown = null;
//                           _selectedCategory = null;
                          
//                           townSearchController.clear();
//                           categorySearchController.clear();
//                           priceMinCtrl.clear();
//                           priceMaxCtrl.clear();
//                           areaMinCtrl.clear();
//                           areaMaxCtrl.clear();
//                           roomsMinCtrl.clear();
//                           roomsMaxCtrl.clear();
//                           bathMinCtrl.clear();
//                           bathMaxCtrl.clear();
                          
//                           _showTownDropdown = false;
//                           _showCategoryDropdown = false;
//                           _filteredTowns = [];
//                           _filteredCategories = [];
                          
//                           localFilters.clear();
//                           localFilters.addAll(resetFilters);
                          
//                           _loadProperties(newFilters: resetFilters, isInitialLoad: true);
                          
//                           Navigator.of(context).pop();
                          
//                           setStateBS(() {});
//                         },
//                         child: Text(AppTranslations.get('reset', locale, 'Réinitialiser')),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           _buildTownFilterSection(
//                             locale, 
//                             setStateBS, 
//                             townSearchController,
//                             localFilters,
//                             (query) => _onTownSearchChanged(query, setStateBS),
//                             () => _clearTownSelection(setStateBS, localFilters, townSearchController),
//                             (town) => _selectTown(town, setStateBS, localFilters, townSearchController)
//                           ),
                          
//                           _buildCategoryFilterSection(
//                             locale, 
//                             setStateBS, 
//                             categorySearchController,
//                             localFilters,
//                             (query) => _onCategorySearchChanged(query, setStateBS),
//                             () => _clearCategorySelection(setStateBS, localFilters, categorySearchController),
//                             (category) => _selectCategory(category, setStateBS, localFilters, categorySearchController)
//                           ),
                          
//                           _buildStatusFilterChips(locale, localFilters, setStateBS),
//                           _buildRangeFilterSection(
//                             locale: locale,
//                             title: AppTranslations.get('monthly_price', locale, 'Prix mensuel'),
//                             minKey: 'monthly_price',
//                             maxKey: 'monthly_price_bis',
//                             operationKey: 'monthly_price_operation',
//                             localFilters: localFilters,
//                             minCtrl: priceMinCtrl,
//                             maxCtrl: priceMaxCtrl,
//                             setStateBS: setStateBS,
//                             isCurrency: true,
//                           ),
//                           _buildRangeFilterSection(
//                             locale: locale,
//                             title: AppTranslations.get('area', locale, 'Surface'),
//                             minKey: 'area',
//                             maxKey: 'area_bis',
//                             operationKey: 'area_operation',
//                             localFilters: localFilters,
//                             minCtrl: areaMinCtrl,
//                             maxCtrl: areaMaxCtrl,
//                             setStateBS: setStateBS,
//                             unit: 'm²',
//                           ),
//                           _buildRangeFilterSection(
//                             locale: locale,
//                             title: AppTranslations.get('rooms', locale, 'Chambres'),
//                             minKey: 'rooms_nb',
//                             maxKey: 'rooms_nb_bis',
//                             operationKey: 'rooms_nb_operation',
//                             localFilters: localFilters,
//                             minCtrl: roomsMinCtrl,
//                             maxCtrl: roomsMaxCtrl,
//                             setStateBS: setStateBS,
//                           ),
//                           _buildRangeFilterSection(
//                             locale: locale,
//                             title: AppTranslations.get('bathrooms', locale, 'Salles de bain'),
//                             minKey: 'bathrooms_nb',
//                             maxKey: 'bathrooms_nb_bis',
//                             operationKey: 'bathrooms_nb_operation',
//                             localFilters: localFilters,
//                             minCtrl: bathMinCtrl,
//                             maxCtrl: bathMaxCtrl,
//                             setStateBS: setStateBS,
//                           ),
//                           _buildEquipmentChips(locale, localFilters, setStateBS),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () => Navigator.of(context).pop(),
//                           child: Text(AppTranslations.get('cancel', locale, 'Annuler')),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             _loadProperties(newFilters: localFilters, isInitialLoad: true);
//                             Navigator.of(context).pop();
//                           },
//                           child: Text(AppTranslations.get('apply_filters', locale, 'Appliquer')),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTownFilterSection(
//     Locale locale, 
//     Function setStateBS, 
//     TextEditingController controller,
//     Map<String, dynamic> localFilters,
//     Function(String) onSearchChanged,
//     VoidCallback onClearSelection,
//     Function(Town) onSelectTown,
//   ) {
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
//             AppTranslations.get('town', locale, 'Ville'),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),
//           TextFormField(
//             controller: controller,
//             decoration: InputDecoration(
//               hintText: AppTranslations.get('search_town', locale, 'Rechercher une ville...'),
//               prefixIcon: const Icon(Icons.location_city, color: Colors.grey),
//               suffixIcon: _selectedTown != null
//                   ? IconButton(
//                       icon: const Icon(Icons.clear, color: Colors.grey),
//                       onPressed: onClearSelection,
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
//               if (controller.text.isEmpty) _loadAllTowns();
//               setStateBS(() => _showTownDropdown = true);
//             },
//             onChanged: onSearchChanged,
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
//                     onTap: () => onSelectTown(town),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryFilterSection(
//     Locale locale, 
//     Function setStateBS, 
//     TextEditingController controller,
//     Map<String, dynamic> localFilters,
//     Function(String) onSearchChanged,
//     VoidCallback onClearSelection,
//     Function(Category) onSelectCategory,
//   ) {
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
//             AppTranslations.get('category', locale, 'Catégorie'),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.secondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 10),
//           TextFormField(
//             controller: controller,
//             decoration: InputDecoration(
//               hintText: AppTranslations.get('search_category', locale, 'Rechercher une catégorie...'),
//               prefixIcon: const Icon(Icons.category, color: Colors.grey),
//               suffixIcon: _selectedCategory != null
//                   ? IconButton(
//                       icon: const Icon(Icons.clear, color: Colors.grey),
//                       onPressed: onClearSelection,
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
//               if (controller.text.isEmpty) _loadAllCategories();
//               setStateBS(() => _showCategoryDropdown = true);
//             },
//             onChanged: onSearchChanged,
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
//                     onTap: () => onSelectCategory(category),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusFilterChips(Locale locale, Map<String, dynamic> localFilters, Function setStateBS) {
//     final statusList = ['', 'free', 'prev_advise', 'busy'];
//     final labels = [
//       AppTranslations.get('all_status', locale, 'Tous'),
//       _getStatusTranslation(locale, 'free'),
//       _getStatusTranslation(locale, 'prev_advise'),
//       _getStatusTranslation(locale, 'busy'),
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
//             AppTranslations.get('status', locale, 'Statut'),
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
//             children: List.generate(statusList.length, (index) {
//               final status = statusList[index];
//               final selected = (localFilters['status'] ?? '') == status;
//               return FilterChip(
//                 label: Text(
//                   labels[index],
//                   style: TextStyle(
//                     color: selected ? Colors.white : _getStatusColor(context, status),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 selected: selected,
//                 onSelected: (_) {
//                   setStateBS(() => localFilters['status'] = status);
//                 },
//                 selectedColor: _getStatusColor(context, status),
//                 backgroundColor: Colors.transparent,
//                 checkmarkColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   side: BorderSide(
//                     color: _getStatusColor(context, status),
//                     width: 1.5,
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRangeFilterSection({
//     required Locale locale,
//     required String title,
//     required String minKey,
//     required String maxKey,
//     required String operationKey,
//     required Map<String, dynamic> localFilters,
//     required TextEditingController minCtrl,
//     required TextEditingController maxCtrl,
//     required Function setStateBS,
//     bool isCurrency = false,
//     String unit = '',
//   }) {
//     final currentOp = localFilters[operationKey] ?? '';

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
//             children: [
//               _operationChip('',
//                   AppTranslations.get('range', locale, 'Intervalle'), currentOp == '', () {
//                 setStateBS(() => localFilters[operationKey] = '');
//               }),
//               _operationChip('sup',
//                   AppTranslations.get('greater_than', locale, 'Supérieur à'), currentOp == 'sup', () {
//                 setStateBS(() {
//                   localFilters[operationKey] = 'sup';
//                   localFilters[maxKey] = '';
//                   maxCtrl.clear();
//                 });
//               }),
//               _operationChip('inf',
//                   AppTranslations.get('less_than', locale, 'Inférieur à'), currentOp == 'inf', () {
//                 setStateBS(() {
//                   localFilters[operationKey] = 'inf';
//                   localFilters[maxKey] = '';
//                   maxCtrl.clear();
//                 });
//               }),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: minCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: currentOp == 'sup'
//                         ? AppTranslations.get('minimum', locale, 'Minimum')
//                         : AppTranslations.get('from', locale, 'De'),
//                     suffixText: isCurrency ? 'XOF' : unit,
//                     border: const OutlineInputBorder(),
//                   ),
//                   onChanged: (val) =>
//                       localFilters[minKey] = val.isEmpty ? '' : int.tryParse(val) ?? 0,
//                 ),
//               ),
//               if (currentOp == '') ...[
//                 const SizedBox(width: 10),
//                 Text(AppTranslations.get('to', locale, 'à'),
//                     style: TextStyle(color: Theme.of(context).hintColor)),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     controller: maxCtrl,
//                     keyboardType: TextInputType.number,
//                     enabled: currentOp == '',
//                     decoration: InputDecoration(
//                       labelText: AppTranslations.get('to', locale, 'À'),
//                       suffixText: isCurrency ? 'XOF' : unit,
//                       border: const OutlineInputBorder(),
//                     ),
//                     onChanged: (val) =>
//                         localFilters[maxKey] = val.isEmpty ? '' : int.tryParse(val) ?? 0,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _operationChip(String value, String label, bool selected, VoidCallback onTap) {
//     return FilterChip(
//       label: Text(label),
//       selected: selected,
//       onSelected: (_) => onTap(),
//       selectedColor: Theme.of(context).colorScheme.secondary,
//       backgroundColor: Colors.transparent,
//       checkmarkColor: Colors.white,
//     );
//   }

//   Widget _buildEquipmentChips(Locale locale, Map<String, dynamic> localFilters, Function setStateBS) {
//     final equipment = [
//       {'key': 'has_internal_kitchen', 'label': AppTranslations.get('internal_kitchen', locale, 'Cuisine interne')},
//       {'key': 'has_external_kitchen', 'label': AppTranslations.get('external_kitchen', locale, 'Cuisine externe')},
//       {'key': 'has_a_parking', 'label': AppTranslations.get('parking', locale, 'Parking')},
//       {'key': 'has_air_conditioning', 'label': AppTranslations.get('air_conditioning', locale, 'Climatisation')},
//       {'key': 'has_security_guards', 'label': AppTranslations.get('security_guards', locale, 'Gardiennage')},
//       {'key': 'has_balcony', 'label': AppTranslations.get('balcony', locale, 'Balcon')},
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
//             children: equipment.map((e) {
//               final key = e['key']!;
//               final label = e['label']!;
//               final current = localFilters[key]?.toString() ?? '';
//               final isSelected = current == 'true';
//               final isExcluded = current == 'false';

//               return ChoiceChip(
//                 label: Text(label),
//                 selected: isSelected,
//                 onSelected: (selected) {
//                   if (selected) {
//                     localFilters[key] = 'true';
//                   } else if (isSelected) {
//                     localFilters[key] = 'false';
//                   } else {
//                     localFilters[key] = '';
//                   }
//                   setStateBS(() {});
//                 },
//                 selectedColor: Colors.green,
//                 backgroundColor: isExcluded ? Colors.red.withOpacity(0.1) : null,
//                 labelStyle: TextStyle(color: isExcluded ? Colors.red : null),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPropertyCard(BuildContext context, Property property) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
//     final primary = Theme.of(context).colorScheme.primary;
//     final accent = Theme.of(context).colorScheme.secondary;

//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         // Vérification CORRIGÉE : seulement si active = true
//         final isFavorite = authProvider.isPropertyFavorite(property.id);
        
//         return GestureDetector(
//           onTap: () => Navigator.of(context)
//               .pushNamed('/property-detail', arguments: {'id': property.id}),
//           child: Container(
//             margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
//             clipBehavior: Clip.antiAlias,
//             decoration: BoxDecoration(
//               color: Theme.of(context).cardColor,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius:
//                           const BorderRadius.vertical(top: Radius.circular(20)),
//                       child: Image.network(
//                         property.mainImage.startsWith('http')
//                             ? property.mainImage
//                             : 'https://via.placeholder.com/600x400.png?text=Image+Indisponible ',
//                         height: 200,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => Container(
//                           height: 200,
//                           color: Colors.grey.shade300,
//                           alignment: Alignment.center,
//                           child:
//                               const Icon(Icons.image_not_supported, color: Colors.grey),
//                         ),
//                       ),
//                     ),
                    
//                     // === DISPOSITION AMÉLIORÉE DES BADGES ===
                    
//                     // Badge Statut (en haut à gauche)
//                     Positioned(
//                       top: 12,
//                       left: 12,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: _getStatusColor(context, property.status),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(_getStatusIcon(property.status), size: 14, color: Colors.white),
//                             const SizedBox(width: 4),
//                             Text(_getStatusTranslation(locale, property.status),
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w600)),
//                           ],
//                         ),
//                       ),
//                     ),
                    
//                     // === CONTENEUR DROITE POUR TOUS LES BADGES ===
//                     Positioned(
//                       top: 12,
//                       right: 12,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           // Badge Certifié (si applicable)
//                           if (property.certified) ...[
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: AppThemes.getCertifiedColor(context),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.verified, size: 14, color: Colors.white),
//                                   SizedBox(width: 4),
//                                   Text('Certifié',
//                                       style: TextStyle(color: Colors.white, fontSize: 11)),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 8), // Espace entre les badges
//                           ],
                          
//                           // Badge Propriétaire (si applicable)
//                           if (_canEditProperty(property)) ...[
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                               decoration: BoxDecoration(
//                                 // color: Colors.green.withOpacity(0.9),
//                                 color: AppThemes.getCertifiedColor(context),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.person, size: 14, color: Colors.white),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     'Propriétaire',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 8), // Espace entre les badges
//                           ],
                          
//                           // ❤️ BOUTON FAVORI - TOUJOURS EN DERNIER
//                           GestureDetector(
//                             onTap: () async {
//                               if (!authProvider.isLoggedIn || _togglingFavoriteId == property.id) {
//                                 if (!authProvider.isLoggedIn) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(AppTranslations.get('login_required', locale, 'Veuillez vous connecter pour ajouter aux favoris.')),
//                                       backgroundColor: AppThemes.getWarningColor(context),
//                                     ),
//                                   );
//                                 }
//                                 return;
//                               }
                              
//                               setState(() => _togglingFavoriteId = property.id);
                              
//                               try {
//                                 await authProvider.toggleFavorite(property.id);
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text('${AppTranslations.get('favorite_error', locale, 'Erreur lors de la modification des favoris')}: $e'),
//                                     backgroundColor: AppThemes.getErrorColor(context),
//                                   ),
//                                 );
//                               } finally {
//                                 if (mounted) {
//                                   setState(() => _togglingFavoriteId = null);
//                                 }
//                               }
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.95),
//                                 borderRadius: BorderRadius.circular(20),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.15),
//                                     blurRadius: 6,
//                                     offset: const Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: _togglingFavoriteId == property.id
//                                   ? SizedBox(
//                                       width: 18,
//                                       height: 18,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor: AlwaysStoppedAnimation<Color>(
//                                           isFavorite ? Colors.red : Colors.grey,
//                                         ),
//                                       ),
//                                     )
//                                   : Icon(
//                                       isFavorite ? Icons.favorite : Icons.favorite_border,
//                                       color: isFavorite ? Colors.red : Colors.grey,
//                                       size: 18,
//                                     ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               '${property.category.name.toUpperCase()}  •  ${property.town.name}',
//                               style: TextStyle(
//                                   color: accent,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Text(property.title,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.w700)),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           _pill(Icons.square_foot, '${property.area} m²'),
//                           const SizedBox(width: 8),
//                           _pill(Icons.bed, '${property.roomsNb} pcs'),
//                           const SizedBox(width: 8),
//                           _pill(Icons.bathtub, '${property.bathroomsNb} bains'),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF / mois',
//                             style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w900,
//                                 color: primary),
//                           ),
//                           Icon(Icons.arrow_forward_ios,
//                               size: 16, color: accent.withOpacity(.6)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _pill(IconData icon, String label) {
//     final accent = Theme.of(context).colorScheme.secondary;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: accent.withOpacity(.08),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: accent),
//           const SizedBox(width: 4),
//           Text(label, style: TextStyle(fontSize: 12, color: accent)),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomLoader() {
//     if (_isPaginating) {
//       return const Padding(
//         padding: EdgeInsets.all(16),
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }
//     if (!_hasMoreData && _properties.isNotEmpty) {
//       final locale = Provider.of<SettingsProvider>(context).locale;
//       return Padding(
//         padding: const EdgeInsets.only(top: 16, bottom: 32),
//         child: Text(
//           AppTranslations.get('end_of_list', locale, 'Fin de la liste'),
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
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: () => _loadProperties(isInitialLoad: true),
//         child: Column(
//           children: [
//             _buildSearchBar(context, locale),
//             Expanded(
//               child: _isLoading && _properties.isEmpty
//                   ? const Center(child: CircularProgressIndicator())
//                   : _errorMessage != null
//                       ? Center(child: Text(_errorMessage!))
//                       : _properties.isEmpty
//                           ? Center(
//                               child: Text(AppTranslations.get(
//                                   'no_properties', locale, 'Aucune propriété')))
//                           : ListView.builder(
//                               controller: _scrollController,
//                               padding: const EdgeInsets.only(top: 8),
//                               itemCount: _properties.length + 1,
//                               itemBuilder: (_, index) {
//                                 if (index == _properties.length) {
//                                   return _buildBottomLoader();
//                                 }
//                                 return _buildPropertyCard(
//                                     context, _properties[index]);
//                               },
//                             ),
//             ),
//           ],
//         ),
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

// ====================================================================
// PAGE D'ACCUEIL AVEC RECHERCHE ET FILTRES
// ====================================================================
/// Page principale affichant la liste des propriétés avec fonctionnalités de :
/// - Recherche en temps réel
/// - Filtres avancés (ville, catégorie, statut, prix, surface, équipements)
/// - Pagination infinie
/// - Gestion des favoris
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ==================================================================
  // SERVICES ET CONTRÔLEURS
  // ==================================================================
  final PropertyService _propertyService = PropertyService();
  final TownService _townService = TownService();
  final CategoryService _categoryService = CategoryService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // ==================================================================
  // ÉTAT DE LA PAGE
  // ==================================================================
  List<Property> _properties = [];
  bool _isLoading = true;
  bool _isPaginating = false;
  bool _hasMoreData = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _limit = 10;
  String _currentSearchQuery = '';
  String? _togglingFavoriteId;

  // ==================================================================
  // FILTRES APPLIQUÉS
  // ==================================================================
  /// Map contenant tous les filtres disponibles pour la recherche
  final Map<String, dynamic> _filters = {
    // Recherche texte
    'search': '',
    'title': '',
    'address': '',
    
    // Filtres numériques avec opérations
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
    
    // Filtres de statut et caractéristiques
    'status': '',
    'water_supply': '',
    'electrical_connection': '',
    'town_id': '',
    'category_property_id': '',
    'certified': '',
    
    // Équipements (seulement 'true' est envoyé à l'API)
    'has_internal_kitchen': '',
    'has_external_kitchen': '',
    'has_a_parking': '',
    'has_air_conditioning': '',
    'has_security_guards': '',
    'has_balcony': '',
    
    // Tri
    'order': 'asc',
  };

  // ==================================================================
  // ÉTAT DES FILTRES (BOTTOM SHEET)
  // ==================================================================
  List<Town> _filteredTowns = [];
  Town? _selectedTown;
  bool _isSearchingTowns = false;
  bool _showTownDropdown = false;

  List<Category> _filteredCategories = [];
  Category? _selectedCategory;
  bool _isSearchingCategories = false;
  bool _showCategoryDropdown = false;

  // ==================================================================
  // LIFECYCLE METHODS
  // ==================================================================
  
  @override
  void initState() {
    super.initState();
    // Charge les propriétés après le premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperties(isInitialLoad: true);
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ==================================================================
  // GESTION DE LA PAGINATION
  // ==================================================================
  
  /// Écoute le défilement pour charger plus de données
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        !_isPaginating &&
        _hasMoreData) {
      _loadProperties(isPaginating: true);
    }
  }

  // ==================================================================
  // MÉTHODES DE GESTION DES DONNÉES
  // ==================================================================
  
  /// Charge les propriétés avec les filtres actuels
  /// [isInitialLoad] : true pour recharger depuis le début
  /// [isPaginating] : true pour charger la page suivante
  /// [newQuery] : nouvelle requête de recherche
  /// [newFilters] : nouveaux filtres à appliquer
  Future<void> _loadProperties({
    bool isInitialLoad = false,
    bool isPaginating = false,
    String? newQuery,
    Map<String, dynamic>? newFilters,
  }) async {
    if (!mounted) return;

    // Détermine le comportement de chargement
    final bool isNewSearch = newQuery != null;
    final bool isNewFilter = newFilters != null;
    final bool shouldReset = isInitialLoad || isNewSearch || isNewFilter || !isPaginating;

    final int nextPage = shouldReset ? 1 : _currentPage + 1;
    final String effectiveQuery = newQuery ?? _currentSearchQuery;

    // Met à jour les filtres si nécessaire
    if (isNewFilter) {
      _filters.clear();
      _filters.addAll(newFilters!);
    }
    _filters['search'] = effectiveQuery;

    // Met à jour l'état de l'interface
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
      // Construction des paramètres de requête
      final Map<String, dynamic> queryParams = {
        'page': nextPage,
        'limit': _limit,
      };

      // Filtrage intelligent des paramètres
      _filters.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          // Pour les équipements, on n'envoie que si la valeur est 'true'
          if (key.startsWith('has_')) {
            if (value == 'true') {
              queryParams[key] = value;
            }
          } else {
            // Pour tous les autres champs, comportement normal
            queryParams[key] = value;
          }
        }
      });

      debugPrint('Requête API avec filtres: $queryParams');

      // Appel API
      final response = await _propertyService.getPropertiesWithFilters(queryParams);
      
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
          _errorMessage = "Erreur de chargement: ${e.toString()}";
          _isLoading = false;
          _isPaginating = false;
          if (isPaginating) _currentPage--;
        });
      }
    }
  }

  // ==================================================================
  // GESTION DES VILLES (FILTRES)
  // ==================================================================
  
  /// Charge toutes les villes disponibles
  Future<void> _loadAllTowns() async {
    try {
      final towns = await _townService.getAllTowns();
      _filteredTowns = towns;
    } catch (e) {
      debugPrint('Erreur chargement villes: $e');
    }
  }

  /// Gère la recherche de villes
  void _onTownSearchChanged(String query, Function setStateBS) async {
    if (query.isEmpty) {
      setStateBS(() {
        _showTownDropdown = false;
        _filteredTowns = [];
      });
      return;
    }
    
    setStateBS(() {
      _isSearchingTowns = true;
      _showTownDropdown = true;
    });
    
    try {
      final response = await _townService.searchTowns(query);
      setStateBS(() {
        _filteredTowns = response.records;
        _isSearchingTowns = false;
      });
    } catch (e) {
      setStateBS(() => _isSearchingTowns = false);
    }
  }

  /// Sélectionne une ville dans les filtres
  void _selectTown(Town town, Function setStateBS, Map<String, dynamic> localFilters, TextEditingController townController) {
    setStateBS(() {
      _selectedTown = town;
      _showTownDropdown = false;
      localFilters['town_id'] = town.id;
      townController.text = town.name;
    });
  }

  /// Efface la sélection de ville
  void _clearTownSelection(Function setStateBS, Map<String, dynamic> localFilters, TextEditingController townController) {
    setStateBS(() {
      _selectedTown = null;
      _showTownDropdown = false;
      localFilters['town_id'] = '';
      townController.clear();
    });
  }

  // ==================================================================
  // GESTION DES CATÉGORIES (FILTRES)
  // ==================================================================
  
  /// Charge toutes les catégories disponibles
  Future<void> _loadAllCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      _filteredCategories = categories;
    } catch (e) {
      debugPrint('Erreur chargement catégories: $e');
    }
  }

  /// Gère la recherche de catégories
  void _onCategorySearchChanged(String query, Function setStateBS) async {
    if (query.isEmpty) {
      setStateBS(() {
        _showCategoryDropdown = false;
        _filteredCategories = [];
      });
      return;
    }
    
    setStateBS(() {
      _isSearchingCategories = true;
      _showCategoryDropdown = true;
    });
    
    try {
      final response = await _categoryService.searchCategories(query);
      setStateBS(() {
        _filteredCategories = response.records;
        _isSearchingCategories = false;
      });
    } catch (e) {
      setStateBS(() => _isSearchingCategories = false);
    }
  }

  /// Sélectionne une catégorie dans les filtres
  void _selectCategory(Category category, Function setStateBS, Map<String, dynamic> localFilters, TextEditingController categoryController) {
    setStateBS(() {
      _selectedCategory = category;
      _showCategoryDropdown = false;
      localFilters['category_property_id'] = category.id;
      categoryController.text = category.name;
    });
  }

  /// Efface la sélection de catégorie
  void _clearCategorySelection(Function setStateBS, Map<String, dynamic> localFilters, TextEditingController categoryController) {
    setStateBS(() {
      _selectedCategory = null;
      _showCategoryDropdown = false;
      localFilters['category_property_id'] = '';
      categoryController.clear();
    });
  }

  // ==================================================================
  // MÉTHODES D'UTILITÉ
  // ==================================================================
  
  /// Retourne la traduction du statut de la propriété
  String _getStatusTranslation(Locale locale, String status) {
    final translations = {
      'free': AppTranslations.get('status_free', locale, 'Libre'),
      'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
      'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
    };
    return translations[status] ?? status;
  }

  /// Retourne la couleur associée au statut
  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'free': return AppThemes.getSuccessColor(context);
      case 'busy': return AppThemes.getErrorColor(context);
      case 'prev_advise': return AppThemes.getWarningColor(context);
      default: return Colors.grey;
    }
  }

  /// Retourne l'icône associée au statut
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'free': return Icons.check_circle;
      case 'busy': return Icons.do_not_disturb;
      case 'prev_advise': return Icons.access_time;
      default: return Icons.help_outline;
    }
  }

  /// Vérifie si l'utilisateur peut modifier cette propriété
  bool _canEditProperty(Property property) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) return false;

    final isOwner = currentUser.id == property.ownerId;
    final isAdmin = currentUser.role == 'admin';
    final isStaff = currentUser.isStaff == true;

    return isOwner || isAdmin || isStaff;
  }

  // ==================================================================
  // WIDGETS DE L'INTERFACE UTILISATEUR
  // ==================================================================

  /// Barre de recherche avec bouton de filtres
  Widget _buildSearchBar(BuildContext context, Locale locale) {
    final accent = Theme.of(context).colorScheme.secondary;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          // Champ de recherche
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (q) => _loadProperties(newQuery: q),
              decoration: InputDecoration(
                hintText: AppTranslations.get('search_placeholder', locale, 'Rechercher…'),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Bouton de filtres
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

  /// Affiche le bottom sheet des filtres
  void _showFilterBottomSheet(BuildContext context, Locale locale) {
    final Map<String, dynamic> localFilters = Map.from(_filters);

    // Contrôleurs pour les champs de filtres
    final townSearchController = TextEditingController();
    final categorySearchController = TextEditingController();
    final priceMinCtrl = TextEditingController(text: localFilters['monthly_price']?.toString() ?? '');
    final priceMaxCtrl = TextEditingController(text: localFilters['monthly_price_bis']?.toString() ?? '');
    final areaMinCtrl = TextEditingController(text: localFilters['area']?.toString() ?? '');
    final areaMaxCtrl = TextEditingController(text: localFilters['area_bis']?.toString() ?? '');
    final roomsMinCtrl = TextEditingController(text: localFilters['rooms_nb']?.toString() ?? '');
    final roomsMaxCtrl = TextEditingController(text: localFilters['rooms_nb_bis']?.toString() ?? '');
    final bathMinCtrl = TextEditingController(text: localFilters['bathrooms_nb']?.toString() ?? '');
    final bathMaxCtrl = TextEditingController(text: localFilters['bathrooms_nb_bis']?.toString() ?? '');

    // Initialise les valeurs existantes
    if (_selectedTown != null) townSearchController.text = _selectedTown!.name;
    if (_selectedCategory != null) categorySearchController.text = _selectedCategory!.name;

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
                  // En-tête avec bouton de réinitialisation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslations.get('filters', locale, 'Filtres'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => _resetFilters(
                          context, locale, setStateBS, localFilters,
                          townSearchController, categorySearchController,
                          priceMinCtrl, priceMaxCtrl, areaMinCtrl, areaMaxCtrl,
                          roomsMinCtrl, roomsMaxCtrl, bathMinCtrl, bathMaxCtrl
                        ),
                        child: Text(AppTranslations.get('reset', locale, 'Réinitialiser')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Contenu défilable des filtres
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Filtre par ville
                          _buildTownFilterSection(
                            locale, setStateBS, townSearchController, localFilters,
                            (query) => _onTownSearchChanged(query, setStateBS),
                            () => _clearTownSelection(setStateBS, localFilters, townSearchController),
                            (town) => _selectTown(town, setStateBS, localFilters, townSearchController)
                          ),
                          
                          // Filtre par catégorie
                          _buildCategoryFilterSection(
                            locale, setStateBS, categorySearchController, localFilters,
                            (query) => _onCategorySearchChanged(query, setStateBS),
                            () => _clearCategorySelection(setStateBS, localFilters, categorySearchController),
                            (category) => _selectCategory(category, setStateBS, localFilters, categorySearchController)
                          ),
                          
                          // Filtre par statut
                          _buildStatusFilterChips(locale, localFilters, setStateBS),
                          
                          // Filtres numériques
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
                          
                          // Filtre par équipements
                          _buildEquipmentChips(locale, localFilters, setStateBS),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  // Boutons d'action
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

  /// Réinitialise tous les filtres
  void _resetFilters(
    BuildContext context,
    Locale locale,
    Function setStateBS,
    Map<String, dynamic> localFilters,
    TextEditingController townController,
    TextEditingController categoryController,
    TextEditingController priceMinCtrl,
    TextEditingController priceMaxCtrl,
    TextEditingController areaMinCtrl,
    TextEditingController areaMaxCtrl,
    TextEditingController roomsMinCtrl,
    TextEditingController roomsMaxCtrl,
    TextEditingController bathMinCtrl,
    TextEditingController bathMaxCtrl,
  ) {
    final Map<String, dynamic> resetFilters = {
      'search': '', 'title': '', 'address': '',
      'monthly_price': '', 'monthly_price_bis': '', 'monthly_price_operation': '',
      'area': '', 'area_bis': '', 'area_operation': '',
      'rooms_nb': '', 'rooms_nb_bis': '', 'rooms_nb_operation': '',
      'bathrooms_nb': '', 'bathrooms_nb_bis': '', 'bathrooms_nb_operation': '',
      'living_rooms_nb': '', 'living_rooms_nb_bis': '', 'living_rooms_nb_operation': '',
      'compartment_number': '', 'compartment_number_bis': '', 'compartment_number_operation': '',
      'status': '', 'water_supply': '', 'electrical_connection': '',
      'town_id': '', 'category_property_id': '', 'certified': '',
      'has_internal_kitchen': '', 'has_external_kitchen': '', 'has_a_parking': '',
      'has_air_conditioning': '', 'has_security_guards': '', 'has_balcony': '',
      'order': 'asc',
    };

    // Réinitialise l'état local
    _selectedTown = null;
    _selectedCategory = null;
    
    // Vide tous les contrôleurs
    townController.clear();
    categoryController.clear();
    priceMinCtrl.clear(); priceMaxCtrl.clear();
    areaMinCtrl.clear(); areaMaxCtrl.clear();
    roomsMinCtrl.clear(); roomsMaxCtrl.clear();
    bathMinCtrl.clear(); bathMaxCtrl.clear();
    
    // Réinitialise l'UI
    _showTownDropdown = false;
    _showCategoryDropdown = false;
    _filteredTowns = [];
    _filteredCategories = [];
    
    // Applique les filtres reset
    localFilters.clear();
    localFilters.addAll(resetFilters);
    
    // Recharge les propriétés
    _loadProperties(newFilters: resetFilters, isInitialLoad: true);
    
    // Ferme le bottom sheet
    Navigator.of(context).pop();
    setStateBS(() {});
  }

  /// Section de filtre par ville
  Widget _buildTownFilterSection(
    Locale locale, 
    Function setStateBS, 
    TextEditingController controller,
    Map<String, dynamic> localFilters,
    Function(String) onSearchChanged,
    VoidCallback onClearSelection,
    Function(Town) onSelectTown,
  ) {
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
            controller: controller,
            decoration: InputDecoration(
              hintText: AppTranslations.get('search_town', locale, 'Rechercher une ville...'),
              prefixIcon: const Icon(Icons.location_city, color: Colors.grey),
              suffixIcon: _selectedTown != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: onClearSelection,
                    )
                  : _isSearchingTowns
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
              border: const OutlineInputBorder(),
            ),
            onTap: () {
              if (controller.text.isEmpty) _loadAllTowns();
              setStateBS(() => _showTownDropdown = true);
            },
            onChanged: onSearchChanged,
          ),
          // Dropdown des résultats de recherche
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
                    onTap: () => onSelectTown(town),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Section de filtre par catégorie
  Widget _buildCategoryFilterSection(
    Locale locale, 
    Function setStateBS, 
    TextEditingController controller,
    Map<String, dynamic> localFilters,
    Function(String) onSearchChanged,
    VoidCallback onClearSelection,
    Function(Category) onSelectCategory,
  ) {
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
            controller: controller,
            decoration: InputDecoration(
              hintText: AppTranslations.get('search_category', locale, 'Rechercher une catégorie...'),
              prefixIcon: const Icon(Icons.category, color: Colors.grey),
              suffixIcon: _selectedCategory != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: onClearSelection,
                    )
                  : _isSearchingCategories
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
              border: const OutlineInputBorder(),
            ),
            onTap: () {
              if (controller.text.isEmpty) _loadAllCategories();
              setStateBS(() => _showCategoryDropdown = true);
            },
            onChanged: onSearchChanged,
          ),
          // Dropdown des résultats de recherche
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
                    onTap: () => onSelectCategory(category),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Section de filtre par statut
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

  /// Section de filtre numérique (prix, surface, etc.)
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
          // Chips d'opération
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildOperationChip('', AppTranslations.get('range', locale, 'Intervalle'), currentOp == '', () {
                setStateBS(() => localFilters[operationKey] = '');
              }),
              _buildOperationChip('sup', AppTranslations.get('greater_than', locale, 'Supérieur à'), currentOp == 'sup', () {
                setStateBS(() {
                  localFilters[operationKey] = 'sup';
                  localFilters[maxKey] = '';
                  maxCtrl.clear();
                });
              }),
              _buildOperationChip('inf', AppTranslations.get('less_than', locale, 'Inférieur à'), currentOp == 'inf', () {
                setStateBS(() {
                  localFilters[operationKey] = 'inf';
                  localFilters[maxKey] = '';
                  maxCtrl.clear();
                });
              }),
            ],
          ),
          const SizedBox(height: 10),
          // Champs de saisie
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

  /// Chip d'opération pour les filtres numériques
  Widget _buildOperationChip(String value, String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.secondary,
      backgroundColor: Colors.transparent,
      checkmarkColor: Colors.white,
    );
  }

  /// Section de filtre par équipements
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

  /// Carte de propriété individuelle
  Widget _buildPropertyCard(BuildContext context, Property property) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isFavorite = authProvider.isPropertyFavorite(property.id);
        
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
                // Image et badges
                Stack(
                  children: [
                    // Image principale
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        property.mainImage.startsWith('http')
                            ? property.mainImage
                            : 'https://via.placeholder.com/600x400.png?text=Image+Indisponible',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    
                    // Badge de statut (gauche)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(context, property.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getStatusIcon(property.status), size: 14, color: Colors.white),
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
                    
                    // Badges et actions (droite)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Badge certifié
                          if (property.certified) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                      style: TextStyle(color: Colors.white, fontSize: 11)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          // Badge propriétaire
                          if (_canEditProperty(property)) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppThemes.getCertifiedColor(context),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Propriétaire',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          // Bouton favori
                          _buildFavoriteButton(context, locale, property, isFavorite, authProvider),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Informations de la propriété
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Catégorie et ville
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
                      // Titre
                      Text(property.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      // Caractéristiques
                      Row(
                        children: [
                          _buildInfoPill(Icons.square_foot, '${property.area} m²'),
                          const SizedBox(width: 8),
                          _buildInfoPill(Icons.bed, '${property.roomsNb} pcs'),
                          const SizedBox(width: 8),
                          _buildInfoPill(Icons.bathtub, '${property.bathroomsNb} bains'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Prix et flèche
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${property.monthlyPrice.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                              (Match m) => '${m[1]} ')} XOF / mois',
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
      },
    );
  }

  /// Bouton favori avec état de chargement
  Widget _buildFavoriteButton(BuildContext context, Locale locale, Property property, 
      bool isFavorite, AuthProvider authProvider) {
    return GestureDetector(
      onTap: () async {
        if (!authProvider.isLoggedIn || _togglingFavoriteId == property.id) {
          if (!authProvider.isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTranslations.get('login_required', locale, 'Veuillez vous connecter pour ajouter aux favoris.')),
                backgroundColor: AppThemes.getWarningColor(context),
              ),
            );
          }
          return;
        }
        
        setState(() => _togglingFavoriteId = property.id);
        
        try {
          await authProvider.toggleFavorite(property.id);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppTranslations.get('favorite_error', locale, 'Erreur lors de la modification des favoris')}: $e'),
              backgroundColor: AppThemes.getErrorColor(context),
            ),
          );
        } finally {
          if (mounted) {
            setState(() => _togglingFavoriteId = null);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _togglingFavoriteId == property.id
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              )
            : Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
                size: 18,
              ),
      ),
    );
  }

  /// Pill d'information (surface, chambres, etc.)
  Widget _buildInfoPill(IconData icon, String label) {
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

  /// Indicateur de chargement en bas de liste
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

  // ==================================================================
  // BUILD PRINCIPAL
  // ==================================================================
  
  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadProperties(isInitialLoad: true),
        child: Column(
          children: [
            // Barre de recherche
            _buildSearchBar(context, locale),
            
            // Liste des propriétés
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
                                return _buildPropertyCard(context, _properties[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}