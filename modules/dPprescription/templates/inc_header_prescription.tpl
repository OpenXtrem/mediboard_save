<script type="text/javascript">

refreshListProtocole = function(oForm){
  var oFormFilter = document.selPrat;
  oFormFilter.praticien_id.value = oForm.praticien_id.value;
  oFormFilter.function_id.value = oForm.function_id.value;
  submitFormAjax(oForm, 'systemMsg', { 
        onComplete : function() { 
           Protocole.refreshList(oForm.praticien_id.value,oForm.prescription_id.value, oForm.function_id.value) 
        } 
  });
}



changePraticien = function(praticien_id){
  var oFormAddLine = document.addLine;
  var oFormAddLineCommentMed = document.addLineCommentMed;
  var oFormAddLineElement = document.addLineElement;
  
  oFormAddLine.praticien_id.value = praticien_id;
  oFormAddLineCommentMed.praticien_id.value = praticien_id;
  oFormAddLineElement.praticien_id.value = praticien_id;
}



// On met � jour les valeurs de praticien_id
Main.add( function(){
  if(document.selPraticienLine){
	  changePraticien(document.selPraticienLine.praticien_id.value);
  }
  // On masque le calendrier
	/*if($('calendarProt')){
	  $('calendarProt').hide();
	}*/
} );



submitProtocole = function(){
  var oForm = document.applyProtocole;
  if(oForm.debut_date){
	  var debut_date = oForm.debut_date.value;
	  if(debut_date != "other"){
	    oForm.debut.value = debut_date;
	  }
	

  }
	if(document.selPraticienLine){
   oForm.praticien_id.value = document.selPraticienLine.praticien_id.value;
  }
 
  submitFormAjax(oForm, 'systemMsg');

  oForm.protocole_id.value = '';
  oForm.debut.value = '';
}




</script>

{{assign var=praticien value=$prescription->_ref_praticien}}

