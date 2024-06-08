<?php
session_start();
include 'connection.php';

if (!isset($_SESSION["username"])) {
    echo "not_logged_in";
    exit();
}

$conn = new mysqli($servername, $dbusername, $dbpassword, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$post_id = $_POST["post_id"];
$username = $_SESSION["username"];

// Check if the user has already liked the post
$check_like_query = "SELECT * FROM likes WHERE post_id = $post_id AND username = '$username'";
$check_like_result = $conn->query($check_like_query);

if ($check_like_result->num_rows > 0) {
    // User has already liked the post, so unlike it
    $delete_like_query = "DELETE FROM likes WHERE post_id = $post_id AND username = '$username'";
    if ($conn->query($delete_like_query) === TRUE) {
        echo "unliked";
    } else {
        echo "error";
    }
} else {
    // User has not liked the post yet, so like it
    $insert_like_query = "INSERT INTO likes (post_id, username) VALUES ($post_id, '$username')";
    if ($conn->query($insert_like_query) === TRUE) {
        echo "liked";
    } else {
        echo "error";
    }
}

$conn->close();
?>
