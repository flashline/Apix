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
package apix.common.event.timing;
import apix.common.event.StandardEvent.MouseTouchEvent;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.common.tools.math.Vector;
#if (js)
	using apix.common.display.ElementExtender;
#end
/**
 * 
 */
class MouseClock   {
	var g:Global;
	var onMouseMove:Dynamic;
	var onMouseUp:Dynamic;
	public var x(default,null):Float;
	public var y(default, null):Float;
	//
			var _vector				:Vector;
	public 	var  vector(get, null)	:Vector;
	public 	var  absx(get, null)	:Float;
	public 	var  absy(get, null)	:Float;
	//
	var sx(default,null):Float;
	var sy(default, null):Float;
	//
	public var top(default,null):EventSource ;
	/**
	* Constructor
	* <br/><b>omm</b> callback func 
	* <br/><b>per</b> period in sec.
	*/
    public function new ( omm:Dynamic, ?omu:Dynamic) {	
		g = Global.get();
		onMouseMove = omm;
		onMouseUp = omu;
		Common.document.addEventListener(StandardEvent.MOUSE_MOVE, clockRun); 
		if (onMouseUp != null) {			
			Common.document.addEventListener(StandardEvent.MOUSE_UP, clockStop);	
		}
		top = new EventSource();
	}
	/**
	 * 
	 * <br/><b></b>	
	 */
	/**
	 * getter/setter
	 */

	/**
	 * public
	 */	
	
	public function remove () : Dynamic {
		Common.document.removeEventListener(StandardEvent.MOUSE_UP, clockStop);
		Common.document.removeEventListener(StandardEvent.MOUSE_MOVE, clockRun); 
		onMouseMove = null;
		top.off();
		return null;
	}
	public function toString() :String {
		var str = "";
		str += "rel x="+x+" / " ;			
		str += "abs x="+absx+" / " ;			
		str += "rel y="+y+" / " ;			
		str += "abs y="+absy+" / " ;			
						
		return str;
    }
	/**
	 * private
	 */
	function clockRun (e:MouseTouchEvent) {
		e.preventDefault(); untyped __js__("if (e.preventManipulation) e.preventManipulation()");
		//var ex:Float = g.isMobile?e.changedTouches[0].pageX:e.clientX;
		//var ey:Float = g.isMobile?e.changedTouches[0].pageY:e.clientY;
		var v = MouseTouchEvent.getVector(e);
		var ex = v.x;
		var ey = v.y;
		//trace("move e.pointerId="+(untyped e.pointerId));
		
		//		
		if (sx == null) sx = ex;
		if (sy == null) sy = ey;
		x=ex-sx ; 
		//offsetX=e.offsetX ;
		y=ey-sy ; 
		//offsetY=e.offsetY ; 
		onMouseMove(this) ;
		top.dispatch(new StandardEvent(this));
	}
	function clockStop (e:ElemMouseEvent) {
		e.preventDefault();	untyped __js__("if (e.preventManipulation) e.preventManipulation()");
		if (onMouseUp != null) onMouseUp(this);
	}
	function get_vector () : Vector { 
		if (_vector == null) _vector = new Vector(x,y);
		else { _vector.x = x; _vector.y = y; }
		return _vector;
	}
	function get_absx () : Float { 
		if (x != null && sx != null) return x + sx;
		else return null;
	}
	function get_absy () : Float { 
		if (y != null && sy != null) return y + sy;
		else return null;
	}
}