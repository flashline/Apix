package apix.ui.container;
//
import apix.common.util.Global;
import apix.common.display.Common;
import apix.common.event.EventSource;
import apix.common.util.Object;
import apix.ui.input.InputField;
import apix.ui.UICompo;
import apix.common.event.StandardEvent;
import haxe.Http; 
import apix.ui.container.Container ;
//using
using apix.common.util.StringExtender;
using apix.common.util.ArrayExtender;
#if js
	using apix.common.display.ElementExtender;
#end
typedef GridProp = { 
	> ContainerProp,
	?column:Bool
} 
typedef ClassInfo = { 
	cls:Class<UICompo>,
	compo:UICompo,
	compoProp:CompoProp
} 
typedef ItemInfo = { 
	id:String,
	classInfoList:Array<ClassInfo>
}
typedef GridValues = { 
	gridId:String,
	rows:Array<Row>
}
typedef Row = { 
	rowId:String,
	fields:Array<Field>
}
typedef Field = {	
	fieldId:String,
	cls:Class<UICompo>,
	compoName:String,
	compo:UICompo
}
//
class GridEvent extends StandardEvent {
	public var value:GridValues;
	public var id:String;
	public function new (target:Grid, id:String,value:GridValues) { 
		super(target);
		this.value = value;
		this.id = id;
	}	
}
//
/**
 * In properties
 * @param  into			#+container id
 * @param  skin			skinName
 * @param  id 			Compo Elem id
 * @param  name			uiCompo name
 * @param  auto			true if auto enable
 * 
 * @param  width
 * @param  height
 * @param  scroll		if true => overflow = scroll ; else hidden
 * 
 * @param  legend		legend label
 * @param  column		true if layout is horizontal
 */
/**
 * Out standard value
 * @param value			value
 * 							value has typdef "GridValues" with this structure to access component's value :
 * 								value.rows[n].fields[n'].uiCompo.value 
 */
/**
 * Event
 * @source  	valid append		-click on valid or append button by user. If user don't click : In the main program you can read 'value' @see GridValues.
 * @param		target				this
 * @param 		id					compo id
 * @param		value				value 
 */
//
class Grid extends Container  {	
	static public inline var FIELD_CTNR_CLASS :String = UICompo.APIX_PRFX + "fieldCtnr" ;
	static public inline var ITEM_CTNR_CLASS :String = UICompo.APIX_PRFX + "itemCtnr" ;
	static public inline var ITEM_CLASS :String = UICompo.APIX_PRFX + "item" ;
	static public inline var UP_CLASS :String = UICompo.APIX_PRFX + "up" ;
	static public inline var DOWN_CLASS :String = UICompo.APIX_PRFX + "down" ;
	static public inline var REMOVE_CLASS :String = UICompo.APIX_PRFX + "remove" ;
	static public inline var APPEND_CLASS :String = UICompo.APIX_PRFX + "append" ;
	static public inline var VALID_CLASS :String = UICompo.APIX_PRFX + "valid" ;
	static public inline var LABEL_DEFAULT :String = "Enter at least 1 row in the grid" ;	
	/**
	 * event dispatcher when user click on "valid" button.
	 * dispatch 
	 * @see GridEvent and Event comments
	 */	
	public var valid	(default, null):EventSource ; 
	/**
	 * event dispatcher when user click on "add" or "remove" button.
	 * dispatch 
	 * @see GridEvent and Event comments
	 */	
	public var append	(default, null):EventSource ; 
	//
	public var firstFieldsCtnrElement(default, null):Elem;	
	//
	var classInfoList:Array<ClassInfo>;	
	var itemInfoList:Array<ItemInfo>;	
	var baseItemElement:Elem;	
	var valided:Bool;
	
