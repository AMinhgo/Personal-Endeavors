# Simple Social Media Application

Welcome to the Facebootleg!

## Introduction

This is a simple social media application built with PHP and MySQL. It allows users to register, log in, post updates, and view posts from other users.

## Features

- User registration and login
- Post creation and display

## Installation and accessing the application

1. **Using this application:**
   You can either clone this whole repository or just download this particular folder.
   Cloning repository
   ```bash
   git clone https://github.com/AMinhgo/Personal-Endeavors.git
   ```
   Download this folder
   Click [here](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2FAMinhgo%2FPersonal-Endeavors%2Ftree%2Fmain%2FSimple%2520Social%2520Media%2520website)

>[!Note]
>For your convenient, this guide used XAMPP to host the application, just put this folder under `xampp/htdocs`.

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
