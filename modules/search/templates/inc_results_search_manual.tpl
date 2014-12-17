{{*
 * $Id$
 *  
 * @category Search
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @link     http://www.mediboard.org*}}

{{mb_include module=system template=inc_pagination change_page="changePage" total=$nbresult current=$start step=30}}
<table class="tbl form" style="height: 70%" id="results_without_aggreg">
  <tbody>
  <tr>
    <th class="title" colspan="6">R�sultats ({{$nbresult}} obtenus en {{$time}}ms)
      <button class="print notext not-printable" type="button" onclick="$('results_without_aggreg').print();">
        {{tr}}Print{{/tr}}
      </button>
      <button class="download notext not-printable" type="button" onclick="Search.downloadCSV();">
        {{tr}}CSV{{/tr}}
      </button>
    </th>
  </tr>
  <tr>
    <th class="narrow">Date <br /> Type</th>
    <th>Document</th>
    <th class="narrow">Auteur</th>
    <th class="narrow">Patient</th>
    <th class="narrow not-printable">Pertinence</th>
    {{if $contexte == "pmsi" && "atih"|module_active}}<th></th>{{/if}}
  </tr>
  <tr>
    <th colspan="6" class="section">Tri�s par pertinence</th>
  </tr>
  {{foreach from=$results key=_key item=_result}}
    <tr>
      <td class="text">
        <span>{{$_result._source.date|substr:0:10|date_format:'%d/%m/%Y'}}</span>

        <div class="compact">{{tr}}{{$_result._type}}{{/tr}}</div>
      </td>
      <td class="text" onmouseover="ObjectTooltip.createEx(this, '{{$_result._type}}-{{$_result._id}}')">
        {{if $_result._source.title != ""}}
          <span>{{$_result._source.title|utf8_decode}}</span>
        {{else}}
          <span> ---- Titre non pr�sent ---</span>
        {{/if}}
        {{if $highlights}}
          <div class="compact">{{$highlights.$_key|purify|smarty:nodefaults}}</div>
        {{/if}}
      </td>
      {{if $_result._source.author_id}}
        {{assign var=author_id value=$_result._source.author_id}}
        <td>
          {{mb_include module=mediusers template=inc_vw_mediuser mediuser=`$authors.$author_id`}}
        </td>
      {{else}}
        <td class="empty">Utilisateur inconnu</td>
      {{/if}}


      {{if $_result._source.patient_id}}
        <td class="compact">
          {{assign var=patient_id value=$_result._source.patient_id}}
          <span onmouseover="ObjectTooltip.createEx(this, 'CPatient-{{$patient_id}}')">{{$patients.$patient_id}}</span>
        </td>
      {{else}}
        <td class="empty">Patient inconnu</td>
      {{/if}}

      <td class="not-printable">
        {{assign var=score value=$_result._score*100}}
        <meter min="0" max="100" value="{{$score}}" low="50.0" optimum="101.0" high="70.0" style="width:100px;" title="{{$score}}%">
          <div class="progressBar compact text">
            <div class="bar normal" style="width:{{$score}}%;"></div>
            <div class="text">{{$score}}%</div>
          </div>
        </meter>
      </td>
      {{if $contexte == "pmsi" && "atih"|module_active}}
        <td class="button narrow not-printable">
          <button class="add notext" onclick="Search.addItemToRss(null, '{{$sejour_id}}', '{{$_result._type}}', '{{$_result._id}}', null)"></button>
        </td>
      {{/if}}
    </tr>
    {{foreachelse}}
    <tr>
      <td colspan="6" class="empty" style="text-align: center">
        Aucun document ne correspond � la recherche
      </td>
    </tr>
  {{/foreach}}
  </tbody>
</table>