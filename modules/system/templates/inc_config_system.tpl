{{* $Id: configure.tpl 7814 2010-01-12 17:26:57Z rhum1 $ *}}

{{*
 * @package Mediboard
 * @subpackage system
 * @version $Revision: 7814 $
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<script type="text/javascript">
Main.add(function(){
  var input = getForm("editConfig-system")["migration[limit_date]"];
  input.className = "date";
  input.type = "hidden";
  Calendar.regField(input);
});
</script>

<form name="editConfig-system" action="?m=system&amp;{{$actionType}}=configure" method="post" onsubmit="return checkForm(this)">
  <input type="hidden" name="dosql" value="do_configure" />
  <input type="hidden" name="m" value="system" />
  <table class="form" style="table-layout: fixed;">
    
    {{mb_include module=system template=inc_config_str var=root_dir size=40}}
    {{mb_include module=system template=inc_config_enum var=instance_role values="prod|qualif"}}
    {{mb_include module=system template=inc_config_str var=mb_id}}
    {{mb_include module=system template=inc_config_bool var=debug}}
    {{mb_include module=system template=inc_config_bool var=readonly}}
    {{mb_include module=system template=inc_config_enum var=minify_javascript values="0|1|2"}}
    {{mb_include module=system template=inc_config_bool var=alternative_mode}}
    
    {{assign var="m" value="system"}}
    {{mb_include module=system template=inc_config_str var=reverse_proxy}}
    {{mb_include module=system template=inc_config_str var=website_url size=40}}
    
    <tr>
      <th colspan="2" class="title">
        Mode migration
      </th>
    </tr>
  
    {{assign var="m" value="migration"}}
    {{mb_include module=system template=inc_config_bool var=active}}
    {{mb_include module=system template=inc_config_str var=intranet_url size=40}}
    {{mb_include module=system template=inc_config_str var=extranet_url size=40}}
    {{mb_include module=system template=inc_config_str var=limit_date}}
    
    <tr>
      <td class="button" colspan="2">
        <button class="modify" type="submit">{{tr}}Save{{/tr}}</button>
      </td>
    </tr>
  </table>
</form>