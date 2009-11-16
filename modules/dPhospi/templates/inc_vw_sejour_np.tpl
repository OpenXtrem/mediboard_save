{{if $curr_sejour->_id != ""}}
<tr {{if $object->_id == $curr_sejour->_id}}class="selected"{{/if}}>
  <td>
    <button class="lookup notext" onclick="popEtatSejour({{$curr_sejour->_id}});" />
  </td>
  <td>
    {{assign var=prescriptions value=$curr_sejour->_ref_prescriptions}}
    {{assign var=prescription_sejour value=$prescriptions.sejour}}
    {{assign var=prescription_sortie value=$prescriptions.sortie}}

    <a class="text" href="#1" onmouseover="ObjectTooltip.createEx(this, '{{$curr_sejour->_ref_patient->_guid}}');" onclick="markAsSelected(this); addSejourIdToSession('{{$curr_sejour->_id}}'); loadViewSejour({{$curr_sejour->_id}},{{$curr_sejour->praticien_id}},{{$curr_sejour->patient_id}},'{{$date}}')">
      <span class="{{if !$curr_sejour->entree_reelle}}patient-not-arrived{{/if}} {{if $curr_sejour->septique}}septique{{/if}}">{{$curr_sejour->_ref_patient->_view}}</span>
    </a>
    <script type="text/javascript">
      ImedsResultsWatcher.addSejour('{{$curr_sejour->_id}}', '{{$curr_sejour->_num_dossier}}');
    </script>
  </td>
  <td>
    <a class="button notext edit" href="?m=dPpatients&amp;tab=vw_edit_patients&amp;patient_id={{$curr_sejour->_ref_patient->_id}}" />
  </td>
  <td>
    <a class="button notext search" href="{{$curr_sejour->_ref_patient->_dossier_cabinet_url}}&amp;patient_id={{$curr_sejour->_ref_patient->_id}}" />
  </td>
  <td>
    <div id="labo_for_{{$curr_sejour->_id}}" style="display: none">
      <img src="images/icons/labo.png" alt="Labo" title="R�sultats de laboratoire disponibles" />
    </div>
    <div id="labo_hot_for_{{$curr_sejour->_id}}" style="display: none">
      <img src="images/icons/labo_hot.png" alt="Labo" title="R�sultats de laboratoire disponibles" />
    </div>
  </td>
  <td class="action">
  <div class="mediuser" style="border-color:#{{$curr_sejour->_ref_praticien->_ref_function->color}}">
    <label title="{{$curr_sejour->_ref_praticien->_view}}">
    {{$curr_sejour->_ref_praticien->_shortview}}
    </label>
    {{if $isPrescriptionInstalled}}         
    	 {{if $prescription_sejour->_id && (!$prescription_sortie->_id || $prescription_sejour->_counts_no_valide)}}
    	   <img src="images/icons/warning.png" alt="" title="" 
    	   			onmouseover='ObjectTooltip.createDOM(this, "tooltip-content-alertes-{{$curr_sejour->_guid}}")'/>
    	 {{/if}}
    	 
    	 <div id="tooltip-content-alertes-{{$curr_sejour->_guid}}" style="display: none;">
    	   <ul>
	    	 {{if !$prescription_sortie->_id}}
		       <li>Ce s�jour ne poss�de pas de prescription de sortie</li>
	       {{/if}}
         {{if $prescription_sejour->_counts_no_valide}}
           <li>Lignes non valid�es dans la prescription de s�jour</li>
         {{/if}}    
    	 </div>    
    {{/if}}             
    </div>
  </td>
</tr>
{{/if}}