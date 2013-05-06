<?php

/**
 * Receiver IHE Config
 *  
 * @category IHE
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */

/**
 * IHE receiver config
 */
class CReceiverIHEConfig extends CMbObjectConfig {
  public $receiver_ihe_config_id;
  
  public $object_id; // CReceiverIHE
  
  // Format
  public $encoding;
  public $ER7_segment_terminator;
  
  // Version
  public $ITI30_HL7_version;
  public $ITI31_HL7_version;
  public $RAD48_HL7_version;
  public $ITI21_HL7_version;
  public $ITI22_HL7_version;

  // Application
  public $receiving_application;
  public $receiving_facility;
  public $assigning_authority_namespace_id;
  public $assigning_authority_universal_id;
  public $assigning_authority_universal_type_id;
  public $country_code;
  
  // Actor Options
  public $iti30_option_merge;
  public $iti30_option_link_unlink;
  public $iti31_in_outpatient_emanagement;
  public $iti31_pending_event_management;
  public $iti31_advanced_encounter_management;
  public $iti31_temporary_patient_transfer_tracking;
  public $iti31_historic_movement;
  
  // Send
  public $modification_admit_code;
  public $send_assigning_authority;
  public $send_all_patients;
  public $send_default_affectation;
  public $send_change_medical_responsibility;
  public $send_change_nursing_ward;
  public $send_change_attending_doctor;
  public $send_first_affectation;
  public $send_provisional_affectation;
  public $send_transfer_patient;
  public $send_own_identifier;
  public $send_self_identifier;
  public $send_update_patient_information;

  // Build
  public $build_mode;
  public $build_NDA;
  public $build_telephone_number;
  public $build_cellular_phone;
  
  // PID
  public $build_PID_31;
  public $build_PID_34;
  
  // PV1
  public $build_PV1_3_2;
  public $build_PV1_3_3;
  public $build_PV1_3_5;
  public $build_PV1_7;
  public $build_PV1_10;
  public $build_PV1_14;
  public $build_PV1_26;
  public $build_PV1_36;
  
  // PV2
  public $build_PV2_45;
  
  public $_categories = array(
    "format" => array(
      "encoding", 
      "ER7_segment_terminator",
    ),
    "version" => array(
      // PAM
      "ITI30_HL7_version",
      "ITI31_HL7_version",

      // SWF
      "RAD48_HL7_version",

      // PDQ
      "ITI21_HL7_version",
      "ITI22_HL7_version",
    ),
    "application" => array(
      "receiving_application",
      "receiving_facility",
      "assigning_authority_namespace_id",
      "assigning_authority_universal_id",
      "assigning_authority_universal_type_id",
      "country_code"
    ),
    "actor options" => array(
      "iti30_option_merge",
      "iti30_option_link_unlink",
      "iti31_in_outpatient_emanagement",
      "iti31_pending_event_management",
      "iti31_advanced_encounter_management",
      "iti31_temporary_patient_transfer_tracking",
      "iti31_historic_movement",
    ),
    "build" => array(
      "build_mode",
      "build_NDA",
      "build_telephone_number",
      "build_cellular_phone"
    ),
    "send" => array(
      "modification_admit_code",
      "send_assigning_authority",
      "send_change_medical_responsibility",
      "send_change_nursing_ward",
      "send_change_attending_doctor",
      "send_all_patients",
      "send_default_affectation",
      "send_first_affectation",
      "send_provisional_affectation",
      "send_transfer_patient",
      "send_own_identifier",
      "send_self_identifier",
      "send_update_patient_information",
    ),
    "PID" => array(
      "build_PID_31",
      "build_PID_34"
    ),
    "PV1" => array(
      "build_PV1_3_2",
      "build_PV1_3_3",
      "build_PV1_3_5",
      "build_PV1_7",
      "build_PV1_10",
      "build_PV1_14",
      "build_PV1_26",
      "build_PV1_36",
    ),
    "PV2" => array(
      "build_PV2_45",
    )
  );

  /**
   * Initialize object specification
   *
   * @return CMbObjectSpec the spec
   */
  function getSpec() {
    $spec = parent::getSpec();

    $spec->table = "receiver_ihe_config";
    $spec->key   = "receiver_ihe_config_id";
    $spec->uniques["uniques"] = array("object_id");

    return $spec;
  }

