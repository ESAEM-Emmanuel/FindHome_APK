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
//     if (property.latitude == null || property.longitude == null) {
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
//             ),
//           ),
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
//           title: const Text('Localisation'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (property.location.isNotEmpty)
//                 Text(
//                   property.location[0],
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               const SizedBox(height: 8),
//               if (property.latitude != null && property.longitude != null)
//                 Text(
//                   'Latitude: ${property.latitude!.toStringAsFixed(6)}\n'
//                   'Longitude: ${property.longitude!.toStringAsFixed(6)}',
//                   style: TextStyle(
//                     color: Theme.of(context).hintColor,
//                     fontSize: 12,
//                   ),
//                 ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Fermer'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// lib/widgets/property_map_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/property_model.dart';

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
    // Vérifier si les coordonnées sont disponibles
    if (!property.hasValidLocation) {
      return _buildNoLocationWidget(context);
    }

    final LatLng propertyLocation = LatLng(
      property.latitude!,
      property.longitude!,
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            center: propertyLocation,
            zoom: 15.0,
            interactiveFlags: interactive 
                ? InteractiveFlag.all 
                : InteractiveFlag.none,
          ),
          children: [
            // Couche de tuiles OpenStreetMap
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.yourapp.immobilier',
            ),
            // Marqueur de la propriété
            MarkerLayer(
              markers: [
                Marker(
                  point: propertyLocation,
                  width: 40,
                  height: 40,
                  builder: (ctx) => GestureDetector(
                    onTap: () {
                      if (interactive) {
                        _showLocationDetails(context, property);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
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
                      ),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour quand il n'y a pas de localisation
  Widget _buildNoLocationWidget(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 40,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Localisation non disponible',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          if (property.location.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                property.location[0],
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  // Afficher les détails de localisation
  void _showLocationDetails(BuildContext context, Property property) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_pin),
              SizedBox(width: 8),
              Text('Localisation'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (property.location.isNotEmpty)
                Column(
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
                ),
              if (property.latitude != null && property.longitude != null)
                Column(
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
                ),
              const SizedBox(height: 16),
              Container(
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
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openInMaps(property);
              },
              child: const Text('Ouvrir dans Maps'),
            ),
          ],
        );
      },
    );
  }

  // Ouvrir dans l'application de cartes par défaut
  void _openInMaps(Property property) {
    if (!property.hasValidLocation) return;

    final String mapsUrl = 'https://www.google.com/maps/search/?api=1&query=${property.latitude},${property.longitude}';
    
    // Vous pouvez utiliser url_launcher pour ouvrir le lien
    // import 'package:url_launcher/url_launcher.dart';
    // launchUrl(Uri.parse(mapsUrl));
    
    debugPrint('Ouvrir dans Maps: $mapsUrl');
  }
}