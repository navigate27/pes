-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 09, 2018 at 05:34 PM
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_edit_product_no` (IN `p_car_model_id` INT, IN `p_date` DATE, IN `p_shift_id` INT, IN `p_process_id` INT, IN `p_product_no` VARCHAR(255), IN `p_st` VARCHAR(255), IN `p_qty` VARCHAR(255))  NO SQL
BEGIN

DECLARE _batch_exist INT;
DECLARE _batch_id INT;

SET _batch_exist = (
    SELECT
    	COUNT(z.ID)
    FROM eff_batch_control z
    WHERE z.car_model_id = p_car_model_id
    AND z.date = p_date
    AND z.shift_id = p_shift_id
    AND z.process_id = p_process_id
);

IF _batch_exist = 0 THEN
	INSERT INTO eff_batch_control 
    (car_model_id, `date`, shift_id, process_id) VALUES
    (p_car_model_id, p_date, p_shift_id, p_process_id);
    
    SET _batch_id = LAST_INSERT_ID();
    
    INSERT INTO eff_product_rep 
    (product_no, std_time, output_qty, group_id, batch_id) VALUES
    (p_product_no, p_st, p_qty, NULL, _batch_id);
    
ELSE
	
    SET _batch_id = (
        SELECT
            z.ID
        FROM eff_batch_control z
        WHERE z.car_model_id = p_car_model_id
        AND z.date = p_date
        AND z.shift_id = p_shift_id
        AND z.process_id = p_process_id
    );
    
    INSERT INTO eff_product_rep 
    (product_no, std_time, output_qty, group_id, batch_id) VALUES
    (p_product_no, p_st, p_qty, NULL, _batch_id);
    
END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_edit_product_st` (IN `p_product_no` VARCHAR(255), IN `p_st` VARCHAR(255), IN `p_account_id` INT)  NO SQL
BEGIN

DECLARE _is_pn_exist INT;

SET _is_pn_exist = (
    SELECT
    	COUNT(z.ID)
    FROM eff_product_st z
    WHERE z.product_no = p_product_no
);

IF _is_pn_exist = 0 THEN

	INSERT INTO eff_product_st (product_no, st, last_update, updated_by) VALUES
	(p_product_no, p_st, NOW(), p_account_id);
	SELECT 'add' AS 'action';
    
ELSE

	UPDATE eff_product_st a 
    SET a.st = p_st, 
    a.last_update = NOW(),
    a.updated_by = p_account_id
    WHERE a.product_no = p_product_no;
	SELECT 'edit' AS 'action';
    
END IF;


END$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_product_st_id` (IN `p_product_no` VARCHAR(255), IN `p_st` VARCHAR(255), IN `p_account_id` INT)  NO SQL
INSERT INTO eff_product_st (product_no, st, last_update, updated_by) VALUES
(p_product_no, p_st, NULL, p_account_id)$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_st_id` (IN `p_st_id` INT, IN `p_product_no` VARCHAR(255), IN `p_st` VARCHAR(255), IN `p_account_id` INT)  NO SQL
UPDATE eff_product_st a
SET a.product_no = p_product_no,
a.st = p_st,
a.last_update = NOW(),
a.updated_by = p_account_id
WHERE a.ID = p_st_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_edit_st_pn` (IN `p_product_no` VARCHAR(255), IN `p_st` VARCHAR(255), IN `p_account_id` INT)  NO SQL
UPDATE eff_product_st a
SET a.st = p_st,
a.last_update = NOW(),
a.updated_by = p_account_id
WHERE a.product_no = p_product_no$$

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
    a.st,
    a.last_update,
    a.updated_by,
    b.name,
    b.username
FROM eff_product_st a
LEFT JOIN eff_account b
ON a.updated_by = b.ID$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_cycle_car_maker_id` (IN `p_car_maker_id` INT, IN `p_shift_id` INT)  NO SQL
SELECT
	a.ID,
    a.car_model_id,
    b.car_model_name,
    b.car_code,
    a.shift_id,
    c.shift,
    c.shift_code,
    a.cycle
FROM eff_car_model_cycle a
LEFT JOIN eff_car_model b
ON a.car_model_id = b.ID
LEFT JOIN eff_shift c
ON a.shift_id = c.ID
WHERE a.car_model_id = p_car_maker_id
AND a.shift_id = p_shift_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_cycle_car_maker_id_shift_id` (IN `p_car_maker_id` INT, IN `p_shift_id` INT)  NO SQL
SELECT
	a.ID,
    a.car_model_id,
    b.car_model_name,
    b.car_code,
    a.shift_id,
    c.shift,
    c.shift_code,
    a.cycle
FROM eff_car_model_cycle a
LEFT JOIN eff_car_model b
ON a.car_model_id = b.ID
LEFT JOIN eff_shift c
ON a.shift_id = c.ID
WHERE a.car_model_id = p_car_maker_id
AND a.shift_id = p_shift_id$$

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
(22, 1, 15, 0, 0, 0, '', 1, 105),
(23, 2, 1, 0, 0, 0, '', 1, 105),
(24, 3, 5, 2, 0, 0, '', 1, 105),
(25, 4, 10, 0, 0, 0, '', 1, 105),
(26, 5, 2, 0, 0, 1, '', 1, 105),
(27, 6, 2, 0, 0, 1, '', 1, 105),
(28, 8, 0, 0, 0, 0, '', 1, 105),
(29, 1, 0, 0, 0, 0, '', 1, 106),
(30, 2, 0, 0, 0, 0, '', 1, 106),
(31, 3, 0, 0, 0, 0, '', 1, 106),
(32, 4, 0, 0, 0, 0, '', 1, 106),
(33, 5, 0, 0, 0, 1, '', 1, 106),
(34, 6, 0, 0, 0, 1, '', 1, 106),
(35, 8, 0, 0, 0, 0, '', 1, 106),
(36, 1, 11, 0, 5, 0, 'support suzuki', 2, 107),
(37, 2, 1, 0, 0, 0, '', 2, 107),
(38, 3, 2, 0, 1, 0, 'support suzuki', 2, 107),
(39, 4, 5, 0, 0, 0, '', 2, 107),
(40, 5, 1, 0, 0, 1, '', 2, 107),
(41, 6, 2, 0, 0, 1, '', 2, 107),
(42, 8, 0, 0, 0, 0, '', 2, 107),
(43, 1, 3, 0, 0, 0, '', 2, 303),
(44, 2, 0, 0, 0, 0, '', 2, 303),
(45, 3, 0, 0, 0, 0, '', 2, 303),
(46, 4, 1, 0, 0, 0, '', 2, 303),
(47, 5, 0, 0, 0, 1, '', 2, 303),
(48, 6, 1, 0, 0, 1, '', 2, 303),
(49, 8, 0, 0, 0, 0, '', 2, 303),
(50, 1, 9, 0, 0, 0, '', 2, 304),
(51, 2, 1, 0, 0, 0, '', 2, 304),
(52, 3, 0, 0, 0, 0, '', 2, 304),
(53, 4, 4, 0, 0, 0, '', 2, 304),
(54, 5, 1, 0, 0, 1, '', 2, 304),
(55, 6, 2, 0, 0, 1, '', 2, 304),
(56, 8, 0, 0, 0, 0, '', 2, 304),
(57, 1, 3, 0, 0, 0, '', 2, 306),
(58, 2, 0, 0, 0, 0, '', 2, 306),
(59, 3, 0, 0, 0, 0, '', 2, 306),
(60, 4, 1, 0, 0, 0, '', 2, 306),
(61, 5, 0, 0, 0, 1, '', 2, 306),
(62, 6, 1, 0, 0, 1, '', 2, 306),
(63, 8, 0, 0, 0, 0, '', 2, 306);

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
(13, 480, 0, 0, 0, 0, 1, 1, 105),
(14, 480, 0, 0, 0, 0, 0, 1, 105),
(15, 450, 0, 0, 0, 1, 1, 1, 105),
(16, 450, 0, 0, 0, 1, 0, 1, 105),
(17, 600, 0, 0, 0, 0, 1, 1, 106),
(18, 600, 0, 0, 0, 0, 0, 1, 106),
(19, 570, 0, 0, 0, 1, 1, 1, 106),
(20, 570, 0, 0, 0, 1, 0, 1, 106),
(21, 540, 0, 0, 0, 0, 1, 2, 107),
(22, 540, 0, 0, 0, 0, 0, 2, 107),
(23, 510, 0, 0, 0, 1, 1, 2, 107),
(24, 510, 0, 0, 0, 1, 0, 2, 107),
(25, 540, 0, 0, 0, 0, 1, 2, 303),
(26, 540, 0, 0, 0, 0, 0, 2, 303),
(27, 510, 0, 0, 0, 1, 1, 2, 303),
(28, 510, 0, 0, 0, 1, 0, 2, 303),
(29, 480, 0, 0, 0, 0, 1, 2, 304),
(30, 480, 0, 0, 0, 0, 0, 2, 304),
(31, 450, 0, 0, 0, 1, 1, 2, 304),
(32, 450, 0, 0, 0, 1, 0, 2, 304),
(33, 480, 0, 0, 0, 0, 1, 2, 306),
(34, 480, 0, 0, 0, 0, 0, 2, 306),
(35, 450, 0, 0, 0, 1, 1, 2, 306),
(36, 450, 0, 0, 0, 1, 0, 2, 306);

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
(22, 22, 15, 0, 0, 0),
(23, 23, 1, 0, 0, 0),
(24, 24, 3, 0, 0, 0),
(25, 25, 10, 0, 0, 0),
(26, 26, 2, 0, 0, 0),
(27, 27, 2, 0, 0, 0),
(28, 28, 0, 0, 0, 0),
(29, 29, 0, 0, 0, 0),
(30, 30, 0, 0, 0, 0),
(31, 31, 0, 0, 0, 0),
(32, 32, 0, 0, 0, 0),
(33, 33, 0, 0, 0, 0),
(34, 34, 0, 0, 0, 0),
(35, 35, 0, 0, 0, 0),
(36, 36, 5, 1, 0, 0),
(37, 37, 0, 0, 0, 0),
(38, 38, 0, 0, 0, 0),
(39, 39, 0, 0, 0, 0),
(40, 40, 0, 0, 0, 0),
(41, 41, 0, 0, 0, 0),
(42, 42, 0, 0, 0, 0),
(43, 43, 1, 2, 0, 0),
(44, 44, 0, 0, 0, 0),
(45, 45, 0, 0, 0, 0),
(46, 46, 0, 1, 0, 0),
(47, 47, 0, 0, 0, 0),
(48, 48, 0, 1, 0, 0),
(49, 49, 0, 0, 0, 0),
(50, 50, 3, 0, 0, 0),
(51, 51, 0, 0, 0, 0),
(52, 52, 0, 0, 0, 0),
(53, 53, 2, 0, 0, 0),
(54, 54, 1, 0, 0, 0),
(55, 55, 1, 0, 0, 0),
(56, 56, 0, 0, 0, 0),
(57, 57, 0, 0, 0, 0),
(58, 58, 0, 0, 0, 0),
(59, 59, 0, 0, 0, 0),
(60, 60, 0, 0, 0, 0),
(61, 61, 0, 0, 0, 0),
(62, 62, 0, 0, 0, 0),
(63, 63, 0, 0, 0, 0);

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
(1, 'PC Test', 'pctest', 'pctest', NULL, NULL, NULL, NULL, NULL, 1),
(2, 'PD Test', 'pdtest', 'pdtest', 3, NULL, NULL, NULL, 1, 2),
(7, 'ADMIN', 'admin', 'falpadmin', NULL, NULL, NULL, NULL, NULL, 3),
(20, 'Lawrenz Tibayan', 'Znerwal', '082392', 3, NULL, NULL, NULL, 1, 2),
(21, 'Esnelyn Moulic', 'Esnie26', '182629', 3, NULL, NULL, NULL, 1, 2),
(22, 'Sarah Jane Manalo', 'Sarah', '090694', 2, NULL, NULL, NULL, 2, 2),
(23, 'Sherlyn Kay Panopio', 'kakay', '182221', 2, NULL, NULL, NULL, 2, 2),
(24, 'Manilyn Tiemsem', 'Mane', '1028', 2, NULL, NULL, NULL, 2, 2),
(25, 'Julie Anne Pamplona', 'Julie', '071520', 5, NULL, NULL, NULL, 1, 2),
(26, 'Cherry Crense', 'Cherry', '082986', 6, NULL, NULL, NULL, 1, 2),
(27, 'Jeziel Indecio', 'Indecio', '922712', 5, NULL, NULL, NULL, 1, 2),
(28, 'Jennie Rose', 'Baby', '080215', 2, NULL, NULL, NULL, NULL, 5),
(30, 'Beverly Espiritu', 'Bev', '0505', 1, NULL, NULL, NULL, 2, 2),
(31, 'Renilyn Llanto', 'Arabella', '082512', 1, NULL, NULL, NULL, 2, 2),
(32, 'Darlyn Virrey', 'Darlyn', 'Virrey', 1, NULL, NULL, NULL, 2, 2),
(33, 'Jenny Ann Falogme', 'AnneJenny', '902104', 4, NULL, NULL, NULL, 2, 2),
(34, 'liezel d montealto', 'ezel', '090615', 7, NULL, NULL, NULL, 1, 2),
(35, 'Renilyn Llanto', 'Arabella2', '082512', 4, NULL, NULL, NULL, 2, 2);

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
(3, 'Admin'),
(4, 'Viewer'),
(5, 'Viewer+');

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
(96, '2018-03-13', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, 1, 1),
(100, '2018-03-27', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, NULL, 1),
(101, '2018-03-28', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, NULL, 1),
(102, '2018-03-29', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, NULL, 1),
(103, '2018-03-30', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, NULL, 1),
(104, '2018-03-31', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, NULL, 1),
(105, '2018-04-02', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, NULL, 1),
(106, '2018-04-03', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 3, NULL, 1),
(107, '2018-04-03', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 2, NULL, 1),
(302, '2018-04-05', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 2, NULL, 1),
(303, '2018-04-04', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 4, NULL, 1),
(304, '2018-04-04', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, NULL, 1),
(305, '2018-04-06', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 2, NULL, 1),
(306, '2018-04-05', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 4, NULL, 1),
(307, '2018-04-03', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, NULL, 1),
(308, '2018-04-05', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, NULL, 1),
(309, '2018-04-09', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 6, 26, 1);

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
(4, 82, 77, 82, 77, 105, 1),
(5, 0, 0, 0, 0, 106, 1),
(6, 100, 100, 0, 0, 107, 2),
(7, 0, 0, 0, 0, 303, 2),
(8, 0, 0, 0, 0, 304, 2),
(9, 100, 100, 105, 105, 306, 2);

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
(7, 'Mazda Merge', '4574'),
(8, 'Battery', '4575');

-- --------------------------------------------------------

--
-- Table structure for table `eff_car_model_cycle`
--

CREATE TABLE `eff_car_model_cycle` (
  `ID` int(11) NOT NULL,
  `car_model_id` int(11) NOT NULL,
  `shift_id` int(11) NOT NULL,
  `cycle` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_car_model_cycle`
--

INSERT INTO `eff_car_model_cycle` (`ID`, `car_model_id`, `shift_id`, `cycle`) VALUES
(1, 1, 1, 'N4,D1'),
(2, 1, 2, 'D2,N3'),
(3, 2, 1, 'N4,D1'),
(4, 2, 2, 'D2,N3'),
(5, 3, 1, 'D1'),
(6, 3, 2, 'NA'),
(7, 4, 1, 'D1'),
(8, 4, 2, 'N3'),
(9, 5, 1, 'D1,D2'),
(10, 5, 2, 'N3,N4'),
(11, 6, 1, 'D1,D2'),
(12, 6, 2, 'N3,N4'),
(13, 7, 1, 'N4,D1'),
(14, 7, 2, 'D2,N3'),
(15, 8, 1, 'DS,D1,D2'),
(16, 8, 2, 'NS,N3,N4');

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
(1, 7, 'n/a', 'n/a', 'n/a', 8, 3, 'n/a', '14:26:00', '14:46:00', 20, 0, 1, NULL, 101),
(2, 1, 'NA', 'NA', 'NA', 1, 1, 'NA', '00:00:00', '00:00:00', 0, 0, 0, NULL, 107);

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
(378, '32107-TAD-K003-4', '267.3397', '349', '', 2, 107),
(379, '32107-TAD-N303-4', '251.3211', '3803', '', 2, 107),
(380, '32107-TAD-N903-4', '266.4988', '1053', '', 2, 107),
(381, '32107-TAD-F703-4', '253.8046', '350', '', 2, 107),
(382, '28950-59F-0001-1', '12.1858', '1280', '', 2, 107),
(383, '32109-TTA-9003-2', '30.919', '3485', '', 2, 107),
(384, '32109-TTA-9103-2', '30.7148', '2940', '', 2, 107),
(385, '32752-TTA-9103-1', '25.8618', '3535', '', 2, 107),
(386, '32109-TAA-9410-5', '24.9645', '3241', '', 2, 107),
(387, '32754-TTA-0002', '22.5827', '6128', '', 2, 107),
(388, '32155-TTA-9203-2', '18.3753', '3103', '', 2, 107),
(389, '32170-TAA-0000-3', '4.4628', '1200', '', 2, 107),
(390, '32107-TAA-N712-3', '270.4967', '2204', '', 2, 107),
(391, '32753-TTA-9102', '22.4481', '4080', '', 2, 107),
(392, '32751-TTA-9203-1', '40.216', '576', '', 2, 107),
(393, '32107-TAA-N712-AL', '270.4967', '232', '', 2, 107),
(394, '32107-TAD-N303-AL', '251.3211', '234', '', 2, 107),
(395, '32751-TTA-9303-1', '41.1213', '7670', '', 2, 107),
(396, '32752-TAA-9310-4', '32.3953', '890', '', 2, 107),
(397, '32751-TAA-0100-4', '40.6861', '3060', '', 2, 107),
(398, '32751-TAA-9310-4', '43.6245', '1520', '', 2, 107),
(399, '32751-TAA-U110-4', '40.5435', '320', '', 2, 107),
(400, '32107-TAD-F903-4', '265.0787', '678', '', 2, 107),
(401, '32751-TTA-9103-1', '36.4586', '1106', '', 2, 107),
(402, '32107-TAD-F903-AL', '265.0787', '80', '', 2, 107),
(403, '32752-TTA-9003-1', '25.0062', '648', '', 2, 107),
(404, '32752-TAA-0100-4', '29.1949', '1441', '', 2, 107),
(405, '32119-TAA-9320-3', '36.5131', '120', '', 2, 107),
(406, '32119-TAA-9020-3', '38.8027', '696', '', 2, 107),
(407, '32751-TTA-0003-1', '35.9309', '2508', '', 2, 107),
(408, '32752-TAA-U010-4', '28.198', '20', '', 2, 107),
(409, '32752-TTA-0003-1', '24.0021', '1296', '', 2, 107),
(410, '32753-TTA-0001-3', '12.8276', '360', '', 2, 107),
(411, '32751-TTA-9303-1', '41.1213', '912', '', 2, 107),
(412, '32171-TAA-0002-2', '2.7028', '400', '', 2, 107),
(429, '24011-5WJ0A-0000P2', '158.4783', '20272', '', NULL, 303),
(430, '24011-5WH1A-0100P3', '204.4097', '3201', '', NULL, 303),
(431, '24011-5WJ0B-0000P2', '154.8057', '2976', '', NULL, 303),
(432, '24011-5WK0A-050101', '165.6857', '1280', '', NULL, 303),
(433, '24011-5WJ0A-0000P2', '158.4783', '20272', '', NULL, 303),
(434, '24011-5WH1A-0100P3', '204.4097', '3201', '', NULL, 303),
(435, '24011-5WJ0B-0000P2', '154.8057', '2976', '', NULL, 303),
(436, '24011-5WK0A-050101', '165.6857', '1280', '', NULL, 303),
(437, '88648-B2540N-2', '15.4479', '2700', '', 2, 304),
(438, '82118-B2Q30A-1', '187.4636', '9726', '', 2, 304),
(439, '82118-B2P90A-1', '166.4979', '11800', '', 2, 304),
(440, '82118-B2Q20A-1', '188.9298', '3666', '', 2, 304),
(441, '82118-B2Q90A-1', '209.2025', '3471', '', 2, 304),
(442, '82118-B2R60A-1', '173.811', '13446', '', 2, 304),
(443, '82153-B2380N-6', '14.5347', '3160', '', 2, 304),
(444, '82141-BAD90B-3', '158.1422', '10218', '', 2, 304),
(445, '82141-BAE40B-3', '203.9545', '3864', '', 2, 304),
(446, '82141-BAE10B-3', '182.8623', '10945', '', 2, 304),
(447, '82152-B2P80A-6', '14.8159', '1871', '', 2, 304),
(448, '82152-B2Q40N-5', '17.6098', '2450', '', 2, 304),
(449, '82151-B2Q30B-1', '28.6642', '500', '', 2, 304),
(450, '82151-B2L10B-1', '23.4759', '2200', '', 2, 304),
(451, '82152-B2R90-5', '20.6907', '200', '', 2, 304),
(452, '82152-B2P70A-6', '20.8044', '420', '', 2, 304),
(453, '82151-B2Q50-3', '28.5754', '480', '', 2, 304),
(454, '82151-B2Q40-3', '25.6278', '3220', '', 2, 304),
(455, '82152-B2R70A-6', '17.2567', '2576', '', 2, 304),
(456, '88648-B2650J-5', '19.8649', '780', '', 2, 304),
(457, '82151-B2Q10B-1', '25.8809', '3360', '', 2, 304),
(458, '82219-B2060J-2', '3.0852', '200', '', 2, 304),
(459, '88648-B2550N-2', '19.3641', '2030', '', 2, 304),
(460, '82415-B2530K-5', '6.8769', '300', '', 2, 304),
(461, '82415-B2551H-4', '8.4988', '160', '', 2, 304),
(462, '82186-B2170M-1', '3.9276', '650', '', 2, 304),
(463, '82171-B2J10-4', '14.1134', '600', '', 2, 304),
(464, '82171-B2E40M-5', '10.3444', '120', '', 2, 304),
(465, '82171-B2G70A-3', '13.9671', '960', '', 2, 304),
(466, '24011-5WJ0A-0000P2', '158.4783', '20392', '', NULL, 303),
(467, '24011-5WH1A-0100P3', '204.4097', '3366', '', NULL, 303),
(468, '24011-5WJ0B-0000P2', '154.8057', '2976', '', NULL, 303),
(469, '24011-5WK0A-050101', '165.6857', '1280', '', NULL, 303),
(470, '32171-TAA-0002-2', '2.7028', '410', '', NULL, 305),
(471, '32107-TAA-J802-3', '218.6968', '1', '', NULL, 305),
(482, '82118-B2Q30A-1', '187.4636', '24', '', NULL, 307),
(483, '88648-B2540N-2', '15.4479', '40', '', NULL, 307),
(484, '82118-B2P90A-1', '166.4979', '30', '', NULL, 307),
(485, '82141-BAE10B-3', '182.8623', '40', '', NULL, 307),
(486, '82118-B2R60A-1', '173.811', '12', '', NULL, 307),
(487, '82118-B2Q90A-1', '209.2025', '18', '', NULL, 307),
(488, '88648-B2550N-2', '19.3641', '20', '', NULL, 307),
(489, '82141-BAE40B-3', '203.9545', '21', '', NULL, 307),
(490, '88648-B2650J-5', '19.8649', '30', '', NULL, 307),
(491, '82118-B2Q20A-1', '188.9298', '20', '', NULL, 307),
(492, '82152-B2R70A-6', '17.2567', '45', '', NULL, 307),
(493, '82415-B2530K-5', '6.8769', '40', '', NULL, 307),
(494, '82171-B2J10-4', '14.1134', '40', '', NULL, 307),
(495, '82151-B2Q10B-1', '25.8809', '45', '', NULL, 307),
(496, '82153-B2380N-6', '14.5347', '45', '', NULL, 307),
(497, '82415-B2551H-4', '8.4988', '50', '', NULL, 307),
(498, '82171-B2G70A-3', '13.9671', '45', '', NULL, 307),
(499, '82186-B2170M-1', '3.9276', '50', '', NULL, 307),
(500, '82219-B2060J-2', '3.0852', '35', '', NULL, 307),
(502, '82118-B2P90A-1', '166.4979', '37', '', 2, 308),
(503, '82153-B2380N-6', '14.5347', '30', '', 2, 308),
(504, '82152-B2R70A-6', '17.2567', '40', '', 2, 308),
(505, '82118-B2Q20A-1', '188.9298', '19', '', 2, 308),
(506, '82141-BAE40B-3', '203.9545', '21', '', 2, 308),
(507, '88648-B2550N-2', '19.3641', '20', '', 2, 308),
(508, '82118-B2Q90A-1', '209.2025', '15', '', 2, 308),
(509, '82118-B2Q30A-1', '187.4636', '27', '', 2, 308),
(510, '88648-B2540N-2', '15.4479', '30', '', 2, 308),
(511, '82141-BAE10B-3', '182.8623', '30', '', 2, 308),
(512, '82118-B2R60A-1', '173.811', '12', '', 2, 308),
(513, '82219-B2060J-2', '3.0852', '50', '', 2, 308),
(514, '82151-B2Q10B-1', '25.8809', '40', '', 2, 308),
(515, '82171-B2G70A-3', '13.9671', '10', '', 2, 308),
(516, '82415-B2530K-5', '6.8769', '50', '', 2, 308),
(517, '88648-B2650J-5', '19.8649', '30', '', 2, 308),
(518, '82171-B2J10-4', '14.1134', '40', '', 2, 308),
(519, '82415-B2551H-4', '8.4988', '40', '', 2, 308);

-- --------------------------------------------------------

--
-- Table structure for table `eff_product_st`
--

