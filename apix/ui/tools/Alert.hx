package apix.ui.tools;
//
import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo;
import haxe.Http;

//using
using apix.common.util.StringExtender;
#if js
	using apix.common.display.ElementExtender;
#end
//
typedef AlertProp = { 
	>CompoProp,
}
//
/**
 * In properties
 * @param  	skinPath	skin path
 * @param	color		css color
 * @param	bgColor		css background-color
 * 
 */
//
class Alert extends UICompo {
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var VALID_CLASS :String = UICompo.APIX_PRFX+"enter" ;
	static public inline var CONTENT_CLASS :String = UICompo.APIX_PRFX+"content" ;
	//
	public var callBack(default, null):Dynamic;
	//
	var buttons:EventSource;
	var popBox:PopBox;
	var labelElement		(default,null) : Elem ;        
	var contentElement		(default,null) : Elem ;         
	var bValidElement		(default,null) : Elem ;         
	//
	static var _instance:Alert;
	//
	/**
	* private constructor
	* @param ?p AlertProp
	*/
	function new (?p:AlertProp) {
		if (p!=null) p.into = null;
		buttons = new EventSource();
		super(); 					
		compoSkinList = AlertLoader.__compoSkinList;		
		setup(p);		
	}	
	public static function get (?p:AlertProp) : Alert {
		if (_instance == null) _instance = new Alert(p);
		return _instance ;
	}
	/**
	 * create in a PopBox and set it as parent ctnr.
	 * enable and update will be called
	 */
	override public function create () : Alert {		
		super.create();
		popBox = new PopBox().create({backgroundColor:"rgba(0,0,0,.7)"});
		popBox.addChild(element);
		setup( { into:"#" + popBox.id } );
		return this;
	}
	public function display (?v:String = "", ?cb:Dynamic = null , ?lab:String = null )  {		
		labelElement.text(lab==null?label:lab);
		callBack = cb;		
		contentElement.inner(v);
		bValidElement.joinEnterKeyToClick();
		popBox.open();
		var nz = g.getNextZindex();
		if (nz-1!=Std.parseInt(popBox.element.css("zIndex"))) popBox.element.css("zIndex", Std.string(nz));
	}
	public function clear () : Alert  {		
		contentElement.inner("");
		return this;
	}
	public function append (v:String )  : Alert   {		
		contentElement.appendInner("<br/>" + v);
		return this;
	}
	/**
	 * restore js standard alert-box when alert()
	 */
    override public function remove () : Alert {
		removeEvents ();
		popBox.close();
		popBox.remove();
		Global.alertFunction = null;
		return this;
	}
		
	
	// 	
	/**
	 * private  
	 */	
	override function setup (?p:AlertProp) :Alert {	
		super.setup(p);
		return this;
	}
	function createEvents () { 
		if (!buttons.hasListener()) {
			buttons.on(function () { } );
			//
			bValidElement.on(StandardEvent.CLICK, onValid);
		}		
	}
	function removeEvents () { 
		if (buttons.hasListener()) {
			buttons.off();
			//
			bValidElement.off(StandardEvent.CLICK, onValid);
		}
	}	
	function onValid (e:ElemEvent) { 			
		e.preventDefault();	
		bValidElement.clearEnterKeyToClick();	
		popBox.close();
		if (callBack != null) {
			callBack();
			callBack = null;
		}
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override function enable ()   : Alert {	
		labelElement = ("#" + id + " ." + Alert.LABEL_CLASS).get();
		contentElement = ("#" + id + " ." + Alert.CONTENT_CLASS).get();
		bValidElement  = ("#" + id + " ." + Alert.VALID_CLASS).get();
		createEvents();
		Global.alertFunction = display;
		//
		enabled = true;	
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : Alert {		
		super.update();
		if (label!=null) labelElement.text(label);			
		return this;
	}	
	//get/set	
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = null;			
		}
		compoProp.label = v;		
		return v;
	}
	//
	//
	/**
	 * static public  
	 */
	/**
	 * load a skin.
	 * use it for each used skin ; InputFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName:String = "default", ?pathStr:String)  {
		AlertLoader.__init(skinName,pathStr);
	}	
}
//

//
/**
 * static class to loadinit InputField
 */
class AlertLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "Alert/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + AlertLoader.PATH : pathStr ; 
		UICompoLoader.__push( AlertLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		AlertLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
