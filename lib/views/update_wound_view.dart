import 'package:cadastro_dados/constats/wound_constants.dart';
import 'package:flutter/material.dart';
import '../../models/wound.dart';
import '../../services/wound/update_wound_service.dart';
import '../../controllers/wound/update_wound_controller.dart';
import '../../controllers/wound/show_wound_controller.dart';
import '../../services/wound/show_wound_service.dart';

class EditWoundScreen extends StatefulWidget {
  final Wound? wound;

  const EditWoundScreen({Key? key, this.wound}) : super(key: key);

  @override
  _EditWoundScreenState createState() => _EditWoundScreenState();
}

class _EditWoundScreenState extends State<EditWoundScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  late final ShowWoundController _showWoundController;
  bool _dataLoaded = false;
  final TextEditingController _larguraController = TextEditingController();
  final TextEditingController _comprimentoController = TextEditingController();

  DateTime? _idadeController;
  String? _sexo;
  String? _corPele;
  String? _localizacao;
  String? _formato;
  String? _origemFerida;
  String? _tempoEvolucao;
  String? _causas;
  double? _comprimento;
  double? _largura;
  String? _dataRegistro;
  List<int>? _tiposTecido;
  double? _extensaoLesao;
  String? _tipoTecido;
  int? _valorCampoInt;

  bool _isLoading = false;
  String? _error;
  late final UpdateWoundController _updateController;

  @override
  void initState() {
    super.initState();

    _updateController = UpdateWoundController(UpdateWoundService());
    _showWoundController = ShowWoundController(ShowWoundService());

    if (widget.wound != null) {
      final wound = widget.wound!;
      _idController.text = wound.id?.toString() ?? '';
      _larguraController.text = wound.largura?.toString() ?? '';
      _comprimentoController.text = wound.comprimento?.toString() ?? '';
      _sexo = wound.sexo;
      _corPele = wound.corPele;
      _idadeController =
          wound.idade != null
              ? DateTime(DateTime.now().year - wound.idade!, 1, 1)
              : null;
      _localizacao = wound.localizacaoAnatomica;
      _formato = wound.forma;
      _origemFerida = wound.origem;
      _tempoEvolucao = wound.evolucao;
      _causas = wound.causa;
      _extensaoLesao = wound.extensaoLesao;
      _tiposTecido = wound.tiposTecido ?? [];
      _dataRegistro = wound.dataRegistro;
      _dataLoaded = true;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _larguraController.dispose();
    _comprimentoController.dispose();
    super.dispose();
  }

  Future<void> _updateWound() async {
    if (!_formKey.currentState!.validate()) return;

    final id = int.tryParse(_idController.text);
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ID inválido')));
      return;
    }

    final extensao = (_largura ?? 0) * (_comprimento ?? 0);

    final wound = Wound(
      id: id,
      pacienteId: 1, // ajustar conforme necessário
      sexo: _sexo,
      corPele: _corPele,
      idade: _idadeController?.year,
      localizacaoAnatomica: _localizacao,
      causa: _causas,
      origem: _origemFerida,
      comprimento: _comprimento,
      largura: _largura,
      extensaoLesao: extensao,
      evolucao: _tempoEvolucao,
      forma: _formato,
      dataRegistro: _dataRegistro,
      tiposTecido: _tiposTecido,
    );

    setState(() => _isLoading = true);

    try {
      final success = await _updateController.update(wound);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ferida atualizada com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar ferida')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWound() async {
    final id = int.tryParse(_idController.text);
    if (id == null) {
      setState(() => _error = 'ID inválido');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final wound = await _showWoundController.show(id);

      setState(() {
        _sexo = wound.sexo;
        _corPele = wound.corPele;
        _idadeController =
            wound.idade != null
                ? DateTime(DateTime.now().year - wound.idade!, 1, 1)
                : null;
        _localizacao = wound.localizacaoAnatomica;
        _formato = wound.forma;
        _origemFerida = wound.origem;
        _tempoEvolucao = wound.evolucao;
        _comprimento = wound.comprimento;
        _largura = wound.largura;
        _dataRegistro = wound.dataRegistro;
        _extensaoLesao = wound.extensaoLesao;
        _tiposTecido = wound.tiposTecido ?? [];
        _dataLoaded = true;
      });
    } catch (e) {
      setState(() => _error = 'Erro ao buscar ferida: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
      });
    } else {
      setState(() {
        _extensaoLesao = null;
      });
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
              Align(
                alignment: Alignment.center,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: TextFormField(
                    controller: _idController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ID do Registro',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) => value!.isEmpty ? 'Informe o ID' : null,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loadWound,
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
                              Text('Carregando...'),
                            ],
                          )
                          : Text('Carregar Dados'),
                ),
              ),
              SizedBox(height: 20),

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

              if (_isLoading) ...[
                Center(child: CircularProgressIndicator()),
              ] else if (_dataLoaded) ...[
                _buildFormFields(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data de Nascimento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text:
                _idadeController != null
                    ? "${_idadeController!.day}/${_idadeController!.month}/${_idadeController!.year}"
                    : '',
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _idadeController ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );

            if (pickedDate != null && pickedDate != _idadeController) {
              setState(() {
                _idadeController = pickedDate;
              });
            }
          },
          validator:
              (value) =>
                  _idadeController == null
                      ? 'Informe a data de nascimento'
                      : null,
        ),
        SizedBox(height: 16),

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
          onChanged: (value) => setState(() => _sexo = value),
          validator: (value) => value == null ? 'Escolha o sexo' : null,
        ),

        SizedBox(height: 16),

        Text('Cor da Pele', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: _corPele,
          decoration: InputDecoration(border: OutlineInputBorder()),
          items:
              WoundConstants.coresPele
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _corPele = value),
          validator: (value) => value == null ? 'Escolha a cor da pele' : null,
        ),
        SizedBox(height: 16),

        Text('Localização', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<int>(
          value: _valorCampoInt,
          decoration: InputDecoration(
            labelText: 'Localização Anatômica',
            border: OutlineInputBorder(),
          ),
          items:
              WoundConstants.localizacoesMap.entries
                  .map(
                    (entry) => DropdownMenuItem<int>(
                      value: entry.value,
                      child: Text(entry.key),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() {
              _valorCampoInt = value;
            });
          },
        ),
        SizedBox(height: 16),

        Text('Formato', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: _formato,
          decoration: InputDecoration(border: OutlineInputBorder()),
          items:
              WoundConstants.formas
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _formato = value),
          validator:
              (value) => value == null ? 'Escolha o formato da ferida' : null,
        ),
        SizedBox(height: 16),

        Text('Origem da Ferida', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: _origemFerida,
          decoration: InputDecoration(border: OutlineInputBorder()),
          items:
              WoundConstants.origens.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value[0].toUpperCase() + value.substring(1),
                  ), // capitaliza
                );
              }).toList(),
          onChanged: (value) => setState(() => _origemFerida = value),
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Escolha a origem da ferida'
                      : null,
        ),
        SizedBox(height: 16),

        Text(
          'Tempo de Evolução',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: _tempoEvolucao,
          decoration: InputDecoration(border: OutlineInputBorder()),
          onChanged: (value) => setState(() => _tempoEvolucao = value),
        ),
        SizedBox(height: 16),

        Text('Tipo de Tecido', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: _tipoTecido,
          decoration: InputDecoration(border: OutlineInputBorder()),
          items:
              WoundConstants.tiposTecido
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),

          onChanged: (value) => setState(() => _tipoTecido = value),
          validator:
              (value) => value == null ? 'Escolha o tipo de ferida' : null,
        ),
        SizedBox(height: 16),

        Text('Causas', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: _causas,
          decoration: InputDecoration(border: OutlineInputBorder()),
          items:
              WoundConstants.causas
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _causas = value),
          validator:
              (value) => value == null ? 'Escolha a causa da ferida' : null,
        ),
        SizedBox(height: 16),

        Text('Comprimento (cm)', style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          controller: _comprimentoController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Comprimento',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _calcularExtensao(),
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Informe o comprimento'
                      : null,
        ),
        SizedBox(height: 16),

        Text('Largura (cm)', style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          controller: _larguraController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Largura',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _calcularExtensao(),
          validator:
              (value) =>
                  value == null || value.isEmpty ? 'Informe a largura' : null,
        ),
        SizedBox(height: 16),

        Text(
          'Extensão da Lesão (cm²)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Extensão calculada',
          ),
          controller: TextEditingController(
            text:
                _extensaoLesao != null
                    ? _extensaoLesao!.toStringAsFixed(2)
                    : '',
          ),
        ),

        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateWound,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    : Text('Salvar Alterações'),
          ),
        ),
      ],
    );
  }
}
