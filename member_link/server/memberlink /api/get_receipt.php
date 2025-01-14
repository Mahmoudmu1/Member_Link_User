<?php

include_once("dbconnect.php");

$purchase_id = $_POST['purchase_id'];

// Validate the purchase ID
if (!isset($purchase_id) || empty($purchase_id)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Invalid purchase ID.']);
    exit();
}

// Fetch purchase details
$sql = "SELECT p.purchase_id, m.name AS membership_name, p.payment_amount, p.purchase_date, p.payment_status
        FROM tbl_purchases p
        JOIN memberships m ON p.membership_id = m.membership_id
        WHERE p.purchase_id = '$purchase_id'";

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $data = $result->fetch_assoc();
    sendJsonResponse(['status' => 'success', 'data' => $data]);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'No receipt found for this purchase.']);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>
