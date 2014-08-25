{{mb_script module=system script=useragent}}

<script>
  Main.add(function() {
    var form = getForm("filter_graph");
    Calendar.regField(form._min_date);
    Calendar.regField(form._max_date);

    form.onsubmit();
  });

  function changePage(start) {
    var form = getForm("filter_graph");
    $V(form.elements.start, start);
    form.onsubmit();
  }
</script>

<form name="filter_graph" action="" method="get" onsubmit="return onSubmitFormAjax(this, null, 'browser_results');">
  <input type="hidden" name="m" value="system" />
  <input type="hidden" name="a" value="ajax_search_user_agents" />
  <input type="hidden" name="start" value="0" />

  <table class="form">
    <tr>
      <th class="narrow">{{tr}}Period{{/tr}}</th>
      <td>
        <input type="hidden" class="dateTime" id="_min_date" name="_min_date" value="{{$min_date}}" onchange="$V(this.form.elements.start, '0');" />
        <b>&raquo;</b>
        <input type="hidden" class="dateTime" id="_max_date" name="_max_date" value="{{$max_date}}" onchange="$V(this.form.elements.start, '0');" />

        <button type="submit" class="search ">{{tr}}Search{{/tr}}</button>
      </td>
    </tr>
  </table>
</form>

<div id="browser_results"></div>