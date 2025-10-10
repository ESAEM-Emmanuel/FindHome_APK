// lib/pages/property_detail_page.dart (Révisé)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Import nécessaire pour 'Locale'
import '../models/property_model.dart';
import '../services/property_service.dart';
import '../providers/settings_provider.dart';
import '../constants/app_translations.dart';

class PropertyDetailPage extends StatefulWidget {
  final String propertyId;

  const PropertyDetailPage({super.key, required this.propertyId});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  final PropertyService _propertyService = PropertyService();
  Property? _property;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  // Méthode de chargement des détails de la propriété
  Future<void> _loadPropertyDetails() async {
    if (!mounted) return;
    
    try {
      // Simulation de la requête API et du parsing 
      await Future.delayed(const Duration(milliseconds: 500)); 
      
      if (mounted) {
        setState(() {
          // Placeholder Property (avec description déjà incluse)
          _property = Property(
            id: widget.propertyId,
            title: "Suite Duplex Moderne",
            description: "Magnifique suite duplex située au cœur du quartier des affaires. Idéal pour les professionnels recherchant confort et proximité. Le logement est certifié et dispose de toutes les commodités modernes.",
            address: "23, Rue des Palmiers, Douala",
            monthlyPrice: 250000,
            area: 180,
            roomsNb: 4,
            bathroomsNb: 2,
            mainImage: 'https://images.unsplash.com/photo-1580587771525-78b9dba38257?fit=crop&w=800', // Image de test
            otherImages: [
              'https://images.unsplash.com/photo-1574343168875-1087e504c568?fit=crop&w=400',
              'https://images.unsplash.com/photo-1577717903269-c89163013b1e?fit=crop&w=400'
            ],
            certified: true,
            status: 'free',
            town: Town(id: 'town_id', name: 'Douala'),
            category: Category(id: 'cat_id', name: 'Suite'),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Impossible de charger les détails: $e";
          _isLoading = false;
        });
      }
    }
  }

  // --- Widgets de la Page ---

  // 1. Section des icônes d'info (chambres, bains, superficie)
  Widget _buildInfoPills(BuildContext context, Property property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPillItem(context, Icons.bed, '${property.roomsNb}', 'Chambres'),
          _buildPillItem(context, Icons.bathtub, '${property.bathroomsNb}', 'Salles de bain'),
          _buildPillItem(context, Icons.square_foot, '${property.area} m²', 'Superficie'),
        ],
      ),
    );
  }

  // Widget de pilule individuelle
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

  // 2. Section des équipements
  Widget _buildFeaturesSection(BuildContext context, Locale locale, Property property) {
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    
    final features = {
      'Cuisine Interne': Icons.kitchen, 
      'Parking': Icons.local_parking, 
      'Climatisation': Icons.ac_unit, 
      'Balcon': Icons.balcony,
      'Gardiennage': Icons.security,
    };
    
    bool isFeatureAvailable(String featureName) {
      return featureName != 'Parking' && featureName != 'Balcon';
    }

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
          children: features.entries.map((entry) {
            final isActive = isFeatureAvailable(entry.key);
            return Chip(
              avatar: Icon(
                entry.value,
                color: isActive ? Colors.white : Theme.of(context).hintColor,
                size: 18,
              ),
              label: Text(
                entry.key,
                style: TextStyle(
                  color: isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: isActive ? accentColor : Theme.of(context).cardColor, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isActive ? accentColor : Theme.of(context).dividerColor),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 3. Galerie d'images
  Widget _buildImageGallery(Property property) {
    final allImages = [property.mainImage, ...property.otherImages];
    final displayImages = allImages.take(4).toList();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 10, left: index == 0 ? 16 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                displayImages[index],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Theme.of(context).dividerColor, 
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image, size: 30, color: Theme.of(context).hintColor), 
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppTranslations.get('error', locale, 'Erreur'))),
        body: Center(child: Text(_errorMessage!)),
      );
    }
    
    final property = _property!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Barre d'application flexible (avec image principale)
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                property.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                ),
              ),
              background: Image.network(
                property.mainImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).dividerColor, 
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported, size: 80, color: Theme.of(context).hintColor), 
                ),
              ),
            ),
            actions: [
              // Bouton Favoris
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () { /* TODO: Gérer l'ajout aux favoris */ },
              ),
            ],
          ),
          
          // 2. Contenu principal (scrollable)
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // --- Bloc Prix et Localisation ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prix
                      Text(
                        '${property.monthlyPrice.toString()} XOF/Mois',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).primaryColor, 
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Adresse
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Theme.of(context).hintColor, size: 18), 
                          const SizedBox(width: 5),
                          Text(
                            '${property.address}, ${property.town.name}',
                            style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor), 
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 30, thickness: 1),

                // --- Bloc Caractéristiques Clés ---
                _buildInfoPills(context, property),

                const Divider(height: 30, thickness: 1),

                // --- Bloc Description ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.get('description', locale, 'Description'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        property.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Theme.of(context).textTheme.bodyMedium?.color), 
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- Bloc Galerie ---
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 15),
                  child: Text(
                    AppTranslations.get('gallery', locale, 'Galerie d\'images'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildImageGallery(property),
                
                const SizedBox(height: 30),

                // --- Bloc Équipements ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildFeaturesSection(context, locale, property), 
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
      
      // 3. Bouton flottant (Contact/Action)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
              // TODO: Action de contacter le propriétaire
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Action: Contacter le propriétaire')),
              );
            },
            child: Text(
              AppTranslations.get('contact_owner', locale, 'Contacter le Propriétaire'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}