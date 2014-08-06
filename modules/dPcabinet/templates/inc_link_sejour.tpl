{{*
  * Relier une consultation � un s�jour
  *  
  * @category dPcabinet
  * @package  Mediboard
  * @author   SARL OpenXtrem <dev@openxtrem.com>
  * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
  * @version  SVN: $Id:$ 
  * @link     http://www.mediboard.org
*}}

<script>
  checkSejourId = function(form) {
    if ($V(form.sejour_id) && $V(form.consultation_ids)) {
      $('button_for_linking').show();
    } else {
      $('button_for_linking').hide();
    }
  };

  generateList = function() {
    var form = getForm("assign_sejour_to_consults");
    var ids = [];
    $$('input.consultation_to_link').each(function(elt){
      if (elt.checked) {
        ids.push(elt.value);
      }
    });
    $V(form.consultation_ids, ids.join("-"));
    checkSejourId(form);
  };

  Main.add(function() {
    generateList();
  })
</script>

<style>
  #list_sejour_to_link li, #list_consult_to_link li {
    list-style: none;
    margin:5px;
  }
</style>

<form method="post" name="assign_sejour_to_consults">
  <input type="hidden" name="consultation_ids" value=""/>
  <input type="hidden" name="m" value="dPcabinet"/>
  <input type="hidden" name="dosql" value="do_consultation_aed" />
  <table class="main">
    <tr>
      <td>
        <table class="tbl">
          <tr>
            <th colspan="2">{{tr}}CConsultation{{/tr}}(s)</th>
          </tr>
          <tbody>
          {{foreach from=$next_consults item=_consult}}
            <tr>
              <td>
                <input type="checkbox" class="consultation_to_link" name="consultation_id_{{$_consult->_id}}" value="{{$_consult->_id}}" {{if $consult->_id == $_consult->_id}}checked="checked"{{/if}} onclick="generateList();" />
              </td>
              <td>
                <label for="consultation_id_{{$_consult->_id}}">
                  <strong>{{$_consult->_datetime|date_format:$conf.datetime}}</strong> {{$_consult}}<br/>{{mb_include module=mediusers template=inc_vw_mediuser mediuser=$_consult->_ref_praticien}}
                  {{if $_consult->sejour_id}}
                    <div class="warning">D�j� li� � <span onmouseover="ObjectTooltip.createEx(this, '{{$_consult->_ref_sejour->_guid}}'); ">{{$_consult->_ref_sejour}}</span></div>
                  {{/if}}
                </label>
              </td>
            </tr>
            {{foreachelse}}
            <td colspan="2" class="empty">{{tr}}CConsultation.none{{/tr}}</td>
          {{/foreach}}
          </tbody>
        </table>
      </td>
      <td style="width:50%;">
        <table class="tbl">
          <tr>
            <th colspan="2">{{tr}}CSejour{{/tr}}</th>
          </tr>
          <tbody>
            <tr>
              <td><input type="radio" name="sejour_id" id="assign_sejour_to_consults_none" checked="checked" value="" onclick="checkSejourId(this.form);"/></td>
              <td>
                <label for="none">
                  {{tr}}None{{/tr}}
                </label>
              </td>
            </tr>
            {{foreach from=$sejours item=_sejour}}
              <tr>
                <td>
                  <input type="radio" name="sejour_id" id="assign_sejour_to_consults_sejour_id_{{$_sejour->_id}}" value="{{$_sejour->_id}}" onclick="checkSejourId(this.form);"/>
                </td>
                <td>
                  <label for="sejour_id_{{$_sejour->_id}}">
                    <span onmouseover="ObjectTooltip.createEx(this, '{{$_sejour->_guid}}');">[{{mb_value object=$_sejour field=type}}] {{$_sejour}}</span><br/>
                    {{mb_include module=mediusers template=inc_vw_mediuser mediuser=$_sejour->_ref_praticien}}
                  </label>
                </td>
              </tr>
            {{/foreach}}
          </tbody>
        </table>
      </td>
    </tr>
    <tr>
      <td colspan="2" class="button">
        <button class="submit" style="display: none;" id="button_for_linking">{{tr}}Save{{/tr}}</button>
        <button class="cancel" type="button" onclick="Control.Modal.close();">{{tr}}Cancel{{/tr}} {{tr}}and{{/tr}} {{tr}}Close{{/tr}}</button>
      </td>
    </tr>
  </table>
</form>