import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayName = TextEditingController();
  final _bio = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _displayName.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ref.read(profileRepositoryProvider).updateMyProfile(
            displayName: _displayName.text.trim(),
            bio: _bio.text.trim(),
          );
      ref.invalidate(myProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (picked == null) return;

    try {
      final bytes = kIsWeb ? await picked.readAsBytes() : null;
      await ref.read(profileRepositoryProvider).uploadAvatar(
            filePath: picked.path,
            fileName: picked.name,
            bytes: bytes,
          );
      ref.invalidate(myProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Avatar updated'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Edit Profile'),
            pinned: true,
            backgroundColor: AppTheme.bgLight,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: profileAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (profile) {
                  if (!_initialized) {
                    _displayName.text = profile.displayName;
                    _bio.text = profile.bio;
                    _initialized = true;
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 64,
                                    backgroundColor: Colors.white,
                                    backgroundImage: profile.avatarUrl != null
                                        ? NetworkImage(profile.avatarUrl!)
                                        : null,
                                    child: profile.avatarUrl == null
                                        ? Text(
                                            profile.username[0].toUpperCase(),
                                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _pickAvatar,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.oppoBlue,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(color: AppTheme.oppoBlue.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                                          ],
                                        ),
                                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            TextFormField(
                              controller: _displayName,
                              decoration: const InputDecoration(labelText: 'Display name'),
                              maxLength: 80,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _bio,
                              decoration: const InputDecoration(
                                labelText: 'Bio',
                                alignLabelWithHint: true,
                              ),
                              maxLength: 280,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 32),

                            AppButton(
                              label: 'Save Changes',
                              isLoading: _saving,
                              onPressed: _save,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}