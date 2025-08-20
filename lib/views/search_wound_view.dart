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

  List<String> _filtrosSelecionados = [];
  Map<String, String> _valoresFiltros = {};

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

  final List<String> _filtrosDisponiveis = [
    'idade',
    'sexo',
    'cor_pele',
    'localizacao_anatomica_id',
    'forma',
    'origem',
    'causa',
    'tipo_tecido',
    'extensao_lesao',
  ];

  Future<void> searchWound() async {
    if (_filtrosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione pelo menos um filtro!')),
      );
      return;
    }

    Map<String, dynamic> filtros = {};

    for (var campo in _filtrosSelecionados) {
      final valor = _valoresFiltros[campo];
      if (valor == null || valor.isEmpty) continue;

      switch (campo) {
        case 'idade':
          filtros['idade'] =
              valor == '< 20'
                  ? '<20'
                  : valor == '20-59'
                  ? '20-59'
                  : '60+';
          break;

        case 'extensao_lesao':
          filtros['extensao_lesao'] = valor;
          break;

        case 'localizacao_anatomica_id':
          filtros['localizacao_anatomica_id'] =
              WoundConstants.localizacoesMap[valor];
          break;

        case 'tipo_tecido':
          filtros['tipo_tecido'] = valor.toLowerCase();
          break;

        default:
          filtros[campo] = valor;
      }
    }

    if (filtros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha pelo menos um valor de filtro!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final resultados = await _searchWoundsController.search(filtros);
      setState(() {
        _resultados = List<Wound>.from(resultados);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
      body: SafeArea(
        child: SingleChildScrollView(
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

              // Lista de checkboxes para selecionar filtros
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _filtrosDisponiveis.map((campo) {
                      return CheckboxListTile(
                        title: Text(campo.replaceAll('_', ' ').toUpperCase()),
                        value: _filtrosSelecionados.contains(campo),
                        onChanged: (bool? selecionado) {
                          setState(() {
                            if (selecionado == true) {
                              _filtrosSelecionados.add(campo);
                              _valoresFiltros[campo] = '';
                            } else {
                              _filtrosSelecionados.remove(campo);
                              _valoresFiltros.remove(campo);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),

              SizedBox(height: 16),

              // Campos dinâmicos baseados nos filtros selecionados
              ..._filtrosSelecionados.map((filtro) {
                final opcoes = _opcoesDropdown[filtro];
                final valorAtual = _valoresFiltros[filtro];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filtro.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      opcoes != null
                          ? DropdownButtonFormField<String>(
                            value:
                                opcoes.contains(valorAtual) ? valorAtual : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items:
                                opcoes
                                    .map(
                                      (valor) => DropdownMenuItem(
                                        value: valor,
                                        child: Text(valor),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _valoresFiltros[filtro] = value ?? '';
                              });
                            },
                          )
                          : TextFormField(
                            initialValue: valorAtual,
                            onChanged: (value) {
                              setState(() {
                                _valoresFiltros[filtro] = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Digite o valor',
                            ),
                          ),
                    ],
                  ),
                );
              }).toList(),

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

              // Resultados
              _resultados.isNotEmpty
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultados encontrados: ${_resultados.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
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
                                  _buildInfoRow(
                                    'Idade',
                                    wound.idade?.toString() ?? 'N/A',
                                  ),
                                  _buildInfoRow('Sexo', wound.sexo ?? 'N/A'),
                                  _buildInfoRow(
                                    'Cor da Pele',
                                    wound.corPele ?? 'N/A',
                                  ),
                                  _buildInfoRow(
                                    'Localização',
                                    wound.localizacaoAnatomica ?? 'N/A',
                                  ),
                                  _buildInfoRow(
                                    'Formato',
                                    wound.forma ?? 'N/A',
                                  ),
                                  _buildInfoRow(
                                    'Origem',
                                    wound.origem ?? 'N/A',
                                  ),
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
                                  _buildInfoRow(
                                    'Evolução',
                                    wound.evolucao ?? 'N/A',
                                  ),
                                  _buildInfoRow(
                                    'Data de Registro',
                                    wound.dataRegistro ?? 'N/A',
                                  ),
                                  _buildInfoRow(
                                    'Tipos de Tecido',
                                    (wound.tiposTecidoDescricao != null &&
                                            wound
                                                .tiposTecidoDescricao!
                                                .isNotEmpty)
                                        ? wound.tiposTecidoDescricao!.join(', ')
                                        : 'N/A',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                  : _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox.shrink(),
            ],
          ),
        ),
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
