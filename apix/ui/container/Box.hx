package apix.ui.container;
//
import apix.common.display.Common;
import apix.common.util.Object;
import apix.ui.tools.Button;
import apix.ui.UICompo;
import haxe.Http; 
import apix.ui.container.Container ;


//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#end 
typedef BoxProp = { 
	> ContainerProp,
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

class Box extends Container  {	
	/**
	* constructor
	* @param ?p BoxProp
	*/
	public function new (?p:BoxProp) {	
		super();
		compoSkinList = BoxLoader.__compoSkinList;
		setup(p);		
	}		
	
		/**
	 * add elements inside
	 * 
	 * @return this
	 */
	
	/**
	 * private  
	 */		
	//getter
	
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
		BoxLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit Box
 */
class BoxLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "Box/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + BoxLoader.PATH : pathStr ; 
		UICompoLoader.__push( BoxLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
	}
	/**
	 * private static
	 */
	static function __load (fromPath:String, sk:String)  {
		var h:Http = new Http(fromPath + UICompoLoader.SKIN_FILE);
		h.onData = __onData;	
		h.request(false);
		UICompoLoader.__currentSkinName = sk;
		UICompoLoader.__currentFromPath = fromPath;	
	}	
	static function __onData (result:String)  {
		var skinContent = UICompoLoader.__storeData(result);
		//
		BoxLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
