// // lib/pages/properties_page.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:ui'; // Import nécessaire pour 'Locale'

// import '../services/property_service.dart';
// import '../models/property_model.dart';
// import '../providers/settings_provider.dart';
// import '../providers/auth_provider.dart';
// import '../constants/app_translations.dart';
// import '../constants/app_themes.dart'; // Pour accentOrange
// import 'create_property_page.dart';

// class PropertiesPage extends StatefulWidget {
//   const PropertiesPage({super.key});

//   @override
//   State<PropertiesPage> createState() => _PropertiesPageState();
// }

// class _PropertiesPageState extends State<PropertiesPage> {
//   final PropertyService _propertyService = PropertyService();
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

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadProperties(isInitialLoad: true);
//     });
    
//     _scrollController.addListener(_scrollListener);
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
//     super.dispose();
//   }

//   Future<void> _loadProperties({
//     bool isInitialLoad = false,
//     bool isPaginating = false,
//     String? newQuery,
//   }) async {
//     if (!mounted) return;

//     final bool isNewSearch = newQuery != null;
//     final bool shouldReset = isInitialLoad || isNewSearch || !isPaginating;
    
//     final int nextPage = shouldReset ? 1 : _currentPage + 1;
//     final String effectiveQuery = newQuery ?? _currentSearchQuery;

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
//       final response = await _propertyService.getProperties(
//         page: nextPage,
//         limit: _limit,
//         search: effectiveQuery,
//       );
      
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

//   // Dialogue de détail d'une propriété
//   Future<void> _showPropertyDetailDialog(Property property) async {
//     final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
//     final Color primaryColor = Theme.of(context).primaryColor;
//     final Color accentColor = Theme.of(context).colorScheme.secondary;

//     return showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Text(
//             property.title,
//             style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 // Image principale
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     property.mainImage.startsWith('http') ? property.mainImage : 'https://via.placeholder.com/400x300.png?text=Image+Indisponible',
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
//                 const SizedBox(height: 16),

//                 // Détails stylisés
//                 _buildDetailRow(
//                   icon: Icons.location_city_outlined,
//                   label: AppTranslations.get('category', locale, 'Catégorie'),
//                   value: property.category.name,
//                   iconColor: primaryColor,
//                 ),
//                 _buildDetailRow(
//                   icon: Icons.location_on_outlined,
//                   label: AppTranslations.get('town', locale, 'Ville'),
//                   value: property.town.name,
//                   iconColor: primaryColor,
//                 ),
//                 _buildDetailRow(
//                   icon: Icons.square_foot,
//                   label: AppTranslations.get('area', locale, 'Surface'),
//                   value: '${property.area} m²',
//                   iconColor: primaryColor,
//                 ),
//                 _buildDetailRow(
//                   icon: Icons.bed_outlined,
//                   label: AppTranslations.get('rooms', locale, 'Pièces'),
//                   value: '${property.roomsNb} Pièces',
//                   iconColor: primaryColor,
//                 ),
//                 _buildDetailRow(
//                   icon: Icons.bathtub_outlined,
//                   label: AppTranslations.get('bathrooms', locale, 'Salles de bain'),
//                   value: '${property.bathroomsNb} Salles de bain',
//                   iconColor: primaryColor,
//                 ),

//                 const SizedBox(height: 16),
//                 // Prix
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         AppTranslations.get('monthly_price', locale, 'Prix mensuel'),
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w900,
//                           color: primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             // Bouton fermer
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 AppTranslations.get('close', locale, 'Fermer'),
//                 style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
//               ),
//             ),
            
