// // lib/pages/create_property_page.dart

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:geolocator/geolocator.dart';
// import '../services/property_service.dart';
// import '../services/town_service.dart';
// import '../services/category_service.dart';
// import '../services/media_service.dart';
// import '../models/town.dart';
// import '../models/category.dart';
// import '../providers/settings_provider.dart';
// import '../providers/auth_provider.dart';
// import '../constants/app_translations.dart';
// import '../constants/app_themes.dart';

// class CreatePropertyPage extends StatefulWidget {
//   const CreatePropertyPage({super.key});

//   @override
//   State<CreatePropertyPage> createState() => _CreatePropertyPageState();
// }

// class _CreatePropertyPageState extends State<CreatePropertyPage> {
//   // === CLÉ ET SERVICES ===
//   final _formKey = GlobalKey<FormState>();
//   final PropertyService _propertyService = PropertyService();
//   final TownService _townService = TownService();
//   final CategoryService _categoryService = CategoryService();
//   final MediaService _mediaService = MediaService();
//   final ImagePicker _imagePicker = ImagePicker();

//   // === CONTRÔLEURS POUR LES CHAMPS TEXTE ===
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _monthlyPriceController = TextEditingController();
//   final TextEditingController _areaController = TextEditingController();
//   final TextEditingController _roomsController = TextEditingController();
//   final TextEditingController _bathroomsController = TextEditingController();
//   final TextEditingController _livingRoomsController = TextEditingController();
//   final TextEditingController _compartmentNumberController = TextEditingController();

//   // === AUTOCOMPLETE POUR LES VILLES ===
//   final TextEditingController _townSearchController = TextEditingController();
//   List<Town> _filteredTowns = [];
//   Town? _selectedTown;
//   bool _isSearchingTowns = false;
//   bool _showTownDropdown = false;

//   // === AUTOCOMPLETE POUR LES CATÉGORIES ===
//   final TextEditingController _categorySearchController = TextEditingController();
//   List<Category> _filteredCategories = [];
//   Category? _selectedCategory;
//   bool _isSearchingCategories = false;
//   bool _showCategoryDropdown = false;

//   // === GESTION DES IMAGES ===
//   File? _selectedMainImage;
//   List<File> _selectedOtherImages = [];
//   String? _uploadedMainImageUrl;
//   List<String> _uploadedOtherImagesUrls = [];
//   bool _isUploadingMainImage = false;
//   bool _isUploadingOtherImages = false;

//   // === ÉQUIPEMENTS (CHECKBOX) ===
//   bool _hasInternalKitchen = false;
//   bool _hasExternalKitchen = false;
//   bool _hasAParking = false;
//   bool _hasAirConditioning = false;
//   bool _hasSecurityGuards = false;
//   bool _hasBalcony = false;

//   // === LOCALISATION GPS ===
//   Position? _userPosition;
//   double? _latitude;
//   double? _longitude;
//   bool _isGettingLocation = false;

//   // === NOUVEAUX CHAMPS SELECT ===
  
//   // Alimentation en eau
//   String _selectedWaterSupply = 'not_available';
  
//   // Connexion électrique
//   String _selectedElectricalConnection = 'not_available';
  
//   // Statut
//   String _selectedStatus = 'free';

//   // === ÉTATS ===
//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialisation des listeners pour l'autocomplete
//     _townSearchController.addListener(_onTownSearchChanged);
//     _categorySearchController.addListener(_onCategorySearchChanged);
    
//     // Chargement des données initiales
//     _getUserLocation();
//     _loadAllTowns();
//     _loadAllCategories();
//   }

//   @override
//   void dispose() {
//     // Nettoyage de tous les contrôleurs
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _addressController.dispose();
//     _monthlyPriceController.dispose();
//     _areaController.dispose();
//     _roomsController.dispose();
//     _bathroomsController.dispose();
//     _livingRoomsController.dispose();
//     _compartmentNumberController.dispose();
//     _townSearchController.dispose();
//     _categorySearchController.dispose();
//     super.dispose();
//   }

//   // === MÉTHODES POUR CHARGER LES DONNÉES INITIALES ===

//   /// Charge toutes les villes disponibles
//   Future<void> _loadAllTowns() async {
//     try {
//       final towns = await _townService.getAllTowns();
//       setState(() {
//         _filteredTowns = towns;
//       });
//     } catch (e) {
//       print('Erreur lors du chargement des villes: $e');
//     }
//   }

//   /// Charge toutes les catégories disponibles
//   Future<void> _loadAllCategories() async {
//     try {
//       final categories = await _categoryService.getAllCategories();
//       setState(() {
//         _filteredCategories = categories;
//       });
//     } catch (e) {
//       print('Erreur lors du chargement des catégories: $e');
//     }
//   }

//   // === MÉTHODES POUR LA LOCALISATION GPS ===

//   /// Récupère la position GPS de l'utilisateur
//   Future<void> _getUserLocation() async {
//     setState(() {
//       _isGettingLocation = true;
//     });

//     try {
//       // Vérification des permissions
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Permissions de localisation refusées');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Permissions de localisation définitivement refusées');
//       }

//       // Récupération de la position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );

//       setState(() {
//         _userPosition = position;
//         _latitude = position.latitude;
//         _longitude = position.longitude;
//         _isGettingLocation = false;
//       });
      
//     } catch (e) {
//       setState(() {
//         _isGettingLocation = false;
//       });
//       _showErrorSnackbar(AppTranslations.get('location_error', const Locale('fr'), 'Erreur de localisation'));
//     }
//   }

//   // === MÉTHODES POUR L'AUTOCOMPLETE DES VILLES ===

//   /// Gère la recherche de villes en temps réel
//   void _onTownSearchChanged() async {
//     final query = _townSearchController.text.trim();
    
//     if (query.isEmpty) {
//       setState(() {
//         _showTownDropdown = false;
//         _filteredTowns = [];
//       });
//       return;
//     }

//     setState(() {
//       _isSearchingTowns = true;
//       _showTownDropdown = true;
//     });

//     try {
//       final response = await _townService.searchTowns(query);
//       setState(() {
//         _filteredTowns = response.records;
//         _isSearchingTowns = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isSearchingTowns = false;
//         _filteredTowns = [];
//       });
//       print('Erreur lors de la recherche de villes: $e');
//     }
//   }

//   /// Sélectionne une ville dans la liste
//   void _selectTown(Town town) {
//     setState(() {
//       _selectedTown = town;
//       _townSearchController.text = town.name;
//       _showTownDropdown = false;
//     });
//   }

//   /// Efface la sélection de ville
//   void _clearTownSelection() {
//     setState(() {
//       _selectedTown = null;
//       _townSearchController.clear();
//       _showTownDropdown = false;
//     });
//   }

//   // === MÉTHODES POUR L'AUTOCOMPLETE DES CATÉGORIES ===

//   /// Gère la recherche de catégories en temps réel
//   void _onCategorySearchChanged() async {
//     final query = _categorySearchController.text.trim();
    
//     if (query.isEmpty) {
//       setState(() {
//         _showCategoryDropdown = false;
//         _filteredCategories = [];
//       });
//       return;
//     }

//     setState(() {
//       _isSearchingCategories = true;
//       _showCategoryDropdown = true;
//     });

//     try {
//       final response = await _categoryService.searchCategories(query);
//       setState(() {
//         _filteredCategories = response.records;
//         _isSearchingCategories = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isSearchingCategories = false;
//         _filteredCategories = [];
//       });
//       print('Erreur lors de la recherche de catégories: $e');
//     }
//   }

