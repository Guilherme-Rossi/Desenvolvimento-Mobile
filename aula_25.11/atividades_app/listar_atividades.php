<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "atividades_app");
$conn->set_charset("utf8mb4");

if ($conn->connect_error) {
    die(json_encode([]));
}

$mes = intval($_GET['mes'] ?? date('n'));
$ano = intval($_GET['ano'] ?? date('Y'));

$stmt = $conn->prepare("SELECT id, dia, mes, ano, atividade FROM atividades WHERE mes = ? AND ano = ? ORDER BY dia ASC, id DESC");
$stmt->bind_param("ii", $mes, $ano);
$stmt->execute();
$result = $stmt->get_result();

$atividades = [];
while ($row = $result->fetch_assoc()) {
    $atividades[] = $row;
}

echo json_encode($atividades, JSON_UNESCAPED_UNICODE);

$stmt->close();
$conn->close();
?>