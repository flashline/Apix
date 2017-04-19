package apix.uix;
//
import apix.common.display.Common;
import apix.common.util.Global;
import apix.common.util.Object;

//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#end
typedef UIXProp = { 
	?into:String,
} 

class UIX  {	
	var compoProp:Object;
	var g:Global;
	public var into(get, never):String;
	/**
	* constructor
	*/
	public function new (?p:UIXProp) {
		g = Global.get(); compoProp = new Object();
		setCompoProp(p);
	}	
	//
	//
	function setCompoProp (?p:UIXProp) {	
		var o:Object = new Object(p); 
		if (!o.empty()) {
			o.forEach(	function (k, v, i) {
							compoProp.set(k, v);
						}
			);	
		}			
	}	
	function get_into () :String {
		return  g.strVal(compoProp.into,"");
	}
}
