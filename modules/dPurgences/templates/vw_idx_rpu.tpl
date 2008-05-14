<script type="text/javascript">

function showLegend() {
  url = new Url;
  url.setModuleAction("dPurgences", "vw_legende");
  url.popup(300, 320, "Legende");
}

// Fonction de refresh du temps d'attente
function updateAttente(sejour_id){
  var url = new Url;
  url.setModuleAction("dPurgences", "httpreq_vw_attente");
  url.addParam("sejour_id", sejour_id);
  url.periodicalUpdate('attente-'+sejour_id, { frequency: 60, waitingText: null });
}
 
function printMainCourante() {
  var url = new Url;
  url.setModuleAction("dPurgences", "print_main_courante");
  url.addParam("date", "{{$date}}");
  url.popup(800, 600, "Impression main courante");
}



function pageMain() {
  regRedirectPopupCal("{{$date}}", "?m={{$m}}&tab={{$tab}}&date=");
}


</script>

<table style="width:100%">
  <tr>
    <td>
      <a class="buttonnew" href="?m=dPurgences&amp;tab=vw_aed_rpu&amp;rpu_id=0">
        Ajouter un patient
      </a> 
    </td>
    <th>
     le
     {{$date|date_format:"%A %d %B %Y"}}
     <img id="changeDate" src="./images/icons/calendar.gif" title="Choisir la date" alt="calendar" />
    </th>
    <td style="text-align: right">
     Type d'affichage
     <form name="selView" action="?m=dPurgences&amp;tab=vw_idx_rpu" method="post">
	      <select name="selAffichage" onchange="submit();">
	        <option value="tous" {{if $selAffichage == "tous"}}selected = "selected"{{/if}}>Tous</option>
	        <option value="presents" {{if $selAffichage == "presents"}} selected = "selected" {{/if}}>Pr�sents</option>
	        <option value="prendre_en_charge" {{if $selAffichage == "prendre_en_charge"}} selected = "selected" {{/if}}>A prendre en charge</option>
	      </select>
	    </form>
      <a href="#" onclick="printMainCourante()" class="buttonprint">Main courante</a>
      <a href="#" onclick="showLegend()" class="buttonsearch">L�gende</a>
    </td>
  </tr>
</table>

