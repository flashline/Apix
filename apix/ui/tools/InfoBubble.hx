package apix.ui.tools;
//
import apix.common.util.Global;
import apix.common.display.Common;
import apix.common.util.Object;
import apix.ui.input.InputField;
import apix.ui.UICompo.UICompoLoader;
import apix.ui.UICompo;
import haxe.Http; 

//using
using apix.common.util.StringExtender;
#if js
	using apix.common.display.ElementExtender;
#end
//
typedef InfoBubbleProp = { 
	?skinPath:String,
	?color:String,
	?bgColor:String,	
	?callBack:Dynamic
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
class InfoBubble  {
	static public inline var SKIN_PATH_DEFAULT:String = "InfoBubble/" ;  
	//
	public var element(default, null):Elem;
	//getter/setter
	public var skinPath(get, null):String;
	public var color(get,null):String;
	public var bgColor(get, null):String;
	public var callBack(get, null):Dynamic;
	//
	var compoProp:Object ; 
	var skinContent:String; 
	var g:Global ;
	//
	static var _instance:InfoBubble;
	
	/**
	* constructor
	* @param ?p InfoBubbleProp
	*/
	function new (?p:InfoBubbleProp) {	
		g = Global.get();
		compoProp = new Object();
		setup(p);		
		load();
	}	
	public static function get (?p:InfoBubbleProp) : InfoBubble {
		if (_instance == null) _instance = new InfoBubble(p);
		return _instance ;
	}
	public function text (info:String) :InfoBubble {
		element.inner(info);
		return this;
    }
	public function show (co:UICompo) :InfoBubble {
		var compoElem = co.element;
		var parent=compoElem.parent();		
		if (element.parent() != parent) parent.addChild(element);
		element.show();
		element.posy(compoElem.posy() - element.height() - 10);	
		element.posx(compoElem.posx());	element.css("width",element.css("maxWidth"));
		if (co.labelAlign == UICompo.LABEL_ALIGN_LEFT  && !g.isMobile) {
			element.posy(compoElem.posy());	
			element.posx(compoElem.posx() + compoElem.width() + 5);	
			element.width(parent.width()-compoElem.width()-15);
		}
		return this;
    }
	public function hide () :InfoBubble {
		element.hide();
		return this;
    }
	// 	
	/**
	 * private  
	 */	
	function setup (?p:InfoBubbleProp)  {	
		var o:Object = new Object(p); 
		if (!o.empty()) {
			o.forEach(	function (k, v, i) {
							compoProp.set(k, v);
						}
			);	
		}			
	}
	function load () {
		var h:Http = new Http(UICompoLoader.baseUrl+skinPath + UICompoLoader.SKIN_FILE);
		h.onData = onData;	
		h.request(false);
		return this ;
	}	
	function onData (result:String)  {
		var tmp = Common.createElem();
		tmp.id = UICompoLoader.TMP_CTNR_ID;
		Common.body.addChild(tmp);
		UICompoLoader.__currentFromPath = skinPath;	
		skinContent = UICompoLoader.__storeData(result);
		Common.body.removeChild(tmp);	
		create () ;			
	}
	function create ()  {			
		var el:Elem = Common.createElem();
		el.inner(skinContent);
		element = el.firstElementChild;	
		Common.body.addChild(element);
		element.posy(0);element.posx(0);
		if (color!=null) el.css("color", color);
		if (bgColor != null) el.css("backgroundColor", bgColor);		
		element.hide();
		if (callBack != null) {
			callBack();
			callBack = null;
		}
    }		
	//get/set
	function get_skinPath () :String {
		var v:String=null;
		if (compoProp.skinPath != null) v = compoProp.skinPath ;
		else {			
			v = UICompoLoader.DEFAULT_SKIN_PATH+InfoBubble.SKIN_PATH_DEFAULT ; 
		}
		compoProp.skinPath = v;		
		return v;
	}
	function get_color () :String {
		var v:String=null;
		if (compoProp.color != null) v = compoProp.color ;
		compoProp.color = v;		
		return v;
	}
	function get_bgColor () :String {
		var v:String=null;
		if (compoProp.bgColor != null) v = compoProp.bgColor ;
		compoProp.bgColor = v;		
		return v;
	}
	function get_callBack () :Dynamic {
		var v:Dynamic=null;
		if (compoProp.callBack != null) v = compoProp.callBack ;
		else {			
			v = null ; 
		}
		compoProp.callBack = v;		
		return v;
	}
}