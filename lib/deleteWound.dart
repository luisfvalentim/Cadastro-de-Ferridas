import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteScreen extends StatefulWidget {
  @override
  _DeleteScreenState createState() => _DeleteScreenState();
}

class _DeleteScreenState extends State<DeleteScreen> {
  final TextEditingController _idController = TextEditingController();
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  Map<String, dynamic>? _dadosPessoa;

  Future<void> buscarPessoa(int id) async {
    try {
      final response =
          await _supabaseClient.from('pessoas').select().eq('id', id).single();

      setState(() {
        _dadosPessoa = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registro não encontrado!')));
      setState(() {
        _dadosPessoa = null;
      });
    }
  }

  Future<void> deletarPessoa(int id) async {
    try {
      await _supabaseClient.from('pessoas').delete().eq('id', id);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registro deletado com sucesso!')));

      setState(() {
        _dadosPessoa = null;
        _idController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao deletar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buscar e Deletar Registro',
          style: TextStyle(color: Colors.blue),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200, // Defina a largura desejada
              child: TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ID do Registro',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  int? id = int.tryParse(_idController.text);
                  if (id != null) {
                    buscarPessoa(id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Por favor, insira um ID válido.'),
                      ),
                    );
                  }
                },
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
            SizedBox(height: 30),
            _dadosPessoa != null
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Dados do Registro:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'ID: ${_dadosPessoa!['id']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Idade: ${_dadosPessoa!['idade']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Sexo: ${_dadosPessoa!['sexo']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Cor da Pele: ${_dadosPessoa!['cor_pele']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Localização: ${_dadosPessoa!['localizacao']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Formato: ${_dadosPessoa!['formato']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Origem da Ferida: ${_dadosPessoa!['origem_ferida']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Tempo de Evolução: ${_dadosPessoa!['tempo_evolucao']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Tipo de Tecido: ${_dadosPessoa!['tipo_tecido']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Causas: ${_dadosPessoa!['causas']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Extensão da Lesão: ${_dadosPessoa!['extensao_lesao']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Ferida Curada: ${_dadosPessoa!['ferida_curada'] ? "Sim" : "Não"}',
                      style: TextStyle(fontSize: 16),
                    ),

                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            deletarPessoa(_dadosPessoa!['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
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
                          child: Text('Deletar'),
                        ),
                        SizedBox(width: 16), // Espaço entre os botões
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _dadosPessoa = null;
                              _idController.clear();
                            });
                          },
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
                          child: Text('Voltar'),
                        ),
                      ],
                    ),
                  ],
                )
                : Container(),
          ],
        ),
      ),
    );
  }
}
