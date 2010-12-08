{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage bloodSalvage
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<table class="form">
  <tr>
	<td style="text-align:center;">
	  <b>Dur�e totale RSPO : </b>
	  {{$totaltime|date_format:$conf.time}}
	</td>
	</tr>
</table>
{{if $totaltime > "05:00:00" && $totaltime < "06:00:00" }} 
  <div class="small-warning" style="text-align:center;">
    Limite l�gale de 6 heures bient�t atteinte ! <br />
    <b>Temps restant : {{$timeleft|date_format:$conf.longtime}}</b>
  </div>
{{/if}}
{{if $totaltime > "06:00:00"}} 
  <div class="small-error" style="text-align:center;">
    Limite l�gale de 6 heures d�pass�e !
  </div>
{{/if}}
