# 🔧 Solução CORS para Imagens - Laravel

## 1. Adicione estas rotas no seu `routes/web.php`:

```php
<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Request;

// Servir imagens com CORS para Flutter Web
Route::get('/storage/{path}', function (Request $request, string $path) {
    if (!Storage::disk('public')->exists($path)) {
        abort(404);
    }
    
    $file = Storage::disk('public')->get($path);
    $mime = Storage::disk('public')->mimeType($path) ?? 'application/octet-stream';
    
    return response($file, 200)
        ->header('Content-Type', $mime)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        ->header('Cache-Control', 'public, max-age=31536000, immutable');
})->where('path', '.*');

// Preflight OPTIONS para /storage/*
Route::options('/storage/{any}', function () {
    return response('', 204)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
})->where('any', '.*');
```

## 2. Certifique-se que seu `config/cors.php` está assim:

```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie', 'storage/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

## 3. Execute estes comandos no Laravel:

```bash
# Limpar cache
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Criar symlink se não existir
php artisan storage:link

# Reiniciar servidor
php artisan serve --host=0.0.0.0 --port=8000
```

## 4. Teste direto no navegador:

Abra: `http://192.168.18.64:8000/storage/feridas/1TURhxFAlt7ta3kEooPFyK2WN8qhb8HSSJxbLmhK.jpg`

Se a imagem carregar com headers CORS, está funcionando!

## 5. Teste no Flutter Web:

- Faça hard refresh (Cmd/Ctrl+Shift+R)
- Vá para a tela de imagens
- As imagens devem carregar normalmente

## ✅ Checklist Final:

- [ ] Rotas adicionadas em `routes/web.php`
- [ ] CORS configurado em `config/cors.php`
- [ ] Caches limpos
- [ ] Symlink criado
- [ ] Servidor reiniciado
- [ ] Teste direto no navegador funcionando
- [ ] Flutter Web carregando imagens

🎯 **Resultado esperado**: Imagens carregando normalmente no Flutter Web sem erros de CORS!

