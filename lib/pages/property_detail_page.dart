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
// import 'edit_property_page.dart'; // Importez votre page d'édition

// class PropertyDetailPage extends StatefulWidget {
//   final String propertyId;
//   const PropertyDetailPage({super.key, required this.propertyId});

//   @override
//   State<PropertyDetailPage> createState() => _PropertyDetailPageState();
// }

// class _PropertyDetailPageState extends State<PropertyDetailPage> {
//   final PropertyService _propertyService = PropertyService();
//   final TextEditingController _reportController = TextEditingController();
//   Property? _property;
//   bool _isLoading = true;
//   String? _errorMessage;
//   bool _isFavorite = false;
//   bool _isReporting = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadPropertyDetails();
//   }

//   Future<void> _loadPropertyDetails() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final accessToken = authProvider.accessToken;

//     try {
//       final loadedProperty = await _propertyService.getPropertyDetail(widget.propertyId);
//       bool isCurrentlyFavorite = false;
//       if (accessToken != null) {
//         try {
//           isCurrentlyFavorite = await _propertyService.isPropertyFavorite(
//             widget.propertyId,
//             accessToken,
//           );
//         } catch (e) {
//           debugPrint("Erreur lors de la vérification du statut favori: $e");
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _property = loadedProperty;
//           _isFavorite = isCurrentlyFavorite;
//           _isLoading = false;
//           _errorMessage = null;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = "Impossible de charger les détails. Cause: $e";
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // === NOUVELLE MÉTHODE : Vérifier les permissions de modification ===
//   bool _canEditProperty() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final currentUser = authProvider.currentUser;
    
//     if (currentUser == null || _property == null) {
//       return false;
//     }

//     // Vérifier si l'utilisateur est le propriétaire
//     final isOwner = currentUser.id == _property!.ownerId;
    
//     // Vérifier si l'utilisateur est admin
//     final isAdmin = currentUser.role == 'admin';
    
//     // Vérifier si l'utilisateur est staff
//     final isStaff = currentUser.isStaff == true;

//     return isOwner || isAdmin || isStaff;
//   }

//   // === NOUVELLE MÉTHODE : Navigation vers la page d'édition ===
//   void _navigateToEditProperty() {
//     if (_property == null) return;

//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => EditPropertyPage(property: _property!),
//       ),
//     ).then((_) {
//       // Recharger les détails après modification
//       _loadPropertyDetails();
//     });
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
//         return Theme.of(context).hintColor;
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

//   void _openFullScreenMap(BuildContext context, Property property) {
//     if (!property.hasValidLocation) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppTranslations.get('location_unavailable', Provider.of<SettingsProvider>(context).locale, 'Localisation non disponible')),
//           backgroundColor: AppThemes.getWarningColor(context),
//         ),
//       );
//       return;
//     }

//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => Scaffold(
//           appBar: AppBar(
//             title: Text(AppTranslations.get('location', Provider.of<SettingsProvider>(context).locale, 'Localisation')),
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

//   Future<void> _handleFavoriteToggle(BuildContext context, Locale locale) async {
//     if (_property == null) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final accessToken = authProvider.accessToken;

//     if (accessToken == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppTranslations.get('login_required', locale, 'Veuillez vous connecter pour ajouter aux favoris.')),
//           backgroundColor: AppThemes.getWarningColor(context),
//         ),
//       );
//       return;
//     }

//     final bool newState = !_isFavorite;
//     setState(() => _isFavorite = newState);

//     try {
//       await _propertyService.toggleFavorite(_property!.id, accessToken);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(_isFavorite
//               ? AppTranslations.get('favorite_added', locale, 'Ajouté aux favoris !')
//               : AppTranslations.get('favorite_removed', locale, 'Retiré des favoris.')),
//           backgroundColor: AppThemes.getSuccessColor(context),
//         ),
//       );
//     } catch (e) {
//       setState(() => _isFavorite = !newState);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppTranslations.get('favorite_error', locale, 'Erreur lors de la modification des favoris')),
//           backgroundColor: AppThemes.getErrorColor(context),
//         ),
//       );
//     }
//   }

//   Future<void> _showReportDialog(BuildContext context, Locale locale, {bool isUserReport = false}) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final accessToken = authProvider.accessToken;

