<?php /* $Id: $ */

/**
* @package Mediboard
* @subpackage dPpatients
* @version $Revision: $
* @author Alexis Granger
*/

// R�cup�ration des crit�res de recherche
$antecedent_patient      = mbGetValueFromGetOrSession("antecedent_patient"          );
$traitement_patient      = mbGetValueFromGetOrSession("traitement_patient"          );
$diagnostic_patient      = mbGetValueFromGetOrSession("diagnostic_patient"          );
$motif_consult           = mbGetValueFromGetOrSession("motif_consult"               );
$remarque_consult        = mbGetValueFromGetOrSession("remarque_consult"            );
$examen_consult          = mbGetValueFromGetOrSession("examen_consult"              );
$traitement_consult      = mbGetValueFromGetOrSession("traitement_consult"          );
$typeAdmission_sejour    = mbGetValueFromGetOrSession("typeAdmission_sejour"        );
$convalescence_sejour    = mbGetValueFromGetOrSession("convalescence_sejour"        );
$remarque_sejour         = mbGetValueFromGetOrSession("remarque_sejour"             );
$materiel_intervention   = mbGetValueFromGetOrSession("materiel_intervention"       );
$examen_intervention     = mbGetValueFromGetOrSession("examen_intervention"         );
$remarque_intervention   = mbGetValueFromGetOrSession("remarque_intervention"       );

$recherche_consult       = mbGetValueFromGetOrSession("recherche_consult","or"      );
$recherche_sejour        = mbGetValueFromGetOrSession("recherche_sejour","or"       );
$recherche_intervention  = mbGetValueFromGetOrSession("recherche_intervention","or" );



//----- Criteres de recherche -----

// Recherche sur les antecedents
$ant = new CAntecedent();
$antecedents = array();
$patients_ant = array();
$where_ant = array();
if($antecedent_patient){
  $where_ant["rques"]   = "LIKE '%$antecedent_patient%'";
}
$order_ant = "antecedent_id, rques";

if ($where_ant) {
  $antecedents = $ant->loadList($where_ant, $order_ant, "0, 30");
}
foreach($antecedents as $key=>$value){
   if($value->object_class != "CPatient"){
   	unset($antecedents[$key]);
   }
   $antecedents_[$key] = $value->object_id;
   $value->loadRefsFwd();
}



// Recherche sur les traitements
$trait = new CTraitement();
$traitements = array();
$patients_trait = array();
$where_trait = array();
if($traitement_patient){ 
  $where_trait["traitement"] = "LIKE '%$traitement_patient%'";
}
$order_trait = "traitement_id, traitement";
if($where_trait) {
  $traitements = $trait->loadList($where_trait, $order_trait, "0, 30");
}
foreach($traitements as $key=>$value){
   if($value->object_class != "CPatient"){
   	unset($traitements_[$key]);
   }
   $traitements_[$key] = $value->object_id;
   $value->loadRefsFwd();
}



// Recherche sur les diagnostics
$where_motif = null;
$where_remarque = null;
$where_examen = null;
$where_traitement = null;
$where_consult = null;

$patients_diag = array();
$where_diag = array();
if($diagnostic_patient){
  $where_diag["listCim10"] = "LIKE '%$diagnostic_patient%'";
}
$order_diag = "patient_id";
$pat_diag = new CPatient();
if($where_diag){
  $patients_diag = $pat_diag->loadList($where_diag, $order_diag, "0, 30");
}



// Recherche sur les Consultations
$consultations = array();
$consult = new CConsultation();
$patient_consult = array();


if($recherche_consult == "and") {
  if($motif_consult){
    $where_consult["motif"]      = "LIKE '%$motif_consult%'";
  }
  if($remarque_consult){
   $where_consult["rques"]      = "LIKE '%$remarque_consult%'";
  }  
  if($examen_consult){
   $where_consult["examen"]     = "LIKE '%$examen_consult%'";
  }
  if($traitement_consult){ 
   $where_consult["traitement"] = "LIKE '%$traitement_consult%'";
  }
}


if($recherche_consult == "or") {
  if($motif_consult){
    $where_motif = "`motif` LIKE '%$motif_consult%'";
    $where_consult[] = $where_motif;  
  }
  if($remarque_consult){
    $where_remarque = "`rques` LIKE '%$remarque_consult%'";
    $where_consult[] = $where_remarque; 
  }
  if($examen_consult){
    $where_examen = "`examen` LIKE '%$examen_consult%'";	
    $where_consult[] = $where_examen;  
  }
  if($traitement_consult){
    $where_traitement = "`traitement` LIKE '%$traitement_consult%'";	
    $where_consult[] = $where_traitement;  
  }
  if($where_consult){
    $where_consult = implode(" OR ", $where_consult);
  }
}

$patients_consult = array();

$order_consult = "patient_id";
if($where_consult){
  $consultations = $consult->loadList($where_consult, $order_consult, "0, 30");
}

foreach($consultations as $key=>$value){
	$value->loadRefPatient();
}


