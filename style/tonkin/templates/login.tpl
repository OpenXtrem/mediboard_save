<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
  <title>{{$app->cfg.company_name}} :: Mediboard Login</title>
  <meta http-equiv="Content-Type" content="text/html;charset={{$localeCharSet}}" />
  <meta name="Description" content="Mediboard: Plateforme Open Source pour les Etablissement de Sant�" />
  <meta name="Version" content="{{$mediboardVersion}}" />
  {{$mediboardShortIcon|smarty:nodefaults}}
  {{$mediboardCommonStyle|smarty:nodefaults}}
  {{$mediboardStyle|smarty:nodefaults}}
  {{$mediboardScript|smarty:nodefaults}}
</head>

<body onload="main()">

<div id="waitingMsgMask" class="chargementMask" style="display: none;"></div>
<div id="waitingMsgText" class="chargementText" style="display: none;">
  <table class="tbl">
    <tr>
      <th class="title">
        <div class="loading"><span id="waitingInnerMsgText">Chargement en cours</span></div>
      </th>
    </tr>
  </table>
</div>

<div id="login">
  <form name="loginFrm" action="./index.php" method="post">
  <input type="hidden" name="login" value="{{$time}}" />
  <input type="hidden" name="redirect" value="{{$redirect|smarty:nodefaults}}" />
  <input type="hidden" name="dialog" value="{{$dialog}}" />
  <table class="form">
    {{if !$dialog}}
    <tr>
      <th class="category" colspan="3">{{$app->cfg.company_name}}</th>
    </tr>
    <tr>
      <td class="logo" colspan="3 ">
        <a href="http://www.mediboard.org/">
          <img src="images/pictures/mbNormal.gif" alt="MediBoard logo" />
        </a>
        <p>
          Plateforme Open Source pour les Etablissements de Sant�<br/>
          Version {{$mb_version_major}}.{{$mb_version_minor}}.{{$mb_version_patch}}
        </p>
      </td>
    </tr>
    {{/if}}
    <tr>
      <th class="category" rowspan="6" style="vertical-align: middle;">
        <img src="./style/{{$uistyle}}/images/pictures/tonkin.gif" alt="Groupe Tonkin" />
      </th>
      <th class="category" colspan="2">Connexion</th>
      {{if $demoVersion}}
      <th class="category">Comptes disponibles</th>
      {{/if}}
    </tr>
    <tr>
      <th><label for="username" title="Nom de l'utilisateur pour s'authentifier">{{tr}}Username{{/tr}}</label></th>
      <td><input type="text" title="notNull str" size="25" maxlength="20" name="username" class="text" /></td>
      {{if $demoVersion}}
      <td rowspan="3" class="category">
        <strong>Administrateur</strong>: admin/admin<br />
        <strong>Chirurgien</strong>: chir/chir<br />
        <strong>PMSI</strong>: pmsi/pmsi<br />
        <strong>Surveillante de bloc</strong>: survbloc/survbloc<br />
        <strong>Hospitalisation</strong>: hospi/hospi
      </td>
      {{/if}}
    </tr>
    <tr>
      <th><label for="password" title="Mot de passe d'authentification">{{tr}}Password{{/tr}}</label></th>
      <td><input type="password"  title="notNull str" size="25" maxlength="32" name="password" class="text" /></td>
    </tr>
    <tr>
      <td colspan="2" class="button">
        <button class="tick" type="submit" name="login">
          {{tr}}login{{/tr}}
        </button>
      </td>
    </tr>
    <tr>
      <th class="category">Bas� sur</th>
      {{if $demoVersion}}
      <th class="category">H�berg� chez</th>
      {{/if}}
      <th class="category">Propuls� par</th>
    </tr>
    <tr>
      <td class="logo">
        <a href="http://www.dotproject.net/">
          <img src="images/pictures/dp_icon.gif" alt="dotProject logo" />
        </a>
        <p>Version {{$mediboardVersion}}</p>
      </td>
      {{if $demoVersion}}
      <td class="logo">
        <a href="http://www.sourceforge.net/projects/mediboard/" title="Projet Mediboard sur Sourceforge">
          <img src="http://www.sourceforge.net/sflogo.php?group_id=112072&amp;type=2" alt="Sourceforge Project Logo" />
        </a>
        <p>H�bergement du code source</p>
      </td>
      {{/if}}
      
      <td class="logo">
        <a href="http://www.mozilla-europe.org/fr/products/firefox/" title="T�l�charger Firefox">
          <img src="http://www.spreadfirefox.com/community/images/affiliates/Buttons/80x15/firefox_80x15.png" alt="Firefox Logo" />
        </a>
        <p>Pour un meilleur confort et plus de s�curit�, nous recommandons d'utiliser le navigateur Firefox</p>
      </td>
      </tr>
	</table>
  </form>
</div>

{{if $errorMessage}}
  {{$errorMessage|nl2br|smarty:nodefaults}}
{{/if}}
</body>
</html>    