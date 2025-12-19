// // lib/pages/property_detail_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/property_model.dart';
// import '../services/property_service.dart';
// import '../providers/settings_provider.dart';
// import '../providers/auth_provider.dart';
// import '../constants/app_translations.dart';
// import '../constants/app_themes.dart';
// import 'simple_image_viewer_screen.dart';
// import '../widgets/property_map_widget.dart';
// import 'edit_property_page.dart';

// // ====================================================================
// // PAGE DE DÉTAIL D'UNE PROPRIÉTÉ
// // ====================================================================
// /// Page affichant les détails complets d'une propriété
// /// Gère l'affichage, les favoris, les signalements et l'édition
// class PropertyDetailPage extends StatefulWidget {
//   final String propertyId;
  
//   const PropertyDetailPage({super.key, required this.propertyId});

//   @override
//   State<PropertyDetailPage> createState() => _PropertyDetailPageState();
// }

// class _PropertyDetailPageState extends State<PropertyDetailPage> {
//   // ==================================================================
//   // SERVICES ET CONTRÔLEURS
//   // ==================================================================
//   final PropertyService _propertyService = PropertyService();
//   final TextEditingController _reportController = TextEditingController();
  
//   // ==================================================================
//   // ÉTAT DE LA PAGE
//   // ==================================================================
//   Property? _property;
//   bool _isLoading = true;
//   String? _errorMessage;
//   bool _isReporting = false;
//   bool _isTogglingFavorite = false;

//   // ==================================================================
//   // LIFECYCLE METHODS
//   // ==================================================================
  
//   @override
//   void initState() {
//     super.initState();
//     _loadPropertyDetails();
//   }

//   // ==================================================================
//   // MÉTHODES DE GESTION DES DONNÉES
//   // ==================================================================
  
//   /// Charge les détails de la propriété depuis l'API
//   Future<void> _loadPropertyDetails() async {
//     try {
//       final loadedProperty = await _propertyService.getPropertyDetail(widget.propertyId);
      
//       if (mounted) {
//         setState(() {
//           _property = loadedProperty;
//           _isLoading = false;
//           _errorMessage = null;
//         });
//       }
//     } catch (e) {
//       print("❌ Erreur chargement détails propriété: $e");
//       if (mounted) {
//         setState(() {
//           _errorMessage = "Impossible de charger les détails. Cause: $e";
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // ==================================================================
//   // MÉTHODES D'UTILITÉ
//   // ==================================================================
  
//   /// Vérifie si l'utilisateur actuel peut modifier cette propriété
//   bool _canEditProperty() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final currentUser = authProvider.currentUser;
    
//     if (currentUser == null || _property == null) {
//       return false;
//     }

//     final isOwner = currentUser.id == _property!.ownerId;
//     final isAdmin = currentUser.role == 'admin';
//     final isStaff = currentUser.isStaff == true;

//     return isOwner || isAdmin || isStaff;
//   }

//   /// Retourne la traduction du statut de la propriété
//   String _getStatusTranslation(Locale locale, String status) {
//     final translations = {
//       'free': AppTranslations.get('status_free', locale, 'Libre'),
//       'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
//       'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
//     };
//     return translations[status] ?? status;
//   }

//   /// Retourne la couleur associée au statut de la propriété
//   Color _getStatusColor(BuildContext context, String status) {
//     switch (status) {
//       case 'free':
//         return AppThemes.getSuccessColor(context);
//       case 'busy':
//         return AppThemes.getErrorColor(context);
//       case 'prev_advise':
//         return AppThemes.getWarningColor(context);
//       default:
//         return Theme.of(context).hintColor;
//     }
//   }

//   /// Retourne l'icône associée au statut de la propriété
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

//   // ==================================================================
//   // MÉTHODES DE NAVIGATION
//   // ==================================================================
  
//   /// Navigue vers la page d'édition de la propriété
//   void _navigateToEditProperty() {
//     if (_property == null) return;

//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => EditPropertyPage(property: _property!),
//       ),
//     ).then((_) {
//       _loadPropertyDetails(); // Recharge les données après édition
//     });
//   }

//   /// Ouvre la visionneuse d'images en plein écran
//   void _openImageFullScreen(List<String> images, int initialIndex) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => SimpleImageViewerScreen(
//           images: images,
//           initialIndex: initialIndex,
//           propertyTitle: _property?.title ?? 'Galerie',
//         ),
//       ),
//     );
//   }

//   /// Ouvre la carte en plein écran
//   void _openFullScreenMap(BuildContext context, Property property) {
//     if (!property.hasValidLocation) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppTranslations.get('location_unavailable', 
//               Provider.of<SettingsProvider>(context).locale, 'Localisation non disponible')),
//           backgroundColor: AppThemes.getWarningColor(context),
//         ),
//       );
//       return;
//     }

//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => Scaffold(
//           appBar: AppBar(
//             title: Text(AppTranslations.get('location', 
//                 Provider.of<SettingsProvider>(context).locale, 'Localisation')),
//           ),
//           body: PropertyMapWidget(
//             property: property,
//             height: MediaQuery.of(context).size.height,
//             interactive: true,
//           ),
//         ),
//       ),
//     );
//   }

//   // ==================================================================
//   // MÉTHODES D'INTERACTION UTILISATEUR
//   // ==================================================================
  
//   /// Gère l'ajout/suppression de la propriété aux favoris
//   Future<void> _handleFavoriteToggle(BuildContext context, Locale locale) async {
//     if (_property == null || _isTogglingFavorite) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     // Vérification de la connexion
//     if (!authProvider.isLoggedIn) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppTranslations.get('login_required', locale, 
//               'Veuillez vous connecter pour ajouter aux favoris.')),
//           backgroundColor: AppThemes.getWarningColor(context),
//         ),
//       );
//       return;
//     }

