{{$mediboardScriptStorage|smarty:nodefaults}}

{{mb_include_script module="dPrepas" script="dPrepas"}}

<table class='titleblock'>
  <tr>
    <td class='titlecell'>
      Gestion des Repas Offline
    </td>
  </tr>
</table>
<table id="header" class="Offline" cellspacing="0">
  <tr>
    <td id="menubar">
      <table>
        <tr>
          <td id="tdMenuRecupServ" class="button">
            <a href="#" onclick="loadServices();">
              <img src="images/pictures/download.png" title="R�cup�rer les services"/><br />R�cup�rer Les services
            </a>
          </td>
          <td id="tdMenuRecupRepas" class="button">
            <a href="#" onclick="getDatadPrepas();">
              <img src="images/pictures/download.png" title="R�cup�rer les services"/><br />R�cup�rer les Repas
            </a>
          </td>
          <td id="tdMenuModifRepas" class="button">
            <a href="#">
              <img src="images/pictures/dPrepas.png" title="Modification des Repas"/><br />Modification des Repas
            </a>
          </td>
          <td id="tdMenuSynchro" class="button">
            <a href="#" onclick="checkInRepas();">
              <img src="images/pictures/upload.png" title="Envoi des Repas"/><br />Envoi des Repas
            </a>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

<form name="FrmSelectService" action="#" method="post">
<table class="form" id="vwServices" style="display:none;">
  <tr>
    <th><label for="service_id" title="Veuillez s�lectionner un service">Service</label></th>
    <td id="listService"><select class="notNull ref" name="service_id"></select></td>
  </tr>
  <tr>
    <th><label for="date" title="Veuillez s�lectionner une date">Date</label></th>
    <td class="date">
      <div id="FrmSelectService_date_da"></div>
      <input type="hidden" name="date" class="notNull date" value="" />
      <img id="FrmSelectService_date_trigger" src="./images/icons/calendar.gif" alt="calendar" title="Choisir une date de d�but" />
    </td>
  </tr>
</table>
</form>

<div id="divPlanningRepas"></div>
<div id="divRepas" style="display:none">
  <form name="editRepas" action="#" method="post">
  <input type="hidden" name="m" value="dPrepas" />
  <input type="hidden" name="dosql" value="do_repas_aed" />
  <input type="hidden" name="repas_id" value="" />
  <input type="hidden" name="_tmp_repas_id" value="" />
  <input type="hidden" name="affectation_id" value="" />
  <input type="hidden" name="typerepas_id" value="" />
  <input type="hidden" name="date" value="" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="_del" value="0" />
  <input type="hidden" name="_synchroConfirm" value="0" />
  
  <table class="form">
    <tr>
      <th class="title" colspan="3" id="thRepasTitle"></th>
    </tr>
    <tr>
      <th><strong>Chambre</strong></th>
      <td id="tdRepasChambre"></td>
      <td rowspan="5" class="halfPane" id="listPlat"></td>
    </tr>
    <tr>
      <th><strong>{{tr}}Date{{/tr}}</strong></th>
      <td id="tdRepasDate"></td>
    </tr>
    <tr>
      <th><strong>Type de Repas</strong></th>
      <td id="tdRepasTypeRepas"></td>
    </tr>
    <tr>
      <td colspan="2" class="button">
        <button type="button" class="submit" onclick="vwPlats('');">Ne pas pr�voir de repas</button>
      </td>
    </tr>
    <tr>
      <td colspan="2" class="button" id="tdlistMenus">
      </td>
    </tr>
  </table>
  </form>
</div>

<div style="display:none">
  <table id="templateListRepas" class="tbl">
    <tr>
      <th class="category">Menu</th>
      <th class="category">Diab�tique</th>
      <th class="category">Sans sel</th>
      <th class="category">Sans r�sidu</th>
    </tr>
  </table>
  
  <table id="templateListPlats" class="form">
    <tbody>
    <tr>
      <th id="thPlatTitle" class="category" colspan="2"></th>
    </tr>
    {{foreach from=$plats->_specs.type->_list item=curr_typePlat}}
    <tr>
      <th>
        <label for="{{$curr_typePlat}}">{{tr}}CPlat.type.{{$curr_typePlat}}{{/tr}}</label>
      </th>
      <td id="{{$curr_typePlat}}" class="text"></td>
    </tr>
    {{/foreach}}
    </tbody>
  </table>
  
  <table id="templateNoRepas" class="form">
    <tbody>
    <tr>
      <th id="thPlatTitle" class="category" colspan="2">
        Ne pas pr�voir de repas
        {{foreach from=$plats->_specs.type->_list item=curr_typePlat}}
        <input type="hidden" name="{{$curr_typePlat}}" value="" />
        {{/foreach}}
      </th>
    </tr>
    </tbody>
  </table>
  
  <select id="templatelistService" class="notNull ref" name="service_id"><option value="">&mdash; Veuillez s�lectionner un service</option></select>
  <button id="templateButtonMod" onclick="saveRepas();" type="button" class="modify">{{tr}}Modify{{/tr}}</button>
  <button id="templateButtonDel" onclick="confirmDeletionOffline(this.form, saveRepas,{typeName:'{{tr escape="javascript"}}CRepas.one{{/tr}}'})" type="button" class="trash">{{tr}}Delete{{/tr}}</button>
  <button id="templateButtonAdd" onclick="saveRepas();" type="button" class="submit">{{tr}}Create{{/tr}}</button>
  <a id="templateHrefBack" class="button" style="float:left;" href="#" onclick="view_planning();" >
    <img align="top" src="images/icons/prev.png" alt="Fichier pr�c�dent" />Retour
  </a>
</div>