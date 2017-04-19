package apix.ui.tools;
//
import apix.common.event.EventSource;
import apix.common.event.StandardEvent;
import apix.common.util.Global;
import apix.common.display.Common;
import apix.common.util.Object;
import apix.ui.tools.Server;
import apix.ui.UICompo;
import haxe.Http;

//using
using apix.common.util.StringExtender;
#if js
	using apix.common.display.ElementExtender;
#end
//
typedef LoggerProp = { 
	>CompoProp,
	?userId:String,
	?pwd:String,
	?company:String,
	?labelSignIn:String,
	?labelSignUp:String,
	?callBack:LoggerEvent -> Void,
	?serverUrl:String,
	?serverAck:String,
}
class LoggerEvent {
	public var target:Logger;
	public var userId:String;
	public var profile:String;
	public var company:String;
	public var logged:Bool;
	public var status:String; // signIn or signUp or sessionOpen or signOut
	public function new (target:Logger,userId:String, profile:String,company:String,logged:Bool,status:String ) { 
		this.target = target; 
		this.userId = userId; 
		this.profile = profile; 
		this.company = company;
		this.logged = logged;
		this.status = status;
	}	
}
//
/**
 * In properties
 * @param  	skinPath	skin path
 * @param	color		css color
 * @param	bgColor		css background-color
 * 
 */
//
class Logger extends UICompo {
	static public inline var LABEL_CLASS :String = UICompo.APIX_PRFX+"label" ;
	static public inline var SIGN_IN_CLASS :String = UICompo.APIX_PRFX+"signIn" ;
	static public inline var SIGN_UP_CLASS :String = UICompo.APIX_PRFX+"signUp" ;
	static public inline var MESSAGE_CLASS :String = UICompo.APIX_PRFX+"message" ;
	static public inline var CANCEL_CLASS :String = UICompo.APIX_PRFX+"cancel" ;
	static public inline var VALID_CLASS :String = UICompo.APIX_PRFX+"enter" ;
	static public inline var GO_SIGN_IN_CLASS :String = UICompo.APIX_PRFX+"goSignIn" ;
	static public inline var GO_SIGN_UP_CLASS :String = UICompo.APIX_PRFX+"goSignUp" ;
	static public inline var MIN_PWD_LEN :Int = 6 ;
	static public inline var MIN_SOC_LEN :Int = 3 ;
	//
	public var callBack(get, null):Dynamic;
	public var end	(default, null):EventSource ;	
	public var server(get, never) :Server; var _server:Server;
	public var serverUrl(get, never) :String; 
	public var labelSignIn(get, never) :String;
	public var labelSignUp(get, never) :String;
	public var userId(get, never) :String;
	public var pwd(get, never) :String;
	public var company(get, never) :String;
	//
	var buttons:EventSource;
	var popBox:PopBox;
	var signInElement		(default,null) : Elem ;       
	var signUpElement		(default,null) : Elem ;       
	var messageElement		(default,null) : Elem ;        
	var signInLabelElement	(default,null) : Elem ;        
	var signUpLabelElement	(default,null) : Elem ;         
	var bSignInValid		(default,null) : Elem ;        
	var bSignInCancel		(default,null) : Elem ;         
	var bSignUpValid		(default,null) : Elem ;         
	var bSignUpCancel		(default,null) : Elem ;        
	var bGoSignUp			(default,null) : Elem ;        
	var bGoSignIn			(default, null) : Elem ;      
	//
	var signInUserIdElement	(default,null) : Elem ;                        
	var signInPwdElement	(default,null) : Elem ;                       
	var signUpUserIdElement	(default,null) : Elem ;                        
	var signUpPwdElement	(default,null) : Elem ;                       
	var signUpPwd2Element	(default,null) : Elem ;                       
	var signUpSocElement	(default, null) : Elem ;  
	//
	var logUserId:String;
	var logCompany:String;
	var logProfile:String;
	var logLogged:Bool;
	var logStatus:String;
		/**
	* constructor
	* @param ?p LoggerProp
	*/
	public function new (?p:LoggerProp) {	
		Logger._this = this;
		buttons = new EventSource();
		end 	= new EventSource();
		super(); 					
		compoSkinList = LoggerLoader.__compoSkinList;		
		setCompoProp(p);		
	}
	static var _this:Logger;
	public static function get () {	
		if (Logger._this == null) trace("f::New Logger() must be done before using Logger.get() ! ");		
		return _this;
	}	
	/**
	 * set component properties  -can be called several time  
	 * @param ?p TextFieldProp
	 * @return this
	 */
	override public function setup (?p:LoggerProp) :Logger {	
		setCompoProp(p);
		return this;
	}
	public function start (?p:LoggerProp) :Logger {	
		setCompoProp(p);
		if (labelSignIn == "" || labelSignUp == "" || callBack == null || serverUrl == "") trace("f::labelSignIn or labelSignUp or callBack or serverUrl properties are missing ! ");
		askIsSessionOpen ();	
		return this;
	}
	public function signOut (?p:LoggerProp) :Logger {	
		setCompoProp(p);
		askSignOut ();	
		return this;
	}
	
