package apix.ui.input;
//
import apix.common.display.Common;
import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.ui.UICompo;
import apix.common.util.Global;
import haxe.Http;
import haxe.Json;
//
//using
using apix.common.util.ArrayExtender;
using apix.common.util.StringExtender;
using apix.common.display.ElementExtender;
/**
 * Main input properties 
 * @see UICompo for others
 * 
 * @param  value 		input value in json i.e. '["apixline.org","http://www.pixaline.net/"]'
 */
/**
 * Main output properties
 * @param values 		@see LinkValues typdef
 * @param value			output value in json i.e. '["apixline.org","http://www.pixaline.net/"]'
 * @param inputElement	Element with value=json value
 */
typedef LinkFieldProp = { 
	> CompoProp ,
	?textPlaceHolder:String,
	?urlPlaceHolder:String,
	?textLabel:String,
	?urlLabel:String,
	?value:String
}
typedef LinkValues = { 
	text:String,
	url:String,
	data:String
} 
//
/**
 * Event
 * @source  blur
 * @param		target				this
 * @param		value				output value in json i.e. '["apixline.org","http://www.pixaline.net/"]'
 * @param		values				LinkValues typdef
 * @param		inputElement		Element with value=json value
 * @param		inputTextElement	Element with link text
 * @param		inputUrlElement		Element with link url
 * @param		id					this Element id
 */
