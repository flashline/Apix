package apix.ui.input;
//
import apix.common.event.EventSource;
import apix.common.event.timing.Clock;
import apix.common.event.timing.MouseClock;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo.MediaData;
import apix.ui.UICompo;
import sys.db.Types.SString;
//
import apix.common.tools.math.Vector;
//
import apix.ui.UICompo.CompoProp;
import apix.ui.UICompo;
import apix.common.event.StandardEvent;
import haxe.Http; 
//using
using apix.common.util.StringExtender;
using apix.common.util.ArrayExtender;
//
using apix.common.display.ElementExtender;
//
/**
 * Main input properties 
 * @see UICompo for others
 * 
 * @param  color			stroke color
 * @param  thickness		stroke line width
 * @param  border			true or false
 * @param  base64UrlValue	image base64 url of signature
 * 
 */
/**
 * Main output properties 
 * @param value			full BmpData
 * @param inputElement	Hidden element wich contains base64 url img in value attr
 */

typedef SignFieldProp = { 
	> CompoProp ,
	/**
	 * stroke color
	 */
	?color:String ,
	?thickness:Int,
	?border:Bool,
	?base64UrlValue:String		// string like "data:image/png;base64, i<string base64>="	
} 
typedef BmpData = { 
	?name:String,
	?color:String ,
	?thickness:Int,
	?lineCap:String,
	?drawingData:Array<Vector>,
	?mediaData:MediaData,
	?toUrlData:String,
	?empty:Bool
}
//

/**
 * Event
 * @source  	click 
 * @param		target				this
 * @param		value				the picture object -BmpData;
 * @param		id					this Element id
 */
class SignFieldEvent extends StandardEvent {
	public var inputElement:Elem;
	public var value:BmpData;
	public var id:String;
	public function new (target:SignField, value:BmpData, inputElement:Elem, id:String) { 
		super(target);
		this.inputElement = inputElement;
		this.value = value;
		this.id = id;
	}	
}
//
//
class SignField extends UICompo    {  
	static public inline var LABEL_DEFAULT 		:String = "Sign this document" ;
	static public inline var LABEL_CLASS 		:String = UICompo.APIX_PRFX+"label" ;
	static public inline var PAINT_CTNR_CLASS 	:String = UICompo.APIX_PRFX+"paintCtnr" ;	
	static public inline var VALID_CLASS 		:String = UICompo.APIX_PRFX+"valid" ;	
	static public inline var CLEAR_CLASS 		:String = UICompo.APIX_PRFX + "clear" ;	
	static public inline var IMG_CLASS 			:String = UICompo.APIX_PRFX + "img" ;	
	//ici static public inline var INPUT_CLASS 		:String = UICompo.APIX_PRFX + "input" ;	
	static public inline var IMG_OK_CLASS 		:String = UICompo.APIX_PRFX + "imgOk" ;
	static public inline var STROKE_COLOR :String = "#000000" ;	
	static public inline var THICKNESS :Int = 3 ;	
	static public inline var WIDTH :String = "340px" ;	
	static public inline var HEIGHT :String = "120px" ;	
	static public inline var LINE_CAP :String = "round" ;	
	/**
	 * event dispatcher when a PhotoField's char append 
	 * @see PhotoFieldEvent
	 */	
	public var click	(default, null):EventSource ;	
	/**
	 *  Hidden input element used by caller to get base64 url img from value attr
	 */	
	public var inputElement(get, never):Elem ; function get_inputElement () : Elem { return  base64Img; }
	//
	public var labelElement(default,null):Elem;	
	//private vars
	var paintCtnr:Elem;	
	var base64Img:Elem;
	var currFromPos:Vector;
	var currToPos:Vector;
	var mouseInPaintInitPos:Vector;
	var mouseClock:MouseClock; 
	var context:Context2D ;
	var bmpData:BmpData ;
	var displayClock:Clock;
	var displayIndex:Int;
	var bValid:Elem;
	var bClear:Elem;
	var drawingData:Array<Vector>;
	/**
	* constructor
	* @param ?p SignFieldProp
	*/
	public function new (?p:SignFieldProp) {
		super(); 
		click 	= new EventSource();
		compoSkinList = SignFieldLoader.__compoSkinList;
		setup(p);		
	}
	//
	//getters/setters
	public var color(get,null):String;		
	public var thickness(get,null):Int;		
	public var border(get,null):Bool;		
	/**
	 * image base64 url of signature
	 */
	public var base64UrlValue(get, null):String;
	//
	//
	