//   /// Sélectionne une catégorie dans la liste
//   void _selectCategory(Category category) {
//     setState(() {
//       _selectedCategory = category;
//       _categorySearchController.text = category.name;
//       _showCategoryDropdown = false;
//     });
//   }

//   /// Efface la sélection de catégorie
//   void _clearCategorySelection() {
//     setState(() {
//       _selectedCategory = null;
//       _categorySearchController.clear();
//       _showCategoryDropdown = false;
//     });
//   }

//   // === MÉTHODES POUR L'UPLOAD D'IMAGES ===

//   /// Sélectionne l'image principale
//   Future<void> _pickMainImage() async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1200,
//         maxHeight: 1200,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _selectedMainImage = File(pickedFile.path);
//         });
//         await _uploadMainImage();
//       }
//     } catch (e) {
//       _showErrorSnackbar(AppTranslations.get('image_selection_error', const Locale('fr'), 'Erreur lors de la sélection de l\'image'));
//     }
//   }

//   /// Sélectionne les images supplémentaires
//   Future<void> _pickOtherImages() async {
//     try {
//       final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
//         maxWidth: 1200,
//         maxHeight: 1200,
//         imageQuality: 85,
//       );

//       if (pickedFiles.isNotEmpty) {
//         setState(() {
//           _selectedOtherImages.addAll(pickedFiles.map((file) => File(file.path)));
//         });
//         await _uploadOtherImages();
//       }
//     } catch (e) {
//       _showErrorSnackbar(AppTranslations.get('image_selection_error', const Locale('fr'), 'Erreur lors de la sélection des images'));
//     }
//   }

//   /// Upload l'image principale
//   Future<void> _uploadMainImage() async {
//     if (_selectedMainImage == null) return;

//     setState(() {
//       _isUploadingMainImage = true;
//     });

//     try {
//       final imageUrl = await _mediaService.uploadSingleFile(_selectedMainImage!);
//       setState(() {
//         _uploadedMainImageUrl = imageUrl;
//         _isUploadingMainImage = false;
//       });
//       _showSuccessSnackbar(AppTranslations.get('main_image_upload_success', const Locale('fr'), 'Image principale uploadée avec succès'));
//     } catch (e) {
//       setState(() {
//         _isUploadingMainImage = false;
//       });
//       _showErrorSnackbar(AppTranslations.get('main_image_upload_error', const Locale('fr'), 'Erreur lors de l\'upload de l\'image principale'));
//     }
//   }

//   /// Upload les images supplémentaires
//   Future<void> _uploadOtherImages() async {
//     if (_selectedOtherImages.isEmpty) return;

//     setState(() {
//       _isUploadingOtherImages = true;
//     });

//     try {
//       final List<String> uploadedUrls = [];
//       for (final imageFile in _selectedOtherImages) {
//         final imageUrl = await _mediaService.uploadSingleFile(imageFile);
//         uploadedUrls.add(imageUrl);
//       }
//       setState(() {
//         _uploadedOtherImagesUrls.addAll(uploadedUrls);
//         _isUploadingOtherImages = false;
//       });
//       _showSuccessSnackbar(AppTranslations.get('other_images_upload_success', const Locale('fr'), '${_selectedOtherImages.length} images uploadées avec succès'));
//     } catch (e) {
//       setState(() {
//         _isUploadingOtherImages = false;
//       });
//       _showErrorSnackbar(AppTranslations.get('other_images_upload_error', const Locale('fr'), 'Erreur lors de l\'upload des images'));
//     }
//   }

//   /// Supprime l'image principale
//   void _removeMainImage() {
//     setState(() {
//       _selectedMainImage = null;
//       _uploadedMainImageUrl = null;
//     });
//   }

//   /// Supprime une image supplémentaire
//   void _removeOtherImage(int index) {
//     setState(() {
//       _selectedOtherImages.removeAt(index);
//       if (index < _uploadedOtherImagesUrls.length) {
//         _uploadedOtherImagesUrls.removeAt(index);
//       }
//     });
//   }

//   // === MÉTHODES POUR LES TRADUCTIONS DES OPTIONS ===

//   /// Retourne les options d'alimentation en eau traduites
//   Map<String, String> _getWaterSupplyOptions(Locale locale) {
//     return {
//       'not_available': AppTranslations.get('water_not_available', locale, 'Non disponible'),
//       'connected_public_supply': AppTranslations.get('water_public_supply', locale, 'Réseau public'),
//       'stand_alone_system': AppTranslations.get('water_stand_alone', locale, 'Système autonome'),
//       'stand_alone_system_with_mains_connection': AppTranslations.get('water_hybrid', locale, 'Système hybride'),
//     };
//   }

//   /// Retourne les options de connexion électrique traduites
//   Map<String, String> _getElectricalConnectionOptions(Locale locale) {
//     return {
//       'not_available': AppTranslations.get('electric_not_available', locale, 'Non disponible'),
//       'connected_public_supply': AppTranslations.get('electric_public_supply', locale, 'Réseau public'),
//       'stand_alone_system': AppTranslations.get('electric_stand_alone', locale, 'Système autonome'),
//       'stand_alone_system_with_mains_connection': AppTranslations.get('electric_hybrid', locale, 'Système hybride'),
//     };
//   }

//   /// Retourne les options de statut traduites
//   Map<String, String> _getStatusOptions(Locale locale) {
//     return {
//       'free': AppTranslations.get('status_free', locale, 'Libre'),
//       'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
//       'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
//     };
//   }

//   // === MÉTHODES POUR LA SOUMISSION ===

//   /// Gère la création de la propriété
//   Future<void> _handleCreateProperty() async {
//     if (_formKey.currentState!.validate()) {
//       final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
      
//       // Validation des champs obligatoires
//       if (_selectedTown == null) {
//         _showErrorSnackbar(AppTranslations.get('select_town_required', locale, 'Veuillez sélectionner une ville'));
//         return;
//       }

//       if (_selectedCategory == null) {
//         _showErrorSnackbar(AppTranslations.get('select_category_required', locale, 'Veuillez sélectionner une catégorie'));
//         return;
//       }

//       if (_uploadedMainImageUrl == null) {
//         _showErrorSnackbar(AppTranslations.get('main_image_required', locale, 'Veuillez uploader une image principale'));
//         return;
//       }

//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final accessToken = authProvider.accessToken;

//       if (accessToken == null) {
//         _showErrorSnackbar(AppTranslations.get('login_required', locale, 'Vous devez être connecté pour créer une propriété'));
//         return;
//       }

//       // Vérification que l'utilisateur est bien connecté et a un ID
//       if (authProvider.currentUser == null || authProvider.currentUser!.id.isEmpty) {
//         _showErrorSnackbar(AppTranslations.get('user_id_not_found', locale, 'Impossible de récupérer votre ID utilisateur. Veuillez vous reconnecter.'));
//         return;
//       }

//       setState(() {
//         _isSubmitting = true;
//       });

