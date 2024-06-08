<?php
$insert_query = null; // Define the variable outside the conditional block
include 'connection.php';
// Check if the form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve form data
    $username = htmlspecialchars($_POST["username"]);
    $email = htmlspecialchars($_POST["email"]);
    $password = htmlspecialchars($_POST["password"]);

    // Validate form data
    if (!empty($username) && !empty($email) && !empty($password)) {

        // Create connection
        $conn = new mysqli($servername, $dbusername, $dbpassword, $dbname);

        // Check connection
        if ($conn->connect_error) {
            die("Connection failed: " . $conn->connect_error);
        }

        // Check if username or email already exists
        $check_query = $conn->prepare("SELECT * FROM users WHERE username = ? OR email = ?");
        $check_query->bind_param("ss", $username, $email);
        $check_query->execute();
        $check_result = $check_query->get_result();

        if ($check_result->num_rows > 0) {
            $message = "Username or email already exists. Please choose a different one.";
        } else {
            // Hash the password
            $hashed_password = password_hash($password, PASSWORD_DEFAULT);

            // Prepare and execute SQL statement to insert user data into database
            $insert_query = $conn->prepare("INSERT INTO users (username, email, password) VALUES (?, ?, ?)");
            $insert_query->bind_param("sss", $username, $email, $hashed_password);
            if ($insert_query->execute()) {
                $message = "Registration successful!";
                $success = true;
            } else {
                $message = "Error: Registration failed. Please try again later.";
            }
        }

        // Close statements and connection
        $check_query->close();
        // Close only if insert_query was initialized
        if ($insert_query !== null) {
            $insert_query->close();
        }
        $conn->close();
        header("Location: login.html");
    } else {
        $message = "All fields are required.";
    }
}
?>
