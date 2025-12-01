// // lib/pages/simple_image_viewer_screen.dart
// import 'package:flutter/material.dart';

// class SimpleImageViewerScreen extends StatefulWidget {
//   final List<String> images;
//   final int initialIndex;
//   final String propertyTitle;

//   const SimpleImageViewerScreen({
//     super.key,
//     required this.images,
//     required this.initialIndex,
//     required this.propertyTitle,
//   });

//   @override
//   State<SimpleImageViewerScreen> createState() => _SimpleImageViewerScreenState();
// }

// class _SimpleImageViewerScreenState extends State<SimpleImageViewerScreen> {
//   late PageController _pageController;
//   late int _currentIndex;
//   final TransformationController _transformationController = TransformationController();
//   bool _isUiVisible = true;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _transformationController.dispose();
//     super.dispose();
//   }

//   void _onPageChanged(int index) {
//     setState(() {
//       _currentIndex = index;
//       _transformationController.value = Matrix4.identity();
//     });
//   }

//   void _resetZoom() {
//     _transformationController.value = Matrix4.identity();
//   }

//   void _toggleUiVisibility() {
//     setState(() => _isUiVisible = !_isUiVisible);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final padding = mediaQuery.padding;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           GestureDetector(
//             onTap: _toggleUiVisibility,
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: widget.images.length,
//               onPageChanged: _onPageChanged,
//               itemBuilder: (_, index) {
//                 return InteractiveViewer(
//                   transformationController: _transformationController,
//                   minScale: 0.5,
//                   maxScale: 4.0,
//                   child: Center(
//                     child: Image.network(
//                       widget.images[index],
//                       fit: BoxFit.contain,
//                       errorBuilder: (_, __, ___) => const Icon(
//                         Icons.broken_image,
//                         color: Colors.white,
//                         size: 80,
//                       ),
//                       loadingBuilder: (_, child, progress) {
//                         if (progress == null) return child;
//                         return const Center(
//                           child: CircularProgressIndicator(color: Colors.white),
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // AppBar cachée / visible
//           AnimatedOpacity(
//             opacity: _isUiVisible ? 1.0 : 0.0,
//             duration: const Duration(milliseconds: 300),
//             child: Container(
//               width: double.infinity,
//               height: kToolbarHeight + padding.top,
//               child: AppBar(
//                 backgroundColor: Colors.black.withOpacity(0.5),
//                 elevation: 0,
//                 leading: IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//                 title: Text(
//                   widget.propertyTitle,
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.zoom_out_map, color: Colors.white),
//                     onPressed: _resetZoom,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(right: 16.0),
//                     child: Center(
//                       child: Text(
//                         '${_currentIndex + 1}/${widget.images.length}',
//                         style: const TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Indicateurs de page
//           if (widget.images.length > 1 && _isUiVisible)
//             Positioned(
//               bottom: 30 + padding.bottom,
//               left: 0,
//               right: 0,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(widget.images.length, (index) {
//                   return Container(
//                     width: 8,
//                     height: 8,
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: _currentIndex == index
//                           ? Colors.white
//                           : Colors.white.withOpacity(0.5),
//                     ),
//                   );
//                 }),
//               ),
//             ),

//           // Boutons de navigation
//           if (widget.images.length > 1 && _isUiVisible) ...[
//             Positioned(
//               left: 10,
//               top: kToolbarHeight + padding.top + 20,
//               bottom: 80 + padding.bottom,
//               child: Center(
//                 child: IconButton(
//                   icon: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.5),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
//                   ),
//                   onPressed: _currentIndex > 0
//                       ? () => _pageController.previousPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut,
//                           )
//                       : null,
//                 ),
//               ),
//             ),
//             Positioned(
//               right: 10,
//               top: kToolbarHeight + padding.top + 20,
//               bottom: 80 + padding.bottom,
//               child: Center(
//                 child: IconButton(
//                   icon: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.5),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
//                   ),
//                   onPressed: _currentIndex < widget.images.length - 1
//                       ? () => _pageController.nextPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut,
//                           )
//                       : null,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// lib/pages/simple_image_viewer_screen.dart
import 'package:flutter/material.dart';

/// Écran de visualisation d'images avec fonctionnalités de zoom, navigation et masquage de l'UI
class SimpleImageViewerScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String propertyTitle;

  const SimpleImageViewerScreen({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.propertyTitle,
  });

  @override
  State<SimpleImageViewerScreen> createState() => _SimpleImageViewerScreenState();
}

class _SimpleImageViewerScreenState extends State<SimpleImageViewerScreen> {
  // === CONTROLLERS ===
  late PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController = TransformationController();
  
  // === ÉTATS DE L'UI ===
  bool _isUiVisible = true;

