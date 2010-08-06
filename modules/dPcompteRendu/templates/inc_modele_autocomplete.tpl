<ul style="text-align: left;">
  {{foreach from=$modeles item=_modele}}
    <li>
      {{if $_modele->_owner == "user"}}
        {{assign var=owner_icon value="user"}}
      {{elseif $_modele->_owner == "func"}}
        {{assign var=owner_icon value="user-function"}}
      {{else}}
        {{assign var=owner_icon value="group"}}
      {{/if}}
      
      <img style="float: right; clear: both;" 
        src="images/icons/{{$owner_icon}}.png" />
      
      {{if $_modele->fast_edit}}
        <img style="float:right;"
          src = "images/buttons/pdf.png"/>
      {{/if}}
      
      <div {{if $_modele->fast_edit}}class="fast_edit"{{/if}}>
        {{$_modele->nom|emphasize:$keywords}}
      </div>
      <small style="color: #666; margin-left: 1em;" class="text">
        {{mb_value object=$_modele field=file_category_id}}
      </small>
      
      <div style="display: none;" class="id">{{$_modele->_id}}</div>
    </li>
  {{/foreach}}
</ul>