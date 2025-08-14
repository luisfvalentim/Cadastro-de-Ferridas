import 'package:cadastro_dados/constats/wound_constants.dart';
import 'package:cadastro_dados/controllers/wound/show_wound_controller.dart';
import 'package:cadastro_dados/services/wound/show_wound_service.dart';
import 'package:flutter/material.dart';
import '../models/wound.dart';
import '../controllers/wound/delete_wound_controller.dart';
import '../services/wound/delete_wound_service.dart';

class DeleteScreen extends StatefulWidget {
  @override
  _DeleteScreenState createState() => _DeleteScreenState();
}

class _DeleteScreenState extends State<DeleteScreen> {
  final TextEditingController _idController = TextEditingController();
  final _showWoundController = ShowWoundController(ShowWoundService());
  // para buscar
  final DeleteWoundController _deleteController = DeleteWoundController(
    DeleteWoundService(),
  ); // para deletar

  Wound? _wound;
  bool _isLoading = false;
  String? _error;

  Future<void> buscarFerida(int id) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _wound = null;
    });

    try {
      final wound = await _showWoundController.show(id);
      setState(() {
        _wound = wound;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao buscar registro: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> deletarFerida(int id) async {
    setState(() => _isLoading = true);

    try {
      final sucesso = await _deleteController.delete(id);

      if (sucesso) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ferida deletada com sucesso!')));
        _limparDados();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ferida não foi deletada.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao deletar: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limparDados() {
    setState(() {
      _wound = null;
      _error = null;
      _idController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buscar e Deletar Registro',
          style: TextStyle(color: Colors.blue),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              child: TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ID do Registro',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          int? id = int.tryParse(_idController.text);
                          if (id != null) {
                            buscarFerida(id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Por favor, insira um ID válido.',
                                ),
                              ),
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isLoading
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Buscando...'),
                          ],
                        )
                        : Text('Buscar'),
              ),
            ),
            SizedBox(height: 30),

            // Mostrar erro se houver
            if (_error != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),

            // Mostrar dados do registro se encontrado
            if (_wound != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Dados do Registro:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('ID', _wound!.id?.toString() ?? 'N/A'),
                          _buildInfoRow(
                            'ID Paciente',
                            _wound!.pacienteId?.toString() ?? 'N/A',
                          ),
                          _buildInfoRow('Sexo', _wound!.sexo ?? 'N/A'),
                          _buildInfoRow(
                            'Cor da Pele',
                            _wound!.corPele ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Idade',
                            _wound!.idade?.toString() ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Localização Anatômica',
                            _wound!.localizacaoAnatomica ?? 'N/A',
                          ),
                          _buildInfoRow('Causa', _wound!.causa ?? 'N/A'),
                          _buildInfoRow('Origem', _wound!.origem ?? 'N/A'),
                          _buildInfoRow(
                            'Comprimento',
                            '${_wound!.comprimento ?? 0} cm',
                          ),
                          _buildInfoRow(
                            'Largura',
                            '${_wound!.largura ?? 0} cm',
                          ),
                          _buildInfoRow(
                            'Extensão da Lesão',
                            '${_wound!.extensaoLesao?.toStringAsFixed(2) ?? 'N/A'} cm²',
                          ),
                          _buildInfoRow('Evolução', _wound!.evolucao ?? 'N/A'),
                          _buildInfoRow('Forma', _wound!.forma ?? 'N/A'),
                          _buildInfoRow(
                            'Data de Registro',
                            _wound!.dataRegistro ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Tipos de Tecido',
                            (_wound!.tiposTecido?.isNotEmpty ?? false)
                                ? _wound!.tiposTecido!
                                    .map(
                                      (id) =>
                                          (id >= 1 &&
                                                  id <=
                                                      WoundConstants
                                                          .tiposTecido
                                                          .length)
                                              ? WoundConstants.tiposTecido[id -
                                                  1]
                                              : 'Desconhecido',
                                    )
                                    .join(', ')
                                : 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _showDeleteConfirmation(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Deletar'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _limparDados,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Voltar'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    if (_wound?.id == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar Exclusão'),
            content: Text(
              'Tem certeza que deseja excluir o registro ID ${_wound!.id}?\n\nEsta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deletarFerida(_wound!.id!);
                },
                child: Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