//     setState(() => _isTogglingFavorite = true);

//     try {
//       final wasFavorite = authProvider.isPropertyFavorite(_property!.id);
//       await authProvider.toggleFavorite(_property!.id);
      
//       if (mounted) {
//         setState(() {});
//       }
      
//       final isNowFavorite = authProvider.isPropertyFavorite(_property!.id);
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(isNowFavorite
//               ? AppTranslations.get('favorite_added', locale, 'Ajouté aux favoris !')
//               : AppTranslations.get('favorite_removed', locale, 'Retiré des favoris.')),
//           backgroundColor: AppThemes.getSuccessColor(context),
//         ),
//       );
      
//     } catch (e) {
//       print('❌ Erreur toggle favori: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${AppTranslations.get('favorite_error', locale, 
//               'Erreur lors de la modification des favoris')}: $e'),
//           backgroundColor: AppThemes.getErrorColor(context),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isTogglingFavorite = false);
//       }
//     }
//   }

//   /// Affiche la boîte de dialogue de signalement
//   Future<void> _showReportDialog(BuildContext context, Locale locale, 
//       {bool isUserReport = false}) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final accessToken = authProvider.accessToken;

//     if (accessToken == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppTranslations.get('login_required', locale, 
//               'Veuillez vous connecter pour effectuer un signalement.')),
//           backgroundColor: AppThemes.getWarningColor(context),
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(isUserReport
//             ? AppTranslations.get('report_user', locale, 'Signaler l\'utilisateur')
//             : AppTranslations.get('report_property', locale, 'Signaler la propriété')),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(AppTranslations.get('report_description', locale, 
//                 'Veuillez décrire la raison de votre signalement')),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _reportController,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: AppTranslations.get('report_hint', locale, 'Description...'),
//                 border: const OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(AppTranslations.get('cancel', locale, 'Annuler')),
//           ),
//           ElevatedButton(
//             onPressed: _isReporting ? null : 
//                 () => _handleReport(context, locale, accessToken, isUserReport: isUserReport),
//             style: ElevatedButton.styleFrom(backgroundColor: AppThemes.getErrorColor(context)),
//             child: _isReporting
//                 ? const SizedBox(width: 20, height: 20, 
//                     child: CircularProgressIndicator(strokeWidth: 2))
//                 : Text(AppTranslations.get('report', locale, 'Signaler')),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Traite l'envoi du signalement
//   Future<void> _handleReport(BuildContext context, Locale locale, String accessToken, 
//       {bool isUserReport = false}) async {
//     if (_property == null || _reportController.text.isEmpty) return;

//     setState(() => _isReporting = true);

//     try {
//       if (isUserReport) {
//         await _propertyService.reportUser(_property!.ownerId, _reportController.text, accessToken);
//       } else {
//         await _propertyService.reportProperty(_property!.id, _reportController.text, accessToken);
//       }

//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(AppTranslations.get('report_success', locale, 
//                 'Signalement envoyé avec succès')),
//             backgroundColor: AppThemes.getSuccessColor(context),
//           ),
//         );
//         _reportController.clear();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${AppTranslations.get('report_error', locale, 
//                 'Erreur lors de l\'envoi du signalement')}: $e'),
//             backgroundColor: AppThemes.getErrorColor(context),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isReporting = false);
//     }
//   }

//   // ==================================================================
//   // WIDGETS DE L'INTERFACE UTILISATEUR
//   // ==================================================================

//   /// Bannière principale avec l'image de la propriété
//   Widget _buildAppBar(Property property, Locale locale) {
//     final allImages = [property.mainImage, ...property.otherImages];
//     final displayImages = allImages.where((url) => url.isNotEmpty).toList();

//     return SliverAppBar(
//       expandedHeight: 300,
//       pinned: true,
//       stretch: true,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           property.title,
//           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         background: GestureDetector(
//           onTap: () => displayImages.isNotEmpty ? 
//               _openImageFullScreen(displayImages, 0) : null,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               // Image principale
//               Image.network(
//                 property.mainImage,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => Container(
//                   color: Colors.grey.shade300,
//                   child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
//                 ),
//               ),
//               // Dégradé pour améliorer la lisibilité du titre
//               DecoratedBox(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         // Badge "Propriétaire" si l'utilisateur peut éditer
//         if (_canEditProperty())
//           Container(
//             margin: const EdgeInsets.all(8),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppThemes.getCertifiedColor(context),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.verified, size: 16, color: Colors.white),
//                 const SizedBox(width: 4),
//                 Text(
//                   'Propriétaire',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         // Bouton favori
//         Consumer<AuthProvider>(
//           builder: (context, authProvider, child) {
//             final isFavorite = authProvider.isPropertyFavorite(property.id);
            
//             if (_isTogglingFavorite) {
//               return const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 ),
//               );
//             }
            
//             return IconButton(
//               icon: Icon(
//                 isFavorite ? Icons.favorite : Icons.favorite_border,
//                 color: isFavorite ? Colors.red : Colors.white,
//               ),
//               onPressed: () => _handleFavoriteToggle(context, locale),
//             );
//           },
//         ),
//         // Menu contextuel
//         Consumer<AuthProvider>(
//           builder: (context, authProvider, child) {
//             return PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {
//                 switch (value) {
//                   case 'report_property':
//                     _showReportDialog(context, locale, isUserReport: false);
//                     break;
//                   case 'report_user':
//                     _showReportDialog(context, locale, isUserReport: true);
//                     break;
//                   case 'edit_property':
//                     if (_canEditProperty()) _navigateToEditProperty();
//                     break;
//                 }
//               },
//               itemBuilder: (_) {
//                 final items = <PopupMenuItem<String>>[];
                
//                 if (_canEditProperty()) {
//                   items.add(
//                     PopupMenuItem(
//                       value: 'edit_property',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
//                           const SizedBox(width: 8),
//                           Text('Modifier la propriété'),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
                
//                 items.addAll([
//                   PopupMenuItem(
//                     value: 'report_property',
//                     child: Row(
//                       children: [
//                         Icon(Icons.flag, color: AppThemes.getErrorColor(context)),
//                         const SizedBox(width: 8),
//                         Text(AppTranslations.get('report_property', locale, 'Signaler la propriété')),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem(
//                     value: 'report_user',
//                     child: Row(
//                       children: [
//                         Icon(Icons.person_off, color: AppThemes.getErrorColor(context)),
//                         const SizedBox(width: 8),
//                         Text(AppTranslations.get('report_user', locale, 'Signaler l\'utilisateur')),
//                       ],
//                     ),
//                   ),
//                 ]);
                
//                 return items;
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
  
//   /// Section affichant le prix, la localisation et les badges de statut
//   Widget _buildPriceLocationSection(Property property, Locale locale) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Catégorie et ville
//           Text(
//             '${property.category.name} • ${property.town.name}',
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.secondary,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Prix
//           Text(
//             '${property.monthlyPrice.toString().replaceAllMapped(
//               RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
//               (Match m) => '${m[1]} ')} XOF / mois',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w900,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Adresse
//           Row(
//             children: [
//               const Icon(Icons.location_on, size: 18, color: Colors.grey),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   '${property.address}, ${property.town.name}',
//                   style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           // Badges de statut et certification
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               // Badge de statut
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(context, property.status).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: _getStatusColor(context, property.status),
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       _getStatusIcon(property.status),
//                       size: 16,
//                       color: _getStatusColor(context, property.status),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       _getStatusTranslation(locale, property.status),
//                       style: TextStyle(
//                         color: _getStatusColor(context, property.status),
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Badge de certification
//               if (property.certified)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: AppThemes.getCertifiedColor(context).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: AppThemes.getCertifiedColor(context),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.verified,
//                         size: 16,
//                         color: AppThemes.getCertifiedColor(context),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         'Certifié',
//                         style: TextStyle(
//                           color: AppThemes.getCertifiedColor(context),
//                           fontWeight: FontWeight.w600,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   /// Section des informations principales sous forme de "pills"
//   Widget _buildInfoPills(Property property) {
//     final pills = [
//       _buildInfoPill(Icons.bed, '${property.roomsNb}', 'Chambres'),
//       _buildInfoPill(Icons.bathtub, '${property.bathroomsNb}', 'Salles de bain'),
//       _buildInfoPill(Icons.living, '${property.livingRoomsNb}', 'Salons'),
//       _buildInfoPill(Icons.square_foot, '${property.area}', 'm²'),
//     ];

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: pills,
//       ),
//     );
//   }

//   /// Widget individuel pour une information sous forme de pill
//   Widget _buildInfoPill(IconData icon, String value, String label) {
//     final accent = Theme.of(context).colorScheme.secondary;
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: accent.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: accent, size: 28),
//         ),
//         const SizedBox(height: 8),
//         Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
//       ],
//     );
//   }

//   /// Section de description de la propriété
//   Widget _buildDescriptionSection(Property property, Locale locale) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppTranslations.get('description', locale, 'Description'),
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             property.description,
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Galerie d'images supplémentaires
//   Widget _buildImageGallery(Property property) {
//     final allImages = [property.mainImage, ...property.otherImages];
//     final displayImages = allImages.where((url) => url.isNotEmpty).toList();

//     if (displayImages.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Text(
//           'Aucune image supplémentaire',
//           style: TextStyle(color: Theme.of(context).hintColor),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             'Galerie',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 120,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: displayImages.length,
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () => _openImageFullScreen(displayImages, index),
//                 child: Container(
//                   margin: EdgeInsets.only(right: 10, left: index == 0 ? 16 : 0),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.network(
//                       displayImages[index],
//                       width: 120,
//                       height: 120,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => Container(
//                         width: 120,
//                         height: 120,
//                         color: Colors.grey.shade300,
//                         child: const Icon(Icons.broken_image, color: Colors.grey),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   /// Section des équipements techniques (eau, électricité)
//   Widget _buildUtilitiesSection(Property property, Locale locale) {
    
//     /// Retourne la traduction d'une valeur d'équipement
//     String _getUtilityValueTranslation(String value) {
//       final translations = {
//         'not_available': AppTranslations.get('not_available', locale, 'Non disponible'),
//         'connected_public_supply': AppTranslations.get('connected_public_supply', locale, 'Réseau public'),
//         'stand_alone_system': AppTranslations.get('stand_alone_system', locale, 'Système autonome'),
//         'stand_alone_system_with_mains_connection': AppTranslations.get('stand_alone_system_with_mains_connection', locale, 'Système autonome avec connexion réseau'),
//       };
//       return translations[value] ?? value;
//     }

//     /// Retourne l'icône appropriée pour un type d'équipement
//     IconData _getUtilityIcon(String type, String value) {
//       if (type == 'water') {
//         switch (value) {
//           case 'connected_public_supply': return Icons.water_drop;
//           case 'stand_alone_system': return Icons.water;
//           case 'stand_alone_system_with_mains_connection': return Icons.water_drop_outlined;
//           default: return Icons.water_damage;
//         }
//       } else {
//         switch (value) {
//           case 'connected_public_supply': return Icons.bolt;
//           case 'stand_alone_system': return Icons.solar_power;
//           case 'stand_alone_system_with_mains_connection': return Icons.electrical_services;
//           default: return Icons.power_off;
//         }
//       }
//     }

//     /// Retourne la couleur appropriée pour un état d'équipement
//     Color _getUtilityColor(String value) {
//       switch (value) {
//         case 'connected_public_supply': return AppThemes.getSuccessColor(context);
//         case 'stand_alone_system': return AppThemes.getWarningColor(context);
//         case 'stand_alone_system_with_mains_connection': return AppThemes.getInfoColor(context);
//         default: return AppThemes.getErrorColor(context);
//       }
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppTranslations.get('utilities', locale, 'viabilisation'),
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 15),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Theme.of(context).cardColor,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Theme.of(context).dividerColor),
//             ),
//             child: Column(
//               children: [
//                 // Alimentation électrique
//                 _buildUtilityRow(
//                   'electricity',
//                   property.electricalConnection,
//                   AppTranslations.get('electrical_connection', locale, 'Alimentation électrique'),
//                   _getUtilityValueTranslation,
//                   _getUtilityIcon,
//                   _getUtilityColor,
//                 ),
//                 const SizedBox(height: 16),
//                 // Alimentation en eau
//                 _buildUtilityRow(
//                   'water',
//                   property.waterSupply,
//                   AppTranslations.get('water_supply', locale, 'Alimentation en eau'),
//                   _getUtilityValueTranslation,
//                   _getUtilityIcon,
//                   _getUtilityColor,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Ligne individuelle pour un équipement technique
//   Widget _buildUtilityRow(
//     String type,
//     String value,
//     String label,
//     String Function(String) valueTranslator,
//     IconData Function(String, String) iconGetter,
//     Color Function(String) colorGetter,
//   ) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: colorGetter(value).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             iconGetter(type, value),
//             color: colorGetter(value),
//             size: 24,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Theme.of(context).colorScheme.secondary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 valueTranslator(value),
//                 style: TextStyle(
//                   color: colorGetter(value),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// Section de la carte avec localisation
//   Widget _buildMapSection(Property property, Locale locale) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.map, color: Theme.of(context).colorScheme.secondary),
//               const SizedBox(width: 8),
//               Text(
//                 AppTranslations.get('location', locale, 'Localisation'),
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           GestureDetector(
//             onTap: () => _openFullScreenMap(context, property),
//             child: PropertyMapWidget(
//               property: property,
//               height: 200,
//               interactive: false,
//             ),
//           ),
//           if (property.location.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Theme.of(context).dividerColor),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary, size: 20),
//                   const SizedBox(width: 12),
//                   Expanded(child: Text(property.location[0])),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   /// Section des équipements de confort
//   Widget _buildFeaturesSection(Property property, Locale locale) {
//     final accent = Theme.of(context).colorScheme.secondary;
//     final features = <String, bool>{
//       AppTranslations.get('internal_kitchen', locale, 'Cuisine interne'): property.hasInternalKitchen,
//       AppTranslations.get('external_kitchen', locale, 'Cuisine externe'): property.hasExternalKitchen,
//       AppTranslations.get('parking', locale, 'Parking'): property.hasAParking,
//       AppTranslations.get('air_conditioning', locale, 'Climatisation'): property.hasAirConditioning,
//       AppTranslations.get('security_guards', locale, 'Gardiennage'): property.hasSecurityGuards,
//       AppTranslations.get('balcony', locale, 'Balcon'): property.hasBalcony,
//     };

//     final activeFeatures = features.entries.where((e) => e.value).toList();

//     if (activeFeatures.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppTranslations.get('features', locale, 'Équipements'),
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 15),
//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             children: activeFeatures.map((e) {
//               return Chip(
//                 avatar: Icon(Icons.check_circle, color: Colors.white, size: 18),
//                 label: Text(e.key, style: const TextStyle(color: Colors.white)),
//                 backgroundColor: accent,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Barre de contact en bas de page
//   Widget _buildContactBar(Locale locale) {
//     final accent = Theme.of(context).colorScheme.secondary;
//     return Container(
//       padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [BoxShadow(
//           color: Colors.black.withOpacity(0.1), 
//           blurRadius: 10, 
//           offset: const Offset(0, -5)
//         )],
//       ),
//       child: SizedBox(
//         height: 50,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: accent,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           onPressed: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Fonctionnalité de contact à implémenter'),
//                 backgroundColor: AppThemes.getInfoColor(context),
//               ),
//             );
//           },
//           child: Text(
//             AppTranslations.get('contact_owner', locale, 'Contacter le propriétaire'),
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Bouton flottant d'édition (visible seulement pour les propriétaires/admins)
//   Widget _buildEditFloatingButton() {
//     if (!_canEditProperty()) {
//       return const SizedBox.shrink();
//     }

