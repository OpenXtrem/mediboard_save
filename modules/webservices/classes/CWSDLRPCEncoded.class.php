<?php

/**
 * Format RPC Encoded
 *  
 * @category Webservices
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version  SVN: $Id:$ 
 * @link     http://www.mediboard.org
 */

/**
 * Class CWSDLRPCEncoded
 * Format RPC Encoded
 */
class CWSDLRPCEncoded extends CWSDLRPC {
  function addMessage() {
    $definitions = $this->documentElement;
    $this->addComment($definitions, "Partie 3 : Messages");
    
    foreach($this->_soap_handler->getParamSpecs() as $_method => $_paramSpec) {
      $message = $this->addElement($definitions, "message", null, "http://schemas.xmlsoap.org/wsdl/");
      $this->addAttribute($message, "name", $_method."Request");
      
      foreach ($_paramSpec['parameters'] as $_oneParam => $_paramType) {
        $part = $this->addElement($message, "part", null, "http://schemas.xmlsoap.org/wsdl/");
        $this->addAttribute($part, "name", $_oneParam);
        $this->addAttribute($part, "type", "xsd:".$_paramType);
      }
      
      $message = $this->addElement($definitions, "message", null, "http://schemas.xmlsoap.org/wsdl/");
      $this->addAttribute($message, "name", $_method."Response");
      
      foreach ($_paramSpec['return'] as $_oneParam => $_paramType) {
        $part = $this->addElement($message, "part", null, "http://schemas.xmlsoap.org/wsdl/");
        $this->addAttribute($part, "name", $_oneParam);
        $this->addAttribute($part, "type", "xsd:".$_paramType);
      }
    }
  }
  
  function addPortType() {
    $definitions = $this->documentElement;
    $partie4 = $this->createComment("partie 4 : Port Type");
    $definitions->appendChild($partie4);
    
    $portType = $this->addElement($definitions, "portType", null, "http://schemas.xmlsoap.org/wsdl/");
    $this->addAttribute($portType, "name", "MediboardPort");
    
    foreach($this->_soap_handler->getParamSpecs() as $_method => $_paramSpec) {
      $partie5 = $this->createComment("partie 5 : Operation");
      $portType->appendChild($partie5);
      $operation = $this->addElement($portType, "operation", null, "http://schemas.xmlsoap.org/wsdl/");
      $this->addAttribute($operation, "name", $_method);
      
      $input = $this->addElement($operation, "input", null, "http://schemas.xmlsoap.org/wsdl/");
      $this->addAttribute($input, "message", "typens:".$_method."Request");
      
      $output = $this->addElement($operation, "output", null, "http://schemas.xmlsoap.org/wsdl/");
      $this->addAttribute($output, "message", "typens:".$_method."Response");
    }
  }
  
  function addBinding() {
    $definitions = $this->documentElement;
    $partie6 = $this->createComment("partie 6 : Binding");
    $definitions->appendChild($partie6);
    
    $binding = $this->addElement($definitions, "binding", null, "http://schemas.xmlsoap.org/wsdl/");
    $this->addAttribute($binding, "name", "MediboardBinding");
    $this->addAttribute($binding, "type", "typens:MediboardPort");
    
    $soap = $this->addElement($binding, "soap:binding", null, "http://schemas.xmlsoap.org/wsdl/soap/");
    $this->addAttribute($soap, "style", "rpc");
    $this->addAttribute($soap, "transport", "http://schemas.xmlsoap.org/soap/http");

    foreach($this->_soap_handler->getParamSpecs() as $_method => $_paramSpec) {
      $operation = $this->addElement($binding, "operation", null, "http://schemas.xmlsoap.org/wsdl/");
      
      $this->addAttribute($operation, "name", $_method);
      
      $soapoperation = $this->addElement($operation, "soap:operation", null, "http://schemas.xmlsoap.org/wsdl/soap/");
      $this->addAttribute($soapoperation, "soapAction", "MediboardAction");
      
      $input = $this->addElement($operation, "input", null, "http://schemas.xmlsoap.org/wsdl/");
      $this->addAttribute($input, "name", $_method."Request");
      
      $soapbody = $this->addElement($input, "soap:body", null, "http://schemas.xmlsoap.org/wsdl/soap/");
      $this->addAttribute($soapbody, "use", "encoded");
      $this->addAttribute($soapbody, "namespace", "urn:MediboardWSDL");
      $this->addAttribute($soapbody, "encodingStyle", "http://schemas.xmlsoap.org/soap/encoding/");
      
      $output = $this->addElement($operation, "output", null, "http://schemas.xmlsoap.org/wsdl/");
      $this->addAttribute($output, "name", $_method."Response");
      
      $soapbody = $this->addElement($output, "soap:body", null, "http://schemas.xmlsoap.org/wsdl/soap/");
      $this->addAttribute($soapbody, "use", "encoded");
      $this->addAttribute($soapbody, "namespace", "urn:MediboardWSDL");
      $this->addAttribute($soapbody, "encodingStyle", "http://schemas.xmlsoap.org/soap/encoding/");
    }
  }
}