package apix.ui.input;
//
import apix.ui.UICompo;
import apix.ui.UICompo.CompoProp;
//
import apix.common.event.EventSource;
import apix.common.display.Common;
import apix.common.event.StandardEvent;
import js.html.BRElement;
//
import haxe.Http; 
//
import cordovax.navigator.Camera;
import cordovax.navigator.Camera.DestinationType;
//using
using apix.common.util.StringExtender;
//
using apix.common.display.ElementExtender;
using apix.common.util.ArrayExtender;
//
/**
 * Main input properties 
 * @see UICompo for others
 * 
 * @param  	value				array of pictures -Array<MediaData>
 * @param	max					max number of photo
 */
/**
 * Main output properties 
 * @param  value				array of pictures -Array<MediaData>;
 * @param  inputElementArray	array of element <img>  with src=base64 url
 */
//
typedef PhotoFieldProp = { 
	> CompoProp ,
	?value:Array<MediaData>,
	?max:Int
} 

/**
 * Event
 * @source  	click 
 * @param		target				this
 * @param		value				array of pictures -Array<MediaData>;
 * @param		id					this Element id
 */
class PhotoFieldEvent extends StandardEvent {
	public var value:Array<MediaData>;
	public var inputElementArray:Array<Elem>;
	public var id:String;
	public function new (target:PhotoField, value:Array<MediaData>,inputElementArray:Array<Elem>, id:String) { 
		super(target);
		this.inputElementArray=inputElementArray;
		this.value = value;
		this.id = id;
	}	
}
//
class PhotoField extends UICompo    {
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX + "label" ;
	static public inline var BUTTON_CLASS :String = UICompo.APIX_PRFX + "button" ;
	static public inline var PHOTO_CTNR_CLASS :String = UICompo.APIX_PRFX + "photoCtnr" ;
	static public inline var LABEL_DEFAULT :String = "Click to take a picture" ;
	static public inline var REMOVE_BUTTON_CLASS :String = UICompo.APIX_PRFX + "removeButton" ;
	static public  		 var MAX :Int = Math.round(Math.POSITIVE_INFINITY) ; // 10 ;
	/**
	 * event dispatcher when a PhotoField's char append 
	 * @see PhotoFieldEvent
	 */	
	public var click	(default, null):EventSource ;	
	//"
	public var labelElement(default,null):Elem;	
	public var buttonElement(default,null):Elem;	
	public var photoCtnrElement(default,null):Elem;		
	public var inputElementArray(default,null):Array<Elem>;	
	var imageDataList:Array<MediaData>;	
	var done:Bool;
	
