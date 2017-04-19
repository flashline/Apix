package apix.ui.tools;
//
import apix.common.util.Global;
import apix.common.display.Common;
import apix.common.util.Object;
import apix.ui.tools.PopBox;
import apix.ui.UICompo.UICompoLoader;
import apix.common.event.StandardEvent;
import apix.ui.UICompo;
import haxe.Http; 
import js.html.EventTarget;
//using
using apix.common.util.StringExtender;
#if js
	using apix.common.event.EventTargetExtender  ;
	using apix.common.display.ElementExtender;
#else if flash
	//TODO
	using apix.common.display.SpriteExtender;
#else 
	//TODO
#end
//
typedef ContextMenuRow = { 
	label:String, 
	?value:String,
	?type:String, // "" or "hr" or "br"
	?shortCut:String, // a letter or null
	callBack:ContextMenuEvent->Void,
	//
	?index:Int , 	// private -not used by caller
	?element:Elem  	// private -not used by caller
	
}
typedef ContextMenuProp = { 
	?skinPath:String,
	?id:String,
	?name:String,
	?selectors:Array<String>,
	rows:Array<ContextMenuRow>
}
class ContextMenuEvent extends StandardEvent { //if bug => remove extends and comments below //
	//public var target:ContextMenu;
	public var srcElement:Elem;
	public var trgtElement:Elem;
	public var index:Int;
	public var name:String;
	public var value:String;
	public function new (target:ContextMenu, 
							srcElement:Elem,
							trgtElement:Elem,
							name:String,
							value:String,
							index:Int
						) { 
							//this.target = target;
							super(target);
							this.srcElement = srcElement;
							this.trgtElement = trgtElement ;
							this.name=name;
							this.value=value;
							this.index=index;
						}	
}
//
/**
 * In properties
 * @param  	skinPath	skin path
 * @param  	id 			Compo Elem id
 * @param	name		name -recommended if they are many instances of ContextMenu
 * @param	selectors	target css class Array
 * @param	rows		Array of menu's rows
 * 
 */
/**
 * Out event sent to callback functions
 * @param           target				this
 * @param           srcElement		right-click source element 
 * @param           value				related action	
 */
