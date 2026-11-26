<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "atividades_app");
$conn->set_charset("utf8mb4");

if ($conn->connect_error) {
    die(json_encode(["sucesso" => false, "mensagem" => "Erro ao conectar ao MySQL."]));
}

$dia = intval($_POST['dia'] ?? 0);
$mes = intval($_POST['mes'] ?? 0);
$ano = intval($_POST['ano'] ?? 0);
$atividade = trim($_POST['atividade'] ?? '');

if ($dia >= 1 && $dia <= 31 && $mes >= 1 && $mes <= 12 && $ano > 0 && !empty($atividade)) {
    $stmt = $conn->prepare("INSERT INTO atividades (dia, mes, ano, atividade) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("iiis", $dia, $mes, $ano, $atividade);

    if ($stmt->execute()) {
        echo json_encode(["sucesso" => true, "mensagem" => "Atividade salva com sucesso!"]);
    } else {
        echo json_encode(["sucesso" => false, "mensagem" => "Erro ao salvar no banco de dados."]);
    }
    $stmt->close();
} else {
    echo json_encode(["sucesso" => false, "mensagem" => "Informe um dia válido (1 a 31) e a atividade."]);
}

$conn->close();
?>