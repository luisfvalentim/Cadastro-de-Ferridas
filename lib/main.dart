import 'package:cadastro_dados/core/crud.dart';
import 'package:cadastro_dados/home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wpmtnoywhieljinjgfed.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwbXRub3l3aGllbGppbmpnZmVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4NTg3MTEsImV4cCI6MjA1ODQzNDcxMX0.7EPIoQWhviaG-hJZfvbT5jFXbClYraW0aIzSAGzTXq4',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Instruments', home: HomeScreen());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supa = SupaBaseCrudService();
  Future<dynamic> lowd() async {
    final result = supa.read();
    return result;
  }

  Future<void> create() async {
    supa.create({
      'id': 3,
      'created_at': DateTime.now().toIso8601String(),
      'idade': '1990-01-01',
      'sexo': 'Feminino',
      'cor_pele': 'Parda',
      'localizacao': 'Perna esquerda',
      'formato': 'Circular',
      'origem_ferida': 'Queimadura',
      'tempo_evolucao': '2 meses',
      'tipo_tecido': 'Granulação',
      'causas': 'Diabetes',
      'extensao_lesao': '5cm',
      'ferida_curada': false,
    });
  }

  @override
  void initState() {
    create();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: lowd(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final instruments = snapshot.data!;
          return ListView.builder(
            itemCount: instruments.length,
            itemBuilder: ((context, index) {
              final instrument = instruments[index];
              return Column(
                children: [
                  ListTile(title: Text(instrument['sexo'])),
                  ListTile(title: Text(instrument['idade'])),
                  ListTile(title: Text(instrument['id'].toString())),
                  ListTile(title: Text(instrument['causas'])),
                  ListTile(title: Text(instrument['formato'])),
                  ListTile(title: Text(instrument['cor_pele'])),
                ],
              );
            }),
          );
        },
      ),
    );
  }
}
