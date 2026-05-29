import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../services/auth_storage.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _green = Color(0xFF1D9E75);
  static const _darkGreen = Color(0xFF147A5B);
  static const _darkText = Color(0xFF1A1A1A);
  static const _subtleText = Color(0xFF6B7280);

  String _name = '';
  String _businessName = '';
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final info = await AuthStorage.getUserInfo();
    if (mounted) {
      setState(() {
        _name = info['name'] ?? 'User';
        _businessName = info['business_name'] ?? 'Toko Saya';
        _profilePictureUrl = info['profile_picture'];
      });
    }

    // Ambil profile terbaru dari server
    try {
      final profile = await ApiService.getProfile();
      if (mounted) {
        final picUrl = profile['profile_picture'] as String?;
        setState(() {
          _profilePictureUrl = picUrl;
        });
        if (picUrl != null && picUrl.isNotEmpty) {
          await AuthStorage.saveProfilePicture(picUrl);
        }
      }
    } catch (_) {
      // Gunakan cache lokal jika gagal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with hero header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: _green,
            surfaceTintColor: _green,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Profil Saya',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1D9E75), Color(0xFF0F6B4F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    // decorative circles
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Avatar + info
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Avatar with ring + camera button
                            GestureDetector(
                              onTap: _showPhotoSourceBottomSheet,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        width: 2.5,
                                      ),
                                    ),
                                    child:
                                        _profilePictureUrl != null &&
                                            _profilePictureUrl!.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 43,
                                            backgroundImage: NetworkImage(
                                              _profilePictureUrl!,
                                            ),
                                            backgroundColor: const Color(
                                              0xFF1D9E75,
                                            ),
                                            onBackgroundImageError: (e, s) {},
                                          )
                                        : Container(
                                            width: 86,
                                            height: 86,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF4ADE80),
                                                  Color(0xFF1D9E75),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                _name.isNotEmpty
                                                    ? _name[0].toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                  // Camera icon overlay
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Color(0xFF1D9E75),
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.storefront_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _businessName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section label
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Pengaturan Akun',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Menu card group
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.edit_rounded,
                          label: 'Edit Profil',
                          subtitle: 'Ubah nama dan nama toko Anda',
                          onTap: () => _showEditProfileDialog(),
                          isFirst: true,
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.info_outline_rounded,
                          label: 'Tentang Aplikasi',
                          subtitle: 'TitikCuan v1.0.0',
                          onTap: () => _showAboutBottomSheet(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Danger zone
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildMenuTile(
                      icon: Icons.no_accounts_rounded,
                      label: 'Nonaktifkan Akun',
                      subtitle: 'Menonaktifkan akun sementara',
                      iconColor: Colors.red.shade700,
                      bgColor: Colors.red.shade50,
                      labelColor: Colors.red.shade700,
                      onTap: () => _showDeactivateDialog(),
                      isFirst: true,
                      isLast: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih sumber foto untuk diperbarui',
                  style: TextStyle(fontSize: 13, color: _subtleText),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _pickAndUploadPhoto(ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3FAF7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _green.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _green.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: _green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Kamera',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _darkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _pickAndUploadPhoto(ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3FAF7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _green.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _green.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_library_rounded,
                                  color: _green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Galeri',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _darkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image == null) return;

    // Buka cropper untuk memotong gambar menjadi persegi (1:1)
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Potong Foto Profil',
          toolbarColor: _green,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          activeControlsWidgetColor: _green,
        ),
        IOSUiSettings(
          title: 'Potong Foto Profil',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: _green)),
    );

    try {
      // 1. Baca bytes dari file terpangkas
      final bytes = await croppedFile.readAsBytes();
      final fileName = croppedFile.path.split('/').last;

      // 2. Upload ke Supabase Storage
      final publicUrl = await ApiService.uploadToSupabase(
        fileBytes: bytes,
        fileName: fileName,
      );

      // 3. Update URL di backend
      await ApiService.updateProfilePicture(publicUrl);

      // 4. Simpan URL ke local storage
      await AuthStorage.saveProfilePicture(publicUrl);

      if (mounted) {
        Navigator.pop(context); // Close loading
        setState(() {
          _profilePictureUrl = publicUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            backgroundColor: _green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _name);
    final businessNameController = TextEditingController(text: _businessName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D9E75), Color(0xFF147A5B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Edit Profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Perbarui informasi akun kamu',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _buildDialogTextField(
                          controller: nameController,
                          label: 'Nama Pengguna',
                          hint: 'Masukkan nama kamu',
                          icon: Icons.person_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildDialogTextField(
                          controller: businessNameController,
                          label: 'Nama Toko',
                          hint: 'Masukkan nama toko kamu',
                          icon: Icons.store_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama toko tidak boleh kosong'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final newName = nameController.text.trim();
                              final newBusinessName = businessNameController
                                  .text
                                  .trim();
                              Navigator.pop(ctx);
                              _updateProfile(newName, newBusinessName);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _green, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Future<void> _updateProfile(String newName, String newBusinessName) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: _green)),
    );

    try {
      await ApiService.updateProfile(
        name: newName,
        businessName: newBusinessName,
      );

      final info = await AuthStorage.getUserInfo();
      final userId = info['user_id'] ?? 0;

      // Save new info to shared_preferences
      await AuthStorage.saveUserInfo(
        userId: userId,
        name: newName,
        businessName: newBusinessName,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        setState(() {
          _name = newName;
          _businessName = newBusinessName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui.'),
            backgroundColor: _green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header merah
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.no_accounts_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nonaktifkan Akun?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tindakan ini bersifat sementara',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Konten
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Anda akan keluar dari aplikasi dan akun tidak akan aktif sampai diaktifkan kembali.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red.shade700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              _deactivateAccount();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Nonaktifkan',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // logo
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/titikcuan_logo.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'TitikCuan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Versi 1.0.0',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FBF8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD4EEE5)),
                ),
                child: const Text(
                  'TitikCuan adalah aplikasi Point of Sale (POS) pintar untuk pedagang UMKM berpindah. '
                  'Dilengkapi dengan pemindai barcode, pencatatan lokasi GPS, dan visualisasi peta penjualan '
                  'untuk membantu pedagang menemukan "titik cuan" terbaik mereka.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                '© 2026 TitikCuan — Kelompok 8\nUniversitas Jember',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deactivateAccount() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: _green)),
    );

    try {
      await ApiService.deactivateAccount();
      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        // Navigate to login screen and clear history
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun Anda berhasil dinonaktifkan.'),
            backgroundColor: _green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? bgColor,
    Color? labelColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: bgColor ?? _green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor ?? _darkGreen, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: labelColor ?? _darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: iconColor?.withValues(alpha: 0.5) ?? _subtleText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Color(0xFFF0F0F0)),
    );
  }
}
