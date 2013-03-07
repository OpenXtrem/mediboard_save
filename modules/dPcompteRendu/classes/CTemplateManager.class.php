<?php
/**
 * $Id$
 *
 * @package    Mediboard
 * @subpackage dPcompteRendu
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision$
 */

/**
 * Gestion avanc�e de documents (destinataires, listes de choix, etc.)
 */
class CTemplateManager {
  var $editor = "ckeditor";

  var $sections      = array();
  var $helpers       = array();
  var $lists         = array();
  var $graphs        = array();
  var $textes_libres = array();

  var $template      = null;
  var $document      = null;
  var $usedLists     = array();
  var $isCourrier    = null;

  var $valueMode     = true; // @todo : changer en applyMode
  var $isModele      = true;
  var $printMode     = false;
  var $simplifyMode  = false;
  var $parameters    = array();
  var $font          = null;
  var $size          = null;
  var $destinataires = array();

  private static $barcodeCache = array();

  /**
   * Constructeur
   *
   * @param array $parameters [optional]
   *
   * @return void
   */
  function CTemplateManager($parameters = array()) {
    $user = CMediusers::get();
    $this->parameters = $parameters;

    if (!isset($parameters["isBody"]) || (isset($parameters["isBody"]) && $parameters["isBody"] == 1)) {
      $this->addProperty("Courrier - nom destinataire"     , "[Courrier - nom destinataire]");
      $this->addProperty("Courrier - adresse destinataire" , "[Courrier - adresse destinataire]");
      $this->addProperty("Courrier - cp ville destinataire", "[Courrier - cp ville destinataire]");
      $this->addProperty("Courrier - copie � - simple"     , "[Courrier - copie � - simple]");
      $this->addProperty("Courrier - copie � - simple (multiligne)", "[Courrier - copie � - simple (multiligne)]");
      $this->addProperty("Courrier - copie � - complet", "[Courrier - copie � - complet]");
      $this->addProperty("Courrier - copie � - complet (multiligne)", "[Courrier - copie � - complet (multiligne)]");
    }

    $now = CMbDT::dateTime();
    $this->addDateProperty("G�n�ral - date du jour", $now);
    $this->addLongDateProperty("G�n�ral - date du jour (longue)", $now);
    $this->addTimeProperty("G�n�ral - heure courante", $now);

    // Connected user
    $user_complete = $user->_view;
    if ($user->isPraticien()) {
      if ($user->titres) {
        $user_complete .= "\n" . $user->titres;
      }
      if ($user->spec_cpam_id) {
        $spec_cpam = $user->loadRefSpecCPAM();
        $user_complete .= "\n" . $spec_cpam->text;
      }
      if ($user->adeli) {
        $user_complete .= "\nAdeli : " . $user->adeli;
      }
      if ($user->rpps) {
        $user_complete .= "\nRPPS : " . $user->rpps;
      }
      if ($user->_user_email) {
        $user_complete .= "\nE-mail : " . $user->_user_email;
      }
    }

    // Initials
    $elements_first_name = preg_split("/[ -]/", $user->_user_first_name);
    $initials_first_name = "";

    foreach ($elements_first_name as $_element) {
      $initials_first_name .= strtoupper(substr($_element, 0, 1));
    }

    $elements_last_name = preg_split("/[ -]/", $user->_user_last_name);
    $initials_last_name = "";

    foreach ($elements_last_name as $_element) {
      $initials_last_name .= strtoupper(substr($_element, 0, 1));
    }

    $this->addProperty("G�n�ral - r�dacteur"        , $user->_shortview);
    $this->addProperty("G�n�ral - r�dacteur - pr�nom", $user->_user_first_name);
    $this->addProperty("G�n�ral - r�dacteur - nom"  , $user->_user_last_name);
    $this->addProperty("G�n�ral - r�dacteur complet", $user_complete);
    $this->addProperty("G�n�ral - r�dacteur (initiales) - pr�nom", $initials_first_name);
    $this->addProperty("G�n�ral - r�dacteur (initiales) - nom", $initials_last_name);
    if (CAppUI::conf("dPcompteRendu CCompteRendu pdf_thumbnails") && CAppUI::pref("pdf_and_thumbs")) {
      $this->addProperty("G�n�ral - num�ro de page", "[G�n�ral - num�ro de page]");
    }
  }

