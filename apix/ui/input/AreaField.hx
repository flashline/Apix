package apix.ui.input;
//
import apix.common.event.EventSource;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo.UICompoLoader;
import apix.common.display.ElementExtender.InputType;
import apix.common.event.StandardEvent;
import apix.ui.input.InputField;
//
import apix.ui.UICompo;
import haxe.Http; 

//using
using apix.common.util.StringExtender;
using apix.common.display.ElementExtender;
//
/**
 * Main input properties 
 * @see UICompo for others
 * @param  value		input value
 * @param  placeHolder
 * @param  charLen		char max number to be entered
 */
/**
 * Main output properties 
 * @param value 		output value 
 * @param inputElement	Elem textarea with value
 */
//
typedef AreaFieldProp = { 
	> InputFieldProp ,	
} 
/**
 * Event
 * @source  input 
 * @param		target				this
 * @param		value				value
 * @param		inputElement		<input> Element
 * @param		id					this Element id
 */
class AreaFieldEvent extends InputFieldEvent { 
	public function new (target:AreaField, value:String, inputElement:Elem, id:String) { 
		super (target, value, inputElement, id);
	}	
}
//

class AreaField extends InputField    {
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var LABEL_DEFAULT :String = "Untitled" ;
	static public inline var PLACE_HOLDER_DEFAULT :String = "Enter data" ;
	
	
	//getter
	
	
	/**
	* constructor
	* @param ?p AreaFieldProp
	*/
	public function new (?p:AreaFieldProp,?from:String) {
		super(p,("isSubClassCall"=="isSubClassCall")); 
		compoSkinList = AreaFieldLoader.__compoSkinList;
		setup(p);		
	}
	/**
	 * setup  AreaFieldProp
	 * @param ?p AreaFieldProp
	 * @return this
	 */
	override public function setup (?p:AreaFieldProp) :AreaField {	
		super.setup(p);
		return this;
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :AreaField {		
		inputElement = ("#" + id + " textarea").get();		
		labelElement = ("#" + id + " ." + InputField.LABEL_CLASS).get();			
		if (disabled) {
			inputElement.prop("readOnly", true);	
		}
		inputElement.on(StandardEvent.INPUT, onAppendChar);
		inputElement.on(StandardEvent.BLUR, onLeaveInputElement);
		
		enabled = true;
		return this;
	}
	override public function remove ()  :AreaField {	
		inputElement.off(StandardEvent.INPUT, onAppendChar);
		inputElement.off(StandardEvent.BLUR,onLeaveInputElement);		
		super.remove();
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : AreaField {		
		super.update();
		return this;
	}	
	/**
	 * private  
	 */	
	override function onAppendChar (e:ElemEvent) { 
		var v = inputElement.value(); value = v;	
		if (input.hasListener()) input.dispatch(new InputFieldEvent(this, v, inputElement, id));			
	}
	function onLeaveInputElement (e:ElemEvent) { 
		if (blur.hasListener()) blur.dispatch(new AreaFieldEvent(this,value,inputElement,id) ) ;		
	}
	
	//
	//
	//
	/**
	 * static public  
	 */
	/**
	 * load a skin.
	 * use it for each used skin ; AreaFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		AreaFieldLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit AreaField
 */
class AreaFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "AreaField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + AreaFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( AreaFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		AreaFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
