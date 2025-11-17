// // lib/pages/profile_page.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../providers/settings_provider.dart';
// import '../constants/app_themes.dart';
// import '../constants/app_translations.dart';
// import '../models/user.dart';
// import '../models/town.dart' as town_model;
// import '../services/town_service.dart';
// import '../services/media_service.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final _formKey = GlobalKey<FormState>();
//   final _passwordFormKey = GlobalKey<FormState>();

//   // Contrôleurs pour l'édition du profil
//   late TextEditingController _usernameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _emailController;
//   late TextEditingController _birthdayController;

//   // Variables pour le genre
//   String? _selectedGender;
//   final List<String> _genders = ['M', 'F'];

//   // Variables pour l'autocomplete des villes
//   final TownService _townService = TownService();
//   final TextEditingController _townSearchController = TextEditingController();
//   List<town_model.Town> _filteredTowns = [];
//   town_model.Town? _selectedTown;
//   bool _isSearchingTowns = false;
//   bool _showTownDropdown = false;

//   // Variables pour l'upload d'image
//   final MediaService _mediaService = MediaService();
//   final ImagePicker _imagePicker = ImagePicker();
//   File? _selectedImage;
//   String? _uploadedImageUrl;
//   bool _isUploadingImage = false;

//   // Contrôleurs pour le changement de mot de passe
//   final _currentPasswordController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialiser les contrôleurs avec des valeurs vides
//     _usernameController = TextEditingController();
//     _phoneController = TextEditingController();
//     _emailController = TextEditingController();
//     _birthdayController = TextEditingController();
    
//     _tabController = TabController(length: 2, vsync: this);
//     _townSearchController.addListener(_onTownSearchChanged);
    
//     // Mettre à jour les contrôleurs après que le widget soit monté
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeControllers();
//     });
//   }

//   void _initializeControllers() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final user = authProvider.currentUser;
    
//     if (user != null) {
//       // Mettre à jour les textes des contrôleurs existants
//       _usernameController.text = user.username ?? '';
//       _phoneController.text = user.phone ?? '';
//       _emailController.text = user.email ?? '';
//       _birthdayController.text = user.birthday ?? '';
      
//       // Initialiser le genre
//       _selectedGender = user.gender;
      
//       // Initialiser la ville
//       if (user.town != null) {
//         _selectedTown = user.town;
//         _townSearchController.text = user.town!.name;
//       }
      
//       // Initialiser l'image
//       _uploadedImageUrl = user.image;
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // S'assurer que les contrôleurs sont à jour si l'utilisateur change
//     _initializeControllers();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _usernameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _birthdayController.dispose();
//     _townSearchController.dispose();
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   // === MÉTHODES POUR L'AUTOCOMPLETE DES VILLES ===

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
//       print('Erreur lors de la recherche: $e');
//     }
//   }

//   void _selectTown(town_model.Town town) {
//     setState(() {
//       _selectedTown = town;
//       _townSearchController.text = town.name;
//       _showTownDropdown = false;
//     });
//   }

//   void _clearTownSelection() {
//     setState(() {
//       _selectedTown = null;
//       _townSearchController.clear();
//       _showTownDropdown = false;
//     });
//   }

//   // === MÉTHODES POUR L'UPLOAD D'IMAGE ===

//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 80,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });
//         // Upload automatique de l'image
//         await _uploadImage();
//       }
//     } catch (e) {
//       _showErrorSnackbar('Erreur lors de la sélection de l\'image: $e');
//     }
//   }

//   Future<void> _takePhoto() async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 80,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });
//         // Upload automatique de l'image
//         await _uploadImage();
//       }
//     } catch (e) {
//       _showErrorSnackbar('Erreur lors de la prise de photo: $e');
//     }
//   }

//   Future<void> _uploadImage() async {
//     if (_selectedImage == null) return;

//     setState(() {
//       _isUploadingImage = true;
//     });

//     try {
//       final imageUrl = await _mediaService.uploadSingleFile(_selectedImage!);
//       setState(() {
//         _uploadedImageUrl = imageUrl;
//         _isUploadingImage = false;
//       });
      
//       _showSuccessSnackbar('Photo de profil uploadée avec succès');
//     } catch (e) {
//       setState(() {
//         _isUploadingImage = false;
//       });
//       _showErrorSnackbar('Erreur lors de l\'upload: $e');
//     }
//   }