	/**
	* constructor
	* @param ?p GridProp
	*/
	public function new (?p:GridProp) {		
		/*classInfoList = [];
		valid = new EventSource();
		append = new EventSource();	
		super(); 
		compoSkinList = GridLoader.__compoSkinList;		
		setup(p);*/
		
		super(); 
		classInfoList = [];
		valid = new EventSource();
		append = new EventSource();
		//itemInfoList = [];				
		compoSkinList = GridLoader.__compoSkinList;
		setup(p);
	}
	/* Grid must be enabled by an explicit call of Grid.enable().
	 * so the UICompo.setup can't be used */
	override public function setup (?p:GridProp) :Grid {	
		setCompoProp(p);
		if (isInitialized()) {
			if (!isCreated()) create();
			if (ctnrExist()) update ();
		}
		return this;
	}
	//getter
	public var column(get, null):Bool;	
	public var baseItemSource(get, null):String; var _baseItemSource:String;		
	public var firstItemElement(get, null):Elem;	
	public var values(get, null):GridValues;	
	
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update ()  :Grid {
		if (isEnabled()) trace("f:: you can't add components in Grid " + id + " because it is already enabled !! ");
		if (baseItemElement == null) {
			baseItemElement = firstItemElement.clone();
			setBaseItemSource();
		}
		if (g.strVal(firstItemElement.id, "") == "") {
			firstItemElement.id = newItemId ;	
			initItemInfoList (firstItemElement.id);
		}		
		element.style.width=width;
		element.style.height = height;
		element.style.overflow = (scroll)?"scroll":"hidden";		
		firstFieldsCtnrElement=("#" + id + " ." + Grid.FIELD_CTNR_CLASS).get() ;		
		setLayoutInFieldsCtnr(firstItemElement);			
		return this;
	
	}	
	/**
	 * calling prog call one time enable() when all fields are added by addCompo() 
	 * @return this
	 */
	override public function enable ()   : Grid {	
		if (isEnabled()) trace("f:: Grid "+id+" already enabled !! ");
		if (!ctnrExist() || !isCreated()) trace("f:: Grid " + id + " can't be enabled !! ");
		//
		legendElement = ("#" + id + " legend").get() ;
		if (g.strVal(legend,"") != "") {
			if (legendElement == null || (!element.hasChild(legendElement)) ) {
				legendElement = Common.createElem(TagType.LEGEND) ;
				element.addChild(legendElement);				
			}
			legendElement.text(legend);
		} 
		else {
			if (legendElement != null && element.hasChild(legendElement)) {				
				element.removeChild(legendElement);
				legendElement = null;
			}			
		}
		//
		renameFieldsId(firstItemElement);	
		addItemListener(firstItemElement);
		addFirstAppendListener();
		enableValid() ;
		//
		return this;		
	}
	override public function addChild (el:Elem)  :Grid {
		firstFieldsCtnrElement.addChild(el);
		update ();
		return this;
	}
	override public function removeChild (el:Elem)  :Grid {
		firstFieldsCtnrElement.removeChild(el);
		return this;
	}
	
	public function addCompoClass (cls:Class<UICompo> , p:Dynamic, ?itemElem = null,?itemClassInfoList:Array<ClassInfo>)  :Grid { 
		var c = Type.createInstance(cls, [p]);
		var o:ClassInfo = { cls:cls, compo:c, compoProp:p };
		if (itemElem == null) {	
			itemElem=firstItemElement;
			classInfoList.push(o);		
			itemInfoList[0].classInfoList.push(o);			
		}
		else {
			if (itemClassInfoList==null || !Std.is(itemClassInfoList,Array) ) trace("f:: Grid.addCompoClass() => itemClassInfoList must be Array and initialised ! id="+itemElem.id);
			itemClassInfoList.push(o);
		}		
		if (c.isCreated()) {
			var ctnrStr = "#" + id + " #" + itemElem.id + " ." + Grid.FIELD_CTNR_CLASS ;			
			ctnrStr.get().addChild(c.element);			
			c.setup( { into:ctnrStr } );
			update();
		}
		return this;
	}
	public function removeAllCompo ()  :Grid { 
		var o:ClassInfo = classInfoList.pop();
		while ( (o!=null) ) {			
			o.compo.remove();
			o=classInfoList.pop();
		}
		initItemInfoList (firstItemElement.id);
		firstFieldsCtnrElement.removeChildren();
		return this;
	}
	