class LinkFieldEvent extends StandardEvent {
	public var values:LinkValues;
	public var value:String;
	public var inputTextElement:Elem;
	public var inputUrlElement:Elem;
	public var inputElement:Elem;
	public var id:String;
	public function new (target:LinkField, values:LinkValues,value:String, inputTextElement:Elem, inputUrlElement:Elem,inputElement:Elem, id:String) { 
		super(target);
		this.values = values;
		this.value = value;
		this.inputTextElement = inputTextElement; 
		this.inputUrlElement = inputUrlElement; 
		this.inputElement = inputElement; 
		this.id = id;
	}	
}
//
class LinkField extends UICompo {	
	//
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var LABEL_DEFAULT :String = "Untitled" ;
	//
	public var labelElement(default,null):Elem;	
	public var inputElement(default,null):Elem; // elem with json as value i.e. '["apixline.org","http://www.pixaline.net/"]'
	public var inputTextElement(default,null):Elem;
	public var inputUrlElement(default,null):Elem;
	public var labelTextElement(default,null):Elem;
	public var labelUrlElement(default,null):Elem;
	/**
	 * event dispatcher
	 */
	public var blur	(default, null):EventSource ;
	//
	// values
	public var values(get, null):LinkValues;
	//	
	public var textPlaceHolder(get, null):String;	
	public var urlPlaceHolder(get, null):String;	
	public var textValue(get, null):String;	
	public var urlValue(get, null):String;	
	public var textLabel(get, null):String;	
	public var urlLabel(get, null):String;	
	//
	public var url(get, null):String;	
	public var text(get, null):String;	
	/**
	* constructor
	* @param ?p LinkFieldProp
	*/
	public function new (?p:LinkFieldProp) {
		super();
		blur 	= new EventSource();
		compoSkinList = LinkFieldLoader.__compoSkinList;
		setup(p);	
	}
	
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :LinkField {	
		labelTextElement = ("#" + id + " .apix_linkTextLabel").get();		
		labelUrlElement = ("#" + id + " .apix_linkUrlLabel").get();		
		inputTextElement = ("#" + id + " .apix_linkText").get();		
		inputUrlElement = ("#" + id + " .apix_linkUrl").get();	inputUrlElement.type(InputType.URL);
		labelElement = ("#" + id + " ." + InputField.LABEL_CLASS).get();
		//
		inputUrlElement.on(StandardEvent.BLUR, onLeave);
		inputTextElement.on(StandardEvent.BLUR, onLeave);
		inputUrlElement.on(StandardEvent.CHANGE, onLeave);
		inputTextElement.on(StandardEvent.CHANGE, onLeave);
		//
		inputElement = Common.document.createElement("input");		
		inputElement.type("text"); inputElement.hide(); 
		element.addChild(inputElement);
		enabled = true;	
		return this;
	}	
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : LinkField {	
		super.update();		
		labelElement.text(label);
		labelTextElement.text(textLabel);
		inputTextElement.value(textValue);	
		inputTextElement.placeHolder(textPlaceHolder);		
		inputTextElement.css("width", width);
		//
		labelUrlElement.text(urlLabel);
		inputUrlElement.value(urlValue);
		inputUrlElement.placeHolder(urlPlaceHolder);		
		inputUrlElement.css("width", width);
		//
		inputElement.value(values.data);
		return this;
	}		
	override function remove() : LinkField {	
		super.remove();
		inputUrlElement.off(StandardEvent.BLUR, onLeave);
		inputTextElement.off(StandardEvent.BLUR, onLeave);
		inputUrlElement.off(StandardEvent.CHANGE, onLeave);
		inputTextElement.off(StandardEvent.CHANGE, onLeave);
		if (blur.hasListener()) blur.off();		
		element.delete();
		return this;
	}		
	/**
	 * private  
	 */		
	function onLeave () {
		value = values.data;
		if (blur.hasListener()) blur.dispatch(new LinkFieldEvent(this,values,value,inputTextElement, inputUrlElement,inputElement,id) ) ;
	}	
	//get/set	
	function get_values () : LinkValues {	
		return {
					text:text,
					url:url, 
					data:'["'+text+'","'+url+'"]'
				} ;
	}
	function get_text() :String {
		return inputTextElement.value();
	}
	function get_url () :String {
		var v = inputUrlElement.value();
		if (v != "" && v.substr(0, 4) != "http") v = "http://" + v;
		inputUrlElement.value(v);
		compoProp.urlValue = v;	
		return inputUrlElement.value();
	}	
	//	
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = InputField.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	function get_textPlaceHolder () :String {  
		var v:String=null;
		if (compoProp.textPlaceHolder != null) v = compoProp.textPlaceHolder ;
		else { v = "Link text";}
		compoProp.textPlaceHolder = v;		
		return v;	
	}
	function get_urlPlaceHolder () :String {  
		var v:String=null;
		if (compoProp.urlPlaceHolder != null) v = compoProp.urlPlaceHolder ;
		else { v = "http://...";}
		compoProp.urlPlaceHolder = v;		
		return v;	
	}
	function get_textValue () :String {  
		return LinkField.getArrayFrom(value)[0];
	}
	function get_urlValue () :String {  
		return LinkField.getArrayFrom(value)[1];
	}
	override function get_value () :String {
		var v:String=null;
		if (compoProp.value != null) v = compoProp.value ;
		else {
			v = '[""],[""]';	
		}
		compoProp.value = v;		
		return v;
	}	
	override function get_isEmpty () : Bool {
		return (g.strVal(urlValue,"") == "")  ; 	//|| (g.strVal(textValue,"") == "")	
	}
	override function set_value (v:String) :String {
		inputElement.value(v);
		setCompoProp( { value:v } );	
		return v;
	}		
	function get_textLabel () :String {  
		var v:String=null;
		if (compoProp.textLabel != null) v = compoProp.textLabel ;
		else { v = "Enter link text";}
		compoProp.textLabel = v;		
		return v;	
	}
	function get_urlLabel () :String {  
		var v:String=null;
		if (compoProp.urlLabel != null) v = compoProp.urlLabel ;
		else { v = "Enter link url";}
		compoProp.urlLabel = v;		
		return v;	
	}	
	/**
	 * static public  
	 */
	
	/**
	 * load a skin.
	 * use it for each used skin ; LinkFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		LinkFieldLoader.__init(skinName,pathStr);
	}
	/**
	 * 
	 * @param	v Json string like "["+text+","+url+"]"
	 * @param	trgt link target
	 * @param	attr added attributes
	 * @return	an html link 
	 */
	public static function getLinkFrom (v:String,?trgt:String="_blank",?attr:String=""):String {		
		var arr:Array<String> = LinkField.getArrayFrom (v);
		if (arr[0] == "") arr[0] = arr[1];
		var v = "<a href='" + arr[1] + "' target='" + trgt + "' " + attr + " >" + arr[0] + "</a>" ;	
		return v;
	}
	public static function getArrayFrom (v:String) : Array<String> {		
		var arr:Array<String>;
		try { 
			arr = cast(Json.parse(v)) ; 
		}
		catch (e:Dynamic) {	
			arr = ["", ""]	;							
		}
		return arr ;	
	}
}
//
//
/**
 * static class to loadinit LinkField
 */
class LinkFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "LinkField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr = pathStr == null ? UICompoLoader.DEFAULT_SKIN_PATH + LinkFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( LinkFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		LinkFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
}
