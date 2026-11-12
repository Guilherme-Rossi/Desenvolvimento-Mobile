<?php
include 'conexao.php';
header('Content-Type: application/json; charset=utf-8');

$sql = "SELECT id, caminho, descricao FROM galeria ORDER BY id ASC";
$resultado = $conn->query($sql);

$fotos = array();
while ($linha = $resultado->fetch_assoc()) {
    $fotos[] = $linha;
}

echo json_encode($fotos, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
$conn->close();
?>