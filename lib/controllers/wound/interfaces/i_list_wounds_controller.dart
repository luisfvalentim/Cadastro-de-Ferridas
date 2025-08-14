import '../../../models/wound.dart';

abstract class IListWoundController {
  Future<List<Wound>> listAll();
}
