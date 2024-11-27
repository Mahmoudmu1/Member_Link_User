-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 09, 2024 at 12:19 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `memberlink_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_admins`
--

CREATE TABLE `tbl_admins` (
  `admin_id` int(3) NOT NULL,
  `admin_fullname` varchar(100) NOT NULL,
  `admin_gender` varchar(10) NOT NULL,
  `admin_email` varchar(50) NOT NULL,
  `admin_phone` varchar(15) NOT NULL,
  `admin_pass` varchar(40) NOT NULL,
  `admin_datereg` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_admins`
--

INSERT INTO `tbl_admins` (`admin_id`, `admin_fullname`, `admin_gender`, `admin_email`, `admin_phone`, `admin_pass`, `admin_datereg`) VALUES
(1, '', '', 'slumberjer@gmail.com', '', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '2024-10-23 15:44:57.000000'),
(2, '', '', 'ahmadhanis@uum.edu.my', '', 'bec75d2e4e2acf4f4ab038144c0d862505e52d07', '2024-10-27 15:23:01.602905'),
(3, '', '', 'dasdasdasdasdasd', '', '00ea1da4192a2030f9ae023de3b3143ed647bbab', '2024-10-27 15:53:27.168759');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_news`
--

CREATE TABLE `tbl_news` (
  `news_id` int(3) NOT NULL,
  `news_title` varchar(300) NOT NULL,
  `news_details` varchar(800) NOT NULL,
  `news_date` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_news`
--

INSERT INTO `tbl_news` (`news_id`, `news_title`, `news_details`, `news_date`) VALUES
(1, 'Exclusive Member Rewards Unlocked!', 'We’re excited to announce a new rewards program exclusively for our valued members! Enjoy access to special discounts, early event registration, and a personalized dashboard to track your benefits. Log in to explore your new perks!', '2024-10-30 15:46:06.775643'),
(2, 'Exciting Updates in Your Membership!', 'Your membership app just got better! We’ve rolled out a series of updates to enhance your experience, including a redesigned profile page and streamlined access to your account history. Update the app today to check out these improvements!', '2024-10-30 15:46:32.239606'),
(3, 'New Feature Alert: Enhanced Member Dashboard', 'Keeping track of your membership benefits is now easier than ever! With our enhanced dashboard, you can view your points, redeem rewards, and get personalized offers at a glance. Log in now to explore!', '2024-10-30 15:46:51.886697'),
(4, 'Special Offer for Loyal Members!', 'Thank you for being a valued member! As a token of our appreciation, enjoy a special 15% discount on all renewals this month. Make sure to use the code MEMBER15 at checkout. Don’t miss out on this limited-time offer!', '2024-10-30 16:25:45.383816');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_admins`
--
ALTER TABLE `tbl_admins`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `admin_email` (`admin_email`);

--
-- Indexes for table `tbl_news`
--
ALTER TABLE `tbl_news`
  ADD PRIMARY KEY (`news_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_admins`
--
ALTER TABLE `tbl_admins`
  MODIFY `admin_id` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tbl_news`
--
ALTER TABLE `tbl_news`
  MODIFY `news_id` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
