import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/map_skin.dart';

/// Currently selected map skin.
final mapSkinProvider = StateProvider<MapSkin>((ref) => MapSkin.tactical);
