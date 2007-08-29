<?php

/**
 *  @package Mediboard
 *  @subpackage classes
 *  @version $Revision: $
 *  @author Alexis Granger
 */


class CIngresDataSource extends CSQLDataSource {
		
  function connect($host, $name, $user, $pass) {
    if (!function_exists( "ingres_connect" )) {
      trigger_error( "FATAL ERROR: Ingres support not available.  Please check your configuration.", E_USER_ERROR );
      die;
    }
	    
    if ("localhost" != $host) { 
      trigger_error( "FATAL ERROR: Ingres server host has to be 'localhost'", E_USER_ERROR );
      die;
    }
    
    if (!$name) { 
      trigger_error( "FATAL ERROR: Ingres driver has to select a specific database	 'localhost'", E_USER_ERROR );
      die;
    }
    
    if (null == $this->link = ingres_connect($name, $user, $pass)) { 
      trigger_error( "FATAL ERROR: Connection to Ingres server failed", E_USER_ERROR );
      die;
    }
            
//    ingres_autocommit($this->link);
    return $this->link;
  }  
    
  function loadTable($table) {
    $query = "SELECT * FROM iitables".
      "\nWHERE table_name = %";
            
    $values = array (
      $table,
    );    
    
    return $this->loadResult($this->prepare($query, $values));
  }

  function loadField($table, $field) {
    $query = "SELECT column_name FROM iiocolumns".
      "\nWHERE table_name = %".
      "\nAND column_name = %";
            
    $values = array (
      $table,
      $field
    );    
    
    return $this->loadResult($this->prepare($query, $values));
  }   

  function error() {
    return ingres_error($this->link);
  }

  function errno() {
    return ingres_errno($this->link);
  }

  function insertId() {
    // No such implementation
    return -1;
  }

  function query($query) {
    return ingres_query($query, $this->link);
  }
  
  function freeResult($result) {
    // No such implementation
    return;
  }

  function numRows($result) {
    // Uses the link
    return ingres_num_rows($this->link);
  }

  function affectedRows() {
    // No such implementation
    return -1;
  }

  function fetchRow($result) {
    // Uses the link
    return ingres_fetch_array(INGRES_NUM, $this->link);
  }

  function fetchArray($result) {
    // Uses the link
    return ingres_fetch_array(INGRES_BOTH, $this->link);
  }

  function fetchAssoc($result) {
    // Uses the link
    return ingres_fetch_array(INGRES_ASSOC, $this->link);
  }

  function fetchObject($result) {
    // Uses the link
    return ingres_fetch_object(INGRES_ASSOC, $this->link);
  }

  function escape($value) {
    return str_replace("'", "\\'", $value);
  }

  function version() {
    // No such implementation
    return "";
  }
  
  function queriesForDSN($user, $pass, $base) {
    return array(); 
  }
  
}

?>