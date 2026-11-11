import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:napwork_task/utils/app_colors.dart';

///start region
class ImagesScreen extends StatefulWidget {
  const ImagesScreen({super.key});

  @override
  State<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  List<Map> images = [];
  StreamSubscription? subscription;

  final gridKey = GlobalKey<AnimatedGridState>();

  @override
  void initState() {
    super.initState();

    /// Call Firestore instance and start a stream
    subscription = FirebaseFirestore.instance
        .collection('images')
        .orderBy('created_at')
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              images.add(change.doc.data()!);
              gridKey.currentState?.insertItem(images.length - 1);
            }
          }
        }, onError: (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not load images')),
          );
        });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGrid(
      key: gridKey,
      padding: EdgeInsets.fromLTRB(12.w, 15, 12.w, 16.h),
      initialItemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisExtent: 180.w + 44.h,
      ),
      itemBuilder: (context, index, animation) {
        final item = images[index];
        return FadeTransition(
          opacity: animation,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: CachedNetworkImage(
                  alignment: Alignment.topCenter,
                  imageUrl: item['url'],
                  width: double.infinity,
                  height: 180.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                item['reference_name'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

///end region
