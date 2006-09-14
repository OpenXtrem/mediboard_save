<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
  <title>Mediboard :: Syst�me de gestion des structures de sant�</title>
  <meta http-equiv="Content-Type" content="text/html;charset=<?php echo isset( $locale_char_set ) ? $locale_char_set : 'UTF-8';?>" />
  <meta name="Description" content="Mediboard: Plateforme Open Source pour les Etablissement de Sant�" />
  <meta name="Version" content="{{$mediboardVersion}}" />
  {{$mediboardShortIcon}}
  {{$mediboardCommonStyle}}
  {{$mediboardStyle}}
  {{$mediboardScript}}
</head>

<body onload="main()">

<script type="text/javascript">
function popChgPwd() {
  window.open( './index.php?m=admin&a=chpwd&dialog=1', 'chpwd', 'top=250,left=250,width=350, height=220, scollbars=false' );
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
          <td class="logo">
            <img src="./style/{{$uistyle}}/images/e-cap.jpg" alt="eCap logo" />
          </td>
          <th width="1%">
            {{$titleBlock}}
          </th>
          <td>
            <div id="systemMsg">
              {{$errorMessage}}
            </div>
          </td>
          <td class="welcome">
            <form name="ChangeGroup" action="" method="get">
            <input type="hidden" name="m" value="{{$m}}" />
            CAPIO Sant� -
            <select name="g" onchange="ChangeGroup.submit();">
              {{foreach from=$Etablissements item=currEtablissement key=keyEtablissement}}
              <option value="{{$keyEtablissement}}" {{if $keyEtablissement==$g}}selected="selected"{{/if}}>
                {{$currEtablissement->_view}}
              </option>
              {{/foreach}}
            </select>
            <br />
            {{tr}}Welcome{{/tr}} {{$AppUI->user_first_name}} {{$AppUI->user_last_name}}
            </form>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td id="menubar">
      | {{$helpOnline}} | 
      {{foreach from=$affModule item=currModule}}
      <a href="?m={{$currModule.modName}}" class="{{if $currModule.modName==$m}}textSelected{{else}}textNonSelected{{/if}}">
        {{$currModule.modNameCourt}}
      </a> |
      {{/foreach}}
      <a href='#' onclick='popChgPwd();return false'>Changez votre mot de passe</a> |
      <a href="./index.php?logout=-1">{{tr}}Logout{{/tr}}</a> |
    </td>
  </tr>
</table>
{{/if}}
<table id="main" class="{{$m}}">
<tr>
  <td>