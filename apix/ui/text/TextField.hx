package apix.ui.text;
//
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo.UICompoLoader;
import apix.ui.UICompo.CompoProp;
import apix.ui.UICompo;
import haxe.Http; 

//using
using apix.common.util.StringExtender;
#if js
	import js.html.Element;
	using apix.common.display.ElementExtender;
	typedef Elem = Element;
#else if flash
	//TO CONTINUE
	import flash.display.Sprite;	
	using apix.common.display.SpriteExtender;
	typedef Elem = Sprite;
#else 
	//TODO
#end
typedef TextFieldProp = { 
	> CompoProp ,
	?value:String ,
	?size:String,
	?bg:Bool,
	?color:String,
} 
//
/**
 * In properties
 * @param  into			#+container id
 * @param  skin			skinName
 * @param  id 			Compo Elem id
 * @param  name			Compo name
 * @param  auto			true if auto enable
 * @param  width		css width
 * @param  height		css  height
 * 
 * @param  value		inner text
 * @param  size			fontSize
 */
/**
 * Out standard value
 * @param value			value
 */
/**
 * No Event
 */
//
class TextField extends UICompo  {
	
	//getter
	public var size(get, null):String;	
	public var bg(get, null):Bool;	
	public var color(get, null):String;	
	
	
	/**
	* constructor
	* @param ?p TextFieldProp
	*/
	public function new (?p:TextFieldProp) {
		super(); 	
		compoSkinList = TextFieldLoader.__compoSkinList;
		setup(p);		
	}
	/**
	 * setup TextFieldProp
	 * @param ?p TextFieldProp
	 * @return this
	 */
	override public function setup (?p:TextFieldProp) :TextField {	
		setCompoProp(p);
		if (isInitialized()) {
			if (!isCreated()) create();
			update ();
		}
		return this;
	}
	
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override public function update ()  : TextField {
		element.inner(value);
		element.css("width",width);
		element.css("height",height);
		element.css("fontSize",size);
		element.css("color", color); 
		if (!bg) {
			element.removeClass("textField");
		}
		else {
			if (!element.hasClass("textField")) element.addClass("textField");
		}
		super.update();
		return this;
	}
	/**
	 * private  
	 */		
	override function get_value () :String {
		var v:String=null;
		if (compoProp.value != null) v = compoProp.value ;
		else {
			v = "";	
		}
		compoProp.value = v;		
		return v;
	}	
	override function set_value (v:String) :String {
		setup( { value:v } );			
		return v;
	}	
	override function get_height () :String {
		var v:String=null;
		if (compoProp.height != null) v = compoProp.height ;
		else {
			v = "auto";			
		}
		compoProp.height = v;		
		return v;
	}
	function get_size () :String {
		var v:String=null;
		if (compoProp.size != null) v = compoProp.size ;
		else {
			v = "1rem";			
		}
		compoProp.size = v;		
		return v;
	}
	function get_color () :String {
		var v:String=null;
		if (compoProp.color != null) v = compoProp.color ;
		else {
			v = "rgba(0, 0, 0, 0.75)";			
		}
		compoProp.color = v;		
		return v;
	}
	function get_bg () :Bool {
		var v:Bool=null;
		if (compoProp.bg != null) v = compoProp.bg ;
		else {
			v = true ;			
		}
		compoProp.bg = v;		
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
	 * use it for each used skin ; Apixs can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		TextFieldLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit TextField
 */
class TextFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "TextField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + TextFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( TextFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		TextFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
