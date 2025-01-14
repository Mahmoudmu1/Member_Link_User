<?php
include_once("dbconnect.php");

$userid = $_POST['userid'];
$membership_id = $_POST['membership_id'];
$amount = $_POST['amount'];
$checkout_type = $_POST['checkout_type'];
$payment_status = "Failed"; // Default status
$receipt_id = uniqid();
$payment_date = date("Y-m-d H:i:s");

// Simulate payment processing logic
$payment_success = rand(0, 1); // Randomize success or failure for testing
if ($payment_success) {
    $payment_status = "Success";
}

// Insert into tbl_purchases
$sql = "INSERT INTO tbl_purchases (user_id, membership_id, payment_amount, payment_status, purchase_date) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("iidss", $userid, $membership_id, $amount, $payment_status, $payment_date);
$stmt->execute();

// If payment is successful, update membership status
if ($payment_status === "Success") {
    // Check if the user already has an active membership
    $check_sql = "SELECT * FROM tbl_user_membership_status WHERE user_id = ? AND membership_id = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bind_param("ii", $userid, $membership_id);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();

    if ($check_result->num_rows > 0) {
        // Update existing membership status
        $update_sql = "UPDATE tbl_user_membership_status SET status = 'Active', start_date = ?, end_date = ? WHERE user_id = ? AND membership_id = ?";
        $start_date = $payment_date;
        $end_date = date("Y-m-d H:i:s", strtotime("+30 days"));
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bind_param("ssii", $start_date, $end_date, $userid, $membership_id);
        $update_stmt->execute();
    } else {
        // Insert new membership status
        $insert_sql = "INSERT INTO tbl_user_membership_status (user_id, membership_id, start_date, end_date, status) VALUES (?, ?, ?, ?, 'Active')";
        $start_date = $payment_date;
        $end_date = date("Y-m-d H:i:s", strtotime("+30 days"));
        $insert_stmt = $conn->prepare($insert_sql);
        $insert_stmt->bind_param("iiss", $userid, $membership_id, $start_date, $end_date);
        $insert_stmt->execute();
    }

    // Log success in tbl_purchases
    $log_sql = "UPDATE tbl_purchases SET payment_status = 'Success' WHERE user_id = ? AND membership_id = ? AND payment_status = 'Failed'";
    $log_stmt = $conn->prepare($log_sql);
    $log_stmt->bind_param("ii", $userid, $membership_id);
    $log_stmt->execute();
    $log_stmt->close();
}

$response = ["status" => $payment_status, "receipt_id" => $receipt_id, "payment_date" => $payment_date];

$stmt->close();
$conn->close();

echo json_encode($response);
