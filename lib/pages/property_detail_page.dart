// // lib/pages/property_detail_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:ui';
// import '../models/property_model.dart';
// import '../services/property_service.dart';
// import '../providers/settings_provider.dart';
// import '../providers/auth_provider.dart';
// import '../constants/app_translations.dart';
// import '../constants/app_themes.dart';
// import 'simple_image_viewer_screen.dart';
// import '../widgets/property_map_widget.dart'; // NOUVEAU : Import du widget carte

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

//   // === MÉTHODE POUR LA VISIONNEUSE D'IMAGES ===
  
//   void _openImageFullScreen(List<String> images, int initialIndex, BuildContext context) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => SimpleImageViewerScreen(
//           images: images,
//           initialIndex: initialIndex,
//           propertyTitle: _property?.title ?? 'Galerie',
//         ),
//       ),
//     );
//   }

//   // === MÉTHODE POUR LA CARTE EN PLEIN ÉCRAN ===
  
//   void _openFullScreenMap(BuildContext context, Property property) {
//     if (!property.hasValidLocation) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Localisation non disponible'),
//           backgroundColor: AppThemes.getWarningColor(context),
//         ),
//       );
//       return;
//     }

//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(
//             title: Text('Localisation - ${property.title}'),
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
//           content: Text(AppTranslations.get(
//             'login_required', 
//             locale, 
//             'Veuillez vous connecter pour ajouter aux favoris.'
//           )),
//           backgroundColor: AppThemes.getWarningColor(context),
//         ),
//       );
//       return;
//     }
    
//     final bool newState = !_isFavorite;
//     setState(() {
//       _isFavorite = newState;
//     });

