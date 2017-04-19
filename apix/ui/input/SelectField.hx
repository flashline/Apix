package apix.ui.input;
//
import apix.common.event.StandardEvent;
import apix.common.event.EventSource;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo.UICompoLoader;
import apix.common.display.ElementExtender.Option;
import apix.common.display.ElementExtender.OptionValue;
//
import apix.ui.UICompo.CompoProp;
import apix.ui.UICompo;
import haxe.Http; 
//using
using apix.common.util.StringExtender;
using apix.common.display.ElementExtender;
//
/**
 * Main input properties 
 * @see UICompo for others
 * 
 * @param  options	Array of ElementExtender.Option	: { value:<input value>, text:"" , selected:<true or false> }
 * @param  multiple true if multi selection
 * */
/**
 * Out standard value
 * @param selectedElement 	
 * @param index 			index of first selected element 
 * @param value 			value of first selected element 
 * @param values 			Array of String -all selected element
 * @param text 				text  of first selected element  
 * @param selectedOption	ElementExtender.OptionValue of first selected element 
 * @param selectedOptions	Array of ElementExtender.OptionValue -all selected element
 */
//
typedef SelectFieldProp = { 
	> CompoProp ,	
	?multiple:Bool ,
	?options:Array<Option>	
} 
//
/**
* Events
	* @source  change ; blur
		* @param target:this
		* @param selectedOption:OptionValue;
		* @param selectedOptions:Array<OptionValue>;			
		* @param multiple:Bool;
		* @param value:String;
		* @param text:String;
		* @param label:String;
		* @param index:Int;
		* @param values:Array<String>;
		* @param selectElement:Elem;
		* @param id:String;
*/
class SelectFieldEvent extends StandardEvent {
	public var selectedOption:OptionValue;
	public var selectedOptions:Array<OptionValue>;			
	public var multiple:Bool;
	public var value:String;
	public var text:String;
	public var label:String;
	public var index:Int;
	public var values:Array<String>;
	public var selectElement:Elem;
	public var id:String;
	public function new (target:SelectField 
							,selectedOption:OptionValue
							,selectedOptions:Array<OptionValue>			
							,multiple:Bool
							,value:String
							,text:String
							,label:String
							,index:Int
							,values:Array<String>
							,selectElement:Elem
							,id:String
		) { 
			super(target);
			this.selectedOption = selectedOption;
			this.selectedOptions=selectedOptions;		
			this.multiple=multiple;
			this.value=value;
			this.text=text;
			this.label=label;
			this.index=index;
			this.values=values;
			this.selectElement=selectElement;
			this.id=id;
		}	
}
//
class SelectField extends UICompo    {
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var LABEL_DEFAULT :String = "Untitled" ;
	//static public inline var OPTION_CTNR_CLASS :String = UICompo.APIX_PRFX+"optionCtnr" ;
	
	/**
	 * event dispatchers
	 */
	public var change	(default, null):EventSource ;
	public var blur	(default, null):EventSource ;
	//
	public var labelElement(default,null):Elem;	
	public var selectElement(default,null):Elem;		
	var _selectedOptions:Array<OptionValue>;
	//getter
	/**
	 * Array of values from selected options if multiple
	 * read-only.
	 */
	public var values(get, null):Array<String>;	
	/**
	 * value of selected option
	 * read-only.
	 */
	//public var value(get, null):String;	
	/**
	 * inner text of selected option
	 * read-only.
	 */
	public var text(get, null):String;	
	/**
	 * index of selected option
	 * read-only.
	 */
	public var index(get, null):Int;	
	/**
	 * object from unique selected option or first selected option if multiple.
	 * read-only.
	 */
	public var selectedOption(get, null):OptionValue;	
	/**
	 * Array of selected options
	 * read-only.
	 */
	public var selectedOptions(get, null):Array<OptionValue>;	
	
