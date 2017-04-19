package apix.ui.container;
//
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo;
import apix.common.event.StandardEvent;
import haxe.Http; 
import apix.ui.container.Node ;
//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#else if (flash)
	using apix.common.display.SpriteExtender;
#end
//
typedef TreeNodeProp = { 
	> NodeProp,
	?shiftX:Int ,
	?selectColor:String,
	?rootMngr:Bool //,
	//?contextMenu:Bool
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
 * 
 * @param  label
 * 		
 * @param  shiftX		
 * @param  selectColor	color when selected
 * 
 */
/*
class TreeNodeEvent extends StandardEvent {
	public var values:DateValues;
	public var inputElement:Elem;
	public var id:String;
	public function new (target:TreeNode, values:DateValues, inputElement:Elem, id:String) { 
		super(target);
		this.values = values;
		this.inputElement = inputElement; 
		this.id = id;
	}	
}*/
/*
		
*/


//
class TreeNode extends Node  {
	static public inline var BAR_CLASS :String = UICompo.APIX_PRFX+"bar" ;	
	static public inline var SHIFT_CLASS :String = UICompo.APIX_PRFX+"shift" ;	
	static public inline var ARROW_CLASS :String = UICompo.APIX_PRFX + "arrow" ;
	static public inline var OPEN_CLASS :String = UICompo.APIX_PRFX+"open" ;	
	static public inline var CLOSE_CLASS :String = UICompo.APIX_PRFX+"close" ;	
	static public inline var EMPTY_CLASS :String = UICompo.APIX_PRFX + "empty" ;	
	static public inline var IMG_DISPLAY_DEFAULT :String = "inline-block" ;		
	static public inline var SELECT_COLOR__DEFAULT :String = "#aa3333" ;
	static public inline var DESELECT_COLOR__DEFAULT :String = "#333333" ;
	//
	
	public var parentNode:TreeNode;
	public var onSelect:TreeNode->Void;
	public var headId(default,null):String;
	//getter
	public var rootMngr(get, null):Bool;
	public var nodes(get, null):Array<TreeNode>;
	public 	var shiftX(get, null):Int;	
	public 	var selectColor(get, null):String;
	public var contextMenu(get, null):Bool;
	
			var imgDisplayFormat(get, null):String;
	/**
	* constructor
	* @param ?p TreeNodeProp
	*/
	public function new (?p:TreeNodeProp) {			
		super(); 
		if (!rootMngr) {
			compoSkinList = TreeNodeLoader.__compoSkinList;
			setup(p);
		}
		nodes = [];
	}	
	override public function enable ()  :TreeNode {
		bodyElement = ("#" + id + " ." + Node.BODY_CLASS).get();
		bodyElement.inner("");
		bodyElement.hide();	
		super.enable();
		("#" + id + " ." + TreeNode.BAR_CLASS).get().hide();		
		get_imgDisplayFormat();
		("#" + id + " ." + Node.HEAD_CLASS).on(StandardEvent.CLICK, onSelectHead);
		headId = Common.newSingleId;
		("#" + id + " ." + Node.HEAD_CLASS).get().id = headId ;
		//
		enabled = true;	
		return this;
	}
	/**
	 * setup  NodeProp
	 * @param ?p NodeProp
	 * @return this
	 */
	override public function setup (?p:TreeNodeProp) :TreeNode {
		if (rootMngr) trace("f::error setup can't be called by Root manager !");
		super.setup(p);
		return this;
	}
	public function addNode (n:TreeNode)  :TreeNode {
		if (!rootMngr && n.isCreated()) {
			bodyElement.addChild(n.element);
			n.setup({into:"#"+id+" ."+Node.BODY_CLASS});
			update();
		}
		n.index = nodes.length;
		n.parentNode = this;
		n.onSelect = onNodeSelected ;
		nodes.push(n);
		return this;
	}	
	public function unlink (tn:TreeNode)  : TreeNode {		
		for (n in nodes) {
			if (n.index == tn.index) {
				nodes.splice(tn.index, 1) ;
				break;
			}
		}
		ordain();
		return this;
	}	
	override public function remove ()  :TreeNode {
		for (n in nodes) {
			n.remove();
		}
		disable ();
		setCompoProp( { into:null } );		
		element.delete();
		if (parentNode!=null) parentNode.unlink(this);
		return this;
	}
	public function append (arr:Array<TreeNode>)   {
		for (n in arr) {
			addNode(n);
		}	
	}
	public function deselect ()  :TreeNode {	
		deselectChildren ();
		deselectMe ();
		return this;
	}	
	public function getNodeByHeadId(v:String) : TreeNode{
		var r:TreeNode = null;
		if (headId == v) r = this;
		else {
			for (n in nodes) {
				r = n.getNodeByHeadId(v);
				if (r != null) break;
			}
		}
		return r;
	}
	override public function disable () : TreeNode {
		if (rootMngr) trace("f::error Root manager isn't a display object !");		
		super.disable();
		("#" + id + " ." + Node.HEAD_CLASS).off(StandardEvent.CLICK, onSelectHead, false);	
		return this;
    }
	/**
	 * private  
	 */	
	
	function deselectChildren ()  :TreeNode {		
		for (n in nodes) {
				n.deselect(); 
		}
		return this;
	}	
	function selectMe ()  :TreeNode {
		if (rootMngr) trace("f::error Root manager isn't a display object !");
		("#" + id + " ." + Node.LABEL_CLASS).get().css("color", selectColor);
		("#" + id + " ." + TreeNode.BAR_CLASS).get().show("inline-block");				
		return this;
	}
	function deselectMe ()  :TreeNode {
		if (rootMngr) trace("f::error Root manager isn't a display object !");
		("#" + id + " ." + Node.LABEL_CLASS).get().css("color", "");
		("#" + id + " ." + TreeNode.BAR_CLASS).get().hide();			
		return this;
	}
	
	function onNodeSelected (?sn:TreeNode)  {
		if (onSelect != null) onSelect(this);
		else if (rootMngr) deselectChildren();
	}
	inline function ordain ()  {
		for (i in 0...nodes.length) {
			nodes[i].index = i;
		}
	}
	override function update ()  :TreeNode {
		if (rootMngr) trace("f::error Root manager isn't a display object !");
		super.update();
		element.style.width		= width;
		element.style.height	= height;	
		//
		("#" + id + " ." + Node.BUTTON_CLASS).get().visible(true);
		if (bodyIsOpen()) {
			("#" + id + " ." +TreeNode.CLOSE_CLASS).get().hide(); 
			("#" + id + " ." +TreeNode.EMPTY_CLASS).get().hide(); 
			("#" + id + " ." +TreeNode.OPEN_CLASS).get().show(imgDisplayFormat); 	
			//
			("#" + id + " ." + Node.BUTTON_CLASS).get().setRotation(90);
		} else {
			("#" + id + " ." + Node.BUTTON_CLASS).get().setRotation(0);
			("#" + id + " ." +TreeNode.OPEN_CLASS).get().hide();
			if (bodyIsEmpty()) {
				("#" + id + " ." +TreeNode.EMPTY_CLASS).get().show(imgDisplayFormat);
				("#" + id + " ." +TreeNode.CLOSE_CLASS).get().hide();	
				("#" + id + " ." + Node.BUTTON_CLASS).get().visible(false);
			} else {
				("#" + id + " ." +TreeNode.CLOSE_CLASS).get().show(imgDisplayFormat);
				("#" + id + " ." +TreeNode.EMPTY_CLASS).get().hide();		
			}
			//	
		}
		("#" + id + " ." + TreeNode.SHIFT_CLASS).get().width(shiftX);	
		return this;
	}	
	override function onOpenClose (e:ElemEvent) {
		if (rootMngr) trace("f::error Root manager isn't a display object !");
		super.onOpenClose(e);
		update();
    }
	function onSelectHead (e:ElemEvent) {
		if (rootMngr) trace("f::error Root manager isn't a display object !");
		
		if (!isArrow(e)) {
			onNodeSelected();
			selectMe();		
		}
    }	
	function isArrow  (e:ElemEvent)  {
		if (rootMngr) trace("f::error Root manager isn't a display object !");
		
		var el:Elem = untyped e.target;
		return el.hasClass(TreeNode.ARROW_CLASS);
    }
	
	
	
	//gets
	function get_contextMenu () :Bool {		
		var v:Bool=null;
		if (compoProp.contextMenu != null) v = compoProp.contextMenu ;
		else {			
			v = false;
		}
		compoProp.contextMenu = v;		
		return v;
	}	
	function get_rootMngr () :Bool {		
		var v:Bool=null;
		if (compoProp.rootMngr != null) v = compoProp.rootMngr ;
		else {			
			v = false;
		}
		compoProp.rootMngr = v;		
		return v;
	}	
	function get_nodes () :Array<TreeNode> {		
		return nodes;
	}	
	function get_shiftX () :Int {
		var v:Int=null;
		if (compoProp.shiftX != null) v = compoProp.shiftX ;
		else {			
			v = 0;
		}
		compoProp.shiftX = v;		
		return v;
	}
	function get_selectColor () :String {
		var v:String=null;
		if (compoProp.selectColor != null) v = compoProp.selectColor ;
		else {			
			v = TreeNode.SELECT_COLOR__DEFAULT;
		}
		compoProp.selectColor = v;		
		return v;
	}
	var _imgDisplayFormat:String;
	function get_imgDisplayFormat () :String {
		if (_imgDisplayFormat==null) {
			_imgDisplayFormat = g.strVal(("#" + id + " ." +TreeNode.CLOSE_CLASS).get().getDisplay(), "").toLowerCase();
			if (_imgDisplayFormat == "") _imgDisplayFormat = TreeNode.IMG_DISPLAY_DEFAULT ;
		}
		return _imgDisplayFormat;
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
		TreeNodeLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit TreeNode
 */
class TreeNodeLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "TreeNode/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + TreeNodeLoader.PATH : pathStr ; 
		UICompoLoader.__push( TreeNodeLoader.__load, UICompoLoader.baseUrl + pathStr, skinName) ;
		
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
		var skinContent=UICompoLoader.__storeData(result);		
		//
		TreeNodeLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
