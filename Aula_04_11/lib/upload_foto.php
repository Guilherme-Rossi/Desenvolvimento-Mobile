<?php
header('Content-Type: application/json; charset=utf-8');

$diretorio = "uploads/";
// Cria a pasta se ela não existir
if (!file_exists($diretorio)) {
    mkdir($diretorio, 0777, true);
}

// Verifica se o arquivo 'foto' foi enviado na requisição
if (isset($_FILES['foto'])) {
    // Gera um nome único para não sobrescrever fotos anteriores
    $nome_arquivo = time() . '_' . basename($_FILES["foto"]["name"]);
    $caminho_completo = $diretorio . $nome_arquivo;

    if (move_uploaded_file($_FILES["foto"]["tmp_name"], $caminho_completo)) {
        echo json_encode(["sucesso" => "Foto salva com sucesso!", "caminho" => $caminho_completo]);
    } else {
        echo json_encode(["erro" => "Erro ao salvar o arquivo no servidor."]);
    }
} else {
    echo json_encode(["erro" => "Nenhuma foto foi recebida pelo PHP."]);
}
?>