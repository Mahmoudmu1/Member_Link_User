<?php
// Load Products Script
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include_once("dbconnect.php");

$results_per_page = 20;
if (isset($_GET['pageno'])){
	$pageno = (int)$_GET['pageno'];
}else{
	$pageno = 1;
}

$page_first_result = ($pageno - 1) * $results_per_page;

$sqlloadproducts = "SELECT * FROM tbl_products ORDER BY product_id DESC";
$result = $conn->query($sqlloadproducts);

if (!$result) {
    die("Query failed: " . $conn->error);
}

$number_of_result = $result->num_rows;
$number_of_page = ceil($number_of_result / $results_per_page);
$sqlloadproducts = $sqlloadproducts . " LIMIT $page_first_result, $results_per_page";

$result = $conn->query($sqlloadproducts);
if ($result->num_rows > 0) {
    $productsarray['products'] = array();
    while ($row = $result->fetch_assoc()) {
        $product = array();
        $product['product_id'] = $row['product_id'];
        $product['name'] = $row['name'];
        $product['description'] = $row['description'];
        $product['quantity'] = $row['quantity'];
        $product['price'] = $row['price'];
        $product['image'] = $row['image'];
        array_push($productsarray['products'], $product);
    }
    $response = array('status' => 'success', 'data' => $productsarray, 'numofpage' => $number_of_page, 'numberofresult' => $number_of_result);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null, 'numofpage' => $number_of_page, 'numberofresult' => $number_of_result);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>