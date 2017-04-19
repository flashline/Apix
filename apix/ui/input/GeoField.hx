package apix.ui.input;
//
import apix.common.event.timing.Delay;
import apix.common.tools.math.GeoLoc;
import apix.ui.UICompo;
import apix.ui.UICompo.CompoProp;
//
//
import apix.common.event.EventSource;
import apix.common.display.Common;
import apix.common.event.StandardEvent;
//
import haxe.Http; 
//
import cordovax.navigator.Geolocation;
import cordovax.navigator.Geolocation.Coordinates;
import cordovax.navigator.Geolocation.Position;
import cordovax.navigator.Geolocation.PositionError;
//using
using apix.common.util.StringExtender;
//
using apix.common.display.ElementExtender;
//
/**
 * Main input properties 
 * @see UICompo for others
 * 
 * @param  value		String i.e. "48° 51' 23.279'' N et 2° 23' 27.169'' E"
 * @param  shortDisplay	true if only value is displayed -not detail
 */
/**
 * Main output properties
 * @param geoValue 		GeoValue object
 * @param value			Location String i.e. "48° 51' 23.279'' N et 2° 23' 27.169'' E"
 * @param inputElement	Elem.value=value
 */
//
typedef GeoFieldProp = { 
	> CompoProp, 
	? value:String,
	? shortDisplay:Bool
} 
typedef GeoValue = { 
	> Coordinates ,
	latDir:String,
	latDeg:Int,
	latMin:Int,
	latSec:Float,
	longDir:String,
	longDeg:Int,
	longMin:Int,
	longSec:Float,
	longitudeText:String,
	latitudeText:String	
} 
/**
 * Event
 * @source  input 
 * @param		target				this
 * @param		value				value
 * @param		inputElement		<input> Element
 * @param		id					this Element id
 */
class GeoFieldEvent extends StandardEvent {
	public var value:String;
	public var geoValue:GeoValue;
	public var inputElement:Elem;
	public var id:String;
	public function new (target:GeoField, value:String, geoValue:GeoValue, inputElement:Elem, id:String) { 
		super(target);
		this.value = value;
		this.geoValue = geoValue;
		this.inputElement = inputElement ;
		this.value = value;
		this.id = id;
	}	
}
//
class GeoField extends UICompo    {
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var LABEL_DEFAULT :String = "Save your geolocation :" ;
	static public inline var DISPLAY_CLASS :String =  UICompo.APIX_PRFX+"display" ;
	static public inline var BUTTON_CLASS :String =  UICompo.APIX_PRFX + "button" ;
	
