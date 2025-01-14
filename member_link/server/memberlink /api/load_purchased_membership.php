<?php

include_once("dbconnect.php");

// Get user_id, page number, and limit from query parameters
$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
$pageno = isset($_GET['pageno']) ? intval($_GET['pageno']) : 1;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;

// Validate user_id
if ($user_id <= 0) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Invalid user ID']);
    exit();
}

// Ensure valid values for pageno and limit
if ($pageno < 1) $pageno = 1;
if ($limit < 1) $limit = 10;

// Calculate offset
$offset = ($pageno - 1) * $limit;

// Count total purchased memberships for user
$sqlCount = "SELECT COUNT(*) AS total FROM tbl_purchases WHERE user_id = '$user_id'";
$resultCount = $conn->query($sqlCount);

$totalPurchases = 0;
$numofpage = 0;

if ($resultCount && $resultCount->num_rows > 0) {
    $totalPurchases = intval($resultCount->fetch_assoc()['total']);
    $numofpage = ceil($totalPurchases / $limit); // Calculate the number of pages
}

// Load purchased memberships with limit and offset
$sqlPurchases = "SELECT 
    p.purchase_id, 
    m.name AS membership_name, 
    p.purchase_date, 
    p.payment_amount, 
    COALESCE(ums.start_date, '-') AS start_date, 
    COALESCE(ums.end_date, '-') AS end_date, 
    ums.status AS membership_status
FROM 
    tbl_purchases p 
JOIN 
    memberships m ON p.membership_id = m.membership_id 
LEFT JOIN 
    tbl_user_membership_status ums 
ON 
    p.user_id = ums.user_id AND p.membership_id = ums.membership_id
WHERE 
    p.user_id = '$user_id'
ORDER BY 
    p.purchase_date DESC 
LIMIT $limit OFFSET $offset";

$result = $conn->query($sqlPurchases);

if ($result && $result->num_rows > 0) {
    $purchaseArray = [];
    while ($row = $result->fetch_assoc()) {
        $purchase = [
            'purchase_id' => $row['purchase_id'],
            'membership_name' => $row['membership_name'],
            'purchase_date' => $row['purchase_date'],
            'payment_amount' => $row['payment_amount'],
            'start_date' => $row['start_date'],
            'end_date' => $row['end_date'],
            'membership_status' => $row['membership_status'] ?? 'Inactive',
        ];
        array_push($purchaseArray, $purchase);
    }

    $response = [
        'status' => 'success',
        'numofpage' => $numofpage,
        'numberofresult' => $totalPurchases,
        'data' => $purchaseArray,
    ];
} else {
    $response = [
        'status' => 'success',
        'numofpage' => $numofpage,
        'numberofresult' => $totalPurchases,
        'data' => [], // Return an empty array
    ];
}

// Send JSON response
sendJsonResponse($response);

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>