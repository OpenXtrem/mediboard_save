<?php

/**
 * CPlanningEvent class
 * allow adding events to a CWeekPlanning
 *
 * @category Ssr
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  SVN: $Id:\$
 * @link     http://www.mediboard.org
 */

/**
 * Class CPlanningEvent
 */
class CPlanningEvent  {
  public $guid;
  public $internal_id;
  
  public $title;
  public $icon;
  public $icon_desc;
  
  public $type;
  public $plage     = array();
  public $menu      = array();
  public $mb_object = array();
  
  public $start;
  public $end;
  public $length;
  public $day;
  public $below       = false;
  public $draggable   = false;
  public $resizable   = false;
  public $disabled    = false;

  public $hour;
  public $minutes;
  public $hour_divider;
  public $width;
  public $display_hours = false;  //show start time and end time in the event display (hover)

  public $offset;               //minutes
  public $offset_top;           //minutes
  public $offset_top_text;      //string
  public $offset_bottom;        //minutes
  public $offset_bottom_text;   //string
  public $color;                //aaa
  public $height;
  public $useHeight;
  public $important;
  public $css_class;

  public $_ref_object;

  /**
   * constructor
   *
   * @param string      $guid           guid
   * @param string      $date           [day h:m:s]
   * @param int         $length         length of the event (minutes)
   * @param string      $title          title displayed of the event
   * @param null        $color          background color of the event
   * @param bool        $important      is the event important
   * @param null|string $css_class      css class
   * @param null        $draggable_guid is the guid dragable
   * @param bool        $html_escape    do I escape the html from title
   */
  function __construct ($guid, $date, $length = 0, $title = "", $color = null, $important = true, $css_class = null, $draggable_guid = null, $html_escape = true) {
    if (!$color) {
      $color = "#999";
    }
    
    $this->guid = $guid;
    $this->draggable_guid = $draggable_guid;
    
    $this->internal_id = "CPlanningEvent-".uniqid();
    
    $this->start = $date;
    $this->length = $length;
    $this->title = $html_escape ? CMbString::htmlEntities($title) : $title;
    $this->color = $color;
    $this->important = $important;
    $this->css_class = is_array($css_class) ? implode(" ", $css_class) : $css_class;

    $this->mb_object = array("id" => "", "guid" => "", "view" => "");
    
    if (preg_match("/[0-9]+ /", $this->start)) {
      $parts = explode(" ", $this->start);
      $this->end = "{$parts[0]} ".CMbDT::time("+{$this->length} MINUTES", $parts[1]);
      $this->day = $parts[0];
      $this->hour = CMbDT::format($parts[1], "%H");
      $this->minutes = CMbDT::format($parts[1], "%M");
    }
    else {
      $this->day = CMbDT::date($date);
      $this->end = CMbDT::dateTime("+{$this->length} MINUTES", $date);
      $this->hour = CMbDT::format($date, "%H");
      $this->minutes = CMbDT::format($date, "%M");
    }
  }

  /**
   * assign an object to the event
   *
   * @param CMbObject $mbObject mediboard object
   *
   * @return void
   */
  function setObject($mbObject) {
    $this->mb_object["id"] = $mbObject->_id;
    $this->mb_object["class"] = $mbObject->_class;
    $this->mb_object["guid"] = $mbObject->_guid;
    $this->mb_object["view"] = utf8_encode($mbObject->_view);
  }

  /**
   * check if an event collid with another
   *
   * @param CPlanningEvent $event the event to check
   *
   * @return bool
   */
  function collides(self $event) {
    if ($event == $this || $this->length == 0 || $event->length == 0) {
      return false;
    }

    return ($event->start < $this->end && $event->end > $this->start);
  }

  /**
   * Add a menu to this
   *
   * @param string $type  class of the menu (css class)
   * @param string $title title of the menu (displayed on hover event)
   *
   * @return null
   */
  function addMenuItem($type, $title){
    $this->menu[] = array(
      "class" => $type, 
      "title" => $title,
    );
  }
}
