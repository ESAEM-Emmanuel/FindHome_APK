// // lib/pages/profile_page.dart
// // VERSION MODERNE 2025 – palette officielle + Material 3
// // Logique inchangée, seule l’UI est revue.

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

// class _ProfilePageState extends State<ProfilePage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final _formKey = GlobalKey<FormState>();
//   final _passwordFormKey = GlobalKey<FormState>();

//   // Contrôleurs
//   late TextEditingController _usernameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _emailController;
//   late TextEditingController _birthdayController;

//   // Genre
//   String? _selectedGender;
//   final List<String> _genders = ['M', 'F'];

//   // Villes
//   final TownService _townService = TownService();
//   final TextEditingController _townSearchController = TextEditingController();
//   List<town_model.Town> _filteredTowns = [];
//   town_model.Town? _selectedTown;
//   bool _isSearchingTowns = false;
//   bool _showTownDropdown = false;

//   // Image
//   final MediaService _mediaService = MediaService();
//   final ImagePicker _imagePicker = ImagePicker();
//   File? _selectedImage;
//   String? _uploadedImageUrl;
//   bool _isUploadingImage = false;

//   // Mot de passe
//   final _currentPasswordController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _usernameController = TextEditingController();
//     _phoneController = TextEditingController();
//     _emailController = TextEditingController();
//     _birthdayController = TextEditingController();

//     _tabController = TabController(length: 2, vsync: this);
//     _townSearchController.addListener(_onTownSearchChanged);

//     WidgetsBinding.instance.addPostFrameCallback((_) => _initializeControllers());
//   }

//   void _initializeControllers() {
//     final user = context.read<AuthProvider>().currentUser;
//     if (user == null) return;

//     _usernameController.text = user.username ?? '';
//     _phoneController.text = user.phone ?? '';
//     _emailController.text = user.email ?? '';
//     _birthdayController.text = user.birthday ?? '';
//     _selectedGender = user.gender;
//     if (user.town != null) {
//       _selectedTown = user.town;
//       _townSearchController.text = user.town!.name;
//     }
//     _uploadedImageUrl = user.image;
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

//   // =========================================================
//   //  VILLES
//   // =========================================================
//   Future<void> _loadAllTowns() async {
//     try {
//       final towns = await _townService.getAllTowns();
//       setState(() => _filteredTowns = towns);
//     } catch (e) {
//       debugPrint('Erreur chargement villes: $e');
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
//       final res = await _townService.searchTowns(query);
//       setState(() {
//         _filteredTowns = res.records;
//         _isSearchingTowns = false;
//       });
//     } catch (e) {
//       setState(() => _isSearchingTowns = false);
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

//   // =========================================================
//   //  IMAGE
//   // =========================================================
//   Future<void> _pickImage() async {
//     final XFile? file = await _imagePicker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 800,
//       maxHeight: 800,
//       imageQuality: 80,
//     );
//     if (file != null) {
//       setState(() => _selectedImage = File(file.path));
//       await _uploadImage();
//     }
//   }

//   Future<void> _takePhoto() async {
//     final XFile? file = await _imagePicker.pickImage(
//       source: ImageSource.camera,
//       maxWidth: 800,
//       maxHeight: 800,
//       imageQuality: 80,
//     );
//     if (file != null) {
//       setState(() => _selectedImage = File(file.path));
//       await _uploadImage();
//     }
//   }

//   Future<void> _uploadImage() async {
//     if (_selectedImage == null) return;
//     setState(() => _isUploadingImage = true);
//     try {
//       final url = await _mediaService.uploadSingleFile(_selectedImage!);
//       setState(() {
//         _uploadedImageUrl = url;
//         _isUploadingImage = false;
//       });
//       _showSuccessSnackbar('Photo uploadée');
//     } catch (e) {
//       setState(() => _isUploadingImage = false);
//       _showErrorSnackbar('Erreur upload');
//     }
//   }

//   void _removeImage() => setState(() {
//         _selectedImage = null;
//         _uploadedImageUrl = null;
//       });

//   // =========================================================
//   //  MISE À JOUR
//   // =========================================================
//   void _updateProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//     final auth = context.read<AuthProvider>();
//     try {
//       await auth.updateProfile(
//         username: _usernameController.text,
//         phone: _phoneController.text,
//         email: _emailController.text,
//         birthday: _birthdayController.text,
//         gender: _selectedGender,
//         image: _uploadedImageUrl,
//         townId: _selectedTown?.id,
//       );
//       _showSuccessSnackbar('Profil mis à jour');
//     } catch (e) {
//       _showErrorSnackbar(e.toString());
//     }
//   }

