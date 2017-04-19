package apix.ui.slider;
//
import apix.common.tools.math.MathX;
import apix.common.event.EventSource;
import apix.common.tools.math.Rectangle;
import apix.common.tools.math.Vector;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo.UICompoLoader;
import apix.common.event.StandardEvent;
import haxe.Json;
//
import apix.ui.UICompo.CompoProp;
import apix.ui.UICompo;
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
 * @param  inputValue	an array Json string with initial value(s) i.e. : "[100,300]" for 2 buttons slider. 
 * 		    - must be between start and end / asc or desc
 * @param  bounds		to limmit button(s) movement
 * @param  start		number
 * @param  end			number
 * @param  decimal		number of decimal after 0 -if int is true decimal =0
 * @param  mouseScale
 * @param  overlay		Bool  	used when there are several selectors : true if a selector can move over an other selector -default is false
 * @param  gap			Int		used when overlay is false : minimum space in pixel between 2 selectors -default is 5
 * @param  hideValue	Bool true if inputElement used for display value(s) must be hidden -default is false
 */
/**
 * Main output properties
 * @param lastSelector				last used selector.
 * @param inputElement 				input element with value of lastSelector
 * @param selectors					Array of all selectors -if multiple button @see typeDef Slider.Selector
 * @param value						lastSelector's value
 */
//
typedef Selector = { 
	/**
	 * inputElement to store value (String)
	 */
	public 	var inputElem : Elem; 
	/**
	 * button (selector's Element)
	 */
	public 	var elem : Elem; 
	/**
	 * numeric value between start and end
	 */
	public 	var value : Float;
	/**
	 * rounded value with 0 to n decimal(s)
	 */
	public  var round :Int -> Float;
	/**
	 * physical position between the bounds.
	 */
	public 	var pos : Float; 
	//private vars
				var xpos : Float; 
				var ypos : Float; 
	@:optional 	var used : Bool; 
	
}
//
typedef SliderProp = { 
	> CompoProp ,
	/**
	 * slider bounds
	 */
	?bounds:Rectangle ,
	/**
	 * numeric start value (from -n to n)
	 * default is bounds.x (or bounds.y if vertical)
	 */
	?start:Float,
	/**
	 * numeric end value(from -n to n)
	 * default is start + bounds.length 
	 */
	?end:Float,	
	/**
	 * number of decimal to round value
	 * default is 0 
	 */
	?decimal:Int,	
	/**
	 * physical scale between mouse move and selector move.
	 * default is 1 
	 */
	?mouseScale:Float,	
	/**
	 * used when there are several selectors : true if a selector can move over an other selector
	 * default is false
	 */
	?overlay:Bool,
	/**
	 * used when overlay is false : minimum space in pixel between 2 selectors
	 * default is 5 
	 */
	?gap:Int,
	/**
	 *  to init and display the values in inputElements value
	 */
	? inputValue:String,
	/**
	 *  true if field with value must be hidden default is false.
	 */
	? hideValue:Bool
	
} 
//
/**
 * Out Event
 * @source  change 
 * @param       target 			this
 * @param		value			lastSelector's value	
 * @param		selectors 		Array of all selectors -if multiple button @see typeDef Slider.Selector
 * @param		inputElement	input element with value of lastSelector
 * @param		lastSelector	current button moved datas
 *  				lastSelector.elem 		last button Elem
 *  				lastSelector.value 		last selector value
 *  				lastSelector.round(n)	round value with n decimal(s)
 *  				lastSelector.pos 		x or y pos
 */
class SliderEvent extends StandardEvent {
	public var lastSelector:Selector;
	public var value:Float;
	public var selectors:Array<Selector>;
	public var inputElement:Elem;
	public function new (target:Slider, lastSelector:Selector,value:Float,inputElement:Elem,selectors:Array<Selector>) { 
		super(target);
		this.lastSelector = lastSelector;
		this.value = value ;
		this.selectors=selectors;
		this.inputElement=inputElement;
	}	
}
//

//
class Slider extends UICompo    {  
	static public inline var BAR_CLASS :String = UICompo.APIX_PRFX+"bar" ;
	static public inline var SELECTOR_CLASS :String = UICompo.APIX_PRFX+"selector" ;
	static public inline var BOUNDS_CLASS :String = UICompo.APIX_PRFX + "bounds" ;	
	static public inline var LABEL_DEFAULT :String = "Move slider's buttons" ;
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	/**
	 *  input elements used to get result of lastSelector
	 */	
	public var inputElement(get, never):Elem ; function get_inputElement () : Elem { return  lastSelector.inputElem; }
	/**
	 * event dispatcher when a Slider's Selector is changing.
	 */
	public var change(default,null):EventSource ;
	/**
	 * Selector array.
	 * use it when multi Selector Slider
	 */
	public var selectors(default, null):Array<Selector>;
	/**
	 * Last used selector or unique Selector
	 * use it when mono Selector Slider
	 */
	public var lastSelector(default, null):Selector;
	
