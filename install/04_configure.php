<?php
/**
 * Installation main configure form
 *
 * @package    Mediboard
 * @subpackage Intaller
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    SVN: $Id$
 * @link       http://www.mediboard.org
 */

require_once "includes/checkauth.php";
require_once $mbpath."includes/compat.php";
require_once $mbpath."classes/CMbConfig.class.php";
require_once $mbpath."classes/CMbArray.class.php";

if (isset($_POST["username"])) {
  unset($_POST["username"]);
}

if (isset($_POST["password"])) {
  unset($_POST["password"]);
}

$mbConfig = new CMbConfig;
$mbConfig->update($_POST);
$mbConfig->load();

$dPconfig = $mbConfig->values;

showHeader();

?>

<h2>Cr�ation du fichier de configuration</h2>

<form name="configure" action="04_configure.php" method="post">

<table class="form">
  <col style="width: 50%" />

  <tr>
    <th class="category" colspan="3">Configuration g�n�rale</th>
  </tr>

  <tr>
    <th><label for="root_dir" title="Repertoire racine. Pas de slash final. Utiliser les slashs aussi pour MS Windows">R�pertoire racine</label></th>
    <td colspan="2"><input type="text" size="40" name="root_dir" value="<?php echo $dPconfig["root_dir"]; ?>" /></td>
  </tr>

  <tr>
    <th><label for="base_url" title="Url Racine pour le syst�me">Url racine</label></th>
    <td colspan="2"><input type="text" size="40" name="base_url" value="<?php echo $dPconfig['base_url'] ?>" /></td>
  </tr>

  <tr>
    <th><label for="instance_role">R�le de l'instance</label></th>
    <td colspan="2">
      <select name="instance_role" size="1">
        <option value="prod"   <?php if ($dPconfig['instance_role'] == 'prod'  ) echo 'selected="1"'; ?> >Production</option>
        <option value="qualif" <?php if ($dPconfig['instance_role'] == 'qualif') echo 'selected="1"'; ?> >Qualification</option>
      </select>
    </td>
  </tr>

  <tr>
    <th><label for="http_redirections" title="Active les redirections http d�finies dans Mediboard">Redirections http actives</label></th>
    <td colspan="2">
      <input type="radio" name="http_redirections" value="0" id="http_redirections_0" <?php if ($dPconfig['http_redirections'] == "0") echo 'checked="1"'; ?> />
      <label for="http_redirections_0">Non</label>
      <input type="radio" name="http_redirections" value="1" id="http_redirections_1" <?php if ($dPconfig['http_redirections'] == "1") echo 'checked="1"'; ?> />
      <label for="http_redirections_1">Oui</label>
    </td>
  </tr>

  <tr>
    <th><label for="shared_memory" title="Choisir quelle extension doit tenter de g�rer la m�moire partag�e (celle-ci doit �tre install�e)">M�moire partag�e</label></th>
    <td>
      <select name="shared_memory" size="1">
        <option value="none" <?php if ($dPconfig['shared_memory'] == 'none') { echo 'selected="selected"'; } ?> >Disque</option>
        <option value="apc"  <?php if ($dPconfig['shared_memory'] == 'apc' ) { echo 'selected="selected"'; } ?> >APC</option>
      </select>
    </td>
    <td>
      <div class="small-info">
        <?php require_once "includes/empty_shared_memory.php"; ?>
      </div>
    </td>
  </tr>

  <tr>
    <th><label for="session_handler" title="Choisir quelle mode de gestion de session ou souhaite utiliser (celle-ci doit �tre install�e)">Gestionnaire de session</label></th>
    <td>
      <select name="session_handler" size="1">
        <option value="files"    <?php if ($dPconfig['session_handler'] == 'files'   ) { echo 'selected="selected"'; } ?> >Fichiers</option>
        <option value="memcache" <?php if ($dPconfig['session_handler'] == 'memcache') { echo 'selected="selected"'; } ?> >Memcache</option>
        <option value="mysql"    <?php if ($dPconfig['session_handler'] == 'mysql'   ) { echo 'selected="selected"'; } ?> >MySQL</option>
        <option value="zebra"    <?php if ($dPconfig['session_handler'] == 'zebra'   ) { echo 'selected="selected"'; } ?> >Zebra (MySQL)</option>
      </select>
    </td>
    <td>
      <div class="small-warning">
        Le changement de ce param�tre <strong>mettra fin � toutes les session des utilisateurs actuellement connect�s</strong>.<br />
        Si vous choisissez le mode Memcache, veuillez vous assurer que le serveur est correctement configur�.
      </div>
    </td>
  </tr>

  <tr>
    <th class="category" colspan="3">Mode maintenance</th>
  </tr>

  <tr>
    <th><label for="offline">Mode maintenance</label></th>
    <td colspan="2">
      <input type="radio" name="offline" value="0" id="offline_0" <?php if ($dPconfig['offline'] == "0") echo 'checked="1"'; ?> />
      <label for="offline_0">Non</label>
      <input type="radio" name="offline" value="1" id="offline_1" <?php if ($dPconfig['offline'] == "1") echo 'checked="1"'; ?> />
      <label for="offline_1">Oui</label>
    </td>
  </tr>

  <tr>
    <th><label for="offline_non_admin">Mode maintenance accessible aux admins</label></th>
    <td colspan="2">
      <input type="radio" name="offline_non_admin" value="0" id="offline_non_admin_0" <?php if ($dPconfig['offline_non_admin'] == "0") echo 'checked="1"'; ?> />
      <label for="offline_non_admin_0">Non</label>
      <input type="radio" name="offline_non_admin" value="1" id="offline_non_admin_1" <?php if ($dPconfig['offline_non_admin'] == "1") echo 'checked="1"'; ?> />
      <label for="offline_non_admin_1">Oui</label>
    </td>
  </tr>

  <tr>
    <th><label for="migration[active]" title="Affiche une page avec les nouvelles adresse de Mediboard aux utilisateurs">Mode migration</label></th>
    <td colspan="2">
      <input type="radio" name="migration[active]" value="0" id="migration[active]_0" <?php if ($dPconfig['migration']['active'] == "0") echo 'checked="1"'; ?> />
      <label for="migration[active]_0">Non</label>
      <input type="radio" name="migration[active]" value="1" id="migration[active]_1" <?php if ($dPconfig['migration']['active'] == "1") echo 'checked="1"'; ?> />
      <label for="migration[active]_1">Oui</label>
    </td>
  </tr>

  <tr>
    <th class="category" colspan="3">Configuration de la base de donn�es principale</th>
  </tr>

  <tr>
    <th><label for="db[std][dbtype]" title="Type de base de donn�es. Seul mysql est possible pour le moment">Type de base de donn�es :</label></th>
    <td colspan="2"><input type="text" readonly="readonly" size="40" name="db[std][dbtype]" value="<?php echo @$dPconfig["db"]["std"]["dbtype"]; ?>" /></td>
  </tr>

  <tr>
    <th><label for="db[std][dbhost]">Nom de l'h�te</label></th>
    <td colspan="2"><input type="text" size="40" name="db[std][dbhost]" value="<?php echo @$dPconfig["db"]["std"]["dbhost"]; ?>" /></td>
  </tr>

  <tr>
    <th><label for="db[std][dbname]">Nom de la base</label></th>
    <td colspan="2"><input type="text" size="40" name="db[std][dbname]" value="<?php echo @$dPconfig["db"]["std"]["dbname"]; ?>" /></td>
  </tr>

  <tr>
    <th><label for="db[std][dbuser]">Nom de l'utilisateur</label></th>
    <td colspan="2"><input type="text" size="40" name="db[std][dbuser]" value="<?php echo @$dPconfig["db"]["std"]["dbuser"]; ?>" /></td>
  </tr>

  <tr>
    <th><label for="db[std][dbpass]">Mot de passe</label></th>
    <td colspan="2"><input type="password" size="40" name="db[std][dbpass]" value="<?php echo @$dPconfig["db"]["std"]["dbpass"]; ?>" /></td>
  </tr>
</table>

<table class="form">
  <tr>
    <th class="category">Validation obligatoire</th>
  </tr>

  <tr>
    <td class="button"><button class="submit" type="submit">Valider la configuration</button></td>
  </tr>
</table>

</form>

<?php showFooter(); ?>