CREATE TABLE `eff_product_st` (
  `ID` int(11) NOT NULL,
  `product_no` varchar(255) NOT NULL,
  `st` varchar(255) NOT NULL,
  `last_update` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_product_st`
--

INSERT INTO `eff_product_st` (`ID`, `product_no`, `st`, `last_update`) VALUES
(443, 'N243-67-EW0(2)-4', '2.6829', '2018-04-02 14:14:59'),
(444, 'NA1J-67-EW0(2)-4', '2.6584', '2018-04-02 14:14:59'),
(445, 'N314-67-030A(4)-2', '128.9872', '2018-04-02 14:14:59'),
(446, 'N314-67-030A(5)', '129.2007', '2018-04-02 14:14:59'),
(447, 'N315-67-030A(5)-2', '160.941', '2018-04-02 14:14:59'),
(448, 'N315-67-030A(6)', '161.0567', '2018-04-02 14:14:59'),
(449, 'N316-67-030A(5)-2', '168.2417', '2018-04-02 14:14:59'),
(450, 'N316-67-030A(6)', '168.3567', '2018-04-02 14:15:00'),
(451, 'N317-67-030A(5)-2', '171.6571', '2018-04-02 14:15:00'),
(452, 'N317-67-030A(6)', '171.674', '2018-04-02 14:15:00'),
(453, 'N319-67-030A(5)-2', '171.4208', '2018-04-02 14:15:00'),
(454, 'N319-67-030A(6)', '171.6424', '2018-04-02 14:15:00'),
(455, 'N322-67-030A(5)-2', '179.9119', '2018-04-02 14:15:00'),
(456, 'N322-67-030A(6)', '180.133', '2018-04-02 14:15:00'),
(457, 'N323-67-030A(4)-2', '135.0338', '2018-04-02 14:15:00'),
(458, 'N323-67-030A(5)', '135.2474', '2018-04-02 14:15:00'),
(459, 'N324-67-030A(5)-2', '183.3302', '2018-04-02 14:15:00'),
(460, 'N324-67-030A(6)', '183.5513', '2018-04-02 14:15:00'),
(461, 'ND0H-67-030A(4)-2', '134.3577', '2018-04-02 14:15:01'),
(462, 'ND0H-67-030A(5)', '134.5736', '2018-04-02 14:15:01'),
(463, 'ND0J-67-030A(5)-2', '158.3291', '2018-04-02 14:15:01'),
(464, 'ND0J-67-030A(6)', '158.4438', '2018-04-02 14:15:01'),
(465, 'ND0L-67-030A(5)-2', '161.6984', '2018-04-02 14:15:01'),
(466, 'ND0L-67-030A(6)', '161.814', '2018-04-02 14:15:01'),
(467, 'ND0N-67-030A(5)-2', '176.0753', '2018-04-02 14:15:01'),
(468, 'ND0N-67-030A(6)', '176.2969', '2018-04-02 14:15:01'),
(469, 'ND0P-67-030B(3)-3', '159.0005', '2018-04-02 14:15:01'),
(470, 'ND0R-67-030B(6)-3', '161.2343', '2018-04-02 14:15:01'),
(471, 'ND0S-67-030B(6)-3', '165.5216', '2018-04-02 14:15:01'),
(472, 'ND0S-67-030B(7)', '165.2339', '2018-04-02 14:15:01'),
(473, 'ND0T-67-030B(6)-3', '168.3175', '2018-04-02 14:15:01'),
(474, 'ND0T-67-030B(7)', '168.0297', '2018-04-02 14:15:02'),
(475, 'ND1A-67-030B(6)-3', '177.6766', '2018-04-02 14:15:02'),
(476, 'ND1A-67-030B(7)', '177.3907', '2018-04-02 14:15:02'),
(477, 'ND1B-67-030B(6)-3', '180.5042', '2018-04-02 14:15:02'),
(478, 'ND1B-67-030B(7)', '180.2155', '2018-04-02 14:15:02'),
(479, 'ND1C-67-030C(6)-3', '157.158', '2018-04-02 14:15:02'),
(480, 'ND1C-67-030C(7)', '156.8707', '2018-04-02 14:15:02'),
(481, 'ND1D-67-030C(6)-3', '164.0167', '2018-04-02 14:15:02'),
(482, 'ND1D-67-030C(7)', '163.7291', '2018-04-02 14:15:02'),
(483, 'ND1E-67-030C(6)-3', '174.9151', '2018-04-02 14:15:02'),
(484, 'ND1E-67-030C(7)', '174.6293', '2018-04-02 14:15:02'),
(485, 'ND1F-67-030B(3)-3', '136.2725', '2018-04-02 14:15:02'),
(486, 'ND1F-67-030B(4)', '135.9859', '2018-04-02 14:15:03'),
(487, 'ND1G-67-030B(6)-3', '167.4544', '2018-04-02 14:15:03'),
(488, 'ND1G-67-030B(7)', '167.1664', '2018-04-02 14:15:03'),
(489, 'ND1H-67-030B(6)-3', '158.4497', '2018-04-02 14:15:03'),
(490, 'ND1H-67-030B(7)', '158.1644', '2018-04-02 14:15:03'),
(491, 'ND1J-67-030B(6)-3', '161.2408', '2018-04-02 14:15:03'),
(492, 'ND1J-67-030B(7)', '160.9529', '2018-04-02 14:15:03'),
(493, 'ND1K-67-030B(6)-3', '162.4389', '2018-04-02 14:15:03'),
(494, 'ND1K-67-030B(7)', '162.151', '2018-04-02 14:15:03'),
(495, 'ND1M-67-030B(6)-3', '169.6687', '2018-04-02 14:15:03'),
(496, 'ND1R-67-030B(6)-3', '178.6051', '2018-04-02 14:15:03'),
(497, 'ND1R-67-030B(7)', '178.3165', '2018-04-02 14:15:03'),
(498, 'ND1S-67-030A(5)-2', '165.775', '2018-04-02 14:15:04'),
(499, 'ND1S-67-030A(6)', '165.8907', '2018-04-02 14:15:04'),
(500, 'ND1T-67-030A(4)-2', '148.8967', '2018-04-02 14:15:04'),
(501, 'ND1T-67-030A(5)', '149.1145', '2018-04-02 14:15:04'),
(502, 'ND1V-67-030A(4)-2', '160.3789', '2018-04-02 14:15:04'),
(503, 'ND1V-67-030A(5)', '160.5989', '2018-04-02 14:15:04'),
(504, 'ND1W-67-030A(5)-2', '162.6904', '2018-04-02 14:15:04'),
(505, 'ND1W-67-030A(6)', '162.8053', '2018-04-02 14:15:04'),
(506, 'ND2D-67-030A(5)-2', '166.3626', '2018-04-02 14:15:04'),
(507, 'ND2D-67-030A(6)', '166.5831', '2018-04-02 14:15:04'),
(508, 'ND2E-67-030A(5)-2', '173.0643', '2018-04-02 14:15:04'),
(509, 'ND2E-67-030A(6)', '173.2844', '2018-04-02 14:15:04'),
(510, 'ND2F-67-030A(6)-3', '154.3775', '2018-04-02 14:15:04'),
(511, 'ND2F-67-030A(7)', '154.0904', '2018-04-02 14:15:04'),
(512, 'ND2G-67-030A(6)-3', '161.6192', '2018-04-02 14:15:04'),
(513, 'ND2G-67-030A(7)', '161.3344', '2018-04-02 14:15:05'),
(514, 'ND2H-67-030A(6)-3', '165.6716', '2018-04-02 14:15:05'),
(515, 'ND2J-67-030A(6)-3', '172.8474', '2018-04-02 14:15:05'),
(516, 'ND2J-67-030A(7)', '172.5593', '2018-04-02 14:15:05'),
(517, 'ND2K-67-030A(6)-3', '156.1639', '2018-04-02 14:15:05'),
(518, 'ND2L-67-030A(6)-3', '174.9464', '2018-04-02 14:15:05'),
(519, 'ND2L-67-030A(7)', '174.6582', '2018-04-02 14:15:05'),
(520, 'ND2M-67-030A(5)-2', '161.6619', '2018-04-02 14:15:05'),
(521, 'ND2M-67-030A(6)', '161.7765', '2018-04-02 14:15:05'),
(522, 'ND2N-67-030A(5)-2', '172.1167', '2018-04-02 14:15:06'),
(523, 'ND2N-67-030A(6)', '172.3383', '2018-04-02 14:15:06'),
(524, 'ND2P-67-030A(4)-2', '140.4068', '2018-04-02 14:15:06'),
(525, 'ND2P-67-030A(5)', '140.6227', '2018-04-02 14:15:06'),
(526, 'ND2R-67-030A(5)-2', '157.0859', '2018-04-02 14:15:06'),
(527, 'ND2R-67-030A(6)', '157.2005', '2018-04-02 14:15:06'),
(528, 'ND2S-67-030A(5)-2', '160.3592', '2018-04-02 14:15:06'),
(529, 'ND2S-67-030A(6)', '160.4738', '2018-04-02 14:15:06'),
(530, 'ND2T-67-030B(3)-3', '172.1666', '2018-04-02 14:15:06'),
(531, 'ND2V-67-030B(6)-3', '173.6021', '2018-04-02 14:15:06'),
(532, 'ND2W-67-030B(6)-3', '172.4632', '2018-04-02 14:15:06'),
(533, 'ND2W-67-030B(7)', '172.1747', '2018-04-02 14:15:06'),
(534, 'ND3A-67-030B(6)-3', '173.9283', '2018-04-02 14:15:07'),
(535, 'ND3A-67-030B(7)', '173.6421', '2018-04-02 14:15:07'),
(536, 'ND3B-67-030A(5)-2', '163.9771', '2018-04-02 14:15:07'),
(537, 'ND3B-67-030A(6)', '164.0949', '2018-04-02 14:15:07'),
(538, 'ND3C-67-030A(5)-2', '174.2049', '2018-04-02 14:15:07'),
(539, 'ND3C-67-030A(6)', '174.4293', '2018-04-02 14:15:07'),
(540, 'ND7L-67-030(2)-4', '169.0652', '2018-04-02 14:15:07'),
(541, 'N243-67-020D(13)', '128.4605', '2018-04-02 14:15:07'),
(542, 'N247-67-020D(13)', '113.8579', '2018-04-02 14:15:07'),
(543, 'N270-67-020D(13)', '130.5653', '2018-04-02 14:15:07'),
(544, 'NA1J-67-020B(9)', '128.5207', '2018-04-02 14:15:08'),
(545, 'NA1L-67-020B(9)', '113.5197', '2018-04-02 14:15:08'),
(546, 'NA6S-67-020B(13)', '113.5815', '2018-04-02 14:15:08'),
(547, 'NA6W-67-020B(9)', '130.6125', '2018-04-02 14:15:08'),
(548, 'NB2N-67-020B(9)', '113.7943', '2018-04-02 14:15:08'),
(549, 'N314-67-070(0)-2', '13.9392', '2018-04-02 14:15:08'),
(550, 'N317-67-070(0)-3', '18.1817', '2018-04-02 14:15:08'),
(551, 'N320-67-070(0)-3', '18.7244', '2018-04-02 14:15:09'),
(552, 'ND0H-67-070(0)-2', '13.49', '2018-04-02 14:15:09'),
(553, 'ND0K-67-070(0)-2', '13.8957', '2018-04-02 14:15:09'),
(554, 'N243-43-754(2)-3', '5.1482', '2018-04-02 14:15:09'),
(555, 'N243-67-290B(4)-4', '29.7437', '2018-04-02 14:15:10'),
(556, 'N243-67-290B(4)-5', '29.7311', '2018-04-02 14:15:10'),
(557, 'N243-67-SH0A(2)-2', '5.1747', '2018-04-02 14:15:10'),
(558, 'N247-66-SH0(2)-3', '1.3546', '2018-04-02 14:15:10'),
(559, 'N247-67-290(6)-8', '18.18', '2018-04-02 14:15:10'),
(560, 'N247-67-290(6)-9', '18.18', '2018-04-02 14:15:10'),
(561, 'N247-67-SH0B(8)-5', '35.2268', '2018-04-02 14:15:10'),
(562, 'N255-67-SH0(2)-3', '4.1653', '2018-04-02 14:15:10'),
(563, 'N256-67-SH0(1)-5', '15.7615', '2018-04-02 14:15:10'),
(564, 'N257-67-SH0(2)-5', '7.2117', '2018-04-02 14:15:10'),
(565, 'N258-67-SH0(2)-5', '7.0445', '2018-04-02 14:15:10'),
(566, 'N259-67-SH0A(3)-3', '3.1569', '2018-04-02 14:15:11'),
(567, 'N261-67-SH0(2)-4', '3.2321', '2018-04-02 14:15:11'),
(568, 'N270-67-SH0(1)-4', '2.716', '2018-04-02 14:15:11'),
(569, 'NA1J-67-290A(7)-8', '21.0339', '2018-04-02 14:15:11'),
(570, 'NA1J-67-290A(7)-9', '21.0339', '2018-04-02 14:15:11'),
(571, 'NA1L-67-SH0A(8)-5', '29.8841', '2018-04-02 14:15:11'),
(572, 'NA1P-67-SB9(2)-3', '2.6495', '2018-04-02 14:15:11'),
(573, 'NA1P-67-SH0(2)-4', '3.5609', '2018-04-02 14:15:11'),
(574, 'NA1V-67-SB9(1)-1', '1.9024', '2018-04-02 14:15:11'),
(575, 'NA9C-67-SH0(1)-4', '4.5022', '2018-04-02 14:15:11'),
(576, 'NB0D-67-290(6)-8', '27.0739', '2018-04-02 14:15:11'),
(577, 'NB0D-67-290(6)-9', '27.0739', '2018-04-02 14:15:11'),
(578, 'ND0H-67-290(0)-3', '18.3598', '2018-04-02 14:15:11'),
(579, 'ND0H-67-290(0)-4', '18.3598', '2018-04-02 14:15:12'),
(580, 'ND0J-67-290(0)-3', '27.2539', '2018-04-02 14:15:12'),
(581, 'ND0J-67-290(0)-4', '27.2539', '2018-04-02 14:15:12'),
(582, 'ND0P-67-SH0(0)-4', '10.0793', '2018-04-02 14:15:12'),
(583, 'ND1F-67-290(1)-3', '18.3494', '2018-04-02 14:15:12'),
(584, 'ND1F-67-290(1)-4', '18.3494', '2018-04-02 14:15:12'),
(585, 'ND1G-67-290(1)-3', '27.2426', '2018-04-02 14:15:12'),
(586, 'ND1G-67-290(1)-4', '27.2426', '2018-04-02 14:15:12'),
(587, 'ND7L-67-SH0(21)-1', '3.0884', '2018-04-02 14:15:12'),
(588, 'N247-67-200(11)-6', '25.1482', '2018-04-02 14:15:12'),
(589, 'NA1J-67-200A(11)-8', '27.1775', '2018-04-02 14:15:12'),
(590, 'NA1L-67-200A(11)-8', '29.6029', '2018-04-02 14:15:13'),
(591, 'NA1P-67-200B(11)-8', '24.8944', '2018-04-02 14:15:13'),
(592, 'NA1V-67-200(11)-6', '25.3528', '2018-04-02 14:15:13'),
(593, 'NA6R-67-200D(11)-6', '24.6419', '2018-04-02 14:15:13'),
(594, 'NA6S-67-200D(11)-6', '27.1652', '2018-04-02 14:15:13'),
(595, 'NA6W-67-200B(11)-8', '25.1538', '2018-04-02 14:15:13'),
(596, 'NA9B-67-200A(11)-8', '24.4216', '2018-04-02 14:15:13'),
(597, 'NA9C-67-200A(11)-8', '27.8596', '2018-04-02 14:15:13'),
(598, 'NA9D-67-200A(11)-8', '27.2112', '2018-04-02 14:15:13'),
(599, 'NB0D-67-200A(11)-8', '27.3445', '2018-04-02 14:15:13'),
(600, 'NB2N-67-200(11)-8', '25.086', '2018-04-02 14:15:13'),
(601, 'NB2V-67-200(11)-6', '28.0577', '2018-04-02 14:15:13'),
(602, 'ND0A-67-200(11)-6', '27.1723', '2018-04-02 14:15:14'),
(603, 'ND0D-67-200(11)-6', '21.7011', '2018-04-02 14:15:14'),
(604, 'ND7L-67-200(13)-3', '27.3445', '2018-04-02 14:15:14'),
(605, 'N247-67-190(10)-8', '29.3967', '2018-04-02 14:15:14'),
(606, 'NA1J-67-190A(10)-6', '32.166', '2018-04-02 14:15:14'),
(607, 'NA1P-67-190B(10)-6', '29.6304', '2018-04-02 14:15:14'),
(608, 'NA1V-67-190(10)-8', '29.3532', '2018-04-02 14:15:14'),
(609, 'NA6R-67-190D(10)-8', '28.9765', '2018-04-02 14:15:14'),
(610, 'NA6S-67-190D(10)-8', '31.4284', '2018-04-02 14:15:14'),
(611, 'NA6W-67-190B(10)-6', '29.176', '2018-04-02 14:15:14'),
(612, 'NA9C-67-190(10)-6', '29.9028', '2018-04-02 14:15:15'),
(613, 'NA9D-67-190B(10)-6', '26.8742', '2018-04-02 14:15:15'),
(614, 'NB0D-67-190A(10)-6', '31.6895', '2018-04-02 14:15:15'),
(615, 'NB2V-67-190(10)-8', '31.8855', '2018-04-02 14:15:15'),
(616, 'ND0D-67-190(10)-8', '26.081', '2018-04-02 14:15:15'),
(617, 'N243-67-150(2)-6', '15.6652', '2018-04-02 14:15:15'),
(618, 'N247-67-150(2)-6', '4.0871', '2018-04-02 14:15:15'),
(619, 'N270-67-150(2)-6', '16.964', '2018-04-02 14:15:15'),
(620, 'N247-67-250(3)-2', '11.2347', '2018-04-02 14:15:15'),
(621, 'N314-67-010A(4)-3', '238.9264', '2018-04-02 14:15:15'),
(622, 'N315-67-010A(4)-3', '242.9144', '2018-04-02 14:15:15'),
(623, 'N316-67-010A(4)-3', '244.6965', '2018-04-02 14:15:16'),
(624, 'N317-67-010A(4)-3', '263.6507', '2018-04-02 14:15:16'),
(625, 'N318-67-010A(4)-3', '265.2678', '2018-04-02 14:15:16'),
(626, 'N319-67-010A(4)-3', '260.8938', '2018-04-02 14:15:16'),
(627, 'N322-67-010A(4)-3', '262.8186', '2018-04-02 14:15:16'),
(628, 'ND0H-67-010A(4)-3', '254.8066', '2018-04-02 14:15:16'),
(629, 'ND0J-67-010A(4)-3', '248.7622', '2018-04-02 14:15:16'),
(630, 'ND0K-67-010A(4)-3', '250.7051', '2018-04-02 14:15:16'),
(631, 'ND0N-67-010A(4)-3', '256.1073', '2018-04-02 14:15:16'),
(632, 'ND0P-67-010B(5)-3', '258.0481', '2018-04-02 14:15:16'),
(633, 'ND0R-67-010B(5)-3', '262.3151', '2018-04-02 14:15:16'),
(634, 'ND1A-67-010B(5)-3', '263.2125', '2018-04-02 14:15:16'),
(635, 'ND1B-67-010B(5)-3', '258.9445', '2018-04-02 14:15:17'),
(636, 'ND1C-67-010C(5)-3', '249.949', '2018-04-02 14:15:17'),
(637, 'ND1D-67-010C(5)-3', '254.3418', '2018-04-02 14:15:17'),
(638, 'ND1E-67-010C(5)-3', '253.8761', '2018-04-02 14:15:17'),
(639, 'ND1F-67-010B(5)-3', '264.4917', '2018-04-02 14:15:17'),
(640, 'ND1G-67-010B(5)-3', '258.0147', '2018-04-02 14:15:17'),
(641, 'ND1H-67-010B(5)-3', '260.2239', '2018-04-02 14:15:17'),
(642, 'ND1M-67-010B(5)-3', '264.1518', '2018-04-02 14:15:17'),
(643, 'ND1N-67-010B(5)-3', '283.2891', '2018-04-02 14:15:17'),
(644, 'ND1P-67-010B(5)-3', '276.9662', '2018-04-02 14:15:18'),
(645, 'ND1R-67-010B(5)-3', '272.9786', '2018-04-02 14:15:18'),
(646, 'ND1V-67-010A(4)-3', '249.8242', '2018-04-02 14:15:18'),
(647, 'ND2F-67-010A(5)-3', '265.0282', '2018-04-02 14:15:18'),
(648, 'ND2G-67-010A(5)-3', '263.1378', '2018-04-02 14:15:18'),
(649, 'ND2H-67-010A(5)-3', '261.0436', '2018-04-02 14:15:18'),
(650, 'ND2J-67-010A(5)-3', '259.1528', '2018-04-02 14:15:18'),
(651, 'ND2L-67-010A(5)-3', '242.9284', '2018-04-02 14:15:19'),
(652, 'ND2M-67-010A(4)-3', '259.6896', '2018-04-02 14:15:19'),
(653, 'ND2N-67-010A(4)-3', '257.042', '2018-04-02 14:15:19'),
(654, 'ND2P-67-010A(4)-3', '249.9007', '2018-04-02 14:15:19'),
(655, 'ND2R-67-010C(5)-3', '249.6088', '2018-04-02 14:15:19'),
(656, 'ND2S-67-010B(5)-3', '259.7585', '2018-04-02 14:15:19'),
(657, 'ND2T-67-010B(5)-3', '278.8579', '2018-04-02 14:15:19'),
(658, 'ND2V-67-010B(5)-3', '279.1751', '2018-04-02 14:15:19'),
(659, 'ND3B-67-010A(5)-3', '268.805', '2018-04-02 14:15:19'),
(660, 'N314-67-050A(4)-6', '169.81', '2018-04-02 14:15:20'),
(661, 'N314-67-050A(5)', '169.6729', '2018-04-02 14:15:20'),
(662, 'N315-67-050A(4)-6', '237.7745', '2018-04-02 14:15:20'),
(663, 'N315-67-050A(5)', '237.4415', '2018-04-02 14:15:20'),
(664, 'N316-67-050A(4)-6', '245.4927', '2018-04-02 14:15:20'),
(665, 'N316-67-050A(5)', '245.4537', '2018-04-02 14:15:20'),
(666, 'N317-67-050A(4)-6', '266.9968', '2018-04-02 14:15:20'),
(667, 'N317-67-050A(5)', '266.6636', '2018-04-02 14:15:21'),
(668, 'N319-67-050A(4)-6', '273.2054', '2018-04-02 14:15:21'),
(669, 'N319-67-050A(5)', '272.8723', '2018-04-02 14:15:21'),
(670, 'N320-67-050A(4)-6', '278.3963', '2018-04-02 14:15:21'),
(671, 'N320-67-050A(5)', '278.3573', '2018-04-02 14:15:21'),
(672, 'N321-67-050A(4)-6', '286.0231', '2018-04-02 14:15:21'),
(673, 'N321-67-050A(5)', '285.9841', '2018-04-02 14:15:21'),
(674, 'N322-67-050A(4)-6', '314.0894', '2018-04-02 14:15:21'),
(675, 'N322-67-050A(5)', '314.0503', '2018-04-02 14:15:21'),
(676, 'N323-67-050A(4)-6', '179.6308', '2018-04-02 14:15:21'),
(677, 'N323-67-050A(5)', '179.4936', '2018-04-02 14:15:21'),
(678, 'N324-67-050A(4)-6', '176.1082', '2018-04-02 14:15:21'),
(679, 'N324-67-050A(5)', '176.069', '2018-04-02 14:15:22'),
(680, 'N325-67-050A(4)-6', '185.527', '2018-04-02 14:15:22'),
(681, 'N325-67-050A(5)', '185.4879', '2018-04-02 14:15:22'),
(682, 'N326-67-050A(4)-6', '280.8018', '2018-04-02 14:15:22'),
(683, 'N326-67-050A(5)', '280.7627', '2018-04-02 14:15:22'),
(684, 'N327-67-050A(4)-6', '302.6312', '2018-04-02 14:15:22'),
(685, 'N327-67-050A(5)', '302.592', '2018-04-02 14:15:22'),
(686, 'N328-67-050A(4)-6', '321.7518', '2018-04-02 14:15:22'),
(687, 'N328-67-050A(5)', '321.4187', '2018-04-02 14:15:23'),
(688, 'N329-67-050A(4)-6', '343.8647', '2018-04-02 14:15:23'),
(689, 'N329-67-050A(5)', '343.8255', '2018-04-02 14:15:23'),
(690, 'N330-67-050A(4)-6', '307.3902', '2018-04-02 14:15:23'),
(691, 'N330-67-050A(5)', '307.351', '2018-04-02 14:15:23'),
(692, 'ND0H-67-050A(4)-6', '204.152', '2018-04-02 14:15:23'),
(693, 'ND0H-67-050A(5)', '204.0149', '2018-04-02 14:15:23'),
(694, 'ND0J-67-050A(4)-6', '270.8259', '2018-04-02 14:15:23'),
(695, 'ND0J-67-050A(5)', '270.6889', '2018-04-02 14:15:23'),
(696, 'ND0K-67-050A(4)-6', '230.5527', '2018-04-02 14:15:24'),
(697, 'ND0K-67-050A(5)', '230.2197', '2018-04-02 14:15:24'),
(698, 'ND0L-67-050A(4)-6', '279.2325', '2018-04-02 14:15:24'),
(699, 'ND0L-67-050A(5)', '279.1007', '2018-04-02 14:15:24'),
(700, 'ND0M-67-050A(4)-6', '314.0705', '2018-04-02 14:15:24'),
(701, 'ND0M-67-050A(5)', '313.9386', '2018-04-02 14:15:24'),
(702, 'ND0N-67-050A(4)-6', '343.0506', '2018-04-02 14:15:25'),
(703, 'ND0N-67-050A(5)', '342.9187', '2018-04-02 14:15:25'),
(704, 'ND0P-67-050B(3)-4', '242.2406', '2018-04-02 14:15:25'),
(705, 'ND0R-67-050B(7)-4', '320.7958', '2018-04-02 14:15:25'),
(706, 'ND0R-67-050B(8)', '320.4627', '2018-04-02 14:15:25'),
(707, 'ND0S-67-050B(7)-4', '280.0135', '2018-04-02 14:15:25'),
(708, 'ND0S-67-050B(8)', '279.735', '2018-04-02 14:15:25'),
(709, 'ND0T-67-050B(7)-4', '297.0275', '2018-04-02 14:15:25'),
(710, 'ND0V-67-050B(7)-4', '256.4459', '2018-04-02 14:15:26'),
(711, 'ND1A-67-050B(7)-4', '309.127', '2018-04-02 14:15:26'),
(712, 'ND1A-67-050B(8)', '308.8485', '2018-04-02 14:15:26'),
(713, 'ND1B-67-050B(7)-4', '350.5373', '2018-04-02 14:15:26'),
(714, 'ND1B-67-050B(8)', '350.2042', '2018-04-02 14:15:26'),
(715, 'ND1C-67-050C(7)-4', '210.2233', '2018-04-02 14:15:26'),
(716, 'ND1C-67-050C(8)', '209.9448', '2018-04-02 14:15:26'),
(717, 'ND1D-67-050C(7)-4', '273.9213', '2018-04-02 14:15:26'),
(718, 'ND1E-67-050C(7)-4', '302.6251', '2018-04-02 14:15:26'),
(719, 'ND1E-67-050C(8)', '302.292', '2018-04-02 14:15:27'),
(720, 'ND1F-67-050B(3)-4', '198.7943', '2018-04-02 14:15:27'),
(721, 'ND1F-67-050B(4)', '198.5157', '2018-04-02 14:15:27'),
(722, 'ND1G-67-050B(7)-4', '264.6286', '2018-04-02 14:15:27'),
(723, 'ND1G-67-050B(8)', '264.2954', '2018-04-02 14:15:27'),
(724, 'ND1H-67-050B(7)-4', '224.4269', '2018-04-02 14:15:27'),
(725, 'ND1H-67-050B(8)', '224.1484', '2018-04-02 14:15:27'),
(726, 'ND1J-67-050B(7)-4', '272.6796', '2018-04-02 14:15:27'),
(727, 'ND1K-67-050B(7)-4', '232.6059', '2018-04-02 14:15:27'),
(728, 'ND1K-67-050B(8)', '232.3326', '2018-04-02 14:15:28'),
(729, 'ND1M-67-050B(7)-4', '293.117', '2018-04-02 14:15:28'),
(730, 'ND1N-67-050B(7)-4', '268.6734', '2018-04-02 14:15:28'),
(731, 'ND1N-67-050B(8)', '268.4001', '2018-04-02 14:15:28'),
(732, 'ND1P-67-050B(7)-4', '308.8866', '2018-04-02 14:15:28'),
(733, 'ND1P-67-050B(8)', '308.5588', '2018-04-02 14:15:28'),
(734, 'ND1R-67-050B(7)-4', '345.0482', '2018-04-02 14:15:28'),
(735, 'ND1R-67-050B(8)', '344.7203', '2018-04-02 14:15:28'),
(736, 'ND1S-67-050A(4)-6', '272.7444', '2018-04-02 14:15:28'),
(737, 'ND1S-67-050A(5)', '272.6125', '2018-04-02 14:15:29'),
(738, 'ND1T-67-050A(4)-6', '222.1565', '2018-04-02 14:15:29'),
(739, 'ND1T-67-050A(5)', '221.8235', '2018-04-02 14:15:29'),
(740, 'ND1V-67-050A(4)-6', '237.3737', '2018-04-02 14:15:29'),
(741, 'ND1V-67-050A(5)', '237.2365', '2018-04-02 14:15:29'),
(742, 'ND1W-67-050A(4)-6', '209.3366', '2018-04-02 14:15:29'),
(743, 'ND1W-67-050A(5)', '209.1995', '2018-04-02 14:15:29'),
(744, 'ND2A-67-050A(4)-6', '262.4132', '2018-04-02 14:15:29'),
(745, 'ND2A-67-050A(5)', '262.0802', '2018-04-02 14:15:30'),
(746, 'ND2B-67-050A(4)-6', '256.2185', '2018-04-02 14:15:30'),
(747, 'ND2B-67-050A(5)', '255.8854', '2018-04-02 14:15:30'),
(748, 'ND2C-67-050A(4)-6', '297.5169', '2018-04-02 14:15:30'),
(749, 'ND2C-67-050A(5)', '297.1838', '2018-04-02 14:15:30'),
(750, 'ND2D-67-050A(4)-6', '250.3577', '2018-04-02 14:15:30'),
(751, 'ND2D-67-050A(5)', '250.2206', '2018-04-02 14:15:30'),
(752, 'ND2E-67-050A(4)-6', '291.0761', '2018-04-02 14:15:30'),
(753, 'ND2E-67-050A(5)', '290.743', '2018-04-02 14:15:31'),
(754, 'ND2F-67-050A(7)-4', '242.8395', '2018-04-02 14:15:31'),
(755, 'ND2F-67-050A(8)', '242.5662', '2018-04-02 14:15:31'),
(756, 'ND2G-67-050A(7)-4', '306.3668', '2018-04-02 14:15:31'),
(757, 'ND2G-67-050A(8)', '306.0389', '2018-04-02 14:15:31'),
(758, 'ND2H-67-050A(7)-4', '277.9141', '2018-04-02 14:15:31'),
(759, 'ND2J-67-050A(7)-4', '342.0436', '2018-04-02 14:15:31'),
(760, 'ND2J-67-050A(8)', '341.7157', '2018-04-02 14:15:31'),
(761, 'ND2K-67-050A(7)-4', '252.5855', '2018-04-02 14:15:31'),
(762, 'ND2L-67-050A(7)-4', '334.6462', '2018-04-02 14:15:31'),
(763, 'ND2L-67-050A(8)', '334.3183', '2018-04-02 14:15:31'),
(764, 'ND2M-67-050A(4)-6', '298.0562', '2018-04-02 14:15:32'),
(765, 'ND2M-67-050A(5)', '297.9243', '2018-04-02 14:15:32'),
(766, 'ND2N-67-050A(4)-6', '334.197', '2018-04-02 14:15:32'),
(767, 'ND2N-67-050A(5)', '333.8691', '2018-04-02 14:15:32'),
(768, 'ND2P-67-050A(4)-6', '238.6171', '2018-04-02 14:15:32'),
(769, 'ND2P-67-050A(5)', '238.4852', '2018-04-02 14:15:32'),
(770, 'ND2R-67-050B(3)-4', '271.1554', '2018-04-02 14:15:32'),
(771, 'ND2S-67-050B(7)-4', '326.4813', '2018-04-02 14:15:32'),
(772, 'ND2T-67-050B(7)-4', '285.289', '2018-04-02 14:15:33'),
(773, 'ND2V-67-050B(7)-4', '301.5573', '2018-04-02 14:15:33'),
(774, 'ND2W-67-050A(7)-4', '265.8957', '2018-04-02 14:15:33'),
(775, 'ND2W-67-050A(8)', '265.6224', '2018-04-02 14:15:33'),
(776, 'ND3A-67-050B(7)-4', '263.4097', '2018-04-02 14:15:33'),
(777, 'ND3B-67-050B(7)-4', '304.2124', '2018-04-02 14:15:33'),
(778, 'ND3C-67-050A(7)-4', '301.0459', '2018-04-02 14:15:33'),
(779, 'ND3C-67-050A(8)', '300.7726', '2018-04-02 14:15:33'),
(780, 'ND3D-67-050A(7)-4', '303.7251', '2018-04-02 14:15:33'),
(781, 'ND3D-67-050A(8)', '303.4518', '2018-04-02 14:15:33'),
(782, 'ND3E-67-050A(7)-4', '300.7702', '2018-04-02 14:15:34'),
(783, 'ND3E-67-050A(8)', '300.4969', '2018-04-02 14:15:34'),
(784, 'ND3F-67-050A(7)-4', '344.7267', '2018-04-02 14:15:34'),
(785, 'ND3F-67-050A(8)', '344.3988', '2018-04-02 14:15:34'),
(786, 'ND3G-67-050A(7)-4', '341.789', '2018-04-02 14:15:34'),
(787, 'ND3G-67-050A(8)', '341.4611', '2018-04-02 14:15:34'),
(788, 'ND3H-67-050A(7)-4', '275.5978', '2018-04-02 14:15:34'),
(789, 'ND3J-67-050A(7)-4', '334.6991', '2018-04-02 14:15:34'),
(790, 'ND3K-67-050A(7)-4', '337.8455', '2018-04-02 14:15:34'),
(791, 'ND3L-67-050A(4)-6', '298.0288', '2018-04-02 14:15:35'),
(792, 'ND3L-67-050A(5)', '297.8969', '2018-04-02 14:15:35'),
(793, 'ND3M-67-050A(4)-6', '334.1651', '2018-04-02 14:15:35'),
(794, 'ND3M-67-050A(5)', '333.8372', '2018-04-02 14:15:35'),
(795, 'ND3N-67-050A(4)-6', '300.6257', '2018-04-02 14:15:35'),
(796, 'ND3N-67-050A(5)', '300.4938', '2018-04-02 14:15:35'),
(797, 'ND3P-67-050A(4)-6', '336.7658', '2018-04-02 14:15:35'),
(798, 'ND3P-67-050A(5)', '336.4379', '2018-04-02 14:15:35'),
(799, 'ND3R-67-050A(4)-6', '326.593', '2018-04-02 14:15:35'),
(800, 'ND3R-67-050A(5)', '326.2599', '2018-04-02 14:15:36'),
(801, 'ND3S-67-050A(4)-6', '284.7496', '2018-04-02 14:15:36'),
(802, 'ND3S-67-050A(5)', '284.4165', '2018-04-02 14:15:36'),
(803, 'ND3T-67-050B(7)-4', '298.8296', '2018-04-02 14:15:36'),
(804, 'ND3V-67-050B(7)-4', '340.2559', '2018-04-02 14:15:36'),
(805, 'ND7L-67-050(2)-4', '323.5383', '2018-04-02 14:15:36'),
(806, 'N247-67-130E(12)', '21.0979', '2018-04-02 14:15:36'),
(807, 'N253-67-130A(12)', '19.6541', '2018-04-02 14:15:36'),
(808, 'N255-67-130E(12)', '17.3048', '2018-04-02 14:15:36'),
(809, 'N259-67-130E(12)', '21.7029', '2018-04-02 14:15:36'),
(810, 'N260-67-130E(12)', '25.1931', '2018-04-02 14:15:36'),
(811, 'N270-67-130E(12)', '25.808', '2018-04-02 14:15:37'),
(812, 'NA1J-67-130D(8)', '20.6568', '2018-04-02 14:15:37'),
(813, 'NA1P-67-130E(8)', '18.2694', '2018-04-02 14:15:37'),
(814, 'NA1V-67-130C(12)', '18.2694', '2018-04-02 14:15:37'),
(815, 'NA6R-67-130C(12)', '18.9331', '2018-04-02 14:15:37'),
(816, 'NA6W-67-130E(8)', '21.1359', '2018-04-02 14:15:37'),
(817, 'NA9B-67-130E(8)', '18.965', '2018-04-02 14:15:37'),
(818, 'NA9C-67-130E(8)', '19.3581', '2018-04-02 14:15:37'),
(819, 'NA9D-67-130E(8)', '20.6926', '2018-04-02 14:15:37'),
(820, 'NA9E-67-130E(8)', '24.0283', '2018-04-02 14:15:37'),
(821, 'NA9F-67-130E(8)', '25.7789', '2018-04-02 14:15:38'),
(822, 'NA9G-67-130E(8)', '20.7323', '2018-04-02 14:15:38'),
(823, 'NA9H-67-130E(8)', '23.4844', '2018-04-02 14:15:38'),
(824, 'NA9J-67-130E(8)', '25.6457', '2018-04-02 14:15:38'),
(825, 'NA9K-67-130E(8)', '21.1314', '2018-04-02 14:15:38'),
(826, 'NA9L-67-130E(8)', '23.305', '2018-04-02 14:15:38'),
(827, 'NA9M-67-130E(8)', '25.8325', '2018-04-02 14:15:38'),
(828, 'NA9N-67-130E(8)', '27.6922', '2018-04-02 14:15:38'),
(829, 'NA9P-67-130D(8)', '22.608', '2018-04-02 14:15:39'),
(830, 'NA9R-67-130D(8)', '27.149', '2018-04-02 14:15:39'),
(831, 'NA9T-67-130C(12)', '20.699', '2018-04-02 14:15:39'),
(832, 'NA9V-67-130C(12)', '25.1088', '2018-04-02 14:15:39'),
(833, 'NB0A-67-130C(12)', '27.0506', '2018-04-02 14:15:39'),
(834, 'NB0D-67-130E(8)', '22.4558', '2018-04-02 14:15:40'),
(835, 'NB2V-67-130C(12)', '21.8798', '2018-04-02 14:15:40'),
(836, 'N344-67-030C(7)', '134.2301', '2018-04-02 14:15:40'),
(837, 'N344-67-030C(7)-1', '134.2417', '2018-04-02 14:15:40'),
(838, 'N345-67-030B(7)', '164.2745', '2018-04-02 14:15:40'),
(839, 'N345-67-030B(7)-1', '164.2716', '2018-04-02 14:15:40'),
(840, 'N346-67-030B(7)', '181.0249', '2018-04-02 14:15:40'),
(841, 'N346-67-030B(7)-1', '181.0221', '2018-04-02 14:15:40'),
(842, 'N347-67-030B(7)', '175.8567', '2018-04-02 14:15:41'),
(843, 'N347-67-030B(7)-1', '176.0411', '2018-04-02 14:15:41'),
(844, 'N349-67-030B(7)', '188.9844', '2018-04-02 14:15:41'),
(845, 'N349-67-030B(7)-1', '189.07', '2018-04-02 14:15:41'),
(846, 'N372-67-030B(7)', '177.2581', '2018-04-02 14:15:41'),
(847, 'N372-67-030B(7)-1', '177.3506', '2018-04-02 14:15:41'),
(848, 'N375-67-030B(7)', '192.7771', '2018-04-02 14:15:41'),
(849, 'N375-67-030B(7)-1', '192.9641', '2018-04-02 14:15:41'),
(850, 'N376-67-030C(7)-1', '140.3638', '2018-04-02 14:15:41'),
(851, 'ND5G-67-030B(7)', '158.9756', '2018-04-02 14:15:42'),
(852, 'ND5G-67-030B(7)-1', '159.0834', '2018-04-02 14:15:42'),
(853, 'ND5H-67-030B(7)', '169.2984', '2018-04-02 14:15:42'),
(854, 'ND5H-67-030B(7)-1', '169.5013', '2018-04-02 14:15:42'),
(855, 'ND5J-67-030B(7)', '161.0921', '2018-04-02 14:15:42'),
(856, 'ND5J-67-030B(7)-1', '161.1997', '2018-04-02 14:15:42'),
(857, 'ND5K-67-030B(7)', '165.753', '2018-04-02 14:15:42'),
(858, 'ND5K-67-030B(7)-1', '165.8608', '2018-04-02 14:15:42'),
(859, 'ND5L-67-030B(7)', '171.575', '2018-04-02 14:15:42'),
(860, 'ND5L-67-030B(7)-1', '171.7772', '2018-04-02 14:15:43'),
(861, 'ND5M-67-030B(7)', '176.2494', '2018-04-02 14:15:43'),
(862, 'ND5M-67-030B(7)-1', '176.449', '2018-04-02 14:15:43'),
(863, 'ND5N-67-030B(7)', '134.484', '2018-04-02 14:15:43'),
(864, 'ND5N-67-030B(7)-1', '134.4726', '2018-04-02 14:15:43'),
(865, 'ND5P-67-030B(7)', '157.3179', '2018-04-02 14:15:43'),
(866, 'ND5P-67-030B(7)-1', '157.3048', '2018-04-02 14:15:43'),
(867, 'ND5R-67-030B(7)', '159.4381', '2018-04-02 14:15:43'),
(868, 'ND5R-67-030B(7)-1', '159.425', '2018-04-02 14:15:43'),
(869, 'ND5S-67-030B(7)', '160.6849', '2018-04-02 14:15:44'),
(870, 'ND5S-67-030B(7)-1', '160.672', '2018-04-02 14:15:44'),
(871, 'ND5V-67-030A(5)', '137.1307', '2018-04-02 14:15:44'),
(872, 'ND5V-67-030A(5)-2', '137.3642', '2018-04-02 14:15:44'),
(873, 'ND5W-67-030A(5)', '167.6938', '2018-04-02 14:15:44'),
(874, 'ND5W-67-030A(5)-2', '168.0021', '2018-04-02 14:15:44'),
(875, 'ND6A-67-030A(5)', '166.4151', '2018-04-02 14:15:44'),
(876, 'ND6A-67-030A(5)-2', '166.6843', '2018-04-02 14:15:44'),
(877, 'ND6B-67-030A(5)', '158.5493', '2018-04-02 14:15:44'),
(878, 'ND6B-67-030A(5)-2', '158.7548', '2018-04-02 14:15:44'),
(879, 'ND6C-67-030A(5)', '177.7058', '2018-04-02 14:15:45'),
(880, 'ND6F-67-030A(5)', '181.8018', '2018-04-02 14:15:45'),
(881, 'ND6F-67-030A(5)-2', '182.3098', '2018-04-02 14:15:45'),
(882, 'ND6G-67-030A(5)', '155.002', '2018-04-02 14:15:45'),
(883, 'ND6G-67-030A(5)-2', '155.2072', '2018-04-02 14:15:45'),
(884, 'ND6H-67-030A(5)', '161.8419', '2018-04-02 14:15:45'),
(885, 'ND6H-67-030A(5)-2', '162.0909', '2018-04-02 14:15:45'),
(886, 'ND6J-67-030A(5)', '166.2585', '2018-04-02 14:15:45'),
(887, 'ND6J-67-030A(5)-2', '166.6304', '2018-04-02 14:15:45'),
(888, 'ND6K-67-030A(5)', '173.3211', '2018-04-02 14:15:45'),
(889, 'ND6K-67-030A(5)-2', '173.7392', '2018-04-02 14:15:45'),
(890, 'ND6L-67-030A(5)', '157.2314', '2018-04-02 14:15:45'),
(891, 'ND6L-67-030A(5)-2', '157.4363', '2018-04-02 14:15:46'),
(892, 'ND6M-67-030A(5)', '175.4205', '2018-04-02 14:15:46'),
(893, 'ND6M-67-030A(5)-2', '175.8385', '2018-04-02 14:15:46'),
(894, 'ND6N-67-030A(5)', '162.3494', '2018-04-02 14:15:46'),
(895, 'ND6N-67-030A(5)-2', '162.624', '2018-04-02 14:15:46'),
(896, 'ND6P-67-030A(5)', '166.6772', '2018-04-02 14:15:46'),
(897, 'ND6P-67-030A(5)-2', '166.9352', '2018-04-02 14:15:46'),
(898, 'ND6R-67-030A(5)', '169.4098', '2018-04-02 14:15:46'),
(899, 'ND6R-67-030A(5)-2', '169.7307', '2018-04-02 14:15:46'),
(900, 'ND6T-67-030A(5)', '174.5731', '2018-04-02 14:15:46'),
(901, 'ND6T-67-030A(5)-2', '175.1187', '2018-04-02 14:15:46'),
(902, 'ND6V-67-030A(5)', '178.6713', '2018-04-02 14:15:46'),
(903, 'ND6V-67-030A(5)-2', '179.1935', '2018-04-02 14:15:46'),
(904, 'ND6W-67-030A(5)', '156.6547', '2018-04-02 14:15:47'),
(905, 'ND6W-67-030A(5)-2', '156.9319', '2018-04-02 14:15:47'),
(906, 'ND7A-67-030B(5)', '166.2983', '2018-04-02 14:15:47'),
(907, 'ND7A-67-030B(5)-2', '166.6213', '2018-04-02 14:15:47'),
(908, 'ND7B-67-030B(5)', '177.3672', '2018-04-02 14:15:47'),
(909, 'ND7B-67-030B(5)-2', '177.8547', '2018-04-02 14:15:47'),
(910, 'ND7C-67-030B(7)-1', '162.9539', '2018-04-02 14:15:47'),
(911, 'ND7D-67-030B(7)-1', '173.5755', '2018-04-02 14:15:47'),
(912, 'NE3D-67-030A(5)', '181.4261', '2018-04-02 14:15:47'),
(913, 'NE3D-67-030A(5)-2', '181.9785', '2018-04-02 14:15:47'),
(914, 'NE3E-67-030A(5)', '178.9943', '2018-04-02 14:15:47'),
(915, 'NE3E-67-030A(5)-2', '179.4095', '2018-04-02 14:15:47'),
(916, 'NE3F-67-030A(5)', '169.6582', '2018-04-02 14:15:47'),
(917, 'NE3G-67-030A(5)', '172.6397', '2018-04-02 14:15:48'),
(918, 'NE3H-67-030A(5)', '174.743', '2018-04-02 14:15:48'),
(919, 'NE3J-67-030A(5)', '170.528', '2018-04-02 14:15:48'),
(920, 'NE3J-67-030A(5)-2', '170.8336', '2018-04-02 14:15:48'),
(921, 'NE3K-67-030B(7)-1', '140.5202', '2018-04-02 14:15:48'),
(922, 'NE3M-67-030B(7)', '162.5938', '2018-04-02 14:15:48'),
(923, 'NE3M-67-030B(7)-1', '162.5806', '2018-04-02 14:15:48'),
(924, 'NE3N-67-030B(7)', '160.893', '2018-04-02 14:15:48'),
(925, 'NE3N-67-030B(7)-1', '160.8685', '2018-04-02 14:15:48'),
(926, 'NE3P-67-030B(7)', '171.1629', '2018-04-02 14:15:48'),
(927, 'NE3P-67-030B(7)-1', '171.2316', '2018-04-02 14:15:48'),
(928, 'NE4A-67-030(7)-1', '178.6457', '2018-04-02 14:15:48'),
(929, 'NE4B-67-030A(7)', '166.3826', '2018-04-02 14:15:49'),
(930, 'NE4B-67-030A(7)-1', '166.3722', '2018-04-02 14:15:49'),
(931, 'NE4C-67-030A(7)', '176.8262', '2018-04-02 14:15:49'),
(932, 'NE4C-67-030A(7)-1', '176.9079', '2018-04-02 14:15:49'),
(933, 'NE4D-67-030A(7)-1', '162.3824', '2018-04-02 14:15:49'),
(934, 'NE4E-67-030A(7)-1', '164.4217', '2018-04-02 14:15:49'),
(935, 'NE4F-67-030A(7)-1', '172.9089', '2018-04-02 14:15:49'),
(936, 'NE4G-67-030A(7)-1', '174.8464', '2018-04-02 14:15:49'),
(937, 'NE5L-67-030A(5)', '161.1468', '2018-04-02 14:15:49'),
(938, 'NE5L-67-030A(5)-2', '161.415', '2018-04-02 14:15:49'),
(939, 'NE5M-67-030A(5)', '163.5834', '2018-04-02 14:15:49'),
(940, 'NE5M-67-030A(5)-2', '163.8523', '2018-04-02 14:15:50'),
(941, 'NE7G-67-030B(7)', '169.178', '2018-04-02 14:15:50'),
(942, 'NE7G-67-030B(7)-1', '169.1651', '2018-04-02 14:15:50'),
(943, 'NE7L-67-030B(7)', '179.6249', '2018-04-02 14:15:50'),
(944, 'NE7L-67-030B(7)-1', '179.7036', '2018-04-02 14:15:50'),
(945, 'N346-67-020B(6)', '129.198', '2018-04-02 14:15:50'),
(946, 'N347-67-020B(6)', '112.535', '2018-04-02 14:15:50'),
(947, 'ND5H-67-020B(6)', '112.1019', '2018-04-02 14:15:50'),
(948, 'ND5V-67-020B(6)', '126.9343', '2018-04-02 14:15:50'),
(949, 'ND6A-67-020B(4)', '126.5983', '2018-04-02 14:15:50'),
(950, 'ND6C-67-020B(4)', '111.5661', '2018-04-02 14:15:50'),
(951, 'ND6D-67-020B(4)', '128.7284', '2018-04-02 14:15:50'),
(952, 'ND6F-67-020B(4)', '111.8656', '2018-04-02 14:15:51'),
(953, 'N344-67-290(4)-2', '32.0527', '2018-04-02 14:15:51'),
(954, 'N345-67-290A(1)', '7.9581', '2018-04-02 14:15:51'),
(955, 'N346-67-290(5)-1', '33.3196', '2018-04-02 14:15:51'),
(956, 'ND5G-67-290(4)-2', '39.9659', '2018-04-02 14:15:51'),
(957, 'ND5H-67-290(3)-2', '26.1688', '2018-04-02 14:15:51'),
(958, 'ND5N-67-290(4)-2', '32.2326', '2018-04-02 14:15:51'),
(959, 'ND5P-67-290(4)-2', '40.1455', '2018-04-02 14:15:51'),
(960, 'ND5V-67-290(4)-2', '32.1665', '2018-04-02 14:15:51'),
(961, 'ND5V-67-SH0A(3)-1', '17.8005', '2018-04-02 14:15:51'),
(962, 'ND5W-67-290(4)-2', '40.0794', '2018-04-02 14:15:51'),
(963, 'ND6C-67-SH0(0)-1', '29.996', '2018-04-02 14:15:51'),
(964, 'ND6F-67-SH0(0)-1', '35.4004', '2018-04-02 14:15:51'),
(965, 'ND6N-67-290(3)-2', '28.8278', '2018-04-02 14:15:52'),
(966, 'PE31-67-SH0(0)-2', '3.6742', '2018-04-02 14:15:52'),
(967, 'N344-67-010B(6)', '254.726', '2018-04-02 14:15:52'),
(968, 'N345-67-010A(6)', '260.25', '2018-04-02 14:15:52'),
(969, 'N346-67-010A(6)', '277.2295', '2018-04-02 14:15:52'),
(970, 'N347-67-010A(6)', '277.5301', '2018-04-02 14:15:52'),
(971, 'ND5H-67-010A(6)', '257.9955', '2018-04-02 14:15:52'),
(972, 'ND5M-67-010A(6)', '265.138', '2018-04-02 14:15:52'),
(973, 'ND5P-67-010A(6)', '258.2426', '2018-04-02 14:15:52'),
(974, 'ND6B-67-010A(6)-2', '275.8652', '2018-04-02 14:15:52'),
(975, 'ND6F-67-010A(6)-2', '289.1107', '2018-04-02 14:15:52'),
(976, 'ND6H-67-010A(6)-2', '276.5697', '2018-04-02 14:15:52'),
(977, 'ND6J-67-010A(6)-2', '275.1712', '2018-04-02 14:15:53'),
(978, 'ND6K-67-010A(6)-2', '274.25', '2018-04-02 14:15:53'),
(979, 'ND6M-67-010A(6)-2', '260.4062', '2018-04-02 14:15:53'),
(980, 'ND6N-67-010B(6)-2', '262.4824', '2018-04-02 14:15:53'),
(981, 'ND6S-67-010B(6)-2', '269.8103', '2018-04-02 14:15:53'),
(982, 'ND6T-67-010B(6)-2', '270.1299', '2018-04-02 14:15:53'),
(983, 'ND6V-67-010B(6)-2', '262.7969', '2018-04-02 14:15:53'),
(984, 'ND7A-67-010A(6)-2', '264.9058', '2018-04-02 14:15:53'),
(985, 'ND7B-67-010A(6)-2', '264.9331', '2018-04-02 14:15:53'),
(986, 'ND7C-67-010A(6)', '273.2135', '2018-04-02 14:15:53'),
(987, 'ND7D-67-010A(6)', '272.1294', '2018-04-02 14:15:54'),
(988, 'NE3F-67-010A(6)-2', '257.7538', '2018-04-02 14:15:54'),
(989, 'NE3M-67-010A(6)-2', '275.8938', '2018-04-02 14:15:54'),
(990, 'NE3P-67-010A(6)-2', '268.392', '2018-04-02 14:15:54'),
(991, 'NE3S-67-010A(6)-2', '291.4348', '2018-04-02 14:15:54'),
(992, 'NE3V-67-010A(6)-2', '283.7459', '2018-04-02 14:15:54'),
(993, 'NE4E-67-010A(6)-2', '257.7784', '2018-04-02 14:15:54'),
(994, 'NE4H-67-010A(6)', '279.8724', '2018-04-02 14:15:54'),
(995, 'NE4P-67-010A(6)-2', '267.2133', '2018-04-02 14:15:54'),
(996, 'NE4S-67-010A(6)-2', '253.3752', '2018-04-02 14:15:54'),
(997, 'NE4T-67-010A(6)-2', '269.5384', '2018-04-02 14:15:55'),
(998, 'NE4W-67-010A(6)', '265.7558', '2018-04-02 14:15:55'),
(999, 'NE5A-67-010A(6)', '264.9781', '2018-04-02 14:15:55'),
(1000, 'NE5C-67-010A(6)-2', '281.4229', '2018-04-02 14:15:55'),
(1001, 'NE5D-67-010A(6)', '273.5143', '2018-04-02 14:15:55'),
(1002, 'NE5M-67-010A(6)-2', '268.3685', '2018-04-02 14:15:55'),
(1003, 'NE7G-67-010A(6)', '265.6799', '2018-04-02 14:15:55'),
(1004, 'NE7J-67-010A(6)', '281.0801', '2018-04-02 14:15:55'),
(1005, 'N344-67-050B(5)', '194.3308', '2018-04-02 14:15:55'),
(1006, 'N345-67-050B(5)', '250.9022', '2018-04-02 14:15:55'),
(1007, 'N346-67-050B(5)', '258.6642', '2018-04-02 14:15:56'),
(1008, 'N347-67-050B(5)', '296.71', '2018-04-02 14:15:56'),
(1009, 'N348-67-050B(5)', '299.8657', '2018-04-02 14:15:56'),
(1010, 'N349-67-050B(5)', '338.1919', '2018-04-02 14:15:56'),
(1011, 'N357-67-050B(5)', '204.102', '2018-04-02 14:15:56'),
(1012, 'N358-67-050B(5)', '198.0049', '2018-04-02 14:15:56'),
(1013, 'N359-67-050B(5)', '291.8354', '2018-04-02 14:15:56'),
(1014, 'N360-67-050B(5)', '317.7386', '2018-04-02 14:15:56'),
(1015, 'N361-67-050B(5)', '329.7228', '2018-04-02 14:15:57'),
(1016, 'N362-67-050B(5)', '289.0339', '2018-04-02 14:15:57'),
(1017, 'N372-67-050B(5)', '279.7755', '2018-04-02 14:15:57'),
(1018, 'N374-67-050B(5)', '321.1282', '2018-04-02 14:15:57'),
(1019, 'N375-67-050B(5)', '358.8026', '2018-04-02 14:15:57'),
(1020, 'N376-67-050B(5)', '188.1001', '2018-04-02 14:15:57'),
(1021, 'ND5G-67-050B(5)', '226.4163', '2018-04-02 14:15:57'),
(1022, 'ND5H-67-050B(5)', '254.5004', '2018-04-02 14:15:57'),
(1023, 'ND5J-67-050B(5)', '261.0386', '2018-04-02 14:15:57'),
(1024, 'ND5K-67-050B(5)', '266.9283', '2018-04-02 14:15:57'),
(1025, 'ND5L-67-050B(5)', '289.3076', '2018-04-02 14:15:58'),
(1026, 'ND5M-67-050B(5)', '295.4852', '2018-04-02 14:15:58'),
(1027, 'ND5N-67-050B(5)', '203.3187', '2018-04-02 14:15:58'),
(1028, 'ND5P-67-050B(5)', '270.1247', '2018-04-02 14:15:58'),
(1029, 'ND5R-67-050B(5)', '229.7258', '2018-04-02 14:15:58'),
(1030, 'ND5V-67-050B(9)', '194.1417', '2018-04-02 14:15:58'),
(1031, 'ND5W-67-050B(9)', '276.3846', '2018-04-02 14:15:58'),
(1032, 'ND6B-67-050B(9)', '264.765', '2018-04-02 14:15:58'),
(1033, 'ND6C-67-050A(6)', '305.658', '2018-04-02 14:15:59'),
(1034, 'ND6D-67-050B(9)', '273.1666', '2018-04-02 14:15:59'),
(1035, 'ND6F-67-050B(9)', '349.2526', '2018-04-02 14:15:59'),
(1036, 'ND6M-67-050C(9)', '339.3369', '2018-04-02 14:15:59'),
(1037, 'ND6N-67-050B(9)', '268.745', '2018-04-02 14:15:59'),
(1038, 'ND6P-67-050B(9)', '309.0344', '2018-04-02 14:15:59'),
(1039, 'ND6S-67-050B(9)', '285.4448', '2018-04-02 14:15:59'),
(1040, 'ND6V-67-050B(9)', '337.9597', '2018-04-02 14:15:59'),
(1041, 'ND7A-67-050C(9)', '274.3813', '2018-04-02 14:15:59'),
(1042, 'ND7B-67-050C(9)', '303.0688', '2018-04-02 14:15:59'),
(1043, 'NE3G-67-050B(9)', '297.093', '2018-04-02 14:16:00'),
(1044, 'NE3J-67-050B(9)', '314.1184', '2018-04-02 14:16:00'),
(1045, 'NE3L-67-050B(9)', '205.8406', '2018-04-02 14:16:00'),
(1046, 'NE3M-67-050B(9)', '273.2516', '2018-04-02 14:16:00'),
(1047, 'NE3R-67-050A(6)', '293.429', '2018-04-02 14:16:00'),
(1048, 'NE4B-67-050B(9)', '224.6397', '2018-04-02 14:16:00'),
(1049, 'NE4D-67-050B(9)', '313.773', '2018-04-02 14:16:00'),
(1050, 'NE4H-67-050B(9)', '308.9803', '2018-04-02 14:16:00'),
(1051, 'NE4K-67-050B(9)', '268.6923', '2018-04-02 14:16:00'),
(1052, 'NE4M-67-050B(9)', '338.3087', '2018-04-02 14:16:00'),
(1053, 'NE4P-67-050B(9)', '297.4431', '2018-04-02 14:16:01'),
(1054, 'NE4S-67-050B(5)', '283.6739', '2018-04-02 14:16:01'),
(1055, 'NE4T-67-050B(5)', '243.0801', '2018-04-02 14:16:01'),
(1056, 'NE4W-67-050B(5)', '302.898', '2018-04-02 14:16:01'),
(1057, 'NE5E-67-050B(5)', '338.4856', '2018-04-02 14:16:01'),
(1058, 'NE5L-67-050B(9)', '236.3823', '2018-04-02 14:16:01'),
(1059, 'NE5N-67-050B(9)', '244.9778', '2018-04-02 14:16:01'),
(1060, 'NE7G-67-050B(5)', '282.2881', '2018-04-02 14:16:01'),
(1061, 'NE7H-67-050B(5)', '323.1075', '2018-04-02 14:16:01'),
(1062, 'NE7L-67-050B(5)', '359.1924', '2018-04-02 14:16:01'),
(1063, 'NE7P-67-050B(5)', '239.7821', '2018-04-02 14:16:01'),
(1064, 'NE7R-67-050B(5)', '274.3158', '2018-04-02 14:16:02'),
(1065, 'NE8B-67-050B(5)', '309.0713', '2018-04-02 14:16:02'),
(1066, 'NE8C-67-050B(5)', '343.9101', '2018-04-02 14:16:02'),
(1067, 'NE8J-67-050B(5)', '267.9578', '2018-04-02 14:16:02'),
(1068, 'NE8K-67-050B(5)', '302.8028', '2018-04-02 14:16:02'),
(1069, 'NE8R-67-050B(5)', '280.6255', '2018-04-02 14:16:02'),
(1070, 'NE8S-67-050B(5)', '315.1779', '2018-04-02 14:16:02'),
(1071, 'NE9B-67-050C(9)', '246.8872', '2018-04-02 14:16:02'),
(1072, 'NE9C-67-050C(9)', '270.4031', '2018-04-02 14:16:03'),
(1073, 'NE9J-67-050C(9)', '342.2049', '2018-04-02 14:16:03'),
(1074, 'NE9M-67-050C(9)', '339.8722', '2018-04-02 14:16:03'),
(1075, 'NF0C-67-050C(9)', '350.0442', '2018-04-02 14:16:03'),
(1076, 'NF0T-67-050C(9)', '308.244', '2018-04-02 14:16:03'),
(1077, 'NF1B-67-050C(9)', '311.1359', '2018-04-02 14:16:03'),
(1078, 'N344-67-130(2)-1', '20.3872', '2018-04-02 14:16:03'),
(1079, 'N345-67-130(2)-1', '25.0584', '2018-04-02 14:16:03'),
(1080, 'N346-67-130(3)', '22.2155', '2018-04-02 14:16:03'),
(1081, 'N372-67-130(2)-1', '26.0729', '2018-04-02 14:16:03'),
(1082, 'ND5G-67-130(2)-1', '20.7787', '2018-04-02 14:16:03'),
(1083, 'ND5H-67-130(4)', '18.2594', '2018-04-02 14:16:04'),
(1084, 'ND5J-67-130(4)', '22.6377', '2018-04-02 14:16:04'),
(1085, 'ND5K-67-130(4)', '18.795', '2018-04-02 14:16:04'),
(1086, 'ND5N-67-130(2)-1', '17.8889', '2018-04-02 14:16:04'),
(1087, 'ND5P-67-130(2)-1', '21.7049', '2018-04-02 14:16:04'),
(1088, 'ND5R-67-130(2)-1', '20.1928', '2018-04-02 14:16:04'),
(1089, 'ND5S-67-130(2)-1', '24.5582', '2018-04-02 14:16:04'),
(1090, 'ND5V-67-130(2)-1', '16.5591', '2018-04-02 14:16:04'),
(1091, 'ND5W-67-130(2)-1', '17.8889', '2018-04-02 14:16:04'),
(1092, 'ND6A-67-130(2)-1', '20.7844', '2018-04-02 14:16:04'),
(1093, 'ND6B-67-130(2)-1', '22.1019', '2018-04-02 14:16:05'),
(1094, 'ND6C-67-130(2)-1', '23.3076', '2018-04-02 14:16:05'),
(1095, 'ND6D-67-130(2)-1', '25.0539', '2018-04-02 14:16:05'),
(1096, 'ND6E-67-130(2)-1', '18.5544', '2018-04-02 14:16:05'),
(1097, 'ND6F-67-130(2)-1', '25.5402', '2018-04-02 14:16:05'),
(1098, 'ND6P-67-130(2)-1', '24.7827', '2018-04-02 14:16:05'),
(1099, 'ND6T-67-130(2)-1', '22.2855', '2018-04-02 14:16:05'),
(1100, 'ND6V-67-130(2)-1', '26.8594', '2018-04-02 14:16:05'),
(1101, 'NE3D-67-130(2)-1', '20.3233', '2018-04-02 14:16:05'),
(1102, 'NE3E-67-130(2)-1', '22.6466', '2018-04-02 14:16:05'),
(1103, 'NE3F-67-130(2)-1', '24.8204', '2018-04-02 14:16:06'),
(1104, 'NE3G-67-130(2)-1', '20.8035', '2018-04-02 14:16:06'),
(1105, 'NE3H-67-130(2)-1', '22.9784', '2018-04-02 14:16:06'),
(1106, 'NE3J-67-130(2)-1', '27.3775', '2018-04-02 14:16:06'),
(1107, 'NE5L-67-130(2)-1', '18.9622', '2018-04-02 14:16:06'),
(1108, 'NE5M-67-130(2)-1', '20.2982', '2018-04-02 14:16:06'),
(1109, 'NE5N-67-130(2)-1', '20.2665', '2018-04-02 14:16:06'),
(1110, 'NE7G-67-130(2)-1', '26.897', '2018-04-02 14:16:06'),
(1111, 'NA4L-67-EW0(1)-2', '2.921', '2018-04-02 14:16:06'),
(1112, 'NA4M-67-EW0(2)-2', '2.4178', '2018-04-02 14:16:06'),
(1113, 'N253-67-030A(10)-C', '166.0035', '2018-04-02 14:16:07'),
(1114, 'N253-67-030A(8)-1-C', '165.89', '2018-04-02 14:16:07'),
(1115, 'N254-67-030A(10)-C', '172.2339', '2018-04-02 14:16:07'),
(1116, 'N254-67-030A(8)-1-C', '172.2177', '2018-04-02 14:16:07'),
(1117, 'N294-67-030A(10)-C', '170.4954', '2018-04-02 14:16:07'),
(1118, 'N294-67-030A(8)-1-C', '170.4789', '2018-04-02 14:16:07'),
(1119, 'N295-67-030A(10)-C', '180.0783', '2018-04-02 14:16:07'),
(1120, 'N295-67-030A(8)-1-C', '180.0646', '2018-04-02 14:16:07'),
(1121, 'N296-67-030A(10)-C', '176.9601', '2018-04-02 14:16:07'),
(1122, 'N296-67-030A(8)-1-C', '176.9428', '2018-04-02 14:16:08'),
(1123, 'N297-67-030A(10)-C', '189.3312', '2018-04-02 14:16:08'),
(1124, 'N297-67-030A(8)-1-C', '189.3135', '2018-04-02 14:16:08'),
(1125, 'NA4L-67-030A(13)-1-D', '151.0433', '2018-04-02 14:16:08'),
(1126, 'NA4M-67-030A(13)-1-D', '160.3039', '2018-04-02 14:16:08'),
(1127, 'NA4N-67-030A(13)-2-D', '130.9958', '2018-04-02 14:16:08'),
(1128, 'NA4T-67-030(7)-1-C', '129.4195', '2018-04-02 14:16:08'),
(1129, 'NA4T-67-030(9)-C', '129.5318', '2018-04-02 14:16:08'),
(1130, 'NA6E-67-030A(7)-1-C', '136.3623', '2018-04-02 14:16:08'),
(1131, 'NA6E-67-030A(9)-C', '136.475', '2018-04-02 14:16:09'),
(1132, 'NA6F-67-030A(7)-1-C', '142.5838', '2018-04-02 14:16:09'),
(1133, 'NA6F-67-030A(9)-C', '142.695', '2018-04-02 14:16:09'),
(1134, 'NB9B-67-030A(11)-2-D', '163.0887', '2018-04-02 14:16:09'),
(1135, 'NB9C-67-030A(11)-2-D', '168.99', '2018-04-02 14:16:09'),
(1136, 'NB9H-67-030A(13)-2-D', '163.5508', '2018-04-02 14:16:09'),
(1137, 'NB9M-67-030A(11)-2-D', '172.838', '2018-04-02 14:16:09'),
(1138, 'NB9N-67-030A(11)-2-D', '182.6039', '2018-04-02 14:16:10'),
(1139, 'NB9P-67-030A(7)-1-C', '155.4578', '2018-04-02 14:16:10'),
(1140, 'NB9P-67-030A(9)-C', '155.5686', '2018-04-02 14:16:10'),
(1141, 'NB9T-67-030A(7)-1-C', '161.7542', '2018-04-02 14:16:10'),
(1142, 'NB9T-67-030A(9)-C', '161.8681', '2018-04-02 14:16:10'),
(1143, 'NC0A-67-030(10)-C', '155.9254', '2018-04-02 14:16:10'),
(1144, 'NC0A-67-030(8)-1-C', '155.8125', '2018-04-02 14:16:10'),
(1145, 'NC0B-67-030A(10)-C', '162.5409', '2018-04-02 14:16:10'),
(1146, 'NC0B-67-030A(8)-1-C', '162.4279', '2018-04-02 14:16:11'),
(1147, 'NC0C-67-030(10)-C', '159.1722', '2018-04-02 14:16:11'),
(1148, 'NC0C-67-030(8)-1-C', '159.059', '2018-04-02 14:16:11'),
(1149, 'NC0D-67-030A(10)-C', '167.2305', '2018-04-02 14:16:11'),
(1150, 'NC0D-67-030A(8)-1-C', '167.1163', '2018-04-02 14:16:11'),
(1151, 'NC0E-67-030(10)-C', '163.5235', '2018-04-02 14:16:11'),
(1152, 'NC0E-67-030(8)-1-C', '163.4094', '2018-04-02 14:16:11'),
(1153, 'NC0F-67-030A(10)-C', '171.7983', '2018-04-02 14:16:11'),
(1154, 'NC0F-67-030A(8)-1-C', '171.6845', '2018-04-02 14:16:11'),
(1155, 'NC0G-67-030(10)-C', '167.9636', '2018-04-02 14:16:12'),
(1156, 'NC0G-67-030(8)-1-C', '167.853', '2018-04-02 14:16:12'),
(1157, 'NC0H-67-030A(10)-C', '176.3957', '2018-04-02 14:16:12'),
(1158, 'NC0H-67-030A(8)-1-C', '176.2804', '2018-04-02 14:16:12'),
(1159, 'NC0J-67-030(10)-C', '172.4429', '2018-04-02 14:16:12'),
(1160, 'NC0J-67-030(8)-1-C', '172.3286', '2018-04-02 14:16:12'),
(1161, 'NC0K-67-030A(11)-2-D', '156.2343', '2018-04-02 14:16:12'),
(1162, 'NC0L-67-030A(11)-2-D', '162.63', '2018-04-02 14:16:12'),
(1163, 'NC0M-67-030A(11)-2-D', '159.2291', '2018-04-02 14:16:12'),
(1164, 'NC0N-67-030A(11)-2-D', '168.5048', '2018-04-02 14:16:13'),
(1165, 'NC0P-67-030A(11)-2-D', '164.7523', '2018-04-02 14:16:13'),
(1166, 'NC0R-67-030A(11)-2-D', '172.351', '2018-04-02 14:16:13'),
(1167, 'NC0S-67-030A(11)-2-D', '168.403', '2018-04-02 14:16:13'),
(1168, 'NC0T-67-030A(11)-2-D', '178.1439', '2018-04-02 14:16:13'),
(1169, 'NC0V-67-030A(11)-2-D', '174.0598', '2018-04-02 14:16:13'),
(1170, 'NC0W-67-030(13)-2-D', '141.98', '2018-04-02 14:16:14'),
(1171, 'NC1A-67-030(13)-2-D', '147.5815', '2018-04-02 14:16:14'),
(1172, 'NC1B-67-030(13)-2-D', '160.7367', '2018-04-02 14:16:14'),
(1173, 'NC1C-67-030(11)-2-D', '170.1898', '2018-04-02 14:16:14'),
(1174, 'NC3E-67-030A(13)-2-D', '135.1063', '2018-04-02 14:16:14'),
(1175, 'NC3F-67-030A(13)-2-D', '140.6637', '2018-04-02 14:16:14'),
(1176, 'NC3G-67-030A(13)-2-D', '144.5736', '2018-04-02 14:16:14'),
(1177, 'NC3H-67-030A(13)-2-D', '150.3047', '2018-04-02 14:16:14'),
(1178, 'NC3J-67-030A(11)-2-D', '166.8584', '2018-04-02 14:16:14'),
(1179, 'NC3K-67-030A(11)-2-D', '174.8457', '2018-04-02 14:16:15'),
(1180, 'NC3L-67-030A(11)-2-D', '177.0023', '2018-04-02 14:16:15'),
(1181, 'NC3M-67-030A(11)-2-D', '184.4961', '2018-04-02 14:16:15'),
(1182, 'NC3V-67-030A(11)-D', '133.9585', '2018-04-02 14:16:15'),
(1183, 'NC3W-67-030A(13)-2-D', '139.3267', '2018-04-02 14:16:15'),
(1184, 'NC4A-67-030A(13)-2-D', '147.016', '2018-04-02 14:16:15'),
(1185, 'NC4E-67-030A(13)-2-D', '155.3802', '2018-04-02 14:16:15'),
(1186, 'NC4N-67-030A(13)-2-D', '143.8721', '2018-04-02 14:16:15'),
(1187, 'NC4P-67-030A(13)-2-D', '149.6019', '2018-04-02 14:16:16'),
(1188, 'NC4V-67-030A(13)-2-D', '159.9656', '2018-04-02 14:16:16'),
(1189, 'NC4W-67-030A(13)-2-D', '165.5369', '2018-04-02 14:16:16'),
(1190, 'NC5C-67-030A(11)-2-D', '159.689', '2018-04-02 14:16:16'),
(1191, 'NC5D-67-030A(11)-2-D', '165.2108', '2018-04-02 14:16:16'),
(1192, 'NC5M-67-030A(11)-2-D', '170.0506', '2018-04-02 14:16:16'),
(1193, 'NC5N-67-030A(11)-2-D', '179.5194', '2018-04-02 14:16:17'),
(1194, 'NC5P-67-030A(11)-2-D', '161.0669', '2018-04-02 14:16:17'),
(1195, 'NC5R-67-030A(11)-2-D', '170.2596', '2018-04-02 14:16:17'),
(1196, 'NC5V-67-030A(11)-2-D', '163.8564', '2018-04-02 14:16:17'),
(1197, 'NC5W-67-030A(11)-2-D', '171.7098', '2018-04-02 14:16:17'),
(1198, 'NC6K-67-030A(11)-2-D', '173.0549', '2018-04-02 14:16:17'),
(1199, 'NC6L-67-030A(11)-2-D', '180.6442', '2018-04-02 14:16:17'),
(1200, 'NC6N-67-030A(11)-2-D', '167.5712', '2018-04-02 14:16:17'),
(1201, 'NC6W-67-030(7)-1-C', '136.6344', '2018-04-02 14:16:17'),
(1202, 'NC6W-67-030(9)-C', '136.7478', '2018-04-02 14:16:17'),
(1203, 'NC7A-67-030(7)-1-C', '144.9882', '2018-04-02 14:16:18'),
(1204, 'NC7A-67-030(9)-C', '145.099', '2018-04-02 14:16:18'),
(1205, 'NC7E-67-030(7)-1-C', '152.7426', '2018-04-02 14:16:18'),
(1206, 'NC7E-67-030(9)-C', '152.8545', '2018-04-02 14:16:18'),
(1207, 'NC7F-67-030(10)-C', '156.4532', '2018-04-02 14:16:18'),
(1208, 'NC7F-67-030(8)-1-C', '156.3424', '2018-04-02 14:16:18'),
(1209, 'NC7N-67-030(10)-C', '159.5977', '2018-04-02 14:16:18'),
(1210, 'NC7N-67-030(8)-1-C', '159.4847', '2018-04-02 14:16:18'),
(1211, 'NC7P-67-030(10)-C', '164.305', '2018-04-02 14:16:18'),
(1212, 'NC7P-67-030(8)-1-C', '164.1909', '2018-04-02 14:16:18'),
(1213, 'NC7V-67-030(7)-1-C', '146.0461', '2018-04-02 14:16:19'),
(1214, 'NC7V-67-030(9)-C', '146.1596', '2018-04-02 14:16:19'),
(1215, 'NC8D-67-030(7)-1-C', '162.3641', '2018-04-02 14:16:19'),
(1216, 'NC8D-67-030(9)-C', '162.476', '2018-04-02 14:16:19'),
(1217, 'NC8M-67-030(10)-C', '168.3908', '2018-04-02 14:16:19'),
(1218, 'NC8M-67-030(8)-1-C', '168.2779', '2018-04-02 14:16:19'),
(1219, 'NC8N-67-030(10)-C', '172.8666', '2018-04-02 14:16:19'),
(1220, 'NC8N-67-030(8)-1-C', '172.7545', '2018-04-02 14:16:19'),
(1221, 'NC8V-67-030A(13)-2-D', '153.9999', '2018-04-02 14:16:19'),
(1222, 'NC9M-67-030A(7)-1-C', '140.9565', '2018-04-02 14:16:19'),
(1223, 'NC9M-67-030A(9)-C', '141.0682', '2018-04-02 14:16:20'),
(1224, 'NC9N-67-030A(7)-1-C', '147.1354', '2018-04-02 14:16:20'),
(1225, 'NC9N-67-030A(9)-C', '147.25', '2018-04-02 14:16:20'),
(1226, 'NC9P-67-030A(11)-2-D', '172.3352', '2018-04-02 14:16:20'),
(1227, 'ND0A-67-030A(10)-C', '159.9196', '2018-04-02 14:16:20'),
(1228, 'ND0A-67-030A(8)-1-C', '159.8066', '2018-04-02 14:16:20'),
(1229, 'ND0B-67-030A(10)-C', '169.169', '2018-04-02 14:16:20'),
(1230, 'ND0B-67-030A(8)-1-C', '169.0576', '2018-04-02 14:16:20'),
(1231, 'ND7M-67-030(11)-2-D', '175.7407', '2018-04-02 14:16:20'),
(1232, 'ND7R-67-030(14)-2-D', '140.1687', '2018-04-02 14:16:20'),
(1233, 'ND7S-67-030(14)-2-D', '156.1251', '2018-04-02 14:16:21'),
(1234, 'ND7T-67-030(12)-2-D', '161.014', '2018-04-02 14:16:21'),
(1235, 'ND7V-67-030(12)-2-D', '161.6039', '2018-04-02 14:16:21'),
(1236, 'NE2L-67-030(13)-D', '153.8536', '2018-04-02 14:16:21'),
(1237, 'NE2M-67-030(13)-D', '156.8565', '2018-04-02 14:16:21'),
(1238, 'NE2N-67-030(13)-D', '164.8083', '2018-04-02 14:16:21'),
(1239, 'NE2P-67-030(13)-D', '163.1286', '2018-04-02 14:16:21'),
(1240, 'NE2R-67-030(13)-D', '166.0219', '2018-04-02 14:16:21'),
(1241, 'NE2S-67-030(13)-D', '173.4244', '2018-04-02 14:16:21'),
(1242, 'A401-67-070D(9)-1', '27.3388', '2018-04-02 14:16:22'),
(1243, 'A401-67-260C(4)-3', '5.9878', '2018-04-02 14:16:22'),
(1244, 'A402-67-070D(9)-1', '15.6163', '2018-04-02 14:16:22'),
(1245, 'A401-15-76X(2)-3', '3.0981', '2018-04-02 14:16:22'),
(1246, 'NA4L-67-290B(8)', '31.2591', '2018-04-02 14:16:22'),
(1247, 'NA4L-67-SH0(3)-3', '8.807', '2018-04-02 14:16:22'),
(1248, 'NA4M-67-290B(8)', '19.0791', '2018-04-02 14:16:22'),
(1249, 'NA4N-67-290A(4)-5', '32.5459', '2018-04-02 14:16:23'),
(1250, 'NA4N-67-SH0(7)-6', '24.7992', '2018-04-02 14:16:23'),
(1251, 'NC3D-67-290B(8)', '10.26', '2018-04-02 14:16:23'),
(1252, 'NC3S-67-290B(8)', '22.9157', '2018-04-02 14:16:23'),
(1253, 'NA4L-67-150(3)-6', '4.0453', '2018-04-02 14:16:23'),
(1254, 'NA4M-67-150(3)-6', '16.646', '2018-04-02 14:16:23'),
(1255, 'NA4L-67-06YA(2)-5', '9.0768', '2018-04-02 14:16:23'),
(1256, 'NA4N-67-06YA(2)-5', '10.9367', '2018-04-02 14:16:24'),
(1257, 'N253-67-010(7)-4', '268.7445', '2018-04-02 14:16:24'),
(1258, 'N254-67-010(7)-4', '271.1623', '2018-04-02 14:16:24'),
(1259, 'N294-67-010(7)-4', '280.0622', '2018-04-02 14:16:24'),
(1260, 'N295-67-010(7)-4', '282.7138', '2018-04-02 14:16:24'),
(1261, 'NA4L-67-010D(11)-2', '256.1952', '2018-04-02 14:16:24'),
(1262, 'NA4M-67-010D(11)-2', '257.7983', '2018-04-02 14:16:24'),
(1263, 'NA4N-67-010C(9)-4', '267.4105', '2018-04-02 14:16:24'),
(1264, 'NA4T-67-010B(7)-4', '266.4996', '2018-04-02 14:16:24'),
(1265, 'NA4V-67-010B(7)-4', '268.9173', '2018-04-02 14:16:24'),
(1266, 'NA5E-67-010(9)-4', '259.2115', '2018-04-02 14:16:24'),
(1267, 'NA6K-67-010(9)-4', '265.3565', '2018-04-02 14:16:25'),
(1268, 'NC3D-67-010C(9)-4', '268.7165', '2018-04-02 14:16:25');
INSERT INTO `eff_product_st` (`ID`, `product_no`, `st`, `last_update`) VALUES
(1269, 'NC3S-67-010C(9)-4', '271.6536', '2018-04-02 14:16:25'),
(1270, 'NC3T-67-010C(9)-4', '278.6302', '2018-04-02 14:16:25'),
(1271, 'NC3V-67-010C(9)-4', '282.8601', '2018-04-02 14:16:25'),
(1272, 'NC3W-67-010C(9)-4', '273.0612', '2018-04-02 14:16:25'),
(1273, 'NC4A-67-010C(9)-4', '280.2377', '2018-04-02 14:16:25'),
(1274, 'NC4B-67-010C(9)-4', '284.4968', '2018-04-02 14:16:25'),
(1275, 'NC4C-67-010C(9)-4', '261.8515', '2018-04-02 14:16:25'),
(1276, 'NC4D-67-010C(9)-4', '263.3298', '2018-04-02 14:16:25'),
(1277, 'NC4E-67-010C(9)-4', '277.2587', '2018-04-02 14:16:26'),
(1278, 'NC4F-67-010C(9)-4', '278.8254', '2018-04-02 14:16:26'),
(1279, 'NC4H-67-010B(7)-4', '269.7206', '2018-04-02 14:16:26'),
(1280, 'NC4J-67-010B(7)-4', '277.4836', '2018-04-02 14:16:26'),
(1281, 'NC4K-67-010B(7)-4', '280.6828', '2018-04-02 14:16:26'),
(1282, 'NC4L-67-010B(7)-4', '272.1106', '2018-04-02 14:16:26'),
(1283, 'NC4M-67-010B(7)-4', '280.1063', '2018-04-02 14:16:26'),
(1284, 'NC4N-67-010B(7)-4', '283.3059', '2018-04-02 14:16:26'),
(1285, 'NC4P-67-010(9)-4', '270.4444', '2018-04-02 14:16:26'),
(1286, 'NC4R-67-010(9)-4', '276.6119', '2018-04-02 14:16:27'),
(1287, 'NC4S-67-010(7)-4', '262.6834', '2018-04-02 14:16:27'),
(1288, 'NC4T-67-010(7)-4', '267.8957', '2018-04-02 14:16:27'),
(1289, 'NC4V-67-010(7)-4', '273.6238', '2018-04-02 14:16:27'),
(1290, 'ND0A-67-010(7)-4', '261.5773', '2018-04-02 14:16:27'),
(1291, 'ND0B-67-010(7)-4', '263.9941', '2018-04-02 14:16:27'),
(1292, 'ND0D-67-010(7)-4', '257.1745', '2018-04-02 14:16:27'),
(1293, 'ND7N-67-010A(11)-2', '271.592', '2018-04-02 14:16:27'),
(1294, 'ND7P-67-010A(11)-2', '273.2556', '2018-04-02 14:16:27'),
(1295, 'N253-67-050(9)-2-C', '240.6137', '2018-04-02 14:16:28'),
(1296, 'N254-67-050(9)-2-C', '263.8722', '2018-04-02 14:16:28'),
(1297, 'N294-67-050(9)-2-C', '260.4631', '2018-04-02 14:16:28'),
(1298, 'N296-67-050(9)-2-C', '283.7846', '2018-04-02 14:16:28'),
(1299, 'NA4L-67-050B(11)-3-D', '220.5891', '2018-04-02 14:16:28'),
(1300, 'NA4M-67-050B(11)-3-D', '243.5163', '2018-04-02 14:16:28'),
(1301, 'NA4N-67-050B(10)-3-D', '192.7527', '2018-04-02 14:16:28'),
(1302, 'NA4T-67-050A(7)-2-C', '192.2288', '2018-04-02 14:16:28'),
(1303, 'NA4V-67-050A(7)-2-C', '215.6083', '2018-04-02 14:16:28'),
(1304, 'NA5E-67-050(10)-3-D', '202.7818', '2018-04-02 14:16:29'),
(1305, 'NA6K-67-050(10)-3-D', '208.6901', '2018-04-02 14:16:29'),
(1306, 'NC3D-67-050B(10)-3-D', '215.8433', '2018-04-02 14:16:29'),
(1307, 'NC3P-67-050C(12)-3-D', '256.371', '2018-04-02 14:16:29'),
(1308, 'NC3S-67-050B(10)-3-D', '198.6481', '2018-04-02 14:16:29'),
(1309, 'NC3T-67-050B(11)-3-D', '206.5156', '2018-04-02 14:16:29'),
(1310, 'NC3V-67-050B(11)-3-D', '212.4681', '2018-04-02 14:16:29'),
(1311, 'NC3W-67-050B(12)-3-D', '234.4577', '2018-04-02 14:16:29'),
(1312, 'NC4A-67-050B(12)-3-D', '241.0966', '2018-04-02 14:16:30'),
(1313, 'NC4B-67-050B(12)-3-D', '257.8637', '2018-04-02 14:16:30'),
(1314, 'NC4C-67-050B(12)-3-D', '263.9134', '2018-04-02 14:16:30'),
(1315, 'NC4D-67-050B(10)-3-D', '221.4908', '2018-04-02 14:16:30'),
(1316, 'NC4E-67-050B(11)-3-D', '229.748', '2018-04-02 14:16:30'),
(1317, 'NC4F-67-050B(11)-3-D', '235.4063', '2018-04-02 14:16:30'),
(1318, 'NC4G-67-050B(12)-3-D', '257.9097', '2018-04-02 14:16:30'),
(1319, 'NC4H-67-050B(12)-3-D', '264.2445', '2018-04-02 14:16:30'),
(1320, 'NC4J-67-050B(12)-3-D', '281.21', '2018-04-02 14:16:30'),
(1321, 'NC4K-67-050B(12)-3-D', '287.4031', '2018-04-02 14:16:30'),
(1322, 'NC4L-67-050B(12)-3-D', '249.0247', '2018-04-02 14:16:31'),
(1323, 'NC4M-67-050B(12)-3-D', '272.1228', '2018-04-02 14:16:31'),
(1324, 'NC4N-67-050B(12)-3-D', '284.2842', '2018-04-02 14:16:31'),
(1325, 'NC4P-67-050B(12)-3-D', '295.9576', '2018-04-02 14:16:31'),
(1326, 'NC4R-67-050B(12)-3-D', '307.4479', '2018-04-02 14:16:31'),
(1327, 'NC4S-67-050B(12)-3-D', '260.874', '2018-04-02 14:16:31'),
(1328, 'NC4T-67-050B(12)-3-D', '272.2263', '2018-04-02 14:16:31'),
(1329, 'NC4V-67-050B(12)-3-D', '283.6434', '2018-04-02 14:16:31'),
(1330, 'NC4W-67-050C(12)-3-D', '268.203', '2018-04-02 14:16:31'),
(1331, 'NC5A-67-050C(12)-3-D', '279.6314', '2018-04-02 14:16:31'),
(1332, 'NC5B-67-050C(12)-3-D', '291.4246', '2018-04-02 14:16:32'),
(1333, 'NC5C-67-050A(7)-2-C', '198.1495', '2018-04-02 14:16:32'),
(1334, 'NC5D-67-050A(8)-2-C', '205.8964', '2018-04-02 14:16:32'),
(1335, 'NC5E-67-050A(8)-2-C', '211.9669', '2018-04-02 14:16:32'),
(1336, 'NC5F-67-050A(9)-2-C', '232.0861', '2018-04-02 14:16:32'),
(1337, 'NC5G-67-050A(9)-2-C', '238.7796', '2018-04-02 14:16:32'),
(1338, 'NC5H-67-050A(9)-2-C', '253.2396', '2018-04-02 14:16:32'),
(1339, 'NC5J-67-050A(9)-2-C', '259.1579', '2018-04-02 14:16:32'),
(1340, 'NC5K-67-050A(7)-2-C', '221.5257', '2018-04-02 14:16:32'),
(1341, 'NC5L-67-050A(8)-2-C', '228.9728', '2018-04-02 14:16:32'),
(1342, 'NC5M-67-050A(8)-2-C', '235.4012', '2018-04-02 14:16:33'),
(1343, 'NC5N-67-050A(9)-2-C', '255.2968', '2018-04-02 14:16:33'),
(1344, 'NC5P-67-050A(9)-2-C', '261.9606', '2018-04-02 14:16:33'),
(1345, 'NC5R-67-050A(9)-2-C', '276.2351', '2018-04-02 14:16:33'),
(1346, 'NC5S-67-050A(9)-2-C', '282.7108', '2018-04-02 14:16:33'),
(1347, 'NC5T-67-050(9)-2-C', '256.7574', '2018-04-02 14:16:33'),
(1348, 'NC5V-67-050(9)-2-C', '280.2629', '2018-04-02 14:16:33'),
(1349, 'NC5W-67-050A(9)-2-C', '215.824', '2018-04-02 14:16:33'),
(1350, 'NC6A-67-050A(9)-2-C', '222.3925', '2018-04-02 14:16:33'),
(1351, 'NC6B-67-050A(9)-2-C', '236.5256', '2018-04-02 14:16:33'),
(1352, 'NC6C-67-050A(9)-2-C', '242.6111', '2018-04-02 14:16:34'),
(1353, 'NC6D-67-050A(9)-2-C', '238.6804', '2018-04-02 14:16:34'),
(1354, 'NC6E-67-050A(9)-2-C', '245.6708', '2018-04-02 14:16:34'),
(1355, 'NC6F-67-050A(9)-2-C', '259.8712', '2018-04-02 14:16:34'),
(1356, 'NC6G-67-050A(9)-2-C', '266.1638', '2018-04-02 14:16:34'),
(1357, 'NC6H-67-050B(12)-3-D', '218.3969', '2018-04-02 14:16:34'),
(1358, 'NC6J-67-050B(12)-3-D', '224.7967', '2018-04-02 14:16:34'),
(1359, 'NC6K-67-050B(12)-3-D', '241.4737', '2018-04-02 14:16:34'),
(1360, 'NC6L-67-050B(12)-3-D', '247.7276', '2018-04-02 14:16:34'),
(1361, 'NC6M-67-050B(12)-3-D', '241.3929', '2018-04-02 14:16:34'),
(1362, 'NC6N-67-050B(12)-3-D', '248.0147', '2018-04-02 14:16:34'),
(1363, 'NC6P-67-050B(12)-3-D', '264.9662', '2018-04-02 14:16:35'),
(1364, 'NC6R-67-050B(12)-3-D', '271.0934', '2018-04-02 14:16:35'),
(1365, 'NC6S-67-050(11)-3-D', '216.6199', '2018-04-02 14:16:35'),
(1366, 'NC6T-67-050(11)-3-D', '222.5878', '2018-04-02 14:16:35'),
(1367, 'NC6V-67-050(12)-3-D', '244.6788', '2018-04-02 14:16:35'),
(1368, 'NC6W-67-050(12)-3-D', '251.3096', '2018-04-02 14:16:35'),
(1369, 'NC7A-67-050(12)-3-D', '268.1484', '2018-04-02 14:16:36'),
(1370, 'NC7B-67-050(12)-3-D', '274.0331', '2018-04-02 14:16:36'),
(1371, 'NC7C-67-050A(7)-2-C', '184.1359', '2018-04-02 14:16:36'),
(1372, 'NC7D-67-050(8)-2-C', '191.5373', '2018-04-02 14:16:36'),
(1373, 'NC7E-67-050(8)-2-C', '197.9688', '2018-04-02 14:16:36'),
(1374, 'NC7F-67-050(9)-2-C', '217.6304', '2018-04-02 14:16:36'),
(1375, 'NC7G-67-050(9)-2-C', '224.4138', '2018-04-02 14:16:36'),
(1376, 'NC7H-67-050(9)-2-C', '238.492', '2018-04-02 14:16:37'),
(1377, 'NC7J-67-050(9)-2-C', '244.9817', '2018-04-02 14:16:37'),
(1378, 'NC7K-67-050(10)-3-D', '206.1935', '2018-04-02 14:16:37'),
(1379, 'NC7L-67-050(10)-3-D', '212.1512', '2018-04-02 14:16:37'),
(1380, 'NC7M-67-050(11)-3-D', '220.044', '2018-04-02 14:16:37'),
(1381, 'NC7N-67-050(11)-3-D', '226.0226', '2018-04-02 14:16:37'),
(1382, 'NC7P-67-050(12)-3-D', '248.1623', '2018-04-02 14:16:37'),
(1383, 'NC7R-67-050(12)-3-D', '254.8047', '2018-04-02 14:16:37'),
(1384, 'NC7S-67-050(12)-3-D', '271.7724', '2018-04-02 14:16:38'),
(1385, 'NC7T-67-050(12)-3-D', '277.9166', '2018-04-02 14:16:38'),
(1386, 'ND0A-67-050(9)-2-C', '250.4575', '2018-04-02 14:16:38'),
(1387, 'ND0B-67-050(9)-2-C', '273.5388', '2018-04-02 14:16:38'),
(1388, 'ND0D-67-050(7)-2-C', '178.0413', '2018-04-02 14:16:38'),
(1389, 'NE2H-67-050(13)-2-D', '235.9394', '2018-04-02 14:16:38'),
(1390, 'NE2J-67-050(13)-2-D', '247.1141', '2018-04-02 14:16:39'),
(1391, 'NE2K-67-050(13)-2-D', '259.0766', '2018-04-02 14:16:39'),
(1392, 'NE2L-67-050(13)-2-D', '270.3076', '2018-04-02 14:16:39'),
(1393, 'NA4L-67-060B(6)-2', '6.5835', '2018-04-02 14:16:39'),
(1394, 'NC3D-67-060B(6)-2', '10.73', '2018-04-02 14:16:39'),
(1395, 'BJE3-67-SH0(1)-6', '2.7405', '2018-04-02 14:16:39'),
(1396, 'DM0P-67-SH0(19)', '2.6346', '2018-04-02 14:16:39'),
(1397, 'B62S-67-290(1)-7', '8.9628', '2018-04-02 14:16:39'),
(1398, 'B63B-67-290(0)-5', '13.0989', '2018-04-02 14:16:39'),
(1399, 'B63C-67-290(1)-7', '6.8082', '2018-04-02 14:16:39'),
(1400, 'B63C-67-290(1)-8', '6.8082', '2018-04-02 14:16:40'),
(1401, 'B63C-67-SC0(1)-3', '1.4546', '2018-04-02 14:16:40'),
(1402, 'B63D-67-290(1)', '18.2554', '2018-04-02 14:16:40'),
(1403, 'B63K-67-290A(6)-1', '15.7821', '2018-04-02 14:16:40'),
(1404, 'B63M-67-290(1)-7', '3.8338', '2018-04-02 14:16:40'),
(1405, 'B63P-67-290(1)', '10.8025', '2018-04-02 14:16:40'),
(1406, 'B64F-67-290(0)-5', '13.6946', '2018-04-02 14:16:41'),
(1407, 'BHN3-67-SH0A(2)-1', '8.0988', '2018-04-02 14:16:41'),
(1408, 'BHN9-67-290(2)-2', '3.1655', '2018-04-02 14:16:41'),
(1409, 'BHP1-67-290(1)-6', '5.5359', '2018-04-02 14:16:41'),
(1410, 'BHP2-67-290(1)-6', '5.7031', '2018-04-02 14:16:41'),
(1411, 'BHP5-67-SH0(2)-3', '2.121', '2018-04-02 14:16:41'),
(1412, 'BHR1-67-290(1)-2', '12.3658', '2018-04-02 14:16:41'),
(1413, 'BJD5-67-SH0(1)-1', '7.2257', '2018-04-02 14:16:41'),
(1414, 'BJE6-67-SH0(0)-5', '3.0803', '2018-04-02 14:16:41'),
(1415, 'BWJW-67-290(0)-2', '13.6962', '2018-04-02 14:16:42'),
(1416, 'BWKV-67-290(0)-2', '3.8338', '2018-04-02 14:16:42'),
(1417, 'BWKW-67-290(0)-2', '13.1023', '2018-04-02 14:16:42'),
(1418, 'B63C-67-200(13)-1', '25.5091', '2018-04-02 14:16:42'),
(1419, 'BABD-67-200(11)-5', '19.372', '2018-04-02 14:16:42'),
(1420, 'BABE-67-200(11)-5', '22.5341', '2018-04-02 14:16:42'),
(1421, 'BABF-67-200(11)-5', '22.9014', '2018-04-02 14:16:42'),
(1422, 'BAEK-67-200(7)-4', '23.0839', '2018-04-02 14:16:43'),
(1423, 'BAER-67-200(11)-5', '18.0988', '2018-04-02 14:16:43'),
(1424, 'BALE-67-200(7)-4', '19.9411', '2018-04-02 14:16:43'),
(1425, 'BALK-67-200(7)-4', '18.4479', '2018-04-02 14:16:43'),
(1426, 'BALM-67-200(7)-4', '21.7291', '2018-04-02 14:16:43'),
(1427, 'BALV-67-200(11)-5', '20.567', '2018-04-02 14:16:43'),
(1428, 'BALW-67-200(15)-2', '26.205', '2018-04-02 14:16:43'),
(1429, 'BHV6-67-200A(8)-4', '18.3083', '2018-04-02 14:16:43'),
(1430, 'BHV7-67-200A(8)-4', '21.6278', '2018-04-02 14:16:44'),
(1431, 'BSR2-67-200(11)-5', '21.5541', '2018-04-02 14:16:44'),
(1432, 'BSR7-67-200(11)-5', '21.6472', '2018-04-02 14:16:44'),
(1433, 'BSR8-67-200(11)-5', '18.3843', '2018-04-02 14:16:44'),
(1434, 'BSR9-67-200(11)-5', '21.54', '2018-04-02 14:16:44'),
(1435, 'B62S-67-190(4)-4', '29.6935', '2018-04-02 14:16:44'),
(1436, 'B63C-67-190(10)-1', '33.7063', '2018-04-02 14:16:44'),
(1437, 'B63E-67-190(4)-4', '26.3475', '2018-04-02 14:16:44'),
(1438, 'BABD-67-190A(2)-2', '25.8212', '2018-04-02 14:16:44'),
(1439, 'BABE-67-190A(2)-2', '28.9419', '2018-04-02 14:16:45'),
(1440, 'BABF-67-190(1)-3', '26.969', '2018-04-02 14:16:45'),
(1441, 'BABT-67-190(1)-3', '26.46', '2018-04-02 14:16:45'),
(1442, 'BABV-67-190(1)-3', '29.6264', '2018-04-02 14:16:45'),
(1443, 'BAEK-67-190A(6)-4', '28.9363', '2018-04-02 14:16:45'),
(1444, 'BAER-67-190A(4)-1', '26.8359', '2018-04-02 14:16:45'),
(1445, 'BAKT-67-190A(6)-4', '26.3475', '2018-04-02 14:16:45'),
(1446, 'BAKV-67-190A(6)-4', '29.6935', '2018-04-02 14:16:45'),
(1447, 'BALE-67-190A(6)-4', '25.6489', '2018-04-02 14:16:46'),
(1448, 'BALK-67-190A(6)-4', '26.592', '2018-04-02 14:16:46'),
(1449, 'BALM-67-190A(6)-4', '29.9377', '2018-04-02 14:16:46'),
(1450, 'BALW-67-190(1)-3', '30.1504', '2018-04-02 14:16:46'),
(1451, 'BBJS-67-190(4)-4', '29.4079', '2018-04-02 14:16:46'),
(1452, 'BBJT-67-190(11)-1', '33.4209', '2018-04-02 14:16:46'),
(1453, 'BSR2-67-190A(4)-1', '30.0167', '2018-04-02 14:16:46'),
(1454, 'BSR7-67-190A(4)-1', '30.2629', '2018-04-02 14:16:46'),
(1455, 'BSR8-67-190A(4)-1', '26.9716', '2018-04-02 14:16:46'),
(1456, 'BSR9-67-190A(4)-1', '30.1524', '2018-04-02 14:16:47'),
(1457, 'B54K-67-060C(11)-1', '25.2', '2018-04-02 14:16:47'),
(1458, 'B54L-67-060C(11)-1', '28.549', '2018-04-02 14:16:47'),
(1459, 'B54M-67-060C(11)-1', '24.8342', '2018-04-02 14:16:47'),
(1460, 'B54N-67-060C(11)-1', '27.9881', '2018-04-02 14:16:47'),
(1461, 'B62T-67-060(18)-2', '29.3301', '2018-04-02 14:16:47'),
(1462, 'B63B-67-060(18)-2', '32.9816', '2018-04-02 14:16:47'),
(1463, 'B63C-67-060(12)-1', '28.206', '2018-04-02 14:16:47'),
(1464, 'B63D-67-060(18)-2', '29.694', '2018-04-02 14:16:48'),
(1465, 'B63E-67-060(12)-1', '25.0523', '2018-04-02 14:16:48'),
(1466, 'B63F-67-060(18)-2', '32.6167', '2018-04-02 14:16:48'),
(1467, 'B64K-67-060(12)-1', '28.7671', '2018-04-02 14:16:48'),
(1468, 'BHN1-67-060A(6)-6', '21.5891', '2018-04-02 14:16:48'),
(1469, 'BHN9-67-060A(17)-2', '29.3534', '2018-04-02 14:16:48'),
(1470, 'BHP1-67-060A(17)-2', '32.6409', '2018-04-02 14:16:48'),
(1471, 'BHP2-67-060A(17)-2', '25.8169', '2018-04-02 14:16:48'),
(1472, 'BHP3-67-060(17)-2', '28.3578', '2018-04-02 14:16:48'),
(1473, 'BHS7-67-060A(17)-2', '25.4514', '2018-04-02 14:16:48'),
(1474, 'BHT1-67-060A(17)-2', '27.9912', '2018-04-02 14:16:48'),
(1475, 'BHT9-67-060A(17)-2', '25.4523', '2018-04-02 14:16:49'),
(1476, 'BHV3-67-060A(17)-2', '27.9923', '2018-04-02 14:16:49'),
(1477, 'BJG8-67-060A(17)-2', '28.9883', '2018-04-02 14:16:49'),
(1478, 'BJG9-67-060A(17)-2', '32.2748', '2018-04-02 14:16:49'),
(1479, 'BPS4-67-060(17)-2', '28.9894', '2018-04-02 14:16:49'),
(1480, 'BPS5-67-060(17)-2', '32.2763', '2018-04-02 14:16:49'),
(1481, 'BRL6-67-060C(11)-1', '23.2989', '2018-04-02 14:16:49'),
(1482, 'BRL7-67-060C(11)-1', '19.1184', '2018-04-02 14:16:49'),
(1483, 'BRL8-67-060C(11)-1', '20.6652', '2018-04-02 14:16:49'),
(1484, 'BRL9-67-060C(11)-1', '23.9836', '2018-04-02 14:16:49'),
(1485, 'BRM8-67-060C(11)-1', '22.3784', '2018-04-02 14:16:50'),
(1486, 'BRM9-67-060C(11)-1', '26.4586', '2018-04-02 14:16:50'),
(1487, 'B63C-67-210A(3)-2', '14.1242', '2018-04-02 14:16:50'),
(1488, 'B63C-67-220A(3)-2', '14.0107', '2018-04-02 14:16:50'),
(1489, 'BABD-67-210A(3)-2', '15.0654', '2018-04-02 14:16:50'),
(1490, 'BABD-67-220A(3)-2', '14.9951', '2018-04-02 14:16:50'),
(1491, 'BALE-67-210A(3)-2', '15.328', '2018-04-02 14:16:50'),
(1492, 'BALE-67-220A(3)-2', '15.2512', '2018-04-02 14:16:50'),
(1493, 'BALK-67-210A(3)-2', '14.3542', '2018-04-02 14:16:50'),
(1494, 'BALK-67-220A(3)-2', '14.2326', '2018-04-02 14:16:50'),
(1495, 'BHN9-67-210(3)-8', '14.0386', '2018-04-02 14:16:51'),
(1496, 'BHN9-67-220(3)-8', '14.0029', '2018-04-02 14:16:51'),
(1497, 'B62T-67-100(4)-2', '13.3768', '2018-04-02 14:16:51'),
(1498, 'B63B-67-100(4)-2', '8.0892', '2018-04-02 14:16:51'),
(1499, 'B63D-67-100(4)-2', '6.2619', '2018-04-02 14:16:51'),
(1500, 'B63F-67-100(4)-2', '13.3859', '2018-04-02 14:16:51'),
(1501, 'BAAN-67-100(4)-2', '16.9989', '2018-04-02 14:16:51'),
(1502, 'BAEK-67-100(6)-1', '14.3074', '2018-04-02 14:16:51'),
(1503, 'BAFN-67-100(4)-2', '17.2834', '2018-04-02 14:16:51'),
(1504, 'BAFR-67-100(7)-1', '14.5787', '2018-04-02 14:16:51'),
(1505, 'BBPN-67-100(9)-1', '14.5697', '2018-04-02 14:16:52'),
(1506, 'BBRJ-67-100(4)-2', '17.2749', '2018-04-02 14:16:52'),
(1507, 'BHN1-67-100A(4)-2', '4.5908', '2018-04-02 14:16:52'),
(1508, 'BHN2-67-100A(4)-2', '6.4249', '2018-04-02 14:16:52'),
(1509, 'BHN3-67-100A(4)-2', '11.8565', '2018-04-02 14:16:52'),
(1510, 'BHN4-67-100A(4)-2', '11.8659', '2018-04-02 14:16:52'),
(1511, 'BHP1-67-100A(6)-3', '7.9607', '2018-04-02 14:16:52'),
(1512, 'BHP2-67-100A(6)-3', '13.3993', '2018-04-02 14:16:52'),
(1513, 'BHP5-67-100A(6)-3', '13.3903', '2018-04-02 14:16:52'),
(1514, 'BWJW-67-100(0)-1', '13.3978', '2018-04-02 14:16:52'),
(1515, 'BWKA-67-100(0)-1', '11.9849', '2018-04-02 14:16:53'),
(1516, 'BWKV-67-100(0)-1', '6.5362', '2018-04-02 14:16:53'),
(1517, 'B62T-67-130(0)-7', '20.2338', '2018-04-02 14:16:53'),
(1518, 'B63D-67-130(2)-7', '21.9197', '2018-04-02 14:16:53'),
(1519, 'B63E-67-130(0)-7', '13.1948', '2018-04-02 14:16:53'),
(1520, 'B63F-67-130(2)-7', '24.4047', '2018-04-02 14:16:53'),
(1521, 'B63G-67-130(1)-7', '30.3253', '2018-04-02 14:16:53'),
(1522, 'B63H-67-130(5)', '15.7391', '2018-04-02 14:16:53'),
(1523, 'B63M-67-130(2)-7', '22.1659', '2018-04-02 14:16:53'),
(1524, 'B63P-67-130(0)-7', '16.6784', '2018-04-02 14:16:54'),
(1525, 'B64E-67-130(0)-7', '10.7029', '2018-04-02 14:16:54'),
(1526, 'B64K-67-130(0)-7', '25.3006', '2018-04-02 14:16:54'),
(1527, 'BABG-67-130(0)-8', '26.7375', '2018-04-02 14:16:54'),
(1528, 'BABH-67-130(0)-8', '19.318', '2018-04-02 14:16:54'),
(1529, 'BABJ-67-130(2)-7', '29.9982', '2018-04-02 14:16:54'),
(1530, 'BABT-67-130(0)-8', '23.1634', '2018-04-02 14:16:54'),
(1531, 'BABV-67-130(2)-7', '28.3733', '2018-04-02 14:16:54'),
(1532, 'BAES-67-130(2)-7', '23.8737', '2018-04-02 14:16:54'),
(1533, 'BAET-67-130(0)-8', '23.233', '2018-04-02 14:16:54'),
(1534, 'BAFA-67-130(1)-8', '12.2237', '2018-04-02 14:16:55'),
(1535, 'BAKS-67-130(4)-1', '18.8398', '2018-04-02 14:16:55'),
(1536, 'BAKT-67-130(0)-7', '21.3735', '2018-04-02 14:16:55'),
(1537, 'BALK-67-130(0)-7', '18.3851', '2018-04-02 14:16:55'),
(1538, 'BALL-67-130(0)-7', '22.4021', '2018-04-02 14:16:55'),
(1539, 'BALV-67-130(0)-8', '15.5077', '2018-04-02 14:16:55'),
(1540, 'BALW-67-130(0)-8', '19.9166', '2018-04-02 14:16:55'),
(1541, 'BAMA-67-130(1)-8', '23.0608', '2018-04-02 14:16:55'),
(1542, 'BAMB-67-130(2)-7', '26.3731', '2018-04-02 14:16:55'),
(1543, 'BAMD-67-130(2)-7', '26.9193', '2018-04-02 14:16:56'),
(1544, 'BAMF-67-130(2)-7', '30.3696', '2018-04-02 14:16:56'),
(1545, 'BBJS-67-130(3)-3', '16.6784', '2018-04-02 14:16:56'),
(1546, 'BRP2-67-130(3)-3', '24.4047', '2018-04-02 14:16:56'),
(1547, 'BSR4-67-130(2)-7', '25.9156', '2018-04-02 14:16:56'),
(1548, 'BSR6-67-130(2)-7', '28.9506', '2018-04-02 14:16:56'),
(1549, 'KD62-67-SH0(2)-7', '1.7914', '2018-04-02 14:16:56'),
(1550, 'KA0G-67-100A(1)-1', '10.2553', '2018-04-02 14:16:57'),
(1551, 'KA0H-67-100A(1)-1', '14.4317', '2018-04-02 14:16:57'),
(1552, 'KA0K-67-100A(1)-1', '12.2969', '2018-04-02 14:16:57'),
(1553, 'KA0M-67-100A(1)-1', '16.5137', '2018-04-02 14:16:57'),
(1554, 'G46C-67-290(1)-1', '9.2366', '2018-04-02 14:16:57'),
(1555, 'G46E-67-290(1)-1', '8.23', '2018-04-02 14:16:57'),
(1556, 'G48V-67-290(1)-4', '4.8043', '2018-04-02 14:16:57'),
(1557, 'G48W-67-290A(2)-2', '4.4088', '2018-04-02 14:16:57'),
(1558, 'G52M-67-290(6)-1', '19.9771', '2018-04-02 14:16:58'),
(1559, 'G52N-67-290(6)-1', '16.9731', '2018-04-02 14:16:58'),
(1560, 'G52S-67-290A(8)', '28.6695', '2018-04-02 14:16:58'),
(1561, 'G53E-67-SH0A(1)', '6.2169', '2018-04-02 14:16:58'),
(1562, 'GBEF-67-290(5)', '4.9778', '2018-04-02 14:16:58'),
(1563, 'GBEF-67-SH0(2)', '6.7138', '2018-04-02 14:16:58'),
(1564, 'GBFN-67-290(5)', '6.5891', '2018-04-02 14:16:58'),
(1565, 'GBFN-67-SH0A(2)', '2.9725', '2018-04-02 14:16:59'),
(1566, 'GBFP-67-SH0A(2)', '5.9996', '2018-04-02 14:16:59'),
(1567, 'GBFS-67-290(2)', '14.9258', '2018-04-02 14:16:59'),
(1568, 'GBFT-67-290(2)', '13.9976', '2018-04-02 14:16:59'),
(1569, 'GBFV-67-290(6)-1', '18.3528', '2018-04-02 14:16:59'),
(1570, 'GBJD-67-290(4)', '3.9313', '2018-04-02 14:16:59'),
(1571, 'GBJE-67-290A(8)', '14.8888', '2018-04-02 14:16:59'),
(1572, 'GBJS-67-290(5)', '3.7291', '2018-04-02 14:17:00'),
(1573, 'GBJW-67-290(5)', '5.4482', '2018-04-02 14:17:00'),
(1574, 'GBWJ-67-290(6)-1', '22.03', '2018-04-02 14:17:00'),
(1575, 'GBWK-67-290(6)-1', '15.1161', '2018-04-02 14:17:00'),
(1576, 'GBWL-67-290(6)-1', '18.9994', '2018-04-02 14:17:00'),
(1577, 'GBWM-67-290(4)', '3.1562', '2018-04-02 14:17:01'),
(1578, 'GCAF-67-SH0A(1)', '4.8526', '2018-04-02 14:17:01'),
(1579, 'GCCC-67-290(6)-1', '8.2616', '2018-04-02 14:17:01'),
(1580, 'GCCD-67-290(6)-1', '7.9571', '2018-04-02 14:17:01'),
(1581, 'GHR5-67-290(2)-4', '5.9895', '2018-04-02 14:17:01'),
(1582, 'GHR9-67-290(2)-4', '5.8223', '2018-04-02 14:17:01'),
(1583, 'GMC8-67-290(1)-2', '14.6229', '2018-04-02 14:17:01'),
(1584, 'GMD7-67-290(1)-3', '14.7744', '2018-04-02 14:17:01'),
(1585, 'GRG1-67-SH0(17)-1', '3.2265', '2018-04-02 14:17:02'),
(1586, 'GRL6-67-SC0(1)-3', '1.3598', '2018-04-02 14:17:02'),
(1587, 'GRM8-67-290(0)-4', '7.1939', '2018-04-02 14:17:02'),
(1588, 'GRM9-67-290A(2)-2', '6.8028', '2018-04-02 14:17:02'),
(1589, 'GSH7-67-SH0A(1)', '7.97', '2018-04-02 14:17:02'),
(1590, 'GSH8-67-SH0A(1)', '9.247', '2018-04-02 14:17:02'),
(1591, 'G46C-67-200A(6)-1', '22.8485', '2018-04-02 14:17:02'),
(1592, 'G48V-67-200A(6)-1', '24.4727', '2018-04-02 14:17:03'),
(1593, 'G52N-67-200(7)-2', '26.0483', '2018-04-02 14:17:03'),
(1594, 'G52P-67-200(7)-1', '23.1178', '2018-04-02 14:17:03'),
(1595, 'G52R-67-200(7)-2', '29.7622', '2018-04-02 14:17:03'),
(1596, 'GBEF-67-200(6)-2', '32.8024', '2018-04-02 14:17:03'),
(1597, 'GBEG-67-200(5)-2', '17.9525', '2018-04-02 14:17:03'),
(1598, 'GBJC-67-200(7)-2', '28.6972', '2018-04-02 14:17:03'),
(1599, 'GBJE-67-200(6)-2', '29.9889', '2018-04-02 14:17:03'),
(1600, 'GBJW-67-200(6)-2', '27.3731', '2018-04-02 14:17:03'),
(1601, 'GBKT-67-200(7)-2', '26.0634', '2018-04-02 14:17:04'),
(1602, 'GBVG-67-200(7)-1', '36.6589', '2018-04-02 14:17:04'),
(1603, 'GBVN-67-200(7)-1', '33.7735', '2018-04-02 14:17:04'),
(1604, 'GBVP-67-200(7)-2', '29.08', '2018-04-02 14:17:04'),
(1605, 'GBVR-67-200(8)-1', '32.8774', '2018-04-02 14:17:04'),
(1606, 'GCAG-67-200(6)-2', '27.5088', '2018-04-02 14:17:04'),
(1607, 'GCAH-67-200(6)-2', '30.1052', '2018-04-02 14:17:04'),
(1608, 'GCAJ-67-200(8)-1', '31.2239', '2018-04-02 14:17:04'),
(1609, 'GCAK-67-200(8)-1', '33.9', '2018-04-02 14:17:05'),
(1610, 'GCBE-67-200(7)-2', '32.4923', '2018-04-02 14:17:05'),
(1611, 'GCBL-67-200(9)-1', '31.0882', '2018-04-02 14:17:05'),
(1612, 'GCCD-67-200(7)-2', '26.3167', '2018-04-02 14:17:05'),
(1613, 'GCCE-67-200(10)', '29.7785', '2018-04-02 14:17:05'),
(1614, 'GCCF-67-200(10)', '30.0322', '2018-04-02 14:17:05'),
(1615, 'GMA4-67-200A(7)-1', '21.7167', '2018-04-02 14:17:05'),
(1616, 'GMA5-67-200A(7)-1', '25.0162', '2018-04-02 14:17:05'),
(1617, 'GMC8-67-200A(6)-1', '25.0823', '2018-04-02 14:17:05'),
(1618, 'GMD9-67-200A(7)-1', '25.1519', '2018-04-02 14:17:05'),
(1619, 'GMN4-67-200A(7)-1', '26.9806', '2018-04-02 14:17:06'),
(1620, 'GMP6-67-200A(6)-1', '24.9466', '2018-04-02 14:17:06'),
(1621, 'GMV7-67-200A(7)-1', '24.7791', '2018-04-02 14:17:06'),
(1622, 'GNR7-67-200A(6)-1', '24.4874', '2018-04-02 14:17:06'),
(1623, 'GPN2-67-200A(7)-1', '18.7805', '2018-04-02 14:17:06'),
(1624, 'G44N-V7-375(4)-8', '40.9613', '2018-04-02 14:17:06'),
(1625, 'G46C-67-190B(11)-1', '31.6469', '2018-04-02 14:17:06'),
(1626, 'G48V-67-190A(11)-1', '30.5498', '2018-04-02 14:17:06'),
(1627, 'G52N-67-190(7)-2', '31.6613', '2018-04-02 14:17:06'),
(1628, 'G52P-67-190(7)-1', '32.2577', '2018-04-02 14:17:06'),
(1629, 'G52R-67-190(7)-2', '35.3826', '2018-04-02 14:17:06'),
(1630, 'GBEF-67-190(6)-2', '36.5363', '2018-04-02 14:17:06'),
(1631, 'GBEG-67-190(9)-2', '22.9087', '2018-04-02 14:17:07'),
(1632, 'GBJC-67-190(7)-2', '34.738', '2018-04-02 14:17:07'),
(1633, 'GBJE-67-190(6)-2', '33.938', '2018-04-02 14:17:07'),
(1634, 'GBJW-67-190(6)-2', '32.1464', '2018-04-02 14:17:07'),
(1635, 'GBKT-67-190(7)-2', '32.1329', '2018-04-02 14:17:07'),
(1636, 'GBVG-67-190(7)-1', '39.4268', '2018-04-02 14:17:07'),
(1637, 'GBVN-67-190(7)-1', '36.6781', '2018-04-02 14:17:07'),
(1638, 'GBVP-67-190(7)-2', '34.8737', '2018-04-02 14:17:07'),
(1639, 'GBVR-67-190(8)-1', '38.5957', '2018-04-02 14:17:07'),
(1640, 'GCAG-67-190(6)-2', '32.2821', '2018-04-02 14:17:07'),
(1641, 'GCAH-67-190(6)-2', '34.7452', '2018-04-02 14:17:07'),
(1642, 'GCAJ-67-190(8)-1', '36.0035', '2018-04-02 14:17:08'),
(1643, 'GCAK-67-190(8)-1', '38.4666', '2018-04-02 14:17:08'),
(1644, 'GCBE-67-190(7)-2', '38.46', '2018-04-02 14:17:08'),
(1645, 'GCBM-67-190(6)-2', '32.3937', '2018-04-02 14:17:08'),
(1646, 'GCBN-67-190(9)', '35.8678', '2018-04-02 14:17:08'),
(1647, 'GCBP-67-190(9)', '36.1152', '2018-04-02 14:17:08'),
(1648, 'GCCD-67-190(7)-2', '31.8843', '2018-04-02 14:17:08'),
(1649, 'GCCF-67-190(7)-2', '32.1394', '2018-04-02 14:17:08'),
(1650, 'GCCG-67-190(10)', '35.8543', '2018-04-02 14:17:08'),
(1651, 'GCCH-67-190(10)', '35.6058', '2018-04-02 14:17:09'),
(1652, 'GCCJ-67-190(10)', '35.8613', '2018-04-02 14:17:09'),
(1653, 'GLW3-67-190D(19)-1', '30.3678', '2018-04-02 14:17:09'),
(1654, 'GMA4-67-190C(13)-1', '28.3379', '2018-04-02 14:17:09'),
(1655, 'GMA5-67-190C(13)-1', '31.4234', '2018-04-02 14:17:09'),
(1656, 'GMP2-67-190D(13)-1', '34.0076', '2018-04-02 14:17:09'),
(1657, 'GMP6-67-190C(11)-1', '31.1708', '2018-04-02 14:17:09'),
(1658, 'GMV7-67-190C(13)-1', '31.0506', '2018-04-02 14:17:09'),
(1659, 'GNR7-67-190C(11)-1', '30.4956', '2018-04-02 14:17:09'),
(1660, 'GNR8-67-190C(11)-1', '30.7452', '2018-04-02 14:17:10'),
(1661, 'GPN2-67-190B(13)-1', '23.5892', '2018-04-02 14:17:10'),
(1662, 'GRK7-67-190A(13)-1', '31.559', '2018-04-02 14:17:10'),
(1663, 'GRM1-67-190A(13)-1', '31.4234', '2018-04-02 14:17:10'),
(1664, 'GRM9-67-190A(13)-1', '28.4396', '2018-04-02 14:17:10'),
(1665, 'G46C-67-060A(6)-2', '30.0708', '2018-04-02 14:17:10'),
(1666, 'G46E-67-060A(18)-3', '37.8802', '2018-04-02 14:17:10'),
(1667, 'G46F-67-060A(18)-3', '35.873', '2018-04-02 14:17:10'),
(1668, 'G46M-67-060(18)-3', '36.2432', '2018-04-02 14:17:10'),
(1669, 'G47B-67-060A(6)-2', '29.7163', '2018-04-02 14:17:10'),
(1670, 'G47F-67-060A(18)-3', '37.5108', '2018-04-02 14:17:10'),
(1671, 'G52M-67-060(7)', '38.01', '2018-04-02 14:17:10'),
(1672, 'G52N-67-060(7)-1', '39.1964', '2018-04-02 14:17:10'),
(1673, 'G52P-67-060(7)', '37.5635', '2018-04-02 14:17:11'),
(1674, 'G52R-67-060(7)-1', '38.7501', '2018-04-02 14:17:11'),
(1675, 'G52S-67-060(7)-1', '37.9819', '2018-04-02 14:17:11'),
(1676, 'G52T-67-060(7)-1', '37.5352', '2018-04-02 14:17:11'),
(1677, 'G53C-67-060(8)-1', '24.7379', '2018-04-02 14:17:11'),
(1678, 'G53D-67-060(8)-1', '24.3158', '2018-04-02 14:17:11'),
(1679, 'G53E-67-060(8)-1', '23.4079', '2018-04-02 14:17:11'),
(1680, 'G53F-67-060(8)-1', '22.9878', '2018-04-02 14:17:11'),
(1681, 'GBEF-67-060(8)-1', '17.993', '2018-04-02 14:17:11'),
(1682, 'GBFN-67-060(8)-1', '22.4856', '2018-04-02 14:17:11'),
(1683, 'GBFS-67-060(8)-1', '19.049', '2018-04-02 14:17:11'),
(1684, 'GBFT-67-060(7)-1', '32.26', '2018-04-02 14:17:12'),
(1685, 'GBFV-67-060(7)-1', '37.5646', '2018-04-02 14:17:12'),
(1686, 'GBFW-67-060(8)-1', '19.0491', '2018-04-02 14:17:12'),
(1687, 'GBGA-67-060A(10)', '31.1241', '2018-04-02 14:17:12'),
(1688, 'GBGR-67-060(7)-1', '32.706', '2018-04-02 14:17:12'),
(1689, 'GBJC-67-060(7)-1', '36.6391', '2018-04-02 14:17:12'),
(1690, 'GBJD-67-060(8)-1', '23.6319', '2018-04-02 14:17:12'),
(1691, 'GBJS-67-060(7)-1', '36.3226', '2018-04-02 14:17:12'),
(1692, 'GBJT-67-060(8)-1', '23.2118', '2018-04-02 14:17:12'),
(1693, 'GBKR-67-060(8)-1', '18.2226', '2018-04-02 14:17:12'),
(1694, 'GBKT-67-060(8)-1', '19.4688', '2018-04-02 14:17:12'),
(1695, 'GBKV-67-060(8)-1', '17.8296', '2018-04-02 14:17:13'),
(1696, 'GBVP-67-060A(10)', '36.489', '2018-04-02 14:17:13'),
(1697, 'GBVR-67-060A(10)', '32.3628', '2018-04-02 14:17:13'),
(1698, 'GBVS-67-060(7)-1', '38.8691', '2018-04-02 14:17:13'),
(1699, 'GBVT-67-060(8)-1', '37.6485', '2018-04-02 14:17:13'),
(1700, 'GBWD-67-060(8)-1', '24.3161', '2018-04-02 14:17:13'),
(1701, 'GBWE-67-060(9)', '22.988', '2018-04-02 14:17:13'),
(1702, 'GBWJ-67-060(7)-1', '33.4458', '2018-04-02 14:17:13'),
(1703, 'GBWK-67-060(7)-1', '38.7509', '2018-04-02 14:17:13'),
(1704, 'GBWL-67-060(8)-1', '37.5362', '2018-04-02 14:17:13'),
(1705, 'GCAF-67-060(8)-1', '24.3158', '2018-04-02 14:17:14'),
(1706, 'GCAG-67-060(8)-1', '19.0491', '2018-04-02 14:17:14'),
(1707, 'GCAH-67-060(8)-1', '24.3161', '2018-04-02 14:17:14'),
(1708, 'GCAJ-67-060(9)', '22.9878', '2018-04-02 14:17:14'),
(1709, 'GCAK-67-060(9)', '22.988', '2018-04-02 14:17:14'),
(1710, 'GCBE-67-060(7)-1', '33.8917', '2018-04-02 14:17:14'),
(1711, 'GCBF-67-060(7)-1', '38.2115', '2018-04-02 14:17:14'),
(1712, 'GCBL-67-060(7)-1', '37.7658', '2018-04-02 14:17:14'),
(1713, 'GCCC-67-060(7)-1', '37.765', '2018-04-02 14:17:14'),
(1714, 'GCCD-67-060(8)-1', '19.049', '2018-04-02 14:17:14'),
(1715, 'GCCE-67-060(8)-1', '22.0666', '2018-04-02 14:17:15'),
(1716, 'GCCF-67-060(8)-1', '23.2118', '2018-04-02 14:17:15'),
(1717, 'GHP9-67-060B(16)-3', '30.5733', '2018-04-02 14:17:15'),
(1718, 'GHR1-67-060B(16)-3', '32.2091', '2018-04-02 14:17:15'),
(1719, 'GJE8-67-060A(16)-3', '29.6049', '2018-04-02 14:17:15'),
(1720, 'GJF7-67-060A(16)-3', '31.241', '2018-04-02 14:17:15'),
(1721, 'GJN8-67-060A(16)-3', '35.2629', '2018-04-02 14:17:16'),
(1722, 'GJP7-67-060A(16)-3', '36.9003', '2018-04-02 14:17:16'),
(1723, 'GLG9-67-060A(16)-3', '36.5315', '2018-04-02 14:17:16'),
(1724, 'GMA4-67-060(2)-4', '23.9026', '2018-04-02 14:17:16'),
(1725, 'GMA5-67-060A(7)-2', '29.7167', '2018-04-02 14:17:16'),
(1726, 'GMB5-67-060(19)-3', '37.5111', '2018-04-02 14:17:16'),
(1727, 'GMC8-67-060A(6)-2', '29.7152', '2018-04-02 14:17:16'),
(1728, 'GMD7-67-060(18)-3', '37.6811', '2018-04-02 14:17:16'),
(1729, 'GMD9-67-060(2)-4', '23.9018', '2018-04-02 14:17:16'),
(1730, 'GME1-67-060A(7)-2', '29.716', '2018-04-02 14:17:16'),
(1731, 'GMK6-67-060(2)-4', '23.9011', '2018-04-02 14:17:16'),
(1732, 'GMN3-67-060(3)-4', '22.9348', '2018-04-02 14:17:17'),
(1733, 'GMN4-67-060(3)-4', '27.3298', '2018-04-02 14:17:17'),
(1734, 'GMN5-67-060(3)-4', '28.6857', '2018-04-02 14:17:17'),
(1735, 'GMS1-67-060(4)-3', '24.255', '2018-04-02 14:17:17'),
(1736, 'GMS2-67-060(4)-3', '28.3345', '2018-04-02 14:17:17'),
(1737, 'GNT1-67-060(20)-3', '31.448', '2018-04-02 14:17:17'),
(1738, 'GRE5-67-060(20)-3', '34.8943', '2018-04-02 14:17:17'),
(1739, 'G44A-67-210A(9)-1-P', '15.0595', '2018-04-02 14:17:17'),
(1740, 'G44A-67-220A(9)-1-P', '15.0634', '2018-04-02 14:17:18'),
(1741, 'G44N-67-210(6)-6-P', '14.469', '2018-04-02 14:17:18'),
(1742, 'G44N-67-220(6)-7-P', '14.7563', '2018-04-02 14:17:18'),
(1743, 'G48J-67-210A(9)-1-P', '15.9619', '2018-04-02 14:17:18'),
(1744, 'G48J-67-220A(9)-1-P', '15.9652', '2018-04-02 14:17:18'),
(1745, 'G48W-67-210(7)-3-P', '15.7568', '2018-04-02 14:17:18'),
(1746, 'G48W-67-220(7)-4-P', '16.0444', '2018-04-02 14:17:18'),
(1747, 'G52D-67-210(4)-2', '18.2427', '2018-04-02 14:17:18'),
(1748, 'G52D-67-220(4)-2', '18.2453', '2018-04-02 14:17:18'),
(1749, 'G52E-67-210(4)-1', '16.1653', '2018-04-02 14:17:18'),
(1750, 'G52E-67-220(4)-1', '16.1681', '2018-04-02 14:17:19'),
(1751, 'G52N-67-210(2)-3', '17.5305', '2018-04-02 14:17:19'),
(1752, 'G52N-67-220(2)-3', '18.1782', '2018-04-02 14:17:19'),
(1753, 'G52P-67-210(2)-2', '15.4881', '2018-04-02 14:17:19'),
(1754, 'G52P-67-220(2)-2', '16.0659', '2018-04-02 14:17:19'),
(1755, 'GBEF-67-210(4)-2', '18.5221', '2018-04-02 14:17:19'),
(1756, 'GBEF-67-220(4)-2', '18.5244', '2018-04-02 14:17:19'),
(1757, 'GBFT-67-210(2)-3', '17.8002', '2018-04-02 14:17:20'),
(1758, 'GBFT-67-220(2)-3', '18.4509', '2018-04-02 14:17:20'),
(1759, 'GBFW-67-210(4)-2', '18.8178', '2018-04-02 14:17:20'),
(1760, 'GBFW-67-220(4)-2', '18.8199', '2018-04-02 14:17:20'),
(1761, 'GBGA-67-210(2)-3', '18.0855', '2018-04-02 14:17:20'),
(1762, 'GBGA-67-220(2)-3', '18.7397', '2018-04-02 14:17:20'),
(1763, 'GHK1-67-210A(9)-1-P', '16.2307', '2018-04-02 14:17:20'),
(1764, 'GHK1-67-220A(9)-1-P', '16.2346', '2018-04-02 14:17:20'),
(1765, 'GHP9-67-210(6)-6-P', '16.0214', '2018-04-02 14:17:20'),
(1766, 'GHP9-67-220(6)-7-P', '16.3091', '2018-04-02 14:17:20'),
(1767, 'GJS1-67-210A(9)-1-P', '15.9616', '2018-04-02 14:17:21'),
(1768, 'GJS1-67-220A(9)-1-P', '15.9652', '2018-04-02 14:17:21'),
(1769, 'GLG9-67-210(6)-6-P', '15.7562', '2018-04-02 14:17:21'),
(1770, 'GLG9-67-220(6)-7-P', '16.0441', '2018-04-02 14:17:21'),
(1771, 'G46E-67-100B(3)', '16.2763', '2018-04-02 14:17:21'),
(1772, 'GBEF-67-100(4)-1', '8.7149', '2018-04-02 14:17:21'),
(1773, 'GBFN-67-100(4)-1', '14.1671', '2018-04-02 14:17:21'),
(1774, 'GBFS-67-100(4)-1', '16.7782', '2018-04-02 14:17:21'),
(1775, 'GBFT-67-100(2)-1', '8.5703', '2018-04-02 14:17:21'),
(1776, 'GBFV-67-100(2)-1', '14.0236', '2018-04-02 14:17:22'),
(1777, 'GBFW-67-100(4)-1', '11.1283', '2018-04-02 14:17:22'),
(1778, 'GBGA-67-100(2)-1', '11.0333', '2018-04-02 14:17:22'),
(1779, 'GBJD-67-100(4)-1', '18.896', '2018-04-02 14:17:22'),
(1780, 'GBJT-67-100(4)-1', '11.7032', '2018-04-02 14:17:22'),
(1781, 'GBVP-67-100(2)-1', '16.4102', '2018-04-02 14:17:22'),
(1782, 'GBVR-67-100(2)-1', '21.1169', '2018-04-02 14:17:22'),
(1783, 'GBWD-67-100(4)-1', '16.5035', '2018-04-02 14:17:22'),
(1784, 'GBWE-67-100(4)-1', '21.1709', '2018-04-02 14:17:22'),
(1785, 'GBWJ-67-100(2)-1', '18.8035', '2018-04-02 14:17:23'),
(1786, 'GBWK-67-100(2)-1', '16.6849', '2018-04-02 14:17:23'),
(1787, 'GBWL-67-100(2)-1', '21.4042', '2018-04-02 14:17:23'),
(1788, 'GCAF-67-100(4)-1', '21.4581', '2018-04-02 14:17:23'),
(1789, 'GHK1-67-100A(11)', '6.5992', '2018-04-02 14:17:23'),
(1790, 'GHK3-67-100B(11)', '12.2773', '2018-04-02 14:17:23'),
(1791, 'GMA5-67-100A(11)', '14.902', '2018-04-02 14:17:23'),
(1792, 'GMB5-67-100A(3)', '10.6628', '2018-04-02 14:17:23'),
(1793, 'GMB6-67-100A(3)', '19.2294', '2018-04-02 14:17:23'),
(1794, 'GMC8-67-100A(11)', '8.925', '2018-04-02 14:17:23'),
(1795, 'GMC9-67-100A(11)', '14.6345', '2018-04-02 14:17:24'),
(1796, 'GMD7-67-100B(3)', '13.3414', '2018-04-02 14:17:24'),
(1797, 'GMD8-67-100B(3)', '18.9576', '2018-04-02 14:17:24'),
(1798, 'GMS1-67-100A(11)', '9.4948', '2018-04-02 14:17:24'),
(1799, 'GRK6-67-100A(11)', '16.2566', '2018-04-02 14:17:24'),
(1800, 'GRM8-67-100A(3)', '17.4297', '2018-04-02 14:17:24'),
(1801, 'GRV1-67-100A(11)', '13.6519', '2018-04-02 14:17:24'),
(1802, 'G48V-67-130A(5)-1', '28.9614', '2018-04-02 14:17:24'),
(1803, 'G48W-67-130A(5)-1', '24.6222', '2018-04-02 14:17:24'),
(1804, 'GBEF-67-130A(8)-2', '27.2335', '2018-04-02 14:17:24'),
(1805, 'GBFN-67-130A(8)-2', '23.5456', '2018-04-02 14:17:25'),
(1806, 'GBFS-67-130(8)-2', '14.8522', '2018-04-02 14:17:25'),
(1807, 'GBFW-67-130(8)-1', '24.1209', '2018-04-02 14:17:25'),
(1808, 'GBGR-67-130(8)-1', '29.8485', '2018-04-02 14:17:25'),
(1809, 'GBJD-67-130A(8)-2', '26.5135', '2018-04-02 14:17:25'),
(1810, 'GBJE-67-130A(8)-2', '29.9768', '2018-04-02 14:17:25'),
(1811, 'GBJS-67-130(6)-2', '12.1447', '2018-04-02 14:17:25'),
(1812, 'GBJW-67-130(6)-2', '20.7864', '2018-04-02 14:17:25'),
(1813, 'GBKR-67-130(7)-1', '18.4958', '2018-04-02 14:17:25'),
(1814, 'GBKT-67-130(7)-1', '24.3316', '2018-04-02 14:17:25'),
(1815, 'GBKV-67-130(7)-1', '27.919', '2018-04-02 14:17:25'),
(1816, 'GBVG-67-130A(8)-2', '30.9046', '2018-04-02 14:17:25'),
(1817, 'GBVH-67-130A(8)-2', '33.7766', '2018-04-02 14:17:26'),
(1818, 'GBVJ-67-130A(8)-2', '26.7169', '2018-04-02 14:17:26'),
(1819, 'GBVL-67-130A(8)-2', '29.7511', '2018-04-02 14:17:26'),
(1820, 'GBWD-67-130(8)-1', '32.3024', '2018-04-02 14:17:26'),
(1821, 'GBWE-67-130(8)-1', '25.9248', '2018-04-02 14:17:26'),
(1822, 'GCAF-67-130(8)-2', '29.6864', '2018-04-02 14:17:26'),
(1823, 'GCAG-67-130(8)-2', '33.2441', '2018-04-02 14:17:26'),
(1824, 'GCAH-67-130(8)-2', '17.7073', '2018-04-02 14:17:26'),
(1825, 'GCAJ-67-130(8)-2', '32.601', '2018-04-02 14:17:26'),
(1826, 'GCAK-67-130(8)-2', '16.5737', '2018-04-02 14:17:26'),
(1827, 'GCAL-67-130(8)-2', '36.2343', '2018-04-02 14:17:26'),
(1828, 'GCAM-67-130(8)-2', '29.4044', '2018-04-02 14:17:27'),
(1829, 'GCAN-67-130(8)-2', '25.3708', '2018-04-02 14:17:27'),
(1830, 'GCAP-67-130(8)-2', '31.536', '2018-04-02 14:17:27'),
(1831, 'GCAR-67-130(8)-2', '35.5948', '2018-04-02 14:17:27'),
(1832, 'GCAS-67-130(8)-2', '32.5327', '2018-04-02 14:17:27'),
(1833, 'GCAT-67-130(8)-2', '19.5693', '2018-04-02 14:17:27'),
(1834, 'GCAV-67-130(8)-2', '28.3334', '2018-04-02 14:17:27'),
(1835, 'GCAW-67-130(8)-2', '38.4563', '2018-04-02 14:17:27'),
(1836, 'GCBA-67-130(8)-2', '34.6234', '2018-04-02 14:17:27'),
(1837, 'GCBL-67-130(6)-2', '23.911', '2018-04-02 14:17:27'),
(1838, 'GCBM-67-130(6)-2', '24.5251', '2018-04-02 14:17:28'),
(1839, 'GCBN-67-130(6)-2', '28.1124', '2018-04-02 14:17:28'),
(1840, 'GCBP-67-130(6)-2', '26.8697', '2018-04-02 14:17:28'),
(1841, 'GCBR-67-130(6)-2', '30.8573', '2018-04-02 14:17:28'),
(1842, 'GCCD-67-130(7)-1', '21.5941', '2018-04-02 14:17:28'),
(1843, 'GCCE-67-130(8)-1', '27.0942', '2018-04-02 14:17:28'),
(1844, 'GCCF-67-130(8)-1', '21.1737', '2018-04-02 14:17:28'),
(1845, 'GCCG-67-130(8)-1', '22.9837', '2018-04-02 14:17:28'),
(1846, 'GCCH-67-130(8)-1', '29.2709', '2018-04-02 14:17:28'),
(1847, 'GMW7-67-130A(8)-1', '27.2904', '2018-04-02 14:17:28'),
(1848, 'GMW9-67-130A(8)-1', '23.8622', '2018-04-02 14:17:28'),
(1849, 'GNA1-67-130A(8)-1', '19.6311', '2018-04-02 14:17:28'),
(1850, 'GNA3-67-130B(9)-1', '26.4993', '2018-04-02 14:17:29'),
(1851, 'GNA4-67-130C(9)-1', '22.2839', '2018-04-02 14:17:29'),
(1852, 'GRG3-67-130A(5)-1', '20.7999', '2018-04-02 14:17:29'),
(1853, 'GRK7-67-130(6)', '27.3428', '2018-04-02 14:17:29'),
(1854, 'GRK8-67-130(6)', '31.6467', '2018-04-02 14:17:29'),
(1855, 'GRK9-67-130C(9)-1', '22.2097', '2018-04-02 14:17:29'),
(1856, 'GRL3-67-130B(9)-1', '27.3496', '2018-04-02 14:17:29'),
(1857, 'GRL5-67-130B(9)-1', '28.0485', '2018-04-02 14:17:30'),
(1858, 'GRL7-67-130A(8)-1', '17.9153', '2018-04-02 14:17:30'),
(1859, 'GRN7-67-130A(8)-1', '25.5302', '2018-04-02 14:17:30'),
(1860, 'GRN8-67-130A(8)-1', '22.6067', '2018-04-02 14:17:30'),
(1861, 'GRP5-67-130C(9)-1', '25.6811', '2018-04-02 14:17:30'),
(1862, 'GRP6-67-130A(8)-1', '28.112', '2018-04-02 14:17:30'),
(1863, 'GRP7-67-130A(8)-1', '26.3144', '2018-04-02 14:17:30'),
(1864, 'GRR1-67-130B(9)-1', '31.0994', '2018-04-02 14:17:30'),
(1865, 'GRR2-67-130B(9)-1', '29.5346', '2018-04-02 14:17:30'),
(1866, 'GRR3-67-130B(9)-1', '35.178', '2018-04-02 14:17:30'),
(1867, 'GRR5-67-130A(6)-1', '13.3458', '2018-04-02 14:17:30'),
(1868, 'GRR6-67-130A(6)-1', '16.8468', '2018-04-02 14:17:30'),
(1869, 'GRR8-67-130A(6)-1', '19.835', '2018-04-02 14:17:31'),
(1870, 'GRS1-67-130A(6)-1', '24.0062', '2018-04-02 14:17:31'),
(1871, 'GRV2-67-130A(8)-1', '15.5901', '2018-04-02 14:17:31'),
(1872, 'GSC2-67-130A(5)-1', '17.9949', '2018-04-02 14:17:31'),
(1873, 'K123-67-290(3)-4', '6.0837', '2018-04-02 14:17:31'),
(1874, 'K128-67-290(2)-3', '4.6849', '2018-04-02 14:17:31'),
(1875, 'K128-67-SH0(15)-1', '3.6196', '2018-04-02 14:17:31'),
(1876, 'K131-66-SH0(0)-2', '3.0459', '2018-04-02 14:17:31'),
(1877, 'K131-67-290(3)-2', '15.609', '2018-04-02 14:17:31'),
(1878, 'K131-V7-295(1)', '17.3697', '2018-04-02 14:17:31'),
(1879, 'K132-67-290(3)-2', '15.2487', '2018-04-02 14:17:32'),
(1880, 'K147-67-290(1)-5', '14.717', '2018-04-02 14:17:32'),
(1881, 'K147-67-SH0A(2)', '7.015', '2018-04-02 14:17:32'),
(1882, 'K148-67-290(2)-3', '6.5873', '2018-04-02 14:17:32'),
(1883, 'K156-67-290A(4)-1', '6.0763', '2018-04-02 14:17:32'),
(1884, 'K157-67-290A(4)-1', '6.0766', '2018-04-02 14:17:32'),
(1885, 'K157-67-SH0(1)', '2.2059', '2018-04-02 14:17:32'),
(1886, 'K230-67-290(0)-1', '12.7875', '2018-04-02 14:17:32'),
(1887, 'K231-67-290(1)-1', '7.8717', '2018-04-02 14:17:32'),
(1888, 'K232-67-290A(6)', '25.7042', '2018-04-02 14:17:32'),
(1889, 'K233-67-290(4)-2', '17.0081', '2018-04-02 14:17:32'),
(1890, 'K262-67-290A(8)', '15.1474', '2018-04-02 14:17:32'),
(1891, 'KB7W-57-X6XB(4)', '3.5275', '2018-04-02 14:17:32'),
(1892, 'KB7W-57-X6XB(4)-1', '3.807', '2018-04-02 14:17:32'),
(1893, 'KB8A-67-SH1(3)-3', '3.0863', '2018-04-02 14:17:32'),
(1894, 'KB9G-67-290(3)-4', '8.232', '2018-04-02 14:17:33'),
(1895, 'KC9E-67-SH1A(1)-2', '2.4873', '2018-04-02 14:17:33'),
(1896, 'KD5L-67-SH0(1)-1', '3.6181', '2018-04-02 14:17:33'),
(1897, 'KD7J-67-290(5)-2', '17.3697', '2018-04-02 14:17:33'),
(1898, 'KD8A-67-290(5)-2', '13.8859', '2018-04-02 14:17:33'),
(1899, 'KD8B-67-290(5)-2', '13.5', '2018-04-02 14:17:33'),
(1900, 'K123-67-200A(11)-2', '25.9565', '2018-04-02 14:17:33'),
(1901, 'K123-67-200A(11)-3', '25.9565', '2018-04-02 14:17:33'),
(1902, 'K131-67-200(11)-3', '27.7894', '2018-04-02 14:17:33'),
(1903, 'K131-67-200(11)-4', '27.7894', '2018-04-02 14:17:33'),
(1904, 'KB7W-67-200B(12)-4', '27.3833', '2018-04-02 14:17:33'),
(1905, 'KB8M-67-200A(12)-4', '23.5952', '2018-04-02 14:17:33'),
(1906, 'KB8N-67-200A(12)-4', '21.7115', '2018-04-02 14:17:33'),
(1907, 'KB8N-67-200A(12)-5', '21.7115', '2018-04-02 14:17:34'),
(1908, 'KB9G-67-200A(11)-3', '26.4494', '2018-04-02 14:17:34'),
(1909, 'KB9G-67-200A(11)-4', '26.4494', '2018-04-02 14:17:34'),
(1910, 'KB9M-67-200(11)-3', '25.9222', '2018-04-02 14:17:34'),
(1911, 'KB9M-67-200(11)-4', '25.9222', '2018-04-02 14:17:34'),
(1912, 'KB9T-67-200(12)-4', '23.086', '2018-04-02 14:17:34'),
(1913, 'KB9T-67-200(12)-5', '23.086', '2018-04-02 14:17:34'),
(1914, 'KC0R-67-200(11)-2', '23.2851', '2018-04-02 14:17:34'),
(1915, 'KC0R-67-200(11)-3', '23.2851', '2018-04-02 14:17:35'),
(1916, 'KD3M-67-200A(12)-4', '25.7256', '2018-04-02 14:17:35'),
(1917, 'KD3M-67-200A(12)-5', '25.7256', '2018-04-02 14:17:35'),
(1918, 'KF1D-67-200A(11)-3', '30.1736', '2018-04-02 14:17:35'),
(1919, 'KF1D-67-200A(11)-4', '30.1736', '2018-04-02 14:17:35'),
(1920, 'KF1H-67-200A(12)-4', '23.2217', '2018-04-02 14:17:35'),
(1921, 'KF1H-67-200A(12)-5', '23.2217', '2018-04-02 14:17:35'),
(1922, 'KL1P-67-200(12)-5', '19.8413', '2018-04-02 14:17:35'),
(1923, 'KL2F-67-200(12)-4', '28.086', '2018-04-02 14:17:36'),
(1924, 'KL2F-67-200(12)-5', '28.0912', '2018-04-02 14:17:36'),
(1925, 'KL2T-67-200(12)-4', '25.7051', '2018-04-02 14:17:36'),
(1926, 'KL2T-67-200(12)-5', '25.7051', '2018-04-02 14:17:36'),
(1927, 'KL3E-67-200(15)-3', '29.9725', '2018-04-02 14:17:36'),
(1928, 'KL3E-67-200(15)-4', '29.9778', '2018-04-02 14:17:36'),
(1929, 'KL4A-67-200(15)-3', '27.7271', '2018-04-02 14:17:36'),
(1930, 'KL4A-67-200(15)-4', '27.7271', '2018-04-02 14:17:36'),
(1931, 'KL4G-67-200(12)-3', '30.5655', '2018-04-02 14:17:36'),
(1932, 'KL4G-67-200(12)-4', '30.5655', '2018-04-02 14:17:37'),
(1933, 'K123-67-190B(13)-4', '31.0973', '2018-04-02 14:17:37'),
(1934, 'K123-67-190B(13)-5', '31.0973', '2018-04-02 14:17:37'),
(1935, 'K131-67-190(13)-4', '29.6823', '2018-04-02 14:17:37'),
(1936, 'K131-67-190(13)-5', '29.6823', '2018-04-02 14:17:37'),
(1937, 'K132-67-190(13)-4', '33.9409', '2018-04-02 14:17:37'),
(1938, 'K132-67-190(13)-5', '33.9409', '2018-04-02 14:17:37'),
(1939, 'K230-67-190(13)-4', '35.2207', '2018-04-02 14:17:37'),
(1940, 'K230-67-190(13)-5', '35.2207', '2018-04-02 14:17:37'),
(1941, 'KB7W-67-190B(12)-2', '33.5166', '2018-04-02 14:17:38'),
(1942, 'KB8M-67-190A(12)-2', '30.4648', '2018-04-02 14:17:38'),
(1943, 'KB9G-67-190A(13)-4', '32.8365', '2018-04-02 14:17:38'),
(1944, 'KB9G-67-190A(13)-5', '32.8417', '2018-04-02 14:17:38'),
(1945, 'KB9N-67-190A(13)-4', '32.3282', '2018-04-02 14:17:38'),
(1946, 'KB9N-67-190A(13)-5', '32.3282', '2018-04-02 14:17:38'),
(1947, 'KB9V-67-190A(12)-2', '30.2222', '2018-04-02 14:17:38'),
(1948, 'KB9V-67-190A(12)-3', '30.2215', '2018-04-02 14:17:38'),
(1949, 'KC0R-67-190A(13)-4', '29.9391', '2018-04-02 14:17:38'),
(1950, 'KC0R-67-190A(13)-5', '29.9391', '2018-04-02 14:17:38'),
(1951, 'KD3F-67-190(12)-2', '31.1129', '2018-04-02 14:17:38'),
(1952, 'KD3F-67-190(12)-3', '31.1124', '2018-04-02 14:17:39'),
(1953, 'KD3M-67-190A(12)-2', '32.6109', '2018-04-02 14:17:39'),
(1954, 'KD3M-67-190A(12)-3', '32.6101', '2018-04-02 14:17:39'),
(1955, 'KF1H-67-190A(12)-2', '30.3579', '2018-04-02 14:17:39'),
(1956, 'KF1H-67-190A(12)-3', '30.3572', '2018-04-02 14:17:39'),
(1957, 'KL1P-67-190(12)-4', '25.2375', '2018-04-02 14:17:39'),
(1958, 'KL2F-67-190(12)-3', '32.1557', '2018-04-02 14:17:39'),
(1959, 'KL2F-67-190(12)-4', '32.1551', '2018-04-02 14:17:39'),
(1960, 'KL2T-67-190(12)-2', '29.7667', '2018-04-02 14:17:39'),
(1961, 'KL2T-67-190(12)-3', '29.7664', '2018-04-02 14:17:40'),
(1962, 'KL3E-67-190(15)-3', '36.6504', '2018-04-02 14:17:40'),
(1963, 'KL3E-67-190(15)-4', '36.6501', '2018-04-02 14:17:40'),
(1964, 'KL4A-67-190(15)-2', '34.3825', '2018-04-02 14:17:40'),
(1965, 'KL4A-67-190(15)-3', '34.3821', '2018-04-02 14:17:40'),
(1966, 'KL4G-67-190(15)-3', '36.9607', '2018-04-02 14:17:40'),
(1967, 'KL4G-67-190(15)-4', '36.9658', '2018-04-02 14:17:40'),
(1968, 'KL5B-67-190(14)-4', '36.5816', '2018-04-02 14:17:40'),
(1969, 'KL5B-67-190(14)-5', '36.5867', '2018-04-02 14:17:40'),
(1970, 'KL6L-67-190(13)-4', '29.1798', '2018-04-02 14:17:40'),
(1971, 'KL6L-67-190(13)-5', '29.1798', '2018-04-02 14:17:40'),
(1972, 'K123-67-060B(15)-4', '37.5962', '2018-04-02 14:17:40'),
(1973, 'K132-67-060(2)-2', '41.1127', '2018-04-02 14:17:40'),
(1974, 'K230-67-060(2)-2', '45.5527', '2018-04-02 14:17:41'),
(1975, 'K231-67-060(4)-2', '60.0013', '2018-04-02 14:17:41'),
(1976, 'K232-67-060(4)-2', '59.9958', '2018-04-02 14:17:41'),
(1977, 'K233-67-060(3)-2', '45.5472', '2018-04-02 14:17:41'),
(1978, 'K262-67-060(16)-4', '38.5263', '2018-04-02 14:17:41'),
(1979, 'K262-67-060(18)', '38.5263', '2018-04-02 14:17:41'),
(1980, 'K263-67-060(16)-4', '54.915', '2018-04-02 14:17:41'),
(1981, 'K263-67-060(18)', '54.7224', '2018-04-02 14:17:41'),
(1982, 'KB7W-67-060A(15)-4', '33.3866', '2018-04-02 14:17:41'),
(1983, 'KB7W-67-060A(18)', '33.3866', '2018-04-02 14:17:41'),
(1984, 'KB8C-67-060A(15)-4', '37.5962', '2018-04-02 14:17:41'),
(1985, 'KB8C-67-060A(18)', '37.5962', '2018-04-02 14:17:42'),
(1986, 'KB8D-67-060A(18)', '50.6582', '2018-04-02 14:17:42'),
(1987, 'KB8F-67-060A(15)-4', '54.0833', '2018-04-02 14:17:42'),
(1988, 'KB8F-67-060A(18)', '53.8907', '2018-04-02 14:17:42'),
(1989, 'KB8M-67-060A(15)-4', '34.2166', '2018-04-02 14:17:42'),
(1990, 'KB8M-67-060A(18)', '34.2166', '2018-04-02 14:17:42'),
(1991, 'KB8N-67-060A(15)-4', '55.3031', '2018-04-02 14:17:42'),
(1992, 'KB8N-67-060A(18)', '55.1105', '2018-04-02 14:17:42'),
(1993, 'KB8R-67-060A(18)', '51.4707', '2018-04-02 14:17:42'),
(1994, 'KB9G-67-060A(15)-4', '33.3866', '2018-04-02 14:17:42'),
(1995, 'KB9G-67-060A(18)', '33.3866', '2018-04-02 14:17:42'),
(1996, 'KB9K-67-060A(15)-4', '34.2167', '2018-04-02 14:17:42'),
(1997, 'KB9K-67-060A(18)', '34.2167', '2018-04-02 14:17:43'),
(1998, 'KB9L-67-060A(15)-4', '39.7214', '2018-04-02 14:17:43'),
(1999, 'KB9L-67-060A(18)', '39.7214', '2018-04-02 14:17:43'),
(2000, 'KB9T-67-060A(18)', '51.4707', '2018-04-02 14:17:43'),
(2001, 'KC0R-67-060A(15)-4', '38.5318', '2018-04-02 14:17:43'),
(2002, 'KC0R-67-060A(18)', '38.5318', '2018-04-02 14:17:43'),
(2003, 'KC9J-67-060A(15)-4', '56.2404', '2018-04-02 14:17:43'),
(2004, 'KC9J-67-060A(18)', '56.0478', '2018-04-02 14:17:43'),
(2005, 'KD4D-67-060A(18)', '51.4707', '2018-04-02 14:17:43'),
(2006, 'KF1F-67-060A(15)-4', '56.048', '2018-04-02 14:17:43'),
(2007, 'KF1F-67-060A(18)', '56.048', '2018-04-02 14:17:43'),
(2008, 'KF1J-67-060A(18)', '38.9126', '2018-04-02 14:17:44'),
(2009, 'KF1K-67-060A(15)-4', '39.7213', '2018-04-02 14:17:44'),
(2010, 'KF1K-67-060A(18)', '39.7213', '2018-04-02 14:17:44'),
(2011, 'KF1R-67-060A(18)', '55.1106', '2018-04-02 14:17:44'),
(2012, 'KF1V-67-060A(15)-4', '50.6583', '2018-04-02 14:17:44'),
(2013, 'KF1V-67-060A(18)', '50.6583', '2018-04-02 14:17:44'),
(2014, 'KF1W-67-060A(18)', '51.4707', '2018-04-02 14:17:44'),
(2015, 'KF2P-67-060A(15)-4', '54.9205', '2018-04-02 14:17:44'),
(2016, 'KF2P-67-060A(18)', '54.7279', '2018-04-02 14:17:44'),
(2017, 'KF2R-67-060A(18)', '38.9126', '2018-04-02 14:17:44'),
(2018, 'KL1P-67-060A(18)', '29.3265', '2018-04-02 14:17:44'),
(2019, 'KL4G-67-060(17)-3', '38.5263', '2018-04-02 14:17:44'),
(2020, 'KL4G-67-060(18)', '38.5263', '2018-04-02 14:17:45'),
(2021, 'KL4H-67-060(17)-3', '54.7224', '2018-04-02 14:17:45'),
(2022, 'KL4H-67-060(18)', '54.7224', '2018-04-02 14:17:45'),
(2023, 'K123-67-210A(8)-3', '16.456', '2018-04-02 14:17:45'),
(2024, 'K123-67-220A(8)-3', '16.1719', '2018-04-02 14:17:45'),
(2025, 'K131-67-210(1)-3', '16.7909', '2018-04-02 14:17:45'),
(2026, 'K131-67-220(1)-3', '16.7274', '2018-04-02 14:17:45'),
(2027, 'K132-67-210(1)-3', '17.8569', '2018-04-02 14:17:45'),
(2028, 'K132-67-220(1)-3', '17.8006', '2018-04-02 14:17:45'),
(2029, 'K230-67-210(1)-3', '17.8567', '2018-04-02 14:17:45'),
(2030, 'K230-67-220(1)-3', '17.8004', '2018-04-02 14:17:45'),
(2031, 'K262-67-210(11)-1', '17.5417', '2018-04-02 14:17:45'),
(2032, 'K262-67-220(11)-1', '17.2566', '2018-04-02 14:17:45'),
(2033, 'KB7W-67-210A(8)-3', '16.8632', '2018-04-02 14:17:46'),
(2034, 'KB7W-67-220A(8)-3', '16.579', '2018-04-02 14:17:46'),
(2035, 'KB8M-67-210(8)-3', '17.5413', '2018-04-02 14:17:46'),
(2036, 'KB8M-67-220(8)-3', '17.2558', '2018-04-02 14:17:46'),
(2037, 'KB8N-67-210(8)-3', '17.8405', '2018-04-02 14:17:46'),
(2038, 'KB8N-67-220(8)-3', '17.555', '2018-04-02 14:17:46'),
(2039, 'KB9H-67-210(8)-3', '18.1229', '2018-04-02 14:17:46'),
(2040, 'KB9H-67-220(8)-3', '17.8372', '2018-04-02 14:17:46'),
(2041, 'K123-67-100A(9)-1', '16.8', '2018-04-02 14:17:46'),
(2042, 'K123-67-100A(9)-2', '16.831', '2018-04-02 14:17:46'),
(2043, 'K131-67-100A(3)-1', '17.7066', '2018-04-02 14:17:46'),
(2044, 'K131-67-100A(3)-2', '17.7376', '2018-04-02 14:17:47'),
(2045, 'KB7W-67-100(9)-1', '12.0922', '2018-04-02 14:17:47'),
(2046, 'KB7W-67-100(9)-2', '12.442', '2018-04-02 14:17:47'),
(2047, 'KB9G-67-100(9)-1', '19.6322', '2018-04-02 14:17:47'),
(2048, 'KB9G-67-100(9)-2', '19.6632', '2018-04-02 14:17:47'),
(2049, 'KB9H-67-100(9)-1', '14.8928', '2018-04-02 14:17:47'),
(2050, 'KB9H-67-100(9)-2', '15.0859', '2018-04-02 14:17:47'),
(2051, 'K123-67-130A(10)-1', '24.5702', '2018-04-02 14:17:47'),
(2052, 'K123-67-130A(10)-2', '24.6665', '2018-04-02 14:17:47'),
(2053, 'K127-67-130A(7)', '30.1531', '2018-04-02 14:17:47'),
(2054, 'K127-67-130A(7)-1', '30.0531', '2018-04-02 14:17:47'),
(2055, 'K128-67-130A(10)-1', '26.6664', '2018-04-02 14:17:47'),
(2056, 'K128-67-130A(10)-2', '26.7633', '2018-04-02 14:17:48'),
(2057, 'K147-67-130A(7)', '32.1785', '2018-04-02 14:17:48'),
(2058, 'K147-67-130A(7)-1', '32.0785', '2018-04-02 14:17:48'),
(2059, 'KB7W-67-130A(9)-1', '19.2921', '2018-04-02 14:17:48'),
(2060, 'KB7W-67-130A(9)-2', '19.3847', '2018-04-02 14:17:48'),
(2061, 'KB8C-67-130A(9)-1', '24.9683', '2018-04-02 14:17:48'),
(2062, 'KB8D-67-130A(9)-1', '29.0784', '2018-04-02 14:17:48'),
(2063, 'KB8E-67-130(9)-2', '25.0021', '2018-04-02 14:17:48'),
(2064, 'KB8F-67-130(9)-1', '28.7977', '2018-04-02 14:17:48'),
(2065, 'KB8F-67-130(9)-2', '28.8897', '2018-04-02 14:17:48'),
(2066, 'KB8M-67-130(9)-2', '14.3644', '2018-04-02 14:17:48'),
(2067, 'KB8N-67-130(9)-2', '28.2494', '2018-04-02 14:17:48'),
(2068, 'KB8P-67-130(9)-2', '30.5386', '2018-04-02 14:17:49'),
(2069, 'KB8T-67-130(9)-2', '18.1847', '2018-04-02 14:17:49'),
(2070, 'KB8V-67-130(9)-2', '33.3752', '2018-04-02 14:17:49'),
(2071, 'KB8W-67-130(9)-1', '35.3698', '2018-04-02 14:17:49'),
(2072, 'KB8W-67-130(9)-2', '35.5617', '2018-04-02 14:17:49'),
(2073, 'KB9A-67-130(9)-1', '11.3715', '2018-04-02 14:17:49'),
(2074, 'KB9A-67-130(9)-2', '11.3715', '2018-04-02 14:17:49'),
(2075, 'KB9J-67-130(10)-1', '18.5371', '2018-04-02 14:17:49'),
(2076, 'KB9J-67-130(10)-2', '18.6309', '2018-04-02 14:17:49'),
(2077, 'KB9M-67-130(10)-1', '20.6217', '2018-04-02 14:17:49'),
(2078, 'KB9M-67-130(10)-2', '20.7155', '2018-04-02 14:17:49'),
(2079, 'KB9V-67-130(9)-1', '14.8878', '2018-04-02 14:17:49'),
(2080, 'KB9V-67-130(9)-2', '15.3731', '2018-04-02 14:17:50'),
(2081, 'KB9W-67-130(9)-1', '17.307', '2018-04-02 14:17:50'),
(2082, 'KB9W-67-130(9)-2', '17.2937', '2018-04-02 14:17:50'),
(2083, 'KC0A-67-130(9)-1', '19.5718', '2018-04-02 14:17:50'),
(2084, 'KC0B-67-130(9)-1', '24.3923', '2018-04-02 14:17:50'),
(2085, 'KC0R-67-130(10)-1', '22.3672', '2018-04-02 14:17:50'),
(2086, 'KC0R-67-130(10)-2', '22.4622', '2018-04-02 14:17:50'),
(2087, 'KC0T-67-130(10)-2', '15.4947', '2018-04-02 14:17:50'),
(2088, 'KC9E-67-130A(9)-1', '28.4698', '2018-04-02 14:17:50'),
(2089, 'KC9F-67-130A(9)', '33.207', '2018-04-02 14:17:50');
INSERT INTO `eff_product_st` (`ID`, `product_no`, `st`, `last_update`) VALUES
(2090, 'KC9F-67-130A(9)-1', '33.207', '2018-04-02 14:17:51'),
(2091, 'KC9J-67-130(9)-1', '25.33', '2018-04-02 14:17:51'),
(2092, 'KC9J-67-130(9)-2', '25.5282', '2018-04-02 14:17:51'),
(2093, 'KD0E-67-130(10)-2', '24.3365', '2018-04-02 14:17:51'),
(2094, 'KD2W-67-130A(9)-1', '23.811', '2018-04-02 14:17:51'),
(2095, 'KD2W-67-130A(9)-2', '23.8995', '2018-04-02 14:17:51'),
(2096, 'KD3A-67-130A(9)-1', '21.539', '2018-04-02 14:17:51'),
(2097, 'KD3A-67-130A(9)-2', '21.6328', '2018-04-02 14:17:51'),
(2098, 'KD3D-67-130A(9)-1', '25.9347', '2018-04-02 14:17:51'),
(2099, 'KD3D-67-130A(9)-2', '26.0246', '2018-04-02 14:17:51'),
(2100, 'KD3E-67-130A(9)-1', '24.6295', '2018-04-02 14:17:51'),
(2101, 'KD3E-67-130A(9)-2', '24.7246', '2018-04-02 14:17:51'),
(2102, 'KD3F-67-130A(9)-1', '28.5206', '2018-04-02 14:17:52'),
(2103, 'KD3F-67-130A(9)-2', '28.612', '2018-04-02 14:17:52'),
(2104, 'KD3M-67-130(9)-1', '27.4068', '2018-04-02 14:17:52'),
(2105, 'KD3M-67-130(9)-2', '27.6049', '2018-04-02 14:17:52'),
(2106, 'KD3R-67-130(9)-1', '15.6737', '2018-04-02 14:17:52'),
(2107, 'KD3R-67-130(9)-2', '15.6681', '2018-04-02 14:17:52'),
(2108, 'KD3S-67-130(9)-2', '29.5594', '2018-04-02 14:17:52'),
(2109, 'KD4D-67-130(10)-2', '24.1825', '2018-04-02 14:17:52'),
(2110, 'KD7V-67-130A(9)', '28.1704', '2018-04-02 14:17:53'),
(2111, 'KD7V-67-130A(9)-1', '28.1704', '2018-04-02 14:17:53'),
(2112, 'KD7W-67-130A(9)', '32.9971', '2018-04-02 14:17:53'),
(2113, 'KD7W-67-130A(9)-1', '32.9971', '2018-04-02 14:17:53'),
(2114, 'KF1H-67-130(9)-2', '31.8364', '2018-04-02 14:17:53'),
(2115, 'KF1J-67-130A(9)-1', '34.5065', '2018-04-02 14:17:53'),
(2116, 'KF1K-67-130A(9)', '38.5865', '2018-04-02 14:17:53'),
(2117, 'KF1K-67-130A(9)-1', '38.5865', '2018-04-02 14:17:53'),
(2118, 'KF2C-67-130(9)-1', '20.8153', '2018-04-02 14:17:53'),
(2119, 'KF2K-67-130(7)-1', '26.8847', '2018-04-02 14:17:53'),
(2120, '82141-BAD90B-3', '158.1422', '2018-04-02 14:17:53'),
(2121, '82141-BAE00B-3', '171.0029', '2018-04-02 14:17:53'),
(2122, '82141-BAE10B-3', '182.8623', '2018-04-02 14:17:53'),
(2123, '82141-BAE40B-3', '203.9545', '2018-04-02 14:17:54'),
(2124, '88648-B2540N-2', '15.4479', '2018-04-02 14:17:54'),
(2125, '88648-B2550N-2', '19.3641', '2018-04-02 14:17:54'),
(2126, '88648-B2650J-5', '19.8649', '2018-04-02 14:17:54'),
(2127, '82219-B2060J-2', '3.0852', '2018-04-02 14:17:54'),
(2128, '82415-B2530K-5', '6.8769', '2018-04-02 14:17:54'),
(2129, '82415-B2551H-4', '8.4988', '2018-04-02 14:17:54'),
(2130, '82152-B2P70A-6', '20.8044', '2018-04-02 14:17:54'),
(2131, '82152-B2P80A-6', '14.8159', '2018-04-02 14:17:54'),
(2132, '82152-B2Q40N-5', '17.6098', '2018-04-02 14:17:55'),
(2133, '82152-B2R70A-6', '17.2567', '2018-04-02 14:17:55'),
(2134, '82151-B2L10B-1', '23.4759', '2018-04-02 14:17:55'),
(2135, '82151-B2Q10B-1', '25.8809', '2018-04-02 14:17:55'),
(2136, '82151-B2Q30B-1', '28.6642', '2018-04-02 14:17:55'),
(2137, '82153-B2380N-6', '14.5347', '2018-04-02 14:17:55'),
(2138, '82186-B2170M-1', '3.9276', '2018-04-02 14:17:55'),
(2139, '82171-B2G70A-3', '13.9671', '2018-04-02 14:17:55'),
(2140, '82118-B2P80A-1', '160.376', '2018-04-02 14:17:56'),
(2141, '82118-B2P90A-1', '166.4979', '2018-04-02 14:17:56'),
(2142, '82118-B2Q00A-1', '182.5493', '2018-04-02 14:17:56'),
(2143, '82118-B2Q20A-1', '188.9298', '2018-04-02 14:17:56'),
(2144, '82146-B2S20A-1', '147.904', '2018-04-02 14:17:56'),
(2145, '82171-B2B40K-4', '11.0062', '2018-04-02 14:17:56'),
(2146, '82171-B2D30L-1', '17.5176', '2018-04-02 14:17:56'),
(2147, '82171-B2G90-2', '16.2315', '2018-04-02 14:17:56'),
(2148, '82171-B2J00-2', '22.8404', '2018-04-02 14:17:56'),
(2149, '82118-B2Q30A-1', '187.4636', '2018-04-02 14:17:56'),
(2150, '82118-B2Q90A-1', '209.2025', '2018-04-02 14:17:56'),
(2151, '82118-B2R60A-1', '173.811', '2018-04-02 14:17:56'),
(2152, '82152-B2R90-5', '20.6907', '2018-04-02 14:17:57'),
(2153, '82151-B2Q40-3', '25.6278', '2018-04-02 14:17:57'),
(2154, '82151-B2Q50-3', '28.5754', '2018-04-02 14:17:57'),
(2155, '82171-B2E40M-5', '10.3444', '2018-04-02 14:17:57'),
(2156, '82171-B2J10-4', '14.1134', '2018-04-02 14:17:57'),
(2157, '53680-TLA-A500-3', '3.984', '2018-04-02 14:17:57'),
(2158, '53680-TMC-T010-3', '8.2035', '2018-04-02 14:17:57'),
(2159, '28950-5TA-E000', '12.2403', '2018-04-02 14:17:57'),
(2160, '28950-5TB-H001', '12.5479', '2018-04-02 14:17:57'),
(2161, '32119-TLA-A006-6', '16.9605', '2018-04-02 14:17:58'),
(2162, '32119-TLY-H003-6', '16.1164', '2018-04-02 14:17:58'),
(2163, '32119-TMM-F000-4', '16.8838', '2018-04-02 14:17:58'),
(2164, '32119-TNY-J002', '17.2934', '2018-04-02 14:17:58'),
(2165, '32119-TNY-J101', '17.17', '2018-04-02 14:17:58'),
(2166, '32129-TLA-A006-5', '19.9654', '2018-04-02 14:17:58'),
(2167, '32129-TLA-A106-5', '13.9553', '2018-04-02 14:17:58'),
(2168, '32129-TLC-A006-5', '19.2456', '2018-04-02 14:17:58'),
(2169, '32129-TLE-R002-5', '13.8815', '2018-04-02 14:17:58'),
(2170, '32129-TMC-U004-5', '19.8214', '2018-04-02 14:17:58'),
(2171, '32129-TMF-Z003-5', '13.8207', '2018-04-02 14:17:58'),
(2172, '32129-TMK-P002-5', '19.158', '2018-04-02 14:17:58'),
(2173, '32129-TMM-F000-2', '19.8888', '2018-04-02 14:17:58'),
(2174, '32129-TMM-F100-2', '13.8787', '2018-04-02 14:17:58'),
(2175, '32129-TMS-F000-2', '19.169', '2018-04-02 14:17:59'),
(2176, '32129-TNY-J002', '19.5433', '2018-04-02 14:17:59'),
(2177, '32129-TNY-J102', '13.6969', '2018-04-02 14:17:59'),
(2178, '32129-TNY-J201', '19.2441', '2018-04-02 14:17:59'),
(2179, '32129-TNY-J301', '19.9639', '2018-04-02 14:17:59'),
(2180, '32129-TNY-J401', '13.9537', '2018-04-02 14:17:59'),
(2181, '32129-TNY-J501', '19.1564', '2018-04-02 14:17:59'),
(2182, '32129-TNY-J601', '19.8197', '2018-04-02 14:17:59'),
(2183, '32129-TNY-J701', '13.88', '2018-04-02 14:17:59'),
(2184, '32129-TPB-E002', '14.4999', '2018-04-02 14:17:59'),
(2185, '32603-TMB-H000-2', '2.3592', '2018-04-02 14:17:59'),
(2186, '32603-TMB-H000-3', '2.3584', '2018-04-02 14:17:59'),
(2187, '32109-TLA-A006-5', '32.6595', '2018-04-02 14:17:59'),
(2188, '32109-TLA-A006-6', '32.6905', '2018-04-02 14:18:00'),
(2189, '32109-TLA-A106-5', '42.414', '2018-04-02 14:18:00'),
(2190, '32109-TLA-A106-6', '42.445', '2018-04-02 14:18:00'),
(2191, '32109-TLC-A003-5', '31.3573', '2018-04-02 14:18:00'),
(2192, '32109-TLC-A003-6', '31.3883', '2018-04-02 14:18:00'),
(2193, '32109-TLE-R003-5', '24.5429', '2018-04-02 14:18:00'),
(2194, '32109-TLE-R003-6', '24.5739', '2018-04-02 14:18:00'),
(2195, '32109-TLY-H003-5', '39.9343', '2018-04-02 14:18:00'),
(2196, '32109-TLY-H003-6', '39.9653', '2018-04-02 14:18:00'),
(2197, '32109-TMM-F000-2', '32.9174', '2018-04-02 14:18:00'),
(2198, '32109-TMM-F000-3', '32.9484', '2018-04-02 14:18:00'),
(2199, '32109-TMS-F000-2', '31.6152', '2018-04-02 14:18:00'),
(2200, '32109-TMS-F000-3', '31.6462', '2018-04-02 14:18:01'),
(2201, '32109-TNY-J000', '31.3876', '2018-04-02 14:18:01'),
(2202, '32109-TNY-J000-1', '31.3876', '2018-04-02 14:18:01'),
(2203, '32109-TNY-J100', '32.6895', '2018-04-02 14:18:01'),
(2204, '32109-TNY-J100-1', '32.6895', '2018-04-02 14:18:01'),
(2205, '32109-TNY-J200', '42.445', '2018-04-02 14:18:01'),
(2206, '32109-TNY-J200-1', '42.445', '2018-04-02 14:18:01'),
(2207, '32109-TNY-J300', '24.5732', '2018-04-02 14:18:01'),
(2208, '32109-TNY-J300-1', '24.5732', '2018-04-02 14:18:01'),
(2209, '32109-TPB-E001', '26.0371', '2018-04-02 14:18:01'),
(2210, '32109-TPB-E001-1', '26.0371', '2018-04-02 14:18:01'),
(2211, '32600-TLA-A001-2', '2.8419', '2018-04-02 14:18:01'),
(2212, '32600-TLA-A101-2', '2.8462', '2018-04-02 14:18:01'),
(2213, '32600-TLY-H001-2', '4.4231', '2018-04-02 14:18:02'),
(2214, '32600-TLY-H001-3', '4.3343', '2018-04-02 14:18:02'),
(2215, '32600-TLY-H100-2', '4.3113', '2018-04-02 14:18:02'),
(2216, '32600-TLY-H100-3', '4.2225', '2018-04-02 14:18:02'),
(2217, '32600-TNY-E001', '3.8452', '2018-04-02 14:18:02'),
(2218, '32600-TNY-E001-1', '3.8426', '2018-04-02 14:18:02'),
(2219, '32600-TNY-G000', '4.0612', '2018-04-02 14:18:02'),
(2220, '32600-TNY-G000-1', '4.0586', '2018-04-02 14:18:02'),
(2221, '32600-TNY-J000', '4.1183', '2018-04-02 14:18:02'),
(2222, '32600-TNY-J000-1', '4.1183', '2018-04-02 14:18:02'),
(2223, '32112-TLA-D003-4', '10.0632', '2018-04-02 14:18:02'),
(2224, '32112-TLY-H000-1', '19.4987', '2018-04-02 14:18:02'),
(2225, '32112-TMB-H000-1', '18.7682', '2018-04-02 14:18:03'),
(2226, '32112-TMC-T003-4', '18.6339', '2018-04-02 14:18:03'),
(2227, '32112-TMC-T103-4', '19.3936', '2018-04-02 14:18:03'),
(2228, '32112-TMC-T203-4', '18.6631', '2018-04-02 14:18:03'),
(2229, '32112-TNY-E000', '17.1413', '2018-04-02 14:18:03'),
(2230, '32131-TLA-D010-4', '15.7554', '2018-04-02 14:18:03'),
(2231, '32131-TLA-D010-5', '15.7554', '2018-04-02 14:18:03'),
(2232, '32131-TLA-M010-4', '18.2645', '2018-04-02 14:18:03'),
(2233, '32131-TLA-M010-5', '18.2645', '2018-04-02 14:18:03'),
(2234, '32131-TLA-R006', '15.7867', '2018-04-02 14:18:03'),
(2235, '32131-TLA-R006-1', '15.7867', '2018-04-02 14:18:03'),
(2236, '32131-TLY-H001', '15.7937', '2018-04-02 14:18:03'),
(2237, '32131-TLY-H001-1', '15.7937', '2018-04-02 14:18:04'),
(2238, '32131-TNY-E000-1', '18.6847', '2018-04-02 14:18:04'),
(2239, '32131-TNY-E000-2', '18.6847', '2018-04-02 14:18:04'),
(2240, '32601-TTA-0000-1', '2.3127', '2018-04-02 14:18:04'),
(2241, '32155-TTA-0002-3', '10.4698', '2018-04-02 14:18:04'),
(2242, '32155-TTA-9003-2', '15.6953', '2018-04-02 14:18:04'),
(2243, '32155-TTA-9102-3', '12.7133', '2018-04-02 14:18:04'),
(2244, '32155-TTA-9203-2', '18.3753', '2018-04-02 14:18:04'),
(2245, '32155-TTA-9302-3', '6.9323', '2018-04-02 14:18:04'),
(2246, '32155-TTA-9403-2', '11.8603', '2018-04-02 14:18:04'),
(2247, '32610-TTA-0001-1', '2.1458', '2018-04-02 14:18:04'),
(2248, '32109-TTA-0003-2', '24.003', '2018-04-02 14:18:05'),
(2249, '32109-TTA-9003-2', '30.919', '2018-04-02 14:18:05'),
(2250, '32109-TTA-9103-2', '30.7148', '2018-04-02 14:18:05'),
(2251, '32109-TTA-9203-2', '23.7983', '2018-04-02 14:18:05'),
(2252, '32109-TTA-9303-2', '20.0374', '2018-04-02 14:18:05'),
(2253, '32109-TTA-9403-2', '26.8018', '2018-04-02 14:18:05'),
(2254, '32600-TTA-0000-1', '2.4106', '2018-04-02 14:18:05'),
(2255, '32752-TTA-0003-1', '24.0021', '2018-04-02 14:18:05'),
(2256, '32752-TTA-9003-1', '25.0062', '2018-04-02 14:18:05'),
(2257, '32752-TTA-9103-1', '25.8618', '2018-04-02 14:18:05'),
(2258, '32752-TTA-9203-1', '26.8363', '2018-04-02 14:18:06'),
(2259, '32751-TTA-0003-1', '35.9309', '2018-04-02 14:18:06'),
(2260, '32751-TTA-9003-1', '39.2863', '2018-04-02 14:18:06'),
(2261, '32751-TTA-9103-1', '36.4586', '2018-04-02 14:18:06'),
(2262, '32751-TTA-9203-1', '40.216', '2018-04-02 14:18:06'),
(2263, '32751-TTA-9303-1', '41.1213', '2018-04-02 14:18:06'),
(2264, '32751-TTA-9403-1', '42.0505', '2018-04-02 14:18:06'),
(2265, '32754-TTA-0002', '22.5827', '2018-04-02 14:18:06'),
(2266, '32754-TTA-9001-3', '7.1779', '2018-04-02 14:18:06'),
(2267, '32753-TTA-0001-3', '12.8276', '2018-04-02 14:18:06'),
(2268, '32753-TTA-9001-3', '7.2696', '2018-04-02 14:18:07'),
(2269, '32753-TTA-9102', '22.4481', '2018-04-02 14:18:07'),
(2270, '32109-TTE-0002', '26.977', '2018-04-02 14:18:07'),
(2271, '32109-TTE-J002', '33.6338', '2018-04-02 14:18:07'),
(2272, '32109-TTE-J102', '26.773', '2018-04-02 14:18:07'),
(2273, '32109-TTE-J202', '33.4296', '2018-04-02 14:18:07'),
(2274, '32601-TXA-0000-1', '2.3154', '2018-04-02 14:18:07'),
(2275, 'MLD-TTA-284', '2.4665', '2018-04-02 14:18:07'),
(2276, '32119-TAA-0200-3', '32.5795', '2018-04-02 14:18:07'),
(2277, '32119-TAA-9020-3', '38.8027', '2018-04-02 14:18:08'),
(2278, '32119-TAA-9110-4', '14.9249', '2018-04-02 14:18:08'),
(2279, '32119-TAA-9210-4', '21.8776', '2018-04-02 14:18:08'),
(2280, '32119-TAA-9320-3', '36.5131', '2018-04-02 14:18:08'),
(2281, '32119-TAA-9400-4', '26.04', '2018-04-02 14:18:08'),
(2282, '32119-TAA-W010-4', '31.3679', '2018-04-02 14:18:08'),
(2283, '32119-TAA-W110-4', '24.4052', '2018-04-02 14:18:08'),
(2284, '32119-TAA-W200-3', '33.9406', '2018-04-02 14:18:08'),
(2285, '32601-TAA-0002', '3.4425', '2018-04-02 14:18:09'),
(2286, '32601-TAD-0000-3', '2.4845', '2018-04-02 14:18:09'),
(2287, '32610-TAA-0002', '2.719', '2018-04-02 14:18:09'),
(2288, '32105-TAA-W002-3', '10.3342', '2018-04-02 14:18:09'),
(2289, '32105-TAA-W102-3', '11.0327', '2018-04-02 14:18:09'),
(2290, '32171-TAA-0002-2', '2.7028', '2018-04-02 14:18:09'),
(2291, '32109-TAA-0100-5', '19.5982', '2018-04-02 14:18:09'),
(2292, '32109-TAA-9010-4', '11.2053', '2018-04-02 14:18:09'),
(2293, '32109-TAA-9110-4', '16.4722', '2018-04-02 14:18:09'),
(2294, '32109-TAA-9200-5', '23.8603', '2018-04-02 14:18:10'),
(2295, '32109-TAA-9300-4', '17.358', '2018-04-02 14:18:10'),
(2296, '32109-TAA-9410-5', '24.9645', '2018-04-02 14:18:10'),
(2297, '32109-TAA-9510-5', '24.1279', '2018-04-02 14:18:10'),
(2298, '32109-TAA-W010-4', '17.669', '2018-04-02 14:18:10'),
(2299, '32109-TAA-W110-4', '12.4793', '2018-04-02 14:18:10'),
(2300, '32752-TAA-0100-4', '29.1949', '2018-04-02 14:18:10'),
(2301, '32752-TAA-9110-4', '19.1198', '2018-04-02 14:18:10'),
(2302, '32752-TAA-9210-4', '20.1435', '2018-04-02 14:18:10'),
(2303, '32752-TAA-9310-4', '32.3953', '2018-04-02 14:18:10'),
(2304, '32752-TAA-9400-4', '21.2059', '2018-04-02 14:18:11'),
(2305, '32752-TAA-9500-4', '22.4145', '2018-04-02 14:18:11'),
(2306, '32752-TAA-U010-4', '28.198', '2018-04-02 14:18:11'),
(2307, '32752-TAA-U100-4', '19.6689', '2018-04-02 14:18:11'),
(2308, '32751-TAA-0100-4', '40.6861', '2018-04-02 14:18:11'),
(2309, '32751-TAA-9010-4', '32.3499', '2018-04-02 14:18:11'),
(2310, '32751-TAA-9100-4', '32.9595', '2018-04-02 14:18:11'),
(2311, '32751-TAA-9210-4', '33.2182', '2018-04-02 14:18:11'),
(2312, '32751-TAA-9310-4', '43.6245', '2018-04-02 14:18:12'),
(2313, '32751-TAA-9400-4', '32.3173', '2018-04-02 14:18:12'),
(2314, '32751-TAA-9500-4', '33.7008', '2018-04-02 14:18:12'),
(2315, '32751-TAA-U010-4', '32.0544', '2018-04-02 14:18:12'),
(2316, '32751-TAA-U110-4', '40.5435', '2018-04-02 14:18:12'),
(2317, '32751-TAD-0000-4', '39.9445', '2018-04-02 14:18:12'),
(2318, '32600-TAA-0001-1', '2.7765', '2018-04-02 14:18:12'),
(2319, '32600-TAD-0001-1', '3.3542', '2018-04-02 14:18:12'),
(2320, '32170-TAA-0000-3', '4.4628', '2018-04-02 14:18:12'),
(2321, '32170-TAB-0001-5', '8.5562', '2018-04-02 14:18:12'),
(2322, '28950-59F-0001-1', '12.1858', '2018-04-02 14:18:13'),
(2323, '32107-TAA-9012-3', '214.6132', '2018-04-02 14:18:13'),
(2324, '32107-TAA-9811-3', '103.786', '2018-04-02 14:18:13'),
(2325, '32107-TAA-9902-3', '170.1605', '2018-04-02 14:18:13'),
(2326, '32107-TAA-J011-3', '137.3918', '2018-04-02 14:18:13'),
(2327, '32107-TAA-J112-3', '165.2915', '2018-04-02 14:18:13'),
(2328, '32107-TAA-J212-3', '182.7133', '2018-04-02 14:18:13'),
(2329, '32107-TAA-J312-3', '188.8752', '2018-04-02 14:18:13'),
(2330, '32107-TAA-J412-3', '200.5851', '2018-04-02 14:18:13'),
(2331, '32107-TAA-J512-3', '216.0695', '2018-04-02 14:18:13'),
(2332, '32107-TAA-J602-3', '230.6824', '2018-04-02 14:18:14'),
(2333, '32107-TAA-J702-3', '229.1048', '2018-04-02 14:18:14'),
(2334, '32107-TAA-J802-3', '218.6968', '2018-04-02 14:18:14'),
(2335, '32107-TAA-J902-3', '220.3852', '2018-04-02 14:18:14'),
(2336, '32107-TAA-L812-3', '166.4277', '2018-04-02 14:18:14'),
(2337, '32107-TAA-L912-3', '203.1557', '2018-04-02 14:18:14'),
(2338, '32107-TAA-N012-3', '251.426', '2018-04-02 14:18:14'),
(2339, '32107-TAA-N112-3', '254.6404', '2018-04-02 14:18:15'),
(2340, '32107-TAA-N212-3', '266.8199', '2018-04-02 14:18:15'),
(2341, '32107-TAA-N312-3', '265.4089', '2018-04-02 14:18:15'),
(2342, '32107-TAA-N412-3', '271.7839', '2018-04-02 14:18:15'),
(2343, '32107-TAA-N512-3', '259.5696', '2018-04-02 14:18:15'),
(2344, '32107-TAA-N612-3', '258.162', '2018-04-02 14:18:15'),
(2345, '32107-TAA-N712-3', '270.4967', '2018-04-02 14:18:15'),
(2346, '32107-TAA-N812-3', '230.3789', '2018-04-02 14:18:15'),
(2347, '32107-TAA-P012-3', '210.2781', '2018-04-02 14:18:15'),
(2348, '32107-TAA-U011-3', '154.0186', '2018-04-02 14:18:15'),
(2349, '32107-TAA-U112-3', '174.6394', '2018-04-02 14:18:15'),
(2350, '32107-TAA-W012-2', '200.2775', '2018-04-02 14:18:16'),
(2351, '32107-TAA-W112-2', '199.4284', '2018-04-02 14:18:16'),
(2352, '32107-TAA-W212-2', '227.0926', '2018-04-02 14:18:16'),
(2353, '32107-TAA-W312-2', '225.599', '2018-04-02 14:18:16'),
(2354, '32107-TAA-W612-2', '266.0466', '2018-04-02 14:18:16'),
(2355, '32107-TAA-W712-2', '265.7333', '2018-04-02 14:18:16'),
(2356, '32107-TAA-Z112-3', '206.8482', '2018-04-02 14:18:16'),
(2357, '32107-TAA-Z212-3', '224.1744', '2018-04-02 14:18:16'),
(2358, '32107-TAA-Z412-3', '219.1553', '2018-04-02 14:18:16'),
(2359, '32107-TAA-Z902-2', '205.8977', '2018-04-02 14:18:16'),
(2360, '32107-TAB-9611-3', '177.4533', '2018-04-02 14:18:17'),
(2361, '32107-TAB-9712-3', '200.9829', '2018-04-02 14:18:17'),
(2362, '32107-TAB-9812-3', '238.5636', '2018-04-02 14:18:17'),
(2363, '32107-TAB-9902-3', '243.1449', '2018-04-02 14:18:17'),
(2364, '32107-TAB-J011-3', '171.2361', '2018-04-02 14:18:17'),
(2365, '32107-TAB-J112-3', '199.6822', '2018-04-02 14:18:17'),
(2366, '32107-TAB-J212-3', '215.9735', '2018-04-02 14:18:18'),
(2367, '32107-TAB-J312-3', '219.3003', '2018-04-02 14:18:18'),
(2368, '32107-TAB-J412-3', '231.7075', '2018-04-02 14:18:18'),
(2369, '32107-TAB-J512-3', '247.3161', '2018-04-02 14:18:18'),
(2370, '32107-TAB-J602-3', '249.8523', '2018-04-02 14:18:18'),
(2371, '32107-TAB-J702-3', '257.3509', '2018-04-02 14:18:18'),
(2372, '32107-TAB-J802-3', '255.41', '2018-04-02 14:18:18'),
(2373, '32107-TAB-J902-3', '245.2751', '2018-04-02 14:18:18'),
(2374, '32107-TAB-L612-3', '195.2634', '2018-04-02 14:18:18'),
(2375, '32107-TAB-L712-3', '237.5097', '2018-04-02 14:18:18'),
(2376, '32107-TAB-L912-3', '248.4395', '2018-04-02 14:18:18'),
(2377, '32107-TAB-N012-3', '255.4149', '2018-04-02 14:18:19'),
(2378, '32107-TAB-N112-3', '253.9422', '2018-04-02 14:18:19'),
(2379, '32107-TAB-N212-3', '252.8252', '2018-04-02 14:18:19'),
(2380, '32107-TAB-N312-3', '251.0306', '2018-04-02 14:18:19'),
(2381, '32107-TAB-N412-3', '260.0408', '2018-04-02 14:18:19'),
(2382, '32107-TAB-N512-3', '258.7512', '2018-04-02 14:18:19'),
(2383, '32107-TAB-N612-3', '257.2293', '2018-04-02 14:18:19'),
(2384, '32107-TAB-W012-2', '226.6487', '2018-04-02 14:18:19'),
(2385, '32107-TAB-W112-2', '226.4338', '2018-04-02 14:18:19'),
(2386, '32107-TAB-W212-2', '214.1803', '2018-04-02 14:18:19'),
(2387, '32107-TAB-W312-2', '252.1298', '2018-04-02 14:18:20'),
(2388, '32107-TAB-W512-2', '292.9165', '2018-04-02 14:18:20'),
(2389, '32107-TAD-0003-4', '226.5253', '2018-04-02 14:18:20'),
(2390, '32107-TAD-9303-4', '235.2167', '2018-04-02 14:18:20'),
(2391, '32107-TAD-9403-4', '237.4531', '2018-04-02 14:18:20'),
(2392, '32107-TAD-9703-4', '250.42', '2018-04-02 14:18:20'),
(2393, '32107-TAD-9803-4', '252.686', '2018-04-02 14:18:20'),
(2394, '32107-TAD-F103-4', '249.9677', '2018-04-02 14:18:20'),
(2395, '32107-TAD-F203-4', '252.198', '2018-04-02 14:18:20'),
(2396, '32107-TAD-F703-4', '253.8046', '2018-04-02 14:18:20'),
(2397, '32107-TAD-F803-4', '256.0357', '2018-04-02 14:18:21'),
(2398, '32107-TAD-F903-4', '265.0787', '2018-04-02 14:18:21'),
(2399, '32107-TAD-J003-4', '232.4168', '2018-04-02 14:18:21'),
(2400, '32107-TAD-J203-4', '249.0372', '2018-04-02 14:18:21'),
(2401, '32107-TAD-J403-4', '255.5628', '2018-04-02 14:18:21'),
(2402, '32107-TAD-J503-4', '258.1113', '2018-04-02 14:18:21'),
(2403, '32107-TAD-K003-4', '267.3397', '2018-04-02 14:18:21'),
(2404, '32107-TAD-N303-4', '251.3211', '2018-04-02 14:18:21'),
(2405, '32107-TAD-N403-4', '253.552', '2018-04-02 14:18:21'),
(2406, '32107-TAD-N503-4', '255.1616', '2018-04-02 14:18:21'),
(2407, '32107-TAD-N603-4', '257.4878', '2018-04-02 14:18:22'),
(2408, '32107-TAD-N903-4', '266.4988', '2018-04-02 14:18:22'),
(2409, '32107-TAD-Z003-4', '268.7003', '2018-04-02 14:18:22'),
(2410, '32107-TAD-Z403-4', '252.8698', '2018-04-02 14:18:22'),
(2411, '32106-TAA-W002-4', '35.0942', '2018-04-02 14:18:22'),
(2412, '32106-TAA-W102-4', '61.377', '2018-04-02 14:18:22'),
(2413, '32106-TAA-W201-5', '35.7364', '2018-04-02 14:18:22'),
(2414, '28950-5TAY-E002', '12.2403', '2018-04-02 14:18:22'),
(2415, '32109-TPBY-E000-2', '26.0069', '2018-04-02 14:18:22'),
(2416, '82161-13F11A-1', '117.0292', '2018-04-02 14:18:22'),
(2417, '82161-13G11A-1', '144.8944', '2018-04-02 14:18:23'),
(2418, '82161-13G21A-1', '152.8074', '2018-04-02 14:18:23'),
(2419, '82161-13G31A-1', '128.7277', '2018-04-02 14:18:23'),
(2420, '82161-13G41A-1', '155.8444', '2018-04-02 14:18:23'),
(2421, '82161-13G51A-1', '164.4763', '2018-04-02 14:18:23'),
(2422, '82161-13G61A-1', '164.4899', '2018-04-02 14:18:23'),
(2423, '82161-13G71-1', '164.3911', '2018-04-02 14:18:23'),
(2424, '82161-13G81A-1', '173.3091', '2018-04-02 14:18:23'),
(2425, '82161-13G91A-1', '175.9755', '2018-04-02 14:18:23'),
(2426, '82161-1AF11A-1', '130.1575', '2018-04-02 14:18:23'),
(2427, '82161-1AG11A-1', '154.5524', '2018-04-02 14:18:23'),
(2428, '82161-1AG21A-1', '164.3651', '2018-04-02 14:18:23'),
(2429, '82161-1AG31A-1', '139.7938', '2018-04-02 14:18:24'),
(2430, '82161-1AG41A-1', '165.5816', '2018-04-02 14:18:24'),
(2431, '82161-1AG51A-1', '175.5254', '2018-04-02 14:18:24'),
(2432, '82161-1AG61A-1', '178.2635', '2018-04-02 14:18:24'),
(2433, '82161-1AG71-1', '178.0125', '2018-04-02 14:18:24'),
(2434, '82161-1AG81A-1', '188.6847', '2018-04-02 14:18:24'),
(2435, '82161-1AG91A-1', '190.8586', '2018-04-02 14:18:24'),
(2436, '82182-12020A', '17.7093', '2018-04-02 14:18:24'),
(2437, '82182-12030A', '18.0097', '2018-04-02 14:18:24'),
(2438, '82154-60400F-1', '20.5112', '2018-04-02 14:18:24'),
(2439, '82154-60410F-1', '21.9153', '2018-04-02 14:18:24'),
(2440, '82154-60420F-1', '19.7795', '2018-04-02 14:18:24'),
(2441, '82154-60430D-1', '20.9931', '2018-04-02 14:18:25'),
(2442, '82154-60440F-1', '22.4127', '2018-04-02 14:18:25'),
(2443, '82154-60450F-1', '22.9948', '2018-04-02 14:18:25'),
(2444, '82154-60460F-1', '22.4615', '2018-04-02 14:18:25'),
(2445, '82154-60470F-1', '21.0314', '2018-04-02 14:18:25'),
(2446, '82154-60480F-1', '13.659', '2018-04-02 14:18:25'),
(2447, '82154-60490F-1', '16.0997', '2018-04-02 14:18:25'),
(2448, '82154-60530-1', '17.8348', '2018-04-02 14:18:25'),
(2449, '82154-60540-1', '21.2052', '2018-04-02 14:18:25'),
(2450, '82153-60580F', '21.5091', '2018-04-02 14:18:26'),
(2451, '82153-60590F', '22.9015', '2018-04-02 14:18:26'),
(2452, '82153-60600F', '20.9656', '2018-04-02 14:18:26'),
(2453, '82153-60610D', '22.7103', '2018-04-02 14:18:26'),
(2454, '82153-60620F', '24.6315', '2018-04-02 14:18:26'),
(2455, '82153-60630F', '23.9858', '2018-04-02 14:18:26'),
(2456, '82153-60640F', '23.2649', '2018-04-02 14:18:26'),
(2457, '82153-60650F', '22.0319', '2018-04-02 14:18:27'),
(2458, '82153-60660F', '14.8682', '2018-04-02 14:18:27'),
(2459, '82153-60670F', '17.1796', '2018-04-02 14:18:27'),
(2460, '82153-60690', '18.6678', '2018-04-02 14:18:27'),
(2461, '82153-60700', '22.2297', '2018-04-02 14:18:27'),
(2462, '36610-31JK0(1)-1-P', '162.2626', '2018-04-02 14:18:27'),
(2463, '36610-31JN0(1)-1-P', '153.0882', '2018-04-02 14:18:27'),
(2464, '36610-31JP0(1)-1-P', '154.1979', '2018-04-02 14:18:27'),
(2465, '36610-31JQ0(1)-1-P', '154.0135', '2018-04-02 14:18:27'),
(2466, '36620-31J10-5-P', '24.2652', '2018-04-02 14:18:27'),
(2467, '36851-31J10-4-P', '1.5114', '2018-04-02 14:18:27'),
(2468, '36854-31J20-3-P', '3.3692', '2018-04-02 14:18:27'),
(2469, '33810-31J10-3-P', '2.9779', '2018-04-02 14:18:28'),
(2470, '33860-31J10-3-P', '4.7023', '2018-04-02 14:18:28'),
(2471, '36856-31J10-4-P', '4.1245', '2018-04-02 14:18:28'),
(2472, '36630-76R20-4-P', '115.9465', '2018-04-02 14:18:28'),
(2473, '36630-76R30-4-P', '143.872', '2018-04-02 14:18:28'),
(2474, '36630-76R60-4-P', '117.9925', '2018-04-02 14:18:28'),
(2475, '36630-76R70-4-P', '146.7056', '2018-04-02 14:18:28'),
(2476, '36630-76R80-4-P', '119.6896', '2018-04-02 14:18:28'),
(2477, '36630-76R90-4-P', '148.4061', '2018-04-02 14:18:28'),
(2478, '36843-76R00-2-P', '3.6423', '2018-04-02 14:18:28'),
(2479, '36843-76R10-2-P', '17.0075', '2018-04-02 14:18:28'),
(2480, '36757-76R00-2-P', '17.6065', '2018-04-02 14:18:28'),
(2481, '36757-76R10-2-P', '21.7329', '2018-04-02 14:18:29'),
(2482, '36757-76R20-2-P', '19.7405', '2018-04-02 14:18:29'),
(2483, '36757-76R30-2-P', '23.741', '2018-04-02 14:18:29'),
(2484, '36756-76R00-3-P', '28.1108', '2018-04-02 14:18:29'),
(2485, '36756-76R10-3-P', '31.3512', '2018-04-02 14:18:29'),
(2486, '36756-76R20-3-P', '30.0712', '2018-04-02 14:18:29'),
(2487, '36756-76R30-3-P', '33.3117', '2018-04-02 14:18:29'),
(2488, '36680-76R00-4-P', '22.7217', '2018-04-02 14:18:29'),
(2489, '36680-76R10-4-P', '27.1067', '2018-04-02 14:18:29'),
(2490, '33880-76R00-1-P', '7.2143', '2018-04-02 14:18:29'),
(2491, '36751-76R00-3-P', '11.4116', '2018-04-02 14:18:29'),
(2492, '36820-76R00-3-P', '15.6458', '2018-04-02 14:18:29'),
(2493, '36820-76R10-3-P', '19.1033', '2018-04-02 14:18:30'),
(2494, '36820-76R20-3-P', '18.4736', '2018-04-02 14:18:30'),
(2495, '36820-76R30-3-P', '21.0726', '2018-04-02 14:18:30'),
(2496, '36602-54S00-X3-P', '130.7944', '2018-04-02 14:18:30'),
(2497, '36602-54S10-X3-P', '132.6578', '2018-04-02 14:18:30'),
(2498, '36602-54S60-X3-P', '98.2079', '2018-04-02 14:18:30'),
(2499, '36602-54S70-X3-P', '115.7575', '2018-04-02 14:18:30'),
(2500, '36602-74P00(11)-1-P', '129.7993', '2018-04-02 14:18:30'),
(2501, '36602-74P10(11)-1-P', '131.664', '2018-04-02 14:18:30'),
(2502, '36602-74P20(11)-1-P', '91.1188', '2018-04-02 14:18:30'),
(2503, '36602-74P30(11)-1-P', '97.4632', '2018-04-02 14:18:30'),
(2504, '36602-74P40(11)-1-P', '94.1282', '2018-04-02 14:18:30'),
(2505, '36602-74P50(11)-1-P', '100.6216', '2018-04-02 14:18:31'),
(2506, '36602-74P60(11)-1-P', '98.2208', '2018-04-02 14:18:31'),
(2507, '36602-74P70(11)-1-P', '114.7607', '2018-04-02 14:18:31'),
(2508, '36602-74P80(11)-1-P', '77.9324', '2018-04-02 14:18:31'),
(2509, '36602-74P90(11)-1-P', '85.3398', '2018-04-02 14:18:31'),
(2510, '36620-54S00-X3-P', '77.8807', '2018-04-02 14:18:31'),
(2511, '36620-54S20-X3-P', '82.8458', '2018-04-02 14:18:31'),
(2512, '36620-54S30-X3-P', '86.4341', '2018-04-02 14:18:31'),
(2513, '36620-54S40-X3-P', '90.8609', '2018-04-02 14:18:31'),
(2514, '36620-54S50-X3-P', '92.9349', '2018-04-02 14:18:31'),
(2515, '36620-54S60-X3-P', '97.0961', '2018-04-02 14:18:32'),
(2516, '36620-54S70-X3-P', '90.474', '2018-04-02 14:18:32'),
(2517, '36620-54S80-X3-P', '93.7743', '2018-04-02 14:18:32'),
(2518, '36620-54S90-X3-P', '96.6862', '2018-04-02 14:18:32'),
(2519, '36620-54SA0-X3-P', '117.4319', '2018-04-02 14:18:32'),
(2520, '36620-54SC0-X3-P', '79.8641', '2018-04-02 14:18:32'),
(2521, '36620-54SE0-X3-P', '87.8454', '2018-04-02 14:18:32'),
(2522, '36620-54SG0-X3-P', '94.2178', '2018-04-02 14:18:32'),
(2523, '36620-54SH0-X3-P', '87.9185', '2018-04-02 14:18:32'),
(2524, '36620-54SJ0-X3-P', '115.1593', '2018-04-02 14:18:32'),
(2525, '36620-54SL0-X3-P', '118.6229', '2018-04-02 14:18:32'),
(2526, '36620-54SM0-X3-P', '121.2386', '2018-04-02 14:18:33'),
(2527, '36620-54SQ0-X3-P', '93.8952', '2018-04-02 14:18:33'),
(2528, '36620-54SR0-X3-P', '97.7344', '2018-04-02 14:18:33'),
(2529, '36620-54SS0-X3-P', '100.2835', '2018-04-02 14:18:33'),
(2530, '36620-54SU0-X3-P', '91.4998', '2018-04-02 14:18:33'),
(2531, '36620-74P20(11)-1-P', '83.0834', '2018-04-02 14:18:33'),
(2532, '36620-74P40(11)-1-P', '89.9483', '2018-04-02 14:18:33'),
(2533, '36620-74P50(11)-1-P', '91.9446', '2018-04-02 14:18:33'),
(2534, '36620-74P60(11)-1-P', '96.2918', '2018-04-02 14:18:33'),
(2535, '36620-74P70(11)-1-P', '90.5229', '2018-04-02 14:18:34'),
(2536, '36620-74P80(11)-1-P', '93.9299', '2018-04-02 14:18:34'),
(2537, '36620-74P90(11)-1-P', '96.8455', '2018-04-02 14:18:34'),
(2538, '36620-74PA0(11)-1-P', '117.429', '2018-04-02 14:18:34'),
(2539, '36620-74PB0(11)-1-P', '131.2291', '2018-04-02 14:18:34'),
(2540, '36620-74PC0(11)-1-P', '80.1017', '2018-04-02 14:18:34'),
(2541, '36620-74PE0(11)-1-P', '86.938', '2018-04-02 14:18:34'),
(2542, '36620-74PG0(11)-1-P', '93.4143', '2018-04-02 14:18:34'),
(2543, '36620-74PH0(11)-1-P', '87.9674', '2018-04-02 14:18:34'),
(2544, '36620-74PJ0(11)-1-P', '115.1542', '2018-04-02 14:18:34'),
(2545, '36620-74PK0(11)-1-P', '129.362', '2018-04-02 14:18:34'),
(2546, '36620-74PL0(11)-1-P', '117.6256', '2018-04-02 14:18:34'),
(2547, '36620-74PM0(11)-1-P', '120.2435', '2018-04-02 14:18:34'),
(2548, '36620-74PN0(11)-1-P', '131.7446', '2018-04-02 14:18:34'),
(2549, '36620-74PP0(11)-1-P', '133.7441', '2018-04-02 14:18:35'),
(2550, '36620-74PQ0(11)-1-P', '93.9453', '2018-04-02 14:18:35'),
(2551, '36620-74PR0(11)-1-P', '97.89', '2018-04-02 14:18:35'),
(2552, '36620-74PS0(11)-1-P', '100.4404', '2018-04-02 14:18:35'),
(2553, '36620-74PU0(11)-1-P', '91.5463', '2018-04-02 14:18:35'),
(2554, '36630-54S00-P', '58.0932', '2018-04-02 14:18:35'),
(2555, '36630-54S10-P', '58.6814', '2018-04-02 14:18:35'),
(2556, '36630-54S20-X3-P', '72.7905', '2018-04-02 14:18:35'),
(2557, '36630-54S30-X3-P', '74.1652', '2018-04-02 14:18:36'),
(2558, '36630-54S40-X3-P', '65.7205', '2018-04-02 14:18:36'),
(2559, '36630-54S50-X3-P', '66.3571', '2018-04-02 14:18:36'),
(2560, '36630-54S60-X3-P', '73.1701', '2018-04-02 14:18:36'),
(2561, '36630-54S70-X3-P', '74.4391', '2018-04-02 14:18:36'),
(2562, '36630-54S80-X3-P', '79.7523', '2018-04-02 14:18:36'),
(2563, '36630-54S90-X3-P', '80.9973', '2018-04-02 14:18:36'),
(2564, '36630-54SA0-X3-P', '92.8884', '2018-04-02 14:18:36'),
(2565, '36630-54SB0-X3-P', '93.5403', '2018-04-02 14:18:36'),
(2566, '36630-54SC0-X3-P', '94.9384', '2018-04-02 14:18:36'),
(2567, '36630-54SD0-X3-P', '97.6544', '2018-04-02 14:18:36'),
(2568, '36630-54SE0-X3-P', '80.3456', '2018-04-02 14:18:36'),
(2569, '36630-54SH0-X3-P', '90.5308', '2018-04-02 14:18:37'),
(2570, '36630-54SJ0-X3-P', '92.5956', '2018-04-02 14:18:37'),
(2571, '36630-54SK0-X3-P', '90.4438', '2018-04-02 14:18:37'),
(2572, '36630-54SL0-X3-P', '92.5087', '2018-04-02 14:18:37'),
(2573, '36630-74P20(7)-2-P', '73.7494', '2018-04-02 14:18:37'),
(2574, '36630-74P30(7)-2-P', '75.1224', '2018-04-02 14:18:37'),
(2575, '36630-74P40(7)-2-P', '66.6988', '2018-04-02 14:18:37'),
(2576, '36630-74P50(7)-2-P', '67.335', '2018-04-02 14:18:37'),
(2577, '36630-74P60(7)-2-P', '74.1278', '2018-04-02 14:18:37'),
(2578, '36630-74P70(7)-2-P', '75.3958', '2018-04-02 14:18:37'),
(2579, '36630-74P80(7)-2-P', '80.7819', '2018-04-02 14:18:37'),
(2580, '36630-74P90(7)-2-P', '82.0262', '2018-04-02 14:18:37'),
(2581, '36630-74PA0(7)-2-P', '97.6', '2018-04-02 14:18:38'),
(2582, '36630-74PB0(7)-2-P', '98.2515', '2018-04-02 14:18:38'),
(2583, '36630-74PC0(7)-2-P', '95.8207', '2018-04-02 14:18:38'),
(2584, '36630-74PD0(7)-2-P', '98.5366', '2018-04-02 14:18:38'),
(2585, '36630-74PE0(7)-2-P', '81.374', '2018-04-02 14:18:38'),
(2586, '36630-74PF0(7)-2-P', '76.7993', '2018-04-02 14:18:38'),
(2587, '36630-74PG0(7)-2-P', '77.402', '2018-04-02 14:18:38'),
(2588, '36630-74PH0(7)-2-P', '91.4138', '2018-04-02 14:18:38'),
(2589, '36630-74PJ0(7)-2-P', '93.4786', '2018-04-02 14:18:38'),
(2590, '36630-74PK0(7)-2-P', '95.0856', '2018-04-02 14:18:38'),
(2591, '36630-74PL0(7)-2-P', '97.1523', '2018-04-02 14:18:38'),
(2592, '36882-74P00-6-P', '5.8294', '2018-04-02 14:18:38'),
(2593, '36843-74P00(1)-1-P', '16.2119', '2018-04-02 14:18:39'),
(2594, '36843-74P10(1)-1-P', '18.612', '2018-04-02 14:18:39'),
(2595, '36757-74P00(2)-P', '6.9094', '2018-04-02 14:18:39'),
(2596, '36757-74P10(2)-P', '9.1519', '2018-04-02 14:18:39'),
(2597, '36757-74P20(2)-P', '15.2974', '2018-04-02 14:18:39'),
(2598, '36757-74P40(2)-P', '12.8372', '2018-04-02 14:18:39'),
(2599, '36756-74P00(1)-3-P', '8.0908', '2018-04-02 14:18:39'),
(2600, '36756-74P10(1)-3-P', '17.4889', '2018-04-02 14:18:39'),
(2601, '36756-74P20(1)-3-P', '26.8505', '2018-04-02 14:18:39'),
(2602, '36756-74P30(1)-3-P', '13.8683', '2018-04-02 14:18:39'),
(2603, '36756-74P40(1)-3-P', '27.0129', '2018-04-02 14:18:39'),
(2604, '36680-74P00(1)-1-P', '15.3113', '2018-04-02 14:18:39'),
(2605, '36680-74P10(1)-1-P', '17.3411', '2018-04-02 14:18:39'),
(2606, '36680-74P20(1)-1-P', '18.7409', '2018-04-02 14:18:40'),
(2607, '36680-74P30(1)-1-P', '23.2949', '2018-04-02 14:18:40'),
(2608, '36680-74P50(1)-1-P', '17.3411', '2018-04-02 14:18:40'),
(2609, '33850-74P00(3)-P', '5.7', '2018-04-02 14:18:40'),
(2610, '33850-74P20(3)-P', '5.7091', '2018-04-02 14:18:40'),
(2611, '33880-54SC0(5)-P', '6.805', '2018-04-02 14:18:40'),
(2612, '33880-74PA0(3)-P', '6.6128', '2018-04-02 14:18:40'),
(2613, '33880-74PB0(3)-P', '6.4438', '2018-04-02 14:18:40'),
(2614, '33880-74PC0(3)-P', '6.3064', '2018-04-02 14:18:40'),
(2615, '36751-74P00(3)-P', '5.4565', '2018-04-02 14:18:40'),
(2616, '36751-74P10(3)-P', '9.1839', '2018-04-02 14:18:40'),
(2617, '36820-74P00(4)-1-P', '7.1172', '2018-04-02 14:18:41'),
(2618, '36820-74P10(4)-1-P', '10.6176', '2018-04-02 14:18:41'),
(2619, '36820-74P30(4)-1-P', '10.5904', '2018-04-02 14:18:41'),
(2620, '36690-79R00-1-P', '5.4771', '2018-04-02 14:18:41'),
(2621, '36602-79R00-5-P', '115.9409', '2018-04-02 14:18:41'),
(2622, '36602-79R20-5-P', '133.1426', '2018-04-02 14:18:41'),
(2623, '36620-79R00-5-P', '126.5269', '2018-04-02 14:18:41'),
(2624, '36620-79R10-5-P', '156.354', '2018-04-02 14:18:41'),
(2625, '36620-79R20-5-P', '137.3616', '2018-04-02 14:18:41'),
(2626, '36620-79R30-5-P', '165.6062', '2018-04-02 14:18:41'),
(2627, '36620-79R40-5-P', '134.9508', '2018-04-02 14:18:41'),
(2628, '36620-79R50-5-P', '163.4283', '2018-04-02 14:18:42'),
(2629, '36620-79R60-5-P', '140.6954', '2018-04-02 14:18:42'),
(2630, '36620-79R70-5-P', '168.4264', '2018-04-02 14:18:42'),
(2631, '36620-79R80-5-P', '150.9276', '2018-04-02 14:18:42'),
(2632, '36620-79R90-5-P', '178.092', '2018-04-02 14:18:42'),
(2633, '36620-79RA0-5-P', '148.7466', '2018-04-02 14:18:42'),
(2634, '36620-79RB0-5-P', '175.7654', '2018-04-02 14:18:42'),
(2635, '36620-79RC0-5-P', '136.441', '2018-04-02 14:18:42'),
(2636, '36620-79RD0-5-P', '149.8917', '2018-04-02 14:18:42'),
(2637, '36620-79RE0-5-P', '134.2761', '2018-04-02 14:18:42'),
(2638, '36620-79RF0-5-P', '163.4838', '2018-04-02 14:18:42'),
(2639, '36620-79RG0-5-P', '144.3491', '2018-04-02 14:18:42'),
(2640, '36620-79RH0-5-P', '172.8919', '2018-04-02 14:18:42'),
(2641, '36620-79RJ0-5-P', '142.2825', '2018-04-02 14:18:43'),
(2642, '36620-79RK0-5-P', '170.8167', '2018-04-02 14:18:43'),
(2643, '36620-79RL0-5-P', '143.4504', '2018-04-02 14:18:43'),
(2644, '36920-79R00-5-P', '138.6888', '2018-04-02 14:18:43'),
(2645, '36920-79R10-5-P', '165.7904', '2018-04-02 14:18:43'),
(2646, '36920-79R20-5-P', '136.6222', '2018-04-02 14:18:43'),
(2647, '36920-79R30-5-P', '163.6121', '2018-04-02 14:18:43'),
(2648, '36920-79R40-5-P', '152.2786', '2018-04-02 14:18:43'),
(2649, '36920-79R50-5-P', '178.2785', '2018-04-02 14:18:43'),
(2650, '36920-79R60-5-P', '150.0749', '2018-04-02 14:18:43'),
(2651, '36920-79R70-5-P', '175.9511', '2018-04-02 14:18:44'),
(2652, '36920-79R80-5-P', '138.5809', '2018-04-02 14:18:44'),
(2653, '36920-79R90-5-P', '165.548', '2018-04-02 14:18:44'),
(2654, '36920-79RA0-5-P', '152.1672', '2018-04-02 14:18:44'),
(2655, '36920-79RB0-5-P', '178.1598', '2018-04-02 14:18:44'),
(2656, '36920-79RC0-5-P', '145.9226', '2018-04-02 14:18:44'),
(2657, '36920-79RD0-5-P', '172.9624', '2018-04-02 14:18:44'),
(2658, '36603-79R00-5-P', '110.5068', '2018-04-02 14:18:44'),
(2659, '36603-79R10-5-P', '124.2282', '2018-04-02 14:18:45'),
(2660, '36603-79R20-5-P', '111.6363', '2018-04-02 14:18:45'),
(2661, '36603-79R30-5-P', '125.3913', '2018-04-02 14:18:45'),
(2662, '36630-79R00-5-P', '148.1045', '2018-04-02 14:18:45'),
(2663, '36630-79R10-5-P', '143.5608', '2018-04-02 14:18:45'),
(2664, '36630-79R20-5-P', '161.742', '2018-04-02 14:18:45'),
(2665, '36630-79R40-5-P', '150.5657', '2018-04-02 14:18:45'),
(2666, '36630-79R60-5-P', '164.601', '2018-04-02 14:18:46'),
(2667, '36630-79R70-5-P', '154.2986', '2018-04-02 14:18:46'),
(2668, '36630-79R80-5-P', '168.2402', '2018-04-02 14:18:46'),
(2669, '36630-79R90-5-P', '130.8025', '2018-04-02 14:18:46'),
(2670, '36630-79RA0-5-P', '148.1488', '2018-04-02 14:18:46'),
(2671, '36630-79RB0-5-P', '144.7295', '2018-04-02 14:18:46'),
(2672, '36630-79RC0-5-P', '161.7861', '2018-04-02 14:18:46'),
(2673, '36630-79RE0-5-P', '152.7313', '2018-04-02 14:18:46'),
(2674, '36630-79RG0-5-P', '166.7794', '2018-04-02 14:18:46'),
(2675, '36630-79RH0-5-P', '156.4632', '2018-04-02 14:18:47'),
(2676, '36630-79RJ0-5-P', '170.4183', '2018-04-02 14:18:47'),
(2677, '36630-79RK0-5-P', '129.6723', '2018-04-02 14:18:47'),
(2678, '36630-79RL0-5-P', '132.0638', '2018-04-02 14:18:47'),
(2679, '36650-79R00-7-P', '131.8753', '2018-04-02 14:18:47'),
(2680, '36650-79R10-7-P', '127.9728', '2018-04-02 14:18:48'),
(2681, '36650-79R20-7-P', '117.2665', '2018-04-02 14:18:48'),
(2682, '36813-79R00-2-P', '20.728', '2018-04-02 14:18:48'),
(2683, '36757-79R00-3-P', '14.7281', '2018-04-02 14:18:48'),
(2684, '36757-79R20-3-P', '17.4498', '2018-04-02 14:18:48'),
(2685, '36757-79R30-3-P', '23.5614', '2018-04-02 14:18:48'),
(2686, '36757-79R40-3-P', '20.9705', '2018-04-02 14:18:48'),
(2687, '36757-79R50-3-P', '25.1478', '2018-04-02 14:18:48'),
(2688, '36757-79R60-3-P', '19.3663', '2018-04-02 14:18:48'),
(2689, '36757-79R70-3-P', '21.7625', '2018-04-02 14:18:48'),
(2690, '36756-79R00-5-P', '28.9102', '2018-04-02 14:18:48'),
(2691, '36756-79R20-5-P', '30.8564', '2018-04-02 14:18:48'),
(2692, '36756-79R30-5-P', '34.0097', '2018-04-02 14:18:49'),
(2693, '36756-79R40-5-P', '28.9929', '2018-04-02 14:18:49'),
(2694, '36756-79R50-5-P', '34.1922', '2018-04-02 14:18:49'),
(2695, '36756-79R60-5-P', '32.598', '2018-04-02 14:18:49'),
(2696, '36756-79R70-5-P', '35.7518', '2018-04-02 14:18:49'),
(2697, '36756-79R80-5-P', '30.9071', '2018-04-02 14:18:49'),
(2698, '36756-79R90-5-P', '32.2778', '2018-04-02 14:18:49'),
(2699, '36680-79R00-3-P', '25.0914', '2018-04-02 14:18:49'),
(2700, '36680-79R20-3-P', '28.5653', '2018-04-02 14:18:50'),
(2701, '36680-79R30-3-P', '32.5027', '2018-04-02 14:18:50'),
(2702, '33880-79R00-2-P', '6.3408', '2018-04-02 14:18:50'),
(2703, '36813-79R50-1-P', '3.6734', '2018-04-02 14:18:50'),
(2704, '36751-79R00-4-P', '6.5581', '2018-04-02 14:18:50'),
(2705, '36751-79R10-4-P', '11.8745', '2018-04-02 14:18:50'),
(2706, '36751-79RC0-4-P', '11.8745', '2018-04-02 14:18:50'),
(2707, '36820-79R00-4-P', '17.824', '2018-04-02 14:18:50'),
(2708, '36820-79R10-4-P', '20.0289', '2018-04-02 14:18:51'),
(2709, '36820-79R20-4-P', '21.4683', '2018-04-02 14:18:51'),
(2710, '36820-79R30-4-P', '23.1514', '2018-04-02 14:18:51'),
(2711, '36820-79R40-4-P', '21.3683', '2018-04-02 14:18:51'),
(2712, '36820-79R50-4-P', '22.8198', '2018-04-02 14:18:51'),
(2713, '36820-79R60-4-P', '24.4964', '2018-04-02 14:18:51'),
(2714, '36820-79R70-4-P', '25.957', '2018-04-02 14:18:51'),
(2715, 'YHB-FLR-AL0-1', '1.4131', '2018-04-02 14:18:52'),
(2716, 'YHB-FLR-AL1-1', '1.7569', '2018-04-02 14:18:52'),
(2717, '36603-57S20-1-P', '151.5217', '2018-04-02 14:18:52'),
(2718, '36603-57S60-1-P', '164.3558', '2018-04-02 14:18:52'),
(2719, '36603-57S80-1-P', '187.7009', '2018-04-02 14:18:52'),
(2720, '36603-81P20(11)-1-P', '147.4722', '2018-04-02 14:18:52'),
(2721, '36603-81P40(11)-1-P', '155.7571', '2018-04-02 14:18:52'),
(2722, '36630-57S00-1-P', '106.633', '2018-04-02 14:18:53'),
(2723, '36630-57S10-1-P', '109.763', '2018-04-02 14:18:53'),
(2724, '36630-57S20-1-P', '120.092', '2018-04-02 14:18:53'),
(2725, '36630-57S30-1-P', '123.2372', '2018-04-02 14:18:53'),
(2726, '36630-57SC0-1-P', '128.2246', '2018-04-02 14:18:53'),
(2727, '36630-57SD0-1-P', '128.942', '2018-04-02 14:18:53'),
(2728, '36630-57SE0-1-P', '134.4272', '2018-04-02 14:18:53'),
(2729, '36630-57SG0-1-P', '136.3876', '2018-04-02 14:18:53'),
(2730, '36630-57SH0-1-P', '141.678', '2018-04-02 14:18:53'),
(2731, '36630-57SJ0-1-P', '142.4932', '2018-04-02 14:18:53'),
(2732, '36630-57SK0-1-P', '165.0457', '2018-04-02 14:18:53'),
(2733, '36630-57SL0-1-P', '167.0155', '2018-04-02 14:18:54'),
(2734, '36630-81P00(11)-1-P', '103.7299', '2018-04-02 14:18:54'),
(2735, '36630-81P10(11)-1-P', '107.4616', '2018-04-02 14:18:54'),
(2736, '36630-81PC0(11)-1-P', '124.6417', '2018-04-02 14:18:54'),
(2737, '36630-81PD0(11)-1-P', '125.9594', '2018-04-02 14:18:54'),
(2738, '36630-81PE0(11)-1-P', '132.8181', '2018-04-02 14:18:54'),
(2739, '36630-81PG0(11)-1-P', '135.0664', '2018-04-02 14:18:54'),
(2740, '36630-81PJ0(11)-1-P', '104.7699', '2018-04-02 14:18:54'),
(2741, '36630-81PK0(11)-1-P', '123.2589', '2018-04-02 14:18:54'),
(2742, '36630-81PL0(11)-1-P', '124.5771', '2018-04-02 14:18:54'),
(2743, '36882-81P00(2)-P', '7.4259', '2018-04-02 14:18:54'),
(2744, '36843-57S00-1-P', '22.1444', '2018-04-02 14:18:54'),
(2745, '36843-57S10-1-P', '22.5309', '2018-04-02 14:18:54'),
(2746, '36843-57SA0-P', '3.5165', '2018-04-02 14:18:55'),
(2747, '36757-81P00(3)-2-P', '15.8466', '2018-04-02 14:18:55'),
(2748, '36757-81P10(3)-2-P', '19.8524', '2018-04-02 14:18:55'),
(2749, '36757-81P20(3)-2-P', '16.1391', '2018-04-02 14:18:55'),
(2750, '36757-81P30(3)-2-P', '20.1261', '2018-04-02 14:18:55'),
(2751, '36756-57S00-1-P', '29.8515', '2018-04-02 14:18:55'),
(2752, '36756-57S10-1-P', '33.068', '2018-04-02 14:18:55'),
(2753, '36756-57S20-1-P', '28.3554', '2018-04-02 14:18:55'),
(2754, '36756-57S30-1-P', '31.6998', '2018-04-02 14:18:56'),
(2755, '36756-81P00(3)-3-P', '29.6928', '2018-04-02 14:18:56'),
(2756, '36756-81P10(3)-3-P', '32.9313', '2018-04-02 14:18:56'),
(2757, '36756-81P20(3)-3-P', '28.2191', '2018-04-02 14:18:56'),
(2758, '36756-81P30(3)-3-P', '31.5635', '2018-04-02 14:18:56'),
(2759, '36680-57S00-1-P', '28.8676', '2018-04-02 14:18:56'),
(2760, '36680-57S10-1-P', '33.0232', '2018-04-02 14:18:56'),
(2761, '36680-81P00(1)-3-P', '28.9743', '2018-04-02 14:18:56'),
(2762, '36680-81P10(1)-3-P', '33.1266', '2018-04-02 14:18:56'),
(2763, '36680-81PH0(1)-3-P', '28.9743', '2018-04-02 14:18:56'),
(2764, '36751-81P00(1)-1-P', '5.948', '2018-04-02 14:18:56'),
(2765, '36751-81P20(1)-1-P', '11.2419', '2018-04-02 14:18:57'),
(2766, '36751-81PA0(2)-1-P', '5.948', '2018-04-02 14:18:57'),
(2767, '36751-81PC0(2)-1-P', '11.2419', '2018-04-02 14:18:57'),
(2768, '36620-80P00(5)-1-P', '107.1365', '2018-04-02 14:18:57'),
(2769, '36620-80P10(5)-1-P', '110.1161', '2018-04-02 14:18:57'),
(2770, '36620-80P20(5)-1-P', '134.8085', '2018-04-02 14:18:57'),
(2771, '36620-80P30(5)-1-P', '137.5063', '2018-04-02 14:18:57'),
(2772, '36620-80P40(5)-1-P', '104.6229', '2018-04-02 14:18:58'),
(2773, '36620-80P50(5)-1-P', '107.4454', '2018-04-02 14:18:58'),
(2774, '36620-80P60(5)-1-P', '132.1178', '2018-04-02 14:18:58'),
(2775, '36620-80P70(5)-1-P', '135.0056', '2018-04-02 14:18:58'),
(2776, '36620-80P80(5)-1-P', '117.0305', '2018-04-02 14:18:58'),
(2777, '36620-80P90(5)-1-P', '119.8513', '2018-04-02 14:18:58'),
(2778, '36620-80PA0(5)-1-P', '143.9833', '2018-04-02 14:18:58'),
(2779, '36620-80PB0(5)-1-P', '146.8367', '2018-04-02 14:18:58'),
(2780, '36620-80PC0(5)-1-P', '105.3084', '2018-04-02 14:18:58'),
(2781, '36620-80PD0(5)-1-P', '110.1863', '2018-04-02 14:18:59'),
(2782, '36620-80PJ0(5)-1-P', '118.3491', '2018-04-02 14:18:59'),
(2783, '36620-80PK0(5)-1-P', '144.9566', '2018-04-02 14:18:59'),
(2784, '36630-80P00(4)-1-P', '97.0477', '2018-04-02 14:18:59'),
(2785, '36630-80P00(5)-P', '96.8437', '2018-04-02 14:18:59'),
(2786, '36630-80P10(4)-1-P', '97.6903', '2018-04-02 14:18:59'),
(2787, '36630-80P10(5)-P', '97.4863', '2018-04-02 14:18:59'),
(2788, '36630-80P20(4)-1-P', '100.3731', '2018-04-02 14:18:59'),
(2789, '36630-80P20(5)-P', '100.1691', '2018-04-02 14:19:00'),
(2790, '36630-80P30(4)-1-P', '101.0154', '2018-04-02 14:19:00'),
(2791, '36630-80P30(5)-P', '100.8114', '2018-04-02 14:19:00'),
(2792, '36630-80P40(4)-1-P', '99.3841', '2018-04-02 14:19:00'),
(2793, '36630-80P40(5)-P', '99.1802', '2018-04-02 14:19:00'),
(2794, '36630-80P50(4)-1-P', '102.1942', '2018-04-02 14:19:00'),
(2795, '36630-80P50(5)-P', '101.9903', '2018-04-02 14:19:00'),
(2796, '36630-80P60(4)-1-P', '102.754', '2018-04-02 14:19:00'),
(2797, '36630-80P60(5)-P', '102.5501', '2018-04-02 14:19:01'),
(2798, '36630-80P70(4)-1-P', '105.6696', '2018-04-02 14:19:01'),
(2799, '36630-80P70(5)-P', '105.4657', '2018-04-02 14:19:01'),
(2800, '36630-80P80(4)-1-P', '91.1731', '2018-04-02 14:19:01'),
(2801, '36630-80P80(5)-P', '90.9691', '2018-04-02 14:19:02'),
(2802, '36630-80P90(4)-1-P', '91.8003', '2018-04-02 14:19:02'),
(2803, '36630-80P90(5)-P', '91.5963', '2018-04-02 14:19:02'),
(2804, '36630-80PE0(4)-1-P', '100.0265', '2018-04-02 14:19:02'),
(2805, '36630-80PE0(5)-P', '99.8226', '2018-04-02 14:19:02'),
(2806, '36630-80PF0(4)-1-P', '103.5013', '2018-04-02 14:19:02'),
(2807, '36630-80PF0(5)-P', '103.2974', '2018-04-02 14:19:03'),
(2808, '39312-80P00-1-P', '1.4137', '2018-04-02 14:19:03'),
(2809, '36680-80P00(1)-1-P', '19.2136', '2018-04-02 14:19:03'),
(2810, '36680-80P10(1)-1-P', '20.8411', '2018-04-02 14:19:03'),
(2811, '36680-80P20(1)-1-P', '23.4306', '2018-04-02 14:19:03'),
(2812, '36680-80P30(1)-1-P', '24.9685', '2018-04-02 14:19:03'),
(2813, '36820-80P00-4-P', '12.9387', '2018-04-02 14:19:03'),
(2814, '36820-80P10-4-P', '14.4386', '2018-04-02 14:19:03'),
(2815, '36820-80P20-4-P', '17.3498', '2018-04-02 14:19:03'),
(2816, '36820-80P30-4-P', '19.1002', '2018-04-02 14:19:03'),
(2817, '36620-52R00(4)-1-P', '120.3631', '2018-04-02 14:19:04'),
(2818, '36620-52R20(4)-1-P', '134.5112', '2018-04-02 14:19:04'),
(2819, '36620-52R30(4)-1-P', '158.6002', '2018-04-02 14:19:04'),
(2820, '36620-52R40(4)-1-P', '130.2718', '2018-04-02 14:19:04'),
(2821, '36620-52R50(4)-1-P', '157.4631', '2018-04-02 14:19:04'),
(2822, '36620-52R80(4)-1-P', '145.3479', '2018-04-02 14:19:04'),
(2823, '36620-52R90(4)-1-P', '169.4942', '2018-04-02 14:19:04'),
(2824, '36620-52RA0(4)-1-P', '139.5881', '2018-04-02 14:19:04'),
(2825, '36620-52RB0(4)-1-P', '164.3363', '2018-04-02 14:19:04'),
(2826, '36620-52RC0(4)-1-P', '126.72', '2018-04-02 14:19:04'),
(2827, '36620-52RG0(4)-1-P', '136.7101', '2018-04-02 14:19:04'),
(2828, '36620-52RH0(4)-1-P', '159.6639', '2018-04-02 14:19:04'),
(2829, '36620-52RL0(4)-1-P', '147.5639', '2018-04-02 14:19:04'),
(2830, '36620-52RM0(4)-1-P', '170.5466', '2018-04-02 14:19:04'),
(2831, '36620-52RP0(4)-1-P', '136.2511', '2018-04-02 14:19:04'),
(2832, '36620-52RQ0(4)-1-P', '126.9375', '2018-04-02 14:19:04'),
(2833, '36620-52RR0(4)-1-P', '140.1132', '2018-04-02 14:19:04'),
(2834, '36602-53R00(4)-1-P', '92.3027', '2018-04-02 14:19:04'),
(2835, '36602-53R10(4)-1-P', '110.117', '2018-04-02 14:19:04'),
(2836, '36602-53R20(4)-1-P', '115.154', '2018-04-02 14:19:04'),
(2837, '36602-53R30(4)-1-P', '102.0948', '2018-04-02 14:19:05'),
(2838, '36602-53R40(4)-1-P', '117.6787', '2018-04-02 14:19:05'),
(2839, '36602-53R51(4)-1-P', '122.2367', '2018-04-02 14:19:05'),
(2840, '36602-53R70(4)-1-P', '126.0155', '2018-04-02 14:19:05'),
(2841, '36602-53R80(4)-1-P', '131.5978', '2018-04-02 14:19:05'),
(2842, '36602-53R90(4)-1-P', '138.4897', '2018-04-02 14:19:05'),
(2843, '36602-53RC0(4)-1-P', '144.4229', '2018-04-02 14:19:05'),
(2844, '36602-53RD0(4)-1-P', '148.0792', '2018-04-02 14:19:05'),
(2845, '36602-53RE0(4)-1-P', '147.5352', '2018-04-02 14:19:05'),
(2846, '36602-53RF0(4)-1-P', '151.0847', '2018-04-02 14:19:05'),
(2847, '36602-53RG0(4)-1-P', '111.2138', '2018-04-02 14:19:05'),
(2848, '36602-53RH0(4)-1-P', '127.523', '2018-04-02 14:19:05'),
(2849, '36602-53RJ1(4)-1-P', '123.1521', '2018-04-02 14:19:05'),
(2850, '36602-53RK1(4)-1-P', '126.1193', '2018-04-02 14:19:05'),
(2851, '36602-53RL0(4)-1-P', '119.63', '2018-04-02 14:19:05'),
(2852, '36602-68R00(1)-1-P', '137.7009', '2018-04-02 14:19:05'),
(2853, '36602-68R10(1)-1-P', '141.2468', '2018-04-02 14:19:05'),
(2854, '36602-68R40(1)-1-P', '143.702', '2018-04-02 14:19:05'),
(2855, '36602-68R50(1)-1-P', '147.2494', '2018-04-02 14:19:05'),
(2856, '36602-68R60(1)-1-P', '147.1227', '2018-04-02 14:19:05'),
(2857, '36602-68R70(1)-1-P', '150.6469', '2018-04-02 14:19:06'),
(2858, '36602-68R80(1)-1-P', '124.5146', '2018-04-02 14:19:06'),
(2859, '36602-68R90(1)-1-P', '131.541', '2018-04-02 14:19:06'),
(2860, '36620-53R20(4)-1-P', '111.8989', '2018-04-02 14:19:06'),
(2861, '36620-53R30(4)-1-P', '120.7372', '2018-04-02 14:19:06'),
(2862, '36620-53R40(4)-1-P', '103.0773', '2018-04-02 14:19:06'),
(2863, '36620-53R50(4)-1-P', '119.9106', '2018-04-02 14:19:06'),
(2864, '36620-53R60(4)-1-P', '122.8723', '2018-04-02 14:19:06'),
(2865, '36620-53R70(4)-1-P', '126.8437', '2018-04-02 14:19:06'),
(2866, '36620-53R90(4)-1-P', '143.3438', '2018-04-02 14:19:06'),
(2867, '36620-53RA0(4)-1-P', '123.2339', '2018-04-02 14:19:06'),
(2868, '36620-53RB0(4)-1-P', '146.3736', '2018-04-02 14:19:06'),
(2869, '36620-53RC0(4)-1-P', '150.0891', '2018-04-02 14:19:06'),
(2870, '36620-53RD0(4)-1-P', '149.5515', '2018-04-02 14:19:06'),
(2871, '36620-53RE0(4)-1-P', '153.2927', '2018-04-02 14:19:06'),
(2872, '36620-53RF0(4)-1-P', '115.7889', '2018-04-02 14:19:06'),
(2873, '36620-53RG0(4)-1-P', '124.3204', '2018-04-02 14:19:06'),
(2874, '36620-53RH0(4)-1-P', '123.5191', '2018-04-02 14:19:07'),
(2875, '36620-53RJ0(4)-1-P', '126.7794', '2018-04-02 14:19:07'),
(2876, '36620-68R00(1)-1-P', '130.3785', '2018-04-02 14:19:07'),
(2877, '36620-68R10(1)-1-P', '142.9678', '2018-04-02 14:19:07'),
(2878, '36620-68R20(1)-1-P', '167.2029', '2018-04-02 14:19:07'),
(2879, '36620-68R50(1)-1-P', '139.751', '2018-04-02 14:19:07'),
(2880, '36620-68R60(1)-1-P', '143.3365', '2018-04-02 14:19:07'),
(2881, '36620-68R70(1)-1-P', '140.632', '2018-04-02 14:19:07'),
(2882, '36620-68R80(1)-1-P', '144.3436', '2018-04-02 14:19:07'),
(2883, '36620-68R90(1)-1-P', '145.6514', '2018-04-02 14:19:07'),
(2884, '36620-68RA0(1)-1-P', '149.3923', '2018-04-02 14:19:07'),
(2885, '36620-68RB0(1)-1-P', '149.0573', '2018-04-02 14:19:07'),
(2886, '36620-68RC0(1)-1-P', '152.6435', '2018-04-02 14:19:08'),
(2887, 'YSD-LHD-AL1-1', '1.1234', '2018-04-02 14:19:08'),
(2888, 'YSD-LHD-CI1-1', '1.5943', '2018-04-02 14:19:08'),
(2889, 'YSD-RHD-AL1', '1.1967', '2018-04-02 14:19:08'),
(2890, 'YSD-RHD-CI1-1', '1.5959', '2018-04-02 14:19:08'),
(2891, 'YSD-RHD-CI2-1', '2.3607', '2018-04-02 14:19:08'),
(2892, '36602-57R00-3-P', '99.7771', '2018-04-02 14:19:08'),
(2893, '36602-57R10-3-P', '123.0411', '2018-04-02 14:19:08'),
(2894, '36602-57R20-3-P', '118.7776', '2018-04-02 14:19:08'),
(2895, '36602-57R30-3-P', '95.7215', '2018-04-02 14:19:08'),
(2896, '36620-57R00-3-P', '90.8309', '2018-04-02 14:19:08'),
(2897, '36620-57R10-3-P', '102.5856', '2018-04-02 14:19:08'),
(2898, '36620-57R20-3-P', '126.2455', '2018-04-02 14:19:08'),
(2899, '36620-57R30-3-P', '100.4761', '2018-04-02 14:19:08'),
(2900, '36620-57R40-3-P', '123.042', '2018-04-02 14:19:08'),
(2901, '36620-57R50-3-P', '118.9583', '2018-04-02 14:19:08'),
(2902, '36620-57R60-3-P', '96.073', '2018-04-02 14:19:08'),
(2903, '36064-64P00(7)-1-P', '235.0483', '2018-04-02 14:19:08'),
(2904, '36064-64P10(7)-1-P', '248.8175', '2018-04-02 14:19:09'),
(2905, '36064-64P20(7)-1-P', '259.9513', '2018-04-02 14:19:09'),
(2906, '36064-64P30(7)-1-P', '257.2416', '2018-04-02 14:19:09'),
(2907, '36064-64P40(7)-1-P', '268.0393', '2018-04-02 14:19:09'),
(2908, '36064-64P50(7)-1-P', '252.9045', '2018-04-02 14:19:09'),
(2909, '36064-64P60(7)-1-P', '265.1987', '2018-04-02 14:19:09'),
(2910, '36064-64P70(7)-1-P', '260.2948', '2018-04-02 14:19:09'),
(2911, '36064-64P80(7)-1-P', '273.0351', '2018-04-02 14:19:09'),
(2912, '36064-64P90(7)-1-P', '232.7512', '2018-04-02 14:19:09'),
(2913, '36064-64PA0(7)-1-P', '219.886', '2018-04-02 14:19:09'),
(2914, '36064-64PB0(7)-1-P', '290.4986', '2018-04-02 14:19:09'),
(2915, '36064-64PC0(7)-1-P', '290.296', '2018-04-02 14:19:09'),
(2916, '36065-64P00(7)-1-P', '275.8671', '2018-04-02 14:19:09'),
(2917, '36065-64P10(7)-1-P', '275.8132', '2018-04-02 14:19:09');
INSERT INTO `eff_product_st` (`ID`, `product_no`, `st`, `last_update`) VALUES
(2918, '36065-64P20(7)-1-P', '301.6256', '2018-04-02 14:19:10'),
(2919, '36065-64P30(7)-1-P', '301.006', '2018-04-02 14:19:10'),
(2920, '36065-64P40(7)-1-P', '317.1614', '2018-04-02 14:19:10'),
(2921, '36065-64P50(7)-1-P', '316.8391', '2018-04-02 14:19:10'),
(2922, '36065-64P60(7)-1-P', '275.8655', '2018-04-02 14:19:10'),
(2923, '36065-64P70(7)-1-P', '275.5122', '2018-04-02 14:19:10'),
(2924, '36065-64P80(7)-1-P', '248.7321', '2018-04-02 14:19:10'),
(2925, '36065-64P90(7)-1-P', '260.1392', '2018-04-02 14:19:10'),
(2926, '36065-64PA0(7)-1-P', '260.9495', '2018-04-02 14:19:10'),
(2927, '36065-64PB0(7)-1-P', '259.664', '2018-04-02 14:19:10'),
(2928, '36065-64PC0(7)-1-P', '260.9425', '2018-04-02 14:19:10'),
(2929, '36065-64PD0(7)-1-P', '272.221', '2018-04-02 14:19:10'),
(2930, '36065-64PJ0(7)-1-P', '232.3028', '2018-04-02 14:19:10'),
(2931, '36065-64PK0(7)-1-P', '245.1717', '2018-04-02 14:19:10'),
(2932, '36065-64PL0(7)-1-P', '235.7124', '2018-04-02 14:19:10'),
(2933, '36065-64PM0(7)-1-P', '256.2566', '2018-04-02 14:19:10'),
(2934, '36065-64PP0(7)-1-P', '255.5707', '2018-04-02 14:19:11'),
(2935, '36065-64PQ0(7)-1-P', '244.3151', '2018-04-02 14:19:11'),
(2936, '36065-64PR0(7)-1-P', '256.4081', '2018-04-02 14:19:11'),
(2937, '36065-64PS0(7)-1-P', '248.2906', '2018-04-02 14:19:11'),
(2938, '36065-64PU0(7)-1-P', '260.6862', '2018-04-02 14:19:11'),
(2939, '36066-64P12(16)-P', '235.7409', '2018-04-02 14:19:11'),
(2940, '36066-64P32(16)-P', '262.0479', '2018-04-02 14:19:11'),
(2941, '36066-64P52(16)-P', '263.003', '2018-04-02 14:19:11'),
(2942, '36066-64PB2(16)-P', '269.6708', '2018-04-02 14:19:11'),
(2943, '36066-64PD2(16)-P', '274.6234', '2018-04-02 14:19:11'),
(2944, '36067-64P11(16)-P', '268.4048', '2018-04-02 14:19:11'),
(2945, '36067-64P52(16)-P', '273.3603', '2018-04-02 14:19:11'),
(2946, '36069-64P31(16)-P', '234.4751', '2018-04-02 14:19:11'),
(2947, '36069-64P51(16)-P', '260.7818', '2018-04-02 14:19:11'),
(2948, '36605-64P00(3)-2-P', '67.1774', '2018-04-02 14:19:11'),
(2949, '36605-64P10(3)-2-P', '65.2138', '2018-04-02 14:19:11'),
(2950, '36605-64P20(3)-2-P', '71.4127', '2018-04-02 14:19:11'),
(2951, '36605-64P30(3)-2-P', '69.668', '2018-04-02 14:19:11'),
(2952, '33840-64P00-5-P', '4.7231', '2018-04-02 14:19:12'),
(2953, '36810-64P00-5-P', '12.3635', '2018-04-02 14:19:12'),
(2954, '36611-64P00-4-P', '3.0743', '2018-04-02 14:19:12'),
(2955, '36757-64P00-8-P', '6.3694', '2018-04-02 14:19:12'),
(2956, '36757-64P10-8-P', '8.9013', '2018-04-02 14:19:12'),
(2957, '36757-64P20-8-P', '13.1899', '2018-04-02 14:19:12'),
(2958, '36757-64P30-8-P', '14.3619', '2018-04-02 14:19:12'),
(2959, '36757-64P40-8-P', '14.6439', '2018-04-02 14:19:12'),
(2960, '36756-64P00(1)-2-P', '7.1311', '2018-04-02 14:19:12'),
(2961, '36756-64P10(1)-2-P', '13.9786', '2018-04-02 14:19:12'),
(2962, '36756-64P20(1)-2-P', '26.6851', '2018-04-02 14:19:13'),
(2963, '36756-64P30(1)-2-P', '27.8866', '2018-04-02 14:19:13'),
(2964, '36756-64P40(1)-2-P', '26.4356', '2018-04-02 14:19:13'),
(2965, '36756-64P50(1)-2-P', '6.7083', '2018-04-02 14:19:13'),
(2966, '36680-64P00(3)-P', '14.9405', '2018-04-02 14:19:13'),
(2967, '36680-64P10(3)-P', '18.0376', '2018-04-02 14:19:13'),
(2968, '36680-64P20(3)-P', '22.2119', '2018-04-02 14:19:13'),
(2969, '36680-64PA0(3)-P', '15.6854', '2018-04-02 14:19:13'),
(2970, '36680-64PB0(3)-P', '18.7774', '2018-04-02 14:19:13'),
(2971, '36680-64PC0(3)-P', '22.9462', '2018-04-02 14:19:13'),
(2972, '33880-64P00(6)-P', '12.4873', '2018-04-02 14:19:13'),
(2973, '33880-64P10(6)-P', '12.424', '2018-04-02 14:19:13'),
(2974, '33880-64P20(6)-P', '12.522', '2018-04-02 14:19:13'),
(2975, '33880-64P30(6)-P', '12.7052', '2018-04-02 14:19:13'),
(2976, '33880-64P40(6)-P', '13.4331', '2018-04-02 14:19:13'),
(2977, '33880-64P50(6)-P', '13.6164', '2018-04-02 14:19:13'),
(2978, '36658-64P00(1)-1-P', '8.2699', '2018-04-02 14:19:13'),
(2979, '36820-64P00(5)-1-P', '13.437', '2018-04-02 14:19:13'),
(2980, '36820-64P10(5)-1-P', '16.244', '2018-04-02 14:19:13'),
(2981, '36820-64P20(5)-1-P', '29.3782', '2018-04-02 14:19:13'),
(2982, '36820-64P40(5)-1-P', '32.9608', '2018-04-02 14:19:14'),
(2983, '36820-64PA0(5)-1-P', '13.5129', '2018-04-02 14:19:14'),
(2984, '36820-64PB0(5)-1-P', '16.5035', '2018-04-02 14:19:14'),
(2985, '36820-64PC0(5)-1-P', '29.1297', '2018-04-02 14:19:14'),
(2986, '36820-64PE0(5)-1-P', '32.7074', '2018-04-02 14:19:14'),
(2987, '33880-63RC0-1-P', '6.7141', '2018-04-02 14:19:14'),
(2988, '91311-81PP0-4-P', '4.1142', '2018-04-02 14:19:14'),
(2989, '91312-81PP0-3-P', '2.7617', '2018-04-02 14:19:14'),
(2990, '91315-81PP0-2-P', '4.5068', '2018-04-02 14:19:14'),
(2991, '96461-81PP0(1)-1-P', '14.905', '2018-04-02 14:19:14'),
(2992, '96562-81PP0-6-P', '2.6402', '2018-04-02 14:19:14'),
(2993, '96564-81PP0-3-P', '6.7616', '2018-04-02 14:19:14'),
(2994, '96572-81PP0-6-P', '5.059', '2018-04-02 14:19:14'),
(2995, '96574-81PP0-2-P', '5.986', '2018-04-02 14:19:14'),
(2996, '24011-1A27A-0301P4', '124.0756', '2018-04-02 14:19:14'),
(2997, '24011-5WH1A-0100P3', '204.4097', '2018-04-02 14:19:14'),
(2998, '24011-5WJ0A-0000P2', '158.4783', '2018-04-02 14:19:14'),
(2999, '24011-5WJ0B-0000P2', '154.8057', '2018-04-02 14:19:14'),
(3000, '24011-5WK0A-050101', '165.6857', '2018-04-02 14:19:14'),
(3001, '24079-5WK0A-0200', '3.3279', '2018-04-02 14:19:14'),
(3002, '32107-TAA-N712-AL', '270.4967', NULL),
(3003, '32107-TAD-N303-AL', '251.3211', NULL),
(3004, '32107-TAD-F903-AL', '265.0787', NULL);

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
-- Indexes for table `eff_car_model_cycle`
--
ALTER TABLE `eff_car_model_cycle`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `car_model_id` (`car_model_id`),
  ADD KEY `shift_id` (`shift_id`);

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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;
--
-- AUTO_INCREMENT for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;
--
-- AUTO_INCREMENT for table `eff_3_extended_wt`
--
ALTER TABLE `eff_3_extended_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;
--
-- AUTO_INCREMENT for table `eff_account`
--
ALTER TABLE `eff_account`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;
--
-- AUTO_INCREMENT for table `eff_account_type`
--
ALTER TABLE `eff_account_type`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `eff_batch_control`
--
ALTER TABLE `eff_batch_control`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=310;
--
-- AUTO_INCREMENT for table `eff_batch_group`
--
ALTER TABLE `eff_batch_group`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT for table `eff_car_model`
--
ALTER TABLE `eff_car_model`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `eff_car_model_cycle`
--
ALTER TABLE `eff_car_model_cycle`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
--
-- AUTO_INCREMENT for table `eff_downtime`
--
ALTER TABLE `eff_downtime`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=521;
--
-- AUTO_INCREMENT for table `eff_product_st`
--
ALTER TABLE `eff_product_st`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3005;
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
-- Constraints for table `eff_car_model_cycle`
--
ALTER TABLE `eff_car_model_cycle`
  ADD CONSTRAINT `eff_car_model_cycle_ibfk_1` FOREIGN KEY (`car_model_id`) REFERENCES `eff_car_model` (`ID`),
  ADD CONSTRAINT `eff_car_model_cycle_ibfk_2` FOREIGN KEY (`shift_id`) REFERENCES `eff_shift` (`ID`);

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
