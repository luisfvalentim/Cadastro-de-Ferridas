import 'dart:convert';

import 'package:cadastro_dados/config/config.dart';
import 'package:cadastro_dados/constats/wound_constants.dart';
import 'package:cadastro_dados/controllers/wound/create_wound_controller.dart';
import 'package:cadastro_dados/models/wound.dart';
import 'package:cadastro_dados/services/auth_service.dart';
import 'package:cadastro_dados/services/paciente/get_paciente_by_id_service.dart';
import 'package:cadastro_dados/services/wound/create_wound_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AddWoundScreen extends StatefulWidget {
  @override
  _AddWoundScreenState createState() => _AddWoundScreenState();
}

class _AddWoundScreenState extends State<AddWoundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _createWoundController = CreateWoundController(CreateWoundService());

  final _pacienteIdController = TextEditingController();
  final TextEditingController _evolucaoController = TextEditingController();
  final TextEditingController _dataRegistroController = TextEditingController();
  final TextEditingController _extensaoController = TextEditingController();
  final TextEditingController _larguraController = TextEditingController();
  final TextEditingController _comprimentoController = TextEditingController();
  final _dataRegistroFormatter = MaskTextInputFormatter(mask: '##/##/####');
  final _dataNascimentoFormatter = MaskTextInputFormatter(mask: '##/##/####');
  final _evolucaoFormatter = MaskTextInputFormatter(
    mask: '##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  String? _dataNascimento;
  String? _sexo;
  String? _corPele;
  String? _localizacaoSelecionada;
  String? _formato;
  String? _origemFerida;
  List<String> _tiposTecidoSelecionados = [];
  String? _causa;
  int? _idade;
  bool _isPacienteExistente = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _pacienteIdController.dispose();
    super.dispose();
  }

  Future<void> _salvarFerida() async {
    if (_formKey.currentState!.validate()) {
      if (_sexo == null ||
          _corPele == null ||
          _localizacaoSelecionada == null ||
          _formato == null ||
          _origemFerida == null ||
          _causa == null ||
          _tiposTecidoSelecionados.isEmpty ||
          _dataNascimento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios.'),
          ),
        );
        return;
      }

      final idLocalizacao =
          WoundConstants.localizacoesMap[_localizacaoSelecionada];

      if (idLocalizacao == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Localização inválida.')));
        return;
      }

      setState(() => _isLoading = true);

      try {
        final wound = Wound(
          pacienteId: int.tryParse(_pacienteIdController.text),
          sexo: _sexo,
          corPele: _corPele,
          idade:
              _dataNascimento != null ? _calcularIdade(_dataNascimento!) : null,

          localizacaoAnatomica: _localizacaoSelecionada, // mostrado no Dropdown
          localizacaoAnatomicaId:
              WoundConstants
                  .localizacoesMap[_localizacaoSelecionada], // enviado no toJson()
          causa: _causa,
          origem: _origemFerida,
          comprimento: double.tryParse(_comprimentoController.text) ?? 0.0,
          largura: double.tryParse(_larguraController.text) ?? 0.0,
          extensaoLesao: double.tryParse(_extensaoController.text),
          evolucao: _evolucaoController.text,
          forma: _formato?.toLowerCase(),
          dataRegistro: _dataRegistroController.text,
          tiposTecido:
              _tiposTecidoSelecionados
                  .map((t) => WoundConstants.tiposTecidoMap[t]!)
                  .toList(),
        );
        print(wound.toJson()); // <-- breakpoint aqui também é útil
        final success = await _createWoundController.create(wound);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ferida adicionada com sucesso!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao salvar ferida!')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  int _calcularIdade(String data) {
    final partes = data.split('/');
    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);

    if (dia == null || mes == null || ano == null) return 0;

    final nascimento = DateTime(ano, mes, dia);
    final hoje = DateTime.now();
    int idade = hoje.year - nascimento.year;
    if (hoje.month < nascimento.month ||
        (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
      idade--;
    }
    return idade;
  }

  bool validarDataFlexivel(String data) {
    // Verifica se é formato MM/AAAA (usado para evolução)
    if (RegExp(r'^\d{2}/\d{4}$').hasMatch(data)) {
      final partes = data.split('/');
      final mes = int.tryParse(partes[0]);
      final ano = int.tryParse(partes[1]);

      if (mes == null || ano == null || mes < 1 || mes > 12) return false;

      final dataConvertida = DateTime(ano, mes);
      final agora = DateTime.now();

      return dataConvertida.isBefore(agora) ||
          (dataConvertida.year == agora.year &&
              dataConvertida.month == agora.month);
    }

    // Verifica se é formato DD/MM/AAAA (usado para data de nascimento ou registro)
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(data)) {
      final partes = data.split('/');
      final dia = int.tryParse(partes[0]);
      final mes = int.tryParse(partes[1]);
      final ano = int.tryParse(partes[2]);

      if (dia == null || mes == null || ano == null) return false;

      final dataConvertida = DateTime.tryParse(
        '$ano-${mes.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}',
      );
      if (dataConvertida == null) return false;

      return dataConvertida.isBefore(DateTime.now()) ||
          dataConvertida.isAtSameMomentAs(DateTime.now());
    }

    return false;
  }

  void _calcularExtensao() {
    final comprimento =
        double.tryParse(_comprimentoController.text.replaceAll(',', '.')) ??
        0.0;
    final largura =
        double.tryParse(_larguraController.text.replaceAll(',', '.')) ?? 0.0;
    final extensao = comprimento * largura;

    _extensaoController.text = extensao.toStringAsFixed(2);
  }

  Future<void> _buscarPacientePorId(String idTexto) async {
    final id = int.tryParse(idTexto);
    if (id == null) return;

    try {
      final paciente = await GetPacienteByIdService().getPacienteById(id);
      if (paciente != null) {
        setState(() {
          _sexo = paciente['sexo'];
          _corPele = paciente['cor_pele'];
          _idade = paciente['idade'];
          _isPacienteExistente = true;
        });
      } else {
        setState(() {
          _isPacienteExistente = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar paciente: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Adicionar Ferida',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Id do Paciente',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _pacienteIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ID do Paciente',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Verifica se tem pelo menos 1 dígito para evitar chamadas desnecessárias
                  if (value.length >= 1) {
                    _buscarPacientePorId(value);
                  }
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe o ID do paciente'
                            : null,
              ),
              SizedBox(height: 16),
              // DATA DE NASCIMENTO
              Text(
                'Data de Nascimento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                inputFormatters: [
                  _dataNascimentoFormatter,
                ], // máscara dd/mm/aaaa
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento (dd/mm/aaaa)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _dataNascimento = value;
                  });
                },
                enabled: !_isPacienteExistente, // bloqueia se já existe
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 10) {
                    return 'Informe a data de nascimento completa';
                  }
                  if (!validarDataFlexivel(value)) {
                    return 'Data inválida ou no futuro';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // SEXO
              Text('Sexo', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    WoundConstants.sexos.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged:
                    _isPacienteExistente
                        ? null
                        : (value) => setState(() => _sexo = value),
                validator: (value) => value == null ? 'Escolha o sexo' : null,
              ),

              SizedBox(height: 16),

              // COR DA PELE
              Text(
                'Cor da Pele',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _corPele,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    WoundConstants.coresPele.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged:
                    _isPacienteExistente
                        ? null
                        : (value) => setState(() => _corPele = value),
                validator:
                    (value) => value == null ? 'Escolha a cor da pele' : null,
              ),

              SizedBox(height: 16),
              Text(
                'Localização anatômica',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _localizacaoSelecionada,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    WoundConstants.localizacoesMap.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(key),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => _localizacaoSelecionada = value),
                validator:
                    (value) => value == null ? 'Escolha a localização' : null,
              ),

              SizedBox(height: 16),

              Text('Formato', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _formato,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    WoundConstants.formas.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _formato = value),
                validator:
                    (value) =>
                        value == null ? 'Escolha o formato da ferida' : null,
              ),
              SizedBox(height: 16),

              Text(
                'Origem da Ferida',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _origemFerida,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    WoundConstants.origens.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _origemFerida = value),
                validator:
                    (value) =>
                        value == null ? 'Escolha a origem da ferida' : null,
              ),

              SizedBox(height: 16),

              Text(
                'Tempo de Evolução',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _evolucaoController,
                inputFormatters: [_evolucaoFormatter],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Evolução (MM/AAAA)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a evolução';
                  }
                  if (!validarDataFlexivel(value)) {
                    return 'Formato inválido ou data futura';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipos de Tecido',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...WoundConstants.tiposTecido.map((tecido) {
                    return CheckboxListTile(
                      title: Text(tecido),
                      value: _tiposTecidoSelecionados.contains(tecido),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _tiposTecidoSelecionados.add(tecido);
                          } else {
                            _tiposTecidoSelecionados.remove(tecido);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),

              SizedBox(height: 16),

              Text('Causas', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _causa,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    WoundConstants.causas.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _causa = value),
                validator:
                    (value) =>
                        value == null ? 'Escolha a causa da ferida' : null,
              ),

              SizedBox(height: 16),

              Text(
                'Comprimento (cm)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _comprimentoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Comprimento (cm)',
                ),
                onChanged: (_) => _calcularExtensao(),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Informe o comprimento';
                  if (double.tryParse(value.replaceAll(',', '.')) == null)
                    return 'Valor inválido';
                  return null;
                },
              ),

              SizedBox(height: 16),

              Text(
                'Largura (cm)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _larguraController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Largura (cm)',
                ),
                onChanged: (_) => _calcularExtensao(),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Informe a largura';
                  if (double.tryParse(value.replaceAll(',', '.')) == null)
                    return 'Valor inválido';
                  return null;
                },
              ),

              SizedBox(height: 16),
              Text(
                'Extensão da Lesão',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _extensaoController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Extensão da Lesão (cm²)',
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Data de Registro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _dataRegistroController,
                inputFormatters: [_dataRegistroFormatter],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Data de Registro (dd/mm/aaaa)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 10) {
                    return 'Informe a data completa';
                  }
                  if (!validarDataFlexivel(value ?? '')) {
                    return 'Data inválida ou no futuro';
                  }
                  return null;
                },
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarFerida,
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
                              Text('Salvando...'),
                            ],
                          )
                          : Text('Salvar Ferida'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
