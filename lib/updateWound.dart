import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditWoundScreen extends StatefulWidget {
  @override
  _EditWoundScreenState createState() => _EditWoundScreenState();
}

class _EditWoundScreenState extends State<EditWoundScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  DateTime? _idadeController;
  String? _sexo;
  String? _corPele;
  String? _localizacao;
  String? _formato;
  String? _origemFerida;
  String? _tempoEvolucao;
  String? _tipoTecido;
  String? _causas;
  String? _extensaoLesao;
  bool? _feridaCurada = false;

  final _supabaseClient = Supabase.instance.client;
  bool _loading = false;
  bool _dataLoaded = false;

  Future<void> _loadWound() async {
    setState(() {
      _loading = true;
    });

    final id = int.tryParse(_idController.text);

    if (id == null) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ID inválido!')));
      return;
    }

    try {
      final response =
          await _supabaseClient.from('pessoas').select().eq('id', id).single();

      if (response.isEmpty) {
        setState(() {
          _loading = false;
          _dataLoaded = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhuma ferida encontrada com esse ID')),
        );
        return;
      }

      final wound = response;
      _idadeController =
          wound['idade'] != null ? DateTime.parse(wound['idade']) : null;
      _sexo = wound['sexo'];
      _corPele = wound['cor_pele'];
      _localizacao = wound['localizacao'];
      _formato = wound['formato'];
      _origemFerida = wound['origem_ferida'];
      _tempoEvolucao = wound['tempo_evolucao'];
      _tipoTecido = wound['tipo_tecido'];
      _causas = wound['causas'];
      _extensaoLesao = wound['extensao_lesao'];
      _feridaCurada = wound['ferida_curada'];

      setState(() {
        _loading = false;
        _dataLoaded = true;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro desconhecido: $e')));
    }
  }

  Future<void> _updateWound() async {
    if (_formKey.currentState!.validate()) {
      final id = int.tryParse(_idController.text);
      if (id == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ID inválido!')));
        return;
      }

      Map<String, dynamic> data = {
        'id': id,
        'idade':
            _idadeController != null
                ? _idadeController!.toIso8601String().split('T')[0]
                : null,
        'sexo': _sexo,
        'cor_pele': _corPele,
        'localizacao': _localizacao,
        'formato': _formato,
        'origem_ferida': _origemFerida,
        'tempo_evolucao': _tempoEvolucao,
        'tipo_tecido': _tipoTecido,
        'causas': _causas,
        'extensao_lesao': _extensaoLesao,
        'ferida_curada': _feridaCurada,
      };

      try {
        final response =
            await _supabaseClient
                .from('pessoas')
                .update(data)
                .eq('id', id)
                .select()
                .single();

        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ferida atualizada com sucesso!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
      }
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
                  onPressed: _loadWound,
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
                  child: Text('Carregar Dados'),
                ),
              ),
              SizedBox(height: 20),
              if (_loading) ...[
                Center(child: CircularProgressIndicator()),
              ] else if (_dataLoaded) ...[
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
                      ['Masculino', 'Feminino', 'Outro'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) => setState(() => _sexo = value),
                  validator: (value) => value == null ? 'Escolha o sexo' : null,
                ),
                SizedBox(height: 16),
                Text(
                  'Cor da Pele',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  initialValue: _corPele,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _corPele = value),
                ),
                SizedBox(height: 16),
                Text(
                  'Localização',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  initialValue: _localizacao,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _localizacao = value),
                ),
                SizedBox(height: 16),
                Text('Formato', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  initialValue: _formato,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _formato = value),
                ),
                SizedBox(height: 16),
                Text(
                  'Origem da Ferida',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  initialValue: _origemFerida,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _origemFerida = value),
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
                Text(
                  'Tipo de Tecido',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  initialValue: _tipoTecido,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _tipoTecido = value),
                ),
                SizedBox(height: 16),
                Text('Causas', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  initialValue: _causas,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _causas = value),
                ),
                SizedBox(height: 16),
                Text(
                  'Extensão da Lesão',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  initialValue: _extensaoLesao,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _extensaoLesao = value),
                ),
                SizedBox(height: 16),
                Text(
                  'Ferida Curada?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<bool>(
                  value:
                      _feridaCurada == null
                          ? null
                          : _feridaCurada, // Carrega o valor armazenado em _feridaCurada
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  items: [
                    DropdownMenuItem(value: true, child: Text('Sim')),
                    DropdownMenuItem(value: false, child: Text('Não')),
                  ],
                  onChanged: (value) => setState(() => _feridaCurada = value),
                  validator:
                      (value) => value == null ? 'Selecione uma opção' : null,
                ),

                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateWound,
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
                    child: Text('Salvar Alterações'),
                  ),
                ),
              ] else ...[
                Center(child: Text('Ferida não encontrada.')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
