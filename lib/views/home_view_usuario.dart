import 'package:cadastro_dados/views/auth/register_view.dart';
import 'package:cadastro_dados/views/list_wound_usuario_view.dart';
import 'package:cadastro_dados/views/searche_wound_usuario_view.dart';
import 'package:flutter/material.dart';
import 'create_wound_view.dart';
import 'list_wound_view.dart';
import 'search_wound_view.dart';
import '../controllers/auth_controller.dart';
import 'user/user_management_view.dart';
import 'auth/login_view.dart';

class HomeScreenUsuario extends StatefulWidget {
  const HomeScreenUsuario({super.key});

  @override
  State<HomeScreenUsuario> createState() => _HomeScreenUsuarioState();
}

class _HomeScreenUsuarioState extends State<HomeScreenUsuario> {
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sistema de Cadastro de Feridas',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.medical_services, size: 80, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Sistema de Cadastro de Feridas',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              SizedBox(height: 60),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildCustomButton(
                            'Buscar Ferida',
                            Icons.search,
                            SearchWoundUsuarioScreen(),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildCustomButton(
                            'Listar Feridas',
                            Icons.list,
                            WoundsListScreenUsuario(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton(String text, IconData icon, Widget screen) {
    return Container(
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[700],
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue[700]),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
