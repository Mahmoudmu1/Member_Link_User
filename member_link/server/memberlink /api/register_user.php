<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

$fullName = $_POST['full_name'];
$gender = $_POST['gender'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$password = sha1($_POST['password']);

$sqlinsert = "INSERT INTO `tbl_admins` (`admin_fullname`, `admin_gender`, `admin_email`, `admin_phone`, `admin_pass`) 
              VALUES ('$fullName', '$gender', '$email', '$phone', '$password')";

if ($conn->query($sqlinsert) === TRUE) {
	$response = array('status' => 'success', 'data' => $sqlinsert);
    sendJsonResponse($response);
}else{
	$response = array('status' => 'failed', 'data' => $sqlinsert);
	sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
