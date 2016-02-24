/*
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
package apix.common.tools.math ;
/**
 * glossary:
 * hypo ~ diagonal ~ radius
 * width ~ x ~ cos ~ cosinus
 * height ~ y ~ sin ~ sinus
 */
class Trigo  { 		
	private var _vector:Vector;
	private var _alpha:Float;
	/**
	 * angle in degree
	 */
	public var alpha(get_alpha,set_alpha):Float;
	/**
	 * alias of cos
	 */
	public var x(get_x,null):Float;
	/**
	 * alias of sin
	 */
	public var y(get_y,null):Float;
	/**
	* cos (x for hypo=1)
	*/
	public var cos(get_x,null):Float;
	/**
	* sin (y for hypo=1)
	*/
	public var sin(get_y,null):Float;
	/**
	* (x,y) or (cos,sin) vector
	*/
	public var vector(get_vector,null):Vector;
	/**
	* angle in % (45°==100%)
	*/	
	public var toPercent(get_toPercent,null):Float;
	/**
	* constructor
	* <br/><b>a</b> angle in degree
	*/	
	public function new  (?a:Float=45.00) {		
		alpha = a;
	}	
	//static public	
	/**
	* new Trigo
	* <br/><b>a</b> angle in degree
	*/
	public static function trigoFromDegree (a:Float) :Trigo {
		return new Trigo(a);
	}
	/**
	* new Trigo
	* <br/><b>n</b> n%
	*/
	public static function trigoFromPercent (n:Float) :Trigo {
		var radian:Float = Math.atan(n / 100);
		var degree:Float = radian * 180 / Math.PI ; 
		return new Trigo(degree);
	}
	/**
	* new Trigo
	* <br/><b>w</b> width
	* <br/><b>h</b> height
	*/
	public static function trigoFromWidthAndHeight (w:Float,h:Float) :Trigo {			
		var radian:Float = Math.atan(h / w);
		var degree:Float = radian * 180 / Math.PI ; 
		return new Trigo(degree);
	}
	//public					
	/**
	* <b>n</b> height
	* <br/><b>return</b> width
	*/
	public function widthFromHeight (n:Float) :Float {			
		return x * n / y;
	}
	/**
	* <b>n</b> hypotenuse
	* <br/><b>return</b> width
	*/
	public function widthFromHypo (n:Float) :Float {			
		return x * n ;
	}
	/**
	* <b>n</b> width
	* <br/><b>return</b> height
	*/
	public function heightFromWidth (n:Float) :Float {			
		return y * n / x ;
	}
	/**
	* <b>n</b> hypotenuse
	* <br/><b>return</b> height
	*/
	public function heightFromHypo (n:Float) :Float {			
		return y * n ;
	}
	/**
	* <b>n</b> width
	* <br/><b>return</b> hypotenuse
	*/
	public function hypoFromWidth (n:Float) :Float {			
		return n / x;
	}
	/**
	* <b>n</b> height
	* <br/><b>return</b> hypotenuse
	*/
	public function hypoFromHeight (n:Float) :Float {			
		return n / y;
	}
	//private get/set
	function set_alpha (a:Float) :Float {
		_alpha = a;
		var radian:Float = alpha * Math.PI / 180;		
		_vector = new Vector(Math.cos(radian), Math.sin(radian)) ;
		return a ;
	}
	function get_alpha () :Float {
		return _alpha ;
	}
	function get_vector () :Vector {
		return _vector ;
	}
	
	function get_x () : Float {			
		return vector.x ;
	}
	function get_y () :Float {			
		return vector.y;
	}
	function get_toPercent () :Float {			
		return MathX.round(heightFromWidth(100),2);
	}
	
}