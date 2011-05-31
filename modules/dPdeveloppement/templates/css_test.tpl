<script type="text/javascript">
Main.add(function(){
  var buttonClasses = $w("none edit hslip trash submit modify save new print cancel search lookup lock tick down "+
    "up left left-disabled right right-disabled change add remove stop warning send send-cancel send-again send-problem send-auto vcard merge history");
                      
  var buttonsContainers = $$("#buttons td");
  buttonClasses.each(function(c){
    buttonsContainers[0].insert('<button class="'+c+' notext" title="button.'+c+' notext">'+c+'</button><br />');
    buttonsContainers[1].insert('<button class="'+c+'" title="button.'+c+'">'+c+'</button><br />');
    buttonsContainers[2].insert('<button class="'+c+' rtl" title="button.'+c+' rtl">'+c+'</button><br />');
    buttonsContainers[3].insert('<a href="#1" class="button '+c+' notext" title="a.button '+c+' notext">'+c+'</a><br />');
    buttonsContainers[4].insert('<a href="#1" class="button '+c+'" title="a.button '+c+'">'+c+'</a><br />');
    buttonsContainers[5].insert('<a href="#1" class="button '+c+' rtl" title="a.button '+c+' rtl">'+c+'</a><br />');
  });

  var form = getForm("test");
  Calendar.regField(form.dateTime);
  Calendar.regField(form.time);
  Calendar.regField(form.date);
  Calendar.regField(form.dateInline, null, {inline: true, container: $(form.dateInline).up(), noView: true});
});
</script>

<button class="new" onclick="showModalDialog('?m=dPdeveloppement&a=iframe_test&dialog=1', null, 'dialogHeight:600px;dialogWidth:900px;center:yes;resizable:no;scroll:no;')">showModalDialog</button>
<button class="new" onclick="open('?m=dPdeveloppement&a=iframe_test&dialog=1', 'test', '')">popup</button>

<hr />
<button class="change" onclick="$$('body')[0].toggleClassName('touchscreen')">Touchscreen</button>

<h1>header 1</h1>
<h2>header 2</h2>
<h3>header 3</h3>

<hr />

<ul class="control_tabs">
  <li><a href="#tab1">normal</a></li>
  <li><a href="#tab2" class="active">active</a></li>
  <li><a href="#tab3" class="empty">empty</a></li>
  <li><a href="#tab3" class="empty active">empty active</a></li>
  <li><a href="#tab4" class="wrong">wrong</a></li>
  <li><a href="#tab4" class="wrong active">wrong active</a></li>
</ul>
<hr class="control_tabs"/>

<table class="main">
  <tr>
    <td class="narrow">

<ul class="control_tabs_vertical">
  <li><a href="#tab1">normal</a></li>
  <li><a href="#tab2" class="active">active</a></li>
  <li><a href="#tab3" class="empty">empty</a></li>
  <li><a href="#tab3" class="empty active">empty active</a></li>
  <li><a href="#tab4" class="wrong">wrong</a></li>
  <li><a href="#tab4" class="wrong active">wrong active</a></li>
</ul>

    </td>
    <td class="narrow">
      
<table style="width: 0.1%;" id="buttons">
  <tr>
    <td></td>
    <td></td>
    <td style="text-align:right;"></td>
    <td></td>
    <td></td>
    <td style="text-align:right;"></td>
  </tr>
</table>

    </td>
    <td>
      