  /**
   * Retrouve un param�tre dans un tableau
   *
   * @param string $name    nom du param�tre
   * @param object $default [optional] valeur par d�faut, si non retrouv�
   *
   * @return string
   */
  function getParameter($name, $default = null) {
    return CValue::read($this->parameters, $name, $default);
  }

  /**
   * Construit l'�l�ment html pour les champs, listes de choix et textes libres.
   *
   * @param string $spanClass classe de l'�l�ment
   * @param string $text      contenu de l'�l�ment
   *
   * @return string
   */
  function makeSpan($spanClass, $text) {
    // Escape entities cuz CKEditor does so
    $text = CMbString::htmlEntities($text);

    // Keep backslashed double quotes instead of quotes
    // cuz CKEditor creates double quoted attributes
    return "<span class=\"{$spanClass}\">{$text}</span>";
  }

  /**
   * Ajoute un champ
   *
   * @param string  $field      nom du champ
   * @param string  $value      [optional]
   * @param array   $options    [optional]
   * @param boolean $htmlescape [optional]
   *
   * @return void
   */
  function addProperty($field, $value = null, $options = array(), $htmlescape = true) {
    if ($htmlescape) {
      $value = CMbString::htmlSpecialChars($value);
    }

    $sec = explode(' - ', $field, 3);
    switch (count($sec)) {
      case 3:
        $section  = $sec[0];
        $item     = $sec[1];
        $sub_item = $sec[2];
        break;
      case 2:
        $section  = $sec[0];
        $item     = $sec[1];
        $sub_item = '';
        break;
      default:
        trigger_error("Error while exploding the string", E_USER_ERROR);
        return;
    }

    if (!array_key_exists($section, $this->sections)) {
      $this->sections[$section] = array();
    }
    if ($sub_item != '' && !array_key_exists($item, $this->sections[$section])) {
      $this->sections[$section][$item] = array();
    }

    if ($sub_item == '') {
      $this->sections[$section][$field] = array (
        "view"      => CMbString::htmlEntities($item),
        "field"     => $field,
        "value"     => $value,
        "fieldHTML" => CMbString::htmlEntities("[{$field}]"),
        "valueHTML" => $value,
        "shortview" => $section . " - " . $item,
        "options"   => $options
      );
    }
    else {
      $this->sections[$section][$item][$sub_item] = array (
        "view"      => CMbString::htmlEntities($sub_item),
        "field"     => $field,
        "value"     => $value,
        "fieldHTML" => CMbString::htmlEntities("[{$field}]"),
        "valueHTML" => $value,
        "shortview" => $section . " - " . $item . " - " . $sub_item,
        "options"   => $options
      );
    }

    if (isset($options["barcode"])) {
      $_field = &$this->sections[$section][$field];

      if ($this->valueMode) {
        $src = $this->getBarcodeDataUri($_field['value'], $options["barcode"]);
      }
      else {
        $src = $_field['fieldHTML'];
      }

      $_field["field"] = "";

      if ($options["barcode"]["title"]) {
        $_field["field"] .= $options["barcode"]["title"]."<br />";
      }

      $_field["field"] .= "<img alt=\"$field\" src=\"$src\" ";

      foreach ($options["barcode"] as $name => $attribute) {
        $_field["field"] .= " $name=\"$attribute\"";
      }

      $_field["field"] .= "/>";
    }

    if (isset($options["image"])) {

      $_field = &$this->sections[$section][$field];
      $file = new CFile();
      $file->load($_field['value']);
      $src = $this->valueMode ? $file->getDataURI() :$_field['fieldHTML'];
      $_field["field"] = "<img src=\"$src\" />";
    }
  }

  /**
   * Ajoute un champ de type date
   *
   * @param string $field nom du champ
   * @param string $value [optional]
   *
   * @return void
   */
  function addDateProperty($field, $value = null) {
    $value = $value ? CMbDT::transform(null, $value, CAppUI::conf("date")) : "";
    $this->addProperty($field, $value);
  }

