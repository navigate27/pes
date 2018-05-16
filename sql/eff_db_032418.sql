-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 24, 2018 at 09:39 AM
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_account_id` (IN `p_name` VARCHAR(255), IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_car_model_id` INT, IN `p_shift_id` INT, IN `p_acc_type` INT, IN `p_group_id` INT)  NO SQL
BEGIN

IF p_acc_type = 1 THEN

    INSERT eff_account
    (name,username,`password`,car_model_id,shift_id,type,group_id)
    VALUES
 (p_name,p_username,p_password,p_car_model_id,p_shift_id,p_acc_type,NULL);
 
ELSE

    INSERT eff_account
        (name,username,`password`,car_model_id,shift_id,type,group_id)
        VALUES (p_name,p_username,p_password,p_car_model_id,p_shift_id,p_acc_type,p_group_id);

END IF;

END$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_st_id` (IN `p_st_id` INT)  NO SQL
DELETE FROM eff_product_st
WHERE ID = p_st_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_account_id` (IN `p_account_id` INT, IN `p_name` VARCHAR(255), IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_car_model_id` INT, IN `p_shift_id` INT, IN `p_acc_type` INT, IN `p_group_id` INT)  NO SQL
UPDATE eff_account a SET 
a.name = p_name,
a.username = p_username,
a.password = p_password,
a.car_model_id = p_car_model_id,
a.shift_id = p_shift_id,
a.type = p_acc_type,
a.group_id = p_group_id
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_car_model_id` (IN `p_car_model_id` INT, IN `p_car_model_name` VARCHAR(255), IN `p_car_code` VARCHAR(255))  NO SQL
UPDATE eff_car_model a
SET a.car_model_name = p_car_model_name, a.car_code = p_car_code
WHERE a.ID = p_car_model_id$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_st_id` (IN `p_st_id` INT, IN `p_product_no` VARCHAR(255), IN `p_st` VARCHAR(255))  NO SQL
UPDATE eff_product_st a
SET a.product_no = p_product_no,
a.st = p_st
WHERE a.ID = p_st_id$$

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
        a.group_id,
        b.account_name,
        c.car_model_name,
        d.shift,
        e.group_name
    FROM eff_account a
    LEFT JOIN eff_account_type b
    ON a.type = b.ID
    LEFT JOIN eff_car_model c
    ON a.car_model_id = c.ID
    LEFT JOIN eff_shift d
    ON a.shift_id = d.ID
    LEFT JOIN eff_group e
    ON a.group_id = e.ID
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
            a.group_id,
            b.account_name,
            c.car_model_name,
            d.shift,
            e.group_name
        FROM eff_account a
        LEFT JOIN eff_account_type b
        ON a.type = b.ID
        LEFT JOIN eff_car_model c
        ON a.car_model_id = c.ID
        LEFT JOIN eff_shift d
        ON a.shift_id = d.ID
        LEFT JOIN eff_group e
    	ON a.group_id = e.ID
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
            a.group_id,
            b.account_name,
            c.car_model_name,
            d.shift,
            e.group_name
        FROM eff_account a
        LEFT JOIN eff_account_type b
        ON a.type = b.ID
        LEFT JOIN eff_car_model c
        ON a.car_model_id = c.ID
        LEFT JOIN eff_shift d
        ON a.shift_id = d.ID
        LEFT JOIN eff_group e
    	ON a.group_id = e.ID
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
    a.group_id,
    e.group_name,
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
LEFT JOIN eff_group e
ON a.group_id = e.ID
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_all_product_on_query` (IN `p_date` DATE, IN `p_car_model_id` INT, IN `p_shift_id` INT, IN `p_process_id` INT, IN `p_group_id` INT)  NO SQL
BEGIN

IF p_shift_id != 0 THEN

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
            WHERE z.batch_id IN (
                SELECT
                    a1.ID
                FROM eff_batch_control a1
                WHERE a1.date = p_date
                AND a1.shift_id = p_shift_id
                AND a1.process_id = p_process_id
                AND a1.car_model_id = p_car_model_id
            )
        ) AS total_output,
        (
            SELECT 
                SUM(ROUND((z.std_time*z.output_qty),2))
            FROM eff_product_rep z
            WHERE z.batch_id IN (
                SELECT
                    a2.ID
                FROM eff_batch_control a2
                WHERE a2.date = p_date
                AND a2.shift_id = p_shift_id
                AND a2.process_id = p_process_id
                AND a2.car_model_id = p_car_model_id
            )
        ) AS total_output_mins,
        c.shift
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    WHERE a.batch_id IN (
        SELECT
            a3.ID
        FROM eff_batch_control a3
        WHERE a3.date = p_date
        AND a3.shift_id = p_shift_id
        AND a3.process_id = p_process_id
        AND a3.car_model_id = p_car_model_id
    );

