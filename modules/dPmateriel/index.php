<?php /* $Id: $ */

/**
 *	@package Mediboard
 *	@subpackage dPmateriel
 *	@version $Revision: $
 *  @author S�bastien Fillonneau
 */

require_once($AppUI->getSystemClass("tabindex"));

$tabs = array();
$tabs[] = array("vw_idx_stock", "Edition des stocks", 0);
$tabs[] = array("vw_idx_materiel", "Edition des Fiches mat�riel", 0);
$tabs[] = array("vw_idx_category", "G�rer les cat�gories de mat�riel", 0);
$default = 0;

$index = new CTabIndex($tabs, $default);
$index->show();

?>