import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/bootstrap.dart';
import '../../../core/typography/app_typography.dart';
import '../../../domain/models/bookmark_model.dart';
import '../../../domain/models/reflection_note_model.dart';

/// Modal bottom sheet for creating, editing, and deleting personal Tadabbur reflection notes.
/// 100% offline, local-only storage for spiritual contemplation.
class ReflectionNoteSheet extends StatefulWidget {
  const ReflectionNoteSheet({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.reference,
    required this.arabicExcerpt,
    required this.translationExcerpt,
    this.existingNote,
  });

  final String contentId;
  final ContentType contentType;
  final String reference;
  final String arabicExcerpt;
  final String translationExcerpt;
  final ReflectionNote? existingNote;

  /// Static helper to present the reflection sheet modally.
  static Future<bool?> show(
    BuildContext context, {
    required String contentId,
    required ContentType contentType,
    required String reference,
    required String arabicExcerpt,
    required String translationExcerpt,
    ReflectionNote? existingNote,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReflectionNoteSheet(
        contentId: contentId,
        contentType: contentType,
        reference: reference,
        arabicExcerpt: arabicExcerpt,
        translationExcerpt: translationExcerpt,
        existingNote: existingNote,
      ),
    );
  }

  @override
  State<ReflectionNoteSheet> createState() => _ReflectionNoteSheetState();
}

class _ReflectionNoteSheetState extends State<ReflectionNoteSheet> {
  late final TextEditingController _textController;
  bool _isSaving = false;
  bool _isDeleting = false;
  ReflectionNote? _currentNote;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.existingNote;
    _textController = TextEditingController(text: widget.existingNote?.noteText ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded && widget.existingNote == null) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    _hasLoaded = true;
    final scope = AppScope.of(context);
    final note = await scope.reflectionNotesRepository.getNoteForContent(widget.contentId);
    if (note != null && mounted) {
      setState(() {
        _currentNote = note;
        if (_textController.text.isEmpty) {
          _textController.text = note.noteText;
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your reflection before saving.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final scope = AppScope.of(context);
    if (scope.preferences.hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }

    final now = DateTime.now();
    final note = ReflectionNote(
      id: _currentNote?.id ?? 'note_${DateTime.now().millisecondsSinceEpoch}',
      contentId: widget.contentId,
      contentType: widget.contentType,
      reference: widget.reference,
      arabicExcerpt: widget.arabicExcerpt,
      translationExcerpt: widget.translationExcerpt,
      noteText: text,
      createdAt: _currentNote?.createdAt ?? now,
      updatedAt: now,
    );

    await scope.saveReflectionNote(note);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_currentNote != null ? 'Reflection updated' : 'Reflection saved to your Tadabbur journal'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteNote() async {
    if (_currentNote == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reflection?'),
        content: const Text('Are you sure you want to delete this reflection note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final scope = AppScope.of(context);
    if (scope.preferences.hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }

    await scope.deleteReflectionNote(_currentNote!.id, widget.contentId);

    if (!mounted) return;
    setState(() => _isDeleting = false);
    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reflection note deleted'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: const Color(0xFFC5A059).withValues(alpha: 0.3),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grab handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFFC5A059),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentNote != null ? 'Edit Tadabbur Reflection' : 'Personal Reflection (Tadabbur)',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.reference,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_currentNote != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 22),
                      tooltip: 'Delete reflection',
                      color: theme.colorScheme.error,
                      onPressed: _isDeleting ? null : _deleteNote,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content Excerpt Preview & Reflection Field
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Excerpt Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFC5A059).withValues(alpha: 0.22),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.arabicExcerpt.isNotEmpty) ...[
                            Text(
                              widget.arabicExcerpt,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.arabic(
                                fontSize: 18,
                                height: 1.8,
                                color: const Color(0xFFC5A059),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Text(
                            '"${widget.translationExcerpt}"',
                            style: AppTypography.translation(
                              fontSize: 13.5,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Journal Text Input
                    const Text(
                      'Your Reflections & Lessons',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _textController,
                      autofocus: _currentNote == null,
                      maxLines: 6,
                      minLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Record what this verse or hadith teaches you, personal insights, or supplications for your heart...',
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFC5A059),
                            width: 1.6,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Privacy notice
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Stored 100% locally and offline on your device. Never shared or uploaded.',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveNote,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_rounded, size: 20),
                      label: Text(_currentNote != null ? 'Update Note' : 'Save Reflection'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFC5A059),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
  }
}
