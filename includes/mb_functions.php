<?php /* $Id$ */

/**
 * @package Mediboard
 * @subpackage includes
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

/**
 * Returns the CMbObject with given GET params keys, if it doesn't exist, a redirect is made
 * @param string $class_key The class name of the object
 * @param string $id_key The object ID
 * @param string $guid_key The object GUID (classname-id)
 * @return CMbObject The object loaded or nothing
 **/
function mbGetObjectFromGet($class_key, $id_key, $guid_key = null) {
  $object_class = CValue::get($class_key);
  $object_id    = CValue::get($id_key);
  $object_guid  = "$object_class-$object_id";

  if ($guid_key) {
    $object_guid = CValue::get($guid_key, $object_guid);
  }

  $object = CMbObject::loadFromGuid($object_guid);

  // Redirection
  if (!$object || !$object->_id) {
    global $ajax;
    CAppUI::redirect("ajax=$ajax&suppressHeaders=1&m=system&a=object_not_found&object_guid=$object_guid");
  }
  
  return $object;
}

/**
 * Returns the CMbObject with given GET or SESSION params keys, if it doesn't exist, a redirect is made
 * @param string $class_key The class name of the object
 * @param string $id_key The object ID
 * @param string $guid_key The object GUID (classname-id)
 * @return CMbObject The object loaded or nothing
 **/
function mbGetObjectFromGetOrSession($class_key, $id_key, $guid_key = null) {
  $object_class = CValue::getOrSession($class_key);
  $object_id    = CValue::getOrSession($id_key);
  $object_guid  = "$object_class-$object_id";

  if ($guid_key) {
    $object_guid = CValue::getOrSession($guid_key, $object_guid);
  }

  $object = CMbObject::loadFromGuid($object_guid);

  // Redirection
  if (!$object || !$object->_id) {
    global $ajax;
    CAppUI::redirect("ajax=$ajax&suppressHeaders=1&m=system&a=object_not_found&object_guid=$object_guid");
  }
  
  return $object;
}

function toBool($value) {
  if (!$value) return false;
  return $value === true || preg_match('/^on|1|true|yes$/i', $value);
}

/**
 * Calculate the bank holidays in France
 * @param string The relative date, used to calculate the bank holidays of a specific year
 * @return array List of bank holidays
 **/
function mbBankHolidays($date = null) {
  if(!$date)
    $date = mbDate();
  $year = mbTransformTime("+0 DAY", $date, "%Y");

  // Calcul du Dimanche de P�ques : http://fr.wikipedia.org/wiki/Computus
  $n = $year - 1900;
  $a = $n % 19;
  $b = intval((7 * $a + 1) / 19);
  $c = ((11 * $a) - $b + 4) % 29;
  $d = intval($n / 4);
  $e = ($n - $c + $d + 31) % 7;
  $P = 25 - $c - $e;
  if($P > 0) {
    $P = "+".$P;
  }
  $paques = mbDate("$P DAYS", "$year-03-31");

  $freeDays = array(
    "$year-01-01",               // Jour de l'an
    mbDate("+1 DAY", $paques),   // Lundi de paques
    "$year-05-01",               // F�te du travail
    "$year-05-08",               // Victoire de 1945
    mbDate("+40 DAYS", $paques), // Jeudi de l'ascension
    mbDate("+50 DAYS", $paques), // Lundi de pentec�te
    "$year-07-14",               // F�te nationnale
    "$year-08-15",               // Assomption
    "$year-11-01",               // Toussaint
    "$year-11-11",               // Armistice 1918
    "$year-12-25"                // No�l
  );
  
  return $freeDays;
}

/**
 * Calculate the number of work days in the given month date
 * @param string $date The relative date of the months to get work days
 * @return integer Number of work days 
 **/
function mbWorkDaysInMonth($date = null) {
  $result = 0;
  if(!$date)
    $date = mbDate();
  $year = mbTransformTime("+0 DAY", $date, "%Y");
  $debut = $date;
  $rectif = mbTransformTime("+0 DAY", $debut, "%d")-1;
  $debut = mbDate("-$rectif DAYS", $debut);
  $fin   = $date;
  $rectif = mbTransformTime("+0 DAY", $fin, "%d")-1;
  $fin = mbDate("-$rectif DAYS", $fin);
  $fin = mbDate("+ 1 MONTH", $fin);
  $fin = mbDate("-1 DAY", $fin);
  $freeDays = mbBankHolidays($date);
  for($i = $debut; $i <= $fin; $i = mbDate("+1 DAY", $i)) {
    $day = mbTransformTime("+0 DAY", $i, "%u");
    if($day == 6 and !in_array($i, $freeDays))
      $result += 0.5;
    elseif($day != 7 and !in_array($i, $freeDays))
      $result += 1;
  }
  return $result;
}

