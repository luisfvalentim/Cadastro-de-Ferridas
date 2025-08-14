import '../../../models/wound.dart';

abstract class IShowWoundController {
  Future<Wound> show(int id);
}