<table class="tbl">
  <tr>
    <th class="title" colspan="5">Title 1</th>
  </tr>
  <tr>
    <th>Title 1</th>
    <th>Title 2</th>
    <th>Title 3</th>
    <th>Title 4</th>
    <th class="disabled">disabled</th>
  </tr>
  <tr >
    <td class="highlight">highlight</td>
    <td class="ok">ok</td>
    <td class="warning">warning</td>
    <td class="error">error</td>
    <td class="disabled">disabled</td>
  </tr>
  <tr>
    <td>Cell 1 - 1</td>
    <td>Cell 1 - 2</td>
    <td>Cell 1 - 3</td>
    <td>Cell 1 - 4</td>
    <td>Cell 1 - 5</td>
  </tr>
  <tr>
    <td>Cell 2 - 1</td>
    <td colspan="2">Cell 2 - 2-3</td>
    <td>Cell 2 - 4</td>
    <td>Cell 2 - 5</td>
  </tr>
  <tr>
    <td colspan="5" class="text">
      <p>
        Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi. Proin porttitor, orci nec nonummy molestie, enim est eleifend mi, non fermentum diam nisl sit amet erat. Duis semper. Duis arcu massa, scelerisque vitae, consequat in, pretium a, enim. Pellentesque congue. Ut in risus volutpat libero pharetra tempor. Cras vestibulum bibendum augue. Praesent egestas leo in pede.
      </p>
    </td>
  </tr>
  <tr>
    <td>Cell 4 - 1</td>
    <td>Cell 4 - 2</td>
    <td>Cell 4 - 3</td>
    <td>Cell 4 - 4</td>
    <td>Cell 4 - 5</td>
  </tr>
</table>

<br />

<form action="?" name="test" method="post" onsubmit="return false">
<table class="form">
  <tr>
    <th class="title" colspan="4">Title 1</th>
  </tr>
  <tr>
    <th class="category" colspan="2">Category 1</th>
    <th class="category" colspan="2">Category 2</th>
  </tr>
  <tr>
    <th>
      <label class="notNull">Title 1</label>
    </th>
    <td>
      <input type="text" value="text" /><br />
      <input type="text" value="text" class="autocomplete" /><br />
      <input type="password" value="password" />
    </td>
    <th rowspan="2">
      <label>Title 2</label>
    </th>
    <td rowspan="2">
      <input type="hidden" class="date" name="dateInline" />
    </td>
  </tr>
  <tr>
    <th>
      <label class="canNull">Title 3</label>
    </th>
    <td>
      <textarea></textarea>
    </td>
  </tr>
  <tr>
    <th>
      <label class="notNullOK">Title 5</label>
    </th>
    <td>
      <select>
        <option style="background: url(./images/icons/cancel.png)">Option 1</option>
        <option value="1">Option 2</option>
        <option value="2">Option 3</option>
        <optgroup label="Optgroup 1">
          <option value="3">Option 4</option>
          <option value="4">Option 5</option>
        </optgroup>
      </select>
    </td>
    <th>
      <label>Title 6</label>
    </th>
    <td>
      <input type="file" />
    </td>
  </tr>
  <tr>
    <th>
      <label>Title 7</label>
    </th>
    <td>
      <input type="hidden" class="dateTime" name="dateTime" value="{{$smarty.now|@iso_datetime}}" />
    </td>
    <th>
      <label>Title 8</label>
    </th>
    <td>
      <input type="hidden" class="time" name="time" value="{{$smarty.now|@iso_time}}" />
    </td>
  </tr>
  <tr>
    <th>
      <label>Title 7</label>
    </th>
    <td>
      <input type="hidden" class="date" name="date" value="{{$smarty.now|@iso_date}}" />
    </td>
    <th>
      <label>Title 8</label>
    </th>
    <td>
      <input type="checkbox" /> 1
      <input type="checkbox" /> 2
      <br />
      <input type="radio" /> 1
      <input type="radio" /> 2
    </td>
  </tr>
  <tr>
    <td colspan="10">
      <button class="tick" type="button">button</button>
      <a class="button tick">a.button</a>
      <input type="checkbox" />
      <input type="radio" />
      <input type="text" />
      <select>
        <option>select</option>
      </select>
    </td>
  </tr>
  <tr>
    <td class="button" colspan="4">
      <button class="submit oneclick" type="submit">{{tr}}Save{{/tr}}</button>
      <button class="trash" type="button">{{tr}}Remove{{/tr}}</button>
    </td>
  </tr>
</table>
</form>

    </td>
    <td>

<div class="small-error">small-error</div>
<div class="small-warning">small-warning</div>
<div class="small-info">small-info</div>
<div class="small-success">small-success</div>

<div class="big-error">big-error</div>
<div class="big-warning">big-warning</div>
<div class="big-info">big-info</div>
<div class="big-success">big-success</div>

<div class="error">error</div>
<div class="warning">warning</div>
<div class="info">message</div>
<div class="loading">loading</div>

    </td>
  </tr>
</table>

<div id="tooltip-container"></div>