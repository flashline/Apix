package apix.ui.tools;
//
import apix.common.display.Common;
import apix.common.util.Global;
import apix.common.util.Object;
import apix.ui.UICompo;
//using
using apix.common.util.StringExtender;
//
#if (js)
	using apix.common.display.ElementExtender;
#end
//
typedef PopBoxProp = {
	? backgroundColor : String,
	? parent : Elem,
	? elementToHide : Elem
}
/**
 * sample : 
 *   	var el:Elem = Common.createElem();
 *		el.width(200);
 *		el.height(200);
 *		el.css("backgroundColor","#f00");
 *		var pb = new PopBox().create( { backgroundColor:"" } );
 *		pb.addChild(el);
 *		pb.open();
 */
class PopBox {	
	var g:Global;
	public var element:Elem;
	public var parent:Elem;
	public var elementToHide:Elem;
	public var child:Elem;
	public var id(get,null):String;
	/**
	* constructor
	* @param ?p BoxProp
	*/
	var saveYpos:Float;
	public function new () {
		g=Global.get(); 
	}	
	public function create (?p:PopBoxProp) : PopBox {
		if (element != null) trace("f::Popup already created ! Remove it before...");
		if (p == null) p = { backgroundColor:"", parent:null,elementToHide:null } ;
		if (g.strVal(p.backgroundColor, "") == "") p.backgroundColor = "rgba(0,0,0,.8)" ;
		if (p.parent == null) p.parent = Common.body ;
		parent = p.parent;
		elementToHide = p.elementToHide ;
		//
		element = Common.createElem();
		element.css("position", "fixed");
		element.css("top", "0px");
		element.css("left", "0px");	
		element.css("width", "" + Common.screenWidth + "px");
		 if (g.isMobile) {
			if (UICompo.orientation==OrientationMode.LANDSCAPE )   { 
				var w=Math.max(Common.windowWidth,Common.documentHeight);  
				element.css("width", "" +w + "px");
			}
			element.css("height", ""+Common.documentHeight+"px");
		} else {			
			element.css("height", "" + Common.screenHeight + "px"); 
			
		}
		element.css("display", "none");
		element.css("backgroundColor", p.backgroundColor);
		element.css("zIndex", Std.string(g.getNextZindex()));
		//
		parent.addChild(element);
		element.id = Common.newSingleId;
		return this;
	}	
	public function remove () : Dynamic  {
		if (element == null) trace("f::Popup is not created ! Create it before...");
		parent.removeChild(element);
		element = null;
		return null;
	}
	public function open ( )  : PopBox { 
		element.css("zIndex", Std.string(g.getNextZindex()));		
		Common.window.on("resize", onResize);	
		parent.css("overflow", "hidden");
		if (g.isMobile) {						
			if (g.isFirefox) saveYpos = Common.documentElement.scrollTop;
			else saveYpos = Common.body.scrollTop;
			if (!g.isTablet || g.isFirefox) parent.css("position", "fixed");
			if (elementToHide!=null) elementToHide.visible(false);
		}
		element.css("display", "block");
		element.css("position", "fixed");		
		resize();
		return this;
	}
	public function close () : PopBox  { 
		Common.window.off("resize", onResize);
		parent.css("overflow", "auto");
		element.css("display", "none");
		if (g.isMobile) {	
			if (elementToHide != null) elementToHide.visible(true);
			if (!g.isTablet || g.isFirefox) {	
				parent.css("position", "relative");
				Common.window.scrollTo(0, Math.round( saveYpos));	
			}
		}
		return this;
	}
	public function addChild (el:Elem) : Elem{ 
		if (child!=null) trace("f::A child already exists in popup !!");
		child = el;
		element.addChild(child);
		child.css("position", "relative");		/*ici*/
		resize();
		return child ;
	}
	public function removeChild () : Dynamic { 
		if (child==null) trace("f::No child exists in popup !!");		
		element.removeChild(child);
		child = null;
		return null;
	}
	
	
	//getter
	function get_id () :String {
		return element.id;
	}
	
	/**
	 * private  
	 */	
	
	function onResize (e:ElemEvent) {
		resize();
	}
	inline function resize () {	
		
		child.posx((Common.windowWidth - child.width()) * .5 );			
		if (g.isMobile) {
			child.posy((Common.windowHeight - child.height()) * .5  );// - parent.positionInWindow().y); //  
		} else {		
			child.posy((Common.windowHeight - child.height()) * .5 );
		}
		/**/
	}
}