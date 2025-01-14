<?php
// Include database connection
include_once("dbconnect.php");

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get the user_id from the request
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;

if (!$user_id) {
    die("Missing user ID.");
}

// Function to update membership status based on current date
function updateMembershipStatus($conn, $user_id) {
    // Get the current date
    $currentDate = date('Y-m-d');

    // Query to update expired memberships for the given user
    $sql = "UPDATE tbl_user_membership_status 
            SET status = 'Expired' 
            WHERE user_id = ? AND end_date < ? AND status = 'Active'";

    // Prepare statement
    $stmt = $conn->prepare($sql);
    if ($stmt) {
        // Bind the user_id and current date parameters
        $stmt->bind_param("is", $user_id, $currentDate);

        // Execute the query
        if ($stmt->execute()) {
            echo "Membership statuses updated successfully for user_id: $user_id.\n";
        } else {
            echo "Error updating membership statuses: " . $stmt->error . "\n";
        }

        // Close the statement
        $stmt->close();
    } else {
        echo "Error preparing statement: " . $conn->error . "\n";
    }
}

// Call the function to update membership statuses for the given user
updateMembershipStatus($conn, $user_id);

// Close the database connection
$conn->close();
?>