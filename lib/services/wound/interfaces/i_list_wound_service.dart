import '../../../models/wound.dart';

abstract class IListWoundsService {
  Future<List<Wound>> getAll();
}
