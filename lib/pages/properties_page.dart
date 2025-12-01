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
//   //  VÉRIFICATION DES PERMISSIONS
//   // =========================================================
  
//   // Vérifie si l'utilisateur peut créer des propriétés
//   bool _canCreateProperty(AuthProvider authProvider) {
//     final user = authProvider.currentUser;
//     if (user == null) return false;
    
//     final isAdmin = user.role == 'admin';
//     final isOwner = user.role == 'owner';
//     final isStaff = user.isStaff == true;
    
//     return isAdmin || isOwner || isStaff;
//   }
  
//   // Vérifie si l'utilisateur peut voir toutes les propriétés
//   bool _canViewAllProperties(AuthProvider authProvider) {
//     final user = authProvider.currentUser;
//     if (user == null) return false;
    
//     final isAdmin = user.role == 'admin';
//     final isStaff = user.isStaff == true;
    
//     return isAdmin || isStaff;
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
    
//     final bool canViewAll = _canViewAllProperties(authProvider);

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

//       // Si l'utilisateur n'est pas admin/staff, on filtre par ses propriétés
//       if (!canViewAll && user != null) {
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
//   //  AJOUTER UNE PROPRIÉTÉ
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

//     // Vérification des permissions
//     if (!_canCreateProperty(authProvider)) {
//       final user = authProvider.currentUser;
      
