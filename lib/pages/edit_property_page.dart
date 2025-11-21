// lib/pages/edit_property_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/property_service.dart';
import '../services/town_service.dart';
import '../services/category_service.dart';
import '../services/media_service.dart';
import '../models/property_model.dart';
import '../models/town.dart';
import '../models/category.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_translations.dart';
import '../constants/app_themes.dart';

class EditPropertyPage extends StatefulWidget {
  final Property property;
  const EditPropertyPage({super.key, required this.property});

  @override
  State<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  // === CLÉ ET SERVICES ===
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();
  final TownService _townService = TownService();
  final CategoryService _categoryService = CategoryService();
  final MediaService _mediaService = MediaService();
  final ImagePicker _imagePicker = ImagePicker();

  // === CONTRÔLEURS POUR LES CHAMPS TEXTE ===
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _monthlyPriceController;
  late final TextEditingController _areaController;
  late final TextEditingController _roomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _livingRoomsController;
  late final TextEditingController _compartmentNumberController;

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
  List<String> _existingOtherImages = [];
  bool _isUploadingImages = false;

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

  // === CHAMPS SELECT ===
  String _selectedWaterSupply = 'not_available';
  String _selectedElectricalConnection = 'not_available';
  String _selectedStatus = 'free';

  // === ÉTATS ===
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    // Initialiser les contrôleurs avec les valeurs existantes
    _initializeControllers();
    
