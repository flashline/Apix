package apix.ui.input;
//
import apix.common.display.ElementExtender.Radio;
import apix.common.event.StandardEvent;
import apix.common.event.EventSource;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo.UICompoLoader;
import js.Browser;
import js.html.Event;
//
import apix.ui.UICompo.CompoProp;
import apix.ui.UICompo;
import haxe.Http; 
//using
using apix.common.util.StringExtender;
//
#if (js)
	using apix.common.display.ElementExtender;
#else if (flash)
	using apix.common.display.SpriteExtender;
#end
//
/**
 * Main input properties 
 * @see UICompo for others
 * 
 * @param  radios 	Array of ElementExtender.Radio	: { value:<input value>, text:"" , selected:<true or false> }
 */
/**
 * Main output properties
 * @param selectedElement 	
 * @param index 			index of selected element 
 * @param value 			value of selected element 
 * @param text 				text of selected element 
 */
//
typedef RadioFieldProp = { 
	> CompoProp ,
	/**
	 * input type.
	 */
	radios:Array<Radio>
} 
//
/**
 * Out Event
 * @source  change 
 * @param           target:this
 * @param           value:String;
 * @param           text:String;
 * @param           index:Int;
 * @param           name:String;
 * @param           selectedElement:Elem;
 * @param           id:Int;
 */
class RadioFieldEvent extends StandardEvent {
	public var value:String;
	public var text:String;
	public var index:Int;
	public var name:String;
	public var selectedElement:Elem;
	public var id:String;
	public function new (target:RadioField, 
							value:String, 
							text:String,
							index:Int,
							name:String,
							selectedElement:Elem,							
							id:String
						) { 
							super(target);
							this.value = value;
							this.text=text;
							this.index=index;
							this.name=name;
							this.selectedElement=selectedElement;
							this.id = id;
						}	
}
//
class RadioField extends UICompo    {
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var RADIO_CTNR_CLASS :String = UICompo.APIX_PRFX+"radioCtnr" ;
	static public inline var RADIO_CLASS :String = UICompo.APIX_PRFX+"radio" ;
	static public inline var LABEL_DEFAULT :String = "Untitled" ;
	static public inline var NO_RADIO_SELECTED :Int = -1 ;
	/**
	 * event dispatcher when a RadioField's content is changing.
	 * dispatch 
	 * StandardEvent.target 		: this 
	 * StandardEvent.RadioElements  
	 * StandardEvent.value 		
	 */	
	public var change	(default, null):EventSource ;
	//
	public var labelElement(default,null):Elem;	
	public var radioElement(default, null):Elem;
	var _checkedIndex:Int;
	//getter	
	/**
	 * value of selected radio -in connection with index
	 * read-only.
	 */
	//public var value(get, null):String;	
	/**
	 * inner text of selected radio -in connection with index
	 * read-only.
	 */
	public var text(get, null):String;	
	/**
	 * index of selected radio
	 * read-only.
	 */
	public var index(get, null):Int;	
	/**
	 * selected radio Elem -in connection with index
	 * read-only.
	 */
	public var selectedElement(get, null):Elem;	
	/**
	 * Array of Radio {label,data,selected}
	 * read-only.
	 * use setup() to write this var ; @see RadioFieldProp .
	 */
	public var radios(get, null):Array<Radio>;

	
	/**
	* constructor
	* @param ?p RadioFieldProp
	*/
	public function new (?p:RadioFieldProp) {
		super(); 
		change 	= new EventSource();		
		compoSkinList = RadioFieldLoader.__compoSkinList;
		setup(p);		
	}
	/**
	 * setup  RadioFieldProp
	 * @param ?p RadioFieldProp
	 * @return this
	 */
	override public function setup (?p:RadioFieldProp) :RadioField {	
		super.setup(p);
		return this;
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :RadioField {			
		radioElement = ("#" + id + " ."+RadioField.RADIO_CTNR_CLASS).get();		
		labelElement = ("#" + id + " ." + RadioField.LABEL_CLASS).get();		
		enabled = true;	
		return this;
	}
	override function remove() : RadioField {	
		super.remove();
		for (o in radios) {			
			if (o.element!=null) o.element.off(StandardEvent.CHANGE, onRadioChange);
		}
		element.delete();
		return this;
	}	
	
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : RadioField {	
		super.update();
		labelElement.text(label);		
		radioElement.removeChildren();
		var i = -1;
		for (o in radios) {
			var el:Elem = Browser.document.createElement("input");
			var rl:Elem = Browser.document.createElement("label");
			var r:Elem  = Browser.document.createElement("span");
			r.attr("class", RadioField.RADIO_CLASS);			
			o.element = el;
			o.labelElement = rl;
			//
			el.type("radio");
			el.value(o.value);
			el.name(name) ;	
			i++;
			el.id = id + "-" + i;
			el.selected(o.selected);					
			rl.text(o.text);
			rl.attr("for", el.id );
			r.addChild(el); // <input radio
			r.addChild(rl);	// <label	
			radioElement.addChild(r); // "apix_radio" element with input + label inside.
			el.on(StandardEvent.CHANGE, onRadioChange);
		}
		return this;
	}	
	/**
	 * private  
	 */	
	//
	function onRadioChange (e:Event) {
		var el:Elem = untyped e.currentTarget;
		_checkedIndex = null;
		if (change.hasListener() ) {
			change.dispatch(new RadioFieldEvent(
									this,
									value,
									text,
									index,
									name,
									selectedElement,
									id
							)
			);
		}
	}	
	override function get_value () :String {	
		var v = "";		
		if (index != RadioField.NO_RADIO_SELECTED) v = radios[index].element.value(); 
		return v ;
	}
	override function set_value (v:String) :String {	
		var i = RadioField.NO_RADIO_SELECTED ; _checkedIndex = null;
		for (o in radios) {
			i++;
			var el:Elem = o.element;
			if (o.value == v) {
				el.selected(true);
				 _checkedIndex = i;
			}
			else {
				el.selected(false);
			}
		}
		if ( _checkedIndex == null) trace("f::Value '"+v+"' doesn't exist in RadioField id : " + id);		
		return v ;
	}	
	function get_text () :String {
		var v = "";
		if (index != RadioField.NO_RADIO_SELECTED) v = radios[index].labelElement.text() ;
		return v ;
	}
	function get_index () :Int {
		if (_checkedIndex==null) {
			var i = RadioField.NO_RADIO_SELECTED ; _checkedIndex = i;
			for (o in radios) {
				i++;
				var el:Elem = o.element;
				if (el.selected()) {
					_checkedIndex = i;
					break ;
				}
			}
		}
        return _checkedIndex ;
	}
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = RadioField.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	
	function get_radios () :Array<Radio> {
		var v:Array<Radio>=null;
		if (compoProp.radios != null) v = compoProp.radios ;
		else {
			v = [];			
		}
		compoProp.radios = v;		
		return v;
	}
	function get_selectedElement () :Elem {		
		var v:Elem = null;
		if (index != RadioField.NO_RADIO_SELECTED) v = radios[index].element ;
		else trace("f:: No button is selected !" );
		return v ;
	}
	//
	//
	//
	/**
	 * static public  
	 */
	/**
	 * load a skin.
	 * use it for each used skin ; RadioFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		RadioFieldLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit RadioField
 */
class RadioFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "RadioField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + RadioFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( RadioFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		RadioFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
