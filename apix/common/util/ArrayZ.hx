
package apix.common.util;

import apix.common.util.StepIterator;
//
/**
* classes imports
*/
using apix.common.util.StringExtender ;
/**
* Negative and positive array
* using:
	    var az = new ArrayZ();		
		az.set( -2, "-22");
		az.set(-1,"-11");
		az.set(0,"+00");
		az.set(2,"+22");
		az.push("+33");
		az.negPush("-33");
		az.forIn(
			function(v,i) {
				trace (	i + "=" + v); // v : -33,-22,-11,+00,null,+22,+33
			}
		);
		// az.length = 4 positives + abs(-3) negatives = 7
*/
class ArrayZ <T>  implements ArrayAccess<T>  { //
	/**
	 * negative lenght
	 */
	public var negLength(default, null):Int; 
	/**
	 * positive length
	 */
	public var posLength(default, null):Int; 
	/**
	 * posLength + abs(negLength)
	 */
	public var length(get, null):Int;
	/**
	 * constructor
	 */
	public function new () {	
		negLength = 0;
		posLength = 0;
	}
	/**
	 * Use this function instead of |array[n]=var;| to update negative and positive lengths.
	 * But we can use |var=array[n];| as read-only access // -infinity<n<+infinity
	 */
	public function set (i:Int,v:T) {	
		this[i] = v;
		if (i < 0) negLength = Std.int(Math.min(Std.int(negLength), Std.int(i)));
		else posLength=Std.int(Math.max(Std.int(posLength), Std.int(i+1)));
	}
	/**
	 * positive push
	 * @param	v	value pushed in array
	 */
	public function push (v:T) {	
		set(posLength, v);
	}
	/**
	 * negative push
	 * @param	v	value pushed in array
	 */
	public function negPush (v:T) {	
		set(negLength-1, v);
	}
	/**
	 * Scan array contents and execute a function
	 * one can use also : for (i in arrayZ.negLength...arrayZ.posLength) { doSomeThing() }
	 * @param	f	Function
	 * @param	s	start indice
	 * @param	e	end indice
	 */
	public function forIn(f:Dynamic, ?s:Int, ? e:Int)  {	
		s=(s == null)?negLength:s;
		e=(e == null)?posLength:e;
		for (i in new StepIterator(s,e) ) { //
			f(this[i], i);			
		}		
	} 
	/**
	 * private
	 */
	function get_length ():Int {
		return posLength + Std.int(Math.abs(1.0*negLength)); 
	}
}