	// 	
	/**
	 * private  
	 */	
	
	
	function createServer (su:String) {
		if (g.strVal(su, "") == "") trace("f::Server url is missing !!");
		return new Server(su);
	}	
	/**
	 * create in a PopBox and set it as parent ctnr.
	 * enable and update will be called
	 */
	override function create () : Logger {		
		super.create();
		popBox = new PopBox().create({backgroundColor:"rgba(255,255,255,.88)"});
		popBox.addChild(element);
		setup( { into:"#" + popBox.id } );
		enable();
		update();
		return this;
	}
	/**
	 * active compo one time
	 * @return this
	 */
	override public function enable ()   : Logger {			
		signInElement 		= ("#" + id + " ." + Logger.SIGN_IN_CLASS).get() ;
		signUpElement 		= ("#" + id + " ." + Logger.SIGN_UP_CLASS).get() ;
		messageElement 		= ("#" + id + " ." + Logger.MESSAGE_CLASS).get() ;
		signInLabelElement 	= ("#" + id + " ." + Logger.SIGN_IN_CLASS+" ." + Logger.LABEL_CLASS).get() ;
		signUpLabelElement 	= ("#" + id + " ." + Logger.SIGN_UP_CLASS+" ." + Logger.LABEL_CLASS).get();
		bSignInValid		= ("#" + id + " ." + Logger.SIGN_IN_CLASS+" ." + Logger.VALID_CLASS).get() ;
		bSignInCancel		= ("#" + id + " ." + Logger.SIGN_IN_CLASS+" ." + Logger.CANCEL_CLASS).get() ;
		bSignUpValid		= ("#" + id + " ." + Logger.SIGN_UP_CLASS+" ." + Logger.VALID_CLASS).get() ;
		bSignUpCancel		= ("#" + id + " ." + Logger.SIGN_UP_CLASS+" ." + Logger.CANCEL_CLASS).get() ;
		bGoSignUp			= ("#" + id + " ." + Logger.SIGN_IN_CLASS+" ." + Logger.GO_SIGN_UP_CLASS).get() ;
		bGoSignIn			= ("#" + id + " ." + Logger.SIGN_UP_CLASS + " ." + Logger.GO_SIGN_IN_CLASS).get() ;
		
		signInUserIdElement	= ("#" + id + " ." + Logger.SIGN_IN_CLASS + " input[name='userId']").get();
		
		signInPwdElement	= ("#" + id + " ." + Logger.SIGN_IN_CLASS + " input[name='pwd']").get();
		signUpUserIdElement	= ("#" + id + " ." + Logger.SIGN_UP_CLASS + " input[name='userId']").get();
		signUpPwdElement	= ("#" + id + " ." + Logger.SIGN_UP_CLASS + " input[name='pwd']").get();
		signUpPwd2Element	= ("#" + id + " ." + Logger.SIGN_UP_CLASS + " input[name='pwdConfirm']").get();
		signUpSocElement	= ("#" + id + " ." + Logger.SIGN_UP_CLASS + " input[name='company']").get();
		//
		signInElement.hide();
		signUpElement.hide();
		messageElement.hide();
		//
		super.update();
		signInLabelElement.text(labelSignIn);
		signUpLabelElement.text(labelSignUp);
		//
		enabled = true;	
		return this;
	}
	
