{{* $Id:$ *}}

{{*
 * @package Mediboard
 * @subpackage ssr
 * @version $Revision: $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}


<script type="text/javascript">
Main.add(function() {
  var sejours_count = {{$sejours_count|json}};
  var link = $('tabs-replacement').down('a[href=#{{$type}}s]');
	link.down('small').update('('+sejours_count+')');
	link.setClassName('wrong', sejours_count != 0);
})
</script>

<table class="tbl">
  {{foreach from=$sejours key=plage_conge_id item=_sejours}}
	  <tr>
	    <th colspan="5" class="title text">
	    	{{assign var=plage_conge value=$plages_conge.$plage_conge_id}}
			  S�jours pendant les cong�s de 
        {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$plage_conge->_ref_user}}
				<br />
				{{mb_include module=system template=inc_interval_date from=$plage_conge->date_debut to=$plage_conge->date_fin}}
			</th>
		</tr>
		<tr>
	    <th colspan="2">{{mb_title class=CSejour field=patient_id}}</th>
	    <th>{{mb_title class=CSejour field=entree}}</th>
	    <th>{{mb_title class=CSejour field=sortie}}</th>
			<th>
			  {{if $type == "kine"}}
			    {{mb_title class=CReplacement field=replacer_id}}
			  {{else}}
          Evts SSR
			  {{/if}}
			</th>
    </tr>
		
	  {{foreach from=$_sejours item=_sejour}}
		  {{assign var=sejour_id value=$_sejour->_id}}
      {{assign var=key value="$plage_conge_id-$sejour_id"}}
      {{assign var=replacement value=$_sejour->_ref_replacement}}
			
      <tr id="replacement-{{$type}}-{{$_sejour->_id}}">
		    <td colspan="2" class="text {{if $replacement->_id && $type == "kine"}} arretee {{/if}}">
					{{assign var=patient value=$_sejour->_ref_patient}}
				  <big class="CPatient-view" style=""
					  onmouseover="ObjectTooltip.createEx(this, '{{$patient->_guid}};')" 
					  onclick="refreshReplacement('{{$_sejour->_id}}','{{$plage_conge_id}}','{{$type}}'); this.up('tr').addUniqueClassName('selected');" >
						{{$patient}}
					</big> 
				  <br />
					{{mb_include module=dPpatients template=inc_vw_ipp ipp=$patient->_IPP}}
          {{$patient->_age}} ans
		    </td>
		    <td style="text-align: center;">
		      {{mb_value object=$_sejour field=entree format=$conf.date}}
		      <div style="text-align: left; opacity: 0.6;">{{$_sejour->_entree_relative}}j</div>
		    </td>
		    <td style="text-align: center;">
		      {{mb_value object=$_sejour field=sortie format=$conf.date}}
		      <div style="text-align: right; opacity: 0.6;">{{$_sejour->_sortie_relative}}j</div>
		    </td>
        {{if $type == "kine"}}
        <td style="text-align: left;">
				  {{if $replacement->_id}} 
            {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$replacement->_ref_replacer}}
				  {{/if}}
        </td>
        {{else}}
        <td style="text-align: center;">
				  {{$count_evts.$key}}
        </td>
	      {{/if}}
		  </tr>
			
    {{/foreach}}
	{{foreachelse}}
	<tr>
	  <th class="title">
	  	S�jours
	  </th>
	</tr>
	<tr>
    <td colspan="10">
      <em>{{tr}}CSejour.none{{/tr}}</em>
    </td>
	</tr>
	{{/foreach}}
</table>