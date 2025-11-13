// // lib/pages/register_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../providers/settings_provider.dart';
// import '../constants/app_themes.dart';
// import '../constants/app_translations.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _birthdayController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _townIdController = TextEditingController();
  
//   String? _selectedGender;
//   final List<String> _genders = ['M', 'F'];

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _birthdayController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _townIdController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleRegister() async {
//     if (_formKey.currentState!.validate()) {
//       final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);

//       try {
//         await authProvider.register(
//           username: _usernameController.text,
//           phone: _phoneController.text,
//           email: _emailController.text,
//           birthday: _birthdayController.text,
//           password: _passwordController.text,
//           confirmPassword: _confirmPasswordController.text,
//           townId: _townIdController.text,
//           gender: _selectedGender,
//         );

//         // ✅ SUCCÈS : Retour à la page de connexion
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(AppTranslations.get('register_success', locale, 'Inscription réussie !')),
//               backgroundColor: AppThemes.getSuccessColor(context),
//               duration: const Duration(seconds: 3),
//             ),
//           );
          
//           // Retour à la page de connexion
//           Navigator.of(context).pop();
//         }

//       } catch (e) {
//         // L'erreur est déjà gérée dans le provider
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(e.toString()),
//               backgroundColor: AppThemes.getErrorColor(context),
//               duration: const Duration(seconds: 5),
//             ),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: authProvider.isLoading ? null : () {
//             Navigator.of(context).pop();
//           },
//         ),
//         title: Text(AppTranslations.get('register', locale, 'Inscription')),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Logo
//                 const Icon(
//                   Icons.person_add_alt_1,
//                   size: 80,
//                   color: primaryBlue,
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Titre
//                 Text(
//                   AppTranslations.get('create_account', locale, 'Créer un compte'),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: primaryBlue,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   AppTranslations.get('fill_details_to_continue', locale, 'Remplissez vos informations pour continuer'),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 40),

//                 // Champ Username
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('username', locale, 'Nom d\'utilisateur') + ' *',
//                     prefixIcon: const Icon(Icons.person_outline, color: primaryBlue),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('required_username', locale, 'Le nom d\'utilisateur est requis');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Champ Phone
//                 TextFormField(
//                   controller: _phoneController,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('phone', locale, 'Téléphone') + ' *',
//                     prefixIcon: const Icon(Icons.phone, color: primaryBlue),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('required_phone', locale, 'Le téléphone est requis');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Champ Email
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('email', locale, 'Email') + ' *',
//                     prefixIcon: const Icon(Icons.email_outlined, color: primaryBlue),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('required_email', locale, 'L\'email est requis');
//                     }
//                     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                       return AppTranslations.get('invalid_email', locale, 'Email invalide');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Champ Birthday
//                 TextFormField(
//                   controller: _birthdayController,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('birthday', locale, 'Date de naissance') + ' *',
//                     hintText: 'YYYY-MM-DD',
//                     prefixIcon: const Icon(Icons.cake, color: primaryBlue),
//                   ),
//                   onTap: () async {
//                     final date = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 ans par défaut
//                       firstDate: DateTime(1900),
//                       lastDate: DateTime.now(),
//                     );
//                     if (date != null) {
//                       _birthdayController.text =
//                           '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//                     }
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('required_birthday', locale, 'La date de naissance est requise');
//                     }
//                     if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
//                       return AppTranslations.get('invalid_date_format', locale, 'Format invalide (YYYY-MM-DD)');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Champ Gender (facultatif)
//                 DropdownButtonFormField<String>(
//                   value: _selectedGender,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('gender', locale, 'Genre'),
//                     prefixIcon: const Icon(Icons.transgender, color: primaryBlue),
//                   ),
//                   items: _genders.map((String gender) {
//                     return DropdownMenuItem<String>(
//                       value: gender,
//                       child: Text(gender == 'M' 
//                         ? AppTranslations.get('male', locale, 'Masculin')
//                         : AppTranslations.get('female', locale, 'Féminin')
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedGender = newValue;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Champ Password
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('password', locale, 'Mot de passe') + ' *',
//                     prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('required_password', locale, 'Le mot de passe est requis');
//                     }
//                     if (value.length < 6) {
//                       return AppTranslations.get('password_min_length', locale, 'Le mot de passe doit contenir au moins 6 caractères');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Champ Confirm Password
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('confirm_password', locale, 'Confirmer le mot de passe') + ' *',
//                     prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('required_confirm_password', locale, 'Veuillez confirmer votre mot de passe');
//                     }
//                     if (value != _passwordController.text) {
//                       return AppTranslations.get('passwords_dont_match', locale, 'Les mots de passe ne correspondent pas');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Champ Town ID
//                 TextFormField(
//                   controller: _townIdController,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('town_id', locale, 'ID de la ville') + ' *',
//                     hintText: 'Ex: e98a1690-b589-4005-9849-b93fa88bde8d',
//                     prefixIcon: const Icon(Icons.location_city, color: primaryBlue),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('required_town_id', locale, 'L\'ID de la ville est requis');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 30),

//                 // Bouton d'inscription
//                 ElevatedButton(
//                   onPressed: authProvider.isLoading ? null : _handleRegister,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryBlue,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 5,
//                   ),
//                   child: authProvider.isLoading
//                       ? const SizedBox(
//                           height: 20, 
//                           width: 20, 
//                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text(
//                           AppTranslations.get('register_button', locale, 'S\'inscrire'),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Lien vers la connexion
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(AppTranslations.get('have_account', locale, 'Déjà un compte ?')),
//                     TextButton(
//                       onPressed: authProvider.isLoading ? null : () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text(
//                         AppTranslations.get('login', locale, 'Se connecter'),
//                         style: const TextStyle(color: accentOrange, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_themes.dart';
import '../constants/app_translations.dart';
import '../models/town.dart';
import '../services/town_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedGender;
  final List<String> _genders = ['M', 'F'];
  
  // Variables pour l'autocomplete des villes
  final TownService _townService = TownService();
  final TextEditingController _townSearchController = TextEditingController();
  List<Town> _filteredTowns = [];
  Town? _selectedTown;
  bool _isSearchingTowns = false;
  bool _showTownDropdown = false;

  @override
  void initState() {
    super.initState();
    _townSearchController.addListener(_onTownSearchChanged);
    _loadAllTowns();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _townSearchController.dispose();
    super.dispose();
  }

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

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTown == null) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        final locale = settingsProvider.locale;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get('required_town', locale, 'Veuillez sélectionner une ville')),
            backgroundColor: AppThemes.getErrorColor(context),
          ),
        );
        return;
      }

      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final locale = settingsProvider.locale;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.register(
          username: _usernameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          birthday: _birthdayController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          townId: _selectedTown!.id,
          gender: _selectedGender,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.get('register_success', locale, 'Inscription réussie !')),
              backgroundColor: AppThemes.getSuccessColor(context),
              duration: const Duration(seconds: 3),
            ),
          );
          
          Navigator.of(context).pop();
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppThemes.getErrorColor(context),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  // CORRECTION : Ajouter le paramètre locale
  Widget _buildTownAutocomplete(Locale locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ de recherche de ville
        TextFormField(
          controller: _townSearchController,
          decoration: InputDecoration(
            labelText: '${AppTranslations.get('town', locale, 'Ville')} *', // CORRECTION : interpolation
            hintText: AppTranslations.get('search_town', locale, 'Rechercher une ville...'),
            prefixIcon: const Icon(Icons.search, color: primaryBlue),
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
          validator: (value) {
            if (_selectedTown == null) {
              return AppTranslations.get('required_town', locale, 'Veuillez sélectionner une ville');
            }
            return null;
          },
        ),
        
        // Dropdown des résultats
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
        
        // Message si aucune ville trouvée
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

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final locale = settingsProvider.locale;
    final authProvider = Provider.of<AuthProvider>(context);

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: authProvider.isLoading ? null : () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(AppTranslations.get('register', locale, 'Inscription')),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const Icon(
                    Icons.person_add_alt_1,
                    size: 80,
                    color: primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  
                  // Titre
                  Text(
                    AppTranslations.get('create_account', locale, 'Créer un compte'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppTranslations.get('fill_details_to_continue', locale, 'Remplissez vos informations pour continuer'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Champ Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: '${AppTranslations.get('username', locale, 'Nom d\'utilisateur')} *', // CORRECTION
                      prefixIcon: const Icon(Icons.person_outline, color: primaryBlue),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTranslations.get('required_username', locale, 'Le nom d\'utilisateur est requis');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ Phone
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: '${AppTranslations.get('phone', locale, 'Téléphone')} *', // CORRECTION
                      prefixIcon: const Icon(Icons.phone, color: primaryBlue),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTranslations.get('required_phone', locale, 'Le téléphone est requis');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: '${AppTranslations.get('email', locale, 'Email')} *', // CORRECTION
                      prefixIcon: const Icon(Icons.email_outlined, color: primaryBlue),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTranslations.get('required_email', locale, 'L\'email est requis');
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return AppTranslations.get('invalid_email', locale, 'Email invalide');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ Birthday
                  TextFormField(
                    controller: _birthdayController,
                    decoration: InputDecoration(
                      labelText: '${AppTranslations.get('birthday', locale, 'Date de naissance')} *', // CORRECTION
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: const Icon(Icons.cake, color: primaryBlue),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        _birthdayController.text =
                            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTranslations.get('required_birthday', locale, 'La date de naissance est requise');
                      }
                      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                        return AppTranslations.get('invalid_date_format', locale, 'Format invalide (YYYY-MM-DD)');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ Gender (facultatif)
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: AppTranslations.get('gender', locale, 'Genre'),
                      prefixIcon: const Icon(Icons.transgender, color: primaryBlue),
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

                  // Champ Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '${AppTranslations.get('password', locale, 'Mot de passe')} *', // CORRECTION
                      prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTranslations.get('required_password', locale, 'Le mot de passe est requis');
                      }
                      if (value.length < 6) {
                        return AppTranslations.get('password_min_length', locale, 'Le mot de passe doit contenir au moins 6 caractères');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '${AppTranslations.get('confirm_password', locale, 'Confirmer le mot de passe')} *', // CORRECTION
                      prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTranslations.get('required_confirm_password', locale, 'Veuillez confirmer votre mot de passe');
                      }
                      if (value != _passwordController.text) {
                        return AppTranslations.get('passwords_dont_match', locale, 'Les mots de passe ne correspondent pas');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // CORRECTION : Passer le locale à la méthode
                  _buildTownAutocomplete(locale),
                  const SizedBox(height: 30),

                  // Bouton d'inscription
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            AppTranslations.get('register_button', locale, 'S\'inscrire'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Lien vers la connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppTranslations.get('have_account', locale, 'Déjà un compte ?')),
                      TextButton(
                        onPressed: authProvider.isLoading ? null : () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppTranslations.get('login', locale, 'Se connecter'),
                          style: const TextStyle(color: accentOrange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}