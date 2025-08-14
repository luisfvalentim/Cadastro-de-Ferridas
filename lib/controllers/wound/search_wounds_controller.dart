import 'interfaces/i_search_wounds_controller.dart';
import '../../services/wound/interfaces/i_search_wounds_service.dart';

class SearchWoundsController implements ISearchWoundsController {
  final ISearchWoundsService _service;

  SearchWoundsController(this._service);

  @override
  Future<List<dynamic>> search(Map<String, dynamic> filters) {
    return _service.search(filters);
  }
}