  /**
   * Ajoute un champ de type date longue
   *
   * @param string $field Nom du champ
   * @param string $value Valeur du champ
   *
   * @return void
   */
  function addLongDateProperty($field, $value) {
    $value = $value ? ucfirst(CMbDT::transform(null, $value, CAppUI::conf("longdate"))) : "";
    $this->addProperty($field, $value);
  }

  /**
   * Ajoute un champ de type heure
   *
   * @param string $field Nom du champ
   * @param string $value Valeur du champ
   *
   * @return void
   */
  function addTimeProperty($field, $value = null) {
    $value = $value ? CMbDT::transform(null, $value, CAppUI::conf("time")) : "";
    $this->addProperty($field, $value);
  }

  /**
   * Ajoute un champ de type date et heure
   *
   * @param string $field Nom du champ
   * @param string $value Valeur du champ
   *
   * @return void
   */
  function addDateTimeProperty($field, $value = null) {
    $value = $value ? CMbDT::transform(null, $value, CAppUI::conf("datetime")) : "";
    $this->addProperty($field, $value);
  }

  /**
   * Ajoute un champ de type liste
   *
   * @param string $field Nom du champ
   * @param array  $items Liste de valeurs
   *
   * @return void
   */
  function addListProperty($field, $items = null) {
    $this->addProperty($field, $this->makeList($items), null, false);
  }

  /**
   * Ajoute un champ de type image
   *
   * @param string $field   Nom du champ
   * @param int    $file_id Identifiant du fichier
   *
   * @return void
   */
  function addImageProperty($field, $file_id) {
    $this->addProperty($field, $file_id, array("image" => 1), false);
  }

  /**
   * G�n�ration de la source html pour la liste d'items
   *
   * @param array $items liste d'items
   *
   * @return string|null
   */
  function makeList($items) {
    if (!$items) {
      return;
    }

    // Make a list out of a string
    if (!is_array($items)) {
      $items = array($items);
    }

    // Escape content
    $items = array_map(array("CMbString", "htmlEntities"), $items);

    // HTML production
    switch ($default = CAppUI::pref("listDefault")) {
      case "ulli":
        $html = "<ul>";
        foreach ($items as $item) {
          $html .= "<li>$item</li>";
        }
        $html.= "</ul>";
        break;

      case "br":
        $html = "";
        $prefix = CAppUI::pref("listBrPrefix");
        foreach ($items as $item) {
          $html .= "<br />$prefix $item";
        }
        break;

      case "inline":
        // Hack: oblig� de d�coder car dans ce mode le template manager
        // le fera une seconde fois s'il ne d�tecte pas d'entit�s HTML
        $items = array_map("html_entity_decode", $items);
        $separator = CAppUI::pref("listInlineSeparator");
        $html = implode(" $separator ", $items);
        break;

      default:
        $html = "";
        trigger_error("Default style for list is unknown '$default'", E_USER_WARNING);
        break;
    }

    return $html;
  }

  /**
   * Ajoute un champ de type graphique
   *
   * @param string $field   Champ
   * @param array  $data    Tableau de donn�es
   * @param array  $options Options
   *
   * @return void
   */
  function addGraph($field, $data, $options = array()) {
    $this->graphs[utf8_encode($field)] = array(
      "data" => $data,
      "options" => $options,
      "name" => utf8_encode($field)
    );

    $this->addProperty($field, $field, null, false);
  }

  /**
   * Ajoute un champ de type code-barre
   *
   * @param string $field   Nom du champ
   * @param object $data    Code barre
   * @param array  $options Options
   *
   * @return void
   */
  function addBarcode($field, $data, $options = array()) {
    $options = array_replace_recursive(array(
      "barcode" => array(
        "width"  => 220,
        "height" => 60,
        "class"  => "barcode",
        "title"  => "",
      )
    ), $options);

    $this->addProperty($field, $data, $options, false);
  }

