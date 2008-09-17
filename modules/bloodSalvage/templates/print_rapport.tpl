{{assign var=operation value=$blood_salvage->_ref_operation}}
{{assign var=patient value=$blood_salvage->_ref_operation->_ref_patient}}
{{assign var=consult_anesth value=$blood_salvage->_ref_operation->_ref_consult_anesth}}
{{assign var=const_med value=$patient->_ref_constantes_medicales}}
{{assign var=dossier_medical value=$patient->_ref_dossier_medical}}
{{assign var=ant value=$dossier_medical->_ref_antecedents}}
{{if !$ant}}
  {{assign var=no_alle value=0}}
{{else}}
  {{assign var=no_alle value=$ant&&!array_key_exists("alle",$ant)}}
{{/if}}

 <table class="form" id="admission">
  <tr>
	  <th class="title" colspan="4">
	    <a href="#" onclick="window.print()">
        {{tr}}CBloodSalvage.report-long{{/tr}}
	    </a>
	  </th>
  </tr>
  <tr>
    <td class="halfPane" {{if $no_alle}}colspan="2"{{/if}}>
      <table width="100%">
        <tr>
          <th class="category" colspan="2">Informations sur le patient</th>
        </tr>
        <tr>
          <td colspan="2">{{$patient->_view}}</td>
        </tr>
        {{if $patient->nom_jeune_fille}}
        <tr>
          <th>Nom de jeune fille</th>
          <td>{{$patient->nom_jeune_fille}}</td>
        </tr>
        {{/if}}
        <tr>
          <td colspan="2">
            N�{{if $patient->sexe != "m"}}e{{/if}} le {{mb_value object=$patient field=naissance}}
            ({{$patient->_age}} ans)
            - sexe {{if $patient->sexe == "m"}} masculin {{else}} f�minin {{/if}}<br />
            {{if $patient->profession}}Profession : {{$patient->profession}}<br />{{/if}}          
            {{if $patient->medecin_traitant}}M�decin traitant : Dr {{$patient->_ref_medecin_traitant->_view}}<br />{{/if}}      
            <br />    
            {{if $const_med->poids}}<strong>{{$const_med->poids}} kg</strong> - {{/if}}
            {{if $const_med->taille}}<strong>{{$const_med->taille}} cm</strong> - {{/if}}
            {{if $const_med->_imc}}IMC : <strong>{{$const_med->_imc}}</strong>
              {{if $const_med->_imc_valeur}}({{$const_med->_imc_valeur}}){{/if}}
            {{/if}}
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <table>
              {{if $isInDM}}
	              {{if $patient->_ref_dossier_medical->groupe_sanguin!="?" || $patient->_ref_dossier_medical->rhesus!="?"}}
	              <tr>
	                <th>Groupe sanguin</th>
	                <td style="white-space: nowrap;font-size:130%;"><b>&nbsp;{{tr}}{{$patient->_ref_dossier_medical->groupe_sanguin}}{{/tr}} &nbsp;{{tr}}{{$patient->_ref_dossier_medical->rhesus}}{{/tr}}</b></td>
	              </tr>
	              {{/if}}
              {{else}}
	              {{if $consult_anesth->groupe!="?" || $consult_anesth->rhesus!="?"}}
	              <tr>
	                <th>Groupe sanguin</th>
	                <td style="white-space: nowrap;font-size:130%;"><b>&nbsp;{{tr}}{{$consult_anesth->groupe}}{{/tr}} &nbsp;{{tr}}{{$consult_anesth->rhesus}}{{/tr}}</b></td>
	              </tr>
	              {{/if}}
              {{/if}}
              {{if $consult_anesth->rai && $consult_anesth->rai!="?"}}
              <tr>
                <th>RAI</th>
                <td style="white-space: nowrap;font-size:130%;"><b>&nbsp;{{tr}}CConsultAnesth.rai.{{$consult_anesth->rai}}{{/tr}}</b></td>
              </tr>
              {{/if}}
              <tr>
                <th>ASA</th>
                <td> <b>{{tr}}CConsultAnesth.ASA.{{$consult_anesth->ASA}}{{/tr}}</b> </td>
              </tr>
              <tr>
                <th>VST</th>
                <td style="white-space: nowrap;">
                  <b>
                  {{if $const_med->_vst}}{{$const_med->_vst}} ml{{/if}}
                  </b>
                </td>
              </tr>
              {{if $consult_anesth->_psa}}
              <tr>
                <th>PSA</th>
                <td style="white-space: nowrap;">
                  <b>{{$consult_anesth->_psa}} ml/GR</b>
                </td>
                <td colspan="2"></td>
              </tr>
              {{/if}}
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td>
      <table width="100%">
        <tr>
          <th class="category" colspan="2">
            {{tr}}CBloodSalvage.operations{{/tr}}
          </th>
        </tr>
        <tr>
          <td>
           {{$operation->_view}} <br />
           {{mb_label object=$operation field=cote}} : {{mb_value object=$operation field=cote}}<br />
           {{if $operation->libelle}}{{mb_label object=$operation field=libelle}} : {{mb_value object=$operation field=libelle}} <br />{{/if}}
           {{tr}}CBloodSalvage.anesthesia{{/tr}} : {{if $operation->_ref_type_anesth}}{{$operation->_ref_type_anesth->name}}  {{/if}} <br />
           {{tr}}CBloodSalvage.anesthesist{{/tr}} : {{$operation->_ref_anesth->_view}}        
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td>
      <table width="100%">
        <tr>
          <th class="category" colspan="2">
            {{tr}}CCellSaver.name{{/tr}}
          </th>
        </tr>
        <tr>
          <td>
           {{tr}}CCellSaver.modele{{/tr}} : {{$blood_salvage->_ref_cell_saver->_view}} <br /> 
           {{tr}}CBloodSalvage-receive_kit{{/tr}} :{{if $blood_salvage->receive_kit}} Lot n� {{$blood_salvage->receive_kit}} {{/if}} &nbsp;
           {{tr}}CBloodSalvage-wash_kit{{/tr}} :{{if $blood_salvage->wash_kit}} Lot n� {{$blood_salvage->wash_kit}} {{/if}}<br />
           {{tr}}CBloodSalvage-anticoagulant_cip{{/tr}} : {{$anticoagulant}} <br /> <br />
           {{tr}}CBloodSalvage-nurse_sspi.report{{/tr}}{{if $tabAffected|@count>1}}s{{/if}}  : 
           {{foreach from=$tabAffected item=nurse name=affect}}
             {{$nurse->_ref_personnel->_ref_user->_view}} &nbsp;
           {{foreachelse}} - {{/foreach}}
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td>
      <table width="100%">
        <tr>
          <th class="category" colspan="2">
            {{tr}}CBloodSalvage.timers{{/tr}}
          </th>
        </tr>
        <tr>
          <td>
           {{mb_label object=$blood_salvage field=_recuperation_start}} :  {{mb_value object=$blood_salvage field=_recuperation_start}}<br /> 
           {{mb_label object=$blood_salvage field=_recuperation_end}} : {{mb_value object=$blood_salvage field=_recuperation_end}}<br /> 
           {{mb_label object=$blood_salvage field=_transfusion_start}} : {{mb_value object=$blood_salvage field=_transfusion_start}}<br /> 
           {{mb_label object=$blood_salvage field=_transfusion_end}} : {{mb_value object=$blood_salvage field=_transfusion_end}}<br /> 
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td>
      <table width="100%">
        <tr>
          <th class="category" colspan="2">
            {{tr}}CBloodSalvage.volumes{{/tr}}
          </th>
        </tr>
        <tr>
          <td>
           {{mb_label object=$blood_salvage field=hgb_pocket}} :  {{mb_value object=$blood_salvage field=hgb_pocket}} g/dl<br /> 
           {{mb_label object=$blood_salvage field=hgb_patient}} : {{mb_value object=$blood_salvage field=hgb_patient}} g/dl<br /> <br /> 
           {{mb_label object=$blood_salvage field=transfused_volume}} : {{mb_value object=$blood_salvage field=transfused_volume}} ml<br /> 
           {{mb_label object=$blood_salvage field=wash_volume}} : {{mb_value object=$blood_salvage field=wash_volume}} ml<br /> 
           {{mb_label object=$blood_salvage field=saved_volume}} : {{mb_value object=$blood_salvage field=saved_volume}} ml<br /> 
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td>
      <table width="100%">
        <tr>
          <th class="category" colspan="2">
            {{tr}}module-dPqualite-court{{/tr}}
          </th>
        </tr>
        <tr>
          <td>
            {{if $blood_salvage->type_ei_id}} {{tr}}CTypeEi-type_ei_id-desc{{/tr}} : {{$blood_salvage->_ref_incident_type->_view}} {{else}} Aucun incident transfusionnel {{/if}}<br />
            {{tr}}BloodSalvage.quality-protocole{{/tr}} : {{mb_value object=$blood_salvage field="sample"}}
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
