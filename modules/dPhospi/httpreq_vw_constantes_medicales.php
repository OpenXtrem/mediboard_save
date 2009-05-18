<?php /* $Id$ */

/**
* @package Mediboard
* @subpackage dPhospi
* @version $Revision$
* @author Fabien M�nager
*/

global $AppUI, $can, $m;

$user = new CMediusers();
$user->load($AppUI->user_id);

if(!$user->isPraticien()) {
  $can->needsRead();
}

$context_guid = mbGetValueFromGet('context_guid');
$selected_context_guid = mbGetValueFromGet('selected_context_guid', $context_guid);
$patient_id = mbGetValueFromGet('patient_id');

$context = null;
$patient = null;

if ($selected_context_guid) {
  $context = CMbObject::loadFromGuid($selected_context_guid);
	$context->loadRefs();
}

if ($context) {
  $patient = $context->_ref_patient;
}

if ($patient_id) {
  $patient = new CPatient;
  $patient->load($patient_id);
}

$patient->loadRefConstantesMedicales();
$patient->loadRefPhotoIdentite();

// Construction d'une constante m�dicale
$constantes = new CConstantesMedicales();
$constantes->patient_id = $patient->_id;

// Les constantes qui correspondent (dans le contexte ou non)
$list_constantes = $constantes->loadMatchingList('datetime');

$list_contexts = array();
foreach($list_constantes as $const) {
  if ($const->context_class && $const->context_id) {
    $c = new $const->context_class;
    $c->load($const->context_id);
    $c->loadRefsFwd();
    $list_contexts[$c->_guid] = $c;
  }
}
$current_context = CMbObject::loadFromGuid($context_guid);
$current_context->loadRefsFwd();
if (!isset($list_contexts[$current_context->_guid])){
  $list_contexts[$current_context->_guid] = $current_context;
}
if (!count($list_contexts)) {
  $list_contexts[] = $current_context;
}

if ($context) {
  $constantes->context_class = $context->_class_name;
  $constantes->context_id = $context->_id;
	$constantes->loadRefContext();
}

// Les constantes qui correspondent (dans le contexte cette fois)
$list_constantes = $constantes->loadMatchingList('datetime');

// La liste des derniers mesures
$latest_constantes = CConstantesMedicales::getLatestFor($patient->_id);

$standard_struct = array(
  'series' => array(
    array('data' => array()),
  ),
);

// Initialisation de la structure des donn�es
$data = array();
foreach(CConstantesMedicales::$list_constantes as $cst) {
  $data[$cst] = $standard_struct;
}

$data['ta'] = array(
  'series' => array(
    array(
      'data' => array(),
      'label' => 'Systole',
    ),
    array(
      'data' => array(),
      'label' => 'Diastole',
    ),
  ),
);

// Petite fonction utilitaire de r�cup�ration des valeurs
function getValue($v) {
  return ($v === null) ? null : floatval($v);
}

$dates = array();
$hours = array();
$const_ids = array();
$i = 0;

// Si le s�jour a des constantes m�dicales
if ($list_constantes) {
  foreach ($list_constantes as $cst) {
    $dates[$i] = mbTransformTime($cst->datetime, null, '%d/%m/%y');
    $hours[$i] = mbTransformTime($cst->datetime, null, '%Hh%M');
    $const_ids[$i] = $cst->_id;
    
    foreach ($data as $name => &$field) {
    	if ($name == 'ta') {
    		$field['series'][0]['data'][$i] = array($i, getValue($cst->_ta_systole));
    		$field['series'][1]['data'][$i] = array($i, getValue($cst->_ta_diastole));
    		continue;
    	}
    	foreach ($field['series'] as &$serie) {
    		$serie['data'][$i] = array($i, getValue($cst->$name));
    	}
    }
    $i++;
  }
}

function getMax($n, $array) {
  $max = -PHP_INT_MAX;
  
  foreach ($array as $a) {
    if (isset($a[1])) {
      $max = max($n, $a[1], $max);
    }
  }
  return $max;
}

function getMin($n, $array) {
  $min = PHP_INT_MAX;
  
  foreach ($array as $a) {
    if (isset($a[1])) {
      $min = min($n, $a[1], $min);
    }
  }
  return $min;
}

