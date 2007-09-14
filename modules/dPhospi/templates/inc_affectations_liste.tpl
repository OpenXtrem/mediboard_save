    <table class="tbl">
      <tr>
        <th class="title">
          {{tr}}CSejour.groupe.{{$group_name}}{{/tr}}
        </th>
      </tr>
    </table>

    {{foreach from=$sejourNonAffectes item=curr_sejour}}
    <form name="addAffectationsejour{{$curr_sejour->sejour_id}}" action="?m={{$m}}" method="post">

    <input type="hidden" name="dosql" value="do_affectation_aed" />
    <input type="hidden" name="lit_id" value="" />
    <input type="hidden" name="sejour_id" value="{{$curr_sejour->sejour_id}}" />
    <input type="hidden" name="entree" value="{{$curr_sejour->entree_prevue}}" />
    <input type="hidden" name="sortie" value="{{$curr_sejour->sortie_prevue}}" />

    </form>

    <table class="sejourcollapse" id="sejour{{$curr_sejour->sejour_id}}">
      <tr>
        <td class="selectsejour" style="background:#{{$curr_sejour->_ref_praticien->_ref_function->color}}">
          {{if $curr_sejour->pathologie != ""}}  
          <input type="radio" id="hospitalisation{{$curr_sejour->sejour_id}}" onclick="selectHospitalisation({{$curr_sejour->sejour_id}})" />
          <script type="text/javascript">new Draggable('sejour{{$curr_sejour->sejour_id}}', {revert:true})</script>
          {{/if}}
        </td>
        <td class="patient" onclick="flipSejour({{$curr_sejour->sejour_id}})">
          <strong><a name="sejour{{$curr_sejour->sejour_id}}">{{$curr_sejour->_ref_patient->_view}}</a></strong>
          {{if $curr_sejour->type != "ambu" && $curr_sejour->type != "exte"}}
          ({{$curr_sejour->_duree_prevue}}j)
          {{else}}
          ({{$curr_sejour->type|truncate:1:""|capitalize}})
          {{/if}}
          {{if $curr_sejour->_couvert_cmu}}
          <div style="float: right;"><strong>CMU</strong></div>
          {{/if}}
        </td>
      </tr>      
      <tr>
        <td class="date" colspan="2"><em>Entr�e</em> : {{$curr_sejour->entree_prevue|date_format:"%A %d %B %H:%M"}}</td>
      </tr>
      <tr>
        <td class="date" colspan="2"><em>Sortie</em> : {{$curr_sejour->sortie_prevue|date_format:"%A %d %B %H:%M"}}</td>
      </tr>
      <tr>
        <td class="date" colspan="2"><em>Age</em> : {{$curr_sejour->_ref_patient->_age}} ans
      </tr>
      <tr>
        <td class="date" colspan="2"><em>Dr. {{$curr_sejour->_ref_praticien->_view}}</em></td>
      </tr>
      {{if $curr_sejour->prestation_id}}
      <tr>
        <td class="date" colspan="2"><em>Prestation: </em>{{$curr_sejour->_ref_prestation->_view}}</td>
      </tr>
      {{/if}}
      <tr>
        <td class="date" colspan="2">
          {{foreach from=$curr_sejour->_ref_operations item=curr_operation}}
            {{if $curr_operation->libelle}}
              <em>[{{$curr_operation->libelle}}]</em>
              <br />
            {{/if}}
            {{foreach from=$curr_operation->_ext_codes_ccam item=curr_code}}
              <em>{{$curr_code->code}}</em> : {{$curr_code->libelleLong}}<br />
            {{/foreach}}
          {{/foreach}}
        </td>
      </tr>
      <tr>
        <td class="date" colspan="2">
        
        <form name="EditSejour{{$curr_sejour->sejour_id}}" action="?m=dPhospi" method="post">

        <input type="hidden" name="m" value="dPplanningOp" />
        <input type="hidden" name="otherm" value="dPhospi" />
        <input type="hidden" name="dosql" value="do_sejour_aed" />
        <input type="hidden" name="sejour_id" value="{{$curr_sejour->sejour_id}}" />
        
        <em>Pathologie:</em>
        <select name="pathologie">
          <option value="">&mdash; Choisir &mdash;</option>
          {{foreach from=$pathos->_enumsTrans.categorie|smarty:nodefaults item=curr_patho}}
          <option {{if $curr_patho == $curr_sejour->pathologie}}selected="selected"{{/if}}>
          {{$curr_patho}}
          </option>
          {{/foreach}}
        </select>
        <br />
        <input type="radio" name="septique" value="0" {{if $curr_sejour->septique == 0}} checked="checked" {{/if}} />
        <label for="septique_0" title="Op�ration propre">Propre</label>
        <input type="radio" name="septique" value="1" {{if $curr_sejour->septique == 1}} checked="checked" {{/if}} />
        <label for="septique_1" title="S�jour septique">Septique</label>

        <button class="submit" onclick="submit()">Valider</button>
        
        </form>
        
        </td>
      </tr>
      {{if $curr_sejour->rques != ""}}
      <tr>
        <td class="date highlight" colspan="2">
          <em>S�jour</em>: {{$curr_sejour->rques|nl2br}}
        </td>
      </tr>
      {{/if}}
      {{foreach from=$curr_sejour->_ref_operations item=curr_operation}}
      {{if $curr_operation->rques != ""}}
      <tr>
        <td class="date highlight" colspan="2">
          <em>Intervention</em>: {{$curr_operation->rques|nl2br}}
        </td>
      </tr>
      {{/if}}
      {{/foreach}}
      {{if $curr_sejour->_ref_patient->rques}}
      <tr>
        <td class="date highlight" colspan="2">
          <em>Patient</em>: {{$curr_sejour->_ref_patient->rques|nl2br}}
        </td>
      </tr>
      {{/if}}
      {{if $curr_sejour->chambre_seule}}
      <tr>
        <td class="date highlight" colspan="2">
          <strong>Chambre seule</strong>
        </td>
      </tr>
      {{else}}
      <tr>
        <td class="date" colspan="2">
          <strong>Chambre double</strong>
        </td>
      </tr>
      {{/if}}
    </table>
    
    {{/foreach}}