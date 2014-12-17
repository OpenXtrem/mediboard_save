{{*
 * $Id$
 *  
 * @category Search
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @link     http://www.mediboard.org*}}

<table class="tbl form" style="height: 70%">
  <tbody>
  <tr>
    <th class="title" colspan="6">R�sultats ({{$nbresult}} obtenus en {{$time}}ms)</th>
  </tr>
  <tr>
    <th class="narrow">Date <br /> Type</th>
    <th>Document</th>
    <th class="narrow">Auteur</th>
    <th class="narrow">Pertinence</th>
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
      <td class="text">
        <span> {{$_result._source.body}}</span>
        {{if $highlights.$_key}}
          <div class="compact">{{$highlights.$_key|purify|smarty:nodefaults}}</div>
        {{/if}}
      </td>
      {{if $_result._source.user_id}}
        {{assign var=user_id value=$_result._source.user_id}}
        <td>
          {{mb_include module=mediusers template=inc_vw_mediuser mediuser=`$authors.$user_id`}}
        </td>
      {{else}}
        <td class="empty">Utilisateur inconnu</td>
      {{/if}}

      <td>
        {{assign var=score value=$_result._score*100}}
        <meter min="0" max="100" value="{{$score}}" low="50.0" optimum="101.0" high="70.0" style="width:100px;" title="{{$score}}%">
          <div class="progressBar compact text">
            <div class="bar normal" style="width:{{$score}}%;"></div>
            <div class="text">{{$score}}%</div>
          </div>
        </meter>
      </td>
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