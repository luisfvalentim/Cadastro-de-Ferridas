import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PeopleScreen extends StatefulWidget {
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await _supabaseClient.from('pessoas').select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de Pessoas",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error); // <-- isso aqui vai te mostrar o erro real
            return Center(child: Text("Erro ao carregar os dados"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Nenhuma pessoa encontrada"));
          }

          final pessoas = snapshot.data!;

          return ListView.builder(
            itemCount: pessoas.length,
            itemBuilder: (context, index) {
              final pessoa = pessoas[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    "ID: ${pessoa['id'] ?? 'Desconhecido'}",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sexo: ${pessoa['sexo'] ?? 'Desconhecido'}"),
                      Text(
                        "Criado em: ${pessoa['created_at'] ?? 'Desconhecido'}",
                      ),
                      Text(
                        "Data de nascimento: ${pessoa['idade'] ?? 'Desconhecida'}",
                      ),
                      Text(
                        "Cor da pele: ${pessoa['cor_pele'] ?? 'Desconhecida'}",
                      ),
                      Text(
                        "Localização: ${pessoa['localizacao'] ?? 'Desconhecida'}",
                      ),
                      Text("Formato: ${pessoa['formato'] ?? 'Desconhecido'}"),
                      Text(
                        "Origem da ferida: ${pessoa['origem_ferida'] ?? 'Desconhecida'}",
                      ),
                      Text(
                        "Tempo de evolução: ${pessoa['tempo_evolucao'] ?? 'Desconhecido'}",
                      ),
                      Text(
                        "Tipo de tecido: ${pessoa['tipo_tecido'] ?? 'Desconhecido'}",
                      ),
                      Text("Causas: ${pessoa['causas'] ?? 'Desconhecidas'}"),
                      Text(
                        "Extensão da lesão: ${pessoa['extensao_lesao'] ?? 'Desconhecida'}",
                      ),
                      Text(
                        "Ferida curada: ${pessoa['ferida_curada'] == true ? 'Sim' : 'Não'}",
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
