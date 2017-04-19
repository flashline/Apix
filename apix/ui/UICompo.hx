
package apix.ui;
import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.common.io.JsonLoader;
import apix.common.util.Global;
import apix.common.util.Object;
import apix.common.display.Common;
import apix.common.util.xml.XmlParser;
import apix.ui.container.TabBox;
import apix.ui.input.EmailField;
import apix.ui.tools.InfoBubble;
import apix.ui.tools.PopBox;
import apix.ui.tools.Spinner;
import js.html.Event;
import js.html.InputElement;
//using
using apix.common.util.StringExtender;
using apix.common.util.ArrayExtender;
//
#if (js)
	using apix.common.display.ElementExtender;
#end
//
@:enum
abstract OrientationMode (String) {
	var PORTRAIT="portrait";
	var LANDSCAPE="landscape";
}
//
typedef Required = { 
	compo:UICompo
}
//
typedef CompoSkin = { public var skinName : String; public var skinContent : String ; public var skinPath : String ; } ;
typedef CompoProp = { 
	?into:String,
	?skin:String,
	?id:String,
	?name:String,
	?label:String,
	?auto:Bool,
	?width:String,
	?height:String,
	//
	?required:Bool,
	?info:String,		// bubble info
	?labelAlign:String,	// top or left
	?labelWidth:String,  // used only with labelAlign
	//
	?style:ElemStyle
	/*
	 * TODO ?
	,
	?x:Float,
	?y:Float
	*/
} 
/**
 * Common input properties
 * @param  into			#+container id
 * @param  skin			skinName
 * @param  id 			Compo Elem id
 * @param  label
 * @param  width
 * @param  height
 * @param  required
 * @param  name			uiCompo name
 * @param  auto			true if auto enable 
 * @param  disabled		if true field is disabled
 * 
 */
/**
 * @param  name 	media name -may be filename or dynamic filename
 * @param  type 	ie: image,audio
 * @param  ext		ie: jpeg,gif,x-wav
 * @param  code 	ie: base64
 * @param  data 	encoded content
 */
typedef MediaData = { 
	name:String,
	type:String,
	ext:String,
	code:String,
	data:String
} 
//
/**
 * Super class for all components
 * In common properties
 * @param  into			#+container id
 * @param  skin			skinName
 * @param  id 			Compo Elem id
 * @param  name			Compo name
 * @param  auto			true if auto enable
 * @param  width		css width
 * @param  height		css  height
 * @param  required		true or false
 * @param  info			bubble info
 * @param  charLen		max input char
 */
/**
 * No Event
 */
//
class UICompo {  
	static public inline var APIX_PRFX :String = "apix_" ;
	static public inline var IMG_OVER_CLASS :String =  UICompo.APIX_PRFX + "imgOver" ;
	static public inline var IMG_OUT_CLASS :String =  UICompo.APIX_PRFX + "imgOut" ;
	static public inline var LABEL_ALIGN_DEFAULT :String = "top" ;
	static public inline var LABEL_ALIGN_TOP :String = "top" ;
	static public inline var LABEL_ALIGN_LEFT :String = "left" ;
	static public inline var BODY_CLASS :String = UICompo.APIX_PRFX+"body" ;
	static public inline var HEAD_CLASS :String = UICompo.APIX_PRFX+"head" ;
	
	//
	/**
	 * event dispatcher used in info-bubble system
	 * to record if a listener already exist 
	 */	
	public var over	(default, null):EventSource ; 
	//
	public var element(default, null):Elem;
	/**
	 * Input elem value
	 */
	public var value(get, set):Dynamic;
	/**
	 * true if compo value is empty -used with required prop 
	 */
	public var isEmpty (get, null):Bool;
	/**
	 * label text
	 * read-only.
	 * use setup() to write this var ; @see InputFieldProp .
	 */
	public var label(get, never):String;
	/**
	 * name.
	 * a unique name for RadioField
	 * read-only.
	 * use setup() to write this var ; @see CompoProp .
	 */
	public var name(get, never):String;	
	public var width(get, never):String;	
	public var height(get, never):String;		
	public var required(get, never):Bool;		
	public var info(get, never):String;	
	public var style(get,never) :ElemStyle;
	
