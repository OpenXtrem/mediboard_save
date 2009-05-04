{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<script type="text/javascript">

// Si ligne de traitement perso finie, on empeche le passage en ligne de prescription normale
Main.add( function(){
  // Preparation du formulaire
  prepareForm('form-stop-{{$line->_class_name}}-{{$line->_id}}');
  
  Calendar.regField('form-stop-{{$line->_class_name}}-{{$line->_id}}', "date_arret", false, dates);
} );

calculDateArret = function(oForm, object_id, object_class, traitement, cat_id){
  // Date mais pas heure
  if(oForm.date_arret.value && !oForm.time_arret.value){
    oForm.time_arret.value = "00:00";
  }
  if(!oForm.date_arret.value){
    oForm.date_arret.value = "{{$today}}";
    oForm.time_arret.value = "{{$now_time}}";
  }
  changeColor(object_id, object_class, oForm, traitement, cat_id);
  Prescription.submitFormStop(oForm, object_id, object_class);
}

</script>

{{if $line->_class_name == "CPrescriptionLineMedicament"}}
  {{assign var=dosql value="do_prescription_line_medicament_aed"}}
  {{assign var=category_id value=""}}
  {{assign var=_traitement_personnel value=$line->traitement_personnel}}
{{else}}
  {{assign var=dosql value="do_prescription_line_element_aed"}}
  {{assign var=category_id value=$category->_id}}
  {{assign var=_traitement_personnel value=0}}
{{/if}}

<form name="form-stop-{{$object_class}}-{{$line->_id}}" method="post" action="">
  <input type="hidden" name="m" value="dPprescription" />
  <input type="hidden" name="dosql" value="{{$dosql}}" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="{{$line->_spec->key}}" value="{{$line->_id}}" />
  {{if $line->date_arret}}
    <input type="hidden" name="date_arret" value="" />
    <input type="hidden" name="time_arret" value="" />
	  <button type="button"
	          class="cancel" 
	          onclick="changeColor('{{$line->_id}}','{{$line->_class_name}}',this.form.date_arret.value,'{{$_traitement_personnel}}','{{$category_id}}'); 
	                   Prescription.submitFormStop(this.form,'{{$line->_id}}','{{$line->_class_name}}');">
	    Annuler l'arr�t
	  </button>
	  {{mb_value object=$line field=date_arret}}
	  {{if $line->time_arret}}
	    � {{mb_value object=$line field=time_arret}}  
	  {{/if}}<br />
  {{else}}
    <table>
      <tr>
        <td style="border: none;">Date d'arr�t</td>
        <td class="date" style="border:none;">
          
          {{assign var=line_id value=$line->_id}}
	        {{mb_field object=$line field=date_arret form=form-stop-$object_class-$line_id canNull=false}}
	        {{mb_field object=$line field=time_arret form=form-stop-$object_class-$line_id}}
	        <button type="button" 
	                class="stop" 
	                onclick="calculDateArret(this.form, '{{$line->_id}}','{{$line->_class_name}}','{{$_traitement_personnel}}','{{$category_id}}');">  
	          Arr�ter
	        </button>
	      </td>
	    </tr>
	  </table>
  {{/if}}
</form>