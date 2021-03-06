<?php

/** This file is part of KCFinder project
  *
  *      @desc Base configuration file
  *   @package KCFinder
  *   @version 2.2
  *    @author Pavel Tzonkov <pavelc@users.sourceforge.net>
  * @copyright 2010 KCFinder Project
  *   @license http://www.opensource.org/licenses/gpl-2.0.php GPLv2
  *   @license http://www.opensource.org/licenses/lgpl-2.1.php LGPLv2
  *      @link http://kcfinder.sunhater.com
  */

// IMPORTANT!!! Do not remove uncommented settings in this file even if
// you are using session configuration.
// See http://kcfinder.sunhater.com/install for setting descriptions

global $dPconfig;

include "../../includes/config_all.php";

$upload_directory = $dPconfig['dPfiles']['CFile']['upload_directory'];

$_CONFIG = array(

    'disabled' => false,
    'readonly' => false,
    'denyZipDownload' => true,

    'theme' => "oxygen",

    'uploadURL' => "../../$upload_directory/editor",
    'uploadDir' => "",

    'dirPerms' => 0755,
    'filePerms' => 0644,

    'deniedExts' => "exe com msi bat php cgi pl",
    
    'access' => array(
        'files' => array(
            'upload' => true,
            'delete' => true,
            'copy' => true,
            'move' => true,
            'rename' => true
        ),

        'dirs' => array(
            'create' => true,
            'delete' => true,
            'rename' => true
        )
    ),

    'types' => array(

        // CKEditor & FCKEditor types
        'files'   =>  "",
        'flash'   =>  "swf",
        'images'  =>  "*img",

        // TinyMCE types
        'file'    =>  "",
        'media'   =>  "swf flv avi mpg mpeg qt mov wmv asf rm",
        'image'   =>  "*img",
    ),

    'mime_magic' => "",

    'maxImageWidth' => 0,
    'maxImageHeight' => 0,

    'thumbWidth' => 100,
    'thumbHeight' => 100,

    'thumbsDir' => ".thumbs",

    'jpegQuality' => 90,

    'cookieDomain' => "",
    'cookiePath' => "",
    'cookiePrefix' => 'KCFINDER_',

    // THE FOLLOWING SETTINGS CANNOT BE OVERRIDED WITH SESSION CONFIGURATION

    '_check4htaccess' => true,
    //'_tinyMCEPath' => "/tiny_mce",

    '_sessionVar' => &$_SESSION['KCFINDER'],
    //'_sessionLifetime' => 30,
    //'_sessionDir' => "/full/directory/path",

    //'_sessionDomain' => ".mysite.com",
    //'_sessionPath' => "/my/path",

    'filenameChangeChars' => array(
        ' ' => "_",
        '%' => "_",
        ':' => "_",
        '$' => "_",
        'à' => "a",
        'â' => "a",
        'é' => "e",
        'è' => "e",
        'ê' => "e",
        'ë' => "e",
        'î' => "i",
        'ï' => "i",
        'ô' => "o",
        'û' => "u",
        'ü' => "u",
        'ù' => "u"
    ),
);

?>