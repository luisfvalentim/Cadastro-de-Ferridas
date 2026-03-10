import 'package:flutter/material.dart';
import 'package:cadastro_dados/controllers/wound/list_wounds_controller.dart';
import 'package:cadastro_dados/controllers/wound/delete_wound_controller.dart';
import 'package:cadastro_dados/services/wound/list_wound_service.dart';
import 'package:cadastro_dados/services/wound/delete_wound_service.dart';
import 'package:cadastro_dados/custom/custom_search_field.dart';
import 'package:cadastro_dados/widgets/wound_info_list.dart';
import '../models/wound.dart';
import 'update_wound_view.dart';

class WoundsListScreen extends StatefulWidget {
  const WoundsListScreen({super.key});

  @override
  State<WoundsListScreen> createState() => _WoundsListScreenState();
}

class _WoundsListScreenState extends State<WoundsListScreen> {
  final _woundController = ListWoundController(ListWoundsService());
  final _deleteController = DeleteWoundController(DeleteWoundService());

  List<Wound> _wounds = [];
  List<Wound> _filtered = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  final Set<int> _selectedForCompare = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _woundController.listAll();
      setState(() {
        _wounds = data;
        _filtered = _applyFilter(data, _query);
      });
    } catch (e) {
      setState(() => _error = 'Erro ao carregar os dados: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Wound> _applyFilter(List<Wound> list, String q) {
    if (q.isEmpty) return list;
    final id = int.tryParse(q);
    if (id == null) return [];
    return list.where((w) => w.pacienteId == id).toList();
  }

  void _toggleCompare(int? id) {
    if (id == null) return;
    setState(() {
      if (_selectedForCompare.contains(id)) {
        _selectedForCompare.remove(id);
      } else {
        if (_selectedForCompare.length >= 2) {
          _selectedForCompare.clear();
        }
        _selectedForCompare.add(id);
      }
    });
  }

  void _openFull(String? url) {
    if (url == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ImageFullScreen(url: url)),
    );
  }

  void _openCompare() {
    final sel = _filtered
        .where((w) => w.id != null && _selectedForCompare.contains(w.id))
        .take(2)
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _CompareWoundsScreen(wounds: sel)),
    );
  }

  void _handleMenu(String action, Wound w) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditWoundScreen(wound: w)),
        ).then((_) => _load());
        break;
      case 'delete':
        _confirmDelete(w);
        break;
    }
  }

  Future<void> _confirmDelete(Wound w) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Excluir ferida ID ${w.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && w.id != null) {
      try {
        final success = await _deleteController.delete(w.id!);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ferida excluída')));
          _load();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Listagem de Feridas'),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorWidget()
              : _listWidget(),
    );
  }

  Widget _errorWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Erro ao carregar os dados', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Text(_error ?? ''),
            ElevatedButton(onPressed: _load, child: const Text('Tentar novamente')),
          ],
        ),
      );

  Widget _listWidget() {
    if (_wounds.isEmpty) {
      return const Center(child: Text('Nenhuma ferida encontrada'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomSearchField(
                  hint: 'Buscar por ID do paciente',
                  onChanged: (v) {
                    setState(() {
                      _query = v;
                      _filtered = _applyFilter(_wounds, v);
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final w = _filtered[index];
                    final selected = w.id != null && _selectedForCompare.contains(w.id);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ID: ${w.id ?? 'Sem ID'}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  WoundInfoList(wound: w),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 170,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: selected,
                                        onChanged: (_) => _toggleCompare(w.id),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (v) => _handleMenu(v, w),
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: ListTile(
                                              leading: Icon(Icons.edit, color: Colors.blue),
                                              title: Text('Editar'),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(Icons.delete, color: Colors.red),
                                              title: Text('Excluir'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (w.imagemUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            w.imagemUrl!,
                                            height: 170,
                                            width: 170,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.broken_image,
                                              size: 80,
                                              color: Colors.red,
                                            ),
                                          ),
                                          Positioned(
                                            right: 4,
                                            top: 4,
                                            child: IconButton(
                                              icon: const Icon(Icons.fullscreen, color: Colors.white),
                                              tooltip: 'Ver em tela cheia',
                                              onPressed: () => _openFull(w.imagemUrl!),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
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
          if (_selectedForCompare.length == 2)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: _openCompare,
                label: const Text('Comparar (2)'),
                icon: const Icon(Icons.compare),
              ),
            ),
        ],
      ),
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

class _CompareWoundsScreen extends StatelessWidget {
  final List<Wound> wounds;
  const _CompareWoundsScreen({required this.wounds});

  @override
  Widget build(BuildContext context) {
    final left = wounds.isNotEmpty ? wounds[0] : null;
    final right = wounds.length > 1 ? wounds[1] : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Comparar Feridas')),
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Expanded(child: _pane(left)),
          Expanded(child: _pane(right)),
        ],
      ),
    );
  }

  Widget _pane(Wound? w) {
    if (w == null) {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white70, size: 80),
      );
    }
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            child: w.imagemUrl != null
                ? Image.network(
                    w.imagemUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, color: Colors.red, size: 120),
                  )
                : const Icon(Icons.image_not_supported, color: Colors.grey, size: 120),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'ID: ${w.id ?? 'N/A'} | Paciente: ${w.pacienteId ?? 'N/A'}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
