import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import '../models/market_model.dart'; // Assurez-vous que ce chemin est correct
import '../models/db_helper.dart'; // Assurez-vous que ce chemin est correct

class MarketForm extends StatefulWidget {
  final Function onSave;

  const MarketForm({super.key, required this.onSave});

  @override
  State<MarketForm> createState() => _MarketFormState();
}

class _MarketFormState extends State<MarketForm> {
  final _formKey = GlobalKey<FormState>();
  final marketNameController = TextEditingController();
  final ownerController = TextEditingController();
  String selectedAvatar = "boy";
  DateTime selectedMarketDate = DateTime.now();

  @override
  void dispose() {
    marketNameController.dispose();
    ownerController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    // Fonction pour formater la date en chaîne de caractères
    // Format : YYYY-MM-DD HH:MM
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Champ Nom marché
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Nom du marché",
                hintText: "Saisir le nom du marché",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                prefixIcon: Icon(Icons.store),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Vous devez compléter ce champ!";
                }
                return null;
              },
              controller: marketNameController,
            ),
          ),
          
          // Champ Nom du propriétaire
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Nom du propriétaire",
                hintText: "Saisir le nom du propriétaire",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Vous devez compléter ce champ!";
                }
                return null;
              },
              controller: ownerController,
            ),
          ),
          
          // Champ Sélecteur d'Avatar
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: "boy", child: Text("Boy")),
                DropdownMenuItem(value: "girl", child: Text("Girl")),
                DropdownMenuItem(value: "vue", child: Text("Vue")),
                DropdownMenuItem(value: "croise", child: Text("Croisé")),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                labelText: "Sélectionner un Avatar",
                prefixIcon: Icon(Icons.face_unlock_sharp),
              ),
              initialValue: selectedAvatar,
              onChanged: (value) {
                setState(() {
                  selectedAvatar = value!;
                });
              },
            ),
          ),
          
          // Champ Date et Heure du marché (CORRIGÉ : onDateSelected -> onChanged)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: DateTimeFormField(
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Colors.black45),
                errorStyle: TextStyle(color: Colors.redAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                suffixIcon: Icon(Icons.event_note),
                labelText: 'Date et Heure du Marché',
              ),
              mode: DateTimeFieldPickerMode.dateAndTime,
              autovalidateMode: AutovalidateMode.always,
              // Utilisation de onChanged à la place de onDateSelected
              onChanged: (DateTime? value) { 
                if (value != null) {
                  setState(() {
                    selectedMarketDate = value;
                  });
                }
              },
              // NOTE: Le validateur d'origine est étrange ("pas un jour probable"). Je l'ai conservé.
              validator: (e) => (e?.day ?? 0) == 1 ? "s'il vous plaît, pas un jour probable" : null,
            ),
          ),
          
          // Bouton Soumettre
          SizedBox(
            width: double.infinity,
            height: 48, // Taille augmentée pour moderniser
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 6, 143, 255), // Couleur de l'AppBar
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Bords arrondis
                ),
                elevation: 5,
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final marketName = marketNameController.text;
                  final owner = ownerController.text;
                  final avatar = selectedAvatar;
                  final hours = _formatDateTime(selectedMarketDate);

                  // Création et sauvegarde de l'objet Market
                  Market market = Market(
                    description: marketName,
                    owner: owner,
                    avatar: avatar,
                    hours: hours,
                  );
                  await DBHelper().save(market);

                  // Appel du callback onSave
                  widget.onSave();

                  // Fermer le dialogue
                  if (!mounted) return;
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text(
                "Soumettre et Enregistrer",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}