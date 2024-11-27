<?php

include_once("dbconnect.php");

$results_per_page = 10;
$searchQuery = isset($_GET['searchQuery']) ? $_GET['searchQuery'] : ''; // Get search query from frontend
if (isset($_GET['pageno'])){
    $pageno = (int)$_GET['pageno'];
}else{
    $pageno = 1;
}

$page_first_result = ($pageno - 1) * $results_per_page;

$sqlloadnews = "SELECT * FROM `tbl_news` WHERE `news_title` LIKE ? OR `news_details` LIKE ? ORDER BY `news_date` DESC";
$stmt = $conn->prepare($sqlloadnews);
$searchTerm = "%$searchQuery%";  // Wildcards for LIKE operator
$stmt->bind_param("ss", $searchTerm, $searchTerm); // Bind the search query to the prepared statement

$stmt->execute();
$result = $stmt->get_result();
$number_of_result = $result->num_rows;

$number_of_page = ceil($number_of_result / $results_per_page);
$sqlloadnews = $sqlloadnews." LIMIT $page_first_result, $results_per_page";
$stmt = $conn->prepare($sqlloadnews);
$stmt->bind_param("ss", $searchTerm, $searchTerm); // Bind again for paginated query
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $newsarray['news'] = array();
    while ($row = $result->fetch_assoc()) {
        $news = array();
        $news['news_id'] = $row['news_id'];
        $news['news_title'] = $row['news_title'];
        $news['news_details'] = $row['news_details'];
        $news['news_date'] = $row['news_date'];
        array_push($newsarray['news'], $news);
    }
    $response = array('status' => 'success', 'data' => $newsarray, 'numofpage' => $number_of_page, 'numberofresult' => $number_of_result);
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
