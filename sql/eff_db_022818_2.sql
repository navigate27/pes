-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 28, 2018 at 10:15 AM
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_batch_id_and_product_no` (IN `p_date` DATE, IN `p_shift_id` INT, IN `p_car_model_id` INT, IN `p_account_id` INT, IN `p_process_id` INT, IN `p_product_no` VARCHAR(255), IN `p_std_time` VARCHAR(255), IN `p_output_qty` VARCHAR(255))  NO SQL
BEGIN

DECLARE _batch_id INT;

INSERT INTO eff_batch_control (`date`,shift_id,car_model_id,account_id,process_id)
VALUES
(p_date, p_shift_id, p_car_model_id, p_account_id, p_process_id);

SET _batch_id = LAST_INSERT_ID();

INSERT INTO eff_product_rep 
(product_no, std_time, output_qty, batch_id)
VALUES
(p_product_no, p_std_time, p_output_qty, _batch_id);

SELECT _batch_id AS batch_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_downtime_id` (IN `p_reason_id` INT, IN `p_part_wire` VARCHAR(255), IN `p_part_term_front` VARCHAR(255), IN `p_part_term_rear` VARCHAR(255), IN `p_account_id` INT, IN `p_process_detail_id` INT, IN `p_dimension` VARCHAR(255), IN `p_time_start` TIME, IN `p_time_end` TIME, IN `p_time_total` INT, IN `p_mp_r1` VARCHAR(255), IN `p_mp_r3` VARCHAR(255), IN `p_batch_id` INT)  NO SQL
INSERT INTO eff_downtime 
(reason_id, part_wire, part_term_front, part_term_rear, account_id, process_detail_id, dimension, time_start, time_end, time_total, mp_r1, mp_r3, batch_id)
VALUES
(p_reason_id, p_part_wire, p_part_term_front, p_part_term_rear, p_account_id, p_process_detail_id, p_dimension, p_time_start, p_time_end, p_time_total, p_mp_r1, p_mp_r3, p_batch_id)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_manpower_count_id` (IN `p_prcs_detail_id` INT, IN `p_actual` INT, IN `p_absent` INT, IN `p_support` INT, IN `p_batch_id` INT)  NO SQL
BEGIN

DECLARE _mpc_id INT;

DECLARE _is_count VARCHAR(10);

SET _is_count = (
    SELECT a.not_count
    FROM eff_process_detail a
    WHERE a.ID = p_prcs_detail_id
);

INSERT eff_1_manpower_count
(process_detail_id, actual, absent, support, batch_id, not_count) VALUES
(p_prcs_detail_id, p_actual, p_absent, p_support, p_batch_id, _is_count);

SET _mpc_id = LAST_INSERT_ID();

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_batch_target_eff` (IN `p_batch_id` INT, IN `p_target_eff` VARCHAR(255))  NO SQL
BEGIN

DECLARE _date VARCHAR(255);

SET _date = (
    SELECT
    	a.date
    FROM eff_batch_control a
    WHERE a.ID = p_batch_id
);

UPDATE eff_batch_control a
SET a.target_eff = p_target_eff
WHERE a.date = _date;

END$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_account_login` (IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255))  NO SQL
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
ON a.type = d.ID
WHERE a.username = p_username
AND a.password = p_password$$

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
            AND z.batch_id = p_batch_id
        )
        WHEN a.is_line = 0 THEN
        (
            SELECT
                SUM(z.actual)
            FROM eff_1_manpower_count z
            WHERE z.batch_id = p_batch_id
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
     		SUM(z.output_qty)
        FROM eff_product_rep z
        WHERE z.batch_id = p_batch_id
    ) AS total_output,
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_shift` ()  NO SQL
SELECT
	a.ID,
    a.shift
FROM eff_shift a
ORDER BY a.ID ASC$$

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
    a.target_eff,
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_batch_id_on_query` (IN `p_date` DATE, IN `p_car_model_id` INT, IN `p_shift_id` INT, IN `p_process_id` INT)  NO SQL
SELECT
	a.ID,
    a.date,
    a.grp,
    a.cutting_plan,
    a.cutting_start_time,
    a.cutting_end_time,
    a.shift_id,
    a.target_eff,
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
AND a.shift_id = p_shift_id
AND a.process_id = p_process_id
AND a.car_model_id = p_car_model_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_car_model_id` (IN `p_car_model_id` INT)  NO SQL
SELECT
	a.ID,
    a.car_model_name
