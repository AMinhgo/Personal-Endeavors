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

// Handle adding comments
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["submit_comment"])) {
    $post_id = $_POST["post_id"];
    $username = $_SESSION["username"];
    $comment = htmlspecialchars($_POST["comment"]);

    if (!empty($comment)) {
        $stmt = $conn->prepare("INSERT INTO comments (post_id, username, comment) VALUES (?, ?, ?)");
        $stmt->bind_param("iss", $post_id, $username, $comment);
        $stmt->execute();
        $stmt->close();

        // Redirect back to the feed page after adding a comment
        header("Location: feed.php#post_" . $post_id); // Redirect with post ID as fragment identifier
        exit();
    }
}


$conn->close();
?>
