<?php
/**
 * $Id: do_import_patient.php 4983 2013-12-12 17:09:40Z charly $
 *
 * @package    Mediboard
 * @subpackage dPpatients
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GPLv2
 * @version    $Revision: 4983 $
 */

CCanDo::checkAdmin();
ini_set("auto_detect_line_endings", true);

global $dPconfig;
unset($dPconfig["object_handlers"]["CSipObjectHandler"]);
unset($dPconfig["object_handlers"]["CSmpObjectHandler"]);
CAppUI::stepAjax("D�sactivation du gestionnaire", UI_MSG_OK);

$start    = CValue::post("start");
$count    = CValue::post("count");
$callback = CValue::post("callback");

CApp::setTimeLimit(600);
CApp::setMemoryLimit("512M");

CMbObject::$useObjectCache = false;

importFile(CAppUI::conf("dPpatients imports pat_csv_path"), $start, $count);

$start += $count;
CAppUI::setConf("dPpatients imports pat_start", $start);
CAppUI::setConf("dPpatients imports pat_count", $count);

if ($callback) {
  CAppUI::js("$callback($start,$count)");
}

echo "<tr><td colspan=\"2\">MEMORY: ".memory_get_peak_usage(true)/(1024*1024)." MB"."</td>";
CMbObject::$useObjectCache = true;
CApp::rip();

/**
 * import the patient file
 *
 * @param string $file  path to the file
 * @param int    $start start int
 * @param int    $count number of iterations
 *
 * @return null
 */
function importFile($file, $start, $count) {
  $fp = fopen($file, 'r');

  $patient = new CPatient();
  $patient_specs = CModelObjectFieldDescription::getSpecList($patient);
  CModelObjectFieldDescription::addBefore($patient->_specs["_IPP"], $patient_specs);
  /** @var CMbFieldSpec[] $_patient_specs */
  $_patient_specs = CModelObjectFieldDescription::getArray($patient_specs);
  echo count($_patient_specs)." traits d'import";

  //0 = first line
  if ($start == 0) {
    $start++;
  }

  $line_nb=0;
  while ($line = fgetcsv($fp, null, ";")) {
    $patient = new CPatient();
    if ($line_nb >= $start && $line_nb<($start+$count)) {

      //foreach SPECS, first load
      foreach ($_patient_specs as $key =>  $_specs) {
        $field = $_specs->fieldName;
        $data = $line[$key];

        //specific cleanups
        if ($_specs instanceof CPhoneSpec) {
          $data = preg_replace('/\D/', '', $data);
        }

        if ($field == "sexe") {
          $data = strtolower($data);
        }

        $patient->$field= $data;
      }

      //clone and IPP
      $IPP = $patient->_IPP;
      $patient->_IPP = null;
      $patient->_generate_IPP = false;
      $patient_full = $patient;

      // load by ipp if basic didn't find.
      if (!$patient->_id) {
        $patient->loadFromIPP();
      }

      //load patient with basics
      if (!$patient->_id) {
        $patient->loadMatchingPatient();
      }

      //update fields if import have more data
      foreach ($patient->getPlainFields() as $field => $value) {
        if (!$patient->$field) {
          $patient->$field = $patient_full->$field;
        }
      }

      //found
      if ($patient->_id) {
        //check IPP
        $patient->loadIPP();

        //update
        $patient->store();

        if (!$patient->_IPP) {
          $idex = CIdSante400::getMatch($patient->_class, CPatient::getTagIPP(), $IPP, $patient->_id );
          $idex->last_update = CMbDT::dateTime();
          $idex->store();
          echo "<tr style=\"color:#c98000\"><td>$line_nb</td><td>patient [$patient->nom $patient->prenom] d�j� existant (MAJ ipp : $idex->id400)</td></tr>";
        }
        else {
          echo "<tr style=\"color:#c98000\"><td>$line_nb</td><td>patient [$patient->nom $patient->prenom] d�j� existant (ipp : $patient->_IPP)</td></tr>";
        }


      }
      //not found
      else {
        $result = $patient->store();
        if (!$result) {
          //create IPP
          $idex = CIdSante400::getMatch($patient->_class, CPatient::getTagIPP(), $IPP, $patient->_id );
          $idex->last_update = CMbDT::dateTime();
          $idex->store();
          echo "<tr style=\"color:green\"><td>$line_nb</td><td>patient [$patient->nom $patient->prenom] cr�� (ipp : $idex->id400)</td></tr>";
        }
        // error while storing
        else {
          $patient->repair();
          $result = $patient->store();
          if (!$result) {
            //create IPP
            $idex = CIdSante400::getMatch($patient->_class, CPatient::getTagIPP(), $patient->_IPP, $patient->_id );
            $idex->last_update = CMbDT::dateTime();
            $idex->store();
            echo "<tr style=\"color:green\"><td>$line_nb</td><td>patient [$patient->nom $patient->prenom] cr�� (ipp : $idex->id400)</td></tr>";
          }
          else {
            mbLog("LINE $line_nb : erreur: ".$result);
            echo "<tr  style=\"color:red\"><td>$line_nb</td><td>
              <div class=\"error\">le patient [$patient->nom $patient->prenom] n'a pas �t� cr��<br/>
            erreur: $result</div></td></tr>";
          }
        }
      }
    }

    if ($line_nb > ($start+$count)) {
      break;
    }
    $line_nb++;
  }
}