//     try {
//       await _propertyService.toggleFavorite(_property!.id, accessToken);
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(_isFavorite 
//             ? AppTranslations.get('favorite_added', locale, 'Ajouté aux favoris !') 
//             : AppTranslations.get('favorite_removed', locale, 'Retiré des favoris.')
//           ),
//           backgroundColor: AppThemes.getSuccessColor(context),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _isFavorite = !newState;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppTranslations.get(
//             'favorite_error', 
//             locale, 
//             'Erreur lors de la modification des favoris'
//           )),
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
//           content: Text(AppTranslations.get(
//             'login_required', 
//             locale, 
//             'Veuillez vous connecter pour effectuer un signalement.'
//           )),
//           backgroundColor: AppThemes.getWarningColor(context),
//         ),
//       );
//       return;
//     }

//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(isUserReport 
//             ? AppTranslations.get('report_user', locale, 'Signaler l\'utilisateur')
//             : AppTranslations.get('report_property', locale, 'Signaler la propriété')
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(AppTranslations.get(
//                 'report_description', 
//                 locale, 
//                 'Veuillez décrire la raison de votre signalement'
//               )),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _reportController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   hintText: AppTranslations.get('report_hint', locale, 'Description...'),
//                   border: const OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(AppTranslations.get('cancel', locale, 'Annuler')),
//             ),
//             ElevatedButton(
//               onPressed: _isReporting ? null : () => _handleReport(
//                 context, 
//                 locale, 
//                 accessToken, 
//                 isUserReport: isUserReport
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppThemes.getErrorColor(context),
//               ),
//               child: _isReporting 
//                 ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : Text(AppTranslations.get('report', locale, 'Signaler')),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _handleReport(BuildContext context, Locale locale, String accessToken, {bool isUserReport = false}) async {
//     if (_property == null || _reportController.text.isEmpty) return;

//     setState(() {
//       _isReporting = true;
//     });

//     try {
//       if (isUserReport) {
//         if (_property!.ownerId.isEmpty) {
//           throw Exception('Impossible de signaler l\'utilisateur: ID du propriétaire non disponible');
//         }
        
//         await _propertyService.reportUser(
//           _property!.ownerId,
//           _reportController.text,
//           accessToken,
//         );
//       } else {
//         await _propertyService.reportProperty(
//           _property!.id,
//           _reportController.text,
//           accessToken,
//         );
//       }

//       if (mounted) {
//         Navigator.of(context).pop();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(AppTranslations.get(
//               'report_success', 
//               locale, 
//               'Signalement envoyé avec succès'
//             )),
//             backgroundColor: AppThemes.getSuccessColor(context),
//           ),
//         );
//         _reportController.clear();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(AppTranslations.get(
//               'report_error', 
//               locale, 
//               'Erreur lors de l\'envoi du signalement: ${e.toString()}'
//             )),
//             backgroundColor: AppThemes.getErrorColor(context),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isReporting = false;
//         });
//       }
//     }
//   }

//   // === MÉTHODES POUR L'UI ===

//   Widget _buildPillItem(BuildContext context, IconData icon, String value, String label) {
//     final Color accentColor = Theme.of(context).colorScheme.secondary;
    
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: accentColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: accentColor, size: 28),
//         ),
//         const SizedBox(height: 8),
//         Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
//       ],
//     );
//   }

//   Widget _buildInfoPills(BuildContext context, Property property) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildPillItem(context, Icons.bed, '${property.roomsNb}', 'Chambres'),
//           _buildPillItem(context, Icons.bathtub, '${property.bathroomsNb}', 'Salles de bain'),
//           _buildPillItem(context, Icons.living, '${property.livingRoomsNb}', 'Salons'),
//           _buildPillItem(context, Icons.square_foot, '${property.area} m²', 'Superficie'),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeaturesSection(BuildContext context, Locale locale, Property property) {
//     final Color accentColor = Theme.of(context).colorScheme.secondary;
    
//     final features = <String, bool>{
//       AppTranslations.get('internal_kitchen', locale, 'Cuisine Interne'): property.hasInternalKitchen,
//       AppTranslations.get('external_kitchen', locale, 'Cuisine Externe'): property.hasExternalKitchen,
//       AppTranslations.get('parking', locale, 'Parking'): property.hasAParking,
//       AppTranslations.get('air_conditioning', locale, 'Climatisation'): property.hasAirConditioning,
//       AppTranslations.get('security_guards', locale, 'Gardiennage'): property.hasSecurityGuards,
//       AppTranslations.get('balcony', locale, 'Balcon'): property.hasBalcony,
//     };
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           AppTranslations.get('features', locale, 'Équipements'),
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         const SizedBox(height: 15),
//         Wrap(
//           spacing: 10,
//           runSpacing: 10,
//           children: features.entries.where((entry) => entry.value).map((entry) {
//             IconData icon;
//             if (entry.key.contains('Cuisine Interne')) {
//               icon = Icons.kitchen;
//             } else if (entry.key.contains('Parking')) {
//               icon = Icons.local_parking;
//             } else if (entry.key.contains('Climatisation')) {
//               icon = Icons.ac_unit;
//             } else if (entry.key.contains('Balcon')) {
//               icon = Icons.balcony;
//             } else if (entry.key.contains('Gardiennage') || entry.key.contains('Security')) {
//               icon = Icons.security;
//             } else {
//               icon = Icons.check_circle;
//             }

//             return Chip(
//               avatar: Icon(icon, color: Colors.white, size: 18),
//               label: Text(
//                 entry.key,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               backgroundColor: accentColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 side: BorderSide.none,
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageGallery(Property property) {
//     final allImages = [property.mainImage, ...property.otherImages];
//     final displayImages = allImages.where((url) => url.isNotEmpty).toList();

//     if (displayImages.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Text(
//           AppTranslations.get('no_images', Provider.of<SettingsProvider>(context).locale, 'Aucune image disponible'),
//           style: TextStyle(
//             color: Theme.of(context).hintColor,
//             fontStyle: FontStyle.italic,
//           ),
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
//             onTap: () {
//               _openImageFullScreen(displayImages, index, context);
//             },
//             child: Container(
//               margin: EdgeInsets.only(
//                 right: 10,
//                 left: index == 0 ? 16 : 0,
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Stack(
//                   children: [
//                     Image.network(
//                       displayImages[index],
//                       width: 120,
//                       height: 120,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(
//                         width: 120,
//                         height: 120,
//                         color: Theme.of(context).dividerColor,
//                         alignment: Alignment.center,
//                         child: Icon(
//                           Icons.broken_image,
//                           size: 40,
//                           color: Theme.of(context).hintColor,
//                         ),
//                       ),
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Container(
//                           width: 120,
//                           height: 120,
//                           color: Theme.of(context).dividerColor,
//                           alignment: Alignment.center,
//                           child: CircularProgressIndicator(
//                             value: loadingProgress.expectedTotalBytes != null
//                                 ? loadingProgress.cumulativeBytesLoaded /
//                                     loadingProgress.expectedTotalBytes!
//                                 : null,
//                           ),
//                         );
//                       },
//                     ),
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(
//                           Icons.zoom_in,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // NOUVEAU : Section carte
//   Widget _buildMapSection(BuildContext context, Locale locale, Property property) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.map,
//                 color: Theme.of(context).colorScheme.secondary,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 AppTranslations.get('location', locale, 'Localisation'),
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
          
//           // Widget carte cliquable pour plein écran
//           GestureDetector(
//             onTap: () => _openFullScreenMap(context, property),
//             child: PropertyMapWidget(
//               property: property,
//               height: 200,
//               interactive: false,
//             ),
//           ),
          
//           // Adresse détaillée
//           if (property.location.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: Theme.of(context).dividerColor,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.location_on,
//                     color: Theme.of(context).colorScheme.secondary,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       property.location[0],
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar(Property property, Color accentColor, Locale locale) {
//     return SliverAppBar(
//       expandedHeight: 300.0,
//       pinned: true,
//       title: Row(
//         children: [
//           Expanded(
//             child: Text(
//               property.title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           if (property.certified)
//             Container(
//               margin: const EdgeInsets.only(left: 8),
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: AppThemes.getCertifiedColor(context).withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.verified,
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     AppTranslations.get('certified', locale, 'Certifié'),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//       flexibleSpace: GestureDetector(
//         onTap: () {
//           final allImages = [property.mainImage, ...property.otherImages];
//           final displayImages = allImages.where((url) => url.isNotEmpty).toList();
//           if (displayImages.isNotEmpty) {
//             _openImageFullScreen(displayImages, 0, context);
//           }
//         },
//         child: Container(
//           width: double.infinity,
//           height: double.infinity,
//           child: Image.network(
//             property.mainImage,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) => Container(
//               color: Theme.of(context).dividerColor,
//               alignment: Alignment.center,
//               child: Icon(
//                 Icons.image_not_supported,
//                 size: 80,
//                 color: Theme.of(context).hintColor,
//               ),
//             ),
//           ),
//         ),
//       ),
//       actions: [
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
//             }
//           },
//           itemBuilder: (BuildContext context) => [
//             PopupMenuItem(
//               value: 'report_property',
//               child: Text(AppTranslations.get('report_property', locale, 'Signaler la propriété')),
//             ),
//             PopupMenuItem(
//               value: 'report_user',
//               child: Text(AppTranslations.get('report_user', locale, 'Signaler l\'utilisateur')),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildPriceLocationSection(BuildContext context, Property property) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Réf: ${property.refNumber}',
//             style: TextStyle(
//               color: Theme.of(context).hintColor,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/Mois',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w900,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(
//                 Icons.location_on,
//                 color: Theme.of(context).hintColor,
//                 size: 18,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   '${property.address}, ${property.town.name}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Theme.of(context).hintColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDescriptionSection(BuildContext context, Locale locale, Property property) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               height: 1.6,
//               color: Theme.of(context).textTheme.bodyMedium?.color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContactBar(BuildContext context, Locale locale, Color accentColor) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SizedBox(
//         height: 50,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: accentColor,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           onPressed: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Action: Contacter le propriétaire via WhatsApp/Appel'),
//                 backgroundColor: AppThemes.getSuccessColor(context),
//               ),
//             );
//           },
//           child: Text(
//             AppTranslations.get('contact_owner', locale, 'Contacter le Propriétaire'),
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
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
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   AppThemes.getSuccessColor(context),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 AppTranslations.get('loading', locale, 'Chargement...'),
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_errorMessage != null || _property == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(AppTranslations.get('error', locale, 'Erreur')),
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   size: 64,
//                   color: AppThemes.getErrorColor(context),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   AppTranslations.get('error_loading', locale, 'Erreur de chargement'),
//                   style: Theme.of(context).textTheme.headlineSmall,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   _errorMessage ?? "Détails non trouvés.",
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _loadPropertyDetails,
//                   child: Text(AppTranslations.get('retry', locale, 'Réessayer')),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
    
//     final property = _property!;
//     final Color accentColor = Theme.of(context).colorScheme.secondary;

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           _buildAppBar(property, accentColor, locale),
          
//           SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 _buildPriceLocationSection(context, property),
                
//                 const Divider(height: 30, thickness: 1),
//                 _buildInfoPills(context, property),
//                 const Divider(height: 30, thickness: 1),

//                 _buildDescriptionSection(context, locale, property),
//                 const SizedBox(height: 30),

//                 Padding(
//                   padding: const EdgeInsets.only(left: 16.0, bottom: 15),
//                   child: Text(
//                     AppTranslations.get('gallery', locale, 'Galerie d\'images'),
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ),
//                 _buildImageGallery(property),
                
//                 const SizedBox(height: 30),

//                 // NOUVEAU : Section carte
//                 _buildMapSection(context, locale, property),
                
//                 const SizedBox(height: 30),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: _buildFeaturesSection(context, locale, property),
//                 ),

//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ],
//       ),
      
//       bottomNavigationBar: _buildContactBar(context, locale, accentColor),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/property_model.dart';
import '../services/property_service.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_translations.dart';
import '../constants/app_themes.dart';
import 'simple_image_viewer_screen.dart';
import '../widgets/property_map_widget.dart';

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

  // === MÉTHODES POUR LES TRADUCTIONS DES NOUVEAUX CHAMPS ===

  /// Retourne la traduction pour l'alimentation en eau
  String _getWaterSupplyTranslation(Locale locale, String waterSupply) {
    final translations = {
      'not_available': AppTranslations.get('water_not_available', locale, 'Non disponible'),
      'connected_public_supply': AppTranslations.get('water_public_supply', locale, 'Réseau public'),
      'stand_alone_system': AppTranslations.get('water_stand_alone', locale, 'Système autonome'),
      'stand_alone_system_with_mains_connection': AppTranslations.get('water_hybrid', locale, 'Système hybride'),
    };
    return translations[waterSupply] ?? waterSupply;
  }

  /// Retourne la traduction pour la connexion électrique
  String _getElectricalConnectionTranslation(Locale locale, String electricalConnection) {
    final translations = {
      'not_available': AppTranslations.get('electric_not_available', locale, 'Non disponible'),
      'connected_public_supply': AppTranslations.get('electric_public_supply', locale, 'Réseau public'),
      'stand_alone_system': AppTranslations.get('electric_stand_alone', locale, 'Système autonome'),
      'stand_alone_system_with_mains_connection': AppTranslations.get('electric_hybrid', locale, 'Système hybride'),
    };
    return translations[electricalConnection] ?? electricalConnection;
  }

  /// Retourne la traduction pour le statut
  String _getStatusTranslation(Locale locale, String status) {
    final translations = {
      'free': AppTranslations.get('status_free', locale, 'Libre'),
      'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
      'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
    };
    return translations[status] ?? status;
  }

  /// Retourne la couleur pour le statut
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

  /// Retourne l'icône pour le statut
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

  // === MÉTHODE POUR LA VISIONNEUSE D'IMAGES ===
  
  void _openImageFullScreen(List<String> images, int initialIndex, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SimpleImageViewerScreen(
          images: images,
          initialIndex: initialIndex,
          propertyTitle: _property?.title ?? 'Galerie',
        ),
      ),
    );
  }

  // === MÉTHODE POUR LA CARTE EN PLEIN ÉCRAN ===
  
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
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('${AppTranslations.get('location', Provider.of<SettingsProvider>(context).locale, 'Localisation')} - ${property.title}'),
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
          content: Text(AppTranslations.get(
            'login_required', 
            locale, 
            'Veuillez vous connecter pour ajouter aux favoris.'
          )),
          backgroundColor: AppThemes.getWarningColor(context),
        ),
      );
      return;
    }
    
    final bool newState = !_isFavorite;
    setState(() {
      _isFavorite = newState;
    });

    try {
      await _propertyService.toggleFavorite(_property!.id, accessToken);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite 
            ? AppTranslations.get('favorite_added', locale, 'Ajouté aux favoris !') 
            : AppTranslations.get('favorite_removed', locale, 'Retiré des favoris.')
          ),
          backgroundColor: AppThemes.getSuccessColor(context),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isFavorite = !newState;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get(
            'favorite_error', 
            locale, 
            'Erreur lors de la modification des favoris'
          )),
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
          content: Text(AppTranslations.get(
            'login_required', 
            locale, 
            'Veuillez vous connecter pour effectuer un signalement.'
          )),
          backgroundColor: AppThemes.getWarningColor(context),
        ),
      );
      return;
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isUserReport 
            ? AppTranslations.get('report_user', locale, 'Signaler l\'utilisateur')
            : AppTranslations.get('report_property', locale, 'Signaler la propriété')
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppTranslations.get(
                'report_description', 
                locale, 
                'Veuillez décrire la raison de votre signalement'
              )),
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
              onPressed: _isReporting ? null : () => _handleReport(
                context, 
                locale, 
                accessToken, 
                isUserReport: isUserReport
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.getErrorColor(context),
              ),
              child: _isReporting 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppTranslations.get('report', locale, 'Signaler')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleReport(BuildContext context, Locale locale, String accessToken, {bool isUserReport = false}) async {
    if (_property == null || _reportController.text.isEmpty) return;

    setState(() {
      _isReporting = true;
    });

    try {
      if (isUserReport) {
        if (_property!.ownerId.isEmpty) {
          throw Exception('Impossible de signaler l\'utilisateur: ID du propriétaire non disponible');
        }
        
        await _propertyService.reportUser(
          _property!.ownerId,
          _reportController.text,
          accessToken,
        );
      } else {
        await _propertyService.reportProperty(
          _property!.id,
          _reportController.text,
          accessToken,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get(
              'report_success', 
              locale, 
              'Signalement envoyé avec succès'
            )),
            backgroundColor: AppThemes.getSuccessColor(context),
          ),
        );
        _reportController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get(
              'report_error', 
              locale, 
              'Erreur lors de l\'envoi du signalement: ${e.toString()}'
            )),
            backgroundColor: AppThemes.getErrorColor(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReporting = false;
        });
      }
    }
  }

  // === MÉTHODES POUR L'UI ===

  Widget _buildPillItem(BuildContext context, IconData icon, String value, String label) {
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoPills(BuildContext context, Property property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPillItem(context, Icons.bed, '${property.roomsNb}', 'Chambres'),
          _buildPillItem(context, Icons.bathtub, '${property.bathroomsNb}', 'Salles de bain'),
          _buildPillItem(context, Icons.living, '${property.livingRoomsNb}', 'Salons'),
          _buildPillItem(context, Icons.square_foot, '${property.area} m²', 'Superficie'),
        ],
      ),
    );
  }

  // === NOUVELLE SECTION : SERVICES ET ÉTAT ===
  
  Widget _buildServicesAndStatusSection(BuildContext context, Locale locale, Property property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('services_status', locale, 'Services et État'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 15),
          
          // Carte avec les informations de services
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Statut de la propriété
                  _buildServiceItem(
                    context,
                    _getStatusIcon(property.status),
                    _getStatusTranslation(locale, property.status),
                    _getStatusColor(context, property.status),
                    AppTranslations.get('status', locale, 'Statut'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Alimentation en eau
                  _buildServiceItem(
                    context,
                    Icons.water_drop,
                    _getWaterSupplyTranslation(locale, property.waterSupply),
                    Theme.of(context).colorScheme.secondary,
                    AppTranslations.get('water_supply', locale, 'Alimentation en eau'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Connexion électrique
                  _buildServiceItem(
                    context,
                    Icons.bolt,
                    _getElectricalConnectionTranslation(locale, property.electricalConnection),
                    Theme.of(context).colorScheme.secondary,
                    AppTranslations.get('electrical_connection', locale, 'Connexion électrique'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, IconData icon, String value, Color color, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
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
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, Locale locale, Property property) {
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    
    final features = <String, bool>{
      AppTranslations.get('internal_kitchen', locale, 'Cuisine Interne'): property.hasInternalKitchen,
      AppTranslations.get('external_kitchen', locale, 'Cuisine Externe'): property.hasExternalKitchen,
      AppTranslations.get('parking', locale, 'Parking'): property.hasAParking,
      AppTranslations.get('air_conditioning', locale, 'Climatisation'): property.hasAirConditioning,
      AppTranslations.get('security_guards', locale, 'Gardiennage'): property.hasSecurityGuards,
      AppTranslations.get('balcony', locale, 'Balcon'): property.hasBalcony,
    };
    
    return Column(
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
          children: features.entries.where((entry) => entry.value).map((entry) {
            IconData icon;
            if (entry.key.contains('Cuisine Interne')) {
              icon = Icons.kitchen;
            } else if (entry.key.contains('Parking')) {
              icon = Icons.local_parking;
            } else if (entry.key.contains('Climatisation')) {
              icon = Icons.ac_unit;
            } else if (entry.key.contains('Balcon')) {
              icon = Icons.balcony;
            } else if (entry.key.contains('Gardiennage') || entry.key.contains('Security')) {
              icon = Icons.security;
            } else {
              icon = Icons.check_circle;
            }

            return Chip(
              avatar: Icon(icon, color: Colors.white, size: 18),
              label: Text(
                entry.key,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageGallery(Property property) {
    final allImages = [property.mainImage, ...property.otherImages];
    final displayImages = allImages.where((url) => url.isNotEmpty).toList();

    if (displayImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          AppTranslations.get('no_images', Provider.of<SettingsProvider>(context).locale, 'Aucune image disponible'),
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontStyle: FontStyle.italic,
          ),
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
            onTap: () {
              _openImageFullScreen(displayImages, index, context);
            },
            child: Container(
              margin: EdgeInsets.only(
                right: 10,
                left: index == 0 ? 16 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      displayImages[index],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 120,
                        color: Theme.of(context).dividerColor,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 120,
                          height: 120,
                          color: Theme.of(context).dividerColor,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, Locale locale, Property property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.map,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                AppTranslations.get('location', locale, 'Localisation'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Widget carte cliquable pour plein écran
          GestureDetector(
            onTap: () => _openFullScreenMap(context, property),
            child: PropertyMapWidget(
              property: property,
              height: 200,
              interactive: false,
            ),
          ),
          
          // Adresse détaillée
          if (property.location.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      property.location[0],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppBar(Property property, Color accentColor, Locale locale) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      title: Row(
        children: [
          Expanded(
            child: Text(
              property.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (property.certified)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppThemes.getCertifiedColor(context).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppTranslations.get('certified', locale, 'Certifié'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      flexibleSpace: GestureDetector(
        onTap: () {
          final allImages = [property.mainImage, ...property.otherImages];
          final displayImages = allImages.where((url) => url.isNotEmpty).toList();
          if (displayImages.isNotEmpty) {
            _openImageFullScreen(displayImages, 0, context);
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            property.mainImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Theme.of(context).dividerColor,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_not_supported,
                size: 80,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ),
      ),
      actions: [
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
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'report_property',
              child: Text(AppTranslations.get('report_property', locale, 'Signaler la propriété')),
            ),
            PopupMenuItem(
              value: 'report_user',
              child: Text(AppTranslations.get('report_user', locale, 'Signaler l\'utilisateur')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceLocationSection(BuildContext context, Property property) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Réf: ${property.refNumber}',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${property.monthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF/Mois',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).hintColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${property.address}, ${property.town.name}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Locale locale, Property property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBar(BuildContext context, Locale locale, Color accentColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Action: Contacter le propriétaire via WhatsApp/Appel'),
                backgroundColor: AppThemes.getSuccessColor(context),
              ),
            );
          },
          child: Text(
            AppTranslations.get('contact_owner', locale, 'Contacter le Propriétaire'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppThemes.getSuccessColor(context),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppTranslations.get('loading', locale, 'Chargement...'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null || _property == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppTranslations.get('error', locale, 'Erreur')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppThemes.getErrorColor(context),
                ),
                const SizedBox(height: 16),
                Text(
                  AppTranslations.get('error_loading', locale, 'Erreur de chargement'),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? "Détails non trouvés.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadPropertyDetails,
                  child: Text(AppTranslations.get('retry', locale, 'Réessayer')),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    final property = _property!;
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(property, accentColor, locale),
          
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildPriceLocationSection(context, property),
                
                const Divider(height: 30, thickness: 1),
                _buildInfoPills(context, property),
                const Divider(height: 30, thickness: 1),

                _buildDescriptionSection(context, locale, property),
                const SizedBox(height: 30),

                // NOUVELLE SECTION : Services et État
                _buildServicesAndStatusSection(context, locale, property),
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 15),
                  child: Text(
                    AppTranslations.get('gallery', locale, 'Galerie d\'images'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildImageGallery(property),
                
                const SizedBox(height: 30),

                // Section carte
                _buildMapSection(context, locale, property),
                
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildFeaturesSection(context, locale, property),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: _buildContactBar(context, locale, accentColor),
    );
  }
}