/**
 * Transforms absolute or relative time into a given format
 * @param string $relative A relative time
 * @param string $ref An absolute time to transform
 * @param string $format The data in which the date will be returned
 * @return string The transformed date
 **/
function mbTransformTime($relative = null, $ref = null, $format) {
  if ($relative === "last sunday") {
    $relative .= " 12:00:00";
  }
  
  $timestamp = $ref ? strtotime($ref) : time();
  if ($relative) {
    $timestamp = strtotime($relative, $timestamp);
  } 
  return strftime($format, $timestamp);
}

/**
 * Transforms absolute or relative time into DB friendly DATETIME format
 * @param string $relative Modifies the time (eg '+1 DAY')
 * @param datetime The reference date time fo transforms
 * @return string The transformed time 
 **/
function mbDateTime($relative = null, $ref = null) {
  return mbTransformTime($relative, $ref, "%Y-%m-%d %H:%M:%S");
}

/**
 * Transforms absolute or relative time into XML DATETIME format
 * @param string $relative Modifies the time (eg '+1 DAY')
 * @param datetime The reference date time fo transforms
 * @return string The transformed time 
 **/
function mbXMLDateTime($relative = null, $ref = null) {
  return mbTransformTime($relative, $ref, CMbDate::$xmlDateTime);
}

/**
 * Converts an xs;duration XML duration into a DB friendly DATETIME
 * @param string $duration where format is P1Y2M3DT10H30M0S
 * @return string: the DATETIME, null if failed
 **/
function mbDateTimeFromXMLDuration($duration) {
  $regexp = "/P((\d+)Y)?((\d+)M)?((\d+)D)?T((\d+)H)?((\d+)M)?((\d+)S)?/";
  if (!preg_match($regexp, $duration, $matches)) {
    return null;
  }
  
  return sprintf("%d-%d-%d %d:%d:%d", 
    $matches[2], $matches[4], $matches[6], 
    $matches[8], $matches[10], $matches[12]);
}


/**
 * Transforms absolute or relative time into DB friendly DATE format
 * @param String $relative The relative time against the $ref (ex: "-1 MONTH")
 * @param Date $ref The reference date
 * @return Date The transformed time
 **/
function mbDate($relative = null, $ref = null) {
  return mbTransformTime($relative, $ref, "%Y-%m-%d");
}

/**
 * Transforms absolute or relative time into DB friendly TIME format
 * @return string: the transformed time 
 **/
function mbTime($relative = null, $ref = null) {
  return mbTransformTime($relative, $ref, "%H:%M:%S");
}

/**
 * Counts the number of intervals between reference and relative
 * @return int: number of intervals
 **/
function mbTimeCountIntervals($reference, $relative, $interval) {
  $zero = strtotime("0:00:00");
  $refStamp = strtotime($reference) - $zero;
  $relStamp = strtotime($relative ) - $zero;
  $intStamp = strtotime($interval ) - $zero;
  $diffStamp = $relStamp - $refStamp;
  $nbInterval = floatval($diffStamp / $intStamp);
  return intval($nbInterval);
}

function mbTimeGetNearestMinsWithInterval($reference, $mins_interval) {
  $min_reference = mbTransformTime(null, $reference, "%M");
  $div = intval($min_reference / $mins_interval);
  $borne_inf = $mins_interval * $div;
  $borne_sup = $mins_interval * ($div + 1);
  $mins_replace = ($min_reference - $borne_inf) < ($borne_sup - $min_reference) ? $borne_inf : $borne_sup;
  if($mins_replace == 60) {
    $reference = sprintf('%02d:00:00',   mbTransformTime(null, $reference, "%H")+1);
  } else {
    $reference = sprintf('%02d:%02d:00', mbTransformTime(null, $reference, "%H"), $mins_replace);
  }
  return $reference;
}

/**
 * Adds a relative time to a reference time
 * @return string: the resulting time */
function mbAddTime($relative, $ref = null) {
  $fragments = explode(":", $relative);
  $hours   = isset($fragments[0]) ? $fragments[0] : '00';
  $minutes = isset($fragments[1]) ? $fragments[1] : '00';
  $seconds = isset($fragments[2]) ? $fragments[2] : '00';
  return mbTime("+$hours hours $minutes minutes $seconds seconds", $ref);
}

