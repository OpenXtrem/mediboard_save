// $Id: $

var CIM10Selector = {
  sForm     : null,
  sView     : null,
  sChir     : null,
  oUrl      : null,
  selfClose : true,
  options : {
    width : 600,
    height: 500
  },

  pop: function() {
    var oForm = document[this.sForm];
    this.oUrl = new Url();
    this.oUrl.setModuleAction("dPplanningOp", "code_selector");
    
    this.oUrl.addParam("chir", oForm[this.sChir].value);
    this.oUrl.addParam("type", "cim10");
    
    this.oUrl.popup(this.options.width, this.options.height, "CIM10 Selector");
  },
  
  set: function(code) {
    var oForm = document[this.sForm];
    oForm[this.sView].value = code;
  },
  
  // Peut �tre appel� sans contexte : ne pas utiliser this
  close: function() {
    CIM10Selector.oUrl.close();
  }

}