  @override
  void initState() {
    super.initState();
    _initializeViewer();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// Initialise le viewer avec l'index de départ et les controllers
  void _initializeViewer() {
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  /// Nettoie les ressources pour éviter les fuites de mémoire
  void _cleanupResources() {
    _pageController.dispose();
    _transformationController.dispose();
  }

  /// Gère le changement de page
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      // Réinitialise le zoom lors du changement d'image
      _transformationController.value = Matrix4.identity();
    });
  }

  /// Réinitialise le zoom à l'échelle originale
  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  /// Alterne la visibilité de l'interface utilisateur
  void _toggleUiVisibility() {
    setState(() => _isUiVisible = !_isUiVisible);
  }

  /// Navigue vers l'image précédente
  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Navigue vers l'image suivante
  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zone principale de visualisation des images
          _buildImageViewer(),
          
          // AppBar avec contrôles
          _buildAppBar(padding),
          
          // Indicateurs de pagination (seulement si plusieurs images)
          if (widget.images.length > 1 && _isUiVisible)
            _buildPageIndicators(padding),
          
          // Boutons de navigation latéraux (seulement si plusieurs images)
          if (widget.images.length > 1 && _isUiVisible) ...[
            _buildPreviousButton(padding),
            _buildNextButton(padding),
          ],
        ],
      ),
    );
  }

  /// Construit le viewer d'images principal avec gesture detection
  Widget _buildImageViewer() {
    return GestureDetector(
      onTap: _toggleUiVisibility,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (_, index) => _buildInteractiveImage(index),
      ),
    );
  }

  /// Construit une image interactive avec zoom et gestion d'erreur
  Widget _buildInteractiveImage(int index) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          widget.images[index],
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildErrorWidget(),
          loadingBuilder: (_, child, progress) => _buildLoadingWidget(child, progress),
        ),
      ),
    );
  }

  /// Construit le widget d'erreur quand une image ne peut pas être chargée
  Widget _buildErrorWidget() {
    return const Icon(
      Icons.broken_image,
      color: Colors.white,
      size: 80,
    );
  }

  /// Construit le widget de chargement avec indicateur de progression
  Widget _buildLoadingWidget(Widget child, ImageChunkEvent? progress) {
    if (progress == null) return child;
    
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  /// Construit l'AppBar animée avec les contrôles
  Widget _buildAppBar(EdgeInsets padding) {
    return AnimatedOpacity(
      opacity: _isUiVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        height: kToolbarHeight + padding.top,
        child: AppBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          leading: _buildCloseButton(),
          title: _buildTitle(),
          actions: _buildAppBarActions(),
        ),
      ),
    );
  }

  /// Construit le bouton de fermeture
  Widget _buildCloseButton() {
    return IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  /// Construit le titre de la propriété
  Widget _buildTitle() {
    return Text(
      widget.propertyTitle,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  /// Construit les actions de l'AppBar (reset zoom + compteur)
  List<Widget> _buildAppBarActions() {
    return [
      // Bouton de réinitialisation du zoom
      IconButton(
        icon: const Icon(Icons.zoom_out_map, color: Colors.white),
        onPressed: _resetZoom,
      ),
      
      // Compteur d'images (current/total)
      Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Center(
          child: Text(
            '${_currentIndex + 1}/${widget.images.length}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    ];
  }

  /// Construit les indicateurs de page (points en bas de l'écran)
  Widget _buildPageIndicators(EdgeInsets padding) {
    return Positioned(
      bottom: 30 + padding.bottom,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.images.length, (index) => _buildPageIndicator(index)),
      ),
    );
  }

  /// Construit un indicateur de page individuel
  Widget _buildPageIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentIndex == index
            ? Colors.white
            : Colors.white.withOpacity(0.5),
      ),
    );
  }

  /// Construit le bouton de navigation vers l'image précédente
  Widget _buildPreviousButton(EdgeInsets padding) {
    return Positioned(
      left: 10,
      top: kToolbarHeight + padding.top + 20,
      bottom: 80 + padding.bottom,
      child: Center(
        child: IconButton(
          icon: _buildNavigationButtonIcon(Icons.chevron_left),
          onPressed: _currentIndex > 0 ? _goToPreviousPage : null,
        ),
      ),
    );
  }

  /// Construit le bouton de navigation vers l'image suivante
  Widget _buildNextButton(EdgeInsets padding) {
    return Positioned(
      right: 10,
      top: kToolbarHeight + padding.top + 20,
      bottom: 80 + padding.bottom,
      child: Center(
        child: IconButton(
          icon: _buildNavigationButtonIcon(Icons.chevron_right),
          onPressed: _currentIndex < widget.images.length - 1 ? _goToNextPage : null,
        ),
      ),
    );
  }

  /// Construit l'icône stylisée pour les boutons de navigation
  Widget _buildNavigationButtonIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }
}