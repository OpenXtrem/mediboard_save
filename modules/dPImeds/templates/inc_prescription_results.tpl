<script type="text/javascript">

Main.add(function() {
  var oForm = document.Imeds_sejour_form;
  oForm.submit();
} );

</script>

<form target="Imeds-sejour" name="Imeds_sejour_form" action="{{$url}}?ctyp=s&amp;cidc={{$idImeds.cidc}}&amp;cdiv={{$idImeds.cdiv}}&amp;csdv={{$idImeds.csdv}}&amp;ndos={{$numPresc}}" method="post">
  <input type="hidden" name="login" value="{{$idImeds.login}}" />
  <input type="hidden" name="password" value="{{$idImeds.password}}" />
</form>

<iframe 
  id="Imeds-sejour" 
  name="Imeds-sejour" 
  onload="ViewPort.SetFrameHeight(this)"
  width="100%" 
  >
  Serveur de r�sultats indisponible pour le s�jour '{{$sejour->_view}}'
</iframe>