FROM eff_car_model a
WHERE a.ID = p_car_model_id$$

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
    a.is_line,
	c.process_detail_name
FROM eff_3_extended_wt a
INNER JOIN eff_1_manpower_count b
ON a.mpcount_id = b.ID
LEFT JOIN eff_process_detail c
ON b.process_detail_id = c.ID
WHERE a.mpcount_id = p_mpc_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_ext_id_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	b.ID,
    c.process_detail_name,
    b.ot_60,
    b.ot_120,
    b.ot_180,
    ((b.ot_60*60)+(b.ot_120*120)+(b.ot_180*180)) AS time_man,
    a.not_count
FROM eff_1_manpower_count a
INNER JOIN eff_3_extended_wt b
ON a.ID = b.mpcount_id
LEFT JOIN eff_process_detail c
ON a.process_detail_id = c.ID
WHERE a.batch_id = p_batch_id$$

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
	SUM(z.output_qty) AS total_output,
	SUM(ROUND((z.std_time*z.output_qty),2)) AS total_output_mins
FROM eff_product_rep z
WHERE z.batch_id = p_batch_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_001_A` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'DAILY PLAN [shift A]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time)*SUM(b.output_qty)) AS output_mm_total
    FROM eff_batch_control a
    LEFT JOIN eff_product_rep b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    AND a.shift_id = 1
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time)*SUM(b.output_qty)) AS output_mm_total
    FROM eff_batch_control a
    LEFT JOIN eff_product_rep b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    AND a.shift_id = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
    
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_001_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'DAILY PLAN [shift A, shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time)*SUM(b.output_qty)) AS output_mm_total
    FROM eff_batch_control a
    LEFT JOIN eff_product_rep b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time)*SUM(b.output_qty)) AS output_mm_total
    FROM eff_batch_control a
    LEFT JOIN eff_product_rep b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_001_B` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'DAILY PLAN [shift B]'
BEGIN

