<?php
// Include the database configuration file
require_once 'config.php';

// Check if the request method is POST
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Get the POST data
    $email = $_POST['email'];
    $password = $_POST['password'];

    // Initialize an array to hold validation errors
    $errors = [];

    // Validate email
    if (empty($email)) {
        $errors[] = "Email is required.";
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = "Invalid email format.";
    }

    // Validate password
    if (empty($password)) {
        $errors[] = "Password is required.";
    }

    // Check if there are any errors
    if (empty($errors)) {
        // Hash the password
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);

        // Insert data into the database
        $sql = "INSERT INTO sign_up (email, password) VALUES (:email, :password)";
        $stmt = $connection->prepare($sql);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':password', $hashed_password);
        
        // Execute the statement
        $status = $stmt->execute();

        // Check if the insert was successful
        if ($status) {
            echo json_encode(["success" => true, "message" => "Sign-up successful!"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to sign up."]);
        }
    } else {
        // Return validation errors
        echo json_encode(["success" => false, "errors" => $errors]);
    }
} else {
    // Return an error message if it's not a POST request
    echo json_encode(["success" => false, "message" => "Invalid request method."]);
}
