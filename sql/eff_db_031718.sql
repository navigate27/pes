-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 17, 2018 at 02:25 AM
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_account_id` (IN `p_name` VARCHAR(255), IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_car_model_id` INT, IN `p_shift_id` INT, IN `p_acc_type` INT)  NO SQL
INSERT eff_account (name,username,`password`,car_model_id,shift_id,type)
VALUES (p_name,p_username,p_password,p_car_model_id,p_shift_id,p_acc_type)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_batch_id_and_product_no` (IN `p_date` DATE, IN `p_shift_id` INT, IN `p_car_model_id` INT, IN `p_account_id` INT, IN `p_process_id` INT, IN `p_product_no` VARCHAR(255), IN `p_std_time` VARCHAR(255), IN `p_output_qty` VARCHAR(255))  NO SQL
BEGIN

DECLARE _batch_id INT;

INSERT INTO eff_batch_control (`date`,group_id,shift_id,car_model_id,account_id,process_id)
VALUES
(p_date, NULL, p_shift_id, p_car_model_id, p_account_id, p_process_id);

SET _batch_id = LAST_INSERT_ID();

INSERT INTO eff_product_rep 
(product_no, std_time, output_qty, group_id, batch_id)
VALUES
(p_product_no, p_std_time, p_output_qty, NULL, _batch_id);

SELECT _batch_id AS batch_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_downtime_id` (IN `p_reason_id` INT, IN `p_part_wire` VARCHAR(255), IN `p_part_term_front` VARCHAR(255), IN `p_part_term_rear` VARCHAR(255), IN `p_pic_id` INT, IN `p_process_detail_id` INT, IN `p_dimension` VARCHAR(255), IN `p_time_start` TIME, IN `p_time_end` TIME, IN `p_time_total` INT, IN `p_mp_r1` VARCHAR(255), IN `p_mp_r3` VARCHAR(255), IN `p_batch_id` INT)  NO SQL
INSERT INTO eff_downtime 
(reason_id, part_wire, part_term_front, part_term_rear, pic_id, process_detail_id, dimension, time_start, time_end, time_total, mp_r1, mp_r3, batch_id)
VALUES
(p_reason_id, p_part_wire, p_part_term_front, p_part_term_rear, p_pic_id, p_process_detail_id, p_dimension, p_time_start, p_time_end, p_time_total, p_mp_r1, p_mp_r3, p_batch_id)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_manpower_count_id` (IN `p_prcs_detail_id` INT, IN `p_actual` INT, IN `p_absent` INT, IN `p_support` INT, IN `p_batch_id` INT, IN `p_group_id` INT, IN `p_remarks` VARCHAR(2048))  NO SQL
BEGIN

DECLARE _mpc_id INT;

DECLARE _is_count VARCHAR(10);

SET _is_count = (
    SELECT a.not_count
    FROM eff_process_detail a
    WHERE a.ID = p_prcs_detail_id
);

INSERT eff_1_manpower_count
(process_detail_id, actual, absent, support, batch_id, not_count, group_id,remarks) VALUES
(p_prcs_detail_id, p_actual, p_absent, p_support, p_batch_id, _is_count, p_group_id,p_remarks);

SET _mpc_id = LAST_INSERT_ID();

INSERT eff_3_extended_wt (mpcount_id, ot_60, ot_120, ot_180, is_line) VALUES
(_mpc_id,0,0,0,0);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_normal_work_id` (IN `p_batch_id` INT, IN `p_wt` INT, IN `p_wbreak` INT, IN `p_is_line` INT, IN `p_group_id` INT)  NO SQL
INSERT INTO eff_2_normal_wt (wt, wbreak, is_line, batch_id, group_id)
VALUES (p_wt, p_wbreak, p_is_line, p_batch_id, p_group_id)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_pic_id` (IN `p_pic_name` VARCHAR(255))  NO SQL
INSERT eff_pic (pic_name) VALUES (p_pic_name)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_product_rep_id` (IN `p_batch_id` INT, IN `p_product_no` VARCHAR(255), IN `p_std_time` VARCHAR(255), IN `p_output_qty` VARCHAR(255))  NO SQL
INSERT INTO eff_product_rep
(product_no, std_time, output_qty, group_id, batch_id)  VALUES
(p_product_no, p_std_time, p_output_qty, NULL, p_batch_id)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_product_st_id` (IN `p_product_no` VARCHAR(255), IN `p_st` VARCHAR(255))  NO SQL
INSERT INTO eff_product_st (product_no, st) VALUES
(p_product_no, p_st)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_reason_id` (IN `p_reason` VARCHAR(255))  NO SQL
INSERT INTO eff_reason (reason) VALUES (p_reason)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_target_eff_id` (IN `p_batch_id` INT, IN `p_group_id` INT, IN `p_line_480` INT, IN `p_acctg_480` INT, IN `p_line_450` INT, IN `p_acctg_450` INT)  NO SQL
INSERT INTO eff_batch_group (target_line_480, target_acctg_480, target_line_450, target_acctg_450, batch_id, group_id) VALUES
(p_line_480, p_acctg_480, p_line_450, p_acctg_450, p_batch_id, p_group_id)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_account_id` (IN `p_account_id` INT)  NO SQL
DELETE FROM eff_account WHERE ID = p_account_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_all_product_on_batch_id` (IN `p_batch_id` INT)  NO SQL
DELETE FROM eff_product_rep WHERE batch_id = p_batch_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_all_st` ()  NO SQL
DELETE FROM eff_product_st$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_downtime_id` (IN `p_dt_id` INT)  NO SQL
DELETE FROM eff_downtime WHERE ID = p_dt_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_pic_id` (IN `p_pic_id` INT)  NO SQL
DELETE FROM eff_pic WHERE id = p_pic_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_product_rep_id` (IN `p_product_id` INT)  NO SQL
DELETE FROM eff_product_rep WHERE ID = p_product_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_reason_id` (IN `p_reason_id` INT)  NO SQL
DELETE FROM eff_reason WHERE ID = p_reason_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_account_id` (IN `p_account_id` INT, IN `p_name` VARCHAR(255), IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_car_model_id` INT, IN `p_shift_id` INT, IN `p_acc_type` INT)  NO SQL
UPDATE eff_account a SET 
a.name = p_name,
a.username = p_username,
a.password = p_password,
a.car_model_id = p_car_model_id,
a.shift_id = p_shift_id,
a.type = p_acc_type
WHERE a.ID = p_account_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_batch_target_eff` (IN `p_batch_id` INT, IN `p_target_eff_line_480` VARCHAR(255), IN `p_target_eff_acct_480` VARCHAR(255), IN `p_target_eff_line_450` VARCHAR(255), IN `p_target_eff_acct_450` VARCHAR(255))  NO SQL
BEGIN

DECLARE _date VARCHAR(255);

SET _date = (
    SELECT
    	a.date
    FROM eff_batch_control a
    WHERE a.ID = p_batch_id
);

UPDATE eff_batch_control a
SET a.target_eff_line_480 = p_target_eff_line_480,
a.target_eff_acct_480 = p_target_eff_acct_480,
a.target_eff_line_450 = p_target_eff_line_450,
a.target_eff_acct_450 = p_target_eff_acct_450
WHERE a.date = _date;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_downtime_id` (IN `p_reason_id` INT, IN `p_part_wire` VARCHAR(255), IN `p_part_term_front` VARCHAR(255), IN `p_part_term_rear` VARCHAR(255), IN `p_pic_id` INT, IN `p_process_detail_id` INT, IN `p_dimension` VARCHAR(255), IN `p_time_start` TIME, IN `p_time_end` TIME, IN `p_time_total` INT, IN `p_mp_r1` VARCHAR(255), IN `p_mp_r3` VARCHAR(255), IN `p_dt_id` INT)  NO SQL
UPDATE eff_downtime a SET a.reason_id = p_reason_id, 
a.part_wire = p_part_wire, 
a.part_term_front = p_part_term_front, 
a.part_term_rear = p_part_term_rear, 
a.pic_id = p_pic_id, 
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_manpower_count_id` (IN `p_mpc_id` INT, IN `p_actual` INT, IN `p_absent` INT, IN `p_support` INT, IN `p_remarks` VARCHAR(2048))  NO SQL
UPDATE eff_1_manpower_count a
SET a.actual = p_actual, 
a.absent = p_absent, a.support = p_support, a.remarks = p_remarks
WHERE a.ID = p_mpc_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_normal_work_id` (IN `p_nw_id` INT, IN `p_wt` INT)  NO SQL
UPDATE eff_2_normal_wt a
SET a.wt = p_wt
WHERE a.ID = p_nw_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_pic_id` (IN `p_pic_id` INT, IN `p_pic_name` VARCHAR(255))  NO SQL
UPDATE eff_pic a
SET a.pic_name = p_pic_name
WHERE a.id = p_pic_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_product_group_on_id` (IN `p_product_id` INT, IN `p_group_id` INT)  NO SQL
UPDATE eff_product_rep a
SET a.group_id = p_group_id
WHERE a.ID = p_product_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_product_rep_id` (IN `p_product_id` INT, IN `p_product_no` VARCHAR(255), IN `p_std_time` VARCHAR(255), IN `p_output_qty` VARCHAR(255))  NO SQL
UPDATE eff_product_rep a 
SET a.product_no = p_product_no,
a.std_time = p_std_time,
a.output_qty = p_output_qty
WHERE a.ID = p_product_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_reason_id` (IN `p_reason_id` INT, IN `p_reason` VARCHAR(255))  NO SQL
UPDATE eff_reason a
SET a.reason = p_reason
WHERE a.ID = p_reason_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_target_eff_id` (IN `p_target_id` INT, IN `p_line_480` INT, IN `p_acctg_480` INT, IN `p_line_450` INT, IN `p_acctg_450` INT)  NO SQL
UPDATE eff_batch_group a
SET a.target_line_480 = p_line_480,
a.target_acctg_480 = p_acctg_480,
a.target_line_450 = p_line_450,
a.target_acctg_450 = p_acctg_450
WHERE a.ID = p_target_id$$

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
    a.group_id,
    e.group_name,
    d.account_name
FROM eff_account a
LEFT JOIN eff_car_model b
ON a.car_model_id = b.ID
LEFT JOIN eff_shift c
ON a.shift_id = c.ID
LEFT JOIN eff_account_type d
ON a.type = d.ID
LEFT JOIN eff_group e
ON a.group_id = e.ID
WHERE a.username = p_username
AND a.password = p_password$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_account_on_account_type` (IN `p_account_type` INT, IN `p_car_model_id` INT)  NO SQL
BEGIN

IF p_account_type = 0 THEN
	SELECT
        a.ID,
        a.name,
        a.username,
        a.password,
        a.car_model_id,
        a.shift_id,
        a.dept_id,
        a.section_id,
        a.type,
        b.account_name,
        c.car_model_name,
        d.shift
    FROM eff_account a
    LEFT JOIN eff_account_type b
    ON a.type = b.ID
    LEFT JOIN eff_car_model c
    ON a.car_model_id = c.ID
    LEFT JOIN eff_shift d
    ON a.shift_id = d.ID
    WHERE a.type != 3;
ELSE
	IF p_car_model_id = 0 THEN
    	SELECT
            a.ID,
            a.name,
            a.username,
            a.password,
            a.car_model_id,
            a.shift_id,
            a.dept_id,
            a.section_id,
            a.type,
            b.account_name,
            c.car_model_name,
            d.shift
        FROM eff_account a
        LEFT JOIN eff_account_type b
        ON a.type = b.ID
        LEFT JOIN eff_car_model c
        ON a.car_model_id = c.ID
        LEFT JOIN eff_shift d
        ON a.shift_id = d.ID
        WHERE a.type = p_account_type;
    ELSE
    	SELECT
            a.ID,
            a.name,
            a.username,
            a.password,
            a.car_model_id,
            a.shift_id,
            a.dept_id,
            a.section_id,
            a.type,
            b.account_name,
            c.car_model_name,
            d.shift
        FROM eff_account a
        LEFT JOIN eff_account_type b
        ON a.type = b.ID
        LEFT JOIN eff_car_model c
        ON a.car_model_id = c.ID
        LEFT JOIN eff_shift d
        ON a.shift_id = d.ID
        WHERE a.type = p_account_type
        AND a.car_model_id = p_car_model_id;
    END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_account_on_id` (IN `p_account_id` INT)  NO SQL
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
WHERE a.ID = p_account_id$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_account_type` ()  NO SQL
SELECT
	a.ID,
    a.account_name
FROM eff_account_type a$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_car_model` ()  NO SQL
SELECT
	a.ID,
    a.car_model_name,
    a.car_code
FROM eff_car_model a$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_downtime_on_batch_id` (IN `p_batch_id` INT)  NO SQL
SELECT
	a.ID,
    a.reason_id,
    b.reason,
    a.part_wire,
    a.part_term_front,
    a.part_term_rear,
    a.pic_id,
    c.pic_name,
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
LEFT JOIN eff_pic c
ON a.pic_id = c.ID
LEFT JOIN eff_process_detail d
ON a.process_detail_id = d.ID
WHERE a.batch_id = p_batch_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_group` ()  NO SQL
SELECT
	a.ID,
    a.group_name
FROM eff_group a$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_manpower_count_on_batch_id` (IN `p_batch_id` INT, IN `p_group_id` INT)  NO SQL
SELECT
	a.ID,
    a.process_detail_id,
    a.actual,
    a.absent,
    a.support,
    a.not_count,
    a.remarks,
    a.batch_id,
    b.process_detail_name,
    c.date,
    c.group_id,
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
WHERE c.ID = p_batch_id
AND a.group_id = p_group_id$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_normal_wt_on_batch_id` (IN `p_batch_id` INT, IN `p_group_id` INT)  NO SQL
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
AND a.group_id = p_group_id
ORDER BY a.wbreak DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_process_detail_on_process_id` (IN `p_process_id` INT)  NO SQL
SELECT 
	a.ID,
    a.process_detail_name,
    a.process_id,
    a.not_count,
    b.process_name
FROM eff_process_detail a
LEFT JOIN eff_process b
ON a.process_id = b.ID
WHERE a.process_id = p_process_id
ORDER BY a.ID ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_product_on_date` (IN `p_car_model_id` INT, IN `p_date` DATE, IN `p_group_id` INT, IN `p_shift_id` INT)  NO SQL
BEGIN

IF p_group_id = 0 AND p_shift_id = 0 THEN
	
    SELECT
        a.ID,
        a.product_no,
        a.std_time,
        a.output_qty,
        a.group_id,
        a.batch_id,
        b.shift_id,
        c.shift,
        d.group_name,
        ROUND((a.std_time*a.output_qty),2) AS output_mins
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    LEFT JOIN eff_group d
    ON a.group_id = d.ID
    WHERE a.batch_id IN (
        SELECT
            z.ID
        FROM eff_batch_control z
        WHERE z.date = p_date
        AND z.car_model_id = p_car_model_id
    );
    
ELSEIF p_group_id != 0 AND p_shift_id = 0 THEN

    SELECT
        a.ID,
        a.product_no,
        a.std_time,
        a.output_qty,
        a.group_id,
        a.batch_id,
        b.shift_id,
        c.shift,
        d.group_name,
        ROUND((a.std_time*a.output_qty),2) AS output_mins
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    LEFT JOIN eff_group d
    ON a.group_id = d.ID
    WHERE a.batch_id IN (
        SELECT
            z.ID
        FROM eff_batch_control z
        WHERE z.date = p_date
        AND z.car_model_id = p_car_model_id
    )
    AND a.group_id = p_group_id;

ELSEIF p_group_id = 0 AND p_shift_id != 0 THEN

    SELECT
        a.ID,
        a.product_no,
        a.std_time,
        a.output_qty,
        a.group_id,
        a.batch_id,
        b.shift_id,
        c.shift,
        d.group_name,
        ROUND((a.std_time*a.output_qty),2) AS output_mins
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    LEFT JOIN eff_group d
    ON a.group_id = d.ID
    WHERE a.batch_id IN (
        SELECT
            z.ID
        FROM eff_batch_control z
        WHERE z.date = p_date
        AND z.car_model_id = p_car_model_id
    )
    AND b.shift_id = p_shift_id;

ELSE
	
    SELECT
        a.ID,
        a.product_no,
        a.std_time,
        a.output_qty,
        a.group_id,
        a.batch_id,
        b.shift_id,
        c.shift,
        d.group_name,
        ROUND((a.std_time*a.output_qty),2) AS output_mins
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    LEFT JOIN eff_group d
    ON a.group_id = d.ID
    WHERE a.batch_id IN (
        SELECT
            z.ID
        FROM eff_batch_control z
        WHERE z.date = p_date
        AND z.car_model_id = p_car_model_id
    )
    AND b.shift_id = p_shift_id;
    
END IF;

END$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_product_st` ()  NO SQL
SELECT
	a.ID,
    a.product_no,
    a.st
FROM eff_product_st a$$

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
    a.group_id,
    a.cutting_plan,
    a.cutting_start_time,
    a.cutting_end_time,
    a.target_eff_line_480,
    a.target_eff_acct_480,
    a.target_eff_line_450,
    a.target_eff_acct_450,
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_batch_id_on_query` (IN `p_date` DATE, IN `p_car_model_id` INT, IN `p_shift_id` INT, IN `p_process_id` INT, IN `p_group_id` INT)  NO SQL
BEGIN

IF p_shift_id != 0 THEN

    SELECT
        a.ID,
        a.date,
        a.group_id,
        a.cutting_plan,
        a.cutting_start_time,
        a.cutting_end_time,
        a.shift_id,
        a.target_eff_line_480,
        a.target_eff_acct_480,
        a.target_eff_line_450,
        a.target_eff_acct_450,
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
    AND a.car_model_id = p_car_model_id;
    
ELSE

    SELECT
        a.ID,
        a.date,
        a.group_id,
        a.cutting_plan,
        a.cutting_start_time,
        a.cutting_end_time,
        a.shift_id,
        a.target_eff_line_480,
        a.target_eff_acct_480,
        a.target_eff_line_450,
        a.target_eff_acct_450,
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
    AND a.process_id = p_process_id
    AND a.car_model_id = p_car_model_id;
    
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_car_model_id` (IN `p_car_model_id` INT)  NO SQL
SELECT
	a.ID,
    a.car_model_name,
    a.car_code
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
    a.pic_id,
    c.pic_name,
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
LEFT JOIN eff_pic c
ON a.pic_id = c.ID
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_ext_id_on_batch_id` (IN `p_batch_id` INT, IN `p_group_id` INT)  NO SQL
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
WHERE a.batch_id = p_batch_id
AND a.group_id = p_group_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_ext_total_man_mins_on_batch_id` (IN `p_batch_id` INT, IN `p_group_id` INT)  NO SQL
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
AND a.group_id = p_group_id
GROUP BY b.is_line
ORDER BY b.is_line DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_group_id` (IN `p_group_id` INT)  NO SQL
SELECT
	a.ID,
    a.group_name
FROM eff_group a
WHERE a.ID = p_group_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_manpower_actual_total_on_batch_id` (IN `p_batch_id` INT, IN `p_group_id` INT)  NO SQL
SELECT
	SUM(z.actual) AS total,
    SUM(z.absent) AS absent,
    SUM(z.support) AS support
FROM eff_1_manpower_count z
WHERE z.batch_id = p_batch_id
AND z.group_id = p_group_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_pic_id` (IN `p_pic_id` INT)  NO SQL
SELECT
	a.id,
    a.pic_name
FROM eff_pic a
WHERE a.id = p_pic_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_pic_list` ()  NO SQL
SELECT
	a.id,
    a.pic_name
FROM eff_pic a$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_product_rep_on_id` (IN `p_product_id` INT)  NO SQL
SELECT
	a.ID,
    a.product_no,
    a.std_time,
    a.output_qty,
    ROUND((a.std_time*a.output_qty),2) AS output_mins
FROM eff_product_rep a
WHERE a.ID = p_product_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_product_rep_total_output_mins_on_batch_id` (IN `p_batch_id` INT, IN `p_group_id` INT)  NO SQL
BEGIN

IF p_group_id != 0 THEN

    SELECT 
        SUM(z.std_time) AS total_st,
        SUM(z.output_qty) AS total_output,
        SUM(ROUND((z.std_time*z.output_qty),2)) AS total_output_mins
    FROM eff_product_rep z
    WHERE z.batch_id = p_batch_id
    AND z.group_id = p_group_id;

ELSE
	
    SELECT 
        SUM(z.std_time) AS total_st,
        SUM(z.output_qty) AS total_output,
        SUM(ROUND((z.std_time*z.output_qty),2)) AS total_output_mins
    FROM eff_product_rep z
    WHERE z.batch_id = p_batch_id;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_product_rep_total_output_mins_on_date` (IN `p_car_model_id` INT, IN `p_date` DATE, IN `p_group_id` INT, IN `p_shift_id` INT)  NO SQL
BEGIN

IF p_group_id = 0 AND p_shift_id = 0 THEN
	
    SELECT
        ROUND(SUM(a.std_time),2) AS total_st,
        SUM(a.output_qty) AS total_output,
        SUM(ROUND((a.std_time*a.output_qty),2)) AS total_output_mins
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    WHERE a.batch_id IN (
        SELECT
            z.ID
        FROM eff_batch_control z
        WHERE z.date = p_date
    );
    
ELSEIF p_group_id != 0 AND p_shift_id = 0 THEN

    SELECT
        ROUND(SUM(a.std_time),2) AS total_st,
        SUM(a.output_qty) AS total_output,
        SUM(ROUND((a.std_time*a.output_qty),2)) AS total_output_mins
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    WHERE a.batch_id IN (
        SELECT
            z.ID
        FROM eff_batch_control z
        WHERE z.date = p_date
    )
    AND a.group_id = p_group_id;

ELSEIF p_group_id = 0 AND p_shift_id != 0 THEN

    SELECT
        ROUND(SUM(a.std_time),2) AS total_st,
        SUM(a.output_qty) AS total_output,
        SUM(ROUND((a.std_time*a.output_qty),2)) AS total_output_mins
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    WHERE a.batch_id IN (
        SELECT
            z.ID
        FROM eff_batch_control z
        WHERE z.date = p_date
    )
    AND b.shift_id = p_shift_id;

ELSE
	
    SELECT
        ROUND(SUM(a.std_time),2) AS total_st,
        SUM(a.output_qty) AS total_output,
        SUM(ROUND((a.std_time*a.output_qty),2)) AS total_output_mins
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    WHERE a.batch_id IN (
        SELECT
            z.ID
        FROM eff_batch_control z
        WHERE z.date = p_date
    )
    AND b.shift_id = p_shift_id;
    
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_reason_id` (IN `p_reason_id` INT)  NO SQL
SELECT
	a.ID,
    a.reason
