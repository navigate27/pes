-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 12, 2018 at 10:59 AM
-- Server version: 10.1.26-MariaDB
-- PHP Version: 7.1.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `eff_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_downtime_id` (IN `p_reason_id` INT, IN `p_part_wire` VARCHAR(255), IN `p_part_term_front` VARCHAR(255), IN `p_part_term_rear` VARCHAR(255), IN `p_account_id` INT, IN `p_process_detail_id` INT, IN `p_dimension` VARCHAR(255), IN `p_time_start` TIME, IN `p_time_end` TIME, IN `p_time_total` INT, IN `p_mp_r1` VARCHAR(255), IN `p_mp_r3` VARCHAR(255), IN `p_batch_id` INT)  NO SQL
INSERT INTO eff_downtime 
(reason_id, part_wire, part_term_front, part_term_rear, account_id, process_detail_id, dimension, time_start, time_end, time_total, mp_r1, mp_r3, batch_id)
VALUES
(p_reason_id, p_part_wire, p_part_term_front, p_part_term_rear, p_account_id, p_process_detail_id, p_dimension, p_time_start, p_time_end, p_time_total, p_mp_r1, p_mp_r3, p_batch_id)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_manpower_count_id` (IN `p_prcs_detail_id` INT, IN `p_actual` INT, IN `p_absent` INT, IN `p_support` INT, IN `p_batch_id` INT)  NO SQL
BEGIN

DECLARE _mpc_id INT;

INSERT eff_1_manpower_count
(process_detail_id, actual, absent, support, batch_id) VALUES
(p_prcs_detail_id, p_actual, p_absent, p_support, p_batch_id);

SET _mpc_id = LAST_INSERT_ID();

INSERT eff_3_extended_wt (mpcount_id, ot_60, ot_120, ot_180, is_line) VALUES
(_mpc_id,0,0,0,1);

INSERT eff_3_extended_wt (mpcount_id, ot_60, ot_120, ot_180, is_line) VALUES
(_mpc_id,0,0,0,0);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_normal_work_id` (IN `p_batch_id` INT, IN `p_wt` INT, IN `p_wbreak` INT, IN `p_is_line` INT)  NO SQL
INSERT INTO eff_2_normal_wt (wt, wbreak, is_line, batch_id)
VALUES (p_wt, p_wbreak, p_is_line, p_batch_id)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_product_rep_id` (IN `p_batch_id` INT, IN `p_product_no` VARCHAR(255), IN `p_std_time` VARCHAR(255), IN `p_output_qty` VARCHAR(255))  NO SQL
INSERT INTO eff_product_rep
(product_no, std_time, output_qty, batch_id)  VALUES
(p_product_no, p_std_time, p_output_qty, p_batch_id)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_downtime_id` (IN `p_dt_id` INT)  NO SQL
DELETE FROM eff_downtime WHERE ID = p_dt_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_product_rep_id` (IN `p_product_id` INT)  NO SQL
DELETE FROM eff_product_rep WHERE ID = p_product_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_downtime_id` (IN `p_reason_id` INT, IN `p_part_wire` VARCHAR(255), IN `p_part_term_front` VARCHAR(255), IN `p_part_term_rear` VARCHAR(255), IN `p_account_id` INT, IN `p_process_detail_id` INT, IN `p_dimension` VARCHAR(255), IN `p_time_start` TIME, IN `p_time_end` TIME, IN `p_time_total` INT, IN `p_mp_r1` VARCHAR(255), IN `p_mp_r3` VARCHAR(255), IN `p_dt_id` INT)  NO SQL
UPDATE eff_downtime a SET a.reason_id = p_reason_id, 
a.part_wire = p_part_wire, 
a.part_term_front = p_part_term_front, 
a.part_term_rear = p_part_term_rear, 
a.account_id = p_account_id, 
a.process_detail_id = p_process_detail_id, 
a.dimension = p_dimension, 
a.time_start = p_time_start, 
a.time_end = p_time_end, 
a.time_total = p_time_total, 
a.mp_r1 = p_mp_r1, 
a.mp_r3 = p_mp_r3