IF p_car_model_id = 0 THEN
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time)*SUM(b.output_qty)) AS output_mm_total
    FROM eff_batch_control a
    LEFT JOIN eff_product_rep b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    AND a.shift_id = 2
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time)*SUM(b.output_qty)) AS output_mm_total
    FROM eff_batch_control a
    LEFT JOIN eff_product_rep b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    AND a.shift_id = 2
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_002_acctg_A` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'MANPOWER [actual,absent,support] [shift A]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            SUM(c.ot_60) +
            SUM(c.ot_120) +
            SUM(c.ot_180)
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    INNER JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            SUM(c.ot_60) +
            SUM(c.ot_120) +
            SUM(c.ot_180)
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    INNER JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_002_acctg_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'MANPOWER [actual,absent,support] [shift A,shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            (
                SELECT 
                    SUM(x.ot_60)+SUM(x.ot_120)+SUM(x.ot_180)
                FROM eff_batch_control z
                LEFT JOIN eff_1_manpower_count y
                ON z.ID = y.batch_id
                LEFT JOIN eff_3_extended_wt x
                ON y.ID = x.mpcount_id
                WHERE z.date = a.date
            )
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            (
                SELECT 
                    SUM(x.ot_60)+SUM(x.ot_120)+SUM(x.ot_180)
                FROM eff_batch_control z
                LEFT JOIN eff_1_manpower_count y
                ON z.ID = y.batch_id
                LEFT JOIN eff_3_extended_wt x
                ON y.ID = x.mpcount_id
                WHERE z.date = a.date
            )
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_002_acctg_B` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'MANPOWER [actual,absent,support] [shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            SUM(c.ot_60) +
            SUM(c.ot_120) +
            SUM(c.ot_180)
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    LEFT JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            SUM(c.ot_60) +
            SUM(c.ot_120) +
            SUM(c.ot_180)
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    LEFT JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_002_line_A` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'MANPOWER [actual,absent,support] [shift A]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            SUM(c.ot_60) +
            SUM(c.ot_120) +
            SUM(c.ot_180)
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    LEFT JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    LEFT JOIN eff_process_detail d
    ON b.process_detail_id = d.ID
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.not_count = 0
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            SUM(c.ot_60) +
            SUM(c.ot_120) +
            SUM(c.ot_180)
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    LEFT JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    LEFT JOIN eff_process_detail d
    ON b.process_detail_id = d.ID
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.not_count = 0
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_002_line_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'MANPOWER [actual,absent,support] [shift A,shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            (
                SELECT 
                    SUM(x.ot_60)+SUM(x.ot_120)+SUM(x.ot_180)
                FROM eff_batch_control z
                LEFT JOIN eff_1_manpower_count y
                ON z.ID = y.batch_id
                LEFT JOIN eff_3_extended_wt x
                ON y.ID = x.mpcount_id
                WHERE z.date = a.date
                AND y.not_count = 0
            )
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    LEFT JOIN eff_process_detail d
    ON b.process_detail_id = d.ID
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.not_count = 0
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            (
                SELECT 
                    SUM(x.ot_60)+SUM(x.ot_120)+SUM(x.ot_180)
                FROM eff_batch_control z
                LEFT JOIN eff_1_manpower_count y
                ON z.ID = y.batch_id
                LEFT JOIN eff_3_extended_wt x
                ON y.ID = x.mpcount_id
                WHERE z.date = a.date
                AND y.not_count = 0
            )
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    LEFT JOIN eff_process_detail d
    ON b.process_detail_id = d.ID
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.not_count = 0
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_002_line_B` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'MANPOWER [actual,absent,support] [shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            SUM(c.ot_60) +
            SUM(c.ot_120) +
            SUM(c.ot_180)
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    LEFT JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id AND c.is_line = 1
    LEFT JOIN eff_process_detail d
    ON b.process_detail_id = d.ID
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.not_count = 0
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.actual) AS actual_total,
        SUM(b.support) AS support_total,
        SUM(b.absent) AS absent_total,
        (SUM(b.actual)+SUM(b.support)) AS manpower_total,
        (
            SUM(b.actual) +
            SUM(c.ot_60) +
            SUM(c.ot_120) +
            SUM(c.ot_180)
        ) AS actual_wot_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    LEFT JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id AND c.is_line = 1
    LEFT JOIN eff_process_detail d
    ON b.process_detail_id = d.ID
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.not_count = 0
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wbreak_acctg_A` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 1, is_line = 0, shift A]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 1
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.wbreak = 1
    AND b.is_line = 0
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 1
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.wbreak = 1
    AND b.is_line = 0
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wbreak_acctg_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 1, is_line = 0, shift A, shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.wbreak = 1
    AND b.is_line = 0
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.wbreak = 1
    AND b.is_line = 0
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wbreak_acctg_B` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 1, is_line = 0, shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 2
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.wbreak = 1
    AND b.is_line = 0
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 2
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.wbreak = 1
    AND b.is_line = 0
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wbreak_line_A` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 1, is_line = 1, shift A]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 1
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.wbreak = 1
    AND b.is_line = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 1
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.wbreak = 1
    AND b.is_line = 1
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wbreak_line_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 1, is_line = 1, shift A, shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.wbreak = 1
    AND b.is_line = 1
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.wbreak = 1
    AND b.is_line = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wbreak_line_B` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE)  NO SQL
    COMMENT 'efficiency [wbreak = 1, is_line = 1, shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 2
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.wbreak = 1
    AND b.is_line = 1
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 2
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.wbreak = 1
    AND b.is_line = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wobreak_acctg_A` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 0, is_line = 0, shift A]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 1
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.wbreak = 0
    AND b.is_line = 0
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 1
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.wbreak = 0
    AND b.is_line = 0
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wobreak_acctg_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 0, is_line = 0, shift A, shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.wbreak = 0
    AND b.is_line = 0
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.wbreak = 0
    AND b.is_line = 0
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wobreak_acctg_B` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 0, is_line = 0, shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 2
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.wbreak = 0
    AND b.is_line = 0
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 2
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.wbreak = 0
    AND b.is_line = 0
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wobreak_line_A` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 0, is_line = 1, shift A]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 1
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.wbreak = 0
    AND b.is_line = 1
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 1
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 1
    AND b.wbreak = 0
    AND b.is_line = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wobreak_line_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 0, is_line = 1, shift A, shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.wbreak = 0
    AND b.is_line = 1
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.wbreak = 0
    AND b.is_line = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_003_wobreak_line_B` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 0, is_line = 1, shift B]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 2
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.wbreak = 0
    AND b.is_line = 1
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.wt) AS wt_total,
        (
            SELECT
                SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE (z.date BETWEEN p_date_start AND p_date_end)
            AND z.process_id = p_process_id
            AND z.shift_id = 2
            AND y.not_count = 0
            AND z.ID = a.ID
        ) AS actual_total,
        b.wbreak,
        b.is_line
    FROM eff_batch_control a
    LEFT JOIN eff_2_normal_wt b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.shift_id = 2
    AND b.wbreak = 0
    AND b.is_line = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_004_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'target efficiency'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.car_model_id,
        a.account_id,
        a.process_id
    FROM eff_batch_control a
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.target_eff,
        a.car_model_id,
        a.account_id,
        a.process_id
    FROM eff_batch_control a
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

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
(46, 1, 10, 0, 5, 0, 3),
(47, 2, 16, 0, 0, 0, 3),
(48, 3, 5, 0, 0, 0, 3),
(49, 4, 2, 0, 3, 0, 3),
(50, 5, 5, 2, 1, 1, 3),
(51, 6, 21, 0, 1, 1, 3),
(52, 1, 8, 2, 0, 0, 25),
(53, 2, 8, 0, 0, 0, 25),
(54, 3, 3, 0, 0, 0, 25),
(55, 4, 8, 0, 0, 0, 25),
(56, 5, 3, 0, 0, 1, 25),
(57, 6, 5, 0, 0, 1, 25),
(58, 1, 1, 0, 2, 0, 1),
(59, 2, 2, 2, 0, 0, 1),
(60, 3, 15, 0, 3, 0, 1),
(61, 4, 11, 0, 1, 0, 1),
(62, 5, 1, 0, 1, 1, 1),
(63, 6, 10, 0, 1, 1, 1),
(64, 1, 8, 1, 5, 0, 2),
(65, 2, 21, 0, 3, 0, 2),
(66, 3, 1, 1, 0, 0, 2),
(67, 4, 7, 2, 8, 0, 2),
(68, 5, 3, 0, 1, 1, 2),
(69, 6, 8, 0, 0, 1, 2),
(70, 1, 0, 0, 0, 0, 30),
(71, 2, 0, 0, 0, 0, 30),
(72, 3, 0, 0, 0, 0, 30),
(73, 4, 8, 0, 0, 0, 30),
(74, 5, 0, 0, 0, 1, 30),
(75, 6, 10, 0, 0, 1, 30);

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
(5, 540, 0, 0, 0, 0, 1, 25),
(6, 540, 0, 0, 0, 0, 0, 25),
(7, 510, 0, 0, 0, 1, 1, 25),
(8, 510, 0, 0, 0, 1, 0, 25),
(17, 480, 0, 0, 0, 0, 1, 1),
(18, 480, 0, 0, 0, 0, 0, 1),
(19, 450, 0, 0, 0, 1, 1, 1),
(20, 450, 0, 0, 0, 1, 0, 1),
(21, 540, 0, 0, 0, 0, 1, 3),
(22, 540, 0, 0, 0, 0, 0, 3),
(23, 510, 0, 0, 0, 1, 1, 3),
(24, 510, 0, 0, 0, 1, 0, 3),
(25, 600, 0, 0, 0, 0, 1, 2),
(26, 600, 0, 0, 0, 0, 0, 2),
(27, 570, 0, 0, 0, 1, 1, 2),
(28, 570, 0, 0, 0, 1, 0, 2),
(29, 480, 0, 0, 0, 0, 1, 30),
(30, 480, 0, 0, 0, 0, 0, 30),
(31, 450, 0, 0, 0, 1, 1, 30),
(32, 450, 0, 0, 0, 1, 0, 30);

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
(38, 40, 0, 0, 0, 0),
(52, 47, 0, 0, 0, 0),
(54, 48, 0, 0, 0, 0),
(56, 49, 0, 0, 0, 0),
(58, 50, 0, 0, 0, 0),
(60, 51, 0, 0, 0, 0),
(62, 52, 0, 0, 0, 0),
(64, 53, 0, 0, 0, 0),
(66, 54, 0, 0, 0, 0),
(68, 55, 0, 0, 0, 0),
(70, 56, 0, 0, 0, 0),
(72, 57, 0, 0, 0, 0),
(74, 58, 10, 0, 0, 0),
(76, 59, 0, 2, 0, 0),
(78, 60, 0, 5, 0, 0),
(80, 61, 0, 0, 3, 0),
(82, 62, 0, 0, 0, 0),
(84, 63, 0, 4, 2, 0),
(86, 64, 0, 0, 0, 0),
(88, 65, 0, 0, 0, 0),
(90, 66, 0, 0, 0, 0),
(92, 67, 0, 0, 0, 0),
(94, 68, 0, 0, 0, 0),
(96, 69, 5, 0, 0, 0),
(97, 70, 0, 0, 0, 0),
(98, 71, 0, 0, 0, 0),
(99, 72, 0, 0, 0, 0),
(100, 73, 0, 0, 0, 0),
(101, 74, 0, 0, 0, 0),
(102, 75, 0, 0, 0, 0);

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
  `target_eff` varchar(255) NOT NULL,
  `shift_id` int(11) NOT NULL,
  `car_model_id` int(11) NOT NULL,
  `account_id` int(11) DEFAULT NULL,
  `process_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_batch_control`
