package apix.ui.input;
//
import apix.common.display.Common;
import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.common.event.timing.Clock;
import apix.ui.tools.PopBox;
import apix.ui.UICompo;
import apix.common.util.Global;
import apix.ui.input.InputField ;
import apix.ui.UICompo.UICompoLoader;
import apix.ui.UICompo.CompoSkin;
import haxe.Http; 
import apix.common.display.ElementExtender.InputType;
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
 * @param  value			input value yyyy/mm/dd
 * @param  pickerSkin		skinName of picker date skin
 * @param  elementToHide	when date picker is open
 */
/**
 * Main output properties
 * @param value 		output value yyyy-mm-dd
 * @param values 		@see DateValues typdef
 * @param displayValue 	dd/mm/yyyy
 * @param dataValue 	yyyy-mm-dd  (idem than value)
 * @param inputElement	Elem with value=dd/mm/yyyy
 * @param dataElement	Elem with value=yyyy-mm-dd
 */
//
typedef DateFieldProp = { 
	> InputFieldProp ,
	? pickerSkin:String,
	? elementToHide:String
} 
typedef PickerInfo = { 
	day:Int,
	month:Int,
	year:Int
} 
typedef DateValues = { 
	day:Int,
	month:Int,
	year:Int,
	date:Date,
	displayValue:String,
	dataValue:String	
} 
/**
 * Event
 * @source  change
 * @param		target				this
 * @param		values				DateValues typdef
 * @param		inputElement		<input> Element
 * @param		id					this Element id
 */

class DateFieldEvent extends StandardEvent {
	public var values:DateValues;
	public var value:String;
	public var dataElement:Elem;
	public var inputElement:Elem;
	public var id:String;
	public function new (target:DateField, values:DateValues,value:String, dataElement:Elem,inputElement:Elem, id:String) { 
		super(target);
		this.values = values;
		this.value = value;
		this.inputElement = inputElement; 
		this.dataElement = dataElement; 
		this.id = id;
	}	
}
//
class DateField extends InputField    {	
	//
	static public inline var PLACE_HOLDER_DEFAULT :String = "jj/mm/aaaa" ;
	//
	/**
	 * event dispatcher
	 */
	public var change	(default, null):EventSource ;	
	public var dataElement(default,null):Elem;
	//
	public var pickerSkin(get,null):String;
	public var pickerElement(default, null):Elem;	
	public var elementToHide(get, null):String;	
	public var date(default, null):Date;	
	public var day(default, null):Int;	
	public var month(default, null):Int;	
	public var year(default, null):Int;	
	var pickerSkinList(get, null):Array<CompoSkin>;
	// values
	public var displayValue(get,null):String;
	public var dataValue(get,null):String;
	public var values(get, null):DateValues;
	//
	var popBox:PopBox;	
	var pickerInfo:PickerInfo;	
	var pickerButtonClock:Clock;
	var pickerLoop:Int;
	/**
	* constructor
	* @param ?p DateFieldProp
	*/
	public function new (?p:DateFieldProp) {
		p.type = InputType.TEXT;
		pickerLoop = 0;
		super(p);
		change 	= new EventSource();
	}
	
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :DateField {	
		inputElement = ("#" + id + " input").get();		
		labelElement = ("#" + id + " ." + InputField.LABEL_CLASS).get();			
		inputElement.prop("readOnly", true);
		inputElement.on(StandardEvent.FOCUS, onEnterInputElement);
		//
		dataElement = Common.document.createElement("input");		
		dataElement.type("text"); dataElement.hide(); 
		element.addChild(dataElement);	
		enabled = true;	
		return this;
	}
	
