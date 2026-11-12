<?php
include 'conexao.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $texto = $_POST['texto'];
    
    // Prepara a inserção de forma segura contra SQL Injection
    $stmt = $conn->prepare("INSERT INTO textos (Texto) VALUES (?)");
    $stmt->bind_param("s", $texto);
    
    if ($stmt->execute()) {
        $mensagem = "Texto salvo com sucesso!";
    } else {
        $mensagem = "Erro ao salvar no banco de dados.";
    }
    $stmt->close();
}
?>

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Salvar Texto</title>
</head>
<body>
    <h2>Enviar novo texto</h2>
    <?php if(isset($mensagem)) echo "<p><strong>$mensagem</strong></p>"; ?>
    
    <form method="POST" action="">
        <textarea name="texto" rows="4" cols="50" required placeholder="Digite o texto aqui..."></textarea><br><br>
        <button type="submit">Salvar</button>
    </form>
</body>
</html>