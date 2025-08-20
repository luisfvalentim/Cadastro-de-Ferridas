import 'package:cadastro_dados/controllers/wound/delete_wound_controller.dart';
import 'package:cadastro_dados/controllers/wound/list_wounds_controller.dart';
import 'package:cadastro_dados/services/wound/delete_wound_service.dart';
import 'package:cadastro_dados/views/update_wound_view.dart';
import 'package:flutter/material.dart';
import '../models/wound.dart';
import 'package:cadastro_dados/services/wound/list_wound_service.dart';

class WoundsListScreen extends StatefulWidget {
  @override
  _WoundsListScreen createState() => _WoundsListScreen();
}

class _WoundsListScreen extends State<WoundsListScreen> {
  final _woundController = ListWoundController(ListWoundsService());
  final _deleteWoundController = DeleteWoundController(DeleteWoundService());

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
    if (idQuery == null) return []; // Só permite buscas numéricas

    return wounds.where((w) => w.id == idQuery).toList();
  }

  Future<void> _deleteWound(Wound wound) async {
    if (wound.id == null) return;

    try {
      final success = await _deleteWoundController.delete(wound.id!);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ferida excluída com sucesso!')));
        _loadWounds();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir ferida')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  void _handleMenuAction(String action, Wound wound) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditWoundScreen(wound: wound),
          ),
        ).then((_) => _loadWounds()); // recarrega ao voltar
        break;

      case 'delete':
        _showDeleteConfirmation(wound);
        break;
    }
  }

  void _showDeleteConfirmation(Wound wound) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar Exclusão'),
            content: Text('Deseja realmente excluir a ferida ID ${wound.id}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteWound(wound);
                },
                child: Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por Id da Ferida',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
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
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text("ID: ${wound.id ?? 'Sem ID'}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Idade',
                          wound.idade?.toString() ?? 'N/A',
                        ),
                        _buildInfoRow('Sexo', wound.sexo ?? 'N/A'),
                        _buildInfoRow('Cor da Pele', wound.corPele ?? 'N/A'),
                        _buildInfoRow(
                          'Localização',
                          wound.localizacaoAnatomica ?? 'N/A',
                        ),
                        _buildInfoRow('Formato', wound.forma ?? 'N/A'),
                        _buildInfoRow('Origem', wound.origem ?? 'N/A'),
                        _buildInfoRow('Causa', wound.causa ?? 'N/A'),
                        _buildInfoRow(
                          'Comprimento',
                          '${wound.comprimento ?? 'N/A'} cm',
                        ),
                        _buildInfoRow(
                          'Largura',
                          '${wound.largura ?? 'N/A'} cm',
                        ),
                        _buildInfoRow(
                          'Extensão da Lesão',
                          '${wound.extensaoLesao ?? 'N/A'} cm²',
                        ),
                        _buildInfoRow('Evolução', wound.evolucao ?? 'N/A'),
                        _buildInfoRow(
                          'Data de Registro',
                          wound.dataRegistro ?? 'N/A',
                        ),
                        _buildInfoRow(
                          'Tipos de Tecido',
                          (wound.tiposTecidoDescricao != null &&
                                  wound.tiposTecidoDescricao!.isNotEmpty)
                              ? wound.tiposTecidoDescricao!.join(', ')
                              : 'N/A',
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, wound),
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Excluir'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