	/**
	 * true if select with multiple choices
	 * read-only.
	 * use setup() to write this var ; @see SelectFieldProp .
	 */
	public var multiple(get, null):Bool;
	/**
	 * Array of Option {label,data,selected}
	 * read-only.
	 * use setup() to write this var ; @see SelectFieldProp .
	 */
	public var options(get, null):Array<Option>;

	
	/**
	* constructor
	* @param ?p SelectFieldProp
	*/
	public function new (?p:SelectFieldProp) {
		super(); 
		change 	= new EventSource();		
		blur 	= new EventSource();		
		compoSkinList = SelectFieldLoader.__compoSkinList;
		setup(p);		
	}
	/**
	 * setup  SelectFieldProp
	 * @param ?p SelectFieldProp
	 * @return this
	 */
	override public function setup (?p:SelectFieldProp) :SelectField {	
		super.setup(p);
		return this;
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()  :SelectField {			
		selectElement = ("#" + id + " select").get();		
		labelElement = ("#" + id + " ." + SelectField.LABEL_CLASS).get();		
		selectElement.on(StandardEvent.CHANGE, onSelectChange);
		selectElement.on(StandardEvent.BLUR, onSelectBlur);
		enabled = true;	
		return this;
	}
	override public function remove ()  :SelectField {			
		super.remove();
		selectElement.off(StandardEvent.CHANGE, onSelectChange);
		selectElement.off(StandardEvent.BLUR, onSelectBlur);
		element.delete();
		return this;
	}
	/**
	 * update compo each time properties are modified
	 * @return this
	 */
	override function update() : SelectField {	
		super.update();
		labelElement.text(label);		
		selectElement.multiple(multiple);
		selectElement.css("height", height);		
		selectElement.removeChildren();		
		for (o in options) {
			var opt:Elem = Common.createElem(TagType.OPTION);			
			opt.inner(o.text);
			opt.value(o.value);
			opt.selected(o.selected);
			selectElement.addChild(opt);
		} 
		return this;
	}	
	override function get_height () :String {
		var v:String=null;
		if (compoProp.height != null) v = compoProp.height ;
		else {
			if (element!=null && g.strVal(element.style.height,"") !="") v = element.style.height ;
			else v = "auto";		
		}
		compoProp.height = v;		
		return v;
	}
	/**
	 * private  
	 */	
	//
	function onSelectChange (e:ElemEvent) {
		_selectedOptions = null;
		if (change.hasListener()) dispatchEvent(change);
	}
	function onSelectBlur (e:ElemEvent) {
		_selectedOptions = null;
		if (blur.hasListener()) dispatchEvent(blur);
	}
	function dispatchEvent (es:EventSource) {
		es.dispatch(new SelectFieldEvent(this,
											selectedOption , 
											selectedOptions , 	
											multiple ,
											value , 
											text , 
											label , 
											index , 
											values , 
											selectElement, 
											id ) 
					) ;
	}
	function get_selectedOptions () :Array<OptionValue> {
		if (_selectedOptions == null) _selectedOptions = selectElement.getSelectedOptions();
		return _selectedOptions;
	}
	function get_selectedOption () :OptionValue {
		var v:Array<OptionValue>=selectedOptions;
		var ov:OptionValue = null;
		if (v.length > 0) ov = v[0];
		else ov = { text:"", value:"", index: -1 } ;
		return ov;
	}	
	function get_values () :Array<String> {
		var arr =[];
		for (o in selectedOptions) {
			arr.push(o.value);
		}
		return arr;
	}	
	override function get_value () :String {
		return selectedOption.value;
	}
	/*override function set_value (v:String) :String {
		if (multiple) trace("f::You can't use set value in a multi-selection SelectField ! id is " + id);	
		var i = -1 ;
		for (o in options) {
			i++; var opt:Elem= selectElement.childAt(i);				
			if (o.value == v) {
				opt.selected(true);
			}
			else {
				opt.selected(false);
			}
		}
		return v;
	}
	*/
	function get_text () :String {
		return selectedOption.text;
	}
	function get_index () :Int {
		return selectedOption.index;
	}	
	override function get_label () :String {
		var v:String=null;
		if (compoProp.label != null) v = compoProp.label ;
		else {
			v = SelectField.LABEL_DEFAULT;			
		}
		compoProp.label = v;		
		return v;
	}
	function get_multiple () :Bool {
		var v:Bool=null;
		if (compoProp.multiple != null) v = compoProp.multiple ;
		else {
			v = false;			
		}
		compoProp.multiple = v;		
		return v;
	}
	function get_options () :Array<Option> {
		var v:Array<Option>=null;
		if (compoProp.options != null) v = compoProp.options ;
		else {
			v = [];			
		}
		compoProp.options = v;		
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
	 * use it for each used skin ; SelectFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName = "default", ?pathStr:String)  {
		SelectFieldLoader.__init(skinName,pathStr);
	}	
}
//
//
/**
 * static class to loadinit SelectField
 */
class SelectFieldLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "SelectField/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + SelectFieldLoader.PATH : pathStr ; 
		UICompoLoader.__push( SelectFieldLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
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
		SelectFieldLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
