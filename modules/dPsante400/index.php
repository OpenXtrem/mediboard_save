<?php /* $Id: $ */

/**
* @package Mediboard
* @subpackage dPressources
* @version $Revision: $
* @author Thomas Despoix
*/

$module = CModule::getInstalled(basename(dirname(__FILE__)));

$module->registerTab("view_identifiants", "Identifiants Externes", TAB_READ);
$module->registerTab("stats_identifiants", "Statistiques identifiants", TAB_READ);
$module->registerTab("synchro_sante400", "Synchronisation ID Externes", TAB_EDIT);

?>