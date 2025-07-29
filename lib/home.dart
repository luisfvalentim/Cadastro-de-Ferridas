import 'package:flutter/material.dart';
import 'package:cadastro_dados/deleteWound.dart';
import 'package:cadastro_dados/insertWound.dart';
import 'package:cadastro_dados/listWound.dart';
import 'package:cadastro_dados/searchWound.dart';
import 'package:cadastro_dados/updateWound.dart';
import 'package:cadastro_dados/drive_images_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Dados de Feridas',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 100),

            // Criando um widget personalizado para os botões
            _buildCustomButton('Adicionar Ferida', AddWoundScreen()),
            SizedBox(height: 10),
            _buildCustomButton('Buscar tipo de Ferida', SearchWoundScreen()),
            SizedBox(height: 10),
            _buildCustomButton('Lista Completa', PeopleScreen()),
            SizedBox(height: 10),
            _buildCustomButton('Deletar Ferida', DeleteScreen()),
            SizedBox(height: 10),
            _buildCustomButton('Editar Ferida', EditWoundScreen()),
            SizedBox(height: 10),
            _buildCustomButton('Ver Imagens (Drive)', DriveImagesPage()),
          ],
        ),
      ),
    );
  }

  // Método para criar botões personalizados
  Widget _buildCustomButton(String text, Widget screen) {
    return SizedBox(
      width: 250, // Largura fixa para todos os botões
      height: 50, // Altura fixa
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Cor do botão
          foregroundColor: Colors.white, // Cor do texto
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Cantos arredondados
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
