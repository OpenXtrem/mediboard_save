<?php /* CLASSES $Id$ */

/**
* @package dotproject
* @subpackage core
* @license http://opensource.org/licenses/bsd-license.php BSD License
*/

// Message No Constants
define("UI_MSG_OK"     , 1);
define("UI_MSG_ALERT"  , 2);
define("UI_MSG_WARNING", 3);
define("UI_MSG_ERROR"  , 4);

// global variable holding the translation array
$GLOBALS["translate"] = array();

define("UI_CASE_UPPER"     , 1);
define("UI_CASE_LOWER"     , 2);
define("UI_CASE_UPPERFIRST", 3);

/**
* The Application User Interface Class.
*
* @author Andrew Eddie <eddieajau@users.sourceforge.net>
* @version $Revision: 1765 $
*/
class CAppUI {
/** @var array generic array for holding the state of anything */
  var $state = null;
/** @var int */
  var $user_id = 0;
/** @var string */
  var $user_first_name = null;
/** @var string */
  var $user_last_name = null;
/** @var string */
  var $user_email = null;
/** @var int */
  var $user_type = null;
/** @var int */
  var $user_group = null;
/** @var dateTime */
  var $user_last_login = null;
/** @var array */
  var $user_prefs=null;
/** @var int Unix time stamp */
  var $day_selected=null;

// localisation
/** @var string */
  var $user_locale=null;
/** @var string */
  var $base_locale = "en"; // do not change - the base "keys" will always be in english
/** @var string langage alert mask */
  static $locale_mask = "";

  var $messages = array();
  
  var $on_load_events = array();
  
/** @var string Default page for a redirect call*/
  var $defaultRedirect = "";

/** @var array Configuration variable array*/
  var $cfg=null;

  var $ds = null;
/**
 * CAppUI Constructor
 */
  function CAppUI() {
    
    global $dPconfig;
    
    $this->state = array();

    $this->user_first_name = "";
    $this->user_last_name = "";
    $this->user_type = 0;

    $this->project_id = 0;

    $this->defaultRedirect = "";
    
    // set up the default preferences
    $this->user_locale = $this->base_locale;
    $this->user_prefs = array();

    // choose to alert for missing translation or not
    $locale_warn = self::conf("locale_warn") ;
    $locale_alert = self::conf("locale_alert");
    self::$locale_mask = $locale_warn ? "$locale_warn%s$locale_warn" : "%s";
  }
  
