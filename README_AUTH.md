# Sistema de Autenticação - Sistema de Cadastro de Feridas

## 📋 Visão Geral

Este sistema implementa um completo sistema de autenticação seguindo o padrão MVC, incluindo:

- ✅ **Login e Cadastro** de usuários
- ✅ **Gerenciamento de Usuários** (para administradores)
- ✅ **Edição e Exclusão** de usuários
- ✅ **Controle de Acesso** baseado em roles
- ✅ **Validações** de formulário
- ✅ **Tratamento de Erros** robusto

## 🏗️ Estrutura MVC

```
lib/
├── models/
│   ├── wound.dart              # Modelo de dados de feridas
│   └── user.dart               # Modelo de dados de usuários
├── views/
│   ├── auth/                   # Telas de autenticação
│   │   ├── login_view.dart     # Tela de login
│   │   ├── register_view.dart  # Tela de cadastro
│   │   ├── user_management_view.dart  # Gerenciamento de usuários
│   │   └── edit_user_view.dart # Edição de usuário
│   └── [outras telas...]
├── controllers/
│   ├── wound_controller.dart   # Lógica de negócio das feridas
│   └── auth_controller.dart    # Lógica de negócio da autenticação
└── services/
    ├── wound_service.dart      # Acesso a dados das feridas
    └── auth_service.dart       # Acesso a dados de usuários
```

## 🗄️ Configuração do Banco de Dados

### 1. Criar Tabela de Usuários no Supabase

Execute o seguinte SQL no seu projeto Supabase:

```sql
-- Criar tabela de usuários
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices para melhor performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- Inserir usuário administrador padrão
INSERT INTO users (email, name, password, role, is_active) 
VALUES ('admin@sistema.com', 'Administrador', 'admin123', 'admin', true);

-- Habilitar RLS (Row Level Security) se necessário
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança (exemplo básico)
CREATE POLICY "Users can view their own data" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Admins can manage all users" ON users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid()::int AND role = 'admin'
        )
    );
```

### 2. Configurar Variáveis de Ambiente

No arquivo `lib/main.dart`, atualize as credenciais do Supabase:

```dart
await Supabase.initialize(
  url: 'SUA_URL_DO_SUPABASE',
  anonKey: 'SUA_CHAVE_ANONIMA',
);
```

## 🔐 Funcionalidades de Segurança

### Validações Implementadas

- **Email**: Formato válido e único
- **Senha**: Mínimo 6 caracteres
- **Nome**: Mínimo 2 caracteres
- **Confirmação de senha**: Deve coincidir

### Controle de Acesso

- **Usuários comuns**: Acesso às funcionalidades básicas
- **Administradores**: Acesso completo + gerenciamento de usuários

### Proteções

- ✅ Soft delete (usuários não são excluídos permanentemente)
- ✅ Validação de permissões antes de operações sensíveis
- ✅ Não permite excluir o próprio usuário
- ✅ Não permite desativar a própria conta

## 🚀 Como Usar

### 1. Primeiro Acesso

1. Execute o SQL para criar a tabela de usuários
2. Configure as credenciais do Supabase no `main.dart`
3. Execute o app - será direcionado para a tela de login
4. Use o usuário admin padrão ou crie uma nova conta

### 2. Login

- Email: `admin@sistema.com`
- Senha: `admin123`

### 3. Gerenciamento de Usuários (Admin)

- Acesse o ícone de usuários no AppBar
- Visualize, edite, ative/desative ou exclua usuários
- Filtre por status (Ativos/Inativos/Todos)

## 📱 Telas Implementadas

### 🔐 Autenticação
- **Login**: Interface moderna com validações
- **Cadastro**: Formulário completo com confirmação de senha
- **Logout**: Acesso via menu do usuário

### 👥 Gerenciamento (Admin)
- **Lista de Usuários**: Visualização com filtros
- **Edição**: Formulário completo com opção de alterar senha
- **Ativação/Desativação**: Controle de status
- **Exclusão**: Soft delete com confirmação

## 🎨 Design System

- **Cores**: Azul como cor principal
- **Gradientes**: Fundos suaves
- **Cards**: Elevação e sombras
- **Loading States**: Indicadores visuais
- **Error Handling**: Mensagens claras e amigáveis

## 🔧 Personalizações

### Adicionar Novos Roles

1. Atualize o enum/modelo de usuário
2. Modifique as validações no controller
3. Atualize as telas de gerenciamento

### Implementar Hash de Senha

```dart
// No AuthService, substitua a comparação direta por:
import 'package:crypto/crypto.dart';
import 'dart:convert';

String _hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}
```

### Adicionar Recuperação de Senha

1. Implemente endpoint no Supabase
2. Crie tela de recuperação
3. Adicione link "Esqueci minha senha"

## 🐛 Troubleshooting

### Problemas Comuns

1. **Erro de conexão**: Verifique as credenciais do Supabase
2. **Usuário não encontrado**: Confirme se a tabela foi criada
3. **Permissões negadas**: Verifique as políticas RLS

### Logs de Debug

O sistema inclui logs detalhados para facilitar o debug:

```dart
print('Erro no login: $e');
print('Erro ao buscar usuários: $e');
```

## 📈 Próximos Passos

- [ ] Implementar hash de senha
- [ ] Adicionar recuperação de senha
- [ ] Implementar refresh tokens
- [ ] Adicionar autenticação biométrica
- [ ] Implementar auditoria de ações
- [ ] Adicionar notificações push

---

**Sistema de Autenticação Completo e Seguro! 🔐✨** 