WHERE a.ID = p_dt_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_extended_on_id` (IN `p_ext_id` INT, IN `p_ot_60` INT, IN `p_ot_120` INT, IN `p_ot_180` INT)  NO SQL
UPDATE eff_3_extended_wt a
SET a.ot_60 = p_ot_60,
a.ot_120 = p_ot_120,
a.ot_180 = p_ot_180
WHERE a.ID = p_ext_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_manpower_count_id` (IN `p_mpc_id` INT, IN `p_actual` INT, IN `p_absent` INT, IN `p_support` INT)  NO SQL
UPDATE eff_1_manpower_count a
SET a.actual = p_actual, 
a.absent = p_absent, a.support = p_support
WHERE a.ID = p_mpc_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_normal_work_id` (IN `p_nw_id` INT, IN `p_wt` INT)  NO SQL
UPDATE eff_2_normal_wt a
SET a.wt = p_wt
WHERE a.ID = p_nw_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_product_rep_id` (IN `p_product_id` INT, IN `p_product_no` VARCHAR(255), IN `p_std_time` VARCHAR(255), IN `p_output_qty` VARCHAR(255))  NO SQL
UPDATE eff_product_rep a 
SET a.product_no = p_product_no,
a.std_time = p_std_time,
a.output_qty = p_output_qty
WHERE a.ID = p_product_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_account` ()  NO SQL
SELECT
	a.ID,
    a.name,
    a.username,
    a.password,
    a.car_model_id,
    b.car_model_name,
    a.shift_id,
    c.shift,
    a.type,
    d.account_name
FROM eff_account a
LEFT JOIN eff_car_model b
ON a.car_model_id = b.ID
LEFT JOIN eff_shift c
ON a.shift_id = c.ID
LEFT JOIN eff_account_type d
ON a.type = d.ID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_car_model` ()  NO SQL
SELECT
	a.ID,
    a.car_model_name
FROM eff_car_model a$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_downtime_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	a.ID,
    a.reason_id,
    b.reason,
    a.part_wire,
    a.part_term_front,
    a.part_term_rear,
    a.account_id,
    c.name,
    a.process_detail_id,
    d.process_detail_name,
    a.dimension,
    a.time_start,
    a.time_end,
    (TIMESTAMPDIFF(MINUTE,a.time_start,a.time_end)) AS time_total,
    a.mp_r1,
    a.mp_r3
FROM eff_downtime a
LEFT JOIN eff_reason b
ON a.reason_id = b.ID
LEFT JOIN eff_account c
ON a.account_id = c.ID
LEFT JOIN eff_process_detail d
ON a.process_detail_id = d.ID
WHERE a.batch_id = p_batch_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_manpower_count_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	a.ID,
    a.process_detail_id,
    a.actual,
    a.absent,
    a.support,
    a.not_count,
    a.batch_id,
    b.process_detail_name,
    c.date,
    c.grp,
    c.shift_id,
    c.car_model_id,
    c.account_id,
    c.process_id,
    d.shift,
    e.car_model_name,
    f.name,
    g.process_name
