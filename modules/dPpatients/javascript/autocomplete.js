// $Id$

var InseeFields = {
	initCPVille: function(sFormName, sFieldCP, sFieldCommune, sFieldFocus) {
  	var oForm = document.forms[sFormName];
  	
		// Populate div creation for CP
    var oField = oForm.elements[sFieldCP];
		var sPopulateDiv = sFieldCP + "_auto_complete";
		var oPopulateDiv = DOM.div( {
			className: "autocomplete", 
			id: sPopulateDiv, 
			style: "display: inline; width: 250px;"
  	} );
		$(oField).insert( { after: oPopulateDiv } );
		
    // Autocomplete for CP
		var url = new Url("dPpatients", "autocomplete_cp_commune");
		url.addParam("column", "code_postal");
		url.autoComplete(oField.id, sPopulateDiv , {
			minChars: 2,
			updateElement: function(selected) {
				InseeFields.updateCPVille(selected, sFormName, sFieldCP, sFieldCommune, sFieldFocus);
			}
		} );
		
    // Populate div creation for Commune
    var oField = oForm.elements[sFieldCommune];
    var sPopulateDiv = sFieldCommune + "_auto_complete";
    var oPopulateDiv = DOM.div( {
      className: "autocomplete", 
      id: sPopulateDiv, 
      style: "display: inline; width: 250px;"
    } );
    $(oField).insert( { after: oPopulateDiv } );
		
    // Autocomplete for Commune
    var url = new Url("dPpatients", "autocomplete_cp_commune");
    url.addParam("column", "commune");
    url.autoComplete(oField.id, sPopulateDiv , {
      minChars: 3,
      updateElement: function(selected) {
        InseeFields.updateCPVille(selected, sFormName, sFieldCP, sFieldCommune, sFieldFocus);
      }
    } );
	},
	
	updateCPVille: function(selected, sFormName, sFieldCP, sFieldCommune, sFieldFocus) {
    var oForm = document.forms[sFormName];
		
		// Valuate CP and Commune
		$V(oForm.elements[sFieldCP     ], selected.select(".cp"     )[0].textContent, true);
    $V(oForm.elements[sFieldCommune], selected.select(".commune")[0].textContent, true);
	  
		// Give focus
	  if (sFieldFocus){
	    $(sFormName + '_' + sFieldFocus).focus();
	  }
	}
}

function initPaysField(sFormName, sFieldPays, sFieldFocus){
  var sFieldId = sFormName + '_' + sFieldPays;
  var sCompleteId = sFieldPays + '_auto_complete';
	Assert.that($(sFieldId), "Pays field '%s'is missing", sFieldId);
	Assert.that($(sCompleteId), "Pays complete div '%s'is missing", sCompleteId);

  new Ajax.Autocompleter(
    sFieldId,
    sCompleteId,
    '?m=dPpatients&ajax=1&suppressHeaders=1&a=httpreq_do_pays_autocomplete&fieldpays='+sFieldPays, {
      method: 'get',
      minChars: 2,
      frequency: 0.15,
      updateElement : function(element) { 
        updateFields(element, sFormName, sFieldFocus, sFieldPays) 
      }
    }
  );
}