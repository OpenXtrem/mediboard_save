{{*
  * header of hprim medecin
  *  
  * @category Hprim21
  * @package  Mediboard
  * @author   SARL OpenXtrem <dev@openxtrem.com>
  * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
  * @version  SVN: $Id:$ 
  * @link     http://www.mediboard.org
*}}

<table class="main form">
  <tr>
    <th colspan="4" class="title">{{$header.1}} {{$header.2}} &ndash; {{$header.6}} [{{$header.8}}]</th>
  </tr>
  <tr>
    <th>Exp�diteur</th>
    <td>
      {{if $header.10}}
        <small>
          [{{$header.10.0}}]
        </small>
        {{$header.10.1}} {{if $header.10.11}}{{$header.10|substr:11}}{{/if}}
      {{/if}}
    </td>

    <th>Destinataire</th>

    <td>
      {{if $header.11}}
        <small>
          [{{$header.11.0}}]
        </small>
        {{$header.11.1}} {{if $header.11.11}}{{$header.11|substr:11}}{{/if}}
      {{/if}}
    </td>
  </tr>
  <tr>
    <td colspan="4"><hr /></td>
  </tr>
  <tr>
    <th>Adresse</th>
    <td>
    {{$header.3}}<br />
    {{$header.4}}<br />
    {{$header.5}}
    </td>

    <th>Num�ro de s�curit� sociale</th>
    <td>{{$header.7}}</td>
  </tr>
</table>