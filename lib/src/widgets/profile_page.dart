import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../l10n/profile_strings.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

/// A full-page profile editor backed by a [ProfileService].
///
/// Handles avatar source selection, avatar upload/removal, name, bio,
/// and auto-saves text fields with a 1.5-second debounce.
///
/// Optionally renders [extraContent] (e.g. a settings panel) at the bottom.
///
/// ```dart
/// ProfilePage(
///   service: myProfileService,
///   strings: ProfileStrings.fromMap(translationMap),
///   extraContent: const MySettingsWidget(),
/// )
/// ```
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.service,
    this.strings = const ProfileStrings(),
    this.extraContent,
  });

  final ProfileService service;
  final ProfileStrings strings;

  /// Optional widget appended after the bio field (e.g. a settings panel).
  final Widget? extraContent;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _customAvatarUrlController = TextEditingController();
  String _avatarSource = 'google';
  int? _seededProfileId;
  Uint8List? _pendingAvatarBytes;
  String? _pendingAvatarMimeType;
  String? _pendingAvatarFileName;
  bool _isUploadingAvatar = false;
  Timer? _autoSaveTimer;

  ProfileStrings get _s => widget.strings;

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onServiceChanged);
    _seedFromProfile(widget.service.profile);
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      oldWidget.service.removeListener(_onServiceChanged);
      widget.service.addListener(_onServiceChanged);
    }
  }

  @override
  void dispose() {
    widget.service.removeListener(_onServiceChanged);
    _autoSaveTimer?.cancel();
    _nameController.dispose();
    _bioController.dispose();
    _customAvatarUrlController.dispose();
    super.dispose();
  }

  // ── service listener ───────────────────────────────────────────────────────

  void _onServiceChanged() {
    if (!mounted) return;
    final profile = widget.service.profile;
    setState(() {
      if (profile == null) {
        _seededProfileId = null;
        return;
      }
      if (profile.id != _seededProfileId) {
        _seedFromProfile(profile);
      } else if (_pendingAvatarBytes == null) {
        // Same user, avatar may have changed (e.g. after deletion)
        _avatarSource = _validSource(profile.avatarSource);
      }
    });
  }

  void _seedFromProfile(UserProfile? profile) {
    if (profile == null) return;
    _seededProfileId = profile.id;
    _nameController.text = profile.name;
    _bioController.text = profile.bio ?? '';
    _customAvatarUrlController.text = profile.customAvatarUrl ?? '';
    _avatarSource = _validSource(profile.avatarSource);
    _clearPendingAvatar();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  String _validSource(String? src) =>
      (['google', 'custom', 'upload'].contains(src)) ? src! : 'google';

  void _clearPendingAvatar() {
    _pendingAvatarBytes = null;
    _pendingAvatarMimeType = null;
    _pendingAvatarFileName = null;
  }

  void _refreshPreview() {
    setState(() {});
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) unawaited(_save(silent: true));
    });
  }

  // ── avatar source ──────────────────────────────────────────────────────────

  void _selectAvatarSource(String next, UserProfile profile) {
    if (next == 'google' && (profile.googleAvatarUrl ?? '').isEmpty) {
      _showSnackBar(_s.noGoogleAvatar);
      return;
    }
    if (next == 'upload') {
      unawaited(_pickAndUploadAvatarImage());
      return;
    }
    setState(() => _avatarSource = next);
    unawaited(_save(silent: true));
  }

  // ── file picker ────────────────────────────────────────────────────────────

  Future<void> _pickAndUploadAvatarImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp', 'gif'],
    );
    if (!mounted) return;
    if (result == null || result.files.isEmpty) {
      _removeAvatarImage();
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showSnackBar(_s.fileBytesError);
      return;
    }

    final mimeType = _detectMimeType(file);
    if (mimeType == null) {
      _showSnackBar(_s.fileUnsupported);
      return;
    }

    if (bytes.length > 1024 * 1024) {
      _showSnackBar(_s.fileTooLarge);
      return;
    }

    setState(() {
      _pendingAvatarBytes = bytes;
      _pendingAvatarMimeType = mimeType;
      _pendingAvatarFileName = file.name;
      _avatarSource = 'upload';
    });

    await _uploadAvatarImage();
  }

  String? _detectMimeType(PlatformFile file) {
    switch (file.extension?.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return null;
    }
  }

  Future<void> _uploadAvatarImage({bool showSuccess = true}) async {
    final bytes = _pendingAvatarBytes;
    final mimeType = _pendingAvatarMimeType;
    if (bytes == null || mimeType == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      await widget.service.uploadAvatarImage(
        bytesBase64: base64Encode(bytes),
        contentType: mimeType,
        fileName: _pendingAvatarFileName,
      );
      if (!mounted) return;
      setState(() {
        _clearPendingAvatar();
        _avatarSource = 'upload';
      });
      if (showSuccess) _showSnackBar(_s.uploadSuccess);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _removeAvatarImage() async {
    try {
      await widget.service.deleteAvatarImage();
      if (!mounted) return;
      setState(() {
        _clearPendingAvatar();
        final src = widget.service.profile?.avatarSource;
        _avatarSource = _validSource(src);
      });
      _showSnackBar(_s.removeSuccess);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString());
    }
  }

  // ── save ───────────────────────────────────────────────────────────────────

  Future<void> _save({bool silent = false}) async {
    try {
      if (_avatarSource == 'upload' && _pendingAvatarBytes != null) {
        await _uploadAvatarImage(showSuccess: false);
      }
      if (!mounted) return;
      await widget.service.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarSource: _avatarSource,
        customAvatarUrl: _customAvatarUrlController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString());
    }
  }

  // ── utils ──────────────────────────────────────────────────────────────────

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _previewAvatarUrl(UserProfile profile) {
    if (_avatarSource == 'custom') {
      return _customAvatarUrlController.text.trim();
    }
    if (_avatarSource == 'upload') {
      return profile.uploadedAvatarUrl ?? '';
    }
    return profile.googleAvatarUrl ?? '';
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profile = widget.service.profile;
    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_s.pageTitle)),
        body: Center(child: Text(_s.pleaseLogIn)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(_s.pageTitle)),
      body: _buildBody(profile),
    );
  }

  Widget _buildBody(UserProfile profile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Email: ${profile.email}'),
            const SizedBox(height: 20),
            Center(child: _buildAvatarPreview(profile)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: _s.name),
              onChanged: (_) => _refreshPreview(),
            ),
            const SizedBox(height: 12),
            _buildAvatarSourceSection(profile),
            const SizedBox(height: 12),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(labelText: _s.bio),
              onChanged: (_) => _scheduleAutoSave(),
            ),
            if (widget.extraContent != null) ...[
              const SizedBox(height: 16),
              widget.extraContent!,
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(UserProfile profile) {
    final hasPending = _pendingAvatarBytes != null && _avatarSource == 'upload';
    final avatarUrl = _previewAvatarUrl(profile);
    final hasAvatar = hasPending || avatarUrl.isNotEmpty;

    return Column(
      children: [
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.28),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: hasPending
                ? Image.memory(_pendingAvatarBytes!, fit: BoxFit.cover)
                : hasAvatar
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _AvatarFallback(
                      label: _nameController.text.trim(),
                    ),
                  )
                : _AvatarFallback(label: _nameController.text.trim()),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          hasAvatar
              ? (_isUploadingAvatar ? _s.uploading : _s.avatarPreview)
              : _s.noAvatar,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSourceSection(UserProfile profile) {
    String desc;
    switch (_avatarSource) {
      case 'custom':
        desc = _s.customAvatarDesc;
        break;
      case 'upload':
        desc = _s.uploadAvatarDesc;
        break;
      default:
        desc = _s.googleAvatarDesc;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _s.avatarSource,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            const ButtonSegment<String>(
              value: 'google',
              icon: Icon(Icons.account_circle_outlined),
              label: Text('Google'),
            ),
            ButtonSegment<String>(
              value: 'custom',
              icon: const Icon(Icons.edit_outlined),
              label: Text(_s.custom),
            ),
            ButtonSegment<String>(
              value: 'upload',
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(_s.upload),
            ),
          ],
          selected: {_avatarSource},
          onSelectionChanged: (sel) => _selectAvatarSource(sel.first, profile),
        ),
        const SizedBox(height: 8),
        Text(
          desc,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customAvatarUrlController,
          keyboardType: TextInputType.url,
          enabled: _avatarSource == 'custom',
          decoration: InputDecoration(
            labelText: _s.customAvatarUrl,
            hintText: 'https://example.com/avatar.png',
          ),
          onChanged: (_) => _refreshPreview(),
        ),
      ],
    );
  }
}

// ── internal fallback widget ────────────────────────────────────────────────

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = label.trim();
    final glyph = text.isEmpty ? '?' : text.characters.first;
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
