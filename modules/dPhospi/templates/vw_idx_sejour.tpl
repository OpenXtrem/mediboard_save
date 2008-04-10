{{mb_include_script module="dPcompteRendu" script="document"}}
{{mb_include_script module="dPplanningOp" script="cim10_selector"}}


{{assign var="do_subject_aed" value="do_sejour_aed"}}
{{assign var="module" value="dPhospi"}}
{{include file="../../dPsalleOp/templates/js_gestion_ccam.tpl"}}

<script language="Javascript" type="text/javascript">
     
function loadActesNGAP(sejour_id){
  var url = new Url;
  url.setModuleAction("dPcabinet", "httpreq_vw_actes_ngap");
  url.addParam("object_id", sejour_id);
  url.addParam("object_class", "CSejour");
  url.requestUpdate('listActesNGAP', { waitingText: null } );
}

Document.refreshList = function(sejour_id){
  var url = new Url;
  url.setModuleAction("dPhospi", "httpreq_vw_documents");
  url.addParam("sejour_id" , sejour_id);
  url.requestUpdate('documents', { waitingText: null } );
}

function loadSejour(sejour_id) {
  url_sejour = new Url;
  url_sejour.setModuleAction("system", "httpreq_vw_complete_object");
  url_sejour.addParam("object_class","CSejour");
  url_sejour.addParam("object_id",sejour_id);
  url_sejour.requestUpdate('viewSejourHospi', {
  waitingText: null,
	onComplete: initPuces
  } );
}

function popEtatSejour(sejour_id) {
  var url = new Url;
  url.setModuleAction("dPhospi", "vw_parcours");
  url.addParam("sejour_id",sejour_id);
  url.pop(1000, 550, 'Etat du S�jour');
}

function reloadDiagnostic(sejour_id, modeDAS) {
  var url = new Url();
  url.setModuleAction("dPsalleOp", "httpreq_diagnostic_principal");
  url.addParam("sejour_id", sejour_id);
  url.addParam("modeDAS", modeDAS);
  url.requestUpdate("cim", { 	waitingText : null } );
}


function loadViewSejour(sejour_id, praticien_id){
  loadSejour(sejour_id); 
  Document.refreshList(sejour_id); 
  if($('listActesNGAP')){
    loadActesNGAP(sejour_id);
  }
  if($('ccam')){
    ActesCCAM.refreshList(sejour_id, praticien_id);
  }
  if($('cim')){
    reloadDiagnostic(sejour_id, '1');    
  }
}

Main.add(function () {
  regRedirectPopupCal("{{$date}}", "?m={{$m}}&tab={{$tab}}&date=");

  {{if $object->_id}}
    loadViewSejour({{$object->_id}});
  {{/if}}

  /* Tab initialization */
  var tab_sejour = Control.Tabs.create('tab-sejour');
  
  {{if $app->user_prefs.ccam_sejour == 1 }}
  var tab_actes = new Control.Tabs('tab-actes');
  {{/if}}
});
</script>

