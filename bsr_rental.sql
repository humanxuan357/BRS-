/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 50524
 Source Host           : localhost:3306
 Source Schema         : bsr_rental

 Target Server Type    : MySQL
 Target Server Version : 50524
 File Encoding         : 65001

 Date: 18/10/2026 23:49:39
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for audit_log
-- ----------------------------
DROP TABLE IF EXISTS `audit_log`;
CREATE TABLE `audit_log`  (
  `log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志编号',
  `employee_id` int(11) NULL DEFAULT NULL COMMENT '操作人编号',
  `actor_type` enum('员工','分包商','顾客','系统') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作者类型',
  `operate_time` datetime NOT NULL COMMENT '操作时间',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '业务模块(合同/设备/支付/维修/排班/采购等)',
  `table_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '数据表',
  `record_id` int(11) NULL DEFAULT NULL COMMENT '记录编号',
  `action` enum('新增','修改','删除','查询导出','登录','审批') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作类型',
  `before_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '修改前内容(JSON文本)',
  `after_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '修改后内容(JSON文本)',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作IP',
  `is_high_risk` tinyint(4) NOT NULL DEFAULT 0 COMMENT '高危操作标记(删除台账/修改费率等为1)',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `fk_audit_employee`(`employee_id`) USING BTREE,
  CONSTRAINT `fk_audit_employee` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '审计日志表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of audit_log
-- ----------------------------

-- ----------------------------
-- Table structure for compensation
-- ----------------------------
DROP TABLE IF EXISTS `compensation`;
CREATE TABLE `compensation`  (
  `comp_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '赔偿编号',
  `contract_id` int(11) NOT NULL COMMENT '合同编号',
  `customer_id` int(11) NOT NULL COMMENT '客户编号',
  `equipment_id` int(11) NOT NULL COMMENT '库存编号',
  `comp_reason` enum('设备丢失','人为损坏') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '赔偿原因',
  `assessed_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '定损金额',
  `actual_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '实际赔付金额',
  `deposit_offset` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '押金抵扣金额',
  `employee_id` int(11) NOT NULL COMMENT '登记员工编号',
  `comp_time` datetime NOT NULL COMMENT '登记时间',
  `status` enum('待赔付','部分赔付','已赔付') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '待赔付' COMMENT '赔偿状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`comp_id`) USING BTREE,
  INDEX `fk_comp_contract`(`contract_id`) USING BTREE,
  INDEX `fk_comp_customer`(`customer_id`) USING BTREE,
  INDEX `fk_comp_equipment`(`equipment_id`) USING BTREE,
  INDEX `fk_comp_employee`(`employee_id`) USING BTREE,
  CONSTRAINT `fk_comp_contract` FOREIGN KEY (`contract_id`) REFERENCES `contract` (`contract_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_comp_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_comp_employee` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_comp_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`equipment_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '设备赔偿表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of compensation
-- ----------------------------

-- ----------------------------
-- Table structure for contract
-- ----------------------------
DROP TABLE IF EXISTS `contract`;
CREATE TABLE `contract`  (
  `contract_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '合同编号',
  `contract_no` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '合同号',
  `contract_date` date NOT NULL COMMENT '合同日期',
  `rent_days` int(11) NOT NULL COMMENT '租赁时长(天)',
  `contract_type` enum('即时到店','预约预租','团体') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '合同类型',
  `customer_id` int(11) NOT NULL COMMENT '客户编号',
  `employee_id` int(11) NOT NULL COMMENT '经办员工编号',
  `skill_id` tinyint(4) NULL DEFAULT NULL COMMENT '本次租用技能等级',
  `store_id` int(11) NOT NULL COMMENT '租赁门店编号',
  `return_store_id` int(11) NULL DEFAULT NULL COMMENT '实际归还门店编号',
  `total_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '应付总额',
  `deposit_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '押金金额',
  `deposit_status` enum('未收','已收','已退','已抵扣') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '未收' COMMENT '押金状态',
  `status` enum('预约中','执行中','已完成','已取消','已逾期') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '执行中' COMMENT '合同状态',
  `booking_slot` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '预约到店时段',
  `booking_expire_time` datetime NULL DEFAULT NULL COMMENT '预约保留到期时间(到期自动释放库存)',
  `slot_quota` int(11) NULL DEFAULT NULL COMMENT '时段预约流量上限',
  `member_count` int(11) NULL DEFAULT NULL COMMENT '团体成员人数(团体合同)',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '取消时间(装备未借出方可取消)',
  `overdue_flag` tinyint(4) NOT NULL DEFAULT 0 COMMENT '逾期标记',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`contract_id`) USING BTREE,
  UNIQUE INDEX `contract_no`(`contract_no`) USING BTREE,
  INDEX `fk_contract_customer`(`customer_id`) USING BTREE,
  INDEX `fk_contract_employee`(`employee_id`) USING BTREE,
  INDEX `fk_contract_skill`(`skill_id`) USING BTREE,
  INDEX `fk_contract_store`(`store_id`) USING BTREE,
  INDEX `fk_contract_return_store`(`return_store_id`) USING BTREE,
  CONSTRAINT `fk_contract_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contract_employee` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contract_return_store` FOREIGN KEY (`return_store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contract_skill` FOREIGN KEY (`skill_id`) REFERENCES `skill_level` (`skill_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contract_store` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '合同表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of contract
-- ----------------------------

-- ----------------------------
-- Table structure for contract_change
-- ----------------------------
DROP TABLE IF EXISTS `contract_change`;
CREATE TABLE `contract_change`  (
  `change_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '变更编号',
  `contract_id` int(11) NOT NULL COMMENT '合同编号',
  `item_id` int(11) NULL DEFAULT NULL COMMENT '明细编号',
  `change_type` enum('新增','减少','升级','替换') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '变更类型',
  `before_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '变更前数据(JSON文本)',
  `after_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '变更后数据(JSON文本)',
  `diff_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '差价或退款金额(正为补收/负为退款)',
  `employee_id` int(11) NOT NULL COMMENT '操作员工编号',
  `change_time` datetime NOT NULL COMMENT '变更时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`change_id`) USING BTREE,
  INDEX `fk_change_contract`(`contract_id`) USING BTREE,
  INDEX `fk_change_item`(`item_id`) USING BTREE,
  INDEX `fk_change_employee`(`employee_id`) USING BTREE,
  CONSTRAINT `fk_change_contract` FOREIGN KEY (`contract_id`) REFERENCES `contract` (`contract_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_change_employee` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_change_item` FOREIGN KEY (`item_id`) REFERENCES `contract_item` (`item_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '合同变更历史表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of contract_change
-- ----------------------------

-- ----------------------------
-- Table structure for contract_item
-- ----------------------------
DROP TABLE IF EXISTS `contract_item`;
CREATE TABLE `contract_item`  (
  `item_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '明细编号',
  `contract_id` int(11) NOT NULL COMMENT '合同编号',
  `equipment_id` int(11) NOT NULL COMMENT '库存编号',
  `item_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '物品名称',
  `quantity` int(11) NOT NULL DEFAULT 1 COMMENT '数量',
  `daily_rate` decimal(10, 2) NOT NULL COMMENT '日租金',
  `line_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '行金额',
  `rent_out_time` datetime NULL DEFAULT NULL COMMENT '借出时间(交付装备时写入)',
  `return_time` datetime NULL DEFAULT NULL COMMENT '归还时间(支持部分归还)',
  `return_store_id` int(11) NULL DEFAULT NULL COMMENT '归还门店编号',
  `item_status` enum('已锁定','在租','已归还','已丢失','已替换') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '已锁定' COMMENT '明细状态',
  `overdue_amount` decimal(12, 2) NULL DEFAULT 0.00 COMMENT '超期费用',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`item_id`) USING BTREE,
  UNIQUE INDEX `uk_item_contract_equip_status`(`contract_id`, `equipment_id`, `item_status`) USING BTREE,
  INDEX `fk_item_equipment`(`equipment_id`) USING BTREE,
  INDEX `fk_item_return_store`(`return_store_id`) USING BTREE,
  CONSTRAINT `fk_item_contract` FOREIGN KEY (`contract_id`) REFERENCES `contract` (`contract_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_item_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`equipment_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_item_return_store` FOREIGN KEY (`return_store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '合同明细表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of contract_item
-- ----------------------------

-- ----------------------------
-- Table structure for contractor
-- ----------------------------
DROP TABLE IF EXISTS `contractor`;
CREATE TABLE `contractor`  (
  `contractor_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '分包商编号',
  `contractor_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '通讯地址',
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `current_hourly_rate` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '当前小时费率',
  `avg_repair_minutes` int(11) NULL DEFAULT NULL COMMENT '平均维修时长(分钟,系统统计)',
  `rework_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '返修率(系统统计)',
  `performance_score` decimal(5, 2) NULL DEFAULT NULL COMMENT '绩效评分(系统统计)',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '合作中' COMMENT '合作状态',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`contractor_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '分包商表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of contractor
-- ----------------------------

-- ----------------------------
-- Table structure for customer
-- ----------------------------
DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer`  (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '客户编号',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '姓名',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '电子邮箱(回头客识别标识)',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '家庭住址',
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话号码',
  `birth_year` smallint(6) NULL DEFAULT NULL COMMENT '估算出生年份',
  `height_cm` smallint(6) NULL DEFAULT NULL COMMENT '身高(cm)',
  `weight_kg` decimal(5, 1) NULL DEFAULT NULL COMMENT '体重(kg)',
  `shoe_size` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '鞋码',
  `member_points` int(11) NOT NULL DEFAULT 0 COMMENT '会员积分',
  `member_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '会员等级',
  `risk_flag` tinyint(4) NOT NULL DEFAULT 0 COMMENT '风险标签(0正常/1风险)',
  `risk_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '风险说明',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '正常' COMMENT '档案状态(含已合并)',
  `merged_to_customer_id` int(11) NULL DEFAULT NULL COMMENT '合并至客户编号',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`customer_id`) USING BTREE,
  UNIQUE INDEX `uk_customer_email`(`email`) USING BTREE,
  INDEX `fk_customer_merged`(`merged_to_customer_id`) USING BTREE,
  CONSTRAINT `fk_customer_merged` FOREIGN KEY (`merged_to_customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '客户表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of customer
-- ----------------------------

-- ----------------------------
-- Table structure for employee
-- ----------------------------
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee`  (
  `employee_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '员工编号',
  `employee_no` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '工号',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '姓名',
  `password_hash` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录密码哈希',
  `role` enum('前台员工','门店店长','总部管理员') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '系统角色',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '住址',
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `position` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '岗位',
  `hire_date` date NOT NULL COMMENT '入职日期',
  `base_salary` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '基础工资',
  `rotation_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '轮岗与特长备注',
  `home_store_id` int(11) NULL DEFAULT NULL COMMENT '所属门店编号',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '在职' COMMENT '在职状态',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`employee_id`) USING BTREE,
  UNIQUE INDEX `uk_employee_no`(`employee_no`) USING BTREE,
  UNIQUE INDEX `uk_employee_email`(`email`) USING BTREE,
  INDEX `fk_employee_home_store`(`home_store_id`) USING BTREE,
  CONSTRAINT `fk_employee_home_store` FOREIGN KEY (`home_store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '员工表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of employee
-- ----------------------------

-- ----------------------------
-- Table structure for equip_category
-- ----------------------------
DROP TABLE IF EXISTS `equip_category`;
CREATE TABLE `equip_category`  (
  `category_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '类别编号',
  `category_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '类别名称',
  `need_skill_flag` tinyint(4) NOT NULL DEFAULT 1 COMMENT '是否需绑定技能等级(配件类固定为0)',
  `is_unique_item` tinyint(4) NOT NULL DEFAULT 1 COMMENT '是否唯一单件物品(雪杖等可计数类为0)',
  `safety_stock` int(11) NOT NULL DEFAULT 0 COMMENT '默认安全库存阈值',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`category_id`) USING BTREE,
  UNIQUE INDEX `category_name`(`category_name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '设备类别表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of equip_category
-- ----------------------------

-- ----------------------------
-- Table structure for equipment
-- ----------------------------
DROP TABLE IF EXISTS `equipment`;
CREATE TABLE `equipment`  (
  `equipment_id` int(11) NOT NULL COMMENT '库存编号(物理压印唯一编号)',
  `equipment_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述',
  `category_id` int(11) NOT NULL COMMENT '类别编号',
  `skill_id` tinyint(4) NULL DEFAULT NULL COMMENT '技能等级编号(配件类强制为空)',
  `purchase_date` date NULL DEFAULT NULL COMMENT '购入日期',
  `purchase_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '购入成本',
  `retail_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '零售价',
  `daily_rate` decimal(10, 2) NOT NULL COMMENT '日租金',
  `status` enum('可租','在租','维修中','待处理','待配件','已报废') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '可租' COMMENT '设备状态',
  `storage_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '存放位置',
  `store_id` int(11) NOT NULL COMMENT '归属门店编号',
  `lock_flag` tinyint(4) NOT NULL DEFAULT 0 COMMENT '库存锁标记(0未锁/1已锁,防超租)',
  `lock_time` datetime NULL DEFAULT NULL COMMENT '加锁时间',
  `lock_contract_id` int(11) NULL DEFAULT NULL COMMENT '占用合同编号',
  `rent_count` int(11) NOT NULL DEFAULT 0 COMMENT '累计租赁次数',
  `maint_count` int(11) NOT NULL DEFAULT 0 COMMENT '累计维修次数',
  `aging_alert` tinyint(4) NOT NULL DEFAULT 0 COMMENT '老化更换预警',
  `scrap_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '报废审批状态(待审批/已批准/已驳回)',
  `scrap_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '报废原因',
  `scrap_residual_value` decimal(10, 2) NULL DEFAULT NULL COMMENT '报废残值',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`equipment_id`) USING BTREE,
  INDEX `fk_equipment_category`(`category_id`) USING BTREE,
  INDEX `fk_equipment_skill`(`skill_id`) USING BTREE,
  INDEX `fk_equipment_store`(`store_id`) USING BTREE,
  INDEX `fk_equipment_lock_contract`(`lock_contract_id`) USING BTREE,
  CONSTRAINT `fk_equipment_category` FOREIGN KEY (`category_id`) REFERENCES `equip_category` (`category_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_equipment_lock_contract` FOREIGN KEY (`lock_contract_id`) REFERENCES `contract` (`contract_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_equipment_skill` FOREIGN KEY (`skill_id`) REFERENCES `skill_level` (`skill_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_equipment_store` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '设备表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of equipment
-- ----------------------------

-- ----------------------------
-- Table structure for maint_material
-- ----------------------------
DROP TABLE IF EXISTS `maint_material`;
CREATE TABLE `maint_material`  (
  `material_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '耗材编号',
  `mo_id` int(11) NOT NULL COMMENT '维修单号',
  `material_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '零件/耗材名称',
  `quantity` int(11) NOT NULL DEFAULT 1 COMMENT '数量',
  `unit_cost` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '单位成本',
  `amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '金额',
  `replace_time` datetime NULL DEFAULT NULL COMMENT '更换时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`material_id`) USING BTREE,
  INDEX `fk_material_mo`(`mo_id`) USING BTREE,
  CONSTRAINT `fk_material_mo` FOREIGN KEY (`mo_id`) REFERENCES `maint_order` (`mo_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '维修耗材表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of maint_material
-- ----------------------------

-- ----------------------------
-- Table structure for maint_order
-- ----------------------------
DROP TABLE IF EXISTS `maint_order`;
CREATE TABLE `maint_order`  (
  `mo_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '维修单号',
  `mo_no` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '维修单编号',
  `equipment_id` int(11) NOT NULL COMMENT '库存编号',
  `apply_date` date NOT NULL COMMENT '申请日期',
  `fault_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '故障描述',
  `status` enum('待分配','待配件','维修中','已完成','无法修复') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '待分配' COMMENT '维修状态',
  `contractor_id` int(11) NULL DEFAULT NULL COMMENT '分包商编号(可空,重新指派)',
  `prev_contractor_id` int(11) NULL DEFAULT NULL COMMENT '原分包商编号(重新指派留痕)',
  `reassign_time` datetime NULL DEFAULT NULL COMMENT '重新分配时间',
  `repair_date` date NULL DEFAULT NULL COMMENT '维修日期',
  `repair_minutes` int(11) NULL DEFAULT NULL COMMENT '维修时长(分钟,15的整数倍)',
  `hourly_rate` decimal(10, 2) NULL DEFAULT NULL COMMENT '适用小时费率(历史留档)',
  `repair_fee` decimal(10, 2) NULL DEFAULT NULL COMMENT '维修费用',
  `accept_score` tinyint(4) NULL DEFAULT NULL COMMENT '验收评分(1-5分)',
  `accept_employee_id` int(11) NULL DEFAULT NULL COMMENT '验收员工编号',
  `accept_time` datetime NULL DEFAULT NULL COMMENT '验收时间',
  `is_rework` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否返修',
  `create_employee_id` int(11) NOT NULL COMMENT '创建员工编号',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`mo_id`) USING BTREE,
  UNIQUE INDEX `mo_no`(`mo_no`) USING BTREE,
  INDEX `fk_mo_equipment`(`equipment_id`) USING BTREE,
  INDEX `fk_mo_contractor`(`contractor_id`) USING BTREE,
  INDEX `fk_mo_accept_employee`(`accept_employee_id`) USING BTREE,
  INDEX `fk_mo_create_employee`(`create_employee_id`) USING BTREE,
  CONSTRAINT `fk_mo_accept_employee` FOREIGN KEY (`accept_employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_mo_contractor` FOREIGN KEY (`contractor_id`) REFERENCES `contractor` (`contractor_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_mo_create_employee` FOREIGN KEY (`create_employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_mo_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`equipment_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '维修单表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of maint_order
-- ----------------------------

-- ----------------------------
-- Table structure for payment
-- ----------------------------
DROP TABLE IF EXISTS `payment`;
CREATE TABLE `payment`  (
  `payment_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '流水编号',
  `payment_no` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '流水号',
  `contract_id` int(11) NULL DEFAULT NULL COMMENT '合同编号',
  `source_type` enum('租赁合同','采购订单','维修单','赔偿单') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '来源单据类型',
  `source_id` int(11) NOT NULL COMMENT '来源单据编号',
  `flow_direction` enum('收入','支出') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '收支方向',
  `biz_category` enum('租金','差价','退款','押金收','押金退','赔偿金','采购支出','维修费','逾期费') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '业务类别',
  `amount` decimal(12, 2) NOT NULL COMMENT '金额',
  `count_in_revenue` tinyint(4) NOT NULL DEFAULT 1 COMMENT '是否计入营业收入(押金类固定为0)',
  `pay_channel` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '支付渠道(第三方支付)',
  `third_party_no` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '第三方支付流水号',
  `pay_status` enum('待支付','已支付','已退款','失败') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '待支付' COMMENT '支付状态',
  `occurred_at` datetime NOT NULL COMMENT '发生时间',
  `settle_period` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '结算周期(周/月/季度标识)',
  `settle_status` enum('未结算','已结算') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '未结算' COMMENT '结算状态',
  `store_id` int(11) NULL DEFAULT NULL COMMENT '归属门店编号',
  `employee_id` int(11) NULL DEFAULT NULL COMMENT '操作人编号',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`payment_id`) USING BTREE,
  UNIQUE INDEX `payment_no`(`payment_no`) USING BTREE,
  UNIQUE INDEX `third_party_no`(`third_party_no`) USING BTREE,
  INDEX `fk_payment_contract`(`contract_id`) USING BTREE,
  INDEX `fk_payment_store`(`store_id`) USING BTREE,
  INDEX `fk_payment_employee`(`employee_id`) USING BTREE,
  CONSTRAINT `fk_payment_contract` FOREIGN KEY (`contract_id`) REFERENCES `contract` (`contract_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_payment_employee` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_payment_store` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '支付流水表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of payment
-- ----------------------------

-- ----------------------------
-- Table structure for purchase_order
-- ----------------------------
DROP TABLE IF EXISTS `purchase_order`;
CREATE TABLE `purchase_order`  (
  `po_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '采购单号',
  `po_no` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '采购订单编号',
  `supplier_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '供应商名称',
  `supplier_contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商联系人',
  `supplier_phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商电话',
  `supplier_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '供应商地址',
  `purchase_date` date NOT NULL COMMENT '采购日期',
  `item_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '设备清单(JSON文本:类别/数量/单价)',
  `total_amount` decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT '采购总金额',
  `accept_status` enum('待到货','待验收','验收合格','验收不合格') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '待到货' COMMENT '到货验收状态',
  `accept_date` date NULL DEFAULT NULL COMMENT '验收日期',
  `accept_employee_id` int(11) NULL DEFAULT NULL COMMENT '验收人编号',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '验收不合格原因',
  `store_id` int(11) NULL DEFAULT NULL COMMENT '入库门店编号',
  `stock_in_date` date NULL DEFAULT NULL COMMENT '入库日期(仅验收合格后写入)',
  `flow_flag` tinyint(4) NOT NULL DEFAULT 0 COMMENT '已生成资金流水标记(0未生成/1已生成)',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`po_id`) USING BTREE,
  UNIQUE INDEX `po_no`(`po_no`) USING BTREE,
  INDEX `fk_po_accept_employee`(`accept_employee_id`) USING BTREE,
  INDEX `fk_po_store`(`store_id`) USING BTREE,
  CONSTRAINT `fk_po_accept_employee` FOREIGN KEY (`accept_employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_po_store` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '采购订单表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of purchase_order
-- ----------------------------

-- ----------------------------
-- Table structure for shift
-- ----------------------------
DROP TABLE IF EXISTS `shift`;
CREATE TABLE `shift`  (
  `shift_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '排班编号',
  `employee_id` int(11) NOT NULL COMMENT '员工编号',
  `store_id` int(11) NOT NULL COMMENT '门店编号',
  `shift_date` date NOT NULL COMMENT '排班日期',
  `start_time` time NOT NULL COMMENT '开始时间',
  `end_time` time NOT NULL COMMENT '结束时间',
  `shift_type` enum('正常','请假','调班','换班','替班') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '正常' COMMENT '班次类型',
  `apply_status` enum('无需审批','待审批','已通过','已驳回') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '无需审批' COMMENT '审批状态',
  `applicant_id` int(11) NULL DEFAULT NULL COMMENT '申请人编号',
  `approver_id` int(11) NULL DEFAULT NULL COMMENT '审批人(店长)编号',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`shift_id`) USING BTREE,
  UNIQUE INDEX `uk_shift_emp_date`(`employee_id`, `shift_date`) USING BTREE,
  INDEX `fk_shift_store`(`store_id`) USING BTREE,
  INDEX `fk_shift_applicant`(`applicant_id`) USING BTREE,
  INDEX `fk_shift_approver`(`approver_id`) USING BTREE,
  CONSTRAINT `fk_shift_applicant` FOREIGN KEY (`applicant_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_shift_approver` FOREIGN KEY (`approver_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_shift_employee` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_shift_store` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '排班表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of shift
-- ----------------------------

-- ----------------------------
-- Table structure for skill_level
-- ----------------------------
DROP TABLE IF EXISTS `skill_level`;
CREATE TABLE `skill_level`  (
  `skill_id` tinyint(4) NOT NULL AUTO_INCREMENT COMMENT '技能等级编号',
  `skill_name` enum('初级','中级','高级','专家+') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '等级名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '等级说明',
  `sort_order` tinyint(4) NOT NULL DEFAULT 0 COMMENT '排序序号',
  PRIMARY KEY (`skill_id`) USING BTREE,
  UNIQUE INDEX `skill_name`(`skill_name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '技能等级表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of skill_level
-- ----------------------------
INSERT INTO `skill_level` VALUES (1, '初级', '滑雪新手，适合初学者装备', 1);
INSERT INTO `skill_level` VALUES (2, '中级', '具备一定滑雪经验', 2);
INSERT INTO `skill_level` VALUES (3, '高级', '熟练滑雪者，适合高性能装备', 3);
INSERT INTO `skill_level` VALUES (4, '专家+', '专业级滑雪者', 4);

-- ----------------------------
-- Table structure for stocktake
-- ----------------------------
DROP TABLE IF EXISTS `stocktake`;
CREATE TABLE `stocktake`  (
  `stocktake_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '盘点编号',
  `stocktake_no` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '盘点单编号',
  `store_id` int(11) NOT NULL COMMENT '盘点门店编号',
  `stocktake_date` date NOT NULL COMMENT '盘点日期',
  `operator_id` int(11) NOT NULL COMMENT '盘点人编号',
  `equipment_id` int(11) NOT NULL COMMENT '库存编号',
  `system_qty` int(11) NOT NULL DEFAULT 1 COMMENT '账面数量',
  `actual_qty` int(11) NOT NULL DEFAULT 0 COMMENT '实际数量',
  `profit_qty` int(11) NOT NULL DEFAULT 0 COMMENT '盘盈数量',
  `loss_qty` int(11) NOT NULL DEFAULT 0 COMMENT '盘亏数量',
  `handle_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '待处理' COMMENT '差异处理状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`stocktake_id`) USING BTREE,
  UNIQUE INDEX `uk_stocktake_no_equip`(`stocktake_no`, `equipment_id`) USING BTREE,
  INDEX `fk_stocktake_store`(`store_id`) USING BTREE,
  INDEX `fk_stocktake_operator`(`operator_id`) USING BTREE,
  INDEX `fk_stocktake_equipment`(`equipment_id`) USING BTREE,
  CONSTRAINT `fk_stocktake_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`equipment_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_stocktake_operator` FOREIGN KEY (`operator_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_stocktake_store` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '盘点单表(扩展)' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of stocktake
-- ----------------------------

-- ----------------------------
-- Table structure for store
-- ----------------------------
DROP TABLE IF EXISTS `store`;
CREATE TABLE `store`  (
  `store_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '门店编号',
  `store_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '门店名称',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '门店地址',
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '门店电话',
  `resort_area` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '所属滑雪度假区',
  `is_main_store` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否主店(0否/1是)',
  `peak_staff_base` int(11) NOT NULL DEFAULT 15 COMMENT '旺季人力基线人数',
  `offpeak_staff_base` int(11) NOT NULL DEFAULT 2 COMMENT '淡季人力基线人数',
  `open_time` time NOT NULL DEFAULT '08:00:00' COMMENT '营业开始时间',
  `close_time` time NOT NULL DEFAULT '22:00:00' COMMENT '营业结束时间',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '营业中' COMMENT '营业状态',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`store_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '门店表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of store
-- ----------------------------
INSERT INTO `store` VALUES (1, 'BSR 主店', '滑雪度假村主入口广场 1 号', NULL, 'BSR 滑雪度假区', 1, 15, 2, '08:00:00', '22:00:00', '营业中', '2026-10-18 23:09:23', NULL);
INSERT INTO `store` VALUES (2, 'BSR 分店', '滑雪度假村东侧服务中心', NULL, 'BSR 滑雪度假区', 0, 15, 2, '08:00:00', '22:00:00', '营业中', '2026-10-18 23:09:23', NULL);

-- ----------------------------
-- Table structure for supplier
-- ----------------------------
DROP TABLE IF EXISTS `supplier`;
CREATE TABLE `supplier`  (
  `supplier_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '供应商编号',
  `supplier_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '供应商名称',
  `contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `cooperation_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '合作中' COMMENT '合作状态',
  `created_at` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`supplier_id`) USING BTREE,
  UNIQUE INDEX `supplier_name`(`supplier_name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '供应商表(扩展)' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of supplier
-- ----------------------------

-- ----------------------------
-- Table structure for transfer
-- ----------------------------
DROP TABLE IF EXISTS `transfer`;
CREATE TABLE `transfer`  (
  `transfer_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '调拨单号',
  `transfer_no` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调拨单编号',
  `equipment_id` int(11) NOT NULL COMMENT '库存编号',
  `from_store_id` int(11) NOT NULL COMMENT '调出门店编号',
  `to_store_id` int(11) NOT NULL COMMENT '调入门店编号',
  `operator_id` int(11) NOT NULL COMMENT '操作人编号',
  `transfer_time` datetime NOT NULL COMMENT '调拨时间',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '调拨原因',
  `approve_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '待审批' COMMENT '审批状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`transfer_id`) USING BTREE,
  UNIQUE INDEX `transfer_no`(`transfer_no`) USING BTREE,
  INDEX `fk_transfer_equipment`(`equipment_id`) USING BTREE,
  INDEX `fk_transfer_from_store`(`from_store_id`) USING BTREE,
  INDEX `fk_transfer_to_store`(`to_store_id`) USING BTREE,
  INDEX `fk_transfer_operator`(`operator_id`) USING BTREE,
  CONSTRAINT `fk_transfer_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`equipment_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_transfer_from_store` FOREIGN KEY (`from_store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_transfer_operator` FOREIGN KEY (`operator_id`) REFERENCES `employee` (`employee_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_transfer_to_store` FOREIGN KEY (`to_store_id`) REFERENCES `store` (`store_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '调拨单表(扩展)' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of transfer
-- ----------------------------

-- ----------------------------
-- View structure for v_contract_stats
-- ----------------------------
DROP VIEW IF EXISTS `v_contract_stats`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_contract_stats` AS select `c`.`employee_id` AS `employee_id`,date_format(`c`.`contract_date`,'%Y-%m') AS `period`,count(distinct `c`.`contract_id`) AS `order_count`,coalesce(sum((case when ((`p`.`count_in_revenue` = 1) and (`p`.`flow_direction` = '收入') and (`p`.`biz_category` in ('租金','差价'))) then `p`.`amount` else 0 end)),0) AS `sales_amount` from (`contract` `c` left join `payment` `p` on((`p`.`contract_id` = `c`.`contract_id`))) group by `c`.`employee_id`,date_format(`c`.`contract_date`,'%Y-%m');

-- ----------------------------
-- View structure for v_maint_stats
-- ----------------------------
DROP VIEW IF EXISTS `v_maint_stats`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_maint_stats` AS select `mo`.`create_employee_id` AS `employee_id`,date_format(`mo`.`apply_date`,'%Y-%m') AS `period`,count(0) AS `maint_count` from `maint_order` `mo` group by `mo`.`create_employee_id`,date_format(`mo`.`apply_date`,'%Y-%m');

-- ----------------------------
-- View structure for v_return_stats
-- ----------------------------
DROP VIEW IF EXISTS `v_return_stats`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_return_stats` AS select `c`.`employee_id` AS `employee_id`,date_format(`ci`.`return_time`,'%Y-%m') AS `period`,count(0) AS `return_count` from (`contract_item` `ci` join `contract` `c` on((`ci`.`contract_id` = `c`.`contract_id`))) where (`ci`.`return_time` is not null) group by `c`.`employee_id`,date_format(`ci`.`return_time`,'%Y-%m');

-- ----------------------------
-- View structure for v_salary
-- ----------------------------
DROP VIEW IF EXISTS `v_salary`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_salary` AS select `e`.`employee_id` AS `employee_id`,`e`.`name` AS `employee_name`,coalesce(`cs`.`period`,`rs`.`period`,`ms`.`period`) AS `period`,coalesce(`cs`.`order_count`,0) AS `order_count`,coalesce(`rs`.`return_count`,0) AS `return_count`,coalesce(`ms`.`maint_count`,0) AS `maint_count`,coalesce(`cs`.`sales_amount`,0) AS `sales_amount`,`e`.`base_salary` AS `base_salary`,round((coalesce(`cs`.`sales_amount`,0) * 0.05),2) AS `bonus`,round((`e`.`base_salary` + (coalesce(`cs`.`sales_amount`,0) * 0.05)),2) AS `total_payable` from (((`employee` `e` left join `v_contract_stats` `cs` on((`cs`.`employee_id` = `e`.`employee_id`))) left join `v_return_stats` `rs` on(((`rs`.`employee_id` = `e`.`employee_id`) and (`rs`.`period` = `cs`.`period`)))) left join `v_maint_stats` `ms` on(((`ms`.`employee_id` = `e`.`employee_id`) and (`ms`.`period` = `cs`.`period`))));

-- ----------------------------
-- Triggers structure for table audit_log
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_audit_ts_bi`;
delimiter ;;
CREATE TRIGGER `trg_audit_ts_bi` BEFORE INSERT ON `audit_log` FOR EACH ROW SET NEW.operate_time = NOW()
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table contract
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_contract_bi`;
delimiter ;;
CREATE TRIGGER `trg_contract_bi` BEFORE INSERT ON `contract` FOR EACH ROW BEGIN
  SET NEW.created_at = NOW();
  IF NEW.rent_days <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '租赁时长必须大于 0';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table contract
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_contract_bu`;
delimiter ;;
CREATE TRIGGER `trg_contract_bu` BEFORE UPDATE ON `contract` FOR EACH ROW BEGIN
  IF NEW.rent_days <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '租赁时长必须大于 0';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table contract_change
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_contract_change_ts_bi`;
delimiter ;;
CREATE TRIGGER `trg_contract_change_ts_bi` BEFORE INSERT ON `contract_change` FOR EACH ROW SET NEW.change_time = NOW()
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table contract_item
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_contract_item_bi`;
delimiter ;;
CREATE TRIGGER `trg_contract_item_bi` BEFORE INSERT ON `contract_item` FOR EACH ROW BEGIN
  SET NEW.created_at = NOW();
  IF NEW.quantity < 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '物品数量必须大于等于 1';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table contract_item
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_contract_item_bu`;
delimiter ;;
CREATE TRIGGER `trg_contract_item_bu` BEFORE UPDATE ON `contract_item` FOR EACH ROW BEGIN
  IF NEW.quantity < 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '物品数量必须大于等于 1';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table contractor
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_contractor_ts_bi`;
delimiter ;;
CREATE TRIGGER `trg_contractor_ts_bi` BEFORE INSERT ON `contractor` FOR EACH ROW SET NEW.created_at = NOW()
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table customer
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_customer_ts_bi`;
delimiter ;;
CREATE TRIGGER `trg_customer_ts_bi` BEFORE INSERT ON `customer` FOR EACH ROW SET NEW.created_at = NOW()
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table employee
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_employee_ts_bi`;
delimiter ;;
CREATE TRIGGER `trg_employee_ts_bi` BEFORE INSERT ON `employee` FOR EACH ROW SET NEW.created_at = NOW()
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table equip_category
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_equip_category_ts_bi`;
delimiter ;;
CREATE TRIGGER `trg_equip_category_ts_bi` BEFORE INSERT ON `equip_category` FOR EACH ROW SET NEW.created_at = NOW()
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table equipment
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_equipment_bi`;
delimiter ;;
CREATE TRIGGER `trg_equipment_bi` BEFORE INSERT ON `equipment` FOR EACH ROW BEGIN
  DECLARE v_flag TINYINT;
  SET NEW.created_at = NOW();
  SELECT need_skill_flag INTO v_flag FROM equip_category WHERE category_id = NEW.category_id;
  IF v_flag = 0 AND NEW.skill_id IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '配件类设备禁止绑定技能等级';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table equipment
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_equipment_bu`;
delimiter ;;
CREATE TRIGGER `trg_equipment_bu` BEFORE UPDATE ON `equipment` FOR EACH ROW BEGIN
  DECLARE v_flag TINYINT;
  SELECT need_skill_flag INTO v_flag FROM equip_category WHERE category_id = NEW.category_id;
  IF v_flag = 0 AND NEW.skill_id IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '配件类设备禁止绑定技能等级';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table maint_order
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_maint_bi`;
delimiter ;;
CREATE TRIGGER `trg_maint_bi` BEFORE INSERT ON `maint_order` FOR EACH ROW BEGIN
  SET NEW.created_at = NOW();
  IF NEW.repair_minutes IS NOT NULL AND (NEW.repair_minutes <= 0 OR NEW.repair_minutes % 15 <> 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '维修时长必须为 15 分钟的整数倍';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table maint_order
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_maint_bu`;
delimiter ;;
CREATE TRIGGER `trg_maint_bu` BEFORE UPDATE ON `maint_order` FOR EACH ROW BEGIN
  IF NEW.repair_minutes IS NOT NULL AND (NEW.repair_minutes <= 0 OR NEW.repair_minutes % 15 <> 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '维修时长必须为 15 分钟的整数倍';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table payment
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_payment_bi`;
delimiter ;;
CREATE TRIGGER `trg_payment_bi` BEFORE INSERT ON `payment` FOR EACH ROW BEGIN
  SET NEW.created_at = NOW();
  IF NEW.amount <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '支付金额必须大于 0';
  END IF;
  IF NEW.biz_category IN ('押金收','押金退') AND NEW.count_in_revenue <> 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '押金单独归类，不得计入营业收入';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table payment
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_payment_bu`;
delimiter ;;
CREATE TRIGGER `trg_payment_bu` BEFORE UPDATE ON `payment` FOR EACH ROW BEGIN
  IF NEW.amount <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '支付金额必须大于 0';
  END IF;
  IF NEW.biz_category IN ('押金收','押金退') AND NEW.count_in_revenue <> 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '押金单独归类，不得计入营业收入';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table purchase_order
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_purchase_bi`;
delimiter ;;
CREATE TRIGGER `trg_purchase_bi` BEFORE INSERT ON `purchase_order` FOR EACH ROW BEGIN
  SET NEW.created_at = NOW();
  IF NEW.accept_status = '验收合格' AND NEW.stock_in_date IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '验收合格时必须登记入库日期';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table purchase_order
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_purchase_bu`;
delimiter ;;
CREATE TRIGGER `trg_purchase_bu` BEFORE UPDATE ON `purchase_order` FOR EACH ROW BEGIN
  IF NEW.accept_status = '验收合格' AND NEW.stock_in_date IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '验收合格时必须登记入库日期';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table shift
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_shift_bi`;
delimiter ;;
CREATE TRIGGER `trg_shift_bi` BEFORE INSERT ON `shift` FOR EACH ROW BEGIN
  SET NEW.created_at = NOW();
  IF NEW.start_time < '08:00:00' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '排班开始时间不得早于 08:00:00';
  END IF;
  IF NEW.end_time > '22:00:00' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '排班结束时间不得晚于 22:00:00';
  END IF;
  IF NEW.start_time >= NEW.end_time THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '排班开始时间必须早于结束时间';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table shift
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_shift_bu`;
delimiter ;;
CREATE TRIGGER `trg_shift_bu` BEFORE UPDATE ON `shift` FOR EACH ROW BEGIN
  IF NEW.start_time < '08:00:00' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '排班开始时间不得早于 08:00:00';
  END IF;
  IF NEW.end_time > '22:00:00' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '排班结束时间不得晚于 22:00:00';
  END IF;
  IF NEW.start_time >= NEW.end_time THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '排班开始时间必须早于结束时间';
  END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table store
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_store_ts_bi`;
delimiter ;;
CREATE TRIGGER `trg_store_ts_bi` BEFORE INSERT ON `store` FOR EACH ROW SET NEW.created_at = NOW()
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table supplier
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_supplier_ts_bi`;
delimiter ;;
CREATE TRIGGER `trg_supplier_ts_bi` BEFORE INSERT ON `supplier` FOR EACH ROW SET NEW.created_at = NOW()
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
