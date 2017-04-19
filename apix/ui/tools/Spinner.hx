package apix.ui.tools;
//
import apix.common.util.Global;
import apix.common.display.Common;
import apix.common.util.Object;
import apix.ui.tools.PopBox;
import apix.ui.UICompo.UICompoLoader;
import apix.ui.UICompo;
import haxe.Http; 

//using
using apix.common.util.StringExtender;
#if js
	using apix.common.display.ElementExtender;
#else if flash
	//TO CONTINUE
	using apix.common.display.SpriteExtender;
#else 
	//TODO
#end
//
typedef SpinnerProp = { 
	?skinPath:String,
	?id:String,
	?color:String,
	?bgColor:String,
	?callBack:Dynamic,
	?text:String
	
}
//
/**
 * In properties
 * @param  	skinPath	skin path
 * @param  	id 			Compo Elem id
 * @param	color		css color
 * @param
 * @param	bgColor		css background-color
 * @param	callBack	facultative call after loading
 * @param	text		text displayed under movie
 * 
 */
//
class Spinner  {
	static public		 var TEXT_DEFAULT:String="";
	static public inline var TEXT_CLASS :String =  UICompo.APIX_PRFX + "text" ;	
	static public inline var SKIN_PATH_DEFAULT:String = "Spinner/cubeGrid/" ;	//mobile //cubeGrid // circle // chasingDot // doubleBounce // fadingCircle //  
	static public inline var COLOR_DEFAULT:String = "#3399dd" ;	
	static public inline var BG_COLOR_DEFAULT:String = "rgba(0,0,0,.7)" ;	
	//
	public var element(default, null):Elem;
	//getter/setter
	public var id(get,null):String;
	public var skinPath(get, null):String;
	public var color(get,null):String;
	public var bgColor(get, null):String;
	public var callBack(get, null):Dynamic;
	public var text(get, null):String;
	//
	var compoProp:Object ; 
	var skinContent:String; 
	var spinnerBox:PopBox; 
	var elementBeforeDisplay:String; 
	var g:Global ;
	//
	static var _instance:Spinner;
	
	/**
	* constructor
	* @param ?p SpinnerProp
	*/
	function new (?p:SpinnerProp) {	
		g = Global.get();
		if (g.isMobile) Spinner.TEXT_DEFAULT = "Loading..." ;
		compoProp = new Object();
		setup(p);
	}	
	public static function get (?p:SpinnerProp) : Spinner {
		if (_instance == null) _instance = new Spinner(p);
		else  _instance.setup (p);
		return _instance ;
	}
	//public // set to "public" only if onData() is modified
	public function start ()  {
		if (spinnerBox==null) load(); 
		else run();
    }
	
	public function stop ()  {	
		if (spinnerBox!=null) {
			element.hide();
			spinnerBox.close();	
		} else "f::error : Spinner not initialized".trace();	
    }
	public function remove () :Dynamic {	
		if (spinnerBox != null) {
			stop();
			spinnerBox = spinnerBox.remove();
			_instance = null;
		} else "f::error : Spinner not initialized".trace();		
		return null ;
    }
	// 
	
	
	/**
	 * private  
	 */	
	function run ()  {
		if (spinnerBox!=null) {
			element.show(elementBeforeDisplay);
			spinnerBox.open();	
			if (callBack != null) {
				callBack();
				setup({callBack:null});
			}
		} else {
			"f::error : Spinner not initialized".trace();
		}
    }
	function setup (?p:SpinnerProp)  {	
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
		run();
	}
	function create ()  {	
		if (spinnerBox == null) {
			spinnerBox = new PopBox().create({backgroundColor:bgColor});
			var el:Elem = Common.createElem();
			el.inner(skinContent);
			element = el.firstElementChild;			
			element.id = id;
			spinnerBox.addChild(element);
			doColored();
			//
			var txEl = ("#" + id + " ." + Spinner.TEXT_CLASS).get();
			if (txEl!=null && text!="") txEl.inner(text);			
			//
			elementBeforeDisplay = element.hide();
		} else "f::error : Spinner already initialized".trace();
    }
	function doColored ()  {
		if (spinnerBox!=null) {
			("#" + id + " .apix_colored").each(setColor);	
		} else "f::error".trace();
    }
	function setColor (el:Elem)  {
		el.css("backgroundColor", color);
    }
	//get/set
	function get_skinPath () :String {
		var v:String=null;
		if (compoProp.skinPath != null) v = compoProp.skinPath ;
		else {			
			v = UICompoLoader.DEFAULT_SKIN_PATH+Spinner.SKIN_PATH_DEFAULT ; 
		}
		compoProp.skinPath = v;		
		return v;
	}
	function get_color () :String {
		var v:String=null;
		if (compoProp.color != null) v = compoProp.color ;
		else {			
			v = Spinner.COLOR_DEFAULT ; 
		}
		compoProp.color = v;		
		return v;
	}
	function get_text () :String {
		var v:String=null;
		if (compoProp.text != null) v = compoProp.text ;
		else {			
			v = Spinner.TEXT_DEFAULT ; 
		}
		compoProp.text = v;		
		return v;
	}
	function get_bgColor () :String {
		var v:String=null;
		if (compoProp.bgColor != null) v = compoProp.bgColor ;
		else {			
			v = Spinner.BG_COLOR_DEFAULT ; 
		}
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
	function get_id () :String {
		var v:String=null;
		if (compoProp.id != null) v = compoProp.id ;
		else {			
			v = Common.newSingleId ; 
		}
		compoProp.id = v;		
		return v;
	}
}