<?php
$servername = "localhost"; // Use "localhost" as your database host in most cPanel setups
$username   = "mhmounyc_101"; // Replace with the database user you created in cPanel
$password   = "WebFree-123"; // Replace with the password you set for the database user
$dbname     = "mhmounyc_memberlink_db"; // Replace with your cPanel database name

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 
?>
