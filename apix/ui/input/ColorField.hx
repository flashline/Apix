package apix.ui.input;
//
import apix.common.display.Common;
import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.ui.UICompo;
import apix.common.util.Global;
import apix.ui.input.InputField ;
import apix.ui.input.InputField.InputFieldProp ;
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
 * @param  value		hexa input value
 */
/**
 * Main output properties 
 * @param value 		hexa value
 * @param values 		@see ColorValues typdef
 * @param inputElement	Elem with value=hexa value
 */
//
typedef ColorFieldProp = { 
	> InputFieldProp,
}
typedef ColorValues = { 
	hexa:String,
	rgb:String,
	red:Int,
	green:Int,
	blue:Int
} 
/**
 * Event
 * @source  change
 * @param		target				this
 * @param		values				ColorValues typdef
 * @param		inputElement		<input> Element
 * @param		id					this Element id
 */
class ColorFieldEvent extends StandardEvent {
	public var values:ColorValues;
	public var value:String;
	public var inputElement:Elem;
	public var id:String;
	public function new (target:ColorField, values:ColorValues,value:String, inputElement:Elem, id:String) { 
		super(target);
		this.value = value;
		this.values = values;
		this.inputElement = inputElement; 
		this.id = id;
	}	
}
//
class ColorField extends InputField {	
	//
	static public inline var PLACE_HOLDER_DEFAULT :String = "" ;
	//
	/**
	 * event dispatcher
	 */
	public var change	(default, null):EventSource ;
	//
	// values
	public var values(get, null):ColorValues;
	public var hexa(get, null):String;
	public var rgb(get, null):String;
	public var red(get, null):Int;
	public var green(get, null):Int;
	public var blue(get, null):Int;
	//
	/**
	* constructor
	* @param ?p ColorFieldProp
	*/
	public function new (?p:ColorFieldProp) {
		p.type = InputType.COLOR;
		super(p);
		change 	= new EventSource();
	}
	
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :ColorField {	
		inputElement = ("#" + id + " input").get();		
		labelElement = ("#" + id + " ." + InputField.LABEL_CLASS).get();
		//
		inputElement.on(StandardEvent.INPUT, onChange);
		inputElement.on(StandardEvent.BLUR, onChange);
		enabled = true;	
		return this;
	}
	
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : ColorField {	
		super.update();	
		return this;
	}		
	override function remove() : ColorField {	
		inputElement.off(StandardEvent.INPUT, onChange);
		inputElement.off(StandardEvent.BLUR, onChange);
		if (change.hasListener()) change.off();		
		super.remove();
		return this;
	}		
	/**
	 * private  
	 */		
	function onChange () {
		value = hexa;
		if (change.hasListener()) change.dispatch(new ColorFieldEvent(this,values,value,inputElement,id) ) ;
	}	
	//get/set	
	function get_values () : ColorValues {
		return { 	hexa:hexa, 
					rgb:rgb, 
					red:red,
					green:green,
					blue:blue,
				} ;
	}
	function get_hexa() :String {
		return inputElement.value();
	}
	function get_rgb () :String {
		return "rgb(" + red + "," + green + "," + blue+")" ;
	}
	function get_red () :Int {
		return g.hexToDec(hexa.substr(1, 2));
	}
	function get_green () :Int {
		return g.hexToDec(hexa.substr(3,2));
	}
	function get_blue () :Int {
		return g.hexToDec(hexa.substr(5,2));
	}
	//	
	override function get_placeHolder () :String {  
		var v:String=null;
		if (compoProp.placeHolder != null) v = compoProp.placeHolder ;
		else {
			v = ColorField.PLACE_HOLDER_DEFAULT;			
		}
		compoProp.placeHolder = v;		
		return v;
	}	
}
//
//