//   void _changePassword() async {
//     if (!_passwordFormKey.currentState!.validate()) return;
//     final auth = context.read<AuthProvider>();
//     try {
//       await auth.changePassword(
//         currentPassword: _currentPasswordController.text,
//         newPassword: _newPasswordController.text,
//         confirmPassword: _confirmPasswordController.text,
//       );
//       _currentPasswordController.clear();
//       _newPasswordController.clear();
//       _confirmPasswordController.clear();
//       _showSuccessSnackbar('Mot de passe modifié');
//     } catch (e) {
//       _showErrorSnackbar(e.toString());
//     }
//   }

//   // =========================================================
//   //  HELPERS
//   // =========================================================
//   void _showErrorSnackbar(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: AppThemes.getErrorColor(context)),
//     );
//   }

//   void _showSuccessSnackbar(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: AppThemes.getSuccessColor(context)),
//     );
//   }

//   String _formatDate(String? d) {
//     if (d == null) return '';
//     try {
//       final date = DateTime.parse(d);
//       return '${date.day}/${date.month}/${date.year}';
//     } catch (_) {
//       return d;
//     }
//   }

//   String _genderLabel(String? g, Locale l) {
//     if (g == 'M') return AppTranslations.get('male', l, 'Masculin');
//     if (g == 'F') return AppTranslations.get('female', l, 'Féminin');
//     return AppTranslations.get('not_specified', l, 'Non spécifié');
//   }

//   // =========================================================
//   //  UI – INFORMATIONS
//   // =========================================================
//   Widget _buildInfoTab(User u, Locale l) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Photo + nom
//           Center(
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: (u.image != null && u.image!.isNotEmpty)
//                       ? NetworkImage(u.image!)
//                       : const AssetImage('assets/default_avatar.png') as ImageProvider,
//                   backgroundColor: primaryColor1.withOpacity(.1),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(u.username ?? 'N/A',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
//                 Text(u.email ?? 'N/A',
//                     style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
//                 if (u.role != null) ...[
//                   const SizedBox(height: 6),
//                   Chip(
//                     label: Text(u.role!.toUpperCase()),
//                     backgroundColor: accentColor1.withOpacity(.15),
//                     labelStyle: TextStyle(color: accentColor1, fontSize: 12),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Infos
//           _infoCard(AppTranslations.get('personal_info', l, 'Infos personnelles'), [
//             _infoRow(Icons.person, AppTranslations.get('username', l, 'Nom'), u.username ?? 'N/A'),
//             _infoRow(Icons.phone, AppTranslations.get('phone', l, 'Téléphone'), u.phone ?? 'N/A'),
//             _infoRow(Icons.email, 'Email', u.email ?? 'N/A'),
//             _infoRow(Icons.cake, AppTranslations.get('birthday', l, 'Anniversaire'), _formatDate(u.birthday)),
//             _infoRow(Icons.transgender, AppTranslations.get('gender', l, 'Genre'), _genderLabel(u.gender, l)),
//           ]),

//           const SizedBox(height: 16),

//           // Localisation
//           if (u.town != null)
//             _infoCard(AppTranslations.get('location', l, 'Localisation'), [
//               _infoRow(Icons.location_city, AppTranslations.get('town', l, 'Ville'), u.town!.name),
//               if (u.town?.country != null) _infoRow(Icons.flag, AppTranslations.get('country', l, 'Pays'), u.town!.country!.name),
//             ]),

//           const SizedBox(height: 16),

//           // Stats
//           _infoCard(AppTranslations.get('statistics', l, 'Statistiques'), [
//             _infoRow(Icons.home, AppTranslations.get('properties_owned', l, 'Propriétés'), '${u.ownedProperties?.length ?? 0}'),
//             _infoRow(Icons.favorite, AppTranslations.get('favorites', l, 'Favoris'), '${u.favorites?.length ?? 0}'),
//             _infoRow(Icons.report, AppTranslations.get('reports_made', l, 'Signalements'), '${u.reportedSignals?.length ?? 0}'),
//           ]),

//           const SizedBox(height: 24),

