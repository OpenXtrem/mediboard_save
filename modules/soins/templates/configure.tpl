<script>
  Main.add(function () {
    var tabs = Control.Tabs.create('tabs-configure', true);
    if (tabs.activeLink.key == "CConfigEtab") {
      Configuration.edit('soins', ['CGroups', 'CService CGroups.group_id'], $('CConfigEtab'));
    }
  });
</script>

<ul id="tabs-configure" class="control_tabs">
  <li>
    <a href="#soins">Dossier de soins</a>
  </li>
  <li onmousedown="Configuration.edit('soins', 'CGroups', $('CConfigEtab'))">
    <a href="#CConfigEtab">Config par établissement</a>
  </li>
</ul>

<div id="soins" style="display: none">
  {{mb_include module=soins template=inc_configure_soins}}
</div>

<div id="CConfigEtab" style="display: none"></div>