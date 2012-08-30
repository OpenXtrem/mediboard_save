<?php /** $Id$ **/

/**
 *  @package Mediboard
 *  @subpackage dicom
 *  @version $Revision$
 *  @author SARL OpenXtrem
 */

/**
 * Represents a Dicom PDU Item
 */
class CDicomPDUItem {
  
  /**
   * The type of the Item
   * 
   * @var hexadecimal umber
   */
  var $type = null;
  
  /**
   * The length of the Item
   * 
   * @var integer
   */
  var $length = null;
  
  /**
   * Decode the item
   * 
   * @param CDicomStreamReader $stream_reader The stream reader
   * 
   * @return null
   */
  function decodeItem(CDicomStreamReader $stream_reader) {
    
  }
  
  /**
   * Encode the item
   * 
   * @param CDicomStreamWriter $stream_writer The stream writer
   * 
   * @return null
   */
  function encodeItem(CDicomStreamWriter $stream_writer) {
    
  }
}
?>