//           // Rafraîchir
//           Center(
//             child: ElevatedButton.icon(
//               // onPressed: () => authProvider.fetchUserProfile().then((_) => _initializeControllers()),
//               onPressed: () => context.read<AuthProvider>().fetchUserProfile().then((_) => _initializeControllers()),
//               icon: const Icon(Icons.refresh),
//               label: Text(AppTranslations.get('refresh_data', l, 'Rafraîchir')),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _infoCard(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title,
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: primaryColor1,
//                 )),
//         const SizedBox(height: 8),
//         Card(
//           margin: EdgeInsets.zero,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: children),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _infoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: primaryColor1),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: TextStyle(
//                         fontSize: 12,
//                         color: Theme.of(context).colorScheme.secondary)),
//                 Text(value,
//                     style: const TextStyle(
//                         fontSize: 14, fontWeight: FontWeight.w500)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // =========================================================
//   //  UI – ÉDITION
//   // =========================================================
//   Widget _buildEditTab(User u, Locale l) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Photo
//           Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(AppTranslations.get('profile_picture', l, 'Photo de profil'),
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor1)),
//                   const SizedBox(height: 16),
//                   _imageSection(l),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Formulaire
//           Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     Text(AppTranslations.get('edit_personal_info', l, 'Modifier les infos'),
//                         style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor1)),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _usernameController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('username', l, 'Nom d’utilisateur'),
//                         prefixIcon: const Icon(Icons.person, color: primaryColor1),
//                       ),
//                       validator: (v) => v!.isEmpty ? AppTranslations.get('username_required', l, 'Requis') : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _phoneController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('phone', l, 'Téléphone'),
//                         prefixIcon: const Icon(Icons.phone, color: primaryColor1),
//                       ),
//                       keyboardType: TextInputType.phone,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Email',
//                         prefixIcon: const Icon(Icons.email, color: primaryColor1),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (v) => v!.contains('@') ? null : AppTranslations.get('email_invalid', l, 'Email invalide'),
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _birthdayController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('birthday', l, 'Date de naissance'),
//                         prefixIcon: const Icon(Icons.cake, color: primaryColor1),
//                         hintText: 'YYYY-MM-DD',
//                       ),
//                       onTap: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(1900),
//                           lastDate: DateTime.now(),
//                         );
//                         if (picked != null) {
//                           _birthdayController.text =
//                               "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     DropdownButtonFormField<String>(
//                       value: _selectedGender,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('gender', l, 'Genre'),
//                         prefixIcon: const Icon(Icons.transgender, color: primaryColor1),
//                       ),
//                       items: _genders
//                           .map((g) => DropdownMenuItem(
//                               value: g,
//                               child: Text(g == 'M'
//                                   ? AppTranslations.get('male', l, 'Masculin')
//                                   : AppTranslations.get('female', l, 'Féminin'))))
//                           .toList(),
//                       onChanged: (v) => setState(() => _selectedGender = v),
//                     ),
//                     const SizedBox(height: 16),
//                     _townAutocomplete(l),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryColor1,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         onPressed: context.watch<AuthProvider>().isLoading ? null : _updateProfile,
//                         child: context.watch<AuthProvider>().isLoading
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                               )
//                             : Text(AppTranslations.get('save_changes', l, 'Sauvegarder')),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Changement de mot de passe
//           Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _passwordFormKey,
//                 child: Column(
//                   children: [
//                     Text(AppTranslations.get('change_password', l, 'Changer le mot de passe'),
//                         style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor1)),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _currentPasswordController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('current_password', l, 'Actuel'),
//                         prefixIcon: const Icon(Icons.lock, color: primaryColor1),
//                       ),
//                       obscureText: true,
//                       validator: (v) => v!.isEmpty ? AppTranslations.get('current_password_required', l, 'Requis') : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _newPasswordController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('new_password', l, 'Nouveau'),
//                         prefixIcon: const Icon(Icons.lock_outline, color: primaryColor1),
//                       ),
//                       obscureText: true,
//                       validator: (v) => v!.length < 6 ? AppTranslations.get('password_min_length', l, '6 caractères min') : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _confirmPasswordController,
//                       decoration: InputDecoration(
//                         labelText: AppTranslations.get('confirm_password', l, 'Confirmation'),
//                         prefixIcon: const Icon(Icons.lock_reset, color: primaryColor1),
//                       ),
//                       obscureText: true,
//                       validator: (v) => v != _newPasswordController.text ? AppTranslations.get('passwords_not_match', l, 'Pas identique') : null,
//                     ),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: errorColor1,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         onPressed: context.watch<AuthProvider>().isLoading ? null : _changePassword,
//                         child: context.watch<AuthProvider>().isLoading
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                               )
//                             : Text(AppTranslations.get('change_password', l, 'Changer')),
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