//   void _removeImage() {
//     setState(() {
//       _selectedImage = null;
//       _uploadedImageUrl = null;
//     });
//   }

//   void _showErrorSnackbar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: AppThemes.getErrorColor(context),
//         ),
//       );
//     }
//   }

//   void _showSuccessSnackbar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: AppThemes.getSuccessColor(context),
//         ),
//       );
//     }
//   }

//   // Méthode pour formater la date
//   String _formatDate(String? dateString) {
//     if (dateString == null) return '';
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day}/${date.month}/${date.year}';
//     } catch (e) {
//       return dateString;
//     }
//   }

//   // Méthode pour formater le genre
//   String _formatGender(String? gender, Locale locale) {
//     if (gender == null) return AppTranslations.get('not_specified', locale, 'Non spécifié');
//     switch (gender) {
//       case 'M': return AppTranslations.get('male', locale, 'Masculin');
//       case 'F': return AppTranslations.get('female', locale, 'Féminin');
//       default: return gender;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.currentUser;

//     if (user == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(AppTranslations.get('profile', locale, 'Profil')),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 size: 64,
//                 color: Theme.of(context).colorScheme.error,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 AppTranslations.get('user_not_connected', locale, 'Utilisateur non connecté'),
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushReplacementNamed(context, '/login');
//                 },
//                 child: Text(AppTranslations.get('login', locale, 'Se connecter')),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return GestureDetector(
//       onTap: () {
//         if (_showTownDropdown) {
//           setState(() {
//             _showTownDropdown = false;
//           });
//         }
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(AppTranslations.get('profile', locale, 'Profil')),
//           bottom: TabBar(
//             controller: _tabController,
//             tabs: [
//               Tab(text: AppTranslations.get('information', locale, 'Informations')),
//               Tab(text: AppTranslations.get('edit_profile', locale, 'Modifier')),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             // Onglet 1: Informations du profil
//             _buildProfileInfoTab(context, user, locale, authProvider),
            
//             // Onglet 2: Édition du profil
//             _buildEditProfileTab(context, user, locale, authProvider),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileInfoTab(BuildContext context, User user, Locale locale, AuthProvider authProvider) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // En-tête avec photo de profil
//           Center(
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: user.image != null && user.image!.isNotEmpty
//                       ? NetworkImage(user.image!)
//                       : const AssetImage('assets/default_avatar.png') as ImageProvider,
//                   backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   user.username ?? 'N/A',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   user.email ?? 'N/A',
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                 ),
//                 if (user.role != null) ...[
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       user.role!.toUpperCase(),
//                       style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                         color: Theme.of(context).colorScheme.primary,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           const SizedBox(height: 32),

//           // Informations personnelles
//           _buildInfoSection(
//             context,
//             AppTranslations.get('personal_info', locale, 'Informations personnelles'),
//             [
//               _buildInfoItem(
//                 context,
//                 Icons.person,
//                 AppTranslations.get('username', locale, 'Nom d\'utilisateur'),
//                 user.username ?? 'N/A',
//               ),
//               _buildInfoItem(
//                 context,
//                 Icons.phone,
//                 AppTranslations.get('phone', locale, 'Téléphone'),
//                 user.phone ?? 'N/A',
//               ),
//               _buildInfoItem(
//                 context,
//                 Icons.email,
//                 AppTranslations.get('email', locale, 'Email'),
//                 user.email ?? 'N/A',
//               ),
//               _buildInfoItem(
//                 context,
//                 Icons.cake,
//                 AppTranslations.get('birthday', locale, 'Date de naissance'),
//                 _formatDate(user.birthday),
//               ),
//               _buildInfoItem(
//                 context,
//                 Icons.transgender,
//                 AppTranslations.get('gender', locale, 'Genre'),
//                 _formatGender(user.gender, locale),
//               ),
//               _buildInfoItem(
//                 context,
//                 Icons.badge,
//                 AppTranslations.get('role', locale, 'Rôle'),
//                 user.role ?? 'N/A',
//               ),
//               _buildInfoItem(
//                 context,
//                 Icons.verified_user,
//                 AppTranslations.get('status', locale, 'Statut'),
//                 user.active == true 
//                     ? AppTranslations.get('active', locale, 'Actif')
//                     : AppTranslations.get('inactive', locale, 'Inactif'),
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // Informations de localisation
//           if (user.town != null) 
//             _buildInfoSection(
//               context,
//               AppTranslations.get('location', locale, 'Localisation'),
//               [
//                 _buildInfoItem(
//                   context,
//                   Icons.location_city,
//                   AppTranslations.get('city', locale, 'Ville'),
//                   user.town?.name ?? 'N/A',
//                 ),
//                 if (user.town?.country != null)
//                   _buildInfoItem(
//                     context,
//                     Icons.flag,
//                     AppTranslations.get('country', locale, 'Pays'),
//                     user.town!.country!.name,
//                   ),
//               ],
//             ),