/**
 * Substract a relative time to a reference time
 * @return string: the resulting time */
function mbSubTime($relative, $ref = null) {
  $fragments = explode(":", $relative);
  $hours   = isset($fragments[0]) ? $fragments[0] : '00';
  $minutes = isset($fragments[1]) ? $fragments[1] : '00';
  $seconds = isset($fragments[2]) ? $fragments[2] : '00';
  return mbTime("-$hours hours -$minutes minutes -$seconds seconds", $ref);
}

/**
 * Adds a relative time to a reference datetime
 * @return string: the resulting time */
function mbAddDateTime($relative, $ref = null) {
  $fragments = explode(":", $relative);
  $hours   = isset($fragments[0]) ? $fragments[0] : '00';
  $minutes = isset($fragments[1]) ? $fragments[1] : '00';
  $seconds = isset($fragments[2]) ? $fragments[2] : '00';
  return mbDateTime("+$hours hours $minutes minutes $seconds seconds", $ref);
}

/**
 * Returns the difference between two dates in days
 * @return int: number of days
 **/
function mbDaysRelative($from, $to) {
  if (!$from || !$to) {
    return null;
  }
  $from = intval(strtotime($from) / 86400);
  $to   = intval(strtotime($to  ) / 86400);
  $days = intval($to - $from);
  return $days;
}

/**
 * Returns the time difference between two times in time format
 * @return string hh:mm:ss diff duration
 **/
function mbTimeRelative($from, $to, $format = '%02d:%02d:%02d') {
  $diff = strtotime($to) - strtotime($from); 
  $hours = intval($diff / 3600);
  $mins = intval(($diff % 3600) / 60);
  $secs = intval($diff % 60);
  return sprintf($format, $hours, $mins, $secs);
}

/**
 * Returns the time difference between two times in time format
 * @return float difference in hours
 **/
function mbHoursRelative($from, $to) {
  if (!$from || !$to) {
    return null;
  }
  $hours = (strtotime($to) / 3600) - (strtotime($from) / 3600);
  return $hours;
}

function mbMinutesRelative($from, $to) {
  if (!$from || !$to) {
    return null;
  }
  $from = intval(strtotime($from) / 60);
  $to   = intval(strtotime($to  ) / 60);
  $minutes = intval($to - $from);
  return $minutes;
}

/**
 * Returns is a lunar date
 * @return boolean true or false
 **/
function isLunarDate($date) {
	$fragments = explode("-", $date);

  return ($fragments[2] > 31) || ($fragments[1] > 12);
}

/**
 * Date utility class
 */
class CMbDate {
  static $secs_per = array (
    "year"   => 31536000, // 60 * 60 * 24 * 365
    "month"  =>  2592000, // 60 * 60 * 24 * 30
    "week"   =>   604800, // 60 * 60 * 24 * 7
    "day"    =>    86400, // 60 * 60 * 24
    "hour"   =>     3600, // 60 * 60
    "minute" =>       60, // 60 
    "second" =>        1, // 1 
   );

   static $xmlDate     = "%Y-%m-%d";
   static $xmlTime     = "%H:%M:%S";
   static $xmlDateTime = null;
   
  /** Compute real relative achieved gregorian durations in years and months
   * @param date $from Starting time
   * @param date $to Ending time, now if null
   * return array[int] Number of years and months
   */
	static function achievedDurations($from, $to = null) {
    $achieved = array(
      "year" => "??",
      "month" => "??",
		);
		
    if ($from == "0000-00-00" || !$from) {
      return $achieved;
    }

    if (!$to) {
      $to = mbDate();
    }
    
		list($yf, $mf, $df) = explode("-", $from);
    list($yt, $mt, $dt) = explode("-", $to);

    $achieved["month"] = 12*($yt-$yf) + ($mt-$mf);
    if ($mt == $mf && $dt < $df) {
      $achieved["month"]--;
    }
		
		$achieved["year"] = intval($achieved["month"] / 12); 
		return $achieved;
	}
	
