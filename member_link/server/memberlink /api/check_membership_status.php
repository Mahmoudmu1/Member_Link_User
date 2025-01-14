<?php
include_once("dbconnect.php");

$user_id = $_POST['user_id'];
$membership_id = $_POST['membership_id'];

// Check if the user has an active membership
$sql = "SELECT * FROM tbl_user_membership_status 
        WHERE user_id = '$user_id' AND membership_id = '$membership_id' AND status = 'Active'";

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    sendJsonResponse(['status' => 'active', 'message' => 'Membership is already active.']);
} else {
    sendJsonResponse(['status' => 'inactive', 'message' => 'Membership is not active.']);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>