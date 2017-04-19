package apix.ui.container;
//
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.container.Box ;
import apix.ui.UICompo;
import haxe.Http; 

//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#end
//
typedef HBoxProp = { 
	> BoxProp,
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
class HBox extends Container  {
	
	
	
	/**
	* constructor
	* @param ?p HBoxProp
	*/
	public function new (?p:HBoxProp) { //,?withSetup:Bool=true
		super();
		compoSkinList = HBoxLoader.__compoSkinList;
		setup(p);
		
	}
	
	/**
	 * update compo each time properties are modified
	 * update() is generally private in other compos but must be public for HBox.
	 * @return this
	 */
	override public function update ()  :HBox {
		super.update();
		element.forEachChildren(inline function (child:Elem)  { child.style.display = "inline-block";	} );		
		return this;
	}
	

	/**
	 * private  
	 */	
	
	//
	//
	/**
	 * static public  
	 */
	/**
	 * load a skin.
	 * use it for each used skin ; Apixs can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		HBoxLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit HBox
 */
class HBoxLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "HBox/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + HBoxLoader.PATH : pathStr ; 
		UICompoLoader.__push( HBoxLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		HBoxLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