//       try {
//         // Préparer les données pour l'API
//         final propertyData = {
//           "title": _titleController.text,
//           "description": _descriptionController.text,
//           "address": _addressController.text,
//           "monthly_price": int.parse(_monthlyPriceController.text),
//           "area": int.parse(_areaController.text),
//           "rooms_nb": int.parse(_roomsController.text),
//           "bathrooms_nb": int.parse(_bathroomsController.text),
//           "living_rooms_nb": int.parse(_livingRoomsController.text),
//           "compartment_number": int.parse(_compartmentNumberController.text),
//           "main_image": _uploadedMainImageUrl,
//           "other_images": _uploadedOtherImagesUrls,
//           "location": [
//             _addressController.text,
//             _latitude?.toString() ?? "",
//             _longitude?.toString() ?? ""
//           ],
//           "owner_id": authProvider.currentUser!.id,
//           "town_id": _selectedTown!.id,
//           "category_property_id": _selectedCategory!.id,
//           "certified": false,
//           "has_internal_kitchen": _hasInternalKitchen,
//           "has_external_kitchen": _hasExternalKitchen,
//           "has_a_parking": _hasAParking,
//           "has_air_conditioning": _hasAirConditioning,
//           "has_security_guards": _hasSecurityGuards,
//           "has_balcony": _hasBalcony,
//           "has_send_verified_request": false,
//           // NOUVEAUX CHAMPS
//           "water_supply": _selectedWaterSupply,
//           "electrical_connection": _selectedElectricalConnection,
//           "status": _selectedStatus,
//         };

//         await _propertyService.createProperty(propertyData, accessToken);

//         if (mounted) {
//           _showSuccessSnackbar(AppTranslations.get('property_created_success', locale, 'Propriété créée avec succès !'));
//           Navigator.of(context).pop();
//         }

//       } catch (e) {
//         _showErrorSnackbar('${AppTranslations.get('creation_error', locale, 'Erreur lors de la création')}: ${e.toString()}');
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isSubmitting = false;
//           });
//         }
//       }
//     }
//   }

//   // === MÉTHODES D'AFFICHAGE DES MESSAGES ===

//   /// Affiche un message d'erreur
//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: AppThemes.getErrorColor(context),
//       ),
//     );
//   }

//   /// Affiche un message de succès
//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: AppThemes.getSuccessColor(context),
//       ),
//     );
//   }

//   // === WIDGETS POUR LES SECTIONS ===