	// server exchanges
	function askIsSessionOpen () {
		server.answerReceived.on(onAnswerIsSessionOpen);
		server.query("isSessionOpen");
	}
	function onAnswerIsSessionOpen (se:ServerEvent) { 
		if (se.answer == "yes") {
			//setCompoProp({userId:se.data.userId,company:se.data.company});
			logUserId = se.data.userId; 
			logProfile = se.data.profile; 
			logCompany = se.data.company;
			logLogged = true ;
			logStatus = "sessionOpen";
			finishLogging();
		} 
		else if (se.answer == "no") {
			//setCompoProp({userId:"",company:""});
			if (!isCreated()) create();			
			doSignIn();			
		} else {
			se.answer = "error";
			showServerError(se); //unknownServerError 
		}
	}
	function askSignIn (ui:String,pw:String) {
		server.answerReceived.on(onAnswerSignIn);
		logUserId = ui;
		var o = {userId:ui, pwd:pw }  ;	
		server.query("askSignIn",o);
	}
	function onAnswerSignIn (se:ServerEvent) { 
		if (se.answer == "ok") {
			logProfile = se.data.profile; 
			logCompany = se.data.company; 
			logLogged = true ;
			logStatus = "signIn";		
			finishLogging();
		} 
		else {
			logUserId = null; 
			showServerError(se);
		}
	}
	function askSignUp (ui:String,pw:String,so:String) {
		server.answerReceived.on(onAnswerSignUp);
		logUserId = ui;  logCompany = so;
		var o = {userId:ui,pwd:pw,company:so }  ;	
		server.query("askSignUp",o);
	}
	function onAnswerSignUp (se:ServerEvent) { 
		if (se.answer == "ok") {
			logProfile = se.data.profile; 
			logLogged = true ;
			logStatus = "signUp";			
			finishLogging();
		} 
		else {
			logUserId = null; logCompany = "" ; 
			showServerError(se);			
		}
	}
	function askSignOut () {
		server.answerReceived.on(onAnswerSignOut);
		server.query("askSignOut");
	}
	function onAnswerSignOut (se:ServerEvent) { 
		/*if (se.answer == "yes") {
			//todo
		} 
		else { }*/		
		logStatus = "signOut";
		logout();		
	}	
	function logout() { 
		clear();
		var str:String=lang.signOutMsg.label;
		str.alert(finishLogging,lang.signOutTitle.label); 
	}
	function clear() { 
		logUserId = null; 
		logProfile = null; 
		logCompany = "";
		logLogged = false ;
	}
	function finishLogging() { 
		removeEvents();
		if (popBox!=null) popBox.close();
		if (callBack) callBack (new LoggerEvent(this,logUserId, logProfile, logCompany, logLogged, logStatus));
	}
	