	/**
	 * to init and display the value in inputElements values
	 */
	public var inputValue(get, null):String;
	/**
	 * true if field with value must be hidden default is false.
	 */
	public var hideValue(get, null):Bool;	
	/**
	 * mouse move scale.
	 * read-only.
	 * use setup() to write this var ; @see SliderProp .
	 */
	public var mouseScale(get,null):Float;			   		
	/**
	 * geometric bounds
	 * read-only.
	 * use setup() to write this var ; @see SliderProp .
	 */
	public var bounds(get,null):Rectangle;		// also write-enabled by setup() 	// 
	/**
	 * start value
	 * read-only.
	 * use setup() to write this var ; @see SliderProp .
	 */
	public var start(get,null):Float;			
	/**
	 * end value
	 * read-only.
	 * use setup() to write this var ; @see SliderProp .
	 */
	public var end(get,null):Float;				
	/**
	 * number of decimal to round value
	 * default is 0 
	 * read-only.
	 * use setup() to write this var ; @see SliderProp .
	 */
	public var decimal(get,null):Int;				
	/**
	 * true if a selector can move over an other selector - default is false
	 * read-only.
	 * use setup() to write this var ; @see SliderProp .
	 */
	public var overlay(get, null):Bool;		
	/**
	 * minimum space between 2 selectors
	 * read-only.
	 * use setup() to write this var ; @see SliderProp .
	 */
	public var gap(get, null):Int;		
	/**
	 * true if there are several selectors
	 * read-only.
	 */
	public var multiple(get,null):Bool;	
	/**
	 * length =  end - start ;
	 * read-only.
	 */
	public var length(get,null):Float;			
	/**
	 * true if Slider is vertical.
	 * read-only.
	 */
	public var vertical(get, null):Bool;	
	/**
	 * true if start<end
	 * read-only.
	 */
	public var ascending(get, null):Bool;	
	/**
	 * label
	 */
	public var labelElement(default,null):Elem;			
	/**
	 * Selector.round() of last moved Selector.
	 */
	public function round (?n:Int = 0) :Float {	return lastSelector.round(n) ;	}
	//
	var mouseScaleVector(get,null):Vector;
	var lastSelectorIndex:Int;
	/**
	* constructor
	* @param ?p SliderProp
	*/
	public function new (?p:SliderProp) {
		super(); 
		compoProp.auto = false;
		change = new EventSource();
		selectors = new Array();
		compoSkinList = SliderLoader.__compoSkinList;
		setup(p);		
	}
	/**
	 * setup  SliderProp
	 * @param ?p SliderProp
	 * @return this
	 */
	override public function setup (?p:SliderProp) :Slider {	
		setCompoProp(p);
		if (isInitialized()) {
			if (!isCreated()) create();			
			//
			if (ctnrExist()) {
				if (auto && !enabled ) enable();
				update();	
			}
		}
		return this;
	}
	/**
	 * active slider when it is not auto. -enable is called just one time 
	 * @return this
	 */
	override public function enable ()  : Slider {
		labelElement = ("#" + id + " ." + Slider.LABEL_CLASS).get();
		if (labelElement!=null) {
			if (label != "") { labelElement.text(label); labelElement.show(); }
			else labelElement.hide();
		}
		// resize slider bounds regarding parent's size.
		var size;
		if (vertical) {
			size = element.parent().height() ;			
			var pct = (size - ("#" + id + " ." + Slider.SELECTOR_CLASS).get().height()) * 100 / size;
			("#" + id + " ." + Slider.BOUNDS_CLASS).get().css("height", Std.string(pct)+"%");
			("#" + id + " ." + Slider.BAR_CLASS).get().css("height", Std.string(pct) + "%");
		}
		else {
			size = element.parent().width() ;			
			var pct = (size - ("#" + id + " ." + Slider.SELECTOR_CLASS).get().width()) * 100 / size;
			("#" + id + " ." + Slider.BOUNDS_CLASS).get().css("width",Std.string(pct)+"%");
			("#" + id + " ." + Slider.BAR_CLASS).get().css("width", Std.string(pct) + "%");			
		}
		//
		var idx = 0; var shft = 0;
		var arr:Array<Elem> = ("#" + id + " ." + Slider.SELECTOR_CLASS).all(element);
		var inputValuesArray:Array<Float> = checkInputValues(Json.parse(g.jsonParseCheck(inputValue, "[]")));		
		if (arr.length > 0) {
			for (el in arr) {
				var val:Float = null;
				var inEl = Common.document.createElement("input");		
				inEl.type("text"); inEl.enable(false); inEl.height(30); inEl.width(100); inEl.show("inline"); 
				inEl.posy(5); inEl.posx(shft); shft += 5;
				element.addChild(inEl);
				if (hideValue) inEl.hide();
				if (inputValuesArray.length > idx) {
					val = inputValuesArray[idx];					
					selectors.push(initSelector({ inputElem:inEl, elem:el, value:val, pos:null,xpos:null, ypos:null, round :null } ));
				} 
				else {
					selectors.push(updateSelector ( { inputElem:inEl, elem:el, value:null, pos:null,xpos:el.posx(), ypos:el.posy(), round :null } ));				
				}
				el.on(g.isMobile?StandardEvent.TOUCH_START:StandardEvent.MOUSE_DOWN, startDrag);
				el.on(g.isMobile?StandardEvent.TOUCH_END:StandardEvent.MOUSE_UP, stopDrag);
				el.on(StandardEvent.MOUSE_DOWN, startDrag);
				el.on(StandardEvent.MOUSE_UP, stopDrag);
				idx++;				
			}	
			lastSelector = selectors[0];			
		}	
		enabled = true;	
		//ici lastSelector.used = true;
		change.dispatch(new SliderEvent(this,lastSelector,value,inputElement,selectors));
		return this;
	}
	override public function remove ()  : Slider {
		super.remove();
		for (s in selectors) {
			s.elem.off(g.isMobile?StandardEvent.TOUCH_START:StandardEvent.MOUSE_DOWN, startDrag);
			s.elem.off(g.isMobile?StandardEvent.TOUCH_END:StandardEvent.MOUSE_UP, stopDrag);
			s.elem.off(StandardEvent.MOUSE_DOWN, startDrag);
			s.elem.off(StandardEvent.MOUSE_UP, stopDrag);
		}
		element.delete();		
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override public function update() : Slider {	
		super.update();		
		return this;
	}
	/**
	 * private  
	 */
	function startDrag (e) {			
		e.preventDefault();		
		var el:Elem = e.currentTarget;
		var o = selectors.objectOf(el,"elem");
		lastSelector=o.object;		
		lastSelectorIndex = o.index;		
		el.startDrag(getSelectorBounds(), mouseScaleVector);//
		Global.mouseClock.top.on(onClock,{elem:el});
	}
	function stopDrag (e) {
		var el:Elem = e.currentTarget;
		el.stopDrag();
	}
	function onClock (e:StandardEvent) {
		var elem:Elem = e.data.elem;
		lastSelector.xpos = elem.posx(); lastSelector.ypos = elem.posy(); 
		lastSelector.used = true;
		updateSelector(lastSelector);
		change.dispatch(new SliderEvent(this,lastSelector,value,inputElement,selectors));
	}
	function initSelector(o:Selector):Selector {
		var sc = length / bounds.length ;
		o.pos = (!vertical?bounds.x:bounds.y) + (o.value-start) / sc ;		
		if (vertical) {
			o.ypos = o.pos; 
			o.elem.posy(o.pos);
		}
		else {
			o.xpos = o.pos;
			o.elem.posx(o.pos);
		}
		o.round = (o.round != null)? o.round:function (?n:Int = 0) { return MathX.round(o.value, n) ; } ;		
		o.inputElem.value(g.strVal(o.round(decimal),""));
		return o;
	}
	function updateSelector (o:Selector):Selector  {
		var sc = length / bounds.length ;	
		o.pos = !vertical? o.xpos :o.ypos ;
		if (o.round!=null) {
			o.value =  start + ((o.pos - (!vertical?bounds.x:bounds.y)) * sc);
			o.inputElem.value(g.strVal(o.round(decimal), ""));
		}
		o.round = (o.round != null)?o.round:function (?n:Int = 0) {return MathX.round(o.value, n) ;} ;
		return o;
	}
	function checkInputValues (arr:Array<Float>):Array<Float>  {
		for (i in 0...arr.length) {
			if (ascending) {
				if (arr[i] < start) arr[i] = start;
				if (arr[i] > end) arr[i] = end;	
			}
			else {
				if (arr[i] > start) arr[i] = start;
				if (arr[i] < end) arr[i] = end;	
			}
		}
		return arr;
	}
	
	// get_func
	function get_mouseScale () :Float {
		if (compoProp.mouseScale == null) compoProp.mouseScale=1 ;
		return compoProp.mouseScale;
	}
	function get_bounds () :Rectangle {
		var r:Rectangle=null;
		if (compoProp.bounds != null) r = compoProp.bounds ;
		else {
			var b:Elem = ("#" + id + " ." + Slider.BOUNDS_CLASS).get() ;
			if (b != null) r = new Rectangle(b.posx(), b.posy(), b.width(), b.height());
			else {
				if (element.width()>element.height()) 	r = new Rectangle(0, 0, element.width(), 0);
				else									r = new Rectangle(0, 0, 0,element.height());
			}
		}
		compoProp.bounds = r;
		return r;
	}
	function getSelectorBounds () :Rectangle {
		var v:Rectangle=bounds;
		if (multiple) if (!overlay) {
			var vx=0.; var vy=0.; var w=0. ; var h=0. ;
			var prev = lastSelectorIndex - 1;
			var next = lastSelectorIndex + 1;
			if (lastSelectorIndex == 0) {
				vx = bounds.x; 
				vy = bounds.y;
				w = selectors[next].xpos - vx- (!vertical?gap:0);
				h = selectors[next].ypos - vy- (vertical?gap:0);				
			}
			else if (lastSelectorIndex == selectors.length-1) {
				vx = selectors[prev].xpos+(!vertical?gap:0);
				vy = selectors[prev].ypos+(vertical?gap:0);
				w = bounds.x+bounds.width - vx;
				h = bounds.y+bounds.height - vy;				
			}
			else if (lastSelectorIndex>0 && lastSelectorIndex< selectors.length-1) {
				vx = selectors[prev].xpos+(!vertical?gap:0);
				vy = selectors[prev].ypos+(vertical?gap:0);
				w = selectors[next].xpos - vx-(!vertical?gap:0);
				h = selectors[next].ypos - vy-(vertical?gap:0);	
			}	
			else { trace("f:: Selector index error ! "); }
			
			v = new Rectangle(vx,vy,w,h);
		}
		return v;
	}
	function get_start () :Float {
		var v:Float=null;
		if (compoProp.start != null) v = compoProp.start ;
		else {
			v = (!vertical)?bounds.x:bounds.y;			
		}
		compoProp.start = v;
		return g.numVal(v);
	}
	function get_end () :Float {
		var v:Float=null;
		if (compoProp.end != null) v = compoProp.end ;
		else {
			v = start + bounds.length;	
		}
		compoProp.end = v;
		return g.numVal(v);
	}
	function get_decimal () :Int {
		var v:Int=0;
		if (compoProp.decimal != null) v = compoProp.decimal ;
		compoProp.decimal = v;
		return g.intVal(v);
	}
	function get_length () :Float {
		return end-start ;
	}
	function get_overlay () :Bool {
		var v:Bool = null;
		if (multiple) {
			if (compoProp.overlay != null) v = compoProp.overlay ;
			else {
				v = false;	
			}
			compoProp.overlay = v;
		}
		return v;
	}
	function get_gap () :Int {
		var v:Int;
		if (compoProp.gap != null) v = compoProp.gap ;
		else v = 5;	
		compoProp.gap= v;		
		return v;
	}
	function get_multiple () :Bool {		
		return (selectors.length>1) ;
	}
	function get_vertical () :Bool {
		return (element.width() < element.height()) ;
	}
	override function get_value () :Float {
		return lastSelector.value ;
	}
	function get_inputValue () :String {
		var v:String=null;
		if (compoProp.inputValue != null) v = compoProp.inputValue ;
		else {
			v = "[]";	
		}
		compoProp.inputValue = v;		
		return v;
	}
	function get_hideValue () :Bool {
		var v:Bool=false;
		if (compoProp.hideValue != null) v = compoProp.hideValue ;
		compoProp.hideValue = v;		
		return v;
	}	
	function get_ascending () :Bool {
		return start<end;
	}	
	// used also if required==true to build the error message
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = lang.slider.label ;
			if (g.strVal(v,"")=="") v=Slider.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	
	function get_mouseScaleVector () :Vector {
		if (mouseScaleVector == null) mouseScaleVector = new Vector(mouseScale,mouseScale);
		return mouseScaleVector ;
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
		SliderLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit Slider
 */
class SliderLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "Slider/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + SliderLoader.PATH : pathStr ; 
		UICompoLoader.__push( SliderLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		SliderLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