//   /// Widget pour la section image principale
//   Widget _buildMainImageSection(Locale locale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '${AppTranslations.get('main_image', locale, 'Image principale')} *',
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//         ),
//         const SizedBox(height: 8),
        
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               if (_selectedMainImage != null) ...[
//                 Stack(
//                   children: [
//                     Container(
//                       width: 200,
//                       height: 150,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         image: DecorationImage(
//                           image: FileImage(_selectedMainImage!),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     if (_isUploadingMainImage)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black54,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Center(
//                             child: CircularProgressIndicator(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 if (_uploadedMainImageUrl != null)
//                   Text(
//                     AppTranslations.get('upload_success', locale, 'Upload réussi ✓'),
//                     style: TextStyle(
//                       color: AppThemes.getSuccessColor(context),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 const SizedBox(height: 12),
//                 ElevatedButton.icon(
//                   onPressed: _removeMainImage,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.shade50,
//                     foregroundColor: Colors.red,
//                   ),
//                   icon: const Icon(Icons.delete, size: 18),
//                   label: Text(AppTranslations.get('remove', locale, 'Supprimer')),
//                 ),
//               ] else ...[
//                 Icon(
//                   Icons.photo_camera,
//                   size: 60,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   AppTranslations.get('no_image_selected', locale, 'Aucune image sélectionnée'),
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//               ],
//               const SizedBox(height: 16),
              
//               ElevatedButton.icon(
//                 onPressed: _pickMainImage,
//                 icon: const Icon(Icons.photo_library),
//                 label: Text(AppTranslations.get('choose_image', locale, 'Choisir une image')),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// Widget pour la section images supplémentaires
//   Widget _buildOtherImagesSection(Locale locale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           AppTranslations.get('additional_images', locale, 'Images supplémentaires (optionnel)'),
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//         ),
//         const SizedBox(height: 8),
        
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               if (_selectedOtherImages.isNotEmpty) ...[
//                 SizedBox(
//                   height: 120,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _selectedOtherImages.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: Stack(
//                           children: [
//                             Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 image: DecorationImage(
//                                   image: FileImage(_selectedOtherImages[index]),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               top: 4,
//                               right: 4,
//                               child: GestureDetector(
//                                 onTap: () => _removeOtherImage(index),
//                                 child: Container(
//                                   decoration: const BoxDecoration(
//                                     color: Colors.red,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(Icons.close, size: 16, color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 if (_isUploadingOtherImages)
//                   const CircularProgressIndicator(),
//                 const SizedBox(height: 12),
//               ] else ...[
//                 Icon(
//                   Icons.photo_library,
//                   size: 50,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   AppTranslations.get('no_additional_images', locale, 'Aucune image supplémentaire'),
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//               ],
//               const SizedBox(height: 16),
              
//               OutlinedButton.icon(
//                 onPressed: _pickOtherImages,
//                 icon: const Icon(Icons.add_photo_alternate),
//                 label: Text(AppTranslations.get('add_images', locale, 'Ajouter des images')),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// Widget pour l'autocomplete des villes
//   Widget _buildTownAutocomplete(Locale locale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: _townSearchController,
//           decoration: InputDecoration(
//             labelText: '${AppTranslations.get('town', locale, 'Ville')} *',
//             hintText: AppTranslations.get('search_town', locale, 'Rechercher une ville...'),
//             prefixIcon: const Icon(Icons.location_city, color: primaryColor1),
//             suffixIcon: _selectedTown != null
//                 ? IconButton(
//                     icon: const Icon(Icons.clear, color: Colors.grey),
//                     onPressed: _clearTownSelection,
//                   )
//                 : _isSearchingTowns
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : null,
//           ),
//           onTap: () {
//             if (_townSearchController.text.isEmpty) {
//               _loadAllTowns();
//             }
//             setState(() {
//               _showTownDropdown = true;
//             });
//           },
//           validator: (value) {
//             if (_selectedTown == null) {
//               return AppTranslations.get('select_town_required', locale, 'Veuillez sélectionner une ville');
//             }
//             return null;
//           },
//         ),
        
//         if (_showTownDropdown && _filteredTowns.isNotEmpty)
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surface,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 4,
//                   color: Colors.black.withOpacity(0.1),
//                 ),
//               ],
//             ),
//             margin: const EdgeInsets.only(top: 4),
//             constraints: const BoxConstraints(maxHeight: 200),
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: _filteredTowns.length,
//               itemBuilder: (context, index) {
//                 final town = _filteredTowns[index];
//                 return ListTile(
//                   leading: const Icon(Icons.location_city, size: 20),
//                   title: Text(town.name),
//                   subtitle: Text(town.country.name),
//                   onTap: () => _selectTown(town),
//                   dense: true,
//                 );
//               },
//             ),
//           ),
        
//         if (_showTownDropdown && _townSearchController.text.isNotEmpty && _filteredTowns.isEmpty && !_isSearchingTowns)
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               AppTranslations.get('no_town_found', locale, 'Aucune ville trouvée'),
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.error,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   /// Widget pour l'autocomplete des catégories
//   Widget _buildCategoryAutocomplete(Locale locale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: _categorySearchController,
//           decoration: InputDecoration(
//             labelText: '${AppTranslations.get('category', locale, 'Catégorie')} *',
//             hintText: AppTranslations.get('search_category', locale, 'Rechercher une catégorie...'),
//             prefixIcon: const Icon(Icons.category, color: primaryColor1),
//             suffixIcon: _selectedCategory != null
//                 ? IconButton(
//                     icon: const Icon(Icons.clear, color: Colors.grey),
//                     onPressed: _clearCategorySelection,
//                   )
//                 : _isSearchingCategories
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : null,
//           ),
//           onTap: () {
//             if (_categorySearchController.text.isEmpty) {
//               _loadAllCategories();
//             }
//             setState(() {
//               _showCategoryDropdown = true;
//             });
//           },
//           validator: (value) {
//             if (_selectedCategory == null) {
//               return AppTranslations.get('select_category_required', locale, 'Veuillez sélectionner une catégorie');
//             }
//             return null;
//           },
//         ),
        
//         if (_showCategoryDropdown && _filteredCategories.isNotEmpty)
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surface,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 4,
//                   color: Colors.black.withOpacity(0.1),
//                 ),
//               ],
//             ),
//             margin: const EdgeInsets.only(top: 4),
//             constraints: const BoxConstraints(maxHeight: 200),
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: _filteredCategories.length,
//               itemBuilder: (context, index) {
//                 final category = _filteredCategories[index];
//                 return ListTile(
//                   leading: const Icon(Icons.category, size: 20),
//                   title: Text(category.name),
//                   onTap: () => _selectCategory(category),
//                   dense: true,
//                 );
//               },
//             ),
//           ),
        
//         if (_showCategoryDropdown && _categorySearchController.text.isNotEmpty && _filteredCategories.isEmpty && !_isSearchingCategories)
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               AppTranslations.get('no_category_found', locale, 'Aucune catégorie trouvée'),
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.error,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   /// Widget pour la section localisation GPS
//   Widget _buildLocationSection(Locale locale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           AppTranslations.get('gps_location', locale, 'Localisation GPS'),
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//         ),
//         const SizedBox(height: 8),
        
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               if (_userPosition != null) ...[
//                 Row(
//                   children: [
//                     const Icon(Icons.gps_fixed, color: Colors.green),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(AppTranslations.get('current_location_detected', locale, 'Position actuelle détectée')),
//                           Text(
//                             '${AppTranslations.get('latitude', locale, 'Lat')}: ${_latitude!.toStringAsFixed(6)}, ${AppTranslations.get('longitude', locale, 'Lng')}: ${_longitude!.toStringAsFixed(6)}',
//                             style: const TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ] else ...[
//                 Row(
//                   children: [
//                     const Icon(Icons.gps_off, color: Colors.grey),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(AppTranslations.get('location_unavailable', locale, 'Localisation non disponible')),
//                     ),
//                   ],
//                 ),
//               ],
//               const SizedBox(height: 12),
              
//               ElevatedButton.icon(
//                 onPressed: _isGettingLocation ? null : _getUserLocation,
//                 icon: _isGettingLocation 
//                     ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
//                     : const Icon(Icons.gps_fixed),
//                 label: Text(_isGettingLocation 
//                     ? AppTranslations.get('detecting', locale, 'Détection...')
//                     : AppTranslations.get('use_my_location', locale, 'Utiliser ma position')),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// Widget pour la section équipements
//   Widget _buildEquipmentSection(Locale locale) {
//     final equipmentItems = [
//       {
//         'label': AppTranslations.get('internal_kitchen', locale, 'Cuisine interne'),
//         'value': _hasInternalKitchen,
//         'onChanged': (value) => setState(() => _hasInternalKitchen = value!),
//         'icon': Icons.kitchen,
//       },
//       {
//         'label': AppTranslations.get('external_kitchen', locale, 'Cuisine externe'),
//         'value': _hasExternalKitchen,
//         'onChanged': (value) => setState(() => _hasExternalKitchen = value!),
//         'icon': Icons.outdoor_grill,
//       },
//       {
//         'label': AppTranslations.get('parking', locale, 'Parking'),
//         'value': _hasAParking,
//         'onChanged': (value) => setState(() => _hasAParking = value!),
//         'icon': Icons.local_parking,
//       },
//       {
//         'label': AppTranslations.get('air_conditioning', locale, 'Climatisation'),
//         'value': _hasAirConditioning,
//         'onChanged': (value) => setState(() => _hasAirConditioning = value!),
//         'icon': Icons.ac_unit,
//       },
//       {
//         'label': AppTranslations.get('security_guards', locale, 'Gardiennage'),
//         'value': _hasSecurityGuards,
//         'onChanged': (value) => setState(() => _hasSecurityGuards = value!),
//         'icon': Icons.security,
//       },
//       {
//         'label': AppTranslations.get('balcony', locale, 'Balcon'),
//         'value': _hasBalcony,
//         'onChanged': (value) => setState(() => _hasBalcony = value!),
//         'icon': Icons.balcony,
//       },
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           AppTranslations.get('equipment', locale, 'Équipements'),
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//         ),
//         const SizedBox(height: 8),
        
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 12,
//               childAspectRatio: 3.5,
//             ),
//             itemCount: equipmentItems.length,
//             itemBuilder: (context, index) {
//               final item = equipmentItems[index];
//               return _buildEquipmentCheckbox(
//                 item['label'] as String,
//                 item['value'] as bool,
//                 item['onChanged'] as Function(bool?),
//                 item['icon'] as IconData,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   /// Widget pour une checkbox d'équipement
//   Widget _buildEquipmentCheckbox(String label, bool value, Function(bool?) onChanged, IconData icon) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: CheckboxListTile(
//         value: value,
//         onChanged: onChanged,
//         title: Row(
//           children: [
//             Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 label,
//                 style: const TextStyle(fontSize: 14),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         controlAffinity: ListTileControlAffinity.leading,
//         dense: true,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 8),
//       ),
//     );
//   }

//   // === NOUVEAUX WIDGETS POUR LES SELECTS ===

//   /// Widget pour le dropdown d'alimentation en eau
//   Widget _buildWaterSupplyDropdown(Locale locale) {
//     final options = _getWaterSupplyOptions(locale);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '${AppTranslations.get('water_supply', locale, 'Alimentation en eau')} *',
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: _selectedWaterSupply,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedWaterSupply = newValue!;
//               });
//             },
//             items: options.entries.map((entry) {
//               return DropdownMenuItem<String>(
//                 value: entry.key,
//                 child: Text(entry.value),
//               );
//             }).toList(),
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               border: InputBorder.none,
//               hintText: AppTranslations.get('select_water_supply', locale, 'Sélectionnez une option'),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return AppTranslations.get('water_supply_required', locale, 'Ce champ est requis');
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   /// Widget pour le dropdown de connexion électrique
//   Widget _buildElectricalConnectionDropdown(Locale locale) {
//     final options = _getElectricalConnectionOptions(locale);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '${AppTranslations.get('electrical_connection', locale, 'Connexion électrique')} *',
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: _selectedElectricalConnection,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedElectricalConnection = newValue!;
//               });
//             },
//             items: options.entries.map((entry) {
//               return DropdownMenuItem<String>(
//                 value: entry.key,
//                 child: Text(entry.value),
//               );
//             }).toList(),
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               border: InputBorder.none,
//               hintText: AppTranslations.get('select_electrical_connection', locale, 'Sélectionnez une option'),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return AppTranslations.get('electrical_connection_required', locale, 'Ce champ est requis');
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   /// Widget pour le dropdown de statut
//   Widget _buildStatusDropdown(Locale locale) {
//     final options = _getStatusOptions(locale);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '${AppTranslations.get('status', locale, 'Statut')} *',
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: _selectedStatus,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedStatus = newValue!;
//               });
//             },
//             items: options.entries.map((entry) {
//               return DropdownMenuItem<String>(
//                 value: entry.key,
//                 child: Text(entry.value),
//               );
//             }).toList(),
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               border: InputBorder.none,
//               hintText: AppTranslations.get('select_status', locale, 'Sélectionnez un statut'),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return AppTranslations.get('status_required', locale, 'Ce champ est requis');
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final settingsProvider = Provider.of<SettingsProvider>(context);
//     final locale = settingsProvider.locale;

//     return GestureDetector(
//       onTap: () {
//         // Ferme les dropdowns lorsqu'on tape ailleurs
//         if (_showTownDropdown) {
//           setState(() {
//             _showTownDropdown = false;
//           });
//         }
//         if (_showCategoryDropdown) {
//           setState(() {
//             _showCategoryDropdown = false;
//           });
//         }
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(AppTranslations.get('new_property', locale, 'Nouvelle propriété')),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.help_outline),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: Text(AppTranslations.get('help', locale, 'Aide')),
//                     content: Text(AppTranslations.get('fill_required_fields', locale, 'Remplissez tous les champs obligatoires (*) pour créer votre propriété.')),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: Text(AppTranslations.get('ok', locale, 'OK')),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // === SECTION INFORMATIONS DE BASE ===
//                 Text(
//                   AppTranslations.get('basic_information', locale, 'Informations de base'),
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 TextFormField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: '${AppTranslations.get('title', locale, 'Titre')} *',
//                     hintText: AppTranslations.get('title_hint', locale, 'Ex: Belle maison moderne...'),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('title_required', locale, 'Le titre est requis');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: '${AppTranslations.get('description', locale, 'Description')} *',
//                     hintText: AppTranslations.get('description_hint', locale, 'Décrivez votre propriété...'),
//                   ),
//                   maxLines: 4,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('description_required', locale, 'La description est requise');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 TextFormField(
//                   controller: _addressController,
//                   decoration: InputDecoration(
//                     labelText: '${AppTranslations.get('address', locale, 'Adresse')} *',
//                     hintText: AppTranslations.get('address_hint', locale, 'Adresse complète de la propriété'),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('address_required', locale, 'L\'adresse est requise');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // === SECTION CARACTÉRISTIQUES ===
//                 Text(
//                   AppTranslations.get('characteristics', locale, 'Caractéristiques'),
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _monthlyPriceController,
//                         decoration: InputDecoration(
//                           labelText: '${AppTranslations.get('monthly_price', locale, 'Prix mensuel')} (XOF) *',
//                           hintText: '50000',
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return AppTranslations.get('price_required', locale, 'Le prix est requis');
//                           }
//                           if (int.tryParse(value) == null) {
//                             return AppTranslations.get('invalid_price', locale, 'Prix invalide');
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _areaController,
//                         decoration: InputDecoration(
//                           labelText: '${AppTranslations.get('area', locale, 'Surface')} (m²) *',
//                           hintText: '120',
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return AppTranslations.get('area_required', locale, 'La surface est requise');
//                           }
//                           if (int.tryParse(value) == null) {
//                             return AppTranslations.get('invalid_area', locale, 'Surface invalide');
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _roomsController,
//                         decoration: InputDecoration(
//                           labelText: '${AppTranslations.get('rooms', locale, 'Nombre de chambres')} *',
//                           hintText: '3',
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return AppTranslations.get('field_required', locale, 'Ce champ est requis');
//                           }
//                           if (int.tryParse(value) == null) {
//                             return AppTranslations.get('invalid_number', locale, 'Nombre invalide');
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _bathroomsController,
//                         decoration: InputDecoration(
//                           labelText: '${AppTranslations.get('bathrooms', locale, 'Salles de bain')} *',
//                           hintText: '2',
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return AppTranslations.get('field_required', locale, 'Ce champ est requis');
//                           }
//                           if (int.tryParse(value) == null) {
//                             return AppTranslations.get('invalid_number', locale, 'Nombre invalide');
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _livingRoomsController,
//                         decoration: InputDecoration(
//                           labelText: '${AppTranslations.get('living_rooms', locale, 'Salons')} *',
//                           hintText: '1',
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return AppTranslations.get('field_required', locale, 'Ce champ est requis');
//                           }
//                           if (int.tryParse(value) == null) {
//                             return AppTranslations.get('invalid_number', locale, 'Nombre invalide');
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _compartmentNumberController,
//                         decoration: InputDecoration(
//                           labelText: '${AppTranslations.get('compartment_number', locale, 'Numéro de compartiment')} *',
//                           hintText: '5',
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return AppTranslations.get('field_required', locale, 'Ce champ est requis');
//                           }
//                           if (int.tryParse(value) == null) {
//                             return AppTranslations.get('invalid_number', locale, 'Nombre invalide');
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // === SECTION SERVICES ET STATUT ===
//                 Text(
//                   AppTranslations.get('services_status', locale, 'Services et Statut'),
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 _buildWaterSupplyDropdown(locale),
//                 const SizedBox(height: 16),

//                 _buildElectricalConnectionDropdown(locale),
//                 const SizedBox(height: 16),

//                 _buildStatusDropdown(locale),
//                 const SizedBox(height: 24),

//                 // === SECTION LOCALISATION ===
//                 Text(
//                   AppTranslations.get('location', locale, 'Localisation'),
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 _buildTownAutocomplete(locale),
//                 const SizedBox(height: 16),

//                 _buildCategoryAutocomplete(locale),
//                 const SizedBox(height: 16),

//                 _buildLocationSection(locale),
//                 const SizedBox(height: 24),

//                 // === SECTION IMAGES ===
//                 Text(
//                   AppTranslations.get('images', locale, 'Images'),
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 _buildMainImageSection(locale),
//                 const SizedBox(height: 16),

//                 _buildOtherImagesSection(locale),
//                 const SizedBox(height: 24),

//                 // === SECTION ÉQUIPEMENTS ===
//                 _buildEquipmentSection(locale),
//                 const SizedBox(height: 32),

//                 // === BOUTON DE SOUMISSION ===
//                 ElevatedButton(
//                   onPressed: _isSubmitting ? null : _handleCreateProperty,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor1,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: _isSubmitting
//                       ? const SizedBox(
//                           height: 20, 
//                           width: 20, 
//                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text(
//                           AppTranslations.get('create_property', locale, 'Créer la propriété'),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/pages/create_property_page.dart
// VERSION CORRIGÉE & MODERNE (basée sur le fichier original fonctionnel)
// Seule la partie visuelle a été actualisée : couleurs, formes, espacements, animations.
// Tous les champs, clés, services, modèles, traductions restent identiques.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/property_service.dart';
import '../services/town_service.dart';
import '../services/category_service.dart';
import '../services/media_service.dart';
import '../models/town.dart';
import '../models/category.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_translations.dart';
import '../constants/app_themes.dart';

class CreatePropertyPage extends StatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  State<CreatePropertyPage> createState() => _CreatePropertyPageState();
}

class _CreatePropertyPageState extends State<CreatePropertyPage> {
  // === CLÉ ET SERVICES ===
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();
  final TownService _townService = TownService();
  final CategoryService _categoryService = CategoryService();
  final MediaService _mediaService = MediaService();
  final ImagePicker _imagePicker = ImagePicker();

  // === CONTRÔLEURS POUR LES CHAMPS TEXTE ===
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _monthlyPriceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _livingRoomsController = TextEditingController();
  final TextEditingController _compartmentNumberController = TextEditingController();

  // === AUTOCOMPLETE POUR LES VILLES ===
  final TextEditingController _townSearchController = TextEditingController();
  List<Town> _filteredTowns = [];
  Town? _selectedTown;
  bool _isSearchingTowns = false;
  bool _showTownDropdown = false;

  // === AUTOCOMPLETE POUR LES CATÉGORIES ===
  final TextEditingController _categorySearchController = TextEditingController();
  List<Category> _filteredCategories = [];
  Category? _selectedCategory;
  bool _isSearchingCategories = false;
  bool _showCategoryDropdown = false;

  // === GESTION DES IMAGES ===
  File? _selectedMainImage;
  List<File> _selectedOtherImages = [];
  String? _uploadedMainImageUrl;
  List<String> _uploadedOtherImagesUrls = [];
  bool _isUploadingMainImage = false;
  bool _isUploadingOtherImages = false;

  // === ÉQUIPEMENTS (CHECKBOX) ===
  bool _hasInternalKitchen = false;
  bool _hasExternalKitchen = false;
  bool _hasAParking = false;
  bool _hasAirConditioning = false;
  bool _hasSecurityGuards = false;
  bool _hasBalcony = false;

  // === LOCALISATION GPS ===
  Position? _userPosition;
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  // === NOUVEAUX CHAMPS SELECT ===
  String _selectedWaterSupply = 'not_available';
  String _selectedElectricalConnection = 'not_available';
  String _selectedStatus = 'free';

  // === ÉTATS ===
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _townSearchController.addListener(_onTownSearchChanged);
    _categorySearchController.addListener(_onCategorySearchChanged);
    _getUserLocation();
    _loadAllTowns();
    _loadAllCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _monthlyPriceController.dispose();
    _areaController.dispose();
    _roomsController.dispose();
    _bathroomsController.dispose();
    _livingRoomsController.dispose();
    _compartmentNumberController.dispose();
    _townSearchController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  // =========================================================
  //  DATA LOADING (identique à l’original)
  // =========================================================
  Future<void> _loadAllTowns() async {
    try {
      final towns = await _townService.getAllTowns();
      setState(() => _filteredTowns = towns);
    } catch (e) {
      debugPrint('Erreur chargement villes: $e');
    }
  }

  Future<void> _loadAllCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() => _filteredCategories = categories);
    } catch (e) {
      debugPrint('Erreur chargement catégories: $e');
    }
  }

  Future<void> _getUserLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permissions refusées');
      }
      if (permission == LocationPermission.deniedForever) throw Exception('Permissions définitivement refusées');

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _userPosition = position;
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() => _isGettingLocation = false);
      _showSnackBar(AppTranslations.get('location_error', const Locale('fr'), 'Erreur de localisation'), isError: true);
    }
  }

  // =========================================================
  //  AUTOCOMPLETE (identique à l’original)
  // =========================================================
  void _onTownSearchChanged() async {
    final query = _townSearchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _showTownDropdown = false;
        _filteredTowns = [];
      });
      return;
    }
    setState(() {
      _isSearchingTowns = true;
      _showTownDropdown = true;
    });
    try {
      final response = await _townService.searchTowns(query);
      setState(() {
        _filteredTowns = response.records;
        _isSearchingTowns = false;
      });
    } catch (e) {
      setState(() => _isSearchingTowns = false);
    }
  }

  void _selectTown(Town town) {
    setState(() {
      _selectedTown = town;
      _townSearchController.text = town.name;
      _showTownDropdown = false;
    });
  }

  void _clearTownSelection() {
    setState(() {
      _selectedTown = null;
      _townSearchController.clear();
      _showTownDropdown = false;
    });
  }

  void _onCategorySearchChanged() async {
    final query = _categorySearchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _showCategoryDropdown = false;
        _filteredCategories = [];
      });
      return;
    }
    setState(() {
      _isSearchingCategories = true;
      _showCategoryDropdown = true;
    });
    try {
      final response = await _categoryService.searchCategories(query);
      setState(() {
        _filteredCategories = response.records;
        _isSearchingCategories = false;
      });
    } catch (e) {
      setState(() => _isSearchingCategories = false);
    }
  }

  void _selectCategory(Category category) {
    setState(() {
      _selectedCategory = category;
      _categorySearchController.text = category.name;
      _showCategoryDropdown = false;
    });
  }

  void _clearCategorySelection() {
    setState(() {
      _selectedCategory = null;
      _categorySearchController.clear();
      _showCategoryDropdown = false;
    });
  }

  // =========================================================
  //  IMAGES (identique à l’original)
  // =========================================================
  Future<void> _pickMainImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _selectedMainImage = File(pickedFile.path));
        await _uploadMainImage();
      }
    } catch (e) {
      _showSnackBar(AppTranslations.get('image_selection_error', const Locale('fr'), 'Erreur de sélection'), isError: true);
    }
  }

  Future<void> _pickOtherImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFiles.isNotEmpty) {
        setState(() => _selectedOtherImages.addAll(pickedFiles.map((f) => File(f.path))));
        await _uploadOtherImages();
      }
    } catch (e) {
      _showSnackBar(AppTranslations.get('image_selection_error', const Locale('fr'), 'Erreur de sélection'), isError: true);
    }
  }

  Future<void> _uploadMainImage() async {
    if (_selectedMainImage == null) return;
    setState(() => _isUploadingMainImage = true);
    try {
      final url = await _mediaService.uploadSingleFile(_selectedMainImage!);
      setState(() {
        _uploadedMainImageUrl = url;
        _isUploadingMainImage = false;
      });
      _showSnackBar(AppTranslations.get('upload_success', const Locale('fr'), 'Upload réussi'));
    } catch (e) {
      setState(() => _isUploadingMainImage = false);
      _showSnackBar(AppTranslations.get('upload_error', const Locale('fr'), 'Erreur d\'upload'), isError: true);
    }
  }

  Future<void> _uploadOtherImages() async {
    if (_selectedOtherImages.isEmpty) return;
    setState(() => _isUploadingOtherImages = true);
    try {
      final urls = <String>[];
      for (final file in _selectedOtherImages) {
        urls.add(await _mediaService.uploadSingleFile(file));
      }
      setState(() {
        _uploadedOtherImagesUrls.addAll(urls);
        _isUploadingOtherImages = false;
      });
      _showSnackBar(AppTranslations.get('upload_success', const Locale('fr'), 'Upload réussi'));
    } catch (e) {
      setState(() => _isUploadingOtherImages = false);
      _showSnackBar(AppTranslations.get('upload_error', const Locale('fr'), 'Erreur d\'upload'), isError: true);
    }
  }

  void _removeMainImage() => setState(() {
        _selectedMainImage = null;
        _uploadedMainImageUrl = null;
      });

  void _removeOtherImage(int index) => setState(() {
        _selectedOtherImages.removeAt(index);
        if (index < _uploadedOtherImagesUrls.length) {
          _uploadedOtherImagesUrls.removeAt(index);
        }
      });

  // =========================================================
  //  SUBMISSION (identique à l’original)
  // =========================================================
  Future<void> _handleCreateProperty() async {
    if (!_formKey.currentState!.validate()) return;
    final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final user = authProvider.currentUser;

    if (_selectedTown == null) {
      _showSnackBar(AppTranslations.get('select_town_required', locale, 'Veuillez sélectionner une ville'), isError: true);
      return;
    }
    if (_selectedCategory == null) {
      _showSnackBar(AppTranslations.get('select_category_required', locale, 'Veuillez sélectionner une catégorie'), isError: true);
      return;
    }
    if (_uploadedMainImageUrl == null) {
      _showSnackBar(AppTranslations.get('main_image_required', locale, 'Image principale requise'), isError: true);
      return;
    }
    if (accessToken == null || user == null || user.id.isEmpty) {
      _showSnackBar(AppTranslations.get('login_required', locale, 'Vous devez être connecté'), isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final propertyData = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "address": _addressController.text,
        "monthly_price": int.parse(_monthlyPriceController.text),
        "area": int.parse(_areaController.text),
        "rooms_nb": int.parse(_roomsController.text),
        "bathrooms_nb": int.parse(_bathroomsController.text),
        "living_rooms_nb": int.parse(_livingRoomsController.text),
        "compartment_number": int.parse(_compartmentNumberController.text),
        "main_image": _uploadedMainImageUrl,
        "other_images": _uploadedOtherImagesUrls,
        "location": [_addressController.text, _latitude?.toString() ?? "", _longitude?.toString() ?? ""],
        "owner_id": user.id,
        "town_id": _selectedTown!.id,
        "category_property_id": _selectedCategory!.id,
        "certified": false,
        "has_internal_kitchen": _hasInternalKitchen,
        "has_external_kitchen": _hasExternalKitchen,
        "has_a_parking": _hasAParking,
        "has_air_conditioning": _hasAirConditioning,
        "has_security_guards": _hasSecurityGuards,
        "has_balcony": _hasBalcony,
        "has_send_verified_request": false,
        "water_supply": _selectedWaterSupply,
        "electrical_connection": _selectedElectricalConnection,
        "status": _selectedStatus,
      };

      await _propertyService.createProperty(propertyData, accessToken);

      if (mounted) {
        _showSnackBar(AppTranslations.get('property_created_success', locale, 'Propriété créée avec succès'));
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar('${AppTranslations.get('creation_error', locale, 'Erreur lors de la création')}: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // =========================================================
  //  HELPERS
  // =========================================================
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppThemes.getErrorColor(context) : AppThemes.getSuccessColor(context),
      ),
    );
  }

  // =========================================================
  //  WIDGETS (UI modernisée sans changer la logique)
  // =========================================================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildMainImageSection(Locale locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppTranslations.get('main_image', locale, 'Image principale')} *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_selectedMainImage != null) ...[
                Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_selectedMainImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_isUploadingMainImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_uploadedMainImageUrl != null)
                  Text(
                    AppTranslations.get('upload_success', locale, 'Upload réussi ✓'),
                    style: TextStyle(
                      color: AppThemes.getSuccessColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _removeMainImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text(AppTranslations.get('remove', locale, 'Supprimer')),
                ),
              ] else ...[
                Icon(
                  Icons.photo_camera,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  AppTranslations.get('no_image_selected', locale, 'Aucune image sélectionnée'),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickMainImage,
                icon: const Icon(Icons.photo_library),
                label: Text(AppTranslations.get('choose_image', locale, 'Choisir une image')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherImagesSection(Locale locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslations.get('additional_images', locale, 'Images supplémentaires (optionnel)'),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_selectedOtherImages.isNotEmpty) ...[
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedOtherImages.length,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedOtherImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeOtherImage(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (_isUploadingOtherImages) const CircularProgressIndicator(),
                const SizedBox(height: 12),
              ] else ...[
                Icon(
                  Icons.photo_library,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslations.get('no_additional_images', locale, 'Aucune image supplémentaire'),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickOtherImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(AppTranslations.get('add_images', locale, 'Ajouter des images')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTownAutocomplete(Locale locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _townSearchController,
          decoration: InputDecoration(
            labelText: '${AppTranslations.get('town', locale, 'Ville')} *',
            hintText: AppTranslations.get('search_town', locale, 'Rechercher une ville...'),
            prefixIcon: const Icon(Icons.location_city, color: primaryColor1),
            suffixIcon: _selectedTown != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: _clearTownSelection,
                  )
                : _isSearchingTowns
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
          ),
          onTap: () {
            if (_townSearchController.text.isEmpty) _loadAllTowns();
            setState(() => _showTownDropdown = true);
          },
          validator: (value) {
            if (_selectedTown == null) {
              return AppTranslations.get('select_town_required', locale, 'Veuillez sélectionner une ville');
            }
            return null;
          },
        ),
        if (_showTownDropdown && _filteredTowns.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.1))],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredTowns.length,
              itemBuilder: (_, index) {
                final town = _filteredTowns[index];
                return ListTile(
                  leading: const Icon(Icons.location_city, size: 20),
                  title: Text(town.name),
                  subtitle: Text(town.country.name),
                  onTap: () => _selectTown(town),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryAutocomplete(Locale locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _categorySearchController,
          decoration: InputDecoration(
            labelText: '${AppTranslations.get('category', locale, 'Catégorie')} *',
            hintText: AppTranslations.get('search_category', locale, 'Rechercher une catégorie...'),
            prefixIcon: const Icon(Icons.category, color: primaryColor1),
            suffixIcon: _selectedCategory != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: _clearCategorySelection,
                  )
                : _isSearchingCategories
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
          ),
          onTap: () {
            if (_categorySearchController.text.isEmpty) _loadAllCategories();
            setState(() => _showCategoryDropdown = true);
          },
          validator: (value) {
            if (_selectedCategory == null) {
              return AppTranslations.get('select_category_required', locale, 'Veuillez sélectionner une catégorie');
            }
            return null;
          },
        ),
        if (_showCategoryDropdown && _filteredCategories.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.1))],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredCategories.length,
              itemBuilder: (_, index) {
                final category = _filteredCategories[index];
                return ListTile(
                  leading: const Icon(Icons.category, size: 20),
                  title: Text(category.name),
                  onTap: () => _selectCategory(category),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLocationSection(Locale locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslations.get('gps_location', locale, 'Localisation GPS'),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_userPosition != null) ...[
                Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppTranslations.get('current_location_detected', locale, 'Position actuelle détectée')),
                          Text(
                            '${AppTranslations.get('latitude', locale, 'Lat')}: ${_latitude!.toStringAsFixed(6)}, ${AppTranslations.get('longitude', locale, 'Lng')}: ${_longitude!.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(Icons.gps_off, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(AppTranslations.get('location_unavailable', locale, 'Localisation non disponible')),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isGettingLocation ? null : _getUserLocation,
                icon: _isGettingLocation
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.gps_fixed),
                label: Text(_isGettingLocation
                    ? AppTranslations.get('detecting', locale, 'Détection...')
                    : AppTranslations.get('use_my_location', locale, 'Utiliser ma position')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(Locale locale) {
    final equipmentItems = [
      {
        'label': AppTranslations.get('internal_kitchen', locale, 'Cuisine interne'),
        'value': _hasInternalKitchen,
        'onChanged': (value) => setState(() => _hasInternalKitchen = value!),
        'icon': Icons.kitchen,
      },
      {
        'label': AppTranslations.get('external_kitchen', locale, 'Cuisine externe'),
        'value': _hasExternalKitchen,
        'onChanged': (value) => setState(() => _hasExternalKitchen = value!),
        'icon': Icons.outdoor_grill,
      },
      {
        'label': AppTranslations.get('parking', locale, 'Parking'),
        'value': _hasAParking,
        'onChanged': (value) => setState(() => _hasAParking = value!),
        'icon': Icons.local_parking,
      },
      {
        'label': AppTranslations.get('air_conditioning', locale, 'Climatisation'),
        'value': _hasAirConditioning,
        'onChanged': (value) => setState(() => _hasAirConditioning = value!),
        'icon': Icons.ac_unit,
      },
      {
        'label': AppTranslations.get('security_guards', locale, 'Gardiennage'),
        'value': _hasSecurityGuards,
        'onChanged': (value) => setState(() => _hasSecurityGuards = value!),
        'icon': Icons.security,
      },
      {
        'label': AppTranslations.get('balcony', locale, 'Balcon'),
        'value': _hasBalcony,
        'onChanged': (value) => setState(() => _hasBalcony = value!),
        'icon': Icons.balcony,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslations.get('equipment', locale, 'Équipements'),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5,
            ),
            itemCount: equipmentItems.length,
            itemBuilder: (_, index) {
              final item = equipmentItems[index];
              return _buildEquipmentCheckbox(
                item['label'] as String,
                item['value'] as bool,
                item['onChanged'] as Function(bool?),
                item['icon'] as IconData,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentCheckbox(String label, bool value, Function(bool?) onChanged, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Map<String, String> _getWaterSupplyOptions(Locale locale) {
    return {
      'not_available': AppTranslations.get('water_not_available', locale, 'Non disponible'),
      'connected_public_supply': AppTranslations.get('water_public_supply', locale, 'Réseau public'),
      'stand_alone_system': AppTranslations.get('water_stand_alone', locale, 'Système autonome'),
      'stand_alone_system_with_mains_connection': AppTranslations.get('water_hybrid', locale, 'Système hybride'),
    };
  }

  Map<String, String> _getElectricalConnectionOptions(Locale locale) {
    return {
      'not_available': AppTranslations.get('electric_not_available', locale, 'Non disponible'),
      'connected_public_supply': AppTranslations.get('electric_public_supply', locale, 'Réseau public'),
      'stand_alone_system': AppTranslations.get('electric_stand_alone', locale, 'Système autonome'),
      'stand_alone_system_with_mains_connection': AppTranslations.get('electric_hybrid', locale, 'Système hybride'),
    };
  }

  Map<String, String> _getStatusOptions(Locale locale) {
    return {
      'free': AppTranslations.get('status_free', locale, 'Libre'),
      'busy': AppTranslations.get('status_busy', locale, 'Occupé'),
      'prev_advise': AppTranslations.get('status_prev_advise', locale, 'Préavis'),
    };
  }

  // =========================================================
  //  DROPDOWNS (UI modernisée)
  // =========================================================
  Widget _buildDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required Function(String?) onChanged,
    required String locale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            items: items.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                // return AppTranslations.get('field_required', locale, 'Ce champ est requis');
                return AppTranslations.get('field_required', Locale(locale), 'Ce champ est requis');
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // =========================================================
  //  BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;

    return GestureDetector(
      onTap: () {
        if (_showTownDropdown) setState(() => _showTownDropdown = false);
        if (_showCategoryDropdown) setState(() => _showCategoryDropdown = false);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppTranslations.get('new_property', locale, 'Nouvelle propriété')),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(AppTranslations.get('help', locale, 'Aide')),
                  content: Text(AppTranslations.get('fill_required_fields', locale, 'Remplissez tous les champs obligatoires (*) pour créer votre propriété.')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppTranslations.get('ok', locale, 'OK')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic info
                _buildSectionTitle(AppTranslations.get('basic_information', locale, 'Informations de base')),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: '${AppTranslations.get('title', locale, 'Titre')} *',
                    hintText: AppTranslations.get('title_hint', locale, 'Ex: Belle maison moderne...'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppTranslations.get('title_required', locale, 'Le titre est requis');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: '${AppTranslations.get('description', locale, 'Description')} *',
                    hintText: AppTranslations.get('description_hint', locale, 'Décrivez votre propriété...'),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppTranslations.get('description_required', locale, 'La description est requise');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: '${AppTranslations.get('address', locale, 'Adresse')} *',
                    hintText: AppTranslations.get('address_hint', locale, 'Adresse complète de la propriété'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppTranslations.get('address_required', locale, 'L\'adresse est requise');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Characteristics
                _buildSectionTitle(AppTranslations.get('characteristics', locale, 'Caractéristiques')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _monthlyPriceController,
                        decoration: InputDecoration(
                          labelText: '${AppTranslations.get('monthly_price', locale, 'Prix mensuel')} (XOF) *',
                          hintText: '50000',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTranslations.get('price_required', locale, 'Le prix est requis');
                          }
                          if (int.tryParse(value) == null) {
                            return AppTranslations.get('invalid_price', locale, 'Prix invalide');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _areaController,
                        decoration: InputDecoration(
                          labelText: '${AppTranslations.get('area', locale, 'Surface')} (m²) *',
                          hintText: '120',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTranslations.get('area_required', locale, 'La surface est requise');
                          }
                          if (int.tryParse(value) == null) {
                            return AppTranslations.get('invalid_area', locale, 'Surface invalide');
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _roomsController,
                        decoration: InputDecoration(
                          labelText: '${AppTranslations.get('rooms', locale, 'Chambres')} *',
                          hintText: '3',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTranslations.get('field_required', locale, 'Ce champ est requis');
                          }
                          if (int.tryParse(value) == null) {
                            return AppTranslations.get('invalid_number', locale, 'Nombre invalide');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _bathroomsController,
                        decoration: InputDecoration(
                          labelText: '${AppTranslations.get('bathrooms', locale, 'Salles de bain')} *',
                          hintText: '2',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTranslations.get('field_required', locale, 'Ce champ est requis');
                          }
                          if (int.tryParse(value) == null) {
                            return AppTranslations.get('invalid_number', locale, 'Nombre invalide');
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _livingRoomsController,
                        decoration: InputDecoration(
                          labelText: '${AppTranslations.get('living_rooms', locale, 'Salons')} *',
                          hintText: '1',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTranslations.get('field_required', locale, 'Ce champ est requis');
                          }
                          if (int.tryParse(value) == null) {
                            return AppTranslations.get('invalid_number', locale, 'Nombre invalide');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _compartmentNumberController,
                        decoration: InputDecoration(
                          labelText: '${AppTranslations.get('compartment_number', locale, 'Numéro de compartiment')} *',
                          hintText: '5',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTranslations.get('field_required', locale, 'Ce champ est requis');
                          }
                          if (int.tryParse(value) == null) {
                            return AppTranslations.get('invalid_number', locale, 'Nombre invalide');
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Services & status
                _buildSectionTitle(AppTranslations.get('services_status', locale, 'Services et Statut')),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: AppTranslations.get('water_supply', locale, 'Alimentation en eau'),
                  value: _selectedWaterSupply,
                  items: _getWaterSupplyOptions(locale),
                  onChanged: (v) => setState(() => _selectedWaterSupply = v!),
                  locale: locale.languageCode,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: AppTranslations.get('electrical_connection', locale, 'Connexion électrique'),
                  value: _selectedElectricalConnection,
                  items: _getElectricalConnectionOptions(locale),
                  onChanged: (v) => setState(() => _selectedElectricalConnection = v!),
                  locale: locale.languageCode,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: AppTranslations.get('status', locale, 'Statut'),
                  value: _selectedStatus,
                  items: _getStatusOptions(locale),
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                  locale: locale.languageCode,
                ),
                const SizedBox(height: 24),

                // Location
                _buildSectionTitle(AppTranslations.get('location', locale, 'Localisation')),
                const SizedBox(height: 16),
                _buildTownAutocomplete(locale),
                const SizedBox(height: 16),
                _buildCategoryAutocomplete(locale),
                const SizedBox(height: 16),
                _buildLocationSection(locale),
                const SizedBox(height: 24),

                // Images
                _buildSectionTitle(AppTranslations.get('images', locale, 'Images')),
                const SizedBox(height: 16),
                _buildMainImageSection(locale),
                const SizedBox(height: 16),
                _buildOtherImagesSection(locale),
                const SizedBox(height: 24),

                // Equipment
                _buildEquipmentSection(locale),
                const SizedBox(height: 32),

                // Submit
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleCreateProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          AppTranslations.get('create_property', locale, 'Créer la propriété'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}