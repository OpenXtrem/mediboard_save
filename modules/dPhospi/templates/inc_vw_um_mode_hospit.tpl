{{*
 * $Id$
 *  
 * @category Hospi
 * @package  Mediboard
 * @author   SARL OpenXtrem <dev@openxtrem.com>
 * @license  GNU General Public License, see http://www.gnu.org/licenses/gpl.html 
 * @link     http://www.mediboard.org*}}

<td id="um_mode_hospi">
  <select name="type_autorisation_mode_hospitalisation">
    <option disabled selected>{{tr}}Choose{{/tr}}</option>
    {{foreach from=$um->_mode_hospitalisation item=_um_mode_hospit}}
      <option value="{{$_um_mode_hospit}}" {{if $uf->type_autorisation_mode_hospitalisation == $_um_mode_hospit}}selected{{/if}} >{{$_um_mode_hospit}}</option>
    {{/foreach}}
  </select>
</td>