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
//       // Réinitialiser le zoom quand on change de page
//       _transformationController.value = Matrix4.identity();
//     });
//   }

//   void _resetZoom() {
//     _transformationController.value = Matrix4.identity();
//   }

//   void _toggleUiVisibility() {
//     setState(() {
//       _isUiVisible = !_isUiVisible;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenSize = mediaQuery.size;
//     final padding = mediaQuery.padding;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         // Prend toute la hauteur et largeur disponible
//         width: screenSize.width,
//         height: screenSize.height,
//         child: Stack(
//           children: [
//             // GestureDetector pour masquer/afficher l'UI en tapant sur l'image
//             GestureDetector(
//               onTap: _toggleUiVisibility,
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: widget.images.length,
//                 onPageChanged: _onPageChanged,
//                 // Utilisation de PageView qui occupe tout l'écran
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context, index) {
//                   return InteractiveViewer(
//                     transformationController: _transformationController,
//                     panEnabled: true,
//                     minScale: 0.5,
//                     maxScale: 4.0,
//                     boundaryMargin: EdgeInsets.all(MediaQuery.of(context).size.width),
//                     child: Container(
//                       width: screenSize.width,
//                       height: screenSize.height,
//                       // Image qui occupe tout l'espace disponible
//                       child: FittedBox(
//                         fit: BoxFit.contain,
//                         child: Image.network(
//                           widget.images[index],
//                           errorBuilder: (context, error, stackTrace) => Container(
//                             color: Colors.black,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.broken_image,
//                                   color: Colors.white,
//                                   size: 60,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   'Image non disponible',
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.8),
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               color: Colors.black,
//                               child: Center(
//                                 child: CircularProgressIndicator(
//                                   value: loadingProgress.expectedTotalBytes != null
//                                       ? loadingProgress.cumulativeBytesLoaded /
//                                           loadingProgress.expectedTotalBytes!
//                                       : null,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // AppBar avec animation de fondu
//             AnimatedOpacity(
//               opacity: _isUiVisible ? 1.0 : 0.0,
//               duration: const Duration(milliseconds: 300),
//               child: Container(
//                 width: screenSize.width,
//                 height: kToolbarHeight + padding.top,
//                 child: AppBar(
//                   backgroundColor: Colors.black.withOpacity(0.5),
//                   elevation: 0,
//                   leading: IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                   title: Text(
//                     widget.propertyTitle,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                   actions: [
//                     IconButton(
//                       icon: const Icon(Icons.zoom_out_map, color: Colors.white),
//                       onPressed: _resetZoom,
//                       tooltip: 'Réinitialiser le zoom',
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 16.0),
//                       child: Center(
//                         child: Text(
//                           '${_currentIndex + 1}/${widget.images.length}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Indicateur de position
//             if (widget.images.length > 1 && _isUiVisible)
//               Positioned(
//                 bottom: 30 + padding.bottom, // Prend en compte la barre de navigation
//                 left: 0,
//                 right: 0,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(widget.images.length, (index) {
//                     return Container(
//                       width: 8,
//                       height: 8,
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: _currentIndex == index
//                             ? Colors.white
//                             : Colors.white.withOpacity(0.5),
//                       ),
//                     );
//                   }),
//                 ),
//               ),

//             // Boutons de navigation
//             if (widget.images.length > 1 && _isUiVisible) ...[
//               // Bouton précédent
//               Positioned(
//                 left: 10,
//                 top: kToolbarHeight + padding.top + 20,
//                 bottom: 80 + padding.bottom,
//                 child: Center(
//                   child: IconButton(
//                     icon: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.5),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
//                     ),
//                     onPressed: _currentIndex > 0
//                         ? () {
//                             _pageController.previousPage(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeInOut,
//                             );
//                           }
//                         : null,
//                   ),
//                 ),
//               ),
              
//               // Bouton suivant
//               Positioned(
//                 right: 10,
//                 top: kToolbarHeight + padding.top + 20,
//                 bottom: 80 + padding.bottom,
//                 child: Center(
//                   child: IconButton(
//                     icon: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.5),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
//                     ),
//                     onPressed: _currentIndex < widget.images.length - 1
//                         ? () {
//                             _pageController.nextPage(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeInOut,
//                             );
//                           }
//                         : null,
//                   ),
//                 ),
//               ),
//             ],

//             // Indicateur de zoom (optionnel)
//             if (_transformationController.value.getMaxScaleOnAxis() != 1.0 && _isUiVisible)
//               Positioned(
//                 top: kToolbarHeight + padding.top + 20,
//                 right: 10,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.7),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     'Zoom: ${_transformationController.value.getMaxScaleOnAxis().toStringAsFixed(1)}x',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/pages/simple_image_viewer_screen.dart
import 'package:flutter/material.dart';

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
  late PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController = TransformationController();
  bool _isUiVisible = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _toggleUiVisibility() {
    setState(() => _isUiVisible = !_isUiVisible);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleUiVisibility,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, index) {
                return InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 80,
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // AppBar cachée / visible
          AnimatedOpacity(
            opacity: _isUiVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: double.infinity,
              height: kToolbarHeight + padding.top,
              child: AppBar(
                backgroundColor: Colors.black.withOpacity(0.5),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  widget.propertyTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out_map, color: Colors.white),
                    onPressed: _resetZoom,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: Text(
                        '${_currentIndex + 1}/${widget.images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Indicateurs de page
          if (widget.images.length > 1 && _isUiVisible)
            Positioned(
              bottom: 30 + padding.bottom,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
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
                }),
              ),
            ),

          // Boutons de navigation
          if (widget.images.length > 1 && _isUiVisible) ...[
            Positioned(
              left: 10,
              top: kToolbarHeight + padding.top + 20,
              bottom: 80 + padding.bottom,
              child: Center(
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                  ),
                  onPressed: _currentIndex > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: kToolbarHeight + padding.top + 20,
              bottom: 80 + padding.bottom,
              child: Center(
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                  ),
                  onPressed: _currentIndex < widget.images.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}