	/**
	 * setup  SignFieldProp
	 * @param ?p SignFieldProp
	 * @return this
	 */
	override public function setup (?p:SignFieldProp) :SignField {	
		super.setup(p);
		return this;
	}
	/**
	 * active slider when it is not auto. -enable is called just one time 
	 * @return this
	 */
	override public function enable ()  :SignField {		
		labelElement = ("#" + id + " ." + InputField.LABEL_CLASS).get();	
		paintCtnr = ("#" + id + " ." + SignField.PAINT_CTNR_CLASS).get();
		paintCtnr.initAsDragContainer();		
		bValid = ("#" + id + " ." + SignField.VALID_CLASS).get();		
		bClear = ("#" + id + " ." + SignField.CLEAR_CLASS).get();
		base64Img = ("#" + id + " ." + SignField.IMG_CLASS).get();
		//inputElement = base64Img;
		bValid.on(StandardEvent.CLICK, onClickValid);	
		bClear.on(StandardEvent.CLICK, onClickClear);	
		bClear.visible(false);
		bValid.visible(false);
		paintCtnr.on(StandardEvent.MOUSE_DOWN, startPaint);
		context = paintCtnr.getContext2D();
		enabled = true;	
		bClear.inner(lang.signClear);
		return this;
	}
	override public function remove ()  :SignField {	
		super.remove();
		bValid.off(StandardEvent.CLICK, onClickValid);	
		bClear.off(StandardEvent.CLICK, onClickClear);	
		paintCtnr.off(StandardEvent.MOUSE_DOWN, startPaint);
		element.delete();
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : SignField {	
		super.update();
		labelElement.text(label);	
		paintCtnr.attr("width", width,true);		
		paintCtnr.attr("height", height, true);
		paintCtnr.width( Std.parseFloat(width));
		paintCtnr.height(Std.parseFloat(height));
		(border != true?paintCtnr.css("borderWidth","0"):paintCtnr.css("borderWidth","thin")) ;
		context.strokeStyle = color;
		context.lineWidth = thickness;
		context.lineCap = SignField.LINE_CAP;
		clear();
		bmpData = { name:name, color:color, thickness:thickness, lineCap:context.lineCap, drawingData:drawingData , mediaData:null, empty:true };	
		if (base64UrlValue != "") {
			showBase64Img (base64UrlValue);
			paintCtnr.hide();
			bClear.visible(true);
			bValid.visible(false);
			bmpData.toUrlData = base64UrlValue;
		}
		else base64Img.hide();
		return this;
	}
	/**
	 * private  
	 */
	function showBase64Img (str:String) {	
		base64Img.show("block");
		if (!(g.isAndroidNative300 && g.isPhone )) base64Img.attrib(Attrib.src, str) ;
		else ("#" + id + " ." + SignField.IMG_OK_CLASS).get().show("block");  
	}
	function startPaint (e:MouseTouchEvent) {	
		//trace("down start pointerId="+(untyped e.pointerId));		
		e.preventDefault();	
		bValid.visible(true);
		bClear.visible(false);  		
		clearBmpData() ;		
		//mouse	pos in ctnr pos	
		mouseInPaintInitPos = MouseTouchEvent.getLocalVector(e, paintCtnr) ;		
		//
		currFromPos = mouseInPaintInitPos;
		currToPos = currFromPos;
		if (mouseClock != null) {
			mouseClock = mouseClock.remove();
		}
		mouseClock = new MouseClock(onClock, stopPaint);
		draw (currFromPos, currToPos) ;
		push (currFromPos, currToPos) ;
	}
	function stopPaint (clk:MouseClock) {
		mouseClock = clk.remove();	
	}	
	function onClock (clk:MouseClock) {		
		currToPos=clk.vector.add(mouseInPaintInitPos);		
		draw (currFromPos, currToPos) ;
		push (currFromPos, currToPos) ;
		currFromPos = currToPos;
	}
	function draw (from:Vector, to:Vector) {
		context.save();
		context.beginPath();
		context.moveTo(from.x,from.y);
		context.lineTo(to.x, to.y);
		context.stroke();
		context.closePath();
		context.restore();		
	}
	
	function push (from:Vector,to:Vector) {
		drawingData.push(from) ;
		drawingData.push(to) ;
		
	}
	function clearBmpData () {
		bmpData.mediaData = null;	
		bmpData.toUrlData = null ;
		bmpData.empty = true;
	}
	function clear () {
		drawingData = [] ;
	}
	function onClickValid (e:ElemEvent) {	
		bmpData.mediaData =  { name:name, type:"image", ext:"png", code:"base64", data:paintCtnr.toBase64() } ; //paintCtnr.toBase64Url() ; //
		bmpData.toUrlData = paintCtnr.toBase64Url();
		bmpData.drawingData =  drawingData;
		bmpData.empty = false;
		base64Img.attrib(Attrib.src,paintCtnr.toBase64Url()) ; // ici
		display ();		
		bValid.visible(false);
	}
	function onClickClear (e:ElemEvent) {	
		if (displayClock != null) displayClock = displayClock.remove();			
		clearContext ();
		clearBmpData ();
		clear();
		base64Img.hide();
		base64Img.attrib(Attrib.src,"") ; 
		bClear.visible(false);
		bValid.visible(false);
		paintCtnr.show();
		if (click.hasListener()) click.dispatch(new SignFieldEvent(this, value,inputElement, id));
	}
	function clearContext () {
		context.clearRect(0, 0, contextWidth, contextHeight); 
	}
	function display () {	
		if (displayClock != null) displayClock = displayClock.remove();		
		clearContext ();
		displayIndex = 0;
		displayClock = new Clock(onDisplayClock,0.01); 
	}
	function onDisplayClock () {
		if (displayIndex+1 < bmpData.drawingData.length) {
			var from=bmpData.drawingData[displayIndex];
			var to=bmpData.drawingData[displayIndex+1];
			draw (from, to) ;
			displayIndex+=2;
		} else {
			if (displayIndex < bmpData.drawingData.length) {
				var from=bmpData.drawingData[displayIndex];
				draw (from, from) ;
			}		
			displayClock.remove();
			paintCtnr.hide();
			bClear.visible(true);
			showBase64Img (bmpData.toUrlData) ;
			if (click.hasListener()) click.dispatch(new SignFieldEvent(this, value, inputElement, id));
		}
	}
	
	//get/set
	
	function get_color () :String {
		var v:String = null;
		if (compoProp.color != null) {
			v = compoProp.color ;
		}
		else {			
			v = SignField.STROKE_COLOR;			
		}		
		compoProp.color = v;
		return v;
	}
	function get_thickness () :Int {
		var v:Int = null;
		if (compoProp.thickness != null) {
			v = compoProp.thickness ;
		}
		else {			
			v = SignField.THICKNESS;			
		}		
		compoProp.thickness = v;
		return v;
	}
	function get_border () :Bool {
		var v:Bool = null;
		if (compoProp.border != null) {
			v = compoProp.border ;
		}
		else {			
			v = true;			
		}		
		compoProp.border = v;
		return v;
	}
	override function get_width () :String {
		var v:String = null;
		if (compoProp.width != null) v = compoProp.width ;
		else {
			var el = ("#" + id + " ." + SignField.PAINT_CTNR_CLASS).get();		
			if (el != null) v = "" + el.width() + "px";
			if (v == "" || v=="0px" ) v = SignField.WIDTH;
		}
		compoProp.width = v ;		
		return v;
	}
	override function get_height () :String {
		var v:String=null;
		if (compoProp.height != null) v = compoProp.height ;
		else {
			var el = ("#" + id + " ." + SignField.PAINT_CTNR_CLASS).get();		
			if (el != null) v = "" + el.height() + "px";
			if (v == "" || v=="0px" ) v = SignField.HEIGHT;
		}
		compoProp.height = v;	
		return v;
	}
	var contextHeight(get,null) :Float ;	
	function get_contextHeight () :Float {
		return Std.parseFloat(height);
	}
	var contextWidth(get,null) :Float ;	
	function get_contextWidth () :Float {
		return Std.parseFloat(width);
	}
	override function get_value ():BmpData {	
		return bmpData ;
	}	
	override function get_isEmpty () : Bool {
		return value.empty ;		
	}
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = lang.signIt;
			if (g.strVal(v,"")=="") v=SignField.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	function get_base64UrlValue () :String {
		var v:String=null;
		if (compoProp.base64UrlValue != null) v = compoProp.base64UrlValue ;
		else {
			v = "";	
		}
		compoProp.base64UrlValue = v;		
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
	 * use it for each used skin ; sliders can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		SignFieldLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit SignField
 */
class SignFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "SignField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + SignFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( SignFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		SignFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