FROM eff_reason a
WHERE a.ID = p_reason_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_001_group` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT, IN `p_group_id` INT)  NO SQL
    COMMENT 'DAILY PLAN [shift A]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time*b.output_qty)) AS output_mm_total
    FROM eff_batch_control a
    LEFT JOIN eff_product_rep b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time*b.output_qty)) AS output_mm_total
    FROM eff_batch_control a
    LEFT JOIN eff_product_rep b
    ON a.ID = b.batch_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND a.car_model_id = p_car_model_id
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date ASC;
    
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_002_group_acctg` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT, IN `p_group_id` INT)  NO SQL
    COMMENT 'MANPOWER [actual,absent,support]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
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
        ) AS actual_wot_total,
        (
            SELECT
            	SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE z.ID = a.ID
            AND z.process_id = p_process_id
            AND z.car_model_id = p_car_model_id
            AND y.process_detail_id = 8
            AND y.group_id = p_group_id
        ) AS ojt_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    INNER JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
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
        ) AS actual_wot_total,
        (
            SELECT
            	SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE z.ID = a.ID
            AND z.process_id = p_process_id
            AND z.car_model_id = p_car_model_id
            AND y.process_detail_id = 8
            AND y.group_id = p_group_id
        ) AS ojt_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    INNER JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.group_id = p_group_id
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_002_group_line` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT, IN `p_group_id` INT)  NO SQL
    COMMENT 'MANPOWER [actual,absent,support]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
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
        ) AS actual_wot_total,
        (
            SELECT
            	SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE z.ID = a.ID
            AND z.process_id = p_process_id
            AND z.car_model_id = p_car_model_id
            AND y.process_detail_id = 8
            AND y.group_id = p_group_id
            AND y.not_count = 0
        ) AS ojt_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    INNER JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.group_id = p_group_id
    AND b.not_count = 0
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
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
        ) AS actual_wot_total,
        (
            SELECT
            	SUM(y.actual)
            FROM eff_batch_control z
            LEFT JOIN eff_1_manpower_count y
            ON z.ID = y.batch_id
            WHERE z.ID = a.ID
            AND z.process_id = p_process_id
            AND z.car_model_id = p_car_model_id
            AND y.process_detail_id = 8
            AND y.group_id = p_group_id
            AND y.not_count = 0
        ) AS ojt_total
    FROM eff_batch_control a
    LEFT JOIN eff_1_manpower_count b
    ON a.ID = b.batch_id
    INNER JOIN eff_3_extended_wt c
    ON b.ID = c.mpcount_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = p_process_id
    AND b.group_id = p_group_id
    AND a.car_model_id = p_car_model_id
    AND b.not_count = 0
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_003_group_wbreak_acctg` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT, IN `p_group_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 1, is_line = 0]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
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
            AND y.group_id = p_group_id
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
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
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
            AND y.group_id = p_group_id
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
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_003_group_wbreak_line` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT, IN `p_group_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 1, is_line = 1]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
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
            AND y.group_id = p_group_id
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
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
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
            AND y.group_id = p_group_id
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
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_003_group_wobreak_acctg` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT, IN `p_group_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 0, is_line = 0]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
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
            AND y.group_id = p_group_id
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
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
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
            AND y.group_id = p_group_id
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
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_003_group_wobreak_line` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT, IN `p_group_id` INT)  NO SQL
    COMMENT 'efficiency [wbreak = 0, is_line = 1]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
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
            AND y.group_id = p_group_id
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
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date;
ELSE
    SELECT
        a.ID,
        a.date,
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
            AND y.group_id = p_group_id
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
    AND b.group_id = p_group_id
    GROUP BY a.date
    ORDER BY a.date;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_004_group` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT, IN `p_group_id` INT)  NO SQL
    COMMENT 'target efficiency acctg 450'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.car_model_id,
        a.account_id,
        a.process_id,
        b.target_line_480 AS target_line_480,
        b.target_acctg_480 AS target_acctg_480,
        b.target_line_450 AS target_line_450,
        b.target_acctg_450 AS target_acctg_450
    FROM eff_batch_control a
    LEFT JOIN eff_batch_group b
    ON a.ID = b.batch_id AND b.group_id = p_group_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    GROUP BY a.date
    ORDER BY a.date ASC;
ELSE
    SELECT
        a.ID,
        a.date,
        a.car_model_id,
        a.account_id,
        a.process_id,
        b.target_line_480 AS target_line_480,
        b.target_acctg_480 AS target_acctg_480,
        b.target_line_450 AS target_line_450,
        b.target_acctg_450 AS target_acctg_450
    FROM eff_batch_control a
    LEFT JOIN eff_batch_group b
    ON a.ID = b.batch_id AND b.group_id = p_group_id
    WHERE (a.date BETWEEN p_date_start AND p_date_end)
    AND a.process_id = 1
    AND a.car_model_id = p_car_model_id
    GROUP BY a.date
    ORDER BY a.date ASC;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_001_A` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'DAILY PLAN [shift A]'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time*b.output_qty)) AS output_mm_total
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
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time*b.output_qty)) AS output_mm_total
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
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time*b.output_qty)) AS output_mm_total
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
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time*b.output_qty)) AS output_mm_total
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
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time*b.output_qty)) AS output_mm_total
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
        a.shift_id,
        a.car_model_id,
        a.account_id,
        a.process_id,
        SUM(b.std_time) AS std_time_total,
        SUM(b.output_qty) AS output_qty_total,
        (SUM(b.std_time*b.output_qty)) AS output_mm_total
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_004_wbreak_acctg_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'target efficiency acctg 450'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff_acct_450 AS target_eff,
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
        a.target_eff_acct_450 AS target_eff,
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_004_wbreak_line_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'target efficiency line 450'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff_line_450 AS target_eff,
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
        a.target_eff_line_450 AS target_eff,
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_004_wobreak_acctg_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'target efficiency acctg 480'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff_acct_480 AS target_eff,
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
        a.target_eff_acct_480 AS target_eff,
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_report_summary_004_wobreak_line_AB` (IN `p_process_id` INT, IN `p_date_start` DATE, IN `p_date_end` DATE, IN `p_car_model_id` INT)  NO SQL
    COMMENT 'target efficiency line 480'
BEGIN

IF p_car_model_id = 0 THEN
	SELECT
        a.ID,
        a.date,
        a.target_eff_line_480 AS target_eff,
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
        a.target_eff_line_480 AS target_eff,
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_target_eff_id_on_query` (IN `p_batch_id` INT, IN `p_group_id` INT)  NO SQL
SELECT
	a.ID,
    a.target_line_480,
    a.target_acctg_480,
    a.target_line_450,
    a.target_acctg_450,
    a.batch_id,
    a.group_id
FROM eff_batch_group a
WHERE a.batch_id = p_batch_id
AND a.group_id = p_group_id$$

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
  `remarks` varchar(2048) NOT NULL,
  `group_id` int(11) DEFAULT NULL,
  `batch_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_1_manpower_count`
--

INSERT INTO `eff_1_manpower_count` (`ID`, `process_detail_id`, `actual`, `absent`, `support`, `not_count`, `remarks`, `group_id`, `batch_id`) VALUES
(22, 1, 1, 0, 0, 0, '', 1, 57),
(23, 2, 0, 0, 0, 0, '', 1, 57),
(24, 3, 0, 0, 0, 0, '', 1, 57),
(25, 4, 0, 0, 0, 0, '', 1, 57),
(26, 5, 0, 0, 0, 1, '', 1, 57),
(27, 6, 3, 0, 0, 1, '', 1, 57),
(28, 8, 2, 0, 0, 0, '', 1, 57);

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
  `group_id` int(11) DEFAULT NULL,
  `batch_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_2_normal_wt`
--

