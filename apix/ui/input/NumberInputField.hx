package apix.ui.input;
//
import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.common.tools.math.MathX;
import apix.common.util.Global;
import apix.ui.input.InputField.InputFieldProp ;
import apix.ui.input.InputField.InputFieldEvent ;
import apix.common.display.ElementExtender.InputType;
//
//using
using apix.common.util.StringExtender;
using apix.common.display.ElementExtender;
//
/**
 * Main input properties 
 * @see UICompo and InputField for others
 * 
 * @param  value		input value as 999.99
 * @param  decimal		Number of digit after dot -or coma
 * @param  int			true if Integer or if decimal == 0
* 
 */
/**
 * Main output properties
 * @param value 	value 
 * @param inputElement	Elem with value
 */
//
typedef NumberInputFieldProp = { 
	> InputFieldProp ,
	?decimal:Int ,
	?int:Bool 
} 
//
/**
 * Event is InputFieldEvent
 * @source  input , blur
 * @see 	InputField.InputFieldEvent
 * @param		target				this
 * @param		value				value
 * @param		inputElement		<input> Element
 * @param		id					this Element id
 */
class NumberInputField extends InputField    {	
	var comaConversion:Bool; 
	var inputCharChecked:Bool; 
	//
	/**
	 * decimal number after dot
	 * read-only.
	 * use setup() to write this var ; @see InputFieldProp .
	 */
	public var decimal(get, null):Int;	
	/**
	 * true if integer
	 * read-only.
	 * use setup() to write this var ; @see InputFieldProp .
	 */
	public var int(get, null):Bool;	
	
	/**
	* constructor
	* @param ?p NumberInputFieldProp
	*/
	public function new (?p:NumberInputFieldProp) {
		super(p); 
		setup( { type:InputType.TEXT } );
		
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :NumberInputField {	
		super.enable();
		inputElement.on(StandardEvent.MOUSE_DOWN,onDownInputElement);
		inputElement.on(StandardEvent.BLUR,onLeaveInputElement);
		return this;
	}
	override public function remove ()  :NumberInputField {			
		inputElement.off(StandardEvent.MOUSE_DOWN,onDownInputElement);
		inputElement.off(StandardEvent.BLUR,onLeaveInputElement);
		super.remove();
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : NumberInputField {	
		var stp=""; var dot=".";
		setCompoProp( { int:(decimal == 0) } );	
		super.update();	
		align();
		inputElement.type(InputType.NUMBER);
		type = InputType.NUMBER;
		if (!int) {	
			for (i in 0...decimal) {
				stp += "0" + dot;
				dot = "";
			}
		}
		stp += "1";
		inputElement.step(stp);
		return this;
	}		
	/**
	 * private  
	 */	
	function onDownInputElement (e:ElemEvent) {
		inputElement.css("textAlign", "left");	
	}
	function onLeaveInputElement (e:ElemEvent) {
		var v:String = null;
		if (!int) {
			v = comaToDot (inputElement.value());
			v = Std.string(MathX.round(g.numVal(v), decimal));
			v = v.toDecimal(decimal);
		} else v = inputElement.value();	
		if (g.numVal(v, 0) == 0) inputElement.value("");
		align ();	
		value = v;			
		if (blur.hasListener()) blur.dispatch(new InputFieldEvent(this,value,inputElement,id) ) ;
	}
	function align () {
		inputElement.css("textAlign", "right");			
	}
	
	
	function comaToDot (v:String) :String {
		var len = v.length; 
		var p = v.indexOf(",");
		if (p > -1) {
			v = v.substring(0, p) + "."+v.substring(p+1, len);
			comaConversion = true;
			
		} 
		else comaConversion = false;	
		return v;
	}	
	
	//
	//get/set
	function get_decimal () :Int {
		var v:Int=null;
		if (compoProp.decimal != null) v = compoProp.decimal ;
		else {
			if (int) v = 0;
			else v = 2;			
		}
		compoProp.decimal = v;		
		return v;
	}
	function get_int () :Bool {
		var v:Bool=null;
		if (compoProp.int != null) v = compoProp.int ;
		else {
			v = false;			
		}
		compoProp.int = v;		
		return v;
	}
		
}
	