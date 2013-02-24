<?php
/**
 * Database installation
 *  
 * @package    Mediboard
 * @subpackage Intaller
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @version    SVN: $Id$ 
 * @link       http://www.mediboard.org
 */

require_once "includes/checkauth.php";
require_once "includes/checkconfig.php";

// Data sources to test in the wizard
global $dPconfig;
$dbConfigs = array (
  "std" => $dPconfig["db"]["std"]
);

require_once "includes/addusers.sql.php"; // Must stay AFTER $dbConfigs

showHeader();

?>

<h2>Initialisation des bases de donn�es</h2>

<p>
  Cette �tape permet de cr�er les bases de donn�es et les utilisateurs de base de donn�es
  indispensables pour le fonctionnement de Mediboard. Dans un second temps, il permettra de 
  remplir ces bases avec les structures minimales.
</p>

<h3>Cr�ation des utilisateurs et des bases</h3>

<p>
  Vous �tes sur le point de cr�er les utilisateurs. Si vous avez des droits d'administration
  sur votre serveur de base de donn�es, l'assistant se charge de tout cr�er pour vous.
  Dans le cas contraire, vous devrez fournir le code g�n�r� � un administrateur pour qu'il
  l'ex�cute.
</p>

<form name="createBases" action="05_initialize.php" method="post">

<table class="form">
  <col style="width: 25%;" />

  <tr>
    <th class="title" colspan="2">Avec des droits d'aministrateurs</th>
  </tr>

  <tr>
    <th><label for="adminhost" title="Nom de l'h�te">Nom de l'h�te</label></th>
    <td><input type="text" size="40" name="adminhost" value="<?php echo $dbConfigs["std"]["dbhost"]; ?>" /></td>
  </tr>

  <tr>
    <th><label for="adminuser" title="Nom de l'utilisateur">Nom de l'administrateur</label></th>
    <td><input type="text" size="40" name="adminuser" value="root" /></td>
  </tr>

  <tr>
    <th><label for="adminpass" title="Mot de passe de l'utililisateur'">Mot de passe de l'administrateur</label></th>
    <td><input type="password" size="40" name="adminpass" value="" /></td>
  </tr>

  <tr>
    <td class="button" colspan="2">
      <button type="submit" class="new">Cr�ation de la base et des utilisateurs</button>
    </td>
  </tr>

<?php 
if (@$_POST["adminhost"]) {
  $dbConnection = new CMbDb(
    $_POST["adminhost"],
    $_POST["adminuser"],
    $_POST["adminpass"]);
    
  if ($dbConnection->connect()) {
    foreach ($queries as $query) {
      $dbConnection->query($query);
    }
  }
?>

<tr>
  <th class="category">Action</th>
  <th class="category">Statut</th>
</tr>

<tr>
  <td>Cr�ations des bases et des utilisateurs</td>
  <td>
    <?php if (!count($dbConnection->_errors)) { ?>
    <div class="info">Cr�ations r�ussies</div>
    <?php } else { ?>
    <div class="error">
      Erreurs lors des cr�ations
      <br />
      <?php echo nl2br(implode("\n", $dbConnection->_errors)); ?>
    </div>
    <?php } ?>
  </td>
</tr>

<?php } ?>

</table>

</form>

<form name="generateCode" action="05_initialize.php" method="post">

<input type="hidden" name="generate" value="true"/>
  
<table class="form">
  <col style="width: 50%;" />

  <tr>
    <th class="title" colspan="2">Sans droits d'aministrateurs</th>
  </tr>

  <tr>
    <td class="button" colspan="2">
      <button type="submit" class="edit">G�n�rer le code de cr�ation des utilisateurs et des bases</button>
    </td>
  </tr>
  
</table>

</form>

<?php if (@$_POST["generate"]) { ?>
<p>
  Merci de fournir le code suivant � un administrateur du serveur de base de
  donn�es pour qu'il puisse l'ex�cuter.
</p>
<p>
  Vous <strong>ne pouvez pas</strong> continuer l'installation de Mediboard 
  tant que cette �tape n'est pas effectu�e.
</p>

<textarea cols="50" rows="10"><?php echo implode("\n\n", $queries); ?></textarea>
<?php } ?>

<h3>Tests de connexion</h3>

<table class="tbl">
  <tr>
    <th>Configuration</th>
    <th>Test de connectivit�</th>
  </tr>
  <?php 
  foreach ($dbConfigs as $dbConfigName => $dbConfig) {
    $dbConnection = new CMbDb(
      $dbConfig["dbhost"], 
      $dbConfig["dbuser"], 
      $dbConfig["dbpass"], 
      $dbConfig["dbname"]
    );
    $dbConnection->connect();
  ?>
  <tr>
    <td><?php echo $dbConfigName; ?>
    </td>
    <td>
    
    <?php if (!count($dbConnection->_errors)) { ?>
      <div class="info">Connexion r�ussie</div>
    <?php } else { ?>
      <div class="error">
        Echec de connexion
        <br />
        <?php echo nl2br(join($dbConnection->_errors, "\n")); ?>
      </div>
    <?php } ?>

    </td>
  </tr>
  <?php } ?>
  
</table>

<?php showFooter(); ?>