import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/aqua_card.dart';
import '../data/models/social_link.dart';
import '../providers/profile_provider.dart';
import 'link_form_sheet.dart';

class LinksScreen extends ConsumerWidget {
  const LinksScreen({super.key});

  Future<void> _openForm(BuildContext context, {SocialLink? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppTheme.bgLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => LinkFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, SocialLink link) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete link?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Remove "${link.label.isEmpty ? link.platformDisplay : link.label}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(100, 44)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(myLinksProvider.notifier).delete(link.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(myLinksProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Manage Links'),
            pinned: true,
            backgroundColor: AppTheme.bgLight,
          ),
          linksAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            data: (links) {
              if (links.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link_off_rounded, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No links yet', style: TextStyle(fontSize: 18, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120), // Space for FAB
                sliver: SliverReorderableList(
                  itemCount: links.length,
                  onReorder: (oldI, newI) => ref.read(myLinksProvider.notifier).reorder(oldI, newI),
                  itemBuilder: (context, index) {
                    final link = links[index];
                    return AquaCard(
                      key: ValueKey(link.id),
                      padding: EdgeInsets.zero,
                      onTap: () => _openForm(context, existing: link),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: ReorderableDragStartListener(
                          index: index,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.oppoBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16), // Squircle
                            ),
                            child: const FaIcon(FontAwesomeIcons.link, color: AppTheme.oppoBlue, size: 20),
                          ),
                        ),
                        title: Text(
                          link.label.isEmpty ? link.platformDisplay : link.label,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark),
                        ),
                        subtitle: Text(
                          link.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.textMuted),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                              builder: (ctx) => SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        leading: const Icon(Icons.edit_rounded),
                                        title: const Text('Edit Link'),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          _openForm(context, existing: link);
                                        },
                                      ),
                                      ListTile(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        leading: const Icon(Icons.delete_rounded, color: Colors.red),
                                        title: const Text('Delete Link', style: TextStyle(color: Colors.red)),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          _confirmDelete(context, ref, link);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(context),
          backgroundColor: AppTheme.oppoBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Link', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}