//           const SizedBox(height: 24),

//           // Statistiques
//           _buildInfoSection(
//             context,
//             AppTranslations.get('statistics', locale, 'Statistiques'),
//             [
//               _buildInfoItem(
//                 context,
//                 Icons.home,
//                 AppTranslations.get('properties_owned', locale, 'Propriétés possédées'),
//                 user.ownedProperties?.length.toString() ?? '0',
//               ),
//               _buildInfoItem(
//                 context,
//                 Icons.favorite,
//                 AppTranslations.get('favorites', locale, 'Favoris'),
//                 user.favorites?.length.toString() ?? '0',
//               ),
//               _buildInfoItem(
//                 context,
//                 Icons.report,
//                 AppTranslations.get('reports_made', locale, 'Signalisations faites'),
//                 user.reportedSignals?.length.toString() ?? '0',
//               ),
//             ],
//           ),

//           const SizedBox(height: 32),

//           // Bouton de rafraîchissement
//           if (authProvider.isLoading)
//             const Center(child: CircularProgressIndicator())
//           else
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   authProvider.fetchUserProfile().then((_) {
//                     // Re-initialiser les contrôleurs après le rafraîchissement
//                     _initializeControllers();
//                   });
//                 },
//                 icon: const Icon(Icons.refresh),
//                 label: Text(AppTranslations.get('refresh_data', locale, 'Rafraîchir les données')),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEditProfileTab(BuildContext context, User user, Locale locale, AuthProvider authProvider) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Section photo de profil
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     AppTranslations.get('profile_picture', locale, 'Photo de profil'),
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildImageUploadSection(locale),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Formulaire d'édition du profil
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       AppTranslations.get('edit_personal_info', locale, 'Modifier les informations personnelles'),
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _usernameController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('username', locale, 'Nom d\'utilisateur'),
//                         prefixIcon: const Icon(Icons.person),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return AppTranslations.get('username_required', locale, 'Le nom d\'utilisateur est requis');
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _phoneController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('phone', locale, 'Téléphone'),
//                         prefixIcon: const Icon(Icons.phone),
//                       ),
//                       keyboardType: TextInputType.phone,
//                     ),

//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('email', locale, 'Email'),
//                         prefixIcon: const Icon(Icons.email),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return AppTranslations.get('email_required', locale, 'L\'email est requis');
//                         }
//                         if (!value.contains('@')) {
//                           return AppTranslations.get('email_invalid', locale, 'Email invalide');
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _birthdayController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('birthday', locale, 'Date de naissance (YYYY-MM-DD)'),
//                         prefixIcon: const Icon(Icons.cake),
//                         hintText: '1990-01-01',
//                       ),
//                       onTap: () async {
//                         final DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(1900),
//                           lastDate: DateTime.now(),
//                         );
//                         if (picked != null) {
//                           _birthdayController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//                         }
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     DropdownButtonFormField<String>(
//                       value: _selectedGender,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('gender', locale, 'Genre'),
//                         prefixIcon: const Icon(Icons.transgender),
//                       ),
//                       items: _genders.map((String gender) {
//                         return DropdownMenuItem<String>(
//                           value: gender,
//                           child: Text(gender == 'M' 
//                             ? AppTranslations.get('male', locale, 'Masculin')
//                             : AppTranslations.get('female', locale, 'Féminin')
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           _selectedGender = newValue;
//                         });
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     _buildTownAutocomplete(locale),

//                     const SizedBox(height: 24),

//                     if (authProvider.isLoading)
//                       const Center(child: CircularProgressIndicator())
//                     else
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _updateProfile,
//                           child: Text(AppTranslations.get('save_changes', locale, 'Sauvegarder les modifications')),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Section changement de mot de passe
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _passwordFormKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       AppTranslations.get('change_password', locale, 'Changer le mot de passe'),
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _currentPasswordController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('current_password', locale, 'Mot de passe actuel'),
//                         prefixIcon: const Icon(Icons.lock),
//                       ),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return AppTranslations.get('current_password_required', locale, 'Le mot de passe actuel est requis');
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _newPasswordController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('new_password', locale, 'Nouveau mot de passe'),
//                         prefixIcon: const Icon(Icons.lock_outline),
//                       ),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return AppTranslations.get('new_password_required', locale, 'Le nouveau mot de passe est requis');
//                         }
//                         if (value.length < 6) {
//                           return AppTranslations.get('password_min_length', locale, 'Le mot de passe doit contenir au moins 6 caractères');
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _confirmPasswordController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('confirm_password', locale, 'Confirmer le mot de passe'),
//                         prefixIcon: const Icon(Icons.lock_reset),
//                       ),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return AppTranslations.get('confirm_password_required', locale, 'La confirmation du mot de passe est requise');
//                         }
//                         if (value != _newPasswordController.text) {
//                           return AppTranslations.get('passwords_not_match', locale, 'Les mots de passe ne correspondent pas');
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 24),

//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Theme.of(context).colorScheme.errorContainer,
//                           foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
//                         ),
//                         onPressed: _changePassword,
//                         child: Text(AppTranslations.get('change_password', locale, 'Changer le mot de passe')),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageUploadSection(Locale locale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Affichage de l'image sélectionnée ou placeholder
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               if (_selectedImage != null || _uploadedImageUrl != null) ...[
//                 // Image sélectionnée ou existante
//                 Stack(
//                   children: [
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(60),
//                         image: DecorationImage(
//                           image: _selectedImage != null
//                               ? FileImage(_selectedImage!)
//                               : NetworkImage(_uploadedImageUrl!) as ImageProvider,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     if (_isUploadingImage)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black54,
//                             borderRadius: BorderRadius.circular(60),
//                           ),
//                           child: const Center(
//                             child: CircularProgressIndicator(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 if (_uploadedImageUrl != null)
//                   Text(
//                     AppTranslations.get('upload_success', locale, 'Upload réussi ✓'),
//                     style: TextStyle(
//                       color: AppThemes.getSuccessColor(context),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _removeImage,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red.shade50,
//                         foregroundColor: Colors.red,
//                       ),
//                       icon: const Icon(Icons.delete, size: 18),
//                       label: Text(AppTranslations.get('remove', locale, 'Supprimer')),
//                     ),
//                   ],
//                 ),
//               ] else ...[
//                 // Aucune image sélectionnée
//                 Icon(
//                   Icons.person,
//                   size: 80,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   AppTranslations.get('no_image_selected', locale, 'Aucune photo sélectionnée'),
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//               ],
//               const SizedBox(height: 16),
              
//               // Boutons d'action
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: _pickImage,
//                       icon: const Icon(Icons.photo_library),
//                       label: Text(AppTranslations.get('choose_from_gallery', locale, 'Galerie')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: _takePhoto,
//                       icon: const Icon(Icons.camera_alt),
//                       label: Text(AppTranslations.get('take_photo', locale, 'Camera')),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTownAutocomplete(Locale locale) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: _townSearchController,
//           decoration: InputDecoration(
//             labelText: AppTranslations.get('town', locale, 'Ville'),
//             hintText: AppTranslations.get('search_town', locale, 'Rechercher une ville...'),
//             prefixIcon: const Icon(Icons.search, color: Colors.grey),
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

//   Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).colorScheme.primary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: children),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
//         await authProvider.updateProfile(
//           username: _usernameController.text,
//           phone: _phoneController.text,
//           email: _emailController.text,
//           birthday: _birthdayController.text.isNotEmpty ? _birthdayController.text : null,
//           gender: _selectedGender,
//           image: _uploadedImageUrl,
//           townId: _selectedTown?.id,
//         );

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(AppTranslations.get('profile_updated', context.read<SettingsProvider>().locale, 'Profil mis à jour avec succès')),
//               backgroundColor: AppThemes.getSuccessColor(context),
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Erreur: $e'),
//               backgroundColor: AppThemes.getErrorColor(context),
//             ),
//           );
//         }
//       }
//     }
//   }

//   void _changePassword() async {
//     if (_passwordFormKey.currentState!.validate()) {
//       try {
//         final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
//         await authProvider.changePassword(
//           currentPassword: _currentPasswordController.text,
//           newPassword: _newPasswordController.text,
//           confirmPassword: _confirmPasswordController.text,
//         );

//         // Vider les champs après succès
//         _currentPasswordController.clear();
//         _newPasswordController.clear();
//         _confirmPasswordController.clear();

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(AppTranslations.get('password_updated', context.read<SettingsProvider>().locale, 'Mot de passe mis à jour avec succès')),
//               backgroundColor: AppThemes.getSuccessColor(context),
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Erreur: $e'),
//               backgroundColor: AppThemes.getErrorColor(context),
//             ),
//           );
//         }
//       }
//     }
//   }
// }

// lib/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_themes.dart';
import '../constants/app_translations.dart';
import '../models/user.dart';
import '../models/town.dart' as town_model;
import '../services/town_service.dart';
import '../services/media_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Contrôleurs pour l'édition du profil
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _birthdayController;

  // Variables pour le genre
  String? _selectedGender;
  final List<String> _genders = ['M', 'F'];

  // Variables pour l'autocomplete des villes
  final TownService _townService = TownService();
  final TextEditingController _townSearchController = TextEditingController();
  List<town_model.Town> _filteredTowns = [];
  town_model.Town? _selectedTown;
  bool _isSearchingTowns = false;
  bool _showTownDropdown = false;

  // Variables pour l'upload d'image
  final MediaService _mediaService = MediaService();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  // Contrôleurs pour le changement de mot de passe
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Initialiser les contrôleurs avec des valeurs vides
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _birthdayController = TextEditingController();
    
    _tabController = TabController(length: 2, vsync: this);
    _townSearchController.addListener(_onTownSearchChanged);
    
    // Mettre à jour les contrôleurs après que le widget soit monté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      // Mettre à jour les textes des contrôleurs existants
      _usernameController.text = user.username ?? '';
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email ?? '';
      _birthdayController.text = user.birthday ?? '';
      
      // Initialiser le genre
      _selectedGender = user.gender;
      
      // Initialiser la ville
      if (user.town != null) {
        _selectedTown = user.town;
        _townSearchController.text = user.town!.name;
      }
      
      // Initialiser l'image
      _uploadedImageUrl = user.image;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // S'assurer que les contrôleurs sont à jour si l'utilisateur change
    _initializeControllers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _townSearchController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // === MÉTHODES POUR L'AUTOCOMPLETE DES VILLES ===

  Future<void> _loadAllTowns() async {
    try {
      final towns = await _townService.getAllTowns();
      setState(() {
        _filteredTowns = towns;
      });
    } catch (e) {
      print('Erreur lors du chargement des villes: $e');
    }
  }

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
      setState(() {
        _isSearchingTowns = false;
        _filteredTowns = [];
      });
      print('Erreur lors de la recherche: $e');
    }
  }

  void _selectTown(town_model.Town town) {
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

  // === MÉTHODES POUR L'UPLOAD D'IMAGE ===

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        // Upload automatique de l'image
        await _uploadImage();
      }
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la sélection de l\'image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        // Upload automatique de l'image
        await _uploadImage();
      }
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la prise de photo: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl = await _mediaService.uploadSingleFile(_selectedImage!);
      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploadingImage = false;
      });
      
      _showSuccessSnackbar('Photo de profil uploadée avec succès');
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      _showErrorSnackbar('Erreur lors de l\'upload: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
    });
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppThemes.getErrorColor(context),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppThemes.getSuccessColor(context),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Méthode pour formater la date
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Méthode pour formater le genre
  String _formatGender(String? gender, Locale locale) {
    if (gender == null) return AppTranslations.get('not_specified', locale, 'Non spécifié');
    switch (gender) {
      case 'M': return AppTranslations.get('male', locale, 'Masculin');
      case 'F': return AppTranslations.get('female', locale, 'Féminin');
      default: return gender;
    }
  }

  // === MÉTHODES POUR LA GESTION DU PROFIL ET MOT DE PASSE ===

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        await authProvider.updateProfile(
          username: _usernameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          birthday: _birthdayController.text.isNotEmpty ? _birthdayController.text : null,
          gender: _selectedGender,
          image: _uploadedImageUrl,
          townId: _selectedTown?.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.get('profile_updated', context.read<SettingsProvider>().locale, 'Profil mis à jour avec succès')),
              backgroundColor: AppThemes.getSuccessColor(context),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: AppThemes.getErrorColor(context),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  void _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        await authProvider.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

        // Vider les champs après succès
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppTranslations.get(
                  'password_updated', 
                  context.read<SettingsProvider>().locale, 
                  'Mot de passe mis à jour avec succès'
                ),
              ),
              backgroundColor: AppThemes.getSuccessColor(context),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur: ${e.toString()}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppThemes.getErrorColor(context),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppTranslations.get('profile', locale, 'Profil')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                AppTranslations.get('user_not_connected', locale, 'Utilisateur non connecté'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(AppTranslations.get('login', locale, 'Se connecter')),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_showTownDropdown) {
          setState(() {
            _showTownDropdown = false;
          });
        }
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppTranslations.get('profile', locale, 'Profil')),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppTranslations.get('information', locale, 'Informations')),
              Tab(text: AppTranslations.get('edit_profile', locale, 'Modifier')),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Onglet 1: Informations du profil
            _buildProfileInfoTab(context, user, locale, authProvider),
            
            // Onglet 2: Édition du profil
            _buildEditProfileTab(context, user, locale, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoTab(BuildContext context, User user, Locale locale, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec photo de profil
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.image != null && user.image!.isNotEmpty
                      ? NetworkImage(user.image!)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                  backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  user.username ?? 'N/A',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email ?? 'N/A',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                if (user.role != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role!.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Informations personnelles
          _buildInfoSection(
            context,
            AppTranslations.get('personal_info', locale, 'Informations personnelles'),
            [
              _buildInfoItem(
                context,
                Icons.person,
                AppTranslations.get('username', locale, 'Nom d\'utilisateur'),
                user.username ?? 'N/A',
              ),
              _buildInfoItem(
                context,
                Icons.phone,
                AppTranslations.get('phone', locale, 'Téléphone'),
                user.phone ?? 'N/A',
              ),
              _buildInfoItem(
                context,
                Icons.email,
                AppTranslations.get('email', locale, 'Email'),
                user.email ?? 'N/A',
              ),
              _buildInfoItem(
                context,
                Icons.cake,
                AppTranslations.get('birthday', locale, 'Date de naissance'),
                _formatDate(user.birthday),
              ),
              _buildInfoItem(
                context,
                Icons.transgender,
                AppTranslations.get('gender', locale, 'Genre'),
                _formatGender(user.gender, locale),
              ),
              _buildInfoItem(
                context,
                Icons.badge,
                AppTranslations.get('role', locale, 'Rôle'),
                user.role ?? 'N/A',
              ),
              _buildInfoItem(
                context,
                Icons.verified_user,
                AppTranslations.get('status', locale, 'Statut'),
                user.active == true 
                    ? AppTranslations.get('active', locale, 'Actif')
                    : AppTranslations.get('inactive', locale, 'Inactif'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Informations de localisation
          if (user.town != null) 
            _buildInfoSection(
              context,
              AppTranslations.get('location', locale, 'Localisation'),
              [
                _buildInfoItem(
                  context,
                  Icons.location_city,
                  AppTranslations.get('city', locale, 'Ville'),
                  user.town?.name ?? 'N/A',
                ),
                if (user.town?.country != null)
                  _buildInfoItem(
                    context,
                    Icons.flag,
                    AppTranslations.get('country', locale, 'Pays'),
                    user.town!.country!.name,
                  ),
              ],
            ),

          const SizedBox(height: 24),

          // Statistiques
          _buildInfoSection(
            context,
            AppTranslations.get('statistics', locale, 'Statistiques'),
            [
              _buildInfoItem(
                context,
                Icons.home,
                AppTranslations.get('properties_owned', locale, 'Propriétés possédées'),
                user.ownedProperties?.length.toString() ?? '0',
              ),
              _buildInfoItem(
                context,
                Icons.favorite,
                AppTranslations.get('favorites', locale, 'Favoris'),
                user.favorites?.length.toString() ?? '0',
              ),
              _buildInfoItem(
                context,
                Icons.report,
                AppTranslations.get('reports_made', locale, 'Signalisations faites'),
                user.reportedSignals?.length.toString() ?? '0',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Bouton de rafraîchissement
          if (authProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  authProvider.fetchUserProfile().then((_) {
                    // Re-initialiser les contrôleurs après le rafraîchissement
                    _initializeControllers();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppTranslations.get('refresh_data', locale, 'Rafraîchir les données')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditProfileTab(BuildContext context, User user, Locale locale, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Section photo de profil
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.get('profile_picture', locale, 'Photo de profil'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildImageUploadSection(locale),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Formulaire d'édition du profil
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.get('edit_personal_info', locale, 'Modifier les informations personnelles'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('username', locale, 'Nom d\'utilisateur'),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.get('username_required', locale, 'Le nom d\'utilisateur est requis');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('phone', locale, 'Téléphone'),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('email', locale, 'Email'),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.get('email_required', locale, 'L\'email est requis');
                        }
                        if (!value.contains('@')) {
                          return AppTranslations.get('email_invalid', locale, 'Email invalide');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _birthdayController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('birthday', locale, 'Date de naissance (YYYY-MM-DD)'),
                        prefixIcon: const Icon(Icons.cake),
                        hintText: '1990-01-01',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _birthdayController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('gender', locale, 'Genre'),
                        prefixIcon: const Icon(Icons.transgender),
                      ),
                      items: _genders.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender == 'M' 
                            ? AppTranslations.get('male', locale, 'Masculin')
                            : AppTranslations.get('female', locale, 'Féminin')
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTownAutocomplete(locale),

                    const SizedBox(height: 24),

                    if (authProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          child: Text(AppTranslations.get('save_changes', locale, 'Sauvegarder les modifications')),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Section changement de mot de passe
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.get('change_password', locale, 'Changer le mot de passe'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('current_password', locale, 'Mot de passe actuel'),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.get('current_password_required', locale, 'Le mot de passe actuel est requis');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('new_password', locale, 'Nouveau mot de passe'),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.get('new_password_required', locale, 'Le nouveau mot de passe est requis');
                        }
                        if (value.length < 6) {
                          return AppTranslations.get('password_min_length', locale, 'Le mot de passe doit contenir au moins 6 caractères');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('confirm_password', locale, 'Confirmer le mot de passe'),
                        prefixIcon: const Icon(Icons.lock_reset),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.get('confirm_password_required', locale, 'La confirmation du mot de passe est requise');
                        }
                        if (value != _newPasswordController.text) {
                          return AppTranslations.get('passwords_not_match', locale, 'Les mots de passe ne correspondent pas');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.errorContainer,
                          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        onPressed: authProvider.isLoading ? null : _changePassword,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(AppTranslations.get('change_password', locale, 'Changer le mot de passe')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(Locale locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Affichage de l'image sélectionnée ou placeholder
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_selectedImage != null || _uploadedImageUrl != null) ...[
                // Image sélectionnée ou existante
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        image: DecorationImage(
                          image: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : NetworkImage(_uploadedImageUrl!) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_uploadedImageUrl != null && !_isUploadingImage)
                  Text(
                    AppTranslations.get('upload_success', locale, 'Upload réussi ✓'),
                    style: TextStyle(
                      color: AppThemes.getSuccessColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _removeImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.delete, size: 18),
                      label: Text(AppTranslations.get('remove', locale, 'Supprimer')),
                    ),
                  ],
                ),
              ] else ...[
                // Aucune image sélectionnée
                Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  AppTranslations.get('no_image_selected', locale, 'Aucune photo sélectionnée'),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 16),
              
              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: Text(AppTranslations.get('choose_from_gallery', locale, 'Galerie')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(AppTranslations.get('take_photo', locale, 'Camera')),
                    ),
                  ),
                ],
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
            labelText: AppTranslations.get('town', locale, 'Ville'),
            hintText: AppTranslations.get('search_town', locale, 'Rechercher une ville...'),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
            if (_townSearchController.text.isEmpty) {
              _loadAllTowns();
            }
            setState(() {
              _showTownDropdown = true;
            });
          },
        ),
        
        if (_showTownDropdown && _filteredTowns.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredTowns.length,
              itemBuilder: (context, index) {
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
        
        if (_showTownDropdown && _townSearchController.text.isNotEmpty && _filteredTowns.isEmpty && !_isSearchingTowns)
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppTranslations.get('no_town_found', locale, 'Aucune ville trouvée'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}