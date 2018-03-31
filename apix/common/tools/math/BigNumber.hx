/**
 * Haxe extern of https://github.com/MikeMcl/bignumber.js
 */
//
package apix.common.tools.math ;
//
/*
 * usage :
	 * var a=new BigNumber(123); var b=new BigNumber(45);
	 * trace("res="+a.pow(b)); 
	 * // res=11110408185131956285910790587176451918559153212268021823629073199866111001242743283966127048043
*/
//
typedef ConfigObject = {
	?POW_PRECISION: Int,
	?DECIMAL_PLACES: Int,
	?EXPONENTIAL_AT: Float
}
//
@:native("BigNumber")
extern class BigNumber {
	public function new (v:Dynamic) ;
	//
	public function toNumber() : Int ;
	public function div(v:Float) :  BigNumber;
	//
	@:overload(function(v:BigNumber):BigNumber{})
	public function add(v:Float) :  BigNumber;
	//
	@:overload(function(v:BigNumber):BigNumber{})
	public function equals(v:Float) :  Bool;
	//
	@:overload(function(v:BigNumber):BigNumber{})
	public function minus(v:Float) :  BigNumber;
	//
	@:overload(function(v:BigNumber):BigNumber{})
	public function times(v:Float) :  BigNumber;
	//
	@:overload(function(v:BigNumber):BigNumber{})
	public function dividedBy (v:Float) :  BigNumber;
	//
	public function dividedToIntegerBy (v:Int) :  BigNumber;
	public function truncated() :  BigNumber;
	public function toFixed() : String ;
	public static function config ( o : ConfigObject ) : BigNumber;
	//
	@:overload(function(v:BigNumber):BigNumber{})
	public function pow ( v : Int, ?m:Float ) : BigNumber;
	//
	public function sqrt (  ) : BigNumber;
	
}


	
	
	