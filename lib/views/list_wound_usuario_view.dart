import 'package:cadastro_dados/config/helpers/label_from_map.dart';
import 'package:cadastro_dados/constats/wound_constants.dart';
import 'package:cadastro_dados/controllers/wound/list_wounds_controller.dart';
import 'package:cadastro_dados/custom/custom_search_field.dart';
import 'package:cadastro_dados/widgets/wound_info_list.dart';
import 'package:flutter/material.dart';
import '../models/wound.dart';
import 'package:cadastro_dados/services/wound/list_wound_service.dart';

class WoundsListScreenUsuario extends StatefulWidget {
  const WoundsListScreenUsuario({super.key});

  @override
  _WoundsListScreenUsuario createState() => _WoundsListScreenUsuario();
}

class _WoundsListScreenUsuario extends State<WoundsListScreenUsuario> {
  final _woundController = ListWoundController(ListWoundsService());

  List<Wound> _wounds = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  List<Wound> _filteredWounds = [];

  @override
  void initState() {
    super.initState();
    _loadWounds();
  }

  Future<void> _loadWounds() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final wounds = await _woundController.listAll();
      setState(() {
        _wounds = wounds;
        _filteredWounds = _applySearchFilter(wounds, _searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar os dados: $e';
        _isLoading = false;
      });
    }
  }

  List<Wound> _applySearchFilter(List<Wound> wounds, String query) {
    if (query.isEmpty) return wounds;
    final idQuery = int.tryParse(query);
    if (idQuery == null) return [];
    return wounds.where((w) => w.pacienteId == idQuery).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Listagem de Feridas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadWounds),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Erro ao carregar os dados",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 10),
            Text(_error!, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadWounds,
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }
    if (_wounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Nenhuma ferida encontrada",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Adicione uma nova ferida para começar",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadWounds,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchField(
              hint: "Buscar por ID do Paciente",
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filteredWounds = _applySearchFilter(_wounds, value);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredWounds.length,
              itemBuilder: (context, index) {
                final wound = _filteredWounds[index];

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📝 Parte escrita
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ID: ${wound.id ?? 'Sem ID'}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              WoundInfoList(wound: wound),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 📸 Imagem ampliada e centralizada
                        SizedBox(
                          width: 170,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (wound.imagemUrl != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        wound.imagemUrl!,
                                        height: 170,
                                        width: 170,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.broken_image,
                                            size: 80,
                                            color: Colors.red,
                                          );
                                        },
                                      ),
                                      Positioned(
                                        right: 4,
                                        top: 4,
                                        child: IconButton(
                                          icon: const Icon(Icons.fullscreen, color: Colors.white),
                                          tooltip: 'Ver em tela cheia',
                                          onPressed: () => _abrirImagemFull(context, wound.imagemUrl!),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else
                                const Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _abrirImagemFull(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ImageFullScreen(url: url)),
    );
  }
}

class _ImageFullScreen extends StatelessWidget {
  final String url;
  const _ImageFullScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, color: Colors.red, size: 120),
          ),
        ),
      ),
    );
  }
}
