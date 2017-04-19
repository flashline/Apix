package apix.ui.container;
//
import apix.common.event.EventSource;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.container.Container;
import apix.ui.UICompo;
import apix.common.event.StandardEvent;
import haxe.Http; 
import apix.ui.container.Node ;
import apix.ui.container.TabNode ;
//using
using apix.common.util.StringExtender;
using apix.common.util.ArrayExtender;
#if (js)
	using apix.common.display.ElementExtender;
#end
//
typedef TabBoxProp = { 
	> ContainerProp,
	?nodesProp:Array<TabNodeProp>
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
 * @param  label
 * 
 */
/**
 * Event
 * @source  	click 
 * @param		target				this
 * @param		value				the picture object -BmpData;
 * @param		id					this Element id
 */
class TabBoxEvent extends StandardEvent {
	public var current:TabNode;
	public var previous:TabNode;
	public var id:String;
	public function new (target:TabBox, current:TabNode,previous:TabNode,id:String) { 
		super(target);
		this.current = current;
		this.previous = previous;
		this.id = id;
	}	
}
//
class TabBox extends Container  {
	static public inline var LABEL_DEFAULT :String = "Untitled ! TabBox needs title !" ;
	static public inline var HEAD_CTNR_CLASS :String = UICompo.APIX_PRFX+"headCtnr" ;	
	static public inline var BODY_CTNR_CLASS :String = UICompo.APIX_PRFX+"bodyCtnr" ;	
	static public inline var FOOT_CTNR_CLASS :String = UICompo.APIX_PRFX+"footCtnr" ;	
	//	
	var nodeHeadOriginal:Elem;
	var nodeBodyOriginal:Elem;	
	var headInto:String;
	var bodyInto:String; 
	//
	public var footElement(default, null):Elem; 
	public var nodesProp(get,never):Array<TabNodeProp>;
	public var nodes(default, null):Array<TabNode>;
	public var click(default, null):EventSource;
	public var previousNode(default, null):TabNode;
	/**
	* constructor
	* @param ?p TabBoxProp
	*/
	public function new (?p:TabBoxProp) {	
		click = new EventSource();
		nodes = [];
		compoSkinList = TabBoxLoader.__compoSkinList;
		super(); 				
		setup(p);		
	}	
	override public function enable ()  :TabBox {			
		nodeHeadOriginal = ("#" +id + " ." + Node.HEAD_CLASS).get();
		nodeBodyOriginal = ("#" + id + " ." + Node.BODY_CLASS).get();	
		headInto = "#" + id + " ." + TabBox.HEAD_CTNR_CLASS;
		bodyInto = "#" + id + " ." + TabBox.BODY_CTNR_CLASS;
		headInto.get().removeChildren();
		bodyInto.get().removeChildren();				
		footElement =  ("#" +id + " ." + TabBox.FOOT_CTNR_CLASS).get(); 
		footElement.id = id + "_foot";
		enabled = true;
		return this;
	}
	/**
	 * setup  NodeProp
	 * @param ?p NodeProp
	 * @return this
	 */
	/*override public function setup (?p:TabBoxProp) :TabBox {	
		super.setup(p);
		return this;
	}*/	
	override public function remove ()  :TabBox {
		removeNodes();		
		element.delete();		
		return this;
	}
	public function addNode (p:TabNodeProp) :TabNode {	
		p.into = null;
		var tn = new TabNode(null,manageNodes);
		tn.createNode(id,p, nodeHeadOriginal, nodeBodyOriginal, headInto, bodyInto);
		nodes.push(tn);
		return tn;
	}
	public function active (n:Int) :TabNode {	
		manageNodes(nodes[n]);
		return nodes[n];
	}
	public function addContentStr (n:Int, v:String) :Elem {	
		if ( nodes[n] == null) trace("f::Before adding content, TabBox must be in a container with its nodes created !");
		return nodes[n].addContentStr(v); 
	}
	public function addContent  (n:Int,el:Elem) :Elem {	
		if ( nodes[n] == null) trace("f::Before adding content, TabBox must be in a container with its nodes created !");
		return nodes[n].addChild(el);
	}	
	public function addContentCompo (n:Int,c:UICompo)  :TabBox {
		if ( nodes[n] == null) trace("f::Before adding component, TabBox must be in a container with its nodes created !");
		nodes[n].addCompo(c);
		return this;
	}
	public function removeContentCompo (n:Int,c:UICompo)  :TabBox {
		if ( nodes[n] == null) trace("f::Before removing component, TabBox must be in a container with its nodes created !");
		nodes[n].removeCompo(c);
		return this;
	}
	public function clearContent (n:Int) :TabBox {	
		if ( nodes[n] == null) trace("f::Before clear contents, TabBox must be in a container with its nodes created !");
		nodes[n].clearContent(); 
		return this;
	}
	public function clearAllContent () :TabBox {	
		for (n in nodes) n.clearContent (); 
		return this;
	}	
	//
	public function addFootCompo (c:UICompo)  :TabBox {
		if (c.isCreated()) {
			footElement.addChild(c.element);
			c.setup({into:"#"+footElement.id});
			update();
		}
		return this;
	}
	public function removeFootCompo  (c:UICompo)  :TabBox {
		if (c.isCreated()) {
			c.remove();
			if (footElement.hasChild(c.element)) footElement.removeChild(c.element);
			c.setup( { into:null } );
		}
		return this;
	}
	
	/**
	 * private  
	 */	
	
	function manageNodes (activeNode:TabNode)  {
		for (n in nodes) if (n != activeNode) n.hide();
		if (click.hasListener()) click.dispatch(new TabBoxEvent(this, activeNode, previousNode , id));
		previousNode = activeNode;
	}	
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update ()  :TabBox {
		super.update();
		if (nodesProp.length>0) {
			createNodes ();				
		}
		return this;
	}	
	function createNodes ()  {	
		if (nodes.length > 0) removeNodes();		
		for (p in nodesProp) {	
			addNode (p);
		}
		active(0);
		compoProp.nodesProp = [];
	}		
	function removeNodes ()  {	
		var n:TabNode;
		while ( (n=nodes.pop())!=null ) {
			n.remove();
		}						
	}
	//gets	
	function get_nodesProp () :Array<TabNodeProp> {		
		var v:Array<TabNodeProp>;
		if (compoProp.nodesProp != null) v = compoProp.nodesProp ;
		else {
			v = [];			
		}
		compoProp.nodesProp = v;		
		return v;
	}		
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
		TabBoxLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit TabBox
 */
class TabBoxLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "TabBox/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + TabBoxLoader.PATH : pathStr ; 
		UICompoLoader.__push( TabBoxLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		TabBoxLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
