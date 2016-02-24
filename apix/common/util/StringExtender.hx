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
package apix.common.util ;
import apix.common.display.Common;
//import js.Browser;
import js.html.Element;
import js.html.NodeList;
using apix.common.display.ElementExtender;
/**
 * extends String usage in caller : using apix.common.util.StringExtender;
 */
class StringExtender  {
	static public var rootHtmlElement:Element;
	/**
	 * Add listener on one or many Element
	 * @param	v					css syntax targeting event source(s)
	 * @param	type				event type
	 * @param	listenerFunction	listener
	 * @param	?b					use capture true/false
	 * @param	?data				facultative params to listenerFunction
	 * @param	?parent				event source(s) parent
	 */	 
	public static function on (v:String,type:String, listenerFunction:Dynamic, ?b:Bool = false, ?data:Dynamic = null,?parent:Element=null) {
		var arr:Array<Element>;	
		arr = all (v, parent);	
		for (el in arr) {
			el.on(type, listenerFunction, b, data); 
		}
	}
	/**Remove listener from one or many Element
	 * @param	v					css syntax targeting event source(s)
	 * @param	type				event type
	 * @param	listenerFunction	listener
	 * @param	?b					use capture true/false
	 * @param	?parent				event source(s) parent
	 */
	public static function off (v:String,type:String, listenerFunction:Dynamic, ?b:Bool = false,?parent:Element=null) {
		var arr:Array<Element>;
		arr = all (v, parent);	
		for (el in arr) {
			el.off(type, listenerFunction, b);
		}
	}
	/**
	 * @param	v					css syntax targeting event source (unique)
	 * @param	?type				event type
	 * @param	listenerFunction	listener
	 * @return  true if at least one listener exists on event source
	 */
    public static function hasLst (v:String, ?type:String, ?listenerFunction:Dynamic,?parent:Element=null) : Bool {	
		var arr:Array<Element> = all (v, parent);
		if (arr.length < 1) trace ("f::The string '"+v+"' doesn't target any existing element !"); 
		return arr[0].hasLst(type,listenerFunction);
		
	}	
	/**
	* run f() function on each Element of given array
	*/		
	public static function each(v:String, ?f:Element->Void , ?parent:Element=null) : Array<Element> {	
		var arr:Array<Element> = all (v, parent);	
		for (el in arr) f(el);
		return arr ;
	}
	public static function all (v:String, ?parent = null) :Array<Element> {
		if (rootHtmlElement == null) rootHtmlElement = Common.body ; // Browser.document.body;
		if (parent == null) parent = rootHtmlElement;	
		return untyped parent.querySelectorAll(v);	
	}
	public static function get (v:String,?parent:Element=null):Element{
		if (rootHtmlElement == null) rootHtmlElement = Common.body ; // Browser.document.body;
		if (parent == null) parent = rootHtmlElement;		
		return untyped parent.querySelector(v);	
	}
	public static function getIfChild (v:String,?el:Element=null):Element{
		var c:Elem=get(v, Common.body);
		return  (c != null && c.parent() == el )?c:null;
	}
	public static function createElem (v:String):Element {		
		return Common.document.createElement(v);	
	}	
	public static function toDecimal(v:String, ?d:Int=2):String {
		var n = Std.parseFloat(v);
		var mul= Math.pow(10, d);
		var str=Std.string(mul + (Math.floor(n * mul) % mul));
		return Std.string(Math.floor(n))+"."+str.substr(1, d);	
	}
	
	public static function replaceOnce (str:String,from:String,to:String ) :String {
		var p = str.indexOf(from); var v = str;
		if (p != -1) {
			v=str.substr(0, p) + to + str.substr(p+(from.length));
		}
		return v;
	}
	/** 
	 * @param	from
	 * @param	to
	 * @return  modified string where each [to] is replaced by [from] 
	 */
	public inline static function replace (v:String, from:String, to:String ) :String {
		var reg = untyped __js__ ("new RegExp('('+from+')', 'g');");
		v = untyped __js__ ("v.replace(reg,to);");
		return v;
	}
	public  static function arrayReplace (v:String, from:Array<String>, to:Array<String> ) :String {	
		var len = from.length;
		for (i in 0...len) {
			v = replace ( v, from[i], to[i] );
		}
		return v ; 
	}
	public inline static function jsonEncode (v:String) :String {	
		return arrayReplace(v, ['"', '&', '='], ['£quo;', '£amp;', '£equ;']);
	}
	public inline static function jsonDecode (v:String) :String {	
		return arrayReplace(v, ['£quo;', '£amp;', '£equ;'], ['"', '&', '=']);
	}
	/**
	 * @param	v	date format yyyy/mm/dd or yyyy-mm-dd etc
	 * @return "" if is a valid date or error msg
	 */
	public static function isDate (v:String) : String {
		var msg = "";
		if (v.length != 10) msg = "invalid date format yyyy-mm-dd";
		else { 
			var yy = Std.parseInt(v.substr(0,4));var mm = Std.parseInt(v.substr(5,2));var dd = Std.parseInt(v.substr(8,2));
			if (yy < 1000 || yy > 9999) msg = "invalid year "+yy;
			else if (mm < 1 || mm > 12) msg = "invalid month "+mm;
			else if (dd < 1 || dd > maxDayIn(mm,(new Date(yy,1,29,0,0,0).getDay() != new Date(yy,2,1,0,0,0).getDay()))) msg= "invalid day "+dd+" for month="+mm+" and year="+yy;
		}
		return msg;
	}	
	/**
	 * @return true if it's a valid mail
	 */
	public inline static function isMail (v:String) : Bool {
		var r:EReg = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?/i;
		return r.match(v);		
    }
	public inline static function unspaced (v:String):String {
		return  (v==null)?"":StringTools.rtrim(StringTools.ltrim(v));
	}		
	public static inline function alert (s:String, ?cb:Dynamic = null, ?title:String = null) {
	//	js.Lib.alert(s );
		Global.get().alert(s, cb, title );
	}
	public static inline function trace (s:String,?v:Dynamic) : String {
		if (v!=null) s += "="+v.toString();
		trace(s);
		return "";
	}
	//
	//
	// private
	inline static function maxDayIn (m:Int,?leap:Bool=false) : Int {
		if (m < 1 || m > 12) { trace ("f::Month must be from 1 to 12 !"); }	
		var v = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1] ;
		if (m == 2 && leap) v++;
		return v;
	}
	//
}
 