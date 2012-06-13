{{* $Id$ *}}

{{*
 * @package Mediboard
 * @subpackage forms
 * @version $Revision$
 * @author SARL OpenXtrem
 * @license GNU General Public License, see http://www.gnu.org/licenses/gpl.html
*}}

<script type="text/javascript">
toggleListCustom = function(form) {
  if (form._concept_type) {
    var concept_type = $V(form._concept_type);
    var enableList = (concept_type == "concept");
    
    var input = form.concept_id_autocomplete_view;
    var select = form._spec_type;
    
    if (input) {
      input.up(".dropdown").down(".dropdown-trigger").setVisibility(enableList);
      input.disabled = input.readOnly = !enableList;
    }
    
    if (enableList) {
      //$V(select, "none");
      $V(form.prop, "");
    }
    else {
      $V(input, "");
      $V(form.concept_id, "");
    }
    
    select.disabled = select.readOnly = !!$V(form.ex_class_field_id) || enableList;
  }
  
  ExFieldSpec.edit(form);
}

selectConcept = function(input) {
  ExFieldSpec.edit(input.form);

  if (!$V(input.form._locale)) {
    $V(input.form._locale, input.form.concept_id_autocomplete_view.value);
  }
}

Main.add(function(){
  var form = getForm("editField");
  var field_id = $V(form.ex_class_field_id);

  toggleListCustom.defer(form);
  form.elements._locale.select();

  {{assign var=_can_formula_arithmetic value=false}}
  {{assign var=_can_formula_concat value=false}}
    
  {{if $ex_field->_id}}
    {{assign var=_spec_type value=$ex_field->_spec_object->getSpecType()}}
    {{assign var=_can_formula_arithmetic value="CExClassField::formulaCanArithmetic"|static_call:$_spec_type}}
    {{assign var=_can_formula_concat value="CExClassField::formulaCanConcat"|static_call:$_spec_type}}
    
    {{if $_can_formula_arithmetic || $_can_formula_concat}}
      ExFormula.edit(field_id);
    {{/if}}
  {{/if}}

  Control.Tabs.create("ExClassField-param", true, {
    afterChange: function(newContainer){
      ExFormula.toggleInsertButtons(newContainer.id == "fieldFormulaEditor", "{{$_can_formula_arithmetic|ternary:'arithmetic':'concat'}}", '{{$ex_field->_id}}');
    }
  });
  
  // highlight current field
  $$("tr.ex-class-field.selected").invoke("removeClassName", "selected");
  
  var selected = $$("tr.ex-class-field[data-ex_class_field_id='{{$ex_field->_id}}']");
  
  if (selected.length) {
    selected[0].addClassName("selected");
  }
});
</script>

