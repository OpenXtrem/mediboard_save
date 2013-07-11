{{*
 * $Id$
 *  
 * @category Messagerie
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html
 * @version  $Revision$
 * @link     http://www.mediboard.org
*}}

<h1>Mail {{$mail_id}}, {{$overview->subject}}</h1>

<table class="main">
  <tr>
    <td>
      <table class="tbl">
        <tr>
          <th class="title" colspan="2">Overview</th>
        </tr>
        {{foreach from=$overview key=key item=value}}
          <tr>
            <th>{{$key}}</th>
            <td>{{$value}}</td>
          </tr>
        {{/foreach}}
      </table>
      <table class="tbl">
        <tr>
          <th class="title">Structure</th>
        </tr>
        <tr>
          <td>
            {{$structure|mbTrace}}
          </td>
        </tr>
      </table>
      <table class="tbl">
        <tr>
          <th class="title" colspan="2">Infos</th>
        </tr>
        {{foreach from=$infos key=key item=value}}
          <tr>
            <th>{{$key}}</th>
            <td>
              {{if is_array($value)}}
                {{$value|@mbTrace}}
              {{else}}
                {{$value}}
              {{/if}}
            </td>
          </tr>
        {{/foreach}}
      </table>
    </td>
  </tr>
</table>