//
class ContextMenu  {
	static public inline var CONTEXT_CTNR_CLASS :String =  UICompo.APIX_PRFX + "contextCtnr" ;	
	static public inline var SKIN_PATH_DEFAULT:String = "ContextMenu/" ;	
	//
	static var skinContent:String; 
	//
	public var element(default, null):Elem;
	public var srcElement(default, null):Elem;
	public var trgtElement(default, null):Elem;
	//getter/setter
	public var id(get,null):String;
	public var name(get,null):String;
	public var skinPath(get, null):String;
	public var selectors(get, null):Array<String>;
	public var rows(get, null):Array<ContextMenuRow>;
	//
	var compoProp:Object ; 	
	var g:Global ;
	var isLoaded(get, null):Bool; function get_isLoaded () :Bool { return g.strVal(skinContent, "") != "" ; }	
	//
	/**
	* constructor
	* @param ?p ContextMenuProp
	*/
	public function new (?p:ContextMenuProp) {	
		g = Global.get();
		compoProp = new Object();
		setup(p);		
		if (!isLoaded) load();
		else {
			create () ;	
			enable();
		}
	}		
	public function remove () :Dynamic {	
		disable ();	
		element.delete();
		return null ;
    }
	// 
	/**
	 * private  
	 */	
	function setup (?p:ContextMenuProp)  {	
		var o:Object = new Object(p); 
		if (!o.empty()) {
			o.forEach(	function (k, v, i) {
							compoProp.set(k, v);
						}
			);	
		}			
	}
	function load () {
		var h:Http = new Http(UICompoLoader.baseUrl+skinPath + UICompoLoader.SKIN_FILE);
		h.onData = onData;	
		h.request(false);
		return this ;
	}	
	function onData (result:String)  {
		var tmp = Common.createElem();
		tmp.id = UICompoLoader.TMP_CTNR_ID;
		Common.body.addChild(tmp);
		UICompoLoader.__currentFromPath = skinPath;	
		ContextMenu.skinContent = UICompoLoader.__storeData(result);
		Common.body.removeChild(tmp);	
		create () ;	
		enable();
	}
	function create ()  {	
		var el:Elem = Common.createElem();
		el.inner(ContextMenu.skinContent);
		element = el.firstElementChild;			
		element.id = id;
		Common.body.addChild(element);
		element.removeChildren();	
		//
		var idx = 0;
		for (row in rows) {
			if (row.type == "hr") el = Common.newHLine; // createElem(TagType.HLINE);
			else if (row.type == "br") el = Common.newLine; // Common.createElem(TagType.LINE);
			else {
				el = Common.createElem(TagType.SPAN);
				el.inner ( (row.shortCut != null)?row.label.replaceOnce(row.shortCut, "<u>" + row.shortCut + "</u>"):row.label );
				row.index = idx; idx++;
				row.element = el ;
			}	
			element.addChild(el);
		}
		element.hide();
    }	
	function enable ()  {
		Common.document.on(StandardEvent.CONTEXT_MENU, onContextMenu);
		Common.document.on(StandardEvent.CLICK, onClearContextMenu);	
		//
		for (row in rows) if (row.element != null ) row.element.on(StandardEvent.CLICK, onClickRow, false, row);
    }	
	//
	function disable () {
		Common.document.off(StandardEvent.CONTEXT_MENU, onContextMenu);
		Common.document.off(StandardEvent.CLICK, onClearContextMenu);	
		//
		for (row in rows) if ( row.element != null ) row.element.off( StandardEvent.CLICK, onClickRow );	
    }
	//
	function onContextMenu (ev:SysContextMenuEvent)  {
		var match = false; 
		for (str in selectors) {
			for (el in str.all() ) {
				for (trgt in ev.path) {
					//trace("trgt id=" + trgt.id+" class="+trgt.className);
					if (el == trgt) {	
						trgtElement = trgt;
						match = true;
						break;
					}					
				}
				if (match) break;
			}
			if (match) break;
		}		
		if (match) {
			ev.preventDefault();
			element.show();
			element.posx(ev.pageX);
			element.posy(ev.pageY);
			srcElement = untyped ev.srcElement;
			
			Common.enableKeyPress(onKeyPress);
		} else {
			clearContextMenu() ;
		}		
    }
	//
	function onClearContextMenu (e:ElemEvent)  {
		Common.disableKeyPress();
		clearContextMenu();
	}
	inline function clearContextMenu()  { element.hide(); }
	//	
	function onKeyPress (e:KeyPressEvent)  {
		for (row in rows) if ( row.shortCut.toLowerCase() == e.keyChrLower ) { row.element.css("backgroundColor","#efe"); doClickRow (row); }
    }
	function onClickRow (e:ElemEvent, row:ContextMenuRow)  {
		doClickRow(row);
    }
	inline function doClickRow (row:ContextMenuRow)  {	
		clearContextMenu();
		if (row.callBack!=null) row.callBack(new ContextMenuEvent(this,srcElement,trgtElement,name,row.value,row.index));
    }
	//
	//get/set
	function get_skinPath () :String {
		var v:String=null;
		if (compoProp.skinPath != null) v = compoProp.skinPath ;
		else {			
			v = UICompoLoader.DEFAULT_SKIN_PATH+ContextMenu.SKIN_PATH_DEFAULT ; 
		}
		compoProp.skinPath = v;		
		return v;
	}
	//
	function get_id () :String {
		var v:String=null;
		if (compoProp.id != null) v = compoProp.id ;
		else {			
			v = Common.newSingleId ; 
		}
		compoProp.id = v;		
		return v;
	}
	function get_name () :String {
		var v:String=null;
		if (compoProp.name != null) v = compoProp.name ;
		else {			
			v = "contextMenu-"+id ; 
		}
		compoProp.name = v;		
		return v;
	}
	function get_selectors () :Array<String> {
		var v:Array<String>=null;
		if (compoProp.selectors != null) v = compoProp.selectors ;
		else {			
			v = [""] ; 
		}
		compoProp.selectors = v;		
		return v;
	}
	function get_rows () :Array<ContextMenuRow> {
		var v:Array<ContextMenuRow>=null;
		if (compoProp.rows != null) v = compoProp.rows ;
		else {			
			"f::error : ContextMenu elements must be initialized ! ".trace(); 
		}
		for (r in v) {
			if (r.type == null) r.type = "";
			if (r.type!="hr" && r.type!="br") {
				if (r.label == null) "f::error : ContextMenu labels must exist ! ".trace(); 			
				if (r.value == null) r.value = r.label ;
				if (r.callBack == null) "f::error : ContextMenu callback functions must exist for each row ! ".trace(); 
			}
			
		}		
		compoProp.rows = v;		
		return v;
	}
	
}