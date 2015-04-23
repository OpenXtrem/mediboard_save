{{*
 * $Id$
 *  
 * @category Pmsi
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @link     http://www.mediboard.org*}}

{{mb_script module="pmsi" script="traitementDossiers" ajax=true}}

{{assign var=patient value=$_sejour->_ref_patient}}
{{assign var=sejour_id value=$_sejour->_id}}
<tr class="sejour sejour-type-default sejour-type-{{$_sejour->type}}" id="{{$_sejour->_guid}}">
  <td>
    {{mb_value object=$_sejour field="sortie_reelle"}}
  </td>

  <td>
    {{mb_include module=planningOp template=inc_vw_numdos nda_obj=$_sejour _show_numdoss_modal=1}}
    <span class="CPatient-view" onmouseover="ObjectTooltip.createEx(this, '{{$patient->_guid}}');">
      {{$patient}}
    </span>
  </td>

  <td class="text">
    {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$_sejour->_ref_praticien}}
  </td>

  <td>
    <span class="CSejour-view" onmouseover="ObjectTooltip.createEx(this, '{{$_sejour->_guid}}');">
      {{$_sejour->_shortview}}
    </span>
  </td>

  <td class="text narrow columns-2">
    <form name="sejour_traitement_dossier_{{$sejour_id}}" method="post" onsubmit=" return traitementDossiers.submitEtatPmsi(this)">
      {{mb_class object=$_sejour->_ref_traitement_dossier}}
      {{mb_key   object=$_sejour->_ref_traitement_dossier}}
      <input type="hidden" name="sejour_id" value="{{$sejour_id}}">

      {{mb_label object=$_sejour->_ref_traitement_dossier field="traitement"}}
      {{if $_sejour->_ref_traitement_dossier->traitement}}
        {{mb_field object=$_sejour->_ref_traitement_dossier field="traitement" form="sejour_traitement_dossier_$sejour_id" register=true onchange="this.form.onsubmit();"}}
      {{else}}
        <button class="tick notext" type="submit" onclick="$V(this.form.traitement, new Date().toDATETIME())">{{tr}}CTraitementDossier-traitement{{/tr}}</button>
        <input type="hidden" name="traitement" value="{{$_sejour->_ref_traitement_dossier->traitement}}">
      {{/if}}


      {{mb_label object=$_sejour->_ref_traitement_dossier field="validate"}}
      {{if $_sejour->_ref_traitement_dossier->validate}}
        {{mb_field object=$_sejour->_ref_traitement_dossier field="validate" form="sejour_traitement_dossier_$sejour_id" register=true onchange="this.form.onsubmit();"}}
      {{else}}
        <button class="tick notext" type="submit" onclick="$V(this.form.validate, (new Date().toDATETIME()))">{{tr}}CTraitementDossier-validate{{/tr}}</button>
        <input type="hidden" name="validate" value="{{$_sejour->_ref_traitement_dossier->validate}}">
      {{/if}}
      </form>
  </td>

  <td class="narrow"></td>
</tr>