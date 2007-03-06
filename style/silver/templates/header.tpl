<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
  <title>Mediboard :: Syst�me de gestion des structures de sant�</title>
  <meta http-equiv="Content-Type" content="text/html;charset={{$localeCharSet}}" />
  <meta name="Description" content="Mediboard: Plateforme Open Source pour les Etablissement de Sant�" />
  <meta name="Version" content="{{$mediboardVersion}}" />
  {{$mediboardShortIcon|smarty:nodefaults}}
  {{$mediboardCommonStyle|smarty:nodefaults}}
  {{$mediboardStyle|smarty:nodefaults}}
  {{$mediboardScript|smarty:nodefaults}}
  {{if $offline}}
  <script type="text/javascript">
    var config = {{$configOffline|@json}};
  </script>
  {{/if}}
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
{{if !$offline}}
<script type="text/javascript">
function popChgPwd() {
  var url = new Url;
  url.setModuleAction("admin", "chpwd");
  url.popup(400, 300, "ChangePassword");
}
</script>

{{if !$dialog}}

{{foreach from=$messages item=currMsg}}
  <div style='background: #aaa; color: #fff;'><strong>{{$currMsg->titre}}</strong> : {{$currMsg->corps}}</div>
{{/foreach}}

<table id="header" cellspacing="0">
  <tr>
    <td id="menubar">
      <table>
        <tbody id="menuIcons">
        <tr>
          <td />
          {{foreach from=$affModule item=currModule}}    
          <td align="center" class="{{if $currModule.modName==$m}}iconSelected{{else}}iconNonSelected{{/if}}">
            <a href="?m={{$currModule.modName}}" title="{{$currModule.modNameLong}}">
              <img src="images/modules/{{$currModule.modName}}.png" alt="{{$currModule.modNameCourt}}" height="48" width="48" />
            </a>
          </td>
          {{/foreach}}
        </tr>
        </tbody>
        <tr>
          <td>
            <button id="menuIcons-trigger" type="button" style="float:left" />
          </td>
          {{foreach from=$affModule item=currModule}}
          <td align="center" class="{{if $currModule.modName==$m}}textSelected{{else}}textNonSelected{{/if}}" title="{{$currModule.modNameLong}}">
            <a href="?m={{$currModule.modName}}">
              <strong>{{$currModule.modNameCourt}}</strong>
            </a>
          </td>
          {{/foreach}}
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td id="user">
      <table>
        <tr>
          <td id="userWelcome">
            <form name="ChangeGroup" action="" method="get">
              <span title="{{tr}}last connection{{/tr}} : {{$AppUI->user_last_login|date_format:"%A %d %B %Y %H:%M"}}">
                {{tr}}Welcome{{/tr}} {{$AppUI->user_first_name}} {{$AppUI->user_last_name}}
              </span>
              <input type="hidden" name="m" value="{{$m}}" />
              <select name="g" onchange="ChangeGroup.submit();">
                {{foreach from=$Etablissements item=currEtablissement key=keyEtablissement}}
                <option value="{{$keyEtablissement}}" {{if $keyEtablissement==$g}}selected="selected"{{/if}}>
                  {{$currEtablissement->_view}}
                </option>
                {{/foreach}}
              </select>
            </form>
          </td>
          <td id="userMenu">
            {{$helpOnline|smarty:nodefaults}} |
            {{$suggestion|smarty:nodefaults}} |
            <a href="#" onclick="popChgPwd();">Changez votre mot de passe</a> |
            <a href="?m=mediusers&amp;a=edit_infos">{{tr}}My Info{{/tr}}</a> |
            <a href="?m=admin&amp;a=edit_prefs&amp;user_id={{$AppUI->user_id}}">{{tr}}Pr�f�rences{{/tr}}</a> |
            <a href="?logout=-1">{{tr}}Logout{{/tr}}</a>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<script language="JavaScript" type="text/javascript">
  new PairEffect("menuIcons", { bStartVisible: true });
</script>
{{/if}}
{{/if}}
<table id="main" class="{{$m}}">
  <tr>
    <td>
      <div {{if $dialog}}class="dialog" {{if !$errorMessage}} style="display: none"{{/if}}{{/if}} id="systemMsg">
        {{$errorMessage|nl2br|smarty:nodefaults}}
      </div>
      {{if !$dialog && !$offline}}
      <table class='titleblock'>
        <tr>
          {{if $titleBlockData.icon}}
          <td>
            {{$titleBlockData.icon|smarty:nodefaults}}
          </td>
          {{/if}}
          <td class='titlecell'>
            {{tr}}{{$titleBlockData.name}}{{/tr}}
          </td>
        </tr>
      </table>
      {{/if}}