import '../../../models/wound.dart';

abstract class ICreateWoundService {
  Future<bool> create(Wound wound);
}
