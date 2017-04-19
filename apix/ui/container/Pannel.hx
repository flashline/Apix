package apix.ui.container;
//
import apix.common.display.Common;
import apix.ui.container.Box;
import apix.ui.UICompo;
import haxe.Http; 

//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#end
typedef PannelProp = { 
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

class Pannel extends Container {
	//
	var headElement:Elem;
	var bodyElement:Elem;
	/**
	* constructor
	* @param ?p PannelProp
	*/
	public function new (?p:PannelProp) {	
		super();
		compoSkinList = PannelLoader.__compoSkinList;
		//if (p != null) 
		setup(p);	
	}	
	override public function enable ()  : Pannel {	
		headElement = ("#" + id + " ."+UICompo.HEAD_CLASS).getIfChild(element) ;
		bodyElement = ("#" + id + " ." + UICompo.BODY_CLASS).getIfChild(element) ;
		headElement.id = id + "_head";
		bodyElement.id = id + "_body";
		enabled = true;
		return this;
	}
		/**
	 * add elements inside
	 * 
	 * @return this
	 */		
	override public function addChild (el:Elem)  :Pannel {
		bodyElement.addChild(el);
		update ();
		return this;
	}
	override public function removeChild (el:Elem)  :Pannel {
		bodyElement.removeChild(el);
		return this;
	}
	override public function addCompo (c:UICompo)  :Pannel {
		if (c.isCreated()) {
			childrenCompo.push(c);
			bodyElement.addChild(c.element);
			c.setup({ into:"#" + bodyElement.id } );
			update();
		}
		return this;
	}	
	override public function removeCompo (c:UICompo)  :Pannel {
		if (c.isCreated()) {
			c.remove();
			childrenCompo.remove(c);
			if (bodyElement.hasChild(c.element)) bodyElement.removeChild(c.element);
			c.setup( { into:null } );
		}
		return this;
	}
	public function addHeadChild (el:Elem)  :Pannel {
		headElement.addChild(el);
		update ();
		return this;
	}
	public function removeHeadChild (el:Elem)  :Pannel {
		headElement.removeChild(el);
		return this;
	}
	public function addHeadCompo (c:UICompo)  :Pannel {
		if (c.isCreated()) {
			headElement.addChild(c.element);
			c.setup({into:"#"+headElement.id});
			update();
		}
		return this;
	}
	public function removeHeadCompo (c:UICompo)  :Pannel {
		if (c.isCreated()) {
			c.remove();
			if (headElement.hasChild(c.element)) headElement.removeChild(c.element);
			c.setup( { into:null } );
		}
		return this;
	}
		
	
			
	/**
	 * private  
	 */		
	
	
	
	//
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
		PannelLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit Pannel
 */
class PannelLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "Pannel/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + PannelLoader.PATH : pathStr ; 
		UICompoLoader.__push( PannelLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		PannelLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
