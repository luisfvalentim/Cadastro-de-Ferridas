<?php
// Adicione esta rota no seu arquivo routes/api.php do Laravel

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Response;

// Rota para fazer proxy das imagens (contornar CORS)
Route::get('/proxy-image', function (Request $request) {
    $path = $request->query('path');
    
    if (!$path) {
        return response()->json(['error' => 'Path parameter required'], 400);
    }
    
    // Remove /storage/ do início do caminho se existir
    $path = ltrim($path, '/storage/');
    
    // Verifica se o arquivo existe
    if (!Storage::disk('public')->exists($path)) {
        return response()->json(['error' => 'File not found'], 404);
    }
    
    // Obtém o arquivo
    $file = Storage::disk('public')->get($path);
    $mimeType = Storage::disk('public')->mimeType($path);
    
    // Retorna o arquivo com headers CORS apropriados
    return response($file)
        ->header('Content-Type', $mimeType)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET')
        ->header('Access-Control-Allow-Headers', 'Content-Type');
})->name('proxy.image');

// Exemplo de uso:
// GET /api/proxy-image?path=/storage/feridas/imagem.jpg
// Isso vai servir o arquivo storage/app/public/feridas/imagem.jpg
?>