//     if (accessToken == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppTranslations.get('login_required', locale, 'Veuillez vous connecter pour effectuer un signalement.')),
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
//             Text(AppTranslations.get('report_description', locale, 'Veuillez décrire la raison de votre signalement')),
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
//             onPressed: _isReporting ? null : () => _handleReport(context, locale, accessToken, isUserReport: isUserReport),
//             style: ElevatedButton.styleFrom(backgroundColor: AppThemes.getErrorColor(context)),
//             child: _isReporting
//                 ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                 : Text(AppTranslations.get('report', locale, 'Signaler')),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _handleReport(BuildContext context, Locale locale, String accessToken, {bool isUserReport = false}) async {
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
//             content: Text(AppTranslations.get('report_success', locale, 'Signalement envoyé avec succès')),
//             backgroundColor: AppThemes.getSuccessColor(context),
//           ),
//         );
//         _reportController.clear();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(AppTranslations.get('report_error', locale, 'Erreur lors de l\'envoi du signalement')),
//             backgroundColor: AppThemes.getErrorColor(context),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isReporting = false);
//     }
//   }

//   // === NOUVEAU WIDGET : Bouton flottant de modification ===
//   Widget _buildEditFloatingButton() {
//     if (!_canEditProperty()) {
//       return const SizedBox.shrink();
//     }

//     return FloatingActionButton(
//       onPressed: _navigateToEditProperty,
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       foregroundColor: Colors.white,
//       child: const Icon(Icons.edit, size: 24),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 4,
//     );
//   }

//   // ---------- UI MODERNE ----------

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
//           onTap: () => displayImages.isNotEmpty ? _openImageFullScreen(displayImages, 0) : null,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.network(
//                 property.mainImage,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => Container(
//                   color: Colors.grey.shade300,
//                   child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
//                 ),
//               ),
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
//         // Badge de propriétaire/admin (optionnel)
//         if (_canEditProperty())
//           Container(
//             margin: const EdgeInsets.all(8),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.9),
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
//         IconButton(
//           icon: Icon(
//             _isFavorite ? Icons.favorite : Icons.favorite_border,
//             color: _isFavorite ? Colors.red : Colors.white,
//           ),
//           onPressed: () => _handleFavoriteToggle(context, locale),
//         ),
//         PopupMenuButton<String>(
//           icon: const Icon(Icons.more_vert, color: Colors.white),
//           onSelected: (value) {
//             if (value == 'report_property') {
//               _showReportDialog(context, locale, isUserReport: false);
//             } else if (value == 'report_user') {
//               _showReportDialog(context, locale, isUserReport: true);
//             } else if (value == 'edit_property' && _canEditProperty()) {
//               _navigateToEditProperty();
//             }
//           },
//           itemBuilder: (_) {
//             final items = <PopupMenuItem<String>>[];
            
//             // Option d'édition seulement pour ceux qui ont les permissions
//             if (_canEditProperty()) {
//               items.add(
//                 PopupMenuItem(
//                   value: 'edit_property',
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
//                       const SizedBox(width: 8),
//                       Text('Modifier la propriété'),
//                     ],
//                   ),
//                 ),
//               );
//             }
            
//             items.addAll([
//               PopupMenuItem(
//                 value: 'report_property',
//                 child: Row(
//                   children: [
//                     Icon(Icons.flag, color: AppThemes.getErrorColor(context)),
//                     const SizedBox(width: 8),
//                     Text(AppTranslations.get('report_property', locale, 'Signaler la propriété')),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 'report_user',
//                 child: Row(
//                   children: [
//                     Icon(Icons.person_off, color: AppThemes.getErrorColor(context)),
//                     const SizedBox(width: 8),
//                     Text(AppTranslations.get('report_user', locale, 'Signaler l\'utilisateur')),
//                   ],
//                 ),
//               ),
//             ]);
            