	// sign in/up
	function doSignIn () {
		signInElement.show();
		signUpElement.hide();
		messageElement.hide();
		signInUserIdElement.value(userId);
		signInPwdElement.value(pwd);
		popBox.open();
		createEvents();
	}
	function doSignUp () {
		signInElement.hide();
		signUpElement.show();
		messageElement.hide();
		signUpUserIdElement.value(userId);
		signUpPwdElement.value(pwd);
		signUpPwd2Element.value("");		
		signUpSocElement.value(company);
		//popBox.open();
	}	
	// events	
	function createEvents () { 
		if (!buttons.hasListener()) {
			buttons.on(function () { } );
			//
			bSignInValid.on(StandardEvent.CLICK, onValidSignIn);
			bSignUpValid.on(StandardEvent.CLICK, onValidSignUp);
			bSignInCancel.on(StandardEvent.CLICK, onCancelSignIn);
			bSignUpCancel.on(StandardEvent.CLICK, onCancelSignUp);
			bGoSignIn.on(StandardEvent.CLICK, onGoSignIn);
			bGoSignUp.on(StandardEvent.CLICK, onGoSignUp);
		}		
	}
	function removeEvents () { 
		if (buttons.hasListener()) {
			buttons.off();
			//
			bSignInValid.off(StandardEvent.CLICK, onValidSignIn);
			bSignUpValid.off(StandardEvent.CLICK, onValidSignUp);
			bSignInCancel.off(StandardEvent.CLICK, onCancelSignIn);
			bSignUpCancel.off(StandardEvent.CLICK, onCancelSignUp);
			bGoSignIn.off(StandardEvent.CLICK, onGoSignIn);
			bGoSignUp.off(StandardEvent.CLICK, onGoSignUp);	
		}
	}
	//listeners
	function onValidSignIn (e:ElemEvent) { 	
		var str = isSignInputValid(signInUserIdElement.value(), signInPwdElement.value());	
		if (str.length > 0) showError(str);
		else {
			setCompoProp({userId:signInUserIdElement.value()});
			askSignIn(signInUserIdElement.value(), signInPwdElement.value());	
		}
	}
	function isSignInputValid (userId:String, pwd:String, ?confirm:String = null, ?soc:String = null) : String {
		var str = "";
		if (!userId.isMail()) str += lang.invalidEmail.label + "<br/>" ;
		if (Logger.MIN_PWD_LEN > pwd.length )  str += lang.pwdLen.label +Logger.MIN_PWD_LEN+ "<br/>" ;
		if (confirm != null && pwd != confirm) str += lang.confirmError.label + "<br/>" ;
		if (soc != null && Logger.MIN_SOC_LEN > soc.length) str += lang.companyLen.label+ Logger.MIN_SOC_LEN + "<br/>" ;
		if (str.length > 0) str = lang.signErrorHeader.label + "<br/>" + str ;
		//	
		return str;
	}
	function onValidSignUp (e:ElemEvent) { 
		var str = isSignInputValid(signUpUserIdElement.value(),signUpPwdElement.value(),signUpPwd2Element.value(),signUpSocElement.value());		
		if (str.length > 0) showError(str);
		else {
			setCompoProp({userId:signUpUserIdElement.value(),company:signUpSocElement.value()});
			askSignUp(signUpUserIdElement.value(),signUpPwdElement.value(),signUpSocElement.value());	
		}
	}
	function onCancelSignIn (e:ElemEvent) { 		
		logStatus = "signIn";
		clear(); finishLogging();
	}
	function  onCancelSignUp (e:ElemEvent) { 			
		logStatus = "signUp";
		clear(); finishLogging();
	}
	function onGoSignIn (e:ElemEvent) { 
		doSignIn();
	}
	function onGoSignUp (e:ElemEvent) { 
		doSignUp();
	}

	// errors display
	function showServerError (se:ServerEvent) { 
		var str = "";
		if (	se != null &&
				se.data != null &&
				se.data.code != null && 
				lang.get(se.data.code)!=null
			) {				
				str = lang.get(se.data.code).label;
				if (se.data.code == "errorFromServer") str += se.data.message ;
		}			
		else 	str = lang.unknownServerError.label;
		//
		showError(str);
	}
	function showError (str:String) { 
		messageElement.inner(str);
		messageElement.show();
	}
	function hideError () { 
		messageElement.inner("");
		messageElement.hide();
	}
	