//     return FloatingActionButton(
//       onPressed: _navigateToEditProperty,
//       backgroundColor: Theme.of(context).colorScheme.secondary,
//       foregroundColor: Colors.white,
//       child: const Icon(Icons.edit, size: 24),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 4,
//     );
//   }

//   // ==================================================================
//   // BUILD PRINCIPAL
//   // ==================================================================
  
//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;

//     // État de chargement
//     if (_isLoading) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: AppThemes.getSuccessColor(context)),
//               const SizedBox(height: 16),
//               Text(AppTranslations.get('loading', locale, 'Chargement...')),
//             ],
//           ),
//         ),
//       );
//     }

//     // État d'erreur
//     if (_errorMessage != null || _property == null) {
//       return Scaffold(
//         appBar: AppBar(title: Text(AppTranslations.get('error', locale, 'Erreur'))),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 64, color: AppThemes.getErrorColor(context)),
//               const SizedBox(height: 16),
//               Text(_errorMessage ?? 'Propriété introuvable', textAlign: TextAlign.center),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _loadPropertyDetails,
//                 child: Text(AppTranslations.get('retry', locale, 'Réessayer')),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // État normal - Affichage des détails
//     final property = _property!;
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           _buildAppBar(property, locale),
//           SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 _buildPriceLocationSection(property, locale),
//                 const Divider(height: 30, thickness: 1),
//                 _buildInfoPills(property),
//                 const Divider(height: 30, thickness: 1),
//                 _buildDescriptionSection(property, locale),
//                 const SizedBox(height: 30),
//                 _buildImageGallery(property),
//                 const SizedBox(height: 30),
//                 _buildUtilitiesSection(property, locale),
//                 const SizedBox(height: 30),
//                 _buildMapSection(property, locale),
//                 const SizedBox(height: 30),
//                 _buildFeaturesSection(property, locale),
//                 const SizedBox(height: 80), // Espace pour la barre de contact
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildContactBar(locale),
//       floatingActionButton: _buildEditFloatingButton(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }
// lib/pages/property_detail_page.dart
// lib/pages/property_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_translations.dart';
import '../constants/app_themes.dart';
import 'simple_image_viewer_screen.dart';
import '../widgets/property_map_widget.dart';
import 'edit_property_page.dart';
import '../widgets/export_widgets.dart'; // Uniquement cet import

