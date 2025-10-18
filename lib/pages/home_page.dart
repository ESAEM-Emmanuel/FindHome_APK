// // lib/pages/home_page.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:ui'; // Import nécessaire pour 'Locale'
// import '../services/property_service.dart';
// import '../models/property_model.dart';
// import '../providers/settings_provider.dart';
// import '../constants/app_translations.dart';

// // Constante pour la couleur d'accentuation (pour l'icône de filtre)
// const Color accentOrange = Color.fromARGB(255, 255, 81, 0);

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // NOTE: Dans une vraie application, le PropertyService devrait être injecté.
//   final PropertyService _propertyService = PropertyService();
//   List<Property> _properties = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     // ✅ CORRECTION DU BLOCAGE UI : 
//     // Utiliser addPostFrameCallback pour garantir que le premier frame de l'UI 
//     // (le CircularProgressIndicator) est dessiné avant de lancer le chargement.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadProperties();
//     });
//   }

//   // Méthode pour charger les données (simulée)
//   Future<void> _loadProperties() async {
//     if (!mounted) return;
    
//     // On garde setState ici pour réinitialiser les états en cas de rafraîchissement
//     setState(() { 
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Simulation d'un appel API long
//       await Future.delayed(const Duration(milliseconds: 700));

//       // Simulation de données AVEC TOUS LES CHAMPS REQUIS (y compris 'description' et 'address')
//       final List<Property> simulatedData = [
//         Property(
//           id: '1', 
//           title: "Villa Prestige 4 Chambres", 
//           description: "Une magnifique villa spacieuse située dans un quartier calme et sécurisé, idéale pour une grande famille.", 
//           address: "123 Avenue des Palmiers, Quartier Bonamoussadi", // 🛑 Ajouté
//           monthlyPrice: 550000, 
//           area: 300, 
//           roomsNb: 4, 
//           bathroomsNb: 3, 
//           certified: true, 
//           status: 'free',
//           mainImage: 'https://images.unsplash.com/photo-1580587771525-78b9dba38257?fit=crop&w=800', 
//           otherImages: [],
//           town: Town(id: 'DLA', name: 'Douala'), 
//           category: Category(id: 'villa', name: 'Villa')
//         ),
//         Property(
//           id: '2', 
//           title: "Appartement Moderne 2 Pcs", 
//           description: "Appartement rénové en centre-ville, parfait pour jeunes professionnels ou couple. Proche de toutes commodités.", 
//           address: "45 Rue de la Poste, Mvan", // 🛑 Ajouté
//           monthlyPrice: 220000, 
//           area: 90, 
//           roomsNb: 2, 
//           bathroomsNb: 1, 
//           certified: false, 
//           status: 'free',
//           mainImage: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?fit=crop&w=800', 
//           otherImages: [],
//           town: Town(id: 'YDE', name: 'Yaoundé'), 
//           category: Category(id: 'apt', name: 'Appartement')
//         ),
//         Property(
//           id: '3', 
//           title: "Studio Meublé Confortable", 
//           description: "Petit studio meublé avec kitchenette et salle de bain privée, idéal pour étudiant ou première location.", 
//           address: "98 Boulevard de la Liberté", // 🛑 Ajouté
//           monthlyPrice: 100000, 
//           area: 35, 
//           roomsNb: 1, 
//           bathroomsNb: 1, 
//           certified: true, 
//           status: 'free',
//           mainImage: 'https://images.unsplash.com/photo-1600004907154-19254d33a697?fit=crop&w=800', 
//           otherImages: [],
//           town: Town(id: 'DLA', name: 'Douala'), 
//           category: Category(id: 'studio', name: 'Studio')
//         ),
//       ];
      
//       if (mounted) {
//         setState(() {
//           _properties = simulatedData;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = e.toString().contains('connexion') 
//               ? 'Erreur de connexion à l\'API.' 
//               : 'Erreur: $e';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // --- Widgets de la Page ---

//   // 1. Barre de Recherche et Filtres (Moderne)
//   Widget _buildSearchAndFilter(BuildContext context, Locale locale) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 20),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 // Utilise la traduction et fallback
//                 hintText: AppTranslations.get('search_placeholder', locale, 'Rechercher un logement...'), 
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Theme.of(context).cardColor,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//               ),
//               onSubmitted: (query) {
//                 // TODO: Appeler _loadProperties avec le filtre de recherche
//               },
//             ),
//           ),
//           const SizedBox(width: 10),
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.secondary,
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
//                       color: Theme.of(context).colorScheme.secondary,
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
//                     '${property.monthlyPrice.toString()} XOF/Mois',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w900,
//                       color: Theme.of(context).primaryColor,
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


//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;

//     return RefreshIndicator(
//       onRefresh: _loadProperties, // Permet de recharger les données en tirant vers le bas
//       child: Column(
//         children: [
//           // Barre de Recherche et Filtres
//           _buildSearchAndFilter(context, locale), 

