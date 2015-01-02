<?php
/**
 * $Id:$
 *
 * @package    Mediboard
 * @subpackage dPfacturation
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision:$
 */

CConfiguration::register(
  array(
    "CGroups" => array(
      "dPfacturation" => array(
        "CEditPdf" => array(
          "use_bill_fct"  => "bool default|0",
          "use_bill_etab" => "bool default|0",
          "home_nom"      => "str",
          "home_adresse"  => "str",
          "home_cp"       => "str",
          "home_ville"    => "str",
          "home_EAN"      => "str",
          "home_RCC"      => "str",
          "home_tel"      => "str",
          "home_fax"      => "str",
        ),
      )
    )
  )
);