ELSE

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
            WHERE z.batch_id IN (
                SELECT
                    a1.ID
                FROM eff_batch_control a1
                WHERE a1.date = p_date
                AND a1.process_id = p_process_id
                AND a1.car_model_id = p_car_model_id
            )
        ) AS total_output,
        (
            SELECT 
                SUM(ROUND((z.std_time*z.output_qty),2))
            FROM eff_product_rep z
            WHERE z.batch_id IN (
                SELECT
                    a2.ID
                FROM eff_batch_control a2
                WHERE a2.date = p_date
                AND a2.process_id = p_process_id
                AND a2.car_model_id = p_car_model_id
            )
        ) AS total_output_mins,
        c.shift
    FROM eff_product_rep a
    LEFT JOIN eff_batch_control b
    ON a.batch_id = b.ID
    LEFT JOIN eff_shift c
    ON b.shift_id = c.ID
    WHERE a.batch_id IN (
        SELECT
            a3.ID
        FROM eff_batch_control a3
        WHERE a3.date = p_date
        AND a3.process_id = p_process_id
        AND a3.car_model_id = p_car_model_id
    );

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
    ) AS total_output_mins,
    c.shift
FROM eff_product_rep a
LEFT JOIN eff_batch_control b
ON a.batch_id = b.ID
LEFT JOIN eff_shift c
ON b.shift_id = c.ID
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
    a.shift,
    a.shift_code
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_product_rep_total_output_mins_on_batch_query` (IN `p_date` DATE, IN `p_car_model_id` INT, IN `p_shift_id` INT, IN `p_process_id` INT, IN `p_group_id` INT)  NO SQL
BEGIN

IF p_shift_id != 0 THEN

    SELECT 
        ROUND(SUM(z.std_time),2) AS total_st,
        SUM(z.output_qty) AS total_output,
        SUM(ROUND((z.std_time*z.output_qty),2)) AS total_output_mins
    FROM eff_product_rep z
    WHERE z.batch_id IN (
        SELECT
            a.ID
        FROM eff_batch_control a
        WHERE a.date = p_date
        AND a.shift_id = p_shift_id
        AND a.process_id = p_process_id
        AND a.car_model_id = p_car_model_id
    );

ELSE

    SELECT 
        ROUND(SUM(z.std_time),2) AS total_st,
        SUM(z.output_qty) AS total_output,
        SUM(ROUND((z.std_time*z.output_qty),2)) AS total_output_mins
    FROM eff_product_rep z
    WHERE z.batch_id IN (
        SELECT
            a.ID
        FROM eff_batch_control a
        WHERE a.date = p_date
        AND a.process_id = p_process_id
        AND a.car_model_id = p_car_model_id
    );
    
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
        AND z.car_model_id = p_car_model_id
        AND z.shift_id = p_shift_id
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
        AND z.car_model_id = p_car_model_id
        AND z.shift_id = p_shift_id
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
        AND z.car_model_id = p_car_model_id
        AND z.shift_id = p_shift_id
    );

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
        AND z.car_model_id = p_car_model_id
        AND z.shift_id = p_shift_id
    );
    
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_st_id` (IN `p_st_id` INT)  NO SQL
SELECT
	a.ID,
    a.product_no,
    a.st
