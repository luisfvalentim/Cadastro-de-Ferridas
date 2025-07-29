import 'package:cadastro_dados/core/crud.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchWoundScreen extends StatefulWidget {
  @override
  _SearchWoundScreenState createState() => _SearchWoundScreenState();
}

class _SearchWoundScreenState extends State<SearchWoundScreen> {
  final _supabaseClient = Supabase.instance.client;

  String? _campoSelecionado;
  String? _valorCampo;
  List<Map<String, dynamic>> _resultados = [];

  final Map<String, List<String>> _opcoesDropdown = {
    'idade': ['< 20', '20-59', '> 60'],
    'sexo': ['Masculino', 'Feminino'],
    'cor_pele': ['Branca', 'Preta', 'Amarela', 'Parda', 'Indígena'],
    'localizacao': [
      'Membros superiores',
      'Membros inferiores',
      'Sacrococcígea',
      'Cabeça ou face',
      'Região torácica',
      'Região abdominal',
      'Região dorsal',
    ],
    'formato': ['Arredondada/Oval', 'Irregular', 'Linear'],
    'origem_ferida': [
      'Traumática (mecânico, químico, físico)',
      'Cirúrgica (incisão, excisão, punção)',
      'Patológica (neoplasia, úlcera venosa, úlcera arterial, pé diabético/úlcera diabética)',
    ],
    'tempo_evolucao': ['Aguda: até 6 meses', 'Crônica: + 6 meses'],
    'tipo_tecido': [
      'Granulação',
      'Necrose',
      'Esfacelo',
      'Fibrina',
      'Epitelização',
    ],
    'causas': ['Traumática', 'Cirúrgica', 'Patológica'],
    'extensao_lesao': [
      'Pequena: Até 3 cm²',
      'Média: De 3,1 cm² a 10 cm²',
      'Grande: De 10,1 cm² a 25 cm²',
      'Muito grande: Maior que 25 cm²',
    ],
    'ferida_curada': ['Sim', 'Não'],
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

    List<Map<String, dynamic>> resultados = [];

    if (_campoSelecionado == 'ferida_curada') {
      resultados = await SupaBaseCrudService().readByCure(_valorCampo!);
    } else if (_campoSelecionado == 'idade') {
      // Suponha que o valor seja uma dessas opções:
      // "< 20", "20-59", "> 60"
      bool menor20 = _valorCampo == '< 20';
      bool entre20e59 = _valorCampo == '20-59';
      bool maior60 = _valorCampo == '> 60';

      resultados = await SupaBaseCrudService().readByFaixaEtaria(
        menor20: menor20,
        entre20e59: entre20e59,
        maior60: maior60,
      );
    } else if (_campoSelecionado == 'extensao_lesao_cm2') {
      late FaixaLesao faixa;

      if (_valorCampo == 'Pequena: Até 3 cm²') {
        faixa = FaixaLesao.pequena;
      } else if (_valorCampo == 'Média: De 3,1 cm² a 10 cm²') {
        faixa = FaixaLesao.media;
      } else if (_valorCampo == 'Grande: De 10,1 cm² a 25 cm²') {
        faixa = FaixaLesao.grande;
      } else if (_valorCampo == 'Muito grande: Maior que 25 cm²') {
        faixa = FaixaLesao.muitoGrande;
      }

      resultados = await SupaBaseCrudService().readPorFaixa(faixa);
    } else {
      resultados = await SupaBaseCrudService().readBySpecific(
        _campoSelecionado!,
        _valorCampo!,
      );
    }

    setState(() {
      _resultados = resultados;
    });
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
                onPressed: searchWound,
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
                child: Text('Buscar'),
              ),
            ),

            SizedBox(height: 20),
            Expanded(
              child:
                  _resultados.isEmpty
                      ? Center(child: Text('Nenhum resultado encontrado'))
                      : ListView.builder(
                        itemCount: _resultados.length,
                        itemBuilder: (context, index) {
                          final item = _resultados[index];
                          return Card(
                            child: ListTile(
                              title: Text('ID: ${item['id']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Idade: ${item['idade'] ?? 'Desconhecida'}",
                                  ),
                                  Text(
                                    "Sexo: ${item['sexo'] ?? 'Desconhecido'}",
                                  ),
                                  Text(
                                    "Cor da Pele: ${item['cor_pele'] ?? 'Desconhecida'}",
                                  ),
                                  Text(
                                    "Localização: ${item['localizacao'] ?? 'Desconhecida'}",
                                  ),
                                  Text(
                                    "Formato: ${item['formato'] ?? 'Desconhecido'}",
                                  ),
                                  Text(
                                    "Origem da Ferida: ${item['origem_ferida'] ?? 'Desconhecida'}",
                                  ),
                                  Text(
                                    "Tempo de Evolução: ${item['tempo_evolucao'] ?? 'Desconhecido'}",
                                  ),
                                  Text(
                                    "Tipo de Tecido: ${item['tipo_tecido'] ?? 'Desconhecido'}",
                                  ),
                                  Text(
                                    "Causas: ${item['causas'] ?? 'Desconhecidas'}",
                                  ),
                                  Text(
                                    "Extensão da Lesão: ${item['extensao_lesao'] ?? 'Desconhecida'}",
                                  ),
                                  Text(
                                    "Ferida Curada: ${item['ferida_curada'] == true ? 'Sim' : 'Não'}",
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
