import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True after successful static admin email/password sign-in (no Firebase Auth required).
final staticAdminSessionProvider = StateProvider<bool>((ref) => false);