// ====================================================================
// PAGE DE DÉTAIL D'UNE PROPRIÉTÉ
// ====================================================================
/// Page affichant les détails complets d'une propriété
/// Gère l'affichage, les favoris, les signalements et l'édition
class PropertyDetailPage extends StatefulWidget {
  final String propertyId;
  
  const PropertyDetailPage({super.key, required this.propertyId});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  // ==================================================================
  // SERVICES ET CONTRÔLEURS
  // ==================================================================
  final PropertyService _propertyService = PropertyService();
  final TextEditingController _reportController = TextEditingController();
  
  // ==================================================================
  // ÉTAT DE LA PAGE
  // ==================================================================
  Property? _property;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isReporting = false;
  bool _isTogglingFavorite = false;

  // ==================================================================
  // LIFECYCLE METHODS
  // ==================================================================
  
  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  // ==================================================================
  // MÉTHODES DE GESTION DES DONNÉES
  // ==================================================================
  
  /// Charge les détails de la propriété depuis l'API
  Future<void> _loadPropertyDetails() async {
    try {
      final loadedProperty = await _propertyService.getPropertyDetail(widget.propertyId);
      
      if (mounted) {
        setState(() {
          _property = loadedProperty;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      print("❌ Erreur chargement détails propriété: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Impossible de charger les détails. Cause: $e";
          _isLoading = false;
        });
      }
    }
  }

  // ==================================================================
  // MÉTHODES D'UTILITÉ
  // ==================================================================
  
  /// Vérifie si l'utilisateur actuel peut modifier cette propriété
  bool _canEditProperty() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null || _property == null) {
      return false;
    }