//             // Bouton voir détails
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pushNamed(
//                   '/property-detail',
//                   arguments: {'id': property.id},
//                 );
//               },
//               icon: const Icon(Icons.visibility_outlined, size: 20),
//               label: Text(AppTranslations.get('view_details', locale, 'Voir détails')),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: accentColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//           ],
//           actionsAlignment: MainAxisAlignment.end,
//         );
//       },
//     );
//   }

//   // Widget utilitaire pour les détails
//   Widget _buildDetailRow({required IconData icon, required String label, required String value, required Color iconColor}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: iconColor, size: 24),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Dialogue pour ajouter une propriété
//   // Dans lib/pages/properties_page.dart

// Future<void> _showAddPropertyDialog() async {
//   final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
//   final authProvider = Provider.of<AuthProvider>(context, listen: false);

//   // Vérifier si l'utilisateur est connecté
//   if (authProvider.accessToken == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(AppTranslations.get('login_required', locale, 'Veuillez vous connecter pour ajouter une propriété.')),
//         backgroundColor: AppThemes.getWarningColor(context),
//       ),
//     );
//     return;
//   }

//   // Naviguer vers la page de création
//   Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (context) => const CreatePropertyPage(),
//     ),
//   ).then((_) {
//     // Recharger les propriétés après la création
//     _loadProperties(isInitialLoad: true);
//   });
// }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
//     final Color accentColor = Theme.of(context).colorScheme.secondary;
//     final Color primaryColor = Theme.of(context).primaryColor;

//     return Scaffold(
//       body: _isLoading && _properties.isEmpty
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Chargement des propriétés...'),
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
//                       Text(
//                         AppTranslations.get('error', locale, 'Erreur'),
//                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           color: Theme.of(context).colorScheme.error,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
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
//                       ElevatedButton.icon(
//                         onPressed: () => _loadProperties(isInitialLoad: true),
//                         icon: const Icon(Icons.refresh),
//                         label: Text(AppTranslations.get('retry', locale, 'Réessayer')),
//                       ),
//                     ],
//                   ),
//                 )
//               : _properties.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.home_work_outlined,
//                             size: 60,
//                             color: Theme.of(context).hintColor,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             _currentSearchQuery.isNotEmpty
//                                 ? AppTranslations.get('no_search_results', locale, 'Aucun résultat trouvé pour votre recherche.')
//                                 : AppTranslations.get('no_properties', locale, 'Aucune propriété trouvée pour l\'instant.'),
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Theme.of(context).hintColor,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     )
//                   : ListView.builder(
//                       controller: _scrollController,
//                       padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
//                       itemCount: _properties.length + 1,
//                       itemBuilder: (context, index) {
//                         if (index == _properties.length) {
//                           return _isPaginating
//                               ? const Padding(
//                                   padding: EdgeInsets.all(16.0),
//                                   child: Center(child: CircularProgressIndicator()),
//                                 )
//                               : !_hasMoreData
//                                   ? Padding(
//                                       padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
//                                       child: Text(
//                                         AppTranslations.get('end_of_list', locale, 'Fin de la liste des propriétés.'),
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(color: Colors.grey[600]),
//                                       ),
//                                     )
//                                   : const SizedBox.shrink();
//                         }

//                         final property = _properties[index];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                           child: Card(
//                             elevation: 2,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             child: ListTile(
//                               leading: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Image.network(
//                                   property.mainImage.startsWith('http') ? property.mainImage : 'https://via.placeholder.com/100x100.png?text=Image',
//                                   width: 60,
//                                   height: 60,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) => Container(
//                                     width: 60,
//                                     height: 60,
//                                     color: Colors.grey.shade300,
//                                     alignment: Alignment.center,
//                                     child: const Icon(Icons.home, color: Colors.grey),
//                                   ),
//                                 ),
//                               ),
//                               title: Text(
//                                 property.title,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     '${property.category.name} - ${property.town.name}',
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                   Text(
//                                     '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/mois',
//                                     style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
//                                   ),
//                                 ],
//                               ),
//                               trailing: IconButton(
//                                 onPressed: () => _showPropertyDetailDialog(property),
//                                 icon: Icon(Icons.arrow_forward_ios, size: 18, color: primaryColor),
//                               ),
//                               onTap: () => _showPropertyDetailDialog(property),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddPropertyDialog,
//         backgroundColor: accentOrange,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }
// // lib/pages/properties_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/property_service.dart';
// import '../models/property_model.dart';
// import '../providers/settings_provider.dart';
// import '../providers/auth_provider.dart';
// import '../constants/app_translations.dart';
// import '../constants/app_themes.dart';
// import 'create_property_page.dart';

// class PropertiesPage extends StatefulWidget {
//   const PropertiesPage({super.key});

//   @override
//   State<PropertiesPage> createState() => _PropertiesPageState();
// }

// class _PropertiesPageState extends State<PropertiesPage> {
//   final PropertyService _propertyService = PropertyService();
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

//   // =========================================================
//   //  CHARGEMENT DES PROPRIÉTÉS SELON LE RÔLE
//   // =========================================================
//   Future<void> _loadProperties({
//     bool isInitialLoad = false,
//     bool isPaginating = false,
//     String? newQuery,
//   }) async {
//     if (!mounted) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final user = authProvider.currentUser;
//     final isAdmin = user?.isStaff ?? false;

//     final bool isNewSearch = newQuery != null;
//     final bool shouldReset = isInitialLoad || isNewSearch || !isPaginating;
//     final int nextPage = shouldReset ? 1 : _currentPage + 1;
//     final String effectiveQuery = newQuery ?? _currentSearchQuery;

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
//       Map<String, dynamic> filters = {
//         'page': nextPage,
//         'limit': _limit,
//         if (effectiveQuery.isNotEmpty) 'search': effectiveQuery,
//       };

//       // Si NON admin → filtrer par propriétaire
//       if (!isAdmin && user != null) {
//         filters['owner_id'] = user.id;
//       }

//       final response = await _propertyService.getPropertiesWithFilters(filters);

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
//           _errorMessage = e.toString();
//           _isLoading = false;
//           _isPaginating = false;
//           if (isPaginating) _currentPage--;
//         });
//       }
//     }
//   }

//   // =========================================================
//   //  AJOUTER UNE PROPRIÉTÉ (bouton flottant)
//   // =========================================================
//   Future<void> _showAddPropertyDialog() async {
//     final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     if (authProvider.accessToken == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppTranslations.get(
//               'login_required', locale, 'Veuillez vous connecter pour ajouter une propriété.')),
//           backgroundColor: AppThemes.getWarningColor(context),
//         ),
//       );
//       return;
//     }

//     Navigator.of(context)
//         .push(MaterialPageRoute(builder: (_) => const CreatePropertyPage()))
//         .then((_) => _loadProperties(isInitialLoad: true));
//   }

//   // =========================================================
//   //  UI MODERNE
//   // =========================================================
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
//                 hintText: AppTranslations.get('search_placeholder', locale, 'Rechercher…'),
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
//               onTap: _showAddPropertyDialog,
//               child: const Padding(
//                 padding: EdgeInsets.all(12),
//                 child: Icon(Icons.add, color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPropertyCard(BuildContext context, Property property) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
//     final primary = Theme.of(context).colorScheme.primary;
//     final accent = Theme.of(context).colorScheme.secondary;

//     return GestureDetector(
//       onTap: () => Navigator.of(context)
//           .pushNamed('/property-detail', arguments: {'id': property.id}),
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 12,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image + badges
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(20)),
//                   child: Image.network(
//                     property.mainImage.startsWith('http')
//                         ? property.mainImage
//                         : 'https://via.placeholder.com/600x400.png?text=Image+Indisponible',
//                     height: 200,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(
//                       height: 200,
//                       color: Colors.grey.shade300,
//                       alignment: Alignment.center,
//                       child:
//                           const Icon(Icons.image_not_supported, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//                 if (property.certified)
//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: AppThemes.getCertifiedColor(context),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.verified, size: 14, color: Colors.white),
//                           SizedBox(width: 4),
//                           Text('Certifié',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 11)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 Positioned(
//                   top: 12,
//                   left: 12,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(context, property.status),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(_getStatusIcon(property.status),
//                             size: 14, color: Colors.white),
//                         const SizedBox(width: 4),
//                         Text(_getStatusTranslation(locale, property.status),
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           '${property.category.name.toUpperCase()}  •  ${property.town.name}',
//                           style: TextStyle(
//                               color: accent,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Text(property.title,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.w700)),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       _pill(Icons.square_foot, '${property.area} m²'),
//                       const SizedBox(width: 8),
//                       _pill(Icons.bed, '${property.roomsNb} pcs'),
//                       const SizedBox(width: 8),
//                       _pill(Icons.bathtub, '${property.bathroomsNb} bains'),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF / mois',
//                         style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w900,
//                             color: primary),
//                       ),
//                       Icon(Icons.arrow_forward_ios,
//                           size: 16, color: accent.withOpacity(.6)),
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

