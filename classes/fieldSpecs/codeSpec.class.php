<?php /* $Id$ */

/**
 *  @package Mediboard
 *  @subpackage classes
 *  @version $Revision: $
 *  @author S�bastien Fillonneau
*/

require_once("./classes/mbFieldSpec.class.php");

class CCodeSpec extends CMbFieldSpec {
  
  var $ccam  = null;
  var $cim10 = null;
  var $adeli = null;
  var $insee = null;
  var $rib   = null;
  
  function getSpecType() {
    return("code");
  }
  
  function checkProperty($object){
 
    $fieldName = $this->fieldName;
    $propValue = $object->$fieldName;
       
    // ccam
    if($this->ccam){
      if (!preg_match ("/^([a-z0-9]){0,7}$/i", $propValue)) {
        return "Code CCAM incorrect, doit contenir 4 lettres et trois chiffres";
      }
    
    // cim10
    }elseif($this->cim10){
      if (!preg_match ("/^([a-z0-9]){0,5}$/i", $propValue)) {
        return "Code CCAM incorrect, doit contenir 5 lettres maximum";
      }
      
    // adeli
    }elseif($this->adeli){
      if (!preg_match ("/^([0-9]){9}$/i", $propValue)) {
        return "Code Adeli incorrect, doit contenir exactement 9 chiffres";
      }

    // RIB
    }elseif($this->rib){
      $compte_banque  = substr($propValue, 0, 5);
      $compte_guichet = substr($propValue, 5, 5);
      $compte_numero  = substr($propValue, 10, 11);
      $compte_cle     = substr($propValue, 21, 2);
      $tabcompte = "";
      $len = strlen($compte_numero);
      for ($i=0; $i < $len; $i++) {
                $car = substr($compte_numero, $i, 1);
                if (!is_numeric($car)) {
                        $c = ord($car) - 64;
                        $b = ($c < 10) ? $c : (($c < 19) ? $c - 9 : $c - 17);
                        $tabcompte .= $b;
                }
                else {
                        $tabcompte .= $car;
                }
        }
        $int = $compte_banque . $compte_guichet . $tabcompte . $compte_cle;
        if (!((strlen($int) >= 21) && (bcmod($int, 97) == 0))){
        	return "Rib incorrect";
        }
        
    // insee
    }elseif($this->insee){
      $matches = null;
      if (!preg_match ("/^([1-2][0-9]{2}[0-9]{2}[0-9]{2}[0-9]{3}[0-9]{3})([0-9]{2})$/i", $propValue, $matches)) {
        return "Matricule incorrect, doit contenir exactement 15 chiffres (commen�ant par 1 ou 2)";
      }
      $code = $matches[1];
      $cle  = $matches[2];
      
      // Use bcmod since standard modulus can't work on numbers exceedind the 2^32 limit
      if (function_exists("bcmod")) {
        if (97 - bcmod($code, 97) != $cle) {
          return "Matricule incorrect, la cl� n'est pas valide";
        }
      }
      
    }else{
      return "Sp�cification de code invalide";
    }
    return null;
  }
  
  function getDBSpec(){
    $type_sql = null;
    
    if($this->ccam){
      $type_sql = "VARCHAR(7)";
    }elseif($this->cim10){
      $type_sql = "VARCHAR(5)";
    }elseif($this->adeli){
      $type_sql = "VARCHAR(9)";
    }elseif($this->insee){
      $type_sql = "VARCHAR(15)";
    }elseif($this->rib){
      $type_sql = "VARCHAR(23)";
    }    
    return $type_sql;
  }

  function getFormHtmlElement($object, $params, $value, $className){
    return $this->getFormElementText($object, $params, $value, $className);
  }
  
  function sample(&$object, $consistent = true) {
    parent::sample($object, $consistent);
    $fieldName = $this->fieldName;
    
    // ccam
    if($this->ccam){
      $object->$fieldName = "BFGA004";
    
    // cim10
    }elseif($this->cim10){
      $object->$fieldName = "H251";
      
    // adeli
    }elseif($this->adeli){
      $object->$fieldName = "123456789";

    // rib
    }elseif($this->rib){
      $object->$fieldName = "11111111111111111111111";
    
    // insee
    }elseif($this->insee){
      $object->$fieldName = "100000000000047";
    }
  }
}

?>