	/**
	 * private  
	 */	
	function removeAllItemCompo (el:Elem)  :Elem { 		
		var ooa = getItemInfo (el);
		var itemInfo:ItemInfo 	= ooa.object ; 
		var idx:Int 			= ooa.index;
		var itemClassInfoList = itemInfo.classInfoList;		
		var o=itemClassInfoList.pop();
		while ( (o!=null) ) {			
			o.compo.remove(); 
			o=itemClassInfoList.pop();
		}		
		removeItemInfo (idx);	
		return el;
	}
	inline function getItemInfo (el:Elem)  :ObjectOfArray { 
		return itemInfoList.objectOf(el.id) ;
	}
	inline function removeItemInfo (idx:Int)  { 
		itemInfoList.splice(idx, 1);
	}
	inline function initItemInfoList (id:String)  { 
		itemInfoList = [];
		itemInfoList.push( {id:id, classInfoList:[] } );
	}
	//listeners
	function addFirstAppendListener()   {
		var b:Elem = ("#" + id + " ." + Grid.APPEND_CLASS).get() ;
		b.on(StandardEvent.CLICK, onClickFirstAppend );
		
	}
	function enableValid()   {		
		var b:Elem = ("#" + id + " ." + Grid.VALID_CLASS).get() ;
		b.style.display = "initial";
		if (!b.hasLst()) b.on(StandardEvent.CLICK, onClickValid );
	}
	function onClickValid(e:ElemEvent) {
		var saveValided = valided; valided = true;
		var str = getRequiredEmptyFields();
		if (str != "") {
			str.alert();
			valided = saveValided;
		}
		else dispatch(valid);
	}
	function getRequiredEmptyFields () {
		var str = ""; var coma = "\n";
		for (row in values.rows) {	
			for (field in row.fields) {
				if (field.compo.required == true) {
					if (field.compo.isEmpty == true) {
						str += coma + field.compo.label ;
						coma = ",\n";	
					}
				}
			}			
		}
		if (str != "") str=lang.emptyError.label + str ;
		return str;
	}
	function onClickAppend(e:ElemEvent) {
		dispatch(append);	
	}
	function dispatch(es:EventSource) {
		if (es.hasListener() ) {
			es.dispatch(new GridEvent(
									this,
									id,
									value
							)
			);
		}	
	}
	function get_values() : GridValues {
		var val: GridValues = { gridId:id, rows:[] };
		("#" + id + " ." + Grid.ITEM_CLASS).all();
		for (itemEl in ("#" + id + " ." + Grid.ITEM_CLASS).all()) {
			var itemInfo:ItemInfo  = getItemInfo (itemEl).object ;
			if (itemInfo.classInfoList != null) {
				val.rows.push( untyped new Object({ rowId:itemInfo.id, fields:[] } ));
				for (classInfo in itemInfo.classInfoList) {				
					val.rows.last().fields.push( { fieldId:classInfo.compo.id, cls:classInfo.cls,compoName:Type.getClassName(classInfo.cls), compo:classInfo.compo } );				
				}
			} else break;
		}
		if (!valided) val.rows = [];
		return val;		
	}
	override function get_value () :  GridValues {		
		return values;
	}
	override function get_isEmpty () : Bool {
		return value.rows.length==0 ;		
	}
	// used only if required==true to build the error message
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = lang.grid.label ;
			if (g.strVal(v,"")=="") v=Grid.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	function disableValid()   {		
		var b:Elem = ("#" + id + " ." + Grid.VALID_CLASS).get() ;
		b.style.display = "none";
	} 
	function addItemListener(el:Elem)  : Elem {
		var b:Elem = ("#" + el.id + " ." + Grid.APPEND_CLASS).get() ;
		b.on(StandardEvent.CLICK, onClickAppendItem,{el:el});
		b = ("#" + el.id + " ." + Grid.REMOVE_CLASS).get() ;
		b.on(StandardEvent.CLICK, onClickRemoveItem, { el:el } );
		b = ("#" + el.id + " ." + Grid.DOWN_CLASS).get() ;
		b.on(StandardEvent.CLICK, onClickDownItem, { el:el } );
		b = ("#" + el.id + " ." + Grid.UP_CLASS).get() ;
		b.on(StandardEvent.CLICK, onClickUpItem, { el:el } );		
		return el;
	}
	function removeItemListener(el:Elem) : Elem{
		var b:Elem = ("#" + el.id + " ." + Grid.APPEND_CLASS).get() ;
		b.off(StandardEvent.CLICK, onClickAppendItem);
		b = ("#" + el.id + " ." + Grid.REMOVE_CLASS).get() ;
		b.off(StandardEvent.CLICK, onClickRemoveItem);
		return el;
	}
	function onClickFirstAppend(e:ElemEvent) {
		var el = firstItemElement ; var nel = null;
		if (el != null) {
			if ( rowIsEmpty (el) ) ("" + lang.noInsertIfEmpty.label).alert();
			else {
				nel = assignId(el.insertElementBefore(baseItemElement.clone()), newItemId) ;				
			}
		}
		else {
			el = ("#" + id + " ." + Grid.ITEM_CTNR_CLASS).get() ;
			nel = assignId(el.addChild(baseItemElement.clone()), newItemId) ;		
		}
		if (nel != null) {
			var itemInfo = {id:nel.id,classInfoList:[] };
			for (o in classInfoList) {
				addCompoClass(o.cls, o.compoProp,nel,itemInfo.classInfoList);
			}
			itemInfoList.push(itemInfo) ;
			addItemListener(renameFieldsId(setLayoutInFieldsCtnr(nel)));	
			dispatch(append);				
			
		}
	}
	function onClickAppendItem(e:ElemEvent, data:Dynamic) {		
		var el:Elem = data.el;
		if ( rowIsEmpty (el) ) ("" + lang.noInsertIfEmpty.label).alert();
		else {
			var nel = assignId(el.insertElementAfter(baseItemElement.clone()), newItemId) ;
			var itemInfo = {id:nel.id,classInfoList:[] };
			for (o in classInfoList) {
				addCompoClass(o.cls, o.compoProp,nel,itemInfo.classInfoList);
			}
			itemInfoList.push(itemInfo) ;
			addItemListener(renameFieldsId(setLayoutInFieldsCtnr(nel)));	
			dispatch(append);			
		}
	}
	function onClickRemoveItem(e:ElemEvent,data:Dynamic) {
		var el:Elem = data.el;
		removeAllItemCompo(removeItemListener(el)).delete();
		dispatch(append);
	}
	function onClickDownItem(e:ElemEvent,data:Dynamic) {
		var el:Elem = data.el;
		var next = el.nextElement();
		if (next == null) ("" + lang.lastRow.label).alert();
		else {
			el.insertElementBefore(next);
		}
	}
	function onClickUpItem(e:ElemEvent,data:Dynamic) {
		var el:Elem = data.el;
		var prev = el.previousElement();
		if (prev == null) ("" + lang.firstRow.label).alert();
		else {
			prev.insertElementBefore(el);
		}
	}
	function assignId (el:Elem,v:String) :Elem {
		el.id = v;
		return el;
	}
	function clearFieldsId (el:Elem) {
		if (g.strVal(el.id, "") == "") trace("f:: item Element must have an id !! ");	
		var fc = ("#" + el.id + " ." + Grid.FIELD_CTNR_CLASS).get() ;
		fc.forEachChildren(function (child:Elem) {
								child.id = null;								
							});
		
	}
	function renameFieldsId (el:Elem)  :Elem {
		if (g.strVal(el.id, "") == "") trace("f:: item Element must have an id !! ");	
		var fc = ("#" + el.id + " ." + Grid.FIELD_CTNR_CLASS).get() ;
		resetNextFieldId();
		fc.forEachChildren(function (child:Elem) {
								child.id = "";
								child.id = getNewFieldId(el);
							});
		return el ;
	}
	function rowIsEmpty (el:Elem)  :Bool {
		var b = true ;
		fieldsCtnrOfItem(el).forEachChildren(inline function (child:Elem) {	
													if ( g.strVal(("#" + child.id + " input").get().value(), "") != "" 													
													) b = false;
											});	
		
		return b;
	}
	function setLayoutInFieldsCtnr (el:Elem) :Elem {
		//if (g.strVal(el.id, "") == "") trace("f:: item Element must have an id !! ");	
		//var fc = ("#" + el.id + " ." + Grid.FIELD_CTNR_CLASS).get() ;
		
		fieldsCtnrOfItem(el).forEachChildren(inline function (child:Elem){
												child.style.display = (column?"inline-block":"block") ;	
											});		
		return el ;
	}
	function fieldsCtnrOfItem (el:Elem) :Elem {
		if (g.strVal(el.id, "") == "") trace("f:: item Element must have an id !! ");	
		return ("#" + el.id + " ." + Grid.FIELD_CTNR_CLASS).get() ;
	}
	
