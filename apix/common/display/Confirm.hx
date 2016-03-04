
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
class Confirm extends Alert  {
	var cancelElem (default,null) :Elem;
	var confirmCallBack :Bool->Confirm->Void;
	var defCancelLabel:String;
	
	public static var _instance:Confirm;
	/**
	 * constructor
	 * @param	el		Alert-box container 
	 * @param	txElem	Message container
	 * @param	bElem	valid button
	 * @param	tEl		title Element
	 * @param	tTx		title text
	 * @param	vTx		valid button text
	 */
	
	public function new (el:Elem,txElem:Elem,bvElem:Elem,bcElem:Elem,tEl:Elem,?tTx:String="Confirm ?",?vTx:String="Yes",?cTx:String="No") {
		cancelElem = bcElem;
		//cancelElem.inner(cTx);
		defCancelLabel = cTx;
		super(el, txElem, bvElem, tEl, tTx, vTx);
		_instance = this;
    }	
	public static function get () {
		if (_instance == null) trace("f:: new Confirm() not executed !");
		return _instance ;
    }	
	public function show (v:String, ?cb:Bool->Confirm->Void, ?titleLabel:String, ?validLabel:String, ?cancelLabel:String) {	
		if (Std.is(v, Array)) {
			var arr:Array<String> = untyped v ;
			v = "";
			for (i in 0...arr.length) {
				v += arr[i];
			}
		}
		
		if (titleLabel !=null) titleElem.inner(titleLabel); else titleElem.inner(defTitleLabel) ;
		if (validLabel !=null) validElem.inner(validLabel); else validElem.inner(defValidLabel) ;
		if (cancelLabel!=null) cancelElem.inner(cancelLabel); else cancelElem.inner(defCancelLabel); 
		
		confirmCallBack = cb;
		ctnrElem.show();
		ctnrElem.visible(true);
		textElem.inner(v);
		cancelElem.joinEnterKeyToClick();
		
		
	}
	public function hide () {	
		ctnrElem.hide(); 		
	}
	override public function enable ()  : Alert  {		
		validElem.on("click", onValid);		
		cancelElem.on("click", onCancel);	
		confirmCallBack = null;
		return this;
	}
    override public function disable ()  : Alert  {	
		cancelElem.off("click", onCancel);
		cancelElem.clearEnterKeyToClick();		
		return super.disable() ;
	}
	override function onValid (e:ElemEvent) {
		cancelElem.clearEnterKeyToClick();	
		if (confirmCallBack != null) {
			confirmCallBack(true,this);
			confirmCallBack = null;
		}
	}
	function onCancel (e:ElemEvent) {
		cancelElem.clearEnterKeyToClick();	
		hide(); 
		if (confirmCallBack != null) {
			confirmCallBack(false,this);
			confirmCallBack = null;
		}
	}	
	
	
}
