import '../../../models/wound.dart';

abstract class ICreateWoundController {
  Future<bool> create(Wound wound);
}
