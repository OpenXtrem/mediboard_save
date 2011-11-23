<?php /* $Id:$ */

/**
 * @package Mediboard
 * @subpackage system
 * @version $Revision: 6069 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 */

class CSourceMLLP extends CExchangeSource {
  const TRAILING = "\x0B";
  const LEADING  = "\x1C\x0D";
  
  var $source_mllp_id     = null;
  var $port               = null;
  
  private $_socket_client = null;
  
  function getSpec() {
    $spec = parent::getSpec();
    $spec->table = 'source_mllp';
    $spec->key   = 'source_mllp_id';
    return $spec;
  }

  function getProps() {
    $specs = parent::getProps();
    $specs["port"] = "num default|7001";
    return $specs;
  }
  
  function updateFormFields() {
    parent::updateFormFields();
    $this->_view = $this->port;
  }
  
  /**
   * @return SocketClient
   */
  function getSocketClient(){
    if ($this->_socket_client) return $this->_socket_client;
		
    CAppUI::requireLibraryFile("phpsocket/SocketClient");
    
    $this->_socket_client = new SocketClient;
    $this->_socket_client->open($this->host, $this->port);
    
    return $this->_socket_client;
  }
  
  function getData($path = null) {
    return $this->_socket_client->recv();
  }
  
  function send($evenement_name = null){
    $this->getSocketClient()->send(self::LEADING.$this->_data.self::TRAILING);
  }
  
  function isReachableSource() {
    try {
      $this->getSocketClient();
    } 
    catch (CMbException $e) {
      $this->_reachable = 0;
      $this->_message   = $e->getMessage();
      return false;
    }
        
    return true;
  }
  
  function isAuthentificate() {
    return $this->isReachableSource();
  }
  
  function getResponseTime() {
    $this->_response_time = url_response_time($this->host, $this->port);
  }
}