//       if (user?.role == 'user') {
//         // Message spécifique pour les utilisateurs normaux
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(AppTranslations.get(
//                 'user_cannot_create', 
//                 locale, 
//                 'Vous devez faire une demande pour obtenir le privilège de créer des propriétés sur notre plateforme.')),
//             backgroundColor: AppThemes.getWarningColor(context),
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       } else {
//         // Message générique pour les autres cas
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(AppTranslations.get(
//                 'no_permission_create', 
//                 locale, 
//                 'Vous n\'avez pas la permission de créer des propriétés.')),
//             backgroundColor: AppThemes.getErrorColor(context),
//           ),
//         );
//       }
//       return;
//     }

//     Navigator.of(context)
//         .push(MaterialPageRoute(builder: (_) => const CreatePropertyPage()))
//         .then((_) => _loadProperties(isInitialLoad: true));
//   }

//   // =========================================================
//   //  UI – LISTVIEW MODERNE 2025 (sans Card)
//   // =========================================================
//   Widget _buildSearchBar(BuildContext context, Locale locale) {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final canCreate = _canCreateProperty(authProvider);
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
//           // if (canCreate) ...[
//           //   const SizedBox(width: 10),
//           //   Material(
//           //     color: accent,
//           //     borderRadius: BorderRadius.circular(30),
//           //     child: InkWell(
//           //       borderRadius: BorderRadius.circular(30),
//           //       onTap: _showAddPropertyDialog,
//           //       child: const Padding(
//           //         padding: EdgeInsets.all(12),
//           //         child: Icon(Icons.add, color: Colors.white),
//           //       ),
//           //     ),
//           //   ),
//           // ],
//         ],
//       ),
//     );
//   }

//   Widget _buildPropertyItem(BuildContext context, Property property) {
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
//     final authProvider = Provider.of<AuthProvider>(context);
//     final canCreate = _canCreateProperty(authProvider);
    
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
//                                 return _buildPropertyItem(
//                                     context, _properties[index]);
//                               },
//                             ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: canCreate
//           ? FloatingActionButton(
//               onPressed: _showAddPropertyDialog,
//               backgroundColor: Theme.of(context).colorScheme.secondary,
//               child: const Icon(Icons.add, color: Colors.white),
//             )
//           : null,
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

// ====================================================================
// PAGE DES PROPRIÉTÉS DE L'UTILISATEUR
// ====================================================================
/// Page affichant les propriétés de l'utilisateur connecté avec :
/// - Gestion des permissions par rôle (admin, owner, staff, user)
/// - Recherche et pagination
/// - Interface moderne avec badges de statut
/// - Bouton flottant conditionnel pour l'ajout de propriétés
class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  // ==================================================================
  // SERVICES ET CONTRÔLEURS
  // ==================================================================
  final PropertyService _propertyService = PropertyService();
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
  // VÉRIFICATION DES PERMISSIONS
  // ==================================================================
  
  /// Vérifie si l'utilisateur peut créer des propriétés
  /// - Admin, Owner et Staff peuvent créer
  /// - Les Users normaux ne peuvent pas créer
  bool _canCreateProperty(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    if (user == null) return false;
    
    final isAdmin = user.role == 'admin';
    final isOwner = user.role == 'owner';
    final isStaff = user.isStaff == true;
    
    return isAdmin || isOwner || isStaff;
  }
  
  /// Vérifie si l'utilisateur peut voir toutes les propriétés
  /// - Admin et Staff voient toutes les propriétés
  /// - Owner et User ne voient que leurs propres propriétés
  bool _canViewAllProperties(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    if (user == null) return false;
    
    final isAdmin = user.role == 'admin';
    final isStaff = user.isStaff == true;
    
    return isAdmin || isStaff;
  }

  // ==================================================================
  // MÉTHODES DE GESTION DES DONNÉES
  // ==================================================================
  
  /// Charge les propriétés selon le rôle de l'utilisateur
  /// [isInitialLoad] : true pour recharger depuis le début
  /// [isPaginating] : true pour charger la page suivante
  /// [newQuery] : nouvelle requête de recherche
  Future<void> _loadProperties({
    bool isInitialLoad = false,
    bool isPaginating = false,
    String? newQuery,
  }) async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final bool canViewAll = _canViewAllProperties(authProvider);

    // Détermine le comportement de chargement
    final bool isNewSearch = newQuery != null;
    final bool shouldReset = isInitialLoad || isNewSearch || !isPaginating;
    final int nextPage = shouldReset ? 1 : _currentPage + 1;
    final String effectiveQuery = newQuery ?? _currentSearchQuery;

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
      Map<String, dynamic> filters = {
        'page': nextPage,
        'limit': _limit,
        if (effectiveQuery.isNotEmpty) 'search': effectiveQuery,
      };

      // Filtrage par propriétaire si l'utilisateur n'est pas admin/staff
      if (!canViewAll && user != null) {
        filters['owner_id'] = user.id;
      }

      // Appel API
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

  // ==================================================================
  // GESTION DE LA CRÉATION DE PROPRIÉTÉS
  // ==================================================================
  
  /// Affiche le dialogue d'ajout de propriété avec vérification des permissions
  Future<void> _showAddPropertyDialog() async {
    final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Vérification de la connexion
    if (authProvider.accessToken == null) {
      _showSnackBar(
        AppTranslations.get('login_required', locale, 
            'Veuillez vous connecter pour ajouter une propriété.'),
        AppThemes.getWarningColor(context),
      );
      return;
    }

    // Vérification des permissions
    if (!_canCreateProperty(authProvider)) {
      _handleNoPermission(authProvider, locale);
      return;
    }

    // Navigation vers la page de création
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreatePropertyPage()))
        .then((_) => _loadProperties(isInitialLoad: true));
  }

  /// Gère l'affichage des messages d'erreur de permission
  void _handleNoPermission(AuthProvider authProvider, Locale locale) {
    final user = authProvider.currentUser;
    
    if (user?.role == 'user') {
      // Message spécifique pour les utilisateurs normaux
      _showSnackBar(
        AppTranslations.get('user_cannot_create', locale, 
            'Vous devez faire une demande pour obtenir le privilège de créer des propriétés sur notre plateforme.'),
        AppThemes.getWarningColor(context),
        duration: const Duration(seconds: 5),
      );
    } else {
      // Message générique pour les autres cas
      _showSnackBar(
        AppTranslations.get('no_permission_create', locale, 
            'Vous n\'avez pas la permission de créer des propriétés.'),
        AppThemes.getErrorColor(context),
      );
    }
  }

  /// Affiche un SnackBar avec les paramètres donnés
  void _showSnackBar(String message, Color backgroundColor, 
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  // ==================================================================
  // MÉTHODES D'UTILITÉ
  // ==================================================================
  
  /// Retourne la couleur associée au statut de la propriété
  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'free': return AppThemes.getSuccessColor(context);
      case 'busy': return AppThemes.getErrorColor(context);
      case 'prev_advise': return AppThemes.getWarningColor(context);
      default: return Colors.grey;
    }
  }

  /// Retourne l'icône associée au statut de la propriété
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'free': return Icons.check_circle;
      case 'busy': return Icons.do_not_disturb;
      case 'prev_advise': return Icons.access_time;
      default: return Icons.help_outline;
    }
  }

  /// Retourne la traduction du statut de la propriété
  String _getStatusTranslation(Locale locale, String status) {
    final translations = {
      'free': AppTranslations.get('status_free', locale, 'Libre'),
      'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
      'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
    };
    return translations[status] ?? status;
  }

  // ==================================================================
  // WIDGETS DE L'INTERFACE UTILISATEUR
  // ==================================================================

  /// Barre de recherche avec gestion des permissions d'ajout
  Widget _buildSearchBar(BuildContext context, Locale locale) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final canCreate = _canCreateProperty(authProvider);
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
          // Bouton d'ajout conditionnel (actuellement commenté)
          // if (canCreate) ...[
          //   const SizedBox(width: 10),
          //   Material(
          //     color: accent,
          //     borderRadius: BorderRadius.circular(30),
          //     child: InkWell(
          //       borderRadius: BorderRadius.circular(30),
          //       onTap: _showAddPropertyDialog,
          //       child: const Padding(
          //         padding: EdgeInsets.all(12),
          //         child: Icon(Icons.add, color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  /// Carte individuelle d'une propriété
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
            // Section image avec badges
            _buildPropertyImageSection(property, locale),
            
            // Section informations
            _buildPropertyInfoSection(property, primary, accent),
          ],
        ),
      ),
    );
  }

  /// Section image avec badges de statut et certification
  Widget _buildPropertyImageSection(Property property, Locale locale) {
    return Stack(
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
        
        // Badge de certification (en haut à droite)
        if (property.certified)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
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
          ),
        
        // Badge de statut (en haut à gauche)
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
      ],
    );
  }

  /// Section informations de la propriété
  Widget _buildPropertyInfoSection(Property property, Color primary, Color accent) {
    return Padding(
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
          
          // Caractéristiques (surface, pièces, salles de bain)
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
          
          // Prix et indicateur de navigation
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

  /// Indicateur de chargement ou fin de liste
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
    final authProvider = Provider.of<AuthProvider>(context);
    final canCreate = _canCreateProperty(authProvider);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadProperties(isInitialLoad: true),
        child: Column(
          children: [
            // Barre de recherche
            _buildSearchBar(context, locale),
            
            // Liste des propriétés
            Expanded(
              child: _buildContent(locale),
            ),
          ],
        ),
      ),
      // Bouton flottant conditionnel pour l'ajout
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: _showAddPropertyDialog,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  /// Construit le contenu principal en fonction de l'état
  Widget _buildContent(Locale locale) {
    // État de chargement initial
    if (_isLoading && _properties.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // État d'erreur
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    // État liste vide
    if (_properties.isEmpty) {
      return Center(
        child: Text(AppTranslations.get('no_properties', locale, 'Aucune propriété')),
      );
    }

    // État normal - Liste des propriétés
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: _properties.length + 1,
      itemBuilder: (_, index) {
        if (index == _properties.length) {
          return _buildBottomLoader();
        }
        return _buildPropertyItem(context, _properties[index]);
      },
    );
  }
}