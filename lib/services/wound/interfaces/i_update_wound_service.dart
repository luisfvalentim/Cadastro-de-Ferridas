import '../../../models/wound.dart';

abstract class IUpdateWoundService {
  Future<bool> update(Wound wound);
}
