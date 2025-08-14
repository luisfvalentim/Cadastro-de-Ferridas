import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class DriveImagesPage extends StatefulWidget {
  @override
  _DriveImagesPageState createState() => _DriveImagesPageState();
}

class _DriveImagesPageState extends State<DriveImagesPage> {
  List<dynamic> _images = [];
  bool _isLoading = true;
  String? _error;

  final String scriptUrl =
      'https://script.google.com/macros/s/AKfycbwC0N9nv8xoPnWH-pz8wyFycihogTDAhCeLQq4BAjccTvj0R6_MZ0IZ0N2XguoogqYF/exec';

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse(scriptUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _images = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar imagens: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar imagens: $e');
      setState(() {
        _error = 'Erro ao carregar imagens: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Imagens do Google Drive',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.blue),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchImages,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Carregando imagens...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erro ao carregar imagens',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchImages,
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma imagem encontrada',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Verifique se há imagens no Google Drive',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchImages,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final image = _images[index];
          final url = image['url'];
          final name = image['name'] ?? 'Sem nome';

          return _buildImageCard(url, name, index);
        },
      ),
    );
  }

  Widget _buildImageCard(String url, String name, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: _buildWebView(url),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 4),
                Text(
                  'Imagem ${index + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView(String url) {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));

      return WebViewWidget(controller: controller);
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Erro ao carregar imagem',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
