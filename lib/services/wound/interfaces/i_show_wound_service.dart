// i_show_wound_service.dart
import '../../../models/wound.dart';

abstract class IShowWoundService {
  Future<Wound> getById(int id);
}
