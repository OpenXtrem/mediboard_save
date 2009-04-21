{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage dPprescription
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

{{if $patient->_id}}
<!-- Footer du tableau -->
<tbody class="hoverable {{if !$no_class}}footer{{/if}} {{if $last_screen_footer}}last_footer{{/if}}">
  <tr>
	  <th class="title" colspan="2">Remarque</th>
	  <th class="title" colspan="2">Pharmacien</th>
	  <th class="title" colspan="{{$count_colspan.0}}">Signature IDE</th>
	  <th class="title" colspan="{{$count_colspan.1}}">Signature IDE</th>
	  <th class="title" colspan="{{$count_colspan.2}}">Signature IDE</th>
  </tr>
  <tr>
	  <td style="border: 1px solid #ccc; height: 1.5cm" colspan="2" rowspan="3"></td>
	  <td class="text" style="border: 1px solid #ccc; text-align: center" colspan="2" rowspan="3">
	  {{if $pharmacien->_id}}
	    {{$pharmacien->_view}} {{$last_log->date|date_format:$dPconfig.datetime}}
	  {{/if}}  
	  </td>
	  <td class="signature_ide" colspan="{{$count_colspan.0}}" ></td>
	  <td class="signature_ide" colspan="{{$count_colspan.1}}"></td>
	  <td class="signature_ide" colspan="{{$count_colspan.2}}"></td>
  </tr>
	<tr>
	  <td class="signature_ide" colspan="{{$count_colspan.0}}" ></td>
	  <td class="signature_ide" colspan="{{$count_colspan.1}}"></td>
	  <td class="signature_ide" colspan="{{$count_colspan.2}}"></td>
	</tr>
	<tr>
	  <td class="signature_ide" colspan="{{$count_colspan.0}}" ></td>
	  <td class="signature_ide" colspan="{{$count_colspan.1}}"></td>
	  <td class="signature_ide" colspan="{{$count_colspan.2}}"></td>
	</tr>
</tbody>
 {{/if}}