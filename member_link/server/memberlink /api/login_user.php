<?php
// Check if POST data is present
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

// Retrieve email and password from POST request
$email = $_POST['email'];
$password = sha1($_POST['password']); // Hash the password

// SQL query to validate user login
$sqllogin = "SELECT * FROM `tbl_users` WHERE `admin_email` = '$email' AND `admin_pass` = '$password'";
$result = $conn->query($sqllogin);

// Check if the user exists
if ($result->num_rows > 0) {
    $user = array();
    while ($row = $result->fetch_assoc()) {
        $user['user_id'] = $row['admin_id']; // Assuming admin_id is now user_id
        $user['user_fullname'] = $row['admin_fullname']; // Adjust field names as needed
        $user['user_email'] = $row['admin_email'];
        $user['user_gender'] = $row['admin_gender'];
        $user['user_phone'] = $row['admin_phone'];
        $user['user_datereg'] = $row['admin_datereg'];
        $user['user_role'] = $row['user_role']; // Retrieve user role
    }
    $response = array('status' => 'success', 'data' => $user);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

// Function to send JSON response
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

$conn->close();
?>
