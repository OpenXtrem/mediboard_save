<?php /** $Id$ **/

/**
 * @package Mediboard
 * @subpackage dPportail
 * @version $Revision$
 * @author Romain Ollvier
 */

class CSetupmessagerie extends CSetup {

  function __construct() {
    parent::__construct();

    $this->mod_name = "messagerie";
    $this->makeRevision("all");

    $query = "CREATE TABLE `mbmail` (
              `mbmail_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
              `from` INT (11) UNSIGNED NOT NULL,
              `to` INT (11) UNSIGNED NOT NULL,
              `subject` VARCHAR (255) NOT NULL,
              `source` MEDIUMTEXT,
              `date_sent` DATETIME,
              `date_read` DATETIME,
              `date_archived` DATETIME,
              `starred` ENUM ('0','1') NOT NULL DEFAULT '0'
              ) /*! ENGINE=MyISAM */;";
    $this->addQuery($query);

    $query = "ALTER TABLE `mbmail` 
              ADD INDEX (`from`),
              ADD INDEX (`to`),
              ADD INDEX (`date_sent`),
              ADD INDEX (`date_read`);";
    $this->addQuery($query);
    
    $this->makeRevision("0.10");
    $query = "ALTER TABLE `mbmail` CHANGE `date_archived` `archived` ENUM ('0','1') NOT NULL DEFAULT '0';";
    $this->addQuery($query);
    
    $this->makeRevision("0.11");
    $query = "RENAME TABLE `mbmail` TO `usermessage`;";
    $this->addQuery($query);
    $query = "ALTER TABLE `usermessage` CHANGE `mbmail_id` `usermessage_id` INT( 11 ) UNSIGNED NOT NULL AUTO_INCREMENT;";
    $this->addQuery($query);

    $this->makeRevision("0.12");

    $this->addPrefQuery("ViewMailAsHtml", 1);

    $this->makeRevision("0.13");
    $this->addDependency("dPfiles", "0.1");
    $query = "CREATE TABLE `user_mail` (
              `user_mail_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
              `user_id` INT (11) UNSIGNED NOT NULL,
              `subject` VARCHAR (255),
              `from` VARCHAR (255),
              `to` VARCHAR (255),
              `date_inbox` DATETIME,
              `date_read` DATETIME,
              `uid` INT (11),
              `answered` ENUM ('0','1') DEFAULT '0',
              `in_reply_to_id` INT (11) UNSIGNED,
              `text_plain_id` INT (11) UNSIGNED,
              `text_html_id` INT (11) UNSIGNED
) /*! ENGINE=MyISAM */;";
    $this->addQuery($query);
    $query = "ALTER TABLE `user_mail` 
              ADD INDEX (`date_inbox`);";
    $this->addQuery($query);


    $this->makeRevision("0.14");
    $query = "CREATE TABLE `user_mail_attachment` (
              `user_mail_attachment_id` INT (11) UNSIGNED NOT NULL auto_increment PRIMARY KEY,
              `mail_id` INT (11) UNSIGNED NOT NULL,
              `type` INT (11) NOT NULL,
              `encoding` INT (11),
              `subtype` VARCHAR (255),
              `id` VARCHAR (255),
              `bytes` INT (11),
              `disposition` VARCHAR (255),
              `part` VARCHAR (255) NOT NULL,
              `name` VARCHAR (255) NOT NULL,
              `extension` VARCHAR (255) NOT NULL
) /*! ENGINE=MyISAM */;";
    $this->addQuery($query);
    $query = "ALTER TABLE `user_mail_attachment`
              ADD INDEX (`mail_id`);";
    $this->addQuery($query);

    $this->makeRevision("0.15");
    $this->addPrefQuery("getAttachmentOnUpdate", 0);

    $this->makeRevision("0.16");
    $query = "ALTER TABLE `user_mail_attachment`
              ADD `linked` VARCHAR (255) AFTER `part`;";
    $this->addQuery($query);

    $this->makeRevision("0.17");
    $this->addPrefQuery("LinkAttachment", 1);

    $this->makeRevision("0.18");
    $this->addPrefQuery("showImgInMail", 1);

    $this->makeRevision("0.19");
    $query = "ALTER TABLE `user_mail`
              ADD `account_id` INT (11) NOT NULL AFTER `user_mail_id`,
              DROP `user_id`;";
    $this->addQuery($query);

    $query = "ALTER TABLE `user_mail` ADD INDEX (`account_id`);";
    $this->addQuery($query);

    $this->makeRevision("0.20");
    $query = "ALTER TABLE `user_mail_attachment` CHANGE `linked` `file_id` INT (11) UNSIGNED ;";
    $this->addQuery($query);

    $this->makeRevision("0.21");
    $this->addPrefQuery("nbMailList", 20);

    $this->makeRevision("0.22");
    $query = "ALTER TABLE `user_mail`
    ADD `text_file_id` INT (11) UNSIGNED AFTER `in_reply_to_id`;";
    $this->addQuery($query);

    $this->makeRevision("0.23");
    $query = "ALTER TABLE `user_mail`
              ADD `favorite` ENUM ('0','1') DEFAULT '0';";
    $this->addQuery($query);

    $this->makeRevision("0.24");
    $query = "ALTER TABLE `user_mail`
              ADD `archived` ENUM ('0','1') DEFAULT '0' AFTER `favorite`;";
    $this->addQuery($query);

    $this->makeRevision("0.25");
    $this->addPrefQuery("markMailOnServerAsRead", 1);

    $this->makeRevision("0.26");
    $query = "ALTER TABLE `user_mail`
                CHANGE `account_id` `account_id` INT (11) UNSIGNED NOT NULL DEFAULT '0',
                ADD `sent` ENUM ('0','1') DEFAULT '0';";
    $this->addQuery($query);

    $this->makeRevision("0.27");
    $this->addPrefQuery("mailReadOnServerGoToArchived", 1);

    $this->mod_version = "0.28";
  }
}