	function setBaseItemSource () {
		_baseItemSource = ("#" + id + " ." + Grid.ITEM_CTNR_CLASS).get().inner() ;
	}
	function get_baseItemSource ()  :String {
		return _baseItemSource ;
	}
	function get_firstItemElement ()  :Elem {
		return ("#" + id + " ." + Grid.ITEM_CLASS).get() ;
	}	
	function get_column () :Bool {
		var v:Bool=null;
		if (compoProp.column != null) v = compoProp.column ;
		else {			
			v = false;
		}
		compoProp.column = v;		
		return v;
	}
	// get new item unique Id
	var newItemId(get, null):String ; 
	static var _nextItemId:Int=-1 ;
	function get_newItemId ():String { 
		_nextItemId++ ; var v = id+"_" + _nextItemId ; 
		if (Common.getElem(v) != null) trace("f::Id " + v + " already exists ! "); 
		return v;
	}	
	// get new field unique Id
	var _nextFieldId:Int ; 
	// _nextFieldId has to be re-initialized before calling first time : getNewFieldId();
	function resetNextFieldId () { 
		_nextFieldId = -1;
	}
	function getNewFieldId (el:Elem):String { 
		_nextFieldId++ ; var v = el.id + "_" + _nextFieldId ; 
		if (Common.getElem(v) != null) trace("f::Id " + v + " already exists ! "); 
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
		GridLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit Grid
 */
class GridLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "Grid/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + GridLoader.PATH : pathStr ; 
		UICompoLoader.__push( GridLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		var skinContent = UICompoLoader.__storeData(result);		
		//
		GridLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
