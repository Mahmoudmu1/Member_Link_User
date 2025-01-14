<?php

include_once("dbconnect.php");

$user_id = $_POST['user_id'];
$membership_id = $_POST['membership_id'];
$amount = isset($_POST['amount']) ? $_POST['amount'] : 0; // Ensure this input is sanitized

// Check if the user already has an active membership
$sqlCheckActive = "SELECT * FROM tbl_user_membership_status 
                   WHERE user_id = '$user_id' AND status = 'Active'";
$resultActive = $conn->query($sqlCheckActive);

if ($resultActive && $resultActive->num_rows > 0) {
    // Deactivate existing active memberships
    $sqlDeactivateAll = "UPDATE tbl_user_membership_status 
                         SET status = 'Inactive' 
                         WHERE user_id = '$user_id' AND status = 'Active'";
    $conn->query($sqlDeactivateAll);
}

// Prevent re-purchasing the same active membership
$sqlCheckDuplicate = "SELECT * FROM tbl_user_membership_status 
                      WHERE user_id = '$user_id' 
                      AND membership_id = '$membership_id' 
                      AND status = 'Active'";
$resultDuplicate = $conn->query($sqlCheckDuplicate);

if ($resultDuplicate && $resultDuplicate->num_rows > 0) {
    sendJsonResponse([
        'status' => 'failed',
        'message' => 'You already have this membership active. Upgrade to a higher membership.'
    ]);
    exit();
}

// Proceed with the new membership
$purchase_date = date('Y-m-d H:i:s');

// Insert into `tbl_purchases`
$sqlInsertPurchase = "INSERT INTO tbl_purchases (user_id, membership_id, payment_amount, payment_status, purchase_date)
                      VALUES ('$user_id', '$membership_id', '$amount', 'Paid', '$purchase_date')";
if (!$conn->query($sqlInsertPurchase)) {
    sendJsonResponse([
        'status' => 'failed', 
        'message' => 'Error recording purchase. Please try again.'
    ]);
    exit();
}

// Insert new active membership into `tbl_user_membership_status`
$sqlInsertStatus = "INSERT INTO tbl_user_membership_status (user_id, membership_id, start_date, end_date, status)
                    VALUES ('$user_id', '$membership_id', NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR), 'Active')";
if ($conn->query($sqlInsertStatus) === TRUE) {
    sendJsonResponse(['status' => 'success', 'message' => 'Membership successfully activated or upgraded!']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Error processing membership activation.']);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
