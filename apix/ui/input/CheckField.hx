package apix.ui.input;
//
import apix.common.display.ElementExtender.CheckValue;
import apix.common.display.ElementExtender.Check;
import apix.common.event.StandardEvent;
import apix.common.event.EventSource;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo.UICompoLoader;
import apix.common.display.Common;
import js.html.Event;
//
import apix.ui.UICompo.CompoProp;
import apix.ui.UICompo;
import haxe.Http; 

#if (js)
	using apix.common.display.ElementExtender;
#else if (flash)
	using apix.common.display.SpriteExtender;
#end
//
/**
 * Main input properties 
 * @see UICompo for others
 * @param  checks			Array of ElementExtender.Check	: { value:<input value>, text:"" , selected:<true or false> }
 */
/**
 * Main output properties 
 * @param selectedValues 	-checked only values Array : Array<CheckValue>
 * @param checkElement		Elem container of <input> with type="check"
 */
//using
using apix.common.util.StringExtender;
//
typedef CheckFieldProp = { 
	> CompoProp ,
	checks:Array<Check>
} 
//
class CheckFieldEvent extends StandardEvent {
	public var values:Array<CheckValue>;
	public var checkElement:Elem;
	public var selectedValues:Array<CheckValue>;
	public var label:String;
	public var id:String;
	public function new (target:CheckField, values:Array<CheckValue>,selectedValues:Array<CheckValue>,checkElement:Elem, label:String, id:String) { 
		super(target);
		this.values = values;
		this.selectedValues = selectedValues;
		this.checkElement = checkElement ;
		this.label = label; 
		this.id = id;
	}	
}

//
/**
 * Event
 * @source  click 
 * @param		target				this
 * @param		values				Array<CheckValue>
 * @param		selectedValues		Array<CheckValue>
 * @param		id					this Element id
 */
class CheckField extends UICompo    {
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var CHECK_CTNR_CLASS :String = UICompo.APIX_PRFX+"checkCtnr" ;
	static public inline var CHECK_CLASS :String = UICompo.APIX_PRFX+"check" ;
	static public inline var LABEL_DEFAULT :String = "Untitled" ;
	static public inline var NO_RADIO_SELECTED :Int = -1 ;
	/**
	 * event dispatcher when a CheckField's content is changing.
	 * dispatch 
	 * StandardEvent.target 		: this 
	 * StandardEvent.CheckElements  
	 * StandardEvent.value 		
	 */	
	public var click	(default, null):EventSource ;
	//
	public var labelElement(default,null):Elem;	
	public var checkElement(default, null):Elem;
	var _checkValues:Array<CheckValue> ;
	//getter	
	/**
	 * values Array of check-boxes 
	 * read-only.
	 */
	public var values(get, null):Array<CheckValue>;	
	/**
	 * Array of selected options
	 * read-only.
	 */
	public var selectedChecks(get, null):Array<CheckValue>;	
	/**
	 * Array of Check {initial text,value,selected,element,labelElement,index}
	 * read-only.
	 * use setup() to write this var ; @see CheckFieldProp .
	 */
	public var checks(get, null):Array<Check>;
	
	/**
	* constructor
	* @param ?p CheckFieldProp
	*/
	public function new (?p:CheckFieldProp) {
		super(); 
		click 	= new EventSource();		
		compoSkinList = CheckFieldLoader.__compoSkinList;
		setup(p);		
	}
	/**
	 * setup  CheckFieldProp
	 * @param ?p CheckFieldProp
	 * @return this
	 */
	override public function setup (?p:CheckFieldProp) :CheckField {	
		super.setup(p);
		return this;
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :CheckField {	
		checkElement = ("#" + id + " ."+CheckField.CHECK_CTNR_CLASS).get();		
		labelElement = ("#" + id + " ." + CheckField.LABEL_CLASS).get();		
		enabled = true;	
		return this;
	}
	override function remove() : CheckField {	
		for (o in checks) {			
			if (o.element!=null) o.element.off(StandardEvent.CLICK,onCheckChange);
		}
		element.delete();
		return this;
	}	
	
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : CheckField {	
		super.update();
		labelElement.text(label);	
		checkElement.removeChildren();
		var i = -1;
		for (o in checks) {
			i++;
			var el:Elem = Common.document.createElement("input");
			var rl:Elem = Common.document.createElement("label");
			var r:Elem  = Common.document.createElement("span");
			r.attr("class", CheckField.CHECK_CLASS);
			o.element = el;
			o.labelElement = rl;
			o.index = i;			
			//
			el.type("checkbox");
			el.value(o.value);	
			el.selected(o.selected);
			el.id = id + "-" + i;
			rl.text(o.text);	
			rl.attr("for", el.id );
			r.addChild(el);
			r.addChild(rl);			
			checkElement.addChild(r);	
			el.on(StandardEvent.CLICK, onCheckChange,{checkObject:o});
		}
		return this;
	}	
	/**
	 * private  
	 */	
	//
	function onCheckChange (e:Event, ?data:Dynamic) {
		_checkValues = null;
		var el:Elem = untyped e.currentTarget ;
		var o:Check = data.checkObject ;
		o.selected = el.selected();
		if (click.hasListener() ) click.dispatch(new CheckFieldEvent(this,values,selectedChecks,checkElement,label,id));
	}		
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = CheckField.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	
	function get_checks () :Array<Check> {
		var v:Array<Check>=null;
		if (compoProp.checks != null) v = compoProp.checks ;
		else {
			v = [];			
		}
		compoProp.checks = v;		
		return v;
	}	
	function get_values () :Array<CheckValue> {
		if (_checkValues == null) {
			_checkValues = [];
			for (o in checks) {
				var el:Elem = o.element ;
				var rl:Elem = o.labelElement ;
				_checkValues.push( { value:el.value(), text:el.text(), index:o.index,selected:el.selected(),element:el ,labelElement:rl } );
			}
		}
		return _checkValues;
	}
	override function get_value () :Array<CheckValue> {		
		return values;
	}
	override function get_isEmpty () : Bool {
		return (selectedChecks.length==0) ;		
	}
	function get_selectedChecks () :Array < CheckValue > {
		var arr:Array<CheckValue>=[];		
		for (o in values) {
			if (o.selected) arr.push(o);
		}		
		return arr;
	}
	
	//
	//
	//
	/**
	 * static public  
	 */
	/**
	 * load a skin.
	 * use it for each used skin ; CheckFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		CheckFieldLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit CheckField
 */
class CheckFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "CheckField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + CheckFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( CheckFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		CheckFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