	//get/set	
	function get_callBack () :Dynamic {
		var v:Dynamic=null;
		if (compoProp.callBack != null) v = compoProp.callBack ;
		else {			
			v = null ; 
		}
		compoProp.callBack = v;		
		return v;
	}
	function get_serverUrl () :String {
		var v:String=null;
		if (compoProp.serverUrl != null) v = compoProp.serverUrl ;
		else {			
			v = null ; 
		}
		compoProp.serverUrl = v;		
		return v;
	}
	function get_server () {
		if (_server==null) {
			if (g.strVal(serverUrl, "") == "") trace("f::ServerUrl is missing !!");
			_server = new Server(serverUrl);
		}
		return _server;
	}
	function get_labelSignIn () :String {
		var v:String="";
		if (compoProp.labelSignIn != null) v = compoProp.labelSignIn ;
		else {			
			v = label ; 
		}
		compoProp.labelSignIn = v;		
		return v;
	}
	function get_labelSignUp () :String {
		var v:String="";
		if (compoProp.labelSignUp != null) v = compoProp.labelSignUp ;
		else {			
			v = "" ; 
		}
		compoProp.labelSignUp = v;		
		return v;
	}
	override function get_label () :String {
		var v:String="";
		if (compoProp.label != null) v = compoProp.label ;
		else {			
			v = "" ; 
		}
		compoProp.label = v;		
		return v;
	}
	function get_userId () :String {
		var v:String="";
		if (compoProp.userId != null) v = compoProp.userId ;
		else {			
			v = "" ; 
		}
		compoProp.userId = v;		
		return v;
	}
	function get_pwd () :String {
		var v:String="";
		if (compoProp.pwd != null) v = compoProp.pwd ;
		else {			
			v = "" ; 
		}
		compoProp.pwd = v;		
		return v;
	}
	function get_company () :String {
		var v:String="";
		if (compoProp.company != null) v = compoProp.company ;
		else {			
			v = "" ; 
		}
		compoProp.company = v;		
		return v;
	}
	//
	//
	/**
	 * static public  
	 */
	/**
	 * load a skin.
	 * use it for each used skin ; InputFields can have same or its own skin.
	 * @param	?skinName="default" skinname
	 * @param	?pathStr skin's path from UICompoLoader.baseUrl
	 */
	public static function init (?skinName:String = "default", ?pathStr:String)  {
		LoggerLoader.__init(skinName,pathStr);
	}	
}
//

//
/**
 * static class to loadinit InputField
 */
class LoggerLoader extends UICompoLoader   { 
	static  inline 	var PATH:String = "Logger/" ;	
	//
	static public	var __compoSkinList:Array<CompoSkin> = new Array() ;
	//
	/**
	 * public static 
	 */
	static public function __init (?skinName = "default", ?pathStr:String)  {
		pathStr != null && skinName == "default" ? trace("f::Invalid skinName '" + skinName + "' when a custom path is given ! ") : true ;
		pathStr= pathStr==null ? UICompoLoader.DEFAULT_SKIN_PATH + LoggerLoader.PATH : pathStr ; 
		UICompoLoader.__push( LoggerLoader.__load,UICompoLoader.baseUrl+pathStr,skinName) ;
	}
	/**
	 * private static
	 */
	static function __load (fromPath:String,sk:String)  {
		var h:Http = new Http(fromPath + UICompoLoader.SKIN_FILE);
		h.onData = __onData;	
		h.request(false);
		UICompoLoader.__currentSkinName = sk;
		UICompoLoader.__currentFromPath = fromPath;	
	}	
	static function __onData (result:String)  {
		var skinContent=UICompoLoader.__storeData(result);		
		//
		LoggerLoader.__compoSkinList.push({skinName:UICompoLoader.__currentSkinName,skinContent:skinContent,skinPath:UICompoLoader.__currentFromPath}); 		
		UICompoLoader.__onEndLoad();		
	}
	
}
