<?php
include 'conexao.php';
header('Content-Type: application/json; charset=utf-8');

$diretorio = "uploads/";
if (!file_exists($diretorio)) {
    mkdir($diretorio, 0777, true);
}

if (isset($_FILES['foto']) && isset($_POST['descricao'])) {
    $descricao = $_POST['descricao'];
    $nome_arquivo = time() . '_' . basename($_FILES["foto"]["name"]);
    $caminho = $diretorio . $nome_arquivo;

    if (move_uploaded_file($_FILES["foto"]["tmp_name"], $caminho)) {
        // Grava no banco de dados
        $stmt = $conn->prepare("INSERT INTO galeria (caminho, descricao) VALUES (?, ?)");
        $stmt->bind_param("ss", $caminho, $descricao);
        
        if ($stmt->execute()) {
            echo json_encode(["sucesso" => "Foto e descrição salvas com sucesso!"]);
        } else {
            echo json_encode(["erro" => "Erro ao salvar no banco de dados."]);
        }
        $stmt->close();
    } else {
        echo json_encode(["erro" => "Erro ao mover o arquivo de imagem."]);
    }
} else {
    echo json_encode(["erro" => "Faltam dados na requisição."]);
}
$conn->close();
?>