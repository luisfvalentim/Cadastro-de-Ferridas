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
  bool _loading = true;

  final String scriptUrl =
      'https://script.google.com/macros/s/AKfycbwC0N9nv8xoPnWH-pz8wyFycihogTDAhCeLQq4BAjccTvj0R6_MZ0IZ0N2XguoogqYF/exec';

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.get(Uri.parse(scriptUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _images = data;
          _loading = false;
        });
      } else {
        throw Exception('Erro ao carregar imagens');
      }
    } catch (e) {
      print('Erro: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Imagens do Google Drive')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : _images.isEmpty
              ? Center(child: Text('Nenhuma imagem encontrada.'))
              : GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 1,
                itemBuilder: (context, index) {
                  final image = _images[index];
                  final url = image['url'];

                  final controller =
                      WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadRequest(Uri.parse(url));

                  return GridTile(
                    footer: Container(
                      color: Colors.black54,
                      padding: EdgeInsets.all(4),
                      child: Text(
                        image['name'] ?? 'Sem nome',
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    child: WebViewWidget(controller: controller),
                  );
                },
              ),
    );
  }
}
