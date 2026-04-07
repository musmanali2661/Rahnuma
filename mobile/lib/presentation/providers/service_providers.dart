import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';

/// Global singleton providers for services.

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