<form name="editField" method="post" action="?" data-object_guid="{{$ex_field->_guid}}" onsubmit="return onSubmitFormAjax(this, {onComplete: ExClass.edit.curry({{$ex_class->_id}})})">
  <input type="hidden" name="m" value="system" />
  <input type="hidden" name="dosql" value="do_ex_class_field_aed" />
  <input type="hidden" name="del" value="0" />
  <input type="hidden" name="callback" value="ExField.saveLatest" />
  
  <input type="hidden" name="_triggered_data" value="{{$ex_field->_triggered_data|@json|smarty:nodefaults|JSAttribute}}" />
  
  {{mb_key object=$ex_field}}
  {{mb_field object=$ex_field field=ex_group_id hidden=true}}
  
  <table class="form">
    
    {{assign var=object value=$ex_field}}
    <tr>
      {{if $object->_id}}
      <th class="title modify text" colspan="4">
        {{mb_include module=system template=inc_object_notes}}
        {{mb_include module=system template=inc_object_idsante400}}
        {{mb_include module=system template=inc_object_history}}
        {{tr}}{{$object->_class}}-title-modify{{/tr}} 
        '{{$object}}'
      </th>
      {{else}}
      <th class="title text" colspan="4">
        {{tr}}{{$object->_class}}-title-create{{/tr}} 
      </th>
      {{/if}}
    </tr>
    
    <tr>
      {{if $ex_field->_id}}
      
        <th>
          {{if $ex_field->concept_id}}
            Concept [liste/type]
          {{else}}
            Type
          {{/if}}
        </th>
        <td colspan="3">
          <strong>
            {{if $ex_field->concept_id}}
              {{mb_value object=$ex_field field=concept_id}}
              {{mb_field object=$ex_field field=concept_id hidden=true}}
            {{else}}
              {{tr}}CMbFieldSpec.type.{{$spec_type}}{{/tr}}
            {{/if}}
          </strong>
        </td>
        
      {{else}}
        
        <th>
          {{if !$conf.forms.CExClassField.force_concept}}
            <label>
              {{tr}}CExClassField-concept_id{{/tr}}
              <input type="radio" onclick="toggleListCustom(this.form)" name="_concept_type" value="concept" checked="checked" />
            </label>
          {{else}}
            <label for="concept_id">{{tr}}CExClassField-concept_id{{/tr}}</label>
          {{/if}}
        </th>
        
        <td>
          {{assign var=_prop value=$ex_field->_props.concept_id}}
          
          {{if $conf.forms.CExClassField.force_concept}}
            {{assign var=_prop value="$_prop notNull"}}
          {{/if}}
          
          {{mb_field object=$ex_field field=concept_id form="editField" autocomplete="true,1,50,true,true" 
                     onchange="selectConcept(this)" prop=$_prop}}
          <button class="new" onclick="ExConcept.createInModal()" type="button">{{tr}}CExConcept-title-create{{/tr}}</button>
        </td>
      
        {{if $conf.forms.CExClassField.force_concept}}
          <td colspan="2"></td>
        {{else}}
          <th>
            <label>
              Type personnalisé
              <input type="radio" onclick="toggleListCustom(this.form)" name="_concept_type" value="custom" />
            </label>
          </th>
          <td>
            <select name="_spec_type" onchange="ExFieldSpec.edit(this.form)">
              {{foreach from="CExClassField::getTypes"|static_call:null key=_key item=_class}}
                <option value="{{$_key}}" {{if $_key == $spec_type && !$ex_field->concept_id}}selected="selected"{{/if}}>
                  {{tr}}CMbFieldSpec.type.{{$_key}}{{/tr}}
                </option>
              {{/foreach}}
            </select>
          </td>
        {{/if}}
      {{/if}}
    </tr>
    
    <tr>
      <th style="width: 8em;">{{mb_label object=$ex_field field=_locale}}</th>
      <td>
        {{if $ex_field->_id}}
          {{mb_field object=$ex_field field=_locale size=30}}
        {{else}}
          {{mb_field object=$ex_field field=_locale size=30}}
        {{/if}}
      </td>
      
      <th>{{mb_label object=$ex_field field=_locale_court}}</th>
      <td>{{mb_field object=$ex_field field=_locale_court tabIndex="3" size=30}}</td>
    </tr>
    
    <tr>
      <th>{{mb_label object=$ex_field field=_locale_desc}}</th>
      <td>{{mb_field object=$ex_field field=_locale_desc tabIndex="2" size=30}}</td>
      
      <th><label for="ex_group_id">Groupe</label></th>
      <td>
        <select name="ex_group_id" style="max-width: 20em;">
          {{foreach from=$ex_class->_ref_groups item=_group}}
            <option value="{{$_group->_id}}" {{if $_group->_id == $ex_field->ex_group_id}}selected="selected"{{/if}}>{{$_group}}</option>
          {{/foreach}}
        </select>
      </td>
    </tr>
    
    <tr>
      <th>Report de valeur</th>
      <td colspan="3">
        {{assign var=class_options value=$ex_field->_ref_ex_group->_ref_ex_class->_host_class_options}}
        {{assign var=_host_class value=$ex_field->_ref_ex_group->_ref_ex_class->host_class}}
      
        {{if $ex_field->_id}}
          <select name="report_level" style="max-width: 16em;">
            <option value="">Aucun</option>
            
          {{if $_host_class != "CMbObject"}}
            <option value="host" {{if $ex_field->report_level == "host"}} selected="selected" {{/if}}>
              {{tr}}{{$_host_class}}{{/tr}}
            </option>
          {{/if}}
          
          {{if $class_options.reference1.0}}
            <option value="1" {{if $ex_field->report_level == "1"}} selected="selected" {{/if}}>
              {{if $class_options.reference1.1|strpos:"." === false}}
                {{tr}}{{$_host_class}}-{{$class_options.reference1.1}}{{/tr}}
              {{else}}
                {{tr}}{{$class_options.reference1.0}}{{/tr}}
              {{/if}}
            </option>
          {{/if}}
          
          {{if $class_options.reference2.0}}
            <option value="2" {{if $ex_field->report_level == "2"}} selected="selected" {{/if}}>
              {{if $class_options.reference2.1|strpos:"." === false}}
                {{tr}}{{$_host_class}}-{{$class_options.reference2.1}}{{/tr}}
              {{else}}
                {{tr}}{{$class_options.reference2.0}}{{/tr}}
              {{/if}}
            </option>
          {{/if}}
          </select>
        {{else}}
          <em>Enregistrez le champ avant de définir le type de report</em>
        {{/if}}
      </td>
    </tr>
    
    {{*
    <tr>
      <th>{{mb_label object=$ex_field field=predicate_id}}</th>
      <td colspan="3">
        {{mb_field object=$ex_field field=predicate_id form="editField" autocomplete="true,1,50,true,true" size=70}}
        <button class="new notext" onclick="ExFieldPredicate.create({{$ex_field->_id}})" type="button">{{tr}}New{{/tr}}</button>
      </td>
    </tr>
    *}}
    
    <tr>
      <td></td>
      <td colspan="3">
        {{if $ex_field->_id}}
          <button type="submit" class="modify">{{tr}}Save{{/tr}}</button>
          <button type="button" class="trash" onclick="confirmDeletion(this.form,{ajax:true,typeName:'le champ ',objName:'{{$ex_field->_view|smarty:nodefaults|JSAttribute}}'})">
            {{tr}}Delete{{/tr}}
          </button>
        {{else}}
          <button type="submit" class="submit">{{tr}}Create{{/tr}}</button>
        {{/if}}
      </td>
    </tr>
    
    <tr {{if $app->user_prefs.INFOSYSTEM == 0}}style="display: none"{{/if}}>
      <th></th>
      <td colspan="3">
        {{mb_field object=$ex_field field=prop readonly="readonly" size=50}}
      </td>
    </tr>
    
  </table>