	override public function remove ()  :DateField {	
		inputElement.off(StandardEvent.FOCUS, onEnterInputElement);
		super.remove();
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : DateField {	
		super.update();	
		var v:String = value;
		if (v != "") {
			var m = v.isDate();
			if (m != "") value = "";			
		}
		storeDate(value);
		displayDate();
		return this;
	}		
	/**
	 * private  
	 */	
	function storeDate(v:String)  {	
		if (v == "") {
			date = null; day = null; month = null; year = null ;
		} else {
			year 	= Std.parseInt(v.substr(0, 4));
			month 	= Std.parseInt(v.substr(5, 2));
			day 	= Std.parseInt(v.substr(8, 2));	
			date = new Date(year,month,day,0,0,0);
		}
	}		
	function displayDate() {
		dataElement.value(dataValue);
		inputElement.value(displayValue);
	}		
	function onEnterInputElement (e:ElemEvent) {
		if (pickerElement == null) createPicker ();
		openPicker();	
	}
	function dispatchChange () {
		value = dataValue;
		if (change.hasListener()) change.dispatch(new DateFieldEvent(this,values,value,dataElement,inputElement,id) ) ;
	}
	
	function onEndPicker (e:ElemEvent, data:Dynamic) {
		if (data.action == "valid") getDataFromPicker();	
		else if (data.action == "clear") {
			date = null; day = null; month = null; year = null ; pickerInfo = null;
			dispatchChange();
		}
		if (data.action != "cancel") {
			displayDate();
			dispatchChange();
		}
		for (el in UICompo.inputStk) el.prop("disabled", false) ;
		popBox.close();
	}
	function createPicker ()  {
		var el:Elem = Common.createElem();
		el.inner(getPickerSkin(pickerSkin).skinContent);
		pickerElement = el.firstElementChild;
		pickerElement.id = id + "-datePicker";
		//
		popBox= new PopBox().create({elementToHide:elementToHide.get()});
		popBox.addChild(pickerElement);
		enablePicker();
	}
	function enablePicker ()  {
		("#" + pickerElement.id + " .apix_enter").get().on(StandardEvent.CLICK	, onEndPicker,{action:"valid"}) ;
		("#" + pickerElement.id + " .apix_cancel").get().on(StandardEvent.CLICK	, onEndPicker,{action:"cancel"}) ;
		("#" + pickerElement.id + " .apix_clear").get().on(StandardEvent.CLICK	, onEndPicker,{action:"clear"}) ;
		//
		("#" + pickerElement.id + " .apix_button").on(StandardEvent.MOUSE_DOWN	, onDownPickerButton) ;
		("#" + pickerElement.id + " .apix_button").on(StandardEvent.MOUSE_UP		, onUpPickerButton	) ;
		
	}	
	function openPicker () {		
		setDataToPicker();		
		for (el in UICompo.inputStk) el.prop("disabled", true) ;
		popBox.open();	
	}	
	function setDataToPicker () {
		if (date == null) {
			if (pickerInfo==null) {
				var d = Date.now() ;
				pickerInfo = { year:d.getFullYear(), month:d.getMonth() + 1, day:d.getDate() };	
			}
		} else pickerInfo = { year:year,month:month,day:day };	
		displayPickerInfo ();		
	}
	function getDataFromPicker () {
		year 	= pickerInfo.year;
		month 	= pickerInfo.month;
		day 	= pickerInfo.day;	
		date = new Date(year, month, day, 0, 0, 0);		
	}	
	function displayPickerInfo () {		
		("#" + pickerElement.id + " .apix_year").get().inner(pad(pickerInfo.year));
		("#" + pickerElement.id + " .apix_month").get().inner(pad(pickerInfo.month));
		("#" + pickerElement.id + " .apix_day").get().inner(pad(pickerInfo.day));		
	}	
		
	// in picker listeners
	function onUpPickerButton (e:ElemEvent) {
		if (pickerButtonClock!=null) pickerButtonClock=pickerButtonClock.remove();
		pickerLoop = 0;
	}
	function onDownPickerButton (e:ElemEvent) {
		var el:Elem = cast(e.currentTarget);
		doDownPickerButton (el);
		if (pickerButtonClock!=null) pickerButtonClock=pickerButtonClock.remove();
		pickerButtonClock = new Clock(doDownPickerButton, .25);
		pickerButtonClock.top.on(onClockPickerButton,{el:el});
	}
	function onClockPickerButton (e:StandardEvent) {
		pickerLoop++;
		var el:Elem = e.data.el;
		if (pickerLoop > 8) {
			if (pickerButtonClock!=null) pickerButtonClock=pickerButtonClock.remove();
			pickerButtonClock = new Clock(doDownPickerButton,0.08);
			pickerButtonClock.top.on(onClockPickerButton,{el:el});
		}
		doDownPickerButton (el);
	}
	
	function doDownPickerButton (el:Elem) {		
		if (el.hasClass("apix_moreDay")) {
			pickerInfo.day++;
			if (pickerInfo.day > g.maxDayIn(pickerInfo.month, g.isBissextile(pickerInfo.year))) pickerInfo.day = 1 ;			
		}
		else if (el.hasClass("apix_moreMonth")) {
			pickerInfo.month++;
			if (pickerInfo.month > 12 ) pickerInfo.month = 1 ;							
		}
		else if (el.hasClass("apix_moreYear")) {
			pickerInfo.year++;
			if (pickerInfo.year > 9999 ) pickerInfo.year = 9999 ;						
		}
		else if (el.hasClass("apix_lessDay")) {
			pickerInfo.day--;
			if (pickerInfo.day < 1 ) pickerInfo.day = g.maxDayIn(pickerInfo.month, g.isBissextile(pickerInfo.year)) ;			
		}
		else if (el.hasClass("apix_lessMonth")) {
			pickerInfo.month--;
			if (pickerInfo.month < 1 ) pickerInfo.month = 12 ;							
		}
		else if (el.hasClass("apix_lessYear")) {
			pickerInfo.year--;
			if (pickerInfo.year < 1000 ) pickerInfo.year = 1000 ;						
		}
		//
		while (pickerInfo.day > g.maxDayIn(pickerInfo.month, g.isBissextile(pickerInfo.year))) {
			pickerInfo.day-- ;
		}	
		displayPickerInfo ();
	}
	
	//
	function pad (v:Int) :String {	
		if (v>31) return g.strVal(v); 
		else return StringTools.lpad(g.strVal(v), "0", 2) ;
	}
	
	function getPickerSkin (v:String) :CompoSkin {	
		var ret = null;
		for (o in pickerSkinList ) {			
			if (o.skinName == v) {
				ret = o; break;
			}
		}
		return ret ;
	}
	//get/set
	function get_displayValue () : String {	
		var v;
		if (date == null) 		v = "" ;
		else					v 	= pad(day) + "/"
									+ pad(month)+ "/"
									+ pad(year);
		return v ;
	}	
	function get_dataValue () :String {
		var v ;
		if (date == null) 		v = "" ;
		else					v 	= pad(year) + "-"
									+ pad(month)+ "-"
									+ pad(day);
		return v ;
	}
	function get_values () : DateValues {
		return { day:day, month:month, year:year, date:date, displayValue:displayValue, dataValue:dataValue } ;
	}
	override function set_value (v:String) :String {
		setCompoProp( { value:v } );	
		return v;
	}
	//	
	override function get_placeHolder () :String {  
		var v:String=null;
		if (compoProp.placeHolder != null) v = compoProp.placeHolder ;
		else {
			v = DateField.PLACE_HOLDER_DEFAULT;			
		}
		compoProp.placeHolder = v;		
		return v;
	}
	function get_pickerSkin () :String {
		var v:String=null;
		if (compoProp.pickerSkin != null) v = compoProp.pickerSkin ;
		else {
			v = "default";			
		}
		compoProp.pickerSkin = v;		
		return v;
	}
	function get_pickerSkinList () :Array<CompoSkin> {
		return DatePickerLoader.__compoSkinList ;
	}	
	function get_elementToHide  () :String {
		var v:String=null;
		if (compoProp.elementToHide != null) v = compoProp.elementToHide ;
		else {
			v = "";			
		}
		compoProp.elementToHide = v;		
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
	public static function init (?skinName = "default", ?pathStr:String)  {
		DatePickerLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit DatePicker
 */
class DatePickerLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "DatePicker/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + DatePickerLoader.PATH : pathStr ; 
		UICompoLoader.__push( DatePickerLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		DatePickerLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}	