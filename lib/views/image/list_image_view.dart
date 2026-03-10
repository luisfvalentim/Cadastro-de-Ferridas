import 'package:flutter/material.dart';
import 'package:cadastro_dados/controllers/image/list_imagem_controller.dart'
    as controller;
import 'package:cadastro_dados/services/image/list_imagem_service.dart'
    as service;
import 'package:cadastro_dados/config/config.dart';
import 'package:cadastro_dados/controllers/image/delete_imagem_controller.dart';
import 'package:cadastro_dados/services/image/delete_imagem_service.dart';

class ListImagemView extends StatefulWidget {
  const ListImagemView({super.key});

  @override
  State<ListImagemView> createState() => _ListImagemViewState();
}

class _ListImagemViewState extends State<ListImagemView> {
  late controller.ListImagemController _controller;
  late Future<List<Map<String, dynamic>>> _futureImagens;
  final _deleteController = DeleteImagemController(DeleteImagemService());
  final Set<int> _selecionadas = {};

  @override
  void initState() {
    super.initState();
    _controller = controller.ListImagemController(service.ListImagemService());
    _carregarImagens();
  }

  void _carregarImagens() {
    setState(() {
      _futureImagens = _controller.listar();
    });
  }

  Future<void> _deleteImagem(int id) async {
    try {
      final sucesso = await _deleteController.delete(id);
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Imagem deletada com sucesso!")),
        );
        _carregarImagens(); // atualiza lista
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao deletar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Imagens salvas")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureImagens,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }
          final imagens = snapshot.data ?? [];
          if (imagens.isEmpty) {
            return const Center(child: Text("Nenhuma imagem encontrada."));
          }
          return Stack(
            children: [
              ListView.builder(
                itemCount: imagens.length,
                itemBuilder: (context, index) {
                  final img = imagens[index];
                  final caminho = img['caminho']?.toString() ?? '';
                  final url = img['url']?.toString();
                  final id = img['id'] as int;
                  final selecionada = _selecionadas.contains(id);
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      onTap: () => _toggleSelecao(id),
                      leading: Stack(
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: url != null
                                ? Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  )
                                : const Icon(Icons.image_not_supported),
                          ),
                          if (selecionada)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Icon(Icons.check_circle,
                                  color: Colors.green.shade600),
                            ),
                        ],
                      ),
                      title: Text("ID: $id"),
                      subtitle: Text(caminho),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text("Confirmar exclusão"),
                                    content: const Text(
                                      "Deseja realmente excluir esta imagem?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text("Cancelar"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text(
                                          "Excluir",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true) {
                              _deleteImagem(id);
                            }
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text("Excluir"),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              ),
              if (_selecionadas.length == 2)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      final sel = imagens
                          .where((img) => _selecionadas.contains(img['id']))
                          .take(2)
                          .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _CompareImagesScreen(imagens: sel),
                        ),
                      );
                    },
                    label: const Text('Comparar (2)'),
                    icon: const Icon(Icons.compare),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _toggleSelecao(int id) {
    setState(() {
      if (_selecionadas.contains(id)) {
        _selecionadas.remove(id);
      } else {
        if (_selecionadas.length >= 2) {
          _selecionadas.clear();
        }
        _selecionadas.add(id);
      }
    });
  }
}

class _CompareImagesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> imagens;
  const _CompareImagesScreen({required this.imagens});

  @override
  Widget build(BuildContext context) {
    final left = imagens.isNotEmpty ? imagens[0]['url']?.toString() : null;
    final right = imagens.length > 1 ? imagens[1]['url']?.toString() : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Comparar Imagens')),
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Expanded(child: _zoomable(left)),
          Expanded(child: _zoomable(right)),
        ],
      ),
    );
  }

  Widget _zoomable(String? url) {
    if (url == null) {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white70, size: 80),
      );
    }
    return InteractiveViewer(
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.red, size: 120),
      ),
    );
  }
}
