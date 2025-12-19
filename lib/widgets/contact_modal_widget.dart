// lib/widgets/contact_modal_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_themes.dart';
import '../constants/app_translations.dart';

// ====================================================================
// MODAL DES OPTIONS DE CONTACT
// ====================================================================
/// Modal affichant les différentes options pour contacter le propriétaire
/// d'une propriété (appel, WhatsApp, SMS, copie du numéro)
class ContactOptionsModal extends StatefulWidget {
  final String phoneNumber;
  final String ownerName;
  final Locale locale;

  const ContactOptionsModal({
    super.key,
    required this.phoneNumber,
    required this.ownerName,
    required this.locale,
  });

  @override
  State<ContactOptionsModal> createState() => _ContactOptionsModalState();
}

class _ContactOptionsModalState extends State<ContactOptionsModal> {
  bool _isLoading = false;
  String? _loadingAction;

  /// Formate le numéro pour les URL (enlève les espaces, etc.)
  String _formatPhoneForUrl(String phone) {
    // Garde seulement les chiffres et le signe +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Si le numéro commence par 0, ajoute l'indicatif camerounais par défaut
    if (cleaned.startsWith('0') && !cleaned.startsWith('+')) {
      cleaned = '+237${cleaned.substring(1)}';
    }
    
    // Si pas de préfixe international, ajoute +237 (Cameroun)
    if (!cleaned.startsWith('+')) {
      cleaned = '+237$cleaned';
    }
    
    return cleaned;
  }

  /// Lance un appel téléphonique
  Future<void> _makePhoneCall() async {
    setState(() {
      _isLoading = true;
      _loadingAction = 'call';
    });

    try {
      final formattedNumber = _formatPhoneForUrl(widget.phoneNumber);
      final url = Uri.parse('tel:$formattedNumber');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        _showErrorSnackbar(AppTranslations.get(
          'call_failed', 
          widget.locale, 
          'Impossible de lancer l\'appel'
        ));
      }
    } catch (e) {
      print('❌ Erreur appel: $e');
      _showErrorSnackbar('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingAction = null;
        });
      }
    }
  }

  /// Ouvre WhatsApp avec le numéro
  Future<void> _openWhatsApp() async {
    setState(() {
      _isLoading = true;
      _loadingAction = 'whatsapp';
    });

    try {
      final formattedNumber = _formatPhoneForUrl(widget.phoneNumber);
      
      // On essaie d'abord l'URL app WhatsApp
      final appUrl = Uri.parse('whatsapp://send?phone=$formattedNumber');
      
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else {
        // Fallback vers la version web
        final webUrl = Uri.parse('https://wa.me/$formattedNumber');
        
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl);
        } else {
          _showErrorSnackbar(AppTranslations.get(
            'whatsapp_not_installed', 
            widget.locale, 
            'WhatsApp n\'est pas installé'
          ));
        }
      }
    } catch (e) {
      print('❌ Erreur WhatsApp: $e');
      _showErrorSnackbar('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingAction = null;
        });
      }
    }
  }

  /// Ouvre l'app SMS avec le numéro pré-rempli
  Future<void> _sendSMS() async {
    setState(() {
      _isLoading = true;
      _loadingAction = 'sms';
    });

    try {
      final formattedNumber = _formatPhoneForUrl(widget.phoneNumber);
      final url = Uri.parse('sms:$formattedNumber');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        _showErrorSnackbar(AppTranslations.get(
          'sms_failed', 
          widget.locale, 
          'Impossible d\'ouvrir l\'application SMS'
        ));
      }
    } catch (e) {
      print('❌ Erreur SMS: $e');
      _showErrorSnackbar('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingAction = null;
        });
      }
    }
  }

  /// Copie le numéro dans le presse-papier
  Future<void> _copyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.phoneNumber));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get(
            'copied_to_clipboard', 
            widget.locale, 
            'Numéro copié dans le presse-papier'
          )),
          backgroundColor: AppThemes.getSuccessColor(context),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Ferme le modal après un délai
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.of(context).pop();
      
    } catch (e) {
      print('❌ Erreur copie presse-papier: $e');
      _showErrorSnackbar('Erreur lors de la copie');
    }
  }

  /// Affiche un message d'erreur
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.getErrorColor(context),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Affiche un indicateur de chargement
  Widget _buildLoadingIndicator(String action) {
    String text = '';
    
    switch (action) {
      case 'call':
        text = 'Ouverture de l\'appel...';
        break;
      case 'whatsapp':
        text = 'Ouverture de WhatsApp...';
        break;
      case 'sms':
        text = 'Ouverture des SMS...';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppThemes.getSuccessColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton pour chaque option de contact
  Widget _buildContactButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionType,
    required VoidCallback onTap,
  }) {
    final isCurrentActionLoading = _isLoading && _loadingAction == actionType;
    
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isCurrentActionLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    )
                  : Icon(icon, color: iconColor, size: 24),
            ),
            
            const SizedBox(width: 16),
            
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Chevron ou indicateur
            if (!isCurrentActionLoading)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).hintColor,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Center(
              child: Text(
                AppTranslations.get('contact_options', widget.locale, 'Contacter'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Nom du propriétaire
            Center(
              child: Text(
                widget.ownerName,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Section du numéro de téléphone
            _buildPhoneNumberSection(),
            
            const SizedBox(height: 24),
            
            // Indicateur de chargement ou boutons d'action
            if (_isLoading && _loadingAction != null)
              _buildLoadingIndicator(_loadingAction!)
            else
              _buildActionButtons(),
            
            const SizedBox(height: 20),
            
            // Bouton Annuler
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  /// Section affichant le numéro de téléphone
  Widget _buildPhoneNumberSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.get('phone_number', widget.locale, 'Numéro'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.content_copy,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: _isLoading ? null : _copyToClipboard,
          ),
        ],
      ),
    );
  }

  /// Section des boutons d'action
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Appeler
        _buildContactButton(
          icon: Icons.call,
          iconColor: Colors.green,
          title: AppTranslations.get('call', widget.locale, 'Appeler'),
          subtitle: AppTranslations.get('call_description', widget.locale, 'Passer un appel direct'),
          actionType: 'call',
          onTap: () {
            Navigator.pop(context);
            _makePhoneCall();
          },
        ),
        
        // const SizedBox(height: 12),
        
        // // WhatsApp
        // _buildContactButton(
        //   icon: Icons.message,
        //   iconColor: const Color(0xFF25D366), // Vert WhatsApp
        //   title: 'WhatsApp',
        //   subtitle: AppTranslations.get('whatsapp_description', widget.locale, 'Envoyer un message WhatsApp'),
        //   actionType: 'whatsapp',
        //   onTap: () {
        //     Navigator.pop(context);
        //     _openWhatsApp();
        //   },
        // ),
        
        const SizedBox(height: 12),
        
        // SMS
        _buildContactButton(
          icon: Icons.sms,
          iconColor: Colors.blue,
          title: 'SMS',
          subtitle: AppTranslations.get('sms_description', widget.locale, 'Envoyer un SMS'),
          actionType: 'sms',
          onTap: () {
            Navigator.pop(context);
            _sendSMS();
          },
        ),
      ],
    );
  }

  /// Bouton Annuler
  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _isLoading ? null : () => Navigator.pop(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          AppTranslations.get('cancel', widget.locale, 'Annuler'),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}