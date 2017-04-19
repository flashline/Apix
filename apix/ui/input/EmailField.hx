package apix.ui.input;
//
import apix.common.display.Common;
import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.ui.input.InputField.InputFieldProp;
import apix.ui.UICompo;
import apix.common.util.Global;
import apix.common.display.ElementExtender.InputType;
import haxe.Http;
import haxe.Json;
//
//using
using apix.common.util.ArrayExtender;
using apix.common.util.StringExtender;
using apix.common.display.ElementExtender;
//
/**
 * Main input properties 
 * @see UICompo and InputField for others
 * 
 * @param  value		input value like 'info@gmail.com'
 */
/**
 * Main output properties
 * @param value			output value like 'info@gmail.com'
 * @param inputElement	Elem with output value
 * @param domainValue	right part
 * @param emailIdValue	left part
 */
//
typedef EmailFieldProp = { 
	> InputFieldProp ,
}
/**
 * Event
 * @source  blur
 * @param		target				this
 * @param		value				
 * @param		inputTextElement	<input> Element with value
 * @param		id					this Element id
 */
class EmailFieldEvent extends StandardEvent {
	public var value:String;
	public var inputElement:Elem;
	public var id:String;
	public function new (target:InputField, value:String, inputElement:Elem, id:String) { 
		super(target);
		this.value = value;
		this.inputElement = inputElement; 
		this.id = id;
	}	
}
//
class EmailField extends InputField {	
	//
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var LABEL_DEFAULT :String = "Untitled" ;
	//
	public var emailIdElement(default,null):Elem;
	public var domainElement(default,null):Elem;
	//
	public var idValue(get, null):String;	
	public var domainValue(get, null):String;	
	public var isMail(get, null):Bool;	
	/**
	* constructor
	* @param ?p EmailFieldProp
	*/
	public function new (?p:EmailFieldProp) {
		super(p,("isSubClassCall"=="isSubClassCall")); 
		compoSkinList = EmailFieldLoader.__compoSkinList;
		setup(p);	
	}
	
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :EmailField {	
		inputElement = Common.document.createElement("input");		
		inputElement.type("text"); inputElement.hide(); 
		element.addChild(inputElement);
		labelElement = ("#" + id + " ." + InputField.LABEL_CLASS).get();			
		//
		emailIdElement = ("#" + id + " .apix_emailId").get();	emailIdElement.type(InputType.EMAIL);	
		domainElement  = ("#" + id + " .apix_emailDomain").get();	domainElement.type(InputType.EMAIL);
		//
		emailIdElement.on(StandardEvent.BLUR, onLeave);
		domainElement.on(StandardEvent.BLUR, onLeave);
		emailIdElement.on(StandardEvent.CHANGE, onLeave);
		domainElement.on(StandardEvent.CHANGE, onLeave);
		//
		enabled = true;	
		return this;
	}	
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : EmailField {	
		super.update();
		//
		emailIdElement.value(idValue);
		emailIdElement.placeHolder(placeHolder);
		domainElement.value(domainValue);
		return this;
	}		
	override function remove() : EmailField {	
		emailIdElement.off(StandardEvent.BLUR, onLeave);
		domainElement.off(StandardEvent.BLUR, onLeave);
		emailIdElement.off(StandardEvent.CHANGE, onLeave);
		domainElement.off(StandardEvent.CHANGE, onLeave);
		super.remove();		
		return this;
	}		
	/**
	 * private  
	 */		
	function onLeave () {		
		if (emailIdElement.value()!="" && domainElement.value()!="") {
			value = emailIdElement.value() + "@" + domainElement.value();
		} 
		else if (emailIdElement.value() != "" ) {
			value = emailIdElement.value() + "@" ;
		}		
		else if (domainElement.value() != "") {
			value = "@" + domainElement.value() ;
		}
		else value = "";
		if (blur.hasListener()) blur.dispatch(new EmailFieldEvent(this, value, inputElement, id) ) ;
	}	
	//get/set	
	
	function get_idValue () :String {  
		var p = value.indexOf("@"); var v:String;
		if (p!=-1) v=value.substr(0,p);
		else v = value;
		return v;
	}	
	function get_domainValue () :String {  
		var p = value.indexOf("@"); var v:String;		
		v = value.substr(p + 1);
		return v;
	}	
	override function set_value (v:String) :String {
		v=super.set_value(v);
		emailIdElement.value(idValue);
		domainElement.value(domainValue);
		return v;
	}
	override function get_isEmpty () : Bool {
		var b = super.get_isEmpty ();
		if (!b) b = !isMail;
		return b;
	}
	function get_isMail () : Bool {
		var str:String = value; var b:Bool;
		if (str == "") b = true; else b = str.isMail() ;
		return b;
	}
	
	/**
	 * static public  
	 */
	
	/**
	 * load a skin.
	 * use it for each used skin ; EmailFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		EmailFieldLoader.__init(skinName,pathStr);
	}
	
}
//
//
/**
 * static class to loadinit EmailField
 */
class EmailFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "EmailField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr = pathStr == null ? UICompoLoader.DEFAULT_SKIN_PATH + EmailFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( EmailFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
	}
	/**
	 * private static
	 */
	static function __load (fromPath:String, sk:String)  {
		var h:Http = new Http(fromPath + UICompoLoader.SKIN_FILE); 
		h.onData = __onData;	
		h.request(false);
		UICompoLoader.__currentSkinName = sk;
		UICompoLoader.__currentFromPath = fromPath;	
	}	
	static function __onData (result:String)  {
		var skinContent=UICompoLoader.__storeData(result);		
		//
		EmailFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
}
