package apix.ui.tools;
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
//
class ServerEvent  {
	public var answer:String;
	public var data:Object;
	public var target:Server;	
	public function new (trgt:Server, ?answ:String, ?dat:Object) { 
		this.target = trgt;
		this.answer =answ;
		this.data = dat; 
	}	
	public function toHtmlString () { 
		var str = "<br/>";
		str+="answer="+this.answer+"<br/>";
		if (this.data!=null) str+="data=<br/>"+this.data.toHtmlString();
		return str;
	}
}
/**
* Manage request/answer exchange with server program
* 2 vars are used : "request" or "answer" which contain keyword
* followed by 1 var data which contains Json format
*/
class Server  {
	/**
	 * event dispatcher when server answers
	 * WARNING: after answerReceived.dispatch(ServerEvent)
	 * 			all listeners are removed : answerReceived.off() is executed.
	 * 			For one Server instance one or many listener(s) may exist but requests must be sequential.
	 */
	public var answerReceived(default,null):EventSource;
	//
	var httpRequest(default,null):Http;
	var serverUrl:String;
	//
	/**
	 * constructor
	 * @param	su server program url
	 */
	public function new (su:String) {
		answerReceived = new EventSource(); 
		serverUrl = su;
    }
	 /**
	 * Create http request
	 */
   function initServer () {
		if (httpRequest == null) {
			httpRequest = new Http(serverUrl);
		}		
	}  	
	/**
	 * Main method to send server request
	 * @param	?o		vars to send
	 * @param	?type	request types : standard, writeDay or writeMonth
	 */
	public function query (request:String,?o:Dynamic=null)  {
		initServer(); 
		httpRequest.onData = onServerData;
		httpRequest.onError = onServerError;
		httpRequest.setParameter("request", request ) ;
		if (o!=null) {
			var strData = Json.stringify(o);
			httpRequest.setParameter("data",strData ) ;
		}		
		httpRequest.request(true);
	}		
    /**
    *@private
    */
	//
	// server return listeners
	//
	function onServerData (result:String)  {		
		var o:Object = httpRequest.getParameter(StringTools.trim(result));
		var e:ServerEvent = new ServerEvent(this);
		e.answer = o.answer;		
		if (o.data != null) {			
			e.data = new Object(Json.parse(o.data));
		}		
		if (answerReceived.hasListener()) {
			answerReceived.dispatch(e);
			answerReceived.off();
		}
	}	
	function onServerError (msg:String) {	
		if (answerReceived.hasListener()) {			
			answerReceived.dispatch(new ServerEvent(this, "error" , new Object( { code:"serverFatalError", message:msg } ) ));
			answerReceived.off();
		}		
		else trace("f::From server:\n" + msg);
	}
	//
	//	get/set
	//
	
}