//           // Contenu principal (Liste des Propriétés)
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator()) // Affiche le loader pendant le chargement
//                 : _errorMessage != null
//                     ? Center(
//                         child: Text(_errorMessage!),
//                       )
//                     : _properties.isEmpty
//                         ? Center(
//                             child: Text(
//                               AppTranslations.get('no_properties', locale, 'Aucune propriété trouvée pour l\'instant.'),
//                               style: const TextStyle(fontSize: 16, color: Colors.grey),
//                             ),
//                           )
//                         : ListView.builder(
//                             itemCount: _properties.length,
//                             itemBuilder: (context, index) {
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
import '../constants/app_translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PropertyService _propertyService = PropertyService();
  final ScrollController _scrollController = ScrollController(); // Contrôleur pour la pagination automatique

  // --- Variables d'état pour la pagination et le chargement ---
  List<Property> _properties = [];
  bool _isLoading = true; // Chargement initial ou rafraîchissement
  bool _isPaginating = false; // Chargement des pages suivantes (au scroll)
  bool _hasMoreData = true; // Indique s'il y a plus de pages à charger
  String? _errorMessage;
  int _currentPage = 1; // Page actuelle
  final int _limit = 10; // Nombre d'éléments par page (doit correspondre à l'API)
  String _currentSearchQuery = ''; 
  // -----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperties(isInitialLoad: true); // Chargement initial
    });
    
    // Écouteur pour détecter la fin du défilement et charger la page suivante
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Si l'utilisateur est près de la fin de la liste (80%) et qu'aucun chargement n'est en cours
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
    super.dispose();
  }

  /// Méthode unifiée pour charger les données (initial, rafraîchissement, recherche, pagination)
  Future<void> _loadProperties({
    bool isInitialLoad = false,
    bool isPaginating = false,
    String? newQuery,
  }) async {
    if (!mounted) return;

    final bool isNewSearch = newQuery != null;
    final bool shouldReset = isInitialLoad || isNewSearch || !isPaginating;
    
    // Déterminer la page et la requête pour le prochain appel API
    final int nextPage = shouldReset ? 1 : _currentPage + 1;
    final String effectiveQuery = newQuery ?? _currentSearchQuery;

    setState(() {
      if (shouldReset) {
        _properties = [];
        _currentPage = 1;
        _isLoading = true;
        _hasMoreData = true; // On suppose qu'il y a plus de données lors d'une réinitialisation
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
          // Ajout des nouvelles propriétés à la liste existante
          _properties.addAll(response.records);
          
          // Mise à jour de l'état de pagination
          _hasMoreData = response.currentPage < response.totalPages;
          
          _isLoading = false;
          _isPaginating = false;
        });
      }
    } catch (e) {
      print('ERREUR API DÉTAILLÉE: $e');
      if (mounted) {
        // Personnalisation des messages d'erreur
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
          if (isPaginating) _currentPage--; // Annuler l'incrémentation de la page si l'appel échoue
        });
      }
    }
  }

  // 1. Barre de Recherche et Filtres (Moderne)
  Widget _buildSearchAndFilter(BuildContext context, Locale locale) {
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    // Utilisation d'un TextEditingController local pour la recherche
    final TextEditingController searchController = TextEditingController(text: _currentSearchQuery);

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              // Utilise la requête de recherche existante comme valeur par défaut
              onSubmitted: (query) {
                // Déclenche une nouvelle recherche, réinitialisant la pagination
                _loadProperties(newQuery: query);
              },
              decoration: InputDecoration(
                hintText: AppTranslations.get('search_placeholder', locale, 'Rechercher un logement...'), 
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _currentSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();
                          _loadProperties(newQuery: ''); // Efface la recherche et recharge tout
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
                // TODO: Afficher le BottomSheet pour les filtres avancés
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2. Carte d'une Propriété (Design Convivial)
  Widget _buildPropertyCard(BuildContext context, Property property) {
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        // Naviguer vers la page de détail en passant l'ID
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
            // Image principale
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

                  // Prix et Superficie (Pilules d'information)
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
                    // Formatage du prix (550000 -> 550 000)
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
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Widget affiché en bas du ListView pour l'auto-scroll
  Widget _buildBottomLoader() {
    if (_isPaginating) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // Affiche un message si toutes les données ont été chargées
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
      onRefresh: () => _loadProperties(isInitialLoad: true), // Rafraîchit en tirant (page 1)
      child: Column(
        children: [
          // Barre de Recherche et Filtres
          _buildSearchAndFilter(context, locale), 

          // Contenu principal (Liste des Propriétés)
          Expanded(
            child: _isLoading && _properties.isEmpty
                ? const Center(child: CircularProgressIndicator()) 
                : _errorMessage != null
                    ? Center(
                        // Affichage en cas d'erreur de chargement
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 50, color: Colors.red),
                            const SizedBox(height: 10),
                            Text(
                              AppTranslations.get('error', locale, 'Erreur'),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red),
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: () => _loadProperties(isInitialLoad: true),
                              icon: const Icon(Icons.refresh),
                              label: Text(AppTranslations.get('retry', locale, 'Réessayer')),
                            ),
                          ],
                        ),
                      )
                    : _properties.isEmpty
                        ? Center(
                            child: Text(
                              // Message différent si la liste est vide après une recherche
                              _currentSearchQuery.isNotEmpty
                                ? AppTranslations.get('no_search_results', locale, 'Aucun résultat trouvé pour votre recherche.')
                                : AppTranslations.get('no_properties', locale, 'Aucune propriété trouvée pour l\'instant.'),
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                              controller: _scrollController, // Rattachement du contrôleur pour le défilement infini
                              itemCount: _properties.length + 1, // +1 pour l'indicateur de chargement/fin
                              itemBuilder: (context, index) {
                                if (index == _properties.length) {
                                  // Dernier élément: affiche l'indicateur de chargement/fin
                                  return _buildBottomLoader();
                                }
                                // Affiche la carte de propriété
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