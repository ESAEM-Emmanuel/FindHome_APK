// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:ui'; // Import nécessaire pour 'Locale'
// import '../services/property_service.dart';
// import '../models/property_model.dart';
// import '../providers/settings_provider.dart';
// import '../constants/app_translations.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final PropertyService _propertyService = PropertyService();
//   final ScrollController _scrollController = ScrollController(); // Contrôleur pour la pagination automatique

//   // --- Variables d'état pour la pagination et le chargement ---
//   List<Property> _properties = [];
//   bool _isLoading = true; // Chargement initial ou rafraîchissement
//   bool _isPaginating = false; // Chargement des pages suivantes (au scroll)
//   bool _hasMoreData = true; // Indique s'il y a plus de pages à charger
//   String? _errorMessage;
//   int _currentPage = 1; // Page actuelle
//   final int _limit = 10; // Nombre d'éléments par page (doit correspondre à l'API)
//   String _currentSearchQuery = ''; 
//   // -----------------------------------------------------------

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadProperties(isInitialLoad: true); // Chargement initial
//     });
    
//     // Écouteur pour détecter la fin du défilement et charger la page suivante
//     _scrollController.addListener(_scrollListener);
//   }

//   void _scrollListener() {
//     // Si l'utilisateur est près de la fin de la liste (80%) et qu'aucun chargement n'est en cours
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
//     super.dispose();
//   }

//   /// Méthode unifiée pour charger les données (initial, rafraîchissement, recherche, pagination)
//   Future<void> _loadProperties({
//     bool isInitialLoad = false,
//     bool isPaginating = false,
//     String? newQuery,
//   }) async {
//     if (!mounted) return;

//     final bool isNewSearch = newQuery != null;
//     final bool shouldReset = isInitialLoad || isNewSearch || !isPaginating;
    
//     // Déterminer la page et la requête pour le prochain appel API
//     final int nextPage = shouldReset ? 1 : _currentPage + 1;
//     final String effectiveQuery = newQuery ?? _currentSearchQuery;

//     setState(() {
//       if (shouldReset) {
//         _properties = [];
//         _currentPage = 1;
//         _isLoading = true;
//         _hasMoreData = true; // On suppose qu'il y a plus de données lors d'une réinitialisation
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
//           // Ajout des nouvelles propriétés à la liste existante
//           _properties.addAll(response.records);
          
//           // Mise à jour de l'état de pagination
//           _hasMoreData = response.currentPage < response.totalPages;
          
//           _isLoading = false;
//           _isPaginating = false;
//         });
//       }
//     } catch (e) {
//       print('ERREUR API DÉTAILLÉE: $e');
//       if (mounted) {
//         // Personnalisation des messages d'erreur
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
//           if (isPaginating) _currentPage--; // Annuler l'incrémentation de la page si l'appel échoue
//         });
//       }
//     }
//   }

//   // 1. Barre de Recherche et Filtres (Moderne)
//   Widget _buildSearchAndFilter(BuildContext context, Locale locale) {
//     final Color accentColor = Theme.of(context).colorScheme.secondary;
//     // Utilisation d'un TextEditingController local pour la recherche
//     final TextEditingController searchController = TextEditingController(text: _currentSearchQuery);

//     return Padding(
//       padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 20),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: searchController,
//               // Utilise la requête de recherche existante comme valeur par défaut
//               onSubmitted: (query) {
//                 // Déclenche une nouvelle recherche, réinitialisant la pagination
//                 _loadProperties(newQuery: query);
//               },
//               decoration: InputDecoration(
//                 hintText: AppTranslations.get('search_placeholder', locale, 'Rechercher un logement...'), 
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 suffixIcon: _currentSearchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear, color: Colors.grey),
//                         onPressed: () {
//                           searchController.clear();
//                           _loadProperties(newQuery: ''); // Efface la recherche et recharge tout
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
//                 // TODO: Afficher le BottomSheet pour les filtres avancés
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 2. Carte d'une Propriété (Design Convivial)
//   Widget _buildPropertyCard(BuildContext context, Property property) {
//     final Color accentColor = Theme.of(context).colorScheme.secondary;
//     final Color primaryColor = Theme.of(context).colorScheme.primary;

