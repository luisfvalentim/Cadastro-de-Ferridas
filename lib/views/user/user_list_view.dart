import 'package:cadastro_dados/controllers/user/user_delete_controller.dart';
import 'package:cadastro_dados/controllers/user/user_edit_controller.dart';
import 'package:cadastro_dados/controllers/user/user_list_controller.dart';
import 'package:cadastro_dados/services/user/user_delete_service.dart';
import 'package:cadastro_dados/services/user/user_edit_service.dart';
import 'package:cadastro_dados/services/user/user_list_service.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';

class UserListView extends StatefulWidget {
  final AppUser currentUser;

  const UserListView({super.key, required this.currentUser});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  late final GetAllUsersController _listCtrl;
  late final UpdateUserController _updateCtrl;
  late final DeleteUserController _deleteCtrl;

  final _searchCtl = TextEditingController();

  List<AppUser> _all = [];
  bool _loading = true;
  String? _error;

  bool get _canEditRole => widget.currentUser.isAdmin;

  @override
  void initState() {
    super.initState();
    _listCtrl = GetAllUsersController(GetAllUsersService());
    _updateCtrl = UpdateUserController(UpdateUserService());
    _deleteCtrl = DeleteUserController(DeleteUserService());
    _load();
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _listCtrl.getAllUsers();
      setState(() => _all = data);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AppUser> get _filtered {
    final q = _searchCtl.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.username.toLowerCase().contains(q) ||
              u.role.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text(
              'Deseja excluir o usuário "${user.name}"?\nEssa ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      try {
        final ok = await _deleteCtrl.deleteUser(user.id);
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário excluído'),
              backgroundColor: Colors.green,
            ),
          );
          _load();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'.replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuários', style: TextStyle(color: Colors.blue[700])),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.blue[700]),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(children: [_searchBar(), Expanded(child: _body())]),
      floatingActionButton:
          _canEditRole
              ? FloatingActionButton.extended(
                onPressed: () {
                  // se quiser abrir RegisterView (admin escolhe role)
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterView(canChooseRole: true)))
                  //   .then((created) { if (created == true) _load(); });
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Cadastrar'),
              )
              : null,
    );
  }

  Widget _searchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchCtl,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Buscar por nome, usuário ou perfil…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchCtl.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtl.clear();
                      setState(() {});
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text('Erro: $_error'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          'Nenhum usuário encontrado',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _tile(_filtered[i]),
      ),
    );
  }

  Widget _tile(AppUser u) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: u.isUserActive ? Colors.green : Colors.grey,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          u.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('@${u.username}', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 6),
              Row(
                children: [
                  _badge(
                    u.isAdmin ? 'Admin' : 'Usuário',
                    u.isAdmin ? Colors.purple : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _badge(
                    u.isUserActive ? 'Ativo' : 'Inativo',
                    u.isUserActive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder:
              (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: _MenuRow(
                    icon: Icons.edit,
                    label: 'Editar',
                    color: Colors.blue,
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: _MenuRow(
                    icon: u.isUserActive ? Icons.block : Icons.check_circle,
                    label: u.isUserActive ? 'Desativar' : 'Ativar',
                    color: u.isUserActive ? Colors.orange : Colors.green,
                  ),
                ),
                if (u.id != widget.currentUser.id)
                  const PopupMenuItem(
                    value: 'delete',
                    child: _MenuRow(
                      icon: Icons.delete,
                      label: 'Excluir',
                      color: Colors.red,
                    ),
                  ),
              ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