FROM eff_1_manpower_count a
LEFT JOIN eff_process_detail b
ON a.process_detail_id = b.ID
LEFT JOIN eff_batch_control c
ON a.batch_id = c.ID
LEFT JOIN eff_shift d
ON c.shift_id = d.ID
LEFT JOIN eff_car_model e
ON c.car_model_id = e.ID
LEFT JOIN eff_account f
ON c.account_id = f.ID
LEFT JOIN eff_process g
ON c.process_id = g.ID
WHERE c.ID = p_batch_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_manpower_count_on_query` (IN `p_date` DATE, IN `p_group` VARCHAR(10), IN `p_shift_id` INT, IN `p_process_id` INT)  NO SQL
SELECT
	a.ID,
    a.process_detail_id,
    a.actual,
    a.absent,
    a.support,
    a.not_count,
    a.batch_id,
    b.process_detail_name,
    c.date,
    c.shift_id,
    c.car_model_id,
    c.account_id,
    c.process_id,
    d.shift,
    e.car_model_name,
    f.name,
    g.process_name
FROM eff_1_manpower_count a
LEFT JOIN eff_process_detail b
ON a.process_detail_id = b.ID
LEFT JOIN eff_batch_control c
ON a.batch_id = c.ID
LEFT JOIN eff_shift d
ON c.shift_id = d.ID
LEFT JOIN eff_car_model e
ON c.car_model_id = e.ID
LEFT JOIN eff_account f
ON c.account_id = f.ID
LEFT JOIN eff_process g
ON c.process_id = g.ID
WHERE c.date = p_date 
AND c.grp = p_group
AND c.shift_id = p_shift_id
AND c.process_id = p_process_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_normal_wt_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	a.ID,
    a.wt,
    (
    CASE 
        WHEN a.is_line = 1 THEN
        (
            SELECT
                SUM(z.actual)
            FROM eff_1_manpower_count z
            WHERE z.not_count = 0
        )
        WHEN a.is_line = 0 THEN
        (
            SELECT
                SUM(z.actual)
            FROM eff_1_manpower_count z
        )
    END
    ) AS mp,
    (a.wt * 
    (CASE 
        WHEN a.is_line = 1 THEN
        (
            SELECT
                SUM(z.actual)
            FROM eff_1_manpower_count z
            WHERE z.not_count = 0
            AND z.batch_id = p_batch_id
        )
        WHEN a.is_line = 0 THEN
        (
            SELECT
                SUM(z.actual)
            FROM eff_1_manpower_count z
            WHERE z.batch_id = p_batch_id
        )
    END)
    ) AS tm_mins,
    CONCAT(( 
        ROUND(((
            (
            SELECT 
                SUM(ROUND((z.std_time*z.output_qty),2))
            FROM eff_product_rep z
            WHERE z.batch_id = p_batch_id) /
            (a.wt * (CASE 
                WHEN a.is_line = 1 THEN
                (
                    SELECT
                        SUM(z.actual)
                    FROM eff_1_manpower_count z
                    WHERE z.not_count = 0
                    AND z.batch_id = p_batch_id
                )
                WHEN a.is_line = 0 THEN
                (
                    SELECT
                        SUM(z.actual)
                    FROM eff_1_manpower_count z
                    WHERE z.batch_id = p_batch_id
                )
            END)
        	)
        ) * 100),2)
    ),'%')
    AS efficiency,
    a.wbreak,
    a.is_line
FROM eff_2_normal_wt a
WHERE a.batch_id = p_batch_id
ORDER BY a.wbreak DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_process_detail_on_process_id` (IN `p_process_id` INT)  NO SQL
SELECT 
	a.ID,
    a.process_detail_name,
    a.process_id,
    b.process_name
FROM eff_process_detail a
LEFT JOIN eff_process b
ON a.process_id = b.ID
WHERE a.process_id = p_process_id
ORDER BY a.ID ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_product_report_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	a.ID,
    a.product_no,
    a.std_time,
    a.output_qty,
    ROUND((a.std_time*a.output_qty),2) AS output_mins,
    (
        SELECT 
     		SUM(ROUND((z.std_time*z.output_qty),2))
        FROM eff_product_rep z
        WHERE z.batch_id = p_batch_id
    ) AS total_output_mins
FROM eff_product_rep a
WHERE a.batch_id = p_batch_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_reason` ()  NO SQL
SELECT
	a.ID,
    a.reason
FROM eff_reason a$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_working_time` ()  NO SQL
SELECT
    a.ID,
    a.time,
    a.value,
    a.wbreak,
    a.wobreak
FROM eff_working_time a$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_batch_id_on_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	a.ID,
    a.date,
    a.grp,
    a.cutting_plan,
    a.cutting_start_time,
    a.cutting_end_time,
    a.shift_id,
    b.shift,
    a.car_model_id,
    d.car_model_name,
    a.account_id,
    e.name,
    a.process_id,
    c.process_name
