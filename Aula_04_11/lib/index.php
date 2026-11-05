<?php 
// Inclui a conexão com o banco de dados que você já criou
include 'conexao.php'; 
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Galeria Maritaca - Web</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f9;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        h1, h2 { text-align: center; color: #3f51b5; }
        
        /* Estilo do Formulário */
        .form-container {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-bottom: 40px;
        }
        input[type="file"], textarea {
            width: 100%;
            padding: 10px;
            margin-top: 8px;
            margin-bottom: 16px;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-sizing: border-box;
        }
        button {
            width: 100%;
            background-color: #3f51b5;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
        }
        button:hover { background-color: #303f9f; }

        /* Estilo da Galeria */
        .galeria {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
        }
        .card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
        }
        .card img {
            width: 100%;
            height: 250px;
            object-fit: cover;
        }
        .card p {
            padding: 15px;
            margin: 0;
            font-size: 16px;
            color: #555;
        }
        .mensagem {
            text-align: center;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: bold;
        }
        .sucesso { background-color: #d4edda; color: #155724; }
        .erro { background-color: #f8d7da; color: #721c24; }
    </style>
</head>
<body>

    <h1> Galeria Maritaca</h1>

    <!-- ÁREA DE PROCESSAMENTO DO UPLOAD (PHP) -->
    <?php
    if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_FILES["foto"])) {
        $descricao = $_POST['descricao'];
        $diretorio = "uploads/";
        
        // Garante que a pasta existe
        if (!file_exists($diretorio)) {
            mkdir($diretorio, 0777, true);
        }

        $nome_arquivo = time() . '_' . basename($_FILES["foto"]["name"]);
        $caminho = $diretorio . $nome_arquivo;

        // Tenta mover a imagem e salvar no BD
        if (move_uploaded_file($_FILES["foto"]["tmp_name"], $caminho)) {
            $stmt = $conn->prepare("INSERT INTO galeria (caminho, descricao) VALUES (?, ?)");
            $stmt->bind_param("ss", $caminho, $descricao);
            
            if ($stmt->execute()) {
                echo "<div class='mensagem sucesso'>Foto enviada e salva na base de dados com sucesso!</div>";
            } else {
                echo "<div class='mensagem erro'>Erro ao salvar na base de dados.</div>";
            }
            $stmt->close();
        } else {
            echo "<div class='mensagem erro'>Erro ao fazer o upload da imagem.</div>";
        }
    }
    ?>

    <!-- FORMULÁRIO HTML -->
    <div class="form-container">
        <h2>Enviar Nova Foto</h2>
        <!-- O enctype="multipart/form-data" é OBRIGATÓRIO para enviar arquivos -->
        <form method="POST" action="" enctype="multipart/form-data">
            <label for="foto">Escolha uma imagem:</label>
            <input type="file" name="foto" id="foto" required accept="image/*">

            <label for="descricao">Descrição da foto:</label>
            <textarea name="descricao" id="descricao" rows="3" required placeholder="Escreva algo sobre a foto..."></textarea>

            <button type="submit">Salvar no Servidor</button>
        </form>
    </div>

    <!-- EXIBIÇÃO DA GALERIA -->
    <h2>Fotos Salvas</h2>
    <div class="galeria">
        <?php
        // Busca as fotos no banco de dados ordenando da mais recente para a mais antiga (DESC)
        $sql = "SELECT caminho, descricao FROM galeria ORDER BY id DESC";
        $resultado = $conn->query($sql);

        if ($resultado->num_rows > 0) {
            while($linha = $resultado->fetch_assoc()) {
                echo "<div class='card'>";
                // Usa o caminho salvo no BD para mostrar a imagem
                echo "<img src='" . htmlspecialchars($linha['caminho']) . "' alt='Foto da galeria'>";
                // Mostra a descrição
                echo "<p>" . htmlspecialchars($linha['descricao']) . "</p>";
                echo "</div>";
            }
        } else {
            echo "<p style='grid-column: 1 / -1; text-align: center;'>Nenhuma foto encontrada. Envie a primeira!</p>";
        }
        
        $conn->close();
        ?>
    </div>

</body>
</html>