<strong>Techniques Complémentaires</strong>
<ul>
  {{foreach from=$consult_anesth->_ref_techniques item=curr_tech}}
  <li>
    <form name="delTrmtFrm{{$curr_tech->technique_id}}" action="?m=dPcabinet" method="post">
    <input type="hidden" name="m" value="dPcabinet" />
    <input type="hidden" name="del" value="1" />
    <input type="hidden" name="dosql" value="do_technique_aed" />
    {{mb_field object=$curr_tech field="technique_id" hidden=1 prop=""}}
    <button class="trash notext" type="button" onclick="submitTech(this.form)">
    </button>
    {{$curr_tech->technique}}
    </form>
  </li>
  {{foreachelse}}
  <li>Pas de technique complémentaire</li>
  {{/foreach}}
</ul>