//     return GestureDetector(
//       onTap: () {
//         // Naviguer vers la page de détail en passant l'ID
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
//             // Image principale
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//               child: Image.network(
//                 property.mainImage.startsWith('http') ? property.mainImage : 'https://via.placeholder.com/600x400.png?text=Image+Indisponible', 
//                 height: 200,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   height: 200,
//                   color: Colors.grey.shade300,
//                   alignment: Alignment.center,
//                   child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
//                 ),
//               ),
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

//                   // Prix et Superficie (Pilules d'information)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildInfoPill(context, ' ${property.area} m²', Icons.square_foot),
//                       _buildInfoPill(context, ' ${property.roomsNb} Pcs', Icons.bed),
//                       _buildInfoPill(context, ' ${property.bathroomsNb} Bains', Icons.bathtub),
//                     ],
//                   ),
//                   const SizedBox(height: 10),

//                   // Prix
//                   Text(
//                     // Formatage du prix (550000 -> 550 000)
//                     '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/Mois',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w900,
//                       color: primaryColor,
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

//   // Widget utilitaire pour les pilules d'information
//   Widget _buildInfoPill(BuildContext context, String text, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.grey.shade600),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }

//   // Widget affiché en bas du ListView pour l'auto-scroll
//   Widget _buildBottomLoader() {
//     if (_isPaginating) {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//     // Affiche un message si toutes les données ont été chargées
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
//       onRefresh: () => _loadProperties(isInitialLoad: true), // Rafraîchit en tirant (page 1)
//       child: Column(
//         children: [
//           // Barre de Recherche et Filtres
//           _buildSearchAndFilter(context, locale), 

//           // Contenu principal (Liste des Propriétés)
//           Expanded(
//             child: _isLoading && _properties.isEmpty
//                 ? const Center(child: CircularProgressIndicator()) 
//                 : _errorMessage != null
//                     ? Center(
//                         // Affichage en cas d'erreur de chargement
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.error_outline, size: 50, color: Colors.red),
//                             const SizedBox(height: 10),
//                             Text(
//                               AppTranslations.get('error', locale, 'Erreur'),
//                               style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red),
//                             ),
//                             const SizedBox(height: 5),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 40.0),
//                               child: Text(
//                                 _errorMessage!,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(fontSize: 16, color: Colors.grey),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             OutlinedButton.icon(
//                               onPressed: () => _loadProperties(isInitialLoad: true),
//                               icon: const Icon(Icons.refresh),
//                               label: Text(AppTranslations.get('retry', locale, 'Réessayer')),
//                             ),
//                           ],
//                         ),
//                       )
//                     : _properties.isEmpty
//                         ? Center(
//                             child: Text(
//                               // Message différent si la liste est vide après une recherche
//                               _currentSearchQuery.isNotEmpty
//                                 ? AppTranslations.get('no_search_results', locale, 'Aucun résultat trouvé pour votre recherche.')
//                                 : AppTranslations.get('no_properties', locale, 'Aucune propriété trouvée pour l\'instant.'),
//                               style: const TextStyle(fontSize: 16, color: Colors.grey),
//                             ),
//                           )
//                         : ListView.builder(
//                               controller: _scrollController, // Rattachement du contrôleur pour le défilement infini
//                               itemCount: _properties.length + 1, // +1 pour l'indicateur de chargement/fin
//                               itemBuilder: (context, index) {
//                                 if (index == _properties.length) {
//                                   // Dernier élément: affiche l'indicateur de chargement/fin
//                                   return _buildBottomLoader();
//                                 }
//                                 // Affiche la carte de propriété
//                                 final property = _properties[index];
//                                 return _buildPropertyCard(context, property);
//                               },
//                             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:ui'; // Import nécessaire pour 'Locale'
// import '../services/property_service.dart';
// import '../models/property_model.dart';
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

