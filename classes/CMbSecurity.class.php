<?php

/**
 * $Id$
 *  
 * @package Mediboard
 * @author  SARL OpenXtrem <dev@openxtrem.com>
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @link    http://www.mediboard.org */

CAppUI::requireLibraryFile("phpseclib/phpseclib/Crypt/Random");
CAppUI::requireLibraryFile("phpseclib/phpseclib/Crypt/AES");
CAppUI::requireLibraryFile("phpseclib/phpseclib/Crypt/TripleDES");

/**
 * Generic security class, uses pure-PHP library phpseclib
 */
class CMbSecurity {
  // Ciphers
  const AES  = 1;
  const DES  = 2;
  const TDES = 3;

  // Encryption modes
  const CTR = CRYPT_AES_MODE_CTR;
  const ECB = CRYPT_AES_MODE_ECB;
  const CBC = CRYPT_AES_MODE_CBC;
  const CFB = CRYPT_AES_MODE_CFB;
  const OFB = CRYPT_AES_MODE_OFB;

  /**
   * Generate a pseudo random string
   *
   * @param int $length String length
   *
   * @return string
   */
  static function getRandomString($length) {
    return bin2hex(crypt_random_string($length));
  }

  /**
   * Generate a pseudo random binary string
   *
   * @param int $length Binary string length
   *
   * @return string
   */
  static function getRandomBinaryString($length) {
    return crypt_random_string($length);
  }

  /**
   * Generate a UUID
   * Based on: http://www.php.net/manual/fr/function.uniqid.php#87992
   *
   * @return string
   */
  static function generateUUID() {
    $pr_bits = null;
    $pr_bits = self::getRandomBinaryString(25);

    $time_low = bin2hex(substr($pr_bits, 0, 4));
    $time_mid = bin2hex(substr($pr_bits, 4, 2));

    $time_hi_and_version       = bin2hex(substr($pr_bits, 6, 2));
    $clock_seq_hi_and_reserved = bin2hex(substr($pr_bits, 8, 2));

    $node = bin2hex(substr($pr_bits, 10, 6));

    /**
     * Set the four most significant bits (bits 12 through 15) of the
     * time_hi_and_version field to the 4-bit version number from
     * Section 4.1.3.
     * @see http://tools.ietf.org/html/rfc4122#section-4.1.3
     */
    $time_hi_and_version = hexdec($time_hi_and_version);
    $time_hi_and_version = $time_hi_and_version >> 4;
    $time_hi_and_version = $time_hi_and_version | 0x4000;

    /**
     * Set the two most significant bits (bits 6 and 7) of the
     * clock_seq_hi_and_reserved to zero and one, respectively.
     */
    $clock_seq_hi_and_reserved = hexdec($clock_seq_hi_and_reserved);
    $clock_seq_hi_and_reserved = $clock_seq_hi_and_reserved >> 2;
    $clock_seq_hi_and_reserved = $clock_seq_hi_and_reserved | 0x8000;

    return sprintf('%08s-%04s-%04x-%04x-%012s', $time_low, $time_mid, $time_hi_and_version, $clock_seq_hi_and_reserved, $node);
  }

  /**
   * Create a Crypt object
   *
   * @param int $encryption Cipher to use
   * @param int $mode       Encryption mode to use
   *
   * @return Crypt_AES|Crypt_DES|Crypt_TripleDES
   */
  static function getCipher($encryption = self::AES, $mode = self::CTR) {
    switch ($encryption) {
      case self::AES:
        return new Crypt_AES($mode);

      case self::DES:
        return new Crypt_DES($mode);

      case self::TDES:
        return new Crypt_TripleDES($mode);
    }

    return null;
  }

  /**
   * Filtering input data
   *
   * @param string $params Array to filter
   *
   * @return array
   */
  static function filterInput($params) {
    if (!is_array($params)) {
      return $params;
    }

    // We replace passwords and passphrases with a mask
    $mask    = "***";
    $pattern = "/password|passphrase/i";

    foreach ($params as $_key => $_value) {
      if (!empty($_value) && preg_match($pattern, $_key)) {
        $params[$_key] = $mask;
      }
    }

    return $params;
  }
}
