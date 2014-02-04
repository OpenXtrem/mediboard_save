<?php 
/**
 * Setup EAI
 *  
 * @category EAI
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */

 /**
 * Class CSetupeai
 * Setup EAI
 */

class CSetupeai extends CSetup {
  
  function __construct() {
    parent::__construct();
    
    $this->mod_name = "eai";
    $this->makeRevision("all");
    $this->makeRevision("0.01");
    
    $sql = "CREATE TABLE `message_supported` (
              `message_supported_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
              `object_id` INT (11) UNSIGNED NOT NULL,
              `object_class` VARCHAR (80) NOT NULL,
              `message` VARCHAR (255) NOT NULL,
              `active` ENUM ('0','1') DEFAULT '0'
            ) /*! ENGINE=MyISAM */;";
    $this->addQuery($sql);
    
    $sql = "ALTER TABLE `message_supported` 
              ADD INDEX (`object_id`),
              ADD INDEX (`object_class`);";
    $this->addQuery($sql);
    
    $this->makeRevision("0.02");
    
    $sql = "CREATE TABLE `echange_any` (
              `echange_any_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
              `group_id` INT (11) UNSIGNED NOT NULL,
              `date_production` DATETIME NOT NULL,
              `emetteur_id` INT (11) NOT NULL,
              `destinataire_id` INT (11) NOT NULL,
              `type` CHAR (100),
              `sous_type` CHAR (100),
              `date_echange` DATETIME,
              `message_content_id` INT (11) UNSIGNED,
              `acquittement_content_id` INT (11) UNSIGNED,
              `statut_acquittement` CHAR (20),
              `message_valide` ENUM ('0','1') DEFAULT '0',
              `acquittement_valide` ENUM ('0','1') DEFAULT '0',
              `id_permanent` CHAR (50),
              `object_id` INT (11) UNSIGNED,
              `object_class` CHAR (80)
            ) /*! ENGINE=MyISAM */;";
    $this->addQuery($sql);
    
    $sql = "ALTER TABLE `echange_any` 
              ADD INDEX (`group_id`),
              ADD INDEX (`date_production`),
              ADD INDEX (`date_echange`),
              ADD INDEX (`message_content_id`),
              ADD INDEX (`acquittement_content_id`),
              ADD INDEX (`object_id`),
              ADD INDEX (`object_class`);";
    $this->addQuery($sql);
    
    $this->makeRevision("0.03");
    
    $query = "ALTER TABLE `echange_any` 
                CHANGE `destinataire_id` `receiver_id` INT (11) UNSIGNED;";
    $this->addQuery($query);
    
    $this->makeRevision("0.04");
    
    $query = "ALTER TABLE `echange_any` 
                CHANGE `emetteur_id` `sender_id` INT (11) UNSIGNED;";
    $this->addQuery($query);
    
    $this->makeRevision("0.05");
    
    $query = "ALTER TABLE `echange_any` 
                ADD `sender_class` ENUM ('CSenderFTP','CSenderSOAP','CSenderMLLP');";
    $this->addQuery($query);
    
    $query = "ALTER TABLE `echange_any` 
                ADD INDEX (`sender_id`),
                ADD INDEX (`receiver_id`);";
    $this->addQuery($query);
    
    $this->makeRevision("0.06");
    
    $query = "ALTER TABLE `echange_any` 
                CHANGE `sender_class` `sender_class` VARCHAR (80);";
    $this->addQuery($query);
    
    $this->makeRevision("0.07");
    
    $query = "ALTER TABLE `echange_any` 
                ADD `reprocess` TINYINT (4) UNSIGNED DEFAULT '0';";
    $this->addQuery($query);
    
    $this->makeRevision("0.08");
    