<table class="form">
  <tr>
    <th class="title" colspan="2">
    
    <!-- Selection du praticien prescripteur de la ligne -->
			{{if !$is_praticien && !$mode_protocole && !$mode_pharma}}
       <div style="position: absolute; right: 15px">
				<form name="selPraticienLine" action="?" method="get">
				  <select name="praticien_id" onchange="changePraticienMed(this.value); changePraticienElt(this.value)">
				    {{foreach from=$listPrats item=_praticien}}
					    <option class="mediuser" 
					            style="border-color: #{{$_praticien->_ref_function->color}};" 
					            value="{{$_praticien->_id}}"
					            {{if $_praticien->_id == $prescription->_current_praticien_id}}selected == "selected"{{/if}}>{{$_praticien->_view}}
					    </option>
				    {{/foreach}}
				  </select>
				</form>
       </div>
			{{/if}}
			 
      {{if !$mode_protocole && $prescription->object_class == "CSejour"}}
        <div style="float:left; padding-right: 5px; " class="noteDiv {{$prescription->_ref_object->_class_name}}-{{$prescription->_ref_object->_id}};">
          <img alt="Ecrire une note" src="images/icons/note_grey.png" />
        </div>
      {{/if}}
     
      {{if !$mode_protocole && !$dialog && !$mode_pharma && !$mode_sejour}}
      <button type="button" class="cancel" onclick="Prescription.close('{{$prescription->object_id}}','{{$prescription->object_class}}')" style="float: left">
        Fermer 
      </button>
      {{/if}}
     
      
      {{if $mode_protocole}}
      <!-- Formulaire de modification du libelle de la prescription -->
      <form name="addLibelle-{{$prescription->_id}}" method="post">
        <input type="hidden" name="m" value="dPprescription" />
        <input type="hidden" name="dosql" value="do_prescription_aed" />
        <input type="hidden" name="del" value="0" />
        <input type="hidden" name="prescription_id" value="{{$prescription->_id}}" />
        <input type="text" name="libelle" value="{{$prescription->libelle}}" 
               onchange="refreshListProtocole(this.form);" />
      
        <button class="tick notext" type="button"></button>
      
      <!-- Modification du pratcien_id / user_id -->
         <select name="praticien_id" onchange="this.form.function_id.value=''; refreshListProtocole(this.form)">
          <option value="">&mdash; S�lection d'un praticien</option>
	        {{foreach from=$praticiens item=praticien}}
	        <option class="mediuser" 
	                style="border-color: #{{$praticien->_ref_function->color}};" 
	                value="{{$praticien->_id}}"
	                {{if $praticien->_id == $prescription->praticien_id}}selected="selected"{{/if}}>{{$praticien->_view}}
	        </option>
	        {{/foreach}}
	      </select>
	      
	      <select name="function_id" onchange="this.form.praticien_id.value=''; refreshListProtocole(this.form)">
          <option value="">&mdash; Choix du cabinet</option>
          {{foreach from=$functions item=_function}}
          <option class="mediuser" style="border-color: #{{$_function->color}}" value="{{$_function->_id}}" 
          {{if $_function->_id == $prescription->function_id}}selected=selected{{/if}}>{{$_function->_view}}</option>
          {{/foreach}}
        </select>
      </form>
        
      {{else}}
        Prescription du Dr. {{$prescription->_ref_praticien->_view}}<br />
        {{$prescription->_ref_object->_view}}
        {{if $prescription->_ref_patient->_age}}
           ({{$prescription->_ref_patient->_age}} ans - {{$prescription->_ref_patient->naissance|date_format:"%d/%m/%Y"}}{{if $poids}} - {{$poids}} kg{{/if}})
        {{/if}}
      {{/if}}

    </th>
  </tr>
  <tr>
  <td>

  

   <!-- Impression de la prescription -->
   <button type="button" class="print" onclick="Prescription.printPrescription('{{$prescription->_id}}')" style="float: left">
     Prescription
   </button>
   
   
   
   {{if !$mode_protocole}}
   {{if $prescription->type != "sortie" && $prescription->type != "externe"}}
   <!-- Impression de la prescription -->
   <button type="button" class="print" onclick="Prescription.printPrescription('{{$prescription->_id}}','ordonnance')" style="float: left">
     Ordonnance
   </button>
   {{/if}}
   
   <!-- Affichage du recapitulatif des alertes -->
   <button type="button" class="search" onclick="Prescription.viewFullAlertes('{{$prescription->_id}}')" style="float: left">
     Alertes
   </button>
   

       {{assign var=antecedents value=$prescription->_ref_object->_ref_patient->_ref_dossier_medical->_ref_antecedents}}
		   <!-- Si le dossier medical poss�de des antecedents -->
		   {{if $antecedents}}
		   
		     <!-- Affichage des allergies -->
			   {{if array_key_exists('alle', $antecedents)}}
			     {{assign var=allergies value=$antecedents.alle}}
			      <img src="images/icons/warning.png" title="Allergies" alt="Allergies" 
			           onmouseover="$('allergies{{$prescription->_id}}').show();"
			           onmouseout="$('allergies{{$prescription->_id}}').hide();" />
			    
			      <div id="allergies{{$prescription->_id}}" class="tooltip" style="display: none; background-color: #ddd; border-style: ridge; padding:3px; left: 174px; top: 110px;">
			        <strong>Allergies</strong>
			        <ul>
				        {{foreach from=$allergies item=allergie}}
				        <li>
						      {{if $allergie->date}}
						 	      {{$allergie->date|date_format:"%d/%m/%Y"}}:
							    {{/if}} 
				  		  	{{$allergie->rques}}
				  	    </li>
				  	    {{/foreach}}
					    </ul>   
			      </div>   
			   {{/if}}
		   
			   <!-- Affichage des autres antecedents -->
		     {{if (array_key_exists('alle', $antecedents) && $antecedents|@count > 1) || ($antecedents|@count >= 1 && !array_key_exists('alle', $antecedents))}}
		      <img src="images/icons/antecedents.gif" title="Ant�c�dents" alt="Ant�c�dents" 
			           onmouseover="$('antecedents{{$prescription->_id}}').show();"
			           onmouseout="$('antecedents{{$prescription->_id}}').hide();" />
			     
			      <div id="antecedents{{$prescription->_id}}" class="tooltip" style="display: none; background-color: #ddd; border-style: ridge; padding:3px; left: 174px; top: 110px;">
			        <ul>
				        {{foreach from=$antecedents key=name item=cat}}
				        {{if $name != "alle"}}
				        <li>
				        <strong>{{tr}}CAntecedent.type.{{$name}}{{/tr}}</strong>
				        <ul>
				        {{foreach from=$cat item=ant}}
				        <li>
						      {{if $ant->date}}
						 	      {{$ant->date|date_format:"%d/%m/%Y"}}:
							    {{/if}} 
				  		  	{{$ant->rques}}
				  	    </li>
				  	    {{/foreach}}
				  	    </ul>
				  	    </li>
				  	    {{/if}}
				  	    {{/foreach}}
					    </ul>   
			      </div>  
		     {{/if}}
	
	   {{/if}} 
   {{/if}}
   </td>
   
       
  {{if !$mode_protocole && !$mode_pharma}}
   <td style="text-align: right;">
      
      <!-- Formulaire de selection protocole -->
      <form name="applyProtocole" method="post" action="?">
	      <table class="form">
	        <tr>
		        <td>
			        Protocoles de {{$prescription->_ref_current_praticien->_view}}
			        <input type="hidden" name="m" value="dPprescription" />
			        <input type="hidden" name="dosql" value="do_apply_protocole_aed" />
			        <input type="hidden" name="del" value="0" />
			        <input type="hidden" name="prescription_id" value="{{$prescription->_id}}" />
			        <input type="hidden" name="praticien_id" value="{{$app->user_id}}" />
			        <select name="protocole_id">
			          <option value="">&mdash; S�lection d'un protocole</option>
			          {{if $protocoles_praticien|@count}}
			          <optgroup label="Praticien">
			          {{foreach from=$protocoles_praticien item=_protocole_praticien}}
			          <option value="{{$_protocole_praticien->_id}}">{{$_protocole_praticien->_view}}</option>
			          {{/foreach}}
			          </optgroup>
			          {{/if}}
			          {{if $protocoles_function|@count}}
			          <optgroup label="Cabinet">
			          {{foreach from=$protocoles_function item=_protocole_function}}
			          <option value="{{$_protocole_function->_id}}">{{$_protocole_function->_view}}</option>
			          {{/foreach}}
			          </optgroup>
			          {{/if}}
			        </select>
			        </td>
			        <td class="date">
				 				{{if $prescription->type != "externe"}}
				 				  <select name="debut_date" 
				 				          onchange="$('applyProtocole_debut_da').innerHTML = new String;
				 				                    this.form.debut.value = '';
				 				          				  if(this.value == 'other') { 
				 				          					  $('calendarProt').show();
				 				          				  } else { 
				 				          				    
				 				          				    this.form.debut.value = this.value;
				 				          				    $('calendarProt').hide();
				 				          				  }">
     				  
				 				    <option value="other">Autre date</option>
				 				    <optgroup label="S�jour">
				 				      <option value="{{$prescription->_ref_object->_entree|date_format:'%Y-%m-%d'}}">Entr�e: {{$prescription->_ref_object->_entree|date_format:"%d/%m/%Y"}}</option>
				 				      <option value="{{$prescription->_ref_object->_sortie|date_format:'%Y-%m-%d'}}">Sortie: {{$prescription->_ref_object->_sortie|date_format:"%d/%m/%Y"}}</option>
				 				    </optgroup>
				 				    <optgroup label="Op�ration">
				 				    {{foreach from=$prescription->_ref_object->_dates_operations item=_date_operation}}
				 				      <option value="{{$_date_operation}}">{{$_date_operation|date_format:"%d/%m/%Y"}}</option>
				 				    {{/foreach}}
 										</optgroup>
 										
				 				    
				 				  </select>
				 				
				 				  <!-- Prescription externe -->
				 				  <div id="calendarProt" style="border:none;">
									{{mb_field object=$protocole_line field="debut" form=applyProtocole}}       
					 				<script type="text/javascript">
					 				  dates = {
									    current: {
									      start: "{{$today}}",
									      stop: ""
									    }
									  }
					 				  Main.add( function(){
					            Calendar.regField('applyProtocole', "debut", false, dates);
					          } );
					 				</script>
				 				  </div>
				 				  
				 				{{else}}
				 				  <!-- Prescription externe -->
									{{mb_field object=$protocole_line field="debut" form=applyProtocole}}       
					 				<script type="text/javascript">
					 				  dates = {
									    current: {
									      start: "{{$today}}",
									      stop: ""
									    }
									  }
					 				  Main.add( function(){
					            Calendar.regField('applyProtocole', "debut", false, dates);
					          } );
					 				</script>				 				
				 				{{/if}}
			 				
			          <button type="button" class="submit" onclick="submitProtocole(this.form);">Appliquer</button>
		        </td>
	        </tr>
	      </table>
      </form>
    </td>  
  {{/if}}
  
  </tr>  

    
</table>