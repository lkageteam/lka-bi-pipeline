-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: brand_soldier_activities
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
-- Table structure for table `ayoba`
--

DROP TABLE IF EXISTS `ayoba`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ayoba` (
  `X_id` varchar(24) DEFAULT NULL,
  `agentId` varchar(24) DEFAULT NULL,
  `type` varchar(8) DEFAULT NULL,
  `userInfo_firstName` varchar(27) DEFAULT NULL,
  `userInfo_lastName` varchar(21) DEFAULT NULL,
  `userInfo_email` varchar(34) DEFAULT NULL,
  `userInfo_idCardNumber` varchar(19) DEFAULT NULL,
  `userInfo_role_label` varchar(14) DEFAULT NULL,
  `userInfo_role__id` varchar(24) DEFAULT NULL,
  `userInfo_role_sigle` varchar(5) DEFAULT NULL,
  `userInfo_role___v` int DEFAULT NULL,
  `userInfo_region_label` varchar(10) DEFAULT NULL,
  `userInfo_region__id` varchar(24) DEFAULT NULL,
  `userInfo_region_role` varchar(3) DEFAULT NULL,
  `userInfo_region_createdAt` varchar(24) DEFAULT NULL,
  `userInfo_region___v` int DEFAULT NULL,
  `userInfo_activate` varchar(5) DEFAULT NULL,
  `userInfo_desactivate` varchar(5) DEFAULT NULL,
  `userInfo_createdAt` varchar(24) DEFAULT NULL,
  `userInfo_updatedAt` varchar(24) DEFAULT NULL,
  `userInfo_phoneNumber` int DEFAULT NULL,
  `userInfo_superviseurId` varchar(24) DEFAULT NULL,
  `userInfo_superviseurName` varchar(18) DEFAULT NULL,
  `userInfo_superviseurLastName` varchar(13) DEFAULT NULL,
  `userInfo_superviseurIdUnique` varchar(9) DEFAULT NULL,
  `userInfo_idUnique` varchar(9) DEFAULT NULL,
  `userInfo_numeroBadge` varchar(17) DEFAULT NULL,
  `userInfo__id` varchar(24) DEFAULT NULL,
  `userInfo_regionChoose` varchar(11) DEFAULT NULL,
  `userInfo_desireRole` varchar(7) DEFAULT NULL,
  `userInfo_birthdate` varchar(10) DEFAULT NULL,
  `userInfo_fonction` varchar(21) DEFAULT NULL,
  `userInfo_degree` varchar(61) DEFAULT NULL,
  `userInfo_address` varchar(27) DEFAULT NULL,
  `userInfo_idCardType` varchar(9) DEFAULT NULL,
  `userInfo_gender` varchar(1) DEFAULT NULL,
  `userInfo_corporateNumber` varchar(17) DEFAULT NULL,
  `userInfo___v` int DEFAULT NULL,
  `createdAt` varchar(24) DEFAULT NULL,
  `numClient` double DEFAULT NULL,
  `region` varchar(10) DEFAULT NULL,
  `X__v` int DEFAULT NULL,
  `userInfo_isBanned` varchar(5) DEFAULT NULL,
  `Date` varchar(10) DEFAULT NULL,
  `Time` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dtc_exisiting`
--

