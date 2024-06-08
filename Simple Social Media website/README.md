# Simple Social Media Application

Welcome to the Facebootleg!

## Introduction

This is a simple social media application built with PHP and MySQL. It allows users to register, log in, post updates, and view posts from other users.

## Features

- User registration and login
- Post creation and display

## Installation and accessing the application

1. **Clone the repository:**
   ```bash
   git clone https://github.com/
   ```
    For your convenient, this guide used XAMPP to host the application, just put this folder under `xampp/htdocs`.

2. **Configure the database connection:**
   Change the `connection.php` to the credentials of your database connection:
   ```php
    <?php
    $servername = "localhost";
    $dbusername = "yourusername";
    $dbpassword = "yourpassword";
    $dbname = "yourdatabase";
    ?>
   ```

3. **Register and log in:**
   Create a new user account and log in to start posting updates.

## Folder Structure

- **scripts/**: JavaScript file
- **uploads/**: holds the uploaded image or gif files
- **connection.php**: Hold database connection credentials
- **feed.php**: Hold collect and display feed from database
- **handle_\*.php**: Handle many of the logic of the application (i.e., comments, deletes, likes)
- **index.php**: Main landing page
- **login.php**: User login page
- **register.php**: User registration page
