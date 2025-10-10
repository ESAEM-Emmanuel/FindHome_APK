// lib/pages/market_page.dart (Mise à Jour)

import 'package:flutter/material.dart';
import 'add_market_page.dart'; 
import '../models/market_model.dart';
import '../models/db_helper.dart';
// 💡 Importation des constantes de couleurs pour les cas où Theme.of(context) n'est pas suffisant
import '../constants/app_themes.dart'; 

// ❌ Suppression des définitions de couleurs dupliquées

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  // Assurez-vous que Market et DBHelper sont correctement définis et importés
  late Future<List<Market>> markets;
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _fetchMarkets();
  }

  void _fetchMarkets() {
    setState(() {
      markets = dbHelper.getMarkets();
    });
  }

  // Modernisation du Dialogue de Détail
  Future<void> showMarketDetailDialog(Market market) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // 💡 Récupération des couleurs du thème dans le builder du dialogue
        final Color primaryColor = Theme.of(context).primaryColor;
        final Color accentColor = Theme.of(context).colorScheme.secondary;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            market.description,
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor), // ✅ Couleur du thème
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ... (Image et autres détails)
                
                // Détails stylisés
                _buildDetailRow(
                  icon: Icons.person_outline,
                  label: "Propriétaire",
                  value: market.owner,
                  iconColor: primaryColor, // ✅ Couleur du thème passée au widget utilitaire
                ),
                // ... autres _buildDetailRow
              ],
            ),
          ),
          actions: <Widget>[
            // Bouton de validation (style Material TextButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Votre marché est en cours de validation..."),
                    backgroundColor: primaryColor, // ✅ Couleur du thème
                  ),
                );
              },
              child: Text("Valider", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)), // ✅ Couleur du thème
            ),
            
            // Bouton Ajouter Calendrier (style ElevatedButton)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Ajouté à votre agenda!"),
                    backgroundColor: accentColor, // ✅ Couleur accent du thème
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month_outlined, size: 20),
              label: const Text("Ajouter à l'agenda"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor, // ✅ Couleur accent du thème
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.end,
        );
      },
    );
  }

  // Widget utilitaire mis à jour pour accepter la couleur de l'icône
  Widget _buildDetailRow({required IconData icon, required String label, required String value, required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24), // ✅ Utilisation de la couleur passée
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialogue de Création (conservé pour la fonctionnalité)
  Future<void> showMarketCreateDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Utilisation de primaryBlue directement de l'import (car Theme.of(context) n'est pas nécessaire ici)
          title: const Text("Ajouter un marché", style: TextStyle(color: primaryBlue)), 
          content: MarketForm(onSave: _fetchMarkets), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Récupération de l'accent Orange via le thème pour le ListTile et le FAB
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    final Color primaryColor = Theme.of(context).primaryColor;


    return Scaffold(
      body: FutureBuilder<List<Market>>(
        future: markets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor)); // ✅ Couleur du thème
          } 
          // ... (Gestion des erreurs et des données vides inchangée)
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ... icônes et textes inchangés
                  SizedBox(height: 10),
                  Text('Aucun marché disponible.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text('Cliquez sur le "+" pour en ajouter un.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          } else {
            // Affichage de la liste modernisée
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8.0, bottom: 80.0), 
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final market = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    // ... (Card styling inchangé)
                    child: ListTile(
                      // ... (Leading et Title inchangés)
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(market.owner, style: const TextStyle(color: Colors.black54)),
                          Text(
                            'Heures : ${market.hours}',
                            style: TextStyle(color: accentColor, fontSize: 12), // ✅ Couleur accent du thème
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () => showMarketDetailDialog(market),
                        icon: Icon(Icons.arrow_forward_ios, size: 18, color: primaryColor), // ✅ Couleur primaire du thème
                      ),
                      onTap: () => showMarketDetailDialog(market),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: showMarketCreateDialog,
        // Le FAB prend déjà sa couleur de accentOrange via Theme.of(context).floatingActionButtonTheme
        // Mais spécifions-la pour être sûr si le thème n'est pas encore totalement appliqué partout.
        backgroundColor: accentOrange, 
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}