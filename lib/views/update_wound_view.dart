import 'package:cadastro_dados/constats/wound_constants.dart';
import 'package:cadastro_dados/services/paciente/get_paciente_by_id_service.dart';
import 'package:cadastro_dados/services/wound/show_wound_service.dart';
import 'package:flutter/material.dart';
import '../../models/wound.dart';
import '../../controllers/wound/show_wound_controller.dart';
import '../../controllers/wound/update_wound_controller.dart';
import '../../services/wound/update_wound_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class EditWoundScreen extends StatefulWidget {
  final Wound wound;

  const EditWoundScreen({Key? key, required this.wound}) : super(key: key);

  @override
  _EditWoundScreenState createState() => _EditWoundScreenState();
}

class _EditWoundScreenState extends State<EditWoundScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pacienteIdController = TextEditingController();
  final TextEditingController _larguraController = TextEditingController();
  final TextEditingController _comprimentoController = TextEditingController();
  final TextEditingController _evolucaoController = TextEditingController();
  final TextEditingController _dataRegistroController = TextEditingController();
  final TextEditingController _extensaoController = TextEditingController();

  late final ShowWoundController _showWoundController;
  late final UpdateWoundController _updateController;

  final _dataRegistroFormatter = MaskTextInputFormatter(mask: '##/##/####');
  final _dataNascimentoFormatter = MaskTextInputFormatter(mask: '##/##/####');
  final _evolucaoFormatter = MaskTextInputFormatter(
    mask: '##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool _dataLoaded = false;
  bool _isLoading = false;
  String? _error;

  String? _dataNascimento;
  String? _sexo;
  String? _corPele;
  String? _localizacaoSelecionada;
  String? _formato;
  String? _origemFerida;
  List<String> _tiposTecidoSelecionados = [];
  String? _causa;
  int? _idade;
  double? _extensaoLesao;
  bool _isPacienteExistente = false;

  @override
  void initState() {
    super.initState();

    _updateController = UpdateWoundController(UpdateWoundService());
    _showWoundController = ShowWoundController(ShowWoundService());

    final wound = widget.wound;

    _idController.text = wound.id?.toString() ?? '';
    _pacienteIdController.text = wound.pacienteId?.toString() ?? '';
    _larguraController.text = wound.largura?.toString() ?? '';
    _comprimentoController.text = wound.comprimento?.toString() ?? '';
    _evolucaoController.text = wound.evolucao ?? '';
    _dataRegistroController.text = wound.dataRegistro ?? '';
    _extensaoController.text = wound.extensaoLesao?.toStringAsFixed(2) ?? '';

    _sexo = wound.sexo;
    _corPele = wound.corPele;
    _idade = wound.idade;
    _dataNascimento =
        wound.idade != null
            ? '01/01/${DateTime.now().year - wound.idade!}'
            : null;

    _localizacaoSelecionada = wound.localizacaoAnatomicaId?.toString();
    _formato = wound.forma;
    _origemFerida = wound.origem;
    _causa = wound.causa;
    _tiposTecidoSelecionados = wound.tiposTecidoDescricao ?? [];

    _dataLoaded = true;
  }

  @override
  void dispose() {
    _idController.dispose();
    _pacienteIdController.dispose();
    _larguraController.dispose();
    _comprimentoController.dispose();
    _evolucaoController.dispose();
    _dataRegistroController.dispose();
    _extensaoController.dispose();
    super.dispose();
  }

  void _calcularExtensao() {
    final largura = double.tryParse(
      _larguraController.text.replaceAll(',', '.'),
    );
    final comprimento = double.tryParse(
      _comprimentoController.text.replaceAll(',', '.'),
    );

    if (largura != null && comprimento != null) {
      setState(() {
        _extensaoLesao = largura * comprimento;
        _extensaoController.text = _extensaoLesao!.toStringAsFixed(2);
      });
    } else {
      setState(() {
        _extensaoLesao = null;
        _extensaoController.text = '';
      });
    }
  }

  Future<void> _updateWound() async {
    if (!_formKey.currentState!.validate()) return;

    final id = int.tryParse(_idController.text);
    final pacienteId = int.tryParse(_pacienteIdController.text);
    final largura = double.tryParse(
      _larguraController.text.replaceAll(',', '.'),
    );
    final comprimento = double.tryParse(
      _comprimentoController.text.replaceAll(',', '.'),
    );
    final extensao = (largura ?? 0) * (comprimento ?? 0);

    final idadeCalculada =
        _dataNascimento != null
            ? DateTime.now().year - int.parse(_dataNascimento!.split('/')[2])
            : _idade ?? 0;

    final tiposTecidoIds =
        _tiposTecidoSelecionados
            .map((desc) => WoundConstants.tiposTecidoMap[desc])
            .whereType<int>()
            .toList();

    final wound = Wound(
      id: id,
      pacienteId: pacienteId,
      sexo: _sexo,
      corPele: _corPele,
      idade: idadeCalculada,
      localizacaoAnatomicaId: int.tryParse(_localizacaoSelecionada ?? ''),
      causa: _causa,
      origem: _origemFerida,
      comprimento: comprimento,
      largura: largura,
      extensaoLesao: extensao,
      evolucao: _evolucaoController.text,
      forma: _formato,
      dataRegistro: _dataRegistroController.text,
      tiposTecido: tiposTecidoIds,
    );

    setState(() => _isLoading = true);

    try {
      final success = await _updateController.update(wound);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ferida atualizada com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar ferida')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: Text('Editar Ferida', style: TextStyle(color: Colors.blue)),
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        elevation: 1,
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
                  onPressed: _isLoading ? null : _updateWound,
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
