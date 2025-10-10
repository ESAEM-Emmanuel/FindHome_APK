// lib/pages/camera_page.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import '../edit_status_page.dart'; // Assurez-vous que ce chemin est correct

// La liste des caméras disponibles est généralement passée depuis main.dart
// Elle est gérée ici dans le constructeur.

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({super.key, required this.cameras});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final Logger _logger = Logger();
  int _selectedCamera = 0; 
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // Initialise la première caméra disponible au démarrage
    _initializeCamera(_selectedCamera);
  }

  @override
  void dispose() {
    // Assurez-vous de disposer du contrôleur lorsque le widget est retiré
    _controller?.dispose();
    super.dispose();
  }
  
  // -----------------------------------------------------------------
  // ✅ LOGIQUE DE LA CAMÉRA (Méthodes de correction précédentes)
  // -----------------------------------------------------------------

  /// Initialise le contrôleur de la caméra pour l'index donné.
  Future<void> _initializeCamera(int cameraIndex) async {
    // 1. Libérer l'ancien contrôleur
    if (_controller != null) {
      await _controller!.dispose();
    }
    
    // Si aucune caméra n'est disponible
    if (widget.cameras.isEmpty) {
      _logger.e("Aucune caméra trouvée.");
      if (mounted) {
        setState(() {
          _controller = null; // S'assurer que le contrôleur est null
        });
      }
      return;
    }

    // 2. Créer et initialiser le nouveau contrôleur
    _controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.medium,
      enableAudio: true,
    );
    _initializeControllerFuture = _controller!.initialize().then((_) {
      // Reconstruire le widget une fois que la caméra est prête
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      _logger.e("Erreur d'initialisation de la caméra: $error");
    });
  }

  /// Bascule entre la caméra avant et arrière.
  void _toggleCamera() {
    if (widget.cameras.length > 1) {
      setState(() {
        _selectedCamera = (_selectedCamera + 1) % widget.cameras.length;
        _initializeCamera(_selectedCamera);
      });
    } else {
      _logger.w("Seule une caméra est disponible.");
    }
  }

  /// Prend une photo et navigue vers la page d'édition.
  Future<void> _takePicture(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _initializeControllerFuture;
      final XFile image = await _controller!.takePicture();
      if (mounted) {
        // ✅ CORRIGÉ : Utilise imagePath: pour correspondre à EditStatusPage
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditStatusPage(imagePath: image.path, isVideo: false),
          ),
        );
      }
    } on CameraException catch (e) {
      _logger.e("Erreur lors de la prise de photo: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.code}')),
        );
      }
    }
  }

  /// Démarre ou arrête l'enregistrement vidéo et navigue vers la page d'édition si arrêté.
  Future<void> _recordVideo(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      // Arrêter l'enregistrement
      try {
        final XFile video = await _controller!.stopVideoRecording();
        setState(() => _isRecording = false);
        
        if (mounted) {
          // ✅ CORRIGÉ : Utilise imagePath: pour correspondre à EditStatusPage
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditStatusPage(imagePath: video.path, isVideo: true),
            ),
          );
        }
      } on CameraException catch (e) {
        _logger.e("Erreur lors de l'arrêt de l'enregistrement: $e");
      }
    } else {
      // Démarrer l'enregistrement
      try {
        await _controller!.startVideoRecording();
        setState(() => _isRecording = true);
      } on CameraException catch (e) {
        _logger.e("Erreur lors du démarrage de l'enregistrement: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.code}')),
          );
        }
      }
    }
  }
  
  // -----------------------------------------------------------------
  // ✅ WIDGETS DE L'INTERFACE UTILISATEUR
  // -----------------------------------------------------------------

  /// Widget utilitaire pour les boutons latéraux.
  Widget _buildSideButton({required IconData icon, required VoidCallback onPressed, required String tooltip, Color color = Colors.white}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializeControllerFuture == null || _controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final Color accentColor = Theme.of(context).colorScheme.secondary;

    // Calcul du ratio pour l'affichage plein écran
    final size = MediaQuery.of(context).size;
    final scale = size.aspectRatio * _controller!.value.aspectRatio;
    final scaleFactor = scale < 1 ? 1 / scale : scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Vue de la Caméra 
          Positioned.fill(
            child: Transform.scale(
              scale: scaleFactor,
              child: Center(
                child: CameraPreview(_controller!),
              ),
            ),
          ),
          
          // 2. Boutons de Contrôle
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bouton pour basculer entre les caméras
                  _buildSideButton(
                    icon: Icons.switch_camera_outlined,
                    onPressed: _toggleCamera,
                    tooltip: 'Basculer caméra',
                  ),
                  
                  // Bouton de Capture PRINCIPALE (Photo/Vidéo)
                  GestureDetector(
                    // Tap court pour la photo
                    onTap: () => _takePicture(context),
                    // Tap long pour la vidéo (démarrer/arrêter si déjà en cours)
                    onLongPress: () => _recordVideo(context), 
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cercle extérieur (pour le contraste)
                        Container(
                          width: 80, 
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Cercle intérieur (couleur accent, ou rouge si enregistrement)
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : accentColor, 
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: _isRecording 
                            ? const Icon(Icons.stop, color: Colors.white, size: 30)
                            : null, 
                        ),
                      ],
                    ),
                  ),

                  // Bouton d'action vidéo explicite (pour l'arrêt rapide)
                   _buildSideButton(
                    // Utilise l'icône enregistrement si en cours, ou caméra vidéo
                    icon: _isRecording ? Icons.stop : Icons.videocam_outlined,
                    onPressed: () => _recordVideo(context),
                    tooltip: _isRecording ? 'Arrêter la vidéo' : 'Démarrer la vidéo',
                    color: _isRecording ? Colors.red : Colors.white,
                  ),
                ],
              ),
            ),
          ),
          
          // 3. Indicateur d'enregistrement REC (en haut)
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "REC",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}