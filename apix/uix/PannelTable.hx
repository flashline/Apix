package apix.uix;
//
import apix.common.display.Common;
import apix.common.util.Global;
import apix.common.util.Object;
import apix.ui.container.HBox;
import apix.ui.container.Pannel;
import apix.ui.UICompo;
import apix.uix.UIX;
//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#end
typedef PannelTableProp = { 
	> UIXProp,	
} 

class PannelTable extends UIX {	
	public var element(get,null):Elem;
	public var compo(get,null):Pannel;
	public var rowNumber(get,null):Int;
	var pannel:Pannel;
	/**
	* constructor
	*/
	public function new (p:PannelTableProp) {
		super(p);
		pannel = new Pannel( { into: compoProp.into } );
	}	
	public function addHeadCompo (c:UICompo) {			
		pannel.addHeadCompo (c);
	}
	public function removeHeadCompo (c:UICompo) {			
		pannel.removeHeadCompo (c);
	}
	public function addRow (?p:PannelTableProp) : HBox {
		if (!pannel.isCreated ()) 	trace("f::The Table must be created in DOM before add row");
		if (p!=null) setCompoProp(p);
		var hb = new HBox();
		pannel.addCompo(hb);
		return hb;
	}
	public function removeRow (hb:HBox) : PannelTable {		
		pannel.removeCompo(hb);	
		return this;
	}
	public function removeRowAt (?n:Int=0) : PannelTable {		
		pannel.removeCompo(getRowAt(n));	
		return this;
	}
	public function getRowAt (?n:Int=0):HBox {		
		return cast(pannel.getCompoAt(n));
	}
	public function getLastRow ()  : HBox {	
		if (rowNumber == 0) trace("f::PannelTable with id '"+pannel.id+"' is empty !");
		return getRowAt (rowNumber-1) ;
	}
	public function removeContent ():PannelTable {	
		 if (rowNumber != 0) {
			removeRowAt(0);
			removeContent();
		 }
		return this;
	}
	//
	//	
	function get_element () : Elem {
		return pannel.element ;
	}
	function get_compo () : Pannel {
		return pannel ;
	}
	function get_rowNumber() : Int {
		return pannel.childrenCompo.length ;
	}
}
