{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

{{mb_script module="dPprescription" script="protocole"}}
{{mb_script module="dPprescription" script="prescription"}}

<script type="text/javascript">

Main.add( function(){
  Protocole.refreshListPack('{{$pack->_id}}');
  Protocole.viewPack('{{$pack->_id}}');
} );

</script>

<table class="main">
  <tr>
    <td style="width: 200px;">
      <table class="form">
		    <!-- Affichage de la liste des protocoles pour le praticien selectionn� -->
		    <tr>
		     <td>
			    <form name="selPrat" action="?" method="get">
			      <input type="hidden" name="tab" value="vw_edit_pack_protocole" />
		        <input type="hidden" name="m" value="dPprescription" />
		        <select name="praticien_id"
              onchange="this.form.function_id.value = ''; this.form.group_id.value = ''; Protocole.refreshListPack(); Protocole.viewPack();"
              style="width: 23em">
		          <option value="">&mdash; {{tr}}CPrescription._owner.prat{{/tr}}</option>
			        {{foreach from=$praticiens item=praticien}}
			        <option class="mediuser" 
			                style="border-color: #{{$praticien->_ref_function->color}};" 
			                value="{{$praticien->_id}}"
			                {{if $praticien->_id == $praticien_id}}selected="selected"{{/if}}>{{$praticien->_view}}
			        </option>
			        {{/foreach}}
			      </select>
			      <br />
			      <select name="function_id"
              onchange="this.form.praticien_id.value = ''; this.form.group_id.value = ''; Protocole.refreshListPack(); Protocole.viewPack()"
              style="width: 23em">
		          <option value="">&mdash; {{tr}}CPrescription._owner.func{{/tr}}</option>
		          {{foreach from=$functions item=_function}}
		          <option class="mediuser" style="border-color: #{{$_function->color}}" value="{{$_function->_id}}" {{if $function_id == $_function->_id}}selected=selected{{/if}}>{{$_function->_view}}</option>
		          {{/foreach}}
		        </select>
            <br/>
            <select name="group_id"
              onchange="this.form.praticien_id.value = ''; this.form.function_id.value = ''; Protocole.refreshListPack(); Protocole.viewPack()"
              style="width: 23em">
              <option value="">&mdash; {{tr}}CPrescription._owner.group{{/tr}}</option>
              {{foreach from=$groups item=_group}}
              <option class="mediuser" value="{{$_group->_id}}" {{if $group_id == $_group->_id}}selected=selected{{/if}}>{{$_group->_view}}</option>
              {{/foreach}}
            </select>
			    </form>
			    <br />
			    <button type="button" class="submit" onclick="Protocole.viewPack('')">
		        Cr�er un pack
		      </button>
		      <!-- Affichage de la liste des packs du praticien / cabinet -->
			    <div id="view_list_pack"></div>
		    </td>
		   </tr>
      </table>
    </td>  
    <td id="view_pack">
    </td>
  </tr>
</table>