FROM eff_product_st a
WHERE a.ID = p_st_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_st_on_product_no` (IN `p_product_no` VARCHAR(255))  NO SQL
SELECT
	a.ID,
    a.product_no,
    a.st
FROM eff_product_st a
WHERE a.product_no = p_product_no$$

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
(8, 1, 10, 1, 0, 0, '', 1, 93),
(9, 2, 0, 2, 0, 0, '', 1, 93),
(10, 3, 0, 3, 0, 0, '', 1, 93),
(11, 4, 0, 0, 0, 0, '', 1, 93),
(12, 5, 1, 4, 0, 1, '', 1, 93),
(13, 6, 0, 0, 0, 1, '', 1, 93),
(14, 8, 0, 0, 0, 0, '', 1, 93);

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
(5, 540, 0, 0, 0, 0, 1, 1, 93),
(6, 540, 0, 0, 0, 0, 0, 1, 93),
(7, 510, 0, 0, 0, 1, 1, 1, 93),
(8, 510, 0, 0, 0, 1, 0, 1, 93);

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
(8, 8, 1, 0, 0, 0),
(9, 9, 0, 0, 0, 0),
(10, 10, 0, 1, 0, 0),
(11, 11, 0, 0, 0, 0),
(12, 12, 0, 0, 0, 0),
(13, 13, 0, 0, 0, 0),
(14, 14, 0, 0, 0, 0);

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
(1, 'Barney Stinson', 'thebarney', 'legendary', NULL, NULL, NULL, NULL, NULL, 1),
(2, 'Ted Mosby', 'thearchitect', 'jedmosley', 3, NULL, NULL, NULL, 1, 2),
(5, 'Zyrene', 'zai', '212724', 2, NULL, NULL, NULL, 1, 2),
(7, 'Avril', 'admin', 'admin', NULL, NULL, NULL, NULL, NULL, 3),
(8, 'edge', 'test_edge', 'testedge', 3, NULL, NULL, NULL, 2, 2),
(15, 'edge', 'test_edge', 'edge', NULL, NULL, NULL, NULL, NULL, 1),
(16, 'null', 'nullu', 'nullpass', NULL, NULL, NULL, NULL, NULL, 1),
(17, 'test null', 'nulluu', 'nullpass', 2, NULL, NULL, NULL, 2, 2),
(18, 'test2null', 'nulltest', 'nullpass', 3, NULL, NULL, NULL, 1, 2);

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
(88, '2018-03-17', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, 1, 1),
(89, '2018-03-13', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 2, 6, 1, 1),
(90, '2018-03-17', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 2, 5, 1, 1),
(91, '2018-03-14', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 2, 6, 1, 1),
(92, '2018-03-17', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 2, 6, 1, 1),
(93, '2018-03-13', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, 1, 1),
(94, '2018-03-17', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 2, 1, 1, 1),
(95, '2018-03-13', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 5, 1, 1),
(96, '2018-03-13', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, 1, 1);

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
(2, 80, 70, 80, 75, 93, 1);

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
(13, 'QA');

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
(16, 'ND1R-67-030B(6)-3', '23.1981', '2', '', NULL, 88),
(17, 'KB9H-67-210(8)-3', '23.1959', '10', '', NULL, 89),
(18, 'N314-67-030A(4)-2', '16.5754', '3', '', NULL, 90),
(19, 'N315-67-030A(5)-2', '20.8439', '22', '', NULL, 91),
(20, 'N316-67-030A(5)-2', '20.8356', '5', '', NULL, 92),
(21, 'N317-67-030A(5)-2', '20.876', '8', '', 1, 93),
(22, 'N319-67-030A(5)-2', '22.9648', '16', '', NULL, 94),
(23, 'N322-67-030A(5)-2', '23.2681', '7', '', NULL, 95),
(24, 'N323-67-030A(4)-2', '17.3819', '12', '', NULL, 96),
(25, 'N324-67-030A(5)-2', '23.3085', '51', '', 1, 93);

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
(388, 'ND1R-67-030B(6)-3', '23.1981'),
(389, 'KB9H-67-210(8)-3', '23.1959'),
(390, 'N314-67-030A(4)-2', '16.5754'),
(391, 'N315-67-030A(5)-2', '20.8439'),
(392, 'N316-67-030A(5)-2', '20.8356'),
(393, 'N317-67-030A(5)-2', '20.876'),
(394, 'N319-67-030A(5)-2', '22.9648'),
(395, 'N322-67-030A(5)-2', '23.2681'),
(396, 'N323-67-030A(4)-2', '17.3819'),
(397, 'N324-67-030A(5)-2', '23.3085');

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
(7, 'Broken/Bend Pin');

-- --------------------------------------------------------

--
-- Table structure for table `eff_shift`
--

CREATE TABLE `eff_shift` (
  `ID` int(11) NOT NULL,
  `shift` varchar(255) NOT NULL,
  `shift_code` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_shift`
--

INSERT INTO `eff_shift` (`ID`, `shift`, `shift_code`) VALUES
(1, 'DS', 'D1,D2'),
(2, 'NS', 'N3,N4');

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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `eff_3_extended_wt`
--
ALTER TABLE `eff_3_extended_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT for table `eff_account`
--
ALTER TABLE `eff_account`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT for table `eff_account_type`
--
ALTER TABLE `eff_account_type`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `eff_batch_control`
--
ALTER TABLE `eff_batch_control`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;
--
-- AUTO_INCREMENT for table `eff_batch_group`
--
ALTER TABLE `eff_batch_group`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `eff_car_model`
--
ALTER TABLE `eff_car_model`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `eff_downtime`
--
ALTER TABLE `eff_downtime`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;
--
-- AUTO_INCREMENT for table `eff_group`
--
ALTER TABLE `eff_group`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `eff_pic`
--
ALTER TABLE `eff_pic`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;
--
-- AUTO_INCREMENT for table `eff_product_st`
--
ALTER TABLE `eff_product_st`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=398;
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
