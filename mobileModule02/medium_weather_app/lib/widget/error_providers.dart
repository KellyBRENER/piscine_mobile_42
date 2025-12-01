import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

//provider qui stock le message d'erreur
final errorProvider = StateProvider<String?>((ref) => null);

