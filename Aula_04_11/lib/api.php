<?php
include 'conexao.php';

// Define o cabeçalho para a página ser reconhecida como JSON
header('Content-Type: application/json; charset=utf-8');

if (isset($_GET['id'])) {
    $id_informado = intval($_GET['id']);
    
    // Busca o primeiro texto com ID MAIOR que o informado
    // O alias 'AS id' e 'AS texto' garante que as chaves do JSON fiquem minúsculas conforme o PDF
    $sql = "SELECT ID AS id, Texto AS texto FROM textos WHERE ID > ? ORDER BY ID ASC LIMIT 1";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $id_informado);
    $stmt->execute();
    $resultado = $stmt->get_result();
    
    if ($linha = $resultado->fetch_assoc()) {
        // Retorna o JSON com as chaves "id" e "texto"
        echo json_encode($linha, JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode(["erro" => "Nenhum texto encontrado com id maior que $id_informado"]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["erro" => "Por favor, passe o parametro 'id' na URL. Exemplo: api.php?id=1"]);
}

$conn->close();
?>