    $query = "CREATE TABLE `domain` (
                `domain_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
                `incrementer_id` INT (11) UNSIGNED NOT NULL,
                `actor_id` INT (11) UNSIGNED,
                `tag` VARCHAR (255) NOT NULL,
                `actor_class` VARCHAR (80) NOT NULL
              ) /*! ENGINE=MyISAM */;";
    $this->addQuery($query);
    
    $query = "ALTER TABLE `domain` 
                ADD INDEX (`incrementer_id`),
                ADD INDEX (`actor_id`);";
    $this->addQuery($query);
    
    $query = "CREATE TABLE `group_domain` (
                `group_domain_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
                `group_id` INT (11) UNSIGNED NOT NULL,
                `domain_id` INT (11) UNSIGNED NOT NULL,
                `object_class` ENUM ('CPatient','CSejour') NOT NULL,
                `master` ENUM ('0','1') NOT NULL DEFAULT '0'
              ) /*! ENGINE=MyISAM */;";
    $this->addQuery($query);
    
    $query = "ALTER TABLE `group_domain` 
                ADD INDEX (`group_id`),
                ADD INDEX (`domain_id`);";
    $this->addQuery($query);

    $this->makeRevision("0.09");

    $query = "CREATE TABLE `object_to_interop_sender` (
                `object_to_interop_sender_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
                `sender_class` VARCHAR (255) NOT NULL,
                `sender_id` INT (11) UNSIGNED NOT NULL,
                `object_class` VARCHAR (255) NOT NULL,
                `object_id` INT (11) UNSIGNED NOT NULL
              )/*! ENGINE=MyISAM */;";
    $this->addQuery($query);

    $query = "ALTER TABLE `object_to_interop_sender`
                ADD INDEX (`sender_id`),
                ADD INDEX (`object_id`);";

    $this->addQuery($query);
    
    $this->makeRevision("0.10");
    
    $query = "ALTER TABLE `domain` 
                CHANGE `incrementer_id` `incrementer_id` INT (11) UNSIGNED,
                CHANGE `actor_class` `actor_class` VARCHAR (80);";
    $this->addQuery($query);
    
    $this->makeRevision("0.11");
    
    function createDomain($setup) {
      $ds = $setup->ds;
      
      $groups = $ds->loadList("SELECT * FROM groups_mediboard");

      $tab = array(
        "CPatient", "CSejour"
      );

      foreach ($groups as $_group) {
        $group_id = $_group["group_id"];

        $group_configs = $ds->loadHash("SELECT * FROM groups_config WHERE object_id = '$group_id'");

        foreach ($tab as $object_class) {
          if ($object_class == "CPatient") {
            $tag_group = CPatient::getTagIPP($group_id);
            if (!array_key_exists("ipp_range_min", $group_configs)) {
              continue;
            }
            $range_min = $group_configs["ipp_range_min"];
            $range_max = $group_configs["ipp_range_max"];
          }
          else {
            $tag_group = CSejour::getTagNDA($group_id);
            if (!array_key_exists("nda_range_min", $group_configs)) {
              continue;
            }
            $range_min = $group_configs["nda_range_min"];
            $range_max = $group_configs["nda_range_max"];
          }

          // Insert domain
          $query = "INSERT INTO `domain` (`domain_id`, `incrementer_id`, `actor_id`, `actor_class`, `tag`) 
                      VALUES (NULL, NULL, NULL, NULL, '$tag_group');";
          $ds->query($query);
          $domain_id = $ds->insertId();
          
          // Insert group domain
          $query = "INSERT INTO `group_domain` (`group_domain_id`, `group_id`, `domain_id`, `object_class`, `master`) 
                      VALUES (NULL, '$group_id', '$domain_id', '$object_class', '1');";
          $ds->query($query);
          
          // Select incrementer for this group
          $select = "SELECT *
                     FROM `incrementer`
                     LEFT JOIN `domain` ON `incrementer`.`incrementer_id` = `domain`.`incrementer_id`
                     LEFT JOIN `group_domain` ON `domain`.`domain_id` = `group_domain`.`domain_id`
                     WHERE `incrementer`.`object_class` = '$object_class'
                     AND `group_domain`.`group_id` = '$group_id';";
          $incrementer = $ds->loadHash($select);
          
          $incrementer_id = $incrementer["incrementer_id"];
          
          if ($incrementer_id) {
            // Update domain with incrementer_id
            $query = "UPDATE `domain` 
                      SET `incrementer_id` = '$incrementer_id'
                      WHERE `domain_id` = '$domain_id';";
            $ds->query($query);
            
            // Update incrementer
            if (!array_key_exists("nda_range_min", $group_configs) || !$range_max || !$range_min) {
              continue;
            }
            $query = "UPDATE `incrementer` 
                      SET `range_min` = '$range_min', `range_max` = '$range_max'
                      WHERE `incrementer_id` = '$incrementer_id';";
            $ds->query($query);
          }
        }
      }
        
        // Update constraints to stick to the event
      return true;
    }

    $this->addFunction("createDomain");
    
    $this->makeRevision("0.12");
    
    $query = "ALTER TABLE `domain` 
                ADD `libelle` VARCHAR (255);";
    $this->addQuery($query);
    
    $this->makeRevision("0.13");
    
    $query = "ALTER TABLE `domain` 
                ADD `derived_from_idex` ENUM ('0','1') DEFAULT '0';";
    $this->addQuery($query);

    $this->makeRevision("0.14");

    $query = "ALTER TABLE `domain`
                ADD `OID` VARCHAR (255);";
    $this->addQuery($query);

    $this->makeRevision("0.15");

    $query = "CREATE TABLE `http_tunnel` (
                `http_tunnel_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
                `address` VARCHAR (255) NOT NULL,
                `status` ENUM ('0','1') NOT NULL DEFAULT '1',
                `start_date` DATETIME,
                `ca_file` VARCHAR (255)
              )/*! ENGINE=MyISAM */;";
    $this->addQuery($query);

    $query = "ALTER TABLE `http_tunnel`
                ADD INDEX (`start_date`);";
    $this->addQuery($query);

    $this->makeRevision("0.16");

    $query = "CREATE TABLE `eai_router` (
                `eai_router_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
                `sender_id` INT (11) UNSIGNED,
                `sender_class` CHAR (80),
                `receiver_id` INT (11) UNSIGNED,
                `receiver_class` CHAR (80),
                `active` ENUM ('0','1') DEFAULT '1'
              )/*! ENGINE=MyISAM */;";
    $this->addQuery($query);

    $query = "ALTER TABLE `eai_router`
                ADD INDEX (`sender_id`),
                ADD INDEX (`sender_class`),
                ADD INDEX (`receiver_id`),
                ADD INDEX (`receiver_class`);";
    $this->addQuery($query);

    $this->makeRevision("0.17");

    function updateRangeDomain($setup) {
      $ds = $setup->ds;

      $groups = $ds->loadList("SELECT * FROM groups_mediboard");

      $tab = array(
        "CPatient", "CSejour"
      );

      foreach ($groups as $_group) {
        $group_id = $_group["group_id"];

        $group_configs = $ds->loadHash("SELECT * FROM groups_config WHERE object_id = '$group_id'");

        foreach ($tab as $object_class) {
          if ($object_class == "CPatient") {
            if (!array_key_exists("ipp_range_min", $group_configs)) {
              continue;
            }
            $range_min = $group_configs["ipp_range_min"];
            $range_max = $group_configs["ipp_range_max"];
          }
          else {
            if (!array_key_exists("nda_range_min", $group_configs)) {
              continue;
            }
            $range_min = $group_configs["nda_range_min"];
            $range_max = $group_configs["nda_range_max"];
          }

          // Select incrementer for this group
          $select = "SELECT *
                     FROM `incrementer`
                     LEFT JOIN `domain` ON `incrementer`.`incrementer_id` = `domain`.`incrementer_id`
                     LEFT JOIN `group_domain` ON `domain`.`domain_id` = `group_domain`.`domain_id`
                     WHERE `incrementer`.`object_class` = '$object_class'
                     AND `group_domain`.`group_id` = '$group_id'";
          $incrementer = $ds->loadHash($select);

          $incrementer_id = $incrementer["incrementer_id"];

          if ($incrementer_id) {
            // Update incrementer
            if (!array_key_exists("nda_range_min", $group_configs) || !$range_max || !$range_min) {
              continue;
            }

            $query = "UPDATE `incrementer`
                      SET `range_min` = '$range_min', `range_max` = '$range_max'
                      WHERE `incrementer_id` = '$incrementer_id';";
            $ds->query($query);
          }
        }
      }

      // Update constraints to stick to the event
      return true;
    }

    $this->addFunction("updateRangeDomain");

    $this->makeRevision("0.18");

    $query = "ALTER TABLE `groups_config`
                DROP `ipp_range_min`,
                DROP `ipp_range_max`,
                DROP `nda_range_min`,
                DROP `nda_range_max`;";
    $this->addQuery($query);

    $this->makeRevision("0.19");

    $query = "ALTER TABLE `incrementer`
                DROP `group_id`;";
    $this->addQuery($query);

    $this->mod_version = "0.20";

    $query = "SELECT * FROM `authorspecialty_20121112` WHERE `code` = 'G15_10/PAC00';";

    $this->addDatasource("ASIP", $query);
  }
}