	/**
	 * top or left
	 */
	public var labelAlign(get, null):String;	
	/**
	 * if labelAlign==left label elem width
	 */
	public var labelWidth(get, null):String;	
	
	//
	public var id(get,never):String;
	public var skin(get,never):String;
	public var auto(get,never):Bool;
	public var into(get,set):String;
	public var ctnr(get, never):Elem;
	public var compoSkinList:Array<CompoSkin> ;
	//
	public var compoProp:Object ; 
	public var lang(default, null):Object;
	//
	var g:Global ;
	var enabled:Bool;	
	var infoBubble:InfoBubble;
	/**
	* constructor
	*/
	public function new () {
		g = Global.get();
		compoProp = new Object();
		compoProp.skin = "default";	
		compoProp.auto = true;	
		enabled = false;
		lang = UICompoLoader.langObject;
		over = new EventSource();
	}	
	/**
	 * set component properties  -can be called several time  
	 * @param ?p TextFieldProp
	 * @return this
	 */
	public function setup (?p:Dynamic) :UICompo {	
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
	public function enable ()   : UICompo {	
		trace("f:: UICompo.enable() must be override by subclass !! ");	
		enabled = true;	
		return this;
	}
	/**
	 * update compo each time properties are modified by setup()
	 * @return this
	 */
	function update () :UICompo {
		// styles
		for (k in Reflect.fields(style)) {
			element.css(k, Reflect.field(style, k));
		}
		//
		if (required) UICompo.addRequired(this); else UICompo.removeRequired(this);
		if (info != "") {
			infoBubble = InfoBubble.get();
			if (!over.hasListener()) {
				over.on(function () {});
				element.on(StandardEvent.MOUSE_OVER, showInfoBubble); 
				element.on(StandardEvent.MOUSE_OUT,hideInfoBubble); 
			}
		}
		return this;
	}		
	/**
	 * remove compo 
	 * @return this
	 */
	public function remove () :UICompo {
		UICompo.removeRequired(this);
		return this;
	}	
	/**
	 * create compo
	 * @return this
	 */
	public function create () :UICompo {		
		element = Common.htmlToElem(getCompoSkins(skin).skinContent);
		if (id == "") {
			setCompoProp( { id:Common.newSingleId } );				
		}
		element.id = id;
		if ( ctnrExist () ) addIntoCtnr ();
		return this;
	}
	public function attach (el:Elem) :UICompo {	
		element = el;
		if (g.strVal(element.id) == "")  element.id = Common.newSingleId; 
		return this;
	}
	public function isCreated () : Bool { 
		return (element != null && g.strVal(element.id)!="" );
	}
	public function ctnrExist () : Bool {	
		return (ctnr != null) ;
	}		
	public function isEnabled() : Bool {	
		return (enabled) ;
	}		
	public function isInitialized () : Bool {	
		var v = (getCompoSkins(skin) != null);
		if (!v) trace("f:: UI&lt;component&gt;.init() must be called before !! ");		
		return v ;
	}	
	public function css (k:String,?v:String=null)  : String {
		var r = element.css(k, v);
		update();
		return r;
	}
	/**
	 * private 
	 */
	
	function showInfoBubble ()  {	
		infoBubble.text(info).show(this);
	}
	function hideInfoBubble ()  {	
		infoBubble.hide();
	}
	function getCompoSkins (v:String) :CompoSkin {	
		var ret = null;
		for (o in compoSkinList) {			
			if (o.skinName == v) {
				ret = o; break;
			}
		}
		return ret ;
	}	
	function addIntoCtnr () {	
		if (ctnrExist () && !ctnr.hasChild(element) ) {
			ctnr.addChild(element); 
		}
	}
	function setCompoProp (?p:Dynamic) {	
		var o:Object = new Object(p); 
		if (!o.empty()) {
			o.forEach(	function (k, v, i) {
							compoProp.set(k, v);
						}
			);	
		}	
		if (isCreated() && p!=null) {
			if (p.id != null)  element.id = compoProp.id;
			if (p.into != null) addIntoCtnr ();
		}
	}
	function get_skin () :String {
		return g.strVal(compoProp.skin);
	}	
	function get_id () :String {
		var v;
		if (isCreated()) v = element.id ;
		else v=g.strVal(compoProp.id);
		return v;
	}
	function get_name () :String {
		var v:String=null;
		if (compoProp.name != null) v = compoProp.name ;
		else {
			v = "unnamed";			//Don't change "unnamed"
		}
		compoProp.name = v;		
		return v;
	}
	function get_width () :String {
		var v:String=null;
		if (compoProp.width != null) v = compoProp.width ;
		else {
			if (element!=null && g.strVal(element.style.width,"")!="") v = element.style.width ;
			else v = "100%";			
		}
		compoProp.width = v;		
		return v;
	}	
	function get_height () :String {
		var v:String=null;
		if (compoProp.height != null) v = compoProp.height ;
		else {
			if (element!=null && g.strVal(element.style.height,"") !="") v = element.style.height ;
			else v = "";		
		}
		compoProp.height = v;		
		return v;
	}
	function get_required () :Bool {
		var v:Bool=null;
		if (compoProp.required != null) v = compoProp.required ;
		else {
			v = false;		
		}
		compoProp.required = v;		
		return v;
	}
	function get_info () :String {
		var v:String=null;
		if (compoProp.info != null) v = compoProp.info ;
		else {
			v = "";		
		}
		compoProp.info = v;		
		return v;
	}
	
	
	function get_ctnr () :Elem {
		if (g.strVal(into) != "") return into.get() ;  
		else return null;
			
	}
	function set_into (v:String) :String {
		setup( { into:v } );
		return v;
	}	
	function get_into () :String {
		return compoProp.into;
	}	
	function get_auto () :Bool {		
		return g.boolVal(compoProp.auto);
	}	
	function get_value () :Dynamic {			
		trace("f:: UICompo. get_value () must be override by subclass !! ");	
		return null ;
	}	
	function set_value (v:Dynamic) :Dynamic {
		trace("f:: UICompo. set_value () must be override by subclass !! ");
		return v;
	}	
	function get_isEmpty () : Bool {
		return g.strVal(value,"") == "" ;		
	}
	function get_label () :String {
		trace("f:: UICompo.get_label() must be override by subclass !! ");	
		return null;
	}
	function get_style () :ElemStyle {
		var v:ElemStyle=null;
		if (compoProp.style != null) v = compoProp.style ;
		else {
			v = {};			
		}
		compoProp.style = v;		
		return v;
	}
	//
	//
	//
	/**
	 * public static
	 */
	static var _orientAlertBox:PopBox;
	public static function lockPortrait (?el:Elem)  {
		if (Global.get().isPhone) {
			Common.window.on("orientationchange", onChangeOrientation);
			Common.window.on("resize", onChangeOrientation);
			changeToPortrait ();
		}
	}
	public static function unlockPortrait ()  {
		if (Common.window.hasLst()) {
			Common.window.off("orientationchange", onChangeOrientation);
			Common.window.off("resize", onChangeOrientation);
		}
			
	}
	public static var orientation(get, null):OrientationMode ;
	static function get_orientation () :OrientationMode {
		if (Math.abs(untyped Common.window.orientation) == 90 ) return OrientationMode.LANDSCAPE;
		else return OrientationMode.PORTRAIT ;
			
	}
	public static function changeToPortrait ()  {	
		if (Math.abs(untyped Common.window.orientation) == 90 ) {
			if (_orientAlertBox!=null) _orientAlertBox=_orientAlertBox.remove();
			_orientAlertBox = new PopBox().create({backgroundColor:"rgba(0,0,0,.9)"});
			var el:Elem = Common.createElem();
			el.css("color","white" );
			el.css("fontSize","1.5rem" );
			el.css("textAlign","center" );
			el.inner(UICompoLoader.langObject.noLanscape); 
			_orientAlertBox.addChild(el);			
			_orientAlertBox.open();
		}
		else {
			if (_orientAlertBox != null) {
				_orientAlertBox.close();
				_orientAlertBox=_orientAlertBox.remove();
			}
		}
    }
	static function onChangeOrientation (e:Event)  {	
		changeToPortrait () ;
    }	
	
	public static var inputStk(default,null):Array<Elem>=[];
	public inline static function init ()  {
		for (i in Common.getElemsByTag('input')) { 
			var el:Elem= i;
			if (!el.prop("disabled")) inputStk.push(el);
		}
	}
	
	public static var requiredStk(default, null):Array<Required> = [];
	public static function addRequired (compo:UICompo) {
		var exist = false;
		for (r in UICompo.requiredStk) {
			if (r.compo == compo) {
				exist = true;
				break;
			}
		}
		if (!exist) requiredStk.push( { compo:compo } );
	}
	public static function removeRequired (c:UICompo) : Null<Required> {
		var i = 0;
		for (r in UICompo.requiredStk) {
			if (r.compo == c) {
				UICompo.requiredStk.splice(i, 1);
				break;
			}
			i++;
		}
		return null;
	}	
	public static function removeAllRequired () {
		UICompo.requiredStk = [];
	}	
	public static function mediaDataToUrl (md:MediaData) : String {
		var v = "";
		if (md.name == null) trace("f:: In parameter isn't a MediaData !");
		v="data:"+md.type+"/"+md.ext+";"+md.code+","+md.data ; // i.e data:image/png;base64,i....etc
		return v;
	}	
	//
	//
	function get_labelAlign () :String {
		var v:String=null;
		if (compoProp.labelAlign != null) v = compoProp.labelAlign ;
		else {
			v = UICompo.LABEL_ALIGN_DEFAULT;			
		}
		v=v.toLowerCase();
		if (v != "left") v = UICompo.LABEL_ALIGN_DEFAULT;
		compoProp.labelAlign = v;		
		return v;
	}
	function get_labelWidth () :String {
		var v:String=null;
		if (compoProp.labelWidth != null) v = compoProp.labelWidth ;
		else {
			v = "50%";		
		}
		compoProp.labelWidth = v;		
		return v;
	}
	//
	//
	public static function getEmpties () : String {
		var str = ""; var coma = "<br/>";
		for (r in UICompo.requiredStk) {
			if (r.compo.isEmpty) {
				str += coma + r.compo.label ;
				if (Std.is(r.compo, EmailField) && (!(cast(r.compo,EmailField).isMail)) ) {
					str +=  " : " + UICompoLoader.langObject.invalidEmail ;
				}
				coma = ",<br/>";
			}
		}
		if (str != "") str=UICompoLoader.langObject.emptyError + str ;
		return str; 
	}
	public static var baseUrl(get,set):String;
	static function set_baseUrl (v:String) : String {
		if (v==null) v="";
		UICompoLoader.baseUrl = v;
		return v;
	}
	static function get_baseUrl () : String {
		var v = UICompoLoader.baseUrl;
		return v;
	}
	//
	//
	//
	public static function loadInit (f:Dynamic)  {
		UICompoLoader.__loadInit(f);
	}
	//
	
}
//
//
//
//
//
//
//
//
class UICompoLoader    { 
	//	
	public 	static 	inline 	var DEFAULT_SKIN_PATH:String = "apix/default/" ;
	public	static 	inline 	var DEFAULT_LANG_SOURCE:String = "apix/lang/default/language.xml" ;
	public 	static 	inline 	var SKIN_FILE:String = "skin." + Common.DESC_EXT ;
	public 	static 	inline 	var TMP_CTNR_ID:String = "apix_tmp_ctnr" ;	
	//
	public 	static 			var __currentFromPath:String  ;	
	public 	static 			var __currentSkinName:String  ;
	public 	static 		    var baseUrl:String="" ;
	public  static 			var langObject:Object ;
	//
			static inline 	var TMP_IMG_URL_PREFIX:String = "././" ;
			static 			var __stk:Array<Dynamic> = new Array() ;
			static 			var __callBack:Dynamic ;	
	//
	/**
	 * public static
	 */
	static public function __loadInit (f:Dynamic )  {
		UICompoLoader.__callBack = f;
		var tmp = Common.createElem();
		tmp.id = UICompoLoader.TMP_CTNR_ID;
		Common.body.addChild(tmp);
		var spinnerProp:SpinnerProp = {  callBack:__startLoadCompo };
		if (Global.get().isMobile) spinnerProp.skinPath = UICompoLoader.DEFAULT_SKIN_PATH + "Spinner/mobile/" ;	
		Spinner.get( spinnerProp ).start();		
	}		
	/**
	 * private static
	 */		
	static function __startLoadCompo ()  {		
		if (Lang.getSrc() == null) UICompoLoader.__loadNext();
		else {			
			var jl = new JsonLoader(); 
			jl.read.on(__onLangLoaded);
			jl.load(Lang.getSrc());		
		}		
	}
	static function __onLangLoaded (e:JsonLoaderEvent)  {			
		var jl:JsonLoader = e.target;
		jl.read.off(__onLangLoaded);
		langObject = e.tree;
		UICompoLoader.__loadNext();
	}	
	static function __push (f:Dynamic, url:String,skinName:String)  {
		UICompoLoader.__stk.push({f: f,url:url,skinName:skinName}) ;
	}
	static function __loadNext ()  {		
		if (UICompoLoader.__stk.length>0) {
			var o = UICompoLoader.__stk.pop() ;
			o.f(o.url,o.skinName);		
		}
		else {
			Common.body.removeChild(("#" + UICompoLoader.TMP_CTNR_ID).get());				
			Spinner.get().stop(); // Spinner.get().stop(); // OR // Spinner.get().remove(); //
			UICompoLoader.__callBack();
		}
	}
	static function __onEndLoad ()  {		
		UICompoLoader.__loadNext();	
	}
	public static function __storeData (result:String) : String {	
		var tmpCtnr = Common.getElem(UICompoLoader.TMP_CTNR_ID);	
		result = result.replace(UICompoLoader.TMP_IMG_URL_PREFIX, UICompoLoader.__currentFromPath ) ; 
		
		tmpCtnr.inner(result);				
		var tmpStyleEl:Elem = tmpCtnr.elemByTag("style");
		var styleContent = tmpStyleEl.text() ; 
		tmpCtnr.removeChild(tmpStyleEl);
		var styleElArr = Common.getElemsByTag("style"); 
		if (styleElArr.length == 0) {
			tmpStyleEl.text(styleContent) ;
			Common.head.addChild(tmpStyleEl); 
		} else {
			var styleEl = styleElArr[0]; 
			styleEl.textContent+=styleContent;		
		}
		var el:Elem = tmpCtnr.elemByClass("apix_loader_ctnr") ; 
		var skinContent=el.inner(); 
		tmpCtnr.inner("");		
		return skinContent ;	
	
	}
	
}
class HLine {
	public function new (v:String, ?visible:Bool = false) {
		var parent=v.get();
		if (visible) parent.addChild(Common.newHLine) ;
		else parent.addChild(Common.newLine) ;
	}
}


class Lang { 
	static var languageSrc:String;
	
	/**
	 * static public  
	 */
	public static function init (?pathStr:String=null)  {
		languageSrc = pathStr;
	}	
	public static function getSrc () :String {
		return languageSrc ;
	}	
	public static function setLangObject (o:Object)  {
		if (o == null) trace("f::Error in Lang.setLangObject(). Parameter must not be null !");
		if (Global.get().className(o) != "Object") trace("f::Error in Lang.setLangObject(). Parameter must be an Object !");
		if (UICompoLoader.langObject!=null || languageSrc!=null) trace("f::Error in Lang.setLangObject(). Lang.init() is already done !");
		UICompoLoader.langObject=o ;
	}
}