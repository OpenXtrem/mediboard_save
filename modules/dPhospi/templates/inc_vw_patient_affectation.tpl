<div class="patient {{if $can->edit}}draggable{{/if}}" data-affectation-guid="{{$_affectation->_guid}}"
 data-patient-id="{{if $_affectation->_ref_sejour->_id}}{{$_affectation->_ref_sejour->patient_id}}{{/if}}"
  id="affectation_topologique_{{$_affectation->_id}}">
    <script>
      Main.add(function(){
        var container = $('affectation_topologique_{{$_affectation->_id}}');
        new Draggable( container, {  revert:true, 
          scroll: window, 
          ghosting: true});
      });
    </script>
  <form name="{{$_affectation->_guid}}" action="" method="post">
    <input type="hidden" name="dosql" value="do_affectation_aed" />
    <input type="hidden" name="del" value="0" />
    <input type="hidden" name="m" value="dPhospi" />                          
    <input type="hidden" name="affectation_id" value="{{$_affectation->_id}}" />
    <input type="hidden" name="sejour_id" value="{{$_affectation->sejour_id}}" />
    <input type="hidden" name="lit_id" value="{{$_affectation->lit_id}}" />
    <input type="hidden" name="service_id" value="{{$_affectation->service_id}}" />
  </form>
  {{if $_affectation->_ref_sejour->_id}}
    {{assign var=_sejour value=$_affectation->_ref_sejour}}
    {{assign var=patient   value=$_sejour->_ref_patient}}
      <span 
      {{if ($_affectation->entree == $_sejour->entree && !$_sejour->entree_reelle) ||
        ($_affectation->entree != $_sejour->entree && !$_affectation->effectue)}}
        style="color: #A33;" 
      {{elseif $_affectation->effectue}}
        style="text-decoration: line-through;"
      {{/if}}
      onmouseover="ObjectTooltip.createEx(this, '{{$_affectation->_guid}}');" >{{$patient->nom}} {{$patient->prenom}}</span>
      <div class="ssr-sejour-bar" title="arriv�e il y a {{$_sejour->_entree_relative}}j et d�part pr�vu dans {{$_sejour->_sortie_relative}}j " style="position:absolute;top:0px;">      
      <div style="width: {{if $_sejour->_duree}}{{math equation='100*(-entree / (duree))' entree=$_sejour->_entree_relative duree=$_sejour->_duree format='%.2f'}}{{else}}100{{/if}}%;"></div>
    </div>
    <br/>
    <div class="libelle compact" style="float:left;">
      {{if $conf.dPhospi.show_age_patient}}({{$patient->_age}}){{/if}}
      {{if $conf.dPhospi.systeme_prestations}}
        <em style="color: #f00;" title="Chambre {{if $_sejour->chambre_seule}}seule{{else}}double{{/if}}">
          {{if $_sejour->chambre_seule}}CS{{else}}CD{{/if}}
          {{if $_sejour->prestation_id}}- {{$_sejour->_ref_prestation->code}}{{/if}}&nbsp;
        </em>
      {{/if}}
      {{$_sejour->libelle|truncate:30|lower}}
    </div>
    {{if $can->edit}}
      <div style="float:right;">
        <span class="toolbar_affectation_topo">
          {{if (!$_affectation->uf_hebergement_id || !$_affectation->uf_medicale_id || !$_affectation->uf_soins_id) && $conf.dPhospi.show_uf}}
            <a style="margin-top: 3px; display: inline" href="#1"
              onclick="AffectationUf.affecter('{{$_affectation->_guid}}','{{$_affectation->_ref_lit->_guid}}')">
              <img src="images/icons/uf-warning.png" width="16" height="16" title="Affecter les UF" />
            </a>
          {{/if}}
          {{if $_affectation->sejour_id}}
            {{if $_affectation->uf_hebergement_id && $_affectation->uf_medicale_id && $_affectation->uf_soins_id && $conf.dPhospi.show_uf}}
              <a style="margin-top: 3px; display: inline" href="#1"
                 onclick="AffectationUf.affecter('{{$_affectation->_guid}}','{{$_affectation->_ref_lit->_guid}}')">
                <img src="images/icons/uf.png" width="16" height="16" title="Affecter les UF" class="opacity-40"
                  onmouseover="this.toggleClassName('opacity-40')" onmouseout="this.toggleClassName('opacity-40')"/></a>
            {{/if}}
          {{/if}}
          {{if $conf.dPadmissions.show_deficience}}
          <span>
            {{mb_include module=patients template=inc_vw_antecedents type=deficience readonly=1}}
          </span>
          {{/if}}
          {{if $_affectation->sejour_id != 0 && $_affectation->lit_id}}
            <button type="button" class="door-out notext opacity-40"
              title="Placer dans le couloir"
              onmouseover="this.toggleClassName('opacity-40')" onmouseout="this.toggleClassName('opacity-40')"
              onclick="choiceAffService('{{$_affectation->_id}}', '{{$_affectation->sejour_id}}', '{{$_affectation->lit_id}}', '{{$_zone->service_id}}');"></button>
          {{/if}}
          <button type="button" class="edit notext opacity-40"
            onmouseover="this.toggleClassName('opacity-40')" onmouseout="this.toggleClassName('opacity-40')"
            onclick="editAffectation('{{$_affectation->_id}}', '{{$_affectation->lit_id}}')"></button>
        </span>
      </div>
    {{/if}}
{{elseif !$_affectation->function_id}}
  <span onmouseover="ObjectTooltip.createEx(this, '{{$_affectation->_guid}}');">
    BLOQUE
  </span>
{{elseif $_affectation->function_id}}
  <span onmouseover="ObjectTooltip.createEx(this, '{{$_affectation->_guid}}');">
    BLOQUE POUR {{mb_value object=$_affectation field=function_id}}
  </span>
{{/if}}
</div>