<table class="tbl">
  <tr>
    <th>{{mb_colonne class=CRPU field="ccmu" order_col=$order_col order_way=$order_way url="?m=$m&amp;tab=vw_idx_rpu"}}</th>
    <th>{{mb_colonne class=CRPU field="_patient_id" order_col=$order_col order_way=$order_way url="?m=$m&amp;tab=vw_idx_rpu"}}</th>
    <th>{{mb_colonne class=CRPU field="_entree" order_col=$order_col order_way=$order_way url="?m=$m&amp;tab=vw_idx_rpu"}}</th>
    <th>{{mb_title class=CRPU field=_attente}} / {{mb_title class=CRPU field=_presence}}</th>
    <th>{{tr}}CRPU-_responsable_id{{/tr}}</th>
    {{if $medicalView}}
    <th>{{tr}}CRPU-diag_infirmier{{/tr}}</th>
    {{/if}}
    <th>Prise en charge</th>
  </tr>
  {{foreach from=$listSejours item=curr_sejour key=sejour_id}}
  {{assign var=rpu value=$curr_sejour->_ref_rpu}}
  {{assign var=patient value=$curr_sejour->_ref_patient}}
  {{assign var=consult value=$rpu->_ref_consult}}
  {{mb_ternary var=background test=$consult->_id value=#cfc other=none}}
  
  <tr>
  	{{if $curr_sejour->annule}}
    <td class="cancelled">
      {{tr}}Cancelled{{/tr}}
    </td>
	  {{else}}

    <td class="ccmu-{{$rpu->ccmu}}">
      <a href="?m=dPurgences&amp;tab=vw_aed_rpu&amp;rpu_id={{$rpu->_id}}">
        {{if $rpu->ccmu}}
          {{tr}}CRPU.ccmu.{{$rpu->ccmu}}{{/tr}}
        {{/if}}
      </a>
      {{if $rpu->box_id}}

      {{assign var=rpu_box_id value=$rpu->box_id}}
      <strong>{{$boxes.$rpu_box_id->_view}}</strong>
      {{/if}}
    </td>
    {{/if}}

  	{{if $curr_sejour->annule}}
  	<td class="cancelled">
	  {{else}}
    <td class="text" style="background-color: {{$background}};">
    {{/if}}
      <a style="float: right;" title="Voir le dossier" href="?m=dPpatients&amp;tab=vw_full_patients&amp;patient_id={{$patient->_id}}&amp;sejour_id={{$sejour_id}}">
        <img src="images/icons/search.png" alt="Dossier patient"/>
      </a>
      <a href="?m=dPurgences&amp;tab=vw_aed_rpu&amp;rpu_id={{$rpu->_id}}">
        <strong>
        {{$patient->_view}}
        </strong>
        {{if $patient->_IPP}}
        <br />[{{$patient->_IPP}}]
        {{/if}}
      </a>
    </td>

  	{{if $curr_sejour->annule}}
    <td class="cancelled"colspan="5">
      {{if $rpu->mutation_sejour_id}}
      Hospitalisation
      <a href="?m=dPplanningOp&tab=vw_edit_sejour&sejour_id={{$rpu->mutation_sejour_id}}">
        dossier [{{$rpu->_ref_sejour_mutation->_num_dossier}}]
     	</a> 
      {{else}}
      {{tr}}Cancelled{{/tr}}
      {{/if}}
    </td>
	  {{else}}
    <td class="text" style="background-color: {{$background}};">
      {{if $can->edit}}
      <a style="float: right" title="Modifier le s�jour" href="?m=dPplanningOp&amp;tab=vw_edit_sejour&amp;sejour_id={{$sejour_id}}">
        <img src="images/icons/planning.png" alt="Planifier"/>
      </a>
      {{/if}}

      <a href="?m=dPurgences&amp;tab=vw_aed_rpu&amp;rpu_id={{$rpu->_id}}">
        {{if $curr_sejour->_date_entree_prevue == $date}}
        {{$curr_sejour->_entree|date_format:"%Hh%M"}}
        {{else}}
        {{$curr_sejour->_entree|date_format:"%d/%m/%Y � %Hh%M"}}
        {{/if}}
        {{if $curr_sejour->_num_dossier}}
          [{{$curr_sejour->_num_dossier}}]
        {{/if}}
      </a>
      {{if $rpu->radio_debut && !$rpu->radio_fin}}
      <strong>En radiologie</strong>
      {{/if}}
      {{if $rpu->radio_debut && $rpu->radio_fin}}
      <strong>Retour de radiologie</strong>
      {{/if}}
      
    </td>
    
	  <td id="attente-{{$sejour_id}}" style="background-color: {{$background}}; text-align: center">
	    {{if $consult->_id}}
	    <a href="?m=dPurgences&amp;tab=edit_consultation&amp;selConsult={{$consult->_id}}">
	      Consultation � {{$consult->heure|date_format:"%Hh%M"}}
	      {{if $date != $consult->_ref_plageconsult->date}}
	      <br/>le {{$consult->_ref_plageconsult->date|date_format:"%d/%m/%Y"}}
	      {{/if}}
	    </a>
	    {{if !$curr_sejour->sortie_reelle}}
	      ({{mb_value object=$rpu field=_attente}} / {{mb_value object=$rpu field=_presence}})
	    {{else}}
	      (sortie � {{$curr_sejour->sortie_reelle|date_format:"%Hh%M"}})
	    {{/if}}
	
	    {{else}}
      <!-- Affichage du temps d'attente de chaque patient -->
      {{mb_value object=$rpu field=_attente}}
      <script type="text/javascript">
        updateAttente("{{$sejour_id}}");
      </script>
      {{/if}}
    </td>
    
    <td class="text" style="background-color: {{$background}};">
      <a href="?m=dPurgences&amp;tab=vw_aed_rpu&amp;rpu_id={{$rpu->_id}}">
        {{$curr_sejour->_ref_praticien->_view}}
      </a>
    </td>

    {{if $medicalView}}
    <td class="text" style="background-color: {{$background}};">
      <a href="?m=dPurgences&amp;tab=vw_aed_rpu&amp;rpu_id={{$rpu->_id}}">
        {{$rpu->diag_infirmier|nl2br}}
      </a>
    </td>
    {{/if}}

    <td class="button" style="background-color: {{$background}};">
		  {{include file="inc_pec_praticien.tpl"}}
    </td>
    {{/if}}
  </tr>
  
  
  {{/foreach}}
</table>
