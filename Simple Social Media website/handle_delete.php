<?php
session_start();
include 'connection.php';

if (!isset($_SESSION["username"])) {
    echo "Unauthorized";
    exit();
}

$conn = new mysqli($servername, $dbusername, $dbpassword, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["post_id"])) {
    $post_id = $_POST["post_id"];
    $username = $_SESSION["username"];

    $delete_likes_query = "DELETE FROM likes WHERE post_id = $post_id";
    $delete_likes_result = $conn->query($delete_likes_query);

    $delete_comments_query = "DELETE FROM comments WHERE post_id = $post_id";
    $delete_comments_result = $conn->query($delete_comments_query);

    $delete_post_query = "DELETE FROM posts WHERE id = $post_id AND username = '$username'";
    if ($conn->query($delete_post_query)) {
        echo "success";
    } else {
        echo "error";
    }
} else {
    echo "Invalid request";
}

$conn->close();
?>
