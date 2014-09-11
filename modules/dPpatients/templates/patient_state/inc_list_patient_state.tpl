{{*
 * $Id$
 *
 * @category DPpatients
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
*}}

<script>
  Main.add(function () {
    var tabname= "patient_{{$state}}";
    Control.Tabs.setTabCount(tabname, {{$count}});
  });
</script>

{{mb_include module=system template=inc_pagination total=$count current=$page change_page="PatientState.changePage.$state" step=30}}
<table class="tbl">
  <tr>
    <th class="title" colspan="7">Donn�es patient</th>
    <th class="title" colspan="3">Donn�es de l'�tat</th>
    <th class="title" rowspan="2">{{tr}}Action{{/tr}}</th>
  </tr>
  <tr>
    <th>{{mb_label class="CPatient" field="_IPP"}}</th>
    <th>{{mb_label class="CPatient" field="nom"}}</th>
    <th>{{mb_label class="CPatient" field="nom_jeune_fille"}}</th>
    <th>{{mb_label class="CPatient" field="prenom"}}</th>
    <th>{{mb_label class="CPatient" field="naissance"}}</th>
    <th>{{mb_label class="CPatient" field="sexe"}}</th>
    <th>List patient doublon</th>
    <th>{{mb_label class="CPatientState" field="datetime"}}</th>
    <th>{{mb_label class="CPatientState" field="mediuser_id"}}</th>
    <th>{{mb_label class="CPatientState" field="reason"}}</th>
  </tr>
  {{foreach from=$patients item=_patient}}
    {{assign var=patient_state value=$_patient->_ref_last_patient_states}}
    <tr>
      <td class="narrow">{{mb_value object=$_patient field="_IPP"}}</td>
      <td>
        <button type="button" class="edit notext"
                onclick="PatientState.edit_patient('{{$_patient->_id}}', '{{$state}}')">
          {{tr}}Edit{{/tr}}
        </button>
        <span onmouseover="ObjectTooltip.createEx(this, '{{$_patient->_guid}}')">{{mb_value object=$_patient field="nom"}}</span>
      </td>
      <td>{{mb_value object=$_patient field="nom_jeune_fille"}}</td>
      <td>{{mb_value object=$_patient field="prenom"}}</td>
      <td>{{mb_value object=$_patient field="naissance"}}</td>
      <td>{{mb_value object=$_patient field="sexe"}}</td>
      <td>
        {{foreach from=$_patient->_ref_patient_links item=_link}}
          {{if $_link->_ref_patient_doubloon}}
            {{assign var=doubloon value=$_link->_ref_patient_doubloon}}
            <form name="unlink_patient_{{$_link->_id}}_{{$_patient->_id}}" method="post"
                  onsubmit="return onSubmitFormAjax(this, PatientState.getListPatientByState.curry('{{$state}}', {{$page}}))">
              {{mb_key object=$_link}}
              {{mb_class object=$_link}}
              <input type="hidden" name="del" value="1">
              <button type="submit" class="unlink notext" title="{{tr}}Unlink{{/tr}}">
                {{tr}}Unlink{{/tr}}
              </button>
            </form>
            <button type="button" class="merge notext"
                    onclick="PatientState.mergePatient('{{$_patient->_id}}-{{$doubloon->_id}}')">{{tr}}Merge{{/tr}}</button>
            <span onmouseover="ObjectTooltip.createEx(this, '{{$doubloon->_guid}}')">
              {{$doubloon->_IPP}} - {{$doubloon->_view}}
            </span>
            <br/>
          {{/if}}
        {{/foreach}}
      </td>
      {{if $patient_state}}
        <td>{{mb_value object=$patient_state field="datetime"}}</td>
        <td>{{if $patient_state->_ref_mediuser}}{{$patient_state->_ref_mediuser->_view}}{{/if}}</td>
        <td>{{mb_value object=$patient_state field="reason"}}</td>
      {{else}}
        <td colspan="3">{{tr}}CPatientState.none{{/tr}}</td>
      {{/if}}
      <td>
        {{if $_patient->_ref_patient_links}}
          Le patient poss�dent des doublons potentielles, veuillez fusionner les patients ou supprimer les liens pour valider l'identit�.
        {{else}}
          <form name="validationState_{{$_patient->_guid}}" method="post"
                      onsubmit="return onSubmitFormAjax(this, PatientState.getListPatientByState.curry('{{$state}}', {{$page}}))">
          {{mb_key   object=$_patient}}
          {{mb_class object=$_patient}}
            {{mb_field object=$_patient field="_reason_state"}}
            {{if $_patient->status != "VALI"}}
              {{mb_field object=$_patient field="status" value="VALI" hidden=true}}
              <button type="submit" class="tick">{{tr}}Validate{{/tr}} l'identit�</button>
            {{else}}
              {{mb_field object=$_patient field="status" value="PROV" hidden=true}}
              <button type="submit" class="cancel">Rendre l'identit� provisoire</button>
            {{/if}}
          </form>
        {{/if}}
      </td>
    </tr>
  {{foreachelse}}
    <tr><td colspan="11" class="empty">{{tr}}CPatient.none{{/tr}}</td></tr>
  {{/foreach}}
</table>