    final isOwner = currentUser.id == _property!.ownerId;
    final isAdmin = currentUser.role == 'admin';
    final isStaff = currentUser.isStaff == true;

    return isOwner || isAdmin || isStaff;
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

  /// Retourne la couleur associée au statut de la propriété
  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'free':
        return AppThemes.getSuccessColor(context);
      case 'busy':
        return AppThemes.getErrorColor(context);
      case 'prev_advise':
        return AppThemes.getWarningColor(context);
      default:
        return Theme.of(context).hintColor;
    }
  }

  /// Retourne l'icône associée au statut de la propriété
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

  // ==================================================================
  // MÉTHODES DE NAVIGATION
  // ==================================================================
  
  /// Navigue vers la page d'édition de la propriété
  void _navigateToEditProperty() {
    if (_property == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditPropertyPage(property: _property!),
      ),
    ).then((_) {
      _loadPropertyDetails(); // Recharge les données après édition
    });
  }

  /// Ouvre la visionneuse d'images en plein écran
  void _openImageFullScreen(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SimpleImageViewerScreen(
          images: images,
          initialIndex: initialIndex,
          propertyTitle: _property?.title ?? 'Galerie',
        ),
      ),
    );
  }

  /// Ouvre la carte en plein écran
  void _openFullScreenMap(BuildContext context, Property property) {
    if (!property.hasValidLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get('location_unavailable', 
              Provider.of<SettingsProvider>(context).locale, 'Localisation non disponible')),
          backgroundColor: AppThemes.getWarningColor(context),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(AppTranslations.get('location', 
                Provider.of<SettingsProvider>(context).locale, 'Localisation')),
          ),
          body: PropertyMapWidget(
            property: property,
            height: MediaQuery.of(context).size.height,
            interactive: true,
          ),
        ),
      ),
    );
  }

  // ==================================================================
  // MÉTHODES D'INTERACTION UTILISATEUR
  // ==================================================================
  
  /// Gère l'ajout/suppression de la propriété aux favoris
  Future<void> _handleFavoriteToggle(BuildContext context, Locale locale) async {
    if (_property == null || _isTogglingFavorite) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Vérification de la connexion
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get('login_required', locale, 
              'Veuillez vous connecter pour ajouter aux favoris.')),
          backgroundColor: AppThemes.getWarningColor(context),
        ),
      );
      return;
    }

    setState(() => _isTogglingFavorite = true);

    try {
      final wasFavorite = authProvider.isPropertyFavorite(_property!.id);
      await authProvider.toggleFavorite(_property!.id);
      
      if (mounted) {
        setState(() {});
      }
      
      final isNowFavorite = authProvider.isPropertyFavorite(_property!.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNowFavorite
              ? AppTranslations.get('favorite_added', locale, 'Ajouté aux favoris !')
              : AppTranslations.get('favorite_removed', locale, 'Retiré des favoris.')),
          backgroundColor: AppThemes.getSuccessColor(context),
        ),
      );
      
    } catch (e) {
      print('❌ Erreur toggle favori: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppTranslations.get('favorite_error', locale, 
              'Erreur lors de la modification des favoris')}: $e'),
          backgroundColor: AppThemes.getErrorColor(context),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isTogglingFavorite = false);
      }
    }
  }

  /// Affiche la boîte de dialogue de signalement
  Future<void> _showReportDialog(BuildContext context, Locale locale, 
      {bool isUserReport = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get('login_required', locale, 
              'Veuillez vous connecter pour effectuer un signalement.')),
          backgroundColor: AppThemes.getWarningColor(context),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isUserReport
            ? AppTranslations.get('report_user', locale, 'Signaler l\'utilisateur')
            : AppTranslations.get('report_property', locale, 'Signaler la propriété')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppTranslations.get('report_description', locale, 
                'Veuillez décrire la raison de votre signalement')),
            const SizedBox(height: 16),
            TextField(
              controller: _reportController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppTranslations.get('report_hint', locale, 'Description...'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppTranslations.get('cancel', locale, 'Annuler')),
          ),
          ElevatedButton(
            onPressed: _isReporting ? null : 
                () => _handleReport(context, locale, accessToken, isUserReport: isUserReport),
            style: ElevatedButton.styleFrom(backgroundColor: AppThemes.getErrorColor(context)),
            child: _isReporting
                ? const SizedBox(width: 20, height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(AppTranslations.get('report', locale, 'Signaler')),
          ),
        ],
      ),
    );
  }

  /// Traite l'envoi du signalement
  Future<void> _handleReport(BuildContext context, Locale locale, String accessToken, 
      {bool isUserReport = false}) async {
    if (_property == null || _reportController.text.isEmpty) return;

    setState(() => _isReporting = true);

    try {
      if (isUserReport) {
        await _propertyService.reportUser(_property!.ownerId, _reportController.text, accessToken);
      } else {
        await _propertyService.reportProperty(_property!.id, _reportController.text, accessToken);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get('report_success', locale, 
                'Signalement envoyé avec succès')),
            backgroundColor: AppThemes.getSuccessColor(context),
          ),
        );
        _reportController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTranslations.get('report_error', locale, 
                'Erreur lors de l\'envoi du signalement')}: $e'),
            backgroundColor: AppThemes.getErrorColor(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isReporting = false);
    }
  }

  // ==================================================================
  // MÉTHODES DE CONTACT
  // ==================================================================
  
  /// Affiche les options de contact dans un menu contextuel
  void _showContactOptions(BuildContext context, Locale locale, String phoneNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return ContactOptionsModal(
          phoneNumber: phoneNumber,
          ownerName: _property?.owner?.username ?? 'Propriétaire',
          locale: locale,
        );
      },
    );
  }

  // ==================================================================
  // WIDGETS DE L'INTERFACE UTILISATEUR
  // ==================================================================

  /// Bannière principale avec l'image de la propriété
  Widget _buildAppBar(Property property, Locale locale) {
    final allImages = [property.mainImage, ...property.otherImages];
    final displayImages = allImages.where((url) => url.isNotEmpty).toList();

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          property.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        background: GestureDetector(
          onTap: () => displayImages.isNotEmpty ? 
              _openImageFullScreen(displayImages, 0) : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image principale
              Image.network(
                property.mainImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                ),
              ),
              // Dégradé pour améliorer la lisibilité du titre
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Badge "Propriétaire" si l'utilisateur peut éditer
        if (_canEditProperty())
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppThemes.getCertifiedColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Propriétaire',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        // Bouton favori
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final isFavorite = authProvider.isPropertyFavorite(property.id);
            
            if (_isTogglingFavorite) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            }
            
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () => _handleFavoriteToggle(context, locale),
            );
          },
        ),
        // Menu contextuel
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'report_property':
                    _showReportDialog(context, locale, isUserReport: false);
                    break;
                  case 'report_user':
                    _showReportDialog(context, locale, isUserReport: true);
                    break;
                  case 'edit_property':
                    if (_canEditProperty()) _navigateToEditProperty();
                    break;
                }
              },
              itemBuilder: (_) {
                final items = <PopupMenuItem<String>>[];
                
                if (_canEditProperty()) {
                  items.add(
                    PopupMenuItem(
                      value: 'edit_property',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Modifier la propriété'),
                        ],
                      ),
                    ),
                  );
                }
                
                items.addAll([
                  PopupMenuItem(
                    value: 'report_property',
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: AppThemes.getErrorColor(context)),
                        const SizedBox(width: 8),
                        Text(AppTranslations.get('report_property', locale, 'Signaler la propriété')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report_user',
                    child: Row(
                      children: [
                        Icon(Icons.person_off, color: AppThemes.getErrorColor(context)),
                        const SizedBox(width: 8),
                        Text(AppTranslations.get('report_user', locale, 'Signaler l\'utilisateur')),
                      ],
                    ),
                  ),
                ]);
                
                return items;
              },
            );
          },
        ),
      ],
    );
  }
  
  /// Section affichant le prix, la localisation et les badges de statut
  Widget _buildPriceLocationSection(Property property, Locale locale) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Catégorie et ville
          Text(
            '${property.category.name} • ${property.town.name}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          // Prix
          Text(
            '${property.monthlyPrice.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
              (Match m) => '${m[1]} ')} XOF / mois',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          // Adresse
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${property.address}, ${property.town.name}',
                  style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Badges de statut et certification
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Badge de statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(context, property.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(context, property.status),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(property.status),
                      size: 16,
                      color: _getStatusColor(context, property.status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusTranslation(locale, property.status),
                      style: TextStyle(
                        color: _getStatusColor(context, property.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de certification
              if (property.certified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppThemes.getCertifiedColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppThemes.getCertifiedColor(context),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppThemes.getCertifiedColor(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Certifié',
                        style: TextStyle(
                          color: AppThemes.getCertifiedColor(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section des informations principales sous forme de "pills"
  Widget _buildInfoPills(Property property) {
    final pills = [
      _buildInfoPill(Icons.bed, '${property.roomsNb}', 'Chambres'),
      _buildInfoPill(Icons.bathtub, '${property.bathroomsNb}', 'Salles de bain'),
      _buildInfoPill(Icons.living, '${property.livingRoomsNb}', 'Salons'),
      _buildInfoPill(Icons.square_foot, '${property.area}', 'm²'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: pills,
      ),
    );
  }

  /// Widget individuel pour une information sous forme de pill
  Widget _buildInfoPill(IconData icon, String value, String label) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 28),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
      ],
    );
  }

  /// Section de description de la propriété
  Widget _buildDescriptionSection(Property property, Locale locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('description', locale, 'Description'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            property.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  /// Galerie d'images supplémentaires
  Widget _buildImageGallery(Property property) {
    final allImages = [property.mainImage, ...property.otherImages];
    final displayImages = allImages.where((url) => url.isNotEmpty).toList();

    if (displayImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Aucune image supplémentaire',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Galerie',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openImageFullScreen(displayImages, index),
                child: Container(
                  margin: EdgeInsets.only(right: 10, left: index == 0 ? 16 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      displayImages[index],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Section des équipements techniques (eau, électricité)
  Widget _buildUtilitiesSection(Property property, Locale locale) {
    
    /// Retourne la traduction d'une valeur d'équipement
    String _getUtilityValueTranslation(String value) {
      final translations = {
        'not_available': AppTranslations.get('not_available', locale, 'Non disponible'),
        'connected_public_supply': AppTranslations.get('connected_public_supply', locale, 'Réseau public'),
        'stand_alone_system': AppTranslations.get('stand_alone_system', locale, 'Système autonome'),
        'stand_alone_system_with_mains_connection': AppTranslations.get('stand_alone_system_with_mains_connection', locale, 'Système autonome avec connexion réseau'),
      };
      return translations[value] ?? value;
    }

    /// Retourne l'icône appropriée pour un type d'équipement
    IconData _getUtilityIcon(String type, String value) {
      if (type == 'water') {
        switch (value) {
          case 'connected_public_supply': return Icons.water_drop;
          case 'stand_alone_system': return Icons.water;
          case 'stand_alone_system_with_mains_connection': return Icons.water_drop_outlined;
          default: return Icons.water_damage;
        }
      } else {
        switch (value) {
          case 'connected_public_supply': return Icons.bolt;
          case 'stand_alone_system': return Icons.solar_power;
          case 'stand_alone_system_with_mains_connection': return Icons.electrical_services;
          default: return Icons.power_off;
        }
      }
    }

    /// Retourne la couleur appropriée pour un état d'équipement
    Color _getUtilityColor(String value) {
      switch (value) {
        case 'connected_public_supply': return AppThemes.getSuccessColor(context);
        case 'stand_alone_system': return AppThemes.getWarningColor(context);
        case 'stand_alone_system_with_mains_connection': return AppThemes.getInfoColor(context);
        default: return AppThemes.getErrorColor(context);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('utilities', locale, 'viabilisation'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                // Alimentation électrique
                _buildUtilityRow(
                  'electricity',
                  property.electricalConnection,
                  AppTranslations.get('electrical_connection', locale, 'Alimentation électrique'),
                  _getUtilityValueTranslation,
                  _getUtilityIcon,
                  _getUtilityColor,
                ),
                const SizedBox(height: 16),
                // Alimentation en eau
                _buildUtilityRow(
                  'water',
                  property.waterSupply,
                  AppTranslations.get('water_supply', locale, 'Alimentation en eau'),
                  _getUtilityValueTranslation,
                  _getUtilityIcon,
                  _getUtilityColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ligne individuelle pour un équipement technique
  Widget _buildUtilityRow(
    String type,
    String value,
    String label,
    String Function(String) valueTranslator,
    IconData Function(String, String) iconGetter,
    Color Function(String) colorGetter,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorGetter(value).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            iconGetter(type, value),
            color: colorGetter(value),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valueTranslator(value),
                style: TextStyle(
                  color: colorGetter(value),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section de la carte avec localisation
  Widget _buildMapSection(Property property, Locale locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                AppTranslations.get('location', locale, 'Localisation'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => _openFullScreenMap(context, property),
            child: PropertyMapWidget(
              property: property,
              height: 200,
              interactive: false,
            ),
          ),
          if (property.location.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(property.location[0])),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Section des équipements de confort
  Widget _buildFeaturesSection(Property property, Locale locale) {
    final accent = Theme.of(context).colorScheme.secondary;
    final features = <String, bool>{
      AppTranslations.get('internal_kitchen', locale, 'Cuisine interne'): property.hasInternalKitchen,
      AppTranslations.get('external_kitchen', locale, 'Cuisine externe'): property.hasExternalKitchen,
      AppTranslations.get('parking', locale, 'Parking'): property.hasAParking,
      AppTranslations.get('air_conditioning', locale, 'Climatisation'): property.hasAirConditioning,
      AppTranslations.get('security_guards', locale, 'Gardiennage'): property.hasSecurityGuards,
      AppTranslations.get('balcony', locale, 'Balcon'): property.hasBalcony,
    };

    final activeFeatures = features.entries.where((e) => e.value).toList();

    if (activeFeatures.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('features', locale, 'Équipements'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: activeFeatures.map((e) {
              return Chip(
                avatar: Icon(Icons.check_circle, color: Colors.white, size: 18),
                label: Text(e.key, style: const TextStyle(color: Colors.white)),
                backgroundColor: accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Barre de contact en bas de page avec options multiples
  Widget _buildContactBar(Locale locale) {
    final accent = Theme.of(context).colorScheme.secondary;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.1), 
          blurRadius: 10, 
          offset: const Offset(0, -5)
        )],
      ),
      child: _buildContactOptions(locale),
    );
  }

  /// Widget des options de contact avec menu contextuel
  Widget _buildContactOptions(Locale locale) {
    final phoneNumber = _property?.owner?.phone ?? '';
    final ownerName = _property?.owner?.username ?? 'Propriétaire';
    
    // Vérifier si le numéro est disponible
    if (phoneNumber.isEmpty) {
      return SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: null,
          child: Text(
            AppTranslations.get('no_contact', locale, 'Contact non disponible'),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    
    // Affiche le numéro formaté dans le bouton
    final displayedPhone = phoneNumber.length > 15 
        ? '${phoneNumber.substring(0, 12)}...' 
        : phoneNumber;
    
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        onPressed: () => _showContactOptions(context, locale, phoneNumber),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppTranslations.get('contact_owner', locale, 'Contacter'),
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    displayedPhone,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_up, size: 20),
          ],
        ),
      ),
    );
    // Affiche le numéro formaté dans le bouton
    // final displayedPhone = phoneNumber.length > 15 
    //     ? '${phoneNumber.substring(0, 12)}...' 
    //     : phoneNumber;

    // return SizedBox(
    //   height: 60,
    //   child: ElevatedButton(
    //     style: ElevatedButton.styleFrom(
    //       backgroundColor: Theme.of(context).colorScheme.secondary,
    //       foregroundColor: Colors.white,
    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //       elevation: 2,
    //       padding: const EdgeInsets.symmetric(
    //         vertical: 10,  // 10 pixels en haut et en bas
    //         horizontal: 20, // 40 pixels à gauche et à droite
    //       ),
    //     ),
    //     onPressed: () => _showContactOptions(context, locale, phoneNumber),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.center, // Centre horizontalement
    //       crossAxisAlignment: CrossAxisAlignment.center, // Centre verticalement
    //       children: [
    //         Icon(Icons.phone, size: 20),
    //         const SizedBox(width: 8),
    //         Expanded(
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement dans la colonne
    //             crossAxisAlignment: CrossAxisAlignment.center, // Centre horizontalement dans la colonne
    //             children: [
    //               Text(
    //                 AppTranslations.get('contact_owner', locale, 'Contacter'),
    //                 style: const TextStyle(fontSize: 14),
    //               ),
    //               Text(
    //                 displayedPhone,
    //                 style: const TextStyle(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.w300,
    //                 ),
    //                 overflow: TextOverflow.ellipsis,
    //               ),
    //             ],
    //           ),
    //         ),
    //         Icon(Icons.arrow_drop_up, size: 20),
    //       ],
    //     ),
    //   ),
    // );
  }

  /// Bouton flottant d'édition (visible seulement pour les propriétaires/admins)
  Widget _buildEditFloatingButton() {
    if (!_canEditProperty()) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: _navigateToEditProperty,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.edit, size: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
    );
  }

  // ==================================================================
  // BUILD PRINCIPAL
  // ==================================================================
  
  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;

    // État de chargement
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppThemes.getSuccessColor(context)),
              const SizedBox(height: 16),
              Text(AppTranslations.get('loading', locale, 'Chargement...')),
            ],
          ),
        ),
      );
    }

    // État d'erreur
    if (_errorMessage != null || _property == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppTranslations.get('error', locale, 'Erreur'))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppThemes.getErrorColor(context)),
              const SizedBox(height: 16),
              Text(_errorMessage ?? 'Propriété introuvable', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadPropertyDetails,
                child: Text(AppTranslations.get('retry', locale, 'Réessayer')),
              ),
            ],
          ),
        ),
      );
    }

    // État normal - Affichage des détails
    final property = _property!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(property, locale),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildPriceLocationSection(property, locale),
                const Divider(height: 30, thickness: 1),
                _buildInfoPills(property),
                const Divider(height: 30, thickness: 1),
                _buildDescriptionSection(property, locale),
                const SizedBox(height: 30),
                _buildImageGallery(property),
                const SizedBox(height: 30),
                _buildUtilitiesSection(property, locale),
                const SizedBox(height: 30),
                _buildMapSection(property, locale),
                const SizedBox(height: 30),
                _buildFeaturesSection(property, locale),
                const SizedBox(height: 80), // Espace pour la barre de contact
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildContactBar(locale),
      floatingActionButton: _buildEditFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}