// Recherche sur les sejours
$sejours = array();
$sejour = new CSejour();
$patients_sejour = array();
$where_sejour = null;


if($recherche_sejour == "and"){
  if($typeAdmission_sejour){
    $where_sejour["type"]         = "LIKE '%$typeAdmission_sejour%'";
  }
  if($convalescence_sejour){
   $where_sejour["convalescence"] = "LIKE '%$convalescence_sejour%'";
  }  
  if($remarque_sejour){
   $where_sejour["rques"]         = "LIKE '%$remarque_sejour%'";
  }
}


if($recherche_sejour == "or") {
  if($typeAdmission_sejour){
    $where_type = "`type` LIKE '%$typeAdmission_sejour%'";
    $where_sejour[] = $where_type;   
  }
  if($convalescence_sejour){
    $where_convalescence = "`convalescence` LIKE '%$convalescence_sejour%'";
    $where_sejour[] = $where_convalescence;  
  }
  if($remarque_sejour){
    $where_remarque = "`rques` LIKE '%$remarque_sejour%'";	
    $where_sejour[] = $where_remarque;  
  }
  if($where_sejour){
    $where_sejour = implode(" OR ", $where_sejour);
  }
}

$order_sejour = "patient_id";
if($where_sejour){
  $sejours = $sejour->loadList($where_sejour, $order_sejour, "0, 30");
}

foreach($sejours as $key=>$value){
	$value->loadRefPatient();
}



// Recherches sur les Interventions
$interventions = array();
$intervention = new COperation();
$patients_intervention = array();
$where_intervention = null;


if($recherche_intervention == "and") {
  if($materiel_intervention){
    $where_intervention["materiel"] = "LIKE '%$materiel_intervention%'";
  }
  if($examen_intervention){
   $where_intervention["examen"]    = "LIKE '%$examen_intervention%'";
  }  
  if($remarque_intervention){
   $where_intervention["rques"]     = "LIKE '%$remarque_intervention%'";
  }
}

if($recherche_intervention == "or"){
  if($materiel_intervention){
 	$where_materiel = "`materiel` LIKE '%$materiel_intervention%'";
	$where_intervention[] = $where_materiel;
  } 
  if($examen_intervention){
	$where_examen = "`examen` LIKE '%$examen_intervention%'";
	$where_intervention[] = $where_examen;
  }
  if($remarque_intervention){
	$where_remarque = "`rques` LIKE '%$remarque_intervention%'";
    $where_intervention[] = $where_remarque;
  }
  if($where_intervention){
    $where_intervention = implode(" OR ", $where_intervention);
  }
}

$order_intervention = "rques";
if($where_intervention){
	$interventions = $intervention->loadlist($where_intervention, $order_intervention, "0, 30");
}

foreach($interventions as &$intervention){
	$intervention->loadRefSejour();
	$intervention->_ref_sejour->loadRefPatient();
}





// Cr�ation du template
$smarty = new CSmartyDP();

$smarty->assign("sejours"                 , $sejours                 );
$smarty->assign("interventions"           , $interventions           );
$smarty->assign("consultations"           , $consultations           );
$smarty->assign("antecedents"             , $antecedents             );
$smarty->assign("traitements"             , $traitements             );

$smarty->assign("ant"                     , $ant                     );
$smarty->assign("trait"                   , $trait                   );
$smarty->assign("intervention"            , $intervention            );
$smarty->assign("consult"                 , $consult                 );
$smarty->assign("sejour"                  , $sejour                  );
$smarty->assign("pat_diag"                , $pat_diag                );



$smarty->assign("antecedent_patient"      , $antecedent_patient      );
$smarty->assign("traitement_patient"      , $traitement_patient      );
$smarty->assign("diagnostic_patient"      , $diagnostic_patient      );
$smarty->assign("motif_consult"           , $motif_consult           );
$smarty->assign("remarque_consult"        , $remarque_consult        );
$smarty->assign("examen_consult"          , $examen_consult          );
$smarty->assign("traitement_consult"      , $traitement_consult      );
$smarty->assign("typeAdmission_sejour"    , $typeAdmission_sejour    );
$smarty->assign("convalescence_sejour"    , $convalescence_sejour    );
$smarty->assign("remarque_sejour"         , $remarque_sejour         );
$smarty->assign("materiel_intervention"   , $materiel_intervention   );
$smarty->assign("examen_intervention"     , $examen_intervention     );
$smarty->assign("remarque_intervention"   , $remarque_intervention   );

$smarty->assign("recherche_consult"       , $recherche_consult       );
$smarty->assign("recherche_sejour"        , $recherche_sejour        );
$smarty->assign("recherche_intervention"  , $recherche_intervention  );

$smarty->assign("patients_ant"            , $patients_ant            );
$smarty->assign("patients_trait"          , $patients_trait          );
$smarty->assign("patients_diag"           , $patients_diag           );
$smarty->assign("patients_consult"        , $patients_consult        );
$smarty->assign("patients_sejour"         , $patients_sejour         );
$smarty->assign("patients_intervention"   , $patients_intervention   );

$smarty->display("vw_recherche.tpl");

?>