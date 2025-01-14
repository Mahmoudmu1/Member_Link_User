<?php

include_once("dbconnect.php");

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get the required POST data
$user_id = $_POST['user_id'];
$membership_id = $_POST['membership_id'];
$amount = $_POST['amount']; // Ensure this is passed from the frontend

// Validate input
if (!$user_id || !$membership_id || !$amount) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Invalid input.']);
    exit();
}

// Deactivate current active membership
$sqlDeactivate = "UPDATE tbl_user_membership_status 
                  SET status = 'Inactive' 
                  WHERE user_id = '$user_id' AND status = 'Active'";

if (!$conn->query($sqlDeactivate)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Error deactivating current membership.']);
    exit();
}

// Activate the new membership
$start_date = date('Y-m-d');
$end_date = date('Y-m-d', strtotime('+1 year')); // Example: 1 year duration

$sqlActivate = "INSERT INTO tbl_user_membership_status (user_id, membership_id, start_date, end_date, status) 
                VALUES ('$user_id', '$membership_id', '$start_date', '$end_date', 'Active') 
                ON DUPLICATE KEY UPDATE 
                membership_id = '$membership_id', start_date = '$start_date', end_date = '$end_date', status = 'Active'";

if ($conn->query($sqlActivate)) {
    sendJsonResponse(['status' => 'success', 'message' => 'Membership upgraded successfully!']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Error activating new membership.']);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>