FROM eff_batch_control a
LEFT JOIN eff_shift b
ON a.shift_id = b.ID
LEFT JOIN eff_process c
ON a.process_id = c.ID
LEFT JOIN eff_car_model d
ON a.car_model_id = d.ID
LEFT JOIN eff_account e
ON a.account_id = e.ID
WHERE a.ID = p_batch_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_batch_id_on_query` (IN `p_date` DATE, IN `p_group` VARCHAR(10), IN `p_shift_id` INT, IN `p_process_id` INT)  NO SQL
SELECT
	a.ID,
    a.date,
    a.grp,
    a.cutting_plan,
    a.cutting_start_time,
    a.cutting_end_time,
    a.shift_id,
    b.shift,
    a.car_model_id,
    d.car_model_name,
    a.account_id,
    e.name,
    a.process_id,
    c.process_name
FROM eff_batch_control a
LEFT JOIN eff_shift b
ON a.shift_id = b.ID
LEFT JOIN eff_process c
ON a.process_id = c.ID
LEFT JOIN eff_car_model d
ON a.car_model_id = d.ID
LEFT JOIN eff_account e
ON a.account_id = e.ID
WHERE a.date = p_date
AND a.grp = p_group
AND a.shift_id = p_shift_id
AND a.process_id = p_process_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_downtime_on_id` (IN `p_dt_id` INT)  NO SQL
SELECT
	a.ID,
    a.reason_id,
    b.reason,
    a.part_wire,
    a.part_term_front,
    a.part_term_rear,
    a.account_id,
    c.name,
    a.process_detail_id,
    d.process_detail_name,
    a.dimension,
    a.time_start,
    a.time_end,
    a.time_total,
    a.mp_r1,
    a.mp_r3,
    e.process_id
FROM eff_downtime a
LEFT JOIN eff_reason b
ON a.reason_id = b.ID
LEFT JOIN eff_account c
ON a.account_id = c.ID
LEFT JOIN eff_process_detail d
ON a.process_detail_id = d.ID
LEFT JOIN eff_batch_control e
ON a.batch_id = e.ID
WHERE a.ID = p_dt_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_extended_on_mpc_id` (IN `p_mpc_id` INT)  NO SQL
SELECT
	a.ID,
    a.mpcount_id,
    a.ot_60,
    a.ot_120,
    a.ot_180,
    ((a.ot_60*60)+(a.ot_120*120)+(a.ot_180*180)) AS time_man,
    a.is_line
FROM eff_3_extended_wt a
WHERE a.mpcount_id = p_mpc_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_ext_total_man_mins_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	(CASE 
    WHEN b.is_line = 1 THEN 'line'
    WHEN b.is_line = 0 THEN 'acc'
    END) AS eff_type,
	SUM((b.ot_60*60)+(b.ot_120*120)+(b.ot_180*180)) AS total_man_mins
FROM eff_1_manpower_count a
INNER JOIN eff_3_extended_wt b
ON a.ID = b.mpcount_id
WHERE a.batch_id = p_batch_id
GROUP BY b.is_line
ORDER BY b.is_line DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_manpower_actual_total_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	SUM(z.actual) AS total,
    SUM(z.absent) AS absent,
    SUM(z.support) AS support
FROM eff_1_manpower_count z
WHERE z.batch_id = p_batch_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_product_rep_on_id` (IN `p_product_id` INT)  NO SQL
SELECT
	a.ID,
    a.product_no,
    a.std_time,
    a.output_qty,
    ROUND((a.std_time*a.output_qty),2) AS output_mins
FROM eff_product_rep a
WHERE a.ID = p_product_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_product_rep_total_output_mins_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT 
	SUM(ROUND((z.std_time*z.output_qty),2)) AS total_output_mins
FROM eff_product_rep z
WHERE z.batch_id = p_batch_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_total_downtime_time_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	SUM(TIMESTAMPDIFF(MINUTE,a.time_start,a.time_end)) AS total_time
FROM eff_downtime a
WHERE a.batch_id = p_batch_id$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `eff_1_manpower_count`
--

