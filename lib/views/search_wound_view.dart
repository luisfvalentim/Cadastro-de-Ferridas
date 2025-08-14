import 'package:cadastro_dados/constats/wound_constants.dart';
import 'package:flutter/material.dart';
import '../models/wound.dart';
import '../controllers/wound/search_wounds_controller.dart';
import '../services/wound/search_wounds_service.dart';

class SearchWoundScreen extends StatefulWidget {
  @override
  _SearchWoundScreenState createState() => _SearchWoundScreenState();
}

class _SearchWoundScreenState extends State<SearchWoundScreen> {
  final SearchWoundsController _searchWoundsController = SearchWoundsController(
    SearchWoundsService(),
  );

  String? _campoSelecionado;
  String? _valorCampo;
  List<Wound> _resultados = [];
  bool _isLoading = false;

  final Map<String, List<String>> _opcoesDropdown = {
    'idade': WoundConstants.faixasIdade,
    'sexo': WoundConstants.sexos,
    'cor_pele': WoundConstants.coresPele,
    'localizacao_anatomica_id': WoundConstants.localizacoesMap.keys.toList(),
    'forma': WoundConstants.formas,
    'origem': WoundConstants.origens,
    'causa': WoundConstants.causas,
    'tipo_tecido': WoundConstants.tiposTecido,
    'extensao_lesao': WoundConstants.faixaExtensoesLesao,
  };

  Future<void> searchWound() async {
    if (_campoSelecionado == null ||
        _valorCampo == null ||
        _valorCampo!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione um critério e informe um valor válido!'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> filtros = {};

      switch (_campoSelecionado) {
        case 'idade':
          if (_valorCampo == '< 20') {
            filtros['idade'] = '<20';
          } else if (_valorCampo == '20-59') {
            filtros['idade'] = '20-59';
          } else if (_valorCampo == '60+') {
            filtros['idade'] = '60+';
          }
          break;

        case 'extensao_lesao':
          filtros['extensao_lesao'] =
              _valorCampo; // já vem como: pequena, media, etc.
          break;

        case 'localizacao_anatomica_id':
          filtros['localizacao_anatomica_id'] =
              WoundConstants.localizacoesMap[_valorCampo];
          break;

        case 'tipo_tecido':
          filtros['tipo_tecido'] = _valorCampo!.toLowerCase(); // ex: granulação
          break;

        default:
          filtros[_campoSelecionado!] = _valorCampo!;
      }

      final resultados = await _searchWoundsController.search(filtros);

      setState(() {
        _resultados = resultados.cast<Wound>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro na busca: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Ferida', style: TextStyle(color: Colors.blue)),
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Escolha o critério de busca:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Container(
              width: 250,
              child: DropdownButtonFormField<String>(
                value: _campoSelecionado,
                isDense: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(fontSize: 14, color: Colors.blue),
                items:
                    [
                      'idade',
                      'sexo',
                      'cor_pele',
                      'localizacao',
                      'formato',
                      'origem_ferida',
                      'tempo_evolucao',
                      'tipo_tecido',
                      'causas',
                      'extensao_lesao',
                      'ferida_curada',
                    ].map((String campo) {
                      return DropdownMenuItem<String>(
                        value: campo,
                        child: Text(campo.replaceAll('_', ' ').toUpperCase()),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _campoSelecionado = value;
                    _valorCampo = null;
                  });
                },
              ),
            ),

            SizedBox(height: 8),
            if (_campoSelecionado != null) ...[
              Text(
                'Informe o valor para "${_campoSelecionado!}":',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                width: 250,
                child:
                    _opcoesDropdown.containsKey(_campoSelecionado!)
                        ? DropdownButtonFormField<String>(
                          value: _valorCampo,
                          isDense: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                          items:
                              _opcoesDropdown[_campoSelecionado!]!.map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _valorCampo = value;
                            });
                          },
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Escolha um valor para o filtro'
                                      : null,
                        )
                        : TextFormField(
                          onChanged:
                              (value) => setState(() => _valorCampo = value),
                          decoration: InputDecoration(
                            labelText:
                                _campoSelecionado!
                                    .replaceAll('_', ' ')
                                    .toUpperCase(),
                            border: OutlineInputBorder(),
                          ),
                        ),
              ),
            ],

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : searchWound,
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

            SizedBox(height: 20),
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_resultados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum resultado encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tente outros critérios de busca',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Resultados encontrados: ${_resultados.length}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _resultados.length,
            itemBuilder: (context, index) {
              final wound = _resultados[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    'ID: ${wound.id ?? 'N/A'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Idade', wound.idade?.toString() ?? 'N/A'),
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
                      _buildInfoRow('Largura', '${wound.largura ?? 'N/A'} cm'),
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
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
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