    _townSearchController.addListener(_onTownSearchChanged);
    _categorySearchController.addListener(_onCategorySearchChanged);
    _getUserLocation();
    _loadAllTowns();
    _loadAllCategories();
    _initializeFormData();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.property.title);
    _descriptionController = TextEditingController(text: widget.property.description);
    _addressController = TextEditingController(text: widget.property.address);
    _monthlyPriceController = TextEditingController(text: widget.property.monthlyPrice.toString());
    _areaController = TextEditingController(text: widget.property.area.toString());
    _roomsController = TextEditingController(text: widget.property.roomsNb.toString());
    _bathroomsController = TextEditingController(text: widget.property.bathroomsNb.toString());
    _livingRoomsController = TextEditingController(text: widget.property.livingRoomsNb.toString());
    _compartmentNumberController = TextEditingController(text: widget.property.compartmentNumber.toString());
  }

  void _initializeFormData() {
    // Initialiser les sélections avec les valeurs existantes
    _selectedTown = widget.property.town;
    _selectedCategory = widget.property.category;
    _townSearchController.text = widget.property.town.name;
    _categorySearchController.text = widget.property.category.name;

    // Initialiser les équipements
    _hasInternalKitchen = widget.property.hasInternalKitchen;
    _hasExternalKitchen = widget.property.hasExternalKitchen;
    _hasAParking = widget.property.hasAParking;
    _hasAirConditioning = widget.property.hasAirConditioning;
    _hasSecurityGuards = widget.property.hasSecurityGuards;
    _hasBalcony = widget.property.hasBalcony;

    // Initialiser les sélections
    _selectedWaterSupply = widget.property.waterSupply;
    _selectedElectricalConnection = widget.property.electricalConnection;
    _selectedStatus = widget.property.status;

    // Initialiser les images existantes
    _existingOtherImages = List.from(widget.property.otherImages);

    // Initialiser la localisation
    if (widget.property.location.length >= 3) {
      _latitude = double.tryParse(widget.property.location[1]);
      _longitude = double.tryParse(widget.property.location[2]);
    }
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
  //  DATA LOADING
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
      _showSnackBar('Erreur de localisation', isError: true);
    }
  }

  // =========================================================
  //  AUTOCOMPLETE
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
  //  GESTION DES IMAGES
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
      }
    } catch (e) {
      _showSnackBar('Erreur de sélection d\'image', isError: true);
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
      }
    } catch (e) {
      _showSnackBar('Erreur de sélection d\'images', isError: true);
    }
  }

  Future<String?> _uploadMainImage() async {
    if (_selectedMainImage == null) return null;
    
    try {
      debugPrint('🔄 Upload de l\'image principale...');
      final url = await _mediaService.uploadSingleFile(_selectedMainImage!);
      debugPrint('✅ Image principale uploadée: $url');
      return url;
    } catch (e) {
      debugPrint('❌ Erreur upload image principale: $e');
      throw Exception('Erreur lors de l\'upload de l\'image principale: $e');
    }
  }

  Future<List<String>> _uploadOtherImages() async {
    if (_selectedOtherImages.isEmpty) return [];
    
    final urls = <String>[];
    try {
      debugPrint('🔄 Upload des images supplémentaires (${_selectedOtherImages.length})...');
      urls.addAll(await _mediaService.uploadFiles(_selectedOtherImages));
      debugPrint('✅ Images supplémentaires uploadées: $urls');
    } catch (e) {
      debugPrint('❌ Erreur upload images supplémentaires: $e');
      throw Exception('Erreur lors de l\'upload des images supplémentaires: $e');
    }
    return urls;
  }

  void _removeMainImage() => setState(() {
        _selectedMainImage = null;
      });

  void _removeOtherImage(int index) => setState(() {
        _selectedOtherImages.removeAt(index);
      });

  void _removeExistingOtherImage(int index) => setState(() {
        _existingOtherImages.removeAt(index);
      });

  // =========================================================
  //  MISE À JOUR DE LA PROPRIÉTÉ
  // =========================================================
  Future<void> _handleUpdateProperty() async {
    if (!_formKey.currentState!.validate()) return;
    
    final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    // Validations
    if (_selectedTown == null) {
      _showSnackBar('Veuillez sélectionner une ville', isError: true);
      return;
    }
    if (_selectedCategory == null) {
      _showSnackBar('Veuillez sélectionner une catégorie', isError: true);
      return;
    }
    if (accessToken == null) {
      _showSnackBar('Vous devez être connecté', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    String? mainImageUrl;
    List<String> otherImagesUrls = [];

    try {
      // ÉTAPE 1: Upload des nouvelles images si sélectionnées
      if (_selectedMainImage != null || _selectedOtherImages.isNotEmpty) {
        debugPrint('🚀 Début de l\'upload des images...');
        setState(() => _isUploadingImages = true);
        
        if (_selectedMainImage != null) {
          mainImageUrl = await _uploadMainImage();
        }
        
        if (_selectedOtherImages.isNotEmpty) {
          otherImagesUrls = await _uploadOtherImages();
        }
        
        setState(() => _isUploadingImages = false);
        debugPrint('✅ Upload des images terminé');
      }

      // ÉTAPE 2: Préparation des données de mise à jour
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
        "main_image": mainImageUrl ?? widget.property.mainImage,
        "other_images": [
          ..._existingOtherImages,
          ...otherImagesUrls,
        ],
        "location": [
          _addressController.text,
          _latitude?.toString() ?? (widget.property.location.length > 1 ? widget.property.location[1] : ""),
          _longitude?.toString() ?? (widget.property.location.length > 2 ? widget.property.location[2] : "")
        ],
        "owner_id": widget.property.ownerId,
        "town_id": _selectedTown!.id,
        "category_property_id": _selectedCategory!.id,
        "certified": widget.property.certified,
        "has_internal_kitchen": _hasInternalKitchen,
        "has_external_kitchen": _hasExternalKitchen,
        "has_a_parking": _hasAParking,
        "has_air_conditioning": _hasAirConditioning,
        "has_security_guards": _hasSecurityGuards,
        "has_balcony": _hasBalcony,
        "has_send_verified_request": widget.property.hasSendVerifiedRequest,
        // "has_send_verified_request": false, // Valeur par défaut
        "water_supply": _selectedWaterSupply,
        "electrical_connection": _selectedElectricalConnection,
        "status": _selectedStatus,
      };

      debugPrint('🚀 Mise à jour de la propriété...');
      debugPrint('📋 Données envoyées: $propertyData');

      await _propertyService.updateProperty(widget.property.id, propertyData, accessToken);

      if (mounted) {
        _showSnackBar('Propriété mise à jour avec succès');
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour: $e');
      if (mounted) {
        _showSnackBar('Erreur lors de la mise à jour: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isUploadingImages = false;
        });
      }
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
  //  WIDGETS
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
    final currentImageUrl = widget.property.mainImage;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppTranslations.get('main_image', locale, 'Image principale')}',
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
                // Nouvelle image sélectionnée
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
                const SizedBox(height: 12),
                if (_isUploadingImages)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        'Upload en cours...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _removeMainImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text('Supprimer la nouvelle image'),
                ),
              ] else ...[
                // Image actuelle
                Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(currentImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Image actuelle',
                  style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickMainImage,
                icon: const Icon(Icons.photo_library),
                label: Text('Changer l\'image principale'),
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
          '${AppTranslations.get('additional_images', locale, 'Images supplémentaires')}',
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
              // Images existantes
              if (_existingOtherImages.isNotEmpty) ...[
                Text(
                  'Images actuelles:',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingOtherImages.length,
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
                                  image: NetworkImage(_existingOtherImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeExistingOtherImage(index),
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
                const SizedBox(height: 16),
              ],
              
              // Nouvelles images sélectionnées
              if (_selectedOtherImages.isNotEmpty) ...[
                Text(
                  'Nouvelles images:',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
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
                if (_isUploadingImages)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        'Upload des images en cours...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
              ],
              
              // Bouton d'ajout
              OutlinedButton.icon(
                onPressed: _pickOtherImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text('Ajouter des images'),
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
    final currentLocation = widget.property.location.isNotEmpty ? widget.property.location[0] : 'Non définie';
    final currentCoords = widget.property.location.length >= 3 
        ? 'Lat: ${widget.property.location[1]}, Lng: ${widget.property.location[2]}'
        : 'Coordonnées non disponibles';

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
              // Localisation actuelle
              Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Localisation actuelle:'),
                        Text(
                          currentLocation,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          currentCoords,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Nouvelle localisation
              if (_userPosition != null) ...[
                Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nouvelle position détectée'),
                          Text(
                            'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
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
                      child: Text('Utiliser la position actuelle ou définir manuellement'),
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
                    ? 'Détection...'
                    : 'Utiliser ma position actuelle'),
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
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(Locale locale) {
    return ElevatedButton(
      onPressed: (_isSubmitting || _isUploadingImages) ? null : _handleUpdateProperty,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isSubmitting || _isUploadingImages
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  _isUploadingImages 
                    ? 'Upload des images...'
                    : 'Mise à jour en cours...',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            )
          : Text(
              'Mettre à jour la propriété',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
          title: Text('Modifier la propriété'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Aide'),
                  content: Text('Modifiez les informations de votre propriété. Les champs marqués d\'un * sont obligatoires.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
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
                _buildSectionTitle('Informations de base'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre *',
                    hintText: 'Ex: Belle maison moderne...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le titre est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Décrivez votre propriété...',
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La description est requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Adresse *',
                    hintText: 'Adresse complète de la propriété',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'adresse est requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Characteristics
                _buildSectionTitle('Caractéristiques'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _monthlyPriceController,
                        decoration: InputDecoration(
                          labelText: 'Prix mensuel (XOF) *',
                          hintText: '50000',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le prix est requis';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Prix invalide';
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
                          labelText: 'Surface (m²) *',
                          hintText: '120',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La surface est requise';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Surface invalide';
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
                          labelText: 'Chambres *',
                          hintText: '3',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est requis';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Nombre invalide';
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
                          labelText: 'Salles de bain *',
                          hintText: '2',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est requis';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Nombre invalide';
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
                          labelText: 'Salons *',
                          hintText: '1',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est requis';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Nombre invalide';
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
                          labelText: 'Numéro de compartiment *',
                          hintText: '5',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est requis';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Services & status
                _buildSectionTitle('Services et Statut'),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Alimentation en eau',
                  value: _selectedWaterSupply,
                  items: _getWaterSupplyOptions(locale),
                  onChanged: (v) => setState(() => _selectedWaterSupply = v!),
                  locale: locale.languageCode,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Connexion électrique',
                  value: _selectedElectricalConnection,
                  items: _getElectricalConnectionOptions(locale),
                  onChanged: (v) => setState(() => _selectedElectricalConnection = v!),
                  locale: locale.languageCode,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Statut',
                  value: _selectedStatus,
                  items: _getStatusOptions(locale),
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                  locale: locale.languageCode,
                ),
                const SizedBox(height: 24),

                // Location
                _buildSectionTitle('Localisation'),
                const SizedBox(height: 16),
                _buildTownAutocomplete(locale),
                const SizedBox(height: 16),
                _buildCategoryAutocomplete(locale),
                const SizedBox(height: 16),
                _buildLocationSection(locale),
                const SizedBox(height: 24),

                // Images
                _buildSectionTitle('Images'),
                const SizedBox(height: 16),
                _buildMainImageSection(locale),
                const SizedBox(height: 16),
                _buildOtherImagesSection(locale),
                const SizedBox(height: 24),

                // Equipment
                _buildEquipmentSection(locale),
                const SizedBox(height: 32),

                // Submit
                _buildSubmitButton(locale),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}