  function addList($name, $choice = null) {
    $this->lists[$name] = array (
      "name" => $name,
      // @todo : passer en regexp
      //"nameHTML" => $this->makeSpan("name", "[Liste - {$name}]"));
      "nameHTML" => CMbString::htmlEntities("[Liste - {$name}]")
    );
  }

  function addHelper($name, $text) {
    $this->helpers[$name] = $text;
  }

  function applyTemplate($template) {
    assert($template instanceof CCompteRendu || $template instanceof CPack);

    if ($template instanceof CCompteRendu) {
      $this->font = $template->font ? CCompteRendu::$fonts[$template->font] : "";
      $this->size = $template->size;

      if (!$this->valueMode) {
        $this->setFields($template->object_class);
      }

      $this->renderDocument($template->_source);
    }
    else {
      /** FIXME: ?? */
      if (!$this->valueMode) {
        $this->setFields("hospitalisation");
      }

      $this->renderDocument($template->_source);
    }
  }

  function initHTMLArea () {
    // Don't use CValue::setSession which uses $m
    $_SESSION["dPcompteRendu"]["templateManager"] = gzcompress(serialize($this));

    $smarty = new CSmartyDP("modules/dPcompteRendu");
    $smarty->assign("templateManager", $this);
    $smarty->display("init_htmlarea.tpl");
  }

  function setFields($modeleType) {
    if ($modeleType) {
      $object = new $modeleType;
      $object->fillTemplate($this);
    }
  }

