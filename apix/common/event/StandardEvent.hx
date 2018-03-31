/**
 * Copyright (c) jm Delettre.
 * 
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

 

package apix.common.event ;
import apix.common.tools.math.Vector;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.common.util.Object;
//
#if (js)
	using apix.common.display.ElementExtender;
#end
/**
 * Events manager package.
 * 
 * Used to send to listeners, datas from EventSource and from class which has called EventSource.bind(), 
 *<br/>super class for other events 
 *<br/>implements dynamic but it's better to extend StandardEvent and add static properties.
 */

//
class KeyPressEvent extends ElemKeyboardEvent {
	public var keyChr : String;
	public var keyChrLower : String;
}
/**
 * special Chrome
 */
class SysContextMenuEvent extends ElemEvent {
	public var path (default, null) :  Array<Elem> ;
	public var clientX (default, null) :  Float ;
	public var clientY (default, null) :  Float ;
	public var pageX (default, null) :  Float ;
	public var pageY (default, null) :  Float ;
	public var screenX (default, null) :  Float ;
	public var screenY (default, null) :  Float ;
}
/**
 *	MouseTouchEvent works for any device (computer or mobile ; mouse or touch)  
 */
class MouseTouchEvent extends ElemMouseEvent {
	public var changedTouches(default, null) : ElemTouchList;
	/**
	 * to be used with Element.getVector() (see ElementExtender)
	 * i.e.
	 * 	MouseTouchEvent.getVector(e).sub(containerElement.getVector()) ==> mouse position vector relative to upper/left of container element.
	 */
	public static function getVector (e:MouseTouchEvent) : Vector { 
		var g = Global.get(); 		
		var ex:Float = Math.fround(g.isMobile?(e.changedTouches==null?e.pageX:e.changedTouches[0].pageX):e.pageX);
		var ey:Float = Math.fround(g.isMobile?(e.changedTouches == null?e.pageY:e.changedTouches[0].pageY):e.pageY);		
		return new Vector(ex,ey) ;
	}
	public inline static function getLocalVector (e:MouseTouchEvent, ctnr:Elem) : Vector { 
		return MouseTouchEvent.getVector(e).sub(ctnr.getVector());
	}
}
 class StandardEvent implements Dynamic {
   /** 
	* Input Events
	* onblur - When a user leaves an input field
	* onchange - When a user changes the content of an input field
	* onchange - When a user selects a dropdown value
	* onfocus - When an input field gets focus
	* onselect - When input text is selected
	* onsubmit - When a user clicks the submit button
	* onreset - When a user clicks the reset button
	* onkeydown - When a user is pressing/holding down a key
	* onkeypress - When a user is pressing/holding down a key
	* onkeyup - When the user releases a key
	* onkeyup - When the user releases a key
	* onkeydown vs onkeyup - Both
}

	* Mouse Events
	* onmouseover/onmouseout - When the mouse passes over an element
	* onmousedown/onmouseup - When pressing/releasing a mouse button
	* onmousedown - When mouse is clicked: Alert which element
	* onmousedown - When mouse is clicked: Alert which button
	* onmousemove/onmouseout - When moving the mouse pointer over/out of an image
	* onmouseover/onmouseout - When moving the mouse over/out of an image
	* onmouseover an image map

	* Click Events
	* Acting to the onclick event
	* onclick - When button is clicked
	* ondblclick - When a text is double-clicked

	* Load Events
	* onload - When the page has been loaded
	* onload - When an image has been loaded
	* onerror - When an error occurs when loading an image
	* onunload - When the browser closes the document
	* onresize - When the browser window is resized
	*/
	 
	 
		   static 			var g:Global = Global.get(); 
	public static 			var msPointer:Bool = (untyped Common.window.navigator.msPointerEnabled); 
	public static inline  	var CLICK : String = "click";
	public static inline  	var DBL_CLICK : String = "dblclick";
	public static   		var MOUSE_DOWN : String = (msPointer)?"MSPointerDown":((g.isMobile)?"touchstart":"mousedown");
	public static 			var MOUSE_MOVE : String = (msPointer)?"MSPointerMove":((g.isMobile)?"touchmove":"mousemove"); 
	public static 		  	var MOUSE_OUT : String = (msPointer)?"MSPointerOut":((g.isMobile)?"touchend":"mouseout"); 
	public static 		  	var MOUSE_OVER : String = (msPointer)?"MSPointerOver":((g.isMobile)?"touchstart":"mouseover"); 
	public static 			var MOUSE_UP : String = (msPointer)?"MSPointerUp":((g.isMobile)?"touchend":"mouseup"); 
	public static inline  	var MOUSE_WHEEL : String = "mousewheel";
	public static inline  	var TOUCH_START : String = "touchstart";
	public static inline  	var TOUCH_MOVE : String = "touchmove";
	public static inline  	var TOUCH_END : String = "touchend";
	public static inline  	var TOUCH_CANCEL : String = "touchcancel";
	public static inline  	var RESIZE : String = "resize";
	
	/*
	public static inline  var MOUSE_DOWN : String = "MSPointerDown";
	this.element.addEventListener(“MSPointerDown”, eventHandlerName, false);
			this.element.addEventListener(“MSPointerMove”, eventHandlerName, false);
			this.element.addEventListener(“MSPointerUp”, eventHandlerName, false);
	*/
	public static inline  var CHANGE : String = "change";
	public static inline  var BLUR : String = "blur";
	public static inline  var INPUT : String = "input";
	public static inline  var FOCUS : String = "focus";
	public static inline  var SELECT : String = "select";
	public static inline  var CONTEXT_MENU : String = "contextmenu";
	//
	/**
	 * <b> data:</b> Used to store -facultatives- parameters sent by "on()" caller to the listener method.
	 * NOT TO BE USED BY dispatcher
	 */
	public var data:Dynamic;
	/**
	 * <b> target:</b> EventSource instance.
	 */
	public var target:Dynamic;	
	/**
	 * Constructor
	 * <br/><b>target:</b> Event source dispatcher.
	 * <br/><b>type:</b> Type of event - change, finish, loadData, errorLoadData, etc.
	 * <br/><b>message:</b>A simple message from event source.
	 */
    public function new (target:Dynamic) { 
		this.target = target;
	}
	/**
	 * 
	 * @param	v	event type
	 * @return  true for type which need hand cursor .
	 */
	static public function isMouseType(v:String) {
		for (i in [CLICK, DBL_CLICK, MOUSE_DOWN, MOUSE_OVER] ) {
			if (i == v) return true ; 
		} 
		return false ;		
	}
	
	/**
	 * use it only if you don't use StandardEvent static var
	 * @param	type Event type
	 * @return  touch , MS or mouse event type.
	 */
	static public function convertEventType(type:String) : String {
		if (type == "mousedown" || type == "touchstart" || type == "MSPointerDown")  type = StandardEvent.MOUSE_DOWN ;
		else if (type == "mouseup" || type == "touchend" || type == "MSPointerUp")  type = StandardEvent.MOUSE_UP ;
		else if (type == "mousemove" || type == "touchmove" || type == "MSPointerMove")  type = StandardEvent.MOUSE_MOVE ;
		return type;
	}	
	
}
	
	