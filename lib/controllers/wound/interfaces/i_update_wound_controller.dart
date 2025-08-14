import '../../../models/wound.dart';

abstract class IUpdateWoundController {
  Future<bool> update(Wound wound);
}
