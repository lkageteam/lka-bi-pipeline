-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: tsa_activities
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `active_merchant`
--

DROP TABLE IF EXISTS `active_merchant`;
/*!50001 DROP VIEW IF EXISTS `active_merchant`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `active_merchant` AS SELECT 
 1 AS `Region`,
 1 AS `total_records`,
 1 AS `active_per_criteria`,
 1 AS `active_merchant`,
 1 AS `criteria_percentage`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `deployments_with_latest_cat`
--

DROP TABLE IF EXISTS `deployments_with_latest_cat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deployments_with_latest_cat` (
  `POS_MSISDN` double DEFAULT NULL,
  `POS_ID` varchar(24) DEFAULT NULL,
  `TSA_ID` varchar(24) DEFAULT NULL,
  `latitude` varchar(23) DEFAULT NULL,
  `longitude` varchar(22) DEFAULT NULL,
  `typePos` varchar(8) DEFAULT NULL,
  `catPDV` varchar(12) DEFAULT NULL,
  `latest_report_date` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `distribution_route`
--

DROP TABLE IF EXISTS `distribution_route`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `distribution_route` (
  `X_id` varchar(24) DEFAULT NULL,
  `etsName` varchar(147) DEFAULT NULL,
  `posNumber` double DEFAULT NULL,
  `ownerName` varchar(52) DEFAULT NULL,
  `ownerLastName` text,
  `ownerlastNumber` double DEFAULT NULL,
  `typePos` varchar(8) DEFAULT NULL,
  `kindOfPos` varchar(10) DEFAULT NULL,
  `activityPeriod` varchar(14) DEFAULT NULL,
  `activityHour` varchar(10) DEFAULT NULL,
  `zone` varchar(194) DEFAULT NULL,
  `creationDate` varchar(10) DEFAULT NULL,
  `TSA_ID` varchar(24) DEFAULT NULL,
  `latitude` varchar(23) DEFAULT NULL,
  `longitude` varchar(22) DEFAULT NULL,
  `TSA_Full_NAME` varchar(40) DEFAULT NULL,
  `Numero_Corporate` double DEFAULT NULL,
  `Region_intern` varchar(10) DEFAULT NULL,
  `RBM` varchar(20) DEFAULT NULL,
  `RegionCode` varchar(4) DEFAULT NULL,
  `distance_km` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `newadd`
--

DROP TABLE IF EXISTS `newadd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `newadd` (
  `Username` varchar(26) DEFAULT NULL,
  `Date` varchar(10) DEFAULT NULL,
  `newadd` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsa_date`
--

DROP TABLE IF EXISTS `tsa_date`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_date` (
  `Date` datetime(6) DEFAULT NULL,
  `Week Day` varchar(3) DEFAULT NULL,
  `Week` varchar(7) DEFAULT NULL,
  `Start date` datetime(6) DEFAULT NULL,
  `End Dqte` double DEFAULT NULL,
  `Period` varchar(15) DEFAULT NULL,
  `Month` varchar(9) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsa_deployments`
--

DROP TABLE IF EXISTS `tsa_deployments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_deployments` (
  `X_id` varchar(24) DEFAULT NULL,
  `etsName` varchar(147) DEFAULT NULL,
  `posNumber` double DEFAULT NULL,
  `ownerName` varchar(52) DEFAULT NULL,
  `ownerLastName` text,
  `longitude` varchar(22) DEFAULT NULL,
  `latitude` varchar(23) DEFAULT NULL,
  `typePos` varchar(8) DEFAULT NULL,
  `posAgentNumber` double DEFAULT NULL,
  `posMerchantNumber` double DEFAULT NULL,
  `createdAt` varchar(24) DEFAULT NULL,
  `agentInfo_firstName` varchar(33) DEFAULT NULL,
  `agentInfo_lastName` varchar(25) DEFAULT NULL,
  `agentInfo_email` varchar(38) DEFAULT NULL,
  `agentInfo_idCardNumber` varchar(23) DEFAULT NULL,
  `agentInfo_role_label` varchar(20) DEFAULT NULL,
  `agentInfo_role_sigle` varchar(6) DEFAULT NULL,
  `agentInfo_role__id` varchar(24) DEFAULT NULL,
  `agentInfo_role___v` int DEFAULT NULL,
  `agentInfo_region_label` varchar(11) DEFAULT NULL,
  `agentInfo_region__id` varchar(24) DEFAULT NULL,
  `agentInfo_region___v` int DEFAULT NULL,
  `agentInfo_region_role` varchar(3) DEFAULT NULL,
  `agentInfo_activate` varchar(4) DEFAULT NULL,
  `agentInfo_desactivate` varchar(5) DEFAULT NULL,
  `agentInfo_isBanned` varchar(5) DEFAULT NULL,
  `agentInfo_createdAt` varchar(24) DEFAULT NULL,
  `agentInfo_updatedAt` varchar(24) DEFAULT NULL,
  `agentInfo_phoneNumber` int DEFAULT NULL,
  `agentInfo_idUnique` varchar(9) DEFAULT NULL,
  `agentInfo__id` varchar(24) DEFAULT NULL,
  `agentInfo_regionChoose` varchar(11) DEFAULT NULL,
  `agentInfo_desireRole` varchar(13) DEFAULT NULL,
  `agentInfo_birthdate` varchar(10) DEFAULT NULL,
  `agentInfo_fonction` varchar(19) DEFAULT NULL,
  `agentInfo_degree` varchar(47) DEFAULT NULL,
  `agentInfo_address` varchar(32) DEFAULT NULL,
  `agentInfo_idCardType` varchar(9) DEFAULT NULL,
  `agentInfo_gender` varchar(1) DEFAULT NULL,
  `agentInfo_corporateNumber` varchar(17) DEFAULT NULL,
  `agentInfo___v` int DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `ownerLastNumber` double DEFAULT NULL,
  `kindOfPos` varchar(10) DEFAULT NULL,
  `activityPeriod` varchar(14) DEFAULT NULL,
  `activityHour` varchar(10) DEFAULT NULL,
  `zone` varchar(194) DEFAULT NULL,
  `sector` varchar(42) DEFAULT NULL,
  `codeMID` varchar(6) DEFAULT NULL,
  `agentInfo_personel` int DEFAULT NULL,
  `Date` varchar(10) DEFAULT NULL,
  `Time` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `tsa_global_monthly`
--

DROP TABLE IF EXISTS `tsa_global_monthly`;
/*!50001 DROP VIEW IF EXISTS `tsa_global_monthly`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `tsa_global_monthly` AS SELECT 
 1 AS `TSA_Full_NAME`,
 1 AS `Numero_Corporate`,
 1 AS `Region_Intern`,
 1 AS `site_count`,
 1 AS `RGA_target_Monthly`,
 1 AS `RGB_target_Monthly`,
 1 AS `RGB_target_EOY`,
 1 AS `Agent_Monthly_target`,
 1 AS `Merchant_Monthly_target`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tsa_kiosk_data`
--

DROP TABLE IF EXISTS `tsa_kiosk_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_kiosk_data` (
  `TSA_ID` varchar(24) DEFAULT NULL,
  `USERNAME` varchar(26) DEFAULT NULL,
  `DEALER` varchar(11) DEFAULT NULL,
  `REGION` varchar(10) DEFAULT NULL,
  `DEPARTEMENT` varchar(13) DEFAULT NULL,
  `COMMUNE` varchar(21) DEFAULT NULL,
  `ENTERPRISE_NAME` varchar(13) DEFAULT NULL,
  `AGENT_NAME` varchar(40) DEFAULT NULL,
  `MOMO_MSISDN` double DEFAULT NULL,
  `P2P_MSISDN` double DEFAULT NULL,
  `REAL_CHANNEL` varchar(8) DEFAULT NULL,
  `SUP_MA` varchar(3) DEFAULT NULL,
  `SUP_MA_MOMO_MSISDN` double DEFAULT NULL,
  `OTHER_DEALERS` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `tsa_monthly_performance`
--

DROP TABLE IF EXISTS `tsa_monthly_performance`;
/*!50001 DROP VIEW IF EXISTS `tsa_monthly_performance`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `tsa_monthly_performance` AS SELECT 
 1 AS `TSA_full_NAME`,
 1 AS `TSA_ID`,
 1 AS `Numero_corporate`,
 1 AS `Region_Intern`,
 1 AS `RBM`,
 1 AS `Visits_Monthly`,
 1 AS `Visits_weekly`,
 1 AS `Number_of_active_days`,
 1 AS `Agent_Deployment_Month`,
 1 AS `Agent_monthly_target`,
 1 AS `Agent_deployment_Monthly_achieved`,
 1 AS `Agent_Deployment_Week`,
 1 AS `Agent_weekly_target`,
 1 AS `Agent_deployment_Weekly_achieved`,
 1 AS `Merchant_Deployment_Month`,
 1 AS `Merchant_monthly_target`,
 1 AS `Merchant_deployment_Monthly_achieved`,
 1 AS `Merchant_Deployment_Week`,
 1 AS `Merchant_weekly_target`,
 1 AS `Merchant_deployment_Weekly_achieved`,
 1 AS `number_of_Kiosk`,
 1 AS `New_add`,
 1 AS `new_add_Target`,
 1 AS `pct_new_add`,
 1 AS `total_target`,
 1 AS `total_active_merchant`,
 1 AS `total_active_merchant_creteria`,
 1 AS `pct_active_merchant`,
 1 AS `pct_active_merchant_creteria`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tsa_numenclature`
--

DROP TABLE IF EXISTS `tsa_numenclature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_numenclature` (
  `TSA_ID` varchar(24) DEFAULT NULL,
  `Numero_Corporate` double DEFAULT NULL,
  `Column1` double DEFAULT NULL,
  `TSA_first_Name` varchar(23) DEFAULT NULL,
  `TSA_Name` varchar(32) DEFAULT NULL,
  `TSA_Full_NAME` varchar(40) DEFAULT NULL,
  `Login_ID` varchar(8) DEFAULT NULL,
  `Numero_Corporate2` varchar(8) DEFAULT NULL,
  `Region_Intern` varchar(10) DEFAULT NULL,
  `Region_Operateur` varchar(11) DEFAULT NULL,
  `DEPARTEMENt` varchar(10) DEFAULT NULL,
  `RegionCode` varchar(4) DEFAULT NULL,
  `SECTION` varchar(9) DEFAULT NULL,
  `RBM` varchar(20) DEFAULT NULL,
  `VILLE` varchar(21) DEFAULT NULL,
  `LOCALITE` varchar(14) DEFAULT NULL,
  `Visits_weekly_Target` double DEFAULT NULL,
  `Visits_montly_Target` double DEFAULT NULL,
  `Agent_weekly_target` double DEFAULT NULL,
  `Agent_Monthly_target` double DEFAULT NULL,
  `Merchant_Weekly_target` double DEFAULT NULL,
  `Merchant_Monthly_target` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsa_reports`
--

DROP TABLE IF EXISTS `tsa_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_reports` (
  `X_id` varchar(24) DEFAULT NULL,
  `posId` varchar(24) DEFAULT NULL,
  `userInfo_firstName` varchar(33) DEFAULT NULL,
  `userInfo_lastName` varchar(25) DEFAULT NULL,
  `userInfo_phoneNumber` int DEFAULT NULL,
  `userInfo__id` varchar(24) DEFAULT NULL,
  `userInfo_corporateNumber` varchar(17) DEFAULT NULL,
  `posInfo_posNumber` double DEFAULT NULL,
  `posInfo_ownerName` varchar(52) DEFAULT NULL,
  `posInfo_ownerLastName` text,
  `posInfo_typePos` varchar(8) DEFAULT NULL,
  `posInfo_posAgentNumber` double DEFAULT NULL,
  `posInfo_posMerchantNumber` double DEFAULT NULL,
  `posInfo_ownerLastNumber` double DEFAULT NULL,
  `posInfo_kindOfPos` varchar(10) DEFAULT NULL,
  `posInfo_activityPeriod` varchar(14) DEFAULT NULL,
  `posInfo_activityHour` varchar(10) DEFAULT NULL,
  `createdAt` varchar(24) DEFAULT NULL,
  `catPDV` varchar(12) DEFAULT NULL,
  `eCashMTN` double DEFAULT NULL,
  `eCashMoov` double DEFAULT NULL,
  `eCashCeltiis` double DEFAULT NULL,
  `cashinMTN` double DEFAULT NULL,
  `cashinMOOV` double DEFAULT NULL,
  `cashinCeltiis` double DEFAULT NULL,
  `cashoutMTN` double DEFAULT NULL,
  `cashoutMOOV` double DEFAULT NULL,
  `cashoutCeltiis` double DEFAULT NULL,
  `airtimeMTN` double DEFAULT NULL,
  `airtimeMOOV` double DEFAULT NULL,
  `airtimeCeltiis` double DEFAULT NULL,
  `frequencyMTN` varchar(8) DEFAULT NULL,
  `frequencyMOOV` varchar(8) DEFAULT NULL,
  `frequencyCeltiis` varchar(8) DEFAULT NULL,
  `visibiltyState` varchar(12) DEFAULT NULL,
  `simNumberMTN` double DEFAULT NULL,
  `simNumberMOOV` int DEFAULT NULL,
  `simNumberCeltiis` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `typeReport` varchar(11) DEFAULT NULL,
  `etsName` varchar(147) DEFAULT NULL,
  `tsaName` varchar(33) DEFAULT NULL,
  `tsaLastName` varchar(25) DEFAULT NULL,
  `Date` varchar(10) DEFAULT NULL,
  `Time` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsa_rga30_target`
--

DROP TABLE IF EXISTS `tsa_rga30_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_rga30_target` (
  `site_id` varchar(11) DEFAULT NULL,
  `arrondissement` varchar(20) DEFAULT NULL,
  `commune` varchar(15) DEFAULT NULL,
  `depatement` varchar(11) DEFAULT NULL,
  `region` varchar(11) DEFAULT NULL,
  `dealer` varchar(11) DEFAULT NULL,
  `sub_dealer` varchar(11) DEFAULT NULL,
  `janv-26` double DEFAULT NULL,
  `févr-26` double DEFAULT NULL,
  `mars-26` double DEFAULT NULL,
  `avr-26` double DEFAULT NULL,
  `mai-26` double DEFAULT NULL,
  `juin-26` double DEFAULT NULL,
  `juil-26` double DEFAULT NULL,
  `août-26` double DEFAULT NULL,
  `sept-26` double DEFAULT NULL,
  `oct-26` double DEFAULT NULL,
  `nov-26` double DEFAULT NULL,
  `déc-26` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsa_rgb30_client_data`
--

DROP TABLE IF EXISTS `tsa_rgb30_client_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_rgb30_client_data` (
  `Nom_EDA` varchar(3) DEFAULT NULL,
  `Numéro_BA_MoMoPay` varchar(3) DEFAULT NULL,
  `Nom_BA_MoMoPay` varchar(3) DEFAULT NULL,
  `REGION` varchar(3) DEFAULT NULL,
  `MSISDN` double DEFAULT NULL,
  `FULLNAME` varchar(126) DEFAULT NULL,
  `REGISTRATION_DATE` datetime(6) DEFAULT NULL,
  `PROFILE` varchar(49) DEFAULT NULL,
  `STATUS` varchar(18) DEFAULT NULL,
  `Active_merchant_30` double DEFAULT NULL,
  `Active_merchant_60` double DEFAULT NULL,
  `Active_merchant_90` double DEFAULT NULL,
  `NB_trans` double DEFAULT NULL,
  `Value_trans` double DEFAULT NULL,
  `Dist_days` double DEFAULT NULL,
  `Avg_#_trans_per_day` varchar(18) DEFAULT NULL,
  `Avg_value_of_trans_per_day` varchar(18) DEFAULT NULL,
  `Avg_Value` varchar(18) DEFAULT NULL,
  `RGM_Modernized` double DEFAULT NULL,
  `Last_activity_day` varchar(5) DEFAULT NULL,
  `site_id` varchar(5) DEFAULT NULL,
  `region2` varchar(10) DEFAULT NULL,
  `depatement` varchar(10) DEFAULT NULL,
  `commune` varchar(15) DEFAULT NULL,
  `arrondissement` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsa_rgb30_target`
--

DROP TABLE IF EXISTS `tsa_rgb30_target`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_rgb30_target` (
  `site_id` varchar(11) DEFAULT NULL,
  `arrondissement` varchar(20) DEFAULT NULL,
  `commune` varchar(15) DEFAULT NULL,
  `depatement` varchar(11) DEFAULT NULL,
  `region` varchar(11) DEFAULT NULL,
  `dealer` varchar(11) DEFAULT NULL,
  `sub_dealer` varchar(11) DEFAULT NULL,
  `janv-26` tinyint DEFAULT NULL,
  `févr-26` double DEFAULT NULL,
  `mars-26` double DEFAULT NULL,
  `avr-26` double DEFAULT NULL,
  `mai-26` double DEFAULT NULL,
  `juin-26` double DEFAULT NULL,
  `juil-26` double DEFAULT NULL,
  `août-26` double DEFAULT NULL,
  `sept-26` double DEFAULT NULL,
  `oct-26` double DEFAULT NULL,
  `nov-26` double DEFAULT NULL,
  `déc-26` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsa_sectorisation`
--

DROP TABLE IF EXISTS `tsa_sectorisation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_sectorisation` (
  `TSA_ID` varchar(24) DEFAULT NULL,
  `NOM_DU_TSA` varchar(40) DEFAULT NULL,
  `NUMÉRO_CORPORATE` double DEFAULT NULL,
  `SITES` varchar(6) DEFAULT NULL,
  `ARRONDISSEMENT` varchar(20) DEFAULT NULL,
  `COMMUNE` varchar(15) DEFAULT NULL,
  `DEPATEMENT` varchar(10) DEFAULT NULL,
  `REGION` varchar(10) DEFAULT NULL,
  `DEALER` varchar(9) DEFAULT NULL,
  `SUB_DEALER` varchar(8) DEFAULT NULL,
  `REGIONS_INT` varchar(10) DEFAULT NULL,
  `RBM` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `value_share_compute`
--

DROP TABLE IF EXISTS `value_share_compute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `value_share_compute` (
  `partner` varchar(24) DEFAULT NULL,
  `userInfo__id` varchar(24) DEFAULT NULL,
  `LOCALITE` varchar(14) NOT NULL DEFAULT '',
  `VILLE` varchar(21) NOT NULL DEFAULT '',
  `Week` int DEFAULT NULL,
  `Month` int DEFAULT NULL,
  `DateValue` varchar(29) DEFAULT NULL,
  `cashinMTN` double NOT NULL DEFAULT '0',
  `cashoutMTN` double NOT NULL DEFAULT '0',
  `cashinMoov` double NOT NULL DEFAULT '0',
  `cashoutMoov` double NOT NULL DEFAULT '0',
  `cashinCeltiis` double NOT NULL DEFAULT '0',
  `cashoutCeltiis` double NOT NULL DEFAULT '0',
  `AirtimeMTN` double NOT NULL DEFAULT '0',
  `AirtimeMoov` double NOT NULL DEFAULT '0',
  `AirtimeCeltiis` double NOT NULL DEFAULT '0',
  `VolumeMTN` double NOT NULL DEFAULT '0',
  `VolumeMoov` double NOT NULL DEFAULT '0',
  `VolumeCeltiis` double NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `value_share_compute_modified`
--

DROP TABLE IF EXISTS `value_share_compute_modified`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `value_share_compute_modified` (
  `partner` varchar(24) DEFAULT NULL,
  `userInfo__id` varchar(24) DEFAULT NULL,
  `LOCALITE` varchar(14) NOT NULL DEFAULT '',
  `VILLE` varchar(21) NOT NULL DEFAULT '',
  `Week` int DEFAULT NULL,
  `Month` int DEFAULT NULL,
  `Year` int DEFAULT NULL,
  `DateValue` varchar(29) DEFAULT NULL,
  `cashinMTN` double DEFAULT NULL,
  `cashoutMTN` double DEFAULT NULL,
  `cashinMoov` double DEFAULT NULL,
  `cashoutMoov` double DEFAULT NULL,
  `cashinCeltiis` double DEFAULT NULL,
  `cashoutCeltiis` double DEFAULT NULL,
  `AirtimeMTN` double DEFAULT NULL,
  `AirtimeMoov` double DEFAULT NULL,
  `AirtimeCeltiis` double DEFAULT NULL,
  `VolumeMTN` double DEFAULT NULL,
  `VolumeMoov` double DEFAULT NULL,
  `VolumeCeltiis` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `value_share_pos`
--

DROP TABLE IF EXISTS `value_share_pos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `value_share_pos` (
  `Partner_ID` varchar(24) DEFAULT NULL,
  `Numero_Corporate_TSA` double DEFAULT NULL,
  `Numero_POS_HV` double DEFAULT NULL,
  `Département` varchar(14) DEFAULT NULL,
  `Commune` varchar(15) DEFAULT NULL,
  `Region` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'tsa_activities'
--

--
-- Dumping routines for database 'tsa_activities'
--

--
-- Final view structure for view `active_merchant`
--

/*!50001 DROP VIEW IF EXISTS `active_merchant`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `active_merchant` AS select `tsa_rgb30_client_data`.`region2` AS `Region`,count(0) AS `total_records`,sum((case when ((`tsa_rgb30_client_data`.`Active_merchant_30` = 1) and (`tsa_rgb30_client_data`.`NB_trans` >= 5) and (`tsa_rgb30_client_data`.`Value_trans` >= 1000)) then 1 else 0 end)) AS `active_per_criteria`,sum((case when (`tsa_rgb30_client_data`.`Active_merchant_30` = 1) then 1 else 0 end)) AS `active_merchant`,round(((sum((case when ((`tsa_rgb30_client_data`.`Active_merchant_30` = 1) and (`tsa_rgb30_client_data`.`NB_trans` >= 5) and (`tsa_rgb30_client_data`.`Value_trans` >= 1000)) then 1 else 0 end)) * 100.0) / nullif(sum((case when (`tsa_rgb30_client_data`.`Active_merchant_30` = 1) then 1 else 0 end)),0)),2) AS `criteria_percentage` from `tsa_rgb30_client_data` group by `tsa_rgb30_client_data`.`region2` order by `active_per_criteria` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tsa_global_monthly`
--

/*!50001 DROP VIEW IF EXISTS `tsa_global_monthly`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tsa_global_monthly` AS with `site_tsa_counts` as (select `tsa_sectorisation`.`SITES` AS `SITES`,count(distinct `tsa_sectorisation`.`TSA_ID`) AS `tsa_count` from `tsa_sectorisation` group by `tsa_sectorisation`.`SITES`), `fair_share_per_site` as (select `tn`.`TSA_Full_NAME` AS `TSA_Full_NAME`,`tn`.`Numero_Corporate` AS `Numero_Corporate`,`tn`.`Region_Intern` AS `Region_Intern`,`tn`.`Agent_Monthly_target` AS `Agent_Monthly_target`,`tn`.`Merchant_Monthly_target` AS `Merchant_Monthly_target`,`ts`.`SITES` AS `SITES`,(`trt`.`juin-26` / `stc`.`tsa_count`) AS `rga_fair_share`,(`trt2`.`juin-26` / `stc`.`tsa_count`) AS `rgb_monthly_fair_share`,(case when (`trt2`.`site_id` <> 'NOT_LOCATED') then (`trt2`.`déc-26` / `stc`.`tsa_count`) else 0 end) AS `rgb_eoy_fair_share` from ((((`tsa_numenclature` `tn` left join `tsa_sectorisation` `ts` on((`tn`.`TSA_ID` = `ts`.`TSA_ID`))) left join `site_tsa_counts` `stc` on((`ts`.`SITES` = `stc`.`SITES`))) left join `tsa_rga30_target` `trt` on((`ts`.`SITES` = `trt`.`site_id`))) left join `tsa_rgb30_target` `trt2` on((`ts`.`SITES` = `trt2`.`site_id`))) where (`tn`.`Region_Intern` <> 'null')) select `fair_share_per_site`.`TSA_Full_NAME` AS `TSA_Full_NAME`,`fair_share_per_site`.`Numero_Corporate` AS `Numero_Corporate`,`fair_share_per_site`.`Region_Intern` AS `Region_Intern`,count(`fair_share_per_site`.`SITES`) AS `site_count`,round(sum(`fair_share_per_site`.`rga_fair_share`),0) AS `RGA_target_Monthly`,round(sum(`fair_share_per_site`.`rgb_monthly_fair_share`),0) AS `RGB_target_Monthly`,round(sum(`fair_share_per_site`.`rgb_eoy_fair_share`),0) AS `RGB_target_EOY`,`fair_share_per_site`.`Agent_Monthly_target` AS `Agent_Monthly_target`,`fair_share_per_site`.`Merchant_Monthly_target` AS `Merchant_Monthly_target` from `fair_share_per_site` group by `fair_share_per_site`.`TSA_Full_NAME`,`fair_share_per_site`.`Numero_Corporate`,`fair_share_per_site`.`Region_Intern`,`fair_share_per_site`.`Agent_Monthly_target`,`fair_share_per_site`.`Merchant_Monthly_target` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tsa_monthly_performance`
--

/*!50001 DROP VIEW IF EXISTS `tsa_monthly_performance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tsa_monthly_performance` AS with `report_recap` as (select `tsa_numenclature`.`TSA_Full_NAME` AS `TSA_full_NAME`,`tsa_numenclature`.`TSA_ID` AS `TSA_ID`,`tsa_numenclature`.`Numero_Corporate` AS `Numero_corporate`,`tsa_numenclature`.`Region_Intern` AS `Region_Intern`,`tsa_numenclature`.`RBM` AS `RBM`,`tsa_numenclature`.`Agent_weekly_target` AS `Agent_weekly_target`,`tsa_numenclature`.`Merchant_Weekly_target` AS `Merchant_weekly_target`,`tsa_numenclature`.`Agent_Monthly_target` AS `Agent_monthly_target`,`tsa_numenclature`.`Merchant_Monthly_target` AS `Merchant_monthly_target` from `tsa_numenclature` where (`tsa_numenclature`.`Region_Intern` <> 'NULL')), `deployment_count` as (select `td`.`agentInfo__id` AS `agentInfo__id`,count((case when ((`td`.`type` = 'deployment') and (`td`.`typePos` <> 'Merchant') and (month(`td`.`Date`) = 6) and (year(`td`.`Date`) = 2026)) then `td`.`X_id` end)) AS `Agent_deployments`,count((case when ((`td`.`type` = 'deployment') and (`td`.`typePos` <> 'Merchant') and (week(`td`.`Date`,3) = week((case when (dayofweek(curdate()) = 1) then (curdate() - interval 1 day) else curdate() end),3)) and (year(`td`.`Date`) = year(curdate()))) then `td`.`X_id` end)) AS `Agent_deployments_current_week`,count((case when ((`td`.`type` = 'deployment') and (`td`.`typePos` = 'Merchant') and (month(`td`.`Date`) = 6) and (year(`td`.`Date`) = 2026)) then `td`.`X_id` end)) AS `Merchant_deployments`,count((case when ((`td`.`type` = 'deployment') and (`td`.`typePos` = 'Merchant') and (week(`td`.`Date`,3) = week((case when (dayofweek(curdate()) = 1) then (curdate() - interval 1 day) else curdate() end),3)) and (year(`td`.`Date`) = year(curdate()))) then `td`.`X_id` end)) AS `Merchant_deployments_current_week` from `tsa_deployments` `td` where (`td`.`Date` between '2026-05-26' and '2026-06-30') group by `td`.`agentInfo__id`), `acquition_kiosk` as (select `tn`.`TSA_ID` AS `TSA_ID`,count(distinct `tk`.`USERNAME`) AS `number_of_Kiosk`,sum(`n`.`newadd`) AS `New_add` from ((`tsa_kiosk_data` `tk` left join `tsa_numenclature` `tn` on((`tk`.`TSA_ID` = `tn`.`TSA_ID`))) left join `newadd` `n` on((`tk`.`USERNAME` = `n`.`Username`))) where (str_to_date(`n`.`Date`,'%d/%m/%Y') between '2026-06-01' and '2026-06-30') group by `tn`.`TSA_ID`), `unique_site_owner` as (select `tsa_sectorisation`.`SITES` AS `SITES`,min(`tsa_sectorisation`.`TSA_ID`) AS `TSA_ID` from `tsa_sectorisation` group by `tsa_sectorisation`.`SITES`), `rgb_target` as (select `u`.`TSA_ID` AS `TSA_ID`,sum(`trt`.`juin-26`) AS `total_target` from (`tsa_rgb30_target` `trt` left join `unique_site_owner` `u` on((`trt`.`site_id` = `u`.`SITES`))) group by `u`.`TSA_ID`), `rgb_active` as (select `u`.`TSA_ID` AS `TSA_ID`,count(`trcd`.`MSISDN`) AS `total_active_merchant`,count((case when ((`trcd`.`NB_trans` >= 5) and (`trcd`.`Value_trans` >= 1000)) then `trcd`.`MSISDN` end)) AS `total_active_merchant_creteria` from (`tsa_rgb30_client_data` `trcd` left join `unique_site_owner` `u` on((`trcd`.`site_id` = `u`.`SITES`))) where (`trcd`.`Active_merchant_30` = 1) group by `u`.`TSA_ID`), `rgb_agg` as (select `a`.`TSA_ID` AS `TSA_ID`,`a`.`total_active_merchant` AS `total_active_merchant`,`a`.`total_active_merchant_creteria` AS `total_active_merchant_creteria`,`t`.`total_target` AS `total_target`,(case when (`t`.`total_target` > 0) then (`a`.`total_active_merchant` / `t`.`total_target`) else 0 end) AS `pct_active_merchant`,(case when (`t`.`total_target` > 0) then (`a`.`total_active_merchant_creteria` / `t`.`total_target`) else 0 end) AS `pct_active_merchant_creteria` from (`rgb_active` `a` left join `rgb_target` `t` on((`a`.`TSA_ID` = `t`.`TSA_ID`)))) select `rr`.`TSA_full_NAME` AS `TSA_full_NAME`,`rr`.`TSA_ID` AS `TSA_ID`,`rr`.`Numero_corporate` AS `Numero_corporate`,`rr`.`Region_Intern` AS `Region_Intern`,`rr`.`RBM` AS `RBM`,count((case when ((month(`tr`.`Date`) = 6) and (year(`tr`.`Date`) = 2026)) then `tr`.`posId` end)) AS `Visits_Monthly`,count((case when ((week(`tr`.`Date`,3) = week((case when (dayofweek(curdate()) = 1) then (curdate() - interval 1 day) else curdate() end),3)) and (year(`tr`.`Date`) = year(curdate()))) then `tr`.`posId` end)) AS `Visits_weekly`,count(distinct (case when ((month(`tr`.`Date`) = 6) and (year(`tr`.`Date`) = 2026)) then `tr`.`Date` end)) AS `Number_of_active_days`,coalesce(`dc`.`Agent_deployments`,0) AS `Agent_Deployment_Month`,`rr`.`Agent_monthly_target` AS `Agent_monthly_target`,round((coalesce(`dc`.`Agent_deployments`,0) / `rr`.`Agent_monthly_target`),2) AS `Agent_deployment_Monthly_achieved`,coalesce(`dc`.`Agent_deployments_current_week`,0) AS `Agent_Deployment_Week`,`rr`.`Agent_weekly_target` AS `Agent_weekly_target`,round((coalesce(`dc`.`Agent_deployments_current_week`,0) / `rr`.`Agent_weekly_target`),2) AS `Agent_deployment_Weekly_achieved`,coalesce(`dc`.`Merchant_deployments`,0) AS `Merchant_Deployment_Month`,`rr`.`Merchant_monthly_target` AS `Merchant_monthly_target`,round((coalesce(`dc`.`Merchant_deployments`,0) / `rr`.`Merchant_monthly_target`),2) AS `Merchant_deployment_Monthly_achieved`,coalesce(`dc`.`Merchant_deployments_current_week`,0) AS `Merchant_Deployment_Week`,`rr`.`Merchant_weekly_target` AS `Merchant_weekly_target`,round((coalesce(`dc`.`Merchant_deployments_current_week`,0) / `rr`.`Merchant_weekly_target`),2) AS `Merchant_deployment_Weekly_achieved`,coalesce(`ak`.`number_of_Kiosk`,0) AS `number_of_Kiosk`,coalesce(`ak`.`New_add`,0) AS `New_add`,120 AS `new_add_Target`,round((coalesce(`ak`.`New_add`,0) / 120),2) AS `pct_new_add`,`ra`.`total_target` AS `total_target`,coalesce(`ra`.`total_active_merchant`,0) AS `total_active_merchant`,coalesce(`ra`.`total_active_merchant_creteria`,0) AS `total_active_merchant_creteria`,coalesce(`ra`.`pct_active_merchant`,0) AS `pct_active_merchant`,coalesce(`ra`.`pct_active_merchant_creteria`,0) AS `pct_active_merchant_creteria` from ((((`report_recap` `rr` left join `tsa_reports` `tr` on(((`rr`.`TSA_ID` = `tr`.`userInfo__id`) and (`tr`.`Date` between '2026-05-26' and '2026-06-30')))) left join `deployment_count` `dc` on((`rr`.`TSA_ID` = `dc`.`agentInfo__id`))) left join `acquition_kiosk` `ak` on((`rr`.`TSA_ID` = `ak`.`TSA_ID`))) left join `rgb_agg` `ra` on((`rr`.`TSA_ID` = `ra`.`TSA_ID`))) group by `rr`.`TSA_full_NAME`,`rr`.`TSA_ID`,`rr`.`Numero_corporate`,`rr`.`Region_Intern`,`rr`.`RBM`,`rr`.`Agent_weekly_target`,`rr`.`Merchant_weekly_target`,`rr`.`Agent_monthly_target`,`rr`.`Merchant_monthly_target`,`dc`.`Agent_deployments`,`dc`.`Agent_deployments_current_week`,`dc`.`Merchant_deployments`,`dc`.`Merchant_deployments_current_week`,`ak`.`number_of_Kiosk`,`ak`.`New_add`,`ra`.`total_active_merchant`,`ra`.`total_active_merchant_creteria`,`ra`.`pct_active_merchant`,`ra`.`pct_active_merchant_creteria`,`ra`.`total_target` order by `rr`.`Region_Intern` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-02 11:52:31