// Mise en place de la ligne de niveau normal pour chaque constante et de l'unit�
$data['ta']['standard'] = 12;
$data['ta']['options']['title'] = utf8_encode('Tension art�rielle (cmHg)');
$data['ta']['options']['yaxis'] = array(
  'min' => getMin(0,  $data['ta']['series'][0]['data']), // min
  'max' => getMax(30, $data['ta']['series'][0]['data']), // max
);

$data['pouls']['standard'] = 60;
$data['pouls']['options']['title'] = utf8_encode('Pouls (puls./min)');
$data['pouls']['options']['yaxis'] = array(
  'min' => getMin(50,  $data['pouls']['series'][0]['data']), // min
  'max' => getMax(120, $data['pouls']['series'][0]['data']), // max
);

$data['poids']['options']['title'] = utf8_encode('Poids (Kg)');
$data['poids']['options']['yaxis'] = array(
  'min' => getMin(0,   $data['poids']['series'][0]['data']), // min
  'max' => getMax(150, $data['poids']['series'][0]['data']), // max
);

$data['taille']['options']['title'] = utf8_encode('Taille (cm)');
$data['taille']['options']['yaxis'] = array(
  'min' => getMin(0,   $data['taille']['series'][0]['data']), // min
  'max' => getMax(220, $data['taille']['series'][0]['data']), // max
);

$data['temperature']['standard'] = 37.5;
$data['temperature']['options']['title'] = utf8_encode('Temp�rature (�C)');
$data['temperature']['options']['yaxis'] = array(
  'min' => getMin(36, $data['temperature']['series'][0]['data']), // min
  'max' => getMax(41, $data['temperature']['series'][0]['data']), // max
);

$data['spo2']['options']['title'] = utf8_encode('Spo2 (%)');
$data['spo2']['options']['yaxis'] = array(
  'min' => getMin(70,  $data['spo2']['series'][0]['data']), // min
  'max' => getMax(100, $data['spo2']['series'][0]['data']), // max
);

$data['score_sensibilite']['options']['title'] = utf8_encode('Score de sensibilit�');
$data['score_sensibilite']['options']['yaxis'] = array(
  'min' => getMin(0, $data['score_sensibilite']['series'][0]['data']), // min
  'max' => getMax(5, $data['score_sensibilite']['series'][0]['data']), // max
);

$data['score_motricite']['options']['title'] = utf8_encode('Score de motricit�');
$data['score_motricite']['options']['yaxis'] = array(
  'min' => getMin(0, $data['score_motricite']['series'][0]['data']), // min
  'max' => getMax(5, $data['score_motricite']['series'][0]['data']), // max
);

$data['EVA']['options']['title'] = utf8_encode('EVA');
$data['EVA']['options']['yaxis'] = array(
  'min' => getMin(0,  $data['EVA']['series'][0]['data']), // min
  'max' => getMax(10, $data['EVA']['series'][0]['data']), // max
);

$data['score_sedation']['options']['title'] = utf8_encode('Score de s�dation');
$data['score_sedation']['options']['yaxis'] = array(
  'min' => getMin(70,  $data['score_sedation']['series'][0]['data']), // min
  'max' => getMax(100, $data['score_sedation']['series'][0]['data']), // max
);

$data['frequence_respiratoire']['options']['title'] = utf8_encode('Fr�quence respiratoire');
$data['frequence_respiratoire']['options']['yaxis'] = array(
  'min' => getMin(70,  $data['frequence_respiratoire']['series'][0]['data']), // min
  'max' => getMax(100, $data['frequence_respiratoire']['series'][0]['data']), // max
);

// Tableau contenant le nom de tous les graphs
$graphs = array();
foreach ($data as $name => &$field) {
	$graphs[] = "constantes-medicales-$name";
}

// Cr�ation du template
$smarty = new CSmartyDP();
$smarty->assign('constantes', $constantes);
$smarty->assign('context',    $context);
$smarty->assign('context_guid', $context_guid);
$smarty->assign('list_contexts', $list_contexts);
$smarty->assign('patient',    $patient);
$smarty->assign('data',       $data);
$smarty->assign('dates',      $dates);
$smarty->assign('hours',      $hours);
$smarty->assign('const_ids',  $const_ids);
$smarty->assign('latest_constantes', $latest_constantes);
$smarty->assign('graphs', $graphs);
$smarty->display('inc_vw_constantes_medicales.tpl');

?>