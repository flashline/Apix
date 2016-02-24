package apix.common.io;
/**
* classes imports
*/

import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.common.util.Object;
import haxe.Json;
import haxe.Http; 
using apix.common.io.HttpExtender ;
using apix.common.util.StringExtender;

class JsonLoaderEvent extends StandardEvent {
	public var answer:String;
	public var tree:Object;	
	public function new (trgt:JsonLoader,?tree:Object, ?answ:String) { 
		super(target);
		this.target = trgt; // dont remove this line
		this.answer =answ;
		this.tree = tree; 
	}	
	public function toHtmlString () { 
		var str = "<br/>";
		str+="answer="+this.answer+"<br/>";
		if (this.tree!=null) str+="tree=<br/>"+this.tree.toHtmlString();
		return str;
	}
	
}

/**
* Read a Json file and dispatch an event with resulting Object.
*/
class JsonLoader  {
	/**
	 * event dispatcher when server answers
	 * WARNING: after read.dispatch(JsonLoaderEvent)
	 * 			all listeners are removed : read.off() is executed.
	 * 			For one JsonLoader instance one or many listener(s) may exist but requests must be sequential.
	 */
	/**
	 * dispatch event when json file is loaded
	 */
	public var read(default, null):EventSource;
	/**
	 * Object resulting of Json file parsing
	 */
	public var tree(default,null):Object;
	//
	public var answer:String;  // facultative
	//
	var httpRequest:Http;
	var fileUrl:String;
	//
	/**
	 * constructor
	 * @param	su server program url
	 */
	public function new () {
		read = new EventSource(); 
    }
	
	/**
	 * Main method to send server request
	 * @param	?o		vars to send
	 * @param	?type	request types : standard, writeDay or writeMonth
	 */
	public function load (?fu:String):JsonLoader  {
		fileUrl = (fu != null)?fu:(fileUrl!=null)?fileUrl:"f::File url must be given !!".trace();
		httpRequest = new Http(fileUrl);
		httpRequest.onData = onJsonLoaderData;
		httpRequest.onError = onJsonLoaderError;
		httpRequest.request();
		return this;
	}		
    /**
    *@private
    */
	function onJsonLoaderData (?result:String)  {		
		var o:Object;
		if (result.substr(0, 6) == "answer") {
			o = httpRequest.getParameter(result);		
			answer = o.answer;
			result = o.data;
		}
		else {
			answer = null;
		}
		tree = new Object(Json.parse(result));
		var e = new JsonLoaderEvent(this,tree,answer);
		read.dispatch(e);
	}
	function onJsonLoaderError (?msg:String)  {		
		answer = "error";
		tree = new Object( { message:msg } );
		var e = new JsonLoaderEvent(this,tree,answer);
		read.dispatch(e);
	}
	//
	//	get/set
	//
	
}