--

INSERT INTO `eff_batch_control` (`ID`, `date`, `grp`, `cutting_plan`, `cutting_start_time`, `cutting_end_time`, `target_eff`, `shift_id`, `car_model_id`, `account_id`, `process_id`) VALUES
(1, '2018-02-06', 'A', '', '00:00:00', '00:00:00', '80', 1, 3, 1, 1),
(2, '2018-02-06', 'B', '', '00:00:00', '00:00:00', '80', 2, 3, 1, 1),
(3, '2018-02-07', 'A', '', '00:00:00', '00:00:00', '80', 1, 3, 1, 1),
(4, '2018-02-07', 'B', '', '00:00:00', '00:00:00', '80', 2, 3, 1, 1),
(20, '2018-02-19', '', '', '00:00:00', '00:00:00', '80', 1, 1, 1, 1),
(21, '2018-02-08', '', '', '00:00:00', '00:00:00', '80', 2, 3, 1, 1),
(22, '2018-02-20', '', '', '00:00:00', '00:00:00', '80', 1, 1, 1, 1),
(24, '2018-02-20', '', '', '00:00:00', '00:00:00', '80', 2, 1, 1, 1),
(25, '2018-02-20', '', '', '00:00:00', '00:00:00', '80', 1, 3, 1, 1),
(26, '2018-02-21', '', '', '00:00:00', '00:00:00', '80', 1, 1, 1, 1),
(27, '2018-02-22', '', '', '00:00:00', '00:00:00', '80', 1, 1, 1, 1),
(28, '2018-02-18', '', '', '00:00:00', '00:00:00', '80', 1, 3, 1, 1),
(29, '2018-02-18', '', '', '00:00:00', '00:00:00', '80', 2, 3, 1, 1),
(30, '2018-02-19', '', '', '00:00:00', '00:00:00', '80', 1, 3, 1, 1),
(31, '2018-02-08', '', '', '00:00:00', '00:00:00', '', 1, 3, 1, 1),
(32, '2018-02-08', '', '', '00:00:00', '00:00:00', '', 1, 4, 1, 1),
(33, '2018-02-08', '', '', '00:00:00', '00:00:00', '', 1, 6, 1, 1),
(34, '2018-02-08', '', '', '00:00:00', '00:00:00', '', 2, 6, 1, 1);

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
(9, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, 1),
(13, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, 12),
(14, 1, '', '', '', 1, 1, '', '14:30:00', '15:00:00', 30, 0, 0, 3),
(15, 2, '', '', '', 2, 1, '', '00:00:00', '00:00:00', 0, 0, 0, 25),
(16, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, 25),
(17, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `eff_pic`
--

CREATE TABLE `eff_pic` (
  `id` int(11) NOT NULL,
  `pic_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_pic`
--

INSERT INTO `eff_pic` (`id`, `pic_name`) VALUES
(1, 'AME'),
(2, 'PE - Final'),
(3, 'PE - Initial'),
(4, 'EQ'),
(5, 'PD - Tube Cutting'),
(6, 'PD - Battery'),
(7, 'PD - Initial'),
(8, 'MM'),
(9, 'IT'),
(10, 'PC'),
(11, 'QA');

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
  `not_count` int(11) NOT NULL,
  `process_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_process_detail`
--

INSERT INTO `eff_process_detail` (`ID`, `process_detail_name`, `not_count`, `process_id`) VALUES
(1, 'TRD Operators', 0, 1),
(2, 'Point Marking', 0, 1),
(3, 'ZAIHAI', 0, 1),
(4, 'QA Inspectors', 0, 1),
(5, 'PD Jr. Staff', 1, 1),
(6, 'QA Jr. Staff', 1, 1);

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
(3394, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 20),
(3395, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 20),
(3396, 'NC8V-67-030A(7)-D', '18.7353', '', '', 20),
(3397, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 20),
(3398, 'NC9P-67-030A(8)-D', '21.0736', '', '', 20),
(3399, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 20),
(3400, 'NA4N-67-290A(4)-1', '1.6564', '', '', 20),
(3401, 'NA4L-67-290B(6)', '1.7623', '20', '', 20),
(3402, 'NA4M-67-290B(6)', '0.8982', '', '', 20),
(3404, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 20),
(3406, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 21),
(3407, 'NC9P-67-030A(8)-D', '21.0736', '', '', 21),
(3408, 'NC8V-67-030A(7)-D', '18.7353', '', '', 21),
(3409, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 21),
(3410, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 21),
(3411, 'NA4N-67-290A(4)-1', '1.6564', '', '', 21),
(3412, 'NA4L-67-290B(6)', '1.7623', '20', '', 21),
(3413, 'NA4M-67-290B(6)', '0.8982', '', '', 21),
(3414, 'NA4M-67-290B(6)', '0.8982', '', '', 21),
(3458, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 24),
(3459, 'NC8V-67-030A(7)-D', '18.7353', '', '', 24),
(3460, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 24),
(3461, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 24),
(3462, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 24),
(3463, 'NC9P-67-030A(8)-D', '21.0736', '', '', 24),
(3464, 'NA4N-67-290A(4)-1', '1.6564', '', '', 24),
(3465, 'NA4L-67-290B(6)', '1.7623', '20', '', 24),
(3466, 'NA4M-67-290B(6)', '0.8982', '', '', 24),
(3467, 'NA4M-67-290B(6)', '0.8982', '2', '', 24),
(3468, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 22),
(3469, 'NC9P-67-030A(8)-D', '21.0736', '', '', 22),
(3470, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 22),
(3471, 'NC8V-67-030A(7)-D', '18.7353', '', '', 22),
(3472, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 22),
(3473, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 22),
(3474, 'NA4N-67-290A(4)-1', '1.6564', '', '', 22),
(3475, 'NA4L-67-290B(6)', '1.7623', '20', '', 22),
(3476, 'NA4M-67-290B(6)', '0.8982', '', '', 22),
(3477, 'NA4M-67-290B(6)', '0.8982', '', '', 22),
(3478, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 25),
(3479, 'NA4N-67-290A(4)-1', '1.6564', '', '', 25),
(3480, 'NA4L-67-290B(6)', '1.7623', '20', '', 25),
(3481, 'NA4M-67-290B(6)', '0.8982', '', '', 25),
(3482, 'NA4M-67-290B(6)', '0.8982', '10', '', 25),
(3483, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 25),
(3484, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 26),
(3485, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 26),
(3486, 'NC9P-67-030A(8)-D', '21.0736', '', '', 26),
(3487, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 26),
(3488, 'NC8V-67-030A(7)-D', '18.7353', '', '', 26),
(3489, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 26),
(3490, 'NA4N-67-290A(4)-1', '1.6564', '', '', 26),
(3491, 'NA4L-67-290B(6)', '1.7623', '20', '', 26),
(3492, 'NA4M-67-290B(6)', '0.8982', '', '', 26),
(3493, 'NA4M-67-290B(6)', '0.8982', '', '', 26),
(3494, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 27),
(3495, 'NC8V-67-030A(7)-D', '18.7353', '', '', 27),
(3496, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 27),
(3497, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 27),
(3498, 'NC9P-67-030A(8)-D', '21.0736', '', '', 27),
(3499, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 27),
(3500, 'NA4N-67-290A(4)-1', '1.6564', '', '', 27),
(3501, 'NA4L-67-290B(6)', '1.7623', '20', '', 27),
(3502, 'NA4M-67-290B(6)', '0.8982', '', '', 27),
(3503, 'NA4M-67-290B(6)', '0.8982', '', '', 27),
(3504, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 27),
(3505, 'NC9P-67-030A(8)-D', '21.0736', '', '', 27),
(3506, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 27),
(3507, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 27),
(3508, 'NC8V-67-030A(7)-D', '18.7353', '', '', 27),
(3509, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 27),
(3510, 'NA4N-67-290A(4)-1', '1.6564', '', '', 27),
(3511, 'NA4L-67-290B(6)', '1.7623', '20', '', 27),
(3512, 'NA4M-67-290B(6)', '0.8982', '', '', 27),
(3513, 'NA4M-67-290B(6)', '0.8982', '', '', 27),
(3514, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 28),
(3515, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 28),
(3516, 'NC9P-67-030A(8)-D', '21.0736', '', '', 28),
(3517, 'NC8V-67-030A(7)-D', '18.7353', '', '', 28),
(3518, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 28),
(3519, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 28),
(3520, 'NA4N-67-290A(4)-1', '1.6564', '', '', 28),
(3521, 'NA4L-67-290B(6)', '1.7623', '20', '', 28),
(3522, 'NA4M-67-290B(6)', '0.8982', '', '', 28),
(3523, 'NA4M-67-290B(6)', '0.8982', '', '', 28),
(3524, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 29),
(3525, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 29),
(3526, 'NC8V-67-030A(7)-D', '18.7353', '', '', 29),
(3527, 'NC9P-67-030A(8)-D', '21.0736', '', '', 29),
(3528, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 29),
(3529, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 29),
(3530, 'NA4N-67-290A(4)-1', '1.6564', '', '', 29),
(3531, 'NA4L-67-290B(6)', '1.7623', '20', '', 29),
(3532, 'NA4M-67-290B(6)', '0.8982', '', '', 29),
(3533, 'NA4M-67-290B(6)', '0.8982', '', '', 29),
(3534, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 30),
(3535, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 30),
(3536, 'NC8V-67-030A(7)-D', '18.7353', '', '', 30),
(3537, 'NC9P-67-030A(8)-D', '21.0736', '', '', 30),
(3538, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 30),
(3539, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 30),
(3540, 'NA4N-67-290A(4)-1', '1.6564', '', '', 30),
(3541, 'NA4L-67-290B(6)', '1.7623', '20', '', 30),
(3542, 'NA4M-67-290B(6)', '0.8982', '', '', 30),
(3543, 'NA4M-67-290B(6)', '0.8982', '', '', 30),
(3544, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 2),
(3545, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', 2),
(3546, 'NC8V-67-030A(7)-D', '18.7353', '5', '', 2),
(3547, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 2),
(3548, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', 2),
(3549, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 2),
(3550, 'NA4N-67-290A(4)-1', '1.6564', '', '', 2),
(3551, 'NA4L-67-290B(6)', '1.7623', '20', '', 2),
(3552, 'NA4M-67-290B(6)', '0.8982', '20', '', 2),
(3553, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 2),
(3554, 'NA4M-67-290B(6)', '0.8982', '', '', 2),
(3555, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 2),
(3556, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', 2),
(3557, 'NA4N-67-290A(4)-1', '1.6564', '', '', 2),
(3558, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 2),
(3599, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 3),
(3600, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', 3),
(3601, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 3),
(3602, 'NC8V-67-030A(7)-D', '18.7353', '5', '', 3),
(3603, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 3),
(3604, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', 3),
(3605, 'NA4N-67-290A(4)-1', '1.6564', '', '', 3),
(3606, 'NA4L-67-290B(6)', '1.7623', '20', '', 3),
(3607, 'NA4M-67-290B(6)', '0.8982', '20', '', 3),
(3608, 'NA4M-67-290B(6)', '0.8982', '', '', 3),
(3609, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 3),
(3610, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 3),
(3611, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', 3),
(3612, 'NA4N-67-290A(4)-1', '1.6564', '', '', 3),
(3613, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 3),
(3614, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', 3),
(3615, 'NC8V-67-030A(7)-D', '18.7353', '', '', 3),
(3616, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 3),
(3617, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 3),
(3618, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 3),
(3619, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 4),
(3620, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 4),
(3621, 'NC8V-67-030A(7)-D', '18.7353', '', '', 4),
(3622, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 4),
(3623, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 4),
(3624, 'NC9P-67-030A(8)-D', '21.0736', '', '', 4),
(3625, 'NA4N-67-290A(4)-1', '1.6564', '', '', 4),
(3626, 'NA4L-67-290B(6)', '1.7623', '20', '', 4),
(3627, 'NA4M-67-290B(6)', '0.8982', '', '', 4),
(3628, 'NA4M-67-290B(6)', '0.8982', '', '', 4),
(3629, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 31),
(3630, 'NC8V-67-030A(7)-D', '18.7353', '', '', 31),
(3631, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', 31),
(3632, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', 31),
(3633, 'NC9P-67-030A(8)-D', '21.0736', '', '', 31),
(3634, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 31),
(3635, 'NA4N-67-290A(4)-1', '1.6564', '', '', 31),
(3636, 'NA4L-67-290B(6)', '1.7623', '20', '', 31),
(3637, 'NA4M-67-290B(6)', '0.8982', '', '', 31),
(3638, 'NA4M-67-290B(6)', '0.8982', '', '', 31),
(3639, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 32),
(3640, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', 32),
(3641, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 32),
(3642, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 32),
(3643, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', 32),
(3644, 'NC8V-67-030A(7)-D', '18.7353', '5', '', 32),
(3645, 'NA4N-67-290A(4)-1', '1.6564', '', '', 32),
(3646, 'NA4L-67-290B(6)', '1.7623', '20', '', 32),
(3647, 'NA4M-67-290B(6)', '0.8982', '20', '', 32),
(3648, 'NA4M-67-290B(6)', '0.8982', '', '', 32),
(3649, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 32),
(3650, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 32),
(3651, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', 32),
(3652, 'NA4N-67-290A(4)-1', '1.6564', '', '', 32),
(3653, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 32),
(3654, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', 32),
(3655, 'NC8V-67-030A(7)-D', '18.7353', '', '', 32),
(3656, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 32),
(3657, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 32),
(3658, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 32),
(3659, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 33),
(3660, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', 33),
(3661, 'NC8V-67-030A(7)-D', '18.7353', '5', '', 33),
(3662, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 33),
(3663, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', 33),
(3664, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 33),
(3665, 'NA4N-67-290A(4)-1', '1.6564', '', '', 33),
(3666, 'NA4L-67-290B(6)', '1.7623', '20', '', 33),
(3667, 'NA4M-67-290B(6)', '0.8982', '20', '', 33),
(3668, 'NA4M-67-290B(6)', '0.8982', '', '', 33),
(3669, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 33),
(3670, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 33),
(3671, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', 33),
(3672, 'NA4N-67-290A(4)-1', '1.6564', '', '', 33),
(3673, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 33),
(3674, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 34),
(3675, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', 34),
(3676, 'NC8V-67-030A(7)-D', '18.7353', '5', '', 34),
(3677, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 34),
(3678, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 34),
(3679, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', 34),
(3680, 'NA4N-67-290A(4)-1', '1.6564', '', '', 34),
(3681, 'NA4L-67-290B(6)', '1.7623', '20', '', 34),
(3682, 'NA4M-67-290B(6)', '0.8982', '20', '', 34),
(3683, 'NA4M-67-290B(6)', '0.8982', '', '', 34),
(3684, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 34),
(3685, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 34),
(3686, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', 34),
(3687, 'NA4N-67-290A(4)-1', '1.6564', '', '', 34),
(3688, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 34),
(3689, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', 34),
(3690, 'NC8V-67-030A(7)-D', '18.7353', '', '', 34),
(3691, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 34),
(3692, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 34),
(3693, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 34);

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
(1, 'IRCS Problem'),
(2, 'Material Shortage'),
(3, 'Delay On Wire'),
(4, 'TRD Machine Problem'),
(5, 'Power Interruption'),
(6, 'Broken/Bend Pin'),
(7, 'NG Operator');

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
(1, '5', '450-480', 480, 450),
(2, '6', '510-540', 540, 510),
(3, '7', '570-600', 600, 570),
(4, '8', '630-660', 660, 630);

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
-- Indexes for table `eff_pic`
--
ALTER TABLE `eff_pic`
  ADD PRIMARY KEY (`id`);

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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;
--
-- AUTO_INCREMENT for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;
--
-- AUTO_INCREMENT for table `eff_3_extended_wt`
--
ALTER TABLE `eff_3_extended_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;
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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;
--
-- AUTO_INCREMENT for table `eff_car_model`
--
ALTER TABLE `eff_car_model`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `eff_downtime`
--
ALTER TABLE `eff_downtime`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
--
-- AUTO_INCREMENT for table `eff_pic`
--
ALTER TABLE `eff_pic`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3694;
--
-- AUTO_INCREMENT for table `eff_reason`
--
ALTER TABLE `eff_reason`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
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
