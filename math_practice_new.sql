/*
 Navicat Premium Dump SQL

 Source Server         : MySQL
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : localhost:3306
 Source Schema         : math_practice

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 26/11/2025 09:22:56
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for difficulty_levels
-- ----------------------------
DROP TABLE IF EXISTS `difficulty_levels`;
CREATE TABLE `difficulty_levels`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '难度ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '难度名称',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '难度代码',
  `level` int NOT NULL COMMENT '难度等级(1-10)',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '难度描述',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '难度等级表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of difficulty_levels
-- ----------------------------
INSERT INTO `difficulty_levels` VALUES (1, '入门', 'beginner', 1, '基础题目，适合初学者', '2025-11-14 09:32:15');
INSERT INTO `difficulty_levels` VALUES (2, '简单', 'easy', 2, '简单题目，基础知识点', '2025-11-14 09:32:15');
INSERT INTO `difficulty_levels` VALUES (3, '中等', 'medium', 5, '中等难度，需要一定思考', '2025-11-14 09:32:15');
INSERT INTO `difficulty_levels` VALUES (4, '困难', 'hard', 8, '困难题目，需要深入思考', '2025-11-14 09:32:15');
INSERT INTO `difficulty_levels` VALUES (5, '挑战', 'challenge', 10, '挑战题目，适合拔高训练', '2025-11-14 09:32:15');

-- ----------------------------
-- Table structure for paper_questions
-- ----------------------------
DROP TABLE IF EXISTS `paper_questions`;
CREATE TABLE `paper_questions`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '关联ID，主键',
  `paper_id` int NOT NULL COMMENT '试卷ID',
  `question_id` int NOT NULL COMMENT '题目ID',
  `student_answer` decimal(10, 2) NULL DEFAULT NULL COMMENT '学生答案（保留2位小数）',
  `is_correct` tinyint(1) NULL DEFAULT 0 COMMENT '是否答对：0-错误，1-正确',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `paper_id`(`paper_id` ASC) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  CONSTRAINT `paper_questions_ibfk_1` FOREIGN KEY (`paper_id`) REFERENCES `papers` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `paper_questions_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 117 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '试卷题目关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of paper_questions
-- ----------------------------
INSERT INTO `paper_questions` VALUES (92, 28, 160, 2.00, 0);
INSERT INTO `paper_questions` VALUES (93, 28, 161, 1.00, 1);
INSERT INTO `paper_questions` VALUES (94, 28, 162, 2.00, 1);
INSERT INTO `paper_questions` VALUES (95, 29, 160, 2.00, 0);
INSERT INTO `paper_questions` VALUES (96, 29, 161, 1.00, 1);
INSERT INTO `paper_questions` VALUES (97, 29, 162, 1.00, 0);
INSERT INTO `paper_questions` VALUES (98, 30, 1, NULL, 0);
INSERT INTO `paper_questions` VALUES (99, 30, 2, NULL, 0);
INSERT INTO `paper_questions` VALUES (100, 30, 3, NULL, 0);
INSERT INTO `paper_questions` VALUES (101, 30, 7, NULL, 0);
INSERT INTO `paper_questions` VALUES (102, 30, 9, NULL, 0);
INSERT INTO `paper_questions` VALUES (103, 30, 46, NULL, 0);
INSERT INTO `paper_questions` VALUES (104, 30, 128, NULL, 0);
INSERT INTO `paper_questions` VALUES (105, 30, 129, NULL, 0);
INSERT INTO `paper_questions` VALUES (106, 30, 162, NULL, 0);
INSERT INTO `paper_questions` VALUES (107, 31, 1, NULL, 0);
INSERT INTO `paper_questions` VALUES (108, 31, 2, NULL, 0);
INSERT INTO `paper_questions` VALUES (109, 31, 3, NULL, 0);
INSERT INTO `paper_questions` VALUES (110, 31, 7, NULL, 0);
INSERT INTO `paper_questions` VALUES (111, 31, 9, NULL, 0);
INSERT INTO `paper_questions` VALUES (112, 31, 46, NULL, 0);
INSERT INTO `paper_questions` VALUES (113, 31, 128, NULL, 0);
INSERT INTO `paper_questions` VALUES (114, 31, 129, NULL, 0);
INSERT INTO `paper_questions` VALUES (115, 31, 160, NULL, 0);
INSERT INTO `paper_questions` VALUES (116, 31, 162, NULL, 0);

-- ----------------------------
-- Table structure for papers
-- ----------------------------
DROP TABLE IF EXISTS `papers`;
CREATE TABLE `papers`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '试卷ID，主键',
  `student_id` int NOT NULL COMMENT '学生ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '试卷标题',
  `total_questions` int NOT NULL COMMENT '题目总数',
  `correct_count` int NULL DEFAULT 0 COMMENT '答对题目数量',
  `score` decimal(5, 2) NULL DEFAULT NULL COMMENT '得分（满分100分）',
  `time_spent` int NULL DEFAULT 0 COMMENT '花费时间（单位：秒）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间（开始答题时间）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `student_id`(`student_id` ASC) USING BTREE,
  CONSTRAINT `papers_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '试卷表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of papers
-- ----------------------------
INSERT INTO `papers` VALUES (28, 3, '1', 3, 2, 67.00, 4, '2025-11-21 15:15:25');
INSERT INTO `papers` VALUES (29, 3, '12', 3, 1, 33.00, 7, '2025-11-26 09:09:55');
INSERT INTO `papers` VALUES (30, 3, '错题专项练习 - 2025/11/26 09:14', 9, 0, NULL, 0, '2025-11-26 09:14:40');
INSERT INTO `papers` VALUES (31, 3, '错题专项练习 - 2025/11/26 09:15', 10, 0, NULL, 0, '2025-11-26 09:15:29');

-- ----------------------------
-- Table structure for question_answers
-- ----------------------------
DROP TABLE IF EXISTS `question_answers`;
CREATE TABLE `question_answers`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '答案ID',
  `question_id` int NOT NULL COMMENT '题目ID',
  `answer_type` enum('single','multiple','text','number','fraction') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '答案类型',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '答案内容',
  `is_correct` tinyint(1) NULL DEFAULT 1 COMMENT '是否为正确答案(用于选择题)',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_question`(`question_id` ASC) USING BTREE,
  CONSTRAINT `fk_answers_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 182 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目答案表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_answers
-- ----------------------------
INSERT INTO `question_answers` VALUES (1, 1, 'number', '15', 1, 1, '2025-11-14 11:00:16');
INSERT INTO `question_answers` VALUES (2, 2, 'number', '9', 1, 1, '2025-11-14 11:00:16');
INSERT INTO `question_answers` VALUES (3, 3, 'number', '35', 1, 1, '2025-11-14 11:00:16');
INSERT INTO `question_answers` VALUES (4, 4, 'number', '40', 1, 0, '2025-11-14 12:36:28');
INSERT INTO `question_answers` VALUES (5, 5, 'number', '12', 1, 0, '2025-11-14 12:36:54');
INSERT INTO `question_answers` VALUES (6, 6, 'fraction', '5/6', 1, 0, '2025-11-14 12:37:09');
INSERT INTO `question_answers` VALUES (7, 6, 'number', '0.833', 1, 1, '2025-11-14 12:37:09');
INSERT INTO `question_answers` VALUES (9, 8, 'number', '12', 1, 0, '2025-11-14 12:37:39');
INSERT INTO `question_answers` VALUES (10, 8, 'text', '12公里/小时', 1, 1, '2025-11-14 12:37:39');
INSERT INTO `question_answers` VALUES (15, 7, 'number', '56', 1, 1, '2025-11-17 19:32:48');
INSERT INTO `question_answers` VALUES (19, 9, 'number', '20', 1, 1, '2025-11-17 20:11:28');
INSERT INTO `question_answers` VALUES (27, 14, 'number', '115', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (28, 15, 'number', '78', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (29, 16, 'number', '370', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (30, 17, 'number', '353', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (31, 18, 'number', '667', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (32, 19, 'number', '1122', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (33, 20, 'number', '1167', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (34, 21, 'number', '59', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (35, 22, 'number', '200', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (36, 23, 'number', '168', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (37, 24, 'number', '30', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (38, 25, 'number', '579', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (39, 26, 'number', '468', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (40, 27, 'number', '80', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (41, 28, 'number', '25', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (42, 29, 'number', '461', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (43, 30, 'number', '225', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (44, 31, 'number', '578', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (45, 32, 'number', '1167', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (46, 33, 'number', '100', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (47, 34, 'number', '100', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (48, 35, 'number', '219', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (49, 36, 'number', '42', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (50, 37, 'number', '8', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (51, 38, 'number', '72', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (52, 39, 'number', '7', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (53, 40, 'number', '60', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (54, 41, 'number', '9', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (55, 42, 'number', '90', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (56, 43, 'number', '12', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (57, 44, 'number', '100', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (58, 45, 'number', '12', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (59, 46, 'number', '126', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (60, 47, 'number', '12', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (61, 48, 'number', '900', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (62, 49, 'number', '15', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (63, 50, 'number', '468', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (64, 51, 'number', '28', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (65, 52, 'number', '1000', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (66, 53, 'number', '24', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (67, 54, 'number', '180', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (68, 55, 'number', '12', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (69, 56, 'number', '112', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (70, 57, 'number', '6', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (71, 58, 'number', '300', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (72, 59, 'number', '6', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (73, 60, 'number', '91', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (74, 61, 'number', '13', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (75, 62, 'number', '85', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (76, 63, 'number', '17', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (77, 64, 'number', '121', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (78, 65, 'number', '11', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (79, 66, 'number', '76', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (80, 67, 'number', '19', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (81, 68, 'number', '78', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (82, 69, 'number', '80', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (83, 70, 'number', '45', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (84, 71, 'number', '6', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (85, 72, 'number', '5', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (86, 73, 'number', '80', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (87, 74, 'number', '19', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (88, 75, 'number', '33', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (89, 76, 'number', '17', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (90, 77, 'number', '100', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (91, 78, 'number', '44', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (92, 79, 'number', '8', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (93, 80, 'number', '50', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (94, 81, 'number', '96', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (95, 82, 'number', '50', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (96, 83, 'number', '36', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (97, 84, 'number', '22', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (98, 85, 'number', '27', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (99, 86, 'number', '6', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (100, 87, 'number', '28', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (101, 88, 'number', '31', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (102, 89, 'number', '20', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (103, 90, 'number', '60', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (104, 91, 'number', '30', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (105, 92, 'number', '21', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (106, 93, 'number', '57', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (107, 94, 'number', '50', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (108, 95, 'number', '54', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (109, 96, 'number', '62', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (110, 97, 'number', '10', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (111, 98, 'number', '30', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (112, 99, 'number', '45', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (113, 100, 'number', '80', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (114, 101, 'number', '50', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (115, 102, 'number', '9', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (116, 103, 'number', '198', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (117, 104, 'number', '-1', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (118, 105, 'number', '8', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (119, 106, 'number', '12', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (120, 107, 'number', '238', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (121, 108, 'number', '55', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (122, 109, 'number', '70', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (123, 110, 'number', '126', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (124, 111, 'number', '1', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (125, 112, 'number', '3', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (126, 113, 'number', '225', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (127, 114, 'number', '45', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (128, 115, 'number', '58', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (129, 116, 'number', '110', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (130, 117, 'number', '114', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (131, 118, 'number', '54', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (132, 119, 'number', '144', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (133, 120, 'number', '795', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (134, 121, 'number', '35', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (135, 122, 'number', '40', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (136, 123, 'number', '84', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (137, 124, 'number', '14', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (138, 125, 'number', '3', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (139, 126, 'number', '7', 1, 0, '2025-11-18 10:23:50');
INSERT INTO `question_answers` VALUES (140, 11, 'number', '40', 1, 1, '2025-11-18 14:26:50');
INSERT INTO `question_answers` VALUES (141, 12, 'number', '12', 1, 1, '2025-11-18 14:27:00');
INSERT INTO `question_answers` VALUES (142, 13, 'number', '5/6', 1, 1, '2025-11-18 14:27:09');
INSERT INTO `question_answers` VALUES (143, 127, 'text', 'apple', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (144, 128, 'text', 'am', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (145, 129, 'text', 'goes', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (146, 130, 'text', 'on', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (147, 131, 'text', 'Do', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (148, 132, 'text', 'heavier', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (149, 133, 'text', 'have finished', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (150, 134, 'text', 'is spoken', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (151, 135, 'text', 'were', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (152, 136, 'text', 'that', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (153, 137, 'text', '秦朝', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (154, 138, 'text', '汉朝', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (155, 139, 'number', '1840', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (156, 140, 'text', '尼罗', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (157, 141, 'number', '1776', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (158, 142, 'number', '1949', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (159, 143, 'number', '1914', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (160, 144, 'text', '清', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (161, 145, 'number', '395', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (162, 146, 'number', '1789', 1, 1, '2025-11-20 17:00:36');
INSERT INTO `question_answers` VALUES (179, 161, 'single', 'A', 1, 1, '2025-11-21 14:54:21');
INSERT INTO `question_answers` VALUES (180, 162, 'single', 'B', 1, 1, '2025-11-21 14:54:21');
INSERT INTO `question_answers` VALUES (181, 160, 'single', 'A', 1, 0, '2025-11-21 15:03:44');

-- ----------------------------
-- Table structure for question_images
-- ----------------------------
DROP TABLE IF EXISTS `question_images`;
CREATE TABLE `question_images`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '图片ID',
  `question_id` int NOT NULL COMMENT '题目ID',
  `image_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片存储路径',
  `image_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片文件名',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_question`(`question_id` ASC) USING BTREE,
  CONSTRAINT `fk_images_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目图片表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_images
-- ----------------------------
INSERT INTO `question_images` VALUES (3, 160, '/api/images/2025-11-21/85e482a2-111d-4eb3-972f-5904ca2ebd04.jpg', '禁止通行.jpg');

-- ----------------------------
-- Table structure for question_options
-- ----------------------------
DROP TABLE IF EXISTS `question_options`;
CREATE TABLE `question_options`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '选项ID',
  `question_id` int NOT NULL COMMENT '题目ID',
  `option_key` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '选项键(A,B,C,D等)',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '选项内容',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_question_option`(`question_id` ASC, `option_key` ASC) USING BTREE,
  CONSTRAINT `fk_options_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 83 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目选项表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_options
-- ----------------------------
INSERT INTO `question_options` VALUES (71, 161, 'A', '开启雾灯、近光灯、示廓灯、前后位灯', 1, '2025-11-21 14:54:21');
INSERT INTO `question_options` VALUES (72, 161, 'B', '车速不得超过每小时40公里', 2, '2025-11-21 14:54:21');
INSERT INTO `question_options` VALUES (73, 161, 'C', '与同车道前车保持50米以上的距离', 3, '2025-11-21 14:54:21');
INSERT INTO `question_options` VALUES (74, 161, 'D', '从最近的出口尽快驶离高速公路', 4, '2025-11-21 14:54:21');
INSERT INTO `question_options` VALUES (75, 162, 'A', '违章行为', 1, '2025-11-21 14:54:21');
INSERT INTO `question_options` VALUES (76, 162, 'B', '违法行为', 2, '2025-11-21 14:54:21');
INSERT INTO `question_options` VALUES (77, 162, 'C', '过失行为', 3, '2025-11-21 14:54:21');
INSERT INTO `question_options` VALUES (78, 162, 'D', '违规行为', 4, '2025-11-21 14:54:21');
INSERT INTO `question_options` VALUES (79, 160, 'A', '禁止通行', 1, '2025-11-21 15:03:44');
INSERT INTO `question_options` VALUES (80, 160, 'B', '禁止驶入', 2, '2025-11-21 15:03:44');
INSERT INTO `question_options` VALUES (81, 160, 'C', '禁止停车', 3, '2025-11-21 15:03:44');
INSERT INTO `question_options` VALUES (82, 160, 'D', '限制高度', 4, '2025-11-21 15:03:44');

-- ----------------------------
-- Table structure for question_types
-- ----------------------------
DROP TABLE IF EXISTS `question_types`;
CREATE TABLE `question_types`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '类型ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型名称',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型代码',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '类型描述',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question_types
-- ----------------------------
INSERT INTO `question_types` VALUES (1, '单选题', 'single_choice', '只有一个正确答案的选择题', '2025-11-14 09:32:15');
INSERT INTO `question_types` VALUES (2, '多选题', 'multiple_choice', '有多个正确答案的选择题', '2025-11-14 09:32:15');
INSERT INTO `question_types` VALUES (3, '填空题', 'fill_blank', '需要填写答案的题目', '2025-11-14 09:32:15');
INSERT INTO `question_types` VALUES (4, '判断题', 'true_false', '判断对错的题目', '2025-11-14 09:32:15');
INSERT INTO `question_types` VALUES (5, '计算题', 'calculation', '需要计算得出答案的题目', '2025-11-14 09:32:15');
INSERT INTO `question_types` VALUES (6, '解答题', 'essay', '需要详细解答过程的题目', '2025-11-14 09:32:15');
INSERT INTO `question_types` VALUES (7, '应用题', 'word_problem', '结合实际情境的题目', '2025-11-14 09:32:15');

-- ----------------------------
-- Table structure for questions
-- ----------------------------
DROP TABLE IF EXISTS `questions`;
CREATE TABLE `questions`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '题目ID',
  `type_id` int NOT NULL COMMENT '题目类型ID',
  `difficulty_id` int NOT NULL COMMENT '难度ID',
  `subject` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '科目',
  `knowledge_point` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '知识点',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '题目内容(支持HTML)',
  `has_image` tinyint(1) NULL DEFAULT 0 COMMENT '是否有图片：0-无，1-有',
  `image_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片存储路径（可选）',
  `analysis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '题目解析',
  `created_by` int NULL DEFAULT NULL COMMENT '创建者ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type`(`type_id` ASC) USING BTREE,
  INDEX `idx_difficulty`(`difficulty_id` ASC) USING BTREE,
  INDEX `idx_subject`(`subject` ASC) USING BTREE,
  INDEX `idx_created_by`(`created_by` ASC) USING BTREE,
  CONSTRAINT `fk_questions_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_questions_difficulty` FOREIGN KEY (`difficulty_id`) REFERENCES `difficulty_levels` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_questions_type` FOREIGN KEY (`type_id`) REFERENCES `question_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 163 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of questions
-- ----------------------------
INSERT INTO `questions` VALUES (1, 5, 2, '数学', '有理数运算', '计算：8 + 7 = ?', 0, NULL, '8+7=15，这是基础的加法运算。', 1, '2025-11-14 11:00:16');
INSERT INTO `questions` VALUES (2, 5, 2, '数学', '有理数运算', '计算：15 - 6 = ?', 0, NULL, '15-6=9，这是基础的减法运算。', 1, '2025-11-14 11:00:16');
INSERT INTO `questions` VALUES (3, 5, 3, '数学', '有理数运算', '计算：23 + 12 = ?', 0, NULL, '23+12=35，注意进位运算。', 1, '2025-11-14 11:00:16');
INSERT INTO `questions` VALUES (4, 5, 2, '数学', '基础加法运算', '15 + 25 = ?', 0, NULL, '将15和25相加得到40。15 + 25 = 40', 1, '2025-11-14 12:36:28');
INSERT INTO `questions` VALUES (5, 5, 3, '数学', '四则混合运算', '(12 + 8) × 3 ÷ 5 = ?', 0, NULL, '先计算括号内的加法：12 + 8 = 20，然后乘以3：20 × 3 = 60，最后除以5：60 ÷ 5 = 12', 1, '2025-11-14 12:36:54');
INSERT INTO `questions` VALUES (6, 5, 4, '数学', '分数加减法', '1/2 + 1/3 = ?', 0, NULL, '先通分：1/2 = 3/6，1/3 = 2/6，然后相加：3/6 + 2/6 = 5/6', 1, '2025-11-14 12:37:09');
INSERT INTO `questions` VALUES (7, 1, 2, '数学', '乘法运算', '7 × 8 = ?', 0, NULL, '7乘以8等于56', 4, '2025-11-14 12:37:20');
INSERT INTO `questions` VALUES (8, 7, 4, '数学', '应用题-速度时间距离', '小明骑自行车去学校，去的时候上坡，速度是每小时10公里，用了30分钟；回来的时候下坡，速度是每小时15公里。请问小明来回的平均速度是多少？', 0, NULL, '1. 去程距离：10 km/h × 0.5 h = 5 km\n2. 回程时间：5 km ÷ 15 km/h = 1/3 h\n3. 总距离：5 km × 2 = 10 km\n4. 总时间：0.5 h + 1/3 h = 5/6 h\n5. 平均速度：10 km ÷ (5/6) h = 12 km/h', 1, '2025-11-14 12:37:39');
INSERT INTO `questions` VALUES (9, 3, 2, '数学', '几何图形周长', '一个正方形的边长是5厘米，它的周长是______厘米。', 0, NULL, '正方形周长公式：周长 = 边长 × 4，所以5 × 4 = 20厘米', 4, '2025-11-14 12:38:00');
INSERT INTO `questions` VALUES (11, 5, 2, '数学', '加法运算', '15 + 25 = ?', 0, NULL, '15+25=40', 4, '2025-11-18 10:17:05');
INSERT INTO `questions` VALUES (12, 5, 3, '数学', '四则运算', '(12 + 8) × 3 ÷ 5 = ?', 0, NULL, '先算括号：12+8=20，然后20×3=60，最后60÷5=12', 4, '2025-11-18 10:17:05');
INSERT INTO `questions` VALUES (13, 5, 4, '数学', '分数运算', '1/2 + 1/3 = ?', 0, NULL, '通分：3/6 + 2/6 = 5/6', 4, '2025-11-18 10:17:05');
INSERT INTO `questions` VALUES (14, 5, 2, '数学', '减法运算', '204 - 89 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (15, 5, 2, '数学', '加减混合运算', '100 - 45 + 23 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (16, 5, 2, '数学', '加减混合运算', '256 + 189 - 75 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (17, 5, 2, '数学', '加减混合运算', '420 - 156 + 89 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (18, 5, 2, '数学', '加减混合运算', '1000 - 567 + 234 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (19, 5, 2, '数学', '加减混合运算', '789 + 456 - 123 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (20, 5, 2, '数学', '加减混合运算', '1500 - 789 + 456 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (21, 5, 2, '数学', '加减混合运算', '28 + 39 - 15 + 7 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (22, 5, 2, '数学', '加减混合运算', '200 - 75 + 120 - 45 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (23, 5, 2, '数学', '加法运算', '56 + 78 + 34 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (24, 5, 2, '数学', '减法运算', '90 - 45 - 15 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (25, 5, 2, '数学', '加法运算', '123 + 456 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (26, 5, 2, '数学', '减法运算', '789 - 321 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (27, 5, 2, '数学', '加法运算', '15 + 29 + 36 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (28, 5, 2, '数学', '减法运算', '50 - 17 - 8 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (29, 5, 2, '数学', '加法运算', '275 + 186 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (30, 5, 2, '数学', '减法运算', '420 - 195 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (31, 5, 2, '数学', '加减混合运算', '1000 - 567 + 234 - 89 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (32, 5, 3, '数学', '加减混合运算', '456 + 789 - 123 + 45 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (33, 5, 3, '数学', '加减混合运算', '28 + 39 + 45 - 12 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (34, 5, 3, '数学', '加减混合运算', '150 - 75 + 50 - 25 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (35, 5, 3, '数学', '加法运算', '89 + 76 + 54 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (36, 5, 3, '数学', '乘法运算', '6 × 7 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (37, 5, 3, '数学', '除法运算', '48 ÷ 6 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (38, 5, 3, '数学', '乘法运算', '9 × 8 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (39, 5, 3, '数学', '除法运算', '63 ÷ 9 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (40, 5, 3, '数学', '乘法运算', '12 × 5 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (41, 5, 3, '数学', '除法运算', '81 ÷ 9 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (42, 5, 3, '数学', '乘法运算', '15 × 6 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (43, 5, 3, '数学', '除法运算', '84 ÷ 7 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (44, 5, 3, '数学', '乘法运算', '25 × 4 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (45, 5, 3, '数学', '除法运算', '96 ÷ 8 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (46, 5, 3, '数学', '乘法运算', '18 × 7 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (47, 5, 3, '数学', '除法运算', '144 ÷ 12 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (48, 5, 3, '数学', '乘法运算', '36 × 25 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (49, 5, 3, '数学', '除法运算', '225 ÷ 15 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (50, 5, 3, '数学', '乘法运算', '78 × 6 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (51, 5, 3, '数学', '除法运算', '392 ÷ 14 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (52, 5, 3, '数学', '乘法运算', '125 × 8 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (53, 5, 3, '数学', '除法运算', '576 ÷ 24 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (54, 5, 3, '数学', '乘法运算', '15 × 12 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (55, 5, 3, '数学', '除法运算', '180 ÷ 15 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (56, 5, 3, '数学', '乘法运算', '7 × 8 × 2 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (57, 5, 3, '数学', '除法运算', '144 ÷ 6 ÷ 4 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (58, 5, 3, '数学', '乘法运算', '25 × 3 × 4 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (59, 5, 3, '数学', '除法运算', '360 ÷ 12 ÷ 5 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (60, 5, 3, '数学', '乘法运算', '13 × 7 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (61, 5, 3, '数学', '除法运算', '169 ÷ 13 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (62, 5, 3, '数学', '乘法运算', '17 × 5 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (63, 5, 3, '数学', '除法运算', '204 ÷ 12 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (64, 5, 3, '数学', '乘法运算', '11 × 11 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (65, 5, 3, '数学', '除法运算', '121 ÷ 11 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (66, 5, 3, '数学', '乘法运算', '19 × 4 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (67, 5, 3, '数学', '除法运算', '228 ÷ 12 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (68, 5, 3, '数学', '乘法运算', '26 × 3 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (69, 5, 3, '数学', '加法运算', '(15 + 25) × 2 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (70, 5, 3, '数学', '减法运算', '(28 - 13) × 3 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (71, 5, 3, '数学', '加法运算', '(12 + 18) ÷ 5 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (72, 5, 3, '数学', '减法运算', '(45 - 15) ÷ 6 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (73, 5, 3, '数学', '加法运算', '8 × (7 + 3) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (74, 5, 3, '数学', '加法运算', '(56 ÷ 8) + 12 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (75, 5, 3, '数学', '加法运算', '15 + 6 × 3 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (76, 5, 3, '数学', '减法运算', '20 - 12 ÷ 4 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (77, 5, 3, '数学', '加减混合运算', '(15 + 5) × (8 - 3) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (78, 5, 3, '数学', '加法运算', '(100 ÷ 5) + (6 × 4) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (79, 5, 3, '数学', '加减混合运算', '(28 + 12) ÷ (9 - 4) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (80, 5, 3, '数学', '加法运算', '15 × 3 + 25 ÷ 5 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (81, 5, 3, '数学', '加减混合运算', '(18 - 6) × (5 + 3) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (82, 5, 4, '数学', '加法运算', '(120 ÷ 6) + (15 × 2) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (83, 5, 4, '数学', '加法运算', '(45 + 15) ÷ 5 × 3 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (84, 5, 4, '数学', '加减混合运算', '8 + 12 × 2 - 10 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (85, 5, 4, '数学', '加减混合运算', '25 - 15 ÷ 3 + 7 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (86, 5, 4, '数学', '加法运算', '(9 + 6) × 2 ÷ 5 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (87, 5, 4, '数学', '加法运算', '(24 ÷ 3) + (5 × 4) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (88, 5, 4, '数学', '减法运算', '18 × 2 - 15 ÷ 3 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (89, 5, 4, '数学', '减法运算', '(50 - 20) ÷ 6 × 4 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (90, 5, 4, '数学', '加法运算', '(13 + 7) × (12 ÷ 4) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (91, 5, 4, '数学', '加法运算', '100 ÷ (5 + 5) × 3 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (92, 5, 4, '数学', '加法运算', '(28 + 14) ÷ 7 + 15 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (93, 5, 4, '数学', '加减混合运算', '9 × (8 - 3) + 12 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (94, 5, 4, '数学', '加法运算', '(45 ÷ 9) × (6 + 4) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (95, 5, 4, '数学', '减法运算', '(60 - 15) ÷ 5 × 6 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (96, 5, 4, '数学', '加法运算', '7 × 8 + 36 ÷ 6 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (97, 5, 4, '数学', '加法运算', '(25 + 15) × 2 ÷ 8 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (98, 5, 4, '数学', '减法运算', '(100 - 40) ÷ 10 × 5 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (99, 5, 4, '数学', '加法运算', '12 × 3 + 18 ÷ 2 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (100, 5, 4, '数学', '加法运算', '(64 ÷ 8) × (7 + 3) = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (101, 5, 4, '数学', '加减混合运算', '(35 - 15) × 2 + 10 = ?', 0, NULL, NULL, 1, '2025-11-10 18:00:31');
INSERT INTO `questions` VALUES (102, 5, 4, '数学', '减法运算', '14 - 5 ÷ 1 = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (103, 5, 4, '数学', '加减混合运算', '(28 + 5) × (8 - 2) = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (104, 5, 4, '数学', '加减混合运算', '27 + 8 - 36 = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (105, 5, 4, '数学', '除法运算', '24 ÷ 3 = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (106, 5, 4, '数学', '乘法运算', '6 × 2 = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (107, 5, 4, '数学', '加法运算', '(28 + 6) × 7 = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (108, 5, 4, '数学', '乘法运算', '5 × 11 = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (109, 5, 4, '数学', '加减混合运算', '51 + 40 - 21 = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (110, 5, 4, '数学', '乘法运算', '9 × 14 = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (111, 5, 4, '数学', '乘法运算', '5 × 2 ÷ 10 = ?', 0, NULL, NULL, 4, '2025-11-12 20:14:49');
INSERT INTO `questions` VALUES (112, 5, 4, '数学', '减法运算', '31 - 28 = ?', 0, NULL, NULL, 4, '2025-11-12 20:15:13');
INSERT INTO `questions` VALUES (113, 5, 4, '数学', '减法运算', '(30 - 5) × 9 = ?', 0, NULL, NULL, 4, '2025-11-13 08:28:36');
INSERT INTO `questions` VALUES (114, 5, 4, '数学', '乘法运算', '3 × 15 = ?', 0, NULL, NULL, 4, '2025-11-13 08:28:36');
INSERT INTO `questions` VALUES (115, 5, 4, '数学', '加法运算', '(14 + 15) × 2 = ?', 0, NULL, NULL, 4, '2025-11-13 08:28:36');
INSERT INTO `questions` VALUES (116, 5, 4, '数学', '乘法运算', '11 × 10 = ?', 0, NULL, NULL, 4, '2025-11-13 08:28:36');
INSERT INTO `questions` VALUES (117, 5, 4, '数学', '加法运算', '(14 + 5) × 6 = ?', 0, NULL, NULL, 4, '2025-11-13 08:28:36');
INSERT INTO `questions` VALUES (118, 5, 4, '数学', '加法运算', '(5 + 1) × 9 = ?', 0, NULL, NULL, 4, '2025-11-13 08:38:09');
INSERT INTO `questions` VALUES (119, 5, 4, '数学', '乘法运算', '12 × 12 = ?', 0, NULL, NULL, 4, '2025-11-13 08:38:09');
INSERT INTO `questions` VALUES (120, 5, 4, '数学', '加减混合运算', '(42 + 11) × (17 - 2) = ?', 0, NULL, NULL, 4, '2025-11-13 08:38:09');
INSERT INTO `questions` VALUES (121, 5, 4, '数学', '减法运算', '100 - 65 = ?', 0, NULL, NULL, 4, '2025-11-13 08:38:09');
INSERT INTO `questions` VALUES (122, 5, 4, '数学', '加法运算', '(40 × 5) ÷ (2 + 3) = ?', 0, NULL, NULL, 4, '2025-11-13 08:38:09');
INSERT INTO `questions` VALUES (123, 5, 4, '数学', '加减混合运算', '89 + 17 - 22 = ?', 0, NULL, NULL, 4, '2025-11-13 08:38:09');
INSERT INTO `questions` VALUES (124, 5, 4, '数学', '加法运算', '(14 × 22) ÷ (13 + 9) = ?', 0, NULL, NULL, 4, '2025-11-13 08:38:09');
INSERT INTO `questions` VALUES (125, 5, 4, '数学', '除法运算', '6 ÷ 2 = ?', 0, NULL, NULL, 4, '2025-11-13 08:38:09');
INSERT INTO `questions` VALUES (126, 5, 4, '数学', '加法运算', '6 + 9 ÷ 9 = ?', 0, NULL, NULL, 4, '2025-11-13 08:38:09');
INSERT INTO `questions` VALUES (127, 3, 2, '英语', '词汇理解', '苹果的英文单词是______。', 0, NULL, '苹果的英文是apple，这是基础词汇。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (128, 3, 2, '英语', '基础语法', 'I ______ a student. (am/is/are)', 0, NULL, '主语是I时，be动词用am。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (129, 3, 3, '英语', '动词时态', 'She ______ to school every day. (go/goes)', 0, NULL, '主语是第三人称单数，动词要加s。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (130, 3, 3, '英语', '介词用法', 'The book is ______ the table. (on/in/at)', 0, NULL, '在桌子上面用介词on。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (131, 3, 3, '英语', '疑问句构成', '______ you like English? (Do/Does/Did)', 0, NULL, '一般现在时疑问句用Do。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (132, 3, 4, '英语', '比较级', 'This box is ______ than that one. (heavy)', 0, NULL, 'heavy的比较级是heavier。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (133, 3, 4, '英语', '现在完成时', 'I ______ already ______ my homework. (finish)', 0, NULL, '现在完成时结构：have/has + 过去分词。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (134, 3, 4, '英语', '被动语态', 'English ______ all over the world. (speak)', 0, NULL, '被动语态：be + 过去分词。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (135, 3, 5, '英语', '虚拟语气', 'If I ______ you, I would study harder. (be)', 0, NULL, '虚拟语气中，be动词用were。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (136, 3, 5, '英语', '定语从句', 'This is the book ______ I bought yesterday. (which/that/who)', 0, NULL, '修饰物用which或that。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (137, 3, 2, '历史', '中国古代史', '中国第一个封建王朝是______。', 0, NULL, '公元前221年，秦始皇统一六国，建立秦朝。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (138, 3, 2, '历史', '中国古代史', '丝绸之路的开辟始于______朝代。', 0, NULL, '汉武帝时期，张骞出使西域，开辟丝绸之路。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (139, 3, 3, '历史', '中国近代史', '鸦片战争爆发于______年。', 0, NULL, '1840年英国发动鸦片战争，中国开始沦为半殖民地半封建社会。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (140, 3, 3, '历史', '世界古代史', '古埃及文明发源于______河流域。', 0, NULL, '尼罗河定期泛滥带来肥沃土壤，孕育了古埃及文明。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (141, 3, 3, '历史', '世界近代史', '美国独立宣言发表于______年。', 0, NULL, '1776年7月4日，北美大陆会议通过《独立宣言》。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (142, 3, 4, '历史', '中国现代史', '中华人民共和国成立于______年。', 0, NULL, '1949年10月1日，毛泽东在天安门宣布中华人民共和国成立。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (143, 3, 4, '历史', '世界现代史', '第一次世界大战爆发于______年。', 0, NULL, '1914年奥匈帝国皇储斐迪南遇刺，引发第一次世界大战。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (144, 3, 4, '历史', '中国近代史', '辛亥革命推翻了______王朝的统治。', 0, NULL, '1911年辛亥革命结束了中国两千多年的封建帝制。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (145, 3, 5, '历史', '世界古代史', '罗马帝国分裂为东西两部分是在______年。', 0, NULL, '公元395年，罗马帝国分裂为东罗马和西罗马帝国。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (146, 3, 5, '历史', '世界近代史', '法国大革命开始于______年。', 0, NULL, '1789年巴黎人民攻占巴士底狱，标志法国大革命开始。', 1, '2025-11-20 17:00:36');
INSERT INTO `questions` VALUES (160, 1, 2, '驾考', '交通信号', '这个标志的含义是？', 1, NULL, '这是禁止通行标志，表示禁止一切车辆和行人通行。', 4, '2025-11-21 14:54:21');
INSERT INTO `questions` VALUES (161, 1, 2, '驾考', '安全行车', '在高速公路上行驶，遇有雾、雨、雪、沙尘、冰雹等低能见度气象条件时，应当遵守什么规定？', 0, NULL, '根据《道路交通安全法》规定，能见度小于200米时，开启雾灯、近光灯、示廓灯和前后位灯，车速不得超过每小时60公里，与同车道前车保持100米以上的距离。', 1, '2025-11-21 14:54:21');
INSERT INTO `questions` VALUES (162, 1, 3, '驾考', '交通法规', '驾驶机动车在道路上违反道路交通安全法的行为，属于什么行为？', 0, NULL, '违反道路交通安全法律、法规的行为属于违法行为。', 1, '2025-11-21 14:54:21');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID，主键',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名，唯一',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（加密存储）',
  `role` enum('student','teacher') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户角色：student-学生，teacher-老师',
  `userClass` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '班级名称（仅学生有）',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表（学生和老师）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'Lucy', '123456', 'teacher', NULL, '2025-11-07 08:41:27');
INSERT INTO `users` VALUES (2, '小明', '1122', 'student', '三年一班', '2025-11-07 08:41:27');
INSERT INTO `users` VALUES (3, '小华', '2233', 'student', '三年二班', '2025-11-07 08:41:27');
INSERT INTO `users` VALUES (4, 'Leo', '123', 'teacher', '', '2025-11-07 14:53:39');
INSERT INTO `users` VALUES (5, '小红', '123', 'student', '三年一班', '2025-11-07 14:58:13');

-- ----------------------------
-- Table structure for wrong_questions
-- ----------------------------
DROP TABLE IF EXISTS `wrong_questions`;
CREATE TABLE `wrong_questions`  (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '错题ID，主键',
  `student_id` int NOT NULL COMMENT '学生ID',
  `question_id` int NOT NULL COMMENT '题目ID（关联新的questions表）',
  `wrong_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '学生的错误答案（支持各种格式）',
  `paper_id` int NULL DEFAULT NULL COMMENT '关联的试卷ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_student_question`(`student_id` ASC, `question_id` ASC) USING BTREE,
  INDEX `student_id`(`student_id` ASC) USING BTREE,
  INDEX `question_id`(`question_id` ASC) USING BTREE,
  INDEX `paper_id`(`paper_id` ASC) USING BTREE,
  CONSTRAINT `fk_wrong_questions_paper` FOREIGN KEY (`paper_id`) REFERENCES `papers` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_wrong_questions_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_wrong_questions_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '错题记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of wrong_questions
-- ----------------------------
INSERT INTO `wrong_questions` VALUES (1, 3, 1, '14', NULL, '2025-11-18 10:15:00');
INSERT INTO `wrong_questions` VALUES (2, 3, 2, '8', NULL, '2025-11-18 10:16:00');
INSERT INTO `wrong_questions` VALUES (3, 3, 3, '30', NULL, '2025-11-18 10:17:00');
INSERT INTO `wrong_questions` VALUES (4, 3, 7, '54', NULL, '2025-11-18 10:18:00');
INSERT INTO `wrong_questions` VALUES (6, 2, 4, '30', NULL, '2025-11-18 10:20:00');
INSERT INTO `wrong_questions` VALUES (7, 2, 5, '15', NULL, '2025-11-18 10:21:00');
INSERT INTO `wrong_questions` VALUES (8, 2, 6, '2/5', NULL, '2025-11-18 10:22:00');
INSERT INTO `wrong_questions` VALUES (9, 5, 8, '12.5', NULL, '2025-11-18 10:23:00');
INSERT INTO `wrong_questions` VALUES (10, 5, 1, '16', NULL, '2025-11-18 10:24:00');
INSERT INTO `wrong_questions` VALUES (11, 5, 2, '10', NULL, '2025-11-18 10:25:00');
INSERT INTO `wrong_questions` VALUES (13, 3, 46, '56565', NULL, '2025-11-18 14:53:39');
INSERT INTO `wrong_questions` VALUES (14, 3, 9, '6', NULL, '2025-11-18 18:17:15');
INSERT INTO `wrong_questions` VALUES (15, 3, 128, '0', NULL, '2025-11-21 08:30:56');
INSERT INTO `wrong_questions` VALUES (16, 3, 129, '0', NULL, '2025-11-21 08:30:56');
INSERT INTO `wrong_questions` VALUES (23, 3, 162, 'A', NULL, '2025-11-21 14:55:41');
INSERT INTO `wrong_questions` VALUES (25, 3, 160, 'B', 29, '2025-11-26 09:10:13');

SET FOREIGN_KEY_CHECKS = 1;
