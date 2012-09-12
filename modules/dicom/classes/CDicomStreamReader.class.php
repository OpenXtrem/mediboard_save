<?php /** $Id$ **/

/**
 *  @package Mediboard
 *  @subpackage dicom
 *  @version $Revision$
 *  @author SARL OpenXtrem
 */

/**
 * A stream reader who can read several types from a binary stream, in Big Endian or Little Endian syntax
 */
class CDicomStreamReader {
  
  /**
   * The stream (usually a stream to the socket connexion)
   * 
   * @var resource
   */
  var $stream = null;
  
  /**
   * The content of the stream, used to keep a trace of the DICOM exchanges
   * 
   * @var binary data
   */
  var $buf = null;
  
  /**
   * The constructor of CDicomStreamReader
   * 
   * @param resource $stream The stream
   */
  function __construct($stream) {
    $this->stream = $stream;
    $this->buf = "";
  }
  
  /**
   * Move forward the stream pointer
   * 
   * @param int $bytes The number of bytes you want to skip. This number can't be negative
   * 
   * @return null
   */
  function skip($bytes) {
    if ($bytes > 0) {
      $this->read($bytes);
    }
  }
  
  /**
   * Return the current position of the stream pointer.
   * 
   * @return int The current position of the stream pointer
   */
  function getPos() {
    return ftell($this->stream);
  }
  
  /**
   * Move the stream pointer
   * 
   * @param int $pos the position
   * 
   * @return null
   */
  function seek($pos) {
    fseek($this->stream, $pos, SEEK_CUR);
  }
  
  /**
   * Rewind the position of the stream pointer
   * 
   * @return null
   */
  function rewind() {
    rewind($this->stream);
  }
  
  /**
   * Read data from the stream, and check if the length of the PDU is passed
   * 
   * @param integer $length The number of byte to read
   * 
   * @return string
   */
  function read($length = 1) {
    $tmp = fread($this->stream, $length);
    $this->buf .= $tmp;
    return $tmp;
  }
  
  /**
   * Close the stream
   * 
   * @return null
   */
  function close() {
    fclose($this->stream);
  }
  
  /**
   * Read hexadecimal numbers from the stream
   * 
   * @param int    $length     The length of the number, equal to 1 if not given
   * 
   * @param string $endianness Equal to BE if you need Big Endian, LE if Little Endian. Equal to BE if not given
   * 
   * @return hexadecimal number
   */
  function readHexByte($length = 1, $endianness = "BE") {
    if ($endianness == "BE") {
      return $this->readHexByteBE($length);
    }
    elseif ($endianness == "LE") {
      return $this->readHexByteLE($length);
    }
  }
  
  /**
   * Read hexadecimal numbers from the stream. Use Big Endian syntax
   * 
   * @param int $length The length of the number, equal to 1 if not given
   * 
   * @return hexadecimal number
   */
  function readHexByteBE($length = 1) {
    $tmp = unpack("H*", $this->read($length));
    return $tmp[1];
  }
  
  /**
   * Read hexadecimal numbers from the stream. Use Little Endian syntax
   * 
   * @param int $length The length of the number, equal to 1 if not given
   * 
   * @return hexadecimal number
   */
  function readHexByteLE($length = 1) {
    $tmp = unpack("h*", $this->read($length));
    return $tmp[1];
  }
  
  /**
   * Read unsigned 32 bits numbers.
   * 
   * @param string $endianness Equal to BE if you need Big Endian, LE if Little Endian. Equal to BE if not given
   * 
   * @return integer
   */
  function readUnsignedInt32($endianness = "BE") {
    if ($endianness == "BE") {
      return $this->readUnsignedInt32BE();
    }
    elseif ($endianness == "LE") {
      return $this->readUnsignedInt32LE();
    }
  }
  
  /**
   * Read unsigned 32 bits numbers, in Big Endian syntax.
   * 
   * @return integer
   */
  function readUnsignedInt32BE() {
    $tmp = unpack("N", $this->read(4));
    return $tmp[1];
  }
  
  /**
   * Read unsigned 32 bits numbers, in Little Endian syntax.
   * 
   * @return integer
   */
  function readUnsignedInt32LE() {
    $tmp = unpack("V", $this->read(4));
    return $tmp[1];
  }
  
  /**
   * Read unsigned 16 bits numbers.
   * 
   * @param string $endianness Equal to BE if you need Big Endian, LE if Little Endian. Equal to BE if not given
   * 
   * @return integer
   */
  function readUnsignedInt16($endianness = "BE") {
    if ($endianness == "BE") {
      return $this->readUnsignedInt16BE();
    }
    elseif ($endianness == "LE") {
      return $this->readUnsignedInt16LE();
    }
  }
  
  /**
   * Read unsigned 16 bits numbers, in Big Endian syntax.
   * 
   * @return integer
   */
  function readUnsignedInt16BE() {
    $tmp = unpack("n", $this->read(2));
    return $tmp[1];
  }
  
  /**
   * Read unsigned 16 bits numbers, in Big Endian syntax.
   * 
   * @return integer
   */
  function readUnsignedInt16LE() {
    $tmp = unpack("v", $this->read(2));
    return $tmp[1];
  }
  
  /**
   * Read unsigned 8 bits numbers.
   * 
   * @return integer
   */
  function readUnsignedInt8() {
    $tmp = unpack("C", $this->read(1));
    return $tmp[1];
  }
  
  /**
   * Read a string
   * 
   * @param int $length The length of the string
   * 
   * @return string
   */
  function readString($length) {
    $tmp = unpack("A*", $this->read($length));
    return $tmp[1];
  }
  
  /**
   * Read a Dicom UID (series of integer, separated by ".")
   * 
   * @param int $length The length of the UID, equal to 64 if not given
   * 
   * @return string
   */
  function readUID($length = 64) {
    $tmp = unpack("A*", $this->read($length));
    return $tmp[1];
  }
} 
?>