  function getAllClasses() {
    $rootDir = $this->getConfig("root_dir");
    foreach(glob("classes/*/*.class.php") as $fileName) {
      require_once("$rootDir/$fileName");
    }
    // Require all global classes
    foreach(glob("classes/*.class.php") as $fileName) {
      require_once("$rootDir/$fileName");
    }
    // Require all modules classes
    foreach(glob("modules/*/*.class.php") as $fileName) {
      require_once("$rootDir/$fileName");
    }
  }

/**
 * Used to load a php class file from the system classes directory
 * @param string $name The class root file name (excluding .class.php)
 * @return string The path to the include file
 */
  function getSystemClass($name=null) {
    if ($name) {
      if ($root = $this->getConfig("root_dir")) {
        return "$root/classes/$name.class.php";
      }
    }
  }

/**
 * Used to load a php class file from the legacy classes directory
 * @param string <b>$name</b> The class file name (excluding .class.php)
 * @return string The path to the include file
 */
  function getLegacyClass($name=null) {
    if ($name) {
      if ($root = $this->getConfig("root_dir")) {
        return "$root/legacy/$name.class.php";
      }
    }
  }

/**
 * Used to load a php class file from the lib directory
 * @param string <b>$name</b> The class root file name (excluding .php)
 * @return string The path to the include file
 */
  function getLibraryFile($name=null) {
    if ($name) {
      if ($root = $this->getConfig("root_dir")) {
        return "$root/lib/$name.php";
      }
    }
  }

/**
 * Used to load a php class file from the module directory
 * @param string $name The class root file name (excluding .class.php)
 * @return string The path to the include file
 */
  function getModuleClass($name = null, $file = null) {
    if ($name) {
      if ($root = $this->getConfig("root_dir")) {
        $filename = $file ? $file : $name;
        return "$root/modules/$name/$filename.class.php";
      }
    }
  }

/**
 * Used to load a php file from the module directory
 * @param string $name The class root file name (excluding .class.php)
 * @return string The path to the include file
 */
  function getModuleFile($name = null, $file = null) {
    if ($name) {
      if ($root = $this->getConfig("root_dir")) {
        $filename = $file ? $file : $name;
        return "$root/modules/$name/$filename.php";
      }
    }
  }
  
/**
 * Used to store information in tmp directory
 * @param string $subpath in tmp directory
 * @return string The path to the include file
 */
  function getTmpPath($subpath) {
    if ($subpath) {
      if ($root = $this->getConfig("root_dir")) {
        return "$root/tmp/$subpath";
      }
    }
  }
  

/**
 * Sets the internal confuration settings array.
 * @param array A named array of configuration variables (usually from config.php)
 */
  function setConfig(&$cfg) {
    $this->cfg = $cfg;
  }

/**
 * Deprecated, see self::conf();
 * Retrieves a configuration setting.
 * @param string The name of a configuration setting
 * @return The value of the setting, otherwise null if the key is not found in the configuration array
 */
  function getConfig($key) {
    if (array_key_exists($key, $this->cfg)) {
      return $this->cfg[$key];
    } else {
      return null;
    }
  }

/**
 * Utility function to read the "directories" under "path"
 *
 * This function is used to read the modules or locales installed on the file system.
 * @param string The path to read.
 * @return array A named array of the directories (the key and value are identical).
 */
  function readDirs($path) {
    $dirs = array();
    $d = dir($this->cfg["root_dir"]."/$path");
    while (false !== ($name = $d->read())) {
      if(is_dir($this->cfg["root_dir"]."/$path/$name") && $name != "." && $name != ".." && $name != "CVS") {
        $dirs[$name] = $name;
      }
    }
    $d->close();
    return $dirs;
  }

/**
 * Utility function to read the "files" under "path"
 * @param string The path to read.
 * @param string A regular expression to filter by.
 * @return array A named array of the files (the key and value are identical).
 */
  function readFiles($path, $filter=".") {
    $files = array();

    if ($handle = opendir($path)) {
      while (false !== ($file = readdir($handle))) { 
        if ($file != "." && $file != ".." && preg_match("/$filter/", $file)) { 
          $files[$file] = $file; 
        } 
      }
      closedir($handle); 
    }
    return $files;
  }


/**
 * Utility function to check whether a file name is "safe"
 *
 * Prevents from access to relative directories (eg ../../dealyfile.php);
 * @param string The file name.
 * @return array A named array of the files (the key and value are identical).
 */
  function checkFileName($file) {
    global $AppUI;

    // define bad characters and their replacement
    $bad_chars = ";.\\";
    $bad_replace = "..."; // Needs the same number of chars as $bad_chars

    // check whether the filename contained bad characters
    if (strpos(strtr($file, $bad_chars, $bad_replace), ".") !== false) {
      $AppUI->redirect("m=system&a=access_denied");
    }
    else {
      return $file;
    }

  }

/**
 * Sets the user locale.
 *
 * Looks in the user preferences first.  If this value has not been set by the user it uses the system default set in config.php.
 * @param string Locale abbreviation corresponding to the sub-directory name in the locales directory (usually the abbreviated language code).
 */
  function setUserLocale() {
    $this->user_locale = $this->user_prefs["LOCALE"];
  }

/**
 * DEPRECATED SEE CAppUI::tr()
 * Translate string to the local language [same form as the gettext abbreviation]
 * @param string The string to translate
 * @return string
 */
  static function _($str) {
    $str = trim($str);
    if (empty($str)) {
      return "";
    }
    
    // Defined and not empty
    if (isset($GLOBALS["translate"][$str]) && $GLOBALS["translate"][$str] != "") {
      return $GLOBALS["translate"][$str];
    }
    
    return sprintf(self::$locale_mask, $str);
  }

/**
* Set the display of warning for untranslated strings
* @param string
*/
  function setWarning($state=true) {
    $temp = @$this->cfg["locale_warn"];
    $this->cfg["locale_warn"] = $state;
    return $temp;
  }
/**
* Save the url query string
*
* Also saves one level of history.  This is useful for returning from a delete
* operation where the record more not now exist.  Returning to a view page
* would be a nonsense in this case.
* @param string If not set then the current url query string is used
*/
  function savePlace($query="") {
    if (!$query) {
      $query = @$_SERVER["QUERY_STRING"];
    }
    if ($query != @$this->state["SAVEDPLACE"]) {
      $this->state["SAVEDPLACE-1"] = @$this->state["SAVEDPLACE"];
      $this->state["SAVEDPLACE"] = $query;
    }
  }

/**
* Redirects the browser to a new page.
*
* Mostly used in conjunction with the savePlace method. It is generally used
* to prevent nasties from doing a browser refresh after a db update.  The
* method deliberately does not use javascript to effect the redirect.
*
* @param string The URL query string to append to the URL
* @param string A marker for a historic "place", only -1 or an empty string is valid.
*/
  function redirect($params="", $hist="") {
    $session_id = SID;

    session_write_close();
  // are the params empty
    if (!$params) {
    // has a place been saved
      $params = !empty($this->state["SAVEDPLACE$hist"]) ? $this->state["SAVEDPLACE$hist"] : $this->defaultRedirect;
    }
    // Fix to handle cookieless sessions
    if ($session_id != "") {
      if (!$params)
        $params = $session_id;
      else
        $params .= "&" . $session_id;
    }
    header("Location: index.php?$params");
    exit(); // stop the PHP execution
  }
  
