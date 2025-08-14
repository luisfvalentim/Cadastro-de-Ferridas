import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user.dart';
import 'edit_user_view.dart';

class UserManagementView extends StatefulWidget {
  @override
  _UserManagementViewState createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final AuthController _authController = AuthController();

  List<AppUser> _users = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'all'; // all, active, inactive

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _authController.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<AppUser> get _filteredUsers {
    switch (_filterStatus) {
      case 'active':
        return _users.where((user) => user.isUserActive).toList();
      case 'inactive':
        return _users.where((user) => !user.isUserActive).toList();
      default:
        return _users;
    }
  }

  Future<void> _toggleUserStatus(AppUser user) async {
    try {
      final success = await _authController.toggleUserStatus(
        user.id,
        !user.isUserActive,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isUserActive
                  ? 'Usuário desativado com sucesso'
                  : 'Usuário ativado com sucesso',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar Exclusão'),
            content: Text(
              'Tem certeza que deseja excluir o usuário "${user.name}"?\n\nEsta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final success = await _authController.deleteUser(user.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usuário excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUserCard(AppUser user) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: user.isUserActive ? Colors.green : Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: user.isUserActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              user.username,
              style: TextStyle(
                color: user.isUserActive ? Colors.grey[600] : Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                _badge(
                  user.isAdmin ? 'Admin' : 'Usuário',
                  user.isAdmin ? Colors.purple : Colors.blue,
                ),
                SizedBox(width: 8),
                _badge(
                  user.isUserActive ? 'Ativo' : 'Inativo',
                  user.isUserActive ? Colors.green : Colors.red,
                ),
              ],
            ),
            if (user.createdAt != null) ...[
              SizedBox(height: 4),
              Text(
                'Criado em: ${_formatDate(user.createdAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUserView(user: user),
                  ),
                ).then((_) => _loadUsers());
                break;
              case 'toggle':
                _toggleUserStatus(user);
                break;
              case 'delete':
                if (user.id != _authController.currentUser?.id) {
                  _deleteUser(user);
                }
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: _menuItem(Icons.edit, 'Editar', Colors.blue),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: _menuItem(
                    user.isUserActive ? Icons.block : Icons.check_circle,
                    user.isUserActive ? 'Desativar' : 'Ativar',
                    user.isUserActive ? Colors.orange : Colors.green,
                  ),
                ),
                if (user.id != _authController.currentUser?.id)
                  PopupMenuItem(
                    value: 'delete',
                    child: _menuItem(Icons.delete, 'Excluir', Colors.red),
                  ),
              ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return Row(
      children: [Icon(icon, color: color), SizedBox(width: 8), Text(label)],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.limeAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Erro: $_error'));
    }
    if (_filteredUsers.isEmpty) {
      return Center(child: Text('Nenhum usuário encontrado'));
    }
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gerenciar Usuários',
          style: TextStyle(color: Colors.blue[700]),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.blue[700]),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadUsers)],
      ),
      body: Column(children: [_buildFilter(), Expanded(child: _buildBody())]),
    );
  }

  Widget _buildFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Text('Filtrar: ', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterStatus,
              items: [
                DropdownMenuItem(value: 'all', child: Text('Todos')),
                DropdownMenuItem(value: 'active', child: Text('Ativos')),
                DropdownMenuItem(value: 'inactive', child: Text('Inativos')),
              ],
              onChanged: (value) => setState(() => _filterStatus = value!),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