//             return items;
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPriceLocationSection(Property property, Locale locale) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '${property.category.name} • ${property.town.name}',
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.secondary,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF / mois',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w900,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           ),
//           const SizedBox(height: 8),
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
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoPills(Property property) {
//     final accent = Theme.of(context).colorScheme.secondary;
//     final pills = [
//       _pill(Icons.bed, '${property.roomsNb}', 'Chambres'),
//       _pill(Icons.bathtub, '${property.bathroomsNb}', 'Salles de bain'),
//       _pill(Icons.living, '${property.livingRoomsNb}', 'Salons'),
//       _pill(Icons.square_foot, '${property.area}', 'm²'),
//     ];

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: pills,
//       ),
//     );
//   }

//   Widget _pill(IconData icon, String value, String label) {
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

//     return SizedBox(
//       height: 120,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: displayImages.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () => _openImageFullScreen(displayImages, index),
//             child: Container(
//               margin: EdgeInsets.only(right: 10, left: index == 0 ? 16 : 0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   displayImages[index],
//                   width: 120,
//                   height: 120,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     width: 120,
//                     height: 120,
//                     color: Colors.grey.shade300,
//                     child: const Icon(Icons.broken_image, color: Colors.grey),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

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
//             children: features.entries.where((e) => e.value).map((e) {
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

//   Widget _buildContactBar(Locale locale) {
//     final accent = Theme.of(context).colorScheme.secondary;
//     return Container(
//       padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
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
//                 content: Text('Action: Contacter le propriétaire'),
//                 backgroundColor: AppThemes.getSuccessColor(context),
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

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;

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
//                 _buildMapSection(property, locale),
//                 const SizedBox(height: 30),
//                 _buildFeaturesSection(property, locale),
//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildContactBar(locale),
//       // NOUVEAU : Bouton flottant de modification
//       floatingActionButton: _buildEditFloatingButton(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }

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

class PropertyDetailPage extends StatefulWidget {
  final String propertyId;
  const PropertyDetailPage({super.key, required this.propertyId});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  final PropertyService _propertyService = PropertyService();
  final TextEditingController _reportController = TextEditingController();
  Property? _property;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;
  bool _isReporting = false;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  Future<void> _loadPropertyDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    try {
      final loadedProperty = await _propertyService.getPropertyDetail(widget.propertyId);
      bool isCurrentlyFavorite = false;
      if (accessToken != null) {
        try {
          isCurrentlyFavorite = await _propertyService.isPropertyFavorite(
            widget.propertyId,
            accessToken,
          );
        } catch (e) {
          debugPrint("Erreur lors de la vérification du statut favori: $e");
        }
      }

      if (mounted) {
        setState(() {
          _property = loadedProperty;
          _isFavorite = isCurrentlyFavorite;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Impossible de charger les détails. Cause: $e";
          _isLoading = false;
        });
      }
    }
  }

  // === MÉTHODE : Vérifier les permissions de modification ===
  bool _canEditProperty() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null || _property == null) {
      return false;
    }

    // Vérifier si l'utilisateur est le propriétaire
    final isOwner = currentUser.id == _property!.ownerId;
    
    // Vérifier si l'utilisateur est admin
    final isAdmin = currentUser.role == 'admin';
    
    // Vérifier si l'utilisateur est staff
    final isStaff = currentUser.isStaff == true;

    return isOwner || isAdmin || isStaff;
  }

  // === MÉTHODE : Navigation vers la page d'édition ===
  void _navigateToEditProperty() {
    if (_property == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditPropertyPage(property: _property!),
      ),
    ).then((_) {
      // Recharger les détails après modification
      _loadPropertyDetails();
    });
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
        return Theme.of(context).hintColor;
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

  void _openFullScreenMap(BuildContext context, Property property) {
    if (!property.hasValidLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get('location_unavailable', Provider.of<SettingsProvider>(context).locale, 'Localisation non disponible')),
          backgroundColor: AppThemes.getWarningColor(context),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(AppTranslations.get('location', Provider.of<SettingsProvider>(context).locale, 'Localisation')),
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

  Future<void> _handleFavoriteToggle(BuildContext context, Locale locale) async {
    if (_property == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get('login_required', locale, 'Veuillez vous connecter pour ajouter aux favoris.')),
          backgroundColor: AppThemes.getWarningColor(context),
        ),
      );
      return;
    }

    final bool newState = !_isFavorite;
    setState(() => _isFavorite = newState);

    try {
      await _propertyService.toggleFavorite(_property!.id, accessToken);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? AppTranslations.get('favorite_added', locale, 'Ajouté aux favoris !')
              : AppTranslations.get('favorite_removed', locale, 'Retiré des favoris.')),
          backgroundColor: AppThemes.getSuccessColor(context),
        ),
      );
    } catch (e) {
      setState(() => _isFavorite = !newState);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get('favorite_error', locale, 'Erreur lors de la modification des favoris')),
          backgroundColor: AppThemes.getErrorColor(context),
        ),
      );
    }
  }

  Future<void> _showReportDialog(BuildContext context, Locale locale, {bool isUserReport = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get('login_required', locale, 'Veuillez vous connecter pour effectuer un signalement.')),
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
            Text(AppTranslations.get('report_description', locale, 'Veuillez décrire la raison de votre signalement')),
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
            onPressed: _isReporting ? null : () => _handleReport(context, locale, accessToken, isUserReport: isUserReport),
            style: ElevatedButton.styleFrom(backgroundColor: AppThemes.getErrorColor(context)),
            child: _isReporting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(AppTranslations.get('report', locale, 'Signaler')),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReport(BuildContext context, Locale locale, String accessToken, {bool isUserReport = false}) async {
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
            content: Text(AppTranslations.get('report_success', locale, 'Signalement envoyé avec succès')),
            backgroundColor: AppThemes.getSuccessColor(context),
          ),
        );
        _reportController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get('report_error', locale, 'Erreur lors de l\'envoi du signalement')),
            backgroundColor: AppThemes.getErrorColor(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isReporting = false);
    }
  }

  // === WIDGET : Bouton flottant de modification ===
  Widget _buildEditFloatingButton() {
    if (!_canEditProperty()) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: _navigateToEditProperty,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.edit, size: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
    );
  }

  // ---------- UI MODERNE ----------

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
          onTap: () => displayImages.isNotEmpty ? _openImageFullScreen(displayImages, 0) : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                property.mainImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // === Badges de statut et certification ===
              Positioned(
                top: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge de statut
                    Container(
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
                          Text(
                            _getStatusTranslation(locale, property.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Badge de certification
                    if (property.certified)
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
                            Text(
                              'Certifié',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Badge de propriétaire/admin
        if (_canEditProperty())
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
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
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: () => _handleFavoriteToggle(context, locale),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'report_property') {
              _showReportDialog(context, locale, isUserReport: false);
            } else if (value == 'report_user') {
              _showReportDialog(context, locale, isUserReport: true);
            } else if (value == 'edit_property' && _canEditProperty()) {
              _navigateToEditProperty();
            }
          },
          itemBuilder: (_) {
            final items = <PopupMenuItem<String>>[];
            
            // Option d'édition seulement pour ceux qui ont les permissions
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
        ),
      ],
    );
  }

  Widget _buildPriceLocationSection(Property property, Locale locale) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${property.category.name} • ${property.town.name}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF / mois',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
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
          // === Section statut et certification ===
          const SizedBox(height: 12),
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

  Widget _buildInfoPills(Property property) {
    final accent = Theme.of(context).colorScheme.secondary;
    final pills = [
      _pill(Icons.bed, '${property.roomsNb}', 'Chambres'),
      _pill(Icons.bathtub, '${property.bathroomsNb}', 'Salles de bain'),
      _pill(Icons.living, '${property.livingRoomsNb}', 'Salons'),
      _pill(Icons.square_foot, '${property.area}', 'm²'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: pills,
      ),
    );
  }

  Widget _pill(IconData icon, String value, String label) {
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

    return SizedBox(
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
    );
  }

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
            children: features.entries.where((e) => e.value).map((e) {
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

  Widget _buildContactBar(Locale locale) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Action: Contacter le propriétaire'),
                backgroundColor: AppThemes.getSuccessColor(context),
              ),
            );
          },
          child: Text(
            AppTranslations.get('contact_owner', locale, 'Contacter le propriétaire'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;

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
                _buildMapSection(property, locale),
                const SizedBox(height: 30),
                _buildFeaturesSection(property, locale),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildContactBar(locale),
      // BOUTON FLOTTANT DE MODIFICATION
      floatingActionButton: _buildEditFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}