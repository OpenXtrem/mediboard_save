{{* $Id:$ *}}

{{*
 * @package Mediboard
 * @subpackage hprim21
 * @version $Revision: 6069 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<script type="text/javascript">

reprocessing = function(echange_hprim21_id){
  var url = new Url("hprim21", "ajax_reprocessing_message");
  url.addParam("echange_hprim21_id", echange_hprim21_id);
  url.requestUpdate("systemMsg", { onComplete:function() { 
     refreshEchange(echange_hprim21_id) }});
}

refreshEchange = function(echange_hprim21_id){
  var url = new Url("hprim21", "ajax_refresh_echange");
  url.addParam("echange_hprim21_id", echange_hprim21_id);
  url.requestUpdate("echange_"+echange_hprim21_id);
}

function changePage(page) {
  $V(getForm('filterEchange').page,page);
}

</script>

<table class="main">  
  {{if !$echg_hprim21->_id}}
  <!-- Filtres -->
  <tr>
    <td style="text-align: center;">
      <form action="?" name="filterEchange" method="get">
        <input type="hidden" name="m" value="{{$m}}" />
        <input type="hidden" name="tab" value="{{$tab}}" />
        <input type="hidden" name="types[]" />
        <input type="hidden" name="page" value="{{$page}}" onchange="this.form.submit()"/>
        
        <table class="form">
          <tr>
            <th class="category" colspan="4">Choix de la date d'�change</th>
          </tr>
          <tr>
            <th style="width:50%">{{mb_label object=$echg_hprim21 field="_date_min"}}</th>
            <td style="width:0.1%">{{mb_field object=$echg_hprim21 field="_date_min" form="filterEchange" register=true onchange="\$V(this.form.page, 0)"}} </td>
            <th style="width:0.1%">{{mb_label object=$echg_hprim21 field="_date_max"}}</th>
            <td style="width:50%">{{mb_field object=$echg_hprim21 field="_date_max" form="filterEchange" register=true onchange="\$V(this.form.page, 0)"}} </td>
          </tr>
          <tr>
            <th class="category" colspan="4">Crit�res de filtres</th>
          </tr>
          <tr>
            <th colspan="2">Type de message</th>
            <td colspan="2">
              <select class="str" name="type_message">
                <option value="">&mdash; Liste des messages </option>
                <option value="ADM" {{if $type_message == "ADM"}}selected="selected"{{/if}}>(ADM) - Admission</option>
                <option value="ERR" {{if $type_message == "ERR"}}selected="selected"{{/if}}>(ERR) - Erreurs</option>
                <option value="FAC" {{if $type_message == "FAC"}}selected="selected"{{/if}}>(FAC) - Facturation</option>
                <option value="ORM" {{if $type_message == "ORM"}}selected="selected"{{/if}}>(ORM) - Demandes d'analyses ou d'actes de radiologie</option>
                <option value="ORU" {{if $type_message == "ORU"}}selected="selected"{{/if}}>(ORU) - R�sultats d'analyses ou de compte rendus de radiologie</option>
                <option value="REG" {{if $type_message == "REG"}}selected="selected"{{/if}}>(REG) - Regl�ment</option>
              </select>
            </td>
          </tr>  
          <tr>
            <td colspan="4" style="text-align: center">
              {{foreach from=$types key=type item=value}}
                <input onclick="$V(this.form.page, 0)" type="checkbox" name="types[{{$type}}]" {{if array_key_exists($type, $selected_types)}}checked="checked"{{/if}} />{{tr}}CEchangeHprim-type-{{$type}}{{/tr}}
              {{/foreach}}
            </td>
          </tr>
          <tr>
            <td colspan="4" style="text-align: center">
              <button type="submit" class="search">{{tr}}Filter{{/tr}}</button>
            </td>
          </tr>
        </table>
          {{if $total_echange_hprim21 != 0}}
            {{mb_include module=system template=inc_pagination total=$total_echange_hprim21 current=$page change_page='changePage' jumper='10'}}
          {{/if}}
      </form>
    </td>
  </tr>
  <tr>
    <td class="halfPane" rowspan="3">
      <table class="tbl">
        <tr>
          <th class="title" colspan="20">ECHANGES HPRIM 2.1</th>
        </tr>
        <tr>
          <th>{{tr}}Purge{{/tr}}</th>
          <th>{{mb_title object=$echg_hprim21 field="echange_hprim21_id"}}</th>
          <th>{{mb_title object=$echg_hprim21 field="object_class"}}</th>
          <th>{{mb_title object=$echg_hprim21 field="object_id"}}</th>
          <th>{{mb_title object=$echg_hprim21 field="id_permanent"}}</th>
          <th>{{mb_title object=$echg_hprim21 field="date_production"}}</th>
          <th>{{mb_title object=$echg_hprim21 field="version"}}</th>
          <th>{{mb_title object=$echg_hprim21 field="type_message"}}</th>
          <th>{{mb_title object=$echg_hprim21 field="emetteur_desc"}}</th>
          <th>{{mb_title object=$echg_hprim21 field="destinataire_desc"}}</th>
          <th>{{mb_title object=$echg_hprim21 field="date_echange"}}</th>
          <th>Retraitement</th>
          <th colspan="2">{{mb_title object=$echg_hprim21 field="message_valide"}}</th>
        </tr>
        {{foreach from=$echangesHprim21 item=_echange_21}}
          <tbody id="echange_{{$_echange_21->_id}}">
            {{mb_include template="inc_echange_hprim21" object=$_echange_21}}
          </tbody>
        {{foreachelse}}
          <tr>
            <td colspan="17">
              {{tr}}CEchangeHprim21.none{{/tr}}
            </td>
          </tr>
        {{/foreach}}
      </table>
    </td>
  </tr>
  {{else}}
  <tr>
    <td>
      <script type="text/javascript">
        Main.add(function () {
          Control.Tabs.create('tabs-contenu', true);
        });
      </script>
      <ul id="tabs-contenu" class="control_tabs">
        <li><a href="#message">{{mb_title object=$echg_hprim21 field="message"}}</a></li>
      </ul>
      
      <hr class="control_tabs" />
      
      <div id="message" style="display: none;">
        {{mb_value object=$echg_hprim21 field="message"}}
      </div>
    </td>
  </tr> 
  {{/if}}
</table>