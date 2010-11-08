{{* $Id: configure.tpl 6341 2009-05-21 11:52:48Z mytto $ *}}

{{*
 * @package Mediboard
 * @subpackage hprimxml
 * @version $Revision: 6341 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<form name="editConfig-schema" action="?m={{$m}}&amp;{{$actionType}}=configure" method="post" onsubmit="return checkForm(this)">
  <input type="hidden" name="dosql" value="do_configure" />
  <input type="hidden" name="m" value="system" />
  <table class="form">
    <tr>
      <th class="category" colspan="2">Global</th>
    </tr>
    {{mb_include module=system template=inc_config_bool var=concatenate_xsd}}
    <tr>
      <th class="category" colspan="2">Patients</th>
    </tr>
    {{mb_include module=system template=inc_config_bool var=mvtComplet}}
    
    <tr>
      <th class="category" colspan="2">PMSI</th>
    </tr>
    {{mb_include module=system template=inc_config_enum var=send_diagnostic values=evt_pmsi|evt_serveuretatspatient}}
    <tr>
      <td class="button" colspan="10">
        <button class="modify" type="submit">{{tr}}Save{{/tr}}</button>
      </td>
    </tr>
  </table>
</form>