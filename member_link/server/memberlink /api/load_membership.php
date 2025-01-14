<?php
include_once("dbconnect.php");

$pageno = isset($_GET['pageno']) ? intval($_GET['pageno']) : 1;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;
$offset = ($pageno - 1) * $limit;

// Count total memberships
$sqlCount = "SELECT COUNT(*) AS total FROM tbl_memberships";
$resultCount = $conn->query($sqlCount);

$totalMemberships = 0;
$numofpage = 0;

if ($resultCount && $resultCount->num_rows > 0) {
    $totalMemberships = intval($resultCount->fetch_assoc()['total']);
    $numofpage = ceil($totalMemberships / $limit);
}

// Fetch memberships
$sqlLoadMemberships = "SELECT * FROM memberships ORDER BY membership_id ASC LIMIT $limit OFFSET $offset";

$result = $conn->query($sqlLoadMemberships);

if ($result && $result->num_rows > 0) {
    $membershipArray = [];
    while ($row = $result->fetch_assoc()) {
        $membershipArray[] = [
            'membership_id' => $row['membership_id'],
            'name' => $row['name'],
            'description' => $row['description'],
            'price' => $row['price'],
            'duration' => $row['duration'],
            'benefits' => $row['benefits'],
            'terms' => $row['terms'],
            'membership_filename' => $row['membership_filename'],
            'membership_sold' => $row['membership_sold'],
            'membership_rating' => $row['membership_rating'],
        ];
    }

    sendJsonResponse([
        'status' => 'success',
        'numofpage' => $numofpage,
        'numberofresult' => $totalMemberships,
        'data' => $membershipArray,
    ]);
} else {
    sendJsonResponse([
        'status' => 'failed',
        'numofpage' => $numofpage,
        'numberofresult' => $totalMemberships,
        'data' => null,
    ]);
}

function sendJsonResponse($response)
{
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>
