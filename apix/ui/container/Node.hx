package apix.ui.container;
//
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo;
import apix.common.event.StandardEvent;

//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#else if (flash)
	using apix.common.display.SpriteExtender;
#end
//
typedef NodeProp = { 
	> CompoProp,	
} 
//
/**
 * In properties
 * @param  into			#+container id
 * @param  skin			skinName
 * @param  id 			Compo Elem id
 * @param  name			uiCompo name
 * @param  auto			true if auto enable
 * @param  height
 * @param  width
 * @param  label	
 * 
 */

//
class Node extends UICompo  {
	static public inline var BUTTON_CLASS :String = UICompo.APIX_PRFX + "button" ;
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;	
	static public inline var HEAD_CLASS :String = UICompo.APIX_PRFX+"head" ;	
	static public inline var BODY_CLASS :String = UICompo.APIX_PRFX+"body" ;	
	static public inline var LABEL_DEFAULT :String = "Untitled ! Node needs label !" ;
	//
	/**
	 * 
	 */
	public 	var headElement(default, null):Elem ;	
	public 	var bodyElement(default, null):Elem ;	
	public 	var index:Int;
	//getter
	//
	//
	/**
	* Node is super class for tree's, tab's or accordeon's nodes
	* and hasn't constructor
	*/
	
	override public function enable ()  :Node {			
		("#" + id + " ." + Node.BUTTON_CLASS).on(StandardEvent.CLICK, onOpenClose);		
		return this;
	}
	public function disable ()  :Node {
		("#" + id + " ." + Node.BUTTON_CLASS).off(StandardEvent.CLICK, onOpenClose,false);			
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update ()  :Node {
		element.style.width		= width;
		element.style.height	= height;	
		("#" + id + " ." + Node.LABEL_CLASS).get().text(label);
		//		
		return this;
	}	
	/**
	 * add elements inside
	 * 
	 * @return this	
	 */
	
	public function addChild (el:Elem)  :Elem {
		bodyElement.addChild(el);
		return el;
	}
	public function removeChild (el:Elem)  :Elem {
		bodyElement.removeChild(el);
		return el;
	}
	
	public function show ()  {
		bodyElement.show();		
	}	
	public function hide ()  {
		bodyElement.hide();
	}
	
	/**
	 * private  
	 */	
	/**
	 * toogle open/close of body element
	 * @param	e
	 */
	function onOpenClose (e:ElemEvent) {
		if (bodyIsOpen()) 	hide();
		else 				show();		
    }
	
	function bodyIsOpen () {
		return (bodyElement.isDisplay()) ;
    }
	function bodyIsEmpty () {
		return (bodyElement.inner() == "");
    }	
	//gets
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {			
			v = Node.LABEL_DEFAULT;
		}
		compoProp.label = v;		
		return v;
	}	
	//
	//
	
}
//
