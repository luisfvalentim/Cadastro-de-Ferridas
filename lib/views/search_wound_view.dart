import 'package:cadastro_dados/constats/wound_constants.dart';
import 'package:cadastro_dados/custom/custom_Dropdown_field.dart';
import 'package:cadastro_dados/custom/custom_butom.dart';
import 'package:cadastro_dados/custom/custom_checkbox_grid.dart';
import 'package:cadastro_dados/custom/custom_text_field.dart';
import 'package:cadastro_dados/widgets/wound_info_list.dart';
import 'package:flutter/material.dart';
import '../models/wound.dart';
import '../controllers/wound/search_wounds_controller.dart';
import '../services/wound/search_wounds_service.dart';

class SearchWoundScreen extends StatefulWidget {
  @override
  _SearchWoundScreenState createState() => _SearchWoundScreenState();
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

class _SearchWoundScreenState extends State<SearchWoundScreen> {
  final SearchWoundsController _searchWoundsController = SearchWoundsController(
    SearchWoundsService(),
  );

  final List<String> _filtrosSelecionados = [];
  final Map<String, String> _valoresFiltros = {};
  List<Wound> _resultados = [];
  bool _isLoading = false;
  final Set<int> _selectedForCompare = {};

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
    'paciente_id': [],
  };

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
                  : '60';
          break;

        case 'extensao_lesao':
          filtros['extensao_lesao'] = valor;
          break;

        case 'localizacao_anatomica_id':
          final idLoc = WoundConstants.localizacoesMap[valor];
          if (idLoc != null) {
            filtros['localizacao_id'] = idLoc.toString();
          }

          if (valor.toLowerCase() == 'outro') {
            final obsLoc = _valoresFiltros['localizacao_observacao'];
            if (obsLoc != null && obsLoc.isNotEmpty) {
              filtros['localizacao_observacao'] = obsLoc;
            }
          }
          break;

        case 'tipo_tecido':
          filtros['tipos_tecido'] = valor.toLowerCase().trim();
          if (valor.toLowerCase().contains('outro')) {
            final obsTecido = _valoresFiltros['tipo_tecido_observacao'];
            if (obsTecido != null && obsTecido.isNotEmpty) {
              filtros['tipo_tecido_observacao'] = obsTecido;
            }
          }
          break;

        case 'paciente_id':
          final id = int.tryParse(valor);
          if (id != null) {
            filtros['paciente_id'] = id.toString();
          }
          break;

