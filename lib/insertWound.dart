import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddWoundScreen extends StatefulWidget {
  @override
  _AddWoundScreenState createState() => _AddWoundScreenState();
}

class _AddWoundScreenState extends State<AddWoundScreen> {
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
  double? _extensaoLesao;
  bool? _feridaCurada = false;

  final _supabaseClient = Supabase.instance.client;

  Future<void> _salvarFerida() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'id': int.tryParse(_idController.text) ?? 0,
        'created_at': DateTime.now().toIso8601String(),
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
                .insert(data)
                .select()
                .single();
        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ferida adicionada com sucesso!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
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
              Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Informe o ID' : null,
              ),
              SizedBox(height: 16),
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
                    ['Masculino', 'Feminino'].map((String value) {
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
              DropdownButtonFormField<String>(
                value: _corPele,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    ['Branca', 'Preta', 'Amarela', 'Parda', 'Indígena'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _corPele = value),
                validator:
                    (value) => value == null ? 'Escolha o cor da pele' : null,
              ),
              SizedBox(height: 16),
              Text(
                'Localização',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _localizacao,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    [
                      'Membros superiores',
                      'Membros inferiores',
                      'Sacrococcígea',
                      'Cabeça ou face',
                      'Região torácica',
                      'Região abdominal',
                      'Região dorsal',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _localizacao = value),
                validator:
                    (value) => value == null ? 'Escolha a localização' : null,
              ),
              SizedBox(height: 16),

              Text('Formato', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _formato,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    ['Arredondada', 'Irregular', 'Linear'].map((String value) {
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
              TextFormField(
                decoration: InputDecoration(border: OutlineInputBorder()),
                onChanged: (value) => setState(() => _origemFerida = value),
              ),
              SizedBox(height: 16),

              Text(
                'Tempo de Evolução',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(border: OutlineInputBorder()),
                onChanged: (value) => setState(() => _tempoEvolucao = value),
              ),
              SizedBox(height: 16),

              Text(
                'Tipo de Tecido',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _tipoTecido,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    [
                      'Granulação',
                      'Necrose',
                      'Esfacelo',
                      'Fibrina',
                      'Epitelização',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _tipoTecido = value),
                validator:
                    (value) =>
                        value == null ? 'Escolha o tipo de ferida' : null,
              ),
              SizedBox(height: 16),

              Text('Causas', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _causas,
                decoration: InputDecoration(border: OutlineInputBorder()),
                items:
                    ['Traumática', 'Cirúrgica', 'Patológica'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _causas = value),
                validator:
                    (value) =>
                        value == null ? 'Escolha a causa da ferida' : null,
              ),
              SizedBox(height: 16),

              Text(
                'Extensão da Lesão',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Extensão da Lesão (cm²)',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _extensaoLesao = double.tryParse(
                      value.replaceAll(',', '.'),
                    );
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a extensão da lesão';
                  }
                  final parsed = double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null) {
                    return 'Digite um número válido';
                  }
                  return null;
                },
              ),

              Text(
                'Ferida Curada?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<bool>(
                value: null,
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
                  onPressed: _salvarFerida,
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
                  child: Text('Salvar Ferida'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