//   // =========================================================
//   //  WIDGETS COMPOSANTS
//   // =========================================================
//   Widget _imageSection(Locale l) {
//     return Column(
//       children: [
//         if (_selectedImage != null || _uploadedImageUrl != null) ...[
//           Stack(
//             children: [
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   image: DecorationImage(
//                     image: _selectedImage != null
//                         ? FileImage(_selectedImage!)
//                         : NetworkImage(_uploadedImageUrl!) as ImageProvider,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               if (_isUploadingImage)
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Center(
//                       child: CircularProgressIndicator(color: Colors.white),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (_uploadedImageUrl != null && !_isUploadingImage)
//             Text(
//               AppTranslations.get('upload_success', l, 'Upload réussi ✓'),
//               style: TextStyle(color: successColor1, fontWeight: FontWeight.bold),
//             ),
//           const SizedBox(height: 12),
//           ElevatedButton.icon(
//             onPressed: _removeImage,
//             icon: const Icon(Icons.delete, size: 18),
//             label: Text(AppTranslations.get('remove', l, 'Supprimer')),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: errorColor1.withOpacity(.05),
//               foregroundColor: errorColor1,
//             ),
//           ),
//         ] else ...[
//           Icon(Icons.person, size: 80, color: Colors.grey.shade400),
//           const SizedBox(height: 12),
//           Text(AppTranslations.get('no_image_selected', l, 'Aucune photo'),
//               style: TextStyle(color: Colors.grey.shade600)),
//         ],
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Expanded(
//               child: OutlinedButton.icon(
//                 onPressed: _pickImage,
//                 icon: const Icon(Icons.photo_library),
//                 label: Text(AppTranslations.get('gallery', l, 'Galerie')),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: OutlinedButton.icon(
//                 onPressed: _takePhoto,
//                 icon: const Icon(Icons.camera_alt),
//                 label: Text(AppTranslations.get('camera', l, 'Caméra')),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _townAutocomplete(Locale l) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: _townSearchController,
//           decoration: InputDecoration(
//             labelText: AppTranslations.get('town', l, 'Ville'),
//             prefixIcon: const Icon(Icons.location_city, color: primaryColor1),
//             suffixIcon: _selectedTown != null
//                 ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearTownSelection)
//                 : _isSearchingTowns
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : null,
//           ),
//           onTap: () {
//             if (_townSearchController.text.isEmpty) _loadAllTowns();
//             setState(() => _showTownDropdown = true);
//           },
//         ),
//         if (_showTownDropdown && _filteredTowns.isNotEmpty)
//           Container(
//             margin: const EdgeInsets.only(top: 4),
//             constraints: const BoxConstraints(maxHeight: 200),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surface,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
//             ),
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: _filteredTowns.length,
//               itemBuilder: (_, i) {
//                 final t = _filteredTowns[i];
//                 return ListTile(
//                   leading: const Icon(Icons.location_city, size: 20),
//                   title: Text(t.name),
//                   subtitle: Text(t.country.name),
//                   onTap: () => _selectTown(t),
//                   dense: true,
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }

//   // =========================================================
//   //  BUILD PRINCIPAL
//   // =========================================================
//   @override
//   Widget build(BuildContext context) {
//     final locale = context.watch<SettingsProvider>().locale;
//     final authProvider = context.watch<AuthProvider>();
//     final user = authProvider.currentUser;

//     if (user == null) {
//       return Scaffold(
//         appBar: AppBar(title: Text(AppTranslations.get('profile', locale, 'Profil'))),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 64, color: errorColor1),
//               const SizedBox(height: 16),
//               Text(AppTranslations.get('user_not_connected', locale, 'Non connecté'),
//                   style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
//                 child: Text(AppTranslations.get('login', locale, 'Se connecter')),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return GestureDetector(
//       onTap: () {
//         if (_showTownDropdown) setState(() => _showTownDropdown = false);
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(AppTranslations.get('profile', locale, 'Profil')),
//           bottom: TabBar(
//             controller: _tabController,
//             indicatorColor: accentColor1,
//             labelColor: accentColor1,
//             unselectedLabelColor: Colors.white,
//             tabs: [
//               Tab(text: AppTranslations.get('information', locale, 'Informations')),
//               Tab(text: AppTranslations.get('edit_profile', locale, 'Modifier')),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _buildInfoTab(user, locale),
//             _buildEditTab(user, locale),
//           ],
//         ),
//       ),
//     );
//   }
// }

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

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Contrôleurs
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _birthdayController;

  // Genre
  String? _selectedGender;
  final List<String> _genders = ['M', 'F'];

  // Villes
  final TownService _townService = TownService();
  final TextEditingController _townSearchController = TextEditingController();
  List<town_model.Town> _filteredTowns = [];
  town_model.Town? _selectedTown;
  bool _isSearchingTowns = false;
  bool _showTownDropdown = false;

  // Image
  final MediaService _mediaService = MediaService();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  bool _hasNewImage = false; // Nouveau flag pour suivre si une nouvelle image a été sélectionnée

  // Mot de passe
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _birthdayController = TextEditingController();

    _tabController = TabController(length: 2, vsync: this);
    _townSearchController.addListener(_onTownSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeControllers());
  }

  void _initializeControllers() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    _usernameController.text = user.username ?? '';
    _phoneController.text = user.phone ?? '';
    _emailController.text = user.email ?? '';
    _birthdayController.text = user.birthday ?? '';
    _selectedGender = user.gender;
    if (user.town != null) {
      _selectedTown = user.town;
      _townSearchController.text = user.town!.name;
    }
    _uploadedImageUrl = user.image;
    _hasNewImage = false; // Réinitialiser le flag lors de l'initialisation
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

  // =========================================================
  //  VILLES
  // =========================================================
  Future<void> _loadAllTowns() async {
    try {
      final towns = await _townService.getAllTowns();
      setState(() => _filteredTowns = towns);
    } catch (e) {
      debugPrint('Erreur chargement villes: $e');
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
      final res = await _townService.searchTowns(query);
      setState(() {
        _filteredTowns = res.records;
        _isSearchingTowns = false;
      });
    } catch (e) {
      setState(() => _isSearchingTowns = false);
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

  // =========================================================
  //  IMAGE
  // =========================================================
  Future<void> _pickImage() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
        _hasNewImage = true; // Marquer qu'une nouvelle image a été sélectionnée
        _uploadedImageUrl = null; // Réinitialiser l'URL uploadée précédente
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
        _hasNewImage = true; // Marquer qu'une nouvelle image a été sélectionnée
        _uploadedImageUrl = null; // Réinitialiser l'URL uploadée précédente
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    
    setState(() => _isUploadingImage = true);
    try {
      final url = await _mediaService.uploadSingleFile(_selectedImage!);
      setState(() {
        _isUploadingImage = false;
      });
      return url;
    } catch (e) {
      setState(() => _isUploadingImage = false);
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  void _removeImage() => setState(() {
        _selectedImage = null;
        _uploadedImageUrl = null;
        _hasNewImage = false; // Réinitialiser le flag
      });

  // =========================================================
  //  MISE À JOUR
  // =========================================================
  void _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthProvider>();
    String? finalImageUrl = _uploadedImageUrl;
    
    try {
      // Uploader la nouvelle image si une a été sélectionnée
      if (_hasNewImage && _selectedImage != null) {
        setState(() => _isUploadingImage = true);
        try {
          finalImageUrl = await _uploadImage();
          setState(() {
            _uploadedImageUrl = finalImageUrl;
            _hasNewImage = false; // Réinitialiser le flag après l'upload
          });
        } catch (e) {
          _showErrorSnackbar('Erreur lors de l\'upload de l\'image: $e');
          setState(() => _isUploadingImage = false);
          return;
        }
      }

      // Mettre à jour le profil avec les nouvelles données
      await auth.updateProfile(
        username: _usernameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        birthday: _birthdayController.text,
        gender: _selectedGender,
        image: finalImageUrl,
        townId: _selectedTown?.id,
      );
      
      _showSuccessSnackbar('Profil mis à jour');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showSuccessSnackbar('Mot de passe modifié');
    } catch (e) {
      _showErrorSnackbar(e.toString());
    }
  }

  // =========================================================
  //  HELPERS
  // =========================================================
  void _showErrorSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppThemes.getErrorColor(context)),
    );
  }

  void _showSuccessSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppThemes.getSuccessColor(context)),
    );
  }

  String _formatDate(String? d) {
    if (d == null) return '';
    try {
      final date = DateTime.parse(d);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return d;
    }
  }

  String _genderLabel(String? g, Locale l) {
    if (g == 'M') return AppTranslations.get('male', l, 'Masculin');
    if (g == 'F') return AppTranslations.get('female', l, 'Féminin');
    return AppTranslations.get('not_specified', l, 'Non spécifié');
  }

  // =========================================================
  //  UI – INFORMATIONS
  // =========================================================
  Widget _buildInfoTab(User u, Locale l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Photo + nom
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: (u.image != null && u.image!.isNotEmpty)
                      ? NetworkImage(u.image!)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                  backgroundColor: primaryColor1.withOpacity(.1),
                ),
                const SizedBox(height: 12),
                Text(u.username ?? 'N/A',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(u.email ?? 'N/A',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                if (u.role != null) ...[
                  const SizedBox(height: 6),
                  Chip(
                    label: Text(u.role!.toUpperCase()),
                    backgroundColor: accentColor1.withOpacity(.15),
                    labelStyle: TextStyle(color: accentColor1, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Infos
          _infoCard(AppTranslations.get('personal_info', l, 'Infos personnelles'), [
            _infoRow(Icons.person, AppTranslations.get('username', l, 'Nom'), u.username ?? 'N/A'),
            _infoRow(Icons.phone, AppTranslations.get('phone', l, 'Téléphone'), u.phone ?? 'N/A'),
            _infoRow(Icons.email, 'Email', u.email ?? 'N/A'),
            _infoRow(Icons.cake, AppTranslations.get('birthday', l, 'Anniversaire'), _formatDate(u.birthday)),
            _infoRow(Icons.transgender, AppTranslations.get('gender', l, 'Genre'), _genderLabel(u.gender, l)),
          ]),

          const SizedBox(height: 16),

          // Localisation
          if (u.town != null)
            _infoCard(AppTranslations.get('location', l, 'Localisation'), [
              _infoRow(Icons.location_city, AppTranslations.get('town', l, 'Ville'), u.town!.name),
              if (u.town?.country != null) _infoRow(Icons.flag, AppTranslations.get('country', l, 'Pays'), u.town!.country!.name),
            ]),

          const SizedBox(height: 16),

          // Stats
          _infoCard(AppTranslations.get('statistics', l, 'Statistiques'), [
            _infoRow(Icons.home, AppTranslations.get('properties_owned', l, 'Propriétés'), '${u.ownedProperties?.length ?? 0}'),
            _infoRow(Icons.favorite, AppTranslations.get('favorites', l, 'Favoris'), '${u.favorites?.length ?? 0}'),
            _infoRow(Icons.report, AppTranslations.get('reports_made', l, 'Signalements'), '${u.reportedSignals?.length ?? 0}'),
          ]),

          const SizedBox(height: 24),

          // Rafraîchir
          Center(
            child: ElevatedButton.icon(
              onPressed: () => context.read<AuthProvider>().fetchUserProfile().then((_) => _initializeControllers()),
              icon: const Icon(Icons.refresh),
              label: Text(AppTranslations.get('refresh_data', l, 'Rafraîchir')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor1,
                )),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryColor1),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  //  UI – ÉDITION
  // =========================================================
  Widget _buildEditTab(User u, Locale l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Photo
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppTranslations.get('profile_picture', l, 'Photo de profil'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor1)),
                  const SizedBox(height: 16),
                  _imageSection(l),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Formulaire
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(AppTranslations.get('edit_personal_info', l, 'Modifier les infos'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor1)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('username', l, 'Nom d\'utilisateur'),
                        prefixIcon: const Icon(Icons.person, color: primaryColor1),
                      ),
                      validator: (v) => v!.isEmpty ? AppTranslations.get('username_required', l, 'Requis') : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('phone', l, 'Téléphone'),
                        prefixIcon: const Icon(Icons.phone, color: primaryColor1),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email, color: primaryColor1),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.contains('@') ? null : AppTranslations.get('email_invalid', l, 'Email invalide'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthdayController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('birthday', l, 'Date de naissance'),
                        prefixIcon: const Icon(Icons.cake, color: primaryColor1),
                        hintText: 'YYYY-MM-DD',
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _birthdayController.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('gender', l, 'Genre'),
                        prefixIcon: const Icon(Icons.transgender, color: primaryColor1),
                      ),
                      items: _genders
                          .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g == 'M'
                                  ? AppTranslations.get('male', l, 'Masculin')
                                  : AppTranslations.get('female', l, 'Féminin'))))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGender = v),
                    ),
                    const SizedBox(height: 16),
                    _townAutocomplete(l),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor1,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: (context.watch<AuthProvider>().isLoading || _isUploadingImage) ? null : _updateProfile,
                        child: (context.watch<AuthProvider>().isLoading || _isUploadingImage)
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(AppTranslations.get('save_changes', l, 'Sauvegarder')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Changement de mot de passe
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  children: [
                    Text(AppTranslations.get('change_password', l, 'Changer le mot de passe'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor1)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('current_password', l, 'Actuel'),
                        prefixIcon: const Icon(Icons.lock, color: primaryColor1),
                      ),
                      obscureText: true,
                      validator: (v) => v!.isEmpty ? AppTranslations.get('current_password_required', l, 'Requis') : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('new_password', l, 'Nouveau'),
                        prefixIcon: const Icon(Icons.lock_outline, color: primaryColor1),
                      ),
                      obscureText: true,
                      validator: (v) => v!.length < 6 ? AppTranslations.get('password_min_length', l, '6 caractères min') : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.get('confirm_password', l, 'Confirmation'),
                        prefixIcon: const Icon(Icons.lock_reset, color: primaryColor1),
                      ),
                      obscureText: true,
                      validator: (v) => v != _newPasswordController.text ? AppTranslations.get('passwords_not_match', l, 'Pas identique') : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorColor1,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: context.watch<AuthProvider>().isLoading ? null : _changePassword,
                        child: context.watch<AuthProvider>().isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(AppTranslations.get('change_password', l, 'Changer')),
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

  // =========================================================
  //  WIDGETS COMPOSANTS
  // =========================================================
  Widget _imageSection(Locale l) {
    return Column(
      children: [
        if (_selectedImage != null || _uploadedImageUrl != null) ...[
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_uploadedImageUrl != null && !_isUploadingImage && !_hasNewImage)
            Text(
              AppTranslations.get('upload_success', l, 'Upload réussi ✓'),
              style: TextStyle(color: successColor1, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _removeImage,
            icon: const Icon(Icons.delete, size: 18),
            label: Text(AppTranslations.get('remove', l, 'Supprimer')),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor1.withOpacity(.05),
              foregroundColor: errorColor1,
            ),
          ),
        ] else ...[
          Icon(Icons.person, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(AppTranslations.get('no_image_selected', l, 'Aucune photo'),
              style: TextStyle(color: Colors.grey.shade600)),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: Text(AppTranslations.get('gallery', l, 'Galerie')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(AppTranslations.get('camera', l, 'Caméra')),
              ),
            ),
          ],
        ),
        if (_hasNewImage && _selectedImage != null) ...[
          const SizedBox(height: 12),
          Text(
            AppTranslations.get('new_image_selected', l, 'Nouvelle image sélectionnée - sera enregistrée lors de la sauvegarde'),
            style: TextStyle(
              color: accentColor1,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _townAutocomplete(Locale l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _townSearchController,
          decoration: InputDecoration(
            labelText: AppTranslations.get('town', l, 'Ville'),
            prefixIcon: const Icon(Icons.location_city, color: primaryColor1),
            suffixIcon: _selectedTown != null
                ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearTownSelection)
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
        ),
        if (_showTownDropdown && _filteredTowns.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredTowns.length,
              itemBuilder: (_, i) {
                final t = _filteredTowns[i];
                return ListTile(
                  leading: const Icon(Icons.location_city, size: 20),
                  title: Text(t.name),
                  subtitle: Text(t.country.name),
                  onTap: () => _selectTown(t),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }

  // =========================================================
  //  BUILD PRINCIPAL
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsProvider>().locale;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppTranslations.get('profile', locale, 'Profil'))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: errorColor1),
              const SizedBox(height: 16),
              Text(AppTranslations.get('user_not_connected', locale, 'Non connecté'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text(AppTranslations.get('login', locale, 'Se connecter')),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_showTownDropdown) setState(() => _showTownDropdown = false);
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppTranslations.get('profile', locale, 'Profil')),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: accentColor1,
            labelColor: accentColor1,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: AppTranslations.get('information', locale, 'Informations')),
              Tab(text: AppTranslations.get('edit_profile', locale, 'Modifier')),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(user, locale),
            _buildEditTab(user, locale),
          ],
        ),
      ),
    );
  }
}