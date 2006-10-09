window.getInnerDimensions = function() {
  var viewH = document.documentElement.clientHeight;
  var viewW = document.documentElement.clientWidth;
  return {x:viewH,y:viewW}
}

Element.getOffsetHeightByClassName = function(class_name){
  var fHeightElem = 0;
  var aElementList = document.getElementsByClassName(class_name);
  for( var i = 0 ; i < aElementList.length ; i++ ){
	  fHeightElem += aElementList[i].offsetHeight;
  }
  return fHeightElem;
}

Element.getInnerWidth = function(element){
  element = $(element);
  var aBorderLeft = Element.getStyle(element,"border-left-width").split("px");
  var aBorderRight = Element.getStyle(element,"border-right-width").split("px");
  var fwidthElem = element.offsetWidth - parseFloat(aBorderLeft[0]) - parseFloat(aBorderRight[0])
  return fwidthElem; 
}

Element.getInnerHeight = function(element){
  element = $(element);
  var aBorderTop = Element.getStyle(element,"border-top-width").split("px");
  var aBorderBottom = Element.getStyle(element,"border-bottom-width").split("px");
  var fheightElem = element.offsetHeight - parseFloat(aBorderTop[0]) - parseFloat(aBorderBottom[0])
  return fheightElem; 
}

function waitingMessage(visibility){  
  if($('waitingMsgMask') && $('waitingMsgText')){
    if(visibility){
      
      $('waitingMsgText').show();
      var posTop  = document.documentElement.scrollTop + (document.documentElement.clientHeight/2) - ($('waitingMsgText').offsetHeight/2);
      var posLeft = document.documentElement.scrollLeft + (document.documentElement.clientWidth/2) - ($('waitingMsgText').offsetWidth/2);
      $('waitingMsgText').style.top = posTop + "px";
      $('waitingMsgText').style.left = posLeft + "px";
      
      $('waitingMsgMask').show();
      $('waitingMsgMask').style.height = document.documentElement.scrollHeight + "px";
      $('waitingMsgMask').style.width = document.documentElement.scrollWidth + "px";
      
    }else{
      $('waitingMsgText').hide();
      $('waitingMsgMask').hide();
    }
  }
}

