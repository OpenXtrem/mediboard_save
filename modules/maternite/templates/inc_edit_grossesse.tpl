{{*
 * $Id$
 *
 * @package    Mediboard
 * @subpackage Maternite
 * @author     SARL OpenXtrem <dev@openxtrem.com>
 * @license    GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version    $Revision$
 *}}
{{mb_script module="dPpatients" script="pat_selector" ajax=1}}

<script>
  PatSelector.init = function() {
    this.sForm      = "editFormGrossesse";
    this.sId        = "parturiente_id";
    this.sView      = "_patient_view";
    this.sSexe      = "_patient_sexe";
    this.pop();
  };

  Main.add(function() {
    {{if $grossesse->_id}}
      reloadHistorique();
    {{/if}}
  });

  reloadHistorique = function() {
    var url = new Url('maternite', 'ajax_grossesse_history');
    url.addParam('grossesse_id', '{{$grossesse->_id}}');
    url.requestUpdate('list_historique');
  };

  admitForSejour = function(sejour_id) {
    var form = getForm('admitSejour');
    $V(form.sejour_id, sejour_id);
    $V(form.entree_reelle, 'now');
    form.onsubmit();
  };

  consultNow = function(prat_id, grossesse_id) {
    var form = getForm('editConsultImm');
    $V(form.prat_id, prat_id);
    $V(form.grossesse_id, grossesse_id);
    form.onsubmit();
    $V("selector_prat_imm", '', false);
    return false;
  };
</script>

<form name="admitSejour" method="post" onsubmit="return onSubmitFormAjax(this, {onComplete: reloadHistorique})">
  <input type="hidden" name="m" value="dPplanningOp" />
  <input type="hidden" name="dosql" value="do_sejour_aed" />
  <input type="hidden" name="sejour_id" value="" />
  <input type="hidden" name="entree_reelle" value="" />
</form>

<form name="editConsultImm" method="post" onsubmit="return onSubmitFormAjax(this, {onComplete: reloadHistorique})">
  <input type="hidden" name="m" value="dPcabinet" />
  <input type="hidden" name="dosql" value="do_consult_now" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="grossesse_id" value="" />
  <input type="hidden" name="prat_id" value="" />
</form>

<form name="editFormGrossesse" method="post" onsubmit="return onSubmitFormAjax(this)">
  <input type="hidden" name="m" value="maternite"/>
  {{mb_class object=$grossesse}}
  {{mb_key   object=$grossesse}}
  <input type="hidden" name="callback" value="Grossesse.afterEditGrossesse" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="_patient_sexe" value="f" />

  <table class="main" style="height:100%;">
    <tr>
      <td class="narrow">
        <table class="form">
          <tr>
            {{mb_include module=system template=inc_form_table_header object=$grossesse}}
          </tr>

          <tr>
            <th>{{mb_label object=$grossesse field=parturiente_id}}</th>
            <td>
              {{mb_field object=$grossesse field=parturiente_id hidden=1}}
              <input type="text" style="cursor: pointer" name="_patient_view" value="{{$grossesse->_ref_parturiente}}" readonly="readonly" {{if !$grossesse->_id}}onclick="PatSelector.init();"{{/if}}/>
            </td>
          </tr>

          <tr>
            <th>
              {{mb_label object=$grossesse field=terme_prevu}}
            </th>
            <td>
              {{mb_field object=$grossesse field=terme_prevu form=editFormGrossesse register=true}}
            </td>
          </tr>
          <tr>
            <th>
              {{mb_label object=$grossesse field=date_dernieres_regles}}
            </th>
            <td>
              {{mb_field object=$grossesse field=date_dernieres_regles form=editFormGrossesse register=true}}
            </td>
          </tr>
          <tr>
            <th>
              {{mb_label object=$grossesse field=active}}
            </th>
            <td>
              {{mb_field object=$grossesse field=active}}
            </td>
          </tr>
          <tr>
            <th>
              {{mb_label object=$grossesse field=multiple}}
            </th>
            <td>
              {{mb_field object=$grossesse field=multiple}}
            </td>
          </tr>
          <tr>
            <th>
              {{mb_label object=$grossesse field=allaitement_maternel}}
            </th>
            <td>
              {{mb_field object=$grossesse field=allaitement_maternel}}
            </td>
          </tr>
          <tr>
            <th>
              {{mb_label object=$grossesse field=fausse_couche}}
            </th>
            <td>
              {{mb_field object=$grossesse field=fausse_couche emptyLabel="Aucune"}}
            </td>
          </tr>
          <tr>
            <th>
              {{mb_label object=$grossesse field=lieu_accouchement}}
            </th>
            <td>
              {{mb_field object=$grossesse field=lieu_accouchement}}
            </td>
          </tr>
          <tr>
            <th>
              {{mb_label object=$grossesse field=rques}}
            </th>
            <td>
              {{mb_field object=$grossesse field=rques form=editFormGrossesse}}
            </td>
          </tr>
          <tr>
            <td colspan="2" class="button">
              {{if $grossesse->_id}}
                <button type="button" class="save" onclick="this.form.onsubmit()">{{tr}}Save{{/tr}}</button>
                <button type="button" class="cancel"
                  onclick="confirmDeletion(this.form, {objName: '{{$grossesse}}', ajax: 1})">{{tr}}Delete{{/tr}}</button>
              {{else}}
                <button id="button_create_grossesse" type="button" class="save" onclick="this.form.onsubmit()">{{tr}}Create{{/tr}}</button>
              {{/if}}
            </td>
          </tr>
        </table>
      </td>
    {{if $grossesse->_id && $with_buttons}}
      <td id="list_historique">
      </td>
      <td class="narrow">
        <table class="tbl">
          <tr>
            <th class="title">Actions</th>
          </tr>
          <tr>
            <td>
              <button type="button" class="sejour_create" onclick="Tdb.editSejour('', '{{$grossesse->_id}}', '{{$grossesse->parturiente_id}}')">
                {{tr}}CSejour-title-create{{/tr}}
              </button><br/>
              <button type="button" class="consultation_create" onclick="Tdb.editRdvConsult('', '{{$grossesse->_id}}', '{{$grossesse->parturiente_id}}')">
                {{tr}}CConsultation-title-create{{/tr}}
              </button><br/>
              <button type="button" class="accouchement_create" onclick="Tdb.editAccouchement('', '', '{{$grossesse->_id}}', '{{$grossesse->parturiente_id}}', reloadHistorique)">
                {{tr}}CAccouchement-title-create{{/tr}}
              </button>
              <hr/>
              <select name="prat_id" id="selector_prat_imm" onchange="consultNow($V(this), '{{$grossesse->_id}}');" style="width:130px;">
                <option value="">&mdash; {{tr}}mod-dPcabinet-tab-ajax_short_consult{{/tr}}</option>
                {{foreach from=$prats item=_prat}}
                  <option value="{{$_prat->_id}}">{{$_prat}}</option>
                {{/foreach}}
              </select>
            </td>
          </tr>
        </table>
        <div id="list_historique"></div>
      </td>
    {{/if}}
  </tr></table>
</form>