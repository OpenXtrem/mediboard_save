{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<script type="text/javascript">

function updateId(id){
  var oForm = document.forms[document.selService.refresh_form.value];
  $V(oForm.config_moment_unitaire_id, id);
}

function checkSHM(name, action){
  var url = new Url;
  url.setModuleAction("dPprescription", "httpreq_check_conf");
  url.addParam("name", name);
  url.addParam("action", action);
  url.requestUpdate("shm");
}

Main.add(function () {
  checkSHM('conf-moment', 'check');
});

</script>

<table class="main">
  <tr>
	  <td>
	    <table class="form">
			  <tr>
			    <td>
						<form name="selService" method="get" action="?">
						  <input type="hidden" name="m" value="{{$m}}" />
						  <input type="hidden" name="tab" value="{{$tab}}" />
						  <select name="service_id" onchange="this.form.submit();">
						    <option value="">&mdash; Choix d'un service</option>
						  {{foreach from=$services item=_service}}
						    <option value="{{$_service->_id}}" {{if $service_id == $_service->_id}}selected="selected"{{/if}}>{{$_service->_view}}</option>
						  {{/foreach}}
						  </select>
						  <input type="hidden" name="refresh_form" value="" />
						</form>
			    </td>
			    <td>
			      <button class="tick" type="button" onclick="checkSHM('conf-moment','check')">V�rifier la m�moire partag�e</button>
			    </td>
			    <td id="shm">
			    </td>
			  </tr>
			</table>
	  </td>
  </tr>
  <tr>
    <td>
      <table class="tbl">
        <tr>
          <th>Libelle</th>
          <th>Principal</th>
          <th>Heure par defaut</th>
          <th>Etablissement</th>
          {{if $service->_id}}
          <th>Service {{$service}}</th>
          {{/if}}
        </tr>
        
        <tr>
          <td colspan="10">
						<script type="text/javascript">
						Main.add(function () {
						  Control.Tabs.create('tabs-chaps', true);
						});
						</script>
          
						<ul id="tabs-chaps" class="control_tabs">
			        {{foreach from=$moments item=momentsChap key=chap}}
						  <li><a href="#{{$chap}}">{{tr}}CMomentUnitaire.type_moment.{{$chap}}{{/tr}}</a></li>
							{{/foreach}}
  					</ul>
	
						<hr class="control_tabs" />
	        </td>
        </tr>

        {{foreach from=$moments item=momentsChap key=chap}}
        <tbody id="{{$chap}}" style="display: none;">
        {{foreach from=$momentsChap item=moment}}
        
        {{assign var=moment_id value=$moment->_id}}
        {{assign var=config_group value=$all_configs.$moment_id.group}}
        {{assign var=config_service value=$all_configs.$moment_id.service}}
        
        <tr>
          <td>{{$moment->libelle}}</td>
          <td>
            <form name="changePrincipalMoment-{{$moment->_id}}" method="post" action="">
              <input type="hidden" name="dosql" value="do_moment_unitaire_aed" />
              <input type="hidden" name="m" value="dPprescription" />
              <input type="hidden" name="moment_unitaire_id" value="{{$moment->_id}}" />
              {{mb_field object=$moment field="principal" typeEnum="checkbox" onchange="submitFormAjax(this.form, 'systemMsg');"}}
            </form>
          </td>  
					<td style="text-align: center">{{$all_configs.$moment_id.default|date_format:$conf.time}}</td>
					<td style="text-align: center">
					  <form name="editConfigMoment-group-{{$moment_id}}" action="" method="post">
					    <input type="hidden" name="m" value="{{$m}}" />
					    <input type="hidden" name="dosql" value="do_config_moment_unitaire_aed" />
					    <input type="hidden" name="moment_unitaire_id" value="{{$moment_id}}" />
					    <input type="hidden" name="group_id" value="{{$group_id}}" />
					    <input type="hidden" name="config_moment_unitaire_id" value="{{$config_group->_id}}" />
					    <input type="hidden" name="callback" value="updateId" />
					    <select name="heure" onchange="$V(document.selService.refresh_form, 'editConfigMoment-group-{{$moment_id}}'); submitFormAjax(this.form, 'systemMsg');">
					      <option value="">-</option>
					      {{foreach from=$hours item=_hour}}
					        <option value="{{$_hour}}:00:00" {{if "$_hour:00:00" == $config_group->heure}}selected="selected"{{/if}}>{{$_hour}}h</option>
					      {{/foreach}}
					    </select>
					  </form>
					</td>
					{{if $service_id}}
					<td style="text-align: center">
					  <form name="editconfigMoment-service-{{$moment_id}}" action="" method="post">
					    <input type="hidden" name="m" value="{{$m}}" />
					    <input type="hidden" name="dosql" value="do_config_moment_unitaire_aed" />
					    <input type="hidden" name="moment_unitaire_id" value="{{$moment_id}}" />
					    <input type="hidden" name="service_id" value="{{$service_id}}" />
					    <input type="hidden" name="config_moment_unitaire_id" value="{{$config_service->_id}}" />
					    <input type="hidden" name="callback" value="updateId" />
					    <select name="heure" onchange="$V(document.selService.refresh_form, 'editconfigMoment-service-{{$moment_id}}'); submitFormAjax(this.form, 'systemMsg');">
					      <option value="">-</option>
					      {{foreach from=$hours item=_hour}}
					        <option value="{{$_hour}}:00:00" {{if "$_hour:00:00" == $config_service->heure}}selected="selected"{{/if}}>{{$_hour}}h</option>
					      {{/foreach}}
					    </select>
					  </form>
			  	</td>
			  	{{/if}}
        </tr>
        {{/foreach}}
        </tbody>
        {{/foreach}}
      </table>
    </td>
  </tr>
</table>