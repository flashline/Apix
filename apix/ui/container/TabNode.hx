package apix.ui.container;
//
import apix.common.util.Global;
import apix.common.display.Common;
import apix.ui.UICompo;
import apix.common.event.StandardEvent;
import  apix.ui.container.Node;
//using
using apix.common.util.StringExtender;
#if (js)
	using apix.common.display.ElementExtender;
#else if (flash)
	using apix.common.display.SpriteExtender;
#end
//
typedef TabNodeProp = { 
	> NodeProp,	
} 
//
/**
 * In properties
 * @param  into			#+container id
 * @param  id 			Compo Elem id
 * @param  name			uiCompo name
 * @param  height
 * @param  width
 * @param  label	
 * 
 */

//
class TabNode extends Node  {
	public var onManageNode:TabNode-> Void;
	//getter
	/**
	* constructor
	* @param ?p TabNodeProp
	*/
	function new (?p:TabNodeProp, cb:TabNode-> Void) {
		super();
		onManageNode = cb;
		setup(p);	
	}	
	/**
	 * setup  TabNodeProp
	 * @param ?p TabNodeProp
	 * @return this
	 */
	override public function setup (?p:Dynamic) :Node {	
		setCompoProp(p);
		if (ctnrExist()) {
			if (!isEnabled()) enable();
			update();	
		}
		return this;
	}	
	override public function enable ()  :TabNode {
		super.enable();
		enabled = true;	
		return this;
	}
	public function createNode (parentId:String,np:TabNodeProp,headToClone:Elem,bodyToClone:Elem,headInto:String, bodyInto:String) :TabNode {
		element = headToClone.clone(); headElement = element;
		bodyElement = bodyToClone.clone();	
		bodyInto.get().addChild(bodyElement);
		headInto.get().addChild(element);
		if (g.strVal(np.id) == "") np.id = Common.newSingleId;
		np.id = parentId + "_" + np.id;
		element.id = np.id;
		np.into = headInto ;
		bodyElement.id = element.id + "_body";
		setup(np);
		return this;
	}
	override public function show ()  {
		super.show();	
		("#" + id + " .apix_buttonBack").get().show();
		("#" + id + " .apix_arrowOpen").get().show();
		("#" + id + " .apix_arrowClose").get().hide();
		
	}	
	override public function hide ()  {
		super.hide();
		("#" + id + " .apix_buttonBack").get().hide();
		("#" + id + " .apix_arrowOpen").get().hide();
		("#" + id + " .apix_arrowClose").get().show();
	}
	override public function remove () :Dynamic {
		super.remove();
		disable();
		element.delete();
		bodyElement.delete();
		return null;
	}
	public function addContentStr (v:String) :Elem {	
		return bodyElement.addChildFromHtml(v); 
	}
	public function clearContent () :TabNode {	
		bodyElement.removeChildren();
		return this;
	}
	public function addCompo (c:UICompo)  :Node {
		if (c.isCreated()) {
			bodyElement.addChild(c.element);
			c.setup( { into:"#" + bodyElement.id } );			
			update();
		}
		return this;
	}
	public function removeCompo (c:UICompo)  :Node {
		if (c.isCreated()) {
			c.remove();
			if (bodyElement.hasChild(c.element)) bodyElement.removeChild(c.element);
			c.setup( { into:null } );
		}
		return this;
	}
	
	/**
	 * private  
	 */	
	/**
	 * toogle open/close of body element
	 * @param	e
	 */
	override function onOpenClose (e:ElemEvent) {
		if (!bodyIsOpen()) {
			onManageNode(this);
			show();
		}					
    }	
	override function get_id () :String {
		var v:String;
		if (compoProp.id != null) v = compoProp.id ;
		else v = "" ;
		compoProp.id = v;		
		return v;
	}
	//
	//
	
}
//
