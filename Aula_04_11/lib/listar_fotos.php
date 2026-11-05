<?php
header('Content-Type: application/json; charset=utf-8');

$diretorio = "uploads/";
$fotos = array();

// Verifica se a pasta existe e lê os arquivos
if (is_dir($diretorio)) {
    $arquivos = scandir($diretorio);
    foreach ($arquivos as $arquivo) {
        // Ignora os diretórios raiz do sistema
        if ($arquivo !== '.' && $arquivo !== '..') {
            // Retorna apenas o caminho relativo da imagem
            $fotos[] = $diretorio . $arquivo;
        }
    }
}

echo json_encode($fotos, JSON_UNESCAPED_SLASHES);
?>