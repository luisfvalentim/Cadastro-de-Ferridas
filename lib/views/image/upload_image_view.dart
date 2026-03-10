import 'dart:io';
import 'package:cadastro_dados/controllers/image/upload_imagem_controller.dart';
import 'package:cadastro_dados/services/image/upload_imagem_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class UploadImagemView extends StatefulWidget {
  const UploadImagemView({super.key});

  @override
  State<UploadImagemView> createState() => _UploadImagemViewState();
}

class _UploadImagemViewState extends State<UploadImagemView> {
  final ImagePicker _picker = ImagePicker();
  final _controller = UploadImagemController(UploadImagemService());

  List<XFile> _imagensSelecionadas = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _imagensEnviadas = [];

  Future<void> _selecionarImagens() async {
    final List<XFile>? files = await _picker.pickMultiImage();

    if (files != null && files.isNotEmpty) {
      setState(() {
        _imagensSelecionadas = files;
      });
    }
  }

  Future<void> _uploadImagens() async {
    if (_imagensSelecionadas.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await _controller.uploadImagens(
        kIsWeb
            ? _imagensSelecionadas
            : _imagensSelecionadas.map((x) => File(x.path)).toList(),
      );

      setState(() {
        _imagensEnviadas = result;
        _imagensSelecionadas = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Imagens enviadas com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao enviar imagens: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPreview(XFile file) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child:
          kIsWeb
              ? Image.network(file.path, width: 100, fit: BoxFit.cover)
              : Image.file(
                File(file.path),
                width: 100,
                fit: BoxFit.cover,
              ), // Mobile
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload de Imagens")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _selecionarImagens,
              icon: const Icon(Icons.photo_library),
              label: const Text("Selecionar Imagens"),
            ),
            const SizedBox(height: 16),
            if (_imagensSelecionadas.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagensSelecionadas.length,
                  itemBuilder:
                      (context, index) =>
                          _buildPreview(_imagensSelecionadas[index]),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _uploadImagens,
              icon: const Icon(Icons.cloud_upload),
              label:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enviar Imagens"),
            ),
            const SizedBox(height: 24),
            if (_imagensEnviadas.isNotEmpty) ...[
              const Text("Imagens salvas no servidor:"),
              Expanded(
                child: ListView.builder(
                  itemCount: _imagensEnviadas.length,
                  itemBuilder: (context, index) {
                    final img = _imagensEnviadas[index];
                    final imagens = img['url'].toString().replaceAll(
                      'storage',
                      'arquivos',
                    );
                    return ListTile(
                      leading: Image.network(imagens, width: 60),
                      title: Text("ID: ${img['id']}"),
                      subtitle: Text(img['caminho']),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