 /**
  * Add message to the the system UI
  * @param string $msg The (translated) message
  * @param int $type type of message (cf UI constants)
  */
  function setMsg($msg, $type = UI_MSG_OK) {
    $msg = $this->_($msg);
    @$this->messages[$type][$msg]++;
  }
  
  function isMsgOK() {
    $errors = 0;
    $errors += count(@$this->messages[UI_MSG_ALERT]);
    $errors += count(@$this->messages[UI_MSG_WARNING]);
    $errors += count(@$this->messages[UI_MSG_ERROR]);
    return $errors == 0;
  }

  /**
   * Display the formatted message and icon
   * @param boolean $reset If true the system UI is cleared
   */
  function getMsg($reset = true) {
    $return = "";
    
    ksort($this->messages);
    
    foreach ($this->messages as $type => $messages) {
      switch ($type) {
        case UI_MSG_OK      : $class = "message"; break;
        case UI_MSG_ALERT   : $class = "message"; break;
        case UI_MSG_WARNING : $class = "warning"; break;
        case UI_MSG_ERROR   : $class = "error" ; break;
        default: $class = "message"; break;
      }

      foreach ($messages as $message => $count) {
        $render = $count > 1 ? "$message x $count" : $message;
        $return .= "<div class='$class'>$render</div>";
      }
      
    }
    
    if ($reset) {
      $this->messages = array();
    }

    return $return;
  }


  
 /**
  * Display an ajax step, and exit on error messages
  * @param string $msg : the message
  * @param enum $msgType : type of message [UI_MSG_OK|UI_MSG_WARNING|UI_MSG_ERROR]
  */
  static function stepAjax($msg, $msgType = UI_MSG_OK) {
    switch($msgType) {
      case UI_MSG_OK      : $class = "message"; break;
      case UI_MSG_WARNING : $class = "warning"; break;
      case UI_MSG_ERROR   : $class = "error" ; break;
      default: $class = "message"; break;
    }
    
    $msg = nl2br($msg);

    echo "\n<div class='$class'>$msg</div>";
    
    if ($msgType == UI_MSG_ERROR) {
      die;
    }
  }