  /**
   * Get properties specifications as strings
   *
   * @return array
   */
  function getProps() {
    $props = parent::getProps();
    $props["object_id"]              = "ref class|CReceiverIHE";
    
    // Format
    $props["encoding"]               = "enum list|UTF-8|ISO-8859-1 default|UTF-8";
    $props["ER7_segment_terminator"] = "enum list|CR|LF|CRLF";
    
    // Version
    $props["ITI30_HL7_version"] = "enum list|2.1|2.2|2.3|2.3.1|2.4|2.5|FR_2.1|FR_2.2|FR_2.3 default|2.5";
    $props["ITI31_HL7_version"] = "enum list|2.1|2.2|2.3|2.3.1|2.4|2.5|FR_2.1|FR_2.2|FR_2.3 default|2.5";
    $props["RAD48_HL7_version"] = "enum list|2.1|2.2|2.3|2.3.1|2.4|2.5 default|2.5";
    $props["ITI21_HL7_version"] = "enum list|2.1|2.2|2.3|2.3.1|2.4|2.5 default|2.5";
    $props["ITI22_HL7_version"] = "enum list|2.1|2.2|2.3|2.3.1|2.4|2.5 default|2.5";
    
    // Application
    $props["receiving_application"] = "str";
    $props["receiving_facility"]    = "str";
    $props["assigning_authority_namespace_id"]      = "str";
    $props["assigning_authority_universal_id"]      = "str";
    $props["assigning_authority_universal_type_id"] = "str";
    $props["country_code"] = "enum list|FRA";
    
    // Actor options
    $props["iti30_option_merge"]                        = "bool default|1";
    $props["iti30_option_link_unlink"]                  = "bool default|0";
    $props["iti31_in_outpatient_emanagement"]           = "bool default|1";
    $props["iti31_pending_event_management"]            = "bool default|0";
    $props["iti31_advanced_encounter_management"]       = "bool default|1";
    $props["iti31_temporary_patient_transfer_tracking"] = "bool default|0";
    $props["iti31_historic_movement"]                   = "bool default|1";
    
    // Send
    $props["modification_admit_code"]            = "enum list|A08|Z99 default|A08";
    $props["send_assigning_authority"]           = "bool default|1";
    $props["send_change_medical_responsibility"] = "enum list|A02|Z80|Z99 default|Z80";
    $props["send_change_nursing_ward"]           = "enum list|A02|Z84|Z99 default|Z84";
    $props["send_change_attending_doctor"]       = "enum list|A54|Z99 default|A54";
    $props["send_all_patients"]                  = "bool default|0";
    $props["send_default_affectation"]           = "bool default|0";
    $props["send_first_affectation"]             = "enum list|A02|Z99 default|Z99";
    $props["send_provisional_affectation"]       = "bool default|0";
    $props["send_transfer_patient"]              = "enum list|A02|Z99 default|A02";
    $props["send_own_identifier"]                = "bool default|1";
    $props["send_self_identifier"]               = "bool default|0";
    $props["send_update_patient_information"]    = "enum list|A08|A31 default|A31";
    
    // Build
    $props["build_mode"]             = "enum list|normal|simple default|normal";
    $props["build_NDA"]              = "enum list|PID_18|PV1_19 default|PID_18";
    $props["build_telephone_number"] = "enum list|XTN_1|XTN_12 default|XTN_12";
    $props["build_cellular_phone"]   = "enum list|PRN|ORN default|PRN";
    
    // PID
    $props["build_PID_31"]  = "enum list|avs|none default|none";
    $props["build_PID_34"]  = "enum list|finess|actor|domain default|finess";
    
    // PV1
    $props["build_PV1_3_2"] = "enum list|name|config_value|idex default|name";
    $props["build_PV1_3_3"] = "enum list|name|config_value|idex default|name";
    $props["build_PV1_3_5"] = "enum list|bed_status|null default|bed_status";
    $props["build_PV1_7"]   = "enum list|unique|repeatable default|unique";
    $props["build_PV1_10"]  = "enum list|discipline|service default|discipline";
    $props["build_PV1_14"]  = "enum list|admit_source|ZFM default|admit_source";
    $props["build_PV1_26"]  = "enum list|movement_id|none default|none";
    $props["build_PV1_36"]  = "enum list|discharge_disposition|ZFM default|discharge_disposition";
    
    // PV2
    $props["build_PV2_45"]  = "enum list|operation|none default|none";
        
    return $props;
  }
}
