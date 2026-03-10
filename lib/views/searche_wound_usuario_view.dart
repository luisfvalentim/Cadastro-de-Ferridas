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

class SearchWoundUsuarioScreen extends StatefulWidget {
  const SearchWoundUsuarioScreen({super.key});

  @override
  _SearchWoundUsuarioScreenState createState() =>
      _SearchWoundUsuarioScreenState();
}

class _SearchWoundUsuarioScreenState extends State<SearchWoundUsuarioScreen> {
  final SearchWoundsController _searchWoundsController = SearchWoundsController(
    SearchWoundsService(),
  );

  final List<String> _filtrosSelecionados = [];
  final Map<String, String> _valoresFiltros = {};
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
            filtros['paciente_id'] =
                id.toString(); // precisa ser string no queryParameters
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Buscar Ferida', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
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
                                  // 📝 Parte escrita
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
                                        const SizedBox(height: 8),

                                        // Imagem (se houver)
                                        if (wound.imagemUrl != null)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              wound.imagemUrl!,
                                              height: 150,
                                              fit: BoxFit.contain,
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
                                      ],
                                    ),
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
}
