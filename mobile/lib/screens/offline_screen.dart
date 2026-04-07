import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/road_event.dart';
import '../providers/route_provider.dart';

/// Offline maps screen — list of city packages available for download.
class OfflineScreen extends ConsumerStatefulWidget {
  const OfflineScreen({super.key});

  @override
  ConsumerState<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends ConsumerState<OfflineScreen> {
  List<OfflinePackage> _packages = [];
  bool _loading = true;
  String? _error;
  final Map<String, bool> _downloading = {};

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiServiceProvider);
      final packages = await api.listOfflinePackages();
      if (mounted) {
        setState(() {
          _packages = packages;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  String _formatSize(int? bytes, int estimatedMb) {
    if (bytes != null) {
      final mb = bytes / (1024 * 1024);
      return mb > 1000
          ? '${(mb / 1024).toStringAsFixed(1)} GB'
          : '${mb.toStringAsFixed(0)} MB';
    }
    return '~$estimatedMb MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Offline Maps'),
            Text(
              'آف لائن نقشے',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPackages,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPackages,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final pkg = _packages[index];
                      final isDownloading = _downloading[pkg.id] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: pkg.available
                                ? Colors.green.shade100
                                : Colors.grey.shade100,
                            child: Icon(
                              pkg.available
                                  ? Icons.check_circle
                                  : Icons.map_outlined,
                              color: pkg.available
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                          title: Text(pkg.name),
                          subtitle: Text(
                            pkg.available
                                ? 'Downloaded · ${_formatSize(pkg.fileSizeBytes, pkg.sizeMb)}'
                                : _formatSize(null, pkg.sizeMb),
                          ),
                          trailing: isDownloading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : pkg.available
                                  ? const Text(
                                      '✓ Ready',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : ElevatedButton(
                                      onPressed: () async {
                                        setState(() =>
                                            _downloading[pkg.id] = true);
                                        try {
                                          final api =
                                              ref.read(apiServiceProvider);
                                          await api.downloadOfflinePackage(
                                            pkg.id,
                                            onProgress: (p) {
                                              // Progress handled visually
                                              // via the downloading indicator
                                            },
                                          );
                                        } catch (e) {
                                          if (mounted) {
                                            setState(() =>
                                                _error = 'Download failed: $e');
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() =>
                                                _downloading[pkg.id] = false);
                                            _loadPackages();
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12)),
                                      child: const Text('Download'),
                                    ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
