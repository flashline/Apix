/**
 * Copyright (c) jm Delettre.
 * 
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package apix.common.event ;
import js.html.Event;
import js.html.EventListener;
import js.html.EventTarget;
/**
 * @usage : using apix.common.util.EventTargetExtender;
 */
class EventTargetExtender  {
	static var listeners:Array<Dynamic>=[];
	
	/**
	 * call examples :
	 *    view.connection.off("click",onClick,false,{param1:"param11",param2:"param12"} ); 
	 *	  view.connection.off("click", onClick, false );
	 * 	  if no parameters needs to be sent, original listener is used ; else a delegate listener is used.
	 * @param	srcEvt
	 * @param	type
	 * @param	listenerFunction
	 * @param	?b
	 * @param	?data
	 */
	public static function on(srcEvt:EventTarget, type:String, listenerFunction:Dynamic, ?b:Bool = false, ?data:Dynamic = null) {
		var deleguateFunction:EventListener = getLst(srcEvt, listenerFunction, data);
		var el:Dynamic=untyped srcEvt;if (el.listeners == null) el.listeners = [];
		el.listeners.push( {type:type, listenerFunction:listenerFunction, deleguateFunction:deleguateFunction } );		
		srcEvt.addEventListener(type, deleguateFunction, b );
	}	
	public static function off(srcEvt:EventTarget, type:String, listenerFunction:Dynamic, ?b:Bool = false)  {			
		if ( !removeDelegateListener(srcEvt, type, listenerFunction, b) ) {
			// normally no possible
			srcEvt.removeEventListener(type, listenerFunction, b);
		}		
	}	
	/**
	 * <b>returns true</b> if at least one listener exists.
	 */
    public static function  hasLst (srcEvt:EventTarget, ?type:String, ?listenerFunction:Dynamic) : Bool {	
		var el:Dynamic = untyped srcEvt;
		var ret:Bool = false;
		if (el.listeners != null) {
			var len = el.listeners.length;
			for (n in 0...len) {
				var i = el.listeners[n];				
				if (type == null) {
					ret = true; break;
				}
				else if (i.type == type) {											
					if (listenerFunction == null) ret = true;
					else if (Reflect.compareMethods(i.listenerFunction,listenerFunction) ) ret = true; 
					if (ret) break;
				}
			}	
		}
		return ret;
	}	
	//
	/**
	 * @private
	 */
	static function getLst(srcEvt,listenerFunction:Dynamic,?data:Dynamic) : EventListener {
		var deleguateFunction:EventListener;
		if (data == null) deleguateFunction = listenerFunction;
		else {			
			deleguateFunction = function (e:Event) { listenerFunction.call(srcEvt, e, data) ;  } ;				
		}
		return deleguateFunction ;
	}
	
	static function removeDelegateListener(srcEvt:Dynamic, type:String, listenerFunction:Dynamic, ?b:Bool = false) :Bool {
		var match = false;
		var el:Dynamic = untyped srcEvt;
		if (el.listeners!=null) {
			var len = el.listeners.length;
			for (n in 0...len) {
				var i = el.listeners[n];
				if (Reflect.compareMethods(i.listenerFunction,listenerFunction) ) { 
					if (i.type == type) {							
						if (i.deleguateFunction != null) {
							srcEvt.removeEventListener(type, i.deleguateFunction, b);
						}
						el.listeners.splice(n, 1);
						//removeDelegateListener(srcEvt, type, listenerFunction, b);
						match = true;
						break;
					}
				}
			}
		}
		return match;
	}
}
 