package apix.ui.container;
//
import apix.common.display.Common;
import apix.common.util.Object;
import apix.ui.input.InputField;
import apix.ui.input.RadioField;
import apix.ui.input.SelectField;
import apix.ui.tools.Button;
import apix.ui.UICompo;
import haxe.Http; 


//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#end 
typedef ContainerProp = { 
	> CompoProp,
	?scroll:Bool,
	?legend:String,
	?background:String,
	?size:String,
	?color:String,
} 
//
/**
 * In properties
 * @param  into			#+container id
 * @param  skin			skinName
 * @param  id 			Compo Elem id
 * @param  name			uiCompo name
 * @param  auto			true if auto enable
 * @param  width
 * @param  height
 * @param  scroll		if true => overflow = scroll ; else hidden
 * @param  legend		legend label
 */
/**
 * No value
 */
/**
 * No Event
 */
//

class Container extends UICompo  {
	//getter
	public var scroll(get, never):Bool;	
	public var legend(get, never):String;
	public var size(get, null):String;	
	public var color(get, null):String;	
	public var background(get, null):String;	
	//public var
	public var childrenCompo(default,null) :Array<UICompo>;
	public var legendElement(default, null):Elem;
	/**
	* constructor
	* @param ?p ContainerProp
	*/
	public function new (?p:ContainerProp) {	
		childrenCompo = [];
		super();		
	}	
	/*
	 * because typed bug with subclasses :  (?p:ContainerProp) has been replaced by (?p:Dynamic)
	 */
	override public function setup (?p:Dynamic) :Container {
		super.setup(p);
		for (c in childrenCompo) {
			c.setup();
		}
		return this;
	}	
	override public function enable ()  : Container {	
		legendElement = ("#" + id + " legend").get() ;
		if (g.strVal(legend,"") != "") {
			if (legendElement == null || (!element.hasChild(legendElement)) ) {
				legendElement = Common.createElem(TagType.LEGEND) ;
				element.addChild(legendElement);				
			}
			legendElement.text(legend);
		} 
		else {
			if (legendElement != null && element.hasChild(legendElement)) {				
				element.removeChild(legendElement);
				legendElement = null;
			}			
		}
		enabled = true;
		return this;
	}
	override public function remove () :Container {
		super.remove();
		for (c in childrenCompo) {
			c.remove();
		}
		return this;
	}
	
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update ()  :Container {
		super.update();
		element.css("width",width);
		element.css("height", height);
		element.style.overflow = (scroll)?"auto":"hidden";		
		element.css("color",color);
		element.css("backgroundColor",background);
		element.css("font-size", background);		
		return this;	
	}
	/**
	 * add elements inside
	 * 
	 * @return this
	 */
		
