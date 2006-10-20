        <tr>
          {{if !$fiche->valid_user_id}}
          <th colspan="2" class="title" style="color:#f00;">
            Validation de la fiche {{$fiche->_view}}
          {{else}}
          <th colspan="2" class="title">
            Visualisation de la fiche {{$fiche->_view}}
          {{/if}}
          </th>
        </tr>
        <tr>
          <th>Evenement</th>
          <td>
            <strong>
              Signalement d'un
              {{tr}}CFicheEi.type_incident.{{$fiche->type_incident}}{{/tr}}
            </strong>
            <br /> le {{$fiche->date_incident|date_format:"%A %d %B %Y � %Hh%M"}}
          </td>
        </tr>
        <tr>
          <th>Auteur de la Fiche</th>
          <td class="text">
            {{$fiche->_ref_user->_view}}
            <br />{{$fiche->_ref_user->_ref_function->_view}}
          </td>
        </tr>
       <tr>
          <th>Concernant</th>
          <td class="text">
            {{tr}}CFicheEi.elem_concerne.{{$fiche->elem_concerne}}{{/tr}}<br />
            {{$fiche->elem_concerne_detail|nl2br}}
          </td>
        </tr>
        <tr>
          <th>Service</th>
          <td class="text">
            {{$fiche->lieu}}
          </td>
        </tr>
        <tr>
          <th colspan="2" class="category">Description de l'�v�nement</th>
        </tr>
        {{foreach from=$catFiche item=currEven key=keyEven}}
        <tr>
          <th><strong>{{$keyEven}}</strong></th>
          <td>
            <ul>
              {{foreach from=$currEven item=currItem}}
              <li>{{$currItem->nom}}</li>
              {{/foreach}}
            </ul>
          </td>
        </tr>  
        {{/foreach}}
        <tr>
          <th colspan="2" class="category">Informations compl�mentaires</th>
        </tr>
        {{if $fiche->autre}}
        <tr>
          <th>Autre</th>
          <td class="text">{{$fiche->autre|nl2br}}</td>
        </tr>
        {{/if}}
        <tr>
          <th>Description des faits</th>
          <td class="text">{{$fiche->descr_faits|nl2br}}</td>
        </tr>
        <tr>
          <th>Mesures Prises</th>
          <td class="text">{{$fiche->mesures|nl2br}}</td>
        </tr>
        <tr>
          <th>Description des cons�quences</th>
          <td class="text">{{$fiche->descr_consequences|nl2br}}</td>
        </tr>
        <tr>
          <th>Gravit� estim�e</th>
          <td>
            {{tr}}CFicheEi.gravite.{{$fiche->gravite}}{{/tr}}
          </td>
        </tr>
        <tr>
          <th>Plainte pr�visible</th>
          <td>
            {{tr}}CFicheEi.plainte.{{$fiche->plainte}}{{/tr}}
          </td>
        </tr>
        <tr>
          <th>Commission concialition</th>
          <td>
            {{tr}}CFicheEi.commission.{{$fiche->commission}}{{/tr}}
          </td>
        </tr>
        <tr>
          <th>Suite de l'�v�nement</th>
          <td class="text">
            {{tr}}CFicheEi.suite_even.{{$fiche->suite_even}}{{/tr}}
            {{if $fiche->suite_even=="autre"}}
              <br />{{$fiche->suite_even_descr|nl2br}}
            {{/if}}
          </td>
        </tr>
        <tr>
          <th>Ev�nement d�j� survenu �<br /> la connaissance de l'auteur</th>
          <td>
            {{tr}}CFicheEi.deja_survenu.{{$fiche->deja_survenu}}{{/tr}}
          </td>
        </tr>
        <tr>
          <th colspan="2" class="category">Enregistrement Qualit�</th>
        </tr>
        {{if $fiche->date_validation}}
        <tr>
          <th>Degr� d'Urgence</th>
          <td>{{tr}}CFicheEi.degre_urgence.{{$fiche->degre_urgence}}{{/tr}}</td>
        </tr>
        <tr>
          <th>Valid�e par</th>
          <td>
            {{$fiche->_ref_user_valid->_view}}
            <br />le {{$fiche->date_validation|date_format:"%d %b %Y � %Hh%M"}}
          </td>
        </tr>
        <tr>
          <th>Transmise �</th>
          <td>
            {{$fiche->_ref_service_valid->_view}}
          </td>
        </tr>
        {{/if}}
        
        {{if $fiche->service_date_validation}}
        <tr>
          <th colspan="2" class="category">Validation du Chef de Service</th>
        </tr>
        <tr>
          <th>Mesures Prises par</th>
          <td>
            {{$fiche->_ref_service_valid->_view}}
            <br />le {{$fiche->service_date_validation|date_format:"%d %b %Y � %Hh%M"}}
          </td>
        </tr>
        <tr>
          <th>Actions mises en place</th>
          <td class="text">{{$fiche->service_actions|nl2br}}</td>
        </tr>
        <tr>
          <th>Description des cons�quences</th>
          <td class="text">{{$fiche->service_descr_consequences|nl2br}}</td>
        </tr>
        {{/if}}
        
        {{if $fiche->qualite_date_validation}}
        <tr>
          <th colspan="2" class="category">Validation du Service Qualit�</th>
        </tr>
        <tr>
          <th>Valid�e par</th>
          <td>
            {{$fiche->_ref_qualite_valid->_view}}
            <br />le {{$fiche->qualite_date_validation|date_format:"%d %b %Y � %Hh%M"}}
          </td>
        </tr>
        {{if $fiche->qualite_date_verification}}
        <tr>
          <th>V�rifi� le</th>
          <td>{{$fiche->qualite_date_verification|date_format:"%d %b %Y"}}</td>
        </tr>
        {{/if}}
        {{if $fiche->qualite_date_controle}}
        <tr>
          <th>Contr�l� le</th>
          <td>{{$fiche->qualite_date_controle|date_format:"%d %b %Y"}}</td>
        </tr>
        {{/if}}
        {{/if}}
        
        {{if !$canAdmin}}
        <tr>
          <td colspan="2" class="button">
            {{$fiche->_etat_actuel}}
          </td>
        </tr>
        {{/if}}