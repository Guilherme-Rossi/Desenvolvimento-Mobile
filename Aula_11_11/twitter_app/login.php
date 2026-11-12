<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$user = "root";
$pass = "";
$db = "twitter_app"; 

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die(json_encode(["sucesso" => false, "mensagem" => "Falha na conexão"]));
}

$email = $_POST['email'] ?? '';
$senha = $_POST['senha'] ?? '';

if (!empty($email) && !empty($senha)) {
    $stmt = $conn->prepare("SELECT id, nome FROM usuarios WHERE email = ? AND senha = ?");
    $stmt->bind_param("ss", $email, $senha);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode(["sucesso" => true, "mensagem" => "Login aprovado", "nome" => $row['nome']]);
    } else {
        echo json_encode(["sucesso" => false, "mensagem" => "E-mail ou senha incorretos."]);
    }
    $stmt->close();
} else {
    echo json_encode(["sucesso" => false, "mensagem" => "Preencha todos os campos."]);
}
$conn->close();
?>