DROP TABLE IF EXISTS `dtc_exisiting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dtc_exisiting` (
  `X_id` varchar(24) DEFAULT NULL,
  `userInfo_superviseurIdUnique` varchar(9) DEFAULT NULL,
  `userInfo_idUnique` varchar(9) DEFAULT NULL,
  `userInfo_numeroBadge` varchar(19) DEFAULT NULL,
  `createdAt` varchar(24) DEFAULT NULL,
  `numClient` double DEFAULT NULL,
  `montantDepot` double DEFAULT NULL,
  `posCompteAbonne` varchar(20) DEFAULT NULL,
  `serviceAchete` varchar(16) DEFAULT NULL,
  `zone` varchar(32) DEFAULT NULL,
  `region` varchar(10) DEFAULT NULL,
  `typeBa` varchar(24) DEFAULT NULL,
  `createdAt_POSIX` datetime(6) DEFAULT NULL,
  `Date` varchar(10) DEFAULT NULL,
  `Time` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `global_hype`
--

DROP TABLE IF EXISTS `global_hype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `global_hype` (
  `ID_Unique` varchar(10) DEFAULT NULL,
  `Région` varchar(10) DEFAULT NULL,
  `MSISDN` double DEFAULT NULL,
  `TYPE D'ACTION` varchar(16) DEFAULT NULL,
  `MONTANT` double DEFAULT NULL,
  `Date` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `grossaddtarget`
--

DROP TABLE IF EXISTS `grossaddtarget`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grossaddtarget` (
  `Date` datetime(6) DEFAULT NULL,
  `Gross Add Target` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kpi targets`
--

DROP TABLE IF EXISTS `kpi targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kpi targets` (
  `Date` datetime(6) DEFAULT NULL,
  `Gross Add Target` double DEFAULT NULL,
  `MTN Hype` double DEFAULT NULL,
  `DTC Existing` double DEFAULT NULL,
  `Ayoba` double DEFAULT NULL,
  `MAJ` double DEFAULT NULL,
  `Yello App` double DEFAULT NULL,
  `MoMo App` double DEFAULT NULL,
  `New User MoMo` double DEFAULT NULL,
  `DTC Sur SIM` double DEFAULT NULL,
  `New User Data` double DEFAULT NULL,
  `Gross Add Target Productivity 10` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kpi_targets`
--

DROP TABLE IF EXISTS `kpi_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kpi_targets` (
  `Date` datetime(6) DEFAULT NULL,
  `Gross Add Target` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `maj`
--

DROP TABLE IF EXISTS `maj`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maj` (
  `X` tinyint DEFAULT NULL,
  `Numéro_Badge` varchar(19) DEFAULT NULL,
  `ID_Unique` varchar(9) DEFAULT NULL,
  `Contact_abonné` double DEFAULT NULL,
  `Username_BA` varchar(46) DEFAULT NULL,
  `Région` varchar(10) DEFAULT NULL,
  `Ville` varchar(13) DEFAULT NULL,
  `Date` varchar(10) DEFAULT NULL,
  `Heure` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mtn_hype`
--

DROP TABLE IF EXISTS `mtn_hype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mtn_hype` (
  `X_id` varchar(24) DEFAULT NULL,
  `userInfo_superviseurIdUnique` varchar(10) DEFAULT NULL,
  `userInfo_idUnique` varchar(9) DEFAULT NULL,
  `createdAt` varchar(24) DEFAULT NULL,
  `numClient` double DEFAULT NULL,
  `forfait` varchar(8) DEFAULT NULL,
  `montant` double DEFAULT NULL,
  `region` varchar(10) DEFAULT NULL,
  `city` varchar(13) DEFAULT NULL,
  `Date` varchar(10) DEFAULT NULL,
  `Time` varchar(8) DEFAULT NULL
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
  `01/05/2025` double DEFAULT NULL,
  `02/05/2025` double DEFAULT NULL,
  `03/05/2025` double DEFAULT NULL,
  `04/05/2025` double DEFAULT NULL,
  `05/05/2025` double DEFAULT NULL,
  `06/05/2025` double DEFAULT NULL,
  `07/05/2025` double DEFAULT NULL,
  `08/05/2025` double DEFAULT NULL,
  `09/05/2025` double DEFAULT NULL,
  `10/05/2025` double DEFAULT NULL,
  `11/05/2025` double DEFAULT NULL,
  `12/05/2025` double DEFAULT NULL,
  `13/05/2025` double DEFAULT NULL,
  `14/05/2025` double DEFAULT NULL,
  `15/05/2025` double DEFAULT NULL,
  `16/05/2025` double DEFAULT NULL,
  `17/05/2025` double DEFAULT NULL,
  `18/05/2025` double DEFAULT NULL,
  `19/05/2025` double DEFAULT NULL,
  `20/05/2025` double DEFAULT NULL,
  `21/05/2025` double DEFAULT NULL,
  `22/05/2025` double DEFAULT NULL,
  `23/05/2025` double DEFAULT NULL,
  `24/05/2025` double DEFAULT NULL,
  `25/05/2025` double DEFAULT NULL,
  `26/05/2025` double DEFAULT NULL,
  `27/05/2025` double DEFAULT NULL,
  `28/05/2025` double DEFAULT NULL,
  `29/05/2025` double DEFAULT NULL,
  `30/05/2025` double DEFAULT NULL,
  `31/05/2025` double DEFAULT NULL,
  `01/06/2025` double DEFAULT NULL,
  `02/06/2025` double DEFAULT NULL,
  `03/06/2025` double DEFAULT NULL,
  `04/06/2025` double DEFAULT NULL,
  `05/06/2025` double DEFAULT NULL,
  `06/06/2025` double DEFAULT NULL,
  `07/06/2025` double DEFAULT NULL,
  `08/06/2025` double DEFAULT NULL,
  `09/06/2025` double DEFAULT NULL,
  `10/06/2025` double DEFAULT NULL,
  `11/06/2025` double DEFAULT NULL,
  `12/06/2025` double DEFAULT NULL,
  `13/06/2025` double DEFAULT NULL,
  `14/06/2025` double DEFAULT NULL,
  `15/06/2025` double DEFAULT NULL,
  `16/06/2025` double DEFAULT NULL,
  `17/06/2025` double DEFAULT NULL,
  `18/06/2025` double DEFAULT NULL,
  `19/06/2025` double DEFAULT NULL,
  `20/06/2025` double DEFAULT NULL,
  `21/06/2025` double DEFAULT NULL,
  `22/06/2025` double DEFAULT NULL,
  `23/06/2025` double DEFAULT NULL,
  `24/06/2025` double DEFAULT NULL,
  `25/06/2025` double DEFAULT NULL,
  `26/06/2025` double DEFAULT NULL,
  `27/06/2025` double DEFAULT NULL,
  `28/06/2025` double DEFAULT NULL,
  `29/06/2025` double DEFAULT NULL,
  `30/06/2025` double DEFAULT NULL,
  `01/07/2025` double DEFAULT NULL,
  `02/07/2025` double DEFAULT NULL,
  `03/07/2025` double DEFAULT NULL,
  `04/07/2025` double DEFAULT NULL,
  `05/07/2025` double DEFAULT NULL,
  `06/07/2025` double DEFAULT NULL,
  `07/07/2025` double DEFAULT NULL,
  `08/07/2025` double DEFAULT NULL,
  `09/07/2025` double DEFAULT NULL,
  `10/07/2025` double DEFAULT NULL,
  `11/07/2025` double DEFAULT NULL,
  `12/07/2025` double DEFAULT NULL,
  `13/07/2025` double DEFAULT NULL,
  `14/07/2025` double DEFAULT NULL,
  `15/07/2025` double DEFAULT NULL,
  `16/07/2025` double DEFAULT NULL,
  `17/07/2025` double DEFAULT NULL,
  `18/07/2025` double DEFAULT NULL,
  `19/07/2025` double DEFAULT NULL,
  `20/07/2025` double DEFAULT NULL,
  `21/07/2025` double DEFAULT NULL,
  `22/07/2025` double DEFAULT NULL,
  `23/07/2025` double DEFAULT NULL,
  `24/07/2025` double DEFAULT NULL,
  `25/07/2025` double DEFAULT NULL,
  `26/07/2025` double DEFAULT NULL,
  `27/07/2025` double DEFAULT NULL,
  `28/07/2025` double DEFAULT NULL,
  `29/07/2025` double DEFAULT NULL,
  `30/07/2025` double DEFAULT NULL,
  `31/07/2025` double DEFAULT NULL,
  `01/08/2025` double DEFAULT NULL,
  `02/08/2025` double DEFAULT NULL,
  `03/08/2025` double DEFAULT NULL,
  `04/08/2025` double DEFAULT NULL,
  `05/08/2025` double DEFAULT NULL,
  `06/08/2025` double DEFAULT NULL,
  `07/08/2025` double DEFAULT NULL,
  `08/08/2025` double DEFAULT NULL,
  `09/08/2025` double DEFAULT NULL,
  `10/08/2025` double DEFAULT NULL,
  `11/08/2025` double DEFAULT NULL,
  `12/08/2025` double DEFAULT NULL,
  `13/08/2025` double DEFAULT NULL,
  `14/08/2025` double DEFAULT NULL,
  `15/08/2025` double DEFAULT NULL,
  `16/08/2025` double DEFAULT NULL,
  `17/08/2025` double DEFAULT NULL,
  `18/08/2025` double DEFAULT NULL,
  `19/08/2025` double DEFAULT NULL,
  `20/08/2025` double DEFAULT NULL,
  `21/08/2025` double DEFAULT NULL,
  `22/08/2025` double DEFAULT NULL,
  `23/08/2025` double DEFAULT NULL,
  `24/08/2025` double DEFAULT NULL,
  `25/08/2025` double DEFAULT NULL,
  `26/08/2025` double DEFAULT NULL,
  `27/08/2025` double DEFAULT NULL,
  `28/08/2025` double DEFAULT NULL,
  `29/08/2025` double DEFAULT NULL,
  `30/08/2025` double DEFAULT NULL,
  `31/08/2025` double DEFAULT NULL,
  `01/09/2025` double DEFAULT NULL,
  `02/09/2025` double DEFAULT NULL,
  `03/09/2025` double DEFAULT NULL,
  `04/09/2025` double DEFAULT NULL,
  `05/09/2025` double DEFAULT NULL,
  `06/09/2025` double DEFAULT NULL,
  `07/09/2025` double DEFAULT NULL,
  `08/09/2025` double DEFAULT NULL,
  `09/09/2025` double DEFAULT NULL,
  `10/09/2025` double DEFAULT NULL,
  `11/09/2025` double DEFAULT NULL,
  `12/09/2025` double DEFAULT NULL,
  `13/09/2025` double DEFAULT NULL,
  `14/09/2025` double DEFAULT NULL,
  `15/09/2025` double DEFAULT NULL,
  `16/09/2025` double DEFAULT NULL,
  `17/09/2025` double DEFAULT NULL,
  `18/09/2025` double DEFAULT NULL,
  `19/09/2025` double DEFAULT NULL,
  `20/09/2025` double DEFAULT NULL,
  `21/09/2025` double DEFAULT NULL,
  `22/09/2025` double DEFAULT NULL,
  `23/09/2025` double DEFAULT NULL,
  `24/09/2025` double DEFAULT NULL,
  `25/09/2025` double DEFAULT NULL,
  `26/09/2025` double DEFAULT NULL,
  `27/09/2025` double DEFAULT NULL,
  `28/09/2025` double DEFAULT NULL,
  `29/09/2025` double DEFAULT NULL,
  `30/09/2025` double DEFAULT NULL,
  `01/10/2025` double DEFAULT NULL,
  `02/10/2025` double DEFAULT NULL,
  `03/10/2025` double DEFAULT NULL,
  `04/10/2025` double DEFAULT NULL,
  `05/10/2025` double DEFAULT NULL,
  `06/10/2025` double DEFAULT NULL,
  `07/10/2025` double DEFAULT NULL,
  `08/10/2025` double DEFAULT NULL,
  `09/10/2025` double DEFAULT NULL,
  `10/10/2025` double DEFAULT NULL,
  `11/10/2025` double DEFAULT NULL,
  `12/10/2025` double DEFAULT NULL,
  `13/10/2025` double DEFAULT NULL,
  `14/10/2025` double DEFAULT NULL,
  `15/10/2025` double DEFAULT NULL,
  `16/10/2025` double DEFAULT NULL,
  `17/10/2025` double DEFAULT NULL,
  `18/10/2025` double DEFAULT NULL,
  `19/10/2025` double DEFAULT NULL,
  `20/10/2025` double DEFAULT NULL,
  `21/10/2025` double DEFAULT NULL,
  `22/10/2025` double DEFAULT NULL,
  `23/10/2025` double DEFAULT NULL,
  `24/10/2025` double DEFAULT NULL,
  `25/10/2025` double DEFAULT NULL,
  `26/10/2025` double DEFAULT NULL,
  `27/10/2025` double DEFAULT NULL,
  `28/10/2025` double DEFAULT NULL,
  `29/10/2025` double DEFAULT NULL,
  `30/10/2025` double DEFAULT NULL,
  `31/10/2025` double DEFAULT NULL,
  `01/11/2025` double DEFAULT NULL,
  `02/11/2025` double DEFAULT NULL,
  `03/11/2025` double DEFAULT NULL,
  `04/11/2025` double DEFAULT NULL,
  `05/11/2025` double DEFAULT NULL,
  `06/11/2025` double DEFAULT NULL,
  `07/11/2025` double DEFAULT NULL,
  `08/11/2025` double DEFAULT NULL,
  `09/11/2025` double DEFAULT NULL,
  `10/11/2025` double DEFAULT NULL,
  `11/11/2025` double DEFAULT NULL,
  `12/11/2025` double DEFAULT NULL,
  `13/11/2025` double DEFAULT NULL,
  `14/11/2025` double DEFAULT NULL,
  `15/11/2025` double DEFAULT NULL,
  `16/11/2025` double DEFAULT NULL,
  `17/11/2025` double DEFAULT NULL,
  `18/11/2025` double DEFAULT NULL,
  `19/11/2025` double DEFAULT NULL,
  `20/11/2025` double DEFAULT NULL,
  `21/11/2025` double DEFAULT NULL,
  `22/11/2025` double DEFAULT NULL,
  `23/11/2025` double DEFAULT NULL,
  `24/11/2025` double DEFAULT NULL,
  `25/11/2025` double DEFAULT NULL,
  `26/11/2025` double DEFAULT NULL,
  `27/11/2025` double DEFAULT NULL,
  `28/11/2025` double DEFAULT NULL,
  `29/11/2025` double DEFAULT NULL,
  `30/11/2025` double DEFAULT NULL,
  `01/12/2025` double DEFAULT NULL,
  `02/12/2025` double DEFAULT NULL,
  `03/12/2025` double DEFAULT NULL,
  `04/12/2025` double DEFAULT NULL,
  `05/12/2025` double DEFAULT NULL,
  `06/12/2025` double DEFAULT NULL,
  `07/12/2025` double DEFAULT NULL,
  `08/12/2025` double DEFAULT NULL,
  `09/12/2025` double DEFAULT NULL,
  `10/12/2025` double DEFAULT NULL,
  `11/12/2025` double DEFAULT NULL,
  `12/12/2025` double DEFAULT NULL,
  `13/12/2025` double DEFAULT NULL,
  `14/12/2025` double DEFAULT NULL,
  `15/12/2025` double DEFAULT NULL,
  `16/12/2025` double DEFAULT NULL,
  `17/12/2025` double DEFAULT NULL,
  `18/12/2025` double DEFAULT NULL,
  `19/12/2025` double DEFAULT NULL,
  `20/12/2025` double DEFAULT NULL,
  `21/12/2025` double DEFAULT NULL,
  `22/12/2025` double DEFAULT NULL,
  `23/12/2025` double DEFAULT NULL,
  `24/12/2025` double DEFAULT NULL,
  `25/12/2025` double DEFAULT NULL,
  `26/12/2025` double DEFAULT NULL,
  `27/12/2025` double DEFAULT NULL,
  `28/12/2025` double DEFAULT NULL,
  `29/12/2025` double DEFAULT NULL,
  `30/12/2025` double DEFAULT NULL,
  `31/12/2025` double DEFAULT NULL,
  `20/01/2026` double DEFAULT NULL,
  `21/01/2026` double DEFAULT NULL,
  `22/01/2026` double DEFAULT NULL,
  `23/01/2026` double DEFAULT NULL,
  `24/01/2026` double DEFAULT NULL,
  `25/01/2026` double DEFAULT NULL,
  `26/01/2026` double DEFAULT NULL,
  `27/01/2026` double DEFAULT NULL,
  `28/01/2026` double DEFAULT NULL,
  `29/01/2026` double DEFAULT NULL,
  `30/01/2026` double DEFAULT NULL,
  `31/01/2026` double DEFAULT NULL,
  `01/02/2026` double DEFAULT NULL,
  `02/02/2026` double DEFAULT NULL,
  `03/02/2026` double DEFAULT NULL,
  `04/02/2026` double DEFAULT NULL,
  `05/02/2026` double DEFAULT NULL,
  `06/02/2026` double DEFAULT NULL,
  `07/02/2026` double DEFAULT NULL,
  `08/02/2026` double DEFAULT NULL,
  `09/02/2026` double DEFAULT NULL,
  `10/02/2026` double DEFAULT NULL,
  `11/02/2026` double DEFAULT NULL,
  `12/02/2026` double DEFAULT NULL,
  `13/02/2026` double DEFAULT NULL,
  `14/02/2026` double DEFAULT NULL,
  `15/02/2026` double DEFAULT NULL,
  `16/02/2026` double DEFAULT NULL,
  `17/02/2026` double DEFAULT NULL,
  `18/02/2026` double DEFAULT NULL,
  `19/02/2026` double DEFAULT NULL,
  `20/02/2026` double DEFAULT NULL,
  `21/02/2026` double DEFAULT NULL,
  `22/02/2026` double DEFAULT NULL,
  `23/02/2026` double DEFAULT NULL,
  `24/02/2026` double DEFAULT NULL,
  `25/02/2026` double DEFAULT NULL,
  `26/02/2026` double DEFAULT NULL,
  `27/02/2026` double DEFAULT NULL,
  `28/02/2026` double DEFAULT NULL,
  `01/03/2026` double DEFAULT NULL,
  `02/03/2026` double DEFAULT NULL,
  `03/03/2026` double DEFAULT NULL,
  `04/03/2026` double DEFAULT NULL,
  `05/03/2026` double DEFAULT NULL,
  `06/03/2026` double DEFAULT NULL,
  `07/03/2026` double DEFAULT NULL,
  `08/03/2026` double DEFAULT NULL,
  `09/03/2026` double DEFAULT NULL,
  `10/03/2026` double DEFAULT NULL,
  `11/03/2026` double DEFAULT NULL,
  `12/03/2026` double DEFAULT NULL,
  `13/03/2026` double DEFAULT NULL,
  `14/03/2026` double DEFAULT NULL,
  `15/03/2026` double DEFAULT NULL,
  `16/03/2026` double DEFAULT NULL,
  `17/03/2026` double DEFAULT NULL,
  `18/03/2026` double DEFAULT NULL,
  `19/03/2026` double DEFAULT NULL,
  `20/03/2026` double DEFAULT NULL,
  `21/03/2026` double DEFAULT NULL,
  `22/03/2026` double DEFAULT NULL,
  `23/03/2026` double DEFAULT NULL,
  `24/03/2026` double DEFAULT NULL,
  `25/03/2026` double DEFAULT NULL,
  `26/03/2026` double DEFAULT NULL,
  `27/03/2026` double DEFAULT NULL,
  `28/03/2026` double DEFAULT NULL,
  `29/03/2026` double DEFAULT NULL,
  `30/03/2026` double DEFAULT NULL,
  `31/03/2026` double DEFAULT NULL,
  `01/04/2026` double DEFAULT NULL,
  `02/04/2026` double DEFAULT NULL,
  `03/04/2026` double DEFAULT NULL,
  `04/04/2026` double DEFAULT NULL,
  `05/04/2026` double DEFAULT NULL,
  `06/04/2026` double DEFAULT NULL,
  `07/04/2026` double DEFAULT NULL,
  `08/04/2026` double DEFAULT NULL,
  `09/04/2026` double DEFAULT NULL,
  `10/04/2026` double DEFAULT NULL,
  `11/04/2026` double DEFAULT NULL,
  `12/04/2026` double DEFAULT NULL,
  `13/04/2026` double DEFAULT NULL,
  `14/04/2026` double DEFAULT NULL,
  `15/04/2026` double DEFAULT NULL,
  `16/04/2026` double DEFAULT NULL,
  `17/04/2026` double DEFAULT NULL,
  `18/04/2026` double DEFAULT NULL,
  `19/04/2026` double DEFAULT NULL,
  `20/04/2026` double DEFAULT NULL,
  `21/04/2026` double DEFAULT NULL,
  `22/04/2026` double DEFAULT NULL,
  `23/04/2026` double DEFAULT NULL,
  `24/04/2026` double DEFAULT NULL,
  `25/04/2026` double DEFAULT NULL,
  `26/04/2026` double DEFAULT NULL,
  `27/04/2026` double DEFAULT NULL,
  `28/04/2026` double DEFAULT NULL,
  `29/04/2026` double DEFAULT NULL,
  `30/04/2026` double DEFAULT NULL,
  `01/05/2026` double DEFAULT NULL,
  `02/05/2026` double DEFAULT NULL,
  `03/05/2026` double DEFAULT NULL,
  `04/05/2026` double DEFAULT NULL,
  `05/05/2026` double DEFAULT NULL,
  `06/05/2026` double DEFAULT NULL,
  `07/05/2026` double DEFAULT NULL,
  `08/05/2026` double DEFAULT NULL,
  `09/05/2026` double DEFAULT NULL,
  `10/05/2026` double DEFAULT NULL,
  `11/05/2026` double DEFAULT NULL,
  `12/05/2026` double DEFAULT NULL,
  `13/05/2026` double DEFAULT NULL,
  `14/05/2026` double DEFAULT NULL,
  `15/05/2026` double DEFAULT NULL,
  `16/05/2026` double DEFAULT NULL,
  `17/05/2026` double DEFAULT NULL,
  `18/05/2026` double DEFAULT NULL,
  `19/05/2026` double DEFAULT NULL,
  `20/05/2026` double DEFAULT NULL,
  `21/05/2026` double DEFAULT NULL,
  `22/05/2026` double DEFAULT NULL,
  `23/05/2026` double DEFAULT NULL,
  `24/05/2026` double DEFAULT NULL,
  `25/05/2026` double DEFAULT NULL,
  `26/05/2026` double DEFAULT NULL,
  `27/05/2026` double DEFAULT NULL,
  `28/05/2026` double DEFAULT NULL,
  `29/05/2026` double DEFAULT NULL,
  `30/05/2026` double DEFAULT NULL,
  `31/05/2026` double DEFAULT NULL,
  `01/06/2026` double DEFAULT NULL,
  `02/06/2026` double DEFAULT NULL,
  `03/06/2026` double DEFAULT NULL,
  `04/06/2026` double DEFAULT NULL,
  `05/06/2026` double DEFAULT NULL,
  `06/06/2026` double DEFAULT NULL,
  `07/06/2026` double DEFAULT NULL,
  `08/06/2026` double DEFAULT NULL,
  `09/06/2026` double DEFAULT NULL,
  `10/06/2026` double DEFAULT NULL,
  `11/06/2026` double DEFAULT NULL,
  `12/06/2026` double DEFAULT NULL,
  `13/06/2026` double DEFAULT NULL,
  `14/06/2026` double DEFAULT NULL,
  `15/06/2026` double DEFAULT NULL,
  `16/06/2026` double DEFAULT NULL,
  `17/06/2026` double DEFAULT NULL,
  `18/06/2026` double DEFAULT NULL,
  `19/06/2026` double DEFAULT NULL,
  `20/06/2026` double DEFAULT NULL,
  `21/06/2026` double DEFAULT NULL,
  `22/06/2026` double DEFAULT NULL,
  `23/06/2026` double DEFAULT NULL,
  `24/06/2026` double DEFAULT NULL,
  `25/06/2026` double DEFAULT NULL,
  `26/06/2026` double DEFAULT NULL,
  `27/06/2026` double DEFAULT NULL,
  `28/06/2026` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `numenclature`
--

DROP TABLE IF EXISTS `numenclature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `numenclature` (
  `Superviseur` varchar(23) DEFAULT NULL,
  `Superviseur_Id` varchar(9) DEFAULT NULL,
  `Noms&PrénomsBS` varchar(43) DEFAULT NULL,
  `Numéros_Pulse_du_BS` varchar(15) DEFAULT NULL,
  `ID_Unique` varchar(13) DEFAULT NULL,
  `Numéros_MoMo_BS` varchar(19) DEFAULT NULL,
  `Le_BS_a_t-il_un_username?` varchar(3) DEFAULT NULL,
  `UsernameBS` varchar(26) DEFAULT NULL,
  `Statut_Username` varchar(7) DEFAULT NULL,
  `Real_statu_actif` double DEFAULT NULL,
  `Région` varchar(10) DEFAULT NULL,
  `Region_Id` varchar(2) DEFAULT NULL,
  `Région+ Mercen` varchar(10) DEFAULT NULL,
  `Ville` varchar(30) DEFAULT NULL,
  `Departement` varchar(30) DEFAULT NULL,
  `Bus` varchar(6) DEFAULT NULL,
  `Toujours_dans_la_team?` varchar(3) DEFAULT NULL,
  `Type_BA` varchar(15) DEFAULT NULL,
  `RM MTN` varchar(8) DEFAULT NULL,
  `Statu_final_Mars` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `period_data`
--

DROP TABLE IF EXISTS `period_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `period_data` (
  `Date` datetime(6) DEFAULT NULL,
  `Week Day` varchar(3) DEFAULT NULL,
  `Week` varchar(7) DEFAULT NULL,
  `Start date` datetime(6) DEFAULT NULL,
  `End Dqte` datetime(6) DEFAULT NULL,
  `Period` varchar(15) DEFAULT NULL,
  `Month` varchar(9) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pickup_animation_computed`
--

DROP TABLE IF EXISTS `pickup_animation_computed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_animation_computed` (
  `id` varchar(26) DEFAULT NULL,
  `site_id` double DEFAULT NULL,
  `W_minus_4` double DEFAULT NULL,
  `W_minus_3` double DEFAULT NULL,
  `W_minus_2` double DEFAULT NULL,
  `W_minus_1` double DEFAULT NULL,
  `W0` double DEFAULT NULL,
  `W1` double DEFAULT NULL,
  `W2` double DEFAULT NULL,
  `W3` double DEFAULT NULL,
  `W4` double DEFAULT NULL,
  `active_weeks` double DEFAULT NULL,
  `baseline` double DEFAULT NULL,
  `baseline_n_weeks` int DEFAULT NULL,
  `uplift_W0` double DEFAULT NULL,
  `uplift_W1` double DEFAULT NULL,
  `uplift_W2` double DEFAULT NULL,
  `uplift_W3` double DEFAULT NULL,
  `uplift_W4` double DEFAULT NULL,
  `post_sales` double DEFAULT NULL,
  `expected_sales` double DEFAULT NULL,
  `incremental_sales` double DEFAULT NULL,
  `avg_post_sales` double DEFAULT NULL,
  `uplift_pct` double DEFAULT NULL,
  `site_id.x` varchar(6) DEFAULT NULL,
  `W0_date` date DEFAULT NULL,
  `site_id.y` varchar(6) DEFAULT NULL,
  `creatorAnimName` varchar(24) DEFAULT NULL,
  `Date` datetime(6) DEFAULT NULL,
  `startDate` datetime(6) DEFAULT NULL,
  `endDate` datetime(6) DEFAULT NULL,
  `region.label` varchar(10) DEFAULT NULL,
  `region.__v` double DEFAULT NULL,
  `New.code` varchar(15) DEFAULT NULL,
  `SiteId` varchar(6) DEFAULT NULL,
  `animation_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_animation_computed`
--

DROP TABLE IF EXISTS `pos_animation_computed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_animation_computed` (
  `msisdn` varchar(14) DEFAULT NULL,
  `animation_date` date DEFAULT NULL,
  `W_minus_4` double DEFAULT NULL,
  `W_minus_3` double DEFAULT NULL,
  `W_minus_2` double DEFAULT NULL,
  `W_minus_1` double DEFAULT NULL,
  `W0` double DEFAULT NULL,
  `W1` double DEFAULT NULL,
  `W2` double DEFAULT NULL,
  `W3` double DEFAULT NULL,
  `W4` double DEFAULT NULL,
  `active_weeks` double DEFAULT NULL,
  `baseline` double DEFAULT NULL,
  `baseline_n_weeks` int DEFAULT NULL,
  `uplift_W0` double DEFAULT NULL,
  `uplift_W1` double DEFAULT NULL,
  `uplift_W2` double DEFAULT NULL,
  `uplift_W3` double DEFAULT NULL,
  `uplift_W4` double DEFAULT NULL,
  `post_sales` double DEFAULT NULL,
  `expected_sales` double DEFAULT NULL,
  `incremental_sales` double DEFAULT NULL,
  `avg_post_sales` double DEFAULT NULL,
  `uplift_pct` double DEFAULT NULL,
  `DATE` datetime(6) DEFAULT NULL,
  `REGION` varchar(10) DEFAULT NULL,
  `LOCALITE` varchar(130) DEFAULT NULL,
  `NOM DU POS` varchar(47) DEFAULT NULL,
  `NOMS & PRENOMS DU` varchar(42) DEFAULT NULL,
  `CONTACT DU PROMOTTEUR` varchar(16) DEFAULT NULL,
  `OBSERVATION` text,
  `TSA Corporate` varchar(32) DEFAULT NULL,
  `W0.x` date DEFAULT NULL,
  `W0.y` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_performance_long`
--

DROP TABLE IF EXISTS `pos_performance_long`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_performance_long` (
  `Refil type` varchar(6) DEFAULT NULL,
  `from_msisdn` varchar(13) DEFAULT NULL,
  `site_id` varchar(5) DEFAULT NULL,
  `ARRONDISSEMENT` varchar(20) DEFAULT NULL,
  `COMMUNE` varchar(15) DEFAULT NULL,
  `DEPARTEMENT` varchar(10) DEFAULT NULL,
  `REGION` varchar(10) DEFAULT NULL,
  `date_num` varchar(5) DEFAULT NULL,
  `value` double DEFAULT NULL,
  `date` date DEFAULT NULL,
  `week` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sdvalid`
--

DROP TABLE IF EXISTS `sdvalid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sdvalid` (
  `CAMPAIGN_NAME` varchar(9) DEFAULT NULL,
  `DATE.ET.HEURE.D'ENREGISTRELENT.DE.L'OPERATION` varchar(8) DEFAULT NULL,
  `DAYNUMBER` double DEFAULT NULL,
  `TYPE.DE.BA` varchar(24) DEFAULT NULL,
  `BADGE` varchar(19) DEFAULT NULL,
  `ID_Unique` varchar(11) DEFAULT NULL,
  `REGION` varchar(11) DEFAULT NULL,
  `VILLES` varchar(32) DEFAULT NULL,
  `MSISDN` double DEFAULT NULL,
  `TYPE.D'ACTION` varchar(19) DEFAULT NULL,
  `ACTION_TYPE` varchar(17) DEFAULT NULL,
  `AMOUNT` double DEFAULT NULL,
  `Mode.d'activation` varchar(20) DEFAULT NULL,
  `Sender_MSISDN` double DEFAULT NULL,
  `DTC` varchar(3) DEFAULT NULL,
  `NEW.ACTIVATION` double DEFAULT NULL,
  `USERNAME` varchar(24) DEFAULT NULL,
  `LKA_ACTIVATION_RANKING` double DEFAULT NULL,
  `MSISDN_RANKING` double DEFAULT NULL,
  `CAMPAIGN_RANKING` double DEFAULT NULL,
  `TOTAL_ACTIVATION_FROM_MTN` double DEFAULT NULL,
  `REAL_ACTIVATION` double DEFAULT NULL,
  `NEW_ACTIVE_DATA_USER` double DEFAULT NULL,
  `NOUVEAU_SIM` double DEFAULT NULL,
  `NEW_ACTIVATION` double DEFAULT NULL,
  `DTC_ACTIVATION` double DEFAULT NULL,
  `NEW_DTC_USER` double DEFAULT NULL,
  `MPOS` double DEFAULT NULL,
  `OFF_NET` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snd_valid`
--

DROP TABLE IF EXISTS `snd_valid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snd_valid` (
  `CAMPAIGN_NAME` varchar(9) DEFAULT NULL,
  `DATE_ET_HEURE_D'ENREGISTRELENT_DE_L'OPERATION` double DEFAULT NULL,
  `DAYNUMBER` varchar(10) DEFAULT NULL,
  `TYPE_DE_BA` varchar(24) DEFAULT NULL,
  `BADGE` varchar(19) DEFAULT NULL,
  `ID_Unique` varchar(11) DEFAULT NULL,
  `REGION` varchar(11) DEFAULT NULL,
  `VILLES` varchar(22) DEFAULT NULL,
  `MSISDN` double DEFAULT NULL,
  `TYPE_D'ACTION` varchar(19) DEFAULT NULL,
  `ACTION_TYPE` varchar(17) DEFAULT NULL,
  `AMOUNT` double DEFAULT NULL,
  `Mode_d'activation` varchar(20) DEFAULT NULL,
  `Sender_MSISDN` double DEFAULT NULL,
  `DTC` varchar(3) DEFAULT NULL,
  `NEW_ACTIVATION` double DEFAULT NULL,
  `USERNAME` varchar(24) DEFAULT NULL,
  `LKA_ACTIVATION_RANKING` double DEFAULT NULL,
  `MSISDN_RANKING` double DEFAULT NULL,
  `CAMPAIGN_RANKING` double DEFAULT NULL,
  `TOTAL_ACTIVATION_FROM_MTN` double DEFAULT NULL,
  `REAL_ACTIVATION` double DEFAULT NULL,
  `NEW_ACTIVE_DATA_USER` double DEFAULT NULL,
  `NOUVEAU_SIM` double DEFAULT NULL,
  `NEW_ACTIVATION_1` double DEFAULT NULL,
  `DTC_ACTIVATION` double DEFAULT NULL,
  `NEW_DTC_USER` double DEFAULT NULL,
  `MPOS` double DEFAULT NULL,
  `OFF_NET` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `supervisor_list`
--

DROP TABLE IF EXISTS `supervisor_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supervisor_list` (
  `Superviseur` varchar(16) DEFAULT NULL,
  `Supervisor_ID` varchar(9) DEFAULT NULL,
  `MPOS` double DEFAULT NULL,
  `Type` varchar(10) DEFAULT NULL,
  `Bus` varchar(6) DEFAULT NULL,
  `Ville` varchar(13) DEFAULT NULL,
  `Commune` varchar(13) DEFAULT NULL,
  `Departement` varchar(10) DEFAULT NULL,
  `Region` varchar(10) DEFAULT NULL,
  `Tss` varchar(23) DEFAULT NULL,
  `Column1` varchar(9) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tsa_numenclature`
--

DROP TABLE IF EXISTS `tsa_numenclature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tsa_numenclature` (
  `TSA_ID` varchar(24) DEFAULT NULL,
  `Numero_Corporate` double DEFAULT NULL,
  `TSA_first_Name` varchar(32) DEFAULT NULL,
  `TSA_Name` varchar(17) DEFAULT NULL,
  `TSA_Full_NAME` varchar(41) DEFAULT NULL,
  `Login_ID` double DEFAULT NULL,
  `Numero_Corporate2` double DEFAULT NULL,
  `Region_Intern` varchar(10) DEFAULT NULL,
  `Region_Operateur` varchar(10) DEFAULT NULL,
  `RBM` varchar(19) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vente_sim`
--

DROP TABLE IF EXISTS `vente_sim`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vente_sim` (
  `X_id` varchar(24) DEFAULT NULL,
  `userInfo_superviseurIdUnique` varchar(10) DEFAULT NULL,
  `userInfo_idUnique` varchar(10) DEFAULT NULL,
  `createdAt` varchar(24) DEFAULT NULL,
  `numSim` double DEFAULT NULL,
  `statusSimVendue` varchar(8) DEFAULT NULL,
  `compteMomo` varchar(3) DEFAULT NULL,
  `statusMomo` varchar(8) DEFAULT NULL,
  `depotInitial` double DEFAULT NULL,
  `activationForfait` varchar(3) DEFAULT NULL,
  `typeForfait` varchar(16) DEFAULT NULL,
  `montantForfait` double DEFAULT NULL,
  `modeActivation` varchar(6) DEFAULT NULL,
  `region` varchar(10) DEFAULT NULL,
  `newUserData` varchar(3) DEFAULT NULL,
  `moovNumberCalled` double DEFAULT NULL,
  `moovNumberCalling` double DEFAULT NULL,
  `typeBa` varchar(11) DEFAULT NULL,
  `userInfo_numeroBadge` varchar(19) DEFAULT NULL,
  `Date` varchar(10) DEFAULT NULL,
  `Time` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'brand_soldier_activities'
--

--
-- Dumping routines for database 'brand_soldier_activities'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-03  9:50:24
