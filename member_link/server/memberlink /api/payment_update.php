<?php
include_once("dbconnect.php");

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Fetch required parameters
$userid = $_GET['userid'] ?? null;
$amount = $_GET['amount'] ?? null;
$checkout_type = $_GET['checkout_type'] ?? null;
$membership_id = $_GET['membership_id'] ?? null;

// Log incoming parameters for debugging
error_log("Received User ID: " . $userid);
error_log("Received Amount: " . $amount);
error_log("Received Checkout Type: " . $checkout_type);
error_log("Received Membership ID: " . $membership_id);

// Fetch Billplz response parameters
$billplz_id = $_GET['billplz']['id'] ?? null;
$billplz_paid = $_GET['billplz']['paid'] ?? null;
$billplz_paid_at = $_GET['billplz']['paid_at'] ?? null;

// Validate essential inputs
if (!$userid || !$amount || !$billplz_id || !$billplz_paid) {
    header("Location: https://yourdomain.com/payment_failed");
    exit();
}

// Log Billplz parameters for debugging
error_log("Billplz ID: " . $billplz_id);
error_log("Billplz Paid: " . $billplz_paid);

// Begin transaction
$conn->begin_transaction();

try {
    // Check for duplicate payment
    $sqlCheckPayment = "SELECT COUNT(*) AS count FROM tbl_payments WHERE user_id = '$userid' AND membership_id = '$membership_id' AND receipt_id = '$billplz_id'";
    $resultCheckPayment = $conn->query($sqlCheckPayment);

    if ($resultCheckPayment) {
        $row = $resultCheckPayment->fetch_assoc();
        if ($row['count'] > 0) {
            error_log("Duplicate payment entry detected. Skipping update.");
            $conn->rollback();
            header("Location: https://yourdomain.com/payment_failed");
            exit();
        }
    } else {
        error_log("Error checking for duplicate payment: " . $conn->error);
        $conn->rollback();
        header("Location: https://yourdomain.com/payment_failed");
        exit();
    }

    // Update payment record
    $paidstatus = $billplz_paid === "true" ? "Success" : "Failed";
    $sqlUpdatePayment = "UPDATE tbl_payments
                         SET status = '$paidstatus', receipt_id = '$billplz_id', payment_date = NOW()
                         WHERE user_id = '$userid' AND membership_id = '$membership_id' AND status = 'Pending'";
    if (!$conn->query($sqlUpdatePayment)) {
        error_log("Error updating payment record: " . $conn->error);
        $conn->rollback();
        header("Location: https://yourdomain.com/payment_failed");
        exit();
    }
    error_log("Payment record updated successfully for User ID: $userid, Status: $paidstatus, Receipt ID: $billplz_id");

    // Insert membership status for successful payments
    if ($checkout_type === 'membership' && $membership_id && $paidstatus === "Success") {
        $currentDate = date('Y-m-d');
        $sqlGetMembership = "SELECT duration FROM memberships WHERE membership_id = $membership_id";

        $result = $conn->query($sqlGetMembership);
        if ($result && $result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $duration = $row['duration'];

            $startDate = $currentDate;
            $endDate = date('Y-m-d', strtotime("+$duration days"));

            $sqlInsertMembership = "INSERT INTO tbl_user_membership_status (user_id, membership_id, start_date, end_date, status)
                                     VALUES ('$userid', '$membership_id', '$startDate', '$endDate', 'Active')";
            if (!$conn->query($sqlInsertMembership)) {
                error_log("Error inserting membership status: " . $conn->error);
                $conn->rollback();
                header("Location: https://yourdomain.com/payment_failed");
                exit();
            }
            error_log("Membership status updated for User ID: $userid, Membership ID: $membership_id");
        } else {
            error_log("Membership duration not found for Membership ID: $membership_id");
            $conn->rollback();
            header("Location: https://yourdomain.com/payment_failed");
            exit();
        }
    }

    // Insert purchase record
    if ($paidstatus === "Success") {
        $sqlInsertPurchase = "INSERT INTO tbl_purchases (user_id, payment_amount, payment_status, purchase_date, membership_id)
                              VALUES ('$userid', '$amount', '$paidstatus', NOW(), " . ($membership_id ? "'$membership_id'" : "NULL") . ")";
        if (!$conn->query($sqlInsertPurchase)) {
            error_log("Error inserting purchase record: " . $conn->error);
            $conn->rollback();
            header("Location: https://yourdomain.com/payment_failed");
            exit();
        }
        error_log("Purchase record inserted successfully for User ID: $userid, Membership ID: $membership_id");
    }

    // Commit transaction
    $conn->commit();
} catch (Exception $e) {
    $conn->rollback();
    error_log("Transaction failed: " . $e->getMessage());
    header("Location: https://yourdomain.com/payment_failed");
    exit();
}

// Redirect to the appropriate URL based on payment status
if ($paidstatus === "Success") {
    header("Location: https://yourdomain.com/payment_success");
} else {
    header("Location: https://yourdomain.com/payment_failed");
}
exit();
?>