//   // Indicateur de statut de connexion
//   Widget _buildAuthStatus(BuildContext context, Locale locale) {
//     final authProvider = Provider.of<AuthProvider>(context);
    
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             authProvider.isLoggedIn ? Icons.verified : Icons.person_outline,
//             color: authProvider.isLoggedIn ? Colors.green : Colors.orange,
//             size: 16,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             authProvider.isLoggedIn 
//               ? AppTranslations.get('welcome_user', locale, 'Connecté')
//               : AppTranslations.get('guest_mode', locale, 'Mode invité'),
//             style: TextStyle(
//               color: authProvider.isLoggedIn ? Colors.green : Colors.orange,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           if (!authProvider.isLoggedIn) ...[
//             const SizedBox(width: 8),
//             GestureDetector(
//               onTap: () {
//                 Navigator.of(context).pushNamed('/login');
//               },
//               child: Text(
//                 AppTranslations.get('login_here', locale, 'Se connecter'),
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.secondary,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // Barre de Recherche et Filtres
//   Widget _buildSearchAndFilter(BuildContext context, Locale locale) {
//     final Color accentColor = Theme.of(context).colorScheme.secondary;

//     return Padding(
//       padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
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

//   // BottomSheet pour les filtres (à implémenter)
//   void _showFilterBottomSheet(BuildContext context, Locale locale) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 AppTranslations.get('filters', locale, 'Filtres'),
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 20),
//               // TODO: Implémenter les filtres avancés
//               Text(
//                 AppTranslations.get('filters_coming_soon', locale, 'Fonctionnalité de filtres à venir...'),
//                 style: TextStyle(
//                   color: Theme.of(context).hintColor,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Text(AppTranslations.get('close', locale, 'Fermer')),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Carte d'une Propriété
//   Widget _buildPropertyCard(BuildContext context, Property property) {
//     final Color accentColor = Theme.of(context).colorScheme.secondary;
//     final Color primaryColor = Theme.of(context).colorScheme.primary;

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
//             // Image principale avec badge de certification
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

