<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage mediusers
* @version $Revision$
* @author S�bastien Fillonneau
*/

global $AppUI;

$do = new CDoObjectAddEdit("CCategory", "category_id");
$do->createMsg = "Cat�gorie cr��e";
$do->modifyMsg = "Cat�gorie modifi�e";
$do->deleteMsg = "Cat�gorie supprim�e";
$do->doIt();

?>