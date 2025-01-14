<?php

error_reporting(E_ALL);

ini_set('display_errors', 1);

 

header("Content-Type: application/json");

 

include_once("dbconnect.php");

 

// Fetch required inputs

$user_id = $_GET['userid'] ?? null;

$amount = $_GET['amount'] ?? null;

$checkout_type = $_GET['checkout_type'] ?? null;

 

// Log incoming data for debugging

error_log("Received User ID (admin_id): " . $user_id);

error_log("Received Amount: " . $amount);

error_log("Received Checkout Type: " . $checkout_type);

 

// Validate required inputs

if (!$user_id || !$amount || !$checkout_type) {

error_log("Missing required inputs.");

echo json_encode(["status" => "error", "message" => "Invalid input."]);

exit();

}

 

// Fetch user details

$sql = "SELECT admin_email, admin_phone, admin_fullname FROM tbl_users WHERE admin_id = '$user_id'";

$result = $conn->query($sql);

 

if (!$result || $result->num_rows == 0) {

error_log("User not found for admin_id: $user_id");

echo json_encode(["status" => "error", "message" => "User not found."]);

exit();

}

 

$user = $result->fetch_assoc();

$email = $user['admin_email'];

$phone = $user['admin_phone'];

$name = $user['admin_fullname'];

 

// Validate email and phone

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {

error_log("Invalid email address: $email");

echo json_encode(["status" => "error", "message" => "Invalid email address."]);

exit();

}

if (!preg_match('/^\+?6?01[0-46-9]-*[0-9]{7,8}$/', $phone)) {

error_log("Invalid phone number: $phone");

echo json_encode(["status" => "error", "message" => "Invalid phone number."]);

exit();

}

 

// Prepare dynamic description and validate checkout type

$description = "Payment by $name";

$membership_id = null;

 

if ($checkout_type === 'membership') {

$membership_id = $_GET['membership_id'] ?? null;

error_log("Received Membership ID: " . $membership_id);

 

if (!$membership_id || !is_numeric($membership_id)) {

error_log("Missing or invalid Membership ID.");

echo json_encode(["status" => "error", "message" => "Missing or invalid membership ID."]);

exit();

}

$description = "Membership Subscription for $name";

} elseif ($checkout_type === 'product') {

$description = "Product Purchase by $name";

} else {

error_log("Invalid checkout type: $checkout_type");

echo json_encode(["status" => "error", "message" => "Invalid checkout type."]);

exit();

}

 

// Insert payment record into the database

$sqlInsertPayment = "INSERT INTO tbl_payments (user_id, email, phone, name, amount, membership_id, checkout_type, status, payment_date)

VALUES ('$user_id', '$email', '$phone', '$name', '$amount', " . ($membership_id ? "'$membership_id'" : "NULL") . ", '$checkout_type', 'Pending', NOW())";

 

if (!$conn->query($sqlInsertPayment)) {

error_log("Error inserting payment record: " . $conn->error);

echo json_encode(["status" => "error", "message" => "Error inserting payment record: " . $conn->error]);

exit();

}

error_log("Payment record inserted successfully.");

 

// Prepare redirect URL

$redirectUrl = "https://mhmoudmu.com/memberlink/api/payment_update.php?" . http_build_query([

'userid' => $user_id,

'amount' => $amount,

'checkout_type' => $checkout_type,

'membership_id' => $membership_id,

]);

 

// Prepare Billplz API call

$data = [

'collection_id' => 'txbkqpm_',

'email' => $email,

'mobile' => $phone,

'name' => $name,

'amount' => $amount * 100,

'callback_url' => "https://mhmoudmu.com/return_url",

'redirect_url' => $redirectUrl,

'description' => $description,

];

 

$ch = curl_init("https://www.billplz-sandbox.com/api/v3/bills");

curl_setopt($ch, CURLOPT_USERPWD, '9a37ff55-5880-4874-a6cb-54e250c7aa8a:');

curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));

curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);

curl_close($ch);

 

// Decode response

$bill = json_decode($response, true);

 

// Prepare response

if (isset($bill['url'])) {

$paymentUrl = filter_var($bill['url'], FILTER_SANITIZE_URL);

if (filter_var($paymentUrl, FILTER_VALIDATE_URL)) {

echo json_encode(["status" => "success", "payment_url" => $paymentUrl]);

} else {

echo json_encode(["status" => "error", "message" => "Invalid payment URL generated."]);

}

} else {

echo json_encode(["status" => "error", "message" => "Failed to create Billplz bill."]);

}

exit;

?>