
package apix.common.display;
//
import apix.common.util.Global ;
//
using apix.common.util.StringExtender;
using apix.common.display.ElementExtender;
/**
 * Replace Global.get().alert() that has the same behaviour than basic browsers alert.
 * Alert.display() is called when Global.get().alert() is called.
 */
class Alert  {
	var validElem (default,null) :Elem;
	var ctnrElem:Elem;
	var defTitleLabel:String;
	var defValidLabel:String;
	var titleElem:Elem;
	var textElem:Elem;
	var callBack :Void->Void;
	public var alertFunction(default,null) :Dynamic;
	/**
	 * constructor
	 * @param	el		Alert-box container 
	 * @param	txElem	Message container
	 * @param	bElem	valid button
	 * @param	tEl		title Element
	 * @param	tTx		title text
	 * @param	vTx		valid button text
	 */
	
	public function new (el:Elem,txElem:Elem,bElem:Elem,tEl:Elem,?tTx:String="Alert !",?vTx:String="Enter") {
		ctnrElem = el;
		titleElem = tEl;
		textElem = txElem;
		validElem = bElem;
		//
		defTitleLabel=tTx;
		defValidLabel = vTx;
		//titleElem.inner(tTx);
		//validElem.inner(vTx);
		//
		enable();
    }	
	/**
	 * restore js standard alert-box when alert()
	 */
	public function disable () : Alert {
		validElem.off("click", onValid);
		validElem.clearEnterKeyToClick();
		alertFunction = null;
		Global.alertFunction = null;
		ctnrElem.hide();
		validElem.clearEnterKeyToClick();
		return this;
	}
	/**
	 * enable after a previous disable()
	 */
	public function enable ()  : Alert  {		
		validElem.on("click", onValid);		
		alertFunction = display; 
		Global.alertFunction = display;
		return this;
	}
    
	/**
    *@private
    */
	
    function onValid (e:ElemEvent) {
		validElem.clearEnterKeyToClick();	
		ctnrElem.hide(); 
		if (callBack != null) {
			callBack();
			//callBack = null;
		}
	}
    function display (?v:String = "", ?cb:Dynamic, ?titleLabel:String,?validLabel:String) {		
		if (Std.is(v, Array)) {
			var arr:Array<String> = untyped v ;
			v = "";
			for (i in 0...arr.length) {
				v += arr[i];
			}
		}
		if (Global.get().strVal(v,"")=="") v = "Alert.display() : Programming error in assign message ! May be dont use 'lang' object";
		if (titleLabel != null) titleElem.inner(titleLabel); else titleElem.inner(defTitleLabel) ;
		if (validLabel!=null) validElem.inner(validLabel); else validElem.inner(defValidLabel) ;
		callBack = cb;
		ctnrElem.show();
		ctnrElem.visible(true);
		textElem.inner(v);
		validElem.joinEnterKeyToClick();
	}
	
}
