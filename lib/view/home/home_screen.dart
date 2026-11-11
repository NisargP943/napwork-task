import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:napwork_task/utils/app_colors.dart';
import 'package:napwork_task/view/images/images_screen.dart';
import 'package:napwork_task/view/upload/upload_screen.dart';

///start region
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.navBar,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: currentIndex,
            sizing: StackFit.expand,
            children: const [UploadScreen(), ImagesScreen()],
          ),
        ),
        bottomNavigationBar: Container(
          color: AppColors.navBar,
          child: SafeArea(
            top: false,
            child: Container(
              height: 64.h,
              padding: EdgeInsets.symmetric(horizontal: 34.w),
              child: Row(
                children: [
                  navItem(0, Icons.home, 'Upload'),
                  navItem(1, Icons.account_circle_outlined, 'Images'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget navItem(int index, IconData icon, String label) {
    final bool selected = currentIndex == index;
    final Color color = selected ? AppColors.green : AppColors.text;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26.sp, color: color),
            SizedBox(height: 4.h),
            SizedBox(
              height: 20.h,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: selected ? 14.sp : 12.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// end region
