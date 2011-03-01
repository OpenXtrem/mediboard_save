{{mb_include_script module="dPplanningOp" script="protocole_selector"}}

<script type="text/javascript">
ProtocoleSelector.init = function(){
  this.sForSejour      = true;
  this.sForm           = "editSejour";
  this.sChir_id        = "praticien_id";
  this.sServiceId      = "service_id";
  this.sDP             = "DP";
  this.sDepassement    = "depassement";
  
  this.sLibelle_sejour = "libelle";
  this.sType           = "type";
  this.sDuree_prevu    = "_duree_prevue";
  this.sConvalescence  = "convalescence";
  this.sRques_sej      = "rques";

  this.sProtoPrescAnesth = "_protocole_prescription_anesth_id";
  this.sProtoPrescChir   = "_protocole_prescription_chir_id";
  
  this.pop();
}

function toggleMode() {
  var trigger = $("modeExpert-trigger"),
      hiddenElements = $$(".modeExpert"),
      expert = !hiddenElements[0].visible();
  
  trigger.update(expert ? '{{tr}}button-COperation-modeExpert{{/tr}}' : '{{tr}}button-COperation-modeEasy{{/tr}}');
  hiddenElements.invoke("setVisible", expert);
}

window.refreshingSejours = false;

function reloadSejours(checkCollision) {
	var oForm = getForm("editSejour");
	var patient_id = $V(oForm.patient_id);

	if (!patient_id) {
    return;
	}
		
  // Changer l'entr�e pr�vue d'un s�jour change �galement la sortie pr�vue,
  // il faut donc �viter de lancer deux fois cette fonction.
  if (window.refreshingSejours) {
	  return;
  }
  window.refreshingSejours = true;
  var url = new Url("dPplanningOp", "ajax_list_sejours");
  url.addParam("check_collision", checkCollision);
  url.addParam("patient_id", patient_id);

  // Dans le cas o� on va checker la collision
  // On envoie �galement l'entr�e pr�vue et la sortie pr�vue
  if (checkCollision) {
    url.addParam("date_entree_prevue", $V(oForm._date_entree_prevue));
    url.addParam("date_sortie_prevue", $V(oForm._date_sortie_prevue));
    url.addParam("hour_entree_prevue", $V(oForm._hour_entree_prevue));
    url.addParam("hour_sortie_prevue", $V(oForm._hour_sortie_prevue));
    url.addParam("min_entree_prevue" , $V(oForm._min_entree_prevue));
    url.addParam("min_sortie_prevue" , $V(oForm._min_sortie_prevue));
    url.addParam("sejour_id"         , $V(oForm.sejour_id));
  }
  url.requestUpdate("list_sejours", {onComplete: function() { window.refreshingSejours = false; }});
}

{{if $app->user_prefs.mode_dhe == 0}}
  Main.add(toggleMode);
{{/if}}
</script> 

<table class="main">

  {{if $sejour->_id}}
  <tr>
    <td>
      <a class="button new" href="?m={{$m}}&amp;tab={{$tab}}&amp;sejour_id=0">
        {{tr}}CSejour.create{{/tr}}
      </a>
    </td>
    <td>
      <a class="button new" href="?m={{$m}}&amp;tab=vw_edit_planning&amp;operation_id=0&amp;sejour_id={{$sejour->_id}}">
        Programmer une nouvelle intervention dans ce s�jour
      </a>
    </td>
  </tr>
  {{/if}}

  <tr>
    {{if $sejour->_id}}
    <th colspan="2" class="title modify">
      {{mb_include module=system template=inc_object_idsante400 object=$sejour}}
      {{mb_include module=system template=inc_object_history    object=$sejour}}
      {{mb_include module=system template=inc_object_notes      object=$sejour}}
      
      <button type="button" class="search" style="float: left;" onclick="ProtocoleSelector.init()">
        {{tr}}button-COperation-choixProtocole{{/tr}}
      </button>
      
      <button type="button" class="hslip" style="float: right;" onclick="toggleMode(this)" id="modeExpert-trigger">
        {{tr}}button-COperation-modeExpert{{/tr}}
      </button>
      
      Modification du s�jour {{$sejour->_view}} {{mb_include module=dPplanningOp template=inc_vw_numdos num_dossier=$sejour->_num_dossier}}
    </th>
    {{else}}
    <th colspan="2" class="title">
      <button type="button" class="search" style="float: left;" onclick="ProtocoleSelector.init()">
        {{tr}}button-COperation-choixProtocole{{/tr}}
      </button>
      
      <button type="button" class="hslip" style="float: right;" onclick="toggleMode(this)" id="modeExpert-trigger">
        {{tr}}button-COperation-modeExpert{{/tr}}
      </button>
      Cr�ation d'un nouveau s�jour
    </th>
    {{/if}}
  </tr>
  
  <tr>
    <td style="width: 60%">
      {{include file="js_form_sejour.tpl"}}
      {{include file="inc_form_sejour.tpl" mode_operation=false}}
    </td>
    <td>
      {{include file="inc_infos_operation.tpl"}}
      {{include file="inc_infos_hospitalisation.tpl"}}
      <table class="form" style="width: 100%;">
        <tr>
          <th class="title">{{tr}}CSejour-existants{{/tr}}</th>
        </tr>
        <tr>
          <td id="list_sejours">
            {{include file="inc_list_sejours.tpl"}}
          </td>
        </tr>

        {{if $sejour->_id}} 
        <tr>
          <th class="title">
          	{{tr}}CMbObject-back-documents{{/tr}}
					</th>
        </tr>
        <tr>
          <td id="documents">
            {{mb_include_script module=dPcompteRendu script=document}}
            {{mb_include_script module=dPcompteRendu script=modele_selector}}
				    <script type="text/javascript">
				    Document.register('{{$sejour->_id}}','{{$sejour->_class_name}}','{{$sejour->praticien_id}}', 'documents');
				    </script>
          </td>
        </tr>

        <tr>
          <th class="title">
          	{{tr}}CMbObject-back-files{{/tr}}
					</th>
        </tr>
        <tr>
          <td id="files">
            {{mb_include_script module=dPcabinet script=file}}
            <script type="text/javascript">
            File.register('{{$sejour->_id}}','{{$sejour->_class_name}}', 'files');
            </script>
            {{mb_include module=dPfiles template=yoplet_uploader object=$sejour}}
          </td>
        </tr>
        {{/if}}

      </table>
    </td>
  </tr>

</table>