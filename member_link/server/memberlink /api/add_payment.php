<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');

include_once("dbconnect.php");

$user_id = $_POST['user_id'];
$membership_id = $_POST['membership_id'];
$payment_amount = $_POST['payment_amount'];

$sql = "INSERT INTO payments (user_id, membership_id, payment_amount, payment_date) VALUES ('$user_id', '$membership_id', '$payment_amount', NOW())";

if ($conn->query($sql) === TRUE) {
    echo json_encode([
        "status" => "success",
        "message" => "Payment recorded successfully"
    ]);
} else {
    echo json_encode([
        "status" => "fail",
        "message" => "Payment failed: " . $conn->error
    ]);
}

$conn->close();
?>