	//getter	
	public var max(get, null):Int;	
	/**
	* constructor
	* @param ?p PhotoFieldProp
	*/
	public function new (?p:PhotoFieldProp) {
		super(); 
		done = false;
		click 	= new EventSource();
		inputElementArray = [];
		compoSkinList = PhotoFieldLoader.__compoSkinList;
		setup(p);		
	}
	/**
	 * setup  PhotoFieldProp
	 * @param ?p PhotoFieldProp
	 * @return this
	 */
	override public function setup (?p:PhotoFieldProp) :PhotoField {	
		super.setup(p);
		return this;
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :PhotoField {	
		labelElement = ("#" + id + " ." + PhotoField.LABEL_CLASS).get();			
		buttonElement = ("#" + id + " ." + PhotoField.BUTTON_CLASS).get();
		photoCtnrElement = ("#" + id + " ." + PhotoField.PHOTO_CTNR_CLASS).get();
		buttonElement.on(StandardEvent.CLICK, onClickButton);
		enabled = true;	
		return this;
	}
	override public function remove ()  :PhotoField {		
		super.remove();
		buttonElement.off(StandardEvent.CLICK, onClickButton);
		for (i in 0...value.length) {
			var md:Dynamic = value[i];
			if (md.button != null) {
				var but:Elem = md.button;
				but.off(StandardEvent.CLICK, onClickRemoveButton);	
			}
		}	
		element.delete();
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : PhotoField{		
		super.update();
		labelElement.text(label);			
		element.css("width",width);
		element.css("height", height);
		if (value != [] && !done) {
			done = true;
			if (value.length > max) trace("f:: " + lang.photoLimit);
			for (i in 0...value.length) { //			
				var md:MediaData = value[i]; //
				var pcEl = displayPicture(md.data);
				inputElementArray.push(pcEl.elemByTag("img"));
				addRemoveButtonListener (pcEl, md) ;
			}
		}
		return this;
	}	
	public function renamePicture () {
		for (i in 0...value.length) {
			var md:MediaData = value[i];
			md.name = name + "-" + (i + 1);				
		}		
	}
	/**
	 * private  
	 */	
	function onClickButton (e:ElemEvent) {
		if (value.length<max) {
			if (g.isMobile) {
				Camera.getPicture(onCamSuccess, onCamError, { targetWidth:400, targetHeight:400 ,quality: 50, destinationType: DestinationType.DATA_URL } );			
			}
			else {
				// testing on web with a drawing
				var pcEl = displayPicture("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");			
				inputElementArray.push(pcEl.elemByTag("img"));
				var md = storePicture("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");
				addRemoveButtonListener (pcEl, md) ;
			}
		}
		else ("" + lang.photoLimit).alert(); 	
	}
	function onCamSuccess(imageData) {
		var pcEl = displayPicture(imageData);	
		inputElementArray.push(pcEl.elemByTag("img"));
		var md=storePicture(imageData);
		addRemoveButtonListener (pcEl,md) ;
				
	}
	function displayPicture (?imageData) : Elem {
		var pcEl = photoCtnrElement.clone();
		element.addChild(pcEl);		
		pcEl.css("display", "block");
		var imgEl = pcEl.elemByTag("img");
		if (imageData != null) imgEl.prop("src", ("data:image/jpeg;base64," + imageData));	
		pcEl.width((Math.min(Common.screenWidth, 300 )));
		return pcEl ;
	}
	function addRemoveButtonListener (pcEl:Elem,md:MediaData) {
		var but = ("." + PhotoField.REMOVE_BUTTON_CLASS).get(pcEl);
		but.on(StandardEvent.CLICK, onClickRemoveButton, { ctnr:pcEl, but:but, md:md } );
		untyped md.button = but;
	}
	function onCamError(m:String) {
		("" + lang.photoError.label+"\n"+m).alert(); 
	}
	function storePicture (?imageData) : MediaData {
		var md:MediaData = { name:null, type:"image", ext:"jpeg", code:"base64", data:imageData } ;
		value.push(md);
		//
		renamePicture ();
		//dispatch
		if (click.hasListener()) click.dispatch(new PhotoFieldEvent(this, value,inputElementArray, id));
		return md;
	} 
	function removePicture (data:Dynamic)  {
		// off
		var but:Elem = data.but;
		but.off(StandardEvent.CLICK, onClickRemoveButton);		
		// remove from value
		for (i in 0...value.length) {
			var mda:MediaData = value[i];
			var mdb:MediaData = data.md ;
			if (mda.name == mdb.name) {				
				value.splice(i, 1);
				inputElementArray.splice(i, 1);
				break;
			}
		}		
		// delete de element photoCtnrElement
		var el:Elem = data.ctnr;	
		el.delete();
		renamePicture ();
		//dispatch
		if (click.hasListener()) click.dispatch(new PhotoFieldEvent(this, value,inputElementArray, id));
	} 
	
	function onClickRemoveButton (e:ElemEvent,data:Dynamic) {	
		removePicture (data);
	}
	//get/set
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = PhotoField.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	function get_max () :Int{
		var v:Int=null;
		if (compoProp.max != null) v = compoProp.max ;
		else {
			v = PhotoField.MAX;			
		}
		compoProp.max = v;		
		return v;
	}
	override function get_name () :String {
		var v:String=null;
		if (compoProp.name != null) v = compoProp.name ;
		else {
			v = PhotoFieldLoader.newSingleName ;
		}
		compoProp.name = v;		
		return v;
	}
	override function get_value () : Array<MediaData> {		
		if (imageDataList==null) {
			if (compoProp.value != null) imageDataList = compoProp.value ;
			else  imageDataList = [];
		}
		return imageDataList ;
	}
	override function get_isEmpty () : Bool {
		return imageDataList.length == 0 ;		
	}
	//
	//
	//
	/**
	 * static public  
	 */
	/**
	 * load a skin.
	 * use it for each used skin ; PhotoFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		PhotoFieldLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit PhotoField
 */
class PhotoFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "PhotoField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + PhotoFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( PhotoFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		PhotoFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	// get unique name
	public static var newSingleName(get, null):String ; static var _nextSingleName:Int=-1 ;
	static function get_newSingleName ():String { 
		_nextSingleName++ ; var name = "untitledPhoto_" + _nextSingleName ; 		
		return name;
	}	
	
}