  /**
   * Compute user friendly approximative duration between two date time
   * @param datetime $from Starting time
   * @param datetime $to Ending time, now if null
   * @param int $min_count The minimum count to reach the upper unit, 2 if undefined
   * @return array("unit" => string, "count" => int)
   */
  static function relative($from, $to = null, $min_count = 2) {
    if (!$from) {
      return null;
    }
    
    if (!$to) {
      $to = mbDateTime();
    }
    
    // Compute diff in seconds
    $diff = strtotime($to) - strtotime($from);
    
    // Find the best unit
    foreach (self::$secs_per as $unit => $secs) {
      if (abs($diff / $secs) > $min_count) {
        break;
      }
    }

    return array (
      "unit" => $unit, 
      "count" => intval($diff / $secs)
    );
  }
  
  /**
   * Returns the month number
   * @param Date $date
   * @return int The month number
   */
  static function monthNumber($date) {
    return intval(mbTransformTime(null, $date, "%m"));
  }
  
  /**
   * Computes the week number in the month
   * @param Date $date
   * @return int The week number
   */
  static function weekNumberInMonth($date) {
    $month = self::monthNumber($date);
    $week_number = 0;
    
    do {
      $date = mbDate("-1 WEEK", $date);
      $_month = self::monthNumber($date);
      $week_number++;
    } while ($_month == $month);
    
    return $week_number;
  }
}

CMbDate::$xmlDateTime = CMbDate::$xmlDate."T".CMbDate::$xmlTime;
/**
 * Return the std variance of an array
 * @return float: ecart-type
 **/

function mbMoyenne($array) {
  if (is_array($array)) {
    return array_sum($array) / count($array);
  } else {
    return false;
  }
}

/**
 * Return the std variance of an array
 * @return float: ecart-type
 **/

function mbEcartType($array) {
  if (is_array($array)) {
    $moyenne = mbMoyenne($array);
    $sigma = 0;
    foreach($array as $value) {
      $sigma += pow((floatval($value)-$moyenne),2);
    }
    $ecarttype = sqrt($sigma / count($array));
    return $ecarttype;
  } else {
    return false;
  }
}

/**
 * Inserts a CSV file into a mysql table 
 * Not a generic function : used for import of specials files
 * @todo : become a generic function
 **/

function mbInsertCSV( $fileName, $tableName, $oldid = false ) {
    $ds = CSQLDataSource::get("std");
    $file = fopen( $fileName, 'rw' );
    if(! $file) {
      echo "Fichier non trouv�<br>";
      return;
    }
    $k = 0;
    $reussite = 0;
    $echec = 0;
    $null = 0;
    
    //$contents = fread ($file, filesize ($fileName));
    //$content = str_replace(chr(10), " ", $content);
  
    while (! feof($file)){
        $k++;
        $line = str_replace("NULL", "\"NULL\"", fgets( $file, 1024));
        $size = strlen($line)-3;
        $test1 = $line[$size] != "\"";
        $test2 = 0;
        $test3 = (! feof( $file ));
        $test = ($test1 || (!$test1 && $test2)) && $test3;
        while($test) {
          $line .= str_replace("NULL", "\"NULL\"", fgets( $file, 1024));
          $size = strlen($line)-3;
          $test1 = $line[$size] != "\"";
          $test2 = 0;
          $test3 = (! feof( $file ));
          $test = ($test1 || (!$test1 && $test2)) && $test3;
        }

        if ( strlen( $line ) > 2 )
        {
            $line = addslashes( $line );
            $line = str_replace("\\\";\\\"", "', '", $line);
            $line = str_replace("\\\"", "", $line);
            $line = str_replace("'NULL'", "NULL", $line);
            if($oldid)
              $requete = 'INSERT INTO '.$tableName.' VALUES ( \''.$line.'\', \'\' ) ';
            else
              $requete = 'INSERT INTO '.$tableName.' VALUES ( \''.$line.'\' ) ';
            if ( ! $ds->exec ( $requete ) ) {
                echo 'Erreur Ligne '.$k.' : '.mysql_error().'<br>'.$requete.'<br>';
                $echec++;
            }  else {
                //echo 'Ligne '.$k.' valide.<br>'.$requete.'<br>';
                $reussite++;
            }
        } else {
            //echo 'Ligne '.$k.' ignor�e.<br>';
            $null++;
        }
    }

    echo '<p>Insertion du fichier '.$fileName.' termin�.</p>';
    echo '<p>'.$k.' lignes trouv�es, '.$reussite.' enregistr�es, ';
    echo $echec.' non conformes, '.$null.' ignor�es.</p><hr>';

    fclose( $file );
}

/**
 * URL to the mediboard.org documentation page 
 * @return string: the link to mediboard.org  */
