import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vietmap_map/constants/route.dart';

class PermissionLocationWidget extends StatefulWidget {
  final VoidCallback? onPermissionGranted;
  final String? pathRiderect;

  const PermissionLocationWidget({
    super.key,
    this.onPermissionGranted,
    this.pathRiderect,
  });

  @override
  State<PermissionLocationWidget> createState() =>
      _PermissionLocationWidgetState();
}

class _PermissionLocationWidgetState extends State<PermissionLocationWidget> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    debugPrint('Requesting location permission... ${widget.pathRiderect}');
    setState(() {
      _isRequesting = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        if (widget.onPermissionGranted != null) {
          widget.onPermissionGranted!();
        } else if (mounted) {
          context.pushReplacementNamed((widget.pathRiderect ?? Routes.mapScreen));
        }
      } else if (permission == LocationPermission.deniedForever) {
        _showOpenSettingsDialog();
      }
    } catch (e) {
      _showErrorDialog();
    } finally {
      setState(() {
        _isRequesting = false;
      });
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quyền bị từ chối'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          content: const Text(
            'Bạn đã từ chối quyền vị trí vĩnh viễn. Vui lòng mở Cài đặt để cấp quyền.',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                context.pop();
                await openAppSettings().then((value) {
                  if (context.mounted && value) {
                    context
                        .pushReplacementNamed((widget.pathRiderect ?? Routes.mapScreen));
                  }
                });
              },
              child: const Text('Mở Cài đặt'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lỗi'),
          content: const Text(
            'Đã xảy ra lỗi khi yêu cầu quyền. Vui lòng thử lại.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Location Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 70,
                color: Colors.blue.shade700,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              'Cấp quyền truy cập vị trí',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'Ứng dụng cần quyền truy cập vị trí của bạn để hiển thị bản đồ, điều hướng và cung cấp trải nghiệm tốt nhất.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Features list
            _buildFeatureItem(
              icon: Icons.map_rounded,
              title: 'Hiển thị vị trí trên bản đồ',
              description: 'Xem vị trí hiện tại của bạn trên bản đồ',
            ),

            const SizedBox(height: 12),

            _buildFeatureItem(
              icon: Icons.navigation_rounded,
              title: 'Điều hướng chính xác',
              description: 'Nhận chỉ dẫn đường đi theo thời gian thực',
            ),

            const SizedBox(height: 12),

            _buildFeatureItem(
              icon: Icons.near_me_rounded,
              title: 'Tìm kiếm gần đây',
              description: 'Khám phá địa điểm xung quanh bạn',
            ),

            const SizedBox(height: 40),

            // Request Permission Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isRequesting ? null : _requestPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isRequesting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Cấp quyền truy cập',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Text(
              'Bạn có thể thay đổi quyền này bất cứ lúc nào trong Cài đặt',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
