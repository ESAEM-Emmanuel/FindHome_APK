// // lib/widgets/property_map_widget.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import '../models/property_model.dart';

// class PropertyMapWidget extends StatelessWidget {
//   final Property property;
//   final double height;
//   final bool interactive;

//   const PropertyMapWidget({
//     super.key,
//     required this.property,
//     this.height = 200,
//     this.interactive = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Vérifier si les coordonnées sont disponibles
//     if (!property.hasValidLocation) {
//       return _buildNoLocationWidget(context);
//     }

//     final LatLng propertyLocation = LatLng(
//       property.latitude!,
//       property.longitude!,
//     );

//     return Container(
//       height: height,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: FlutterMap(
//           options: MapOptions(
//             center: propertyLocation,
//             zoom: 15.0,
//             interactiveFlags: interactive 
//                 ? InteractiveFlag.all 
//                 : InteractiveFlag.none,
//           ),
//           children: [
//             // Couche de tuiles OpenStreetMap
//             TileLayer(
//               urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//               userAgentPackageName: 'com.yourapp.immobilier',
//             ),
//             // Marqueur de la propriété
//             MarkerLayer(
//               markers: [
//                 Marker(
//                   point: propertyLocation,
//                   width: 40,
//                   height: 40,
//                   builder: (ctx) => GestureDetector(
//                     onTap: () {
//                       if (interactive) {
//                         _showLocationDetails(context, property);
//                       }
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.secondary,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                         border: Border.all(
//                           color: Colors.white,
//                           width: 2,
//                         ),
//                       ),
//                       child: Icon(
//                         Icons.location_pin,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget pour quand il n'y a pas de localisation
//   Widget _buildNoLocationWidget(BuildContext context) {
//     return Container(
//       height: height,
//       decoration: BoxDecoration(
//         color: Theme.of(context).dividerColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.location_off,
//             size: 40,
//             color: Theme.of(context).hintColor,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Localisation non disponible',
//             style: TextStyle(
//               color: Theme.of(context).hintColor,
//               fontSize: 16,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           if (property.location.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 property.location[0],
//                 style: TextStyle(
//                   color: Theme.of(context).hintColor,
//                   fontSize: 12,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // Afficher les détails de localisation
//   void _showLocationDetails(BuildContext context, Property property) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Row(
//             children: [
//               Icon(Icons.location_pin),
//               SizedBox(width: 8),
//               Text('Localisation'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (property.location.isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Adresse:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       property.location[0],
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                     const SizedBox(height: 12),
//                   ],
//                 ),
//               if (property.latitude != null && property.longitude != null)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Coordonnées GPS:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Latitude: ${property.latitude!.toStringAsFixed(6)}',
//                       style: TextStyle(
//                         color: Theme.of(context).hintColor,
//                         fontSize: 12,
//                       ),
//                     ),
//                     Text(
//                       'Longitude: ${property.longitude!.toStringAsFixed(6)}',
//                       style: TextStyle(
//                         color: Theme.of(context).hintColor,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.info, size: 16, color: Colors.blue),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Utilisez cette localisation pour naviguer vers la propriété',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Fermer'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _openInMaps(property);
//               },
//               child: const Text('Ouvrir dans Maps'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Ouvrir dans l'application de cartes par défaut
//   void _openInMaps(Property property) {
//     if (!property.hasValidLocation) return;

//     final String mapsUrl = 'https://www.google.com/maps/search/?api=1&query=${property.latitude},${property.longitude}';
    
//     // Vous pouvez utiliser url_launcher pour ouvrir le lien
//     // import 'package:url_launcher/url_launcher.dart';
//     // launchUrl(Uri.parse(mapsUrl));
    
//     debugPrint('Ouvrir dans Maps: $mapsUrl');
//   }
// }
// lib/widgets/property_map_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/property_model.dart';

/// Widget affichant la carte de localisation d'une propriété
/// 
/// Affiche une carte interactive avec la position de la propriété
/// et permet d'accéder aux détails de localisation
class PropertyMapWidget extends StatelessWidget {
  final Property property;
  final double height;
  final bool interactive;

  const PropertyMapWidget({
    super.key,
    required this.property,
    this.height = 200,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    // Vérifier si les coordonnées GPS sont disponibles
    if (!property.hasValidLocation) {
      return _buildNoLocationWidget(context);
    }

    return _buildMapWidget(context);
  }

  // ===========================================================================
  // WIDGETS PRINCIPAUX
  // ===========================================================================

  /// Construit le widget de carte avec la localisation de la propriété
  Widget _buildMapWidget(BuildContext context) {
    final LatLng propertyLocation = LatLng(
      property.latitude!,
      property.longitude!,
    );

    return Container(
      height: height,
      decoration: _buildMapContainerDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: _buildMapOptions(propertyLocation),
          children: _buildMapLayers(context, propertyLocation),
        ),
      ),
    );
  }

  /// Construit le widget affiché quand aucune localisation n'est disponible
  Widget _buildNoLocationWidget(BuildContext context) {
    return Container(
      height: height,
      decoration: _buildNoLocationDecoration(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNoLocationIcon(context),
          const SizedBox(height: 8),
          _buildNoLocationText(context),
          if (property.location.isNotEmpty) _buildLocationFallback(context),
        ],
      ),
    );
  }

  // ===========================================================================
  // MÉTHODES DE CONSTRUCTION DES ÉLÉMENTS UI
  // ===========================================================================

  /// Définition du style du conteneur de la carte
  BoxDecoration _buildMapContainerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Définition du style du conteneur sans localisation
  BoxDecoration _buildNoLocationDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).dividerColor,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Configuration des options de la carte FlutterMap
  MapOptions _buildMapOptions(LatLng propertyLocation) {
    return MapOptions(
      center: propertyLocation,
      zoom: 15.0,
      interactiveFlags: interactive 
          ? InteractiveFlag.all 
          : InteractiveFlag.none,
    );
  }

  /// Construction des différentes couches de la carte
  List<Widget> _buildMapLayers(BuildContext context, LatLng propertyLocation) {
    return [
      _buildTileLayer(),
      _buildMarkerLayer(context, propertyLocation),
    ];
  }

  /// Construction de la couche de tuiles OpenStreetMap
  TileLayer _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.yourapp.immobilier',
    );
  }

  /// Construction de la couche de marqueurs
  MarkerLayer _buildMarkerLayer(BuildContext context, LatLng propertyLocation) {
    return MarkerLayer(
      markers: [
        Marker(
          point: propertyLocation,
          width: 40,
          height: 40,
          builder: (ctx) => _buildPropertyMarker(context),
        ),
      ],
    );
  }

  /// Construction du marqueur de propriété
  Widget _buildPropertyMarker(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (interactive) {
          _showLocationDetails(context, property);
        }
      },
      child: Container(
        decoration: _buildMarkerDecoration(context),
        child: Icon(
          Icons.location_pin,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// Style du marqueur de propriété
  BoxDecoration _buildMarkerDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.secondary,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: Colors.white,
        width: 2,
      ),
    );
  }

  /// Icône d'absence de localisation
  Widget _buildNoLocationIcon(BuildContext context) {
    return Icon(
      Icons.location_off,
      size: 40,
      color: Theme.of(context).hintColor,
    );
  }

  /// Texte d'absence de localisation
  Widget _buildNoLocationText(BuildContext context) {
    return Text(
      'Localisation non disponible',
      style: TextStyle(
        color: Theme.of(context).hintColor,
        fontSize: 16,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Affichage de l'adresse textuelle en fallback
  Widget _buildLocationFallback(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        property.location[0],
        style: TextStyle(
          color: Theme.of(context).hintColor,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ===========================================================================
  // MÉTHODES D'INTERACTION
  // ===========================================================================

  /// Affiche les détails de localisation dans une boîte de dialogue
  void _showLocationDetails(BuildContext context, Property property) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _buildDialogTitle(),
          content: _buildDialogContent(context, property),
          actions: _buildDialogActions(context, property),
        );
      },
    );
  }

  /// Construction du titre de la boîte de dialogue
  Widget _buildDialogTitle() {
    return const Row(
      children: [
        Icon(Icons.location_pin),
        SizedBox(width: 8),
        Text('Localisation'),
      ],
    );
  }

  /// Construction du contenu de la boîte de dialogue
  Widget _buildDialogContent(BuildContext context, Property property) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (property.location.isNotEmpty) _buildAddressSection(property),
        if (property.hasValidLocation) _buildCoordinatesSection(context, property),
        const SizedBox(height: 16),
        _buildInfoSection(),
      ],
    );
  }

  /// Section d'adresse dans la boîte de dialogue
  Widget _buildAddressSection(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Adresse:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          property.location[0],
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Section des coordonnées GPS dans la boîte de dialogue
  Widget _buildCoordinatesSection(BuildContext context, Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coordonnées GPS:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Latitude: ${property.latitude!.toStringAsFixed(6)}',
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 12,
          ),
        ),
        Text(
          'Longitude: ${property.longitude!.toStringAsFixed(6)}',
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Section d'information dans la boîte de dialogue
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, size: 16, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Utilisez cette localisation pour naviguer vers la propriété',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construction des actions de la boîte de dialogue
  List<Widget> _buildDialogActions(BuildContext context, Property property) {
    return [
      _buildCloseButton(context),
      _buildOpenMapsButton(context, property),
    ];
  }

  /// Bouton de fermeture de la boîte de dialogue
  Widget _buildCloseButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Fermer'),
    );
  }

  /// Bouton d'ouverture dans l'application de cartes
  Widget _buildOpenMapsButton(BuildContext context, Property property) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        _openInMaps(property);
      },
      child: const Text('Ouvrir dans Maps'),
    );
  }

  // ===========================================================================
  // MÉTHODES DE NAVIGATION
  // ===========================================================================

  /// Ouvre la localisation dans l'application de cartes par défaut
  void _openInMaps(Property property) {
    if (!property.hasValidLocation) return;

    final String mapsUrl = _buildMapsUrl(property);
    
    // TODO: Implémenter l'ouverture avec url_launcher
    // import 'package:url_launcher/url_launcher.dart';
    // await launchUrl(Uri.parse(mapsUrl));
    
    debugPrint('Ouvrir dans Maps: $mapsUrl');
  }

  /// Construit l'URL pour l'application de cartes
  String _buildMapsUrl(Property property) {
    return 'https://www.google.com/maps/search/?api=1&query=${property.latitude},${property.longitude}';
  }
}