function mbPortalURL($page = "Accueil", $tab = null) {
  $url = "http://www.mediboard.org/public/";
  
  $url .= ($page == "tracker") ? "tracker4" : "mod-$page";
  $url .= $tab ? "-tab-$tab" : "";
  return $url;
}

function stringNotEmpty($s){
  return $s !== "";
}

function mbLoadScriptsStorage(){
  $affichageScript = "";
  $affichageScript .= CJSLoader::loadFile("lib/dojo/dojo.js");
  $affichageScript .= CJSLoader::loadFile("lib/dojo/src/io/__package__.js");
  $affichageScript .= CJSLoader::loadFile("lib/dojo/src/html/__package__.js");
  $affichageScript .= CJSLoader::loadFile("lib/dojo/src/lfx/__package__.js");
  $affichageScript .= CJSLoader::loadFile("includes/javascript/storage.js");
  return $affichageScript;
}

/** Must be like "64M" */ 
function set_min_memory_limit($min) {
  $actual = CMbString::fromDecaBinary(ini_get('memory_limit'));
  $new    = CMbString::fromDecaBinary($min);
  if ($new > $actual) {
    ini_set('memory_limit', $min);
  }
}

/**
 * Check if a method is overridden in a given class
 * @param mixed $class The class or object
 * @param string $method The method name
 * @return bool
 */
function is_method_overridden($class, $method) {
  $rMethod = new ReflectionMethod($class, $method);
  return $rMethod->getDeclaringClass()->getName() == $class;
}

/**
 * Strip slashes recursively if value is an array
 * @param mixed $value
 * @return mixed the stripped value
 **/
function stripslashes_deep($value) {
  return is_array($value) ?
    array_map("stripslashes_deep", $value) :
    stripslashes($value);
}

/**
 * Copy the hash array content into the object as properties
 * only existing properties of object are filled, when defined in hash
 * @param array $hash the input array
 * @param object $object to fill of any class
 **/
function bindHashToObject($hash, &$object) {

  // @TODO use property_exists() which is a bit faster
  // BUT requires PHP >= 5.1   
  
  $vars = get_object_vars($object);
  foreach ($hash as $k => $v) {
    if (array_key_exists($k, $vars)) {
      $object->$k = $hash[$k];
    }
  } 
}

/**
 * Convert a date from ISO to locale format
 * @param string $date Date in ISO format
 * @return string Date in locale format
 */
function mbDateToLocale($date) {
  return preg_replace("/(\d{4})-(\d{2})-(\d{2})/", '$3/$2/$1', $date);
}

/**
 * Convert a date from locale to ISO format
 * @param string $date Date in locale format
 * @return string Date in ISO format
 */
function mbDateFromLocale($date) {
  return preg_replace("/(\d{2})\/(\d{2})\/(\d{2,4})/", '$3-$2-$1', $date);
}

/**
 * Convert a date from LDAP to ISO format
 * @param string $dateLargeInt nano seconds (yes, nano seconds) since jan 1st 1601
 * @return string DateTime in ISO format
 */
function mbDateTimeFromLDAP($dateLargeInt) {
  // seconds since jan 1st 1601
  $secsAfterADEpoch = $dateLargeInt / (10000000); 
  // unix epoch - AD epoch * number of tropical days * seconds in a day
  $ADToUnixConvertor = ((1970-1601) * 365.242190) * 86400; 
  // unix Timestamp version of AD timestamp
  $unixTsLastLogon = intval($secsAfterADEpoch-$ADToUnixConvertor); 
  
  return date("d-m-Y H:i:s", $unixTsLastLogon);
}

function mbDateTimeFromAD($dateAD) {
  return preg_replace("/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\.0Z/", '$1-$2-$3 $4:$5:$6', $dateAD);
}

/**
 * Check if a number is a valid Luhn number
 * see http://en.wikipedia.org/wiki/Luhn
 * @param code string String representing a potential Luhn number
 * @return bool
 */
function luhn ($code) {
  $code = preg_replace('/\D|\s/', '', $code);
  $code_length = strlen($code);
  $sum = 0;
  
  $parity = $code_length % 2;
  
  for ($i = $code_length - 1; $i >= 0; $i--) {
    $digit = $code{$i};
    
    if ($i % 2 == $parity) {
      $digit *= 2;
      
      if ($digit > 9) {
        $digit -= 9;
      }
    }
    
    $sum += $digit;
  }
  
  return (($sum % 10) == 0);
}

