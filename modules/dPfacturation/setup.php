<?php /* $Id: */

/**
* @package Mediboard
* @subpackage dPfacturation
* @version $Revision: $
* @author Alexis / Yohann
*/

global $AppUI;

// MODULE CONFIGURATION DEFINITION
$config = array();
$config["mod_name"]        = "dPfacturation";
$config["mod_version"]     = "0.11";
$config["mod_type"]        = "user";

class CSetupdPfacturation extends CSetup {
  
  function __construct() {
    parent::__construct();
    
    $this->mod_name = "dPfacturation";
    $this->makeRevision("all");
    
    $sql = "CREATE TABLE `facture` (
 			`facture_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT, 
 			`date` DATE NOT NULL, 
 			`sejour_id` INT(11) UNSIGNED NOT NULL, 
			PRIMARY KEY (`facture_id`)) TYPE=MYISAM;";
     $this->addQuery($sql);
      
     $sql = "CREATE TABLE `factureitem` (
 				`factureitem_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT, 
 				`facture_id` INT(11) UNSIGNED NOT NULL, 
 				`libelle` TEXT NOT NULL, 
 				`prix_ht` FLOAT NOT NULL, 
 				`taxe` FLOAT NOT NULL, 
			PRIMARY KEY (`factureitem_id`)) TYPE=MYISAM;";
     $this->addQuery($sql);   
     
     $this->makeRevision("0.10");
    
     $sql = "ALTER TABLE `facture` ADD `prix` FLOAT NOT NULL";
     $this->addQuery($sql);
  
     $this->mod_version = "0.11";
  }
}
?>
