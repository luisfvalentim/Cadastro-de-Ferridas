import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class EditUserView extends StatefulWidget {
  final AppUser user;

  EditUserView({required this.user});

  @override
  _EditUserViewState createState() => _EditUserViewState();
}

class _EditUserViewState extends State<EditUserView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passwordController;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showPasswordField = false;
  String? _error;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _passwordController = TextEditingController();
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await AuthService.updateUser(
        id: widget.user.id,
        name: _nameController.text.trim(),
        password: _showPasswordField ? _passwordController.text : null,
        role: _selectedRole,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = 'Erro ao atualizar usuário';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Usuário',
          style: TextStyle(color: Colors.blue[700]),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.blue[700]),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _updateUser,
              child: Text(
                'Salvar',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24),
                  _buildFormFields(),
                  if (_error != null) ...[
                    SizedBox(height: 20),
                    _buildErrorBox(_error!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor:
                widget.user.isUserActive ? Colors.green : Colors.grey,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Editar Usuário',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ID: ${widget.user.id}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              labelText: 'Nome Completo',
              prefixIcon: Icon(Icons.person, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Por favor, insira o nome';
              if (value.length < 2)
                return 'O nome deve ter pelo menos 2 caracteres';
              return null;
            },
          ),
          SizedBox(height: 20),

          if (widget.user.isAdmin)
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Usuário',
                    prefixIcon: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'usuario', child: Text('Usuário')),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _selectedRole = value),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Selecione o tipo de usuário'
                              : null,
                ),
                SizedBox(height: 20),
              ],
            ),

          CheckboxListTile(
            title: Text('Alterar senha'),
            value: _showPasswordField,
            onChanged: (value) {
              setState(() {
                _showPasswordField = value ?? false;
                if (!_showPasswordField) _passwordController.clear();
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),

          if (_showPasswordField)
            Column(
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Nova Senha',
                    prefixIcon: Icon(Icons.lock, color: Colors.blue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (_showPasswordField &&
                        (value == null || value.length < 6)) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
              ],
            ),

          SizedBox(height: 24),
          _buildUserInfo(),
          SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isLoading ? null : _updateUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                      'Atualizar Usuário',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações do Usuário',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            'Status',
            widget.user.isUserActive ? 'Ativo' : 'Inativo',
          ),
          _buildInfoRow(
            'Tipo',
            widget.user.isAdmin ? 'Administrador' : 'Usuário',
          ),
          if (widget.user.createdAt != null)
            _buildInfoRow('Criado em', _formatDate(widget.user.createdAt!)),
          if (widget.user.updatedAt != null)
            _buildInfoRow('Atualizado em', _formatDate(widget.user.updatedAt!)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
