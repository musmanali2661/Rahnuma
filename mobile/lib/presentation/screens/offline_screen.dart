import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../data/models/offline_package_model.dart';
import '../../data/services/offline_db_service.dart';
import '../providers/service_providers.dart';

/// Offline maps management screen.
///
/// Lists available city map packages from the server and allows
/// the user to download or delete them.
class OfflineScreen extends ConsumerStatefulWidget {
  const OfflineScreen({super.key});

  @override
  ConsumerState<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends ConsumerState<OfflineScreen> {
  List<OfflinePackage> _packages = [];
  Set<String> _downloadedCities = {};
  bool _isLoading = true;
  String? _error;
  final Map<String, double> _downloadProgress = {};

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final db = OfflineDbService.instance;
      final packages = await api.listOfflinePackages();
      final downloaded = await db.downloadedCities();
      setState(() {
        _packages = packages;
        _downloadedCities = downloaded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _download(OfflinePackage pkg) async {
    final db = OfflineDbService.instance;
    final savePath = await db.packageSavePath(pkg.city);

    setState(() => _downloadProgress[pkg.city] = 0.0);

    try {
      final api = ref.read(apiServiceProvider);
      await api.downloadPackage(
        pkg.city,
        savePath,
        (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress[pkg.city] = received / total;
            });
          }
        },
      );

      await db.markDownloaded(
        city: pkg.city,
        displayName: pkg.displayName,
        sizeMb: pkg.sizeMb,
        filePath: savePath,
      );

      setState(() {
        _downloadedCities.add(pkg.city);
        _downloadProgress.remove(pkg.city);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pkg.displayName} downloaded successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _downloadProgress.remove(pkg.city));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _delete(OfflinePackage pkg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Map'),
        content: Text(
            'Delete the offline map for ${pkg.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.dangerRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await OfflineDbService.instance.removePackage(pkg.city);
      setState(() => _downloadedCities.remove(pkg.city));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Maps'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPackages,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load packages',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _loadPackages,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _packages.isEmpty
                  ? const Center(
                      child: Text(
                        'No city packages available',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Available City Maps',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _packages.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final pkg = _packages[i];
                              final isDownloaded =
                                  _downloadedCities.contains(pkg.city);
                              final progress =
                                  _downloadProgress[pkg.city];

                              return _PackageTile(
                                package: pkg,
                                isDownloaded: isDownloaded,
                                downloadProgress: progress,
                                onDownload: () => _download(pkg),
                                onDelete: () => _delete(pkg),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({
    required this.package,
    required this.isDownloaded,
    required this.onDownload,
    required this.onDelete,
    this.downloadProgress,
  });

  final OfflinePackage package;
  final bool isDownloaded;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final double? downloadProgress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDownloaded
              ? AppColors.primaryGreen.withAlpha(26)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isDownloaded ? Icons.map : Icons.map_outlined,
          color: isDownloaded
              ? AppColors.primaryGreen
              : Colors.grey.shade500,
        ),
      ),
      title: Text(
        package.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${package.sizeMb.toStringAsFixed(0)} MB',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          if (downloadProgress != null) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: downloadProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen),
            ),
            const SizedBox(height: 2),
            Text(
              '${(downloadProgress! * 100).toInt()}%',
              style: const TextStyle(fontSize: 11),
            ),
          ],
          if (isDownloaded && downloadProgress == null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.check_circle,
                    size: 12, color: AppColors.primaryGreen),
                const SizedBox(width: 4),
                const Text(
                  'Downloaded',
                  style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: downloadProgress != null
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGreen,
              ),
            )
          : isDownloaded
              ? IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.dangerRed),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                )
              : IconButton(
                  icon: const Icon(Icons.download,
                      color: AppColors.primaryGreen),
                  onPressed: onDownload,
                  tooltip: 'Download',
                ),
    );
  }
}