INSERT INTO `eff_2_normal_wt` (`ID`, `wt`, `manpower`, `tm_mins`, `eff_result`, `wbreak`, `is_line`, `group_id`, `batch_id`) VALUES
(1, 540, 0, 0, 0, 0, 1, 2, 56),
(2, 540, 0, 0, 0, 0, 0, 2, 56),
(3, 510, 0, 0, 0, 1, 1, 2, 56),
(4, 510, 0, 0, 0, 1, 0, 2, 56),
(17, 540, 0, 0, 0, 0, 1, 1, 57),
(18, 540, 0, 0, 0, 0, 0, 1, 57),
(19, 510, 0, 0, 0, 1, 1, 1, 57),
(20, 510, 0, 0, 0, 1, 0, 1, 57);

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
(1, 1, 0, 0, 0, 0),
(2, 2, 0, 0, 0, 0),
(3, 3, 0, 0, 0, 0),
(4, 4, 0, 0, 0, 0),
(5, 5, 0, 0, 0, 0),
(6, 6, 0, 0, 0, 0),
(7, 7, 0, 0, 0, 0),
(8, 8, 0, 0, 0, 0),
(9, 9, 0, 0, 0, 0),
(10, 10, 0, 0, 0, 0),
(11, 11, 0, 0, 0, 0),
(12, 12, 0, 0, 0, 0),
(13, 13, 0, 0, 0, 0),
(14, 14, 0, 0, 0, 0),
(15, 15, 5, 0, 0, 0),
(16, 16, 0, 0, 0, 0),
(17, 17, 0, 0, 0, 0),
(18, 18, 0, 0, 0, 0),
(19, 19, 0, 0, 0, 0),
(20, 20, 0, 0, 0, 0),
(21, 21, 0, 0, 0, 0),
(22, 22, 0, 0, 0, 0),
(23, 23, 0, 0, 0, 0),
(24, 24, 0, 0, 2, 0),
(25, 25, 0, 0, 0, 0),
(26, 26, 0, 0, 2, 0),
(27, 27, 0, 0, 0, 0),
(28, 28, 0, 0, 0, 0),
(29, 29, 0, 0, 0, 0),
(30, 30, 0, 0, 0, 0),
(31, 31, 0, 0, 0, 0),
(32, 32, 0, 0, 0, 0),
(33, 33, 0, 0, 0, 0),
(34, 34, 0, 0, 0, 0),
(35, 35, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `eff_account`
--

CREATE TABLE `eff_account` (
  `ID` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `car_model_id` int(11) DEFAULT NULL,
  `shift_id` int(11) DEFAULT NULL,
  `dept_id` int(11) DEFAULT NULL,
  `section_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `type` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_account`
--

INSERT INTO `eff_account` (`ID`, `name`, `username`, `password`, `car_model_id`, `shift_id`, `dept_id`, `section_id`, `group_id`, `type`) VALUES
(1, 'Barney Stinson', 'thebarney', 'legendary', 3, 1, 0, 0, NULL, 1),
(2, 'Ted Mosby', 'thearchitect', 'jedmosley', 3, 1, 0, 0, 1, 2),
(5, 'Zyrene', 'zai', '212724', 2, 1, 0, 0, 1, 2),
(7, 'Avril', 'admin', 'admin', NULL, NULL, NULL, NULL, NULL, 3),
(8, 'edge', 'test_edge', 'testedge', 3, 2, NULL, NULL, 2, 2),
(15, 'edge', 'test_edge', 'edge', NULL, NULL, NULL, NULL, NULL, 1);

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
(2, 'Production'),
(3, 'Admin');

-- --------------------------------------------------------

--
-- Table structure for table `eff_batch_control`
--

CREATE TABLE `eff_batch_control` (
  `ID` int(11) NOT NULL,
  `date` date NOT NULL,
  `group_id` int(11) DEFAULT NULL,
  `cutting_plan` varchar(255) NOT NULL,
  `cutting_start_time` time NOT NULL,
  `cutting_end_time` time NOT NULL,
  `target_eff_line_480` varchar(255) NOT NULL,
  `target_eff_acct_480` varchar(255) NOT NULL,
  `target_eff_line_450` varchar(255) NOT NULL,
  `target_eff_acct_450` varchar(255) NOT NULL,
  `shift_id` int(11) NOT NULL,
  `car_model_id` int(11) NOT NULL,
  `account_id` int(11) DEFAULT NULL,
  `process_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_batch_control`
--

INSERT INTO `eff_batch_control` (`ID`, `date`, `group_id`, `cutting_plan`, `cutting_start_time`, `cutting_end_time`, `target_eff_line_480`, `target_eff_acct_480`, `target_eff_line_450`, `target_eff_acct_450`, `shift_id`, `car_model_id`, `account_id`, `process_id`) VALUES
(1, '2018-02-06', 1, '', '00:00:00', '00:00:00', '80', '0', '90', '0', 1, 3, 1, 1),
(2, '2018-02-06', 1, '', '00:00:00', '00:00:00', '80', '0', '90', '0', 2, 3, 1, 1),
(3, '2018-02-07', 1, '', '00:00:00', '00:00:00', '70', '0', '80', '0', 1, 3, 1, 1),
(4, '2018-02-07', 1, '', '00:00:00', '00:00:00', '70', '0', '80', '0', 2, 3, 1, 1),
(20, '2018-02-19', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 1, 1, 1, 1),
(21, '2018-02-08', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 2, 3, 1, 1),
(22, '2018-02-20', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 1, 1, 1, 1),
(24, '2018-02-20', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 2, 1, 1, 1),
(25, '2018-02-20', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 1, 3, 1, 1),
(26, '2018-02-21', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 1, 1, 1, 1),
(27, '2018-02-22', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 1, 1, 1, 1),
(28, '2018-02-18', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 1, 3, 1, 1),
(29, '2018-02-18', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 2, 3, 1, 1),
(30, '2018-02-19', 1, '', '00:00:00', '00:00:00', '80', '', '', '', 1, 3, 1, 1),
(31, '2018-02-08', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, 1, 1),
(32, '2018-02-08', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 4, 1, 1),
(33, '2018-02-08', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 6, 1, 1),
(34, '2018-02-08', 1, '', '00:00:00', '00:00:00', '', '', '', '', 2, 6, 1, 1),
(35, '2018-02-28', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, 1, 1),
(36, '2018-02-09', 1, '', '00:00:00', '00:00:00', '95', '', '', '', 1, 3, 1, 1),
(40, '2018-03-03', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, 1, 1),
(41, '2018-03-03', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 2, 1, 1),
(42, '2018-03-03', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 2, 1, 1),
(43, '2018-03-02', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, 1, 1),
(44, '2018-03-02', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 2, 1, 1),
(45, '2018-03-02', 1, '', '00:00:00', '00:00:00', '', '', '', '', 2, 2, 1, 1),
(46, '2018-03-03', 1, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, 1, 1),
(48, '2018-03-05', 1, '', '00:00:00', '00:00:00', '98', '', '', '', 1, 3, 1, 1),
(49, '2018-03-07', 1, '', '00:00:00', '00:00:00', '60', '', '', '', 1, 1, 1, 1),
(50, '2018-03-07', 1, '', '00:00:00', '00:00:00', '60', '', '', '', 2, 1, 1, 1),
(51, '2018-03-07', 1, '', '00:00:00', '00:00:00', '60', '', '', '', 1, 3, 1, 1),
(55, '2018-03-10', NULL, '', '00:00:00', '00:00:00', '90', '80', '75', '70', 1, 3, 1, 1),
(56, '2018-03-10', NULL, '', '00:00:00', '00:00:00', '90', '80', '75', '70', 2, 3, 1, 1),
(57, '2018-03-13', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, 1, 1),
(58, '2018-03-14', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, 1, 1),
(59, '2018-03-13', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 2, 3, 1, 1),
(60, '2018-03-16', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `eff_batch_group`
--

CREATE TABLE `eff_batch_group` (
  `ID` int(11) NOT NULL,
  `target_line_480` int(11) NOT NULL,
  `target_acctg_480` int(11) NOT NULL,
  `target_line_450` int(11) NOT NULL,
  `target_acctg_450` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_batch_group`
--

INSERT INTO `eff_batch_group` (`ID`, `target_line_480`, `target_acctg_480`, `target_line_450`, `target_acctg_450`, `batch_id`, `group_id`) VALUES
(1, 81, 78, 98, 99, 57, 1),
(2, 78, 98, 89, 99, 57, 2),
(3, 90, 0, 0, 0, 58, 1);

-- --------------------------------------------------------

--
-- Table structure for table `eff_car_model`
--

CREATE TABLE `eff_car_model` (
  `ID` int(11) NOT NULL,
  `car_model_name` varchar(255) NOT NULL,
  `car_code` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_car_model`
--

INSERT INTO `eff_car_model` (`ID`, `car_model_name`, `car_code`) VALUES
(1, 'Daihatsu', '4568'),
(2, 'Honda', '4569'),
(3, 'Mazda J12', '4570'),
(4, 'Nissan', '4571'),
(5, 'Suzuki', '4572'),
(6, 'Toyota', '4573'),
(7, 'Mazda Merge', '4574');

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
  `pic_id` int(11) NOT NULL,
  `process_detail_id` int(11) NOT NULL,
  `dimension` varchar(255) NOT NULL,
  `time_start` time NOT NULL,
  `time_end` time NOT NULL,
  `time_total` int(11) NOT NULL,
  `mp_r1` int(11) NOT NULL,
  `mp_r3` int(11) NOT NULL,
  `group_id` int(11) DEFAULT NULL,
  `batch_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_downtime`
--

INSERT INTO `eff_downtime` (`ID`, `reason_id`, `part_wire`, `part_term_front`, `part_term_rear`, `pic_id`, `process_detail_id`, `dimension`, `time_start`, `time_end`, `time_total`, `mp_r1`, `mp_r3`, `group_id`, `batch_id`) VALUES
(5, 2, 'ABC', 'ZXC', 'QWE', 2, 1, '1', '09:15:00', '09:47:00', 32, 2, 2, NULL, 1),
(6, 1, '', '', '', 1, 5, '', '14:30:00', '15:00:00', 0, 0, 0, NULL, 1),
(7, 2, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, NULL, 1),
(8, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, NULL, 1),
(9, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, NULL, 1),
(13, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, NULL, 12),
(14, 7, '', '', '', 1, 1, '', '14:30:00', '15:00:00', 30, 0, 0, NULL, 3),
(15, 2, '', '', '', 2, 1, '', '00:00:00', '00:00:00', 0, 0, 0, NULL, 25),
(16, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, NULL, 25),
(17, 1, '', '', '', 1, 1, '', '00:00:00', '00:00:00', 0, 0, 0, NULL, 1),
(18, 1, '', '', '', 4, 1, '', '10:00:00', '10:30:00', 30, 0, 0, NULL, 36),
(19, 3, '', '', '', 1, 1, '', '13:00:00', '13:50:00', 50, 0, 0, NULL, 36),
(20, 4, 'sample', 'sample', 'sample', 2, 1, 'sample', '11:28:00', '11:28:00', 1, 1, 1, NULL, 51);

-- --------------------------------------------------------

--
-- Table structure for table `eff_group`
--

CREATE TABLE `eff_group` (
  `ID` int(11) NOT NULL,
  `group_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_group`
--

INSERT INTO `eff_group` (`ID`, `group_name`) VALUES
(1, 'A'),
(2, 'B'),
(3, 'C');

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
(11, 'QA'),
(12, 'test');

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
(6, 'QA Jr. Staff', 1, 1),
(8, 'OJT', 0, 1);

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
  `group_id` int(11) DEFAULT NULL,
  `batch_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_product_rep`
--

INSERT INTO `eff_product_rep` (`ID`, `product_no`, `std_time`, `output_qty`, `output_min`, `group_id`, `batch_id`) VALUES
(1, 'N243-67-010C(11)-6', '22.6499', '', '', NULL, 1),
(2, 'N247-67-010C(11)-6', '26.5913', '', '', NULL, 1),
(3, 'N255-67-010C(11)-6', '23.9555', '', '', NULL, 1),
(4, 'N256-67-010C(11)-6', '23.2354', '', '', NULL, 1),
(5, 'N257-67-010C(13)-4', '25.6251', '', '', NULL, 1),
(6, 'N258-67-010C(11)-6', '25.8712', '', '', NULL, 1),
(7, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 1),
(8, 'N261-67-SH0(2)-4', '0.2861', '', '', NULL, 1),
(9, 'NA1L-67-010C(14)-6', '25.3751', '', '', NULL, 1),
(3394, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 20),
(3395, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 20),
(3396, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 20),
(3397, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 20),
(3398, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 20),
(3399, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 20),
(3400, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 20),
(3401, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 20),
(3402, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 20),
(3404, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 20),
(3406, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 21),
(3407, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 21),
(3408, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 21),
(3409, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 21),
(3410, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 21),
(3411, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 21),
(3412, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 21),
(3413, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 21),
(3414, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 21),
(3458, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 24),
(3459, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 24),
(3460, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 24),
(3461, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 24),
(3462, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 24),
(3463, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 24),
(3464, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 24),
(3465, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 24),
(3466, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 24),
(3467, 'NA4M-67-290B(6)', '0.8982', '2', '', NULL, 24),
(3468, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 22),
(3469, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 22),
(3470, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 22),
(3471, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 22),
(3472, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 22),
(3473, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 22),
(3474, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 22),
(3475, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 22),
(3476, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 22),
(3477, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 22),
(3478, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 25),
(3479, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 25),
(3480, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 25),
(3481, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 25),
(3482, 'NA4M-67-290B(6)', '0.8982', '10', '', NULL, 25),
(3483, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 25),
(3484, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 26),
(3485, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 26),
(3486, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 26),
(3487, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 26),
(3488, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 26),
(3489, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 26),
(3490, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 26),
(3491, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 26),
(3492, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 26),
(3493, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 26),
(3494, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 27),
(3495, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 27),
(3496, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 27),
(3497, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 27),
(3498, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 27),
(3499, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 27),
(3500, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 27),
(3501, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 27),
(3502, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 27),
(3503, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 27),
(3504, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 27),
(3505, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 27),
(3506, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 27),
(3507, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 27),
(3508, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 27),
(3509, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 27),
(3510, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 27),
(3511, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 27),
(3512, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 27),
(3513, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 27),
(3514, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 28),
(3515, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 28),
(3516, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 28),
(3517, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 28),
(3518, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 28),
(3519, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 28),
(3520, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 28),
(3521, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 28),
(3522, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 28),
(3523, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 28),
(3524, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 29),
(3525, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 29),
(3526, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 29),
(3527, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 29),
(3528, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 29),
(3529, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 29),
(3530, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 29),
(3531, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 29),
(3532, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 29),
(3533, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 29),
(3534, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 30),
(3535, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 30),
(3536, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 30),
(3537, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 30),
(3538, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 30),
(3539, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 30),
(3540, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 30),
(3541, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 30),
(3542, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 30),
(3543, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 30),
(3544, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 2),
(3545, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 2),
(3546, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 2),
(3547, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 2),
(3548, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 2),
(3549, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 2),
(3550, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 2),
(3551, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 2),
(3552, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 2),
(3553, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 2),
(3554, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 2),
(3555, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 2),
(3556, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 2),
(3557, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 2),
(3558, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 2),
(3599, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 3),
(3600, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 3),
(3601, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 3),
(3602, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 3),
(3603, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 3),
(3604, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 3),
(3605, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 3),
(3606, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 3),
(3607, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 3),
(3608, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 3),
(3609, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 3),
(3610, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 3),
(3611, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 3),
(3612, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 3),
(3613, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 3),
(3614, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', NULL, 3),
(3615, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 3),
(3616, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 3),
(3617, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 3),
(3618, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 3),
(3619, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 4),
(3620, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 4),
(3621, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 4),
(3622, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 4),
(3623, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 4),
(3624, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 4),
(3625, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 4),
(3626, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 4),
(3627, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 4),
(3628, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 4),
(3629, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 31),
(3630, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 31),
(3631, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 31),
(3632, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 31),
(3633, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 31),
(3634, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 31),
(3635, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 31),
(3636, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 31),
(3637, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 31),
(3638, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 31),
(3639, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 32),
(3640, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 32),
(3641, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 32),
(3642, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 32),
(3643, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 32),
(3644, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 32),
(3645, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 32),
(3646, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 32),
(3647, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 32),
(3648, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 32),
(3649, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 32),
(3650, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 32),
(3651, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 32),
(3652, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 32),
(3653, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 32),
(3654, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', NULL, 32),
(3655, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 32),
(3656, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 32),
(3657, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 32),
(3658, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 32),
(3659, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 33),
(3660, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 33),
(3661, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 33),
(3662, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 33),
(3663, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 33),
(3664, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 33),
(3665, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 33),
(3666, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 33),
(3667, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 33),
(3668, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 33),
(3669, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 33),
(3670, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 33),
(3671, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 33),
(3672, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 33),
(3673, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 33),
(3674, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 34),
(3675, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 34),
(3676, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 34),
(3677, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 34),
(3678, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 34),
(3679, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 34),
(3680, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 34),
(3681, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 34),
(3682, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 34),
(3683, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 34),
(3684, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 34),
(3685, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 34),
(3686, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 34),
(3687, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 34),
(3688, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 34),
(3689, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', NULL, 34),
(3690, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 34),
(3691, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 34),
(3692, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 34),
(3693, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 34),
(7072, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 36),
(7073, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 36),
(7074, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 36),
(7075, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 36),
(7076, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 36),
(7077, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 36),
(7078, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 36),
(7079, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 36),
(7080, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 36),
(7081, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 36),
(7082, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 36),
(7083, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 36),
(7084, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 36),
(7085, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 36),
(7086, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 36),
(7137, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 40),
(7138, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 40),
(7139, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 40),
(7140, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 40),
(7141, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 40),
(7142, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 40),
(7143, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 40),
(7144, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 40),
(7145, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 40),
(7146, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 40),
(7147, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 40),
(7148, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 40),
(7149, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 40),
(7150, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 40),
(7151, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 40),
(7152, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 41),
(7153, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 41),
(7154, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 41),
(7155, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 41),
(7156, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 41),
(7157, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 41),
(7158, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 41),
(7159, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 41),
(7160, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 41),
(7161, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 41),
(7162, '', '', '', '', NULL, 42),
(7163, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 43),
(7164, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 43),
(7165, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 43),
(7166, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 43),
(7167, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 43),
(7168, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 43),
(7169, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 43),
(7170, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 43),
(7171, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 43),
(7172, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 43),
(7173, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 44),
(7174, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 44),
(7175, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 44),
(7176, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 44),
(7177, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 44),
(7178, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 44),
(7179, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 44),
(7180, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 44),
(7181, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 44),
(7182, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 44),
(7183, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 44),
(7184, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 44),
(7185, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 44),
(7186, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 44),
(7187, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 45),
(7188, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 45),
(7189, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 45),
(7190, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 45),
(7191, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 45),
(7192, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 45),
(7193, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 45),
(7194, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 45),
(7195, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 45),
(7196, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 45),
(7197, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 45),
(7198, 'NC6L-67-030A(7)-3-D', '22.9065', '12', '', NULL, 46),
(7199, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 46),
(7200, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 46),
(7201, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 46),
(7202, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 46),
(7203, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 46),
(7204, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 46),
(7205, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 46),
(7206, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 46),
(7207, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 46),
(7208, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 46),
(7209, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 46),
(7210, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 46),
(7211, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 46),
(7212, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', NULL, 46),
(7213, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 46),
(7214, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 46),
(7215, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 46),
(7216, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 46),
(7236, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 48),
(7237, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', NULL, 48),
(7238, 'NC8V-67-030A(7)-D', '18.7353', '5', '', NULL, 48),
(7239, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 48),
(7240, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 48),
(7241, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', NULL, 48),
(7242, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 48),
(7243, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 48),
(7244, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 48),
(7245, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 48),
(7246, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 48),
(7247, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 48),
(7248, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 48),
(7249, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 48),
(7250, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 48),
(7251, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', NULL, 48),
(7252, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 48),
(7253, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 48),
(7254, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 48),
(7255, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 48),
(7256, 'test', '5', '2', '', NULL, 48),
(7277, '33880-64P00(6)-P', '0', '', '', NULL, 49),
(7278, '33880-64P10(6)-P', '0', '', '', NULL, 49),
(7279, '33880-64P20(6)-P', '0', '', '', NULL, 49),
(7280, '33880-64P30(6)-P', '0', '', '', NULL, 49),
(7281, '33880-64P40(6)-P', '0', '', '', NULL, 49),
(7282, '33880-64P50(6)-P', '0', '', '', NULL, 49),
(7283, '36658-64P00(1)-P', '0.5572', '', '', NULL, 49),
(7284, '36680-64P00(3)-P', '1.2445', '', '', NULL, 49),
(7285, '36680-64P20(3)-P', '1.7721', '', '', NULL, 49),
(7286, '36680-64PB0(3)-P', '1.6641', '', '', NULL, 49),
(7287, '36680-64PC0(3)-P', '1.7682', '', '', NULL, 49),
(7288, '36680-64PA0(3)-P', '1.2416', '', '', NULL, 49),
(7289, '36680-64P10(3)-P', '1.6677', '', '', NULL, 49),
(7290, '36820-64P00(5)-P', '1.5728', '', '', NULL, 49),
(7291, '36820-64P10(5)-P', '1.9944', '', '', NULL, 49),
(7292, '36820-64P20(5)-P', '3.1435', '', '', NULL, 49),
(7293, '36820-64P40(5)-P', '3.2602', '', '', NULL, 49),
(7294, '36820-64PB0(5)-P', '1.9952', '', '', NULL, 49),
(7295, '36820-64PA0(5)-P', '1.5717', '', '', NULL, 49),
(7296, '36820-64PE0(5)-P', '3.2517', '', '', NULL, 49),
(7297, '36820-64PC0(5)-P', '3.1353', '', '', NULL, 49),
(7298, '33840-64P00-4-P', '0', '', '', NULL, 49),
(7299, '36810-64P00-4-P', '2.019', '', '', NULL, 49),
(7300, '36611-64P00-4-P', '0.2889', '', '', NULL, 49),
(7301, '36756-64P10(1)-1-P', '1.7502', '', '', NULL, 49),
(7302, '36756-64P00(1)-1-P', '0.5167', '', '', NULL, 49),
(7303, '36756-64P20(1)-1-P', '3.8587', '', '', NULL, 49),
(7304, '36756-64P50(1)-1-P', '0.31', '', '', NULL, 49),
(7305, '36756-64P40(1)-1-P', '4.1997', '', '', NULL, 49),
(7306, '36756-64P30(1)-1-P', '4.0913', '', '', NULL, 49),
(7307, '36757-64P00-6-P', '0.2067', '', '', NULL, 49),
(7308, '36757-64P10-6-P', '0.7386', '', '', NULL, 49),
(7309, '36757-64P20-6-P', '1.6553', '', '', NULL, 49),
(7310, '36757-64P30-6-P', '1.8882', '', '', NULL, 49),
(7311, '36757-64P40-6-P', '1.9907', '', '', NULL, 49),
(7312, '36064-64P00(6)-P', '21.0184', '', '', NULL, 49),
(7313, '36064-64P00(7)-P', '21.0184', '', '', NULL, 49),
(7314, '36064-64P10(6)-P', '22.483', '', '', NULL, 49),
(7315, '36064-64P10(7)-P', '22.483', '', '', NULL, 49),
(7316, '36064-64P20(6)-P', '24.1599', '55', '', NULL, 49),
(7317, '36064-64P20(7)-P', '24.1617', '', '', NULL, 49),
(7318, '36064-64P30(7)-P', '23.8696', '', '', NULL, 49),
(7319, '36064-64P30(6)-P', '23.8696', '', '', NULL, 49),
(7320, '36064-64P40(7)-P', '25.5482', '', '', NULL, 49),
(7321, '36064-64P40(6)-P', '25.5463', '', '', NULL, 49),
(7322, '36064-64P50(6)-P', '23.1798', '', '', NULL, 49),
(7323, '36064-64P50(7)-P', '23.1798', '', '', NULL, 49),
(7324, '36064-64P60(6)-P', '24.8418', '', '', NULL, 49),
(7325, '36064-64P60(7)-P', '24.8418', '', '', NULL, 49),
(7326, '36064-64P70(6)-P', '24.0132', '', '', NULL, 49),
(7327, '36064-64P70(7)-P', '24.0132', '', '', NULL, 49),
(7328, '36064-64P80(6)-P', '25.6753', '', '', NULL, 49),
(7329, '36064-64P80(7)-P', '25.6753', '', '', NULL, 49),
(7330, '36064-64P90(6)-P', '20.4578', '', '', NULL, 49),
(7331, '36064-64P90(7)-P', '20.4578', '25', '', NULL, 49),
(7332, '36064-64PA0(7)-P', '18.7926', '25', '', NULL, 49),
(7333, '36064-64PA0(6)-P', '18.7926', '', '', NULL, 49),
(7334, '36064-64PB0(7)-P', '27.8947', '', '', NULL, 49),
(7335, '36064-64PB0(6)-P', '27.8941', '', '', NULL, 49),
(7336, '36064-64PC0(6)-P', '28.0939', '', '', NULL, 49),
(7337, '36064-64PC0(7)-P', '28.0945', '', '', NULL, 49),
(7338, '36065-64P00(6)-P', '25.9342', '25', '', NULL, 49),
(7339, '36065-64P00(7)-P', '25.9342', '', '', NULL, 49),
(7340, '36065-64P10(6)-P', '26.134', '', '', NULL, 49),
(7341, '36065-64P10(7)-P', '26.134', '', '', NULL, 49),
(7342, '36065-64P20(6)-P', '30.2485', '50', '', NULL, 49),
(7343, '36065-64P20(7)-P', '30.2485', '25', '', NULL, 49),
(7344, '36065-64P30(6)-P', '30.4483', '', '', NULL, 49),
(7345, '36065-64P40(6)-P', '33.08', '', '', NULL, 49),
(7346, '36065-64P30(7)-P', '30.4483', '', '', NULL, 49),
(7347, '36065-64P40(7)-P', '33.08', '', '', NULL, 49),
(7348, '36065-64P50(6)-P', '33.2799', '', '', NULL, 49),
(7349, '36065-64P60(6)-P', '25.9339', '', '', NULL, 49),
(7350, '36065-64P50(7)-P', '33.2799', '', '', NULL, 49),
(7351, '36065-64P70(6)-P', '26.1338', '', '', NULL, 49),
(7352, '36065-64P60(7)-P', '25.9339', '', '', NULL, 49),
(7353, '36065-64P80(6)-P', '22.5869', '35', '', NULL, 49),
(7354, '36065-64P70(7)-P', '26.1338', '', '', NULL, 49),
(7355, '36065-64P80(7)-P', '22.5869', '', '', NULL, 49),
(7356, '36065-64P90(6)-P', '24.2637', '25', '', NULL, 49),
(7357, '36065-64PA0(6)-P', '24.1107', '', '', NULL, 49),
(7358, '36065-64P90(7)-P', '24.2655', '', '', NULL, 49),
(7359, '36065-64PB0(6)-P', '24.0984', '', '', NULL, 49),
(7360, '36065-64PA0(7)-P', '24.1107', '', '', NULL, 49),
(7361, '36065-64PB0(7)-P', '24.0984', '', '', NULL, 49),
(7362, '36065-64PC0(6)-P', '24.4778', '25', '', NULL, 49),
(7363, '36065-64PC0(7)-P', '24.4778', '', '', NULL, 49),
(7364, '36065-64PD0(6)-P', '26.1546', '', '', NULL, 49),
(7365, '36065-64PE0(6)-P', '18.3924', '', '', NULL, 49),
(7366, '36065-64PD0(7)-P', '26.1565', '', '', NULL, 49),
(7367, '36065-64PG0(6)-P', '19.2084', '', '', NULL, 49),
(7368, '36065-64PH0(6)-P', '20.8708', '', '', NULL, 49),
(7369, '36065-64PJ0(6)-P', '20.6835', '20', '', NULL, 49),
(7370, '36065-64PF0(6)-P', '16.73', '', '', NULL, 49),
(7371, '36065-64PJ0(7)-P', '20.6835', '', '', NULL, 49),
(7372, '36065-64PK0(6)-P', '22.3485', '', '', NULL, 49),
(7373, '36065-64PL0(6)-P', '21.0204', '', '', NULL, 49),
(7374, '36065-64PK0(7)-P', '22.3485', '', '', NULL, 49),
(7375, '36065-64PM0(6)-P', '23.5167', '', '', NULL, 49),
(7376, '36065-64PL0(7)-P', '21.0204', '', '', NULL, 49),
(7377, '36065-64PM0(7)-P', '23.5167', '', '', NULL, 49),
(7378, '36065-64PQ0(6)-P', '21.7734', '', '', NULL, 49),
(7379, '36065-64PP0(6)-P', '23.5044', '', '', NULL, 49),
(7380, '36065-64PQ0(7)-P', '21.7734', '', '', NULL, 49),
(7381, '36065-64PP0(7)-P', '23.5044', '25', '', NULL, 49),
(7382, '36065-64PR0(6)-P', '23.4354', '', '', NULL, 49),
(7383, '36065-64PR0(7)-P', '23.4354', '30', '', NULL, 49),
(7384, '36065-64PS0(6)-P', '22.1026', '', '', NULL, 49),
(7385, '36065-64PS0(7)-P', '22.1026', '', '', NULL, 49),
(7386, '36065-64PU0(7)-P', '23.7646', '', '', NULL, 49),
(7387, '36065-64PU0(6)-P', '23.7646', '', '', NULL, 49),
(7388, '36605-64P00(3)-1-P', '5.9654', '', '', NULL, 49),
(7389, '36605-64P10(3)-1-P', '5.7383', '', '', NULL, 49),
(7390, '36605-64P20(3)-1-P', '6.5215', '', '', NULL, 49),
(7391, '36605-64P30(3)-1-P', '6.2941', '', '', NULL, 49),
(7392, '33850-74P00(3)-P', '0', '', '', NULL, 49),
(7393, '33850-74P20(3)-P', '0', '', '', NULL, 49),
(7394, '33880-74PA0(3)-P', '0', '', '', NULL, 49),
(7395, '33880-74PB0(3)-P', '0', '', '', NULL, 49),
(7396, '33880-74PC0(3)-P', '0', '', '', NULL, 49),
(7397, '33880-54SC0(5)-P', '0', '', '', NULL, 49),
(7398, '36680-74P10(1)-P', '1.2554', '20', '', NULL, 49),
(7399, '36680-74P00(1)-P', '0.9407', '100', '', NULL, 49),
(7400, '36680-74P20(1)-P', '1.4593', '', '', NULL, 49),
(7401, '36680-74P30(1)-P', '1.5657', '', '', NULL, 49),
(7402, '36820-74P00(4)-P', '0.3181', '', '', NULL, 49),
(7403, '36680-74P50(1)-P', '1.2554', '20', '', NULL, 49),
(7404, '36820-74P10(4)-P', '0.7397', '', '', NULL, 49),
(7405, '36820-74P30(4)-P', '0.7369', '', '', NULL, 49),
(7406, '36882-74P00-6-P', '0.341', '', '', NULL, 49),
(7407, '36843-74P00(1)-P', '1.1936', '120', '', NULL, 49),
(7408, '36843-74P10(1)-P', '1.4259', '40', '', NULL, 49),
(7409, '36756-74P00(1)-2-P', '0.7184', '', '', NULL, 49),
(7410, '36756-74P20(1)-2-P', '4.2267', '', '', NULL, 49),
(7411, '36756-74P10(1)-2-P', '2.522', '', '', NULL, 49),
(7412, '36757-74P00(2)-P', '0.4081', '', '', NULL, 49),
(7413, '36756-74P40(1)-2-P', '4.0202', '', '', NULL, 49),
(7414, '36756-74P30(1)-2-P', '1.4304', '', '', NULL, 49),
(7415, '36757-74P10(2)-P', '0.9361', '', '', NULL, 49),
(7416, '36757-74P40(2)-P', '1.7458', '', '', NULL, 49),
(7417, '36757-74P20(2)-P', '1.9494', '', '', NULL, 49),
(7418, '36751-74P00(3)-P', '0.2068', '110', '', NULL, 49),
(7419, '36751-74P10(3)-P', '0.7374', '210', '', NULL, 49),
(7420, '36602-74P10(11)-P', '22.6124', '', '', NULL, 49),
(7421, '36602-74P00(11)-P', '22.0961', '', '', NULL, 49),
(7422, '36602-74P20(11)-P', '16.4087', '', '', NULL, 49),
(7423, '36602-74P30(11)-P', '17.1943', '', '', NULL, 49),
(7424, '36602-74P40(11)-P', '16.9253', '', '', NULL, 49),
(7425, '36602-74P60(11)-P', '17.1756', '', '', NULL, 49),
(7426, '36602-74P50(11)-P', '17.7109', '', '', NULL, 49),
(7427, '36602-74P80(11)-P', '12.7524', '12', '', NULL, 49),
(7428, '36602-74P70(11)-P', '20.494', '', '', NULL, 49),
(7429, '36602-74P90(11)-P', '14.5826', '', '', NULL, 49),
(7430, '36620-74P00(11)-P', '11.9423', '', '', NULL, 49),
(7431, '36620-74P10-8-P', '0', '', '', NULL, 49),
(7432, '36620-74P20(11)-P', '13.895', '', '', NULL, 49),
(7433, '36620-74P30(11)-P', '13.7726', '', '', NULL, 49),
(7434, '36620-74P40(11)-P', '15.5154', '', '', NULL, 49),
(7435, '36620-74P50(11)-P', '15.3683', '', '', NULL, 49),
(7436, '36620-74P60(11)-P', '16.3011', '', '', NULL, 49),
(7437, '36620-74P80(11)-P', '15.9271', '', '', NULL, 49),
(7438, '36620-74P70(11)-P', '15.8675', '', '', NULL, 49),
(7439, '36620-74PA0(11)-P', '21.0253', '6', '', NULL, 49),
(7440, '36620-74P90(11)-P', '16.6531', '', '', NULL, 49),
(7441, '36620-74PB0(11)-P', '22.7226', '', '', NULL, 49),
(7442, '36620-74PD0-8-P', '0', '', '', NULL, 49),
(7443, '36620-74PG0(11)-P', '15.7845', '', '', NULL, 49),
(7444, '36620-74PE0(11)-P', '14.9988', '', '', NULL, 49),
(7445, '36620-74PF0-8-P', '0', '', '', NULL, 49),
(7446, '36620-74PC0(11)-P', '13.3784', '12', '', NULL, 49),
(7447, '36620-74PH0(11)-P', '15.3512', '42', '', NULL, 49),
(7448, '36620-74PJ0(11)-P', '20.5091', '', '', NULL, 49),
(7449, '36620-74PL0(11)-P', '21.0106', '', '', NULL, 49),
(7450, '36620-74PM0(11)-P', '21.5268', '', '', NULL, 49),
(7451, '36620-74PN0(11)-P', '22.5045', '', '', NULL, 49),
(7452, '36620-74PK0(11)-P', '22.2064', '', '', NULL, 49),
(7453, '36620-74PP0(11)-P', '23.0207', '', '', NULL, 49),
(7454, '36620-74PQ0(11)-P', '17.0111', '', '', NULL, 49),
(7455, '36620-74PR0(11)-P', '17.2806', '12', '', NULL, 49),
(7456, '36602-54S60-X3-P', '17.1826', '', '', NULL, 49),
(7457, '36620-74PS0(11)-P', '17.7968', '', '', NULL, 49),
(7458, '36602-54S00-X3-P', '22.1162', '', '', NULL, 49),
(7459, '36620-74PU0(11)-P', '16.4949', '', '', NULL, 49),
(7460, '36602-54S10-X3-P', '22.6318', '', '', NULL, 49),
(7461, '36602-54S70-X3-P', '20.5147', '', '', NULL, 49),
(7462, '36620-54S00-X3-P', '12.7524', '', '', NULL, 49),
(7463, '36620-54S30-X3-P', '14.5951', '', '', NULL, 49),
(7464, '36620-54S60-X3-P', '16.3135', '', '', NULL, 49),
(7465, '36620-54S20-X3-P', '13.895', '', '', NULL, 49),
(7466, '36620-54S40-X3-P', '15.5278', '', '', NULL, 49),
(7467, '36620-54S50-X3-P', '15.3807', '', '', NULL, 49),
(7468, '36620-54S70-X3-P', '15.8668', '', '', NULL, 49),
(7469, '36620-54S80-X3-P', '15.9271', '', '', NULL, 49),
(7470, '36620-54SA0-X3-P', '21.0306', '', '', NULL, 49),
(7471, '36620-54SE0-X3-P', '15.0113', '', '', NULL, 49),
(7472, '36620-54S90-X3-P', '16.6525', '', '', NULL, 49),
(7473, '36620-54SC0-X3-P', '13.3784', '', '', NULL, 49),
(7474, '36620-54SG0-X3-P', '15.7969', '', '', NULL, 49),
(7475, '36620-54SH0-X3-P', '15.3512', '', '', NULL, 49),
(7476, '36620-54SJ0-X3-P', '20.5149', '', '', NULL, 49),
(7477, '36620-54SM0-X3-P', '21.5469', '', '', NULL, 49),
(7478, '36620-54SQ0-X3-P', '17.0105', '', '', NULL, 49),
(7479, '36620-54SL0-X3-P', '21.0313', '', '', NULL, 49),
(7480, '36620-54SR0-X3-P', '17.2806', '', '', NULL, 49),
(7481, '36620-54SS0-X3-P', '17.7962', '', '', NULL, 49),
(7482, '36630-74P20(7)-P', '5.3164', '', '', NULL, 49),
(7483, '36620-54SU0-X3-P', '16.4949', '', '', NULL, 49),
(7484, '36630-74P10(7)-P', '4.455', '', '', NULL, 49),
(7485, '36630-74P00(7)-P', '4.2247', '', '', NULL, 49),
(7486, '36630-74P30(7)-P', '5.7561', '', '', NULL, 49),
(7487, '36630-74P70(7)-P', '5.8571', '', '', NULL, 49),
(7488, '36630-74P50(7)-P', '5.0142', '', '', NULL, 49),
(7489, '36630-74P40(7)-P', '4.7839', '24', '', NULL, 49),
(7490, '36630-74P60(7)-P', '5.4173', '12', '', NULL, 49),
(7491, '36630-74P80(7)-P', '7.1904', '45', '', NULL, 49),
(7492, '36630-74P90(7)-P', '7.6251', '', '', NULL, 49),
(7493, '36630-74PB0(7)-P', '9.304', '', '', NULL, 49),
(7494, '36630-74PD0(7)-P', '9.0307', '', '', NULL, 49),
(7495, '36630-74PC0(7)-P', '8.7041', '', '', NULL, 49),
(7496, '36630-74PE0(7)-P', '7.4207', '', '', NULL, 49),
(7497, '36630-74PA0(7)-P', '9.0996', '', '', NULL, 49),
(7498, '36630-74PF0(7)-P', '6.3981', '', '', NULL, 49),
(7499, '36630-74PG0(7)-P', '6.6075', '', '', NULL, 49),
(7500, '36630-74PJ0(7)-P', '8.4024', '', '', NULL, 49),
(7501, '36630-74PH0(7)-P', '8.2801', '', '', NULL, 49),
(7502, '36630-74PK0(7)-P', '8.4947', '', '', NULL, 49),
(7503, '36630-74PL0(7)-P', '8.617', '', '', NULL, 49),
(7504, '36630-54S00-P', '4.2137', '', '', NULL, 49),
(7505, '36630-54S10-P', '4.444', '', '', NULL, 49),
(7506, '36630-54S60-X3-P', '5.4112', '', '', NULL, 49),
(7507, '36630-54S30-X3-P', '5.7499', '', '', NULL, 49),
(7508, '36630-54S40-X3-P', '4.7727', '', '', NULL, 49),
(7509, '36630-54S50-X3-P', '5.003', '', '', NULL, 49),
(7510, '36630-54S20-X3-P', '5.3102', '', '', NULL, 49),
(7511, '36630-54S70-X3-P', '5.8509', '', '', NULL, 49),
(7512, '36630-54S90-X3-P', '7.6185', '', '', NULL, 49),
(7513, '36630-54SA0-X3-P', '8.975', '', '', NULL, 49),
(7514, '36630-54SB0-X3-P', '9.1793', '', '', NULL, 49),
(7515, '36630-54SC0-X3-P', '8.6937', '', '', NULL, 49),
(7516, '36630-54S80-X3-P', '7.1839', '', '', NULL, 49),
(7517, '36630-54SD0-X3-P', '9.0203', '', '', NULL, 49),
(7518, '36630-54SH0-X3-P', '8.2695', '', '', NULL, 49),
(7519, '36630-54SJ0-X3-P', '8.3918', '', '', NULL, 49),
(7520, '36630-54SK0-X3-P', '8.3705', '', '', NULL, 49),
(7521, '36630-54SL0-X3-P', '8.4928', '', '', NULL, 49),
(7522, '36630-54SE0-X3-P', '7.4142', '', '', NULL, 49),
(7523, '36680-81P00(1)-2-P', '2.5975', '', '', NULL, 49),
(7524, '36680-81P10(1)-2-P', '2.5975', '', '', NULL, 49),
(7525, '36680-81PH0(1)-2-P', '2.5975', '', '', NULL, 49),
(7526, '36680-57S00-1-P', '2.5975', '', '', NULL, 49),
(7527, '36680-57S10-1-P', '2.5975', '', '', NULL, 49),
(7528, '36882-81P00(2)-P', '0.3603', '', '', NULL, 49),
(7529, '36843-57S00-1-P', '1.4737', '', '', NULL, 49),
(7530, '36843-57S10-1-P', '1.5015', '', '', NULL, 49),
(7531, '36843-57SA0-P', '0.3233', '', '', NULL, 49),
(7532, '36756-81P20(3)-2-P', '4.2933', '', '', NULL, 49),
(7533, '36756-81P00(3)-2-P', '4.1785', '', '', NULL, 49),
(7534, '36756-81P10(3)-2-P', '4.1785', '', '', NULL, 49),
(7535, '36756-81P30(3)-2-P', '4.2933', '', '', NULL, 49),
(7536, '36756-57S20-1-P', '4.3968', '', '', NULL, 49),
(7537, '36756-57S00-1-P', '4.282', '', '', NULL, 49),
(7538, '36756-57S10-1-P', '4.282', '', '', NULL, 49),
(7539, '36756-57S30-1-P', '4.3968', '', '', NULL, 49),
(7540, '36757-81P00(3)-1-P', '1.8462', '', '', NULL, 49),
(7541, '36757-81P10(3)-1-P', '1.8462', '', '', NULL, 49),
(7542, '36757-81P20(3)-1-P', '1.9495', '', '', NULL, 49),
(7543, '36757-81P30(3)-1-P', '1.9495', '', '', NULL, 49),
(7544, '36751-81P00(1)-P', '0.4256', '', '', NULL, 49),
(7545, '36751-81P20(1)-P', '1.4205', '', '', NULL, 49),
(7546, '36751-81PA0(2)-P', '0.4256', '', '', NULL, 49),
(7547, '36751-81PC0(2)-P', '1.4205', '', '', NULL, 49),
(7548, '36630-81P00(11)-P', '10.8939', '', '', NULL, 49),
(7549, '36603-81P40(11)-P', '17.1465', '', '', NULL, 49),
(7550, '36603-81P20(11)-P', '15.7831', '', '', NULL, 49),
(7551, '36630-81PC0(11)-P', '13.2712', '', '', NULL, 49),
(7552, '36630-81P10(11)-P', '11.3193', '', '', NULL, 49),
(7553, '36630-81PD0(11)-P', '13.4844', '', '', NULL, 49),
(7554, '36630-81PE0(11)-P', '14.6345', '', '', NULL, 49),
(7555, '36630-81PG0(11)-P', '14.9869', '', '', NULL, 49),
(7556, '36630-81PK0(11)-P', '13.127', '', '', NULL, 49),
(7557, '36630-81PJ0(11)-P', '10.1619', '', '', NULL, 49),
(7558, '36603-57S60-1-P', '18.4889', '', '', NULL, 49),
(7559, '36630-81PL0(11)-P', '13.3402', '', '', NULL, 49),
(7560, '36603-57S20-1-P', '16.3457', '', '', NULL, 49),
(7561, '36603-57S80-1-P', '20.6385', '', '', NULL, 49),
(7562, '36630-57S00-1-P', '11.239', '', '', NULL, 49),
(7563, '36630-57S10-1-P', '11.6701', '', '', NULL, 49),
(7564, '36630-57S20-1-P', '13.379', '', '', NULL, 49),
(7565, '36630-57SC0-1-P', '13.6169', '', '', NULL, 49),
(7566, '36630-57S30-1-P', '13.8101', '', '', NULL, 49),
(7567, '36630-57SE0-1-P', '14.749', '', '', NULL, 49),
(7568, '36630-57SD0-1-P', '13.8358', '', '', NULL, 49),
(7569, '36630-57SG0-1-P', '15.1009', '', '', NULL, 49),
(7570, '36630-57SH0-1-P', '15.7568', '', '', NULL, 49),
(7571, '36630-57SK0-1-P', '17.9063', '', '', NULL, 49),
(7572, '36630-57SJ0-1-P', '15.9758', '', '', NULL, 49),
(7573, '36630-57SL0-1-P', '18.2584', '', '', NULL, 49),
(7574, '36680-80P00(1)-1-P', '1.3835', '', '', NULL, 49),
(7575, '36680-80P10(1)-1-P', '1.7006', '30', '', NULL, 49),
(7576, '36680-80P20(1)-1-P', '1.3835', '40', '', NULL, 49),
(7577, '36680-80P30(1)-1-P', '1.7006', '', '', NULL, 49),
(7578, '36820-80P00-4-P', '0.7451', '20', '', NULL, 49),
(7579, '36820-80P20-4-P', '1.1506', '', '', NULL, 49),
(7580, '36820-80P10-4-P', '1.0532', '40', '', NULL, 49),
(7581, '36820-80P30-4-P', '1.4587', '40', '', NULL, 49),
(7582, '39312-80P00-P', '0.096', '', '', NULL, 49),
(7583, '36620-80P10(5)-P', '19.6927', '', '', NULL, 49),
(7584, '36620-80P00(5)-P', '18.9777', '', '', NULL, 49),
(7585, '36620-80P20(5)-P', '20.7791', '', '', NULL, 49),
(7586, '36620-80P30(5)-P', '21.4941', '', '', NULL, 49),
(7587, '36620-80P40(5)-P', '18.0335', '', '', NULL, 49),
(7588, '36620-80P50(5)-P', '18.7486', '', '', NULL, 49),
(7589, '36620-80P60(5)-P', '19.8349', '', '', NULL, 49),
(7590, '36620-80P70(5)-P', '20.55', '', '', NULL, 49),
(7591, '36620-80P80(5)-P', '20.3567', '', '', NULL, 49),
(7592, '36620-80P90(5)-P', '21.071', '', '', NULL, 49),
(7593, '36620-80PA0(5)-P', '22.1581', '', '', NULL, 49),
(7594, '36620-80PB0(5)-P', '22.8724', '', '', NULL, 49),
(7595, '36620-80PC0(5)-P', '18.4431', '', '', NULL, 49),
(7596, '36620-80PD0(5)-P', '19.8045', '', '', NULL, 49),
(7597, '36620-80PJ0(5)-P', '20.8689', '', '', NULL, 49),
(7598, '36620-80PK0(5)-P', '22.4669', '', '', NULL, 49),
(7599, '36630-80P00(4)-P', '9.1541', '', '', NULL, 49),
(7600, '36630-80P10(4)-P', '9.3582', '18', '', NULL, 49),
(7601, '36630-80P20(4)-P', '9.1541', '', '', NULL, 49),
(7602, '36630-80P30(4)-P', '9.3582', '', '', NULL, 49),
(7603, '36630-80P40(4)-P', '9.539', '', '', NULL, 49),
(7604, '36630-80P50(4)-P', '9.8686', '36', '', NULL, 49),
(7605, '36630-80P70(4)-P', '9.8686', '24', '', NULL, 49),
(7606, '36630-80P60(4)-P', '9.539', '6', '', NULL, 49),
(7607, '36630-80P80(4)-P', '7.9313', '6', '', NULL, 49),
(7608, '36630-80P90(4)-P', '8.1416', '12', '', NULL, 49),
(7609, '36630-80PE0(4)-P', '9.7431', '', '', NULL, 49),
(7610, '36630-80PF0(4)-P', '9.7431', '', '', NULL, 49),
(7611, '36620-52R00(4)-P', '19.1654', '', '', NULL, 49),
(7612, '36620-52R20(4)-P', '22.095', '', '', NULL, 49),
(7613, '36620-52R30(4)-P', '23.2294', '15', '', NULL, 49),
(7614, '36620-52R40(4)-P', '21.4351', '', '', NULL, 49),
(7615, '36620-52R50(4)-P', '22.86', '', '', NULL, 49),
(7616, '36620-52R80(4)-P', '24.3191', '', '', NULL, 49),
(7617, '36620-52RA0(4)-P', '23.1024', '20', '', NULL, 49),
(7618, '36620-52R90(4)-P', '25.4535', '', '', NULL, 49),
(7619, '36620-52RB0(4)-P', '24.2367', '15', '', NULL, 49),
(7620, '36620-52RM0(4)-P', '25.9454', '', '', NULL, 49),
(7621, '36620-52RC0(4)-P', '20.1649', '', '', NULL, 49),
(7622, '36620-52RG0(4)-P', '22.5973', '', '', NULL, 49),
(7623, '36620-52RH0(4)-P', '23.7183', '', '', NULL, 49),
(7624, '36620-52RL0(4)-P', '24.8245', '', '', NULL, 49),
(7625, '36620-52RP0(4)-P', '22.2727', '', '', NULL, 49),
(7626, '36620-52RQ0(4)-P', '20.1445', '15', '', NULL, 49),
(7627, '36620-52RR0(4)-P', '23.087', '', '', NULL, 49),
(7628, '36620-53R20(4)-P', '17.5067', '', '', NULL, 49),
(7629, '36620-53R40(4)-P', '15.6893', '', '', NULL, 49),
(7630, '36620-53R50(4)-P', '18.6634', '', '', NULL, 49),
(7631, '36620-53R30(4)-P', '19.1209', '', '', NULL, 49),
(7632, '36620-53R60(4)-P', '19.3892', '25', '', NULL, 49),
(7633, '36620-53R70(4)-P', '20.2516', '', '', NULL, 49),
(7634, '36620-53R90(4)-P', '22.9794', '', '', NULL, 49),
(7635, '36620-53RA0(4)-P', '19.4373', '15', '', NULL, 49),
(7636, '36620-53RB0(4)-P', '24.5025', '', '', NULL, 49),
(7637, '36620-53RC0(4)-P', '24.6063', '', '', NULL, 49),
(7638, '36620-53RD0(4)-P', '25.2132', '', '', NULL, 49),
(7639, '36620-53RE0(4)-P', '25.317', '', '', NULL, 49),
(7640, '36620-53RF0(4)-P', '17.6104', '', '', NULL, 49),
(7641, '36620-53RG0(4)-P', '19.2246', '15', '', NULL, 49),
(7642, '36620-53RH0(4)-P', '18.7671', '', '', NULL, 49),
(7643, '36620-68R00(1)-P', '21.2855', '', '', NULL, 49),
(7644, '36620-53RJ0(4)-P', '19.4929', '20', '', NULL, 49),
(7645, '36620-68R10(1)-P', '23.8117', '25', '', NULL, 49),
(7646, '36620-68R20(1)-P', '24.946', '30', '', NULL, 49),
(7647, '36620-68R60(1)-P', '22.9755', '', '', NULL, 49),
(7648, '36620-68R50(1)-P', '22.8718', '', '', NULL, 49),
(7649, '36620-68R80(1)-P', '23.1715', '', '', NULL, 49),
(7650, '36620-68R70(1)-P', '23.0678', '', '', NULL, 49),
(7651, '36620-68R90(1)-P', '24.283', '', '', NULL, 49),
(7652, '36620-68RA0(1)-P', '24.3867', '', '', NULL, 49),
(7653, '36602-53R00(4)-P', '13.5514', '', '', NULL, 49),
(7654, '36620-68RB0(1)-P', '25.1002', '', '', NULL, 49),
(7655, '36620-68RC0(1)-P', '25.2039', '', '', NULL, 49),
(7656, '36602-53R10(4)-P', '16.4214', '', '', NULL, 49),
(7657, '36602-53R20(4)-P', '17.8433', '', '', NULL, 49),
(7658, '36602-53R30(4)-P', '15.6822', '', '', NULL, 49),
(7659, '36602-53R40(4)-P', '17.9609', '', '', NULL, 49),
(7660, '36602-53R51(4)-P', '19.0584', '', '', NULL, 49),
(7661, '36602-53R80(4)-P', '21.2114', '', '', NULL, 49),
(7662, '36602-53R70(4)-P', '19.876', '', '', NULL, 49),
(7663, '36602-53R90(4)-P', '22.4956', '', '', NULL, 49),
(7664, '36602-53RC0(4)-P', '23.7968', '', '', NULL, 49),
(7665, '36602-53RE0(4)-P', '24.4899', '', '', NULL, 49),
(7666, '36602-53RG0(4)-P', '17.3762', '', '', NULL, 49),
(7667, '36602-53RD0(4)-P', '23.9008', '', '', NULL, 49),
(7668, '36602-53RF0(4)-P', '24.594', '', '', NULL, 49),
(7669, '36602-53RH0(4)-P', '20.1715', '', '', NULL, 49),
(7670, '36602-53RL0(4)-P', '18.3526', '', '', NULL, 49),
(7671, '36602-53RJ1(4)-P', '18.4566', '', '', NULL, 49),
(7672, '36602-53RK1(4)-P', '19.1624', '', '', NULL, 49),
(7673, '36602-68R40(1)-P', '23.5897', '', '', NULL, 49),
(7674, '36602-68R00(1)-P', '22.3647', '', '', NULL, 49),
(7675, '36602-68R10(1)-P', '22.4687', '', '', NULL, 49),
(7676, '36602-68R50(1)-P', '23.6938', '', '', NULL, 49),
(7677, '36602-68R60(1)-P', '24.3847', '', '', NULL, 49),
(7678, '36602-68R80(1)-P', '19.5801', '', '', NULL, 49),
(7679, '36602-68R70(1)-P', '24.4888', '', '', NULL, 49),
(7680, '36620-57R00-2-P', '12.8569', '', '', NULL, 49),
(7681, '36602-68R90(1)-P', '21.2109', '', '', NULL, 49),
(7682, '36620-57R10-2-P', '15.8752', '25', '', NULL, 49),
(7683, '36620-57R20-2-P', '20.9983', '30', '', NULL, 49),
(7684, '36620-57R30-2-P', '15.4729', '', '', NULL, 49),
(7685, '36620-57R50-2-P', '19.4717', '', '', NULL, 49),
(7686, '36620-57R60-2-P', '14.6578', '', '', NULL, 49),
(7687, '36620-57R40-2-P', '20.2868', '', '', NULL, 49),
(7688, '36602-57R00-2-P', '15.2379', '', '', NULL, 49),
(7689, '36602-57R10-2-P', '20.0515', '', '', NULL, 49),
(7690, '36602-57R30-2-P', '14.4414', '', '', NULL, 49),
(7691, '33880-63RC0-1-P', '0', '', '', NULL, 49),
(7692, '36602-57R20-2-P', '19.255', '', '', NULL, 49),
(7693, '33880-79R00-2-P', '0', '', '', NULL, 49),
(7694, '36680-79R00-3-P', '1.9303', '', '', NULL, 49),
(7695, '36680-79R20-3-P', '2.3448', '', '', NULL, 49),
(7696, '36680-79R30-3-P', '2.3448', '', '', NULL, 49),
(7697, '36820-79R10-4-P', '0.9698', '', '', NULL, 49),
(7698, '36820-79R20-4-P', '0.8751', '', '', NULL, 49),
(7699, '36820-79R00-4-P', '0.6567', '', '', NULL, 49),
(7700, '36820-79R30-4-P', '1.1882', '', '', NULL, 49),
(7701, '36820-79R50-4-P', '1.398', '100', '', NULL, 49),
(7702, '36820-79R40-4-P', '1.0848', '', '', NULL, 49),
(7703, '36820-79R70-4-P', '1.6164', '480', '', NULL, 49),
(7704, '36813-79R50-P', '0.4296', '', '', NULL, 49),
(7705, '36820-79R60-4-P', '1.3032', '', '', NULL, 49),
(7706, '36813-79R00-2-P', '1.4487', '600', '', NULL, 49),
(7707, '36756-79R00-4-P', '3.9272', '390', '', NULL, 49),
(7708, '36756-79R40-4-P', '4.2364', '', '', NULL, 49),
(7709, '36756-79R50-4-P', '4.4388', '', '', NULL, 49),
(7710, '36756-79R20-4-P', '4.2298', '', '', NULL, 49),
(7711, '36756-79R30-4-P', '4.2298', '', '', NULL, 49),
(7712, '36756-79R60-4-P', '4.6712', '', '', NULL, 49),
(7713, '36756-79R90-4-P', '4.2364', '', '', NULL, 49),
(7714, '36757-79R00-3-P', '1.6573', '', '', NULL, 49),
(7715, '36756-79R70-4-P', '4.6712', '', '', NULL, 49),
(7716, '36756-79R80-4-P', '4.4388', '', '', NULL, 49),
(7717, '36757-79R20-3-P', '1.9607', '', '', NULL, 49),
(7718, '36757-79R30-3-P', '2.1637', '', '', NULL, 49),
(7719, '36757-79R40-3-P', '2.3962', '', '', NULL, 49),
(7720, '36757-79R70-3-P', '1.9607', '80', '', NULL, 49),
(7721, '36757-79R60-3-P', '2.1637', '', '', NULL, 49),
(7722, '36751-79R00-3-P', '0.4217', '', '', NULL, 49),
(7723, '36757-79R50-3-P', '2.3962', '', '', NULL, 49),
(7724, '36751-79R10-3-P', '1.4114', '', '', NULL, 49),
(7725, '36751-79RC0-3-P', '1.4114', '', '', NULL, 49),
(7726, '36620-79R00-4-P', '21.5177', '', '', NULL, 49),
(7727, '36690-79R00-1-P', '0.2', '', '', NULL, 49),
(7728, '36602-79R00-4-P', '19.5992', '300', '', NULL, 49),
(7729, '36602-79R20-4-P', '22.626', '', '', NULL, 49),
(7730, '36620-79R10-4-P', '23.7428', '70', '', NULL, 49),
(7731, '36620-79R20-4-P', '23.8338', '', '', NULL, 49),
(7732, '36620-79R40-4-P', '23.3356', '', '', NULL, 49),
(7733, '36620-79R50-4-P', '25.5718', '', '', NULL, 49),
(7734, '36620-79R60-4-P', '24.2299', '', '', NULL, 49),
(7735, '36620-79R70-4-P', '26.2596', '', '', NULL, 49),
(7736, '36620-79R30-4-P', '26.0699', '', '', NULL, 49),
(7737, '36620-79R80-4-P', '26.546', '', '', NULL, 49),
(7738, '36620-79RA0-4-P', '26.0478', '', '', NULL, 49),
(7739, '36620-79RB0-4-P', '28.0886', '', '', NULL, 49),
(7740, '36620-79RD0-4-P', '26.4517', '', '', NULL, 49),
(7741, '36620-79R90-4-P', '28.5867', '', '', NULL, 49),
(7742, '36620-79RC0-4-P', '23.7395', '', '', NULL, 49),
(7743, '36620-79RE0-4-P', '23.117', '', '', NULL, 49),
(7744, '36620-79RG0-4-P', '25.4331', '', '', NULL, 49),
(7745, '36620-79RF0-4-P', '25.3421', '', '', NULL, 49),
(7746, '36620-79RJ0-4-P', '24.9349', '', '', NULL, 49),
(7747, '36620-79RH0-4-P', '27.6692', '', '', NULL, 49),
(7748, '36620-79RK0-4-P', '27.171', '', '', NULL, 49),
(7749, '36620-79RL0-4-P', '25.3388', '', '', NULL, 49),
(7750, '36920-79R10-4-P', '26.0796', '', '', NULL, 49),
(7751, '36920-79R00-4-P', '24.2473', '', '', NULL, 49),
(7752, '36920-79R20-4-P', '23.7492', '', '', NULL, 49),
(7753, '36920-79R30-4-P', '25.5815', '', '', NULL, 49),
(7754, '36920-79R40-4-P', '26.9595', '', '', NULL, 49),
(7755, '36920-79R50-4-P', '28.5964', '', '', NULL, 49),
(7756, '36920-79R60-4-P', '26.4614', '', '', NULL, 49),
(7757, '36920-79R70-4-P', '28.0983', '', '', NULL, 49),
(7758, '36920-79R80-4-P', '24.1708', '', '', NULL, 49),
(7759, '36920-79R90-4-P', '26.0031', '', '', NULL, 49),
(7760, '36920-79RA0-4-P', '26.883', '', '', NULL, 49),
(7761, '36920-79RC0-4-P', '25.7701', '55', '', NULL, 49),
(7762, '36920-79RB0-4-P', '28.5199', '', '', NULL, 49),
(7763, '36920-79RD0-4-P', '27.6024', '95', '', NULL, 49),
(7764, '36603-79R00-4-P', '9.202', '', '', NULL, 49),
(7765, '36603-79R10-4-P', '10.8789', '', '', NULL, 49),
(7766, '36603-79R20-4-P', '9.4043', '', '', NULL, 49),
(7767, '36603-79R30-4-P', '11.0812', '', '', NULL, 49),
(7768, '36630-79R10-4-P', '13.1866', '', '', NULL, 49),
(7769, '36630-79R00-4-P', '14.9542', '', '', NULL, 49),
(7770, '36630-79R20-4-P', '16.6311', '', '', NULL, 49),
(7771, '36630-79R40-4-P', '15.3476', '', '', NULL, 49),
(7772, '36630-79R60-4-P', '17.0245', '', '', NULL, 49),
(7773, '36630-79R70-4-P', '15.931', '', '', NULL, 49),
(7774, '36630-79R80-4-P', '17.6079', '', '', NULL, 49),
(7775, '36630-79R90-4-P', '11.7119', '', '', NULL, 49),
(7776, '36630-79RA0-4-P', '15.1627', '', '', NULL, 49),
(7777, '36630-79RB0-4-P', '13.3888', '', '', NULL, 49),
(7778, '36630-79RC0-4-P', '16.8396', '', '', NULL, 49),
(7779, '36630-79RE0-4-P', '15.6878', '', '', NULL, 49),
(7780, '36630-79RG0-4-P', '17.3647', '', '', NULL, 49),
(7781, '36630-79RH0-4-P', '16.2713', '', '', NULL, 49),
(7782, '36630-79RK0-4-P', '11.5096', '', '', NULL, 49),
(7783, '36630-79RJ0-4-P', '17.9481', '', '', NULL, 49),
(7784, '36630-79RL0-4-P', '11.8778', '', '', NULL, 49),
(7785, '36650-79R00-6-P', '11.2475', '', '', NULL, 49),
(7786, '36650-79R20-6-P', '10.7936', '', '', NULL, 49),
(7787, '36650-79R10-6-P', '10.0545', '298', '', NULL, 49),
(7788, '33880-76R00-1-P', '0', '', '', NULL, 49),
(7789, '36680-76R00-4-P', '1.7861', '', '', NULL, 49),
(7790, '36680-76R010-4-P', '1.7861', '', '', NULL, 49),
(7791, '36820-76R00-3-P', '0.6468', '', '', NULL, 49),
(7792, '36820-76R10-3-P', '1.0658', '', '', NULL, 49),
(7793, '36820-76R20-3-P', '0.9583', '', '', NULL, 49),
(7794, '36820-76R30-3-P', '1.3774', '', '', NULL, 49),
(7795, '36843-76R00-2-P', '0.2238', '', '', NULL, 49),
(7796, '36843-76R10-2-P', '1.695', '', '', NULL, 49),
(7797, '36756-76R00-3-P', '4.2432', '', '', NULL, 49),
(7798, '36757-76R10-2-P', '1.917', '', '', NULL, 49),
(7799, '36756-76R20-3-P', '4.4815', '', '', NULL, 49),
(7800, '36757-76R00-2-P', '1.917', '', '', NULL, 49),
(7801, '36756-76R10-3-P', '4.2432', '', '', NULL, 49),
(7802, '36756-76R30-3-P', '4.4815', '', '', NULL, 49),
(7803, '36757-76R20-2-P', '2.1554', '', '', NULL, 49),
(7804, '36757-76R30-2-P', '2.1554', '', '', NULL, 49),
(7805, '36751-76R00-3-P', '0.9105', '', '', NULL, 49),
(7806, '36630-76R30-3-P', '14.8234', '', '', NULL, 49),
(7807, '36630-76R20-3-P', '11.5895', '', '', NULL, 49),
(7808, '36630-76R60-3-P', '12.0157', '', '', NULL, 49),
(7809, '36630-76R70-3-P', '15.2362', '', '', NULL, 49),
(7810, '36630-76R80-3-P', '12.1209', '', '', NULL, 49),
(7811, '36856-31J10-3-P', '0.6649', '', '', NULL, 49),
(7812, '36851-31J10-4-P', '0.0972', '', '', NULL, 49),
(7813, '36854-31J20-3-P', '0.379', '', '', NULL, 49),
(7814, '33860-31J10-3-P', '0.3902', '', '', NULL, 49),
(7815, '36630-76R90-3-P', '15.3415', '', '', NULL, 49),
(7816, '33810-31J10-3-P', '0', '', '', NULL, 49),
(7817, '36610-31JK0(1)-P', '20.7102', '', '', NULL, 49),
(7818, '36610-31JQ0(1)-P', '19.3023', '', '', NULL, 49),
(7819, '36610-31JN0(1)-P', '18.8213', '', '', NULL, 49),
(7820, '36610-31JP0(1)-P', '19.0441', '', '', NULL, 49),
(7821, 'YSD-LHD-AL1-1', '0.305', '', '', NULL, 49),
(7822, '36620-31J10-4-P', '3.3549', '', '', NULL, 49),
(7823, 'YSD-LHD-CI1-1', '0.3242', '', '', NULL, 49),
(7824, 'YSD-RHD-AL1', '0.3147', '', '', NULL, 49),
(7825, 'YSD-RHD-CI2-1', '0.5408', '', '', NULL, 49),
(7826, 'YSD-RHD-CI1-1', '0.3245', '', '', NULL, 49),
(7827, '', '', '', '', NULL, 49),
(7828, '33880-64P10(6)-P', '0', '', '', NULL, 50),
(7829, '33880-64P20(6)-P', '0', '', '', NULL, 50),
(7830, '33880-64P30(6)-P', '0', '', '', NULL, 50),
(7831, '33880-64P40(6)-P', '0', '', '', NULL, 50),
(7832, '33880-64P50(6)-P', '0', '', '', NULL, 50),
(7833, '36658-64P00(1)-P', '0.5572', '', '', NULL, 50),
(7834, '36680-64P00(3)-P', '1.2445', '', '', NULL, 50),
(7835, '36680-64P10(3)-P', '1.6677', '', '', NULL, 50),
(7836, '36680-64P20(3)-P', '1.7721', '', '', NULL, 50),
(7837, '36680-64PA0(3)-P', '1.2416', '', '', NULL, 50),
(7838, '36680-64PB0(3)-P', '1.6641', '', '', NULL, 50),
(7839, '36680-64PC0(3)-P', '1.7682', '', '', NULL, 50),
(7840, '36820-64P00(5)-P', '1.5728', '', '', NULL, 50),
(7841, '36820-64P10(5)-P', '1.9944', '', '', NULL, 50),
(7842, '36820-64P20(5)-P', '3.1435', '', '', NULL, 50),
(7843, '36820-64P40(5)-P', '3.2602', '', '', NULL, 50),
(7844, '36820-64PA0(5)-P', '1.5717', '', '', NULL, 50),
(7845, '36820-64PB0(5)-P', '1.9952', '', '', NULL, 50),
(7846, '36820-64PC0(5)-P', '3.1353', '', '', NULL, 50);
INSERT INTO `eff_product_rep` (`ID`, `product_no`, `std_time`, `output_qty`, `output_min`, `group_id`, `batch_id`) VALUES
(7847, '36820-64PE0(5)-P', '3.2517', '', '', NULL, 50),
(7848, '33840-64P00-4-P', '0', '', '', NULL, 50),
(7849, '36810-64P00-4-P', '2.019', '', '', NULL, 50),
(7850, '36611-64P00-4-P', '0.2889', '', '', NULL, 50),
(7851, '36756-64P00(1)-1-P', '0.5167', '', '', NULL, 50),
(7852, '36756-64P10(1)-1-P', '1.7502', '', '', NULL, 50),
(7853, '36756-64P20(1)-1-P', '3.8587', '', '', NULL, 50),
(7854, '36756-64P30(1)-1-P', '4.0913', '', '', NULL, 50),
(7855, '36756-64P40(1)-1-P', '4.1997', '', '', NULL, 50),
(7856, '36756-64P50(1)-1-P', '0.31', '', '', NULL, 50),
(7857, '36757-64P00-6-P', '0.2067', '', '', NULL, 50),
(7858, '36757-64P10-6-P', '0.7386', '', '', NULL, 50),
(7859, '36757-64P20-6-P', '1.6553', '', '', NULL, 50),
(7860, '36757-64P30-6-P', '1.8882', '', '', NULL, 50),
(7861, '36757-64P40-6-P', '1.9907', '', '', NULL, 50),
(7862, '36064-64P00(6)-P', '21.0184', '', '', NULL, 50),
(7863, '36064-64P00(7)-P', '21.0184', '', '', NULL, 50),
(7864, '36064-64P10(6)-P', '22.483', '', '', NULL, 50),
(7865, '36064-64P10(7)-P', '22.483', '', '', NULL, 50),
(7866, '36064-64P20(6)-P', '24.1599', '55', '', NULL, 50),
(7867, '36064-64P20(7)-P', '24.1617', '', '', NULL, 50),
(7868, '36064-64P30(6)-P', '23.8696', '', '', NULL, 50),
(7869, '36064-64P30(7)-P', '23.8696', '', '', NULL, 50),
(7870, '36064-64P40(6)-P', '25.5463', '', '', NULL, 50),
(7871, '36064-64P40(7)-P', '25.5482', '', '', NULL, 50),
(7872, '36064-64P50(6)-P', '23.1798', '', '', NULL, 50),
(7873, '36064-64P50(7)-P', '23.1798', '', '', NULL, 50),
(7874, '36064-64P60(6)-P', '24.8418', '', '', NULL, 50),
(7875, '36064-64P60(7)-P', '24.8418', '', '', NULL, 50),
(7876, '36064-64P70(6)-P', '24.0132', '', '', NULL, 50),
(7877, '36064-64P70(7)-P', '24.0132', '', '', NULL, 50),
(7878, '36064-64P80(6)-P', '25.6753', '', '', NULL, 50),
(7879, '36064-64P80(7)-P', '25.6753', '', '', NULL, 50),
(7880, '36064-64P90(6)-P', '20.4578', '', '', NULL, 50),
(7881, '36064-64P90(7)-P', '20.4578', '25', '', NULL, 50),
(7882, '36064-64PA0(6)-P', '18.7926', '', '', NULL, 50),
(7883, '36064-64PA0(7)-P', '18.7926', '25', '', NULL, 50),
(7884, '36064-64PB0(6)-P', '27.8941', '', '', NULL, 50),
(7885, '36064-64PB0(7)-P', '27.8947', '', '', NULL, 50),
(7886, '36064-64PC0(6)-P', '28.0939', '', '', NULL, 50),
(7887, '36064-64PC0(7)-P', '28.0945', '', '', NULL, 50),
(7888, '36065-64P00(6)-P', '25.9342', '25', '', NULL, 50),
(7889, '36065-64P00(7)-P', '25.9342', '', '', NULL, 50),
(7890, '36065-64P10(6)-P', '26.134', '', '', NULL, 50),
(7891, '36065-64P10(7)-P', '26.134', '', '', NULL, 50),
(7892, '36065-64P20(6)-P', '30.2485', '50', '', NULL, 50),
(7893, '36065-64P20(7)-P', '30.2485', '25', '', NULL, 50),
(7894, '36065-64P30(6)-P', '30.4483', '', '', NULL, 50),
(7895, '36065-64P30(7)-P', '30.4483', '', '', NULL, 50),
(7896, '36065-64P40(6)-P', '33.08', '', '', NULL, 50),
(7897, '36065-64P40(7)-P', '33.08', '', '', NULL, 50),
(7898, '36065-64P50(6)-P', '33.2799', '', '', NULL, 50),
(7899, '36065-64P50(7)-P', '33.2799', '', '', NULL, 50),
(7900, '36065-64P60(6)-P', '25.9339', '', '', NULL, 50),
(7901, '36065-64P60(7)-P', '25.9339', '', '', NULL, 50),
(7902, '36065-64P70(6)-P', '26.1338', '', '', NULL, 50),
(7903, '36065-64P70(7)-P', '26.1338', '', '', NULL, 50),
(7904, '36065-64P80(6)-P', '22.5869', '35', '', NULL, 50),
(7905, '36065-64P80(7)-P', '22.5869', '', '', NULL, 50),
(7906, '36065-64P90(6)-P', '24.2637', '25', '', NULL, 50),
(7907, '36065-64P90(7)-P', '24.2655', '', '', NULL, 50),
(7908, '36065-64PA0(6)-P', '24.1107', '', '', NULL, 50),
(7909, '36065-64PA0(7)-P', '24.1107', '', '', NULL, 50),
(7910, '36065-64PB0(6)-P', '24.0984', '', '', NULL, 50),
(7911, '36065-64PB0(7)-P', '24.0984', '', '', NULL, 50),
(7912, '36065-64PC0(6)-P', '24.4778', '25', '', NULL, 50),
(7913, '36065-64PC0(7)-P', '24.4778', '', '', NULL, 50),
(7914, '36065-64PD0(6)-P', '26.1546', '', '', NULL, 50),
(7915, '36065-64PD0(7)-P', '26.1565', '', '', NULL, 50),
(7916, '36065-64PE0(6)-P', '18.3924', '', '', NULL, 50),
(7917, '36065-64PF0(6)-P', '16.73', '', '', NULL, 50),
(7918, '36065-64PG0(6)-P', '19.2084', '', '', NULL, 50),
(7919, '36065-64PH0(6)-P', '20.8708', '', '', NULL, 50),
(7920, '36065-64PJ0(6)-P', '20.6835', '20', '', NULL, 50),
(7921, '36065-64PJ0(7)-P', '20.6835', '', '', NULL, 50),
(7922, '36065-64PK0(6)-P', '22.3485', '', '', NULL, 50),
(7923, '36065-64PK0(7)-P', '22.3485', '', '', NULL, 50),
(7924, '36065-64PL0(6)-P', '21.0204', '', '', NULL, 50),
(7925, '36065-64PL0(7)-P', '21.0204', '', '', NULL, 50),
(7926, '36065-64PM0(6)-P', '23.5167', '', '', NULL, 50),
(7927, '36065-64PM0(7)-P', '23.5167', '', '', NULL, 50),
(7928, '36065-64PP0(6)-P', '23.5044', '', '', NULL, 50),
(7929, '36065-64PP0(7)-P', '23.5044', '25', '', NULL, 50),
(7930, '36065-64PQ0(6)-P', '21.7734', '', '', NULL, 50),
(7931, '36065-64PQ0(7)-P', '21.7734', '', '', NULL, 50),
(7932, '36065-64PR0(6)-P', '23.4354', '', '', NULL, 50),
(7933, '36065-64PR0(7)-P', '23.4354', '30', '', NULL, 50),
(7934, '36065-64PS0(6)-P', '22.1026', '', '', NULL, 50),
(7935, '36065-64PS0(7)-P', '22.1026', '', '', NULL, 50),
(7936, '36065-64PU0(6)-P', '23.7646', '', '', NULL, 50),
(7937, '36065-64PU0(7)-P', '23.7646', '', '', NULL, 50),
(7938, '36605-64P00(3)-1-P', '5.9654', '', '', NULL, 50),
(7939, '36605-64P10(3)-1-P', '5.7383', '', '', NULL, 50),
(7940, '36605-64P20(3)-1-P', '6.5215', '', '', NULL, 50),
(7941, '36605-64P30(3)-1-P', '6.2941', '', '', NULL, 50),
(7942, '33850-74P00(3)-P', '0', '', '', NULL, 50),
(7943, '33850-74P20(3)-P', '0', '', '', NULL, 50),
(7944, '33880-74PA0(3)-P', '0', '', '', NULL, 50),
(7945, '33880-74PB0(3)-P', '0', '', '', NULL, 50),
(7946, '33880-74PC0(3)-P', '0', '', '', NULL, 50),
(7947, '33880-54SC0(5)-P', '0', '', '', NULL, 50),
(7948, '36680-74P00(1)-P', '0.9407', '100', '', NULL, 50),
(7949, '36680-74P10(1)-P', '1.2554', '20', '', NULL, 50),
(7950, '36680-74P20(1)-P', '1.4593', '', '', NULL, 50),
(7951, '36680-74P30(1)-P', '1.5657', '', '', NULL, 50),
(7952, '36680-74P50(1)-P', '1.2554', '20', '', NULL, 50),
(7953, '36820-74P00(4)-P', '0.3181', '', '', NULL, 50),
(7954, '36820-74P10(4)-P', '0.7397', '', '', NULL, 50),
(7955, '36820-74P30(4)-P', '0.7369', '', '', NULL, 50),
(7956, '36882-74P00-6-P', '0.341', '', '', NULL, 50),
(7957, '36843-74P00(1)-P', '1.1936', '120', '', NULL, 50),
(7958, '36843-74P10(1)-P', '1.4259', '40', '', NULL, 50),
(7959, '36756-74P00(1)-2-P', '0.7184', '', '', NULL, 50),
(7960, '36756-74P10(1)-2-P', '2.522', '', '', NULL, 50),
(7961, '36756-74P20(1)-2-P', '4.2267', '', '', NULL, 50),
(7962, '36756-74P30(1)-2-P', '1.4304', '', '', NULL, 50),
(7963, '36756-74P40(1)-2-P', '4.0202', '', '', NULL, 50),
(7964, '36757-74P00(2)-P', '0.4081', '', '', NULL, 50),
(7965, '36757-74P10(2)-P', '0.9361', '', '', NULL, 50),
(7966, '36757-74P20(2)-P', '1.9494', '', '', NULL, 50),
(7967, '36757-74P40(2)-P', '1.7458', '', '', NULL, 50),
(7968, '36751-74P00(3)-P', '0.2068', '110', '', NULL, 50),
(7969, '36751-74P10(3)-P', '0.7374', '210', '', NULL, 50),
(7970, '36602-74P00(11)-P', '22.0961', '', '', NULL, 50),
(7971, '36602-74P10(11)-P', '22.6124', '', '', NULL, 50),
(7972, '36602-74P20(11)-P', '16.4087', '', '', NULL, 50),
(7973, '36602-74P30(11)-P', '17.1943', '', '', NULL, 50),
(7974, '36602-74P40(11)-P', '16.9253', '', '', NULL, 50),
(7975, '36602-74P50(11)-P', '17.7109', '', '', NULL, 50),
(7976, '36602-74P60(11)-P', '17.1756', '', '', NULL, 50),
(7977, '36602-74P70(11)-P', '20.494', '', '', NULL, 50),
(7978, '36602-74P80(11)-P', '12.7524', '12', '', NULL, 50),
(7979, '36602-74P90(11)-P', '14.5826', '', '', NULL, 50),
(7980, '36620-74P00(11)-P', '11.9423', '', '', NULL, 50),
(7981, '36620-74P10-8-P', '0', '', '', NULL, 50),
(7982, '36620-74P20(11)-P', '13.895', '', '', NULL, 50),
(7983, '36620-74P30(11)-P', '13.7726', '', '', NULL, 50),
(7984, '36620-74P40(11)-P', '15.5154', '', '', NULL, 50),
(7985, '36620-74P50(11)-P', '15.3683', '', '', NULL, 50),
(7986, '36620-74P60(11)-P', '16.3011', '', '', NULL, 50),
(7987, '36620-74P70(11)-P', '15.8675', '', '', NULL, 50),
(7988, '36620-74P80(11)-P', '15.9271', '', '', NULL, 50),
(7989, '36620-74P90(11)-P', '16.6531', '', '', NULL, 50),
(7990, '36620-74PA0(11)-P', '21.0253', '6', '', NULL, 50),
(7991, '36620-74PB0(11)-P', '22.7226', '', '', NULL, 50),
(7992, '36620-74PC0(11)-P', '13.3784', '12', '', NULL, 50),
(7993, '36620-74PD0-8-P', '0', '', '', NULL, 50),
(7994, '36620-74PE0(11)-P', '14.9988', '', '', NULL, 50),
(7995, '36620-74PF0-8-P', '0', '', '', NULL, 50),
(7996, '36620-74PG0(11)-P', '15.7845', '', '', NULL, 50),
(7997, '36620-74PH0(11)-P', '15.3512', '42', '', NULL, 50),
(7998, '36620-74PJ0(11)-P', '20.5091', '', '', NULL, 50),
(7999, '36620-74PK0(11)-P', '22.2064', '', '', NULL, 50),
(8000, '36620-74PL0(11)-P', '21.0106', '', '', NULL, 50),
(8001, '36620-74PM0(11)-P', '21.5268', '', '', NULL, 50),
(8002, '36620-74PN0(11)-P', '22.5045', '', '', NULL, 50),
(8003, '36620-74PP0(11)-P', '23.0207', '', '', NULL, 50),
(8004, '36620-74PQ0(11)-P', '17.0111', '', '', NULL, 50),
(8005, '36620-74PR0(11)-P', '17.2806', '12', '', NULL, 50),
(8006, '36620-74PS0(11)-P', '17.7968', '', '', NULL, 50),
(8007, '36620-74PU0(11)-P', '16.4949', '', '', NULL, 50),
(8008, '36602-54S00-X3-P', '22.1162', '', '', NULL, 50),
(8009, '36602-54S10-X3-P', '22.6318', '', '', NULL, 50),
(8010, '36602-54S60-X3-P', '17.1826', '', '', NULL, 50),
(8011, '36602-54S70-X3-P', '20.5147', '', '', NULL, 50),
(8012, '36620-54S00-X3-P', '12.7524', '', '', NULL, 50),
(8013, '36620-54S20-X3-P', '13.895', '', '', NULL, 50),
(8014, '36620-54S30-X3-P', '14.5951', '', '', NULL, 50),
(8015, '36620-54S40-X3-P', '15.5278', '', '', NULL, 50),
(8016, '36620-54S50-X3-P', '15.3807', '', '', NULL, 50),
(8017, '36620-54S60-X3-P', '16.3135', '', '', NULL, 50),
(8018, '36620-54S70-X3-P', '15.8668', '', '', NULL, 50),
(8019, '36620-54S80-X3-P', '15.9271', '', '', NULL, 50),
(8020, '36620-54S90-X3-P', '16.6525', '', '', NULL, 50),
(8021, '36620-54SA0-X3-P', '21.0306', '', '', NULL, 50),
(8022, '36620-54SC0-X3-P', '13.3784', '', '', NULL, 50),
(8023, '36620-54SE0-X3-P', '15.0113', '', '', NULL, 50),
(8024, '36620-54SG0-X3-P', '15.7969', '', '', NULL, 50),
(8025, '36620-54SH0-X3-P', '15.3512', '', '', NULL, 50),
(8026, '36620-54SJ0-X3-P', '20.5149', '', '', NULL, 50),
(8027, '36620-54SL0-X3-P', '21.0313', '', '', NULL, 50),
(8028, '36620-54SM0-X3-P', '21.5469', '', '', NULL, 50),
(8029, '36620-54SQ0-X3-P', '17.0105', '', '', NULL, 50),
(8030, '36620-54SR0-X3-P', '17.2806', '', '', NULL, 50),
(8031, '36620-54SS0-X3-P', '17.7962', '', '', NULL, 50),
(8032, '36620-54SU0-X3-P', '16.4949', '', '', NULL, 50),
(8033, '36630-74P00(7)-P', '4.2247', '', '', NULL, 50),
(8034, '36630-74P10(7)-P', '4.455', '', '', NULL, 50),
(8035, '36630-74P20(7)-P', '5.3164', '', '', NULL, 50),
(8036, '36630-74P30(7)-P', '5.7561', '', '', NULL, 50),
(8037, '36630-74P40(7)-P', '4.7839', '24', '', NULL, 50),
(8038, '36630-74P50(7)-P', '5.0142', '', '', NULL, 50),
(8039, '36630-74P60(7)-P', '5.4173', '12', '', NULL, 50),
(8040, '36630-74P70(7)-P', '5.8571', '', '', NULL, 50),
(8041, '36630-74P80(7)-P', '7.1904', '45', '', NULL, 50),
(8042, '36630-74P90(7)-P', '7.6251', '', '', NULL, 50),
(8043, '36630-74PA0(7)-P', '9.0996', '', '', NULL, 50),
(8044, '36630-74PB0(7)-P', '9.304', '', '', NULL, 50),
(8045, '36630-74PC0(7)-P', '8.7041', '', '', NULL, 50),
(8046, '36630-74PD0(7)-P', '9.0307', '', '', NULL, 50),
(8047, '36630-74PE0(7)-P', '7.4207', '', '', NULL, 50),
(8048, '36630-74PF0(7)-P', '6.3981', '', '', NULL, 50),
(8049, '36630-74PG0(7)-P', '6.6075', '', '', NULL, 50),
(8050, '36630-74PH0(7)-P', '8.2801', '', '', NULL, 50),
(8051, '36630-74PJ0(7)-P', '8.4024', '', '', NULL, 50),
(8052, '36630-74PK0(7)-P', '8.4947', '', '', NULL, 50),
(8053, '36630-74PL0(7)-P', '8.617', '', '', NULL, 50),
(8054, '36630-54S00-P', '4.2137', '', '', NULL, 50),
(8055, '36630-54S10-P', '4.444', '', '', NULL, 50),
(8056, '36630-54S20-X3-P', '5.3102', '', '', NULL, 50),
(8057, '36630-54S30-X3-P', '5.7499', '', '', NULL, 50),
(8058, '36630-54S40-X3-P', '4.7727', '', '', NULL, 50),
(8059, '36630-54S50-X3-P', '5.003', '', '', NULL, 50),
(8060, '36630-54S60-X3-P', '5.4112', '', '', NULL, 50),
(8061, '36630-54S70-X3-P', '5.8509', '', '', NULL, 50),
(8062, '36630-54S80-X3-P', '7.1839', '', '', NULL, 50),
(8063, '36630-54S90-X3-P', '7.6185', '', '', NULL, 50),
(8064, '36630-54SA0-X3-P', '8.975', '', '', NULL, 50),
(8065, '36630-54SB0-X3-P', '9.1793', '', '', NULL, 50),
(8066, '36630-54SC0-X3-P', '8.6937', '', '', NULL, 50),
(8067, '36630-54SD0-X3-P', '9.0203', '', '', NULL, 50),
(8068, '36630-54SE0-X3-P', '7.4142', '', '', NULL, 50),
(8069, '36630-54SH0-X3-P', '8.2695', '', '', NULL, 50),
(8070, '36630-54SJ0-X3-P', '8.3918', '', '', NULL, 50),
(8071, '36630-54SK0-X3-P', '8.3705', '', '', NULL, 50),
(8072, '36630-54SL0-X3-P', '8.4928', '', '', NULL, 50),
(8073, '36680-81P00(1)-2-P', '2.5975', '', '', NULL, 50),
(8074, '36680-81P10(1)-2-P', '2.5975', '', '', NULL, 50),
(8075, '36680-81PH0(1)-2-P', '2.5975', '', '', NULL, 50),
(8076, '36680-57S00-1-P', '2.5975', '', '', NULL, 50),
(8077, '36680-57S10-1-P', '2.5975', '', '', NULL, 50),
(8078, '36882-81P00(2)-P', '0.3603', '', '', NULL, 50),
(8079, '36843-57S00-1-P', '1.4737', '', '', NULL, 50),
(8080, '36843-57S10-1-P', '1.5015', '', '', NULL, 50),
(8081, '36843-57SA0-P', '0.3233', '', '', NULL, 50),
(8082, '36756-81P00(3)-2-P', '4.1785', '', '', NULL, 50),
(8083, '36756-81P10(3)-2-P', '4.1785', '', '', NULL, 50),
(8084, '36756-81P20(3)-2-P', '4.2933', '', '', NULL, 50),
(8085, '36756-81P30(3)-2-P', '4.2933', '', '', NULL, 50),
(8086, '36756-57S00-1-P', '4.282', '', '', NULL, 50),
(8087, '36756-57S10-1-P', '4.282', '', '', NULL, 50),
(8088, '36756-57S20-1-P', '4.3968', '', '', NULL, 50),
(8089, '36756-57S30-1-P', '4.3968', '', '', NULL, 50),
(8090, '36757-81P00(3)-1-P', '1.8462', '', '', NULL, 50),
(8091, '36757-81P10(3)-1-P', '1.8462', '', '', NULL, 50),
(8092, '36757-81P20(3)-1-P', '1.9495', '', '', NULL, 50),
(8093, '36757-81P30(3)-1-P', '1.9495', '', '', NULL, 50),
(8094, '36751-81P00(1)-P', '0.4256', '', '', NULL, 50),
(8095, '36751-81P20(1)-P', '1.4205', '', '', NULL, 50),
(8096, '36751-81PA0(2)-P', '0.4256', '', '', NULL, 50),
(8097, '36751-81PC0(2)-P', '1.4205', '', '', NULL, 50),
(8098, '36603-81P20(11)-P', '15.7831', '', '', NULL, 50),
(8099, '36603-81P40(11)-P', '17.1465', '', '', NULL, 50),
(8100, '36630-81P00(11)-P', '10.8939', '', '', NULL, 50),
(8101, '36630-81P10(11)-P', '11.3193', '', '', NULL, 50),
(8102, '36630-81PC0(11)-P', '13.2712', '', '', NULL, 50),
(8103, '36630-81PD0(11)-P', '13.4844', '', '', NULL, 50),
(8104, '36630-81PE0(11)-P', '14.6345', '', '', NULL, 50),
(8105, '36630-81PG0(11)-P', '14.9869', '', '', NULL, 50),
(8106, '36630-81PK0(11)-P', '13.127', '', '', NULL, 50),
(8107, '36630-81PJ0(11)-P', '10.1619', '', '', NULL, 50),
(8108, '36630-81PL0(11)-P', '13.3402', '', '', NULL, 50),
(8109, '36603-57S20-1-P', '16.3457', '', '', NULL, 50),
(8110, '36603-57S60-1-P', '18.4889', '', '', NULL, 50),
(8111, '36603-57S80-1-P', '20.6385', '', '', NULL, 50),
(8112, '36630-57S00-1-P', '11.239', '', '', NULL, 50),
(8113, '36630-57S10-1-P', '11.6701', '', '', NULL, 50),
(8114, '36630-57S20-1-P', '13.379', '', '', NULL, 50),
(8115, '36630-57S30-1-P', '13.8101', '', '', NULL, 50),
(8116, '36630-57SC0-1-P', '13.6169', '', '', NULL, 50),
(8117, '36630-57SD0-1-P', '13.8358', '', '', NULL, 50),
(8118, '36630-57SE0-1-P', '14.749', '', '', NULL, 50),
(8119, '36630-57SG0-1-P', '15.1009', '', '', NULL, 50),
(8120, '36630-57SH0-1-P', '15.7568', '', '', NULL, 50),
(8121, '36630-57SJ0-1-P', '15.9758', '', '', NULL, 50),
(8122, '36630-57SK0-1-P', '17.9063', '', '', NULL, 50),
(8123, '36630-57SL0-1-P', '18.2584', '', '', NULL, 50),
(8124, '36680-80P00(1)-1-P', '1.3835', '30', '', NULL, 50),
(8125, '36680-80P10(1)-1-P', '1.7006', '40', '', NULL, 50),
(8126, '36680-80P20(1)-1-P', '1.3835', '', '', NULL, 50),
(8127, '36680-80P30(1)-1-P', '1.7006', '20', '', NULL, 50),
(8128, '36820-80P00-4-P', '0.7451', '40', '', NULL, 50),
(8129, '36820-80P10-4-P', '1.0532', '', '', NULL, 50),
(8130, '36820-80P20-4-P', '1.1506', '40', '', NULL, 50),
(8131, '36820-80P30-4-P', '1.4587', '', '', NULL, 50),
(8132, '39312-80P00-P', '0.096', '', '', NULL, 50),
(8133, '36620-80P00(5)-P', '18.9777', '', '', NULL, 50),
(8134, '36620-80P10(5)-P', '19.6927', '', '', NULL, 50),
(8135, '36620-80P20(5)-P', '20.7791', '', '', NULL, 50),
(8136, '36620-80P30(5)-P', '21.4941', '', '', NULL, 50),
(8137, '36620-80P40(5)-P', '18.0335', '', '', NULL, 50),
(8138, '36620-80P50(5)-P', '18.7486', '', '', NULL, 50),
(8139, '36620-80P60(5)-P', '19.8349', '', '', NULL, 50),
(8140, '36620-80P70(5)-P', '20.55', '', '', NULL, 50),
(8141, '36620-80P80(5)-P', '20.3567', '', '', NULL, 50),
(8142, '36620-80P90(5)-P', '21.071', '', '', NULL, 50),
(8143, '36620-80PA0(5)-P', '22.1581', '', '', NULL, 50),
(8144, '36620-80PB0(5)-P', '22.8724', '', '', NULL, 50),
(8145, '36620-80PC0(5)-P', '18.4431', '', '', NULL, 50),
(8146, '36620-80PD0(5)-P', '19.8045', '', '', NULL, 50),
(8147, '36620-80PJ0(5)-P', '20.8689', '', '', NULL, 50),
(8148, '36620-80PK0(5)-P', '22.4669', '', '', NULL, 50),
(8149, '36630-80P00(4)-P', '9.1541', '18', '', NULL, 50),
(8150, '36630-80P10(4)-P', '9.3582', '', '', NULL, 50),
(8151, '36630-80P20(4)-P', '9.1541', '', '', NULL, 50),
(8152, '36630-80P30(4)-P', '9.3582', '', '', NULL, 50),
(8153, '36630-80P40(4)-P', '9.539', '36', '', NULL, 50),
(8154, '36630-80P50(4)-P', '9.8686', '6', '', NULL, 50),
(8155, '36630-80P60(4)-P', '9.539', '24', '', NULL, 50),
(8156, '36630-80P70(4)-P', '9.8686', '6', '', NULL, 50),
(8157, '36630-80P80(4)-P', '7.9313', '12', '', NULL, 50),
(8158, '36630-80P90(4)-P', '8.1416', '', '', NULL, 50),
(8159, '36630-80PE0(4)-P', '9.7431', '', '', NULL, 50),
(8160, '36630-80PF0(4)-P', '9.7431', '', '', NULL, 50),
(8161, '36620-52R00(4)-P', '19.1654', '', '', NULL, 50),
(8162, '36620-52R20(4)-P', '22.095', '15', '', NULL, 50),
(8163, '36620-52R30(4)-P', '23.2294', '', '', NULL, 50),
(8164, '36620-52R40(4)-P', '21.4351', '', '', NULL, 50),
(8165, '36620-52R50(4)-P', '22.86', '', '', NULL, 50),
(8166, '36620-52R80(4)-P', '24.3191', '', '', NULL, 50),
(8167, '36620-52R90(4)-P', '25.4535', '20', '', NULL, 50),
(8168, '36620-52RA0(4)-P', '23.1024', '15', '', NULL, 50),
(8169, '36620-52RB0(4)-P', '24.2367', '', '', NULL, 50),
(8170, '36620-52RC0(4)-P', '20.1649', '', '', NULL, 50),
(8171, '36620-52RG0(4)-P', '22.5973', '', '', NULL, 50),
(8172, '36620-52RH0(4)-P', '23.7183', '', '', NULL, 50),
(8173, '36620-52RL0(4)-P', '24.8245', '', '', NULL, 50),
(8174, '36620-52RM0(4)-P', '25.9454', '', '', NULL, 50),
(8175, '36620-52RP0(4)-P', '22.2727', '15', '', NULL, 50),
(8176, '36620-52RQ0(4)-P', '20.1445', '', '', NULL, 50),
(8177, '36620-52RR0(4)-P', '23.087', '', '', NULL, 50),
(8178, '36620-53R20(4)-P', '17.5067', '', '', NULL, 50),
(8179, '36620-53R30(4)-P', '19.1209', '', '', NULL, 50),
(8180, '36620-53R40(4)-P', '15.6893', '', '', NULL, 50),
(8181, '36620-53R50(4)-P', '18.6634', '25', '', NULL, 50),
(8182, '36620-53R60(4)-P', '19.3892', '', '', NULL, 50),
(8183, '36620-53R70(4)-P', '20.2516', '', '', NULL, 50),
(8184, '36620-53R90(4)-P', '22.9794', '15', '', NULL, 50),
(8185, '36620-53RA0(4)-P', '19.4373', '', '', NULL, 50),
(8186, '36620-53RB0(4)-P', '24.5025', '', '', NULL, 50),
(8187, '36620-53RC0(4)-P', '24.6063', '', '', NULL, 50),
(8188, '36620-53RD0(4)-P', '25.2132', '', '', NULL, 50),
(8189, '36620-53RE0(4)-P', '25.317', '', '', NULL, 50),
(8190, '36620-53RF0(4)-P', '17.6104', '15', '', NULL, 50),
(8191, '36620-53RG0(4)-P', '19.2246', '', '', NULL, 50),
(8192, '36620-53RH0(4)-P', '18.7671', '20', '', NULL, 50),
(8193, '36620-53RJ0(4)-P', '19.4929', '', '', NULL, 50),
(8194, '36620-68R00(1)-P', '21.2855', '25', '', NULL, 50),
(8195, '36620-68R10(1)-P', '23.8117', '30', '', NULL, 50),
(8196, '36620-68R20(1)-P', '24.946', '', '', NULL, 50),
(8197, '36620-68R50(1)-P', '22.8718', '', '', NULL, 50),
(8198, '36620-68R60(1)-P', '22.9755', '', '', NULL, 50),
(8199, '36620-68R70(1)-P', '23.0678', '', '', NULL, 50),
(8200, '36620-68R80(1)-P', '23.1715', '', '', NULL, 50),
(8201, '36620-68R90(1)-P', '24.283', '', '', NULL, 50),
(8202, '36620-68RA0(1)-P', '24.3867', '', '', NULL, 50),
(8203, '36620-68RB0(1)-P', '25.1002', '', '', NULL, 50),
(8204, '36620-68RC0(1)-P', '25.2039', '', '', NULL, 50),
(8205, '36602-53R00(4)-P', '13.5514', '', '', NULL, 50),
(8206, '36602-53R10(4)-P', '16.4214', '', '', NULL, 50),
(8207, '36602-53R20(4)-P', '17.8433', '', '', NULL, 50),
(8208, '36602-53R30(4)-P', '15.6822', '', '', NULL, 50),
(8209, '36602-53R40(4)-P', '17.9609', '', '', NULL, 50),
(8210, '36602-53R51(4)-P', '19.0584', '', '', NULL, 50),
(8211, '36602-53R70(4)-P', '19.876', '', '', NULL, 50),
(8212, '36602-53R80(4)-P', '21.2114', '', '', NULL, 50),
(8213, '36602-53R90(4)-P', '22.4956', '', '', NULL, 50),
(8214, '36602-53RC0(4)-P', '23.7968', '', '', NULL, 50),
(8215, '36602-53RD0(4)-P', '23.9008', '', '', NULL, 50),
(8216, '36602-53RE0(4)-P', '24.4899', '', '', NULL, 50),
(8217, '36602-53RF0(4)-P', '24.594', '', '', NULL, 50),
(8218, '36602-53RG0(4)-P', '17.3762', '', '', NULL, 50),
(8219, '36602-53RH0(4)-P', '20.1715', '', '', NULL, 50),
(8220, '36602-53RJ1(4)-P', '18.4566', '', '', NULL, 50),
(8221, '36602-53RK1(4)-P', '19.1624', '', '', NULL, 50),
(8222, '36602-53RL0(4)-P', '18.3526', '', '', NULL, 50),
(8223, '36602-68R00(1)-P', '22.3647', '', '', NULL, 50),
(8224, '36602-68R10(1)-P', '22.4687', '', '', NULL, 50),
(8225, '36602-68R40(1)-P', '23.5897', '', '', NULL, 50),
(8226, '36602-68R50(1)-P', '23.6938', '', '', NULL, 50),
(8227, '36602-68R60(1)-P', '24.3847', '', '', NULL, 50),
(8228, '36602-68R70(1)-P', '24.4888', '', '', NULL, 50),
(8229, '36602-68R80(1)-P', '19.5801', '', '', NULL, 50),
(8230, '36602-68R90(1)-P', '21.2109', '', '', NULL, 50),
(8231, '36620-57R00-2-P', '12.8569', '25', '', NULL, 50),
(8232, '36620-57R10-2-P', '15.8752', '30', '', NULL, 50),
(8233, '36620-57R20-2-P', '20.9983', '', '', NULL, 50),
(8234, '36620-57R30-2-P', '15.4729', '', '', NULL, 50),
(8235, '36620-57R40-2-P', '20.2868', '', '', NULL, 50),
(8236, '36620-57R50-2-P', '19.4717', '', '', NULL, 50),
(8237, '36620-57R60-2-P', '14.6578', '', '', NULL, 50),
(8238, '36602-57R00-2-P', '15.2379', '', '', NULL, 50),
(8239, '36602-57R10-2-P', '20.0515', '', '', NULL, 50),
(8240, '36602-57R20-2-P', '19.255', '', '', NULL, 50),
(8241, '36602-57R30-2-P', '14.4414', '', '', NULL, 50),
(8242, '33880-63RC0-1-P', '0', '', '', NULL, 50),
(8243, '33880-79R00-2-P', '0', '', '', NULL, 50),
(8244, '36680-79R00-3-P', '1.9303', '', '', NULL, 50),
(8245, '36680-79R20-3-P', '2.3448', '', '', NULL, 50),
(8246, '36680-79R30-3-P', '2.3448', '', '', NULL, 50),
(8247, '36820-79R00-4-P', '0.6567', '', '', NULL, 50),
(8248, '36820-79R10-4-P', '0.9698', '', '', NULL, 50),
(8249, '36820-79R20-4-P', '0.8751', '', '', NULL, 50),
(8250, '36820-79R30-4-P', '1.1882', '', '', NULL, 50),
(8251, '36820-79R40-4-P', '1.0848', '100', '', NULL, 50),
(8252, '36820-79R50-4-P', '1.398', '', '', NULL, 50),
(8253, '36820-79R60-4-P', '1.3032', '480', '', NULL, 50),
(8254, '36820-79R70-4-P', '1.6164', '', '', NULL, 50),
(8255, '36813-79R50-P', '0.4296', '600', '', NULL, 50),
(8256, '36813-79R00-2-P', '1.4487', '390', '', NULL, 50),
(8257, '36756-79R00-4-P', '3.9272', '', '', NULL, 50),
(8258, '36756-79R20-4-P', '4.2298', '', '', NULL, 50),
(8259, '36756-79R30-4-P', '4.2298', '', '', NULL, 50),
(8260, '36756-79R40-4-P', '4.2364', '', '', NULL, 50),
(8261, '36756-79R50-4-P', '4.4388', '', '', NULL, 50),
(8262, '36756-79R60-4-P', '4.6712', '', '', NULL, 50),
(8263, '36756-79R70-4-P', '4.6712', '', '', NULL, 50),
(8264, '36756-79R80-4-P', '4.4388', '', '', NULL, 50),
(8265, '36756-79R90-4-P', '4.2364', '', '', NULL, 50),
(8266, '36757-79R00-3-P', '1.6573', '', '', NULL, 50),
(8267, '36757-79R20-3-P', '1.9607', '', '', NULL, 50),
(8268, '36757-79R30-3-P', '2.1637', '', '', NULL, 50),
(8269, '36757-79R40-3-P', '2.3962', '', '', NULL, 50),
(8270, '36757-79R50-3-P', '2.3962', '', '', NULL, 50),
(8271, '36757-79R60-3-P', '2.1637', '80', '', NULL, 50),
(8272, '36757-79R70-3-P', '1.9607', '', '', NULL, 50),
(8273, '36751-79R00-3-P', '0.4217', '', '', NULL, 50),
(8274, '36751-79R10-3-P', '1.4114', '', '', NULL, 50),
(8275, '36751-79RC0-3-P', '1.4114', '', '', NULL, 50),
(8276, '36690-79R00-1-P', '0.2', '300', '', NULL, 50),
(8277, '36602-79R00-4-P', '19.5992', '', '', NULL, 50),
(8278, '36602-79R20-4-P', '22.626', '', '', NULL, 50),
(8279, '36620-79R00-4-P', '21.5177', '70', '', NULL, 50),
(8280, '36620-79R10-4-P', '23.7428', '', '', NULL, 50),
(8281, '36620-79R20-4-P', '23.8338', '', '', NULL, 50),
(8282, '36620-79R30-4-P', '26.0699', '', '', NULL, 50),
(8283, '36620-79R40-4-P', '23.3356', '', '', NULL, 50),
(8284, '36620-79R50-4-P', '25.5718', '', '', NULL, 50),
(8285, '36620-79R60-4-P', '24.2299', '', '', NULL, 50),
(8286, '36620-79R70-4-P', '26.2596', '', '', NULL, 50),
(8287, '36620-79R80-4-P', '26.546', '', '', NULL, 50),
(8288, '36620-79R90-4-P', '28.5867', '', '', NULL, 50),
(8289, '36620-79RA0-4-P', '26.0478', '', '', NULL, 50),
(8290, '36620-79RB0-4-P', '28.0886', '', '', NULL, 50),
(8291, '36620-79RC0-4-P', '23.7395', '', '', NULL, 50),
(8292, '36620-79RD0-4-P', '26.4517', '', '', NULL, 50),
(8293, '36620-79RE0-4-P', '23.117', '', '', NULL, 50),
(8294, '36620-79RF0-4-P', '25.3421', '', '', NULL, 50),
(8295, '36620-79RG0-4-P', '25.4331', '', '', NULL, 50),
(8296, '36620-79RH0-4-P', '27.6692', '', '', NULL, 50),
(8297, '36620-79RJ0-4-P', '24.9349', '', '', NULL, 50),
(8298, '36620-79RK0-4-P', '27.171', '', '', NULL, 50),
(8299, '36620-79RL0-4-P', '25.3388', '', '', NULL, 50),
(8300, '36920-79R00-4-P', '24.2473', '', '', NULL, 50),
(8301, '36920-79R10-4-P', '26.0796', '', '', NULL, 50),
(8302, '36920-79R20-4-P', '23.7492', '', '', NULL, 50),
(8303, '36920-79R30-4-P', '25.5815', '', '', NULL, 50),
(8304, '36920-79R40-4-P', '26.9595', '', '', NULL, 50),
(8305, '36920-79R50-4-P', '28.5964', '', '', NULL, 50),
(8306, '36920-79R60-4-P', '26.4614', '', '', NULL, 50),
(8307, '36920-79R70-4-P', '28.0983', '', '', NULL, 50),
(8308, '36920-79R80-4-P', '24.1708', '', '', NULL, 50),
(8309, '36920-79R90-4-P', '26.0031', '', '', NULL, 50),
(8310, '36920-79RA0-4-P', '26.883', '', '', NULL, 50),
(8311, '36920-79RB0-4-P', '28.5199', '55', '', NULL, 50),
(8312, '36920-79RC0-4-P', '25.7701', '95', '', NULL, 50),
(8313, '36920-79RD0-4-P', '27.6024', '', '', NULL, 50),
(8314, '36603-79R00-4-P', '9.202', '', '', NULL, 50),
(8315, '36603-79R10-4-P', '10.8789', '', '', NULL, 50),
(8316, '36603-79R20-4-P', '9.4043', '', '', NULL, 50),
(8317, '36603-79R30-4-P', '11.0812', '', '', NULL, 50),
(8318, '36630-79R00-4-P', '14.9542', '', '', NULL, 50),
(8319, '36630-79R10-4-P', '13.1866', '', '', NULL, 50),
(8320, '36630-79R20-4-P', '16.6311', '', '', NULL, 50),
(8321, '36630-79R40-4-P', '15.3476', '', '', NULL, 50),
(8322, '36630-79R60-4-P', '17.0245', '', '', NULL, 50),
(8323, '36630-79R70-4-P', '15.931', '', '', NULL, 50),
(8324, '36630-79R80-4-P', '17.6079', '', '', NULL, 50),
(8325, '36630-79R90-4-P', '11.7119', '', '', NULL, 50),
(8326, '36630-79RA0-4-P', '15.1627', '', '', NULL, 50),
(8327, '36630-79RB0-4-P', '13.3888', '', '', NULL, 50),
(8328, '36630-79RC0-4-P', '16.8396', '', '', NULL, 50),
(8329, '36630-79RE0-4-P', '15.6878', '', '', NULL, 50),
(8330, '36630-79RG0-4-P', '17.3647', '', '', NULL, 50),
(8331, '36630-79RH0-4-P', '16.2713', '', '', NULL, 50),
(8332, '36630-79RJ0-4-P', '17.9481', '', '', NULL, 50),
(8333, '36630-79RK0-4-P', '11.5096', '', '', NULL, 50),
(8334, '36630-79RL0-4-P', '11.8778', '', '', NULL, 50),
(8335, '36650-79R00-6-P', '11.2475', '298', '', NULL, 50),
(8336, '36650-79R10-6-P', '10.0545', '', '', NULL, 50),
(8337, '36650-79R20-6-P', '10.7936', '', '', NULL, 50),
(8338, '33880-76R00-1-P', '0', '', '', NULL, 50),
(8339, '36680-76R00-4-P', '1.7861', '', '', NULL, 50),
(8340, '36680-76R010-4-P', '1.7861', '', '', NULL, 50),
(8341, '36820-76R00-3-P', '0.6468', '', '', NULL, 50),
(8342, '36820-76R10-3-P', '1.0658', '', '', NULL, 50),
(8343, '36820-76R20-3-P', '0.9583', '', '', NULL, 50),
(8344, '36820-76R30-3-P', '1.3774', '', '', NULL, 50),
(8345, '36843-76R00-2-P', '0.2238', '', '', NULL, 50),
(8346, '36843-76R10-2-P', '1.695', '', '', NULL, 50),
(8347, '36756-76R00-3-P', '4.2432', '', '', NULL, 50),
(8348, '36756-76R10-3-P', '4.2432', '', '', NULL, 50),
(8349, '36756-76R20-3-P', '4.4815', '', '', NULL, 50),
(8350, '36756-76R30-3-P', '4.4815', '', '', NULL, 50),
(8351, '36757-76R00-2-P', '1.917', '', '', NULL, 50),
(8352, '36757-76R10-2-P', '1.917', '', '', NULL, 50),
(8353, '36757-76R20-2-P', '2.1554', '', '', NULL, 50),
(8354, '36757-76R30-2-P', '2.1554', '', '', NULL, 50),
(8355, '36751-76R00-3-P', '0.9105', '', '', NULL, 50),
(8356, '36630-76R20-3-P', '11.5895', '', '', NULL, 50),
(8357, '36630-76R30-3-P', '14.8234', '', '', NULL, 50),
(8358, '36630-76R60-3-P', '12.0157', '', '', NULL, 50),
(8359, '36630-76R70-3-P', '15.2362', '', '', NULL, 50),
(8360, '36630-76R80-3-P', '12.1209', '', '', NULL, 50),
(8361, '36630-76R90-3-P', '15.3415', '', '', NULL, 50),
(8362, '36851-31J10-4-P', '0.0972', '', '', NULL, 50),
(8363, '36854-31J20-3-P', '0.379', '', '', NULL, 50),
(8364, '36856-31J10-3-P', '0.6649', '', '', NULL, 50),
(8365, '33860-31J10-3-P', '0.3902', '', '', NULL, 50),
(8366, '33810-31J10-3-P', '0', '', '', NULL, 50),
(8367, '36610-31JK0(1)-P', '20.7102', '', '', NULL, 50),
(8368, '36610-31JQ0(1)-P', '19.3023', '', '', NULL, 50),
(8369, '36610-31JN0(1)-P', '18.8213', '', '', NULL, 50),
(8370, '36610-31JP0(1)-P', '19.0441', '', '', NULL, 50),
(8371, '36620-31J10-4-P', '3.3549', '', '', NULL, 50),
(8372, 'YSD-LHD-AL1-1', '0.305', '', '', NULL, 50),
(8373, 'YSD-LHD-CI1-1', '0.3242', '', '', NULL, 50),
(8374, 'YSD-RHD-AL1', '0.3147', '', '', NULL, 50),
(8375, 'YSD-RHD-CI1-1', '0.3245', '', '', NULL, 50),
(8376, 'YSD-RHD-CI2-1', '0.5408', '', '', NULL, 50),
(8377, '33880-64P10(6)-P', '0', '', '', NULL, 51),
(8378, '33880-64P20(6)-P', '0', '', '', NULL, 51),
(8379, '33880-64P30(6)-P', '0', '', '', NULL, 51),
(8380, '33880-64P40(6)-P', '0', '', '', NULL, 51),
(8381, '33880-64P50(6)-P', '0', '', '', NULL, 51),
(8382, '36658-64P00(1)-P', '0.5572', '', '', NULL, 51),
(8383, '36680-64P00(3)-P', '1.2445', '', '', NULL, 51),
(8384, '36680-64P10(3)-P', '1.6677', '', '', NULL, 51),
(8385, '36680-64P20(3)-P', '1.7721', '', '', NULL, 51),
(8386, '36680-64PA0(3)-P', '1.2416', '', '', NULL, 51),
(8387, '36680-64PB0(3)-P', '1.6641', '', '', NULL, 51),
(8388, '36680-64PC0(3)-P', '1.7682', '', '', NULL, 51),
(8389, '36820-64P00(5)-P', '1.5728', '', '', NULL, 51),
(8390, '36820-64P10(5)-P', '1.9944', '', '', NULL, 51),
(8391, '36820-64P20(5)-P', '3.1435', '', '', NULL, 51),
(8392, '36820-64P40(5)-P', '3.2602', '', '', NULL, 51),
(8393, '36820-64PA0(5)-P', '1.5717', '', '', NULL, 51),
(8394, '36820-64PB0(5)-P', '1.9952', '', '', NULL, 51),
(8395, '36820-64PC0(5)-P', '3.1353', '', '', NULL, 51),
(8396, '36820-64PE0(5)-P', '3.2517', '', '', NULL, 51),
(8397, '33840-64P00-4-P', '0', '', '', NULL, 51),
(8398, '36810-64P00-4-P', '2.019', '', '', NULL, 51),
(8399, '36611-64P00-4-P', '0.2889', '', '', NULL, 51),
(8400, '36756-64P00(1)-1-P', '0.5167', '', '', NULL, 51),
(8401, '36756-64P10(1)-1-P', '1.7502', '', '', NULL, 51),
(8402, '36756-64P20(1)-1-P', '3.8587', '', '', NULL, 51),
(8403, '36756-64P30(1)-1-P', '4.0913', '', '', NULL, 51),
(8404, '36756-64P40(1)-1-P', '4.1997', '', '', NULL, 51),
(8405, '36756-64P50(1)-1-P', '0.31', '', '', NULL, 51),
(8406, '36757-64P00-6-P', '0.2067', '', '', NULL, 51),
(8407, '36757-64P10-6-P', '0.7386', '', '', NULL, 51),
(8408, '36757-64P20-6-P', '1.6553', '', '', NULL, 51),
(8409, '36757-64P30-6-P', '1.8882', '', '', NULL, 51),
(8410, '36757-64P40-6-P', '1.9907', '', '', NULL, 51),
(8411, '36064-64P00(6)-P', '21.0184', '', '', NULL, 51),
(8412, '36064-64P00(7)-P', '21.0184', '', '', NULL, 51),
(8413, '36064-64P10(6)-P', '22.483', '', '', NULL, 51),
(8414, '36064-64P10(7)-P', '22.483', '', '', NULL, 51),
(8415, '36064-64P20(6)-P', '24.1599', '55', '', NULL, 51),
(8416, '36064-64P20(7)-P', '24.1617', '', '', NULL, 51),
(8417, '36064-64P30(6)-P', '23.8696', '', '', NULL, 51),
(8418, '36064-64P30(7)-P', '23.8696', '', '', NULL, 51),
(8419, '36064-64P40(6)-P', '25.5463', '', '', NULL, 51),
(8420, '36064-64P40(7)-P', '25.5482', '', '', NULL, 51),
(8421, '36064-64P50(6)-P', '23.1798', '', '', NULL, 51),
(8422, '36064-64P50(7)-P', '23.1798', '', '', NULL, 51),
(8423, '36064-64P60(6)-P', '24.8418', '', '', NULL, 51),
(8424, '36064-64P60(7)-P', '24.8418', '', '', NULL, 51),
(8425, '36064-64P70(6)-P', '24.0132', '', '', NULL, 51),
(8426, '36064-64P70(7)-P', '24.0132', '', '', NULL, 51),
(8427, '36064-64P80(6)-P', '25.6753', '', '', NULL, 51),
(8428, '36064-64P80(7)-P', '25.6753', '', '', NULL, 51),
(8429, '36064-64P90(6)-P', '20.4578', '', '', NULL, 51),
(8430, '36064-64P90(7)-P', '20.4578', '25', '', NULL, 51),
(8431, '36064-64PA0(6)-P', '18.7926', '', '', NULL, 51),
(8432, '36064-64PA0(7)-P', '18.7926', '25', '', NULL, 51),
(8433, '36064-64PB0(6)-P', '27.8941', '', '', NULL, 51),
(8434, '36064-64PB0(7)-P', '27.8947', '', '', NULL, 51),
(8435, '36064-64PC0(6)-P', '28.0939', '', '', NULL, 51),
(8436, '36064-64PC0(7)-P', '28.0945', '', '', NULL, 51),
(8437, '36065-64P00(6)-P', '25.9342', '25', '', NULL, 51),
(8438, '36065-64P00(7)-P', '25.9342', '', '', NULL, 51),
(8439, '36065-64P10(6)-P', '26.134', '', '', NULL, 51),
(8440, '36065-64P10(7)-P', '26.134', '', '', NULL, 51),
(8441, '36065-64P20(6)-P', '30.2485', '50', '', NULL, 51),
(8442, '36065-64P20(7)-P', '30.2485', '25', '', NULL, 51),
(8443, '36065-64P30(6)-P', '30.4483', '', '', NULL, 51),
(8444, '36065-64P30(7)-P', '30.4483', '', '', NULL, 51),
(8445, '36065-64P40(6)-P', '33.08', '', '', NULL, 51),
(8446, '36065-64P40(7)-P', '33.08', '', '', NULL, 51),
(8447, '36065-64P50(6)-P', '33.2799', '', '', NULL, 51),
(8448, '36065-64P50(7)-P', '33.2799', '', '', NULL, 51),
(8449, '36065-64P60(6)-P', '25.9339', '', '', NULL, 51),
(8450, '36065-64P60(7)-P', '25.9339', '', '', NULL, 51),
(8451, '36065-64P70(6)-P', '26.1338', '', '', NULL, 51),
(8452, '36065-64P70(7)-P', '26.1338', '', '', NULL, 51),
(8453, '36065-64P80(6)-P', '22.5869', '35', '', NULL, 51),
(8454, '36065-64P80(7)-P', '22.5869', '', '', NULL, 51),
(8455, '36065-64P90(6)-P', '24.2637', '25', '', NULL, 51),
(8456, '36065-64P90(7)-P', '24.2655', '', '', NULL, 51),
(8457, '36065-64PA0(6)-P', '24.1107', '', '', NULL, 51),
(8458, '36065-64PA0(7)-P', '24.1107', '', '', NULL, 51),
(8459, '36065-64PB0(6)-P', '24.0984', '', '', NULL, 51),
(8460, '36065-64PB0(7)-P', '24.0984', '', '', NULL, 51),
(8461, '36065-64PC0(6)-P', '24.4778', '25', '', NULL, 51),
(8462, '36065-64PC0(7)-P', '24.4778', '', '', NULL, 51),
(8463, '36065-64PD0(6)-P', '26.1546', '', '', NULL, 51),
(8464, '36065-64PD0(7)-P', '26.1565', '', '', NULL, 51),
(8465, '36065-64PE0(6)-P', '18.3924', '', '', NULL, 51),
(8466, '36065-64PF0(6)-P', '16.73', '', '', NULL, 51),
(8467, '36065-64PG0(6)-P', '19.2084', '', '', NULL, 51),
(8468, '36065-64PH0(6)-P', '20.8708', '', '', NULL, 51),
(8469, '36065-64PJ0(6)-P', '20.6835', '20', '', NULL, 51),
(8470, '36065-64PJ0(7)-P', '20.6835', '', '', NULL, 51),
(8471, '36065-64PK0(6)-P', '22.3485', '', '', NULL, 51),
(8472, '36065-64PK0(7)-P', '22.3485', '', '', NULL, 51),
(8473, '36065-64PL0(6)-P', '21.0204', '', '', NULL, 51),
(8474, '36065-64PL0(7)-P', '21.0204', '', '', NULL, 51),
(8475, '36065-64PM0(6)-P', '23.5167', '', '', NULL, 51),
(8476, '36065-64PM0(7)-P', '23.5167', '', '', NULL, 51),
(8477, '36065-64PP0(6)-P', '23.5044', '', '', NULL, 51),
(8478, '36065-64PP0(7)-P', '23.5044', '25', '', NULL, 51),
(8479, '36065-64PQ0(6)-P', '21.7734', '', '', NULL, 51),
(8480, '36065-64PQ0(7)-P', '21.7734', '', '', NULL, 51),
(8481, '36065-64PR0(6)-P', '23.4354', '', '', NULL, 51),
(8482, '36065-64PR0(7)-P', '23.4354', '30', '', NULL, 51),
(8483, '36065-64PS0(6)-P', '22.1026', '', '', NULL, 51),
(8484, '36065-64PS0(7)-P', '22.1026', '', '', NULL, 51),
(8485, '36065-64PU0(6)-P', '23.7646', '', '', NULL, 51),
(8486, '36065-64PU0(7)-P', '23.7646', '', '', NULL, 51),
(8487, '36605-64P00(3)-1-P', '5.9654', '', '', NULL, 51),
(8488, '36605-64P10(3)-1-P', '5.7383', '', '', NULL, 51),
(8489, '36605-64P20(3)-1-P', '6.5215', '', '', NULL, 51),
(8490, '36605-64P30(3)-1-P', '6.2941', '', '', NULL, 51),
(8491, '33850-74P00(3)-P', '0', '', '', NULL, 51),
(8492, '33850-74P20(3)-P', '0', '', '', NULL, 51),
(8493, '33880-74PA0(3)-P', '0', '', '', NULL, 51),
(8494, '33880-74PB0(3)-P', '0', '', '', NULL, 51),
(8495, '33880-74PC0(3)-P', '0', '', '', NULL, 51),
(8496, '33880-54SC0(5)-P', '0', '', '', NULL, 51),
(8497, '36680-74P00(1)-P', '0.9407', '100', '', NULL, 51),
(8498, '36680-74P10(1)-P', '1.2554', '20', '', NULL, 51),
(8499, '36680-74P20(1)-P', '1.4593', '', '', NULL, 51),
(8500, '36680-74P30(1)-P', '1.5657', '', '', NULL, 51),
(8501, '36680-74P50(1)-P', '1.2554', '20', '', NULL, 51),
(8502, '36820-74P00(4)-P', '0.3181', '', '', NULL, 51),
(8503, '36820-74P10(4)-P', '0.7397', '', '', NULL, 51),
(8504, '36820-74P30(4)-P', '0.7369', '', '', NULL, 51),
(8505, '36882-74P00-6-P', '0.341', '', '', NULL, 51),
(8506, '36843-74P00(1)-P', '1.1936', '120', '', NULL, 51),
(8507, '36843-74P10(1)-P', '1.4259', '40', '', NULL, 51),
(8508, '36756-74P00(1)-2-P', '0.7184', '', '', NULL, 51),
(8509, '36756-74P10(1)-2-P', '2.522', '', '', NULL, 51),
(8510, '36756-74P20(1)-2-P', '4.2267', '', '', NULL, 51),
(8511, '36756-74P30(1)-2-P', '1.4304', '', '', NULL, 51),
(8512, '36756-74P40(1)-2-P', '4.0202', '', '', NULL, 51),
(8513, '36757-74P00(2)-P', '0.4081', '', '', NULL, 51),
(8514, '36757-74P10(2)-P', '0.9361', '', '', NULL, 51),
(8515, '36757-74P20(2)-P', '1.9494', '', '', NULL, 51),
(8516, '36757-74P40(2)-P', '1.7458', '', '', NULL, 51),
(8517, '36751-74P00(3)-P', '0.2068', '110', '', NULL, 51),
(8518, '36751-74P10(3)-P', '0.7374', '210', '', NULL, 51),
(8519, '36602-74P00(11)-P', '22.0961', '', '', NULL, 51),
(8520, '36602-74P10(11)-P', '22.6124', '', '', NULL, 51),
(8521, '36602-74P20(11)-P', '16.4087', '', '', NULL, 51),
(8522, '36602-74P30(11)-P', '17.1943', '', '', NULL, 51),
(8523, '36602-74P40(11)-P', '16.9253', '', '', NULL, 51),
(8524, '36602-74P50(11)-P', '17.7109', '', '', NULL, 51),
(8525, '36602-74P60(11)-P', '17.1756', '', '', NULL, 51),
(8526, '36602-74P70(11)-P', '20.494', '', '', NULL, 51),
(8527, '36602-74P80(11)-P', '12.7524', '12', '', NULL, 51),
(8528, '36602-74P90(11)-P', '14.5826', '', '', NULL, 51),
(8529, '36620-74P00(11)-P', '11.9423', '', '', NULL, 51),
(8530, '36620-74P10-8-P', '0', '', '', NULL, 51),
(8531, '36620-74P20(11)-P', '13.895', '', '', NULL, 51),
(8532, '36620-74P30(11)-P', '13.7726', '', '', NULL, 51),
(8533, '36620-74P40(11)-P', '15.5154', '', '', NULL, 51),
(8534, '36620-74P50(11)-P', '15.3683', '', '', NULL, 51),
(8535, '36620-74P60(11)-P', '16.3011', '', '', NULL, 51),
(8536, '36620-74P70(11)-P', '15.8675', '', '', NULL, 51),
(8537, '36620-74P80(11)-P', '15.9271', '', '', NULL, 51),
(8538, '36620-74P90(11)-P', '16.6531', '', '', NULL, 51),
(8539, '36620-74PA0(11)-P', '21.0253', '6', '', NULL, 51),
(8540, '36620-74PB0(11)-P', '22.7226', '', '', NULL, 51),
(8541, '36620-74PC0(11)-P', '13.3784', '12', '', NULL, 51),
(8542, '36620-74PD0-8-P', '0', '', '', NULL, 51),
(8543, '36620-74PE0(11)-P', '14.9988', '', '', NULL, 51),
(8544, '36620-74PF0-8-P', '0', '', '', NULL, 51),
(8545, '36620-74PG0(11)-P', '15.7845', '', '', NULL, 51),
(8546, '36620-74PH0(11)-P', '15.3512', '42', '', NULL, 51),
(8547, '36620-74PJ0(11)-P', '20.5091', '', '', NULL, 51),
(8548, '36620-74PK0(11)-P', '22.2064', '', '', NULL, 51),
(8549, '36620-74PL0(11)-P', '21.0106', '', '', NULL, 51),
(8550, '36620-74PM0(11)-P', '21.5268', '', '', NULL, 51),
(8551, '36620-74PN0(11)-P', '22.5045', '', '', NULL, 51),
(8552, '36620-74PP0(11)-P', '23.0207', '', '', NULL, 51),
(8553, '36620-74PQ0(11)-P', '17.0111', '', '', NULL, 51),
(8554, '36620-74PR0(11)-P', '17.2806', '12', '', NULL, 51),
(8555, '36620-74PS0(11)-P', '17.7968', '', '', NULL, 51),
(8556, '36620-74PU0(11)-P', '16.4949', '', '', NULL, 51),
(8557, '36602-54S00-X3-P', '22.1162', '', '', NULL, 51),
(8558, '36602-54S10-X3-P', '22.6318', '', '', NULL, 51),
(8559, '36602-54S60-X3-P', '17.1826', '', '', NULL, 51),
(8560, '36602-54S70-X3-P', '20.5147', '', '', NULL, 51),
(8561, '36620-54S00-X3-P', '12.7524', '', '', NULL, 51),
(8562, '36620-54S20-X3-P', '13.895', '', '', NULL, 51),
(8563, '36620-54S30-X3-P', '14.5951', '', '', NULL, 51),
(8564, '36620-54S40-X3-P', '15.5278', '', '', NULL, 51),
(8565, '36620-54S50-X3-P', '15.3807', '', '', NULL, 51),
(8566, '36620-54S60-X3-P', '16.3135', '', '', NULL, 51),
(8567, '36620-54S70-X3-P', '15.8668', '', '', NULL, 51),
(8568, '36620-54S80-X3-P', '15.9271', '', '', NULL, 51),
(8569, '36620-54S90-X3-P', '16.6525', '', '', NULL, 51),
(8570, '36620-54SA0-X3-P', '21.0306', '', '', NULL, 51),
(8571, '36620-54SC0-X3-P', '13.3784', '', '', NULL, 51),
(8572, '36620-54SE0-X3-P', '15.0113', '', '', NULL, 51),
(8573, '36620-54SG0-X3-P', '15.7969', '', '', NULL, 51),
(8574, '36620-54SH0-X3-P', '15.3512', '', '', NULL, 51),
(8575, '36620-54SJ0-X3-P', '20.5149', '', '', NULL, 51),
(8576, '36620-54SL0-X3-P', '21.0313', '', '', NULL, 51),
(8577, '36620-54SM0-X3-P', '21.5469', '', '', NULL, 51),
(8578, '36620-54SQ0-X3-P', '17.0105', '', '', NULL, 51),
(8579, '36620-54SR0-X3-P', '17.2806', '', '', NULL, 51),
(8580, '36620-54SS0-X3-P', '17.7962', '', '', NULL, 51),
(8581, '36620-54SU0-X3-P', '16.4949', '', '', NULL, 51),
(8582, '36630-74P00(7)-P', '4.2247', '', '', NULL, 51),
(8583, '36630-74P10(7)-P', '4.455', '', '', NULL, 51),
(8584, '36630-74P20(7)-P', '5.3164', '', '', NULL, 51),
(8585, '36630-74P30(7)-P', '5.7561', '', '', NULL, 51),
(8586, '36630-74P40(7)-P', '4.7839', '24', '', NULL, 51),
(8587, '36630-74P50(7)-P', '5.0142', '', '', NULL, 51),
(8588, '36630-74P60(7)-P', '5.4173', '12', '', NULL, 51),
(8589, '36630-74P70(7)-P', '5.8571', '', '', NULL, 51),
(8590, '36630-74P80(7)-P', '7.1904', '45', '', NULL, 51),
(8591, '36630-74P90(7)-P', '7.6251', '', '', NULL, 51),
(8592, '36630-74PA0(7)-P', '9.0996', '', '', NULL, 51),
(8593, '36630-74PB0(7)-P', '9.304', '', '', NULL, 51),
(8594, '36630-74PC0(7)-P', '8.7041', '', '', NULL, 51),
(8595, '36630-74PD0(7)-P', '9.0307', '', '', NULL, 51),
(8596, '36630-74PE0(7)-P', '7.4207', '', '', NULL, 51),
(8597, '36630-74PF0(7)-P', '6.3981', '', '', NULL, 51),
(8598, '36630-74PG0(7)-P', '6.6075', '', '', NULL, 51),
(8599, '36630-74PH0(7)-P', '8.2801', '', '', NULL, 51),
(8600, '36630-74PJ0(7)-P', '8.4024', '', '', NULL, 51),
(8601, '36630-74PK0(7)-P', '8.4947', '', '', NULL, 51),
(8602, '36630-74PL0(7)-P', '8.617', '', '', NULL, 51),
(8603, '36630-54S00-P', '4.2137', '', '', NULL, 51),
(8604, '36630-54S10-P', '4.444', '', '', NULL, 51),
(8605, '36630-54S20-X3-P', '5.3102', '', '', NULL, 51),
(8606, '36630-54S30-X3-P', '5.7499', '', '', NULL, 51),
(8607, '36630-54S40-X3-P', '4.7727', '', '', NULL, 51),
(8608, '36630-54S50-X3-P', '5.003', '', '', NULL, 51),
(8609, '36630-54S60-X3-P', '5.4112', '', '', NULL, 51),
(8610, '36630-54S70-X3-P', '5.8509', '', '', NULL, 51),
(8611, '36630-54S80-X3-P', '7.1839', '', '', NULL, 51),
(8612, '36630-54S90-X3-P', '7.6185', '', '', NULL, 51),
(8613, '36630-54SA0-X3-P', '8.975', '', '', NULL, 51),
(8614, '36630-54SB0-X3-P', '9.1793', '', '', NULL, 51),
(8615, '36630-54SC0-X3-P', '8.6937', '', '', NULL, 51),
(8616, '36630-54SD0-X3-P', '9.0203', '', '', NULL, 51),
(8617, '36630-54SE0-X3-P', '7.4142', '', '', NULL, 51),
(8618, '36630-54SH0-X3-P', '8.2695', '', '', NULL, 51),
(8619, '36630-54SJ0-X3-P', '8.3918', '', '', NULL, 51),
(8620, '36630-54SK0-X3-P', '8.3705', '', '', NULL, 51),
(8621, '36630-54SL0-X3-P', '8.4928', '', '', NULL, 51),
(8622, '36680-81P00(1)-2-P', '2.5975', '', '', NULL, 51),
(8623, '36680-81P10(1)-2-P', '2.5975', '', '', NULL, 51),
(8624, '36680-81PH0(1)-2-P', '2.5975', '', '', NULL, 51),
(8625, '36680-57S00-1-P', '2.5975', '', '', NULL, 51),
(8626, '36680-57S10-1-P', '2.5975', '', '', NULL, 51),
(8627, '36882-81P00(2)-P', '0.3603', '', '', NULL, 51),
(8628, '36843-57S00-1-P', '1.4737', '', '', NULL, 51),
(8629, '36843-57S10-1-P', '1.5015', '', '', NULL, 51),
(8630, '36843-57SA0-P', '0.3233', '', '', NULL, 51),
(8631, '36756-81P00(3)-2-P', '4.1785', '', '', NULL, 51),
(8632, '36756-81P10(3)-2-P', '4.1785', '', '', NULL, 51),
(8633, '36756-81P20(3)-2-P', '4.2933', '', '', NULL, 51),
(8634, '36756-81P30(3)-2-P', '4.2933', '', '', NULL, 51),
(8635, '36756-57S00-1-P', '4.282', '', '', NULL, 51),
(8636, '36756-57S10-1-P', '4.282', '', '', NULL, 51),
(8637, '36756-57S20-1-P', '4.3968', '', '', NULL, 51),
(8638, '36756-57S30-1-P', '4.3968', '', '', NULL, 51),
(8639, '36757-81P00(3)-1-P', '1.8462', '', '', NULL, 51),
(8640, '36757-81P10(3)-1-P', '1.8462', '', '', NULL, 51),
(8641, '36757-81P20(3)-1-P', '1.9495', '', '', NULL, 51),
(8642, '36757-81P30(3)-1-P', '1.9495', '', '', NULL, 51),
(8643, '36751-81P00(1)-P', '0.4256', '', '', NULL, 51),
(8644, '36751-81P20(1)-P', '1.4205', '', '', NULL, 51),
(8645, '36751-81PA0(2)-P', '0.4256', '', '', NULL, 51),
(8646, '36751-81PC0(2)-P', '1.4205', '', '', NULL, 51),
(8647, '36603-81P20(11)-P', '15.7831', '', '', NULL, 51),
(8648, '36603-81P40(11)-P', '17.1465', '', '', NULL, 51),
(8649, '36630-81P00(11)-P', '10.8939', '', '', NULL, 51),
(8650, '36630-81P10(11)-P', '11.3193', '', '', NULL, 51),
(8651, '36630-81PC0(11)-P', '13.2712', '', '', NULL, 51),
(8652, '36630-81PD0(11)-P', '13.4844', '', '', NULL, 51),
(8653, '36630-81PE0(11)-P', '14.6345', '', '', NULL, 51),
(8654, '36630-81PG0(11)-P', '14.9869', '', '', NULL, 51),
(8655, '36630-81PK0(11)-P', '13.127', '', '', NULL, 51),
(8656, '36630-81PJ0(11)-P', '10.1619', '', '', NULL, 51),
(8657, '36630-81PL0(11)-P', '13.3402', '', '', NULL, 51),
(8658, '36603-57S20-1-P', '16.3457', '', '', NULL, 51),
(8659, '36603-57S60-1-P', '18.4889', '', '', NULL, 51),
(8660, '36603-57S80-1-P', '20.6385', '', '', NULL, 51),
(8661, '36630-57S00-1-P', '11.239', '', '', NULL, 51),
(8662, '36630-57S10-1-P', '11.6701', '', '', NULL, 51),
(8663, '36630-57S20-1-P', '13.379', '', '', NULL, 51),
(8664, '36630-57S30-1-P', '13.8101', '', '', NULL, 51),
(8665, '36630-57SC0-1-P', '13.6169', '', '', NULL, 51),
(8666, '36630-57SD0-1-P', '13.8358', '', '', NULL, 51),
(8667, '36630-57SE0-1-P', '14.749', '', '', NULL, 51),
(8668, '36630-57SG0-1-P', '15.1009', '', '', NULL, 51),
(8669, '36630-57SH0-1-P', '15.7568', '', '', NULL, 51),
(8670, '36630-57SJ0-1-P', '15.9758', '', '', NULL, 51),
(8671, '36630-57SK0-1-P', '17.9063', '', '', NULL, 51),
(8672, '36630-57SL0-1-P', '18.2584', '', '', NULL, 51),
(8673, '36680-80P00(1)-1-P', '1.3835', '30', '', NULL, 51),
(8674, '36680-80P10(1)-1-P', '1.7006', '40', '', NULL, 51),
(8675, '36680-80P20(1)-1-P', '1.3835', '', '', NULL, 51),
(8676, '36680-80P30(1)-1-P', '1.7006', '20', '', NULL, 51),
(8677, '36820-80P00-4-P', '0.7451', '40', '', NULL, 51),
(8678, '36820-80P10-4-P', '1.0532', '', '', NULL, 51),
(8679, '36820-80P20-4-P', '1.1506', '40', '', NULL, 51),
(8680, '36820-80P30-4-P', '1.4587', '', '', NULL, 51),
(8681, '39312-80P00-P', '0.096', '', '', NULL, 51),
(8682, '36620-80P00(5)-P', '18.9777', '', '', NULL, 51),
(8683, '36620-80P10(5)-P', '19.6927', '', '', NULL, 51),
(8684, '36620-80P20(5)-P', '20.7791', '', '', NULL, 51),
(8685, '36620-80P30(5)-P', '21.4941', '', '', NULL, 51),
(8686, '36620-80P40(5)-P', '18.0335', '', '', NULL, 51),
(8687, '36620-80P50(5)-P', '18.7486', '', '', NULL, 51),
(8688, '36620-80P60(5)-P', '19.8349', '', '', NULL, 51),
(8689, '36620-80P70(5)-P', '20.55', '', '', NULL, 51),
(8690, '36620-80P80(5)-P', '20.3567', '', '', NULL, 51),
(8691, '36620-80P90(5)-P', '21.071', '', '', NULL, 51),
(8692, '36620-80PA0(5)-P', '22.1581', '', '', NULL, 51),
(8693, '36620-80PB0(5)-P', '22.8724', '', '', NULL, 51),
(8694, '36620-80PC0(5)-P', '18.4431', '', '', NULL, 51),
(8695, '36620-80PD0(5)-P', '19.8045', '', '', NULL, 51),
(8696, '36620-80PJ0(5)-P', '20.8689', '', '', NULL, 51),
(8697, '36620-80PK0(5)-P', '22.4669', '', '', NULL, 51),
(8698, '36630-80P00(4)-P', '9.1541', '18', '', NULL, 51),
(8699, '36630-80P10(4)-P', '9.3582', '', '', NULL, 51),
(8700, '36630-80P20(4)-P', '9.1541', '', '', NULL, 51),
(8701, '36630-80P30(4)-P', '9.3582', '', '', NULL, 51),
(8702, '36630-80P40(4)-P', '9.539', '36', '', NULL, 51),
(8703, '36630-80P50(4)-P', '9.8686', '6', '', NULL, 51),
(8704, '36630-80P60(4)-P', '9.539', '24', '', NULL, 51),
(8705, '36630-80P70(4)-P', '9.8686', '6', '', NULL, 51),
(8706, '36630-80P80(4)-P', '7.9313', '12', '', NULL, 51),
(8707, '36630-80P90(4)-P', '8.1416', '', '', NULL, 51),
(8708, '36630-80PE0(4)-P', '9.7431', '', '', NULL, 51),
(8709, '36630-80PF0(4)-P', '9.7431', '', '', NULL, 51),
(8710, '36620-52R00(4)-P', '19.1654', '', '', NULL, 51),
(8711, '36620-52R20(4)-P', '22.095', '15', '', NULL, 51),
(8712, '36620-52R30(4)-P', '23.2294', '', '', NULL, 51),
(8713, '36620-52R40(4)-P', '21.4351', '', '', NULL, 51),
(8714, '36620-52R50(4)-P', '22.86', '', '', NULL, 51),
(8715, '36620-52R80(4)-P', '24.3191', '', '', NULL, 51),
(8716, '36620-52R90(4)-P', '25.4535', '20', '', NULL, 51),
(8717, '36620-52RA0(4)-P', '23.1024', '15', '', NULL, 51),
(8718, '36620-52RB0(4)-P', '24.2367', '', '', NULL, 51),
(8719, '36620-52RC0(4)-P', '20.1649', '', '', NULL, 51),
(8720, '36620-52RG0(4)-P', '22.5973', '', '', NULL, 51),
(8721, '36620-52RH0(4)-P', '23.7183', '', '', NULL, 51),
(8722, '36620-52RL0(4)-P', '24.8245', '', '', NULL, 51),
(8723, '36620-52RM0(4)-P', '25.9454', '', '', NULL, 51),
(8724, '36620-52RP0(4)-P', '22.2727', '15', '', NULL, 51),
(8725, '36620-52RQ0(4)-P', '20.1445', '', '', NULL, 51),
(8726, '36620-52RR0(4)-P', '23.087', '', '', NULL, 51),
(8727, '36620-53R20(4)-P', '17.5067', '', '', NULL, 51),
(8728, '36620-53R30(4)-P', '19.1209', '', '', NULL, 51),
(8729, '36620-53R40(4)-P', '15.6893', '', '', NULL, 51),
(8730, '36620-53R50(4)-P', '18.6634', '25', '', NULL, 51),
(8731, '36620-53R60(4)-P', '19.3892', '', '', NULL, 51),
(8732, '36620-53R70(4)-P', '20.2516', '', '', NULL, 51),
(8733, '36620-53R90(4)-P', '22.9794', '15', '', NULL, 51),
(8734, '36620-53RA0(4)-P', '19.4373', '', '', NULL, 51),
(8735, '36620-53RB0(4)-P', '24.5025', '', '', NULL, 51),
(8736, '36620-53RC0(4)-P', '24.6063', '', '', NULL, 51),
(8737, '36620-53RD0(4)-P', '25.2132', '', '', NULL, 51),
(8738, '36620-53RE0(4)-P', '25.317', '', '', NULL, 51),
(8739, '36620-53RF0(4)-P', '17.6104', '15', '', NULL, 51),
(8740, '36620-53RG0(4)-P', '19.2246', '', '', NULL, 51),
(8741, '36620-53RH0(4)-P', '18.7671', '20', '', NULL, 51),
(8742, '36620-53RJ0(4)-P', '19.4929', '', '', NULL, 51),
(8743, '36620-68R00(1)-P', '21.2855', '25', '', NULL, 51),
(8744, '36620-68R10(1)-P', '23.8117', '30', '', NULL, 51),
(8745, '36620-68R20(1)-P', '24.946', '', '', NULL, 51),
(8746, '36620-68R50(1)-P', '22.8718', '', '', NULL, 51),
(8747, '36620-68R60(1)-P', '22.9755', '', '', NULL, 51),
(8748, '36620-68R70(1)-P', '23.0678', '', '', NULL, 51),
(8749, '36620-68R80(1)-P', '23.1715', '', '', NULL, 51),
(8750, '36620-68R90(1)-P', '24.283', '', '', NULL, 51),
(8751, '36620-68RA0(1)-P', '24.3867', '', '', NULL, 51),
(8752, '36620-68RB0(1)-P', '25.1002', '', '', NULL, 51),
(8753, '36620-68RC0(1)-P', '25.2039', '', '', NULL, 51),
(8754, '36602-53R00(4)-P', '13.5514', '', '', NULL, 51),
(8755, '36602-53R10(4)-P', '16.4214', '', '', NULL, 51),
(8756, '36602-53R20(4)-P', '17.8433', '', '', NULL, 51),
(8757, '36602-53R30(4)-P', '15.6822', '', '', NULL, 51),
(8758, '36602-53R40(4)-P', '17.9609', '', '', NULL, 51),
(8759, '36602-53R51(4)-P', '19.0584', '', '', NULL, 51),
(8760, '36602-53R70(4)-P', '19.876', '', '', NULL, 51);
INSERT INTO `eff_product_rep` (`ID`, `product_no`, `std_time`, `output_qty`, `output_min`, `group_id`, `batch_id`) VALUES
(8761, '36602-53R80(4)-P', '21.2114', '', '', NULL, 51),
(8762, '36602-53R90(4)-P', '22.4956', '', '', NULL, 51),
(8763, '36602-53RC0(4)-P', '23.7968', '', '', NULL, 51),
(8764, '36602-53RD0(4)-P', '23.9008', '', '', NULL, 51),
(8765, '36602-53RE0(4)-P', '24.4899', '', '', NULL, 51),
(8766, '36602-53RF0(4)-P', '24.594', '', '', NULL, 51),
(8767, '36602-53RG0(4)-P', '17.3762', '', '', NULL, 51),
(8768, '36602-53RH0(4)-P', '20.1715', '', '', NULL, 51),
(8769, '36602-53RJ1(4)-P', '18.4566', '', '', NULL, 51),
(8770, '36602-53RK1(4)-P', '19.1624', '', '', NULL, 51),
(8771, '36602-53RL0(4)-P', '18.3526', '', '', NULL, 51),
(8772, '36602-68R00(1)-P', '22.3647', '', '', NULL, 51),
(8773, '36602-68R10(1)-P', '22.4687', '', '', NULL, 51),
(8774, '36602-68R40(1)-P', '23.5897', '', '', NULL, 51),
(8775, '36602-68R50(1)-P', '23.6938', '', '', NULL, 51),
(8776, '36602-68R60(1)-P', '24.3847', '', '', NULL, 51),
(8777, '36602-68R70(1)-P', '24.4888', '', '', NULL, 51),
(8778, '36602-68R80(1)-P', '19.5801', '', '', NULL, 51),
(8779, '36602-68R90(1)-P', '21.2109', '', '', NULL, 51),
(8780, '36620-57R00-2-P', '12.8569', '25', '', NULL, 51),
(8781, '36620-57R10-2-P', '15.8752', '30', '', NULL, 51),
(8782, '36620-57R20-2-P', '20.9983', '', '', NULL, 51),
(8783, '36620-57R30-2-P', '15.4729', '', '', NULL, 51),
(8784, '36620-57R40-2-P', '20.2868', '', '', NULL, 51),
(8785, '36620-57R50-2-P', '19.4717', '', '', NULL, 51),
(8786, '36620-57R60-2-P', '14.6578', '', '', NULL, 51),
(8787, '36602-57R00-2-P', '15.2379', '', '', NULL, 51),
(8788, '36602-57R10-2-P', '20.0515', '', '', NULL, 51),
(8789, '36602-57R20-2-P', '19.255', '', '', NULL, 51),
(8790, '36602-57R30-2-P', '14.4414', '', '', NULL, 51),
(8791, '33880-63RC0-1-P', '0', '', '', NULL, 51),
(8792, '33880-79R00-2-P', '0', '', '', NULL, 51),
(8793, '36680-79R00-3-P', '1.9303', '', '', NULL, 51),
(8794, '36680-79R20-3-P', '2.3448', '', '', NULL, 51),
(8795, '36680-79R30-3-P', '2.3448', '', '', NULL, 51),
(8796, '36820-79R00-4-P', '0.6567', '', '', NULL, 51),
(8797, '36820-79R10-4-P', '0.9698', '', '', NULL, 51),
(8798, '36820-79R20-4-P', '0.8751', '', '', NULL, 51),
(8799, '36820-79R30-4-P', '1.1882', '', '', NULL, 51),
(8800, '36820-79R40-4-P', '1.0848', '100', '', NULL, 51),
(8801, '36820-79R50-4-P', '1.398', '', '', NULL, 51),
(8802, '36820-79R60-4-P', '1.3032', '480', '', NULL, 51),
(8803, '36820-79R70-4-P', '1.6164', '', '', NULL, 51),
(8804, '36813-79R50-P', '0.4296', '600', '', NULL, 51),
(8805, '36813-79R00-2-P', '1.4487', '390', '', NULL, 51),
(8806, '36756-79R00-4-P', '3.9272', '', '', NULL, 51),
(8807, '36756-79R20-4-P', '4.2298', '', '', NULL, 51),
(8808, '36756-79R30-4-P', '4.2298', '', '', NULL, 51),
(8809, '36756-79R40-4-P', '4.2364', '', '', NULL, 51),
(8810, '36756-79R50-4-P', '4.4388', '', '', NULL, 51),
(8811, '36756-79R60-4-P', '4.6712', '', '', NULL, 51),
(8812, '36756-79R70-4-P', '4.6712', '', '', NULL, 51),
(8813, '36756-79R80-4-P', '4.4388', '', '', NULL, 51),
(8814, '36756-79R90-4-P', '4.2364', '', '', NULL, 51),
(8815, '36757-79R00-3-P', '1.6573', '', '', NULL, 51),
(8816, '36757-79R20-3-P', '1.9607', '', '', NULL, 51),
(8817, '36757-79R30-3-P', '2.1637', '', '', NULL, 51),
(8818, '36757-79R40-3-P', '2.3962', '', '', NULL, 51),
(8819, '36757-79R50-3-P', '2.3962', '', '', NULL, 51),
(8820, '36757-79R60-3-P', '2.1637', '80', '', NULL, 51),
(8821, '36757-79R70-3-P', '1.9607', '', '', NULL, 51),
(8822, '36751-79R00-3-P', '0.4217', '', '', NULL, 51),
(8823, '36751-79R10-3-P', '1.4114', '', '', NULL, 51),
(8824, '36751-79RC0-3-P', '1.4114', '', '', NULL, 51),
(8825, '36690-79R00-1-P', '0.2', '300', '', NULL, 51),
(8826, '36602-79R00-4-P', '19.5992', '', '', NULL, 51),
(8827, '36602-79R20-4-P', '22.626', '', '', NULL, 51),
(8828, '36620-79R00-4-P', '21.5177', '70', '', NULL, 51),
(8829, '36620-79R10-4-P', '23.7428', '', '', NULL, 51),
(8830, '36620-79R20-4-P', '23.8338', '', '', NULL, 51),
(8831, '36620-79R30-4-P', '26.0699', '', '', NULL, 51),
(8832, '36620-79R40-4-P', '23.3356', '', '', NULL, 51),
(8833, '36620-79R50-4-P', '25.5718', '', '', NULL, 51),
(8834, '36620-79R60-4-P', '24.2299', '', '', NULL, 51),
(8835, '36620-79R70-4-P', '26.2596', '', '', NULL, 51),
(8836, '36620-79R80-4-P', '26.546', '', '', NULL, 51),
(8837, '36620-79R90-4-P', '28.5867', '', '', NULL, 51),
(8838, '36620-79RA0-4-P', '26.0478', '', '', NULL, 51),
(8839, '36620-79RB0-4-P', '28.0886', '', '', NULL, 51),
(8840, '36620-79RC0-4-P', '23.7395', '', '', NULL, 51),
(8841, '36620-79RD0-4-P', '26.4517', '', '', NULL, 51),
(8842, '36620-79RE0-4-P', '23.117', '', '', NULL, 51),
(8843, '36620-79RF0-4-P', '25.3421', '', '', NULL, 51),
(8844, '36620-79RG0-4-P', '25.4331', '', '', NULL, 51),
(8845, '36620-79RH0-4-P', '27.6692', '', '', NULL, 51),
(8846, '36620-79RJ0-4-P', '24.9349', '', '', NULL, 51),
(8847, '36620-79RK0-4-P', '27.171', '', '', NULL, 51),
(8848, '36620-79RL0-4-P', '25.3388', '', '', NULL, 51),
(8849, '36920-79R00-4-P', '24.2473', '', '', NULL, 51),
(8850, '36920-79R10-4-P', '26.0796', '', '', NULL, 51),
(8851, '36920-79R20-4-P', '23.7492', '', '', NULL, 51),
(8852, '36920-79R30-4-P', '25.5815', '', '', NULL, 51),
(8853, '36920-79R40-4-P', '26.9595', '', '', NULL, 51),
(8854, '36920-79R50-4-P', '28.5964', '', '', NULL, 51),
(8855, '36920-79R60-4-P', '26.4614', '', '', NULL, 51),
(8856, '36920-79R70-4-P', '28.0983', '', '', NULL, 51),
(8857, '36920-79R80-4-P', '24.1708', '', '', NULL, 51),
(8858, '36920-79R90-4-P', '26.0031', '', '', NULL, 51),
(8859, '36920-79RA0-4-P', '26.883', '', '', NULL, 51),
(8860, '36920-79RB0-4-P', '28.5199', '55', '', NULL, 51),
(8861, '36920-79RC0-4-P', '25.7701', '95', '', NULL, 51),
(8862, '36920-79RD0-4-P', '27.6024', '', '', NULL, 51),
(8863, '36603-79R00-4-P', '9.202', '', '', NULL, 51),
(8864, '36603-79R10-4-P', '10.8789', '', '', NULL, 51),
(8865, '36603-79R20-4-P', '9.4043', '', '', NULL, 51),
(8866, '36603-79R30-4-P', '11.0812', '', '', NULL, 51),
(8867, '36630-79R00-4-P', '14.9542', '', '', NULL, 51),
(8868, '36630-79R10-4-P', '13.1866', '', '', NULL, 51),
(8869, '36630-79R20-4-P', '16.6311', '', '', NULL, 51),
(8870, '36630-79R40-4-P', '15.3476', '', '', NULL, 51),
(8871, '36630-79R60-4-P', '17.0245', '', '', NULL, 51),
(8872, '36630-79R70-4-P', '15.931', '', '', NULL, 51),
(8873, '36630-79R80-4-P', '17.6079', '', '', NULL, 51),
(8874, '36630-79R90-4-P', '11.7119', '', '', NULL, 51),
(8875, '36630-79RA0-4-P', '15.1627', '', '', NULL, 51),
(8876, '36630-79RB0-4-P', '13.3888', '', '', NULL, 51),
(8877, '36630-79RC0-4-P', '16.8396', '', '', NULL, 51),
(8878, '36630-79RE0-4-P', '15.6878', '', '', NULL, 51),
(8879, '36630-79RG0-4-P', '17.3647', '', '', NULL, 51),
(8880, '36630-79RH0-4-P', '16.2713', '', '', NULL, 51),
(8881, '36630-79RJ0-4-P', '17.9481', '', '', NULL, 51),
(8882, '36630-79RK0-4-P', '11.5096', '', '', NULL, 51),
(8883, '36630-79RL0-4-P', '11.8778', '', '', NULL, 51),
(8884, '36650-79R00-6-P', '11.2475', '298', '', NULL, 51),
(8885, '36650-79R10-6-P', '10.0545', '', '', NULL, 51),
(8886, '36650-79R20-6-P', '10.7936', '', '', NULL, 51),
(8887, '33880-76R00-1-P', '0', '', '', NULL, 51),
(8888, '36680-76R00-4-P', '1.7861', '', '', NULL, 51),
(8889, '36680-76R010-4-P', '1.7861', '', '', NULL, 51),
(8890, '36820-76R00-3-P', '0.6468', '', '', NULL, 51),
(8891, '36820-76R10-3-P', '1.0658', '', '', NULL, 51),
(8892, '36820-76R20-3-P', '0.9583', '', '', NULL, 51),
(8893, '36820-76R30-3-P', '1.3774', '', '', NULL, 51),
(8894, '36843-76R00-2-P', '0.2238', '', '', NULL, 51),
(8895, '36843-76R10-2-P', '1.695', '', '', NULL, 51),
(8896, '36756-76R00-3-P', '4.2432', '', '', NULL, 51),
(8897, '36756-76R10-3-P', '4.2432', '', '', NULL, 51),
(8898, '36756-76R20-3-P', '4.4815', '', '', NULL, 51),
(8899, '36756-76R30-3-P', '4.4815', '', '', NULL, 51),
(8900, '36757-76R00-2-P', '1.917', '', '', NULL, 51),
(8901, '36757-76R10-2-P', '1.917', '', '', NULL, 51),
(8902, '36757-76R20-2-P', '2.1554', '', '', NULL, 51),
(8903, '36757-76R30-2-P', '2.1554', '', '', NULL, 51),
(8904, '36751-76R00-3-P', '0.9105', '', '', NULL, 51),
(8905, '36630-76R20-3-P', '11.5895', '', '', NULL, 51),
(8906, '36630-76R30-3-P', '14.8234', '', '', NULL, 51),
(8907, '36630-76R60-3-P', '12.0157', '', '', NULL, 51),
(8908, '36630-76R70-3-P', '15.2362', '', '', NULL, 51),
(8909, '36630-76R80-3-P', '12.1209', '', '', NULL, 51),
(8910, '36630-76R90-3-P', '15.3415', '', '', NULL, 51),
(8911, '36851-31J10-4-P', '0.0972', '', '', NULL, 51),
(8912, '36854-31J20-3-P', '0.379', '', '', NULL, 51),
(8913, '36856-31J10-3-P', '0.6649', '', '', NULL, 51),
(8914, '33860-31J10-3-P', '0.3902', '', '', NULL, 51),
(8915, '33810-31J10-3-P', '0', '', '', NULL, 51),
(8916, '36610-31JK0(1)-P', '20.7102', '', '', NULL, 51),
(8917, '36610-31JQ0(1)-P', '19.3023', '', '', NULL, 51),
(8918, '36610-31JN0(1)-P', '18.8213', '', '', NULL, 51),
(8919, '36610-31JP0(1)-P', '19.0441', '', '', NULL, 51),
(8920, '36620-31J10-4-P', '3.3549', '', '', NULL, 51),
(8921, 'YSD-LHD-AL1-1', '0.305', '', '', NULL, 51),
(8922, 'YSD-LHD-CI1-1', '0.3242', '', '', NULL, 51),
(8923, 'YSD-RHD-AL1', '0.3147', '', '', NULL, 51),
(8924, 'YSD-RHD-CI1-1', '0.3245', '', '', NULL, 51),
(8925, 'YSD-RHD-CI2-1', '0.5408', '', '', NULL, 51),
(9074, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 1, 55),
(9075, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', 1, 55),
(9076, 'NC8V-67-030A(7)-D', '18.7353', '5', '', 1, 55),
(9077, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', 1, 55),
(9078, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 1, 55),
(9079, 'NA4N-67-290A(4)-1', '1.6564', '', '', 1, 55),
(9080, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 1, 55),
(9081, 'NA4M-67-290B(6)', '0.8982', '20', '', 1, 55),
(9082, 'NA4L-67-290B(6)', '1.7623', '20', '', 1, 55),
(9083, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 1, 55),
(9084, 'NA4M-67-290B(6)', '0.8982', '', '', 1, 55),
(9085, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 1, 55),
(9086, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', 1, 55),
(9087, 'NA4N-67-290A(4)-1', '1.6564', '', '', 1, 55),
(9088, 'NC8V-67-030A(7)-D', '18.7353', '', '', 1, 55),
(9089, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 1, 55),
(9090, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', 1, 55),
(9091, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 1, 55),
(9092, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 1, 55),
(9093, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 2, 55),
(9109, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 2, 56),
(9110, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 2, 56),
(9111, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', 2, 56),
(9112, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', 2, 56),
(9113, 'NC8V-67-030A(7)-D', '18.7353', '5', '', 2, 56),
(9114, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 2, 56),
(9115, 'NA4N-67-290A(4)-1', '1.6564', '', '', 2, 56),
(9116, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 2, 56),
(9117, 'NA4L-67-290B(6)', '1.7623', '20', '', 2, 56),
(9118, 'NA4M-67-290B(6)', '0.8982', '', '', 2, 56),
(9119, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 2, 56),
(9120, 'NA4M-67-290B(6)', '0.8982', '20', '', 2, 56),
(9121, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', 2, 56),
(9122, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 2, 56),
(9123, 'NA4N-67-290A(4)-1', '1.6564', '', '', 2, 56),
(9124, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 1, 57),
(9125, 'NC8V-67-030A(7)-D', '18.7353', '5', '', 1, 57),
(9126, 'NC6N-67-030A(7)-3-D', '20.1358', '5', '', 1, 57),
(9127, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 1, 57),
(9128, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 1, 57),
(9129, 'NA4N-67-06YA(2)-2', '0.7806', '15', '', 1, 57),
(9130, 'NA4N-67-290A(4)-1', '1.6564', '', '', 1, 57),
(9131, 'NA4L-67-290B(6)', '1.7623', '20', '', 1, 57),
(9132, 'NA4M-67-290B(6)', '0.8982', '20', '', 1, 57),
(9133, 'NA4M-67-290B(6)', '0.8982', '', '', 1, 57),
(9134, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 1, 57),
(9135, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 1, 57),
(9136, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', 1, 57),
(9137, 'NA4N-67-290A(4)-1', '1.6564', '', '', 1, 57),
(9138, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', 1, 57),
(9139, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', 1, 57),
(9140, 'NC8V-67-030A(7)-D', '18.7353', '', '', 1, 57),
(9141, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 1, 57),
(9142, 'NA4L-67-06YA(2)-2', '0.5854', '', '', 1, 57),
(9143, 'NC9P-67-030A(8)-D', '21.0736', '1', '', 1, 57),
(9146, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 59),
(9147, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 59),
(9148, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 59),
(9149, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 59),
(9150, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 59),
(9151, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 59),
(9152, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 59),
(9153, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 59),
(9154, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 59),
(9155, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 59),
(9156, 'NC6N-67-030A(7)-3-D', '20.1358', '', '', NULL, 58),
(9157, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 58),
(9158, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 58),
(9159, 'NC9P-67-030A(8)-D', '21.0736', '', '', NULL, 58),
(9160, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 58),
(9161, 'NA4N-67-06YA(2)-2', '0.7806', '20', '', NULL, 58),
(9162, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 58),
(9163, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 58),
(9164, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 58),
(9165, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 58),
(9166, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 60),
(9167, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 60),
(9168, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 60),
(9169, 'NA4M-67-290B(6)', '0.8982', '', '', NULL, 60),
(9170, 'NA4M-67-290B(6)', '0.8982', '20', '', NULL, 60),
(9171, 'NA4L-67-290B(6)', '1.7623', '20', '', NULL, 60),
(9172, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 60),
(9173, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 60),
(9174, 'NA4N-67-06YA(2)-2', '0.7806', '11', '', NULL, 60),
(9175, 'NA4N-67-290A(4)-1', '1.6564', '', '', NULL, 60),
(9176, 'NC6L-67-030A(7)-3-D', '22.9065', '', '', NULL, 60),
(9177, 'NC6N-67-030A(7)-3-D', '20.1358', '32', '', NULL, 60),
(9178, 'NC8V-67-030A(7)-D', '18.7353', '', '', NULL, 60),
(9179, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 60),
(9180, 'NA4L-67-06YA(2)-2', '0.5854', '', '', NULL, 60),
(9181, 'NC9P-67-030A(8)-D', '21.0736', '1', '', NULL, 60);

-- --------------------------------------------------------

--
-- Table structure for table `eff_product_st`
--

CREATE TABLE `eff_product_st` (
  `ID` int(11) NOT NULL,
  `product_no` varchar(255) NOT NULL,
  `st` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_product_st`
--

INSERT INTO `eff_product_st` (`ID`, `product_no`, `st`) VALUES
(241, 'ND0S-67-030B(6)-3', '20.8535'),
(242, 'ND0S-67-030B(7)', '20.8513'),
(243, 'ND0T-67-030B(6)-3', '21.2472'),
(244, 'ND0T-67-030B(7)', '21.2449'),
(245, 'ND1A-67-030B(6)-3', '23.3434'),
(246, 'ND1R-67-030B(6)-3', '23.1981'),
(247, 'ND1R-67-030B(7)', '23.1959'),
(248, 'N314-67-030A(4)-2', '16.5754'),
(249, 'N315-67-030A(5)-2', '20.8439'),
(250, 'N316-67-030A(5)-2', '20.8356'),
(251, 'N317-67-030A(5)-2', '20.876'),
(252, 'N319-67-030A(5)-2', '22.9648'),
(253, 'N322-67-030A(5)-2', '23.2681'),
(254, 'N323-67-030A(4)-2', '17.3819'),
(255, 'N324-67-030A(5)-2', '23.3085');

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
(2, 'sample reason'),
(3, 'Delay On Wire'),
(4, 'TRD Machine Problem'),
(5, 'Power Interruption'),
(6, 'Broken/Bend Pin'),
(7, 'NG Operator'),
(8, 'test');

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
(1, 'DS'),
(2, 'NS');

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
  ADD KEY `process_detail_id` (`process_detail_id`) USING BTREE,
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `batch_id` (`batch_id`),
  ADD KEY `group_id` (`group_id`);

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
  ADD KEY `type` (`type`),
  ADD KEY `group_id` (`group_id`);

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
  ADD KEY `process_id` (`process_id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `eff_batch_group`
--
ALTER TABLE `eff_batch_group`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `batch_id` (`batch_id`),
  ADD KEY `group_id` (`group_id`) USING BTREE;

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
  ADD KEY `account_id` (`pic_id`),
  ADD KEY `batch_id` (`batch_id`),
  ADD KEY `process_id` (`process_detail_id`),
  ADD KEY `reason_id` (`reason_id`);

--
-- Indexes for table `eff_group`
--
ALTER TABLE `eff_group`
  ADD PRIMARY KEY (`ID`);

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
  ADD KEY `batch_id` (`batch_id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `eff_product_st`
--
ALTER TABLE `eff_product_st`
  ADD PRIMARY KEY (`ID`);

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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;
--
-- AUTO_INCREMENT for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `eff_3_extended_wt`
--
ALTER TABLE `eff_3_extended_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;
--
-- AUTO_INCREMENT for table `eff_account`
--
ALTER TABLE `eff_account`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT for table `eff_account_type`
--
ALTER TABLE `eff_account_type`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `eff_batch_control`
--
ALTER TABLE `eff_batch_control`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;
--
-- AUTO_INCREMENT for table `eff_batch_group`
--
ALTER TABLE `eff_batch_group`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `eff_car_model`
--
ALTER TABLE `eff_car_model`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `eff_downtime`
--
ALTER TABLE `eff_downtime`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `eff_group`
--
ALTER TABLE `eff_group`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `eff_pic`
--
ALTER TABLE `eff_pic`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT for table `eff_process`
--
ALTER TABLE `eff_process`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `eff_process_detail`
--
ALTER TABLE `eff_process_detail`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `eff_product_rep`
--
ALTER TABLE `eff_product_rep`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9182;
--
-- AUTO_INCREMENT for table `eff_product_st`
--
ALTER TABLE `eff_product_st`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=256;
--
-- AUTO_INCREMENT for table `eff_reason`
--
ALTER TABLE `eff_reason`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
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
  ADD CONSTRAINT `eff_1_manpower_count_ibfk_2` FOREIGN KEY (`batch_id`) REFERENCES `eff_batch_control` (`ID`),
  ADD CONSTRAINT `eff_1_manpower_count_ibfk_3` FOREIGN KEY (`group_id`) REFERENCES `eff_group` (`ID`);

--
-- Constraints for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  ADD CONSTRAINT `eff_2_normal_wt_ibfk_2` FOREIGN KEY (`batch_id`) REFERENCES `eff_batch_control` (`ID`),
  ADD CONSTRAINT `eff_2_normal_wt_ibfk_3` FOREIGN KEY (`group_id`) REFERENCES `eff_group` (`ID`);

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
  ADD CONSTRAINT `eff_account_ibfk_3` FOREIGN KEY (`type`) REFERENCES `eff_account_type` (`ID`),
  ADD CONSTRAINT `eff_account_ibfk_4` FOREIGN KEY (`group_id`) REFERENCES `eff_group` (`ID`);

--
-- Constraints for table `eff_batch_control`
--
ALTER TABLE `eff_batch_control`
  ADD CONSTRAINT `eff_batch_control_ibfk_1` FOREIGN KEY (`car_model_id`) REFERENCES `eff_car_model` (`ID`),
  ADD CONSTRAINT `eff_batch_control_ibfk_2` FOREIGN KEY (`shift_id`) REFERENCES `eff_shift` (`ID`),
  ADD CONSTRAINT `eff_batch_control_ibfk_3` FOREIGN KEY (`account_id`) REFERENCES `eff_account` (`ID`),
  ADD CONSTRAINT `eff_batch_control_ibfk_4` FOREIGN KEY (`process_id`) REFERENCES `eff_process` (`ID`),
  ADD CONSTRAINT `eff_batch_control_ibfk_5` FOREIGN KEY (`group_id`) REFERENCES `eff_group` (`ID`);

--
-- Constraints for table `eff_batch_group`
--
ALTER TABLE `eff_batch_group`
  ADD CONSTRAINT `eff_batch_group_ibfk_1` FOREIGN KEY (`batch_id`) REFERENCES `eff_batch_control` (`ID`),
  ADD CONSTRAINT `eff_batch_group_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `eff_group` (`ID`);

--
-- Constraints for table `eff_downtime`
--
ALTER TABLE `eff_downtime`
  ADD CONSTRAINT `eff_downtime_ibfk_1` FOREIGN KEY (`pic_id`) REFERENCES `eff_pic` (`id`),
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
  ADD CONSTRAINT `eff_product_rep_ibfk_1` FOREIGN KEY (`batch_id`) REFERENCES `eff_batch_control` (`ID`),
  ADD CONSTRAINT `eff_product_rep_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `eff_group` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
