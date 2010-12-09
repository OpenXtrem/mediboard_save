{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage {subpackage}
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<script type="text/javascript">

ExFieldSpec.options = {{$spec->getOptions()|@json}};

ElementChecker.check.regex = function(){
  this.assertMultipleArgs("regex");
  if (!(new RegExp(this.oProperties["regex"])).test(this.sValue))
    this.addError("regex", "Doit respecter l'expression r�guli�re /"+this.oProperties["regex"]+"/");
}.bind(ElementChecker);

updateFieldSpec = function(nocheck){
  var form = getForm("editFieldSpec");
  if (nocheck && !checkForm(form)) return;
  
  var data = form.serialize(true);
  var fields = {};
  var str = "{{$spec->getSpecType()}}";
  
  var translations = data["__enum[]"];
  if (translations) {
    translations.pop(); // pour supprimer l'element vide
    delete data["__enum[]"];
  }
  
  Object.keys(data).each(function(k){
    var d = data[k];
    
    if (d !== "") {
      if (Object.isArray(d)) {
        d = d.filter(function(e){return e !== ""});
        if (d.length == 0) return;
      }
      
      str += " "+(k.split("[")[0]);
      
      if (Object.isArray(d))
        str += "|"+d.invoke("replace", /\s|\|/g, "").join("|");
      else {
        var v = d.strip();
        if (ExFieldSpec.options[k] != "bool" || v != "1") {
          str += "|"+v;
        }
      }
      
      fields[k] = d;
    }
  });
  
  str = str.strip();
  ExFieldSpec.prop = str;
  
  var fieldForm = getForm("editField");
  $V(fieldForm.prop, str);
  
  if (translations)
    $V(fieldForm._enum_translation, Object.toJSON(translations));
}

avoidSpaces = function(event) {
  var key = Event.key(event);
  if (key == 32) Event.stop(event);
}

cloneTemplate = function(input) {
  var template = $(input).previous('.template');
  var clone = template.clone(true).observe("change", updateFieldSpec);
  template.insert({before: clone.show().removeClassName('template')});
}

Main.add(function(){
  var form = getForm("editFieldSpec");
  form.select("input.nospace").invoke("observe", "keypress", avoidSpaces);
  form.select("input, select").invoke("observe", "change", updateFieldSpec.curry(true));
  updateFieldSpec(true);
});
</script>

<form name="editFieldSpec" action="?" method="get" onsubmit="return false">
  
<table class="main form">
  <tr>
    <th class="category" style="width: 12em;">Option</th>
    <th class="category">Valeur</th>
  </tr>
  
  {{foreach from=$options item=_type key=_name}}
    <tr>
      <th><label for="{{$_name}}">{{$_name}}</label></th>
      <td>
        {{* str *}}
        {{if $_type == "str"}}
          <input type="text" name="{{$_name}}" value="{{$spec->$_name}}" class="str nospace regex|^\s*[^\s\|]*\s*$" />
          
        {{* num *}}
        {{elseif $_type == "num"}}
          <input type="text" name="{{$_name}}" value="{{$spec->$_name}}" class="str nospace regex|^\s*-?[\d\.]*\s*$" size="2" />
          
        {{* bool *}}
        {{elseif $_type == "bool"}}
          <label><input type="radio" name="{{$_name}}" value="" {{if $spec->$_name === null || $spec->$_name === ""}}checked="checked"{{/if}} /> Ind�fini</label>
          <label><input type="radio" name="{{$_name}}" value="0" {{if $spec->$_name === 0 || $spec->$_name === "0"}}checked="checked"{{/if}} /> Non</label>
          <label><input type="radio" name="{{$_name}}" value="1" {{if $spec->$_name == 1}}checked="checked"{{/if}} /> Oui</label>
          
        {{* enum *}}
        {{elseif is_array($_type)}}
          {{foreach from=$_type item=_type}}
          <label><input type="radio" name="{{$_name}}" value="{{$_type}}" {{if $spec->$_name === $_type}}checked="checked"{{/if}} /> {{$_type}} </label>
          {{/foreach}}
          
        {{* field *}}
        {{elseif $_type == "field"}}
          {{if $other_fields|@count}}
            <select name="{{$_name}}">
              <option value=""> &mdash; </option>
              {{foreach from=$other_fields item=_other_field}}
                <option value="{{$_other_field}}" {{if $_other_field == $spec->$_name}}selected="selected"{{/if}}>{{$_other_field}}</option>
              {{/foreach}}
            </select>
          {{else}}
            <input type="hidden" name="{{$_name}}" value="" />
            <span style="color: #999">Aucun autre champ</span>
          {{/if}}
          
        {{* list *}}
        {{elseif $_type == "list"}}
          {{foreach from=$spec->_list key=_key item=_value}}
            <div>
              <input type="text" name="{{$_name}}[]" value="{{$_value}}" />
              Traduction: <input type="text" name="__enum[]" value="{{$spec->_locales.$_value}}" />
              <button type="button" class="cancel notext" onclick="$(this).up().remove(); updateFieldSpec();">{{tr}}Delete{{/tr}}</button>
            </div>
          {{/foreach}}
          
          <div style="display: none;" class="template">
            <input type="text" name="{{$_name}}[]" value="" />
            Traduction: <input type="text" name="__enum[]" value="" />
            <button type="button" class="cancel notext" onclick="$(this).up().remove(); updateFieldSpec();">{{tr}}Delete{{/tr}}</button>
          </div>
          
          <button type="button" class="add notext" onclick="cloneTemplate(this)">{{tr}}Add{{/tr}}</button>
          
        {{* class *}}
        {{elseif $_type == "class"}}
          <select name="{{$_name}}">
            {{foreach from=$classes item=_value}}
              <option value="{{$_value}}" {{if $_value == $spec->class}}selected="selected"{{/if}}>{{$_value}}</option>
            {{/foreach}}
          </select>
          
        {{/if}}
      </td>
    </tr>
  {{/foreach}}
</table>
</form>