<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Configurações de conexão
$host = "localhost";
$user = "root";
$pass = "";
$db = "twitter_app"; 

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die(json_encode(["sucesso" => false, "mensagem" => "Falha na conexão com o banco"]));
}

// Recebe os dados do Flutter
$nome = $_POST['nome'] ?? '';
$email = $_POST['email'] ?? '';
$senha = $_POST['senha'] ?? ''; 

if (!empty($nome) && !empty($email) && !empty($senha)) {
    // Insere os dados na tabela usuarios
    $stmt = $conn->prepare("INSERT INTO usuarios (nome, email, senha) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $nome, $email, $senha);
    
    if ($stmt->execute()) {
        echo json_encode(["sucesso" => true, "mensagem" => "Cadastro realizado com sucesso!"]);
    } else {
        echo json_encode(["sucesso" => false, "mensagem" => "Erro. Este e-mail já pode estar cadastrado."]);
    }
    $stmt->close();
} else {
    echo json_encode(["sucesso" => false, "mensagem" => "Preencha todos os campos corretamente."]);
}

$conn->close();
?>