 /**
  * Echo an ajax callback with given value
  * @param string $callback : name of the javascript function 
  * @param string $value : value paramater for javascript function
  */
  static function callbackAjax($callback, $value) {
    $value = smarty_modifier_json($value);
    echo "\n<script type='text/javascript'>$callback($value);</script>";
  }
  
  
/**
 * Login function
 *
 * Upon a successful username and password match, several fields from the user
 * table are loaded in this object for convenient reference.  The style, localces
 * and preferences are also loaded at this time.
 *
 * @param string The user login name
 * @param string The user password
 * @return boolean True if successful, false if not
 */
  function login() {
    global $dPconfig;
  	$ds = CSQLDataSource::get("std");
    // Test login and password validity
    $user = new CUser;
    $user->user_username = trim(mbGetValueFromPost("username"));
    $user->_user_password = trim(mbGetValueFromPost("password"));
    
    $specsObj = $user->getSpecsObj();
    //mbTrace($specsObj);
    $pwdSpecs = $specsObj['_user_password']; // Spec du mot de passe sans _
    $pwd = $user->_user_password; // Le mot de passe r�cup�r� est avec un _

    $weakPwd = false;
    // minLength
    if ($pwdSpecs->minLength > strlen($pwd)) {
      $weakPwd = true;
    }

    // notContaining
    if($pwdSpecs->notContaining) {
      $target = $pwdSpecs->notContaining;
        if ($field = $user->$target)
          if (stristr($pwd, $field))
            $weakPwd = true;
    }

    // alphaAndNum
    if($pwdSpecs->alphaAndNum) {
      if (!preg_match("/[a-z]/", strtolower($pwd)) || !preg_match("/\d+/", $pwd)) {
        $weakPwd = true;
      }
    }
    
    
    if ($weakPwd) {
      $this->addOnLoadEvents(
      'if (window.opener == null) {
      var url = new Url;
      url.setModuleAction("admin", "chpwd");
      url.addParam("showMessage", "1");
      url.popup(600, 300, "ChangePassword");
    }');
    }
      //$this->setMsg('dsbfjsdbfhsdfhdbj', UI_MSG_WARNING);
      
    // Login as, for administators
    if ($loginas = mbGetValueFromPost("loginas")) {
      if ($this->user_type != 1) {
        $this->setMsg("Only administrator can login as another user", UI_MSG_ERROR);
        return false;
      }
      
      $user->user_username = trim($loginas);
      $user->_user_password = null;
    } 
    // No password given
    elseif (!$user->_user_password) {
      $this->setMsg("You should enter your password", UI_MSG_ERROR);
      return false;
    }
        
    
    
    // See CUser::updateDBFields
    $user->loadMatchingObject();
    
    if (!$user->_id) {
      $this->setMsg("Wrong login/password combination", UI_MSG_ERROR);
      return false;
    }
    
    // Put user_group in AppUI
    $remote = 1;
    if ($ds->loadTable("users_mediboard") && $ds->loadTable("groups_mediboard")) {
      $sql = "SELECT `remote` FROM `users_mediboard` WHERE `user_id` = '$user->user_id'";
      if ($cur = $ds->exec($sql)) {
        if ($row = $ds->fetchRow($cur)) {
          $remote = intval($row[0]);
        }
      }
      $sql = "SELECT `groups_mediboard`.`group_id`" .
          "\nFROM `groups_mediboard`, `functions_mediboard`, `users_mediboard`" .
          "\nWHERE `groups_mediboard`.`group_id` = `functions_mediboard`.`group_id`" .
          "\nAND `functions_mediboard`.`function_id` = `users_mediboard`.`function_id`" .
          "\nAND `users_mediboard`.`user_id` = '$user->user_id'";
      $this->user_group = $ds->loadResult($sql);
    }
    
    // Test if remote connection is allowed
    $browserIP = explode(".", $_SERVER["REMOTE_ADDR"]);
    $ip0 = intval($browserIP[0]);
    $ip1 = intval($browserIP[1]);
    $ip2 = intval($browserIP[2]);
    $ip3 = intval($browserIP[3]);
    $is_local[1] = ($ip0 == 127 && $ip1 == 0 && $ip2 == 0 && $ip3 == 1);
    $is_local[2] = ($ip0 == 10);
    $is_local[3] = ($ip0 == 172 && $ip1 >= 16 && $ip1 < 32);
    $is_local[4] = ($ip0 == 192 && $ip1 == 168);
    $is_local[0] = $is_local[1] || $is_local[2] || $is_local[3] || $is_local[4];
    $is_local[0] = $is_local[0] && ($_SERVER["REMOTE_ADDR"] != $dPconfig["system"]["reverse_proxy"]);
    if (!$is_local[0] && $remote == 1 && $user->user_type != 1) {
      $this->setMsg("User has no remote access", UI_MSG_ERROR);
      return false;
    }

    // Load the user in AppUI
    $this->user_id         = $user->user_id;
    $this->user_first_name = $user->user_first_name;
    $this->user_last_name  = $user->user_last_name;
    $this->user_email      = $user->user_email;
    $this->user_type       = $user->user_type;
    $this->user_last_login = $user->user_last_login;
    
    // save the last_login dateTime
    if($ds->loadField("users", "user_last_login")) {
      // Nullify password or you md5 it once more
      $user->user_last_name = null;
      $user->user_last_login = mbDateTime();
      $user->store();
    }

    // load the user preferences
    $this->loadPrefs($this->user_id);
    $this->setUserLocale();
    return true;
  }

/**
 * Load the stored user preferences from the database into the internal
 * preferences variable.
 * @param int $uid User id number, 0 for default preferences
 */
  function loadPrefs($uid = 0) {
  	$ds = CSQLDataSource::get("std");
    $sql = "SELECT pref_name, pref_value FROM user_preferences WHERE pref_user = '$uid'";
    $user_prefs = $ds->loadHashList($sql);
    $this->user_prefs = array_merge($this->user_prefs, $user_prefs);
  }
  
  /**
   * Attempt to make AppUI functions static for better use
   */

  /**
   * Translate given statement
   * @param string $str statement to translate
   * @return string translated statement
   */
  static function tr($str) {
    $str = trim($str);
    if (empty($str)) {
      return "";
    }
    
    // Defined and not empty
    if (isset($GLOBALS["translate"][$str]) && $GLOBALS["translate"][$str] != "") {
      return $GLOBALS["translate"][$str];
    }
    
    return sprintf(self::$locale_mask, $str);
  }

  /**
   * Return the configuration setting for a given path
   * @param $path string Tokenized path, eg "module class var";
   * @return mixed scalar or array of values depending on the path
   */
  static function conf($path = "") {
    global $dPconfig;
    $conf = $dPconfig;
    foreach (explode(" ", $path) as $part) {
    	$conf = $conf[$part];
    }
    return $conf;
  }
    
  function addOnLoadEvents($code) {
    $this->on_load_events[] = $code;
  }
}

?>