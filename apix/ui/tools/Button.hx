package apix.ui.tools;
//
import apix.common.event.EventSource;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo.UICompoLoader;
import apix.common.event.StandardEvent;
//
import apix.ui.UICompo;
import haxe.Http; 

//using
using apix.common.util.StringExtender;
//
#if (js)
	using apix.common.display.ElementExtender;
#end
//
typedef ButtonProp = { 
	> CompoProp ,
	/**
	 * input type.
	 */
	?callBack:ElemEvent->Void,
	?value:String,
	?img:String,
	?alt:String,
	
} 
class ButtonEvent extends StandardEvent {
	public var value:String;
	public var id:String;
	public var event:ElemMouseEvent;
	public function new (target:Button, value:String, id:String,event:ElemMouseEvent) { 
		super(target);
		this.value = value;
		this.id = id;
		this.event = event;
	}	
}
/*
Property	Description	DOM
bubbles	Returns whether or not a specific event is a bubbling event	2
cancelable	Returns whether or not an event can have its default action prevented	2
currentTarget	Returns the element whose event listeners triggered the event	2
defaultPrevented	Returns whether or not the preventDefault() method was called for the event	3
eventPhase	Returns which phase of the event flow is currently being evaluated	2
isTrusted	Returns whether or not an event is trusted	3
target	Returns the element that triggered the event	2
timeStamp	Returns the time (in milliseconds relative to the epoch) at which the event was created	2
type	Returns the name of the event	2
view	Returns a reference to the Window object where the event occured*/
/**
 * In properties
 * @param  into			#+container id
 * @param  skin			skinName
 * @param  id 			Compo Elem id
 * @param  name			uiCompo name
 * @param  auto			true if auto enable
 * 
 * @param  callBack		called on click
 * @param  value
 */

/**
 * Event
 * @source  input 
 * @param		target				this
 * @param		value				value
 * @param		inputElement		<input> Element
 * @param		id					this Element id
 */
//
class Button extends UICompo    {
	static public inline var VALUE_DEFAULT :String = "OK" ;
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX + "label" ;	
	static public inline var IMG_CLASS :String = UICompo.APIX_PRFX + "img" ;	
	//
	var labelElement(default,null):Elem;	
	var imgElement(default,null):Elem;	
	//
	/**
	 * event dispatcher when a InputField's char append 
	 * @see InputFieldEvent
	 */	
	public var click	(default, null):EventSource ;
	//getter
	public var callBack(get, null):ButtonEvent->Void;	
	public var img(get, null):String;	
	public var alt(get, null):String;	
	/**
	* constructor
	* @param ?p ButtonProp
	*/
	public function new (?p:ButtonProp) {
		click = new EventSource();
		super(); 
		compoSkinList = ButtonLoader.__compoSkinList;
		setup(p);		
	}
	/**
	 * setup  ButtonProp
	 * @param ?p ButtonProp
	 * @return this
	 */
	override public function setup (?p:ButtonProp) :Button {	
		setCompoProp(p);
		if (isInitialized()) {
			if (!isCreated()) create();
			if (ctnrExist()) {
				if (!isEnabled() ) enable();
				update();	
			}
		}
		return this;
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :Button {	
		element.on(StandardEvent.CLICK,onClick);
		labelElement = ("#" + id + " ." + Button.LABEL_CLASS).get();
		imgElement = ("#" + id + " ." + Button.IMG_CLASS).get();
		enabled = true;	
		return this;
	}
	override public function remove ()  : Button{	
		super.remove();
		element.off(StandardEvent.CLICK, onClick);
		if (click.hasListener()) click.off();
		element.delete();
		return this;
	}
		
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override public function update() : Button {	
		if (labelElement != null) labelElement.text(value);		
		else element.text(value);	
		element.css("width", width);			
		element.css("height", height);	
		if (img != "") {
			imgElement.attr("src", img);
			imgElement.attr("alt", alt);
			
		}
		return this;
	}	
	/**
	 * private  
	 */	
	
	function onClick (e:ElemMouseEvent) {	
		var evt = null;
		if (callBack != null) {
			evt = new ButtonEvent(this, value, id, e);
			callBack(evt);
		}
		if (click.hasListener()) {
			if (evt==null) evt=new ButtonEvent(this, value, id, e);
			click.dispatch(evt);	
		}
	}
	override function get_value () :String {
		var v:String=null;
		if (compoProp.value != null) v = compoProp.value ;
		else {
			v = Button.VALUE_DEFAULT;	
		}
		compoProp.value = v;		
		return v;
	}		
	function get_callBack () :ButtonEvent->Void {
		var v:ButtonEvent->Void=null;
		if (compoProp.callBack != null) v = compoProp.callBack ;
		compoProp.callBack = v;		
		return v;
	}
	function get_img () :String {
		var v:String=null;
		if (compoProp.img != null) v = compoProp.img ;
		else {
			v = "" ;			
		}
		compoProp.img = v;		
		return v;
	}
	function get_alt () :String {
		var v:String=null;
		if (compoProp.alt != null) v = compoProp.alt ;
		compoProp.alt = v;		
		return v;
	}
	
	//
	//
	//
	/**
	 * static public  
	 */
	/**
	 * load a skin.
	 * use it for each used skin ; Buttons can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		ButtonLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit Button
 */
class ButtonLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "Button/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + ButtonLoader.PATH : pathStr ; 
		UICompoLoader.__push( ButtonLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
	}
	/**
	 * private static
	 */
	static function __load (fromPath:String,sk:String)  {
		var h:Http = new Http(fromPath + UICompoLoader.SKIN_FILE);
		h.onData = __onData;	
		h.request(false);
		UICompoLoader.__currentSkinName = sk;
		UICompoLoader.__currentFromPath = fromPath;	
	}	
	static function __onData (result:String)  {
		var skinContent=UICompoLoader.__storeData(result);		
		//
		ButtonLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