	public function addChild (el:Elem)  :Container {
		element.addChild(el);
		update ();
		return this;
	}
	public function removeChild (el:Elem)  :Container {
		element.removeChild(el);
		return this;
	}
	public function addCompo (c:UICompo)  :Container {
		if (c.isCreated()) {
			childrenCompo.push(c);
			element.addChild(c.element);
			c.setup( { into:"#" + id } );
			update();
		}
		return this;
	}
	public function removeCompo (c:UICompo)  :Container {
		if (c.isCreated()) {
			c.remove();
			childrenCompo.remove(c);
			if (element.hasChild(c.element)) element.removeChild(c.element);
			c.setup( { into:null } );
		}
		return this;
	}
	public function getCompoAt (?n:Int = 0)  :UICompo {	
		if (n>childrenCompo.length-1) trace("f::out of range !");
		return childrenCompo[n];
	}
	public function getLastCompo()  : UICompo {	
		return getCompoAt (childrenCompo.length - 1) ;
	}
	public function getCompo (idc:String)  : UICompo {	
		var co:UICompo = null;
		for (c in childrenCompo) {
			if (c.id == idc) {
				var co = c;
				break;
			}
		}
		return co;
	}
	public inline function getBoxAt (?n:Int = 0)  :Box {	
		return  cast(getCompoAt (n),Box) ;
	}	
	public inline function getLastBox()  : Box {	
		return cast(getLastCompo(),Box) ;
	}
	public inline function getBox(idc:String)  : Box {	
		return cast(getCompo (idc),Box) ;
	}	
	//
	public inline function getHBoxAt (?n:Int = 0)  :HBox {	
		return  cast(getCompoAt (n),HBox) ;
	}	
	public inline function getLastHBox()  : HBox {	
		return cast(getLastCompo(),HBox) ;
	}
	public inline function getHBox(idc:String)  : HBox {	
		return cast(getCompo (idc),HBox) ;
	}	
	//
	public inline function getTabBoxAt (?n:Int = 0)  :TabBox {	
		return  cast(getCompoAt(n),TabBox) ;
	}	
	public inline function getLastTabBox()  : TabBox {
		return cast(getLastCompo(),TabBox) ;
	}
	public inline function getTabBox(idc:String)  : TabBox {	
		return cast(getCompo (idc),TabBox) ;
	}
	//
	public inline function getButtonAt (?n:Int = 0)  :Button {	
		return  cast(getCompoAt(n),Button) ;
	}	
	public inline function getLastButton()  : Button {
		return cast(getLastCompo(),Button) ;
	}
	public inline function getButton(idc:String)  : Button {	
		return cast(getCompo (idc),Button) ;
	}
	//
	public inline function getInputFieldAt (?n:Int = 0)  :InputField {	
		return  cast(getCompoAt(n),InputField) ;
	}	
	public inline function getLastInputField()  : InputField {
		return cast(getLastCompo(),InputField) ;
	}
	public inline function getInputField(idc:String)  : InputField {	
		return cast(getCompo (idc),InputField) ;
	}
	//
	public inline function getSelectFieldAt (?n:Int = 0)  :SelectField {	
		return  cast(getCompoAt(n),SelectField) ;
	}	
	public inline function getLastSelectField()  : SelectField {
		return cast(getLastCompo(),SelectField) ;
	}
	public inline function getSelectField(idc:String)  : SelectField {	
		return cast(getCompo (idc),SelectField) ;
	}
	//
	public inline function getRadioFieldAt (?n:Int = 0)  :RadioField {	
		return  cast(getCompoAt(n),RadioField) ;
	}	
	public inline function getLastRadioField()  : RadioField {
		return cast(getLastCompo(),RadioField) ;
	}
	public inline function getRadioField(idc:String)  : RadioField {	
		return cast(getCompo (idc),RadioField) ;
	}
	
	
	
	/**
	 * private  
	 */	
	//get_
	function get_scroll () :Bool {
		var v:Bool=null;
		if (compoProp.scroll != null) v = compoProp.scroll ;
		else {
			v = false;			
		}
		compoProp.scroll = v;		
		return v;
	}
	function get_legend () :String {
		var v:String=null;
		if (compoProp.legend != null) v = compoProp.legend ;
		else {			
			v = "";
		}
		compoProp.legend = v;		
		return v;
	}
	function get_size () :String {
		var v:String=null;
		if (compoProp.size != null) v = compoProp.size ;
		else {
			v = "1rem";			
		}
		compoProp.size = v;		
		return v;
	}
	function get_color () :String {
		var v:String=null;
		if (compoProp.color != null) v = compoProp.color ;
		else {
			v = "#000";			
		}
		compoProp.color = v;		
		return v;
	}
	function get_background () :String {
		var v:String=null;
		if (compoProp.background != null) v = compoProp.background ;
		else {
			if (style.backgroundColor != null) v = style.backgroundColor;
			else if (element != null && g.strVal(element.css("backgroundColor"), "") != "") v = element.css("backgroundColor"); 
			else v = "transparent";			
		}
		compoProp.background = v;		
		return v;
	}
}