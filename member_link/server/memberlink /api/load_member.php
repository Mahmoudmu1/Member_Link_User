<?php
include_once("dbconnect.php");

$pageno = isset($_GET['pageno']) ? intval($_GET['pageno']) : 1;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;
$offset = ($pageno - 1) * $limit;
$search = isset($_GET['search']) ? addslashes($_GET['search']) : '';

$sqlCount = "SELECT COUNT(*) AS total FROM tbl_user WHERE user_role != 'Admin'";
if (!empty($search)) {
    $sqlCount .= " AND (user_username LIKE '%$search%' OR user_email LIKE '%$search%')";
}
$resultCount = $conn->query($sqlCount);

$totalMembers = 0;
$numofpage = 0;

if ($resultCount && $resultCount->num_rows > 0) {
    $totalMembers = $resultCount->fetch_assoc()['total'];
    $numofpage = ceil($totalMembers / $limit);
}

$sqlLoadMembers = "SELECT user_id, user_username, user_email, user_role, user_profile_image, user_ranking
                   FROM tbl_user WHERE user_role != 'Admin'";
if (!empty($search)) {
    $sqlLoadMembers .= " AND (user_username LIKE '%$search%' OR user_email LIKE '%$search%')";
}
$sqlLoadMembers .= " ORDER BY user_username ASC LIMIT $limit OFFSET $offset";

$result = $conn->query($sqlLoadMembers);

if ($result && $result->num_rows > 0) {
    $membersArray = [];
    while ($row = $result->fetch_assoc()) {
        $membersArray[] = [
            'id' => $row['user_id'],
            'name' => $row['user_username'],
            'email' => $row['user_email'],
            'role' => $row['user_role'],
            'profileImage' => $row['user_profile_image'] ?: null,
            'userranking' => $row['user_ranking'] ?: null,
        ];
    }

    sendJsonResponse([
        'status' => 'success',
        'numofpage' => $numofpage,
        'numberofresult' => $totalMembers,
        'data' => ['members' => $membersArray],
    ]);
} else {
    sendJsonResponse(['status' => 'fail', 'message' => 'No members found']);
}

function sendJsonResponse($response)
{
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>
