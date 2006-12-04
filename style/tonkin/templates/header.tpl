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
    <td id="mainHeader">
      <table>
        <tr>
          <td rowspan="3" class="logo">
            <img src="./style/{{$uistyle}}/images/tonkin.gif" alt="Groupe Tonkin" />
          </td>
          <th width="1%">
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
          </th>
          <td width="100%">
            <div id="systemMsg">
              {{$errorMessage|smarty:nodefaults}}
            </div>
          </td>
        </tr>
        <tr>
          <td colspan="2" id="menubar1">
            <form name="ChangeGroup" action="" method="get">
            <input type="hidden" name="m" value="{{$m}}" />
            <select name="g" onchange="ChangeGroup.submit();">
              {{foreach from=$Etablissements item=currEtablissement key=keyEtablissement}}
              <option value="{{$keyEtablissement}}" {{if $keyEtablissement==$g}}selected="selected"{{/if}}>
                {{$currEtablissement->_view}}
              </option>
              {{/foreach}}
            </select>
            {{$helpOnline|smarty:nodefaults}} |
            <a href="#" onclick="popChgPwd();">Changez votre mot de passe</a> |
            <a href="?m=mediusers&amp;a=edit_infos">{{tr}}My Info{{/tr}}</a> |
            <a href="./index.php?m=admin&amp;a=edit_prefs&amp;user_id={{$AppUI->user_id}}">{{tr}}Pr�f�rences{{/tr}}</a> |
            <a href="?logout=-1">{{tr}}Logout{{/tr}}</a> |
            </form>
          </td>
        </tr>
        <tr>
          <td colspan="2" id="menubar2">
            {{foreach from=$affModule item=currModule}}    
            <a href="?m={{$currModule.modName}}" class="{{if $currModule.modName==$m}}textSelected{{else}}textNonSelected{{/if}}">
              {{$currModule.modNameCourt}}
            </a> |
            {{/foreach}}
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td id="menubar"></td>
  </tr>
</table>
{{else}}
<div id="systemMsg" style="display: block;">
  {{$errorMessage|smarty:nodefaults}}
</div>
{{/if}}
<table id="main" class="{{$m}}">
  <tr>
    <td>