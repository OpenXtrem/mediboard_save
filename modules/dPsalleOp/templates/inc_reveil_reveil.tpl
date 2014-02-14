<script>
  Main.add(function () {    
    Control.Tabs.setTabCount("reveil", "{{$listOperations|@count}}");
    
    {{if $isImedsInstalled}}
      ImedsResultsWatcher.loadResults();
    {{/if}}
  });

  submitReveilForm = function(oFormOperation) {
    submitFormAjax(oFormOperation,'systemMsg', {onComplete: function(){refreshTabsReveil()}});
  }
</script>

{{assign var=use_poste value=$conf.dPplanningOp.COperation.use_poste}}
{{assign var=use_sortie_reveil_reel value="dPsalleOp COperation use_sortie_reveil_reel"|conf:"CGroups-$g"}}

<table class="tbl">
  <tr>
    <th>{{tr}}SSPI.Salle{{/tr}}</th>
    <th>{{tr}}SSPI.Praticien{{/tr}}</th>
    <th>{{tr}}SSPI.Patient{{/tr}}</th>
    <th class="narrow"></th>
    {{if $use_poste}}
      <th>{{tr}}SSPI.Poste{{/tr}}</th>
    {{/if}}
    <th>{{tr}}SSPI.Chambre{{/tr}}</th>    
    {{if $isbloodSalvageInstalled}}
      <th>{{tr}}SSPI.RSPO{{/tr}}</th>
    {{/if}}
    {{if $personnels !== null}}
    <th>{{tr}}SSPI.SortieSalle{{/tr}}</th>
    {{/if}}
    <th>{{tr}}SSPI.Responsable{{/tr}}</th>
    <th>{{tr}}SSPI.EntreeReveil{{/tr}}</th>
    {{if @$modules.brancardage->_can->read}}
      <th>{{tr}}CBrancardage{{/tr}}</th>
    {{/if}}
    {{if $use_sortie_reveil_reel}}
      <th>{{tr}}SSPI.SortieReveilPossible{{/tr}}</th>
      <th style="width: 15%">{{tr}}SSPI.SortieReveilReel{{/tr}}</th>
    {{else}}
      <th>{{tr}}SSPI.SortieReveil{{/tr}}</th>
    {{/if}}
    <th class="narrow"></th>
  </tr>    
  {{foreach from=$listOperations key=key item=_operation}}
    {{assign var=_operation_id value=$_operation->_id}}
  <tr>
    <td>{{$_operation->_ref_salle->_shortview}}</td>
    <td class="text">
      {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$_operation->_ref_chir}}
    </td>
    <td class="text">
      <div style="float: right;">
        {{if $isImedsInstalled}}
          {{mb_include module=Imeds template=inc_sejour_labo link="#1" sejour=$_operation->_ref_sejour float="none"}}
        {{/if}}
      </div>

        <span class="{{if !$_operation->_ref_sejour->entree_reelle}}patient-not-arrived{{/if}} {{if $_operation->_ref_sejour->septique}}septique{{/if}}"
            onmouseover="ObjectTooltip.createEx(this, '{{$_operation->_ref_sejour->_ref_patient->_guid}}')">
        {{$_operation->_ref_patient->_view}}
        </span>
    </td>
    <td>
      <button class="soins button notext" onclick="showDossierSoins('{{$_operation->sejour_id}}','{{$_operation->_id}}');">Dossier de soins</button>
      <button class="edit notext button" onclick="codageCCAM('{{$_operation->_id}}');">Codage</button>
      <button type="button" class="injection notext" onclick="Operation.dossierBloc('{{$_operation->_id}}', true)">Dossier de bloc</button>
    </td>
    {{if $use_poste}}
      <td>
        {{mb_include module=dPsalleOp template=inc_form_toggle_poste_sspi type="reveil"}}
      </td>
    {{/if}}
    <td class="text">
      {{mb_include module=hospi template=inc_placement_sejour sejour=$_operation->_ref_sejour}}
    </td>
    {{if $isbloodSalvageInstalled}}
      {{assign var=salvage value=$_operation->_ref_blood_salvage}}
      <td>
        {{if $salvage->_id}}
        <div style="float:left ; display:inline">
          <a href="#" title="Voir la proc�dure RSPO" onclick="viewRSPO({{$_operation->_id}});">         
          <img src="images/icons/search.png" title="Voir la proc�dure RSPO" alt="vw_rspo" />
          {{if $salvage->_totaltime > "00:00:00"}}
           D�but� � {{$salvage->_recuperation_start|date_format:$conf.time}}
          {{else}}
            Non d�but�
          {{/if}} 
        </a>
        </div>
        {{if $salvage->_totaltime|date_format:$conf.time > "05:00"}}
        <div style="float:right; display:inline">
        
        <img src="images/icons/warning.png" title="Dur�e l�gale bient�t atteinte !" alt="alerte-dur�e-RSPO">
        {{/if}}
        </div>
        {{else}} 
          Non inscrit
        {{/if}}
      </td>
    {{/if}}
    <td>
      {{mb_value object=$_operation field="sortie_salle"}}
    </td>
    {{if $personnels !== null}}
    <td>
      <form name="selPersonnel{{$_operation->_id}}" action="?m={{$m}}" method="post">
        <input type="hidden" name="m" value="dPpersonnel" />
        <input type="hidden" name="dosql" value="do_affectation_aed" />
        <input type="hidden" name="del" value="0" />
        <input type="hidden" name="object_id" value="{{$_operation->_id}}" />
        <input type="hidden" name="object_class" value="{{$_operation->_class}}" />
        <input type="hidden" name="tag" value="reveil" />
        <input type="hidden" name="realise" value="0" />
        <select name="personnel_id" style="max-width: 120px;">
        <option value="">&mdash; Personnel</option>
        {{foreach from=$personnels item="personnel"}}
        <option value="{{$personnel->_id}}">{{$personnel->_ref_user->_view}}</option>
        {{/foreach}}
        </select>
        <button type="button" class="add notext" onclick="submitFormAjax(this.form, 'systemMsg', {onComplete: function() { refreshTabsReveil(); }})">
          {{tr}}Add{{/tr}}
        </button>
      </form>
      {{foreach from=$_operation->_ref_affectations_personnel.reveil item=curr_affectation}}
        <br />
        <form name="delPersonnel{{$curr_affectation->_id}}" action="?m={{$m}}" method="post">
          <input type="hidden" name="m" value="dPpersonnel" />
          <input type="hidden" name="dosql" value="do_affectation_aed" />
          <input type="hidden" name="del" value="1" />
          <input type="hidden" name="affect_id" value="{{$curr_affectation->_id}}" />
          <button type="button" class="trash notext" onclick="submitFormAjax(this.form, 'systemMsg', {onComplete: function() { refreshTabsReveil(); }})">
            {{tr}}Delete{{/tr}}
          </button>
        </form>
        {{$curr_affectation->_ref_personnel->_ref_user->_view}}
      {{/foreach}}
    </td>
    {{/if}}
    <td>
      <form name="editEntreeReveilReveilFrm{{$_operation->_id}}" action="?m={{$m}}" method="post">
        <input type="hidden" name="m" value="planningOp" />
        <input type="hidden" name="dosql" value="do_planning_aed" />
        <input type="hidden" name="operation_id" value="{{$_operation->_id}}" />
        <input type="hidden" name="del" value="0" />
        {{if $_operation->_ref_sejour->type=="exte"}}
        -
        {{elseif $modif_operation && !$_operation->sortie_reveil_possible}}
          {{mb_field object=$_operation field="entree_reveil" form="editEntreeReveilReveilFrm$_operation_id" onchange="submitReveilForm(this.form);"}}
        {{else}}
          {{mb_value object=$_operation field="entree_reveil"}}
        {{/if}}
      </form>
    </td>
    {{if @$modules.brancardage->_can->read}}
    <td>
       <span id="demandebrancard-{{$_operation->sejour_id}}">
         {{mb_include module=brancardage template=inc_exist_brancard brancardage=$_operation->_ref_brancardage id="demandebrancard"
           sejour_id=$_operation->sejour_id salle_id=$_operation->salle_id operation_id=$_operation->_id
           opid=$_operation->_id reveil=true }}
       </span>
    </td>
    {{/if}}
    <td class="button">
      {{if $modif_operation}}
      <form name="editSortieReveilReveilFrm{{$_operation->_id}}" action="?m={{$m}}" method="post">
        <input type="hidden" name="m" value="dPplanningOp" />
        <input type="hidden" name="dosql" value="do_planning_aed" />
        <input type="hidden" name="operation_id" value="{{$_operation->_id}}" />
        <input type="hidden" name="del" value="0" />

        {{mb_field object=$_operation field=sortie_reveil_possible form=editSortieReveilReveilFrm`$_operation->_id` onchange="submitReveilForm(this.form)"}}
        {{if !$_operation->sortie_reveil_possible}}
          <button class="tick notext" type="button"
            onclick="if (!this.form.sortie_reveil_possible.value) { $V(this.form.sortie_reveil_possible, 'current'); }; submitReveilForm(this.form);">{{tr}}Modify{{/tr}}</button>
        {{/if}}
      </form>
      {{else}}-{{/if}}
      
      {{mb_include module=forms template=inc_widget_ex_class_register object=$_operation event_name=sortie_reveil cssStyle="display: inline-block; font-size: 0.8em;"}}
    </td>
    {{if $use_sortie_reveil_reel}}
      <td class="button">
        <form name="editSortieReveilReelReveilFrm{{$_operation->_id}}" action="?m={{$m}}" method="post">
          <input type="hidden" name="m" value="dPplanningOp" />
          <input type="hidden" name="dosql" value="do_planning_aed" />
          <input type="hidden" name="operation_id" value="{{$_operation->_id}}" />
          <input type="hidden" name="del" value="0" />
          {{if $modif_operation}}
            {{mb_field object=$_operation field=sortie_reveil_reel register=true form="editSortieReveilReelReveilFrm$_operation_id" onchange="submitSortieForm(this.form);"}}
            {{if !$_operation->sortie_reveil_reel}}
              <button class="tick notext" type="button"
              onclick="if (!this.form.sortie_reveil_reel.value) { $V(this.form.sortie_reveil_reel, 'current'); }; submitSortieForm(this.form);">{{tr}}Modify{{/tr}}</button>
            {{/if}}
          {{else}}
            {{mb_value object=$_operation field="sortie_reveil_reel"}}
          {{/if}}
        </form>
        </td>
    {{/if}}
    <td>
      <button type="button" class="print notext"
        onclick="printDossier('{{$_operation->sejour_id}}', '{{$_operation->_id}}')"></button>
    </td>
  </tr>
  {{foreachelse}}
  <tr><td colspan="20" class="empty">{{tr}}COperation.none{{/tr}}</td></tr>
  {{/foreach}}
</table>
