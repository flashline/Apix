package apix.ui.input;
//
import apix.common.event.EventSource;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo.UICompoLoader;
import apix.common.display.ElementExtender.InputType;
import apix.common.event.StandardEvent;
//
import apix.ui.UICompo.CompoProp;
import apix.ui.UICompo;
import haxe.Http; 

//using
using apix.common.util.StringExtender;
using apix.common.display.ElementExtender;
//
/**
 * Main input properties 
 * @see UICompo for others
 * 
 * @param  value
 * @param  type			ElementExtender.InputType
 * @param  placeHolder
*/
/**
 * Main output properties
 * @param value 		value 
 * @param inputElement	Elem with value
 */
//
typedef InputFieldProp = { 
	> CompoProp ,
	/**
	 * input type.
	 */
	?type:InputType ,
	?placeHolder:String,
	?value:String,
	?disabled:Bool
	
} 
/**
 * Event
 * @source  input 
 * @param		target				this
 * @param		value				value
 * @param		inputElement		<input> Element
 * @param		id					this Element id
 */
class InputFieldEvent extends StandardEvent {
	public var value:String;
	public var inputElement:Elem;
	public var id:String;
	public function new (target:InputField, value:String, inputElement:Elem, id:String) { 
		super(target);
		this.value = value;
		this.inputElement = inputElement; 
		this.id = id;
	}	
}
//
class InputField extends UICompo    {
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var LABEL_DEFAULT :String = "Untitled" ;
	static public inline var PLACE_HOLDER_DEFAULT :String = "Enter data" ;
	
	
	/**
	 * event dispatcher when a InputField's char append 
	 * @see InputFieldEvent
	 */	
	public var input	(default, null):EventSource ;
	/**
	 * used by subclasses
	 */
	public var blur		(default, null):EventSource ;
	//"
	public var labelElement(default,null):Elem;	
	public var inputElement(default,null):Elem;		
	
	//getter
	
	/**
	 * Input elem place holder
	 * read-only.
	 * use setup() to write this var ; @see InputFieldProp .
	 */
	public var placeHolder(get, null):String;	
	/**
	 * Input elem type
	 * read-only.
	 * use setup() to write this var ; @see InputFieldProp .
	 */
	public var type(get, null):InputType;	
	/**
	 * if false => input is enabled.
	 */
	public var disabled(get, null):Bool;	
	
	
	/**
	* constructor
	* @param ?p InputFieldProp
	*/
	public function new (?p:InputFieldProp,?isSubClassCall:Bool=false) {
		super(); 
		input 	= new EventSource();		
		blur 	= new EventSource();
		if (!isSubClassCall) {
			compoSkinList = InputFieldLoader.__compoSkinList;
			setup(p);		
		}
	}
	/**
	 * setup  InputFieldProp
	 * @param ?p InputFieldProp
	 * @return this
	 */
	override public function setup (?p:InputFieldProp) :InputField {	
		super.setup(p);
		return this;
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :InputField {			
		inputElement = ("#" + id + " input").get();		
		labelElement = ("#" + id + " ." + InputField.LABEL_CLASS).get();			
		if (disabled) {
			inputElement.enable(false,true);	
		}
		inputElement.on(StandardEvent.INPUT, onAppendChar);
		enabled = true;	
		return this;
	}
	override public function remove ()  :InputField {	
		super.remove();
		inputElement.off(StandardEvent.INPUT, onAppendChar);
		if (input.hasListener()) input.off();
		if (blur.hasListener()) blur.off();		
		element.delete();
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : InputField {		
		super.update();
		labelElement.text(label);
		inputElement.value(value);
		inputElement.inputType(type);
		inputElement.placeHolder(placeHolder);		
		inputElement.css("width",width);		
		if (labelAlign == "left" && !g.isMobile) {
			element.forEachChildren(inline function (child:Elem)  { child.style.display = "inline-block";	} );
			labelElement.css("textAlign", "right");
			labelElement.css("width", labelWidth);	
			inputElement.width(element.width() - labelElement.width() - 10);
			element.width(labelElement.width()+inputElement.width()+10);
		}
		return this;
	}	
	/**
	 * getInGridValue () is a function -instead of get_ var- to access at result value when InputField is into a Grid and has the super class UICompo's type.
	 * @return
	 */
	/*override public function getInGridValue () :String {			
		return value ;
	}*/
	/**
	 * private  
	 */	
	function onAppendChar (e:ElemEvent) { 
		var v = inputElement.value(); value = v;	
		if (input.hasListener()) input.dispatch(new InputFieldEvent(this, v, inputElement, id));			
	}	
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
	function get_type () :InputType {
		var v:InputType=null;
		if (compoProp.type != null) v = compoProp.type ;
		else {
			v = InputType.TEXT;			
		}
		compoProp.type = v;		
		return v;
	}
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = InputField.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	function get_placeHolder () :String {
		var v:String=null;
		if (compoProp.placeHolder != null) v = compoProp.placeHolder ;
		else {
			v = InputField.PLACE_HOLDER_DEFAULT;			
		}
		compoProp.placeHolder = v;		
		return v;
	}
	function get_disabled () :Bool {
		var v:Bool=null;
		if (compoProp.disabled != null) v = compoProp.disabled ;
		else {
			v = false;			
		}
		compoProp.disabled = v;		
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
	 * use it for each used skin ; InputFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		InputFieldLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit InputField
 */
class InputFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "InputField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr = pathStr == null ? UICompoLoader.DEFAULT_SKIN_PATH + InputFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( InputFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
	}
	/**
	 * private static
	 */
	static function __load (fromPath:String, sk:String)  {
		var h:Http = new Http(fromPath + UICompoLoader.SKIN_FILE);
		h.onData = __onData;	
		h.request(false);
		UICompoLoader.__currentSkinName = sk;
		UICompoLoader.__currentFromPath = fromPath;	
	}	
	static function __onData (result:String)  {
		var skinContent=UICompoLoader.__storeData(result);		
		//
		InputFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