//                   // Prix
//                   Text(
//                     '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/Mois',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w900,
//                       color: primaryColor,
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
//           // Indicateur de statut de connexion
//           _buildAuthStatus(context, locale),
          
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
import 'dart:ui'; // Import nécessaire pour 'Locale'
import '../services/property_service.dart';
import '../models/property_model.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading && 
        !_isPaginating && 
        _hasMoreData) 
    {
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

  Future<void> _loadProperties({
    bool isInitialLoad = false,
    bool isPaginating = false,
    String? newQuery,
  }) async {
    if (!mounted) return;

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
      final response = await _propertyService.getProperties(
        page: nextPage,
        limit: _limit,
        search: effectiveQuery,
      );
      
      if (mounted) {
        setState(() {
          _properties.addAll(response.records);
          _hasMoreData = response.currentPage < response.totalPages;
          _isLoading = false;
          _isPaginating = false;
        });
      }
    } catch (e) {
      print('ERREUR API DÉTAILLÉE: $e');
      if (mounted) {
        String message = AppTranslations.get('data_loading_error', const Locale('fr'), 'Erreur de chargement des données.');
        if (e.toString().contains('Connection refused') || e.toString().contains('host lookup')) {
             message = AppTranslations.get('api_connection_error', const Locale('fr'), 'Impossible de se connecter à l\'API. Vérifiez l\'adresse du serveur.');
        } else if (e.toString().contains('Exception: Échec du chargement')) {
             message = e.toString().substring(e.toString().indexOf(':') + 1).trim();
        }

        setState(() {
          _errorMessage = message;
          _isLoading = false;
          _isPaginating = false;
          if (isPaginating) _currentPage--;
        });
      }
    }
  }

  // Barre de Recherche et Filtres
  Widget _buildSearchAndFilter(BuildContext context, Locale locale) {
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 10), // Ajustement du padding top
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (query) {
                _loadProperties(newQuery: query);
              },
              decoration: InputDecoration(
                hintText: AppTranslations.get('search_placeholder', locale, 'Rechercher un logement...'), 
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _currentSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _loadProperties(newQuery: '');
                        },
                      )
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
          Container(
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () {
                _showFilterBottomSheet(context, locale);
              },
            ),
          ),
        ],
      ),
    );
  }

  // BottomSheet pour les filtres (à implémenter)
  void _showFilterBottomSheet(BuildContext context, Locale locale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppTranslations.get('filters', locale, 'Filtres'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              // TODO: Implémenter les filtres avancés
              Text(
                AppTranslations.get('filters_coming_soon', locale, 'Fonctionnalité de filtres à venir...'),
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppTranslations.get('close', locale, 'Fermer')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Carte d'une Propriété
  Widget _buildPropertyCard(BuildContext context, Property property) {
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/property-detail',
          arguments: {'id': property.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale avec badge de certification
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    property.mainImage.startsWith('http') ? property.mainImage : 'https://via.placeholder.com/600x400.png?text=Image+Indisponible', 
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                if (property.certified)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Certifié',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie et Ville
                  Text(
                    '${property.category.name.toUpperCase()} - ${property.town.name}',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  // Titre
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Caractéristiques (Pilules d'information)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoPill(context, ' ${property.area} m²', Icons.square_foot),
                      _buildInfoPill(context, ' ${property.roomsNb} Pcs', Icons.bed),
                      _buildInfoPill(context, ' ${property.bathroomsNb} Bains', Icons.bathtub),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Prix
                  Text(
                    '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/Mois',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
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

  // Widget utilitaire pour les pilules d'information
  Widget _buildInfoPill(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12, 
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour l'indicateur de chargement en bas
  Widget _buildBottomLoader() {
    if (_isPaginating) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (!_hasMoreData && _properties.isNotEmpty) {
      final locale = Provider.of<SettingsProvider>(context).locale;
      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
        child: Text(
          AppTranslations.get('end_of_list', locale, 'Fin de la liste des propriétés.'),
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

    return RefreshIndicator(
      onRefresh: () => _loadProperties(isInitialLoad: true),
      child: Column(
        children: [
          // ✅ SUPPRIMÉ : Indicateur de statut de connexion
          
          // Barre de Recherche et Filtres
          _buildSearchAndFilter(context, locale), 

          // Contenu principal (Liste des Propriétés)
          Expanded(
            child: _isLoading && _properties.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Chargement des propriétés...'),
                      ],
                    ),
                  ) 
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline, 
                              size: 50, 
                              color: Theme.of(context).colorScheme.error
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppTranslations.get('error', locale, 'Erreur'),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.error
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: Theme.of(context).hintColor
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _loadProperties(isInitialLoad: true),
                              icon: const Icon(Icons.refresh),
                              label: Text(AppTranslations.get('retry', locale, 'Réessayer')),
                            ),
                          ],
                        ),
                      )
                    : _properties.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: Theme.of(context).hintColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _currentSearchQuery.isNotEmpty
                                    ? AppTranslations.get('no_search_results', locale, 'Aucun résultat trouvé pour votre recherche.')
                                    : AppTranslations.get('no_properties', locale, 'Aucune propriété trouvée pour l\'instant.'),
                                  style: TextStyle(
                                    fontSize: 16, 
                                    color: Theme.of(context).hintColor
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _properties.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _properties.length) {
                                return _buildBottomLoader();
                              }
                              final property = _properties[index];
                              return _buildPropertyCard(context, property);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}