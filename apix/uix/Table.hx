package apix.uix;
//
import apix.common.display.Common;
import apix.common.util.Global;
import apix.common.util.Object;
import apix.ui.container.Box;
import apix.ui.container.HBox;
import apix.uix.UIX;

//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#end
typedef TableProp = { 
	> UIXProp,
} 

class Table extends UIX  {	
	public var element(get,null):Elem;
	public var compo(get,null):Box;
	var box:Box;
	/**
	* constructor
	*/
	public function new (?p:TableProp) {
		super(p);			
		box = new Box({ into: compoProp.into });
	}	
	public function addRow (?p:TableProp) : HBox {
		if (!box.isCreated ()) 	trace("f::The Table must be created in DOM before add row");
		if (p!=null) setCompoProp(p);
		var hb = new HBox();
		box.addCompo(hb);
		return hb;
	}
	public function removeRow (hb:HBox) : Table {		
		box.removeCompo(hb);	
		return this;
	}
	public function removeRowAt (?n:Int=0) : Table {		
		box.removeCompo(getRowAt(n));	
		return this;
	}
	public function getRowAt (?n:Int=0):HBox {		
		return cast(box.getCompoAt(n));
	}
	//
	//
	function get_element () : Elem {
		return box.element ;
	}
	function get_compo () : Box {
		return box ;
	}
}
