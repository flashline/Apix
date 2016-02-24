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
import apix.common.util.Object;
//
typedef ObjectOfArray = { 
	public var object :Dynamic; 	
	public var index : Int; 
}
/**
 * extends Array usage in caller : import net.flash_line.util.ArrayExtender ; using net.flash_line.display.ArrayExtender;
 */
class ArrayExtender  {
	public static function last (arr:Array<Dynamic>):Dynamic {
		if (arr.length < 1) return null;
		else return arr[arr.length-1];
	}
	public static function toHtmlString (arr:Array <Dynamic>,?tab:String=""):String {
		var str:String = tab + "["; var tabType = "..."; var i = 0;
		var len = arr.length;
		for ( v in arr) {			
			if (Std.is(v, Array)) str += "<br/>" + toHtmlString(v, tab + tabType);
			else if (Std.is(v, Object)) str += "<br/>" + v.toHtmlString(tab + tabType);
			else if (Std.is(v, String)) str += '"'+v+'"';
			else str += v;
			if (i < len - 1) str += ",";
			else str += "<br/>";
			i++;
		}
		str += tab + "]";
		return str;
	}
	/**
	* If Array contains dynamic or typedef objects with a  property prop  then return object with the prop value == val + its index
	* <br/><b>key</b> 	property.
	* <br/><b>val</b>	value of property
	* <br/><b>return</b> the first object of Array which has its property prop equal to val + its index
	*/
	public static function objectOf (arr:Array <Dynamic> , val:Dynamic , ?key:String="id" ) :ObjectOfArray {
		var ret:ObjectOfArray = {object:{},index:null}; var i = -1;
		for (o in arr) {
			i++;
			if (Reflect.field(o, key ) == val) {
				ret = { object:o, index:i };
				break;
			}
		}		
		return ret;
	}
	/**
	* run f on each element of array
			
	public function forEach(array:Array<Dynamic> , ?f:Dynamic) : Array<Dynamic> {	
		for (e in array) f(e);
		return array ;
	}
	*/
	/**
	* pop array and exec clear() method of each element 
	* <br/>	f : Function in to be launched instead of clear()
	*/		
	public static function clear(array:Array <Dynamic> , ?f:String) : Dynamic {	
		var o:Dynamic;
		while ( o = array.pop() ) {
			if (f == null) {
				if (o.clear != null) o.clear(); 
			} else {
				Reflect.field(o, f)();
			}
		}	
		return null ;
	}
	public static function forEach (array:Array <Dynamic>, f:Dynamic,?dataParams:Dynamic ) {
		for (o in array) {
			f(o,dataParams);
		}		
	}
	/**
	* 
	*/		
	public static function isEnum(array:Array<String>, v:String) : Bool {	
		var match = false; for (i in array) if (i == v) { match = true;  break; } return match;		
	}
}
 