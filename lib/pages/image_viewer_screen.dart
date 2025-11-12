// // lib/pages/image_viewer_screen.dart
// import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';

// class ImageViewerScreen extends StatefulWidget {
//   final List<String> images;
//   final int initialIndex;
//   final String propertyTitle;

//   const ImageViewerScreen({
//     super.key,
//     required this.images,
//     required this.initialIndex,
//     required this.propertyTitle,
//   });

//   @override
//   State<ImageViewerScreen> createState() => _ImageViewerScreenState();
// }

// class _ImageViewerScreenState extends State<ImageViewerScreen> {
//   late PageController _pageController;
//   late int _currentIndex;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onPageChanged(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   // Builder pour gérer le chargement et les erreurs d'images
//   PhotoViewGalleryPageOptions _buildImagePage(String imageUrl, int index) {
//     return PhotoViewGalleryPageOptions(
//       imageProvider: NetworkImage(imageUrl),
//       minScale: PhotoViewComputedScale.contained,
//       maxScale: PhotoViewComputedScale.covered * 2,
//       heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
//       errorBuilder: (context, error, stackTrace) => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.broken_image,
//               color: Colors.white,
//               size: 60,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Image non disponible',
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.8),
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//       loadingBuilder: (context, event) => Center(
//         child: Container(
//           width: 50,
//           height: 50,
//           child: CircularProgressIndicator(
//             value: event == null
//                 ? 0
//                 : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black.withOpacity(0.5),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           widget.propertyTitle,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: Center(
//               child: Text(
//                 '${_currentIndex + 1}/${widget.images.length}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Galerie d'images avec zoom
//           PhotoViewGallery.builder(
//             pageController: _pageController,
//             itemCount: widget.images.length,
//             builder: (context, index) {
//               return _buildImagePage(widget.images[index], index);
//             },
//             onPageChanged: _onPageChanged,
//             backgroundDecoration: const BoxDecoration(color: Colors.black),
//           ),

//           // Indicateur de position en bas (seulement si plusieurs images)
//           if (widget.images.length > 1)
//             Positioned(
//               bottom: 30,
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

//           // Boutons de navigation (seulement si plusieurs images)
//           if (widget.images.length > 1) ...[
//             // Bouton précédent
//             Positioned(
//               left: 10,
//               top: 0,
//               bottom: 0,
//               child: Center(
//                 child: IconButton(
//                   icon: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.5),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
//                   ),
//                   onPressed: _currentIndex > 0
//                       ? () {
//                           _pageController.previousPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut,
//                           );
//                         }
//                       : null,
//                 ),
//               ),
//             ),

//             // Bouton suivant
//             Positioned(
//               right: 10,
//               top: 0,
//               bottom: 0,
//               child: Center(
//                 child: IconButton(
//                   icon: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.5),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.chevron_right, color: Colors.white, size: 30),
//                   ),
//                   onPressed: _currentIndex < widget.images.length - 1
//                       ? () {
//                           _pageController.nextPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeInOut,
//                           );
//                         }
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