	static public inline var DECIMAL :Int =  7;
	static public inline var TIME_OUT :Int =  6;
	/**
	 * event dispatcher when a GeoField's char append 
	 * @see GeoFieldEvent
	 */	
	public var click	(default, null):EventSource ;
	//
	public 	var buttonElement(default,null):Elem;	
	public 	var labelElement(default, null):Elem;	
			var displayElement(default, null):Elem;				
	//
			var geoValue : GeoValue ;
			var valueInputField:InputField;
			var imgOver : Elem;
			var imgOut : Elem;
			var imgDisplayStyle: String;
			var delay:Delay;
	//getter
	/**
	 * location String i.e. "48° 51' 23.279'' N et 2° 23' 27.169'' E"
	 */
	//public var value
	/**
	 * if true : only value is displayed
	 */
	public var shortDisplay(get, null):Bool;
	/**
	 * input element with value attr wich contains the result String -used by some caller instead of value
	 * read-only.
	 */
	public var inputElement(get, never):Elem ; function get_inputElement () : Elem { return  valueInputField.inputElement; }
	/**
	 * element with contains the label of result -used by some caller instead of value
	 * read-only.	 
	public var inputLabelElement(get, never):Elem ; function get_inputLabelElement () : Elem { return  valueInputField.labelElement; }
	*/
	/**
	* constructor
	* @param ?p GeoFieldProp
	*/
	public function new (?p:GeoFieldProp) {
		super(); 
		click 	= new EventSource();		
		compoSkinList = GeoFieldLoader.__compoSkinList;
		setup(p);		
	}
	/**
	 * setup  GeoFieldProp
	 * @param ?p GeoFieldProp
	 * @return this
	 */
	override public function setup (?p:GeoFieldProp) :GeoField {	
		super.setup(p);
		return this;
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :GeoField {			
		labelElement 	= 	("#" + id + " ." + GeoField.LABEL_CLASS).get();		
		displayElement 	= 	("#" + id + " ." + GeoField.DISPLAY_CLASS).get();				
		buttonElement 	= 	("#" + id + " ." + GeoField.BUTTON_CLASS).get();
		buttonElement.on(StandardEvent.CLICK, onClickButton);
		buttonElement.on(StandardEvent.MOUSE_OVER, onOverButton);
		buttonElement.on(StandardEvent.MOUSE_DOWN, onOverButton);
		buttonElement.on(StandardEvent.MOUSE_UP, onOutButton);
		buttonElement.on(StandardEvent.MOUSE_OUT, onOutButton);
		//
		imgOver=("#" + id + " ." + UICompo.IMG_OVER_CLASS).get();
		imgOut=("#" + id + " ." + UICompo.IMG_OUT_CLASS).get();		
		imgDisplayStyle = imgOver.hide();
		valueInputField=new InputField({ into:("#" + id ), label:lang.geoLocWhereIs, disabled:true, placeHolder:"",value:value } ) ;
		enabled = true;	
		return this;
	}
	
	override public function remove ()  :GeoField {		
		super.remove();
		buttonElement.off(StandardEvent.CLICK, onClickButton);
		buttonElement.off(StandardEvent.MOUSE_OVER, onOverButton);
		buttonElement.off(StandardEvent.MOUSE_DOWN, onOverButton);
		buttonElement.off(StandardEvent.MOUSE_UP, onOutButton);
		buttonElement.off(StandardEvent.MOUSE_OUT, onOutButton);
		element.delete();
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : GeoField {		
		super.update();
		labelElement.text(label);	
		return this;
	}	
	/**
	 * getInGridValue () is a function -instead of get_ var- to access at result value when GeoField is into a Grid and has the super class UICompo's type.
	 * @return
	 */
	/*override public function getInGridValue () :String {			
		return value ;
	}*/
	/**
	 * private  
	 */	
	function onOverButton (e:ElemEvent) {
		imgOver.show(imgDisplayStyle);
		imgOut.hide();
	}
	function onOutButton (e:ElemEvent) {
		imgOver.hide();
		imgOut.show(imgDisplayStyle);
	}
	function onClickButton (e:ElemEvent) {
		delay=new Delay(onTimeOut,GeoField.TIME_OUT);
		Geolocation.getCurrentPosition(onGeolocSuccess, onGeolocError,{enableHighAccuracy:true});	
	}	
	function onTimeOut () {
		delay.remove();
		("" + lang.geoLocTimeOut).alert(); 	
	}	
		
	function onGeolocSuccess (position:Position) {	
		delay.remove();
		storeGeoLoc(position);
		displayGeoLoc();		
		if (click.hasListener()) click.dispatch(new GeoFieldEvent(this, value, geoValue, inputElement, id));
	}	
	function onGeolocError(error:PositionError) {
		delay.remove();
		("" + lang.geoLocError+"\n"+"#"+error.code+"\n"+ error.message).alert(); 		
	}		
	function storeGeoLoc (position:Position)  {
		geoValue = g.newObject(position.coords);
		var gl = new GeoLoc(geoValue.latitude, geoValue.longitude);		
		geoValue.latDir = gl.latDir ;
		geoValue.latDeg = gl.latDeg;
		geoValue.latMin = gl.latMin;
		geoValue.latSec = gl.latSec;
		geoValue.longDir = gl.longDir;
		geoValue.longDeg = gl.longDeg;
		geoValue.longMin = gl.longMin;
		geoValue.longSec = gl.longSec;		
		//
		geoValue.latitudeText 	= ""+geoValue.latDeg + lang.geoLocDeg + geoValue.latMin + lang.geoLocMin + geoValue.latSec + lang.geoLocSec + geoValue.latDir;		
		geoValue.longitudeText 	= ""+geoValue.longDeg + lang.geoLocDeg + geoValue.longMin + lang.geoLocMin + geoValue.longSec + lang.geoLocSec + geoValue.longDir;		
		value	= 	 geoValue.latitudeText + lang.geoLocSepar + geoValue.longitudeText ;
	} 
	function displayGeoLoc () {	
		if (!shortDisplay) {
			displayElement.inner("");		
			var arr = [];
			arr.push(new NumberInputField( {into:("#" + id + " ." + GeoField.DISPLAY_CLASS), label:lang.geoLocLongitude, disabled:true, decimal:GeoField.DECIMAL, value:Std.string(geoValue.longitude).toDecimal(GeoField.DECIMAL) } ) );
			arr.push(new NumberInputField( {into:("#" + id + " ." + GeoField.DISPLAY_CLASS), label:lang.geoLocLatitude, disabled:true, decimal:GeoField.DECIMAL, value:Std.string(geoValue.latitude).toDecimal(GeoField.DECIMAL) } ) );
			arr.push(new NumberInputField( {into:("#" + id + " ." + GeoField.DISPLAY_CLASS), label:lang.geoLocAccuracy, disabled:true, decimal:0, value:Std.string(geoValue.accuracy) } ) );
			//
			for (compo in arr) {
				compo.labelElement.css("display", "inline-block");
				compo.labelElement.css("textAlign", "right");
				compo.inputElement.css("display", "inline-block");
				compo.labelElement.css("width", "49%");
				compo.inputElement.css("width", "49%");
			}
		}
		valueInputField.value=value;		
	}
	//get/set
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = lang.geoLocRecord ;
			if (g.strVal(v,"")=="") v=GeoField.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	/*override function get_value () : GeoValue {		
		return  geoValue.latitudeText + " " + geoValue.longitudeText;
	}*/
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
		inputElement.value(v);
		setCompoProp( { value:v } );	
		return v;
	}	
	function get_shortDisplay () :Bool {
		var v :Bool;
		if (compoProp.shortDisplay != null) v = compoProp.shortDisplay ;
		else {
			v = false;	
		}
		compoProp.shortDisplay = v;		
		return v;
	}
	//
	/**
	 * static public  
	 */
	/**
	 * load a skin.
	 * use it for each used skin ; GeoFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		GeoFieldLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit GeoField
 */
class GeoFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "GeoField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + GeoFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( GeoFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		GeoFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
