<?php
$servidor = "localhost";
$usuario = "root"; // Usuário padrão do XAMPP
$senha = "";       // O XAMPP vem sem senha por padrão
$banco = "maritaca";

$conn = new mysqli($servidor, $usuario, $senha, $banco);

// Verifica se houve erro
if ($conn->connect_error) {
    die("Falha na conexão: " . $conn->connect_error);
}
// Define o padrão de caracteres para evitar problemas com acentos
$conn->set_charset("utf8mb4");
?>