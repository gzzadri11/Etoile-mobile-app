library;

/// Boite de dialogue de recadrage circulaire pour les photos de profil.

import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Full-screen dialog for circular image cropping.
///
/// Returns cropped [Uint8List] bytes via Navigator.pop, or null if cancelled.
class CircleCropDialog extends StatefulWidget {
  final Uint8List imageBytes;

  const CircleCropDialog({super.key, required this.imageBytes});

  /// Show the crop dialog and return cropped bytes (or null if cancelled).
  static Future<Uint8List?> show(BuildContext context, Uint8List imageBytes) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CircleCropDialog(imageBytes: imageBytes),
      ),
    );
  }

  @override
  State<CircleCropDialog> createState() => _CircleCropDialogState();
}

class _CircleCropDialogState extends State<CircleCropDialog> {
  final _cropController = CropController();
  bool _isCropping = false;

  void _onCrop() {
    setState(() => _isCropping = true);
    _cropController.crop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.bgPrimary,
        title: const Text('Recadrer la photo'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isCropping ? null : _onCrop,
            child: _isCropping
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                : const Text(
                    'Valider',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
        ],
      ),
      body: Crop(
        image: widget.imageBytes,
        controller: _cropController,
        onCropped: (croppedBytes) {
          Navigator.of(context).pop(croppedBytes);
        },
        withCircleUi: true,
        baseColor: Colors.black,
        maskColor: Colors.black.withValues(alpha: 0.7),
        interactive: true,
        fixCropRect: true,
        progressIndicator: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),
    );
  }
}
