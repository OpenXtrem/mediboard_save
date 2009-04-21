<?php /* $Id$ */

/**
 *	@package Mediboard
 *	@subpackage dPmedicament
 *	@version $Revision$
 *  @author SARL OpenXtrem
 *  @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

global $can;
$can->needsAdmin();

// Comptage
$count = CBcbProduitLivretTherapeutique::countProduitsMed();
CAppUI::stepAjax("Il y a $count produits dans le livret");

// Purge
if (-1 === $purge = CBcbProduitLivretTherapeutique::purgeProduits()) {
  CAppUI::stepAjax("Impossible de supprimer les produits", UI_MSG_ERROR);
}

CAppUI::stepAjax("$purge produits supprim�s dans le livret", UI_MSG_WARNING);
?>