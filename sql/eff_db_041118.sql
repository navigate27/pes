-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 11, 2018 at 03:06 PM
-- Server version: 10.1.30-MariaDB
-- PHP Version: 7.2.1

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
(63, 8, 0, 0, 0, 0, '', 2, 306),
(64, 1, 5, 0, 0, 0, '', 2, 312),
(65, 2, 0, 0, 0, 0, '', 2, 312),
(66, 3, 0, 0, 0, 0, '', 2, 312),
(67, 4, 0, 0, 0, 0, '', 2, 312),
(68, 5, 0, 0, 0, 1, '', 2, 312),
(69, 6, 0, 0, 0, 1, '', 2, 312),
(70, 8, 0, 0, 0, 0, '', 2, 312),
(71, 1, 10, 0, 1, 0, '', 2, 313),
(72, 2, 1, 0, 0, 0, '', 2, 313),
(73, 3, 1, 0, 0, 0, '', 2, 313),
(74, 4, 4, 0, 0, 0, '', 2, 313),
(75, 5, 1, 0, 0, 1, '', 2, 313),
(76, 6, 2, 0, 0, 1, '', 2, 313),
(77, 8, 0, 0, 0, 0, '', 2, 313),
(78, 1, 19, 0, 0, 0, '', 2, 314),
(79, 2, 2, 0, 0, 0, '', 2, 314),
(80, 3, 3, 0, 0, 0, '', 2, 314),
(81, 4, 12, 0, 0, 0, '', 2, 314),
(82, 5, 2, 0, 0, 1, '', 2, 314),
(83, 6, 3, 0, 0, 1, '', 2, 314),
(84, 8, 0, 0, 0, 0, '', 2, 314),
(85, 1, 11, 1, 0, 0, '', 1, 315),
(86, 2, 1, 0, 0, 0, '', 1, 315),
(87, 3, 2, 0, 0, 0, '', 1, 315),
(88, 4, 1, 0, 0, 0, '', 1, 315),
(89, 5, 1, 0, 0, 1, '', 1, 315),
(90, 6, 1, 0, 0, 1, '', 1, 315),
(91, 8, 1, 0, 0, 0, '', 1, 315);

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
(36, 450, 0, 0, 0, 1, 0, 2, 306),
(37, 480, 0, 0, 0, 0, 1, 2, 312),
(38, 480, 0, 0, 0, 0, 0, 2, 312),
(39, 450, 0, 0, 0, 1, 1, 2, 312),
(40, 450, 0, 0, 0, 1, 0, 2, 312),
(41, 480, 0, 0, 0, 0, 1, 2, 313),
(42, 480, 0, 0, 0, 0, 0, 2, 313),
(43, 450, 0, 0, 0, 1, 1, 2, 313),
(44, 450, 0, 0, 0, 1, 0, 2, 313),
(45, 480, 0, 0, 0, 0, 1, 2, 314),
(46, 480, 0, 0, 0, 0, 0, 2, 314),
(47, 450, 0, 0, 0, 1, 1, 2, 314),
(48, 450, 0, 0, 0, 1, 0, 2, 314),
(49, 540, 0, 0, 0, 0, 1, 1, 315),
(50, 540, 0, 0, 0, 0, 0, 1, 315),
(51, 510, 0, 0, 0, 1, 1, 1, 315),
(52, 510, 0, 0, 0, 1, 0, 1, 315);

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
(63, 63, 0, 0, 0, 0),
(64, 64, 0, 0, 0, 0),
(65, 65, 0, 0, 0, 0),
(66, 66, 0, 0, 0, 0),
(67, 67, 0, 0, 0, 0),
(68, 68, 0, 0, 0, 0),
(69, 69, 0, 0, 0, 0),
(70, 70, 0, 0, 0, 0),
(71, 71, 0, 0, 0, 0),
(72, 72, 0, 0, 0, 0),
(73, 73, 0, 0, 0, 0),
(74, 74, 0, 0, 0, 0),
(75, 75, 1, 0, 0, 0),
(76, 76, 0, 0, 0, 0),
(77, 77, 0, 0, 0, 0),
(78, 78, 1, 0, 0, 0),
(79, 79, 0, 1, 0, 0),
(80, 80, 1, 0, 0, 0),
(81, 81, 0, 0, 1, 0),
(82, 82, 1, 0, 0, 0),
(83, 83, 1, 0, 0, 0),
(84, 84, 2, 0, 0, 0),
(85, 85, 2, 0, 0, 0),
(86, 86, 3, 0, 0, 0),
(87, 87, 1, 0, 0, 0),
(88, 88, 0, 0, 0, 0),
(89, 89, 0, 0, 0, 0),
(90, 90, 0, 0, 0, 0),
(91, 91, 0, 0, 0, 0);

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
(28, 'Jennie Rose', 'Baby', '080215', 2, NULL, NULL, NULL, 2, 2),
(30, 'Beverly Espiritu', 'Bev', '0505', 1, NULL, NULL, NULL, 2, 2),
(31, 'Renilyn Llanto', 'Arabella', '082512', 1, NULL, NULL, NULL, 2, 2),
(32, 'Darlyn Virrey', 'Darlyn', 'Virrey', 1, NULL, NULL, NULL, 2, 2),
(33, 'Jenny Ann Falogme', 'AnneJenny', '902104', 4, NULL, NULL, NULL, 2, 2),
(34, 'liezel d montealto', 'ezel', '090615', 7, NULL, NULL, NULL, 1, 2),
(35, 'Renilyn Llanto', 'Denisse', '082512', 4, NULL, NULL, NULL, 2, 2),
(37, 'Maricris Escarez', 'Yuan', 'maricris18', 2, NULL, NULL, NULL, 2, 2),
(38, 'Lanica Abanes', 'lanica', 'lyndsaymcknight', 5, NULL, NULL, NULL, 2, 2),
(39, 'Charmaine Malabuyoc', 'Charm', 'bigmama', 5, NULL, NULL, NULL, 2, 2),
(40, 'Rowena O. Alvarez', 'wena', '0526', 5, NULL, NULL, NULL, 2, 2),
(41, 'Mildred V. Lacorte', 'mildred', '040115', 6, NULL, NULL, NULL, 2, 2),
(42, 'Lizee Garcia', 'lizee', '012295', 6, NULL, NULL, NULL, NULL, 5),
(43, 'sample viewer', 'viewer', '123', 1, NULL, NULL, NULL, NULL, 5),
(44, 'Jasmine Titular', 'LexieAmarah', '022416', 7, NULL, NULL, NULL, 2, 2),
(45, 'Leah Namuco', 'Bhinene', '130448', 7, NULL, NULL, NULL, 2, 2),
(46, 'Glaiza Awat', 'Glaiza', '021290', 2, NULL, NULL, NULL, 1, 2),
(47, 'pdmazda', 'pdmazda', 'pdmazda', 7, NULL, NULL, NULL, 1, 2);

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
(5, 'Viewer');

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
(309, '2018-04-09', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 6, 26, 1),
(310, '2018-04-13', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, 30, 1),
(311, '2018-04-14', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 1, 30, 1),
(312, '2018-04-10', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 2, 2, NULL, 1),
(313, '2018-04-10', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 2, 1, NULL, 1),
(314, '2018-04-11', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 7, NULL, 1),
(315, '2018-04-11', NULL, '', '00:00:00', '00:00:00', '', '', '', '', 1, 2, NULL, 1);

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
(9, 100, 100, 105, 105, 306, 2),
(10, 99, 80, 77, 87, 312, 2),
(11, 150, 150, 150, 150, 313, 2),
(12, 130, 123, 135, 128, 314, 2),
(13, 130, 130, 120, 100, 315, 1);

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
(2, 1, 'NA', 'NA', 'NA', 1, 1, 'NA', '00:00:00', '00:00:00', 0, 0, 0, NULL, 107),
(3, 4, 'na', 'na', 'na', 4, 1, 'na', '23:20:00', '23:40:00', 20, 0, 1, NULL, 314),
(4, 4, 'NA', 'NA', 'NA', 4, 1, 'NA', '02:17:00', '02:19:00', 2, 0, 0, NULL, 315);

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
(519, '82415-B2551H-4', '8.4988', '40', '', 2, 308),
(626, '82118-B2Q30A-1', '187.4636', '57', '', 2, 313),
(627, '82141-BAE40B-3', '203.9545', '21', '', 2, 313),
(628, '82118-B2Q90A-1', '209.2025', '17', '', 2, 313),
(629, '82141-BAE10B-3', '182.8623', '60', '', 2, 313),
(630, '82118-B2R60A-1', '173.811', '12', '', 2, 313),
(631, '82118-B2P90A-1', '166.4979', '147', '', 2, 313),
(633, '82153-B2380N-6', '14.5347', '260', '', 2, 313),
(634, '82152-B2Q40N-5', '17.6098', '152', '', 2, 313),
(635, '82152-B2R90-5', '20.6907', '10', '', 2, 313),
(637, '82152-B2P70A-6', '20.8044', '20', '', 2, 313),
(638, '88648-B2550N-2', '19.3641', '440', '', 2, 313),
(641, '82151-B2L10B-1', '23.4759', '80', '', 2, 313),
(642, '82151-B2Q50-3', '28.5754', '10', '', 2, 313),
(643, '82151-B2Q30B-1', '28.6642', '20', '', 2, 313),
(644, '82151-B2Q40-3', '25.6278', '157', '', 2, 313),
(645, '82171-B2G70A-3', '13.9671', '240', '', 2, 313),
(646, '82171-B2J10-4', '14.1134', '160', '', 2, 313),
(647, '82415-B2530K-5', '6.8769', '430', '', 2, 313),
(650, '82219-B2060J-2', '3.0852', '600', '', 2, 313),
(651, '82152-B2P80A-6', '', '80', '', 2, 313),
(750, '32109-TTA-9003-2', '30.919', '180', '', 1, 315),
(751, '32754-TTA-0002', '22.5827', '190', '', 1, 315),
(752, '32752-TTA-9203-1', '26.8363', '72', '', 1, 315),
(753, '32751-TTA-0003-1', '35.9309', '120', '', 1, 315),
(754, '32753-TTA-0001-3', '12.8276', '160', '', 1, 315),
(755, '32751-TTA-9003-1', '39.2863', '120', '', 1, 315),
(756, '32155-TTA-9203-2', '18.3753', '200', '', 1, 315),
(757, '32752-TTA-0003-1', '24.0021', '174', '', 1, 315),
(758, 'BALV-67-130(0)-8', '15.5077', '20', '', NULL, 314),
(759, 'GBJW-67-190(6)-2', '32.1464', '16', '', NULL, 314),
(760, 'GBEF-67-190(6)-2', '36.5363', '112', '', NULL, 314),
(761, 'GCAH-67-190(6)-2', '34.7452', '16', '', NULL, 314),
(762, 'GCAH-67-200(6)-2', '30.1052', '16', '', NULL, 314),
(763, 'GBJE-67-200(6)-2', '29.9889', '16', '', NULL, 314),
(764, 'GBVG-67-200(7)-1', '36.6589', '24', '', NULL, 314),
(765, 'GCBL-67-200(9)-1', '31.0882', '16', '', NULL, 314),
(766, 'GBEF-67-200(6)-2', '32.8024', '80', '', NULL, 314),
(767, 'GMD9-67-200A(7)-1', '25.1519', '1', '', NULL, 314),
(768, 'GRK7-67-190A(13)-1', '31.559', '24', '', NULL, 314),
(769, 'GJS1-67-220A(9)-1-P', '15.9652', '15', '', NULL, 314),
(770, 'GHK1-67-220A(9)-1-P', '16.2346', '30', '', NULL, 314),
(771, 'G52N-67-220(2)-3', '18.1782', '45', '', NULL, 314),
(772, 'GBFT-67-220(2)-3', '18.4509', '75', '', NULL, 314),
(773, 'GBEF-67-220(4)-2', '18.5244', '180', '', NULL, 314),
(774, 'G52D-67-220(4)-2', '18.2453', '15', '', NULL, 314),
(775, 'GBFW-67-220(4)-2', '18.8199', '30', '', NULL, 314),
(776, 'GBVR-67-190(8)-1', '38.5957', '8', '', NULL, 314),
(777, 'G52N-67-190(7)-2', '31.6613', '16', '', NULL, 314),
(778, 'BAMF-67-130(2)-7', '30.3696', '10', '', NULL, 314),
(779, 'BABG-67-130(0)-8', '26.7375', '60', '', NULL, 314),
(780, 'BABJ-67-130(2)-7', '29.9982', '10', '', NULL, 314),
(781, 'BALK-67-130(0)-7', '18.3851', '10', '', NULL, 314),
(782, 'B62T-67-130(0)-7', '20.2338', '10', '', NULL, 314),
(783, 'BSR4-67-130(2)-7', '25.9156', '10', '', NULL, 314),
(784, 'BSR6-67-130(2)-7', '28.9506', '10', '', NULL, 314),
(785, 'B63F-67-130(2)-7', '24.4047', '105', '', NULL, 314),
(786, 'GCAM-67-130(8)-2', '29.4044', '10', '', NULL, 314),
(787, 'GBWD-67-130(8)-1', '32.3024', '20', '', NULL, 314),
(788, 'GCAS-67-130(8)-2', '32.5327', '20', '', NULL, 314),
(789, 'B63E-67-190(4)-4', '26.3475', '56', '', NULL, 314),
(790, 'KL2F-67-190(12)-4', '32.1551', '190', '', NULL, 314),
(791, 'KL2T-67-190(12)-3', '29.7664', '48', '', NULL, 314),
(792, 'KL2F-67-200(12)-5', '28.0912', '194', '', NULL, 314),
(793, 'KL2T-67-200(12)-5', '25.7051', '40', '', NULL, 314),
(794, 'B63C-67-190(10)-1', '33.7063', '32', '', NULL, 314),
(795, 'KB9N-67-190A(13)-5', '32.3282', '120', '', NULL, 314),
(796, 'BAMB-67-130(2)-7', '26.3731', '40', '', NULL, 314),
(797, 'GBJE-67-130A(8)-2', '29.9768', '20', '', NULL, 314),
(798, 'KF1H-67-190A(12)-3', '30.3572', '104', '', NULL, 314),
(799, 'KB9M-67-200(11)-4', '25.9222', '104', '', NULL, 314),
(800, 'KB9G-67-200A(11)-4', '26.4494', '32', '', NULL, 314),
(801, 'KF1D-67-200A(11)-4', '30.1736', '24', '', NULL, 314),
(802, 'KF1D-67-200A(11)-4', '30.1736', '24', '', NULL, 314),
(803, 'K131-67-190(13)-5', '29.6823', '32', '', NULL, 314),
(804, 'KC0R-67-190A(13)-5', '29.9391', '32', '', NULL, 314),
(805, 'KB8W-67-130(9)-2', '35.5617', '56', '', NULL, 314),
(806, 'KB9T-67-200(12)-5', '23.086', '104', '', NULL, 314),
(807, 'KB9T-67-200(12)-5', '23.086', '104', '', NULL, 314),
(808, 'KD3M-67-200A(12)-5', '25.7256', '48', '', NULL, 314),
(809, 'BABV-67-190(1)-3', '29.6264', '56', '', NULL, 314),
(810, 'BSR7-67-190A(4)-1', '30.2629', '16', '', NULL, 314),
(811, 'BSR9-67-190A(4)-1', '30.1524', '8', '', NULL, 314),
(812, 'BSR8-67-190A(4)-1', '26.9716', '8', '', NULL, 314),
(813, 'KF1H-67-200A(12)-5', '23.2217', '96', '', NULL, 314),
(814, 'KD3M-67-130(9)-2', '27.6049', '28', '', NULL, 314),
(815, 'K262-67-060(18)', '38.5263', '48', '', NULL, 314),
(816, 'K263-67-060(18)', '54.7224', '168', '', NULL, 314),
(817, 'GMP2-67-190D(13)-1', '34.0076', '1', '', NULL, 314),
(818, 'BHV7-67-200A(8)-4', '21.6278', '96', '', NULL, 314),
(819, 'BAEK-67-200(7)-4', '23.0839', '32', '', NULL, 314),
(820, 'KB8F-67-060A(18)', '53.8907', '136', '', NULL, 314),
(821, 'BABE-67-190A(2)-2', '28.9419', '16', '', NULL, 314),
(822, 'BABD-67-190A(2)-2', '25.8212', '16', '', NULL, 314),
(823, 'K230-67-190(13)-5', '35.2207', '48', '', NULL, 314),
(824, 'KB9J-67-130(10)-2', '18.6309', '28', '', NULL, 314),
(825, 'BAET-67-130(0)-8', '23.233', '40', '', NULL, 314),
(826, 'KF1F-67-060A(18)', '56.048', '56', '', NULL, 314),
(827, 'KC9J-67-060A(18)', '56.0478', '32', '', NULL, 314),
(828, 'KF1K-67-060A(18)', '39.7213', '24', '', NULL, 314),
(829, 'KD7W-67-130A(9)-1', '32.9971', '98', '', NULL, 314),
(830, 'KC9F-67-130A(9)-1', '33.207', '147', '', NULL, 314),
(831, 'BAMA-67-130(1)-8', '23.0608', '10', '', NULL, 314),
(832, 'BBJS-67-190(4)-4', '29.4079', '40', '', NULL, 314),
(833, 'KB8C-67-060A(18)', '37.5962', '152', '', NULL, 314),
(834, 'K231-67-060(4)-2', '60.0013', '24', '', NULL, 314),
(835, 'KF1V-67-060A(18)', '50.6583', '24', '', NULL, 314),
(836, 'B54N-67-060C(11)-1', '27.9881', '48', '', NULL, 314),
(837, 'KD3E-67-130A(9)-2', '24.7246', '1', '', NULL, 314),
(838, 'KD2W-67-130A(9)-2', '23.8995', '126', '', NULL, 314),
(839, 'BABD-67-200(11)-5', '19.372', '16', '', NULL, 314),
(840, 'BRL7-67-060C(11)-1', '19.1184', '32', '', NULL, 314),
(841, 'BRL8-67-060C(11)-1', '20.6652', '32', '', NULL, 314),
(842, 'K232-67-060(4)-2', '59.9958', '88', '', NULL, 314),
(843, 'K262-67-210(11)-1', '17.5417', '32', '', NULL, 314),
(844, 'BALE-67-210A(3)-2', '15.328', '90', '', NULL, 314),
(845, 'G52N-67-200(7)-2', '26.0483', '16', '', NULL, 314),
(846, 'BABD-67-220A(3)-2', '14.9951', '30', '', NULL, 314),
(847, 'B62T-67-060(18)-2', '29.3301', '8', '', NULL, 314),
(848, 'B63F-67-060(18)-2', '32.6167', '8', '', NULL, 314),
(849, 'GBWK-67-100(2)-1', '16.6849', '5', '', NULL, 314),
(850, 'KD3F-67-190(12)-3', '31.1124', '88', '', NULL, 314),
(851, 'GBJC-67-200(7)-2', '28.6972', '16', '', NULL, 314),
(852, 'K123-67-200A(11)-3', '25.9565', '72', '', NULL, 314),
(853, 'BALK-67-220A(3)-2', '14.2326', '17', '', NULL, 314),
(854, 'B63C-67-220A(3)-2', '14.0107', '210', '', NULL, 314),
(855, 'BSR9-67-200(11)-5', '21.54', '8', '', NULL, 314),
(856, 'BSR7-67-200(11)-5', '21.6472', '8', '', NULL, 314),
(857, 'BJG8-67-060A(17)-2', '28.9883', '8', '', NULL, 314),
(858, 'BJG9-67-060A(17)-2', '32.2748', '16', '', NULL, 314),
(859, 'G52S-67-290A(8)', '28.6695', '125', '', NULL, 314),
(860, 'BSR8-67-200(11)-5', '18.3843', '8', '', NULL, 314),
(861, 'BAER-67-200(11)-5', '18.0988', '24', '', NULL, 314),
(862, 'BALV-67-200(11)-5', '20.567', '48', '', NULL, 314),
(863, 'BHP1-67-060A(17)-2', '32.6409', '64', '', NULL, 314),
(864, 'B63B-67-060(18)-2', '32.9816', '32', '', NULL, 314),
(865, 'K128-67-130A(10)-2', '26.7633', '98', '', NULL, 314),
(866, 'KC0R-67-060A(18)', '38.5318', '168', '', NULL, 314),
(867, 'KD3D-67-130A(9)-2', '26.0246', '70', '', NULL, 314),
(868, 'KB7W-67-060A(18)', '33.3866', '40', '', NULL, 314),
(869, 'K147-67-130A(7)-1', '32.0785', '70', '', NULL, 314),
(870, 'BALW-67-200(15)-2', '26.205', '8', '', NULL, 314),
(871, 'K131-67-100A(3)-2', '17.7376', '75', '', NULL, 314),
(872, 'GBWJ-67-290(6)-1', '22.03', '300', '', NULL, 314),
(873, 'K132-67-220(1)-3', '17.8006', '64', '', NULL, 314),
(874, 'KB8M-67-220(8)-3', '17.2558', '292', '', NULL, 314),
(875, 'KB8M-67-220(8)-3', '17.2558', '288', '', NULL, 314),
(876, 'K230-67-220(1)-3', '17.8004', '32', '', NULL, 314),
(877, 'BPS4-67-060(17)-2', '28.9894', '1', '', NULL, 314),
(878, 'KB8N-67-210(8)-3', '17.8405', '88', '', NULL, 314),
(879, 'KB8M-67-210(8)-3', '17.5413', '292', '', NULL, 314),
(880, 'KB8M-67-210(8)-3', '17.5413', '292', '', NULL, 314),
(881, 'KB7W-67-100(9)-2', '12.442', '60', '', NULL, 314),
(882, 'B63C-67-210A(3)-2', '14.1242', '173', '', NULL, 314),
(883, 'B63C-67-210A(3)-2', '14.1242', '210', '', NULL, 314),
(884, 'KC0R-67-130(10)-2', '22.4622', '28', '', NULL, 314),
(885, 'GBWD-67-100(4)-1', '16.5035', '1', '', NULL, 314),
(886, 'K123-67-100A(9)-2', '16.831', '368', '', NULL, 314),
(887, 'BALK-67-210A(3)-2', '14.3542', '15', '', NULL, 314),
(888, 'GBWL-67-290(6)-1', '18.9994', '300', '', NULL, 314),
(889, 'K230-67-060(2)-2', '45.5527', '4', '', NULL, 314),
(890, 'B63K-67-290A(6)-1', '15.7821', '40', '', NULL, 314),
(891, 'KB7W-67-220A(8)-3', '16.579', '64', '', NULL, 314),
(892, 'GBFN-67-290(5)', '6.5891', '150', '', NULL, 314),
(893, 'GBFT-67-290(2)', '13.9976', '165', '', NULL, 314),
(894, 'GBFS-67-290(2)', '14.9258', '150', '', NULL, 314),
(895, 'B62S-67-290(1)-7', '8.9628', '240', '', NULL, 314),
(896, 'KB9G-67-290(3)-4', '8.232', '175', '', NULL, 314),
(897, 'B63C-67-290(1)-8', '6.8082', '60', '', NULL, 314),
(898, 'KD8B-67-290(5)-2', '13.5', '30', '', NULL, 314),
(899, 'K123-67-220A(8)-3', '16.1719', '32', '', NULL, 314),
(900, 'K123-67-210A(8)-3', '16.456', '64', '', NULL, 314),
(901, 'GRM8-67-290(0)-4', '7.1939', '60', '', NULL, 314),
(902, 'B63B-67-290(0)-5', '13.0989', '125', '', NULL, 314),
(903, 'B64F-67-290(0)-5', '13.6946', '40', '', NULL, 314),
(904, 'BHP2-67-290(1)-6', '5.7031', '160', '', NULL, 314),
(905, 'BJD5-67-SH0(1)-1', '7.2257', '75', '', NULL, 314),
(906, 'BHN3-67-SH0A(2)-1', '8.0988', '120', '', NULL, 314),
(907, 'BJE6-67-SH0(0)-5', '3.0803', '50', '', NULL, 314),
(908, 'KB8A-67-SH1(3)-3', '3.0863', '300', '', NULL, 314),
(909, 'GRG1-67-SH0(17)-1', '3.2265', '150', '', NULL, 314),
(910, 'BJE3-67-SH0(1)-6', '2.7405', '600', '', NULL, 314),
(911, 'KD5L-67-SH0(1)-1', '3.6181', '100', '', NULL, 314),
(912, 'GCCC-67-290(6)-1', '8.2616', '60', '', NULL, 314),
(913, 'KC9E-67-SH1A(1)-2', '2.4873', '525', '', NULL, 314),
(914, 'KB7W-57-X6XB(4)-1', '3.807', '275', '', NULL, 314);

-- --------------------------------------------------------

--
-- Table structure for table `eff_product_st`
--

CREATE TABLE `eff_product_st` (
  `ID` int(11) NOT NULL,
  `product_no` varchar(255) NOT NULL,
  `st` varchar(255) NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `last_update` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eff_product_st`
--

INSERT INTO `eff_product_st` (`ID`, `product_no`, `st`, `updated_by`, `last_update`) VALUES
(3005, 'KA0G-67-100A(1)-1', '0.635', 1, '2018-04-11 16:45:38'),
(3006, 'KA0H-67-100A(1)-1', '1.0425', 1, '2018-04-11 16:45:38'),
(3007, 'KA0K-67-100A(1)-1', '0.9695', 1, '2018-04-11 16:45:38'),
(3008, 'KA0M-67-100A(1)-1', '1.377', 1, '2018-04-11 16:45:39'),
(3009, 'KD47-67-100B(7)-1', '0', 1, '2018-04-11 16:45:39'),
(3010, 'KD62-67-SH0(2)-7', '0.2871', 1, '2018-04-11 16:45:39'),
(3011, 'G53C-67-060(8)-1', '1.97', 1, '2018-04-11 16:45:39'),
(3012, 'G53C-67-060(8)-2', '1.97', 1, '2018-04-11 16:45:39'),
(3013, 'G53D-67-060(8)-1', '1.9788', 1, '2018-04-11 16:45:39'),
(3014, 'G53D-67-060(8)-2', '1.9788', 1, '2018-04-11 16:45:39'),
(3015, 'G53E-67-060(8)-1', '1.5409', 1, '2018-04-11 16:45:39'),
(3016, 'G53E-67-060(8)-2', '1.5409', 1, '2018-04-11 16:45:39'),
(3017, 'G53F-67-060(8)-1', '1.5497', 1, '2018-04-11 16:45:39'),
(3018, 'G53F-67-060(8)-2', '1.5497', 1, '2018-04-11 16:45:39'),
(3019, 'GBEF-67-060(8)-1', '1.3346', 1, '2018-04-11 16:45:39'),
(3020, 'GBEF-67-060(8)-2', '0', 1, '2018-04-11 16:45:39'),
(3021, 'GBFN-67-060(8)-1', '1.3346', 1, '2018-04-11 16:45:40'),
(3022, 'GBFN-67-060(8)-2', '1.3346', 1, '2018-04-11 16:45:40'),
(3023, 'GBFS-67-060(8)-1', '1.5497', 1, '2018-04-11 16:45:40'),
(3024, 'GBFS-67-060(8)-2', '1.5497', 1, '2018-04-11 16:45:40'),
(3025, 'GBFW-67-060(8)-1', '1.5497', 1, '2018-04-11 16:45:40'),
(3026, 'GBFW-67-060(8)-2', '1.5497', 1, '2018-04-11 16:45:40'),
(3027, 'GBJD-67-060(8)-1', '1.5409', 1, '2018-04-11 16:45:40'),
(3028, 'GBJD-67-060(8)-2', '1.5409', 1, '2018-04-11 16:45:40'),
(3029, 'GBJT-67-060(8)-1', '1.5497', 1, '2018-04-11 16:45:40'),
(3030, 'GBJT-67-060(8)-2', '1.5497', 1, '2018-04-11 16:45:40'),
(3031, 'GBKR-67-060(8)-1', '1.3346', 1, '2018-04-11 16:45:40'),
(3032, 'GBKR-67-060(8)-2', '1.3346', 1, '2018-04-11 16:45:40'),
(3033, 'GBKT-67-060(8)-1', '1.5409', 1, '2018-04-11 16:45:41'),
(3034, 'GBKT-67-060(8)-2', '0', 1, '2018-04-11 16:45:41'),
(3035, 'GBKV-67-060(8)-1', '1.3434', 1, '2018-04-11 16:45:41'),
(3036, 'GBKV-67-060(8)-2', '0', 1, '2018-04-11 16:45:41'),
(3037, 'GBWD-67-060(8)-1', '1.9788', 1, '2018-04-11 16:45:41'),
(3038, 'GBWD-67-060(8)-2', '1.9788', 1, '2018-04-11 16:45:41'),
(3039, 'GBWE-67-060(9)', '1.5497', 1, '2018-04-11 16:45:41'),
(3040, 'GBWE-67-060(9)-1', '1.5497', 1, '2018-04-11 16:45:41'),
(3041, 'GCAF-67-060(8)-1', '1.9788', 1, '2018-04-11 16:45:41'),
(3042, 'GCAF-67-060(8)-2', '1.9788', 1, '2018-04-11 16:45:41'),
(3043, 'GCAG-67-060(8)-1', '1.5497', 1, '2018-04-11 16:45:41'),
(3044, 'GCAG-67-060(8)-2', '0', 1, '2018-04-11 16:45:41'),
(3045, 'GCAH-67-060(8)-1', '1.9788', 1, '2018-04-11 16:45:42'),
(3046, 'GCAH-67-060(8)-2', '0', 1, '2018-04-11 16:45:42'),
(3047, 'GCAJ-67-060(9)', '1.5497', 1, '2018-04-11 16:45:42'),
(3048, 'GCAJ-67-060(9)-1', '1.5497', 1, '2018-04-11 16:45:42'),
(3049, 'GCAK-67-060(9)', '1.5497', 1, '2018-04-11 16:45:42'),
(3050, 'GCAK-67-060(9)-1', '0', 1, '2018-04-11 16:45:42'),
(3051, 'GCCD-67-060(8)-1', '1.5497', 1, '2018-04-11 16:45:42'),
(3052, 'GCCD-67-060(8)-2', '0', 1, '2018-04-11 16:45:42'),
(3053, 'GCCE-67-060(8)-1', '1.3434', 1, '2018-04-11 16:45:42'),
(3054, 'GCCE-67-060(8)-2', '1.3434', 1, '2018-04-11 16:45:42'),
(3055, 'GCCF-67-060(8)-1', '1.5497', 1, '2018-04-11 16:45:42'),
(3056, 'GCCF-67-060(8)-2', '0', 1, '2018-04-11 16:45:43'),
(3057, 'G52M-67-060(7)', '3.3656', 1, '2018-04-11 16:45:43'),
(3058, 'G52N-67-060(7)-1', '3.571', 1, '2018-04-11 16:45:43'),
(3059, 'G52N-67-060(7)-2', '3.571', 1, '2018-04-11 16:45:43'),
(3060, 'G52P-67-060(7)', '3.3695', 1, '2018-04-11 16:45:43'),
(3061, 'G52R-67-060(7)-1', '3.5749', 1, '2018-04-11 16:45:43'),
(3062, 'G52R-67-060(7)-2', '3.5749', 1, '2018-04-11 16:45:43'),
(3063, 'G52S-67-060(7)-1', '3.1655', 1, '2018-04-11 16:45:43'),
(3064, 'G52S-67-060(7)-2', '3.1655', 1, '2018-04-11 16:45:43'),
(3065, 'G52T-67-060(7)-1', '3.1693', 1, '2018-04-11 16:45:43'),
(3066, 'G52T-67-060(7)-2', '3.1693', 1, '2018-04-11 16:45:43'),
(3067, 'GBFT-67-060(7)-1', '2.964', 1, '2018-04-11 16:45:43'),
(3068, 'GBFT-67-060(7)-2', '2.964', 1, '2018-04-11 16:45:44'),
(3069, 'GBFV-67-060(7)-1', '3.3696', 1, '2018-04-11 16:45:44'),
(3070, 'GBFV-67-060(7)-2', '0', 1, '2018-04-11 16:45:44'),
(3071, 'GBGA-67-060A(10)', '2.7834', 1, '2018-04-11 16:45:44'),
(3072, 'GBGA-67-060A(10)-1', '0', 1, '2018-04-11 16:45:44'),
(3073, 'GBGR-67-060(7)-1', '2.96', 1, '2018-04-11 16:45:44'),
(3074, 'GBGR-67-060(7)-2', '0', 1, '2018-04-11 16:45:44'),
(3075, 'GBJC-67-060(7)-1', '2.96', 1, '2018-04-11 16:45:44'),
(3076, 'GBJC-67-060(7)-2', '0', 1, '2018-04-11 16:45:44'),
(3077, 'GBJS-67-060(7)-1', '2.964', 1, '2018-04-11 16:45:44'),
(3078, 'GBJS-67-060(7)-2', '0', 1, '2018-04-11 16:45:44'),
(3079, 'GBVP-67-060A(10)', '3.1893', 1, '2018-04-11 16:45:45'),
(3080, 'GBVP-67-060A(10)-1', '0', 1, '2018-04-11 16:45:45'),
(3081, 'GBVR-67-060A(10)', '2.9888', 1, '2018-04-11 16:45:45'),
(3082, 'GBVR-67-060A(10)-1', '2.9888', 1, '2018-04-11 16:45:45'),
(3083, 'GBVS-67-060(7)-1', '3.5975', 1, '2018-04-11 16:45:45'),
(3084, 'GBVS-67-060(7)-2', '3.5975', 1, '2018-04-11 16:45:45'),
(3085, 'GBVT-67-060(8)-1', '3.1916', 1, '2018-04-11 16:45:45'),
(3086, 'GBVT-67-060(8)-2', '3.1916', 1, '2018-04-11 16:45:45'),
(3087, 'GBWJ-67-060(7)-1', '3.1695', 1, '2018-04-11 16:45:45'),
(3088, 'GBWJ-67-060(7)-2', '3.1695', 1, '2018-04-11 16:45:45'),
(3089, 'GBWK-67-060(7)-1', '3.575', 1, '2018-04-11 16:45:45'),
(3090, 'GBWK-67-060(7)-2', '3.575', 1, '2018-04-11 16:45:45'),
(3091, 'GBWL-67-060(8)-1', '3.1695', 1, '2018-04-11 16:45:46'),
(3092, 'GBWL-67-060(8)-2', '3.1695', 1, '2018-04-11 16:45:46'),
(3093, 'GCBE-67-060(7)-1', '3.1655', 1, '2018-04-11 16:45:46'),
(3094, 'GCBE-67-060(7)-2', '0', 1, '2018-04-11 16:45:46'),
(3095, 'GCBF-67-060(7)-1', '3.1655', 1, '2018-04-11 16:45:46'),
(3096, 'GCBF-67-060(7)-2', '3.1655', 1, '2018-04-11 16:45:46'),
(3097, 'GCBL-67-060(7)-1', '3.1695', 1, '2018-04-11 16:45:46'),
(3098, 'GCBL-67-060(7)-2', '0', 1, '2018-04-11 16:45:46'),
(3099, 'GCCC-67-060(7)-1', '3.1693', 1, '2018-04-11 16:45:47'),
(3100, 'GCCC-67-060(7)-2', '0', 1, '2018-04-11 16:45:47'),
(3101, 'G46E-67-060A(18)-3', '3.5469', 1, '2018-04-11 16:45:47'),
(3102, 'G46E-67-060A(18)-4', '0', 1, '2018-04-11 16:45:47'),
(3103, 'G46F-67-060A(18)-3', '3.3484', 1, '2018-04-11 16:45:47'),
(3104, 'G46F-67-060A(18)-4', '0', 1, '2018-04-11 16:45:47'),
(3105, 'G46M-67-060(18)-3', '3.3436', 1, '2018-04-11 16:45:47'),
(3106, 'G46M-67-060(18)-4', '0', 1, '2018-04-11 16:45:47'),
(3107, 'G47F-67-060A(18)-3', '3.5517', 1, '2018-04-11 16:45:47'),
(3108, 'G47F-67-060A(18)-4', '0', 1, '2018-04-11 16:45:47'),
(3109, 'GHP9-67-060B(16)-3', '2.947', 1, '2018-04-11 16:45:47'),
(3110, 'GHP9-67-060B(16)-4', '0', 1, '2018-04-11 16:45:47'),
(3111, 'GHR1-67-060B(16)-3', '3.1502', 1, '2018-04-11 16:45:47'),
(3112, 'GHR1-67-060B(16)-4', '0', 1, '2018-04-11 16:45:48'),
(3113, 'GJE8-67-060A(16)-3', '2.7666', 1, '2018-04-11 16:45:48'),
(3114, 'GJE8-67-060A(16)-4', '0', 1, '2018-04-11 16:45:48'),
(3115, 'GJF7-67-060A(16)-3', '2.9698', 1, '2018-04-11 16:45:48'),
(3116, 'GJF7-67-060A(16)-4', '0', 1, '2018-04-11 16:45:48'),
(3117, 'GJN8-67-060A(16)-3', '2.9422', 1, '2018-04-11 16:45:48'),
(3118, 'GJN8-67-060A(16)-4', '0', 1, '2018-04-11 16:45:48'),
(3119, 'GJP7-67-060A(16)-3', '3.1454', 1, '2018-04-11 16:45:48'),
(3120, 'GJP7-67-060A(16)-4', '0', 1, '2018-04-11 16:45:48'),
(3121, 'GLG9-67-060A(16)-3', '3.1503', 1, '2018-04-11 16:45:48'),
(3122, 'GLG9-67-060A(16)-4', '0', 1, '2018-04-11 16:45:49'),
(3123, 'GMB5-67-060(19)-3', '3.5518', 1, '2018-04-11 16:45:49'),
(3124, 'GMB5-67-060(19)-4', '0', 1, '2018-04-11 16:45:49'),
(3125, 'GMD7-67-060(18)-3', '3.5732', 1, '2018-04-11 16:45:49'),
(3126, 'GMD7-67-060(18)-4', '0', 1, '2018-04-11 16:45:49'),
(3127, 'GNT1-67-060(20)-3', '2.9437', 1, '2018-04-11 16:45:49'),
(3128, 'GNT1-67-060(20)-4', '0', 1, '2018-04-11 16:45:49'),
(3129, 'GRE5-67-060(20)-3', '2.947', 1, '2018-04-11 16:45:49'),
(3130, 'GRE5-67-060(20)-4', '0', 1, '2018-04-11 16:45:49'),
(3131, 'GRM8-67-060(23)-2', '0', 1, '2018-04-11 16:45:49'),
(3132, 'GRM8-67-060(23)-3', '0', 1, '2018-04-11 16:45:50'),
(3133, 'GSC5-67-060(22)-3', '0', 1, '2018-04-11 16:45:50'),
(3134, 'GSC5-67-060(22)-4', '0', 1, '2018-04-11 16:45:50'),
(3135, 'G46C-67-060A(6)-2', '2.3098', 1, '2018-04-11 16:45:50'),
(3136, 'G46C-67-060A(6)-4', '0', 1, '2018-04-11 16:45:50'),
(3137, 'G47B-67-060A(6)-2', '2.3183', 1, '2018-04-11 16:45:50'),
(3138, 'G47B-67-060A(6)-4', '0', 1, '2018-04-11 16:45:50'),
(3139, 'GMA4-67-060(2)-4', '1.8932', 1, '2018-04-11 16:45:50'),
(3140, 'GMA4-67-060(2)-6', '0', 1, '2018-04-11 16:45:50'),
(3141, 'GMA5-67-060A(7)-2', '2.3184', 1, '2018-04-11 16:45:50'),
(3142, 'GMA5-67-060A(7)-4', '0', 1, '2018-04-11 16:45:50'),
(3143, 'GMC8-67-060A(6)-2', '2.3181', 1, '2018-04-11 16:45:50'),
(3144, 'GMC8-67-060A(6)-4', '0', 1, '2018-04-11 16:45:50'),
(3145, 'GMD9-67-060(2)-4', '1.8931', 1, '2018-04-11 16:45:51'),
(3146, 'GMD9-67-060(2)-6', '1.8931', 1, '2018-04-11 16:45:51'),
(3147, 'GME1-67-060A(7)-2', '2.3182', 1, '2018-04-11 16:45:51'),
(3148, 'GME1-67-060A(7)-4', '2.3182', 1, '2018-04-11 16:45:51'),
(3149, 'GMK6-67-060(2)-4', '1.893', 1, '2018-04-11 16:45:51'),
(3150, 'GMK6-67-060(2)-6', '0', 1, '2018-04-11 16:45:51'),
(3151, 'GMN3-67-060(3)-4', '1.6781', 1, '2018-04-11 16:45:51'),
(3152, 'GMN3-67-060(3)-6', '0', 1, '2018-04-11 16:45:51'),
(3153, 'GMN4-67-060(3)-4', '1.6781', 1, '2018-04-11 16:45:51'),
(3154, 'GMN4-67-060(3)-6', '0', 1, '2018-04-11 16:45:51'),
(3155, 'GMN5-67-060(3)-4', '1.8847', 1, '2018-04-11 16:45:51'),
(3156, 'GMN5-67-060(3)-6', '0', 1, '2018-04-11 16:45:51'),
(3157, 'GMS1-67-060(4)-3', '1.8847', 1, '2018-04-11 16:45:51'),
(3158, 'GMS1-67-060(4)-5', '0', 1, '2018-04-11 16:45:52'),
(3159, 'GMS2-67-060(4)-3', '1.8932', 1, '2018-04-11 16:45:52'),
(3160, 'GMS2-67-060(4)-5', '1.8932', 1, '2018-04-11 16:45:52'),
(3161, 'GSB8-67-060(8)-2', '0', 1, '2018-04-11 16:45:52'),
(3162, 'GSB8-67-060(8)-4', '0', 1, '2018-04-11 16:45:52'),
(3163, 'GSB9-67-060(8)-2', '0', 1, '2018-04-11 16:45:52'),
(3164, 'GSB9-67-060(8)-4', '0', 1, '2018-04-11 16:45:52'),
(3165, 'GSC1-67-060(8)-2', '0', 1, '2018-04-11 16:45:52'),
(3166, 'GSC1-67-060(8)-4', '0', 1, '2018-04-11 16:45:52'),
(3167, 'GSC2-67-060(8)-2', '0', 1, '2018-04-11 16:45:52'),
(3168, 'GSC2-67-060(8)-4', '0', 1, '2018-04-11 16:45:52'),
(3169, 'GBFN-67-130A(8)-2', '1.3259', 1, '2018-04-11 16:45:52'),
(3170, 'GBFN-67-130A(8)-3', '1.3259', 1, '2018-04-11 16:45:52'),
(3171, 'GBFS-67-130(8)-2', '1.3259', 1, '2018-04-11 16:45:52'),
(3172, 'GBFS-67-130(8)-3', '0', 1, '2018-04-11 16:45:53'),
(3173, 'GBFW-67-130(8)-1', '1.9424', 1, '2018-04-11 16:45:53'),
(3174, 'GBFW-67-130(8)-2', '0', 1, '2018-04-11 16:45:53'),
(3175, 'GBJD-67-130A(8)-2', '1.9366', 1, '2018-04-11 16:45:53'),
(3176, 'GBJD-67-130A(8)-3', '1.9366', 1, '2018-04-11 16:45:53'),
(3177, 'GBJS-67-130(6)-2', '0.9308', 1, '2018-04-11 16:45:53'),
(3178, 'GBJS-67-130(6)-3', '0.9308', 1, '2018-04-11 16:45:53'),
(3179, 'GBJW-67-130(6)-2', '0.9308', 1, '2018-04-11 16:45:53'),
(3180, 'GBJW-67-130(6)-3', '0.9308', 1, '2018-04-11 16:45:53'),
(3181, 'GBKR-67-130(7)-1', '0.9336', 1, '2018-04-11 16:45:53'),
(3182, 'GBKR-67-130(7)-2', '0.9336', 1, '2018-04-11 16:45:53'),
(3183, 'GBVJ-67-130A(8)-2', '1.9441', 1, '2018-04-11 16:45:53'),
(3184, 'GBVJ-67-130A(8)-3', '0', 1, '2018-04-11 16:45:53'),
(3185, 'GBVL-67-130A(8)-2', '2.554', 1, '2018-04-11 16:45:53'),
(3186, 'GBVL-67-130A(8)-3', '0', 1, '2018-04-11 16:45:54'),
(3187, 'GBWE-67-130(8)-1', '2.2526', 1, '2018-04-11 16:45:54'),
(3188, 'GBWE-67-130(8)-2', '2.2526', 1, '2018-04-11 16:45:54'),
(3189, 'GCAF-67-130(8)-2', '1.9394', 1, '2018-04-11 16:45:54'),
(3190, 'GCAF-67-130(8)-3', '0', 1, '2018-04-11 16:45:54'),
(3191, 'GCAH-67-130(8)-2', '1.9366', 1, '2018-04-11 16:45:54'),
(3192, 'GCAH-67-130(8)-3', '0', 1, '2018-04-11 16:45:54'),
(3193, 'GCAJ-67-130(8)-2', '2.5492', 1, '2018-04-11 16:45:54'),
(3194, 'GCAJ-67-130(8)-3', '0', 1, '2018-04-11 16:45:54'),
(3195, 'GCAK-67-130(8)-2', '1.6358', 1, '2018-04-11 16:45:54'),
(3196, 'GCAK-67-130(8)-3', '0', 1, '2018-04-11 16:45:54'),
(3197, 'GCAN-67-130(8)-2', '1.6358', 1, '2018-04-11 16:45:54'),
(3198, 'GCAN-67-130(8)-3', '1.6358', 1, '2018-04-11 16:45:54'),
(3199, 'GCAP-67-130(8)-2', '2.2493', 1, '2018-04-11 16:45:55'),
(3200, 'GCAP-67-130(8)-3', '0', 1, '2018-04-11 16:45:55'),
(3201, 'GCAT-67-130(8)-2', '2.2456', 1, '2018-04-11 16:45:55'),
(3202, 'GCAT-67-130(8)-3', '0', 1, '2018-04-11 16:45:55'),
(3203, 'GCAV-67-130(8)-2', '2.2456', 1, '2018-04-11 16:45:55'),
(3204, 'GCAV-67-130(8)-3', '2.2456', 1, '2018-04-11 16:45:55'),
(3205, 'GCBA-67-130(8)-2', '2.8592', 1, '2018-04-11 16:45:55'),
(3206, 'GCBA-67-130(8)-3', '0', 1, '2018-04-11 16:45:55'),
(3207, 'GCBL-67-130(6)-2', '1.3346', 1, '2018-04-11 16:45:55'),
(3208, 'GCBL-67-130(6)-3', '0', 1, '2018-04-11 16:45:55'),
(3209, 'GCBP-67-130(6)-2', '1.9454', 1, '2018-04-11 16:45:55'),
(3210, 'GCBP-67-130(6)-3', '0', 1, '2018-04-11 16:45:55'),
(3211, 'GCCD-67-130(7)-1', '1.3386', 1, '2018-04-11 16:45:56'),
(3212, 'GCCD-67-130(7)-2', '0', 1, '2018-04-11 16:45:56'),
(3213, 'GCCF-67-130(8)-1', '1.33', 1, '2018-04-11 16:45:56'),
(3214, 'GCCF-67-130(8)-2', '0', 1, '2018-04-11 16:45:56'),
(3215, 'GCCG-67-130(8)-1', '1.6411', 1, '2018-04-11 16:45:56'),
(3216, 'GCCG-67-130(8)-2', '1.6411', 1, '2018-04-11 16:45:56'),
(3217, 'GBEF-67-130A(8)-2', '2.1306', 1, '2018-04-11 16:45:56'),
(3218, 'GBEF-67-130A(8)-3', '0', 1, '2018-04-11 16:45:56'),
(3219, 'GBGR-67-130(8)-1', '2.7474', 1, '2018-04-11 16:45:56'),
(3220, 'GBGR-67-130(8)-2', '0', 1, '2018-04-11 16:45:56'),
(3221, 'GBJE-67-130A(8)-2', '2.7414', 1, '2018-04-11 16:45:56'),
(3222, 'GBJE-67-130A(8)-3', '2.7414', 1, '2018-04-11 16:45:56'),
(3223, 'GBKT-67-130(7)-1', '1.7386', 1, '2018-04-11 16:45:57'),
(3224, 'GBKT-67-130(7)-2', '1.7386', 1, '2018-04-11 16:45:57'),
(3225, 'GBKV-67-130(7)-1', '2.1373', 1, '2018-04-11 16:45:57'),
(3226, 'GBKV-67-130(7)-2', '0', 1, '2018-04-11 16:45:57'),
(3227, 'GBVG-67-130A(8)-2', '2.7426', 1, '2018-04-11 16:45:57'),
(3228, 'GBVG-67-130A(8)-3', '0', 1, '2018-04-11 16:45:57'),
(3229, 'GBVH-67-130A(8)-2', '3.3524', 1, '2018-04-11 16:45:57'),
(3230, 'GBVH-67-130A(8)-3', '3.3524', 1, '2018-04-11 16:45:57'),
(3231, 'GBWD-67-130(8)-1', '3.0513', 1, '2018-04-11 16:45:57'),
(3232, 'GBWD-67-130(8)-2', '3.0513', 1, '2018-04-11 16:45:57'),
(3233, 'GCAG-67-130(8)-2', '2.7415', 1, '2018-04-11 16:45:57'),
(3234, 'GCAG-67-130(8)-3', '0', 1, '2018-04-11 16:45:58'),
(3235, 'GCAL-67-130(8)-2', '3.3525', 1, '2018-04-11 16:45:58'),
(3236, 'GCAL-67-130(8)-3', '0', 1, '2018-04-11 16:45:58'),
(3237, 'GCAM-67-130(8)-2', '2.4342', 1, '2018-04-11 16:45:58'),
(3238, 'GCAM-67-130(8)-3', '2.4342', 1, '2018-04-11 16:45:58'),
(3239, 'GCAR-67-130(8)-2', '3.0444', 1, '2018-04-11 16:45:58'),
(3240, 'GCAR-67-130(8)-3', '0', 1, '2018-04-11 16:45:58'),
(3241, 'GCAS-67-130(8)-2', '3.0441', 1, '2018-04-11 16:45:58'),
(3242, 'GCAS-67-130(8)-3', '3.0441', 1, '2018-04-11 16:45:59'),
(3243, 'GCAW-67-130(8)-2', '3.6552', 1, '2018-04-11 16:45:59'),
(3244, 'GCAW-67-130(8)-3', '0', 1, '2018-04-11 16:45:59'),
(3245, 'GCBM-67-130(6)-2', '1.7355', 1, '2018-04-11 16:45:59'),
(3246, 'GCBM-67-130(6)-3', '0', 1, '2018-04-11 16:45:59'),
(3247, 'GCBN-67-130(6)-2', '2.133', 1, '2018-04-11 16:45:59'),
(3248, 'GCBN-67-130(6)-3', '0', 1, '2018-04-11 16:45:59'),
(3249, 'GCBR-67-130(6)-2', '2.7438', 1, '2018-04-11 16:45:59'),
(3250, 'GCBR-67-130(6)-3', '0', 1, '2018-04-11 16:45:59'),
(3251, 'GCCE-67-130(8)-1', '2.135', 1, '2018-04-11 16:45:59'),
(3252, 'GCCE-67-130(8)-2', '0', 1, '2018-04-11 16:45:59'),
(3253, 'GCCH-67-130(8)-1', '2.4398', 1, '2018-04-11 16:45:59'),
(3254, 'GCCH-67-130(8)-2', '2.4398', 1, '2018-04-11 16:45:59'),
(3255, 'G44A-67-130(11)-5', '0', 1, '2018-04-11 16:45:59'),
(3256, 'GNA1-67-130A(8)-1', '0.5093', 1, '2018-04-11 16:46:00'),
(3257, 'GNA1-67-130A(8)-2', '0', 1, '2018-04-11 16:46:00'),
(3258, 'GRL7-67-130A(8)-1', '1.4239', 1, '2018-04-11 16:46:00'),
(3259, 'GRL7-67-130A(8)-2', '0', 1, '2018-04-11 16:46:00'),
(3260, 'GRM8-67-130A(8)-1', '0', 1, '2018-04-11 16:46:00'),
(3261, 'GRM8-67-130A(8)-2', '0', 1, '2018-04-11 16:46:00'),
(3262, 'GRN2-67-130A(8)-1', '0', 1, '2018-04-11 16:46:00'),
(3263, 'GRN2-67-130A(8)-2', '0', 1, '2018-04-11 16:46:00'),
(3264, 'GRN3-67-130A(8)-1', '0', 1, '2018-04-11 16:46:00'),
(3265, 'GRN3-67-130A(8)-2', '0', 1, '2018-04-11 16:46:00'),
(3266, 'GRN7-67-130A(8)-1', '1.1291', 1, '2018-04-11 16:46:01'),
(3267, 'GRN7-67-130A(8)-2', '0', 1, '2018-04-11 16:46:01'),
(3268, 'GRN8-67-130A(8)-1', '0.8141', 1, '2018-04-11 16:46:01'),
(3269, 'GRN8-67-130A(8)-2', '0', 1, '2018-04-11 16:46:01'),
(3270, 'GRN9-67-130A(8)-1', '0', 1, '2018-04-11 16:46:01'),
(3271, 'GRN9-67-130A(8)-2', '0', 1, '2018-04-11 16:46:01'),
(3272, 'GRP6-67-130A(8)-1', '1.436', 1, '2018-04-11 16:46:01'),
(3273, 'GRP6-67-130A(8)-2', '1.436', 1, '2018-04-11 16:46:01'),
(3274, 'GRP7-67-130A(8)-1', '1.4239', 1, '2018-04-11 16:46:01'),
(3275, 'GRP7-67-130A(8)-2', '0', 1, '2018-04-11 16:46:01'),
(3276, 'GRP8-67-130A(8)-1', '0', 1, '2018-04-11 16:46:01'),
(3277, 'GRP8-67-130A(8)-2', '0', 1, '2018-04-11 16:46:01'),
(3278, 'GRR6-67-130A(6)-1', '0.5071', 1, '2018-04-11 16:46:01'),
(3279, 'GRR6-67-130A(6)-2', '0', 1, '2018-04-11 16:46:02'),
(3280, 'GRR7-67-130A(6)-1', '0', 1, '2018-04-11 16:46:02'),
(3281, 'GRR7-67-130A(6)-2', '0', 1, '2018-04-11 16:46:02'),
(3282, 'GRR8-67-130A(6)-1', '0.8108', 1, '2018-04-11 16:46:02'),
(3283, 'GRR8-67-130A(6)-2', '0', 1, '2018-04-11 16:46:02'),
(3284, 'GRS1-67-130A(6)-1', '1.4197', 1, '2018-04-11 16:46:02'),
(3285, 'GRS1-67-130A(6)-2', '0', 1, '2018-04-11 16:46:02'),
(3286, 'GRS2-67-130A(6)-1', '0', 1, '2018-04-11 16:46:02'),
(3287, 'GRS2-67-130A(6)-2', '0', 1, '2018-04-11 16:46:02'),
(3288, 'GRV2-67-130A(8)-1', '0.1939', 1, '2018-04-11 16:46:02'),
(3289, 'GRV2-67-130A(8)-2', '0', 1, '2018-04-11 16:46:02'),
(3290, 'GRP3-67-130(6)', '0', 1, '2018-04-11 16:46:02'),
(3291, 'GRP4-67-130(6)', '0', 1, '2018-04-11 16:46:03'),
(3292, 'GRR5-67-130A(6)-1', '0.1939', 1, '2018-04-11 16:46:03'),
(3293, 'GRR5-67-130A(6)-2', '0', 1, '2018-04-11 16:46:03'),
(3294, 'GRS5-67-130(4)', '0', 1, '2018-04-11 16:46:03'),
(3295, 'G45K-67-130(8)-5', '0', 1, '2018-04-11 16:46:03'),
(3296, 'G45M-67-130(9)-5', '0', 1, '2018-04-11 16:46:03'),
(3297, 'G46S-67-130(8)-5', '0', 1, '2018-04-11 16:46:03'),
(3298, 'G48V-67-130A(5)-1', '2.2172', 1, '2018-04-11 16:46:03'),
(3299, 'G48V-67-130A(5)-2', '0', 1, '2018-04-11 16:46:03'),
(3300, 'G48W-67-130A(5)-1', '1.6092', 1, '2018-04-11 16:46:03'),
(3301, 'G48W-67-130A(5)-2', '0', 1, '2018-04-11 16:46:03'),
(3302, 'GNA4-67-130C(9)-1', '1.3136', 1, '2018-04-11 16:46:03'),
(3303, 'GNA4-67-130C(9)-2', '0', 1, '2018-04-11 16:46:03'),
(3304, 'GRG3-67-130A(5)-1', '1.3088', 1, '2018-04-11 16:46:04'),
(3305, 'GRG3-67-130A(5)-2', '0', 1, '2018-04-11 16:46:04'),
(3306, 'GRK9-67-130C(9)-1', '1.3049', 1, '2018-04-11 16:46:04'),
(3307, 'GRK9-67-130C(9)-2', '0', 1, '2018-04-11 16:46:04'),
(3308, 'GRL3-67-130B(9)-1', '1.9176', 1, '2018-04-11 16:46:04'),
(3309, 'GRL3-67-130B(9)-2', '0', 1, '2018-04-11 16:46:04'),
(3310, 'GRL5-67-130B(9)-1', '1.9311', 1, '2018-04-11 16:46:04'),
(3311, 'GRL5-67-130B(9)-2', '0', 1, '2018-04-11 16:46:04'),
(3312, 'GRP5-67-130C(9)-1', '1.6118', 1, '2018-04-11 16:46:04'),
(3313, 'GRP5-67-130C(9)-2', '1.6118', 1, '2018-04-11 16:46:04'),
(3314, 'GRR1-67-130B(9)-1', '2.2319', 1, '2018-04-11 16:46:04'),
(3315, 'GRR1-67-130B(9)-2', '2.2319', 1, '2018-04-11 16:46:04'),
(3316, 'GRR2-67-130B(9)-1', '2.2226', 1, '2018-04-11 16:46:05'),
(3317, 'GRR2-67-130B(9)-2', '2.2226', 1, '2018-04-11 16:46:05'),
(3318, 'GRR3-67-130B(9)-1', '2.8402', 1, '2018-04-11 16:46:05'),
(3319, 'GRR3-67-130B(9)-2', '2.8402', 1, '2018-04-11 16:46:05'),
(3320, 'GRV3-67-130C(9)-1', '0', 1, '2018-04-11 16:46:05'),
(3321, 'GRV3-67-130C(9)-2', '0', 1, '2018-04-11 16:46:05'),
(3322, 'GSC2-67-130A(5)-1', '0.9977', 1, '2018-04-11 16:46:05'),
(3323, 'GSC2-67-130A(5)-2', '0', 1, '2018-04-11 16:46:05'),
(3324, 'GSC3-67-130A(5)-1', '0', 1, '2018-04-11 16:46:05'),
(3325, 'GSC3-67-130A(5)-2', '0', 1, '2018-04-11 16:46:05'),
(3326, 'GSC4-67-130A(5)-1', '0', 1, '2018-04-11 16:46:05'),
(3327, 'GSC4-67-130A(5)-2', '0', 1, '2018-04-11 16:46:05'),
(3328, 'GRK7-67-130(6)', '1.8863', 1, '2018-04-11 16:46:06'),
(3329, 'GRK8-67-130(6)', '2.5828', 1, '2018-04-11 16:46:06'),
(3330, 'GBEF-67-100(4)-1', '0.8193', 1, '2018-04-11 16:46:06'),
(3331, 'GBFN-67-100(4)-1', '1.2261', 1, '2018-04-11 16:46:06'),
(3332, 'GBFS-67-100(4)-1', '1.6542', 1, '2018-04-11 16:46:06'),
(3333, 'GBFT-67-100(2)-1', '0.8269', 1, '2018-04-11 16:46:06'),
(3334, 'GBFV-67-100(2)-1', '1.2337', 1, '2018-04-11 16:46:06'),
(3335, 'GBFW-67-100(4)-1', '1.2381', 1, '2018-04-11 16:46:06'),
(3336, 'GBGA-67-100(2)-1', '1.2528', 1, '2018-04-11 16:46:06'),
(3337, 'GBJD-67-100(4)-1', '2.0413', 1, '2018-04-11 16:46:06'),
(3338, 'GBJT-67-100(4)-1', '1.2474', 1, '2018-04-11 16:46:06'),
(3339, 'GBVP-67-100(2)-1', '1.6596', 1, '2018-04-11 16:46:07'),
(3340, 'GBVR-67-100(2)-1', '2.4824', 1, '2018-04-11 16:46:07'),
(3341, 'GBWD-67-100(4)-1', '1.6448', 1, '2018-04-11 16:46:07'),
(3342, 'GBWE-67-100(4)-1', '2.46', 1, '2018-04-11 16:46:07'),
(3343, 'GBWJ-67-100(2)-1', '2.0565', 1, '2018-04-11 16:46:07'),
(3344, 'GBWK-67-100(2)-1', '1.669', 1, '2018-04-11 16:46:07'),
(3345, 'GBWL-67-100(2)-1', '2.4917', 1, '2018-04-11 16:46:07'),
(3346, 'GCAF-67-100(4)-1', '2.4693', 1, '2018-04-11 16:46:07'),
(3347, 'G46E-67-100B(3)', '1.2611', 1, '2018-04-11 16:46:07'),
(3348, 'GMB5-67-100A(3)', '0.8414', 1, '2018-04-11 16:46:07'),
(3349, 'GMB6-67-100A(3)', '1.7036', 1, '2018-04-11 16:46:07'),
(3350, 'GMD7-67-100B(3)', '1.2748', 1, '2018-04-11 16:46:07'),
(3351, 'GMD8-67-100B(3)', '1.6945', 1, '2018-04-11 16:46:08'),
(3352, 'GRM8-67-100A(3)', '1.4762', 1, '2018-04-11 16:46:08'),
(3353, 'GRM9-67-100A(3)', '0', 1, '2018-04-11 16:46:08'),
(3354, 'GRS5-67-100A(3)', '0', 1, '2018-04-11 16:46:08'),
(3355, 'GHK1-67-100A(11)', '0.618', 1, '2018-04-11 16:46:08'),
(3356, 'GHK3-67-100B(11)', '1.0284', 1, '2018-04-11 16:46:08'),
(3357, 'GMA5-67-100A(11)', '1.4514', 1, '2018-04-11 16:46:08'),
(3358, 'GMC8-67-100A(11)', '1.032', 1, '2018-04-11 16:46:08'),
(3359, 'GMC9-67-100A(11)', '1.4424', 1, '2018-04-11 16:46:08'),
(3360, 'GMS1-67-100A(11)', '1.0412', 1, '2018-04-11 16:46:09'),
(3361, 'GRK6-67-100A(11)', '1.6592', 1, '2018-04-11 16:46:09'),
(3362, 'GRR5-67-100A(11)', '0', 1, '2018-04-11 16:46:09'),
(3363, 'GRV1-67-100A(11)', '1.2362', 1, '2018-04-11 16:46:09'),
(3364, 'G52M-67-290(6)-1', '1.2639', 1, '2018-04-11 16:46:09'),
(3365, 'G52N-67-290(6)-1', '1.1632', 1, '2018-04-11 16:46:09'),
(3366, 'G52S-67-290A(8)', '1.7067', 1, '2018-04-11 16:46:09'),
(3367, 'GBFV-67-290(6)-1', '1.0391', 1, '2018-04-11 16:46:09'),
(3368, 'GBJE-67-290A(8)', '0.6676', 1, '2018-04-11 16:46:09'),
(3369, 'GBWJ-67-290(6)-1', '1.4842', 1, '2018-04-11 16:46:09'),
(3370, 'GBWK-67-290(6)-1', '0.9392', 1, '2018-04-11 16:46:09'),
(3371, 'GBWL-67-290(6)-1', '1.3827', 1, '2018-04-11 16:46:09'),
(3372, 'GCCC-67-290(6)-1', '0.445', 1, '2018-04-11 16:46:09'),
(3373, 'GCCD-67-290(6)-1', '0.4435', 1, '2018-04-11 16:46:10'),
(3374, 'GBFT-67-290(2)', '0.8966', 1, '2018-04-11 16:46:10'),
(3375, 'GBFS-67-290(2)', '0.9284', 1, '2018-04-11 16:46:10'),
(3376, 'GBJD-67-290(4)', '0.5756', 1, '2018-04-11 16:46:10'),
(3377, 'GBWM-67-290(4)', '0.2878', 1, '2018-04-11 16:46:10'),
(3378, 'GBEF-67-290(5)', '0.9613', 1, '2018-04-11 16:46:10'),
(3379, 'GBFN-67-290(5)', '1.3449', 1, '2018-04-11 16:46:10'),
(3380, 'GBJS-67-290(5)', '0.6736', 1, '2018-04-11 16:46:10'),
(3381, 'GBJW-67-290(5)', '1.0572', 1, '2018-04-11 16:46:10'),
(3382, 'GHR5-67-290(2)-4', '0.4403', 1, '2018-04-11 16:46:10'),
(3383, 'GHR9-67-290(2)-4', '0.4403', 1, '2018-04-11 16:46:10'),
(3384, 'G46C-67-290(1)-1', '0.4701', 1, '2018-04-11 16:46:10'),
(3385, 'G46E-67-290(1)-1', '0.4449', 1, '2018-04-11 16:46:10'),
(3386, 'GMC8-67-290(1)-2', '0.9344', 1, '2018-04-11 16:46:10'),
(3387, 'GMD7-67-290(1)-3', '0.8996', 1, '2018-04-11 16:46:11'),
(3388, 'G48V-67-290(1)-4', '0.2217', 1, '2018-04-11 16:46:11'),
(3389, 'G48W-67-290A(2)-2', '0.2195', 1, '2018-04-11 16:46:11'),
(3390, 'GRM8-67-290(0)-4', '0.4394', 1, '2018-04-11 16:46:11'),
(3391, 'GRM9-67-290A(2)-2', '0.4373', 1, '2018-04-11 16:46:11'),
(3392, 'GRL6-67-SC0(1)-3', '0.1906', 1, '2018-04-11 16:46:11'),
(3393, 'G53E-67-SH0A(1)', '0.3922', 1, '2018-04-11 16:46:11'),
(3394, 'GCAF-67-SH0A(1)', '0.1985', 1, '2018-04-11 16:46:11'),
(3395, 'GCAF-67-SH0A(1)-1', '0.1985', 1, '2018-04-11 16:46:11'),
(3396, 'GSH7-67-SH0A(1)', '0.3914', 1, '2018-04-11 16:46:11'),
(3397, 'GSH7-67-SH0A(1)-1', '0.3914', 1, '2018-04-11 16:46:11'),
(3398, 'GSH8-67-SH0A(1)', '0.5851', 1, '2018-04-11 16:46:11'),
(3399, 'GSH8-67-SH0A(1)-1', '0.5851', 1, '2018-04-11 16:46:11'),
(3400, 'GBEF-67-SH0(2)', '0.7834', 1, '2018-04-11 16:46:11'),
(3401, 'GBEF-67-SH0(2)-1', '0.7834', 1, '2018-04-11 16:46:12'),
(3402, 'GRG1-67-SH0(17)-1', '0.2856', 1, '2018-04-11 16:46:12'),
(3403, 'GBFN-67-SH0A(2)', '0.198', 1, '2018-04-11 16:46:12'),
(3404, 'GBFP-67-SH0A(2)', '0.3975', 1, '2018-04-11 16:46:12'),
(3405, 'GBEF-67-190(6)-2', '5.346', 1, '2018-04-11 16:46:12'),
(3406, 'GBEF-67-190(6)-3', '5.346', 1, '2018-04-11 16:46:12'),
(3407, 'GBJE-67-190(6)-2', '5.1471', 1, '2018-04-11 16:46:12'),
(3408, 'GBJE-67-190(6)-3', '5.1471', 1, '2018-04-11 16:46:13'),
(3409, 'GBJW-67-190(6)-2', '4.8505', 1, '2018-04-11 16:46:13'),
(3410, 'GBJW-67-190(6)-3', '4.8505', 1, '2018-04-11 16:46:13'),
(3411, 'GBVG-67-190(7)-1', '5.346', 1, '2018-04-11 16:46:13'),
(3412, 'GBVG-67-190(7)-2', '5.346', 1, '2018-04-11 16:46:13'),
(3413, 'GBVN-67-190(7)-1', '5.1471', 1, '2018-04-11 16:46:13'),
(3414, 'GBVN-67-190(7)-2', '0', 1, '2018-04-11 16:46:13'),
(3415, 'GCAG-67-190(6)-2', '4.8505', 1, '2018-04-11 16:46:13'),
(3416, 'GCAG-67-190(6)-3', '0', 1, '2018-04-11 16:46:13'),
(3417, 'GCAH-67-190(6)-2', '5.0494', 1, '2018-04-11 16:46:13'),
(3418, 'GCAH-67-190(6)-3', '5.0494', 1, '2018-04-11 16:46:13'),
(3419, 'GCAJ-67-190(8)-1', '4.8505', 1, '2018-04-11 16:46:13'),
(3420, 'GCAJ-67-190(8)-2', '0', 1, '2018-04-11 16:46:14'),
(3421, 'GCAK-67-190(8)-1', '5.0494', 1, '2018-04-11 16:46:14'),
(3422, 'GCAK-67-190(8)-2', '5.0494', 1, '2018-04-11 16:46:14'),
(3423, 'GCBM-67-190(6)-2', '4.9501', 1, '2018-04-11 16:46:14'),
(3424, 'GCBM-67-190(6)-3', '4.9501', 1, '2018-04-11 16:46:14'),
(3425, 'GCBN-67-190(9)', '4.8505', 1, '2018-04-11 16:46:14'),
(3426, 'GCBN-67-190(9)-1', '4.8505', 1, '2018-04-11 16:46:14'),
(3427, 'GCBP-67-190(9)', '4.9501', 1, '2018-04-11 16:46:14'),
(3428, 'GCBP-67-190(9)-1', '4.9501', 1, '2018-04-11 16:46:14'),
(3429, 'G52N-67-190(7)-2', '4.7536', 1, '2018-04-11 16:46:14'),
(3430, 'G52N-67-190(7)-3', '4.7536', 1, '2018-04-11 16:46:14'),
(3431, 'G52P-67-190(7)-1', '5.054', 1, '2018-04-11 16:46:14'),
(3432, 'G52R-67-190(7)-2', '4.7536', 1, '2018-04-11 16:46:14'),
(3433, 'G52R-67-190(7)-3', '4.7536', 1, '2018-04-11 16:46:15'),
(3434, 'GBJC-67-190(7)-2', '5.1544', 1, '2018-04-11 16:46:15'),
(3435, 'GBJC-67-190(7)-3', '5.1544', 1, '2018-04-11 16:46:15'),
(3436, 'GBKT-67-190(7)-2', '4.9527', 1, '2018-04-11 16:46:15'),
(3437, 'GBKT-67-190(7)-3', '4.9527', 1, '2018-04-11 16:46:15'),
(3438, 'GBVP-67-190(7)-2', '5.1544', 1, '2018-04-11 16:46:15'),
(3439, 'GBVP-67-190(7)-3', '5.1544', 1, '2018-04-11 16:46:15'),
(3440, 'GBVR-67-190(8)-1', '5.1544', 1, '2018-04-11 16:46:15'),
(3441, 'GBVR-67-190(8)-2', '5.1544', 1, '2018-04-11 16:46:15'),
(3442, 'GCBE-67-190(7)-2', '5.1544', 1, '2018-04-11 16:46:15'),
(3443, 'GCBE-67-190(7)-3', '5.1544', 1, '2018-04-11 16:46:15'),
(3444, 'GCCD-67-190(7)-2', '4.8529', 1, '2018-04-11 16:46:16'),
(3445, 'GCCD-67-190(7)-3', '4.8529', 1, '2018-04-11 16:46:16'),
(3446, 'GCCF-67-190(7)-2', '4.9556', 1, '2018-04-11 16:46:16'),
(3447, 'GCCF-67-190(7)-3', '4.9556', 1, '2018-04-11 16:46:16'),
(3448, 'GCCG-67-190(10)', '4.9527', 1, '2018-04-11 16:46:16'),
(3449, 'GCCG-67-190(10)-1', '4.9527', 1, '2018-04-11 16:46:16'),
(3450, 'GCCH-67-190(10)', '4.8529', 1, '2018-04-11 16:46:16'),
(3451, 'GCCH-67-190(10)-1', '4.8529', 1, '2018-04-11 16:46:16'),
(3452, 'GCCJ-67-190(10)', '4.9556', 1, '2018-04-11 16:46:16'),
(3453, 'GCCJ-67-190(10)-1', '4.9556', 1, '2018-04-11 16:46:17'),
(3454, 'GBEG-67-190(9)-2', '3.0587', 1, '2018-04-11 16:46:17'),
(3455, 'GLW3-67-190D(19)-1', '4.1418', 1, '2018-04-11 16:46:17'),
(3456, 'GRK7-67-190A(13)-1', '4.3405', 1, '2018-04-11 16:46:17'),
(3457, 'GRK7-67-190A(13)-2', '4.3405', 1, '2018-04-11 16:46:17'),
(3458, 'GRM1-67-190A(13)-1', '4.3405', 1, '2018-04-11 16:46:17'),
(3459, 'GRM1-67-190A(13)-2', '0', 1, '2018-04-11 16:46:17'),
(3460, 'GRM9-67-190A(13)-1', '3.9442', 1, '2018-04-11 16:46:17'),
(3461, 'GRM9-67-190A(13)-2', '0', 1, '2018-04-11 16:46:17'),
(3462, 'GMA4-67-190C(13)-1', '3.9442', 1, '2018-04-11 16:46:18'),
(3463, 'GMA4-67-190C(13)-2', '0', 1, '2018-04-11 16:46:18'),
(3464, 'GMA5-67-190C(13)-1', '4.3405', 1, '2018-04-11 16:46:18'),
(3465, 'GMA5-67-190C(13)-2', '0', 1, '2018-04-11 16:46:18'),
(3466, 'GMP2-67-190D(13)-1', '4.7302', 1, '2018-04-11 16:46:18'),
(3467, 'GMP2-67-190D(13)-2', '4.7302', 1, '2018-04-11 16:46:18'),
(3468, 'GMV7-67-190C(13)-1', '4.2389', 1, '2018-04-11 16:46:18'),
(3469, 'GMV7-67-190C(13)-2', '0', 1, '2018-04-11 16:46:18'),
(3470, 'GPN2-67-190B(13)-1', '3.06', 1, '2018-04-11 16:46:18'),
(3471, 'GPN2-67-190B(13)-2', '0', 1, '2018-04-11 16:46:19'),
(3472, 'G46C-67-190B(11)-1', '4.6355', 1, '2018-04-11 16:46:19'),
(3473, 'G46C-67-190B(11)-2', '0', 1, '2018-04-11 16:46:19'),
(3474, 'G48V-67-190A(11)-1', '4.1402', 1, '2018-04-11 16:46:19'),
(3475, 'G48V-67-190A(11)-2', '0', 1, '2018-04-11 16:46:19'),
(3476, 'GMP6-67-190C(11)-1', '4.3407', 1, '2018-04-11 16:46:19'),
(3477, 'GMP6-67-190C(11)-2', '0', 1, '2018-04-11 16:46:19'),
(3478, 'GNR7-67-190C(11)-1', '4.1419', 1, '2018-04-11 16:46:19'),
(3479, 'GNR7-67-190C(11)-2', '0', 1, '2018-04-11 16:46:19'),
(3480, 'GNR8-67-190C(11)-1', '4.2411', 1, '2018-04-11 16:46:19'),
(3481, 'GNR8-67-190C(11)-2', '0', 1, '2018-04-11 16:46:20'),
(3482, 'GRS5-67-190A(11)-1', '0', 1, '2018-04-11 16:46:20'),
(3483, 'GRS5-67-190A(11)-2', '0', 1, '2018-04-11 16:46:20'),
(3484, 'G44N-V7-375(4)-8', '5.5167', 1, '2018-04-11 16:46:20'),
(3485, 'GBEF-67-200(6)-2', '4.3421', 1, '2018-04-11 16:46:20'),
(3486, 'GBEF-67-200(6)-3', '4.3421', 1, '2018-04-11 16:46:20'),
(3487, 'GBJE-67-200(6)-2', '4.1433', 1, '2018-04-11 16:46:20'),
(3488, 'GBJE-67-200(6)-3', '4.1433', 1, '2018-04-11 16:46:20'),
(3489, 'GBJW-67-200(6)-2', '3.7491', 1, '2018-04-11 16:46:20'),
(3490, 'GBJW-67-200(6)-3', '3.7491', 1, '2018-04-11 16:46:20'),
(3491, 'GBVG-67-200(7)-1', '4.3421', 1, '2018-04-11 16:46:20'),
(3492, 'GBVG-67-200(7)-2', '4.3421', 1, '2018-04-11 16:46:20'),
(3493, 'GBVN-67-200(7)-1', '4.3421', 1, '2018-04-11 16:46:20'),
(3494, 'GBVN-67-200(7)-2', '0', 1, '2018-04-11 16:46:21'),
(3495, 'GCAG-67-200(6)-2', '3.7491', 1, '2018-04-11 16:46:21'),
(3496, 'GCAG-67-200(6)-3', '0', 1, '2018-04-11 16:46:21'),
(3497, 'GCAH-67-200(6)-2', '3.948', 1, '2018-04-11 16:46:21'),
(3498, 'GCAH-67-200(6)-3', '3.948', 1, '2018-04-11 16:46:21'),
(3499, 'GCAJ-67-200(8)-1', '3.7491', 1, '2018-04-11 16:46:21'),
(3500, 'GCAJ-67-200(8)-2', '0', 1, '2018-04-11 16:46:21'),
(3501, 'GCAK-67-200(8)-1', '3.948', 1, '2018-04-11 16:46:21'),
(3502, 'GCAK-67-200(8)-2', '3.948', 1, '2018-04-11 16:46:21'),
(3503, 'GCBL-67-200(9)-1', '3.7491', 1, '2018-04-11 16:46:21'),
(3504, 'GCBL-67-200(9)-2', '3.7491', 1, '2018-04-11 16:46:21'),
(3505, 'G52N-67-200(7)-2', '3.5557', 1, '2018-04-11 16:46:22'),
(3506, 'G52N-67-200(7)-3', '3.5557', 1, '2018-04-11 16:46:22'),
(3507, 'G52P-67-200(7)-1', '2.9745', 1, '2018-04-11 16:46:22'),
(3508, 'G52R-67-200(7)-2', '3.5556', 1, '2018-04-11 16:46:22'),
(3509, 'G52R-67-200(7)-3', '3.5556', 1, '2018-04-11 16:46:22'),
(3510, 'GBJC-67-200(7)-2', '3.8572', 1, '2018-04-11 16:46:22'),
(3511, 'GBJC-67-200(7)-3', '3.8572', 1, '2018-04-11 16:46:22'),
(3512, 'GBKT-67-200(7)-2', '3.5601', 1, '2018-04-11 16:46:22'),
(3513, 'GBKT-67-200(7)-3', '3.5601', 1, '2018-04-11 16:46:22'),
(3514, 'GBVP-67-200(7)-2', '3.9598', 1, '2018-04-11 16:46:22'),
(3515, 'GBVP-67-200(7)-3', '3.9598', 1, '2018-04-11 16:46:22'),
(3516, 'GBVR-67-200(8)-1', '3.9598', 1, '2018-04-11 16:46:22'),
(3517, 'GBVR-67-200(8)-2', '3.9598', 1, '2018-04-11 16:46:23'),
(3518, 'GCBE-67-200(7)-2', '3.8572', 1, '2018-04-11 16:46:23'),
(3519, 'GCBE-67-200(7)-3', '3.8572', 1, '2018-04-11 16:46:23'),
(3520, 'GCCD-67-200(7)-2', '3.6627', 1, '2018-04-11 16:46:23'),
(3521, 'GCCD-67-200(7)-3', '3.6627', 1, '2018-04-11 16:46:23'),
(3522, 'GCCE-67-200(10)', '3.5601', 1, '2018-04-11 16:46:23'),
(3523, 'GCCE-67-200(10)-1', '3.5601', 1, '2018-04-11 16:46:23'),
(3524, 'GCCF-67-200(10)', '3.6627', 1, '2018-04-11 16:46:23'),
(3525, 'GCCF-67-200(10)-1', '3.6627', 1, '2018-04-11 16:46:23'),
(3526, 'GBEG-67-200(5)-2', '2.061', 1, '2018-04-11 16:46:23'),
(3527, 'GMA4-67-200A(7)-1', '2.652', 1, '2018-04-11 16:46:23'),
(3528, 'GMA4-67-200A(7)-2', '0', 1, '2018-04-11 16:46:24'),
(3529, 'GMA5-67-200A(7)-1', '3.1498', 1, '2018-04-11 16:46:24'),
(3530, 'GMA5-67-200A(7)-2', '0', 1, '2018-04-11 16:46:24'),
(3531, 'GMD9-67-200A(7)-1', '3.1498', 1, '2018-04-11 16:46:24'),
(3532, 'GMD9-67-200A(7)-2', '3.1498', 1, '2018-04-11 16:46:24'),
(3533, 'GMV7-67-200A(7)-1', '3.0482', 1, '2018-04-11 16:46:24'),
(3534, 'GMV7-67-200A(7)-2', '3.0482', 1, '2018-04-11 16:46:24'),
(3535, 'GPN2-67-200A(7)-1', '2.0619', 1, '2018-04-11 16:46:24'),
(3536, 'GPN2-67-200A(7)-2', '0', 1, '2018-04-11 16:46:24'),
(3537, 'G46C-67-200A(6)-1', '2.5634', 1, '2018-04-11 16:46:24'),
(3538, 'G46C-67-200A(6)-2', '0', 1, '2018-04-11 16:46:24'),
(3539, 'G48V-67-200A(6)-1', '2.9469', 1, '2018-04-11 16:46:24'),
(3540, 'G48V-67-200A(6)-2', '0', 1, '2018-04-11 16:46:25'),
(3541, 'GMC8-67-200A(6)-1', '3.15', 1, '2018-04-11 16:46:25'),
(3542, 'GMC8-67-200A(6)-2', '0', 1, '2018-04-11 16:46:25'),
(3543, 'GMP6-67-200A(6)-1', '3.15', 1, '2018-04-11 16:46:25'),
(3544, 'GMP6-67-200A(6)-2', '0', 1, '2018-04-11 16:46:25'),
(3545, 'GNR7-67-200A(6)-1', '2.9512', 1, '2018-04-11 16:46:25'),
(3546, 'GNR7-67-200A(6)-2', '0', 1, '2018-04-11 16:46:25'),
(3547, 'G52D-67-210(4)-2', '1.8802', 1, '2018-04-11 16:46:25'),
(3548, 'G52E-67-210(4)-1', '1.2972', 1, '2018-04-11 16:46:25'),
(3549, 'GBEF-67-210(4)-2', '1.9829', 1, '2018-04-11 16:46:25'),
(3550, 'GBFW-67-210(4)-2', '2.0866', 1, '2018-04-11 16:46:25'),
(3551, 'G52N-67-210(2)-3', '1.8772', 1, '2018-04-11 16:46:25'),
(3552, 'G52P-67-210(2)-2', '1.2943', 1, '2018-04-11 16:46:25'),
(3553, 'GBFT-67-210(2)-3', '1.9794', 1, '2018-04-11 16:46:26'),
(3554, 'GBGA-67-210(2)-3', '2.0826', 1, '2018-04-11 16:46:26'),
(3555, 'G52D-67-220(4)-2', '1.8801', 1, '2018-04-11 16:46:26'),
(3556, 'G52E-67-220(4)-1', '1.2972', 1, '2018-04-11 16:46:26'),
(3557, 'GBEF-67-220(4)-2', '1.9828', 1, '2018-04-11 16:46:26'),
(3558, 'GBFW-67-220(4)-2', '2.0865', 1, '2018-04-11 16:46:26'),
(3559, 'G52N-67-220(2)-3', '1.8771', 1, '2018-04-11 16:46:26'),
(3560, 'G52P-67-220(2)-2', '1.2943', 1, '2018-04-11 16:46:26'),
(3561, 'GBFT-67-220(2)-3', '1.9792', 1, '2018-04-11 16:46:26'),
(3562, 'GBGA-67-220(2)-3', '2.0825', 1, '2018-04-11 16:46:26'),
(3563, 'G48W-67-210(7)-3-P', '1.5796', 1, '2018-04-11 16:46:26'),
(3564, 'G48W-67-220(7)-4-P', '1.5797', 1, '2018-04-11 16:46:26'),
(3565, 'G44N-67-210(6)-6-P', '1.0905', 1, '2018-04-11 16:46:26'),
(3566, 'G44N-67-220(6)-7-P', '1.0905', 1, '2018-04-11 16:46:27'),
(3567, 'GHK1-67-210A(9)-1-P', '1.6849', 1, '2018-04-11 16:46:27'),
(3568, 'GHP9-67-210(6)-6-P', '1.6805', 1, '2018-04-11 16:46:27'),
(3569, 'GHP9-67-220(6)-7-P', '1.6807', 1, '2018-04-11 16:46:27'),
(3570, 'GLG9-67-210(6)-6-P', '1.5795', 1, '2018-04-11 16:46:27'),
(3571, 'GLG9-67-220(6)-7-P', '1.5796', 1, '2018-04-11 16:46:27'),
(3572, 'G48J-67-210A(9)-1-P', '1.5834', 1, '2018-04-11 16:46:27'),
(3573, 'G48J-67-220A(9)-1-P', '1.5836', 1, '2018-04-11 16:46:27'),
(3574, 'G44A-67-210A(9)-1-P', '1.1952', 1, '2018-04-11 16:46:27'),
(3575, 'G44A-67-220A(9)-1-P', '1.1955', 1, '2018-04-11 16:46:27'),
(3576, 'GHK1-67-220A(9)-1-P', '1.6851', 1, '2018-04-11 16:46:28'),
(3577, 'GJS1-67-210A(9)-1-P', '1.5834', 1, '2018-04-11 16:46:28'),
(3578, 'GJS1-67-220A(9)-1-P', '1.5836', 1, '2018-04-11 16:46:28'),
(3579, 'B62T-67-060(18)-2', '2.4579', 1, '2018-04-11 16:46:28'),
(3580, 'B62T-67-060(18)-3', '2.4579', 1, '2018-04-11 16:46:28'),
(3581, 'B63B-67-060(18)-2', '2.8458', 1, '2018-04-11 16:46:28'),
(3582, 'B63B-67-060(18)-3', '2.8458', 1, '2018-04-11 16:46:28'),
(3583, 'B63D-67-060(18)-2', '2.4529', 1, '2018-04-11 16:46:28'),
(3584, 'B63D-67-060(18)-3', '2.4529', 1, '2018-04-11 16:46:28'),
(3585, 'B63F-67-060(18)-2', '2.8508', 1, '2018-04-11 16:46:29'),
(3586, 'B63F-67-060(18)-3', '2.8508', 1, '2018-04-11 16:46:29'),
(3587, 'BHN9-67-060A(17)-2', '2.4529', 1, '2018-04-11 16:46:29'),
(3588, 'BHN9-67-060A(17)-3', '2.4529', 1, '2018-04-11 16:46:29'),
(3589, 'BHP1-67-060A(17)-2', '2.8458', 1, '2018-04-11 16:46:29'),
(3590, 'BHP1-67-060A(17)-3', '2.8458', 1, '2018-04-11 16:46:29'),
(3591, 'BHP2-67-060A(17)-2', '2.4529', 1, '2018-04-11 16:46:29'),
(3592, 'BHP2-67-060A(17)-3', '2.4529', 1, '2018-04-11 16:46:29'),
(3593, 'BHP3-67-060(17)-2', '2.8458', 1, '2018-04-11 16:46:29'),
(3594, 'BHP3-67-060(17)-3', '0', 1, '2018-04-11 16:46:29'),
(3595, 'BHS7-67-060A(17)-2', '2.4577', 1, '2018-04-11 16:46:29'),
(3596, 'BHS7-67-060A(17)-3', '2.4577', 1, '2018-04-11 16:46:29'),
(3597, 'BHT1-67-060A(17)-2', '2.8506', 1, '2018-04-11 16:46:30'),
(3598, 'BHT1-67-060A(17)-3', '2.8506', 1, '2018-04-11 16:46:30'),
(3599, 'BHT9-67-060A(17)-2', '2.4579', 1, '2018-04-11 16:46:30'),
(3600, 'BHT9-67-060A(17)-3', '2.4579', 1, '2018-04-11 16:46:30'),
(3601, 'BHV3-67-060A(17)-2', '2.8508', 1, '2018-04-11 16:46:30'),
(3602, 'BHV3-67-060A(17)-3', '2.8508', 1, '2018-04-11 16:46:30'),
(3603, 'BJG8-67-060A(17)-2', '2.4577', 1, '2018-04-11 16:46:30'),
(3604, 'BJG8-67-060A(17)-3', '2.4577', 1, '2018-04-11 16:46:30'),
(3605, 'BJG9-67-060A(17)-2', '2.8506', 1, '2018-04-11 16:46:30'),
(3606, 'BJG9-67-060A(17)-3', '2.8506', 1, '2018-04-11 16:46:30'),
(3607, 'BPS4-67-060(17)-2', '2.4579', 1, '2018-04-11 16:46:30'),
(3608, 'BPS4-67-060(17)-3', '2.4579', 1, '2018-04-11 16:46:31'),
(3609, 'BPS5-67-060(17)-2', '2.8508', 1, '2018-04-11 16:46:31'),
(3610, 'BPS5-67-060(17)-3', '2.8508', 1, '2018-04-11 16:46:31'),
(3611, 'B54K-67-060C(11)-1', '1.4182', 1, '2018-04-11 16:46:31'),
(3612, 'B54K-67-060C(11)-2', '1.4182', 1, '2018-04-11 16:46:31'),
(3613, 'B54L-67-060C(11)-1', '1.8102', 1, '2018-04-11 16:46:31'),
(3614, 'B54L-67-060C(11)-2', '1.8102', 1, '2018-04-11 16:46:31'),
(3615, 'B54M-67-060C(11)-1', '1.4153', 1, '2018-04-11 16:46:31'),
(3616, 'B54M-67-060C(11)-2', '1.4153', 1, '2018-04-11 16:46:31'),
(3617, 'B54N-67-060C(11)-1', '1.8073', 1, '2018-04-11 16:46:31'),
(3618, 'B54N-67-060C(11)-2', '1.8073', 1, '2018-04-11 16:46:32'),
(3619, 'B63C-67-060(12)-1', '1.8073', 1, '2018-04-11 16:46:32'),
(3620, 'B63C-67-060(12)-2', '1.8073', 1, '2018-04-11 16:46:32'),
(3621, 'B63E-67-060(12)-1', '1.4153', 1, '2018-04-11 16:46:32'),
(3622, 'B63E-67-060(12)-2', '0', 1, '2018-04-11 16:46:32'),
(3623, 'B64K-67-060(12)-1', '1.8102', 1, '2018-04-11 16:46:32'),
(3624, 'B64K-67-060(12)-2', '1.8102', 1, '2018-04-11 16:46:32'),
(3625, 'BHN1-67-060A(6)-6', '1.2088', 1, '2018-04-11 16:46:32'),
(3626, 'BRL6-67-060C(11)-1', '1.2102', 1, '2018-04-11 16:46:32'),
(3627, 'BRL6-67-060C(11)-2', '1.2102', 1, '2018-04-11 16:46:32'),
(3628, 'BRL7-67-060C(11)-1', '1.2102', 1, '2018-04-11 16:46:32'),
(3629, 'BRL7-67-060C(11)-2', '1.2102', 1, '2018-04-11 16:46:32'),
(3630, 'BRL8-67-060C(11)-1', '1.4153', 1, '2018-04-11 16:46:33'),
(3631, 'BRL8-67-060C(11)-2', '1.4153', 1, '2018-04-11 16:46:33'),
(3632, 'BRL9-67-060C(11)-1', '1.8073', 1, '2018-04-11 16:46:33'),
(3633, 'BRL9-67-060C(11)-2', '1.8073', 1, '2018-04-11 16:46:33'),
(3634, 'BRM8-67-060C(11)-1', '1.6022', 1, '2018-04-11 16:46:33'),
(3635, 'BRM8-67-060C(11)-2', '1.6022', 1, '2018-04-11 16:46:33'),
(3636, 'BRM9-67-060C(11)-1', '1.6022', 1, '2018-04-11 16:46:33'),
(3637, 'BRM9-67-060C(11)-2', '1.6022', 1, '2018-04-11 16:46:33'),
(3638, 'BHP2-67-130B(9)-7', '0', 1, '2018-04-11 16:46:33'),
(3639, 'BABG-67-130(0)-8', '1.5186', 1, '2018-04-11 16:46:33'),
(3640, 'BABG-67-130(0)-9', '1.5186', 1, '2018-04-11 16:46:33'),
(3641, 'BABH-67-130(0)-8', '0.9007', 1, '2018-04-11 16:46:33'),
(3642, 'BABH-67-130(0)-9', '0.9007', 1, '2018-04-11 16:46:34'),
(3643, 'BABJ-67-130(2)-7', '2.12', 1, '2018-04-11 16:46:34'),
(3644, 'BABJ-67-130(2)-8', '2.12', 1, '2018-04-11 16:46:34'),
(3645, 'BABT-67-130(0)-8', '1.21', 1, '2018-04-11 16:46:34'),
(3646, 'BABT-67-130(0)-9', '0', 1, '2018-04-11 16:46:34'),
(3647, 'BABV-67-130(2)-7', '1.8135', 1, '2018-04-11 16:46:34'),
(3648, 'BABV-67-130(2)-8', '0', 1, '2018-04-11 16:46:34'),
(3649, 'BAES-67-130(2)-7', '1.1133', 1, '2018-04-11 16:46:34'),
(3650, 'BAES-67-130(2)-8', '1.1133', 1, '2018-04-11 16:46:35'),
(3651, 'BAET-67-130(0)-8', '1.2172', 1, '2018-04-11 16:46:35'),
(3652, 'BAET-67-130(0)-9', '1.2172', 1, '2018-04-11 16:46:35'),
(3653, 'BAFA-67-130(1)-8', '0.5104', 1, '2018-04-11 16:46:35'),
(3654, 'BAFA-67-130(1)-9', '0.5104', 1, '2018-04-11 16:46:35'),
(3655, 'BALV-67-130(0)-8', '0.1938', 1, '2018-04-11 16:46:35'),
(3656, 'BALV-67-130(0)-9', '0.1938', 1, '2018-04-11 16:46:35'),
(3657, 'BALW-67-130(0)-8', '0.5104', 1, '2018-04-11 16:46:35'),
(3658, 'BALW-67-130(0)-9', '0.5104', 1, '2018-04-11 16:46:35'),
(3659, 'BAMA-67-130(1)-8', '0.8183', 1, '2018-04-11 16:46:35'),
(3660, 'BAMA-67-130(1)-9', '0.8183', 1, '2018-04-11 16:46:36'),
(3661, 'BAMB-67-130(2)-7', '1.4198', 1, '2018-04-11 16:46:36'),
(3662, 'BAMB-67-130(2)-8', '1.4198', 1, '2018-04-11 16:46:36'),
(3663, 'BAMD-67-130(2)-7', '1.8201', 1, '2018-04-11 16:46:36'),
(3664, 'BAMD-67-130(2)-8', '0', 1, '2018-04-11 16:46:36'),
(3665, 'BAMF-67-130(2)-7', '2.224', 1, '2018-04-11 16:46:36'),
(3666, 'BAMF-67-130(2)-8', '2.224', 1, '2018-04-11 16:46:36'),
(3667, 'BSR4-67-130(2)-7', '1.1301', 1, '2018-04-11 16:46:36'),
(3668, 'BSR4-67-130(2)-8', '1.1301', 1, '2018-04-11 16:46:36'),
(3669, 'BSR6-67-130(2)-7', '1.4374', 1, '2018-04-11 16:46:36'),
(3670, 'BSR6-67-130(2)-8', '1.4374', 1, '2018-04-11 16:46:36'),
(3671, 'B63H-67-130(5)', '1.1094', 1, '2018-04-11 16:46:36'),
(3672, 'B63H-67-130(5)-1', '1.1094', 1, '2018-04-11 16:46:36'),
(3673, 'BBJS-67-130(3)-3', '0.5057', 1, '2018-04-11 16:46:37'),
(3674, 'BBJS-67-130(3)-4', '0.5057', 1, '2018-04-11 16:46:37'),
(3675, 'BRP2-67-130(3)-3', '1.4163', 1, '2018-04-11 16:46:37'),
(3676, 'BRP2-67-130(3)-4', '1.4163', 1, '2018-04-11 16:46:37'),
(3677, 'B62T-67-130(0)-7', '0.8141', 1, '2018-04-11 16:46:37'),
(3678, 'B62T-67-130(0)-8', '0.8141', 1, '2018-04-11 16:46:37'),
(3679, 'B63D-67-130(2)-7', '1.1094', 1, '2018-04-11 16:46:37'),
(3680, 'B63D-67-130(2)-8', '1.1094', 1, '2018-04-11 16:46:37'),
(3681, 'B63E-67-130(0)-7', '0.1936', 1, '2018-04-11 16:46:37'),
(3682, 'B63E-67-130(0)-8', '0.1936', 1, '2018-04-11 16:46:38'),
(3683, 'B63F-67-130(2)-7', '1.4163', 1, '2018-04-11 16:46:38'),
(3684, 'B63F-67-130(2)-8', '1.4163', 1, '2018-04-11 16:46:38'),
(3685, 'B63G-67-130(1)-7', '2.1096', 1, '2018-04-11 16:46:38'),
(3686, 'B63G-67-130(1)-8', '2.1096', 1, '2018-04-11 16:46:38'),
(3687, 'B63M-67-130(2)-7', '1.1101', 1, '2018-04-11 16:46:38'),
(3688, 'B63M-67-130(2)-8', '0', 1, '2018-04-11 16:46:38'),
(3689, 'B63P-67-130(0)-7', '0.5057', 1, '2018-04-11 16:46:38'),
(3690, 'B63P-67-130(0)-8', '0', 1, '2018-04-11 16:46:38'),
(3691, 'B64E-67-130(0)-7', '0.5057', 1, '2018-04-11 16:46:38'),
(3692, 'B64E-67-130(0)-8', '0', 1, '2018-04-11 16:46:38'),
(3693, 'B64K-67-130(0)-7', '1.5077', 1, '2018-04-11 16:46:39'),
(3694, 'B64K-67-130(0)-8', '1.5077', 1, '2018-04-11 16:46:39'),
(3695, 'BAKS-67-130(4)-1', '0.8032', 1, '2018-04-11 16:46:39'),
(3696, 'BAKS-67-130(4)-2', '0.8032', 1, '2018-04-11 16:46:39'),
(3697, 'BAKT-67-130(0)-7', '1.2064', 1, '2018-04-11 16:46:39'),
(3698, 'BAKT-67-130(0)-8', '0', 1, '2018-04-11 16:46:39'),
(3699, 'BALK-67-130(0)-7', '0.8943', 1, '2018-04-11 16:46:39'),
(3700, 'BALK-67-130(0)-8', '0.8943', 1, '2018-04-11 16:46:39'),
(3701, 'BALL-67-130(0)-7', '1.2035', 1, '2018-04-11 16:46:39'),
(3702, 'BALL-67-130(0)-8', '1.2035', 1, '2018-04-11 16:46:39'),
(3703, 'BJE3-67-SH0(1)-6', '0.2855', 1, '2018-04-11 16:46:39'),
(3704, 'DM0P-67-SH0(19)', '0.2855', 1, '2018-04-11 16:46:40'),
(3705, 'B62T-67-100(4)-2', '0.93', 1, '2018-04-11 16:46:40'),
(3706, 'B63B-67-100(4)-2', '0.5292', 1, '2018-04-11 16:46:40'),
(3707, 'B63D-67-100(4)-2', '0.3279', 1, '2018-04-11 16:46:40'),
(3708, 'B63F-67-100(4)-2', '0.9316', 1, '2018-04-11 16:46:40'),
(3709, 'BAAN-67-100(4)-2', '1.3529', 1, '2018-04-11 16:46:40'),
(3710, 'BAEK-67-100(6)-1', '1.3303', 1, '2018-04-11 16:46:40'),
(3711, 'BAFN-67-100(4)-2', '1.3626', 1, '2018-04-11 16:46:40'),
(3712, 'BAFR-67-100(7)-1', '1.3399', 1, '2018-04-11 16:46:40'),
(3713, 'BBPN-67-100(9)-1', '1.3383', 1, '2018-04-11 16:46:40'),
(3714, 'BBRJ-67-100(4)-2', '1.361', 1, '2018-04-11 16:46:40'),
(3715, 'BHN1-67-100A(4)-2', '0.317', 1, '2018-04-11 16:46:40'),
(3716, 'BHN2-67-100A(4)-2', '0.518', 1, '2018-04-11 16:46:41'),
(3717, 'BHN3-67-100A(4)-2', '0.9187', 1, '2018-04-11 16:46:41'),
(3718, 'BHN4-67-100A(4)-2', '0.9203', 1, '2018-04-11 16:46:41'),
(3719, 'BHP1-67-100A(6)-3', '0.5292', 1, '2018-04-11 16:46:41'),
(3720, 'BHP2-67-100A(6)-3', '0.9314', 1, '2018-04-11 16:46:41'),
(3721, 'BHP5-67-100A(6)-3', '0.9297', 1, '2018-04-11 16:46:41'),
(3722, 'BWJW-67-100(0)-1', '0.9297', 1, '2018-04-11 16:46:41'),
(3723, 'BWKA-67-100(0)-1', '0.9186', 1, '2018-04-11 16:46:41'),
(3724, 'BWKV-67-100(0)-1', '0.5179', 1, '2018-04-11 16:46:41'),
(3725, 'B63C-67-SC0(1)-3', '0.1888', 1, '2018-04-11 16:46:41'),
(3726, 'BHN3-67-SH0A(2)-1', '0.5452', 1, '2018-04-11 16:46:41'),
(3727, 'BHP5-67-SH0(2)-3', '0.191', 1, '2018-04-11 16:46:41'),
(3728, 'BHR1-67-290(1)-2', '1.0154', 1, '2018-04-11 16:46:42'),
(3729, 'BJD5-67-SH0(1)-1', '0.5445', 1, '2018-04-11 16:46:42'),
(3730, 'BJE6-67-SH0(0)-5', '0.3809', 1, '2018-04-11 16:46:42'),
(3731, 'BHN9-67-290(2)-2', '0.2144', 1, '2018-04-11 16:46:42'),
(3732, 'BHP1-67-290(1)-6', '0.4389', 1, '2018-04-11 16:46:42'),
(3733, 'BHP2-67-290(1)-6', '0.4389', 1, '2018-04-11 16:46:42'),
(3734, 'B62S-67-290(1)-7', '0.6627', 1, '2018-04-11 16:46:42'),
(3735, 'B63C-67-290(1)-8', '0.4389', 1, '2018-04-11 16:46:42'),
(3736, 'B63D-67-290(1)', '1.0957', 1, '2018-04-11 16:46:42'),
(3737, 'B63K-67-290A(6)-1', '0.8812', 1, '2018-04-11 16:46:42'),
(3738, 'B63M-67-290(1)-7', '0.2169', 1, '2018-04-11 16:46:42'),
(3739, 'B63P-67-290(1)', '0.8814', 1, '2018-04-11 16:46:42'),
(3740, 'BWKV-67-290(0)-2', '0.2169', 1, '2018-04-11 16:46:43'),
(3741, 'B64F-67-290(0)-5', '0.9125', 1, '2018-04-11 16:46:43'),
(3742, 'BWJW-67-290(0)-2', '0.9126', 1, '2018-04-11 16:46:43'),
(3743, 'B63B-67-290(0)-5', '0.9116', 1, '2018-04-11 16:46:43'),
(3744, 'BWKW-67-290(0)-2', '0.9121', 1, '2018-04-11 16:46:43'),
(3745, 'BABD-67-190A(2)-2', '3.6397', 1, '2018-04-11 16:46:43'),
(3746, 'BABD-67-190A(2)-3', '3.6397', 1, '2018-04-11 16:46:43'),
(3747, 'BABE-67-190A(2)-2', '4.042', 1, '2018-04-11 16:46:43'),
(3748, 'BABE-67-190A(2)-3', '4.042', 1, '2018-04-11 16:46:44'),
(3749, 'BABF-67-190(1)-3', '3.9407', 1, '2018-04-11 16:46:44'),
(3750, 'BABF-67-190(1)-4', '3.9407', 1, '2018-04-11 16:46:44'),
(3751, 'BABT-67-190(1)-3', '4.1358', 1, '2018-04-11 16:46:44'),
(3752, 'BABT-67-190(1)-4', '4.1358', 1, '2018-04-11 16:46:44'),
(3753, 'BABV-67-190(1)-3', '4.5381', 1, '2018-04-11 16:46:44'),
(3754, 'BABV-67-190(1)-4', '4.5381', 1, '2018-04-11 16:46:44'),
(3755, 'BAER-67-190A(4)-1', '4.1342', 1, '2018-04-11 16:46:44'),
(3756, 'BAER-67-190A(4)-2', '4.1342', 1, '2018-04-11 16:46:44'),
(3757, 'BALW-67-190(1)-3', '4.343', 1, '2018-04-11 16:46:44'),
(3758, 'BALW-67-190(1)-4', '4.343', 1, '2018-04-11 16:46:45'),
(3759, 'BSR2-67-190A(4)-1', '4.5365', 1, '2018-04-11 16:46:45'),
(3760, 'BSR2-67-190A(4)-2', '4.5365', 1, '2018-04-11 16:46:45'),
(3761, 'BSR7-67-190A(4)-1', '4.6381', 1, '2018-04-11 16:46:45'),
(3762, 'BSR7-67-190A(4)-2', '4.6381', 1, '2018-04-11 16:46:45'),
(3763, 'BSR8-67-190A(4)-1', '4.1342', 1, '2018-04-11 16:46:45'),
(3764, 'BSR8-67-190A(4)-2', '4.1342', 1, '2018-04-11 16:46:45'),
(3765, 'BSR9-67-190A(4)-1', '4.5365', 1, '2018-04-11 16:46:45'),
(3766, 'BSR9-67-190A(4)-2', '4.5365', 1, '2018-04-11 16:46:45'),
(3767, 'B62S-67-190(4)-4', '4.5361', 1, '2018-04-11 16:46:45'),
(3768, 'B62S-67-190(4)-5', '4.5361', 1, '2018-04-11 16:46:45'),
(3769, 'B63C-67-190(10)-1', '4.5361', 1, '2018-04-11 16:46:45'),
(3770, 'B63C-67-190(10)-2', '4.5361', 1, '2018-04-11 16:46:46'),
(3771, 'B63E-67-190(4)-4', '4.1339', 1, '2018-04-11 16:46:46'),
(3772, 'B63E-67-190(4)-5', '4.1339', 1, '2018-04-11 16:46:46'),
(3773, 'BAEK-67-190A(6)-4', '4.1428', 1, '2018-04-11 16:46:46'),
(3774, 'BAEK-67-190A(6)-5', '4.1428', 1, '2018-04-11 16:46:47'),
(3775, 'BAKT-67-190A(6)-4', '4.1339', 1, '2018-04-11 16:46:47'),
(3776, 'BAKT-67-190A(6)-5', '4.1339', 1, '2018-04-11 16:46:47'),
(3777, 'BAKV-67-190A(6)-4', '4.5361', 1, '2018-04-11 16:46:47'),
(3778, 'BAKV-67-190A(6)-5', '4.5361', 1, '2018-04-11 16:46:47'),
(3779, 'BALE-67-190A(6)-4', '3.7406', 1, '2018-04-11 16:46:47'),
(3780, 'BALE-67-190A(6)-5', '3.7406', 1, '2018-04-11 16:46:47'),
(3781, 'BALK-67-190A(6)-4', '4.2352', 1, '2018-04-11 16:46:47'),
(3782, 'BALK-67-190A(6)-5', '4.2352', 1, '2018-04-11 16:46:47'),
(3783, 'BALM-67-190A(6)-4', '4.6374', 1, '2018-04-11 16:46:47'),
(3784, 'BALM-67-190A(6)-5', '4.6374', 1, '2018-04-11 16:46:48'),
(3785, 'BBJS-67-190(4)-4', '4.5376', 1, '2018-04-11 16:46:48'),
(3786, 'BBJS-67-190(4)-5', '4.5376', 1, '2018-04-11 16:46:48'),
(3787, 'BBJT-67-190(11)-1', '4.5376', 1, '2018-04-11 16:46:48'),
(3788, 'BBJT-67-190(11)-2', '4.5376', 1, '2018-04-11 16:46:48'),
(3789, 'BABD-67-200(11)-5', '2.4521', 1, '2018-04-11 16:46:49'),
(3790, 'BABD-67-200(11)-6', '2.4521', 1, '2018-04-11 16:46:49'),
(3791, 'BABE-67-200(11)-5', '2.8541', 1, '2018-04-11 16:46:49'),
(3792, 'BABE-67-200(11)-6', '2.8541', 1, '2018-04-11 16:46:49'),
(3793, 'BABF-67-200(11)-5', '2.4599', 1, '2018-04-11 16:46:49'),
(3794, 'BABF-67-200(11)-6', '0', 1, '2018-04-11 16:46:49'),
(3795, 'BAER-67-200(11)-5', '2.0652', 1, '2018-04-11 16:46:49'),
(3796, 'BAER-67-200(11)-6', '2.0652', 1, '2018-04-11 16:46:49'),
(3797, 'BALV-67-200(11)-5', '2.2619', 1, '2018-04-11 16:46:49'),
(3798, 'BALV-67-200(11)-6', '2.2619', 1, '2018-04-11 16:46:49'),
(3799, 'BALW-67-200(15)-2', '2.8605', 1, '2018-04-11 16:46:49'),
(3800, 'BALW-67-200(15)-3', '2.8605', 1, '2018-04-11 16:46:49'),
(3801, 'BSR2-67-200(11)-5', '2.4673', 1, '2018-04-11 16:46:50'),
(3802, 'BSR2-67-200(11)-6', '2.4673', 1, '2018-04-11 16:46:50'),
(3803, 'BSR7-67-200(11)-5', '2.5686', 1, '2018-04-11 16:46:50'),
(3804, 'BSR7-67-200(11)-6', '2.5686', 1, '2018-04-11 16:46:50'),
(3805, 'BSR8-67-200(11)-5', '2.0652', 1, '2018-04-11 16:46:50'),
(3806, 'BSR8-67-200(11)-6', '2.0652', 1, '2018-04-11 16:46:50'),
(3807, 'BSR9-67-200(11)-5', '2.4673', 1, '2018-04-11 16:46:50'),
(3808, 'BSR9-67-200(11)-6', '2.4673', 1, '2018-04-11 16:46:50'),
(3809, 'B63C-67-200(13)-1', '2.4673', 1, '2018-04-11 16:46:50'),
(3810, 'BAEK-67-200(7)-4', '2.9557', 1, '2018-04-11 16:46:50'),
(3811, 'BALE-67-200(7)-4', '2.5536', 1, '2018-04-11 16:46:50'),
(3812, 'BALK-67-200(7)-4', '2.1666', 1, '2018-04-11 16:46:50'),
(3813, 'BALM-67-200(7)-4', '2.5687', 1, '2018-04-11 16:46:51'),
(3814, 'BHV6-67-200A(8)-4', '2.0652', 1, '2018-04-11 16:46:51'),
(3815, 'BHV7-67-200A(8)-4', '2.4673', 1, '2018-04-11 16:46:51'),
(3816, 'B63C-67-210A(3)-2', '1.1881', 1, '2018-04-11 16:46:51'),
(3817, 'BABD-67-210A(3)-2', '1.5749', 1, '2018-04-11 16:46:51');
INSERT INTO `eff_product_st` (`ID`, `product_no`, `st`, `updated_by`, `last_update`) VALUES
(3818, 'BALE-67-210A(3)-2', '1.6756', 1, '2018-04-11 16:46:51'),
(3819, 'BALK-67-210A(3)-2', '1.2888', 1, '2018-04-11 16:46:51'),
(3820, 'BHN9-67-210(3)-8', '1.1882', 1, '2018-04-11 16:46:51'),
(3821, 'B63C-67-220A(3)-2', '1.1882', 1, '2018-04-11 16:46:51'),
(3822, 'BABD-67-220A(3)-2', '1.5751', 1, '2018-04-11 16:46:51'),
(3823, 'BALE-67-220A(3)-2', '1.6758', 1, '2018-04-11 16:46:51'),
(3824, 'BALK-67-220A(3)-2', '1.2889', 1, '2018-04-11 16:46:51'),
(3825, 'BHN9-67-220(3)-8', '1.1882', 1, '2018-04-11 16:46:51'),
(3826, 'N253-67-010(7)-4', '24.8288', 1, '2018-04-11 16:46:52'),
(3827, 'N254-67-010(7)-4', '25.1218', 1, '2018-04-11 16:46:52'),
(3828, 'N294-67-010(7)-4', '26.2839', 1, '2018-04-11 16:46:52'),
(3829, 'N295-67-010(7)-4', '26.5771', 1, '2018-04-11 16:46:52'),
(3830, 'NA4L-67-010D(11)-2', '24.2468', 1, '2018-04-11 16:46:52'),
(3831, 'NA4M-67-010D(11)-2', '24.3412', 1, '2018-04-11 16:46:52'),
(3832, 'NA4N-67-010C(9)-4', '25.0381', 1, '2018-04-11 16:46:52'),
(3833, 'NA4T-67-010B(7)-4', '24.8335', 1, '2018-04-11 16:46:52'),
(3834, 'NA4V-67-010B(7)-4', '25.1266', 1, '2018-04-11 16:46:52'),
(3835, 'NA5E-67-010(9)-4', '23.9027', 1, '2018-04-11 16:46:52'),
(3836, 'NA6K-67-010(9)-4', '24.4206', 1, '2018-04-11 16:46:53'),
(3837, 'NC3D-67-010C(9)-4', '25.1325', 1, '2018-04-11 16:46:53'),
(3838, 'NC3S-67-010C(9)-4', '25.3093', 1, '2018-04-11 16:46:53'),
(3839, 'NC3T-67-010C(9)-4', '26.494', 1, '2018-04-11 16:46:53'),
(3840, 'NC3V-67-010C(9)-4', '26.7652', 1, '2018-04-11 16:46:53'),
(3841, 'NC3W-67-010C(9)-4', '25.4038', 1, '2018-04-11 16:46:53'),
(3842, 'NC4A-67-010C(9)-4', '26.5884', 1, '2018-04-11 16:46:53'),
(3843, 'NC4B-67-010C(9)-4', '26.8596', 1, '2018-04-11 16:46:53'),
(3844, 'NC4C-67-010C(9)-4', '24.6604', 1, '2018-04-11 16:46:53'),
(3845, 'NC4D-67-010C(9)-4', '24.7548', 1, '2018-04-11 16:46:53'),
(3846, 'NC4E-67-010C(9)-4', '26.416', 1, '2018-04-11 16:46:53'),
(3847, 'NC4F-67-010C(9)-4', '26.5105', 1, '2018-04-11 16:46:53'),
(3848, 'NC4H-67-010B(7)-4', '25.0701', 1, '2018-04-11 16:46:54'),
(3849, 'NC4J-67-010B(7)-4', '26.2902', 1, '2018-04-11 16:46:54'),
(3850, 'NC4K-67-010B(7)-4', '26.5268', 1, '2018-04-11 16:46:54'),
(3851, 'NC4L-67-010B(7)-4', '25.3631', 1, '2018-04-11 16:46:54'),
(3852, 'NC4M-67-010B(7)-4', '26.5833', 1, '2018-04-11 16:46:54'),
(3853, 'NC4N-67-010B(7)-4', '26.8199', 1, '2018-04-11 16:46:54'),
(3854, 'NC4P-67-010(9)-4', '25.3586', 1, '2018-04-11 16:46:54'),
(3855, 'NC4R-67-010(9)-4', '25.8764', 1, '2018-04-11 16:46:54'),
(3856, 'NC4S-67-010(7)-4', '24.1861', 1, '2018-04-11 16:46:54'),
(3857, 'NC4T-67-010(7)-4', '25.159', 1, '2018-04-11 16:46:54'),
(3858, 'NC4V-67-010(7)-4', '25.6426', 1, '2018-04-11 16:46:54'),
(3859, 'ND0A-67-010(7)-4', '24.1233', 1, '2018-04-11 16:46:55'),
(3860, 'ND0B-67-010(7)-4', '24.4163', 1, '2018-04-11 16:46:55'),
(3861, 'ND0D-67-010(7)-4', '23.7024', 1, '2018-04-11 16:46:55'),
(3862, 'ND7N-67-010A(11)-2', '26.002', 1, '2018-04-11 16:46:55'),
(3863, 'ND7P-67-010A(11)-2', '26.0965', 1, '2018-04-11 16:46:55'),
(3864, 'N253-67-050(9)-2-C', '28.2039', 1, '2018-04-11 16:46:55'),
(3865, 'N254-67-050(9)-2-C', '31.4746', 1, '2018-04-11 16:46:55'),
(3866, 'N294-67-050(9)-2-C', '29.3546', 1, '2018-04-11 16:46:55'),
(3867, 'N295-67-050(9)-2-C', '0', 1, '2018-04-11 16:46:55'),
(3868, 'N296-67-050(9)-2-C', '32.6254', 1, '2018-04-11 16:46:55'),
(3869, 'N297-67-050(9)-2-C', '0', 1, '2018-04-11 16:46:55'),
(3870, 'NA4T-67-050A(7)-2-C', '19.9451', 1, '2018-04-11 16:46:55'),
(3871, 'NA4V-67-050A(7)-2-C', '23.2183', 1, '2018-04-11 16:46:56'),
(3872, 'NC5C-67-050A(7)-2-C', '21.6135', 1, '2018-04-11 16:46:56'),
(3873, 'NC5D-67-050A(8)-2-C', '21.4747', 1, '2018-04-11 16:46:56'),
(3874, 'NC5E-67-050A(8)-2-C', '23.1432', 1, '2018-04-11 16:46:56'),
(3875, 'NC5F-67-050A(9)-2-C', '26.0691', 1, '2018-04-11 16:46:56'),
(3876, 'NC5G-67-050A(9)-2-C', '27.7345', 1, '2018-04-11 16:46:56'),
(3877, 'NC5H-67-050A(9)-2-C', '28.4162', 1, '2018-04-11 16:46:56'),
(3878, 'NC5J-67-050A(9)-2-C', '30.0847', 1, '2018-04-11 16:46:56'),
(3879, 'NC5K-67-050A(7)-2-C', '24.8868', 1, '2018-04-11 16:46:56'),
(3880, 'NC5L-67-050A(8)-2-C', '24.748', 1, '2018-04-11 16:46:56'),
(3881, 'NC5M-67-050A(8)-2-C', '26.4165', 1, '2018-04-11 16:46:56'),
(3882, 'NC5N-67-050A(9)-2-C', '29.3424', 1, '2018-04-11 16:46:56'),
(3883, 'NC5P-67-050A(9)-2-C', '31.0077', 1, '2018-04-11 16:46:56'),
(3884, 'NC5R-67-050A(9)-2-C', '31.6895', 1, '2018-04-11 16:46:56'),
(3885, 'NC5S-67-050A(9)-2-C', '33.358', 1, '2018-04-11 16:46:56'),
(3886, 'NC5T-67-050(9)-2-C', '30.3411', 1, '2018-04-11 16:46:56'),
(3887, 'NC5V-67-050(9)-2-C', '33.6145', 1, '2018-04-11 16:46:56'),
(3888, 'NC5W-67-050A(9)-2-C', '23.4714', 1, '2018-04-11 16:46:56'),
(3889, 'NC6A-67-050A(9)-2-C', '25.1367', 1, '2018-04-11 16:46:56'),
(3890, 'NC6B-67-050A(9)-2-C', '25.8186', 1, '2018-04-11 16:46:57'),
(3891, 'NC6C-67-050A(9)-2-C', '27.4871', 1, '2018-04-11 16:46:57'),
(3892, 'NC6D-67-050A(9)-2-C', '26.7446', 1, '2018-04-11 16:46:57'),
(3893, 'NC6E-67-050A(9)-2-C', '28.41', 1, '2018-04-11 16:46:57'),
(3894, 'NC6F-67-050A(9)-2-C', '29.0919', 1, '2018-04-11 16:46:57'),
(3895, 'NC6G-67-050A(9)-2-C', '30.7604', 1, '2018-04-11 16:46:57'),
(3896, 'NC7C-67-050A(7)-2-C', '19.766', 1, '2018-04-11 16:46:57'),
(3897, 'NC7D-67-050(8)-2-C', '19.6273', 1, '2018-04-11 16:46:57'),
(3898, 'NC7E-67-050(8)-2-C', '21.2958', 1, '2018-04-11 16:46:57'),
(3899, 'NC7F-67-050(9)-2-C', '24.2215', 1, '2018-04-11 16:46:57'),
(3900, 'NC7G-67-050(9)-2-C', '25.8868', 1, '2018-04-11 16:46:57'),
(3901, 'NC7H-67-050(9)-2-C', '26.5687', 1, '2018-04-11 16:46:57'),
(3902, 'NC7J-67-050(9)-2-C', '28.2372', 1, '2018-04-11 16:46:57'),
(3903, 'ND0A-67-050(9)-2-C', '28.6726', 1, '2018-04-11 16:46:57'),
(3904, 'ND0B-67-050(9)-2-C', '31.946', 1, '2018-04-11 16:46:57'),
(3905, 'ND0D-67-050(7)-2-C', '18.0976', 1, '2018-04-11 16:46:57'),
(3906, 'NA4L-67-050B(11)-3-D', '22.0421', 1, '2018-04-11 16:46:57'),
(3907, 'NA4M-67-050B(11)-3-D', '25.4109', 1, '2018-04-11 16:46:57'),
(3908, 'NA4N-67-050B(10)-3-D', '19.6435', 1, '2018-04-11 16:46:57'),
(3909, 'NA5E-67-050(10)-3-D', '21.402', 1, '2018-04-11 16:46:57'),
(3910, 'NA6K-67-050(10)-3-D', '22.8848', 1, '2018-04-11 16:46:57'),
(3911, 'NC3D-67-050B(10)-3-D', '23.013', 1, '2018-04-11 16:46:57'),
(3912, 'NC3P-67-050C(12)-3-D', '29.0667', 1, '2018-04-11 16:46:57'),
(3913, 'NC3S-67-050B(10)-3-D', '21.127', 1, '2018-04-11 16:46:57'),
(3914, 'NC3T-67-050B(11)-3-D', '20.8088', 1, '2018-04-11 16:46:57'),
(3915, 'NC3V-67-050B(11)-3-D', '22.2922', 1, '2018-04-11 16:46:57'),
(3916, 'NC3W-67-050B(12)-3-D', '25.8297', 1, '2018-04-11 16:46:57'),
(3917, 'NC4A-67-050B(12)-3-D', '27.325', 1, '2018-04-11 16:46:57'),
(3918, 'NC4B-67-050B(12)-3-D', '28.2464', 1, '2018-04-11 16:46:57'),
(3919, 'NC4C-67-050B(12)-3-D', '29.7299', 1, '2018-04-11 16:46:57'),
(3920, 'NC4D-67-050B(10)-3-D', '24.496', 1, '2018-04-11 16:46:57'),
(3921, 'NC4E-67-050B(11)-3-D', '24.1783', 1, '2018-04-11 16:46:57'),
(3922, 'NC4F-67-050B(11)-3-D', '25.6611', 1, '2018-04-11 16:46:57'),
(3923, 'NC4G-67-050B(12)-3-D', '29.1991', 1, '2018-04-11 16:46:58'),
(3924, 'NC4H-67-050B(12)-3-D', '30.6937', 1, '2018-04-11 16:46:58'),
(3925, 'NC4J-67-050B(12)-3-D', '31.6158', 1, '2018-04-11 16:46:58'),
(3926, 'NC4K-67-050B(12)-3-D', '33.0987', 1, '2018-04-11 16:46:58'),
(3927, 'NC4L-67-050B(12)-3-D', '27.1766', 1, '2018-04-11 16:46:58'),
(3928, 'NC4M-67-050B(12)-3-D', '30.5455', 1, '2018-04-11 16:46:58'),
(3929, 'NC4N-67-050B(12)-3-D', '33.2636', 1, '2018-04-11 16:46:58'),
(3930, 'NC4P-67-050B(12)-3-D', '32.9622', 1, '2018-04-11 16:46:58'),
(3931, 'NC4R-67-050B(12)-3-D', '35.6686', 1, '2018-04-11 16:46:58'),
(3932, 'NC4S-67-050B(12)-3-D', '29.8948', 1, '2018-04-11 16:46:58'),
(3933, 'NC4T-67-050B(12)-3-D', '29.5934', 1, '2018-04-11 16:46:58'),
(3934, 'NC4V-67-050B(12)-3-D', '32.2999', 1, '2018-04-11 16:46:58'),
(3935, 'NC4W-67-050C(12)-3-D', '31.7849', 1, '2018-04-11 16:46:58'),
(3936, 'NC5A-67-050C(12)-3-D', '31.4834', 1, '2018-04-11 16:46:58'),
(3937, 'NC5B-67-050C(12)-3-D', '34.1898', 1, '2018-04-11 16:46:58'),
(3938, 'NC6H-67-050B(12)-3-D', '23.2517', 1, '2018-04-11 16:46:58'),
(3939, 'NC6J-67-050B(12)-3-D', '24.7469', 1, '2018-04-11 16:46:58'),
(3940, 'NC6K-67-050B(12)-3-D', '25.6684', 1, '2018-04-11 16:46:58'),
(3941, 'NC6L-67-050B(12)-3-D', '27.1518', 1, '2018-04-11 16:46:58'),
(3942, 'NC6M-67-050B(12)-3-D', '26.621', 1, '2018-04-11 16:46:58'),
(3943, 'NC6N-67-050B(12)-3-D', '28.1157', 1, '2018-04-11 16:46:58'),
(3944, 'NC6P-67-050B(12)-3-D', '29.0377', 1, '2018-04-11 16:46:58'),
(3945, 'NC6R-67-050B(12)-3-D', '30.5206', 1, '2018-04-11 16:46:58'),
(3946, 'NC6S-67-050(11)-3-D', '22.567', 1, '2018-04-11 16:46:58'),
(3947, 'NC6T-67-050(11)-3-D', '24.05', 1, '2018-04-11 16:46:58'),
(3948, 'NC6V-67-050(12)-3-D', '27.588', 1, '2018-04-11 16:46:58'),
(3949, 'NC6W-67-050(12)-3-D', '29.0826', 1, '2018-04-11 16:46:58'),
(3950, 'NC7A-67-050(12)-3-D', '30.0047', 1, '2018-04-11 16:46:58'),
(3951, 'NC7B-67-050(12)-3-D', '31.4875', 1, '2018-04-11 16:46:59'),
(3952, 'NC7K-67-050(10)-3-D', '21.8465', 1, '2018-04-11 16:46:59'),
(3953, 'NC7L-67-050(10)-3-D', '23.3293', 1, '2018-04-11 16:46:59'),
(3954, 'NC7M-67-050(11)-3-D', '23.0116', 1, '2018-04-11 16:46:59'),
(3955, 'NC7N-67-050(11)-3-D', '24.4945', 1, '2018-04-11 16:46:59'),
(3956, 'NC7P-67-050(12)-3-D', '28.0325', 1, '2018-04-11 16:46:59'),
(3957, 'NC7R-67-050(12)-3-D', '29.5271', 1, '2018-04-11 16:46:59'),
(3958, 'NC7S-67-050(12)-3-D', '30.4492', 1, '2018-04-11 16:46:59'),
(3959, 'NC7T-67-050(12)-3-D', '31.9321', 1, '2018-04-11 16:46:59'),
(3960, 'NE2H-67-050(13)-2-D', '24.485', 1, '2018-04-11 16:46:59'),
(3961, 'NE2J-67-050(13)-2-D', '27.0083', 1, '2018-04-11 16:46:59'),
(3962, 'NE2K-67-050(13)-2-D', '27.8538', 1, '2018-04-11 16:46:59'),
(3963, 'NE2L-67-050(13)-2-D', '30.3771', 1, '2018-04-11 16:46:59'),
(3964, 'NA4L-67-060B(6)-2', '0.3971', 1, '2018-04-11 16:46:59'),
(3965, 'NC3D-67-060B(6)-2', '0.3971', 1, '2018-04-11 16:46:59'),
(3966, 'A401-67-070D(9)-1', '0.5592', 1, '2018-04-11 16:46:59'),
(3967, 'A401-67-260C(4)-3', '0.1917', 1, '2018-04-11 16:46:59'),
(3968, 'A402-67-070D(9)-1', '0', 1, '2018-04-11 16:46:59'),
(3969, 'N253-67-030A(10)-C', '20.3602', 1, '2018-04-11 16:46:59'),
(3970, 'N253-67-030A(8)-1-C', '20.3593', 1, '2018-04-11 16:46:59'),
(3971, 'N254-67-030A(10)-C', '21.9521', 1, '2018-04-11 16:46:59'),
(3972, 'N254-67-030A(8)-1-C', '21.9511', 1, '2018-04-11 16:46:59'),
(3973, 'N294-67-030A(10)-C', '21.715', 1, '2018-04-11 16:46:59'),
(3974, 'N294-67-030A(8)-1-C', '21.714', 1, '2018-04-11 16:46:59'),
(3975, 'N295-67-030A(10)-C', '21.7777', 1, '2018-04-11 16:46:59'),
(3976, 'N295-67-030A(8)-1-C', '21.7767', 1, '2018-04-11 16:47:00'),
(3977, 'N296-67-030A(10)-C', '23.307', 1, '2018-04-11 16:47:00'),
(3978, 'N296-67-030A(8)-1-C', '23.3058', 1, '2018-04-11 16:47:00'),
(3979, 'N297-67-030A(10)-C', '23.8927', 1, '2018-04-11 16:47:00'),
(3980, 'N297-67-030A(8)-1-C', '23.8914', 1, '2018-04-11 16:47:00'),
(3981, 'NA4T-67-030(7)-1-C', '16.8233', 1, '2018-04-11 16:47:00'),
(3982, 'NA4T-67-030(9)-C', '16.824', 1, '2018-04-11 16:47:00'),
(3983, 'NA6E-67-030A(7)-1-C', '17.8755', 1, '2018-04-11 16:47:00'),
(3984, 'NA6E-67-030A(9)-C', '17.8762', 1, '2018-04-11 16:47:00'),
(3985, 'NA6F-67-030A(7)-1-C', '19.4674', 1, '2018-04-11 16:47:00'),
(3986, 'NA6F-67-030A(9)-C', '19.4682', 1, '2018-04-11 16:47:00'),
(3987, 'NB9P-67-030A(7)-1-C', '19.7872', 1, '2018-04-11 16:47:00'),
(3988, 'NB9P-67-030A(9)-C', '19.7879', 1, '2018-04-11 16:47:00'),
(3989, 'NB9T-67-030A(7)-1-C', '21.3791', 1, '2018-04-11 16:47:00'),
(3990, 'NB9T-67-030A(9)-C', '21.38', 1, '2018-04-11 16:47:00'),
(3991, 'NC0A-67-030(10)-C', '18.722', 1, '2018-04-11 16:47:00'),
(3992, 'NC0A-67-030(8)-1-C', '18.7212', 1, '2018-04-11 16:47:00'),
(3993, 'NC0B-67-030A(10)-C', '19.6423', 1, '2018-04-11 16:47:00'),
(3994, 'NC0B-67-030A(8)-1-C', '19.6415', 1, '2018-04-11 16:47:00'),
(3995, 'NC0C-67-030(10)-C', '19.113', 1, '2018-04-11 16:47:00'),
(3996, 'NC0C-67-030(8)-1-C', '19.1122', 1, '2018-04-11 16:47:00'),
(3997, 'NC0D-67-030A(10)-C', '20.9972', 1, '2018-04-11 16:47:00'),
(3998, 'NC0D-67-030A(8)-1-C', '20.9961', 1, '2018-04-11 16:47:00'),
(3999, 'NC0E-67-030(10)-C', '20.4679', 1, '2018-04-11 16:47:00'),
(4000, 'NC0E-67-030(8)-1-C', '20.4668', 1, '2018-04-11 16:47:00'),
(4001, 'NC0F-67-030A(10)-C', '21.7572', 1, '2018-04-11 16:47:00'),
(4002, 'NC0F-67-030A(8)-1-C', '21.7562', 1, '2018-04-11 16:47:00'),
(4003, 'NC0G-67-030(10)-C', '20.9322', 1, '2018-04-11 16:47:00'),
(4004, 'NC0G-67-030(8)-1-C', '20.9314', 1, '2018-04-11 16:47:00'),
(4005, 'NC0H-67-030A(10)-C', '23.1121', 1, '2018-04-11 16:47:00'),
(4006, 'NC0H-67-030A(8)-1-C', '23.1109', 1, '2018-04-11 16:47:00'),
(4007, 'NC0J-67-030(10)-C', '22.2871', 1, '2018-04-11 16:47:00'),
(4008, 'NC0J-67-030(8)-1-C', '22.2861', 1, '2018-04-11 16:47:01'),
(4009, 'NC6V-67-030(3)-9-C', '0', 1, '2018-04-11 16:47:01'),
(4010, 'NC6W-67-030(7)-1-C', '18.569', 1, '2018-04-11 16:47:01'),
(4011, 'NC6W-67-030(9)-C', '18.5699', 1, '2018-04-11 16:47:01'),
(4012, 'NC7A-67-030(7)-1-C', '18.3441', 1, '2018-04-11 16:47:01'),
(4013, 'NC7A-67-030(9)-C', '18.3448', 1, '2018-04-11 16:47:01'),
(4014, 'NC7D-67-030(3)-9-C', '0', 1, '2018-04-11 16:47:01'),
(4015, 'NC7E-67-030(7)-1-C', '20.0897', 1, '2018-04-11 16:47:01'),
(4016, 'NC7E-67-030(9)-C', '20.0906', 1, '2018-04-11 16:47:01'),
(4017, 'NC7F-67-030(10)-C', '18.917', 1, '2018-04-11 16:47:01'),
(4018, 'NC7F-67-030(8)-1-C', '18.9162', 1, '2018-04-11 16:47:01'),
(4019, 'NC7N-67-030(10)-C', '19.308', 1, '2018-04-11 16:47:01'),
(4020, 'NC7N-67-030(8)-1-C', '19.3072', 1, '2018-04-11 16:47:01'),
(4021, 'NC7P-67-030(10)-C', '20.6629', 1, '2018-04-11 16:47:01'),
(4022, 'NC7P-67-030(8)-1-C', '20.6618', 1, '2018-04-11 16:47:01'),
(4023, 'NC7T-67-030(3)-9-C', '0', 1, '2018-04-11 16:47:01'),
(4024, 'NC7V-67-030(7)-1-C', '20.3882', 1, '2018-04-11 16:47:01'),
(4025, 'NC7V-67-030(9)-C', '20.3891', 1, '2018-04-11 16:47:01'),
(4026, 'NC8C-67-030(3)-9-C', '0', 1, '2018-04-11 16:47:01'),
(4027, 'NC8D-67-030(7)-1-C', '21.9089', 1, '2018-04-11 16:47:01'),
(4028, 'NC8D-67-030(9)-C', '21.9098', 1, '2018-04-11 16:47:01'),
(4029, 'NC8M-67-030(10)-C', '21.1271', 1, '2018-04-11 16:47:01'),
(4030, 'NC8M-67-030(8)-1-C', '21.1263', 1, '2018-04-11 16:47:01'),
(4031, 'NC8N-67-030(10)-C', '22.4821', 1, '2018-04-11 16:47:01'),
(4032, 'NC8N-67-030(8)-1-C', '22.481', 1, '2018-04-11 16:47:01'),
(4033, 'NC9M-67-030A(7)-1-C', '19.2301', 1, '2018-04-11 16:47:01'),
(4034, 'NC9M-67-030A(9)-C', '19.231', 1, '2018-04-11 16:47:01'),
(4035, 'NC9N-67-030A(7)-1-C', '20.822', 1, '2018-04-11 16:47:01'),
(4036, 'NC9N-67-030A(9)-C', '20.8231', 1, '2018-04-11 16:47:01'),
(4037, 'ND0A-67-030A(10)-C', '19.013', 1, '2018-04-11 16:47:01'),
(4038, 'ND0A-67-030A(8)-1-C', '19.0122', 1, '2018-04-11 16:47:01'),
(4039, 'ND0B-67-030A(10)-C', '21.128', 1, '2018-04-11 16:47:02'),
(4040, 'ND0B-67-030A(8)-1-C', '21.127', 1, '2018-04-11 16:47:02'),
(4041, 'NA4L-67-030A(13)-1-D', '18.2278', 1, '2018-04-11 16:47:02'),
(4042, 'NA4M-67-030A(13)-1-D', '19.9792', 1, '2018-04-11 16:47:02'),
(4043, 'NA4N-67-030A(13)-2-D', '16.4983', 1, '2018-04-11 16:47:02'),
(4044, 'NB9B-67-030A(11)-2-D', '19.4315', 1, '2018-04-11 16:47:02'),
(4045, 'NB9C-67-030A(11)-2-D', '20.785', 1, '2018-04-11 16:47:02'),
(4046, 'NB9H-67-030A(13)-2-D', '20.89', 1, '2018-04-11 16:47:02'),
(4047, 'NB9M-67-030A(11)-2-D', '21.4833', 1, '2018-04-11 16:47:02'),
(4048, 'NB9N-67-030A(11)-2-D', '23.752', 1, '2018-04-11 16:47:02'),
(4049, 'NC0K-67-030A(11)-2-D', '18.3023', 1, '2018-04-11 16:47:02'),
(4050, 'NC0L-67-030A(11)-2-D', '19.2256', 1, '2018-04-11 16:47:02'),
(4051, 'NC0M-67-030A(11)-2-D', '18.6959', 1, '2018-04-11 16:47:02'),
(4052, 'NC0N-67-030A(11)-2-D', '20.5792', 1, '2018-04-11 16:47:02'),
(4053, 'NC0P-67-030A(11)-2-D', '20.0495', 1, '2018-04-11 16:47:02'),
(4054, 'NC0R-67-030A(11)-2-D', '21.2775', 1, '2018-04-11 16:47:02'),
(4055, 'NC0S-67-030A(11)-2-D', '20.4473', 1, '2018-04-11 16:47:02'),
(4056, 'NC0T-67-030A(11)-2-D', '22.631', 1, '2018-04-11 16:47:02'),
(4057, 'NC0V-67-030A(11)-2-D', '21.8008', 1, '2018-04-11 16:47:02'),
(4058, 'NC0W-67-030(13)-2-D', '18.4376', 1, '2018-04-11 16:47:02'),
(4059, 'NC1A-67-030(13)-2-D', '19.7912', 1, '2018-04-11 16:47:02'),
(4060, 'NC1B-67-030(13)-2-D', '20.2479', 1, '2018-04-11 16:47:02'),
(4061, 'NC1C-67-030(11)-2-D', '20.8412', 1, '2018-04-11 16:47:02'),
(4062, 'NC3E-67-030A(13)-2-D', '17.028', 1, '2018-04-11 16:47:02'),
(4063, 'NC3F-67-030A(13)-2-D', '18.3815', 1, '2018-04-11 16:47:02'),
(4064, 'NC3G-67-030A(13)-2-D', '19.0797', 1, '2018-04-11 16:47:02'),
(4065, 'NC3H-67-030A(13)-2-D', '20.4333', 1, '2018-04-11 16:47:02'),
(4066, 'NC3J-67-030A(11)-2-D', '19.7444', 1, '2018-04-11 16:47:02'),
(4067, 'NC3K-67-030A(11)-2-D', '21.6866', 1, '2018-04-11 16:47:02'),
(4068, 'NC3L-67-030A(11)-2-D', '21.7962', 1, '2018-04-11 16:47:03'),
(4069, 'NC3M-67-030A(11)-2-D', '23.7384', 1, '2018-04-11 16:47:03'),
(4070, 'NC3V-67-030A(11)-D', '16.8919', 1, '2018-04-11 16:47:03'),
(4071, 'NC3W-67-030A(13)-2-D', '18.2454', 1, '2018-04-11 16:47:03'),
(4072, 'NC4A-67-030A(13)-2-D', '17.9149', 1, '2018-04-11 16:47:03'),
(4073, 'NC4D-67-030A(11)-D', '0', 1, '2018-04-11 16:47:03'),
(4074, 'NC4E-67-030A(13)-2-D', '19.662', 1, '2018-04-11 16:47:03'),
(4075, 'NC4F-67-030A(11)-D', '0', 1, '2018-04-11 16:47:03'),
(4076, 'NC4N-67-030A(13)-2-D', '18.8541', 1, '2018-04-11 16:47:03'),
(4077, 'NC4P-67-030A(13)-2-D', '20.2076', 1, '2018-04-11 16:47:03'),
(4078, 'NC4V-67-030A(13)-2-D', '20.2707', 1, '2018-04-11 16:47:03'),
(4079, 'NC4W-67-030A(13)-2-D', '21.6242', 1, '2018-04-11 16:47:03'),
(4080, 'NC5C-67-030A(11)-2-D', '18.9018', 1, '2018-04-11 16:47:03'),
(4081, 'NC5D-67-030A(11)-2-D', '20.2553', 1, '2018-04-11 16:47:03'),
(4082, 'NC5M-67-030A(11)-2-D', '20.8641', 1, '2018-04-11 16:47:03'),
(4083, 'NC5N-67-030A(11)-2-D', '23.0235', 1, '2018-04-11 16:47:03'),
(4084, 'NC5P-67-030A(11)-2-D', '18.8211', 1, '2018-04-11 16:47:03'),
(4085, 'NC5R-67-030A(11)-2-D', '20.5725', 1, '2018-04-11 16:47:03'),
(4086, 'NC5V-67-030A(11)-2-D', '19.2147', 1, '2018-04-11 16:47:03'),
(4087, 'NC5W-67-030A(11)-2-D', '21.1569', 1, '2018-04-11 16:47:03'),
(4088, 'NC6K-67-030A(11)-2-D', '20.9661', 1, '2018-04-11 16:47:03'),
(4089, 'NC6L-67-030A(11)-2-D', '22.9083', 1, '2018-04-11 16:47:03'),
(4090, 'NC6N-67-030A(11)-2-D', '20.1373', 1, '2018-04-11 16:47:03'),
(4091, 'NC8V-67-030A(13)-2-D', '18.8382', 1, '2018-04-11 16:47:03'),
(4092, 'NC9P-67-030A(11)-2-D', '21.1767', 1, '2018-04-11 16:47:03'),
(4093, 'ND7M-67-030(11)-2-D', '22.1947', 1, '2018-04-11 16:47:03'),
(4094, 'ND7N-67-030(14)-D', '0', 1, '2018-04-11 16:47:03'),
(4095, 'ND7P-67-030(14)-D', '0', 1, '2018-04-11 16:47:03'),
(4096, 'ND7R-67-030(14)-2-D', '18.2496', 1, '2018-04-11 16:47:03'),
(4097, 'ND7S-67-030(14)-2-D', '19.6662', 1, '2018-04-11 16:47:03'),
(4098, 'ND7T-67-030(12)-2-D', '19.8079', 1, '2018-04-11 16:47:03'),
(4099, 'ND7V-67-030(12)-2-D', '20.0138', 1, '2018-04-11 16:47:03'),
(4100, 'NE2L-67-030(13)-D', '18.5754', 1, '2018-04-11 16:47:03'),
(4101, 'NE2M-67-030(13)-D', '18.969', 1, '2018-04-11 16:47:03'),
(4102, 'NE2N-67-030(13)-D', '20.9112', 1, '2018-04-11 16:47:03'),
(4103, 'NE2P-67-030(13)-D', '20.3268', 1, '2018-04-11 16:47:04'),
(4104, 'NE2R-67-030(13)-D', '20.7204', 1, '2018-04-11 16:47:04'),
(4105, 'NE2S-67-030(13)-D', '22.6626', 1, '2018-04-11 16:47:04'),
(4106, 'NA4L-67-06YA(2)-5', '0.5851', 1, '2018-04-11 16:47:04'),
(4107, 'NA4N-67-06YA(2)-5', '0.7803', 1, '2018-04-11 16:47:04'),
(4108, 'NA4N-67-290A(4)-5', '1.6564', 1, '2018-04-11 16:47:04'),
(4109, 'NA4L-67-290B(8)', '1.7595', 1, '2018-04-11 16:47:04'),
(4110, 'NA4M-67-290B(8)', '0.9006', 1, '2018-04-11 16:47:04'),
(4111, 'NC3D-67-290B(8)', '0.4357', 1, '2018-04-11 16:47:04'),
(4112, 'NC3S-67-290B(8)', '1.2946', 1, '2018-04-11 16:47:04'),
(4113, 'A401-15-76X(2)-3', '0.3265', 1, '2018-04-11 16:47:04'),
(4114, 'NA4N-67-SH0(7)-6', '2.5437', 1, '2018-04-11 16:47:04'),
(4115, 'NA4L-67-SH0(3)-3', '0.3468', 1, '2018-04-11 16:47:04'),
(4116, 'NA4L-67-150(3)-6', '0.2227', 1, '2018-04-11 16:47:04'),
(4117, 'NA4M-67-150(3)-6', '1.4112', 1, '2018-04-11 16:47:04'),
(4118, 'NA4M-67-EW0(2)-2', '0', 1, '2018-04-11 16:47:04'),
(4119, 'NA4L-67-EW0(1)-2', '0', 1, '2018-04-11 16:47:04'),
(4120, 'K147-67-060(9)-1', '0', 1, '2018-04-11 16:47:04'),
(4121, 'K262-67-060(16)-4', '3.2674', 1, '2018-04-11 16:47:04'),
(4122, 'K262-67-060(18)', '3.2674', 1, '2018-04-11 16:47:04'),
(4123, 'K262-67-060(18)-1', '3.2674', 1, '2018-04-11 16:47:04'),
(4124, 'K263-67-060(16)-4', '4.606', 1, '2018-04-11 16:47:04'),
(4125, 'K263-67-060(18)', '4.606', 1, '2018-04-11 16:47:04'),
(4126, 'K263-67-060(18)-1', '4.606', 1, '2018-04-11 16:47:04'),
(4127, 'KB7W-67-060A(15)-4', '3.0627', 1, '2018-04-11 16:47:04'),
(4128, 'KB7W-67-060A(18)', '3.0627', 1, '2018-04-11 16:47:04'),
(4129, 'KB7W-67-060A(18)-1', '3.0627', 1, '2018-04-11 16:47:04'),
(4130, 'KB8C-67-060A(15)-4', '3.0627', 1, '2018-04-11 16:47:04'),
(4131, 'KB8C-67-060A(18)', '3.0627', 1, '2018-04-11 16:47:04'),
(4132, 'KB8C-67-060A(18)-1', '3.0627', 1, '2018-04-11 16:47:04'),
(4133, 'KB8D-67-060A(15)-4', '0', 1, '2018-04-11 16:47:05'),
(4134, 'KB8D-67-060A(18)', '4.4013', 1, '2018-04-11 16:47:05'),
(4135, 'KB8D-67-060A(18)-1', '0', 1, '2018-04-11 16:47:05'),
(4136, 'KB8F-67-060A(15)-4', '4.4013', 1, '2018-04-11 16:47:05'),
(4137, 'KB8F-67-060A(18)', '4.4013', 1, '2018-04-11 16:47:05'),
(4138, 'KB8F-67-060A(18)-1', '4.4013', 1, '2018-04-11 16:47:05'),
(4139, 'KB8M-67-060A(15)-4', '3.2674', 1, '2018-04-11 16:47:05'),
(4140, 'KB8M-67-060A(18)', '3.2674', 1, '2018-04-11 16:47:05'),
(4141, 'KB8M-67-060A(18)-1', '3.2674', 1, '2018-04-11 16:47:05'),
(4142, 'KB8N-67-060A(15)-4', '4.8162', 1, '2018-04-11 16:47:05'),
(4143, 'KB8N-67-060A(18)', '4.8162', 1, '2018-04-11 16:47:05'),
(4144, 'KB8N-67-060A(18)-1', '0', 1, '2018-04-11 16:47:05'),
(4145, 'KB8R-67-060A(15)-4', '0', 1, '2018-04-11 16:47:05'),
(4146, 'KB8R-67-060A(18)', '4.606', 1, '2018-04-11 16:47:05'),
(4147, 'KB8R-67-060A(18)-1', '0', 1, '2018-04-11 16:47:05'),
(4148, 'KB9G-67-060A(15)-4', '3.0627', 1, '2018-04-11 16:47:05'),
(4149, 'KB9G-67-060A(18)', '3.0627', 1, '2018-04-11 16:47:05'),
(4150, 'KB9G-67-060A(18)-1', '3.0627', 1, '2018-04-11 16:47:05'),
(4151, 'KB9K-67-060A(15)-4', '3.2674', 1, '2018-04-11 16:47:05'),
(4152, 'KB9K-67-060A(18)', '3.2674', 1, '2018-04-11 16:47:05'),
(4153, 'KB9K-67-060A(18)-1', '3.2674', 1, '2018-04-11 16:47:05'),
(4154, 'KB9L-67-060A(15)-4', '3.6822', 1, '2018-04-11 16:47:05'),
(4155, 'KB9L-67-060A(18)', '3.6822', 1, '2018-04-11 16:47:05'),
(4156, 'KB9L-67-060A(18)-1', '3.6822', 1, '2018-04-11 16:47:05'),
(4157, 'KB9T-67-060A(15)-4', '0', 1, '2018-04-11 16:47:05'),
(4158, 'KB9T-67-060A(18)', '4.606', 1, '2018-04-11 16:47:05'),
(4159, 'KB9T-67-060A(18)-1', '0', 1, '2018-04-11 16:47:05'),
(4160, 'KC0R-67-060A(15)-4', '3.2674', 1, '2018-04-11 16:47:05'),
(4161, 'KC0R-67-060A(18)', '3.2674', 1, '2018-04-11 16:47:05'),
(4162, 'KC0R-67-060A(18)-1', '3.2674', 1, '2018-04-11 16:47:05'),
(4163, 'KC9J-67-060A(15)-4', '5.0209', 1, '2018-04-11 16:47:05'),
(4164, 'KC9J-67-060A(18)', '5.0209', 1, '2018-04-11 16:47:05'),
(4165, 'KC9J-67-060A(18)-1', '5.0209', 1, '2018-04-11 16:47:05'),
(4166, 'KD4D-67-060A(15)-4', '0', 1, '2018-04-11 16:47:05'),
(4167, 'KD4D-67-060A(18)', '4.606', 1, '2018-04-11 16:47:06'),
(4168, 'KD4D-67-060A(18)-1', '0', 1, '2018-04-11 16:47:06'),
(4169, 'KF1F-67-060A(15)-4', '5.021', 1, '2018-04-11 16:47:06'),
(4170, 'KF1F-67-060A(18)', '5.021', 1, '2018-04-11 16:47:06'),
(4171, 'KF1F-67-060A(18)-1', '5.021', 1, '2018-04-11 16:47:06'),
(4172, 'KF1J-67-060A(15)-4', '0', 1, '2018-04-11 16:47:06'),
(4173, 'KF1J-67-060A(18)', '3.4775', 1, '2018-04-11 16:47:06'),
(4174, 'KF1J-67-060A(18)-1', '0', 1, '2018-04-11 16:47:06'),
(4175, 'KF1K-67-060A(15)-4', '3.6822', 1, '2018-04-11 16:47:06'),
(4176, 'KF1K-67-060A(18)', '3.6822', 1, '2018-04-11 16:47:06'),
(4177, 'KF1K-67-060A(18)-1', '3.6822', 1, '2018-04-11 16:47:06'),
(4178, 'KF1R-67-060A(15)-4', '0', 1, '2018-04-11 16:47:06'),
(4179, 'KF1R-67-060A(18)', '4.8163', 1, '2018-04-11 16:47:06'),
(4180, 'KF1R-67-060A(18)-1', '0', 1, '2018-04-11 16:47:06'),
(4181, 'KF1V-67-060A(15)-4', '4.4013', 1, '2018-04-11 16:47:06'),
(4182, 'KF1V-67-060A(18)', '4.4013', 1, '2018-04-11 16:47:06'),
(4183, 'KF1V-67-060A(18)-1', '4.4013', 1, '2018-04-11 16:47:06'),
(4184, 'KF1W-67-060A(15)-4', '0', 1, '2018-04-11 16:47:06'),
(4185, 'KF1W-67-060A(18)', '4.606', 1, '2018-04-11 16:47:06'),
(4186, 'KF1W-67-060A(18)-1', '0', 1, '2018-04-11 16:47:06'),
(4187, 'KF2P-67-060A(15)-4', '4.606', 1, '2018-04-11 16:47:06'),
(4188, 'KF2P-67-060A(18)', '4.606', 1, '2018-04-11 16:47:06'),
(4189, 'KF2P-67-060A(18)-1', '4.606', 1, '2018-04-11 16:47:06'),
(4190, 'KF2R-67-060A(15)-4', '0', 1, '2018-04-11 16:47:06'),
(4191, 'KF2R-67-060A(18)', '3.4775', 1, '2018-04-11 16:47:06'),
(4192, 'KF2R-67-060A(18)-1', '0', 1, '2018-04-11 16:47:06'),
(4193, 'KL1P-67-060A(15)-4', '0', 1, '2018-04-11 16:47:06'),
(4194, 'KL1P-67-060A(18)', '2.5488', 1, '2018-04-11 16:47:06'),
(4195, 'KL1P-67-060A(18)-1', '0', 1, '2018-04-11 16:47:06'),
(4196, 'KL4G-67-060(17)-3', '3.2674', 1, '2018-04-11 16:47:06'),
(4197, 'KL4G-67-060(18)', '3.2674', 1, '2018-04-11 16:47:07'),
(4198, 'KL4G-67-060(18)-1', '0', 1, '2018-04-11 16:47:07'),
(4199, 'KL4H-67-060(17)-3', '4.606', 1, '2018-04-11 16:47:07'),
(4200, 'KL4H-67-060(18)', '4.606', 1, '2018-04-11 16:47:07'),
(4201, 'KL4H-67-060(18)-1', '4.606', 1, '2018-04-11 16:47:07'),
(4202, 'K131-67-060(2)', '0', 1, '2018-04-11 16:47:07'),
(4203, 'K132-67-060(2)-2', '2.8569', 1, '2018-04-11 16:47:07'),
(4204, 'K230-67-060(2)-2', '3.2518', 1, '2018-04-11 16:47:07'),
(4205, 'K231-67-060(4)-2', '4.4864', 1, '2018-04-11 16:47:07'),
(4206, 'K232-67-060(4)-2', '4.4864', 1, '2018-04-11 16:47:07'),
(4207, 'K233-67-060(3)-2', '3.2518', 1, '2018-04-11 16:47:07'),
(4208, 'K123-67-130A(10)-1', '1.4222', 1, '2018-04-11 16:47:07'),
(4209, 'K123-67-130A(10)-2', '1.4222', 1, '2018-04-11 16:47:07'),
(4210, 'K123-67-130A(10)-3', '1.4222', 1, '2018-04-11 16:47:07'),
(4211, 'K128-67-130A(10)-1', '1.6175', 1, '2018-04-11 16:47:07'),
(4212, 'K128-67-130A(10)-2', '1.6175', 1, '2018-04-11 16:47:07'),
(4213, 'K128-67-130A(10)-3', '1.6175', 1, '2018-04-11 16:47:07'),
(4214, 'KB7W-67-130A(9)-1', '0.5102', 1, '2018-04-11 16:47:07'),
(4215, 'KB7W-67-130A(9)-2', '0.5102', 1, '2018-04-11 16:47:07'),
(4216, 'KB7W-67-130A(9)-3', '0.5102', 1, '2018-04-11 16:47:07'),
(4217, 'KB8E-67-130(9)-1', '0', 1, '2018-04-11 16:47:07'),
(4218, 'KB8E-67-130(9)-2', '1.1198', 1, '2018-04-11 16:47:07'),
(4219, 'KB8E-67-130(9)-3', '0', 1, '2018-04-11 16:47:07'),
(4220, 'KB8F-67-130(9)-1', '1.7265', 1, '2018-04-11 16:47:07'),
(4221, 'KB8F-67-130(9)-2', '1.7258', 1, '2018-04-11 16:47:07'),
(4222, 'KB8F-67-130(9)-3', '1.7258', 1, '2018-04-11 16:47:07'),
(4223, 'KB8M-67-130(9)-1', '0', 1, '2018-04-11 16:47:07'),
(4224, 'KB8M-67-130(9)-2', '0.819', 1, '2018-04-11 16:47:07'),
(4225, 'KB8M-67-130(9)-3', '0', 1, '2018-04-11 16:47:07'),
(4226, 'KB8N-67-130(9)-1', '0', 1, '2018-04-11 16:47:07'),
(4227, 'KB8N-67-130(9)-2', '1.438', 1, '2018-04-11 16:47:08'),
(4228, 'KB8N-67-130(9)-3', '0', 1, '2018-04-11 16:47:08'),
(4229, 'KB8P-67-130(9)-1', '0', 1, '2018-04-11 16:47:08'),
(4230, 'KB8P-67-130(9)-2', '1.6333', 1, '2018-04-11 16:47:08'),
(4231, 'KB8P-67-130(9)-3', '0', 1, '2018-04-11 16:47:08'),
(4232, 'KB8T-67-130(9)-1', '0', 1, '2018-04-11 16:47:08'),
(4233, 'KB8T-67-130(9)-2', '1.4254', 1, '2018-04-11 16:47:08'),
(4234, 'KB8T-67-130(9)-3', '0', 1, '2018-04-11 16:47:08'),
(4235, 'KB8V-67-130(9)-1', '0', 1, '2018-04-11 16:47:08'),
(4236, 'KB8V-67-130(9)-2', '2.1443', 1, '2018-04-11 16:47:08'),
(4237, 'KB8V-67-130(9)-3', '0', 1, '2018-04-11 16:47:08'),
(4238, 'KB8W-67-130(9)-1', '2.3403', 1, '2018-04-11 16:47:08'),
(4239, 'KB8W-67-130(9)-2', '2.3396', 1, '2018-04-11 16:47:08'),
(4240, 'KB8W-67-130(9)-3', '2.3396', 1, '2018-04-11 16:47:08'),
(4241, 'KB9A-67-130(9)-1', '0.5102', 1, '2018-04-11 16:47:08'),
(4242, 'KB9A-67-130(9)-2', '0.5102', 1, '2018-04-11 16:47:08'),
(4243, 'KB9A-67-130(9)-3', '0', 1, '2018-04-11 16:47:08'),
(4244, 'KB9J-67-130(10)-1', '0.7011', 1, '2018-04-11 16:47:08'),
(4245, 'KB9J-67-130(10)-2', '0.7011', 1, '2018-04-11 16:47:08'),
(4246, 'KB9J-67-130(10)-3', '0.7011', 1, '2018-04-11 16:47:08'),
(4247, 'KB9M-67-130(10)-1', '1.0034', 1, '2018-04-11 16:47:08'),
(4248, 'KB9M-67-130(10)-2', '1.0034', 1, '2018-04-11 16:47:08'),
(4249, 'KB9M-67-130(10)-3', '1.0034', 1, '2018-04-11 16:47:08'),
(4250, 'KB9V-67-130(9)-1', '0.1938', 1, '2018-04-11 16:47:08'),
(4251, 'KB9V-67-130(9)-2', '0.1938', 1, '2018-04-11 16:47:08'),
(4252, 'KB9V-67-130(9)-3', '0.1938', 1, '2018-04-11 16:47:08'),
(4253, 'KB9W-67-130(9)-1', '0.3891', 1, '2018-04-11 16:47:08'),
(4254, 'KB9W-67-130(9)-2', '0.3891', 1, '2018-04-11 16:47:08'),
(4255, 'KB9W-67-130(9)-3', '0.3891', 1, '2018-04-11 16:47:08'),
(4256, 'KC0R-67-130(10)-1', '1.0101', 1, '2018-04-11 16:47:08'),
(4257, 'KC0R-67-130(10)-2', '1.0101', 1, '2018-04-11 16:47:09'),
(4258, 'KC0R-67-130(10)-3', '1.0101', 1, '2018-04-11 16:47:09'),
(4259, 'KC0T-67-130(10)-1', '0', 1, '2018-04-11 16:47:09'),
(4260, 'KC0T-67-130(10)-2', '0.3891', 1, '2018-04-11 16:47:09'),
(4261, 'KC0T-67-130(10)-3', '0', 1, '2018-04-11 16:47:09'),
(4262, 'KC9J-67-130(9)-1', '1.1293', 1, '2018-04-11 16:47:09'),
(4263, 'KC9J-67-130(9)-2', '1.1293', 1, '2018-04-11 16:47:09'),
(4264, 'KC9J-67-130(9)-3', '1.1293', 1, '2018-04-11 16:47:09'),
(4265, 'KD0E-67-130(10)-1', '0', 1, '2018-04-11 16:47:09'),
(4266, 'KD0E-67-130(10)-2', '1.3113', 1, '2018-04-11 16:47:09'),
(4267, 'KD0E-67-130(10)-3', '0', 1, '2018-04-11 16:47:09'),
(4268, 'KD2W-67-130A(9)-1', '1.1184', 1, '2018-04-11 16:47:09'),
(4269, 'KD2W-67-130A(9)-2', '1.1177', 1, '2018-04-11 16:47:09'),
(4270, 'KD2W-67-130A(9)-3', '1.1177', 1, '2018-04-11 16:47:09'),
(4271, 'KD3A-67-130A(9)-1', '0.7055', 1, '2018-04-11 16:47:09'),
(4272, 'KD3A-67-130A(9)-2', '0.7055', 1, '2018-04-11 16:47:09'),
(4273, 'KD3A-67-130A(9)-3', '0.7055', 1, '2018-04-11 16:47:09'),
(4274, 'KD3D-67-130A(9)-1', '1.3137', 1, '2018-04-11 16:47:09'),
(4275, 'KD3D-67-130A(9)-2', '1.313', 1, '2018-04-11 16:47:09'),
(4276, 'KD3D-67-130A(9)-3', '1.313', 1, '2018-04-11 16:47:09'),
(4277, 'KD3E-67-130A(9)-1', '1.0142', 1, '2018-04-11 16:47:09'),
(4278, 'KD3E-67-130A(9)-2', '1.0142', 1, '2018-04-11 16:47:09'),
(4279, 'KD3E-67-130A(9)-3', '1.0142', 1, '2018-04-11 16:47:09'),
(4280, 'KD3F-67-130A(9)-1', '1.6213', 1, '2018-04-11 16:47:09'),
(4281, 'KD3F-67-130A(9)-2', '1.6207', 1, '2018-04-11 16:47:09'),
(4282, 'KD3F-67-130A(9)-3', '1.6207', 1, '2018-04-11 16:47:09'),
(4283, 'KD3M-67-130(9)-1', '1.3245', 1, '2018-04-11 16:47:09'),
(4284, 'KD3M-67-130(9)-2', '1.3245', 1, '2018-04-11 16:47:09'),
(4285, 'KD3M-67-130(9)-3', '1.3245', 1, '2018-04-11 16:47:09'),
(4286, 'KD3R-67-130(9)-1', '1.1184', 1, '2018-04-11 16:47:09'),
(4287, 'KD3R-67-130(9)-2', '1.1177', 1, '2018-04-11 16:47:09'),
(4288, 'KD3R-67-130(9)-3', '1.1177', 1, '2018-04-11 16:47:09'),
(4289, 'KD3S-67-130(9)-1', '0', 1, '2018-04-11 16:47:09'),
(4290, 'KD3S-67-130(9)-2', '1.7368', 1, '2018-04-11 16:47:10'),
(4291, 'KD3S-67-130(9)-3', '0', 1, '2018-04-11 16:47:10'),
(4292, 'KD4D-67-130(10)-1', '0', 1, '2018-04-11 16:47:10'),
(4293, 'KD4D-67-130(10)-2', '1.3097', 1, '2018-04-11 16:47:10'),
(4294, 'KD4D-67-130(10)-3', '1.3097', 1, '2018-04-11 16:47:10'),
(4295, 'KF1H-67-130(9)-1', '0', 1, '2018-04-11 16:47:10'),
(4296, 'KF1H-67-130(9)-2', '1.9321', 1, '2018-04-11 16:47:10'),
(4297, 'KF1H-67-130(9)-3', '0', 1, '2018-04-11 16:47:10'),
(4298, 'K127-67-130A(7)', '2.3142', 1, '2018-04-11 16:47:10'),
(4299, 'K127-67-130A(7)-1', '2.3142', 1, '2018-04-11 16:47:10'),
(4300, 'K127-67-130A(7)-2', '2.3142', 1, '2018-04-11 16:47:10'),
(4301, 'K147-67-130A(7)', '2.5096', 1, '2018-04-11 16:47:10'),
(4302, 'K147-67-130A(7)-1', '2.5096', 1, '2018-04-11 16:47:10'),
(4303, 'K147-67-130A(7)-2', '2.5096', 1, '2018-04-11 16:47:10'),
(4304, 'KB8C-67-130A(9)', '0', 1, '2018-04-11 16:47:10'),
(4305, 'KB8C-67-130A(9)-1', '1.5089', 1, '2018-04-11 16:47:10'),
(4306, 'KB8C-67-130A(9)-2', '0', 1, '2018-04-11 16:47:10'),
(4307, 'KB8D-67-130A(9)', '0', 1, '2018-04-11 16:47:10'),
(4308, 'KB8D-67-130A(9)-1', '2.1188', 1, '2018-04-11 16:47:10'),
(4309, 'KB8D-67-130A(9)-2', '0', 1, '2018-04-11 16:47:10'),
(4310, 'KC0A-67-130(9)', '0', 1, '2018-04-11 16:47:10'),
(4311, 'KC0A-67-130(9)-1', '1.6188', 1, '2018-04-11 16:47:10'),
(4312, 'KC0A-67-130(9)-2', '0', 1, '2018-04-11 16:47:10'),
(4313, 'KC0B-67-130(9)', '0', 1, '2018-04-11 16:47:10'),
(4314, 'KC0B-67-130(9)-1', '2.3172', 1, '2018-04-11 16:47:10'),
(4315, 'KC0B-67-130(9)-2', '0', 1, '2018-04-11 16:47:10'),
(4316, 'KC9E-67-130A(9)', '0', 1, '2018-04-11 16:47:10'),
(4317, 'KC9E-67-130A(9)-1', '1.9196', 1, '2018-04-11 16:47:10'),
(4318, 'KC9E-67-130A(9)-2', '0', 1, '2018-04-11 16:47:10'),
(4319, 'KC9F-67-130A(9)', '2.6177', 1, '2018-04-11 16:47:11'),
(4320, 'KC9F-67-130A(9)-1', '2.6177', 1, '2018-04-11 16:47:11'),
(4321, 'KC9F-67-130A(9)-2', '2.6177', 1, '2018-04-11 16:47:11'),
(4322, 'KD7V-67-130A(9)', '1.8141', 1, '2018-04-11 16:47:11'),
(4323, 'KD7V-67-130A(9)-1', '1.8141', 1, '2018-04-11 16:47:11'),
(4324, 'KD7V-67-130A(9)-2', '1.8141', 1, '2018-04-11 16:47:11'),
(4325, 'KD7W-67-130A(9)', '2.5125', 1, '2018-04-11 16:47:11'),
(4326, 'KD7W-67-130A(9)-1', '2.5125', 1, '2018-04-11 16:47:11'),
(4327, 'KD7W-67-130A(9)-2', '2.5125', 1, '2018-04-11 16:47:11'),
(4328, 'KF1J-67-130A(9)', '0', 1, '2018-04-11 16:47:11'),
(4329, 'KF1J-67-130A(9)-1', '2.524', 1, '2018-04-11 16:47:11'),
(4330, 'KF1J-67-130A(9)-2', '0', 1, '2018-04-11 16:47:11'),
(4331, 'KF1K-67-130A(9)', '3.1299', 1, '2018-04-11 16:47:11'),
(4332, 'KF1K-67-130A(9)-1', '3.1299', 1, '2018-04-11 16:47:11'),
(4333, 'KF1K-67-130A(9)-2', '3.1299', 1, '2018-04-11 16:47:11'),
(4334, 'KF1L-67-130(6)-1', '0', 1, '2018-04-11 16:47:11'),
(4335, 'KF1M-67-130(6)-1', '0', 1, '2018-04-11 16:47:11'),
(4336, 'KF2C-67-130(9)', '0', 1, '2018-04-11 16:47:11'),
(4337, 'KF2C-67-130(9)-1', '1.198', 1, '2018-04-11 16:47:11'),
(4338, 'KF2C-67-130(9)-2', '0', 1, '2018-04-11 16:47:11'),
(4339, 'KF2K-67-130(7)', '0', 1, '2018-04-11 16:47:11'),
(4340, 'KF2K-67-130(7)-1', '1.8098', 1, '2018-04-11 16:47:11'),
(4341, 'KF2K-67-130(7)-2', '0', 1, '2018-04-11 16:47:11'),
(4342, 'K123-67-100A(9)-2', '1.4509', 1, '2018-04-11 16:47:11'),
(4343, 'K131-67-100A(3)-2', '1.6664', 1, '2018-04-11 16:47:11'),
(4344, 'KB7W-67-100(9)-2', '1.0506', 1, '2018-04-11 16:47:11'),
(4345, 'KB9G-67-100(9)-2', '1.7889', 1, '2018-04-11 16:47:11'),
(4346, 'KB9H-67-100(9)-2', '1.3886', 1, '2018-04-11 16:47:11'),
(4347, 'K123-67-290(3)-4', '0.2244', 1, '2018-04-11 16:47:11'),
(4348, 'K262-67-290A(8)', '0.6671', 1, '2018-04-11 16:47:11'),
(4349, 'KB9G-67-290(3)-4', '0.4456', 1, '2018-04-11 16:47:11'),
(4350, 'K128-67-290(2)-3', '0.2235', 1, '2018-04-11 16:47:11'),
(4351, 'K148-67-290(2)-3', '0.4189', 1, '2018-04-11 16:47:11'),
(4352, 'K147-67-290(1)-5', '0.9129', 1, '2018-04-11 16:47:11'),
(4353, 'K156-67-290A(4)-1', '0.451', 1, '2018-04-11 16:47:12'),
(4354, 'K157-67-290A(4)-1', '0.4511', 1, '2018-04-11 16:47:12'),
(4355, 'K131-67-290(3)-2', '1.044', 1, '2018-04-11 16:47:12'),
(4356, 'K131-V7-295(1)', '1.266', 1, '2018-04-11 16:47:12'),
(4357, 'K232-67-290A(6)', '1.4877', 1, '2018-04-11 16:47:12'),
(4358, 'KD7J-67-290(5)-2', '1.266', 1, '2018-04-11 16:47:12'),
(4359, 'KD8A-67-290(5)-2', '0.8188', 1, '2018-04-11 16:47:12'),
(4360, 'K132-67-290(3)-2', '1.0432', 1, '2018-04-11 16:47:12'),
(4361, 'K233-67-290(4)-2', '1.2653', 1, '2018-04-11 16:47:12'),
(4362, 'KD7K-67-290(3)', '0', 1, '2018-04-11 16:47:12'),
(4363, 'KD8B-67-290(5)-2', '0.8189', 1, '2018-04-11 16:47:12'),
(4364, 'K230-67-290(0)-1', '0.9016', 1, '2018-04-11 16:47:12'),
(4365, 'K231-67-290(1)-1', '0.6897', 1, '2018-04-11 16:47:12'),
(4366, 'K157-67-SH0(1)', '0.19', 1, '2018-04-11 16:47:12'),
(4367, 'K128-67-SH0(15)-1', '0.2868', 1, '2018-04-11 16:47:12'),
(4368, 'K147-67-SH0A(2)', '1.6199', 1, '2018-04-11 16:47:12'),
(4369, 'KD5L-67-SH0(1)-1', '0.2856', 1, '2018-04-11 16:47:12'),
(4370, 'K131-66-SH0(0)-2', '0.4747', 1, '2018-04-11 16:47:12'),
(4371, 'KB8A-67-SH1(3)-3', '0.3199', 1, '2018-04-11 16:47:12'),
(4372, 'KC9E-67-SH1A(1)-2', '0.2155', 1, '2018-04-11 16:47:12'),
(4373, 'KB7W-57-X6XB(4)', '0.2167', 1, '2018-04-11 16:47:12'),
(4374, 'KB7W-57-X6XB(4)-1', '0.2167', 1, '2018-04-11 16:47:12'),
(4375, 'K123-67-190B(13)-4', '4.4769', 1, '2018-04-11 16:47:12'),
(4376, 'K123-67-190B(13)-5', '4.4769', 1, '2018-04-11 16:47:12'),
(4377, 'K131-67-190(13)-4', '3.9814', 1, '2018-04-11 16:47:12'),
(4378, 'K131-67-190(13)-5', '3.9814', 1, '2018-04-11 16:47:12'),
(4379, 'K132-67-190(13)-4', '3.9814', 1, '2018-04-11 16:47:12'),
(4380, 'K132-67-190(13)-5', '3.9814', 1, '2018-04-11 16:47:12'),
(4381, 'K230-67-190(13)-4', '4.4769', 1, '2018-04-11 16:47:12'),
(4382, 'K230-67-190(13)-5', '4.4769', 1, '2018-04-11 16:47:12'),
(4383, 'KB9G-67-190A(13)-4', '4.3821', 1, '2018-04-11 16:47:12'),
(4384, 'KB9G-67-190A(13)-5', '4.3821', 1, '2018-04-11 16:47:13'),
(4385, 'KB9N-67-190A(13)-4', '4.279', 1, '2018-04-11 16:47:13'),
(4386, 'KB9N-67-190A(13)-5', '4.279', 1, '2018-04-11 16:47:13'),
(4387, 'KC0R-67-190A(13)-4', '4.0809', 1, '2018-04-11 16:47:13'),
(4388, 'KC0R-67-190A(13)-5', '4.0809', 1, '2018-04-11 16:47:13'),
(4389, 'KL4G-67-190(15)-3', '4.3821', 1, '2018-04-11 16:47:13'),
(4390, 'KL4G-67-190(15)-4', '4.3821', 1, '2018-04-11 16:47:13'),
(4391, 'KL5B-67-190(14)-4', '4.279', 1, '2018-04-11 16:47:13'),
(4392, 'KL5B-67-190(14)-5', '4.279', 1, '2018-04-11 16:47:13'),
(4393, 'KL6L-67-190(13)-4', '3.9847', 1, '2018-04-11 16:47:13'),
(4394, 'KL6L-67-190(13)-5', '3.9847', 1, '2018-04-11 16:47:13'),
(4395, 'KB8H-67-190A(6)-1', '0', 1, '2018-04-11 16:47:13'),
(4396, 'KB9V-67-190A(12)-2', '4.0817', 1, '2018-04-11 16:47:13'),
(4397, 'KB9V-67-190A(12)-3', '4.0816', 1, '2018-04-11 16:47:13'),
(4398, 'KD3F-67-190(12)-2', '4.5797', 1, '2018-04-11 16:47:13'),
(4399, 'KD3F-67-190(12)-3', '4.5796', 1, '2018-04-11 16:47:13'),
(4400, 'KD3M-67-190A(12)-2', '4.2798', 1, '2018-04-11 16:47:13'),
(4401, 'KD3M-67-190A(12)-3', '4.2797', 1, '2018-04-11 16:47:13'),
(4402, 'KF1H-67-190A(12)-2', '4.0817', 1, '2018-04-11 16:47:13'),
(4403, 'KF1H-67-190A(12)-3', '4.0816', 1, '2018-04-11 16:47:13'),
(4404, 'KL1P-67-190(12)-3', '0', 1, '2018-04-11 16:47:13'),
(4405, 'KL1P-67-190(12)-4', '3.0794', 1, '2018-04-11 16:47:13'),
(4406, 'KL2F-67-190(12)-3', '4.282', 1, '2018-04-11 16:47:13'),
(4407, 'KL2F-67-190(12)-4', '4.2819', 1, '2018-04-11 16:47:13'),
(4408, 'KL2T-67-190(12)-2', '4.0839', 1, '2018-04-11 16:47:13'),
(4409, 'KL2T-67-190(12)-3', '4.0838', 1, '2018-04-11 16:47:13'),
(4410, 'KL3E-67-190(15)-3', '4.2798', 1, '2018-04-11 16:47:13'),
(4411, 'KL3E-67-190(15)-4', '4.2797', 1, '2018-04-11 16:47:13'),
(4412, 'KL4A-67-190(15)-2', '4.0817', 1, '2018-04-11 16:47:13'),
(4413, 'KL4A-67-190(15)-3', '4.0816', 1, '2018-04-11 16:47:13'),
(4414, 'KB8N-67-200A(12)-4', '2.4956', 1, '2018-04-11 16:47:13'),
(4415, 'KB8N-67-200A(12)-5', '2.4956', 1, '2018-04-11 16:47:13'),
(4416, 'KB9T-67-200(12)-4', '2.8833', 1, '2018-04-11 16:47:13'),
(4417, 'KB9T-67-200(12)-5', '2.8833', 1, '2018-04-11 16:47:13'),
(4418, 'KD3M-67-200A(12)-4', '3.0816', 1, '2018-04-11 16:47:14'),
(4419, 'KD3M-67-200A(12)-5', '3.0816', 1, '2018-04-11 16:47:14'),
(4420, 'KF1H-67-200A(12)-4', '2.8833', 1, '2018-04-11 16:47:14'),
(4421, 'KF1H-67-200A(12)-5', '2.8833', 1, '2018-04-11 16:47:14'),
(4422, 'KL1P-67-200(12)-4', '0', 1, '2018-04-11 16:47:14'),
(4423, 'KL1P-67-200(12)-5', '2.0812', 1, '2018-04-11 16:47:14'),
(4424, 'KL2F-67-200(12)-4', '3.4739', 1, '2018-04-11 16:47:14'),
(4425, 'KL2F-67-200(12)-5', '3.4739', 1, '2018-04-11 16:47:14'),
(4426, 'KL2T-67-200(12)-4', '3.2756', 1, '2018-04-11 16:47:14'),
(4427, 'KL2T-67-200(12)-5', '3.2756', 1, '2018-04-11 16:47:14'),
(4428, 'KL3E-67-200(15)-3', '3.0816', 1, '2018-04-11 16:47:14'),
(4429, 'KL3E-67-200(15)-4', '3.0816', 1, '2018-04-11 16:47:14'),
(4430, 'KL4A-67-200(15)-3', '2.8833', 1, '2018-04-11 16:47:14'),
(4431, 'KL4A-67-200(15)-4', '2.8833', 1, '2018-04-11 16:47:14'),
(4432, 'K123-67-200A(11)-2', '2.4926', 1, '2018-04-11 16:47:14'),
(4433, 'K123-67-200A(11)-3', '2.4926', 1, '2018-04-11 16:47:14'),
(4434, 'K131-67-200(11)-3', '2.8802', 1, '2018-04-11 16:47:14'),
(4435, 'K131-67-200(11)-4', '2.8802', 1, '2018-04-11 16:47:14'),
(4436, 'KB9G-67-200A(11)-3', '3.1813', 1, '2018-04-11 16:47:14'),
(4437, 'KB9G-67-200A(11)-4', '3.1813', 1, '2018-04-11 16:47:14'),
(4438, 'KB9M-67-200(11)-3', '3.0782', 1, '2018-04-11 16:47:14'),
(4439, 'KB9M-67-200(11)-4', '3.0782', 1, '2018-04-11 16:47:14'),
(4440, 'KC0R-67-200(11)-2', '2.8802', 1, '2018-04-11 16:47:14'),
(4441, 'KC0R-67-200(11)-3', '2.8802', 1, '2018-04-11 16:47:14'),
(4442, 'KF1D-67-200A(11)-3', '3.0782', 1, '2018-04-11 16:47:14'),
(4443, 'KF1D-67-200A(11)-4', '3.0782', 1, '2018-04-11 16:47:14'),
(4444, 'KL4G-67-200(12)-3', '3.1813', 1, '2018-04-11 16:47:14'),
(4445, 'KL4G-67-200(12)-4', '3.1813', 1, '2018-04-11 16:47:14'),
(4446, 'K123-67-210A(8)-3', '1.0939', 1, '2018-04-11 16:47:14'),
(4447, 'K123-67-210A(8)-4', '1.0939', 1, '2018-04-11 16:47:14'),
(4448, 'K131-67-210(1)-3', '1.0921', 1, '2018-04-11 16:47:15'),
(4449, 'K131-67-210(1)-4', '1.0921', 1, '2018-04-11 16:47:15'),
(4450, 'K132-67-210(1)-3', '1.4891', 1, '2018-04-11 16:47:15'),
(4451, 'K132-67-210(1)-4', '1.4891', 1, '2018-04-11 16:47:15'),
(4452, 'K230-67-210(1)-3', '1.4891', 1, '2018-04-11 16:47:15'),
(4453, 'K230-67-210(1)-4', '1.4891', 1, '2018-04-11 16:47:15'),
(4454, 'K262-67-210(11)-1', '1.4924', 1, '2018-04-11 16:47:15'),
(4455, 'K262-67-210(11)-2', '1.4924', 1, '2018-04-11 16:47:15'),
(4456, 'KB7W-67-210A(8)-3', '1.1958', 1, '2018-04-11 16:47:15'),
(4457, 'KB7W-67-210A(8)-4', '1.1958', 1, '2018-04-11 16:47:15'),
(4458, 'KB8M-67-210(8)-3', '1.4923', 1, '2018-04-11 16:47:15'),
(4459, 'KB8M-67-210(8)-4', '1.4923', 1, '2018-04-11 16:47:15'),
(4460, 'KB8N-67-210(8)-3', '1.5942', 1, '2018-04-11 16:47:15'),
(4461, 'KB8N-67-210(8)-4', '1.5942', 1, '2018-04-11 16:47:15'),
(4462, 'KB9H-67-210(8)-3', '1.6961', 1, '2018-04-11 16:47:15'),
(4463, 'KB9H-67-210(8)-4', '1.6961', 1, '2018-04-11 16:47:15'),
(4464, 'KL1P-67-210(9)-2', '0', 1, '2018-04-11 16:47:15'),
(4465, 'KL1P-67-210(9)-3', '0', 1, '2018-04-11 16:47:15'),
(4466, 'K123-67-220A(8)-3', '1.0939', 1, '2018-04-11 16:47:15'),
(4467, 'K123-67-220A(8)-4', '1.0939', 1, '2018-04-11 16:47:15'),
(4468, 'K131-67-220(1)-3', '1.0921', 1, '2018-04-11 16:47:15'),
(4469, 'K131-67-220(1)-4', '1.0921', 1, '2018-04-11 16:47:15'),
(4470, 'K132-67-220(1)-3', '1.4891', 1, '2018-04-11 16:47:15'),
(4471, 'K132-67-220(1)-4', '1.4891', 1, '2018-04-11 16:47:15'),
(4472, 'K230-67-220(1)-3', '1.4891', 1, '2018-04-11 16:47:15'),
(4473, 'K230-67-220(1)-4', '1.4891', 1, '2018-04-11 16:47:15'),
(4474, 'K262-67-220(11)-1', '1.4923', 1, '2018-04-11 16:47:16'),
(4475, 'K262-67-220(11)-2', '1.4923', 1, '2018-04-11 16:47:16'),
(4476, 'KB7W-67-220A(8)-3', '1.1958', 1, '2018-04-11 16:47:16'),
(4477, 'KB7W-67-220A(8)-4', '1.1958', 1, '2018-04-11 16:47:16'),
(4478, 'KB8M-67-220(8)-3', '1.4921', 1, '2018-04-11 16:47:16'),
(4479, 'KB8M-67-220(8)-4', '1.4921', 1, '2018-04-11 16:47:16'),
(4480, 'KB8N-67-220(8)-3', '1.594', 1, '2018-04-11 16:47:16'),
(4481, 'KB8N-67-220(8)-4', '1.594', 1, '2018-04-11 16:47:16'),
(4482, 'KB9H-67-220(8)-3', '1.6959', 1, '2018-04-11 16:47:16'),
(4483, 'KB9H-67-220(8)-4', '1.6959', 1, '2018-04-11 16:47:16'),
(4484, 'KL1P-67-220(9)-2', '0', 1, '2018-04-11 16:47:16'),
(4485, 'KL1P-67-220(9)-3', '0', 1, '2018-04-11 16:47:16'),
(4486, 'N314-67-010A(4)-3', '23.1373', 1, '2018-04-11 16:47:16'),
(4487, 'N315-67-010A(4)-3', '23.3589', 1, '2018-04-11 16:47:16'),
(4488, 'N316-67-010A(4)-3', '23.6191', 1, '2018-04-11 16:47:16'),
(4489, 'N317-67-010A(4)-3', '25.7661', 1, '2018-04-11 16:47:16'),
(4490, 'N318-67-010A(4)-3', '26.0263', 1, '2018-04-11 16:47:16'),
(4491, 'N319-67-010A(4)-3', '26.0134', 1, '2018-04-11 16:47:16'),
(4492, 'N322-67-010A(4)-3', '26.2736', 1, '2018-04-11 16:47:16'),
(4493, 'ND0H-67-010A(4)-3', '24.9346', 1, '2018-04-11 16:47:16'),
(4494, 'ND0J-67-010A(4)-3', '23.9543', 1, '2018-04-11 16:47:16'),
(4495, 'ND0K-67-010A(4)-3', '24.2144', 1, '2018-04-11 16:47:16'),
(4496, 'ND0N-67-010A(4)-3', '25.1483', 1, '2018-04-11 16:47:16'),
(4497, 'ND0P-67-010B(5)-3', '25.0373', 1, '2018-04-11 16:47:16'),
(4498, 'ND0R-67-010B(5)-3', '25.758', 1, '2018-04-11 16:47:16'),
(4499, 'ND1A-67-010B(5)-3', '25.7664', 1, '2018-04-11 16:47:16'),
(4500, 'ND1B-67-010B(5)-3', '25.0458', 1, '2018-04-11 16:47:16'),
(4501, 'ND1C-67-010C(5)-3', '24.014', 1, '2018-04-11 16:47:16'),
(4502, 'ND1D-67-010C(5)-3', '24.7348', 1, '2018-04-11 16:47:17'),
(4503, 'ND1E-67-010C(5)-3', '24.7492', 1, '2018-04-11 16:47:17'),
(4504, 'ND1F-67-010B(5)-3', '25.9421', 1, '2018-04-11 16:47:17'),
(4505, 'ND1G-67-010B(5)-3', '24.961', 1, '2018-04-11 16:47:17'),
(4506, 'ND1H-67-010B(5)-3', '25.2214', 1, '2018-04-11 16:47:17'),
(4507, 'ND1M-67-010B(5)-3', '25.9564', 1, '2018-04-11 16:47:17'),
(4508, 'ND1N-67-010B(5)-3', '28.1969', 1, '2018-04-11 16:47:17'),
(4509, 'ND1P-67-010B(5)-3', '27.2158', 1, '2018-04-11 16:47:17'),
(4510, 'ND1R-67-010B(5)-3', '27.2884', 1, '2018-04-11 16:47:17'),
(4511, 'ND1V-67-010A(4)-3', '24.1961', 1, '2018-04-11 16:47:17'),
(4512, 'ND2F-67-010A(5)-3', '25.7888', 1, '2018-04-11 16:47:17'),
(4513, 'ND2G-67-010A(5)-3', '25.5283', 1, '2018-04-11 16:47:17'),
(4514, 'ND2H-67-010A(5)-3', '25.8612', 1, '2018-04-11 16:47:17'),
(4515, 'ND2J-67-010A(5)-3', '25.6008', 1, '2018-04-11 16:47:17'),
(4516, 'ND2L-67-010A(5)-3', '23.2889', 1, '2018-04-11 16:47:17'),
(4517, 'ND2M-67-010A(4)-3', '25.3577', 1, '2018-04-11 16:47:17'),
(4518, 'ND2N-67-010A(4)-3', '25.6059', 1, '2018-04-11 16:47:17'),
(4519, 'ND2P-67-010A(4)-3', '24.168', 1, '2018-04-11 16:47:17'),
(4520, 'ND2R-67-010C(5)-3', '24.0284', 1, '2018-04-11 16:47:17'),
(4521, 'ND2S-67-010B(5)-3', '25.2357', 1, '2018-04-11 16:47:17'),
(4522, 'ND2T-67-010B(5)-3', '27.4763', 1, '2018-04-11 16:47:17'),
(4523, 'ND2V-67-010B(5)-3', '28.2695', 1, '2018-04-11 16:47:17'),
(4524, 'ND3B-67-010A(5)-3', '26.8362', 1, '2018-04-11 16:47:17'),
(4525, 'N314-67-050A(4)-6', '16.3055', 1, '2018-04-11 16:47:17'),
(4526, 'N314-67-050A(5)', '16.3055', 1, '2018-04-11 16:47:17'),
(4527, 'N315-67-050A(4)-6', '26.9637', 1, '2018-04-11 16:47:17'),
(4528, 'N315-67-050A(5)', '26.9637', 1, '2018-04-11 16:47:17'),
(4529, 'N316-67-050A(4)-6', '26.9637', 1, '2018-04-11 16:47:17'),
(4530, 'N316-67-050A(5)', '26.9637', 1, '2018-04-11 16:47:17'),
(4531, 'N317-67-050A(4)-6', '29.3193', 1, '2018-04-11 16:47:17'),
(4532, 'N317-67-050A(5)', '29.3193', 1, '2018-04-11 16:47:17'),
(4533, 'N319-67-050A(4)-6', '31.2896', 1, '2018-04-11 16:47:17'),
(4534, 'N319-67-050A(5)', '31.2896', 1, '2018-04-11 16:47:17'),
(4535, 'N320-67-050A(4)-6', '32.9714', 1, '2018-04-11 16:47:18'),
(4536, 'N320-67-050A(5)', '32.9714', 1, '2018-04-11 16:47:18'),
(4537, 'N321-67-050A(4)-6', '32.9714', 1, '2018-04-11 16:47:18'),
(4538, 'N321-67-050A(5)', '32.9714', 1, '2018-04-11 16:47:18'),
(4539, 'N322-67-050A(4)-6', '37.2967', 1, '2018-04-11 16:47:18'),
(4540, 'N322-67-050A(5)', '37.2967', 1, '2018-04-11 16:47:18'),
(4541, 'N323-67-050A(4)-6', '17.4884', 1, '2018-04-11 16:47:18'),
(4542, 'N323-67-050A(5)', '17.4884', 1, '2018-04-11 16:47:18'),
(4543, 'N324-67-050A(4)-6', '16.964', 1, '2018-04-11 16:47:18'),
(4544, 'N324-67-050A(5)', '16.964', 1, '2018-04-11 16:47:18'),
(4545, 'N325-67-050A(4)-6', '18.147', 1, '2018-04-11 16:47:18'),
(4546, 'N325-67-050A(5)', '18.147', 1, '2018-04-11 16:47:18'),
(4547, 'N326-67-050A(4)-6', '31.2896', 1, '2018-04-11 16:47:18'),
(4548, 'N326-67-050A(5)', '31.2896', 1, '2018-04-11 16:47:18'),
(4549, 'N327-67-050A(4)-6', '33.6451', 1, '2018-04-11 16:47:18'),
(4550, 'N327-67-050A(5)', '33.6451', 1, '2018-04-11 16:47:18'),
(4551, 'N328-67-050A(4)-6', '37.2967', 1, '2018-04-11 16:47:18'),
(4552, 'N328-67-050A(5)', '37.2967', 1, '2018-04-11 16:47:18'),
(4553, 'N329-67-050A(4)-6', '39.6523', 1, '2018-04-11 16:47:18'),
(4554, 'N329-67-050A(5)', '39.6523', 1, '2018-04-11 16:47:18'),
(4555, 'N330-67-050A(4)-6', '35.3268', 1, '2018-04-11 16:47:18'),
(4556, 'N330-67-050A(5)', '35.3268', 1, '2018-04-11 16:47:18'),
(4557, 'ND0H-67-050A(4)-6', '21.9241', 1, '2018-04-11 16:47:18'),
(4558, 'ND0H-67-050A(5)', '21.9241', 1, '2018-04-11 16:47:18'),
(4559, 'ND0J-67-050A(4)-6', '31.3297', 1, '2018-04-11 16:47:18'),
(4560, 'ND0J-67-050A(5)', '31.3297', 1, '2018-04-11 16:47:18'),
(4561, 'ND0K-67-050A(4)-6', '25.3414', 1, '2018-04-11 16:47:19'),
(4562, 'ND0K-67-050A(5)', '25.3414', 1, '2018-04-11 16:47:19'),
(4563, 'ND0L-67-050A(4)-6', '32.9938', 1, '2018-04-11 16:47:19'),
(4564, 'ND0L-67-050A(5)', '32.9938', 1, '2018-04-11 16:47:19'),
(4565, 'ND0M-67-050A(4)-6', '38.1505', 1, '2018-04-11 16:47:19'),
(4566, 'ND0M-67-050A(5)', '38.1505', 1, '2018-04-11 16:47:19'),
(4567, 'ND0N-67-050A(4)-6', '41.837', 1, '2018-04-11 16:47:19'),
(4568, 'ND0N-67-050A(5)', '41.837', 1, '2018-04-11 16:47:19'),
(4569, 'ND1S-67-050A(4)-6', '32.1631', 1, '2018-04-11 16:47:19'),
(4570, 'ND1S-67-050A(5)', '32.1631', 1, '2018-04-11 16:47:19'),
(4571, 'ND1T-67-050A(4)-6', '24.2588', 1, '2018-04-11 16:47:19'),
(4572, 'ND1T-67-050A(5)', '24.2588', 1, '2018-04-11 16:47:19'),
(4573, 'ND1V-67-050A(4)-6', '26.061', 1, '2018-04-11 16:47:19'),
(4574, 'ND1V-67-050A(5)', '26.061', 1, '2018-04-11 16:47:19'),
(4575, 'ND1W-67-050A(4)-6', '22.3745', 1, '2018-04-11 16:47:19'),
(4576, 'ND1W-67-050A(5)', '22.3745', 1, '2018-04-11 16:47:19'),
(4577, 'ND2A-67-050A(4)-6', '30.2664', 1, '2018-04-11 16:47:19'),
(4578, 'ND2A-67-050A(5)', '30.2664', 1, '2018-04-11 16:47:19'),
(4579, 'ND2B-67-050A(4)-6', '29.4131', 1, '2018-04-11 16:47:19'),
(4580, 'ND2B-67-050A(5)', '29.4131', 1, '2018-04-11 16:47:19'),
(4581, 'ND2C-67-050A(4)-6', '35.4208', 1, '2018-04-11 16:47:19'),
(4582, 'ND2C-67-050A(5)', '35.4208', 1, '2018-04-11 16:47:19'),
(4583, 'ND2D-67-050A(4)-6', '27.9454', 1, '2018-04-11 16:47:19'),
(4584, 'ND2D-67-050A(5)', '27.9454', 1, '2018-04-11 16:47:19'),
(4585, 'ND2E-67-050A(4)-6', '33.9531', 1, '2018-04-11 16:47:19'),
(4586, 'ND2E-67-050A(5)', '33.9531', 1, '2018-04-11 16:47:19'),
(4587, 'ND2M-67-050A(4)-6', '36.0005', 1, '2018-04-11 16:47:19'),
(4588, 'ND2M-67-050A(5)', '36.0005', 1, '2018-04-11 16:47:19'),
(4589, 'ND2N-67-050A(4)-6', '40.3286', 1, '2018-04-11 16:47:19'),
(4590, 'ND2N-67-050A(5)', '40.3286', 1, '2018-04-11 16:47:20'),
(4591, 'ND2P-67-050A(4)-6', '27.0064', 1, '2018-04-11 16:47:20'),
(4592, 'ND2P-67-050A(5)', '27.0064', 1, '2018-04-11 16:47:20'),
(4593, 'ND3L-67-050A(4)-6', '36.0155', 1, '2018-04-11 16:47:20'),
(4594, 'ND3L-67-050A(5)', '36.0155', 1, '2018-04-11 16:47:20'),
(4595, 'ND3M-67-050A(4)-6', '40.3436', 1, '2018-04-11 16:47:20'),
(4596, 'ND3M-67-050A(5)', '40.3436', 1, '2018-04-11 16:47:20'),
(4597, 'ND3N-67-050A(4)-6', '36.0005', 1, '2018-04-11 16:47:20'),
(4598, 'ND3N-67-050A(5)', '36.0005', 1, '2018-04-11 16:47:20'),
(4599, 'ND3P-67-050A(4)-6', '40.3286', 1, '2018-04-11 16:47:20'),
(4600, 'ND3P-67-050A(5)', '40.3286', 1, '2018-04-11 16:47:20'),
(4601, 'ND3R-67-050A(4)-6', '39.1074', 1, '2018-04-11 16:47:20'),
(4602, 'ND3R-67-050A(5)', '39.1074', 1, '2018-04-11 16:47:20'),
(4603, 'ND3S-67-050A(4)-6', '33.0997', 1, '2018-04-11 16:47:20'),
(4604, 'ND3S-67-050A(5)', '33.0997', 1, '2018-04-11 16:47:20'),
(4605, 'ND0P-67-050B(4)', '0', 1, '2018-04-11 16:47:20'),
(4606, 'ND0R-67-050B(8)', '36.9231', 1, '2018-04-11 16:47:20'),
(4607, 'ND0S-67-050B(8)', '30.9094', 1, '2018-04-11 16:47:20');
INSERT INTO `eff_product_st` (`ID`, `product_no`, `st`, `updated_by`, `last_update`) VALUES
(4608, 'ND0T-67-050B(8)', '0', 1, '2018-04-11 16:47:21'),
(4609, 'ND0V-67-050B(8)', '0', 1, '2018-04-11 16:47:21'),
(4610, 'ND1A-67-050B(8)', '34.708', 1, '2018-04-11 16:47:21'),
(4611, 'ND1B-67-050B(8)', '40.7241', 1, '2018-04-11 16:47:21'),
(4612, 'ND1C-67-050C(8)', '22.1734', 1, '2018-04-11 16:47:21'),
(4613, 'ND1D-67-050C(8)', '0', 1, '2018-04-11 16:47:21'),
(4614, 'ND1E-67-050C(8)', '34.3884', 1, '2018-04-11 16:47:21'),
(4615, 'ND1F-67-050B(4)', '20.4618', 1, '2018-04-11 16:47:21'),
(4616, 'ND1G-67-050B(8)', '29.9979', 1, '2018-04-11 16:47:21'),
(4617, 'ND1H-67-050B(8)', '24.0152', 1, '2018-04-11 16:47:21'),
(4618, 'ND1J-67-050B(8)', '0', 1, '2018-04-11 16:47:21'),
(4619, 'ND1K-67-050B(8)', '25.5084', 1, '2018-04-11 16:47:21'),
(4620, 'ND1M-67-050B(8)', '0', 1, '2018-04-11 16:47:21'),
(4621, 'ND1N-67-050B(8)', '30.6864', 1, '2018-04-11 16:47:21'),
(4622, 'ND1P-67-050B(8)', '36.6691', 1, '2018-04-11 16:47:21'),
(4623, 'ND1R-67-050B(8)', '41.0678', 1, '2018-04-11 16:47:21'),
(4624, 'ND2F-67-050A(8)', '27.5028', 1, '2018-04-11 16:47:21'),
(4625, 'ND2G-67-050A(8)', '35.8855', 1, '2018-04-11 16:47:21'),
(4626, 'ND2H-67-050A(8)', '0', 1, '2018-04-11 16:47:21'),
(4627, 'ND2J-67-050A(8)', '40.2844', 1, '2018-04-11 16:47:21'),
(4628, 'ND2K-67-050A(8)', '0', 1, '2018-04-11 16:47:21'),
(4629, 'ND2L-67-050A(8)', '39.5693', 1, '2018-04-11 16:47:21'),
(4630, 'ND2R-67-050B(4)', '0', 1, '2018-04-11 16:47:21'),
(4631, 'ND2S-67-050B(8)', '0', 1, '2018-04-11 16:47:21'),
(4632, 'ND2T-67-050B(8)', '0', 1, '2018-04-11 16:47:21'),
(4633, 'ND2V-67-050B(8)', '0', 1, '2018-04-11 16:47:21'),
(4634, 'ND2W-67-050A(8)', '29.9006', 1, '2018-04-11 16:47:21'),
(4635, 'ND3A-67-050B(8)', '0', 1, '2018-04-11 16:47:21'),
(4636, 'ND3B-67-050B(8)', '0', 1, '2018-04-11 16:47:21'),
(4637, 'ND3C-67-050A(8)', '34.2992', 1, '2018-04-11 16:47:21'),
(4638, 'ND3D-67-050A(8)', '34.2993', 1, '2018-04-11 16:47:21'),
(4639, 'ND3E-67-050A(8)', '34.2173', 1, '2018-04-11 16:47:22'),
(4640, 'ND3F-67-050A(8)', '40.2844', 1, '2018-04-11 16:47:22'),
(4641, 'ND3G-67-050A(8)', '40.1999', 1, '2018-04-11 16:47:22'),
(4642, 'ND3H-67-050A(8)', '0', 1, '2018-04-11 16:47:22'),
(4643, 'ND3J-67-050A(8)', '0', 1, '2018-04-11 16:47:22'),
(4644, 'ND3K-67-050A(8)', '0', 1, '2018-04-11 16:47:22'),
(4645, 'ND3T-67-050B(8)', '0', 1, '2018-04-11 16:47:22'),
(4646, 'ND3V-67-050B(8)', '0', 1, '2018-04-11 16:47:22'),
(4647, 'ND7L-67-050(2)-5', '0', 1, '2018-04-11 16:47:22'),
(4648, 'N247-67-250(3)-2', '0', 1, '2018-04-11 16:47:22'),
(4649, 'N243-67-020D(13)', '10.2978', 1, '2018-04-11 16:47:22'),
(4650, 'N247-67-020D(13)', '9.8558', 1, '2018-04-11 16:47:22'),
(4651, 'N270-67-020D(13)', '10.6626', 1, '2018-04-11 16:47:22'),
(4652, 'NA6S-67-020B(13)', '9.7409', 1, '2018-04-11 16:47:22'),
(4653, 'NA1J-67-020B(9)', '10.321', 1, '2018-04-11 16:47:22'),
(4654, 'NA1L-67-020B(9)', '9.7626', 1, '2018-04-11 16:47:22'),
(4655, 'NA6W-67-020B(9)', '10.6871', 1, '2018-04-11 16:47:22'),
(4656, 'NB2N-67-020B(9)', '9.8774', 1, '2018-04-11 16:47:22'),
(4657, 'N314-67-070(0)-2', '0', 1, '2018-04-11 16:47:22'),
(4658, 'N317-67-070(0)-3', '0.1913', 1, '2018-04-11 16:47:22'),
(4659, 'ND0H-67-070(0)-2', '0', 1, '2018-04-11 16:47:22'),
(4660, 'N320-67-070(0)-3', '0.1913', 1, '2018-04-11 16:47:22'),
(4661, 'ND0K-67-070(0)-2', '0', 1, '2018-04-11 16:47:22'),
(4662, 'N314-67-030A(4)-2', '16.5754', 1, '2018-04-11 16:47:22'),
(4663, 'N314-67-030A(5)', '16.5752', 1, '2018-04-11 16:47:22'),
(4664, 'N315-67-030A(5)-2', '20.8439', 1, '2018-04-11 16:47:22'),
(4665, 'N315-67-030A(6)', '20.8441', 1, '2018-04-11 16:47:22'),
(4666, 'N316-67-030A(5)-2', '20.8356', 1, '2018-04-11 16:47:22'),
(4667, 'N316-67-030A(6)', '20.8357', 1, '2018-04-11 16:47:22'),
(4668, 'N317-67-030A(5)-2', '20.876', 1, '2018-04-11 16:47:22'),
(4669, 'N317-67-030A(6)', '20.876', 1, '2018-04-11 16:47:22'),
(4670, 'N319-67-030A(5)-2', '22.9648', 1, '2018-04-11 16:47:22'),
(4671, 'N319-67-030A(6)', '22.9652', 1, '2018-04-11 16:47:23'),
(4672, 'N322-67-030A(5)-2', '23.2681', 1, '2018-04-11 16:47:23'),
(4673, 'N322-67-030A(6)', '23.2684', 1, '2018-04-11 16:47:23'),
(4674, 'N323-67-030A(4)-2', '17.3819', 1, '2018-04-11 16:47:23'),
(4675, 'N323-67-030A(5)', '17.3818', 1, '2018-04-11 16:47:23'),
(4676, 'N324-67-030A(5)-2', '23.3085', 1, '2018-04-11 16:47:23'),
(4677, 'N324-67-030A(6)', '23.3088', 1, '2018-04-11 16:47:23'),
(4678, 'ND0H-67-030A(4)-2', '18.1726', 1, '2018-04-11 16:47:23'),
(4679, 'ND0H-67-030A(5)', '18.1725', 1, '2018-04-11 16:47:23'),
(4680, 'ND0J-67-030A(5)-2', '20.5758', 1, '2018-04-11 16:47:23'),
(4681, 'ND0J-67-030A(6)', '20.5759', 1, '2018-04-11 16:47:23'),
(4682, 'ND0L-67-030A(5)-2', '20.9668', 1, '2018-04-11 16:47:23'),
(4683, 'ND0L-67-030A(6)', '20.9669', 1, '2018-04-11 16:47:23'),
(4684, 'ND0N-67-030A(5)-2', '23.4305', 1, '2018-04-11 16:47:23'),
(4685, 'ND0N-67-030A(6)', '23.4308', 1, '2018-04-11 16:47:23'),
(4686, 'ND1S-67-030A(5)-2', '21.2059', 1, '2018-04-11 16:47:23'),
(4687, 'ND1S-67-030A(6)', '21.2061', 1, '2018-04-11 16:47:23'),
(4688, 'ND1T-67-030A(4)-2', '19.3817', 1, '2018-04-11 16:47:23'),
(4689, 'ND1T-67-030A(5)', '19.3818', 1, '2018-04-11 16:47:23'),
(4690, 'ND1V-67-030A(4)-2', '21.6062', 1, '2018-04-11 16:47:23'),
(4691, 'ND1V-67-030A(5)', '21.6065', 1, '2018-04-11 16:47:23'),
(4692, 'ND1W-67-030A(5)-2', '20.4744', 1, '2018-04-11 16:47:23'),
(4693, 'ND1W-67-030A(6)', '20.4747', 1, '2018-04-11 16:47:23'),
(4694, 'ND2D-67-030A(5)-2', '22.2676', 1, '2018-04-11 16:47:23'),
(4695, 'ND2D-67-030A(6)', '22.268', 1, '2018-04-11 16:47:23'),
(4696, 'ND2E-67-030A(5)-2', '22.699', 1, '2018-04-11 16:47:23'),
(4697, 'ND2E-67-030A(6)', '22.6994', 1, '2018-04-11 16:47:23'),
(4698, 'ND2M-67-030A(5)-2', '20.8665', 1, '2018-04-11 16:47:23'),
(4699, 'ND2M-67-030A(6)', '20.8667', 1, '2018-04-11 16:47:23'),
(4700, 'ND2N-67-030A(5)-2', '23.091', 1, '2018-04-11 16:47:23'),
(4701, 'ND2N-67-030A(6)', '23.0914', 1, '2018-04-11 16:47:24'),
(4702, 'ND2P-67-030A(4)-2', '18.9791', 1, '2018-04-11 16:47:24'),
(4703, 'ND2P-67-030A(5)', '18.9791', 1, '2018-04-11 16:47:24'),
(4704, 'ND2R-67-030A(5)-2', '20.3546', 1, '2018-04-11 16:47:24'),
(4705, 'ND2R-67-030A(6)', '20.3547', 1, '2018-04-11 16:47:24'),
(4706, 'ND2S-67-030A(5)-2', '20.7456', 1, '2018-04-11 16:47:24'),
(4707, 'ND2S-67-030A(6)', '20.7457', 1, '2018-04-11 16:47:24'),
(4708, 'ND3B-67-030A(5)-2', '20.8665', 1, '2018-04-11 16:47:24'),
(4709, 'ND3B-67-030A(6)', '20.8667', 1, '2018-04-11 16:47:24'),
(4710, 'ND3C-67-030A(5)-2', '23.091', 1, '2018-04-11 16:47:24'),
(4711, 'ND3C-67-030A(6)', '23.0914', 1, '2018-04-11 16:47:24'),
(4712, 'ND0P-67-030B(4)', '0', 1, '2018-04-11 16:47:24'),
(4713, 'ND0R-67-030B(7)', '0', 1, '2018-04-11 16:47:24'),
(4714, 'ND0S-67-030B(7)', '20.8513', 1, '2018-04-11 16:47:24'),
(4715, 'ND0T-67-030B(7)', '21.2449', 1, '2018-04-11 16:47:24'),
(4716, 'ND1A-67-030B(7)', '23.3413', 1, '2018-04-11 16:47:24'),
(4717, 'ND1B-67-030B(7)', '23.7349', 1, '2018-04-11 16:47:24'),
(4718, 'ND1C-67-030C(7)', '19.3755', 1, '2018-04-11 16:47:24'),
(4719, 'ND1D-67-030C(7)', '19.9081', 1, '2018-04-11 16:47:24'),
(4720, 'ND1E-67-030C(7)', '22.1926', 1, '2018-04-11 16:47:24'),
(4721, 'ND1F-67-030B(4)', '17.8448', 1, '2018-04-11 16:47:24'),
(4722, 'ND1G-67-030B(7)', '20.9114', 1, '2018-04-11 16:47:24'),
(4723, 'ND1H-67-030B(7)', '19.9278', 1, '2018-04-11 16:47:24'),
(4724, 'ND1J-67-030B(7)', '20.3214', 1, '2018-04-11 16:47:24'),
(4725, 'ND1K-67-030B(7)', '20.5563', 1, '2018-04-11 16:47:24'),
(4726, 'ND1M-67-030B(7)', '0', 1, '2018-04-11 16:47:24'),
(4727, 'ND1R-67-030B(7)', '23.1959', 1, '2018-04-11 16:47:25'),
(4728, 'ND2F-67-030A(7)', '19.6298', 1, '2018-04-11 16:47:25'),
(4729, 'ND2G-67-030A(7)', '20.2693', 1, '2018-04-11 16:47:25'),
(4730, 'ND2H-67-030A(7)', '0', 1, '2018-04-11 16:47:25'),
(4731, 'ND2J-67-030A(7)', '22.5538', 1, '2018-04-11 16:47:25'),
(4732, 'ND2K-67-030A(7)', '0', 1, '2018-04-11 16:47:25'),
(4733, 'ND2L-67-030A(7)', '22.5538', 1, '2018-04-11 16:47:25'),
(4734, 'ND2T-67-030B(4)', '0', 1, '2018-04-11 16:47:25'),
(4735, 'ND2V-67-030B(7)', '0', 1, '2018-04-11 16:47:25'),
(4736, 'ND2W-67-030B(7)', '22.6059', 1, '2018-04-11 16:47:25'),
(4737, 'ND3A-67-030B(7)', '22.8408', 1, '2018-04-11 16:47:25'),
(4738, 'ND7L-67-030(2)-6', '0', 1, '2018-04-11 16:47:25'),
(4739, 'N247-67-130E(12)', '1.3957', 1, '2018-04-11 16:47:25'),
(4740, 'N253-67-130A(12)', '1.0964', 1, '2018-04-11 16:47:25'),
(4741, 'N255-67-130E(12)', '0.7936', 1, '2018-04-11 16:47:25'),
(4742, 'N257-67-130C(12)', '0', 1, '2018-04-11 16:47:25'),
(4743, 'N259-67-130E(12)', '1.3957', 1, '2018-04-11 16:47:25'),
(4744, 'N260-67-130E(12)', '1.9831', 1, '2018-04-11 16:47:25'),
(4745, 'N270-67-130E(12)', '1.9831', 1, '2018-04-11 16:47:25'),
(4746, 'NA1J-67-130D(8)', '1.4022', 1, '2018-04-11 16:47:25'),
(4747, 'NA1P-67-130E(8)', '1.0936', 1, '2018-04-11 16:47:25'),
(4748, 'NA1V-67-130C(12)', '1.0936', 1, '2018-04-11 16:47:25'),
(4749, 'NA6R-67-130C(12)', '1.0964', 1, '2018-04-11 16:47:25'),
(4750, 'NA6W-67-130E(8)', '1.3957', 1, '2018-04-11 16:47:25'),
(4751, 'NA9B-67-130E(8)', '1.0976', 1, '2018-04-11 16:47:25'),
(4752, 'NA9C-67-130E(8)', '1.0976', 1, '2018-04-11 16:47:25'),
(4753, 'NA9D-67-130E(8)', '1.3976', 1, '2018-04-11 16:47:25'),
(4754, 'NA9E-67-130E(8)', '1.6951', 1, '2018-04-11 16:47:26'),
(4755, 'NA9F-67-130E(8)', '1.9951', 1, '2018-04-11 16:47:26'),
(4756, 'NA9G-67-130E(8)', '1.393', 1, '2018-04-11 16:47:26'),
(4757, 'NA9H-67-130E(8)', '1.6938', 1, '2018-04-11 16:47:26'),
(4758, 'NA9J-67-130E(8)', '1.9893', 1, '2018-04-11 16:47:26'),
(4759, 'NA9K-67-130E(8)', '1.3969', 1, '2018-04-11 16:47:26'),
(4760, 'NA9L-67-130E(8)', '1.6924', 1, '2018-04-11 16:47:26'),
(4761, 'NA9M-67-130E(8)', '1.9932', 1, '2018-04-11 16:47:26'),
(4762, 'NA9N-67-130E(8)', '2.2887', 1, '2018-04-11 16:47:26'),
(4763, 'NA9P-67-130D(8)', '1.7014', 1, '2018-04-11 16:47:26'),
(4764, 'NA9R-67-130D(8)', '2.2977', 1, '2018-04-11 16:47:26'),
(4765, 'NA9T-67-130C(12)', '1.3918', 1, '2018-04-11 16:47:26'),
(4766, 'NA9V-67-130C(12)', '1.9792', 1, '2018-04-11 16:47:26'),
(4767, 'NB0A-67-130C(12)', '2.2785', 1, '2018-04-11 16:47:26'),
(4768, 'NB0D-67-130E(8)', '1.6957', 1, '2018-04-11 16:47:26'),
(4769, 'NB2V-67-130C(12)', '1.6843', 1, '2018-04-11 16:47:26'),
(4770, 'N243-67-290B(4)-4', '1.6587', 1, '2018-04-11 16:47:26'),
(4771, 'N243-67-290B(4)-5', '1.6573', 1, '2018-04-11 16:47:26'),
(4772, 'N247-67-290(6)-9', '1.1906', 1, '2018-04-11 16:47:26'),
(4773, 'NA1J-67-290A(7)-9', '1.6623', 1, '2018-04-11 16:47:26'),
(4774, 'NB0D-67-290(6)-9', '2.0713', 1, '2018-04-11 16:47:26'),
(4775, 'ND0H-67-290(0)-4', '1.1907', 1, '2018-04-11 16:47:26'),
(4776, 'ND0J-67-290(0)-4', '2.0714', 1, '2018-04-11 16:47:26'),
(4777, 'ND1F-67-290(1)-4', '1.1905', 1, '2018-04-11 16:47:26'),
(4778, 'ND1G-67-290(1)-4', '2.0712', 1, '2018-04-11 16:47:26'),
(4779, 'N243-43-754(2)-3', '0.6429', 1, '2018-04-11 16:47:27'),
(4780, 'NA1P-67-SB9(2)-3', '0.2854', 1, '2018-04-11 16:47:27'),
(4781, 'NA1V-67-SB9(1)-1', '0.2873', 1, '2018-04-11 16:47:27'),
(4782, 'N259-67-SH0A(3)-3', '0.3251', 1, '2018-04-11 16:47:27'),
(4783, 'N243-67-SH0A(2)-2', '0.3313', 1, '2018-04-11 16:47:27'),
(4784, 'N247-67-SH0B(8)-5', '2.7235', 1, '2018-04-11 16:47:27'),
(4785, 'NA1L-67-SH0A(8)-5', '2.7235', 1, '2018-04-11 16:47:27'),
(4786, 'N255-67-SH0(2)-3', '0.1967', 1, '2018-04-11 16:47:27'),
(4787, 'N256-67-SH0(1)-5', '4.6', 1, '2018-04-11 16:47:27'),
(4788, 'N257-67-SH0(2)-5', '0.4539', 1, '2018-04-11 16:47:27'),
(4789, 'N258-67-SH0(2)-5', '0.4539', 1, '2018-04-11 16:47:27'),
(4790, 'N261-67-SH0(2)-4', '0.2861', 1, '2018-04-11 16:47:27'),
(4791, 'N270-67-SH0(1)-4', '0.19', 1, '2018-04-11 16:47:27'),
(4792, 'NA1P-67-SH0(2)-4', '0.1908', 1, '2018-04-11 16:47:27'),
(4793, 'NA9C-67-SH0(1)-4', '0.2185', 1, '2018-04-11 16:47:27'),
(4794, 'N247-66-SH0(2)-3', '0.0945', 1, '2018-04-11 16:47:27'),
(4795, 'ND0P-67-SH0(0)-4', '0.5831', 1, '2018-04-11 16:47:27'),
(4796, 'ND7L-67-SH0(21)-1', '0.287', 1, '2018-04-11 16:47:27'),
(4797, 'N243-67-150(2)-6', '1.1894', 1, '2018-04-11 16:47:27'),
(4798, 'N247-67-150(2)-6', '0.221', 1, '2018-04-11 16:47:27'),
(4799, 'N270-67-150(2)-6', '1.4104', 1, '2018-04-11 16:47:27'),
(4800, 'N243-67-EW0(2)-4', '0', 1, '2018-04-11 16:47:27'),
(4801, 'NA1J-67-EW0(2)-4', '0', 1, '2018-04-11 16:47:27'),
(4802, 'N247-67-190(10)-8', '3.8179', 1, '2018-04-11 16:47:28'),
(4803, 'NA1V-67-190(10)-8', '3.6226', 1, '2018-04-11 16:47:28'),
(4804, 'NA6R-67-190D(10)-8', '3.5192', 1, '2018-04-11 16:47:28'),
(4805, 'NA6S-67-190D(10)-8', '3.92', 1, '2018-04-11 16:47:28'),
(4806, 'NB2V-67-190(10)-8', '4.0234', 1, '2018-04-11 16:47:28'),
(4807, 'ND0D-67-190(10)-8', '3.3164', 1, '2018-04-11 16:47:28'),
(4808, 'NA1J-67-190A(10)-6', '4.2236', 1, '2018-04-11 16:47:28'),
(4809, 'NA1L-67-190A(7)-1', '0', 1, '2018-04-11 16:47:28'),
(4810, 'NA1P-67-190B(10)-6', '3.8229', 1, '2018-04-11 16:47:28'),
(4811, 'NA6W-67-190B(10)-6', '3.6245', 1, '2018-04-11 16:47:28'),
(4812, 'NA8W-67-190A(7)-1', '0', 1, '2018-04-11 16:47:28'),
(4813, 'NA9C-67-190(10)-6', '4.0208', 1, '2018-04-11 16:47:28'),
(4814, 'NA9D-67-190B(10)-6', '3.6201', 1, '2018-04-11 16:47:28'),
(4815, 'NA9E-67-190A(7)-1', '0', 1, '2018-04-11 16:47:28'),
(4816, 'NB0D-67-190A(10)-6', '4.0252', 1, '2018-04-11 16:47:28'),
(4817, 'NA1J-67-200A(11)-8', '2.915', 1, '2018-04-11 16:47:28'),
(4818, 'NA1L-67-200A(11)-8', '3.3157', 1, '2018-04-11 16:47:28'),
(4819, 'NA1P-67-200B(11)-8', '2.5161', 1, '2018-04-11 16:47:28'),
(4820, 'NA6W-67-200B(11)-8', '2.6196', 1, '2018-04-11 16:47:28'),
(4821, 'NA9B-67-200A(11)-8', '2.7122', 1, '2018-04-11 16:47:28'),
(4822, 'NA9C-67-200A(11)-8', '3.0203', 1, '2018-04-11 16:47:28'),
(4823, 'NA9D-67-200A(11)-8', '3.1129', 1, '2018-04-11 16:47:28'),
(4824, 'NB0D-67-200A(11)-8', '2.9168', 1, '2018-04-11 16:47:28'),
(4825, 'NB2N-67-200(11)-8', '2.714', 1, '2018-04-11 16:47:28'),
(4826, 'ND7L-67-200(13)-3', '2.9168', 1, '2018-04-11 16:47:28'),
(4827, 'N247-67-200(11)-6', '2.7138', 1, '2018-04-11 16:47:28'),
(4828, 'NA1V-67-200(11)-6', '2.6194', 1, '2018-04-11 16:47:28'),
(4829, 'NA6R-67-200D(11)-6', '2.4124', 1, '2018-04-11 16:47:28'),
(4830, 'NA6S-67-200D(11)-6', '2.8131', 1, '2018-04-11 16:47:28'),
(4831, 'NB2V-67-200(11)-6', '3.0201', 1, '2018-04-11 16:47:28'),
(4832, 'ND0A-67-200(11)-6', '2.8159', 1, '2018-04-11 16:47:28'),
(4833, 'ND0D-67-200(11)-6', '2.2125', 1, '2018-04-11 16:47:28'),
(4834, 'N344-67-010B(6)', '24.7377', 1, '2018-04-11 16:47:28'),
(4835, 'N345-67-010A(6)', '25.1201', 1, '2018-04-11 16:47:29'),
(4836, 'N346-67-010A(6)', '27.3398', 1, '2018-04-11 16:47:29'),
(4837, 'N347-67-010A(6)', '28.1759', 1, '2018-04-11 16:47:29'),
(4838, 'ND5H-67-010A(6)', '25.0955', 1, '2018-04-11 16:47:29'),
(4839, 'ND5M-67-010A(6)', '25.8048', 1, '2018-04-11 16:47:29'),
(4840, 'ND5P-67-010A(6)', '25.0107', 1, '2018-04-11 16:47:29'),
(4841, 'ND6B-67-010A(6)-2', '26.7174', 1, '2018-04-11 16:47:29'),
(4842, 'ND6F-67-010A(6)-2', '28.9577', 1, '2018-04-11 16:47:29'),
(4843, 'ND6H-67-010A(6)-2', '27.0953', 1, '2018-04-11 16:47:29'),
(4844, 'ND6J-67-010A(6)-2', '27.5321', 1, '2018-04-11 16:47:29'),
(4845, 'ND6K-67-010A(6)-2', '27.2716', 1, '2018-04-11 16:47:29'),
(4846, 'ND6M-67-010A(6)-2', '25.1506', 1, '2018-04-11 16:47:29'),
(4847, 'ND6N-67-010B(6)-2', '25.3471', 1, '2018-04-11 16:47:29'),
(4848, 'ND6S-67-010B(6)-2', '26.0599', 1, '2018-04-11 16:47:29'),
(4849, 'ND6T-67-010B(6)-2', '26.2825', 1, '2018-04-11 16:47:29'),
(4850, 'ND6V-67-010B(6)-2', '25.568', 1, '2018-04-11 16:47:29'),
(4851, 'ND7A-67-010A(6)-2', '25.511', 1, '2018-04-11 16:47:29'),
(4852, 'ND7B-67-010A(6)-2', '25.6297', 1, '2018-04-11 16:47:29'),
(4853, 'ND7C-67-010A(6)', '26.9343', 1, '2018-04-11 16:47:29'),
(4854, 'ND7D-67-010A(6)', '27.2834', 1, '2018-04-11 16:47:29'),
(4855, 'NE3F-67-010A(6)-2', '24.7982', 1, '2018-04-11 16:47:29'),
(4856, 'NE3M-67-010A(6)-2', '26.8361', 1, '2018-04-11 16:47:29'),
(4857, 'NE3P-67-010A(6)-2', '26.1215', 1, '2018-04-11 16:47:29'),
(4858, 'NE3S-67-010A(6)-2', '28.7814', 1, '2018-04-11 16:47:29'),
(4859, 'NE3V-67-010A(6)-2', '28.0686', 1, '2018-04-11 16:47:29'),
(4860, 'NE4E-67-010A(6)-2', '24.9152', 1, '2018-04-11 16:47:29'),
(4861, 'NE4H-67-010A(6)', '28.1591', 1, '2018-04-11 16:47:29'),
(4862, 'NE4P-67-010A(6)-2', '26.557', 1, '2018-04-11 16:47:29'),
(4863, 'NE4S-67-010A(6)-2', '24.4361', 1, '2018-04-11 16:47:29'),
(4864, 'NE4T-67-010A(6)-2', '26.3825', 1, '2018-04-11 16:47:29'),
(4865, 'NE4W-67-010A(6)', '26.2267', 1, '2018-04-11 16:47:29'),
(4866, 'NE5A-67-010A(6)', '26.574', 1, '2018-04-11 16:47:29'),
(4867, 'NE5C-67-010A(6)-2', '28.2432', 1, '2018-04-11 16:47:29'),
(4868, 'NE5D-67-010A(6)', '27.1023', 1, '2018-04-11 16:47:30'),
(4869, 'NE5M-67-010A(6)-2', '26.0046', 1, '2018-04-11 16:47:30'),
(4870, 'NE7G-67-010A(6)', '25.7183', 1, '2018-04-11 16:47:30'),
(4871, 'NE7J-67-010A(6)', '27.8099', 1, '2018-04-11 16:47:30'),
(4872, 'N344-67-050B(5)', '20.8221', 1, '2018-04-11 16:47:30'),
(4873, 'N344-67-050B(5)-1', '0', 1, '2018-04-11 16:47:30'),
(4874, 'N345-67-050B(5)', '29.767', 1, '2018-04-11 16:47:30'),
(4875, 'N345-67-050B(5)-1', '29.767', 1, '2018-04-11 16:47:30'),
(4876, 'N346-67-050B(5)', '29.767', 1, '2018-04-11 16:47:30'),
(4877, 'N346-67-050B(5)-1', '29.767', 1, '2018-04-11 16:47:30'),
(4878, 'N347-67-050B(5)', '34.5422', 1, '2018-04-11 16:47:30'),
(4879, 'N347-67-050B(5)-1', '34.5422', 1, '2018-04-11 16:47:30'),
(4880, 'N348-67-050B(5)', '35.7736', 1, '2018-04-11 16:47:30'),
(4881, 'N348-67-050B(5)-1', '35.7736', 1, '2018-04-11 16:47:30'),
(4882, 'N349-67-050B(5)', '40.5485', 1, '2018-04-11 16:47:30'),
(4883, 'N349-67-050B(5)-1', '40.5485', 1, '2018-04-11 16:47:30'),
(4884, 'N357-67-050B(5)', '22.0053', 1, '2018-04-11 16:47:30'),
(4885, 'N357-67-050B(5)-1', '0', 1, '2018-04-11 16:47:30'),
(4886, 'N358-67-050B(5)', '21.3467', 1, '2018-04-11 16:47:30'),
(4887, 'N358-67-050B(5)-1', '21.3467', 1, '2018-04-11 16:47:30'),
(4888, 'N359-67-050B(5)', '35.7736', 1, '2018-04-11 16:47:30'),
(4889, 'N359-67-050B(5)-1', '35.7736', 1, '2018-04-11 16:47:30'),
(4890, 'N360-67-050B(5)', '36.9033', 1, '2018-04-11 16:47:30'),
(4891, 'N360-67-050B(5)-1', '36.9033', 1, '2018-04-11 16:47:30'),
(4892, 'N361-67-050B(5)', '40.5485', 1, '2018-04-11 16:47:30'),
(4893, 'N361-67-050B(5)-1', '40.5485', 1, '2018-04-11 16:47:30'),
(4894, 'N362-67-050B(5)', '34.5422', 1, '2018-04-11 16:47:30'),
(4895, 'N362-67-050B(5)-1', '0', 1, '2018-04-11 16:47:30'),
(4896, 'N372-67-050B(5)', '32.1283', 1, '2018-04-11 16:47:30'),
(4897, 'N372-67-050B(5)-1', '32.1283', 1, '2018-04-11 16:47:30'),
(4898, 'N374-67-050B(5)', '38.1349', 1, '2018-04-11 16:47:30'),
(4899, 'N374-67-050B(5)-1', '38.1349', 1, '2018-04-11 16:47:31'),
(4900, 'N375-67-050B(5)', '42.9096', 1, '2018-04-11 16:47:31'),
(4901, 'N375-67-050B(5)-1', '42.9096', 1, '2018-04-11 16:47:31'),
(4902, 'N376-67-050B(5)', '20.1635', 1, '2018-04-11 16:47:31'),
(4903, 'N376-67-050B(5)-1', '20.1635', 1, '2018-04-11 16:47:31'),
(4904, 'ND5G-67-050B(5)', '24.6725', 1, '2018-04-11 16:47:31'),
(4905, 'ND5G-67-050B(5)-1', '24.6725', 1, '2018-04-11 16:47:31'),
(4906, 'ND5H-67-050B(5)', '28.3512', 1, '2018-04-11 16:47:31'),
(4907, 'ND5H-67-050B(5)-1', '28.3512', 1, '2018-04-11 16:47:31'),
(4908, 'ND5J-67-050B(5)', '29.8348', 1, '2018-04-11 16:47:31'),
(4909, 'ND5J-67-050B(5)-1', '0', 1, '2018-04-11 16:47:31'),
(4910, 'ND5K-67-050B(5)', '30.6788', 1, '2018-04-11 16:47:31'),
(4911, 'ND5K-67-050B(5)-1', '30.6788', 1, '2018-04-11 16:47:31'),
(4912, 'ND5L-67-050B(5)', '33.5134', 1, '2018-04-11 16:47:31'),
(4913, 'ND5L-67-050B(5)-1', '0', 1, '2018-04-11 16:47:31'),
(4914, 'ND5M-67-050B(5)', '34.3574', 1, '2018-04-11 16:47:31'),
(4915, 'ND5M-67-050B(5)-1', '34.3574', 1, '2018-04-11 16:47:31'),
(4916, 'ND5N-67-050B(5)', '22.2309', 1, '2018-04-11 16:47:31'),
(4917, 'ND5N-67-050B(5)-1', '0', 1, '2018-04-11 16:47:31'),
(4918, 'ND5P-67-050B(5)', '31.6342', 1, '2018-04-11 16:47:31'),
(4919, 'ND5P-67-050B(5)-1', '31.6342', 1, '2018-04-11 16:47:31'),
(4920, 'ND5R-67-050B(5)', '25.6473', 1, '2018-04-11 16:47:31'),
(4921, 'ND5R-67-050B(5)-1', '25.6473', 1, '2018-04-11 16:47:31'),
(4922, 'ND7C-67-050B(5)', '37.0597', 1, '2018-04-11 16:47:31'),
(4923, 'ND7C-67-050B(5)-1', '0', 1, '2018-04-11 16:47:31'),
(4924, 'ND7D-67-050B(5)', '41.3799', 1, '2018-04-11 16:47:31'),
(4925, 'ND7D-67-050B(5)-1', '0', 1, '2018-04-11 16:47:31'),
(4926, 'NE4S-67-050B(5)', '34.0306', 1, '2018-04-11 16:47:31'),
(4927, 'NE4S-67-050B(5)-1', '34.0306', 1, '2018-04-11 16:47:31'),
(4928, 'NE4T-67-050B(5)', '28.0443', 1, '2018-04-11 16:47:31'),
(4929, 'NE4T-67-050B(5)-1', '28.0443', 1, '2018-04-11 16:47:32'),
(4930, 'NE4W-67-050B(5)', '37.0448', 1, '2018-04-11 16:47:32'),
(4931, 'NE4W-67-050B(5)-1', '37.0448', 1, '2018-04-11 16:47:32'),
(4932, 'NE5A-67-050B(5)', '37.0448', 1, '2018-04-11 16:47:32'),
(4933, 'NE5A-67-050B(5)-1', '0', 1, '2018-04-11 16:47:32'),
(4934, 'NE5E-67-050B(5)', '41.365', 1, '2018-04-11 16:47:32'),
(4935, 'NE5E-67-050B(5)-1', '41.365', 1, '2018-04-11 16:47:32'),
(4936, 'NE5F-67-050B(5)', '41.365', 1, '2018-04-11 16:47:32'),
(4937, 'NE5F-67-050B(5)-1', '0', 1, '2018-04-11 16:47:32'),
(4938, 'NE7G-67-050B(5)', '33.3176', 1, '2018-04-11 16:47:32'),
(4939, 'NE7G-67-050B(5)-1', '33.3176', 1, '2018-04-11 16:47:32'),
(4940, 'NE7H-67-050B(5)', '39.3041', 1, '2018-04-11 16:47:32'),
(4941, 'NE7H-67-050B(5)-1', '39.3041', 1, '2018-04-11 16:47:32'),
(4942, 'NE7L-67-050B(5)', '43.6243', 1, '2018-04-11 16:47:32'),
(4943, 'NE7L-67-050B(5)-1', '43.6243', 1, '2018-04-11 16:47:32'),
(4944, 'NE7P-67-050B(5)', '27.069', 1, '2018-04-11 16:47:32'),
(4945, 'NE7P-67-050B(5)-1', '27.069', 1, '2018-04-11 16:47:32'),
(4946, 'NE7R-67-050B(5)', '32.2339', 1, '2018-04-11 16:47:32'),
(4947, 'NE7R-67-050B(5)-1', '32.2339', 1, '2018-04-11 16:47:32'),
(4948, 'NE7V-67-050B(5)', '39.5197', 1, '2018-04-11 16:47:32'),
(4949, 'NE7V-67-050B(5)-1', '0', 1, '2018-04-11 16:47:32'),
(4950, 'NE8B-67-050B(5)', '36.7537', 1, '2018-04-11 16:47:32'),
(4951, 'NE8B-67-050B(5)-1', '36.7537', 1, '2018-04-11 16:47:32'),
(4952, 'NE8C-67-050B(5)', '41.9185', 1, '2018-04-11 16:47:32'),
(4953, 'NE8C-67-050B(5)-1', '41.9185', 1, '2018-04-11 16:47:32'),
(4954, 'NE8F-67-050B(5)', '35.841', 1, '2018-04-11 16:47:32'),
(4955, 'NE8F-67-050B(5)-1', '0', 1, '2018-04-11 16:47:32'),
(4956, 'NE8J-67-050B(5)', '30.7476', 1, '2018-04-11 16:47:32'),
(4957, 'NE8J-67-050B(5)-1', '30.7476', 1, '2018-04-11 16:47:32'),
(4958, 'NE8K-67-050B(5)', '35.9125', 1, '2018-04-11 16:47:33'),
(4959, 'NE8K-67-050B(5)-1', '35.9125', 1, '2018-04-11 16:47:33'),
(4960, 'NE8R-67-050B(5)', '33.0751', 1, '2018-04-11 16:47:33'),
(4961, 'NE8R-67-050B(5)-1', '33.0751', 1, '2018-04-11 16:47:33'),
(4962, 'NE8S-67-050B(5)', '38.2399', 1, '2018-04-11 16:47:33'),
(4963, 'NE8S-67-050B(5)-1', '38.2399', 1, '2018-04-11 16:47:33'),
(4964, 'NF1G-67-050B(5)', '33.4835', 1, '2018-04-11 16:47:33'),
(4965, 'NF1G-67-050B(5)-1', '0', 1, '2018-04-11 16:47:33'),
(4966, 'NF1H-67-050B(5)', '27.4773', 1, '2018-04-11 16:47:33'),
(4967, 'NF1H-67-050B(5)-1', '0', 1, '2018-04-11 16:47:33'),
(4968, 'NF1J-67-050B(5)', '35.8799', 1, '2018-04-11 16:47:33'),
(4969, 'NF1J-67-050B(5)-1', '0', 1, '2018-04-11 16:47:33'),
(4970, 'NF1K-67-050B(5)', '29.8739', 1, '2018-04-11 16:47:33'),
(4971, 'NF1K-67-050B(5)-1', '0', 1, '2018-04-11 16:47:33'),
(4972, 'NF1L-67-050B(5)', '37.1622', 1, '2018-04-11 16:47:33'),
(4973, 'NF1L-67-050B(5)-1', '0', 1, '2018-04-11 16:47:33'),
(4974, 'NF1M-67-050B(5)', '31.1559', 1, '2018-04-11 16:47:33'),
(4975, 'NF1M-67-050B(5)-1', '0', 1, '2018-04-11 16:47:33'),
(4976, 'NF1N-67-050B(5)', '39.5585', 1, '2018-04-11 16:47:33'),
(4977, 'NF1N-67-050B(5)-1', '0', 1, '2018-04-11 16:47:33'),
(4978, 'NF1P-67-050B(5)', '33.5525', 1, '2018-04-11 16:47:33'),
(4979, 'NF1P-67-050B(5)-1', '0', 1, '2018-04-11 16:47:33'),
(4980, 'ND5V-67-050B(9)', '20.7644', 1, '2018-04-11 16:47:33'),
(4981, 'ND5W-67-050B(9)', '32.5295', 1, '2018-04-11 16:47:33'),
(4982, 'ND6B-67-050B(9)', '30.4108', 1, '2018-04-11 16:47:33'),
(4983, 'ND6D-67-050B(9)', '31.7358', 1, '2018-04-11 16:47:33'),
(4984, 'ND6F-67-050B(9)', '42.1146', 1, '2018-04-11 16:47:33'),
(4985, 'ND6H-67-050C(9)', '37.3906', 1, '2018-04-11 16:47:33'),
(4986, 'ND6J-67-050C(9)', '32.9498', 1, '2018-04-11 16:47:33'),
(4987, 'ND6K-67-050C(9)', '41.7864', 1, '2018-04-11 16:47:34'),
(4988, 'ND6L-67-050C(9)', '29.3817', 1, '2018-04-11 16:47:34'),
(4989, 'ND6M-67-050C(9)', '40.6283', 1, '2018-04-11 16:47:34'),
(4990, 'ND6N-67-050B(9)', '30.3071', 1, '2018-04-11 16:47:34'),
(4991, 'ND6P-67-050B(9)', '36.3215', 1, '2018-04-11 16:47:34'),
(4992, 'ND6S-67-050B(9)', '33.9123', 1, '2018-04-11 16:47:34'),
(4993, 'ND6V-67-050B(9)', '40.1007', 1, '2018-04-11 16:47:34'),
(4994, 'ND7A-67-050C(9)', '30.9532', 1, '2018-04-11 16:47:34'),
(4995, 'ND7B-67-050C(9)', '34.7325', 1, '2018-04-11 16:47:34'),
(4996, 'NE3G-67-050B(9)', '34.0865', 1, '2018-04-11 16:47:34'),
(4997, 'NE3J-67-050B(9)', '37.6916', 1, '2018-04-11 16:47:34'),
(4998, 'NE3L-67-050B(9)', '22.4212', 1, '2018-04-11 16:47:34'),
(4999, 'NE3M-67-050B(9)', '31.6774', 1, '2018-04-11 16:47:34'),
(5000, 'NE4B-67-050B(9)', '24.428', 1, '2018-04-11 16:47:34'),
(5001, 'NE4D-67-050B(9)', '37.7189', 1, '2018-04-11 16:47:34'),
(5002, 'NE4H-67-050B(9)', '36.384', 1, '2018-04-11 16:47:34'),
(5003, 'NE4K-67-050B(9)', '30.3697', 1, '2018-04-11 16:47:34'),
(5004, 'NE4M-67-050B(9)', '40.1631', 1, '2018-04-11 16:47:34'),
(5005, 'NE4P-67-050B(9)', '34.1488', 1, '2018-04-11 16:47:34'),
(5006, 'NE5L-67-050B(9)', '26.5467', 1, '2018-04-11 16:47:34'),
(5007, 'NE5N-67-050B(9)', '27.898', 1, '2018-04-11 16:47:34'),
(5008, 'NE9B-67-050C(9)', '28.539', 1, '2018-04-11 16:47:34'),
(5009, 'NE9C-67-050C(9)', '30.9481', 1, '2018-04-11 16:47:34'),
(5010, 'NE9F-67-050C(9)', '31.7908', 1, '2018-04-11 16:47:34'),
(5011, 'NE9J-67-050C(9)', '40.6283', 1, '2018-04-11 16:47:34'),
(5012, 'NE9M-67-050C(9)', '40.6134', 1, '2018-04-11 16:47:34'),
(5013, 'NE9R-67-050C(9)', '36.9461', 1, '2018-04-11 16:47:34'),
(5014, 'NE9S-67-050C(9)', '41.3419', 1, '2018-04-11 16:47:34'),
(5015, 'NE9T-67-050C(9)', '41.3419', 1, '2018-04-11 16:47:34'),
(5016, 'NF0B-67-050C(9)', '41.327', 1, '2018-04-11 16:47:34'),
(5017, 'NF0C-67-050C(9)', '41.327', 1, '2018-04-11 16:47:34'),
(5018, 'NF0G-67-050C(9)', '35.8034', 1, '2018-04-11 16:47:34'),
(5019, 'NF0H-67-050C(9)', '35.3588', 1, '2018-04-11 16:47:35'),
(5020, 'NF0J-67-050C(9)', '35.3588', 1, '2018-04-11 16:47:35'),
(5021, 'NF0P-67-050C(9)', '32.9348', 1, '2018-04-11 16:47:35'),
(5022, 'NF0R-67-050C(9)', '35.3438', 1, '2018-04-11 16:47:35'),
(5023, 'NF0T-67-050C(9)', '35.3438', 1, '2018-04-11 16:47:35'),
(5024, 'NF1B-67-050C(9)', '36.9312', 1, '2018-04-11 16:47:35'),
(5025, 'NF1D-67-050C(9)', '28.554', 1, '2018-04-11 16:47:35'),
(5026, 'NF1E-67-050C(9)', '31.4076', 1, '2018-04-11 16:47:35'),
(5027, 'NF1F-67-050C(9)', '30.9631', 1, '2018-04-11 16:47:35'),
(5028, 'N346-67-020B(6)', '8.9573', 1, '2018-04-11 16:47:35'),
(5029, 'N347-67-020B(6)', '8.1653', 1, '2018-04-11 16:47:35'),
(5030, 'ND5H-67-020B(6)', '8.0503', 1, '2018-04-11 16:47:35'),
(5031, 'ND5V-67-020B(6)', '8.592', 1, '2018-04-11 16:47:35'),
(5032, 'ND6A-67-020B(4)', '8.6088', 1, '2018-04-11 16:47:35'),
(5033, 'ND6C-67-020B(4)', '8.065', 1, '2018-04-11 16:47:35'),
(5034, 'ND6D-67-020B(4)', '8.9743', 1, '2018-04-11 16:47:35'),
(5035, 'ND6F-67-020B(4)', '8.1802', 1, '2018-04-11 16:47:35'),
(5036, 'N344-67-030C(7)', '18.1705', 1, '2018-04-11 16:47:35'),
(5037, 'N344-67-030C(7)-1', '18.1714', 1, '2018-04-11 16:47:35'),
(5038, 'N345-67-030B(7)', '21.6339', 1, '2018-04-11 16:47:35'),
(5039, 'N345-67-030B(7)-1', '21.6349', 1, '2018-04-11 16:47:35'),
(5040, 'N346-67-030B(7)', '22.3743', 1, '2018-04-11 16:47:35'),
(5041, 'N346-67-030B(7)-1', '22.3753', 1, '2018-04-11 16:47:35'),
(5042, 'N347-67-030B(7)', '24.0654', 1, '2018-04-11 16:47:35'),
(5043, 'N347-67-030B(7)-1', '24.0663', 1, '2018-04-11 16:47:35'),
(5044, 'N349-67-030B(7)', '24.6664', 1, '2018-04-11 16:47:35'),
(5045, 'N349-67-030B(7)-1', '24.6673', 1, '2018-04-11 16:47:35'),
(5046, 'N372-67-030B(7)', '22.2348', 1, '2018-04-11 16:47:35'),
(5047, 'N372-67-030B(7)-1', '22.2358', 1, '2018-04-11 16:47:35'),
(5048, 'N375-67-030B(7)', '24.8058', 1, '2018-04-11 16:47:35'),
(5049, 'N375-67-030B(7)-1', '24.8067', 1, '2018-04-11 16:47:35'),
(5050, 'N376-67-030C(7)', '0', 1, '2018-04-11 16:47:36'),
(5051, 'N376-67-030C(7)-1', '18.9771', 1, '2018-04-11 16:47:36'),
(5052, 'ND5G-67-030B(7)', '20.1366', 1, '2018-04-11 16:47:36'),
(5053, 'ND5G-67-030B(7)-1', '20.1375', 1, '2018-04-11 16:47:36'),
(5054, 'ND5H-67-030B(7)', '22.36', 1, '2018-04-11 16:47:36'),
(5055, 'ND5H-67-030B(7)-1', '22.3609', 1, '2018-04-11 16:47:36'),
(5056, 'ND5J-67-030B(7)', '20.6527', 1, '2018-04-11 16:47:36'),
(5057, 'ND5J-67-030B(7)-1', '20.6537', 1, '2018-04-11 16:47:36'),
(5058, 'ND5K-67-030B(7)', '20.568', 1, '2018-04-11 16:47:36'),
(5059, 'ND5K-67-030B(7)-1', '20.5689', 1, '2018-04-11 16:47:36'),
(5060, 'ND5L-67-030B(7)', '22.8761', 1, '2018-04-11 16:47:36'),
(5061, 'ND5L-67-030B(7)-1', '22.8771', 1, '2018-04-11 16:47:36'),
(5062, 'ND5M-67-030B(7)', '22.7914', 1, '2018-04-11 16:47:36'),
(5063, 'ND5M-67-030B(7)-1', '22.7923', 1, '2018-04-11 16:47:36'),
(5064, 'ND5N-67-030B(7)', '18.266', 1, '2018-04-11 16:47:36'),
(5065, 'ND5N-67-030B(7)-1', '18.2669', 1, '2018-04-11 16:47:36'),
(5066, 'ND5P-67-030B(7)', '20.4481', 1, '2018-04-11 16:47:36'),
(5067, 'ND5P-67-030B(7)-1', '20.449', 1, '2018-04-11 16:47:36'),
(5068, 'ND5R-67-030B(7)', '20.9642', 1, '2018-04-11 16:47:36'),
(5069, 'ND5R-67-030B(7)-1', '20.9652', 1, '2018-04-11 16:47:36'),
(5070, 'ND5S-67-030B(7)', '20.8392', 1, '2018-04-11 16:47:36'),
(5071, 'ND5S-67-030B(7)-1', '20.8401', 1, '2018-04-11 16:47:36'),
(5072, 'ND7C-67-030B(7)', '0', 1, '2018-04-11 16:47:36'),
(5073, 'ND7C-67-030B(7)-1', '20.6691', 1, '2018-04-11 16:47:36'),
(5074, 'ND7D-67-030B(7)', '0', 1, '2018-04-11 16:47:36'),
(5075, 'ND7D-67-030B(7)-1', '22.8925', 1, '2018-04-11 16:47:36'),
(5076, 'NE3K-67-030B(7)', '0', 1, '2018-04-11 16:47:36'),
(5077, 'NE3K-67-030B(7)-1', '19.0726', 1, '2018-04-11 16:47:36'),
(5078, 'NE3M-67-030B(7)', '21.3552', 1, '2018-04-11 16:47:36'),
(5079, 'NE3M-67-030B(7)-1', '21.3562', 1, '2018-04-11 16:47:36'),
(5080, 'NE3N-67-030B(7)', '20.6684', 1, '2018-04-11 16:47:36'),
(5081, 'NE3N-67-030B(7)-1', '20.6691', 1, '2018-04-11 16:47:36'),
(5082, 'NE3P-67-030B(7)', '22.8917', 1, '2018-04-11 16:47:36'),
(5083, 'NE3P-67-030B(7)-1', '22.8925', 1, '2018-04-11 16:47:36'),
(5084, 'NE4B-67-030A(7)', '21.4947', 1, '2018-04-11 16:47:36'),
(5085, 'NE4B-67-030A(7)-1', '21.4957', 1, '2018-04-11 16:47:37'),
(5086, 'NE4C-67-030A(7)', '23.7181', 1, '2018-04-11 16:47:37'),
(5087, 'NE4C-67-030A(7)-1', '23.7191', 1, '2018-04-11 16:47:37'),
(5088, 'NE4D-67-030A(7)', '0', 1, '2018-04-11 16:47:37'),
(5089, 'NE4D-67-030A(7)-1', '20.5285', 1, '2018-04-11 16:47:37'),
(5090, 'NE4E-67-030A(7)', '0', 1, '2018-04-11 16:47:37'),
(5091, 'NE4E-67-030A(7)-1', '21.0447', 1, '2018-04-11 16:47:37'),
(5092, 'NE4F-67-030A(7)', '0', 1, '2018-04-11 16:47:37'),
(5093, 'NE4F-67-030A(7)-1', '22.7519', 1, '2018-04-11 16:47:37'),
(5094, 'NE4G-67-030A(7)', '0', 1, '2018-04-11 16:47:37'),
(5095, 'NE4G-67-030A(7)-1', '23.2681', 1, '2018-04-11 16:47:37'),
(5096, 'NE7G-67-030B(7)', '21.4947', 1, '2018-04-11 16:47:37'),
(5097, 'NE7G-67-030B(7)-1', '21.4957', 1, '2018-04-11 16:47:37'),
(5098, 'NE7L-67-030B(7)', '23.7181', 1, '2018-04-11 16:47:37'),
(5099, 'NE7L-67-030B(7)-1', '23.7191', 1, '2018-04-11 16:47:37'),
(5100, 'ND5V-67-030A(5)-2', '18.2606', 1, '2018-04-11 16:47:37'),
(5101, 'ND5W-67-030A(5)-2', '21.3038', 1, '2018-04-11 16:47:37'),
(5102, 'ND6A-67-030A(5)-2', '21.1647', 1, '2018-04-11 16:47:37'),
(5103, 'ND6B-67-030A(5)-2', '20.2217', 1, '2018-04-11 16:47:37'),
(5104, 'ND6F-67-030A(5)-2', '23.5883', 1, '2018-04-11 16:47:37'),
(5105, 'ND6G-67-030A(5)-2', '20.129', 1, '2018-04-11 16:47:37'),
(5106, 'ND6H-67-030A(5)-2', '20.6617', 1, '2018-04-11 16:47:37'),
(5107, 'ND6J-67-030A(5)-2', '22.4135', 1, '2018-04-11 16:47:37'),
(5108, 'ND6K-67-030A(5)-2', '22.9462', 1, '2018-04-11 16:47:37'),
(5109, 'ND6L-67-030A(5)-2', '20.6703', 1, '2018-04-11 16:47:37'),
(5110, 'ND6M-67-030A(5)-2', '22.9462', 1, '2018-04-11 16:47:37'),
(5111, 'ND6N-67-030A(5)-2', '20.5099', 1, '2018-04-11 16:47:37'),
(5112, 'ND6P-67-030A(5)-2', '20.6489', 1, '2018-04-11 16:47:37'),
(5113, 'ND6R-67-030A(5)-2', '21.0426', 1, '2018-04-11 16:47:37'),
(5114, 'ND6T-67-030A(5)-2', '22.9999', 1, '2018-04-11 16:47:37'),
(5115, 'ND6V-67-030A(5)-2', '23.1389', 1, '2018-04-11 16:47:37'),
(5116, 'ND6W-67-030A(5)-2', '19.4755', 1, '2018-04-11 16:47:37'),
(5117, 'ND7A-67-030B(5)-2', '20.0081', 1, '2018-04-11 16:47:38'),
(5118, 'ND7B-67-030B(5)-2', '22.2926', 1, '2018-04-11 16:47:38'),
(5119, 'NE3D-67-030A(5)-2', '23.5326', 1, '2018-04-11 16:47:38'),
(5120, 'NE3E-67-030A(5)-2', '23.5883', 1, '2018-04-11 16:47:38'),
(5121, 'NE3J-67-030A(5)-2', '21.3038', 1, '2018-04-11 16:47:38'),
(5122, 'NE3R-67-030(7)-1', '20.6703', 1, '2018-04-11 16:47:38'),
(5123, 'NE3S-67-030(7)-1', '20.129', 1, '2018-04-11 16:47:38'),
(5124, 'NE3T-67-030(7)-1', '20.6617', 1, '2018-04-11 16:47:38'),
(5125, 'NE3V-67-030(7)-1', '22.4135', 1, '2018-04-11 16:47:38'),
(5126, 'NE3W-67-030(7)-1', '22.9462', 1, '2018-04-11 16:47:38'),
(5127, 'NE4A-67-030(7)-1', '22.9462', 1, '2018-04-11 16:47:38'),
(5128, 'NE5L-67-030A(5)-2', '20.6153', 1, '2018-04-11 16:47:38'),
(5129, 'NE5M-67-030A(5)-2', '21.1647', 1, '2018-04-11 16:47:38'),
(5130, 'N344-67-130(2)-1', '1.3925', 1, '2018-04-11 16:47:38'),
(5131, 'N345-67-130(2)-1', '1.999', 1, '2018-04-11 16:47:38'),
(5132, 'N346-67-130(3)', '1.6975', 1, '2018-04-11 16:47:38'),
(5133, 'N372-67-130(2)-1', '1.999', 1, '2018-04-11 16:47:38'),
(5134, 'ND5G-67-130(2)-1', '1.4008', 1, '2018-04-11 16:47:38'),
(5135, 'ND5H-67-130(4)', '1.0993', 1, '2018-04-11 16:47:38'),
(5136, 'ND5J-67-130(4)', '1.6987', 1, '2018-04-11 16:47:38'),
(5137, 'ND5K-67-130(4)', '1.1018', 1, '2018-04-11 16:47:38'),
(5138, 'ND5N-67-130(2)-1', '1.0965', 1, '2018-04-11 16:47:38'),
(5139, 'ND5P-67-130(2)-1', '1.6935', 1, '2018-04-11 16:47:38'),
(5140, 'ND5R-67-130(2)-1', '1.3959', 1, '2018-04-11 16:47:38'),
(5141, 'ND5S-67-130(2)-1', '1.9941', 1, '2018-04-11 16:47:38'),
(5142, 'ND5V-67-130(2)-1', '0.7955', 1, '2018-04-11 16:47:38'),
(5143, 'ND5W-67-130(2)-1', '1.0965', 1, '2018-04-11 16:47:38'),
(5144, 'ND6A-67-130(2)-1', '1.4041', 1, '2018-04-11 16:47:38'),
(5145, 'ND6B-67-130(2)-1', '1.7052', 1, '2018-04-11 16:47:38'),
(5146, 'ND6C-67-130(2)-1', '1.7104', 1, '2018-04-11 16:47:38'),
(5147, 'ND6D-67-130(2)-1', '2.0115', 1, '2018-04-11 16:47:39'),
(5148, 'ND6E-67-130(2)-1', '1.1005', 1, '2018-04-11 16:47:39'),
(5149, 'ND6F-67-130(2)-1', '2.0094', 1, '2018-04-11 16:47:39'),
(5150, 'ND6P-67-130(2)-1', '2.0184', 1, '2018-04-11 16:47:39'),
(5151, 'ND6T-67-130(2)-1', '1.7099', 1, '2018-04-11 16:47:39'),
(5152, 'ND6V-67-130(2)-1', '2.3174', 1, '2018-04-11 16:47:39'),
(5153, 'NE3D-67-130(2)-1', '1.3971', 1, '2018-04-11 16:47:39'),
(5154, 'NE3E-67-130(2)-1', '1.708', 1, '2018-04-11 16:47:39'),
(5155, 'NE3F-67-130(2)-1', '2.0045', 1, '2018-04-11 16:47:39'),
(5156, 'NE3G-67-130(2)-1', '1.402', 1, '2018-04-11 16:47:39'),
(5157, 'NE3H-67-130(2)-1', '1.6986', 1, '2018-04-11 16:47:39'),
(5158, 'NE3J-67-130(2)-1', '2.306', 1, '2018-04-11 16:47:39'),
(5159, 'NE5L-67-130(2)-1', '1.1018', 1, '2018-04-11 16:47:39'),
(5160, 'NE5M-67-130(2)-1', '1.4028', 1, '2018-04-11 16:47:39'),
(5161, 'NE5N-67-130(2)-1', '1.4097', 1, '2018-04-11 16:47:39'),
(5162, 'NE7G-67-130(2)-1', '2.2955', 1, '2018-04-11 16:47:39'),
(5163, 'N346-67-290(5)-1', '2.0992', 1, '2018-04-11 16:47:39'),
(5164, 'N344-67-290(4)-2', '1.7674', 1, '2018-04-11 16:47:39'),
(5165, 'ND5G-67-290(4)-2', '1.9852', 1, '2018-04-11 16:47:39'),
(5166, 'ND5H-67-290(3)-2', '1.4077', 1, '2018-04-11 16:47:39'),
(5167, 'ND5N-67-290(4)-2', '1.7675', 1, '2018-04-11 16:47:39'),
(5168, 'ND5P-67-290(4)-2', '1.9852', 1, '2018-04-11 16:47:39'),
(5169, 'ND5V-67-290(4)-2', '1.7672', 1, '2018-04-11 16:47:39'),
(5170, 'ND5W-67-290(4)-2', '1.985', 1, '2018-04-11 16:47:39'),
(5171, 'ND6N-67-290(3)-2', '1.8795', 1, '2018-04-11 16:47:39'),
(5172, 'N345-67-290A(1)', '0.448', 1, '2018-04-11 16:47:39'),
(5173, 'ND6C-67-SH0(0)-1', '2.7235', 1, '2018-04-11 16:47:39'),
(5174, 'ND6F-67-SH0(0)-1', '2.7235', 1, '2018-04-11 16:47:39'),
(5175, 'PE31-67-SH0(0)-2', '0.3251', 1, '2018-04-11 16:47:39'),
(5176, 'ND5V-67-SH0A(3)-1', '4.6843', 1, '2018-04-11 16:47:39'),
(5177, '82141-BAD90B-3', '21.8191', 1, '2018-04-11 16:47:40'),
(5178, '82141-BAE00B-3', '24.7897', 1, '2018-04-11 16:47:40'),
(5179, '82141-BAE10B-3', '26.3142', 1, '2018-04-11 16:47:40'),
(5180, '82141-BAE40B-3', '27.7765', 1, '2018-04-11 16:47:40'),
(5181, '82151-B2L10B-1', '3.6296', 1, '2018-04-11 16:47:40'),
(5182, '82151-B2Q10B-1', '4.1607', 1, '2018-04-11 16:47:40'),
(5183, '82151-B2Q30B-1', '4.2612', 1, '2018-04-11 16:47:40'),
(5184, '82152-B2P70A-6', '2.3053', 1, '2018-04-11 16:47:40'),
(5185, '82152-B2P80A-6', '1.671', 1, '2018-04-11 16:47:40'),
(5186, '82152-B2R70A-6', '2.2043', 1, '2018-04-11 16:47:40'),
(5187, '82153-B2380N-6', '0.9797', 1, '2018-04-11 16:47:41'),
(5188, '82171-B2G70A-3', '1.1447', 1, '2018-04-11 16:47:40'),
(5189, '82186-B2170M-1', '0.0977', 1, '2018-04-11 16:47:40'),
(5190, '82219-B2060J-2', '0.2145', 1, '2018-04-11 16:47:40'),
(5191, '82415-B2530K-5', '0.4525', 1, '2018-04-11 16:47:41'),
(5192, '82415-B2551H-4', '0.4628', 1, '2018-04-11 16:47:41'),
(5193, '88648-B2540N-2', '1.8868', 1, '2018-04-11 16:47:41'),
(5194, '88648-B2550N-2', '2.8057', 1, '2018-04-11 16:47:41'),
(5195, '82118-B2P80A-1', '24.4845', 1, '2018-04-11 16:47:40'),
(5196, '82118-B2P90A-1', '26.0136', 1, '2018-04-11 16:47:40'),
(5197, '82118-B2Q00A-1', '26.0522', 1, '2018-04-11 16:47:40'),
(5198, '82118-B2Q20A-1', '27.5813', 1, '2018-04-11 16:47:40'),
(5199, '82146-B2S20A-1', '21.5293', 1, '2018-04-11 16:47:40'),
(5200, '82171-B2B40K-4', '0.5311', 1, '2018-04-11 16:47:40'),
(5201, '82171-B2D30L-1', '0.7555', 1, '2018-04-11 16:47:40'),
(5202, '82171-B2G90-2', '1.0717', 1, '2018-04-11 16:47:41'),
(5203, '82171-B2J00-2', '1.2961', 1, '2018-04-11 16:47:41'),
(5204, '82152-B2Q40N-5', '2.2043', 1, '2018-04-11 16:47:41'),
(5205, '88648-B2650J-5', '2.8059', 1, '2018-04-11 16:47:41'),
(5206, '82118-B2Q30A-1', '26.7131', 1, '2018-04-11 16:47:41'),
(5207, '82118-B2Q90A-1', '28.2715', 1, '2018-04-11 16:47:41'),
(5208, '82118-B2R60A-1', '24.384', 1, '2018-04-11 16:47:41'),
(5209, '82151-B2Q40-3', '4.0606', 1, '2018-04-11 16:47:41'),
(5210, '82151-B2Q50-3', '4.161', 1, '2018-04-11 16:47:41'),
(5211, '82152-B2R90-5', '2.2035', 1, '2018-04-11 16:47:41'),
(5212, '82171-B2E40M-5', '0.6171', 1, '2018-04-11 16:47:41'),
(5213, '82171-B2J10-4', '1.1409', 1, '2018-04-11 16:47:41'),
(5214, '32600-TTA-0000-1', '0', 1, '2018-04-11 16:47:41'),
(5215, '32751-TTA-0003-1', '5.0152', 1, '2018-04-11 16:47:41'),
(5216, '32751-TTA-9003-1', '5.6317', 1, '2018-04-11 16:47:41'),
(5217, '32751-TTA-9103-1', '5.2175', 1, '2018-04-11 16:47:41'),
(5218, '32751-TTA-9203-1', '5.8352', 1, '2018-04-11 16:47:42'),
(5219, '32751-TTA-9303-1', '5.8345', 1, '2018-04-11 16:47:42'),
(5220, '32751-TTA-9403-1', '6.038', 1, '2018-04-11 16:47:42'),
(5221, '32752-TTA-0003-1', '2.4898', 1, '2018-04-11 16:47:42'),
(5222, '32752-TTA-9003-1', '2.6924', 1, '2018-04-11 16:47:42'),
(5223, '32752-TTA-9103-1', '2.6925', 1, '2018-04-11 16:47:42'),
(5224, '32752-TTA-9203-1', '2.8951', 1, '2018-04-11 16:47:42'),
(5225, '32753-TTA-0001-3', '1.7025', 1, '2018-04-11 16:47:42'),
(5226, '32753-TTA-9001-3', '0.71', 1, '2018-04-11 16:47:42'),
(5227, '32753-TTA-9102', '3.6257', 1, '2018-04-11 16:47:42'),
(5228, '32754-TTA-0002', '3.7238', 1, '2018-04-11 16:47:42'),
(5229, '32754-TTA-9001-3', '0.7099', 1, '2018-04-11 16:47:42'),
(5230, '32155-TTA-0002-3', '0.5428', 1, '2018-04-11 16:47:42'),
(5231, '32155-TTA-9003-2', '1.3743', 1, '2018-04-11 16:47:42'),
(5232, '32155-TTA-9102-3', '0.9595', 1, '2018-04-11 16:47:42'),
(5233, '32155-TTA-9203-2', '1.7837', 1, '2018-04-11 16:47:42'),
(5234, '32155-TTA-9302-3', '0.3106', 1, '2018-04-11 16:47:42'),
(5235, '32155-TTA-9403-2', '1.1421', 1, '2018-04-11 16:47:42'),
(5236, '32109-TTA-0003-2', '1.9089', 1, '2018-04-11 16:47:42'),
(5237, '32109-TTA-9003-2', '2.2395', 1, '2018-04-11 16:47:42'),
(5238, '32109-TTA-9103-2', '2.237', 1, '2018-04-11 16:47:42'),
(5239, '32109-TTA-9203-2', '1.9063', 1, '2018-04-11 16:47:42'),
(5240, '32109-TTA-9303-2', '1.5886', 1, '2018-04-11 16:47:42'),
(5241, '32109-TTA-9403-2', '1.9192', 1, '2018-04-11 16:47:42'),
(5242, '32601-TTA-0000-1', '0', 1, '2018-04-11 16:47:43'),
(5243, '32610-TTA-0001-1', '0', 1, '2018-04-11 16:47:43'),
(5244, '32601-TXA-0000-1', '0', 1, '2018-04-11 16:47:43'),
(5245, '32109-TTE-0002', '2.3908', 1, '2018-04-11 16:47:43'),
(5246, '32109-TTE-J002', '2.7263', 1, '2018-04-11 16:47:43'),
(5247, '32109-TTE-J102', '2.3882', 1, '2018-04-11 16:47:43'),
(5248, '32109-TTE-J202', '2.7237', 1, '2018-04-11 16:47:43'),
(5249, 'MLD-TTA-284', '0.1338', 1, '2018-04-11 16:47:43'),
(5250, '32600-TAD-0001-1', '0', 1, '2018-04-11 16:47:43'),
(5251, '32600-TAA-0001-1', '0', 1, '2018-04-11 16:47:43'),
(5252, '32107-TAA-9012-3', '24.2716', 1, '2018-04-11 16:47:43'),
(5253, '32107-TAA-9811-3', '9.5321', 1, '2018-04-11 16:47:43'),
(5254, '32107-TAA-9902-3', '17.1198', 1, '2018-04-11 16:47:43'),
(5255, '32107-TAA-J011-3', '12.1085', 1, '2018-04-11 16:47:43'),
(5256, '32107-TAA-J112-3', '17.1201', 1, '2018-04-11 16:47:43'),
(5257, '32107-TAA-J212-3', '19.8393', 1, '2018-04-11 16:47:43'),
(5258, '32107-TAA-J312-3', '19.4434', 1, '2018-04-11 16:47:43'),
(5259, '32107-TAA-J412-3', '21.6126', 1, '2018-04-11 16:47:43'),
(5260, '32107-TAA-J512-3', '24.7096', 1, '2018-04-11 16:47:43'),
(5261, '32107-TAA-J602-3', '27.3658', 1, '2018-04-11 16:47:43'),
(5262, '32107-TAA-J702-3', '26.898', 1, '2018-04-11 16:47:43'),
(5263, '32107-TAA-J802-3', '25.0964', 1, '2018-04-11 16:47:43'),
(5264, '32107-TAA-J902-3', '25.66', 1, '2018-04-11 16:47:43'),
(5265, '32107-TAA-L812-3', '20.1285', 1, '2018-04-11 16:47:44'),
(5266, '32107-TAA-L912-3', '21.9994', 1, '2018-04-11 16:47:44'),
(5267, '32107-TAA-N012-3', '26.7562', 1, '2018-04-11 16:47:44'),
(5268, '32107-TAA-N112-3', '27.1432', 1, '2018-04-11 16:47:44'),
(5269, '32107-TAA-N212-3', '29.8545', 1, '2018-04-11 16:47:44'),
(5270, '32107-TAA-N312-3', '29.4165', 1, '2018-04-11 16:47:44'),
(5271, '32107-TAA-N412-3', '30.3829', 1, '2018-04-11 16:47:44'),
(5272, '32107-TAA-N512-3', '28.1135', 1, '2018-04-11 16:47:44'),
(5273, '32107-TAA-N612-3', '27.6755', 1, '2018-04-11 16:47:44'),
(5274, '32107-TAA-N712-3', '30.2415', 1, '2018-04-11 16:47:44'),
(5275, '32107-TAA-N812-3', '26.7864', 1, '2018-04-11 16:47:44'),
(5276, '32107-TAA-P012-3', '23.8323', 1, '2018-04-11 16:47:44'),
(5277, '32107-TAA-U011-3', '14.4672', 1, '2018-04-11 16:47:44'),
(5278, '32107-TAA-U112-3', '18.6777', 1, '2018-04-11 16:47:44'),
(5279, '32107-TAA-Z112-3', '22.9271', 1, '2018-04-11 16:47:44'),
(5280, '32107-TAA-Z212-3', '26.0473', 1, '2018-04-11 16:47:44'),
(5281, '32107-TAA-Z412-3', '24.8776', 1, '2018-04-11 16:47:44'),
(5282, '32107-TAB-9611-3', '16.4644', 1, '2018-04-11 16:47:44'),
(5283, '32107-TAB-9712-3', '21.0403', 1, '2018-04-11 16:47:44'),
(5284, '32107-TAB-9812-3', '26.7089', 1, '2018-04-11 16:47:44'),
(5285, '32107-TAB-9902-3', '27.0932', 1, '2018-04-11 16:47:44'),
(5286, '32107-TAB-J011-3', '16.0265', 1, '2018-04-11 16:47:44'),
(5287, '32107-TAB-J112-3', '21.038', 1, '2018-04-11 16:47:44'),
(5288, '32107-TAB-J212-3', '23.7573', 1, '2018-04-11 16:47:45'),
(5289, '32107-TAB-J312-3', '23.3614', 1, '2018-04-11 16:47:45'),
(5290, '32107-TAB-J412-3', '25.5307', 1, '2018-04-11 16:47:45'),
(5291, '32107-TAB-J512-3', '28.6274', 1, '2018-04-11 16:47:45'),
(5292, '32107-TAB-J602-3', '29.0142', 1, '2018-04-11 16:47:45'),
(5293, '32107-TAB-J702-3', '30.333', 1, '2018-04-11 16:47:45'),
(5294, '32107-TAB-J802-3', '29.8651', 1, '2018-04-11 16:47:45'),
(5295, '32107-TAB-J902-3', '28.1892', 1, '2018-04-11 16:47:45'),
(5296, '32107-TAB-L612-3', '22.9033', 1, '2018-04-11 16:47:45'),
(5297, '32107-TAB-L712-3', '26.8449', 1, '2018-04-11 16:47:45'),
(5298, '32107-TAB-L912-3', '28.5762', 1, '2018-04-11 16:47:45'),
(5299, '32107-TAB-N012-3', '29.8047', 1, '2018-04-11 16:47:45'),
(5300, '32107-TAB-N112-3', '29.3667', 1, '2018-04-11 16:47:45'),
(5301, '32107-TAB-N212-3', '29.0143', 1, '2018-04-11 16:47:45'),
(5302, '32107-TAB-N312-3', '28.5762', 1, '2018-04-11 16:47:45'),
(5303, '32107-TAB-N412-3', '30.333', 1, '2018-04-11 16:47:45'),
(5304, '32107-TAB-N512-3', '30.1916', 1, '2018-04-11 16:47:45'),
(5305, '32107-TAB-N612-3', '29.7536', 1, '2018-04-11 16:47:45'),
(5306, '32107-TAA-W012-2', '23.6119', 1, '2018-04-11 16:47:45'),
(5307, '32107-TAA-W112-2', '23.4872', 1, '2018-04-11 16:47:45'),
(5308, '32107-TAA-W212-2', '27.8056', 1, '2018-04-11 16:47:45'),
(5309, '32107-TAA-W312-2', '27.4619', 1, '2018-04-11 16:47:45'),
(5310, '32107-TAA-W612-2', '30.6037', 1, '2018-04-11 16:47:45'),
(5311, '32107-TAA-W712-2', '30.479', 1, '2018-04-11 16:47:46'),
(5312, '32107-TAA-Z902-2', '23.999', 1, '2018-04-11 16:47:46'),
(5313, '32107-TAB-W012-2', '26.5792', 1, '2018-04-11 16:47:46'),
(5314, '32107-TAB-W112-2', '26.4547', 1, '2018-04-11 16:47:46'),
(5315, '32107-TAB-W212-2', '27.5368', 1, '2018-04-11 16:47:46'),
(5316, '32107-TAB-W312-2', '30.4292', 1, '2018-04-11 16:47:46'),
(5317, '32107-TAB-W512-2', '33.5709', 1, '2018-04-11 16:47:46'),
(5318, '32107-TAD-0003-4', '22.9944', 1, '2018-04-11 16:47:46'),
(5319, '32107-TAD-9303-4', '23.7788', 1, '2018-04-11 16:47:46'),
(5320, '32107-TAD-9403-4', '23.9787', 1, '2018-04-11 16:47:46'),
(5321, '32107-TAD-9703-4', '25.9173', 1, '2018-04-11 16:47:46'),
(5322, '32107-TAD-9803-4', '26.1172', 1, '2018-04-11 16:47:46'),
(5323, '32107-TAD-F103-4', '26.4786', 1, '2018-04-11 16:47:46'),
(5324, '32107-TAD-F203-4', '26.6787', 1, '2018-04-11 16:47:46'),
(5325, '32107-TAD-F703-4', '26.4744', 1, '2018-04-11 16:47:46'),
(5326, '32107-TAD-F803-4', '26.6745', 1, '2018-04-11 16:47:46'),
(5327, '32107-TAD-F903-4', '28.6185', 1, '2018-04-11 16:47:46'),
(5328, '32107-TAD-J003-4', '23.4217', 1, '2018-04-11 16:47:46'),
(5329, '32107-TAD-J203-4', '26.5488', 1, '2018-04-11 16:47:46'),
(5330, '32107-TAD-J403-4', '27.8349', 1, '2018-04-11 16:47:46'),
(5331, '32107-TAD-J503-4', '28.0349', 1, '2018-04-11 16:47:46'),
(5332, '32107-TAD-K003-4', '28.8186', 1, '2018-04-11 16:47:46'),
(5333, '32107-TAD-N303-4', '26.9059', 1, '2018-04-11 16:47:46'),
(5334, '32107-TAD-N403-4', '27.1059', 1, '2018-04-11 16:47:46'),
(5335, '32107-TAD-N503-4', '26.9017', 1, '2018-04-11 16:47:46'),
(5336, '32107-TAD-N603-4', '27.1017', 1, '2018-04-11 16:47:47'),
(5337, '32107-TAD-N903-4', '29.0458', 1, '2018-04-11 16:47:47'),
(5338, '32107-TAD-Z003-4', '29.2459', 1, '2018-04-11 16:47:47'),
(5339, '32107-TAD-Z403-4', '26.5446', 1, '2018-04-11 16:47:47'),
(5340, '32105-TAA-W002-3', '1.5559', 1, '2018-04-11 16:47:47'),
(5341, '32105-TAA-W102-3', '1.7486', 1, '2018-04-11 16:47:47'),
(5342, '32106-TAA-W002-4', '5.6339', 1, '2018-04-11 16:47:47'),
(5343, '32106-TAA-W102-4', '10.7893', 1, '2018-04-11 16:47:47'),
(5344, '32106-TAA-W201-5', '5.6839', 1, '2018-04-11 16:47:47'),
(5345, '32171-TAA-0002-2', '0.189', 1, '2018-04-11 16:47:47'),
(5346, '32109-TAA-0100-5', '2.3182', 1, '2018-04-11 16:47:47'),
(5347, '32109-TAA-9200-5', '2.2114', 1, '2018-04-11 16:47:47'),
(5348, '32109-TAA-9410-5', '2.6386', 1, '2018-04-11 16:47:47'),
(5349, '32109-TAA-9510-5', '2.3182', 1, '2018-04-11 16:47:47'),
(5350, '32109-TAA-9010-4', '0.942', 1, '2018-04-11 16:47:47'),
(5351, '32109-TAA-9110-4', '1.2621', 1, '2018-04-11 16:47:47'),
(5352, '32109-TAA-9300-4', '1.5824', 1, '2018-04-11 16:47:47'),
(5353, '32109-TAA-W010-4', '1.6892', 1, '2018-04-11 16:47:47'),
(5354, '32109-TAA-W110-4', '1.3691', 1, '2018-04-11 16:47:47'),
(5355, '28950-59F-0001-1', '1.2555', 1, '2018-04-11 16:47:47'),
(5356, '32601-TAD-0000-3', '0', 1, '2018-04-11 16:47:47'),
(5357, '32601-TAA-0002', '0', 1, '2018-04-11 16:47:47'),
(5358, '32751-TAA-0100-4', '5.8372', 1, '2018-04-11 16:47:47'),
(5359, '32751-TAA-9010-4', '4.7076', 1, '2018-04-11 16:47:47'),
(5360, '32751-TAA-9100-4', '5.0175', 1, '2018-04-11 16:47:48'),
(5361, '32751-TAA-9210-4', '4.9112', 1, '2018-04-11 16:47:48'),
(5362, '32751-TAA-9310-4', '5.9346', 1, '2018-04-11 16:47:48'),
(5363, '32751-TAA-9400-4', '4.7104', 1, '2018-04-11 16:47:48'),
(5364, '32751-TAA-9500-4', '5.221', 1, '2018-04-11 16:47:48'),
(5365, '32751-TAA-U010-4', '4.6042', 1, '2018-04-11 16:47:48'),
(5366, '32751-TAA-U110-4', '5.5221', 1, '2018-04-11 16:47:48'),
(5367, '32751-TAD-0000-4', '5.6337', 1, '2018-04-11 16:47:48'),
(5368, '32752-TAA-0100-4', '2.8884', 1, '2018-04-11 16:47:48'),
(5369, '32752-TAA-9110-4', '1.6522', 1, '2018-04-11 16:47:48'),
(5370, '32752-TAA-9210-4', '1.8566', 1, '2018-04-11 16:47:48'),
(5371, '32752-TAA-9310-4', '2.9857', 1, '2018-04-11 16:47:48'),
(5372, '32752-TAA-9400-4', '2.0662', 1, '2018-04-11 16:47:48'),
(5373, '32752-TAA-9500-4', '2.2706', 1, '2018-04-11 16:47:48'),
(5374, '32752-TAA-U010-4', '2.684', 1, '2018-04-11 16:47:48'),
(5375, '32752-TAA-U100-4', '1.8645', 1, '2018-04-11 16:47:48'),
(5376, '32610-TAA-0002', '0', 1, '2018-04-11 16:47:48'),
(5377, '32170-TAA-0000-3', '0.4452', 1, '2018-04-11 16:47:48'),
(5378, '32170-TAB-0001-5', '0.5551', 1, '2018-04-11 16:47:48'),
(5379, '32119-TAA-0200-3', '2.519', 1, '2018-04-11 16:47:48'),
(5380, '32119-TAA-9020-3', '2.82', 1, '2018-04-11 16:47:48'),
(5381, '32119-TAA-9320-3', '2.519', 1, '2018-04-11 16:47:49'),
(5382, '32119-TAA-W200-3', '2.4115', 1, '2018-04-11 16:47:49'),
(5383, '32119-TAA-9110-4', '1.0804', 1, '2018-04-11 16:47:49'),
(5384, '32119-TAA-9210-4', '1.3738', 1, '2018-04-11 16:47:49'),
(5385, '32119-TAA-9400-4', '1.6754', 1, '2018-04-11 16:47:49'),
(5386, '32119-TAA-W010-4', '2.0705', 1, '2018-04-11 16:47:49'),
(5387, '32119-TAA-W110-4', '1.7771', 1, '2018-04-11 16:47:49'),
(5388, '32112-TLA-D003-4', '0.6078', 1, '2018-04-11 16:47:49'),
(5389, '32112-TLA-D003-5', '0.6078', 1, '2018-04-11 16:47:49'),
(5390, '32112-TLY-H000-1', '1.2464', 1, '2018-04-11 16:47:49'),
(5391, '32112-TLY-H000-2', '1.2464', 1, '2018-04-11 16:47:49'),
(5392, '32112-TMB-H000-1', '1.2466', 1, '2018-04-11 16:47:49'),
(5393, '32112-TMB-H000-2', '1.2466', 1, '2018-04-11 16:47:49'),
(5394, '32112-TMC-T003-4', '1.2451', 1, '2018-04-11 16:47:49'),
(5395, '32112-TMC-T003-5', '1.2451', 1, '2018-04-11 16:47:49'),
(5396, '32112-TMC-T103-4', '1.2463', 1, '2018-04-11 16:47:49'),
(5397, '32112-TMC-T103-5', '1.2463', 1, '2018-04-11 16:47:49'),
(5398, '32112-TMC-T203-4', '1.2465', 1, '2018-04-11 16:47:49'),
(5399, '32112-TMC-T203-5', '1.2465', 1, '2018-04-11 16:47:49'),
(5400, '32112-TNY-E000', '1.1984', 1, '2018-04-11 16:47:49'),
(5401, '32112-TNY-E000-1', '1.1984', 1, '2018-04-11 16:47:49'),
(5402, '32600-TLY-H001-3', '0', 1, '2018-04-11 16:47:49'),
(5403, '32600-TLY-H001-4', '0', 1, '2018-04-11 16:47:49'),
(5404, '32600-TLY-H100-3', '0', 1, '2018-04-11 16:47:49'),
(5405, '32600-TLY-H100-4', '0', 1, '2018-04-11 16:47:49'),
(5406, '32600-TNY-E001-1', '0', 1, '2018-04-11 16:47:49'),
(5407, '32600-TNY-E001-2', '0', 1, '2018-04-11 16:47:49'),
(5408, '32600-TNY-G000-1', '0', 1, '2018-04-11 16:47:50'),
(5409, '32600-TNY-G000-2', '0', 1, '2018-04-11 16:47:50'),
(5410, '32600-TNY-J000-1', '0', 1, '2018-04-11 16:47:50'),
(5411, '32600-TNY-J000-2', '0', 1, '2018-04-11 16:47:50'),
(5412, '32131-TLA-D010-5', '1.1932', 1, '2018-04-11 16:47:50'),
(5413, '32131-TLA-D010-6', '1.1932', 1, '2018-04-11 16:47:50'),
(5414, '32131-TLA-M010-5', '1.4825', 1, '2018-04-11 16:47:50'),
(5415, '32131-TLA-M010-6', '1.4825', 1, '2018-04-11 16:47:50');
INSERT INTO `eff_product_st` (`ID`, `product_no`, `st`, `updated_by`, `last_update`) VALUES
(5416, '32131-TLA-R006-1', '1.1947', 1, '2018-04-11 16:47:50'),
(5417, '32131-TLA-R006-2', '1.1947', 1, '2018-04-11 16:47:50'),
(5418, '32131-TLY-H001-1', '1.1954', 1, '2018-04-11 16:47:50'),
(5419, '32131-TLY-H001-2', '1.1954', 1, '2018-04-11 16:47:50'),
(5420, '32131-TNY-E000-2', '1.4905', 1, '2018-04-11 16:47:50'),
(5421, '32131-TNY-E000-3', '1.4905', 1, '2018-04-11 16:47:50'),
(5422, '32109-TLA-A006-6', '2.6329', 1, '2018-04-11 16:47:50'),
(5423, '32109-TLA-A006-7', '2.6329', 1, '2018-04-11 16:47:50'),
(5424, '32109-TLA-A106-6', '3.837', 1, '2018-04-11 16:47:50'),
(5425, '32109-TLA-A106-7', '3.837', 1, '2018-04-11 16:47:50'),
(5426, '32109-TLC-A003-6', '2.3315', 1, '2018-04-11 16:47:50'),
(5427, '32109-TLC-A003-7', '2.3315', 1, '2018-04-11 16:47:50'),
(5428, '32109-TLE-R003-6', '1.932', 1, '2018-04-11 16:47:50'),
(5429, '32109-TLE-R003-7', '1.932', 1, '2018-04-11 16:47:50'),
(5430, '32109-TLY-H003-6', '3.4378', 1, '2018-04-11 16:47:50'),
(5431, '32109-TLY-H003-7', '3.4378', 1, '2018-04-11 16:47:50'),
(5432, '32109-TMM-F000-3', '2.6329', 1, '2018-04-11 16:47:51'),
(5433, '32109-TMM-F000-4', '2.6329', 1, '2018-04-11 16:47:51'),
(5434, '32109-TMS-F000-3', '2.3315', 1, '2018-04-11 16:47:51'),
(5435, '32109-TMS-F000-4', '2.3315', 1, '2018-04-11 16:47:51'),
(5436, '32109-TNY-J000-1', '2.3315', 1, '2018-04-11 16:47:51'),
(5437, '32109-TNY-J000-2', '2.3315', 1, '2018-04-11 16:47:51'),
(5438, '32109-TNY-J100-1', '2.6329', 1, '2018-04-11 16:47:51'),
(5439, '32109-TNY-J100-2', '2.6329', 1, '2018-04-11 16:47:51'),
(5440, '32109-TNY-J200-1', '3.837', 1, '2018-04-11 16:47:51'),
(5441, '32109-TNY-J200-2', '3.837', 1, '2018-04-11 16:47:51'),
(5442, '32109-TNY-J300-1', '1.932', 1, '2018-04-11 16:47:51'),
(5443, '32109-TNY-J300-2', '1.932', 1, '2018-04-11 16:47:51'),
(5444, '32109-TPB-E001-1', '2.2334', 1, '2018-04-11 16:47:51'),
(5445, '32109-TPB-E001-2', '2.2334', 1, '2018-04-11 16:47:51'),
(5446, '32603-TMB-H000-3', '0', 1, '2018-04-11 16:47:51'),
(5447, '53680-TLA-A500-3', '0.2908', 1, '2018-04-11 16:47:51'),
(5448, '53680-TLA-A500-4', '0.2908', 1, '2018-04-11 16:47:51'),
(5449, '53680-TMC-T010-3', '0.2939', 1, '2018-04-11 16:47:51'),
(5450, '53680-TMC-T010-4', '0.2939', 1, '2018-04-11 16:47:51'),
(5451, '28950-5TA-E000', '1.2587', 1, '2018-04-11 16:47:51'),
(5452, '28950-5TB-H001', '1.2601', 1, '2018-04-11 16:47:51'),
(5453, '32119-TLA-A006-6', '1.8928', 1, '2018-04-11 16:47:51'),
(5454, '32119-TLA-A006-7', '1.8928', 1, '2018-04-11 16:47:51'),
(5455, '32119-TLY-H003-6', '1.582', 1, '2018-04-11 16:47:51'),
(5456, '32119-TLY-H003-7', '1.582', 1, '2018-04-11 16:47:51'),
(5457, '32119-TMM-F000-4', '1.8928', 1, '2018-04-11 16:47:52'),
(5458, '32119-TMM-F000-5', '1.8928', 1, '2018-04-11 16:47:52'),
(5459, '32119-TNY-J002', '1.8937', 1, '2018-04-11 16:47:52'),
(5460, '32119-TNY-J002-1', '1.8937', 1, '2018-04-11 16:47:52'),
(5461, '32119-TNY-J101', '1.8926', 1, '2018-04-11 16:47:52'),
(5462, '32119-TNY-J101-1', '1.8926', 1, '2018-04-11 16:47:52'),
(5463, '32129-TLA-A006-5', '1.9378', 1, '2018-04-11 16:47:52'),
(5464, '32129-TLA-A006-6', '1.9378', 1, '2018-04-11 16:47:52'),
(5465, '32129-TLA-A106-5', '1.4208', 1, '2018-04-11 16:47:52'),
(5466, '32129-TLA-A106-6', '1.4208', 1, '2018-04-11 16:47:52'),
(5467, '32129-TLC-A006-5', '1.73', 1, '2018-04-11 16:47:52'),
(5468, '32129-TLC-A006-6', '1.73', 1, '2018-04-11 16:47:52'),
(5469, '32129-TLE-R002-5', '1.4186', 1, '2018-04-11 16:47:52'),
(5470, '32129-TLE-R002-6', '1.4186', 1, '2018-04-11 16:47:52'),
(5471, '32129-TMC-U004-5', '1.9325', 1, '2018-04-11 16:47:52'),
(5472, '32129-TMC-U004-6', '1.9325', 1, '2018-04-11 16:47:52'),
(5473, '32129-TMF-Z003-5', '1.4169', 1, '2018-04-11 16:47:52'),
(5474, '32129-TMF-Z003-6', '1.4169', 1, '2018-04-11 16:47:52'),
(5475, '32129-TMK-P002-5', '1.7253', 1, '2018-04-11 16:47:52'),
(5476, '32129-TMK-P002-6', '1.7253', 1, '2018-04-11 16:47:52'),
(5477, '32129-TMM-F000-2', '1.9378', 1, '2018-04-11 16:47:52'),
(5478, '32129-TMM-F000-3', '1.9378', 1, '2018-04-11 16:47:52'),
(5479, '32129-TMM-F100-2', '1.4208', 1, '2018-04-11 16:47:52'),
(5480, '32129-TMM-F100-3', '1.4208', 1, '2018-04-11 16:47:52'),
(5481, '32129-TMS-F000-2', '1.73', 1, '2018-04-11 16:47:52'),
(5482, '32129-TMS-F000-3', '1.73', 1, '2018-04-11 16:47:53'),
(5483, '32129-TNY-J002', '1.9316', 1, '2018-04-11 16:47:53'),
(5484, '32129-TNY-J002-1', '1.9316', 1, '2018-04-11 16:47:53'),
(5485, '32129-TNY-J102', '1.4162', 1, '2018-04-11 16:47:53'),
(5486, '32129-TNY-J102-1', '1.4162', 1, '2018-04-11 16:47:53'),
(5487, '32129-TNY-J201', '1.7299', 1, '2018-04-11 16:47:53'),
(5488, '32129-TNY-J201-1', '1.7299', 1, '2018-04-11 16:47:53'),
(5489, '32129-TNY-J301', '1.9377', 1, '2018-04-11 16:47:53'),
(5490, '32129-TNY-J301-1', '1.9377', 1, '2018-04-11 16:47:53'),
(5491, '32129-TNY-J401', '1.4207', 1, '2018-04-11 16:47:53'),
(5492, '32129-TNY-J401-1', '1.4207', 1, '2018-04-11 16:47:53'),
(5493, '32129-TNY-J501', '1.7252', 1, '2018-04-11 16:47:53'),
(5494, '32129-TNY-J501-1', '1.7252', 1, '2018-04-11 16:47:53'),
(5495, '32129-TNY-J601', '1.9324', 1, '2018-04-11 16:47:53'),
(5496, '32129-TNY-J601-1', '1.9324', 1, '2018-04-11 16:47:53'),
(5497, '32129-TNY-J701', '1.4185', 1, '2018-04-11 16:47:53'),
(5498, '32129-TNY-J701-1', '1.4185', 1, '2018-04-11 16:47:53'),
(5499, '32129-TPB-E002', '1.6263', 1, '2018-04-11 16:47:53'),
(5500, '32129-TPB-E002-1', '1.6263', 1, '2018-04-11 16:47:53'),
(5501, '82161-13F11A-1', '9.1839', 1, '2018-04-11 16:47:53'),
(5502, '82161-13F11A-2', '0', 1, '2018-04-11 16:47:53'),
(5503, '82161-13G11A-1', '11.8729', 1, '2018-04-11 16:47:54'),
(5504, '82161-13G11A-2', '11.8729', 1, '2018-04-11 16:47:54'),
(5505, '82161-13G21A-1', '13.1253', 1, '2018-04-11 16:47:54'),
(5506, '82161-13G21A-2', '13.1253', 1, '2018-04-11 16:47:54'),
(5507, '82161-1AF11A-1', '9.7834', 1, '2018-04-11 16:47:54'),
(5508, '82161-1AF11A-2', '9.7834', 1, '2018-04-11 16:47:54'),
(5509, '82161-1AG11A-1', '12.1257', 1, '2018-04-11 16:47:54'),
(5510, '82161-1AG11A-2', '12.1257', 1, '2018-04-11 16:47:54'),
(5511, '82161-1AG21A-1', '13.6438', 1, '2018-04-11 16:47:54'),
(5512, '82161-1AG21A-2', '13.6438', 1, '2018-04-11 16:47:54'),
(5513, '82161-13G31A-1', '9.6499', 1, '2018-04-11 16:47:54'),
(5514, '82161-13G31A-2', '0', 1, '2018-04-11 16:47:54'),
(5515, '82161-13G41A-1', '12.3414', 1, '2018-04-11 16:47:54'),
(5516, '82161-13G41A-2', '12.3414', 1, '2018-04-11 16:47:54'),
(5517, '82161-13G51A-1', '13.5964', 1, '2018-04-11 16:47:54'),
(5518, '82161-13G51A-2', '0', 1, '2018-04-11 16:47:54'),
(5519, '82161-1AG31A-1', '9.8736', 1, '2018-04-11 16:47:54'),
(5520, '82161-1AG31A-2', '0', 1, '2018-04-11 16:47:54'),
(5521, '82161-1AG41A-1', '12.591', 1, '2018-04-11 16:47:54'),
(5522, '82161-1AG41A-2', '12.591', 1, '2018-04-11 16:47:54'),
(5523, '82161-1AG51A-1', '14.112', 1, '2018-04-11 16:47:54'),
(5524, '82161-1AG51A-2', '0', 1, '2018-04-11 16:47:54'),
(5525, '82161-13G61A-1', '13.2199', 1, '2018-04-11 16:47:55'),
(5526, '82161-13G61A-2', '13.2199', 1, '2018-04-11 16:47:55'),
(5527, '82161-13G71-1', '13.9268', 1, '2018-04-11 16:47:55'),
(5528, '82161-13G81A-1', '14.8266', 1, '2018-04-11 16:47:55'),
(5529, '82161-13G81A-2', '14.8266', 1, '2018-04-11 16:47:55'),
(5530, '82161-13G91A-1', '15.511', 1, '2018-04-11 16:47:55'),
(5531, '82161-13G91A-2', '15.511', 1, '2018-04-11 16:47:55'),
(5532, '82161-1AG61A-1', '13.4755', 1, '2018-04-11 16:47:55'),
(5533, '82161-1AG61A-2', '13.4755', 1, '2018-04-11 16:47:55'),
(5534, '82161-1AG71-1', '14.1625', 1, '2018-04-11 16:47:55'),
(5535, '82161-1AG81A-1', '15.3488', 1, '2018-04-11 16:47:55'),
(5536, '82161-1AG81A-2', '15.3488', 1, '2018-04-11 16:47:55'),
(5537, '82161-1AG91A-1', '16.0168', 1, '2018-04-11 16:47:55'),
(5538, '82161-1AG91A-2', '0', 1, '2018-04-11 16:47:55'),
(5539, '82182-12020A', '1.3814', 1, '2018-04-11 16:47:55'),
(5540, '82182-12030A', '1.3824', 1, '2018-04-11 16:47:55'),
(5541, '82153-60580F', '2.17', 1, '2018-04-11 16:47:55'),
(5542, '82153-60580F-1', '2.17', 1, '2018-04-11 16:47:55'),
(5543, '82153-60590F', '2.3651', 1, '2018-04-11 16:47:55'),
(5544, '82153-60590F-1', '2.3651', 1, '2018-04-11 16:47:55'),
(5545, '82153-60600F', '2.3786', 1, '2018-04-11 16:47:55'),
(5546, '82153-60600F-1', '2.3786', 1, '2018-04-11 16:47:55'),
(5547, '82153-60610D', '2.3718', 1, '2018-04-11 16:47:55'),
(5548, '82153-60610F', '2.3718', 1, '2018-04-11 16:47:55'),
(5549, '82153-60620F', '2.5697', 1, '2018-04-11 16:47:56'),
(5550, '82153-60620G', '2.5697', 1, '2018-04-11 16:47:56'),
(5551, '82153-60630F', '2.769', 1, '2018-04-11 16:47:56'),
(5552, '82153-60630F-1', '2.769', 1, '2018-04-11 16:47:56'),
(5553, '82153-60640F', '2.5601', 1, '2018-04-11 16:47:56'),
(5554, '82153-60640F-1', '2.5601', 1, '2018-04-11 16:47:56'),
(5555, '82153-60650F', '2.365', 1, '2018-04-11 16:47:56'),
(5556, '82153-60650F-1', '2.365', 1, '2018-04-11 16:47:56'),
(5557, '82153-60660F', '1.2966', 1, '2018-04-11 16:47:56'),
(5558, '82153-60660F-1', '1.2966', 1, '2018-04-11 16:47:56'),
(5559, '82153-60670F', '1.7774', 1, '2018-04-11 16:47:56'),
(5560, '82153-60670F-1', '1.7774', 1, '2018-04-11 16:47:56'),
(5561, '82153-60690', '2.1814', 1, '2018-04-11 16:47:56'),
(5562, '82153-60690-1', '2.1814', 1, '2018-04-11 16:47:56'),
(5563, '82153-60700', '2.5718', 1, '2018-04-11 16:47:56'),
(5564, '82153-60700-1', '0', 1, '2018-04-11 16:47:56'),
(5565, '82153-60710', '0', 1, '2018-04-11 16:47:56'),
(5566, '82153-60720', '0', 1, '2018-04-11 16:47:56'),
(5567, '82154-60400F-1', '2.1702', 1, '2018-04-11 16:47:56'),
(5568, '82154-60400F-2', '2.1702', 1, '2018-04-11 16:47:56'),
(5569, '82154-60410F-1', '2.3653', 1, '2018-04-11 16:47:56'),
(5570, '82154-60410F-2', '2.3653', 1, '2018-04-11 16:47:56'),
(5571, '82154-60420F-1', '2.3788', 1, '2018-04-11 16:47:56'),
(5572, '82154-60420F-2', '2.3788', 1, '2018-04-11 16:47:56'),
(5573, '82154-60430D-1', '2.371', 1, '2018-04-11 16:47:57'),
(5574, '82154-60430F', '2.371', 1, '2018-04-11 16:47:57'),
(5575, '82154-60440F-1', '2.569', 1, '2018-04-11 16:47:57'),
(5576, '82154-60440G', '2.569', 1, '2018-04-11 16:47:57'),
(5577, '82154-60450F-1', '2.7692', 1, '2018-04-11 16:47:57'),
(5578, '82154-60450F-2', '2.7692', 1, '2018-04-11 16:47:57'),
(5579, '82154-60460F-1', '2.5603', 1, '2018-04-11 16:47:57'),
(5580, '82154-60460F-2', '2.5603', 1, '2018-04-11 16:47:57'),
(5581, '82154-60470F-1', '2.3653', 1, '2018-04-11 16:47:57'),
(5582, '82154-60470F-2', '2.3653', 1, '2018-04-11 16:47:57'),
(5583, '82154-60480F-1', '1.2966', 1, '2018-04-11 16:47:57'),
(5584, '82154-60480F-2', '1.2966', 1, '2018-04-11 16:47:57'),
(5585, '82154-60490F-1', '1.7777', 1, '2018-04-11 16:47:57'),
(5586, '82154-60490F-2', '1.7777', 1, '2018-04-11 16:47:57'),
(5587, '82154-60530-1', '2.1816', 1, '2018-04-11 16:47:57'),
(5588, '82154-60530-2', '2.1816', 1, '2018-04-11 16:47:57'),
(5589, '82154-60540-1', '2.572', 1, '2018-04-11 16:47:57'),
(5590, '82154-60540-2', '0', 1, '2018-04-11 16:47:57'),
(5591, '82154-60550', '0', 1, '2018-04-11 16:47:57'),
(5592, '82154-60560', '0', 1, '2018-04-11 16:47:57'),
(5593, '33880-64P00(6)-P', '0', 1, '2018-04-11 16:47:57'),
(5594, '33880-64P10(6)-P', '0', 1, '2018-04-11 16:47:57'),
(5595, '33880-64P20(6)-P', '0', 1, '2018-04-11 16:47:57'),
(5596, '33880-64P30(6)-P', '0', 1, '2018-04-11 16:47:57'),
(5597, '33880-64P40(6)-P', '0', 1, '2018-04-11 16:47:58'),
(5598, '33880-64P50(6)-P', '0', 1, '2018-04-11 16:47:58'),
(5599, '36658-64P00(1)-1-P', '0.5572', 1, '2018-04-11 16:47:58'),
(5600, '36680-64P00(3)-P', '1.2445', 1, '2018-04-11 16:47:58'),
(5601, '36680-64P10(3)-P', '1.6677', 1, '2018-04-11 16:47:58'),
(5602, '36680-64P20(3)-P', '1.7721', 1, '2018-04-11 16:47:58'),
(5603, '36680-64PA0(3)-P', '1.2416', 1, '2018-04-11 16:47:58'),
(5604, '36680-64PB0(3)-P', '1.6641', 1, '2018-04-11 16:47:58'),
(5605, '36680-64PC0(3)-P', '1.7682', 1, '2018-04-11 16:47:58'),
(5606, '36820-64P00(5)-1-P', '1.5728', 1, '2018-04-11 16:47:58'),
(5607, '36820-64P10(5)-1-P', '1.9944', 1, '2018-04-11 16:47:58'),
(5608, '36820-64P20(5)-1-P', '3.1435', 1, '2018-04-11 16:47:58'),
(5609, '36820-64P40(5)-1-P', '3.2602', 1, '2018-04-11 16:47:58'),
(5610, '36820-64PA0(5)-1-P', '1.5717', 1, '2018-04-11 16:47:58'),
(5611, '36820-64PB0(5)-1-P', '1.9952', 1, '2018-04-11 16:47:58'),
(5612, '36820-64PC0(5)-1-P', '3.1353', 1, '2018-04-11 16:47:58'),
(5613, '36820-64PE0(5)-1-P', '3.2517', 1, '2018-04-11 16:47:58'),
(5614, '33840-64P00-5-P', '0', 1, '2018-04-11 16:47:58'),
(5615, '36810-64P00-5-P', '2.0184', 1, '2018-04-11 16:47:58'),
(5616, '36611-64P00-4-P', '0.2889', 1, '2018-04-11 16:47:58'),
(5617, '36756-64P00(1)-2-P', '0.5167', 1, '2018-04-11 16:47:58'),
(5618, '36756-64P10(1)-2-P', '1.7502', 1, '2018-04-11 16:47:58'),
(5619, '36756-64P20(1)-2-P', '3.8587', 1, '2018-04-11 16:47:58'),
(5620, '36756-64P30(1)-2-P', '4.0913', 1, '2018-04-11 16:47:58'),
(5621, '36756-64P40(1)-2-P', '4.1997', 1, '2018-04-11 16:47:58'),
(5622, '36756-64P50(1)-2-P', '0.31', 1, '2018-04-11 16:47:58'),
(5623, '36757-64P00-8-P', '0.2066', 1, '2018-04-11 16:47:59'),
(5624, '36757-64P10-8-P', '0.7386', 1, '2018-04-11 16:47:59'),
(5625, '36757-64P20-8-P', '1.6553', 1, '2018-04-11 16:47:59'),
(5626, '36757-64P30-8-P', '1.8882', 1, '2018-04-11 16:47:59'),
(5627, '36757-64P40-8-P', '1.9907', 1, '2018-04-11 16:47:59'),
(5628, '36064-64P00(7)-1-P', '21.0184', 1, '2018-04-11 16:47:59'),
(5629, '36064-64P10(7)-1-P', '22.4829', 1, '2018-04-11 16:47:59'),
(5630, '36064-64P20(7)-1-P', '24.1616', 1, '2018-04-11 16:47:59'),
(5631, '36064-64P30(7)-1-P', '23.8695', 1, '2018-04-11 16:47:59'),
(5632, '36064-64P40(7)-1-P', '25.5481', 1, '2018-04-11 16:47:59'),
(5633, '36064-64P50(7)-1-P', '23.1798', 1, '2018-04-11 16:47:59'),
(5634, '36064-64P60(7)-1-P', '24.8418', 1, '2018-04-11 16:47:59'),
(5635, '36064-64P70(7)-1-P', '24.0132', 1, '2018-04-11 16:47:59'),
(5636, '36064-64P80(7)-1-P', '25.6753', 1, '2018-04-11 16:47:59'),
(5637, '36064-64P90(7)-1-P', '20.4578', 1, '2018-04-11 16:47:59'),
(5638, '36064-64PA0(7)-1-P', '18.7926', 1, '2018-04-11 16:47:59'),
(5639, '36064-64PB0(7)-1-P', '27.8947', 1, '2018-04-11 16:47:59'),
(5640, '36064-64PC0(7)-1-P', '28.0945', 1, '2018-04-11 16:47:59'),
(5641, '36065-64P00(7)-1-P', '25.9342', 1, '2018-04-11 16:47:59'),
(5642, '36065-64P10(7)-1-P', '26.134', 1, '2018-04-11 16:47:59'),
(5643, '36065-64P20(7)-1-P', '30.2485', 1, '2018-04-11 16:47:59'),
(5644, '36065-64P30(7)-1-P', '30.4483', 1, '2018-04-11 16:47:59'),
(5645, '36065-64P40(7)-1-P', '33.08', 1, '2018-04-11 16:47:59'),
(5646, '36065-64P50(7)-1-P', '33.2799', 1, '2018-04-11 16:48:00'),
(5647, '36065-64P60(7)-1-P', '25.9339', 1, '2018-04-11 16:48:00'),
(5648, '36065-64P70(7)-1-P', '26.1338', 1, '2018-04-11 16:48:00'),
(5649, '36065-64P80(7)-1-P', '22.5868', 1, '2018-04-11 16:48:00'),
(5650, '36065-64P90(7)-1-P', '24.2654', 1, '2018-04-11 16:48:00'),
(5651, '36065-64PA0(7)-1-P', '24.1107', 1, '2018-04-11 16:48:00'),
(5652, '36065-64PB0(7)-1-P', '24.0984', 1, '2018-04-11 16:48:00'),
(5653, '36065-64PC0(7)-1-P', '24.4777', 1, '2018-04-11 16:48:00'),
(5654, '36065-64PD0(7)-1-P', '26.1564', 1, '2018-04-11 16:48:00'),
(5655, '36065-64PJ0(7)-1-P', '20.6835', 1, '2018-04-11 16:48:00'),
(5656, '36065-64PK0(7)-1-P', '22.3485', 1, '2018-04-11 16:48:00'),
(5657, '36065-64PL0(7)-1-P', '21.0204', 1, '2018-04-11 16:48:00'),
(5658, '36065-64PM0(7)-1-P', '23.5167', 1, '2018-04-11 16:48:00'),
(5659, '36065-64PP0(7)-1-P', '23.5044', 1, '2018-04-11 16:48:00'),
(5660, '36065-64PQ0(7)-1-P', '21.7734', 1, '2018-04-11 16:48:00'),
(5661, '36065-64PR0(7)-1-P', '23.4354', 1, '2018-04-11 16:48:00'),
(5662, '36065-64PS0(7)-1-P', '22.1026', 1, '2018-04-11 16:48:00'),
(5663, '36065-64PU0(7)-1-P', '23.7646', 1, '2018-04-11 16:48:00'),
(5664, '36066-64P12(15)-1-P', '0', 1, '2018-04-11 16:48:00'),
(5665, '36066-64P12(16)-P', '21.2899', 1, '2018-04-11 16:48:00'),
(5666, '36066-64P32(15)-1-P', '0', 1, '2018-04-11 16:48:00'),
(5667, '36066-64P32(16)-P', '24.1993', 1, '2018-04-11 16:48:00'),
(5668, '36066-64P52(15)-1-P', '0', 1, '2018-04-11 16:48:00'),
(5669, '36066-64P52(16)-P', '24.5289', 1, '2018-04-11 16:48:01'),
(5670, '36066-64PB2(15)-1-P', '0', 1, '2018-04-11 16:48:01'),
(5671, '36066-64PB2(16)-P', '25.582', 1, '2018-04-11 16:48:01'),
(5672, '36066-64PD2(15)-1-P', '0', 1, '2018-04-11 16:48:01'),
(5673, '36066-64PD2(16)-P', '26.4166', 1, '2018-04-11 16:48:01'),
(5674, '36067-64P11(15)-1-P', '0', 1, '2018-04-11 16:48:01'),
(5675, '36067-64P11(16)-P', '25.6221', 1, '2018-04-11 16:48:01'),
(5676, '36067-64P52(15)-1-P', '0', 1, '2018-04-11 16:48:01'),
(5677, '36067-64P52(16)-P', '26.4566', 1, '2018-04-11 16:48:01'),
(5678, '36069-64P31(15)-1-P', '0', 1, '2018-04-11 16:48:01'),
(5679, '36069-64P31(16)-P', '21.33', 1, '2018-04-11 16:48:01'),
(5680, '36069-64P51(15)-1-P', '0', 1, '2018-04-11 16:48:01'),
(5681, '36069-64P51(16)-P', '24.2393', 1, '2018-04-11 16:48:01'),
(5682, '36605-64P00(3)-2-P', '5.9654', 1, '2018-04-11 16:48:01'),
(5683, '36605-64P10(3)-2-P', '5.7384', 1, '2018-04-11 16:48:01'),
(5684, '36605-64P20(3)-2-P', '6.5215', 1, '2018-04-11 16:48:01'),
(5685, '36605-64P30(3)-2-P', '6.2941', 1, '2018-04-11 16:48:01'),
(5686, '33850-74P00(3)-P', '0', 1, '2018-04-11 16:48:01'),
(5687, '33850-74P20(3)-P', '0', 1, '2018-04-11 16:48:01'),
(5688, '33880-74PA0(3)-P', '0', 1, '2018-04-11 16:48:01'),
(5689, '33880-74PB0(3)-P', '0', 1, '2018-04-11 16:48:01'),
(5690, '33880-74PC0(3)-P', '0', 1, '2018-04-11 16:48:01'),
(5691, '33880-54SC0(5)-P', '0', 1, '2018-04-11 16:48:01'),
(5692, '36680-74P00(1)-1-P', '0.9407', 1, '2018-04-11 16:48:01'),
(5693, '36680-74P10(1)-1-P', '1.2554', 1, '2018-04-11 16:48:01'),
(5694, '36680-74P20(1)-1-P', '1.4593', 1, '2018-04-11 16:48:02'),
(5695, '36680-74P30(1)-1-P', '1.5657', 1, '2018-04-11 16:48:02'),
(5696, '36680-74P50(1)-1-P', '1.2554', 1, '2018-04-11 16:48:02'),
(5697, '36820-74P00(4)-1-P', '0.3181', 1, '2018-04-11 16:48:02'),
(5698, '36820-74P10(4)-1-P', '0.7397', 1, '2018-04-11 16:48:02'),
(5699, '36820-74P30(4)-1-P', '0.7369', 1, '2018-04-11 16:48:02'),
(5700, '36882-74P00-6-P', '0.341', 1, '2018-04-11 16:48:02'),
(5701, '36843-74P00(1)-1-P', '1.1936', 1, '2018-04-11 16:48:02'),
(5702, '36843-74P10(1)-1-P', '1.4259', 1, '2018-04-11 16:48:02'),
(5703, '36756-74P00(1)-3-P', '0.7184', 1, '2018-04-11 16:48:02'),
(5704, '36756-74P10(1)-3-P', '2.522', 1, '2018-04-11 16:48:02'),
(5705, '36756-74P20(1)-3-P', '4.2267', 1, '2018-04-11 16:48:02'),
(5706, '36756-74P30(1)-3-P', '1.4304', 1, '2018-04-11 16:48:02'),
(5707, '36756-74P40(1)-3-P', '4.0202', 1, '2018-04-11 16:48:02'),
(5708, '36757-74P00(2)-P', '0.4081', 1, '2018-04-11 16:48:02'),
(5709, '36757-74P10(2)-P', '0.9361', 1, '2018-04-11 16:48:02'),
(5710, '36757-74P20(2)-P', '1.9494', 1, '2018-04-11 16:48:02'),
(5711, '36757-74P40(2)-P', '1.7458', 1, '2018-04-11 16:48:02'),
(5712, '36751-74P00(3)-P', '0.2068', 1, '2018-04-11 16:48:02'),
(5713, '36751-74P10(3)-P', '0.7374', 1, '2018-04-11 16:48:02'),
(5714, '36602-74P00(11)-1-P', '22.0961', 1, '2018-04-11 16:48:02'),
(5715, '36602-74P10(11)-1-P', '22.6124', 1, '2018-04-11 16:48:02'),
(5716, '36602-74P20(11)-1-P', '16.4087', 1, '2018-04-11 16:48:02'),
(5717, '36602-74P30(11)-1-P', '17.1943', 1, '2018-04-11 16:48:02'),
(5718, '36602-74P40(11)-1-P', '16.9253', 1, '2018-04-11 16:48:02'),
(5719, '36602-74P50(11)-1-P', '17.7109', 1, '2018-04-11 16:48:03'),
(5720, '36602-74P60(11)-1-P', '17.1756', 1, '2018-04-11 16:48:03'),
(5721, '36602-74P70(11)-1-P', '20.494', 1, '2018-04-11 16:48:03'),
(5722, '36602-74P80(11)-1-P', '12.7524', 1, '2018-04-11 16:48:03'),
(5723, '36602-74P90(11)-1-P', '14.5826', 1, '2018-04-11 16:48:03'),
(5724, '36620-74P10-8-P', '0', 1, '2018-04-11 16:48:03'),
(5725, '36620-74P20(11)-1-P', '13.895', 1, '2018-04-11 16:48:03'),
(5726, '36620-74P40(11)-1-P', '15.5154', 1, '2018-04-11 16:48:03'),
(5727, '36620-74P50(11)-1-P', '15.3683', 1, '2018-04-11 16:48:03'),
(5728, '36620-74P60(11)-1-P', '16.3011', 1, '2018-04-11 16:48:03'),
(5729, '36620-74P70(11)-1-P', '15.8675', 1, '2018-04-11 16:48:03'),
(5730, '36620-74P80(11)-1-P', '15.9271', 1, '2018-04-11 16:48:03'),
(5731, '36620-74P90(11)-1-P', '16.6531', 1, '2018-04-11 16:48:03'),
(5732, '36620-74PA0(11)-1-P', '21.0253', 1, '2018-04-11 16:48:03'),
(5733, '36620-74PB0(11)-1-P', '22.7226', 1, '2018-04-11 16:48:03'),
(5734, '36620-74PC0(11)-1-P', '13.3784', 1, '2018-04-11 16:48:03'),
(5735, '36620-74PD0-8-P', '0', 1, '2018-04-11 16:48:03'),
(5736, '36620-74PE0(11)-1-P', '14.9988', 1, '2018-04-11 16:48:03'),
(5737, '36620-74PF0-8-P', '0', 1, '2018-04-11 16:48:03'),
(5738, '36620-74PG0(11)-1-P', '15.7845', 1, '2018-04-11 16:48:03'),
(5739, '36620-74PH0(11)-1-P', '15.3512', 1, '2018-04-11 16:48:03'),
(5740, '36620-74PJ0(11)-1-P', '20.5091', 1, '2018-04-11 16:48:03'),
(5741, '36620-74PK0(11)-1-P', '22.2064', 1, '2018-04-11 16:48:03'),
(5742, '36620-74PL0(11)-1-P', '21.0106', 1, '2018-04-11 16:48:03'),
(5743, '36620-74PM0(11)-1-P', '21.5268', 1, '2018-04-11 16:48:03'),
(5744, '36620-74PN0(11)-1-P', '22.5045', 1, '2018-04-11 16:48:04'),
(5745, '36620-74PP0(11)-1-P', '23.0207', 1, '2018-04-11 16:48:04'),
(5746, '36620-74PQ0(11)-1-P', '17.0111', 1, '2018-04-11 16:48:04'),
(5747, '36620-74PR0(11)-1-P', '17.2806', 1, '2018-04-11 16:48:04'),
(5748, '36620-74PS0(11)-1-P', '17.7968', 1, '2018-04-11 16:48:04'),
(5749, '36620-74PU0(11)-1-P', '16.4949', 1, '2018-04-11 16:48:04'),
(5750, '36602-54S00-X3-P', '22.1162', 1, '2018-04-11 16:48:04'),
(5751, '36602-54S10-X3-P', '22.6318', 1, '2018-04-11 16:48:04'),
(5752, '36602-54S60-X3-P', '17.1826', 1, '2018-04-11 16:48:04'),
(5753, '36602-54S70-X3-P', '20.5147', 1, '2018-04-11 16:48:04'),
(5754, '36620-54S00-X3-P', '12.7524', 1, '2018-04-11 16:48:04'),
(5755, '36620-54S20-X3-P', '13.895', 1, '2018-04-11 16:48:04'),
(5756, '36620-54S30-X3-P', '14.5951', 1, '2018-04-11 16:48:04'),
(5757, '36620-54S40-X3-P', '15.5278', 1, '2018-04-11 16:48:04'),
(5758, '36620-54S50-X3-P', '15.3807', 1, '2018-04-11 16:48:04'),
(5759, '36620-54S60-X3-P', '16.3135', 1, '2018-04-11 16:48:04'),
(5760, '36620-54S70-X3-P', '15.8668', 1, '2018-04-11 16:48:04'),
(5761, '36620-54S80-X3-P', '15.9271', 1, '2018-04-11 16:48:04'),
(5762, '36620-54S90-X3-P', '16.6525', 1, '2018-04-11 16:48:04'),
(5763, '36620-54SA0-X3-P', '21.0306', 1, '2018-04-11 16:48:04'),
(5764, '36620-54SC0-X3-P', '13.3784', 1, '2018-04-11 16:48:04'),
(5765, '36620-54SE0-X3-P', '15.0113', 1, '2018-04-11 16:48:04'),
(5766, '36620-54SG0-X3-P', '15.7969', 1, '2018-04-11 16:48:04'),
(5767, '36620-54SH0-X3-P', '15.3512', 1, '2018-04-11 16:48:04'),
(5768, '36620-54SJ0-X3-P', '20.5149', 1, '2018-04-11 16:48:05'),
(5769, '36620-54SL0-X3-P', '21.0313', 1, '2018-04-11 16:48:05'),
(5770, '36620-54SM0-X3-P', '21.5469', 1, '2018-04-11 16:48:05'),
(5771, '36620-54SQ0-X3-P', '17.0105', 1, '2018-04-11 16:48:05'),
(5772, '36620-54SR0-X3-P', '17.2806', 1, '2018-04-11 16:48:05'),
(5773, '36620-54SS0-X3-P', '17.7962', 1, '2018-04-11 16:48:05'),
(5774, '36620-54SU0-X3-P', '16.4949', 1, '2018-04-11 16:48:05'),
(5775, '36630-74P20(7)-2-P', '5.3164', 1, '2018-04-11 16:48:05'),
(5776, '36630-74P30(7)-2-P', '5.7561', 1, '2018-04-11 16:48:05'),
(5777, '36630-74P40(7)-2-P', '4.7839', 1, '2018-04-11 16:48:05'),
(5778, '36630-74P50(7)-2-P', '5.0142', 1, '2018-04-11 16:48:05'),
(5779, '36630-74P60(7)-2-P', '5.4173', 1, '2018-04-11 16:48:05'),
(5780, '36630-74P70(7)-2-P', '5.8571', 1, '2018-04-11 16:48:05'),
(5781, '36630-74P80(7)-2-P', '7.1904', 1, '2018-04-11 16:48:05'),
(5782, '36630-74P90(7)-2-P', '7.6251', 1, '2018-04-11 16:48:05'),
(5783, '36630-74PA0(7)-2-P', '9.0996', 1, '2018-04-11 16:48:05'),
(5784, '36630-74PB0(7)-2-P', '9.304', 1, '2018-04-11 16:48:05'),
(5785, '36630-74PC0(7)-2-P', '8.7041', 1, '2018-04-11 16:48:05'),
(5786, '36630-74PD0(7)-2-P', '9.0307', 1, '2018-04-11 16:48:05'),
(5787, '36630-74PE0(7)-2-P', '7.4207', 1, '2018-04-11 16:48:05'),
(5788, '36630-74PF0(7)-2-P', '6.3981', 1, '2018-04-11 16:48:05'),
(5789, '36630-74PG0(7)-2-P', '6.6075', 1, '2018-04-11 16:48:05'),
(5790, '36630-74PH0(7)-2-P', '8.2801', 1, '2018-04-11 16:48:05'),
(5791, '36630-74PJ0(7)-2-P', '8.4024', 1, '2018-04-11 16:48:05'),
(5792, '36630-74PK0(7)-2-P', '8.4947', 1, '2018-04-11 16:48:05'),
(5793, '36630-74PL0(7)-2-P', '8.617', 1, '2018-04-11 16:48:06'),
(5794, '36630-54S00-P', '4.2137', 1, '2018-04-11 16:48:06'),
(5795, '36630-54S10-P', '4.444', 1, '2018-04-11 16:48:06'),
(5796, '36630-54S20-X3-P', '5.3102', 1, '2018-04-11 16:48:06'),
(5797, '36630-54S30-X3-P', '5.7499', 1, '2018-04-11 16:48:06'),
(5798, '36630-54S40-X3-P', '4.7727', 1, '2018-04-11 16:48:06'),
(5799, '36630-54S50-X3-P', '5.003', 1, '2018-04-11 16:48:06'),
(5800, '36630-54S60-X3-P', '5.4112', 1, '2018-04-11 16:48:06'),
(5801, '36630-54S70-X3-P', '5.8509', 1, '2018-04-11 16:48:06'),
(5802, '36630-54S80-X3-P', '7.1839', 1, '2018-04-11 16:48:06'),
(5803, '36630-54S90-X3-P', '7.6185', 1, '2018-04-11 16:48:06'),
(5804, '36630-54SA0-X3-P', '8.975', 1, '2018-04-11 16:48:06'),
(5805, '36630-54SB0-X3-P', '9.1793', 1, '2018-04-11 16:48:06'),
(5806, '36630-54SC0-X3-P', '8.6937', 1, '2018-04-11 16:48:06'),
(5807, '36630-54SD0-X3-P', '9.0203', 1, '2018-04-11 16:48:06'),
(5808, '36630-54SE0-X3-P', '7.4142', 1, '2018-04-11 16:48:06'),
(5809, '36630-54SH0-X3-P', '8.2695', 1, '2018-04-11 16:48:06'),
(5810, '36630-54SJ0-X3-P', '8.3918', 1, '2018-04-11 16:48:06'),
(5811, '36630-54SK0-X3-P', '8.3705', 1, '2018-04-11 16:48:06'),
(5812, '36630-54SL0-X3-P', '8.4928', 1, '2018-04-11 16:48:06'),
(5813, '36680-81P00(1)-3-P', '2.5975', 1, '2018-04-11 16:48:06'),
(5814, '36680-81P10(1)-3-P', '2.5975', 1, '2018-04-11 16:48:06'),
(5815, '36680-81PH0(1)-3-P', '2.5975', 1, '2018-04-11 16:48:06'),
(5816, '36680-57S00-1-P', '2.5975', 1, '2018-04-11 16:48:07'),
(5817, '36680-57S10-1-P', '2.5975', 1, '2018-04-11 16:48:07'),
(5818, '36882-81P00(2)-P', '0.3603', 1, '2018-04-11 16:48:07'),
(5819, '36843-57S00-1-P', '1.4737', 1, '2018-04-11 16:48:07'),
(5820, '36843-57S10-1-P', '1.5015', 1, '2018-04-11 16:48:07'),
(5821, '36843-57SA0-P', '0.3233', 1, '2018-04-11 16:48:07'),
(5822, '36756-81P00(3)-3-P', '4.1785', 1, '2018-04-11 16:48:07'),
(5823, '36756-81P10(3)-3-P', '4.1785', 1, '2018-04-11 16:48:07'),
(5824, '36756-81P20(3)-3-P', '4.2933', 1, '2018-04-11 16:48:07'),
(5825, '36756-81P30(3)-3-P', '4.2933', 1, '2018-04-11 16:48:07'),
(5826, '36756-57S00-1-P', '4.282', 1, '2018-04-11 16:48:07'),
(5827, '36756-57S10-1-P', '4.282', 1, '2018-04-11 16:48:07'),
(5828, '36756-57S20-1-P', '4.3968', 1, '2018-04-11 16:48:07'),
(5829, '36756-57S30-1-P', '4.3968', 1, '2018-04-11 16:48:07'),
(5830, '36757-81P00(3)-2-P', '1.8462', 1, '2018-04-11 16:48:07'),
(5831, '36757-81P10(3)-2-P', '1.8462', 1, '2018-04-11 16:48:07'),
(5832, '36757-81P20(3)-2-P', '1.9495', 1, '2018-04-11 16:48:07'),
(5833, '36757-81P30(3)-2-P', '1.9495', 1, '2018-04-11 16:48:07'),
(5834, '36751-81P00(1)-1-P', '0.4256', 1, '2018-04-11 16:48:07'),
(5835, '36751-81P20(1)-1-P', '1.4205', 1, '2018-04-11 16:48:07'),
(5836, '36751-81PA0(2)-1-P', '0.4256', 1, '2018-04-11 16:48:07'),
(5837, '36751-81PC0(2)-1-P', '1.4205', 1, '2018-04-11 16:48:07'),
(5838, '36603-81P20(11)-1-P', '15.7831', 1, '2018-04-11 16:48:07'),
(5839, '36603-81P40(11)-1-P', '17.1465', 1, '2018-04-11 16:48:07'),
(5840, '36630-81P00(11)-1-P', '10.8939', 1, '2018-04-11 16:48:07'),
(5841, '36630-81P10(11)-1-P', '11.3193', 1, '2018-04-11 16:48:07'),
(5842, '36630-81PC0(11)-1-P', '13.2712', 1, '2018-04-11 16:48:07'),
(5843, '36630-81PD0(11)-1-P', '13.4844', 1, '2018-04-11 16:48:08'),
(5844, '36630-81PE0(11)-1-P', '14.6345', 1, '2018-04-11 16:48:08'),
(5845, '36630-81PG0(11)-1-P', '14.9869', 1, '2018-04-11 16:48:08'),
(5846, '36630-81PK0(11)-1-P', '13.127', 1, '2018-04-11 16:48:08'),
(5847, '36630-81PJ0(11)-1-P', '10.1619', 1, '2018-04-11 16:48:08'),
(5848, '36630-81PL0(11)-1-P', '13.3402', 1, '2018-04-11 16:48:08'),
(5849, '36603-57S20-1-P', '16.3457', 1, '2018-04-11 16:48:08'),
(5850, '36603-57S60-1-P', '18.4889', 1, '2018-04-11 16:48:08'),
(5851, '36603-57S80-1-P', '20.6385', 1, '2018-04-11 16:48:08'),
(5852, '36630-57S00-1-P', '11.239', 1, '2018-04-11 16:48:08'),
(5853, '36630-57S10-1-P', '11.6701', 1, '2018-04-11 16:48:08'),
(5854, '36630-57S20-1-P', '13.379', 1, '2018-04-11 16:48:08'),
(5855, '36630-57S30-1-P', '13.8101', 1, '2018-04-11 16:48:08'),
(5856, '36630-57SC0-1-P', '13.6169', 1, '2018-04-11 16:48:08'),
(5857, '36630-57SD0-1-P', '13.8358', 1, '2018-04-11 16:48:08'),
(5858, '36630-57SE0-1-P', '14.749', 1, '2018-04-11 16:48:08'),
(5859, '36630-57SG0-1-P', '15.1009', 1, '2018-04-11 16:48:08'),
(5860, '36630-57SH0-1-P', '15.7568', 1, '2018-04-11 16:48:08'),
(5861, '36630-57SJ0-1-P', '15.9758', 1, '2018-04-11 16:48:08'),
(5862, '36630-57SK0-1-P', '17.9063', 1, '2018-04-11 16:48:08'),
(5863, '36630-57SL0-1-P', '18.2584', 1, '2018-04-11 16:48:08'),
(5864, '36680-80P00(1)-1-P', '1.3835', 1, '2018-04-11 16:48:08'),
(5865, '36680-80P10(1)-1-P', '1.7006', 1, '2018-04-11 16:48:08'),
(5866, '36680-80P20(1)-1-P', '1.3835', 1, '2018-04-11 16:48:08'),
(5867, '36680-80P30(1)-1-P', '1.7006', 1, '2018-04-11 16:48:08'),
(5868, '36820-80P00-4-P', '0.7451', 1, '2018-04-11 16:48:09'),
(5869, '36820-80P10-4-P', '1.0532', 1, '2018-04-11 16:48:09'),
(5870, '36820-80P20-4-P', '1.1506', 1, '2018-04-11 16:48:09'),
(5871, '36820-80P30-4-P', '1.4587', 1, '2018-04-11 16:48:09'),
(5872, '39312-80P00-1-P', '0.096', 1, '2018-04-11 16:48:09'),
(5873, '36620-80P00(5)-1-P', '18.9777', 1, '2018-04-11 16:48:09'),
(5874, '36620-80P10(5)-1-P', '19.6927', 1, '2018-04-11 16:48:09'),
(5875, '36620-80P20(5)-1-P', '20.7791', 1, '2018-04-11 16:48:09'),
(5876, '36620-80P30(5)-1-P', '21.4941', 1, '2018-04-11 16:48:09'),
(5877, '36620-80P40(5)-1-P', '18.0335', 1, '2018-04-11 16:48:09'),
(5878, '36620-80P50(5)-1-P', '18.7486', 1, '2018-04-11 16:48:09'),
(5879, '36620-80P60(5)-1-P', '19.8349', 1, '2018-04-11 16:48:09'),
(5880, '36620-80P70(5)-1-P', '20.55', 1, '2018-04-11 16:48:09'),
(5881, '36620-80P80(5)-1-P', '20.3567', 1, '2018-04-11 16:48:09'),
(5882, '36620-80P90(5)-1-P', '21.071', 1, '2018-04-11 16:48:09'),
(5883, '36620-80PA0(5)-1-P', '22.1581', 1, '2018-04-11 16:48:09'),
(5884, '36620-80PB0(5)-1-P', '22.8724', 1, '2018-04-11 16:48:09'),
(5885, '36620-80PC0(5)-1-P', '18.4431', 1, '2018-04-11 16:48:09'),
(5886, '36620-80PD0(5)-1-P', '19.8045', 1, '2018-04-11 16:48:09'),
(5887, '36620-80PJ0(5)-1-P', '20.8689', 1, '2018-04-11 16:48:09'),
(5888, '36620-80PK0(5)-1-P', '22.4669', 1, '2018-04-11 16:48:09'),
(5889, '36630-80P00(5)-P', '9.1541', 1, '2018-04-11 16:48:09'),
(5890, '36630-80P10(5)-P', '9.3582', 1, '2018-04-11 16:48:09'),
(5891, '36630-80P20(5)-P', '9.1541', 1, '2018-04-11 16:48:09'),
(5892, '36630-80P30(5)-P', '9.3582', 1, '2018-04-11 16:48:09'),
(5893, '36630-80P40(5)-P', '9.539', 1, '2018-04-11 16:48:10'),
(5894, '36630-80P50(5)-P', '9.8686', 1, '2018-04-11 16:48:10'),
(5895, '36630-80P60(5)-P', '9.539', 1, '2018-04-11 16:48:10'),
(5896, '36630-80P70(5)-P', '9.8686', 1, '2018-04-11 16:48:10'),
(5897, '36630-80P80(5)-P', '7.9313', 1, '2018-04-11 16:48:10'),
(5898, '36630-80P90(5)-P', '8.1416', 1, '2018-04-11 16:48:10'),
(5899, '36630-80PE0(5)-P', '9.7431', 1, '2018-04-11 16:48:10'),
(5900, '36630-80PF0(5)-P', '9.7431', 1, '2018-04-11 16:48:10'),
(5901, '91311-81PP0-4-P', '0', 1, '2018-04-11 16:48:10'),
(5902, '91312-81PP0-3-P', '0', 1, '2018-04-11 16:48:10'),
(5903, '91315-81PP0-2-P', '0', 1, '2018-04-11 16:48:10'),
(5904, '96461-81PP0(1)-1-P', '3.115', 1, '2018-04-11 16:48:10'),
(5905, '96562-81PP0-6-P', '0.3791', 1, '2018-04-11 16:48:10'),
(5906, '96572-81PP0-6-P', '0.7701', 1, '2018-04-11 16:48:10'),
(5907, '96564-81PP0-3-P', '1.4409', 1, '2018-04-11 16:48:10'),
(5908, '96574-81PP0-2-P', '1.4261', 1, '2018-04-11 16:48:10'),
(5909, '36620-52R00(4)-1-P', '19.1654', 1, '2018-04-11 16:48:10'),
(5910, '36620-52R20(4)-1-P', '22.095', 1, '2018-04-11 16:48:10'),
(5911, '36620-52R30(4)-1-P', '23.2294', 1, '2018-04-11 16:48:10'),
(5912, '36620-52R40(4)-1-P', '21.4351', 1, '2018-04-11 16:48:10'),
(5913, '36620-52R50(4)-1-P', '22.86', 1, '2018-04-11 16:48:10'),
(5914, '36620-52R80(4)-1-P', '24.3191', 1, '2018-04-11 16:48:10'),
(5915, '36620-52R90(4)-1-P', '25.4535', 1, '2018-04-11 16:48:11'),
(5916, '36620-52RA0(4)-1-P', '23.1024', 1, '2018-04-11 16:48:11'),
(5917, '36620-52RB0(4)-1-P', '24.2367', 1, '2018-04-11 16:48:11'),
(5918, '36620-52RC0(4)-1-P', '20.1649', 1, '2018-04-11 16:48:11'),
(5919, '36620-52RG0(4)-1-P', '22.5973', 1, '2018-04-11 16:48:11'),
(5920, '36620-52RH0(4)-1-P', '23.7183', 1, '2018-04-11 16:48:11'),
(5921, '36620-52RL0(4)-1-P', '24.8245', 1, '2018-04-11 16:48:11'),
(5922, '36620-52RM0(4)-1-P', '25.9454', 1, '2018-04-11 16:48:11'),
(5923, '36620-52RP0(4)-1-P', '22.2727', 1, '2018-04-11 16:48:11'),
(5924, '36620-52RQ0(4)-1-P', '20.1445', 1, '2018-04-11 16:48:11'),
(5925, '36620-52RR0(4)-1-P', '23.087', 1, '2018-04-11 16:48:11'),
(5926, '36620-53R20(4)-1-P', '17.5067', 1, '2018-04-11 16:48:11'),
(5927, '36620-53R30(4)-1-P', '19.1209', 1, '2018-04-11 16:48:11'),
(5928, '36620-53R40(4)-1-P', '15.6893', 1, '2018-04-11 16:48:11'),
(5929, '36620-53R50(4)-1-P', '18.6634', 1, '2018-04-11 16:48:11'),
(5930, '36620-53R60(4)-1-P', '19.3892', 1, '2018-04-11 16:48:11'),
(5931, '36620-53R70(4)-1-P', '20.2516', 1, '2018-04-11 16:48:11'),
(5932, '36620-53R90(4)-1-P', '22.9794', 1, '2018-04-11 16:48:11'),
(5933, '36620-53RA0(4)-1-P', '19.4373', 1, '2018-04-11 16:48:11'),
(5934, '36620-53RB0(4)-1-P', '24.5025', 1, '2018-04-11 16:48:11'),
(5935, '36620-53RC0(4)-1-P', '24.6063', 1, '2018-04-11 16:48:11'),
(5936, '36620-53RD0(4)-1-P', '25.2132', 1, '2018-04-11 16:48:11'),
(5937, '36620-53RE0(4)-1-P', '25.317', 1, '2018-04-11 16:48:11'),
(5938, '36620-53RF0(4)-1-P', '17.6104', 1, '2018-04-11 16:48:11'),
(5939, '36620-53RG0(4)-1-P', '19.2246', 1, '2018-04-11 16:48:11'),
(5940, '36620-53RH0(4)-1-P', '18.7671', 1, '2018-04-11 16:48:12'),
(5941, '36620-53RJ0(4)-1-P', '19.4929', 1, '2018-04-11 16:48:12'),
(5942, '36620-68R00(1)-1-P', '21.2893', 1, '2018-04-11 16:48:12'),
(5943, '36620-68R10(1)-1-P', '23.8155', 1, '2018-04-11 16:48:12'),
(5944, '36620-68R20(1)-1-P', '24.9498', 1, '2018-04-11 16:48:12'),
(5945, '36620-68R50(1)-1-P', '22.8756', 1, '2018-04-11 16:48:12'),
(5946, '36620-68R60(1)-1-P', '22.9794', 1, '2018-04-11 16:48:12'),
(5947, '36620-68R70(1)-1-P', '23.0716', 1, '2018-04-11 16:48:12'),
(5948, '36620-68R80(1)-1-P', '23.1753', 1, '2018-04-11 16:48:12'),
(5949, '36620-68R90(1)-1-P', '24.2868', 1, '2018-04-11 16:48:12'),
(5950, '36620-68RA0(1)-1-P', '24.3905', 1, '2018-04-11 16:48:12'),
(5951, '36620-68RB0(1)-1-P', '25.104', 1, '2018-04-11 16:48:12'),
(5952, '36620-68RC0(1)-1-P', '25.2077', 1, '2018-04-11 16:48:12'),
(5953, '36602-53R00(4)-1-P', '13.5514', 1, '2018-04-11 16:48:12'),
(5954, '36602-53R10(4)-1-P', '16.4214', 1, '2018-04-11 16:48:12'),
(5955, '36602-53R20(4)-1-P', '17.8433', 1, '2018-04-11 16:48:12'),
(5956, '36602-53R30(4)-1-P', '15.6822', 1, '2018-04-11 16:48:12'),
(5957, '36602-53R40(4)-1-P', '17.9609', 1, '2018-04-11 16:48:12'),
(5958, '36602-53R51(4)-1-P', '19.0584', 1, '2018-04-11 16:48:12'),
(5959, '36602-53R70(4)-1-P', '19.876', 1, '2018-04-11 16:48:12'),
(5960, '36602-53R80(4)-1-P', '21.2114', 1, '2018-04-11 16:48:12'),
(5961, '36602-53R90(4)-1-P', '22.4956', 1, '2018-04-11 16:48:12'),
(5962, '36602-53RC0(4)-1-P', '23.7968', 1, '2018-04-11 16:48:12'),
(5963, '36602-53RD0(4)-1-P', '23.9008', 1, '2018-04-11 16:48:12'),
(5964, '36602-53RE0(4)-1-P', '24.4899', 1, '2018-04-11 16:48:13'),
(5965, '36602-53RF0(4)-1-P', '24.594', 1, '2018-04-11 16:48:13'),
(5966, '36602-53RG0(4)-1-P', '17.3762', 1, '2018-04-11 16:48:13'),
(5967, '36602-53RH0(4)-1-P', '20.1715', 1, '2018-04-11 16:48:13'),
(5968, '36602-53RJ1(4)-1-P', '18.4566', 1, '2018-04-11 16:48:13'),
(5969, '36602-53RK1(4)-1-P', '19.1624', 1, '2018-04-11 16:48:13'),
(5970, '36602-53RL0(4)-1-P', '18.3526', 1, '2018-04-11 16:48:13'),
(5971, '36602-68R00(1)-1-P', '22.3647', 1, '2018-04-11 16:48:13'),
(5972, '36602-68R10(1)-1-P', '22.4687', 1, '2018-04-11 16:48:13'),
(5973, '36602-68R40(1)-1-P', '23.5897', 1, '2018-04-11 16:48:13'),
(5974, '36602-68R50(1)-1-P', '23.6938', 1, '2018-04-11 16:48:13'),
(5975, '36602-68R60(1)-1-P', '24.3847', 1, '2018-04-11 16:48:13'),
(5976, '36602-68R70(1)-1-P', '24.4888', 1, '2018-04-11 16:48:13'),
(5977, '36602-68R80(1)-1-P', '19.5801', 1, '2018-04-11 16:48:13'),
(5978, '36602-68R90(1)-1-P', '21.2109', 1, '2018-04-11 16:48:13'),
(5979, '36620-57R00-3-P', '12.8569', 1, '2018-04-11 16:48:13'),
(5980, '36620-57R10-3-P', '15.8752', 1, '2018-04-11 16:48:13'),
(5981, '36620-57R20-3-P', '20.9983', 1, '2018-04-11 16:48:13'),
(5982, '36620-57R30-3-P', '15.4729', 1, '2018-04-11 16:48:13'),
(5983, '36620-57R40-3-P', '20.2868', 1, '2018-04-11 16:48:13'),
(5984, '36620-57R50-3-P', '19.4717', 1, '2018-04-11 16:48:13'),
(5985, '36620-57R60-3-P', '14.6578', 1, '2018-04-11 16:48:13'),
(5986, '36602-57R00-3-P', '15.2379', 1, '2018-04-11 16:48:13'),
(5987, '36602-57R10-3-P', '20.0515', 1, '2018-04-11 16:48:13'),
(5988, '36602-57R20-3-P', '19.255', 1, '2018-04-11 16:48:13'),
(5989, '36602-57R30-3-P', '14.4414', 1, '2018-04-11 16:48:14'),
(5990, '33880-63RC0-1-P', '0', 1, '2018-04-11 16:48:14'),
(5991, '33880-79R00-2-P', '0', 1, '2018-04-11 16:48:14'),
(5992, '36680-79R00-3-P', '1.9303', 1, '2018-04-11 16:48:14'),
(5993, '36680-79R20-3-P', '2.3448', 1, '2018-04-11 16:48:14'),
(5994, '36680-79R30-3-P', '2.3448', 1, '2018-04-11 16:48:14'),
(5995, '36820-79R00-4-P', '0.6567', 1, '2018-04-11 16:48:14'),
(5996, '36820-79R10-4-P', '0.9698', 1, '2018-04-11 16:48:14'),
(5997, '36820-79R20-4-P', '0.8751', 1, '2018-04-11 16:48:14'),
(5998, '36820-79R30-4-P', '1.1882', 1, '2018-04-11 16:48:14'),
(5999, '36820-79R40-4-P', '1.0848', 1, '2018-04-11 16:48:14'),
(6000, '36820-79R50-4-P', '1.398', 1, '2018-04-11 16:48:14'),
(6001, '36820-79R60-4-P', '1.3032', 1, '2018-04-11 16:48:14'),
(6002, '36820-79R70-4-P', '1.6164', 1, '2018-04-11 16:48:14'),
(6003, '36813-79R50-1-P', '0.4296', 1, '2018-04-11 16:48:14'),
(6004, '36813-79R00-2-P', '1.4487', 1, '2018-04-11 16:48:14'),
(6005, '36756-79R00-5-P', '3.9272', 1, '2018-04-11 16:48:14'),
(6006, '36756-79R20-5-P', '4.2298', 1, '2018-04-11 16:48:14'),
(6007, '36756-79R30-5-P', '4.2298', 1, '2018-04-11 16:48:14'),
(6008, '36756-79R40-5-P', '4.2364', 1, '2018-04-11 16:48:14'),
(6009, '36756-79R50-5-P', '4.4388', 1, '2018-04-11 16:48:14'),
(6010, '36756-79R60-5-P', '4.6712', 1, '2018-04-11 16:48:14'),
(6011, '36756-79R70-5-P', '4.6712', 1, '2018-04-11 16:48:14'),
(6012, '36756-79R80-5-P', '4.4388', 1, '2018-04-11 16:48:14'),
(6013, '36756-79R90-5-P', '4.2364', 1, '2018-04-11 16:48:14'),
(6014, '36757-79R00-3-P', '1.6573', 1, '2018-04-11 16:48:14'),
(6015, '36757-79R20-3-P', '1.9607', 1, '2018-04-11 16:48:15'),
(6016, '36757-79R30-3-P', '2.1637', 1, '2018-04-11 16:48:15'),
(6017, '36757-79R40-3-P', '2.3962', 1, '2018-04-11 16:48:15'),
(6018, '36757-79R50-3-P', '2.3962', 1, '2018-04-11 16:48:15'),
(6019, '36757-79R60-3-P', '2.1637', 1, '2018-04-11 16:48:15'),
(6020, '36757-79R70-3-P', '1.9607', 1, '2018-04-11 16:48:15'),
(6021, '36751-79R00-4-P', '0.4217', 1, '2018-04-11 16:48:15'),
(6022, '36751-79R10-4-P', '1.4114', 1, '2018-04-11 16:48:15'),
(6023, '36751-79RC0-4-P', '1.4114', 1, '2018-04-11 16:48:15'),
(6024, '36690-79R00-1-P', '0.2', 1, '2018-04-11 16:48:15'),
(6025, '36602-79R00-5-P', '19.5992', 1, '2018-04-11 16:48:15'),
(6026, '36602-79R20-5-P', '22.626', 1, '2018-04-11 16:48:15'),
(6027, '36620-79R00-5-P', '21.5177', 1, '2018-04-11 16:48:15'),
(6028, '36620-79R10-5-P', '23.7428', 1, '2018-04-11 16:48:15'),
(6029, '36620-79R20-5-P', '23.8338', 1, '2018-04-11 16:48:15'),
(6030, '36620-79R30-5-P', '26.0699', 1, '2018-04-11 16:48:15'),
(6031, '36620-79R40-5-P', '23.3356', 1, '2018-04-11 16:48:15'),
(6032, '36620-79R50-5-P', '25.5718', 1, '2018-04-11 16:48:15'),
(6033, '36620-79R60-5-P', '24.2299', 1, '2018-04-11 16:48:15'),
(6034, '36620-79R70-5-P', '26.2596', 1, '2018-04-11 16:48:15'),
(6035, '36620-79R80-5-P', '26.546', 1, '2018-04-11 16:48:15'),
(6036, '36620-79R90-5-P', '28.5867', 1, '2018-04-11 16:48:16'),
(6037, '36620-79RA0-5-P', '26.0478', 1, '2018-04-11 16:48:16'),
(6038, '36620-79RB0-5-P', '28.0886', 1, '2018-04-11 16:48:16'),
(6039, '36620-79RC0-5-P', '23.7395', 1, '2018-04-11 16:48:16'),
(6040, '36620-79RD0-5-P', '26.4517', 1, '2018-04-11 16:48:16'),
(6041, '36620-79RE0-5-P', '23.117', 1, '2018-04-11 16:48:16'),
(6042, '36620-79RF0-5-P', '25.3421', 1, '2018-04-11 16:48:16'),
(6043, '36620-79RG0-5-P', '25.4331', 1, '2018-04-11 16:48:16'),
(6044, '36620-79RH0-5-P', '27.6692', 1, '2018-04-11 16:48:16'),
(6045, '36620-79RJ0-5-P', '24.9349', 1, '2018-04-11 16:48:16'),
(6046, '36620-79RK0-5-P', '27.171', 1, '2018-04-11 16:48:16'),
(6047, '36620-79RL0-5-P', '25.3388', 1, '2018-04-11 16:48:16'),
(6048, '36920-79R00-5-P', '24.2473', 1, '2018-04-11 16:48:16'),
(6049, '36920-79R10-5-P', '26.0796', 1, '2018-04-11 16:48:16'),
(6050, '36920-79R20-5-P', '23.7492', 1, '2018-04-11 16:48:16'),
(6051, '36920-79R30-5-P', '25.5815', 1, '2018-04-11 16:48:16'),
(6052, '36920-79R40-5-P', '26.9595', 1, '2018-04-11 16:48:16'),
(6053, '36920-79R50-5-P', '28.5964', 1, '2018-04-11 16:48:16'),
(6054, '36920-79R60-5-P', '26.4614', 1, '2018-04-11 16:48:16'),
(6055, '36920-79R70-5-P', '28.0983', 1, '2018-04-11 16:48:16'),
(6056, '36920-79R80-5-P', '24.1708', 1, '2018-04-11 16:48:16'),
(6057, '36920-79R90-5-P', '26.0031', 1, '2018-04-11 16:48:16'),
(6058, '36920-79RA0-5-P', '26.883', 1, '2018-04-11 16:48:16'),
(6059, '36920-79RB0-5-P', '28.5199', 1, '2018-04-11 16:48:17'),
(6060, '36920-79RC0-5-P', '25.7701', 1, '2018-04-11 16:48:17'),
(6061, '36920-79RD0-5-P', '27.6024', 1, '2018-04-11 16:48:17'),
(6062, '36603-79R00-5-P', '9.202', 1, '2018-04-11 16:48:17'),
(6063, '36603-79R10-5-P', '10.8789', 1, '2018-04-11 16:48:17'),
(6064, '36603-79R20-5-P', '9.4043', 1, '2018-04-11 16:48:17'),
(6065, '36603-79R30-5-P', '11.0812', 1, '2018-04-11 16:48:17'),
(6066, '36630-79R00-5-P', '14.9542', 1, '2018-04-11 16:48:17'),
(6067, '36630-79R10-5-P', '13.1866', 1, '2018-04-11 16:48:17'),
(6068, '36630-79R20-5-P', '16.6311', 1, '2018-04-11 16:48:17'),
(6069, '36630-79R40-5-P', '15.3476', 1, '2018-04-11 16:48:17'),
(6070, '36630-79R60-5-P', '17.0245', 1, '2018-04-11 16:48:17'),
(6071, '36630-79R70-5-P', '15.931', 1, '2018-04-11 16:48:17'),
(6072, '36630-79R80-5-P', '17.6079', 1, '2018-04-11 16:48:17'),
(6073, '36630-79R90-5-P', '11.7119', 1, '2018-04-11 16:48:17'),
(6074, '36630-79RA0-5-P', '15.1627', 1, '2018-04-11 16:48:17'),
(6075, '36630-79RB0-5-P', '13.3888', 1, '2018-04-11 16:48:17'),
(6076, '36630-79RC0-5-P', '16.8396', 1, '2018-04-11 16:48:17'),
(6077, '36630-79RE0-5-P', '15.6878', 1, '2018-04-11 16:48:17'),
(6078, '36630-79RG0-5-P', '17.3647', 1, '2018-04-11 16:48:17'),
(6079, '36630-79RH0-5-P', '16.2713', 1, '2018-04-11 16:48:17'),
(6080, '36630-79RJ0-5-P', '17.9481', 1, '2018-04-11 16:48:17'),
(6081, '36630-79RK0-5-P', '11.5096', 1, '2018-04-11 16:48:17'),
(6082, '36630-79RL0-5-P', '11.8778', 1, '2018-04-11 16:48:17'),
(6083, '36650-79R00-7-P', '11.2475', 1, '2018-04-11 16:48:17'),
(6084, '36650-79R10-7-P', '10.0544', 1, '2018-04-11 16:48:17'),
(6085, '36650-79R20-7-P', '10.7936', 1, '2018-04-11 16:48:18'),
(6086, '33880-76R00-1-P', '0', 1, '2018-04-11 16:48:18'),
(6087, '36680-76R00-4-P', '1.7861', 1, '2018-04-11 16:48:18'),
(6088, '36680-76R10-4-P', '1.7861', 1, '2018-04-11 16:48:18'),
(6089, '36820-76R00-3-P', '0.6468', 1, '2018-04-11 16:48:18'),
(6090, '36820-76R10-3-P', '1.0658', 1, '2018-04-11 16:48:18'),
(6091, '36820-76R20-3-P', '0.9583', 1, '2018-04-11 16:48:18'),
(6092, '36820-76R30-3-P', '1.3774', 1, '2018-04-11 16:48:18'),
(6093, '36843-76R00-2-P', '0.2238', 1, '2018-04-11 16:48:18'),
(6094, '36843-76R10-2-P', '1.695', 1, '2018-04-11 16:48:18'),
(6095, '36756-76R00-3-P', '4.2432', 1, '2018-04-11 16:48:18'),
(6096, '36756-76R10-3-P', '4.2432', 1, '2018-04-11 16:48:18'),
(6097, '36756-76R20-3-P', '4.4815', 1, '2018-04-11 16:48:18'),
(6098, '36756-76R30-3-P', '4.4815', 1, '2018-04-11 16:48:18'),
(6099, '36757-76R00-2-P', '1.917', 1, '2018-04-11 16:48:18'),
(6100, '36757-76R10-2-P', '1.917', 1, '2018-04-11 16:48:18'),
(6101, '36757-76R20-2-P', '2.1554', 1, '2018-04-11 16:48:18'),
(6102, '36757-76R30-2-P', '2.1554', 1, '2018-04-11 16:48:18'),
(6103, '36751-76R00-3-P', '0.9105', 1, '2018-04-11 16:48:18'),
(6104, '36630-76R20-4-P', '11.5895', 1, '2018-04-11 16:48:18'),
(6105, '36630-76R30-4-P', '14.8234', 1, '2018-04-11 16:48:18'),
(6106, '36630-76R60-4-P', '12.0157', 1, '2018-04-11 16:48:18'),
(6107, '36630-76R70-4-P', '15.2362', 1, '2018-04-11 16:48:18'),
(6108, '36630-76R80-4-P', '12.1209', 1, '2018-04-11 16:48:18'),
(6109, '36630-76R90-4-P', '15.3415', 1, '2018-04-11 16:48:18'),
(6110, '36851-31J10-4-P', '0.0972', 1, '2018-04-11 16:48:18'),
(6111, '36854-31J20-3-P', '0.379', 1, '2018-04-11 16:48:19'),
(6112, '36856-31J10-4-P', '0.6649', 1, '2018-04-11 16:48:19'),
(6113, '33860-31J10-3-P', '0.3902', 1, '2018-04-11 16:48:19'),
(6114, '33810-31J10-3-P', '0', 1, '2018-04-11 16:48:19'),
(6115, '36610-31JK0(1)-1-P', '20.7102', 1, '2018-04-11 16:48:19'),
(6116, '36610-31JQ0(1)-1-P', '19.3023', 1, '2018-04-11 16:48:19'),
(6117, '36610-31JN0(1)-1-P', '18.8213', 1, '2018-04-11 16:48:19'),
(6118, '36610-31JP0(1)-1-P', '19.0441', 1, '2018-04-11 16:48:19'),
(6119, '36620-31J10-5-P', '3.3549', 1, '2018-04-11 16:48:19'),
(6120, 'YSD-LHD-AL1-1', '0.305', 1, '2018-04-11 16:48:19'),
(6121, 'YSD-LHD-CI1-1', '0.3242', 1, '2018-04-11 16:48:19'),
(6122, 'YSD-RHD-AL1', '0.3147', 1, '2018-04-11 16:48:19'),
(6123, 'YSD-RHD-CI1-1', '0.3245', 1, '2018-04-11 16:48:19'),
(6124, 'YSD-RHD-CI2-1', '0.5408', 1, '2018-04-11 16:48:19'),
(6125, 'YHB-FLR-AL0-1', '0.3487', 1, '2018-04-11 16:48:19'),
(6126, 'YHB-FLR-AL1-1', '0.5284', 1, '2018-04-11 16:48:19'),
(6127, '24011-5WH1A-0100P3', '18.4327', 1, '2018-04-11 16:48:19'),
(6128, '24011-5WJ0A-0000P2', '14.8264', 1, '2018-04-11 16:48:19'),
(6129, '24011-5WJ0B-0000P2', '13.8127', 1, '2018-04-11 16:48:19'),
(6130, '24011-1A27A-0301P4', '9.8694', 1, '2018-04-11 16:48:19'),
(6131, '24011-5WK0A-050101', '13.0985', 1, '2018-04-11 16:48:19'),
(6132, '24079-5WK0A-0200', '0.1897', 1, '2018-04-11 16:48:19');

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
  ADD PRIMARY KEY (`ID`),
  ADD KEY `updated_by` (`updated_by`);

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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT for table `eff_2_normal_wt`
--
ALTER TABLE `eff_2_normal_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `eff_3_extended_wt`
--
ALTER TABLE `eff_3_extended_wt`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT for table `eff_account`
--
ALTER TABLE `eff_account`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `eff_account_type`
--
ALTER TABLE `eff_account_type`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `eff_batch_control`
--
ALTER TABLE `eff_batch_control`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=316;

--
-- AUTO_INCREMENT for table `eff_batch_group`
--
ALTER TABLE `eff_batch_group`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=915;

--
-- AUTO_INCREMENT for table `eff_product_st`
--
ALTER TABLE `eff_product_st`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6135;

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

--
-- Constraints for table `eff_product_st`
--
ALTER TABLE `eff_product_st`
  ADD CONSTRAINT `eff_product_st_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `eff_account` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