/**
 * Check wether a URL exists (200 HTTP Header)
 * @param string $url URL to check
 * @return bool
 */
function url_exists($url) {
	$old = ini_set('default_socket_timeout', 5); 

	$headers = @get_headers($url);
	ini_set('default_socket_timeout', $old); 
  return (preg_match("|200|", $headers[0])); 
}

/**
 * Check responsetime for a webbserver
 * @param string $url URL to check
 * @return int response time
 */
function url_response_time($url, $port){
  $parse_url = parse_url($url);
  if (isset($parse_url["port"])) {
    $port = $parse_url["port"];
  }
  
  $url = isset($parse_url["host"]) ? $parse_url["host"] : $url;

  $starttime     = microtime(true);
  $file          = @fsockopen($url, $port, $errno, $errstr, 5);
  $stoptime      = microtime(true);
  $response_time = 0;
  
  if (!$file) {
    $response_time = -1;  // Site is down
  }
  else{
    fclose($file);
    $response_time = ($stoptime - $starttime) * 1000;
    $response_time = floor($response_time);
  }

  return $response_time;
}

/**
 * Build a url string based on components in an array
 * @param array $components Components, as of parse_url (see PHP documentation)
 * @return string
 */
function make_url($components) {
  $url = $components["scheme"] . "://";

  if (isset($components["user"])) {
    $url .= $components["user"] . ":" . $components["pass"] . "@";
  }
  
  $url .=  $components["host"];
  
  if (isset($components["port"])) {
    $url .=  ":" . $components["port"];
  }
  
  $url .=  $components["path"];
  
  if (isset($components["query"])) {
    $url .=  "?" . $components["query"];
  }
  
  if (isset($components["fragment"])) {
    $url .=  "#" . $components["fragment"];
  }
  
  return $url;
}

/**
 * Check wether a IP address is in intranet-like form
 * @param string $ip IP address to check
 * @return bool
 */
function is_intranet_ip($ip) {
  // ipv6 en local
  if ($ip === '::1' || $ip === '0:0:0:0:0:0:0:1'){
    return true;
  }

  $ip = explode('.', $ip);
  return 
    ($ip[0] == 127) ||
    ($ip[0] == 10) ||
    ($ip[0] == 172 && $ip[1] >= 16 && $ip[1] < 32) ||
    ($ip[0] == 192 && $ip[1] == 168);
}

function get_server_var($var_name) {
  if (isset($_SERVER[$var_name]))
    return $_SERVER[$var_name];
  elseif (isset($_ENV[$var_name]))
    return $_ENV[$var_name];
  elseif (getenv($var_name))
    return getenv($var_name);
  elseif (function_exists('apache_getenv') && apache_getenv($var_name, true))
    return apache_getenv($var_name, true);
  return null;
}

function get_remote_address(){
  $address = array(
    "proxy" => null, 
    "client" => null, 
    "remote" => null,
  );
  
  $address["client"] = ($client = get_server_var("HTTP_CLIENT_IP")) ? $client : get_server_var("REMOTE_ADDR");
  $address["remote"] = $address["client"];
  
  $forwarded = array(
    "HTTP_X_FORWARDED_FOR",
    "HTTP_FORWARDED_FOR",
    "HTTP_X_FORWARDED",
    "HTTP_FORWARDED",
    "HTTP_FORWARDED_FOR_IP",
    "X_FORWARDED_FOR",
    "FORWARDED_FOR",
    "X_FORWARDED",
    "FORWARDED",
    "FORWARDED_FOR_IP",
  );
  
  $client = null;
  
  foreach($forwarded as $name) {
    if ($client = get_server_var($name))
      break;
  }
  
  if ($client) {
    $address["proxy"]  = $address["client"];
    $address["client"] = $client;
  }
  
  // To handle weird IPs sent by iPhones, in the form "10.10.10.10, 10.10.10.10"
  $proxy  = explode(",", $address["proxy"]);
  $client = explode(",", $address["client"]);
  $remote = explode(",", $address["remote"]);
  
  $address["proxy"]  = reset($proxy);
  $address["client"] = reset($client);
  $address["remote"] = reset($remote);
  
  return $address;
}

function mb_crc32($str) {
  $crc = crc32($str);

  // if 32bit platform
  if (PHP_INT_MAX <= pow(2, 31)-1 && $crc < 0) {
    $crc += pow(2, 32);
  }
  
  return $crc;
}
