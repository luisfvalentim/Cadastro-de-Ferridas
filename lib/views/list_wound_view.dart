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

    return wounds.where((w) {
      final lowerQuery = query.toLowerCase();
      return (w.sexo?.toLowerCase().contains(lowerQuery) ?? false) ||
          (w.forma?.toLowerCase().contains(lowerQuery) ?? false) ||
          (w.origem?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
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
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar por sexo, forma ou origem...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white60),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _filteredWounds = _applySearchFilter(_wounds, value);
            });
          },
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
      child: ListView.builder(
        itemCount: _filteredWounds.length,
        itemBuilder: (context, index) {
          final wound = _filteredWounds[index];

          return Card(
            child: ListTile(
              title: Text("ID: ${wound.id ?? 'Sem ID'}"),
              subtitle: Text("Sexo: ${wound.sexo ?? 'Indefinido'}"),
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
    );
  }
}
