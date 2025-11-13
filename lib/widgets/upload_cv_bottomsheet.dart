import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jobseeker_app/controllers/portofolio_controller.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class UploadCvBottomSheet extends StatefulWidget {
  final PortfolioController portfolioController;
  final Function(String filePath)? onCvUploaded;

  const UploadCvBottomSheet({
    super.key,
    required this.portfolioController,
    this.onCvUploaded,
  });

  @override
  State<UploadCvBottomSheet> createState() => _UploadCvBottomSheetState();
}

class _UploadCvBottomSheetState extends State<UploadCvBottomSheet> {
  File? _selectedCv;
  bool _isUploading = false;

  Future<void> _pickCvFile() async {
    if (widget.portfolioController.cvFilePath != null) {
      final shouldReplace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: ColorsApp.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Replace CV?",
            style: TextStyle(
              color: ColorsApp.primarydark,
              fontFamily: "Lato",
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            "You already uploaded a CV. Uploading a new one will replace the old CV. Continue?",
            style: TextStyle(
              color: ColorsApp.Grey1,
              fontFamily: "Lato",
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: ColorsApp.Grey1),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsApp.primarydark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Replace",
                style: TextStyle(color: ColorsApp.white),
              ),
            ),
          ],
        ),
      );

      if (shouldReplace != true) return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedCv = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadCv() async {
    if (_selectedCv == null) return;

    setState(() => _isUploading = true);

    final fileName = _selectedCv!.path.split('/').last;

    final success = await widget.portfolioController.uploadCv(
      context,
      _selectedCv!.path,
      fileName: fileName,
    );

    setState(() => _isUploading = false);

    if (success) {
      await widget.portfolioController.loadPortfolio(); // refresh data
      widget.onCvUploaded?.call(widget.portfolioController.cvFilePath ?? "");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingCvPath = widget.portfolioController.cvFilePath;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 48,
        left: 24,
        right: 24,
        top: 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Upload CV",
                style: TextStyle(
                  fontFamily: "Lato",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // EXISTING CV
          if (existingCvPath != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: ColorsApp.primarylight,
                border: Border.all(color: ColorsApp.Grey3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/image/pdf.png",
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      existingCvPath.split('/').last,
                      style: const TextStyle(
                        fontFamily: "Lato",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: ColorsApp.white,
                          title: const Text(
                            "Delete CV?",
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: const Text(
                            "Are you sure you want to delete your current CV?",
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: ColorsApp.Grey1),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsApp.primarydark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: ColorsApp.white),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await widget.portfolioController.deleteCv(context);
                        await widget.portfolioController
                            .loadPortfolio(); // refresh
                        setState(() {});
                      }
                    },
                  )
                ],
              ),
            ),

          // PICK NEW FILE
          if (_selectedCv != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: ColorsApp.primarylight,
                border: Border.all(color: ColorsApp.primarydark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/image/pdf.png",
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCv!.path.split('/').last,
                      style: const TextStyle(
                        fontFamily: "Lato",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: ColorsApp.primarydark,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _pickCvFile,
                  icon: const Icon(Icons.add, color: ColorsApp.primarydark),
                  label: const Text(
                    "Add CV",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ColorsApp.primarydark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadCv,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.primarydark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Upload CV",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