        case 'origem':
          filtros['origem'] = valor;
          final obs = _valoresFiltros['origem_observacao'];
          if (valor == 'outro' && obs != null && obs.isNotEmpty) {
            filtros['origem_observacao'] = obs;
          }
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
    final sel = _resultados
        .where((w) => w.id != null && _selectedForCompare.contains(w.id))
        .take(2)
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _CompareWoundsScreen(wounds: sel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Buscar Ferida', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),

              CustomCheckboxGrid(
                title: 'Filtros',
                options: WoundConstants.filtrosDisponiveis,
                selectedOptions: _filtrosSelecionados,
                onToggle: (campo) {
                  setState(() {
                    final selected = _filtrosSelecionados.contains(campo);
                    if (selected) {
                      _filtrosSelecionados.remove(campo);
                      _valoresFiltros.remove(campo);
                    } else {
                      _filtrosSelecionados.add(campo);
                      _valoresFiltros[campo] = '';
                    }
                  });
                },
              ),

              SizedBox(height: 16),
              ..._filtrosSelecionados.map((filtro) {
                final opcoes = _opcoesDropdown[filtro];
                final valorAtual = _valoresFiltros[filtro];
                final text = valorAtual ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),

                      if (filtro == 'tipo_tecido') ...[
                        CustomCheckboxGrid(
                          title: 'Tipo de Tecido',
                          options: WoundConstants.tiposTecido,
                          selectedOptions:
                              _valoresFiltros[filtro]?.split(',') ?? [],
                          labels: WoundConstants.tiposTecidoLabels,
                          onToggle: (tecido) {
                            setState(() {
                              final selecionados =
                                  _valoresFiltros[filtro]?.split(',') ?? [];
                              if (selecionados.contains(tecido)) {
                                selecionados.remove(tecido);
                              } else {
                                selecionados.add(tecido);
                              }
                              _valoresFiltros[filtro] = selecionados.join(',');
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        if ((_valoresFiltros[filtro]?.split(',') ?? [])
                            .contains('outro'))
                          CustomTextField(
                            controller: TextEditingController(
                                text:
                                    _valoresFiltros['tipo_tecido_observacao'] ??
                                    '',
                              )
                              ..selection = TextSelection.collapsed(
                                offset:
                                    _valoresFiltros['tipo_tecido_observacao']
                                        ?.length ??
                                    0,
                              ),
                            label: "Observação Tipo de Tecido",
                            hint: "Descreva o tecido",
                            onChanged: (value) {
                              _valoresFiltros['tipo_tecido_observacao'] = value;
                            },
                          ),
                      ] else if (filtro == 'localizacao_anatomica_id') ...[
                        CustomDropdownField<String>(
                          label: "Localização Anatômica",
                          hint: 'Selecione',
                          value:
                              opcoes!.contains(valorAtual) ? valorAtual : null,
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
                        ),
                        SizedBox(height: 16),
                        if (valorAtual == 'Outro')
                          CustomTextField(
                            controller: TextEditingController(
                                text:
                                    _valoresFiltros['localizacao_observacao'] ??
                                    '',
                              )
                              ..selection = TextSelection.collapsed(
                                offset:
                                    _valoresFiltros['localizacao_observacao']
                                        ?.length ??
                                    0,
                              ),
                            label: "Observação Localização",
                            hint: "Descreva a localização",
                            onChanged: (value) {
                              _valoresFiltros['localizacao_observacao'] = value;
                            },
                          ),
                      ] else if (filtro == 'origem') ...[
                        CustomDropdownField<String>(
                          label: "Origem",
                          hint: 'Selecione',
                          value:
                              opcoes!.contains(valorAtual) ? valorAtual : null,
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
                        ),
                        SizedBox(height: 16),
                        if (valorAtual == 'outro')
                          CustomTextField(
                            controller: TextEditingController(
                                text:
                                    _valoresFiltros['origem_observacao'] ?? '',
                              )
                              ..selection = TextSelection.collapsed(
                                offset:
                                    _valoresFiltros['origem_observacao']
                                        ?.length ??
                                    0,
                              ),
                            label: "Observação Origem",
                            hint: "Descreva a origem",
                            onChanged: (value) {
                              _valoresFiltros['origem_observacao'] = value;
                            },
                          ),
                      ] else if (opcoes != null) ...[
                        CustomDropdownField<String>(
                          label: filtro.replaceAll('_', ' ').toUpperCase(),
                          hint: 'Selecione',
                          value:
                              opcoes.contains(valorAtual) ? valorAtual : null,
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
                        ),
                      ] else ...[
                        CustomTextField(
                          controller: TextEditingController(text: text)
                            ..selection = TextSelection.collapsed(
                              offset: text.length,
                            ),
                          label: filtro.replaceAll('_', ' ').toUpperCase(),
                          hint: 'Digite o valor',
                          onChanged: (value) {
                            _valoresFiltros[filtro] = value;
                          },
                        ),
                      ],
                    ],
                  ),
                );
              }),

              SizedBox(height: 20),
              CustomButton(
                text: 'Buscar',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : searchWound,
                loadingText: 'Buscando',
              ),
              SizedBox(height: 20),
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
                          final selected = wound.id != null &&
                              _selectedForCompare.contains(wound.id);
                          return Card(
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.blue,
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ID: ${wound.id ?? 'N/A'}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        WoundInfoList(wound: wound),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: selected,
                                              onChanged: (_) =>
                                                  _toggleCompare(wound.id),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        if (wound.imagemUrl != null)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              wound.imagemUrl!,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return const Icon(
                                                  Icons.broken_image,
                                                  size: 80,
                                                  color: Colors.red,
                                                );
                                              },
                                            ),
                                          )
                                        else
                                          const Icon(
                                            Icons.image_not_supported,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        const SizedBox(height: 8),
                                        if (wound.imagemUrl != null)
                                          TextButton.icon(
                                            onPressed: () =>
                                                _openFull(wound.imagemUrl),
                                            icon: const Icon(Icons.fullscreen),
                                            label:
                                                const Text('Tela cheia / Zoom'),
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
                      if (_selectedForCompare.length == 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _openCompare,
                              icon: const Icon(Icons.compare),
                              label: const Text('Comparar (2)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
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
}
