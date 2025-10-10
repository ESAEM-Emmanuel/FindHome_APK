// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Import nécessaire pour 'Locale'
import '../services/property_service.dart';
import '../models/property_model.dart';
import '../providers/settings_provider.dart';
import '../constants/app_translations.dart';

// Constante pour la couleur d'accentuation (pour l'icône de filtre)
const Color accentOrange = Color.fromARGB(255, 255, 81, 0);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // NOTE: Dans une vraie application, le PropertyService devrait être injecté.
  final PropertyService _propertyService = PropertyService();
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // ✅ CORRECTION DU BLOCAGE UI : 
    // Utiliser addPostFrameCallback pour garantir que le premier frame de l'UI 
    // (le CircularProgressIndicator) est dessiné avant de lancer le chargement.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperties();
    });
  }

  // Méthode pour charger les données (simulée)
  Future<void> _loadProperties() async {
    if (!mounted) return;
    
    // On garde setState ici pour réinitialiser les états en cas de rafraîchissement
    setState(() { 
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulation d'un appel API long
      await Future.delayed(const Duration(milliseconds: 700));

      // Simulation de données AVEC TOUS LES CHAMPS REQUIS (y compris 'description' et 'address')
      final List<Property> simulatedData = [
        Property(
          id: '1', 
          title: "Villa Prestige 4 Chambres", 
          description: "Une magnifique villa spacieuse située dans un quartier calme et sécurisé, idéale pour une grande famille.", 
          address: "123 Avenue des Palmiers, Quartier Bonamoussadi", // 🛑 Ajouté
          monthlyPrice: 550000, 
          area: 300, 
          roomsNb: 4, 
          bathroomsNb: 3, 
          certified: true, 
          status: 'free',
          mainImage: 'https://images.unsplash.com/photo-1580587771525-78b9dba38257?fit=crop&w=800', 
          otherImages: [],
          town: Town(id: 'DLA', name: 'Douala'), 
          category: Category(id: 'villa', name: 'Villa')
        ),
        Property(
          id: '2', 
          title: "Appartement Moderne 2 Pcs", 
          description: "Appartement rénové en centre-ville, parfait pour jeunes professionnels ou couple. Proche de toutes commodités.", 
          address: "45 Rue de la Poste, Mvan", // 🛑 Ajouté
          monthlyPrice: 220000, 
          area: 90, 
          roomsNb: 2, 
          bathroomsNb: 1, 
          certified: false, 
          status: 'free',
          mainImage: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?fit=crop&w=800', 
          otherImages: [],
          town: Town(id: 'YDE', name: 'Yaoundé'), 
          category: Category(id: 'apt', name: 'Appartement')
        ),
        Property(
          id: '3', 
          title: "Studio Meublé Confortable", 
          description: "Petit studio meublé avec kitchenette et salle de bain privée, idéal pour étudiant ou première location.", 
          address: "98 Boulevard de la Liberté", // 🛑 Ajouté
          monthlyPrice: 100000, 
          area: 35, 
          roomsNb: 1, 
          bathroomsNb: 1, 
          certified: true, 
          status: 'free',
          mainImage: 'https://images.unsplash.com/photo-1600004907154-19254d33a697?fit=crop&w=800', 
          otherImages: [],
          town: Town(id: 'DLA', name: 'Douala'), 
          category: Category(id: 'studio', name: 'Studio')
        ),
      ];
      
      if (mounted) {
        setState(() {
          _properties = simulatedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('connexion') 
              ? 'Erreur de connexion à l\'API.' 
              : 'Erreur: $e';
          _isLoading = false;
        });
      }
    }
  }

  // --- Widgets de la Page ---

  // 1. Barre de Recherche et Filtres (Moderne)
  Widget _buildSearchAndFilter(BuildContext context, Locale locale) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                // Utilise la traduction et fallback
                hintText: AppTranslations.get('search_placeholder', locale, 'Rechercher un logement...'), 
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onSubmitted: (query) {
                // TODO: Appeler _loadProperties avec le filtre de recherche
              },
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
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
                      color: Theme.of(context).colorScheme.secondary,
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
                    '${property.monthlyPrice.toString()} XOF/Mois',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).primaryColor,
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


  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;

    return RefreshIndicator(
      onRefresh: _loadProperties, // Permet de recharger les données en tirant vers le bas
      child: Column(
        children: [
          // Barre de Recherche et Filtres
          _buildSearchAndFilter(context, locale), 

          // Contenu principal (Liste des Propriétés)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // Affiche le loader pendant le chargement
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!),
                      )
                    : _properties.isEmpty
                        ? Center(
                            child: Text(
                              AppTranslations.get('no_properties', locale, 'Aucune propriété trouvée pour l\'instant.'),
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _properties.length,
                            itemBuilder: (context, index) {
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