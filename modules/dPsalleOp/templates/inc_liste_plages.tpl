      <form action="index.php" name="selection" method="get">
      
      <input type="hidden" name="m" value="{{$m}}" />
  
      <table class="form">
        <tr>
          <th class="category" colspan="2">
            {{$date|date_format:"%A %d %B %Y"}}
            <img id="changeDate" src="./images/calendar.gif" title="Choisir la date" alt="calendar" />
          </th>
        </tr>
        
        <tr>
          <th><label for="salle" title="Salle d'op�ration">Salle</label></th>
          <td>
            <select name="salle" onchange="this.form.submit()">
              <option value="">&mdash; Aucune salle</option>
              {{foreach from=$listSalles item=curr_salle}}
              <option value="{{$curr_salle->salle_id}}" {{if $curr_salle->salle_id == $salle}} selected="selected" {{/if}}>
                {{$curr_salle->nom}}
              </option>
              {{/foreach}}
            </select>
          </td>
        </tr>
      </table>
      
      </form>
            
      {{foreach from=$plages item=curr_plage}}
      <hr />
      
      <form name="anesth{{$curr_plage->plageop_id}}" action="index.php" method="post">

      <input type="hidden" name="m" value="dPbloc" />
      <input type="hidden" name="otherm" value="{{$m}}" />
      <input type="hidden" name="dosql" value="do_plagesop_aed" />
      <input type="hidden" name="del" value="0" />
      <input type="hidden" name="_repeat" value="1" />
      <input type="hidden" name="plageop_id" value="{{$curr_plage->plageop_id}}" />
      <input type="hidden" name="chir_id" value="{{$curr_plage->chir_id}}" />

      <table class="form">
        <tr>
          <th class="category" colspan="2">
            <a href="?m=dPbloc&amp;tab=vw_edit_interventions&amp;plageop_id={{$curr_plage->plageop_id}}" title="Administrer la plage">
              Plage du Dr. {{$curr_plage->_ref_chir->_view}}
              de {{$curr_plage->debut|date_format:"%Hh%M"}} � {{$curr_plage->fin|date_format:"%Hh%M"}}
            </a>
          </th>
        </tr>
      
        <tr>
          <th><label for="anesth_id" title="Anesth�siste associ� � la plage d'op�ration">Anesth�siste</label></th>
          <td>
            <select name="anesth_id" onchange="submit()">
              <option value="">&mdash; Choisir un anesth�siste</option>
              {{foreach from=$listAnesths item=curr_anesth}}
              <option value="{{$curr_anesth->user_id}}" {{if $curr_plage->anesth_id == $curr_anesth->user_id}} selected="selected" {{/if}}>
                {{$curr_anesth->_view}}
              </option>
              {{/foreach}}
            </select>
          </td>
        </tr>
        
      </table>

      </form>

       <table class="tbl">
        <tr>
          <th>Heure</th>
          <th>Patient</th>
          <th>Intervention</th>
          <th>Cot�</th>
          <th>Dur�e</th>
        </tr>
        {{foreach from=$curr_plage->_ref_operations item=curr_operation}}
        <tr>
          {{if $curr_operation->entree_bloc && $curr_operation->sortie_bloc}}
          <td style="background-image:url(modules/{{$m}}/images/ray.gif); background-repeat:repeat;">
          {{elseif $curr_operation->entree_bloc}}
          <td style="background-color:#cfc">
          {{elseif $curr_operation->sortie_bloc}}
          <td style="background-color:#fcc">
          {{else}}
          <td>
          {{/if}}
            <a href="index.php?m={{$m}}&amp;op={{$curr_operation->operation_id}}" title="Coder l'intervention">
              {{$curr_operation->time_operation|date_format:"%Hh%M"}}
            </a>
          </td>
          <td>
            <a href="index.php?m={{$m}}&amp;op={{$curr_operation->operation_id}}" title="Coder l'intervention">
              {{$curr_operation->_ref_sejour->_ref_patient->_view}}
            </a>
          </td>
          <td>
            <a href="?m=dPplanningOp&amp;tab=vw_edit_planning&amp;operation_id={{$curr_operation->operation_id}}" title="Modifier l'intervention">
              {{foreach from=$curr_operation->_ext_codes_ccam item=curr_code}}
              {{$curr_code->code}}<br />
              {{/foreach}}
            </a>
          </td>
          <td>{{tr}}COperation.cote.{{$curr_operation->cote}}{{/tr}}</td>
          <td>{{$curr_operation->temp_operation|date_format:"%Hh%M"}}</td>
        </tr>
        {{/foreach}}
      </table>
      {{/foreach}}

      {{if $urgences|@count}}
      
      <hr />

      <table class="form">
        <tr>
          <th class="category" colspan="2">
            Urgences
          </th>
        </tr>        
      </table>
      <table class="tbl">
        <tr>
          <th>praticien</th>
          <th>Patient</th>
          <th>Intervention</th>
          <th>Cot�</th>
        </tr>
        {{foreach from=$urgences item=curr_operation}}
        <tr>
          {{if $curr_operation->entree_bloc && $curr_operation->sortie_bloc}}
          <td style="background-image:url(modules/{{$m}}/images/ray.gif); background-repeat:repeat;">
          {{elseif $curr_operation->entree_bloc}}
          <td style="background-color:#cfc">
          {{elseif $curr_operation->sortie_bloc}}
          <td style="background-color:#fcc">
          {{else}}
          <td>
          {{/if}}
            <a href="index.php?m={{$m}}&amp;op={{$curr_operation->operation_id}}" title="Coder l'intervention">
              {{$curr_operation->_ref_chir->_view}}
            </a>
          </td>
          <td>
            <a href="index.php?m={{$m}}&amp;op={{$curr_operation->operation_id}}" title="Coder l'intervention">
              {{$curr_operation->_ref_sejour->_ref_patient->_view}}
            </a>
          </td>
          <td>
            <a href="?m=dPplanningOp&amp;tab=vw_edit_planning&amp;operation_id={{$curr_operation->operation_id}}" title="Modifier l'intervention">
              {{foreach from=$curr_operation->_ext_codes_ccam item=curr_code}}
              {{$curr_code->code}}<br />
              {{/foreach}}
            </a>
          </td>
          <td>{{tr}}COperation.cote.{{$curr_operation->cote}}{{/tr}}</td>
        </tr>
        {{/foreach}}
      </table>
      {{/if}}