//   String _getStatusTranslation(Locale locale, String status) {
//     final translations = {
//       'free': AppTranslations.get('status_free', locale, 'Libre'),
//       'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
//       'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
//     };
//     return translations[status] ?? status;
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
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddPropertyDialog,
//         backgroundColor: Theme.of(context).colorScheme.secondary,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }

// lib/pages/properties_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_translations.dart';
import '../constants/app_themes.dart';
import 'create_property_page.dart';

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  final PropertyService _propertyService = PropertyService();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperties(isInitialLoad: true);
    });
    _scrollController.addListener(_scrollListener);
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
    super.dispose();
  }

  // =========================================================
  //  CHARGEMENT DES PROPRIÉTÉS SELON LE RÔLE
  // =========================================================
  Future<void> _loadProperties({
    bool isInitialLoad = false,
    bool isPaginating = false,
    String? newQuery,
  }) async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final isAdmin = user?.isStaff ?? false;

    final bool isNewSearch = newQuery != null;
    final bool shouldReset = isInitialLoad || isNewSearch || !isPaginating;
    final int nextPage = shouldReset ? 1 : _currentPage + 1;
    final String effectiveQuery = newQuery ?? _currentSearchQuery;

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
      Map<String, dynamic> filters = {
        'page': nextPage,
        'limit': _limit,
        if (effectiveQuery.isNotEmpty) 'search': effectiveQuery,
      };

      if (!isAdmin && user != null) {
        filters['owner_id'] = user.id;
      }

      final response = await _propertyService.getPropertiesWithFilters(filters);

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

  // =========================================================
  //  AJOUTER UNE PROPRIÉTÉ
  // =========================================================
  Future<void> _showAddPropertyDialog() async {
    final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get(
              'login_required', locale, 'Veuillez vous connecter pour ajouter une propriété.')),
          backgroundColor: AppThemes.getWarningColor(context),
        ),
      );
      return;
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreatePropertyPage()))
        .then((_) => _loadProperties(isInitialLoad: true));
  }

  // =========================================================
  //  UI – LISTVIEW MODERNE 2025 (sans Card)
  // =========================================================
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
              onTap: _showAddPropertyDialog,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyItem(BuildContext context, Property property) {
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
                        : 'https://via.placeholder.com/600x400.png?text=Image+Indisponible',
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

  String _getStatusTranslation(Locale locale, String status) {
    final translations = {
      'free': AppTranslations.get('status_free', locale, 'Libre'),
      'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
      'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
    };
    return translations[status] ?? status;
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
                                return _buildPropertyItem(
                                    context, _properties[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPropertyDialog,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}