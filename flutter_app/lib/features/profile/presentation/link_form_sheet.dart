import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../data/models/platforms.dart';
import '../data/models/social_link.dart';
import '../providers/profile_provider.dart';

class LinkFormSheet extends ConsumerStatefulWidget {
  final SocialLink? existing;

  const LinkFormSheet({super.key, this.existing});

  @override
  ConsumerState<LinkFormSheet> createState() => _LinkFormSheetState();
}

class _LinkFormSheetState extends ConsumerState<LinkFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _platform;
  late final TextEditingController _url;
  late final TextEditingController _label;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _platform = widget.existing?.platform ?? platforms.first.value;
    _url = TextEditingController(text: widget.existing?.url ?? '');
    _label = TextEditingController(text: widget.existing?.label ?? '');
  }

  @override
  void dispose() {
    _url.dispose();
    _label.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final notifier = ref.read(myLinksProvider.notifier);
      if (widget.existing == null) {
        await notifier.add(
          platform: _platform,
          url: _url.text.trim(),
          label: _label.text.trim(),
        );
      } else {
        await notifier.updateLink(
          id: widget.existing!.id,
          platform: _platform,
          url: _url.text.trim(),
          label: _label.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Edit Link' : 'Add New Link',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              initialValue: _platform,
              decoration: const InputDecoration(labelText: 'Platform'),
              items: platforms
                  .map((p) => DropdownMenuItem(value: p.value, child: Text(p.label)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _url,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'URL is required';
                final uri = Uri.tryParse(v.trim());
                if (uri == null || !uri.hasScheme) return 'Include https://';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _label,
              decoration: const InputDecoration(
                labelText: 'Label (optional)',
                hintText: 'e.g. Follow me',
              ),
              maxLength: 60,
            ),
            const SizedBox(height: 24),

            AppButton(
              label: isEdit ? 'Save Changes' : 'Add Link',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}