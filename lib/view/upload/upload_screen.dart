import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:napwork_task/services/api_service.dart';
import 'package:napwork_task/utils/app_colors.dart';

/// start region
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final nameController = TextEditingController();
  File? image;
  bool isLoading = false;

  /// Image Picker
  Future<void> pickImage(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source);
      if (file != null) {
        setState(() => image = File(file.path));
      }
    } catch (e) {
      showMessage('Permission denied or camera not available');
    }
  }

  Future<void> submit() async {
    if (nameController.text.trim().isEmpty) {
      showMessage('Please enter reference name');
      return;
    }

    setState(() => isLoading = true);
    try {
      await ApiService.uploadImage(image!.path, nameController.text.trim());
      if (!mounted) return;
      showMessage('Image uploaded successfully');
      nameController.clear();
      image = null;
    } catch (e) {
      if (!mounted) return;
      showMessage(ApiService.errorMessage(e));
    }
    setState(() => isLoading = false);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return image == null ? selectView() : previewView();
  }

  Widget selectView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          dashedBox(
            height: 160.h,
            onTap: () => pickImage(ImageSource.gallery),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 64.sp, color: AppColors.green),
                SizedBox(height: 4.h),
                Text('Browser Gallery', style: textStyle(14.sp)),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Row(
            children: [
              dashedLine(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text('OR', style: textStyle(14.sp)),
              ),
              dashedLine(),
            ],
          ),
          SizedBox(height: 40.h),
          dashedBox(
            height: 52.h,
            onTap: () => pickImage(ImageSource.camera),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 20.sp, color: AppColors.green),
                SizedBox(width: 12.w),
                Text('Open camera', style: textStyle(14.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget previewView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Image.file(
                image!,
                width: double.infinity,
                height: 549.h,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 24.h,
                right: 22.w,
                child: GestureDetector(
                  onTap: () => setState(() => image = null),
                  child: CircleAvatar(
                    radius: 11.r,
                    backgroundColor: AppColors.red,
                    child: Icon(Icons.close, size: 15.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: TextField(
              controller: nameController,
              style: textStyle(14.sp),
              decoration: InputDecoration(
                hintText: 'Reference Name',
                hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.hint),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 22.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 33.h),
          SizedBox(
            width: 113.w,
            height: 48.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashedBox({
    required double height,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(8.r),
        color: AppColors.green,
        dashPattern: const [9, 6],
        padding: EdgeInsets.zero,
        child: SizedBox(width: double.infinity, height: height, child: child),
      ),
    );
  }

  Widget dashedLine() {
    return Expanded(
      child: Row(
        children: List.generate(
          20,
          (_) => Expanded(
            child: Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              color: AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }

  TextStyle textStyle(double size) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: AppColors.text,
    );
  }
}

/// end region