<table class="main">
  <tr>
    <td style="width:200px;" rowspan="3">
      <table>
        <tr>
          <th>
            {{$date|date_format:"%A %d %B %Y"}}
            <img id="changeDate" src="./images/icons/calendar.gif" title="Choisir la date" alt="calendar" />
          </th>
        </tr>
        <tr>
          {{include file="inc_mode_hospi.tpl"}}
        </tr>
        <tr>
          <td>
            <form name="selService" action="?m={{$m}}" method="get">
              <label for="service_id">Service</label>
              <input type="hidden" name="m" value="{{$m}}" />
              <select name="service_id" onChange="submit()">
                <option value="">&mdash; Choix d'un service</option>
                {{foreach from=$services item=curr_service}}
                <option value="{{$curr_service->_id}}" {{if $curr_service->_id == $service->_id}} selected="selected" {{/if}}>{{$curr_service->nom}}</option>
                {{/foreach}}
                <option value="NP" {{if $service_id == "NP"}} selected="selected" {{/if}}>Non plac�s</option>
              </select>
            </form>
          </td>
        </tr>
        <tr>
          <td>
            {{if $service->_id}}
            <table class="tbl">
            {{foreach from=$service->_ref_chambres item=curr_chambre}}
            
            {{foreach from=$curr_chambre->_ref_lits item=curr_lit}}
            <tr>
              <th class="category" colspan="5">
                {{$curr_chambre->_view}} - {{$curr_lit->_view}}
              </th> 
                {{foreach from=$curr_lit->_ref_affectations item=curr_affectation}}
              
              {{if $curr_affectation->_ref_sejour->_id != ""}}
              <tr>
              <td>
              <a href="#1" onclick="popEtatSejour({{$curr_affectation->_ref_sejour->_id}});">
                <img src="images/icons/jumelle.png" alt="edit" title="Etat du S�jour" />
              </a>
              </td>
              <td>
              <a href="#1" onclick="loadViewSejour({{$curr_affectation->_ref_sejour->_id}}, {{$curr_affectation->_ref_sejour->praticien_id}});">
                {{$curr_affectation->_ref_sejour->_ref_patient->_view}}
              </a>
              </td>
              <td>
                <a style="float: right;" href="?m=dPpatients&amp;tab=vw_edit_patients&amp;patient_id={{$curr_affectation->_ref_sejour->_ref_patient->_id}}">
                  <img src="images/icons/edit.png" alt="edit" title="Editer le patient" />
                </a>
                </td>
                <td>
                <a style="float: right;" href="{{$curr_affectation->_ref_sejour->_ref_patient->_dossier_cabinet_url}}&amp;patient_id={{$curr_affectation->_ref_sejour->_ref_patient->_id}}">
                  <img src="images/icons/search.png" alt="view" title="Afficher le dossier complet" />
                </a>                             
              </td>
              <td class="action" style="background:#{{$curr_affectation->_ref_sejour->_ref_praticien->_ref_function->color}}">
              {{$curr_affectation->_ref_sejour->_ref_praticien->_shortview}}
              </td>
            </tr>
            {{/if}}
            {{/foreach}}
            
            {{/foreach}}
            
            {{/foreach}}
            </table>
            {{elseif $service_id == "NP"}}
            {{foreach from=$groupSejourNonAffectes key=group_name item=sejourNonAffectes}}
            <table class="tbl">
              <tr>
                <th class="title" colspan="5">
                  {{tr}}CSejour.groupe.{{$group_name}}{{/tr}}
                </th>
              </tr>
              {{foreach from=$sejourNonAffectes item=curr_sejour}}
              
              {{if $curr_sejour->_id != ""}}
              <tr>
	              <td>
	              <a href="#1" onclick="popEtatSejour({{$curr_sejour->_id}});">
	                <img src="images/icons/jumelle.png" alt="edit" title="Etat du S�jour" />
	              </a>
	              </td>
	              <td>
	              <a href="#1" onclick="loadViewSejour({{$curr_sejour->_id}},{{$curr_sejour->praticien_id}})">
	                {{$curr_sejour->_ref_patient->_view}}
	              </a>
	              </td>
	              <td>
	                <a style="float: right;" href="?m=dPpatients&amp;tab=vw_edit_patients&amp;patient_id={{$curr_sejour->_ref_patient->_id}}">
	                  <img src="images/icons/edit.png" alt="edit" title="Editer le patient" />
	                </a>
	                </td>
	                <td>
	                <a style="float: right;" href="{{$curr_sejour->_ref_patient->_dossier_cabinet_url}}&amp;patient_id={{$curr_sejour->_ref_patient->_id}}">
	                  <img src="images/icons/search.png" alt="view" title="Afficher le dossier complet" />
	                </a>                             
	              </td>
	              <td class="action" style="background:#{{$curr_sejour->_ref_praticien->_ref_function->color}}">
	              {{$curr_sejour->_ref_praticien->_shortview}}
	              </td>
              </tr>
              {{/if}}
              {{/foreach}}
            </table>
            {{/foreach}}
            {{/if}}
          </td>
        </tr>
      </table>
    </td>
    <td>
    
      <!-- Tab titles -->
      <ul id="tab-sejour" class="control_tabs">
        <li><a href="#viewSejourHospi">S�jour</a></li>
        
        {{if $app->user_prefs.ccam_sejour == 1 }}
          <li><a href="#Actes">Gestion des actes</a></li>
        {{/if}}
    
        <li><a href="#documents">Documents</a></li>
      </ul>
      <hr class="control_tabs" />
      
      
      <!-- Tabs -->
      <div id="viewSejourHospi" style="display: none;"></div>
      
      {{if $app->user_prefs.ccam_sejour == 1 }}
      <div id="Actes" style="display: none;">
        <ul id="tab-actes" class="control_tabs">
          <li><a href="#one">Actes CCAM</a></li>
          <li><a href="#two">Actes NGAP</a></li>
          <li><a href="#three">Diagnostics</a></li>
        </ul>
        <hr class="control_tabs" />
        
        <table class="form">
          <tr id="one">
            <td id="ccam"></td>
          </tr>
          <tr id="two">
            <td id="listActesNGAP"></td>
          </tr>
          <tr id="three">
            <td id="cim"></td>
          </tr>
        </table>
      </div>
      {{/if}}
      
      <div id="documents" style="display: none;"></div>
    </td>
  </tr>
</table>
