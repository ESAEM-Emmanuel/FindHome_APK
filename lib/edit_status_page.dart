import 'package:flutter/material.dart';
import 'dart:io';
import 'package:signature/signature.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:image/image.dart' as img; // Laisser commenté si non utilisé

// Définition des couleurs pour l'uniformité
const Color primaryBlue = Color.fromARGB(255, 6, 143, 255);
const Color accentOrange = Color.fromARGB(255, 255, 81, 0);

class EditStatusPage extends StatefulWidget {
  final String imagePath;
  final bool isVideo; // ✅ AJOUTÉ : Le paramètre manquant pour gérer les vidéos

  // ✅ CORRECTION : Mise à jour du constructeur pour inclure isVideo
  const EditStatusPage({super.key, required this.imagePath, this.isVideo = false}); 

  @override
  _EditStatusPageState createState() => _EditStatusPageState();
}

class _EditStatusPageState extends State<EditStatusPage> {
  // Contrôleurs
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 8,
    penColor: accentOrange,
  );
  final TextEditingController _textController = TextEditingController();
  
  // États de l'interface
  bool _isDrawingMode = false;
  bool _isEditingText = false;
  
  // État du texte statique (Pour simuler le texte déplacé)
  String _staticText = '';
  Offset _textPosition = const Offset(50, 50);

  // Clé pour capturer le widget
  final GlobalKey _globalKey = GlobalKey();

  @override
  void dispose() {
    _signatureController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Logique de sauvegarde et de partage (PLACEHOLDER)
  Future<void> _saveAndShareStatus() async {
    // Note: Vous utiliserez widget.isVideo pour adapter la logique de capture/partage
    // (ex: si c'est une vidéo, vous ne capturez pas le RepaintBoundary mais partagez le fichier vidéo original).

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Utilisation de widget.isVideo pour le message
        content: Text(widget.isVideo ? 'Vidéo prête à être partagée!' : 'Statut sauvegardé et prêt à être partagé!'), 
        backgroundColor: primaryBlue,
      ),
    );
    // Retourner à l'écran précédent
    Navigator.of(context).pop();
  }

  // --- Widgets de Contrôle ---

  // Barre d'outils supérieure pour les actions
  Widget _buildTopToolbar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5, bottom: 10, left: 10, right: 10),
        color: Colors.black.withOpacity(0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton de retour/Annuler
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
            
            // Outils de modification
            // N'afficher les outils de dessin/texte que si ce n'est PAS une vidéo, ou adapter
            if (!widget.isVideo) 
            Row(
              children: [
                // Bouton Dessin
                IconButton(
                  icon: Icon(Icons.brush, color: _isDrawingMode ? accentOrange : Colors.white, size: 28),
                  onPressed: () {
                    setState(() {
                      _isDrawingMode = !_isDrawingMode;
                      _isEditingText = false;
                    });
                  },
                ),
                
                // Bouton Annuler le Dessin (Undo)
                if (_isDrawingMode)
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.white, size: 28),
                    onPressed: () {
                      _signatureController.undo();
                    },
                  ),

                // Bouton Texte
                IconButton(
                  icon: Icon(Icons.text_fields, color: _isEditingText ? accentOrange : Colors.white, size: 28),
                  onPressed: () {
                    setState(() {
                      _isEditingText = true;
                      _isDrawingMode = false;
                      _textController.text = _staticText;
                    });
                  },
                ),
              ],
            ),
            
            // Bouton Final (Enregistrer/Partager)
            ElevatedButton.icon(
              onPressed: _saveAndShareStatus,
              icon: Icon(widget.isVideo ? Icons.play_arrow : Icons.send, size: 20),
              label: Text(widget.isVideo ? 'Partager Vidéo' : 'Publier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Zone de saisie de texte pleine page
  Widget _buildTextEditor() {
    // ... (inchangé)
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: _textController,
          autofocus: true,
          textAlign: TextAlign.center,
          maxLines: null,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(blurRadius: 2.0, color: Colors.black, offset: Offset(1, 1))
            ],
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Tapez votre texte ici...',
            hintStyle: TextStyle(color: Colors.white54, fontSize: 32),
          ),
          onSubmitted: (text) {
            setState(() {
              _staticText = text;
              _isEditingText = false;
            });
          },
        ),
      ),
    );
  }

  // Texte statique déplaçable (simulé)
  Widget _buildStaticText(BuildContext context) {
    if (_staticText.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: _textPosition.dx,
      top: _textPosition.dy,
      child: GestureDetector(
        // Rendre le texte déplaçable
        onPanUpdate: (details) {
          if (!_isEditingText) {
            setState(() {
              _textPosition += details.delta;
            });
          }
        },
        // Double Tap pour l'édition
        onDoubleTap: () {
            setState(() {
            _isEditingText = true;
            _textController.text = _staticText;
            _isDrawingMode = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            _staticText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: RepaintBoundary(
        key: _globalKey,
        child: Stack(
          children: [
            // 1. Image ou Vidéo de fond
            Positioned.fill(
              child: widget.isVideo 
                ? const Center(child: Text("Lecteur Vidéo Placeholder", style: TextStyle(color: Colors.white)))
                : PhotoView(
                    imageProvider: FileImage(File(widget.imagePath)),
                    disableGestures: _isDrawingMode || _isEditingText,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  ),
            ),
            
            // 2. Calque de Dessin
            if (_isDrawingMode && !widget.isVideo) // Désactiver le dessin sur la vidéo
              Positioned.fill(
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.transparent,
                ),
              ),
              
            // 3. Texte Statique (déplaçable)
            _buildStaticText(context),
            
            // 4. Éditeur de Texte (actif lorsque l'utilisateur tape)
            if (_isEditingText)
              Container(
                color: Colors.black.withOpacity(0.8),
                child: _buildTextEditor(),
              ),

            // 5. Contrôles Supérieurs 
            if (!_isEditingText)
              _buildTopToolbar(),
            
            // 6. Bouton de Confirmation flottant (uniquement en mode édition de texte)
            if (_isEditingText)
              Positioned(
                bottom: 30,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.check),
                  onPressed: () {
                    setState(() {
                      _staticText = _textController.text;
                      _isEditingText = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}