</form>

<ul class="control_tabs" id="ExClassField-param">
  <li><a href="#fieldSpecEditor">Propriétés</a></li>

  {{if $ex_field->_id}}
    {{assign var=_spec_type value=$ex_field->_spec_object->getSpecType()}}
    {{assign var=_can_formula value="CExClassField::formulaCanResult"|static_call:$_spec_type}}
    
    {{if $_can_formula}}
      <li>
        <a href="#fieldFormulaEditor" {{if !$ex_field->formula}} class="empty" {{/if}} 
           style="background-image: url(style/mediboard/images/buttons/formula.png); background-repeat: no-repeat; background-position: 2px 2px; padding-left: 18px;">
          Formule / concaténation
        </a>
      </li>
    {{/if}}
    
    {{*
    <li>
      <a href="#fieldPredicates" {{if $ex_field->_ref_predicates|@count == 0}} class="empty" {{/if}}>
        {{tr}}CExClassField-back-predicates{{/tr}} <small>({{$ex_field->_ref_predicates|@count}})</small>
      </a>
    </li>
    *}}
  {{/if}}
</ul>
<hr class="control_tabs" />

<div id="fieldSpecEditor" style="white-space: normal; display: none;"></div>

<div id="fieldFormulaEditor" style="display: none;">
  Enregistrez le champ pour modifier sa formule
</div>

<div id="fieldPredicates" style="display: none;">
  {{if $ex_field->_id}}
    <button class="new" onclick="ExFieldPredicate.create('{{$ex_field->_id}}')">{{tr}}CExClassFieldPredicate-title-create{{/tr}}</button>
    
    <table class="main tbl" style="table-layout: fixed;">
      <tr>
        <th class="narrow"></th>
        <th>{{mb_title class=CExClassFieldPredicate field=operator}}</th>
        <th>{{mb_title class=CExClassFieldPredicate field=_value}}</th>
      </tr>
      {{foreach from=$ex_field->_ref_predicates item=_predicate}}
        <tr>
          <td>
            <button class="edit notext" onclick="ExFieldPredicate.edit({{$_predicate->_id}})">{{tr}}Edit{{/tr}}</button>
          </td>
          <td style="text-align: right;">{{mb_value object=$_predicate field=operator}}</td>
          <td>{{mb_value object=$_predicate field=_value}}</td>
        </tr>
      {{foreachelse}}
        <tr>
          <td colspan="3" class="empty">
            {{tr}}CExClassFieldPredicate.none{{/tr}}
          </td>
        </tr>
      {{/foreach}}
    </table>
  {{/if}}
</div>