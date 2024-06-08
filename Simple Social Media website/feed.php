<?php
session_start();
include 'connection.php';

// Check if the user is logged in
if (!isset($_SESSION["username"])) {
    header("Location: login.html");
    exit();
}

// Create connection
$conn = new mysqli($servername, $dbusername, $dbpassword, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle post submission including optional file upload
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["submit_post"])) {
    $username = $_SESSION["username"];
    $content = htmlspecialchars($_POST["content"]);

    if (!empty($_FILES["image"]["name"])) {
        $file_name = $_FILES["image"]["name"];
        $file_temp = $_FILES["image"]["tmp_name"];
        $file_destination = "uploads/" . $file_name;

        if (move_uploaded_file($file_temp, $file_destination)) {
            $stmt = $conn->prepare("INSERT INTO posts (username, content, image_path) VALUES (?, ?, ?)");
            $stmt->bind_param("sss", $username, $content, $file_destination);
            $stmt->execute();
            $stmt->close();
            $last_post_id = $conn->insert_id; // Get the ID of the last inserted post
            header("Location: feed.php#post_" . $last_post_id); // Redirect with post ID as fragment identifier
            exit();
        } else {
            echo "Failed to upload the file.";
        }
    } else {
        if (!empty($content)) {
            $stmt = $conn->prepare("INSERT INTO posts (username, content) VALUES (?, ?)");
            $stmt->bind_param("ss", $username, $content);
            $stmt->execute();
            $stmt->close();
            $last_post_id = $conn->insert_id; // Get the ID of the last inserted post
            header("Location: feed.php#post_" . $last_post_id); // Redirect with post ID as fragment identifier
            exit();
        }
    }
}

// Retrieve posts from database
$posts_query = "SELECT id, username, content, created_at, image_path FROM posts ORDER BY created_at DESC";
$posts_result = $conn->query($posts_query);
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Feed</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="./scripts/script.js"></script>
    <style>
  .posts {
    width: 70%; /* Adjust the width as needed */
    height: auto; /* Adjust the height as needed */
    padding: 10px; /* Adjust padding as needed */
    margin-bottom: 10px; /* Adjust margin as needed */
    border-width: 2px; /* Adjust border thickness as needed */
  }
  .new_post {
    width: 70%; /* Adjust the width as needed */
    height: auto; /* Adjust the height as needed */
    margin-bottom: 20px; /* Adjust margin as needed */
  }
</style>
</head>

<body>
    <nav class="navbar navbar-dark bg-primary">
        <span class="navbar-brand mb-0 h1">Facebootleg</span>
        <div class="ml-auto">
            <a href="logout.php" class="btn btn-outline-light">Logout</a>
        </div>
    </nav>

    <div class="container mt-3">
        <h1>Welcome to the Feed Page, <?php echo htmlspecialchars($_SESSION["username"]); ?>!</h1>

        <!-- Post creation form with file upload -->
        <div class="list-group">
            <div class="d-flex justify-content-center">
                <form action="feed.php" method="post" enctype="multipart/form-data" class="mb-4 new_post">
                    <div class="form-group">
                        <label for="content">Create a post:</label>
                        <textarea class="form-control" id="content" name="content" rows="3" required></textarea>
                    </div>
                    <div class="form-group">
                        <label for="image">Upload Image:</label>
                        <input type="file" class="form-control-file" id="image" name="image" accept="image/png, image/gif, image/jpeg">
                    </div>
                    <button type="submit" name="submit_post" class="btn btn-primary">Post</button>
                </form>
            </div>
        </div>

        <!-- Display posts including images -->
        <?php if ($posts_result->num_rows > 0): ?>
            <div class="list-group">
                <?php while ($post = $posts_result->fetch_assoc()): ?>
                <div class="d-flex justify-content-center">
                    <div id="post_<?php echo $post['id']; ?>" class="list-group-item mb-4 border-top posts">
                        <!-- Delete button -->
                        <?php if ($_SESSION["username"] == $post["username"]) : ?>
                            <div class="d-flex justify-content-end">
                                <button type="button" class="btn btn-danger btn-sm delete-btn" data-post-id="<?php echo $post["id"]; ?>">Delete</button>
                            </div>
                        <?php endif; ?>
                        <h5 class="mb-1"><?php echo ($post["username"]); ?></h5>
                        <p class="mb-1"><?php echo ($post["content"]); ?></p>
                        <small class="text-muted"><?php echo $post["created_at"]; ?></small>

                        <!-- Display image if available -->
                        <?php if (!empty($post["image_path"])): ?>
                            <div class="mt-2 d-flex justify-content-center">
                                <img src="<?php echo $post["image_path"]; ?>" class="img-fluid" alt="Post Image">
                            </div>
                        <?php endif; ?>

                        <!-- Like button -->
                        <?php
                        $liked = false;
                        $post_id = $post["id"];
                        $username = $_SESSION["username"];
                        $check_like_query = "SELECT * FROM likes WHERE post_id = $post_id AND username = '$username'";
                        $check_like_result = $conn->query($check_like_query);
                        $liked = $check_like_result->num_rows > 0;
                        ?>
                        <div class="mt-2 mb-2">
                        <button type="button" class="like-btn btn btn-<?php echo $liked ? "success" : "primary"; ?> btn-sm" data-post-id="<?php echo $post["id"]; ?>">
                            <?php echo $liked ? "Liked" : "Like"; ?>
                        </button>
                        </div>

                        <!-- Display comments -->
                        <?php
                        $comments_query = "SELECT * FROM comments WHERE post_id = $post_id";
                        $comments_result = $conn->query($comments_query);

                        if ($comments_result->num_rows > 0): ?>
                            <div class="comments" style="max-height: 150px; overflow-y: auto;">
                                <?php while ($comment = $comments_result->fetch_assoc()): ?>
                                    <div class="comment">
                                        <p><strong><?php echo ($comment["username"]); ?>:</strong> <?php echo ($comment["comment"]); ?></p>
                                    </div>
                                <?php endwhile; ?>
                            </div>
                        <?php endif; ?>

                        <!-- Comment form -->
                        <form id="commentForm" action="handle_comment.php" method="post" class="mb-2">
                            <div class="form-group">
                                <input type="text" class="form-control comment-form" name="comment" placeholder="Write a comment..." required>
                                <input type="hidden" name="post_id" value="<?php echo $post["id"]; ?>">
                            </div>
                            <button type="submit" name="submit_comment" class="btn btn-primary btn-sm">Comment</button>
                        </form>
     
                    </div>
                </div>
                <?php endwhile; ?>
            </div>
        <?php else: ?>
            <p>No posts to display.</p>
        <?php endif; ?>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.4/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>

</html>

<?php
$conn->close();
?>