CREATE TABLE `eff_1_manpower_count` (
  `ID` int(11) NOT NULL,
  `process_detail_id` int(11) NOT NULL,
  `actual` int(11) NOT NULL,
  `absent` int(11) NOT NULL,
  `support` int(11) NOT NULL,
  `not_count` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_1_manpower_count`
--

INSERT INTO `eff_1_manpower_count` (`ID`, `process_detail_id`, `actual`, `absent`, `support`, `not_count`, `batch_id`) VALUES
(28, 1, 15, 0, 0, 0, 1),
(29, 2, 1, 0, 0, 0, 1),
(30, 3, 5, 1, 0, 0, 1),
(31, 4, 10, 0, 0, 0, 1),
(32, 5, 2, 0, 0, 1, 1),
(33, 6, 3, 0, 0, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `eff_2_normal_wt`
--

CREATE TABLE `eff_2_normal_wt` (
  `ID` int(11) NOT NULL,
  `wt` int(11) NOT NULL,
  `manpower` int(11) NOT NULL,
  `tm_mins` int(11) NOT NULL,
  `eff_result` int(11) NOT NULL,
  `wbreak` int(11) NOT NULL,
  `is_line` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_2_normal_wt`
--

INSERT INTO `eff_2_normal_wt` (`ID`, `wt`, `manpower`, `tm_mins`, `eff_result`, `wbreak`, `is_line`, `batch_id`) VALUES
(19, 480, 0, 0, 0, 1, 1, 1),
(20, 480, 0, 0, 0, 1, 0, 1),
(21, 450, 0, 0, 0, 0, 1, 1),
(22, 450, 0, 0, 0, 0, 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `eff_3_extended_wt`
--

CREATE TABLE `eff_3_extended_wt` (
  `ID` int(11) NOT NULL,
  `mpcount_id` int(11) NOT NULL,
  `ot_60` int(11) NOT NULL,
  `ot_120` int(11) NOT NULL,
  `ot_180` int(11) NOT NULL,
  `is_line` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_3_extended_wt`
--

INSERT INTO `eff_3_extended_wt` (`ID`, `mpcount_id`, `ot_60`, `ot_120`, `ot_180`, `is_line`) VALUES
(13, 28, 5, 4, 6, 1),
(14, 28, 1, 0, 0, 0),
(15, 29, 0, 0, 0, 1),
(16, 29, 0, 0, 6, 0),
(17, 30, 0, 0, 0, 1),
(18, 30, 0, 0, 0, 0),
(19, 31, 0, 0, 0, 1),
(20, 31, 0, 0, 0, 0),
(21, 32, 0, 0, 0, 1),
(22, 32, 0, 11, 0, 0),
(23, 33, 0, 10, 0, 1),
(24, 33, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `eff_account`
--

CREATE TABLE `eff_account` (
  `ID` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `car_model_id` int(11) NOT NULL,
  `shift_id` int(11) NOT NULL,
  `dept_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `type` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_account`
--

INSERT INTO `eff_account` (`ID`, `name`, `username`, `password`, `car_model_id`, `shift_id`, `dept_id`, `section_id`, `type`) VALUES
(1, 'Barney Stinson', 'thebarney', 'legendary', 3, 1, 0, 0, 1),
(2, 'Ted Mosby', 'thearchitect', 'jedmosley', 3, 1, 0, 0, 2);

-- --------------------------------------------------------

--
-- Table structure for table `eff_account_type`
--

CREATE TABLE `eff_account_type` (
  `ID` int(11) NOT NULL,
  `account_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_account_type`
--

INSERT INTO `eff_account_type` (`ID`, `account_name`) VALUES
(1, 'PC'),
(2, 'Production');

-- --------------------------------------------------------

--
-- Table structure for table `eff_batch_control`
--

CREATE TABLE `eff_batch_control` (
  `ID` int(11) NOT NULL,
  `date` date NOT NULL,
  `grp` varchar(255) NOT NULL,
  `cutting_plan` varchar(255) NOT NULL,
  `cutting_start_time` time NOT NULL,
  `cutting_end_time` time NOT NULL,
  `shift_id` int(11) NOT NULL,
  `car_model_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `process_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_batch_control`
--

INSERT INTO `eff_batch_control` (`ID`, `date`, `grp`, `cutting_plan`, `cutting_start_time`, `cutting_end_time`, `shift_id`, `car_model_id`, `account_id`, `process_id`) VALUES
(1, '2018-02-06', 'A', '', '00:00:00', '00:00:00', 1, 3, 1, 1),
(2, '2018-02-06', 'B', '', '00:00:00', '00:00:00', 2, 3, 1, 1),
(3, '2018-02-07', 'A', '', '00:00:00', '00:00:00', 1, 3, 1, 1),
(4, '2018-02-07', 'B', '', '00:00:00', '00:00:00', 2, 3, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `eff_car_model`
--

CREATE TABLE `eff_car_model` (
  `ID` int(11) NOT NULL,
  `car_model_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_car_model`
--

INSERT INTO `eff_car_model` (`ID`, `car_model_name`) VALUES
(1, 'Daihatsu'),
(2, 'Honda'),
(3, 'Mazda J12'),
(4, 'Nissan'),
(5, 'Suzuki'),
(6, 'Toyota'),
(7, 'Mazda Merge');

-- --------------------------------------------------------

--
-- Table structure for table `eff_downtime`
--

CREATE TABLE `eff_downtime` (
  `ID` int(11) NOT NULL,
  `reason_id` int(11) NOT NULL,
  `part_wire` varchar(255) NOT NULL,
  `part_term_front` varchar(255) NOT NULL,
  `part_term_rear` varchar(255) NOT NULL,
  `account_id` int(11) NOT NULL,
  `process_detail_id` int(11) NOT NULL,
  `dimension` varchar(255) NOT NULL,
  `time_start` time NOT NULL,
  `time_end` time NOT NULL,
  `time_total` int(11) NOT NULL,
  `mp_r1` int(11) NOT NULL,
  `mp_r3` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_downtime`
--

INSERT INTO `eff_downtime` (`ID`, `reason_id`, `part_wire`, `part_term_front`, `part_term_rear`, `account_id`, `process_detail_id`, `dimension`, `time_start`, `time_end`, `time_total`, `mp_r1`, `mp_r3`, `batch_id`) VALUES
(5, 2, 'ABC', 'ZXC', 'QWE', 2, 1, '1', '09:15:00', '09:47:00', 32, 2, 2, 1),
(6, 1, '', '', '', 1, 5, '', '14:30:00', '15:00:00', 0, 0, 0, 1),
(7, 2, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, 1),
(8, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, 1),
(9, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `eff_process`
--

CREATE TABLE `eff_process` (
  `ID` int(11) NOT NULL,
  `process_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_process`
--

INSERT INTO `eff_process` (`ID`, `process_name`) VALUES
(1, 'First Process'),
(2, 'Secondary Process'),
(3, 'Final Process');

-- --------------------------------------------------------

--
-- Table structure for table `eff_process_detail`
--

CREATE TABLE `eff_process_detail` (
  `ID` int(11) NOT NULL,
  `process_detail_name` varchar(255) NOT NULL,
  `process_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_process_detail`
--

INSERT INTO `eff_process_detail` (`ID`, `process_detail_name`, `process_id`) VALUES
(1, 'TRD Operators', 1),
(2, 'Point Marking', 1),
(3, 'ZAIHAI', 1),
(4, 'QA Inspectors', 1),
(5, 'PD Jr. Staff', 1),
(6, 'QA Jr. Staff', 1);

-- --------------------------------------------------------

--
-- Table structure for table `eff_product_rep`
--

CREATE TABLE `eff_product_rep` (
  `ID` int(11) NOT NULL,
  `product_no` varchar(255) NOT NULL,
  `std_time` varchar(255) NOT NULL,
  `output_qty` varchar(255) NOT NULL,
  `output_min` varchar(255) NOT NULL,
  `batch_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_product_rep`
--

INSERT INTO `eff_product_rep` (`ID`, `product_no`, `std_time`, `output_qty`, `output_min`, `batch_id`) VALUES
(1, 'N243-67-010C(11)-6', '22.6499', '', '', 1),
(2, 'N247-67-010C(11)-6', '26.5913', '', '', 1),
(3, 'N255-67-010C(11)-6', '23.9555', '', '', 1),
(4, 'N256-67-010C(11)-6', '23.2354', '', '', 1),
(5, 'N257-67-010C(13)-4', '25.6251', '', '', 1),
(6, 'N258-67-010C(11)-6', '25.8712', '', '', 1),
(7, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 1),
(8, 'N261-67-SH0(2)-4', '0.2861', '', '', 1),
(9, 'NA1L-67-010C(14)-6', '25.3751', '', '', 1),
(10, 'NA4L-67-290B(6)', '1.7623', '20', '', 1);

-- --------------------------------------------------------

--
-- Table structure for table `eff_reason`
--

CREATE TABLE `eff_reason` (
  `ID` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_reason`
--

INSERT INTO `eff_reason` (`ID`, `reason`) VALUES
(1, 'Faulty Wire'),
(2, 'NG Operator');

-- --------------------------------------------------------

--
-- Table structure for table `eff_shift`
--

CREATE TABLE `eff_shift` (
  `ID` int(11) NOT NULL,
  `shift` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_shift`
--

INSERT INTO `eff_shift` (`ID`, `shift`) VALUES
(1, 'A'),
(2, 'B');

-- --------------------------------------------------------

--
-- Table structure for table `eff_working_time`
--

CREATE TABLE `eff_working_time` (
  `ID` int(11) NOT NULL,
  `time` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `wobreak` int(11) NOT NULL,
  `wbreak` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='for dropdown purposes don''t use in relational data';

--
-- Dumping data for table `eff_working_time`
--

INSERT INTO `eff_working_time` (`ID`, `time`, `value`, `wobreak`, `wbreak`) VALUES
(1, '5', '450-480', 450, 480),
(2, '6', '510-540', 510, 540),
(3, '7', '570-600', 570, 600),
(4, '8', '630-660', 630, 660);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `eff_1_manpower_count`
--
ALTER TABLE `eff_1_manpower_count`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `batch_id` (`batch_id`),
  ADD KEY `process_detail_id` (`process_detail_id`) USING BTREE;

--
-- Indexes for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `batch_id` (`batch_id`);

--
-- Indexes for table `eff_3_extended_wt`
--
ALTER TABLE `eff_3_extended_wt`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `mpcount_id` (`mpcount_id`);

--
-- Indexes for table `eff_account`
--
ALTER TABLE `eff_account`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `car_model_id` (`car_model_id`),
  ADD KEY `shift_id` (`shift_id`),
  ADD KEY `type` (`type`);

--
-- Indexes for table `eff_account_type`
--
ALTER TABLE `eff_account_type`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `eff_batch_control`
--
ALTER TABLE `eff_batch_control`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `car_model_id` (`car_model_id`),
  ADD KEY `shift_id` (`shift_id`),
  ADD KEY `account_id` (`account_id`),
  ADD KEY `process_id` (`process_id`);

--
-- Indexes for table `eff_car_model`
--
ALTER TABLE `eff_car_model`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `eff_downtime`
--
ALTER TABLE `eff_downtime`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `account_id` (`account_id`),
  ADD KEY `batch_id` (`batch_id`),
  ADD KEY `process_id` (`process_detail_id`),
  ADD KEY `reason_id` (`reason_id`);

--
-- Indexes for table `eff_process`
--
ALTER TABLE `eff_process`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `eff_process_detail`
--
ALTER TABLE `eff_process_detail`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `process_id` (`process_id`);

--
-- Indexes for table `eff_product_rep`
--
ALTER TABLE `eff_product_rep`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `batch_id` (`batch_id`);

--
-- Indexes for table `eff_reason`
--
ALTER TABLE `eff_reason`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `eff_shift`
--
ALTER TABLE `eff_shift`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `eff_working_time`
--
ALTER TABLE `eff_working_time`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `eff_1_manpower_count`
--
ALTER TABLE `eff_1_manpower_count`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;
--
-- AUTO_INCREMENT for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;
--
-- AUTO_INCREMENT for table `eff_3_extended_wt`
--
ALTER TABLE `eff_3_extended_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;
--
-- AUTO_INCREMENT for table `eff_account`
--
ALTER TABLE `eff_account`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `eff_account_type`
--
ALTER TABLE `eff_account_type`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `eff_batch_control`
--
ALTER TABLE `eff_batch_control`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `eff_car_model`
--
ALTER TABLE `eff_car_model`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `eff_downtime`
--
ALTER TABLE `eff_downtime`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT for table `eff_process`
--
ALTER TABLE `eff_process`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `eff_process_detail`
--
ALTER TABLE `eff_process_detail`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `eff_product_rep`
--
ALTER TABLE `eff_product_rep`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT for table `eff_reason`
--
ALTER TABLE `eff_reason`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `eff_shift`
--
ALTER TABLE `eff_shift`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `eff_working_time`
--
ALTER TABLE `eff_working_time`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `eff_1_manpower_count`
--
ALTER TABLE `eff_1_manpower_count`
  ADD CONSTRAINT `eff_1_manpower_count_ibfk_1` FOREIGN KEY (`process_detail_id`) REFERENCES `eff_process_detail` (`ID`),
  ADD CONSTRAINT `eff_1_manpower_count_ibfk_2` FOREIGN KEY (`batch_id`) REFERENCES `eff_batch_control` (`ID`);

--
-- Constraints for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  ADD CONSTRAINT `eff_2_normal_wt_ibfk_2` FOREIGN KEY (`batch_id`) REFERENCES `eff_batch_control` (`ID`);

--
-- Constraints for table `eff_3_extended_wt`
--
ALTER TABLE `eff_3_extended_wt`
  ADD CONSTRAINT `eff_3_extended_wt_ibfk_1` FOREIGN KEY (`mpcount_id`) REFERENCES `eff_1_manpower_count` (`ID`);

--
-- Constraints for table `eff_account`
--
ALTER TABLE `eff_account`
  ADD CONSTRAINT `eff_account_ibfk_1` FOREIGN KEY (`car_model_id`) REFERENCES `eff_car_model` (`ID`),
  ADD CONSTRAINT `eff_account_ibfk_2` FOREIGN KEY (`shift_id`) REFERENCES `eff_shift` (`ID`),
  ADD CONSTRAINT `eff_account_ibfk_3` FOREIGN KEY (`type`) REFERENCES `eff_account_type` (`ID`);

--
-- Constraints for table `eff_batch_control`
--
ALTER TABLE `eff_batch_control`
  ADD CONSTRAINT `eff_batch_control_ibfk_1` FOREIGN KEY (`car_model_id`) REFERENCES `eff_car_model` (`ID`),
  ADD CONSTRAINT `eff_batch_control_ibfk_2` FOREIGN KEY (`shift_id`) REFERENCES `eff_shift` (`ID`),
  ADD CONSTRAINT `eff_batch_control_ibfk_3` FOREIGN KEY (`account_id`) REFERENCES `eff_account` (`ID`),
  ADD CONSTRAINT `eff_batch_control_ibfk_4` FOREIGN KEY (`process_id`) REFERENCES `eff_process` (`ID`);

--
-- Constraints for table `eff_downtime`
--
ALTER TABLE `eff_downtime`
  ADD CONSTRAINT `eff_downtime_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `eff_account` (`ID`),
  ADD CONSTRAINT `eff_downtime_ibfk_2` FOREIGN KEY (`batch_id`) REFERENCES `eff_batch_control` (`ID`),
  ADD CONSTRAINT `eff_downtime_ibfk_3` FOREIGN KEY (`process_detail_id`) REFERENCES `eff_process_detail` (`ID`),
  ADD CONSTRAINT `eff_downtime_ibfk_4` FOREIGN KEY (`reason_id`) REFERENCES `eff_reason` (`ID`);

--
-- Constraints for table `eff_process_detail`
--
ALTER TABLE `eff_process_detail`
  ADD CONSTRAINT `eff_process_detail_ibfk_1` FOREIGN KEY (`process_id`) REFERENCES `eff_process` (`ID`);

--
-- Constraints for table `eff_product_rep`
--
ALTER TABLE `eff_product_rep`
  ADD CONSTRAINT `eff_product_rep_ibfk_1` FOREIGN KEY (`batch_id`) REFERENCES `eff_batch_control` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