  function loadLists($user_id, $compte_rendu_id = 0) {
    // Liste de choix
    $compte_rendu = new CCompteRendu();
    $compte_rendu->load($compte_rendu_id);

    $where = array();
    $user = CMediusers::get($user_id);
    $user->loadRefFunction();
    if ($user_id) {
      $where[] = "(
        user_id = '$user->user_id' OR
        function_id = '$user->function_id' OR
        group_id = '{$user->_ref_function->group_id}'
      )";
    }
    else {
      $where[] = "(
        function_id IN('$user->function_id', '$compte_rendu->function_id') OR
        group_id IN('{$user->_ref_function->group_id}', '$compte_rendu->group_id')
      )";
    }

    $where[] = $compte_rendu->_spec->ds->prepare("`compte_rendu_id` IS NULL OR compte_rendu_id = %", $compte_rendu_id);
    $order = "nom ASC";
    $lists = new CListeChoix();
    $lists = $lists->loadList($where, $order);
    foreach ($lists as $list) {
      $this->addList($list->nom);
    }
  }

  function loadHelpers($user_id, $modeleType, $other_function_id = "") {
    $compte_rendu = new CCompteRendu();
    $ds = $compte_rendu->_spec->ds;

    // Chargement de l'utilisateur courant
    $currUser = new CMediusers();
    $currUser->load($user_id);

    $order = "name";

    // Where user_id
    $whereUser = array();
    $whereUser["user_id"] = $ds->prepare("= %", $user_id);
    $whereUser["class"]   = $ds->prepare("= %", $compte_rendu->_class);

    // Where function_id
    $whereFunc = array();
    $whereFunc["function_id"] = $other_function_id ?
      "IN ($currUser->function_id, $other_function_id)" : $ds->prepare("= %", $currUser->function_id);
    $whereFunc["class"]       = $ds->prepare("= %", $compte_rendu->_class);

    // Where group_id
    $whereGroup = array();
    $group = CGroups::loadCurrent();
    $whereGroup["group_id"] = $ds->prepare("= %", $group->_id);
    $whereGroup["class"]       = $ds->prepare("= %", $compte_rendu->_class);

    // Chargement des aides
    $aide = new CAideSaisie();
    $aidesUser   = $aide->loadList($whereUser, $order);
    $aidesFunc   = $aide->loadList($whereFunc, $order);
    $aidesGroup  = $aide->loadList($whereGroup, $order);

    $this->helpers["Aide de l'utilisateur"] = array();
    foreach ($aidesUser as $aideUser) {
      if ($aideUser->depend_value_1 == $modeleType || $aideUser->depend_value_1 == "") {
        $this->helpers["Aide de l'utilisateur"][CMbString::htmlEntities($aideUser->name)] = CMbString::htmlEntities($aideUser->text);
      }
    }
    $this->helpers["Aide de la fonction"] = array();
    foreach ($aidesFunc as $aideFunc) {
      if ($aideFunc->depend_value_1 == $modeleType || $aideFunc->depend_value_1 == "") {
        $this->helpers["Aide de la fonction"][CMbString::htmlEntities($aideFunc->name)] = CMbString::htmlEntities($aideFunc->text);
      }
    }
    $this->helpers["Aide de l'&eacute;tablissement"] = array();
    foreach ($aidesGroup as $aideGroup) {
      if ($aideGroup->depend_value_1 == $modeleType || $aideGroup->depend_value_1 == "") {
        $this->helpers["Aide de l'&eacute;tablissement"][CMbString::htmlEntities($aideGroup->name)] = CMbString::htmlEntities($aideGroup->text);
      }
    }
  }

  function getBarcodeDataUri($code, $options) {
    if (!$code) {
      return;
    }

    $size = "{$options['width']}x{$options['width']}";

    if (isset(self::$barcodeCache[$code][$size])) {
      return self::$barcodeCache[$code][$size];
    }

    CAppUI::requireLibraryFile("tcpdf/barcode/barcode");
    CAppUI::requireLibraryFile("tcpdf/barcode/c128bobject");
    CAppUI::requireLibraryFile("tcpdf/barcode/cmb128bobject");

    $bc_options = (BCD_DEFAULT_STYLE | BCS_DRAW_TEXT) & ~BCS_BORDER;
    $barcode = new CMb128BObject($options["width"] * 2, $options["height"] * 2, $bc_options, $code);

    $barcode->SetFont(7);
    $barcode->DrawObject(2);

    ob_start();
    $barcode->FlushObject();
    $image = ob_get_contents();
    ob_end_clean();

    $barcode->DestroyObject();

    $image = "data:image/png;base64,".urlencode(base64_encode($image));

    return self::$barcodeCache[$code][$size] = $image;
  }

  function renderDocument($_source) {
    $fields = array();
    $values = array();
    foreach ($this->sections as $properties) {
      foreach ($properties as $key=>$property) {
        if (strpos($key, ' - ') === false) {
          foreach ($property as $_property) {
            $fields[] = $_property["fieldHTML"];
            $values[] = nl2br($_property["valueHTML"]);
          }
        }
        else if ($property["valueHTML"] && isset($property["options"]["barcode"])) {
          $options = $property["options"]["barcode"];

          $image = $this->getBarcodeDataUri($property["valueHTML"], $options);

          $fields[] = "src=\"{$property['fieldHTML']}\"";
          $values[] = "src=\"$image\"";
        }
        else if ($property["valueHTML"] && isset($property["options"]["image"])) {
          $file = new CFile();
          $file->load($property['value']);
          $src = $file->getDataURI();
          $fields[] = "src=\"{$property['fieldHTML']}\"";
          $values[] = "src=\"$src\"";
        }
        else {
          $property["fieldHTML"] = preg_replace("/'/", '&#39;', $property["fieldHTML"]);
          $fields[] = $property["fieldHTML"];
          $values[] =  nl2br($property["valueHTML"]);
        }
      }
    }

    if (count($fields)) {
      $this->document = str_ireplace($fields, $values, $_source);
    }
  }

  // Obtention des listes utilis�es dans le document
  function getUsedLists($lists) {
    $this->usedLists = array();
    foreach ($lists as $value) {

      // Remplacer 039 par 39 car ckeditor remplace ' par &#39;
      $nom = str_replace("#039;", "#39;", CMbString::htmlEntities(stripslashes("[Liste - $value->nom]"), ENT_QUOTES));
      $pos = strpos($this->document, $nom);
      if ($pos !== false) {
        $this->usedLists[$pos] = $value;
      }
    }
    ksort($this->usedLists);
    return $this->usedLists;
  }

  // V�rification s'il s'agit d'un courrier
  function isCourrier() {
    $pos = strpos($this->document, "[Courrier -");
    if ($pos) {
      $this->isCourrier = true;
    }
    return $this->isCourrier;
  }
}
