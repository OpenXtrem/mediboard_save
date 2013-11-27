// $Id: $

Consultation = {
  edit: function(consult_id, fragment) {
    new Url().
      setModuleTab('cabinet', Preferences.new_consultation == "1" ? 'vw_consultation' : 'edit_consultation').
      addParam('selConsult', consult_id).
      setFragment(fragment).
      redirectOpener();
  },

  plan: function(consult_id) {
    new Url().
      setModuleTab('cabinet', 'edit_planning').
      addParam('consultation_id', consult_id).
      redirectOpener();
  },

  macroStats: function(button) { 
    var form = button.form;
    var url = new Url('cabinet', 'user_stats');
    url.addElement(form.period);
    url.addElement(form.date);
    url.addElement(form.type);
    url.requestModal(950, 600);
  },
  
  checkParams: function() {
    new Url('cabinet', 'check_params').requestModal(950);
  }
  
};
