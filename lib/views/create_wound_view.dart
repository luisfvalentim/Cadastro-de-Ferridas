import 'package:cadastro_dados/constats/wound_constants.dart';
import 'package:cadastro_dados/controllers/wound/create_wound_controller.dart';
import 'package:cadastro_dados/models/wound.dart';
import 'package:cadastro_dados/services/paciente/get_paciente_by_id_service.dart';
import 'package:cadastro_dados/services/wound/create_wound_service.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cadastro_dados/services/image/list_imagem_service.dart';
import 'package:cadastro_dados/custom/custom_text_field.dart';
import 'package:cadastro_dados/custom/custom_dropdown_field.dart';
import 'package:cadastro_dados/custom/custom_checkbox_grid.dart';
import 'package:cadastro_dados/custom/custom_multi_select_field.dart';

class AddWoundScreen extends StatefulWidget {
  @override
  _AddWoundScreenState createState() => _AddWoundScreenState();
}

class _AddWoundScreenState extends State<AddWoundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _createWoundController = CreateWoundController(CreateWoundService());
  final _listImagemService = ListImagemService();

  final _pacienteIdController = TextEditingController();
  final TextEditingController _evolucaoController = TextEditingController();
  final TextEditingController _dataRegistroController = TextEditingController();
  final TextEditingController _extensaoController = TextEditingController();
  final TextEditingController _larguraController = TextEditingController();
  final TextEditingController _comprimentoController = TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();

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
  int? _selectedImagemId;
  List<Map<String, dynamic>> _imagensDisponiveis = [];
  bool _carregandoImagens = false;

  bool _isLoading = false;

  String? _formatDateToApi(String? brDate) {
    if (brDate == null || brDate.isEmpty) return null;
    final parts = brDate.split('/');
    if (parts.length != 3) return brDate;
    final dia = parts[0].padLeft(2, '0');
    final mes = parts[1].padLeft(2, '0');
    final ano = parts[2];
    return '$ano-$mes-$dia';
  }

  @override
  void dispose() {
    _pacienteIdController.dispose();
    _dataNascimentoController.dispose();
    _evolucaoController.dispose();
    _dataRegistroController.dispose();
    _extensaoController.dispose();
    _larguraController.dispose();
    _comprimentoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarImagens();
  }

  Future<void> _carregarImagens() async {
    setState(() => _carregandoImagens = true);
    try {
      final imgs = await _listImagemService.getAll();
      setState(() {
        _imagensDisponiveis = imgs;
        _carregandoImagens = false;
      });
    } catch (e) {
      setState(() => _carregandoImagens = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar imagens: $e')));
    }
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
          dataNascimento: _formatDateToApi(_dataNascimento),

          localizacaoAnatomica: _localizacaoSelecionada, // mostrado no Dropdown
          localizacaoAnatomicaId:
              WoundConstants
                  .localizacoesMap[_localizacaoSelecionada], // enviado no toJson()
          localizacoes: idLocalizacao != null ? [idLocalizacao] : [],
          causa: _causa,
          origem: _origemFerida,
          imagemId: _selectedImagemId,
          comprimento: double.tryParse(_comprimentoController.text) ?? 0.0,
          largura: double.tryParse(_larguraController.text) ?? 0.0,
          extensaoLesao: double.tryParse(_extensaoController.text),
          evolucao: _evolucaoController.text,
          forma: _formato?.toLowerCase(),
          dataRegistro: _formatDateToApi(_dataRegistroController.text),
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
              const SizedBox(height: 8),
              if (_carregandoImagens)
                const Center(child: CircularProgressIndicator())
              else
                CustomDropdownField<int>(
                  label: 'Escolha uma imagem',
                  hint: 'Selecione',
                  value: _selectedImagemId,
                  items:
                      _imagensDisponiveis.map((img) {
                        return DropdownMenuItem<int>(
                          value: img['id'] as int,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  img['url'] ?? '',
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stack) =>
                                          const Icon(Icons.broken_image),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text('ID ${img['id']}'),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (v) => setState(() => _selectedImagemId = v),
                  validator: (v) => v == null ? 'Escolha uma imagem' : null,
                ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _pacienteIdController,
                label: 'ID do Paciente',
                hint: 'Digite o ID',
                keyboardType: TextInputType.number,
                onChanged: (value) {
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
              CustomTextField(
                controller: _dataNascimentoController,
                label: 'Data de Nascimento',
                hint: 'dd/mm/aaaa',
                keyboardType: TextInputType.number,
                inputFormatters: [_dataNascimentoFormatter],
                readOnly: _isPacienteExistente,
                onChanged: (value) => setState(() => _dataNascimento = value),
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
              CustomDropdownField<String>(
                label: 'Sexo',
                hint: 'Escolha o sexo',
                value: _sexo,
                items:
                    WoundConstants.sexos
                        .map(
                          (v) => DropdownMenuItem<String>(
                            value: v,
                            child: Text(v),
                          ),
                        )
                        .toList(),
                onChanged:
                    _isPacienteExistente
                        ? null
                        : (v) => setState(() => _sexo = v),
                validator: (v) => v == null ? 'Escolha o sexo' : null,
                isEnabled: !_isPacienteExistente,
              ),
              SizedBox(height: 16),
              CustomDropdownField<String>(
                label: 'Cor da Pele',
                hint: 'Escolha a cor da pele',
                value: _corPele,
                items:
                    WoundConstants.coresPele
                        .map(
                          (v) => DropdownMenuItem<String>(
                            value: v,
                            child: Text(v),
                          ),
                        )
                        .toList(),
                onChanged:
                    _isPacienteExistente
                        ? null
                        : (v) => setState(() => _corPele = v),
                validator: (v) => v == null ? 'Escolha a cor da pele' : null,
                isEnabled: !_isPacienteExistente,
              ),
              SizedBox(height: 16),
              CustomDropdownField<String>(
                label: 'Localização anatômica',
                hint: 'Escolha a localização',
                value: _localizacaoSelecionada,
                items:
                    WoundConstants.localizacoesMap.keys
                        .map(
                          (key) => DropdownMenuItem<String>(
                            value: key,
                            child: Text(key),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _localizacaoSelecionada = v),
                validator: (v) => v == null ? 'Escolha a localização' : null,
              ),
              SizedBox(height: 16),
              CustomDropdownField<String>(
                label: 'Formato',
                hint: 'Escolha o formato da ferida',
                value: _formato,
                items:
                    WoundConstants.formas
                        .map(
                          (v) => DropdownMenuItem<String>(
                            value: v,
                            child: Text(v),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _formato = v),
                validator:
                    (v) => v == null ? 'Escolha o formato da ferida' : null,
              ),
              SizedBox(height: 16),
              CustomDropdownField<String>(
                label: 'Origem da Ferida',
                hint: 'Selecione a origem',
                value: _origemFerida,
                items:
                    WoundConstants.origens
                        .map(
                          (v) => DropdownMenuItem<String>(
                            value: v,
                            child: Text(v),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _origemFerida = v),
                validator:
                    (v) => v == null ? 'Escolha a origem da ferida' : null,
              ),
              SizedBox(height: 16),

              CustomTextField(
                controller: _evolucaoController,
                label: 'Tempo de Evolução',
                hint: 'MM/AAAA',
                keyboardType: TextInputType.number,
                inputFormatters: [_evolucaoFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Informe a evolução';
                  if (!validarDataFlexivel(value))
                    return 'Formato inválido ou data futura';
                  return null;
                },
              ),
              SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCheckboxGrid(
                    title: 'Tipos de Tecido',
                    options: WoundConstants.tiposTecido,
                    labels: WoundConstants.tiposTecidoLabels,
                    selectedOptions: _tiposTecidoSelecionados,
                    onToggle: (tecido) {
                      setState(() {
                        if (_tiposTecidoSelecionados.contains(tecido)) {
                          _tiposTecidoSelecionados.remove(tecido);
                        } else {
                          _tiposTecidoSelecionados.add(tecido);
                        }
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 16),

              CustomDropdownField<String>(
                label: 'Causa da Ferida',
                hint: 'Selecione a causa',
                value: _causa,
                items:
                    WoundConstants.causas
                        .map(
                          (v) => DropdownMenuItem<String>(
                            value: v,
                            child: Text(v),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _causa = v),
                validator:
                    (v) => v == null ? 'Escolha a causa da ferida' : null,
              ),

              SizedBox(height: 16),

              CustomTextField(
                controller: _comprimentoController,
                label: 'Comprimento (cm)',
                hint: 'Ex: 2.5',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _calcularExtensao(),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Informe o comprimento';
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              CustomTextField(
                controller: _larguraController,
                label: 'Largura (cm)',
                hint: 'Ex: 1.8',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _calcularExtensao(),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Informe a largura';
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              CustomTextField(
                controller: _extensaoController,
                label: 'Extensão da Lesão (cm²)',
                readOnly: true,
              ),
              SizedBox(height: 16),

              CustomTextField(
                controller: _dataRegistroController,
                label: 'Data de Registro',
                hint: 'dd/mm/aaaa',
                inputFormatters: [_dataRegistroFormatter],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 10) {
                    return 'Informe a data completa';
                  }
                  if (!validarDataFlexivel(value)) {
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
