/*
	Copyright (c) 2004-2006, The Dojo Foundation
	All Rights Reserved.

	Licensed under the Academic Free License version 2.1 or above OR the
	modified BSD license. For more information on Dojo licensing, see:

		http://dojotoolkit.org/community/licensing.shtml
*/

/*
	This is a compiled version of Dojo, built for deployment and not for
	development. To get an editable version, please visit:

		http://dojotoolkit.org

	for documentation and information on getting the source.
*/

if(typeof dojo=="undefined"){
var dj_global=this;
var dj_currentContext=this;
function dj_undef(_1,_2){
return (typeof (_2||dj_currentContext)[_1]=="undefined");
}
if(dj_undef("djConfig",this)){
var djConfig={};
}
if(dj_undef("dojo",this)){
var dojo={};
}
dojo.global=function(){
return dj_currentContext;
};
dojo.locale=djConfig.locale;
dojo.version={major:0,minor:0,patch:0,flag:"dev",revision:Number("$Rev: 6824 $".match(/[0-9]+/)[0]),toString:function(){
with(dojo.version){
return major+"."+minor+"."+patch+flag+" ("+revision+")";
}
}};
dojo.evalProp=function(_3,_4,_5){
if((!_4)||(!_3)){
return undefined;
}
if(!dj_undef(_3,_4)){
return _4[_3];
}
return (_5?(_4[_3]={}):undefined);
};
dojo.parseObjPath=function(_6,_7,_8){
var _9=(_7||dojo.global());
var _a=_6.split(".");
var _b=_a.pop();
for(var i=0,l=_a.length;i<l&&_9;i++){
_9=dojo.evalProp(_a[i],_9,_8);
}
return {obj:_9,prop:_b};
};
dojo.evalObjPath=function(_e,_f){
if(typeof _e!="string"){
return dojo.global();
}
if(_e.indexOf(".")==-1){
return dojo.evalProp(_e,dojo.global(),_f);
}
var ref=dojo.parseObjPath(_e,dojo.global(),_f);
if(ref){
return dojo.evalProp(ref.prop,ref.obj,_f);
}
return null;
};
dojo.errorToString=function(_11){
if(!dj_undef("message",_11)){
return _11.message;
}else{
if(!dj_undef("description",_11)){
return _11.description;
}else{
return _11;
}
}
};
dojo.raise=function(_12,_13){
if(_13){
_12=_12+": "+dojo.errorToString(_13);
}else{
_12=dojo.errorToString(_12);
}
try{
if(djConfig.isDebug){
dojo.hostenv.println("FATAL exception raised: "+_12);
}
}
catch(e){
}
throw _13||Error(_12);
};
dojo.debug=function(){
};
dojo.debugShallow=function(obj){
};
dojo.profile={start:function(){
},end:function(){
},stop:function(){
},dump:function(){
}};
function dj_eval(_15){
return dj_global.eval?dj_global.eval(_15):eval(_15);
}
dojo.unimplemented=function(_16,_17){
var _18="'"+_16+"' not implemented";
if(_17!=null){
_18+=" "+_17;
}
dojo.raise(_18);
};
dojo.deprecated=function(_19,_1a,_1b){
var _1c="DEPRECATED: "+_19;
if(_1a){
_1c+=" "+_1a;
}
if(_1b){
_1c+=" -- will be removed in version: "+_1b;
}
dojo.debug(_1c);
};
dojo.render=(function(){
function vscaffold(_1d,_1e){
var tmp={capable:false,support:{builtin:false,plugin:false},prefixes:_1d};
for(var i=0;i<_1e.length;i++){
tmp[_1e[i]]=false;
}
return tmp;
}
return {name:"",ver:dojo.version,os:{win:false,linux:false,osx:false},html:vscaffold(["html"],["ie","opera","khtml","safari","moz"]),svg:vscaffold(["svg"],["corel","adobe","batik"]),vml:vscaffold(["vml"],["ie"]),swf:vscaffold(["Swf","Flash","Mm"],["mm"]),swt:vscaffold(["Swt"],["ibm"])};
})();
dojo.hostenv=(function(){
var _21={isDebug:false,allowQueryConfig:false,baseScriptUri:"",baseRelativePath:"",libraryScriptUri:"",iePreventClobber:false,ieClobberMinimal:true,preventBackButtonFix:true,delayMozLoadingFix:false,searchIds:[],parseWidgets:true};
if(typeof djConfig=="undefined"){
djConfig=_21;
}else{
for(var _22 in _21){
if(typeof djConfig[_22]=="undefined"){
djConfig[_22]=_21[_22];
}
}
}
return {name_:"(unset)",version_:"(unset)",getName:function(){
return this.name_;
},getVersion:function(){
return this.version_;
},getText:function(uri){
dojo.unimplemented("getText","uri="+uri);
}};
})();
dojo.hostenv.getBaseScriptUri=function(){
if(djConfig.baseScriptUri.length){
return djConfig.baseScriptUri;
}
var uri=new String(djConfig.libraryScriptUri||djConfig.baseRelativePath);
if(!uri){
dojo.raise("Nothing returned by getLibraryScriptUri(): "+uri);
}
var _25=uri.lastIndexOf("/");
djConfig.baseScriptUri=djConfig.baseRelativePath;
return djConfig.baseScriptUri;
};
(function(){
var _26={pkgFileName:"__package__",loading_modules_:{},loaded_modules_:{},addedToLoadingCount:[],removedFromLoadingCount:[],inFlightCount:0,modulePrefixes_:{dojo:{name:"dojo",value:"src"}},setModulePrefix:function(_27,_28){
this.modulePrefixes_[_27]={name:_27,value:_28};
},moduleHasPrefix:function(_29){
var mp=this.modulePrefixes_;
return Boolean(mp[_29]&&mp[_29].value);
},getModulePrefix:function(_2b){
if(this.moduleHasPrefix(_2b)){
return this.modulePrefixes_[_2b].value;
}
return _2b;
},getTextStack:[],loadUriStack:[],loadedUris:[],post_load_:false,modulesLoadedListeners:[],unloadListeners:[],loadNotifying:false};
for(var _2c in _26){
dojo.hostenv[_2c]=_26[_2c];
}
})();
dojo.hostenv.loadPath=function(_2d,_2e,cb){
var uri;
if(_2d.charAt(0)=="/"||_2d.match(/^\w+:/)){
uri=_2d;
}else{
uri=this.getBaseScriptUri()+_2d;
}
if(djConfig.cacheBust&&dojo.render.html.capable){
uri+="?"+String(djConfig.cacheBust).replace(/\W+/g,"");
}
try{
return !_2e?this.loadUri(uri,cb):this.loadUriAndCheck(uri,_2e,cb);
}
catch(e){
dojo.debug(e);
return false;
}
};
dojo.hostenv.loadUri=function(uri,cb){
if(this.loadedUris[uri]){
return true;
}
var _33=this.getText(uri,null,true);
if(!_33){
return false;
}
this.loadedUris[uri]=true;
if(cb){
_33="("+_33+")";
}
var _34=dj_eval(_33);
if(cb){
cb(_34);
}
return true;
};
dojo.hostenv.loadUriAndCheck=function(uri,_36,cb){
var ok=true;
try{
ok=this.loadUri(uri,cb);
}
catch(e){
dojo.debug("failed loading ",uri," with error: ",e);
}
return Boolean(ok&&this.findModule(_36,false));
};
dojo.loaded=function(){
};
dojo.unloaded=function(){
};
dojo.hostenv.loaded=function(){
this.loadNotifying=true;
this.post_load_=true;
var mll=this.modulesLoadedListeners;
for(var x=0;x<mll.length;x++){
mll[x]();
}
this.modulesLoadedListeners=[];
this.loadNotifying=false;
dojo.loaded();
};
dojo.hostenv.unloaded=function(){
var mll=this.unloadListeners;
while(mll.length){
(mll.pop())();
}
dojo.unloaded();
};
dojo.addOnLoad=function(obj,_3d){
var dh=dojo.hostenv;
if(arguments.length==1){
dh.modulesLoadedListeners.push(obj);
}else{
if(arguments.length>1){
dh.modulesLoadedListeners.push(function(){
obj[_3d]();
});
}
}
if(dh.post_load_&&dh.inFlightCount==0&&!dh.loadNotifying){
dh.callLoaded();
}
};
dojo.addOnUnload=function(obj,_40){
var dh=dojo.hostenv;
if(arguments.length==1){
dh.unloadListeners.push(obj);
}else{
if(arguments.length>1){
dh.unloadListeners.push(function(){
obj[_40]();
});
}
}
};
dojo.hostenv.modulesLoaded=function(){
if(this.post_load_){
return;
}
if(this.loadUriStack.length==0&&this.getTextStack.length==0){
if(this.inFlightCount>0){
dojo.debug("files still in flight!");
return;
}
dojo.hostenv.callLoaded();
}
};
dojo.hostenv.callLoaded=function(){
if(typeof setTimeout=="object"){
setTimeout("dojo.hostenv.loaded();",0);
}else{
dojo.hostenv.loaded();
}
};
dojo.hostenv.getModuleSymbols=function(_42){
var _43=_42.split(".");
for(var i=_43.length;i>0;i--){
var _45=_43.slice(0,i).join(".");
if((i==1)&&!this.moduleHasPrefix(_45)){
_43[0]="../"+_43[0];
}else{
var _46=this.getModulePrefix(_45);
if(_46!=_45){
_43.splice(0,i,_46);
break;
}
}
}
return _43;
};
dojo.hostenv._global_omit_module_check=false;
dojo.hostenv.loadModule=function(_47,_48,_49){
if(!_47){
return;
}
_49=this._global_omit_module_check||_49;
var _4a=this.findModule(_47,false);
if(_4a){
return _4a;
}
if(dj_undef(_47,this.loading_modules_)){
this.addedToLoadingCount.push(_47);
}
this.loading_modules_[_47]=1;
var _4b=_47.replace(/\./g,"/")+".js";
var _4c=_47.split(".");
var _4d=this.getModuleSymbols(_47);
var _4e=((_4d[0].charAt(0)!="/")&&!_4d[0].match(/^\w+:/));
var _4f=_4d[_4d.length-1];
var ok;
if(_4f=="*"){
_47=_4c.slice(0,-1).join(".");
while(_4d.length){
_4d.pop();
_4d.push(this.pkgFileName);
_4b=_4d.join("/")+".js";
if(_4e&&_4b.charAt(0)=="/"){
_4b=_4b.slice(1);
}
ok=this.loadPath(_4b,!_49?_47:null);
if(ok){
break;
}
_4d.pop();
}
}else{
_4b=_4d.join("/")+".js";
_47=_4c.join(".");
var _51=!_49?_47:null;
ok=this.loadPath(_4b,_51);
if(!ok&&!_48){
_4d.pop();
while(_4d.length){
_4b=_4d.join("/")+".js";
ok=this.loadPath(_4b,_51);
if(ok){
break;
}
_4d.pop();
_4b=_4d.join("/")+"/"+this.pkgFileName+".js";
if(_4e&&_4b.charAt(0)=="/"){
_4b=_4b.slice(1);
}
ok=this.loadPath(_4b,_51);
if(ok){
break;
}
}
}
if(!ok&&!_49){
dojo.raise("Could not load '"+_47+"'; last tried '"+_4b+"'");
}
}
if(!_49&&!this["isXDomain"]){
_4a=this.findModule(_47,false);
if(!_4a){
dojo.raise("symbol '"+_47+"' is not defined after loading '"+_4b+"'");
}
}
return _4a;
};
dojo.hostenv.startPackage=function(_52){
var _53=String(_52);
var _54=_53;
var _55=_52.split(/\./);
if(_55[_55.length-1]=="*"){
_55.pop();
_54=_55.join(".");
}
var _56=dojo.evalObjPath(_54,true);
this.loaded_modules_[_53]=_56;
this.loaded_modules_[_54]=_56;
return _56;
};
dojo.hostenv.findModule=function(_57,_58){
var lmn=String(_57);
if(this.loaded_modules_[lmn]){
return this.loaded_modules_[lmn];
}
if(_58){
dojo.raise("no loaded module named '"+_57+"'");
}
return null;
};
dojo.kwCompoundRequire=function(_5a){
var _5b=_5a["common"]||[];
var _5c=_5a[dojo.hostenv.name_]?_5b.concat(_5a[dojo.hostenv.name_]||[]):_5b.concat(_5a["default"]||[]);
for(var x=0;x<_5c.length;x++){
var _5e=_5c[x];
if(_5e.constructor==Array){
dojo.hostenv.loadModule.apply(dojo.hostenv,_5e);
}else{
dojo.hostenv.loadModule(_5e);
}
}
};
dojo.require=function(_5f){
dojo.hostenv.loadModule.apply(dojo.hostenv,arguments);
};
dojo.requireIf=function(_60,_61){
var _62=arguments[0];
if((_62===true)||(_62=="common")||(_62&&dojo.render[_62].capable)){
var _63=[];
for(var i=1;i<arguments.length;i++){
_63.push(arguments[i]);
}
dojo.require.apply(dojo,_63);
}
};
dojo.requireAfterIf=dojo.requireIf;
dojo.provide=function(_65){
return dojo.hostenv.startPackage.apply(dojo.hostenv,arguments);
};
dojo.registerModulePath=function(_66,_67){
return dojo.hostenv.setModulePrefix(_66,_67);
};
dojo.setModulePrefix=function(_68,_69){
dojo.deprecated("dojo.setModulePrefix(\""+_68+"\", \""+_69+"\")","replaced by dojo.registerModulePath","0.5");
return dojo.registerModulePath(_68,_69);
};
dojo.exists=function(obj,_6b){
var p=_6b.split(".");
for(var i=0;i<p.length;i++){
if(!obj[p[i]]){
return false;
}
obj=obj[p[i]];
}
return true;
};
dojo.hostenv.normalizeLocale=function(_6e){
var _6f=_6e?_6e.toLowerCase():dojo.locale;
if(_6f=="root"){
_6f="ROOT";
}
return _6f;
};
dojo.hostenv.searchLocalePath=function(_70,_71,_72){
_70=dojo.hostenv.normalizeLocale(_70);
var _73=_70.split("-");
var _74=[];
for(var i=_73.length;i>0;i--){
_74.push(_73.slice(0,i).join("-"));
}
_74.push(false);
if(_71){
_74.reverse();
}
for(var j=_74.length-1;j>=0;j--){
var loc=_74[j]||"ROOT";
var _78=_72(loc);
if(_78){
break;
}
}
};
dojo.hostenv.localesGenerated;
dojo.hostenv.registerNlsPrefix=function(){
dojo.registerModulePath("nls","nls");
};
dojo.hostenv.preloadLocalizations=function(){
if(dojo.hostenv.localesGenerated){
dojo.hostenv.registerNlsPrefix();
function preload(_79){
_79=dojo.hostenv.normalizeLocale(_79);
dojo.hostenv.searchLocalePath(_79,true,function(loc){
for(var i=0;i<dojo.hostenv.localesGenerated.length;i++){
if(dojo.hostenv.localesGenerated[i]==loc){
dojo["require"]("nls.dojo_"+loc);
return true;
}
}
return false;
});
}
preload();
var _7c=djConfig.extraLocale||[];
for(var i=0;i<_7c.length;i++){
preload(_7c[i]);
}
}
dojo.hostenv.preloadLocalizations=function(){
};
};
dojo.requireLocalization=function(_7e,_7f,_80,_81){
dojo.hostenv.preloadLocalizations();
var _82=dojo.hostenv.normalizeLocale(_80);
var _83=[_7e,"nls",_7f].join(".");
var _84="";
if(_81){
var _85=_81.split(",");
for(var i=0;i<_85.length;i++){
if(_82.indexOf(_85[i])==0){
if(_85[i].length>_84.length){
_84=_85[i];
}
}
}
if(!_84){
_84="ROOT";
}
}
var _87=_81?_84:_82;
var _88=dojo.hostenv.findModule(_83);
var _89=null;
if(_88){
if(djConfig.localizationComplete&&_88._built){
return;
}
var _8a=_87.replace("-","_");
var _8b=_83+"."+_8a;
_89=dojo.hostenv.findModule(_8b);
}
if(!_89){
_88=dojo.hostenv.startPackage(_83);
var _8c=dojo.hostenv.getModuleSymbols(_7e);
var _8d=_8c.concat("nls").join("/");
var _8e;
dojo.hostenv.searchLocalePath(_87,_81,function(loc){
var _90=loc.replace("-","_");
var _91=_83+"."+_90;
var _92=false;
if(!dojo.hostenv.findModule(_91)){
dojo.hostenv.startPackage(_91);
var _93=[_8d];
if(loc!="ROOT"){
_93.push(loc);
}
_93.push(_7f);
var _94=_93.join("/")+".js";
_92=dojo.hostenv.loadPath(_94,null,function(_95){
var _96=function(){
};
_96.prototype=_8e;
_88[_90]=new _96();
for(var j in _95){
_88[_90][j]=_95[j];
}
});
}else{
_92=true;
}
if(_92&&_88[_90]){
_8e=_88[_90];
}else{
_88[_90]=_8e;
}
if(_81){
return true;
}
});
}
if(_81&&_82!=_84){
_88[_82.replace("-","_")]=_88[_84.replace("-","_")];
}
};
(function(){
var _98=djConfig.extraLocale;
if(_98){
if(!_98 instanceof Array){
_98=[_98];
}
var req=dojo.requireLocalization;
dojo.requireLocalization=function(m,b,_9c,_9d){
req(m,b,_9c,_9d);
if(_9c){
return;
}
for(var i=0;i<_98.length;i++){
req(m,b,_98[i],_9d);
}
};
}
})();
}
if(typeof window!="undefined"){
(function(){
if(djConfig.allowQueryConfig){
var _9f=document.location.toString();
var _a0=_9f.split("?",2);
if(_a0.length>1){
var _a1=_a0[1];
var _a2=_a1.split("&");
for(var x in _a2){
var sp=_a2[x].split("=");
if((sp[0].length>9)&&(sp[0].substr(0,9)=="djConfig.")){
var opt=sp[0].substr(9);
try{
djConfig[opt]=eval(sp[1]);
}
catch(e){
djConfig[opt]=sp[1];
}
}
}
}
}
if(((djConfig["baseScriptUri"]=="")||(djConfig["baseRelativePath"]==""))&&(document&&document.getElementsByTagName)){
var _a6=document.getElementsByTagName("script");
var _a7=/(__package__|dojo|bootstrap1)\.js([\?\.]|$)/i;
for(var i=0;i<_a6.length;i++){
var src=_a6[i].getAttribute("src");
if(!src){
continue;
}
var m=src.match(_a7);
if(m){
var _ab=src.substring(0,m.index);
if(src.indexOf("bootstrap1")>-1){
_ab+="../";
}
if(!this["djConfig"]){
djConfig={};
}
if(djConfig["baseScriptUri"]==""){
djConfig["baseScriptUri"]=_ab;
}
if(djConfig["baseRelativePath"]==""){
djConfig["baseRelativePath"]=_ab;
}
break;
}
}
}
var dr=dojo.render;
var drh=dojo.render.html;
var drs=dojo.render.svg;
var dua=(drh.UA=navigator.userAgent);
var dav=(drh.AV=navigator.appVersion);
var t=true;
var f=false;
drh.capable=t;
drh.support.builtin=t;
dr.ver=parseFloat(drh.AV);
dr.os.mac=dav.indexOf("Macintosh")>=0;
dr.os.win=dav.indexOf("Windows")>=0;
dr.os.linux=dav.indexOf("X11")>=0;
drh.opera=dua.indexOf("Opera")>=0;
drh.khtml=(dav.indexOf("Konqueror")>=0)||(dav.indexOf("Safari")>=0);
drh.safari=dav.indexOf("Safari")>=0;
var _b3=dua.indexOf("Gecko");
drh.mozilla=drh.moz=(_b3>=0)&&(!drh.khtml);
if(drh.mozilla){
drh.geckoVersion=dua.substring(_b3+6,_b3+14);
}
drh.ie=(document.all)&&(!drh.opera);
drh.ie50=drh.ie&&dav.indexOf("MSIE 5.0")>=0;
drh.ie55=drh.ie&&dav.indexOf("MSIE 5.5")>=0;
drh.ie60=drh.ie&&dav.indexOf("MSIE 6.0")>=0;
drh.ie70=drh.ie&&dav.indexOf("MSIE 7.0")>=0;
var cm=document["compatMode"];
drh.quirks=(cm=="BackCompat")||(cm=="QuirksMode")||drh.ie55||drh.ie50;
dojo.locale=dojo.locale||(drh.ie?navigator.userLanguage:navigator.language).toLowerCase();
dr.vml.capable=drh.ie;
drs.capable=f;
drs.support.plugin=f;
drs.support.builtin=f;
var _b5=window["document"];
var tdi=_b5["implementation"];
if((tdi)&&(tdi["hasFeature"])&&(tdi.hasFeature("org.w3c.dom.svg","1.0"))){
drs.capable=t;
drs.support.builtin=t;
drs.support.plugin=f;
}
if(drh.safari){
var tmp=dua.split("AppleWebKit/")[1];
var ver=parseFloat(tmp.split(" ")[0]);
if(ver>=420){
drs.capable=t;
drs.support.builtin=t;
drs.support.plugin=f;
}
}else{
}
})();
dojo.hostenv.startPackage("dojo.hostenv");
dojo.render.name=dojo.hostenv.name_="browser";
dojo.hostenv.searchIds=[];
dojo.hostenv._XMLHTTP_PROGIDS=["Msxml2.XMLHTTP","Microsoft.XMLHTTP","Msxml2.XMLHTTP.4.0"];
dojo.hostenv.getXmlhttpObject=function(){
var _b9=null;
var _ba=null;
try{
_b9=new XMLHttpRequest();
}
catch(e){
}
if(!_b9){
for(var i=0;i<3;++i){
var _bc=dojo.hostenv._XMLHTTP_PROGIDS[i];
try{
_b9=new ActiveXObject(_bc);
}
catch(e){
_ba=e;
}
if(_b9){
dojo.hostenv._XMLHTTP_PROGIDS=[_bc];
break;
}
}
}
if(!_b9){
return dojo.raise("XMLHTTP not available",_ba);
}
return _b9;
};
dojo.hostenv._blockAsync=false;
dojo.hostenv.getText=function(uri,_be,_bf){
if(!_be){
this._blockAsync=true;
}
var _c0=this.getXmlhttpObject();
function isDocumentOk(_c1){
var _c2=_c1["status"];
return Boolean((!_c2)||((200<=_c2)&&(300>_c2))||(_c2==304));
}
if(_be){
var _c3=this,_c4=null,gbl=dojo.global();
var xhr=dojo.evalObjPath("dojo.io.XMLHTTPTransport");
_c0.onreadystatechange=function(){
if(_c4){
gbl.clearTimeout(_c4);
_c4=null;
}
if(_c3._blockAsync||(xhr&&xhr._blockAsync)){
_c4=gbl.setTimeout(function(){
_c0.onreadystatechange.apply(this);
},10);
}else{
if(4==_c0.readyState){
if(isDocumentOk(_c0)){
_be(_c0.responseText);
}
}
}
};
}
_c0.open("GET",uri,_be?true:false);
try{
_c0.send(null);
if(_be){
return null;
}
if(!isDocumentOk(_c0)){
var err=Error("Unable to load "+uri+" status:"+_c0.status);
err.status=_c0.status;
err.responseText=_c0.responseText;
throw err;
}
}
catch(e){
this._blockAsync=false;
if((_bf)&&(!_be)){
return null;
}else{
throw e;
}
}
this._blockAsync=false;
return _c0.responseText;
};
dojo.hostenv.defaultDebugContainerId="dojoDebug";
dojo.hostenv._println_buffer=[];
dojo.hostenv._println_safe=false;
dojo.hostenv.println=function(_c8){
if(!dojo.hostenv._println_safe){
dojo.hostenv._println_buffer.push(_c8);
}else{
try{
var _c9=document.getElementById(djConfig.debugContainerId?djConfig.debugContainerId:dojo.hostenv.defaultDebugContainerId);
if(!_c9){
_c9=dojo.body();
}
var div=document.createElement("div");
div.appendChild(document.createTextNode(_c8));
_c9.appendChild(div);
}
catch(e){
try{
document.write("<div>"+_c8+"</div>");
}
catch(e2){
window.status=_c8;
}
}
}
};
dojo.addOnLoad(function(){
dojo.hostenv._println_safe=true;
while(dojo.hostenv._println_buffer.length>0){
dojo.hostenv.println(dojo.hostenv._println_buffer.shift());
}
});
function dj_addNodeEvtHdlr(_cb,_cc,fp){
var _ce=_cb["on"+_cc]||function(){
};
_cb["on"+_cc]=function(){
fp.apply(_cb,arguments);
_ce.apply(_cb,arguments);
};
return true;
}
function dj_load_init(e){
var _d0=(e&&e.type)?e.type.toLowerCase():"load";
if(arguments.callee.initialized||(_d0!="domcontentloaded"&&_d0!="load")){
return;
}
arguments.callee.initialized=true;
if(typeof (_timer)!="undefined"){
clearInterval(_timer);
delete _timer;
}
var _d1=function(){
if(dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
};
if(dojo.hostenv.inFlightCount==0){
_d1();
dojo.hostenv.modulesLoaded();
}else{
dojo.hostenv.modulesLoadedListeners.unshift(_d1);
}
}
if(document.addEventListener){
if(dojo.render.html.opera||(dojo.render.html.moz&&!djConfig.delayMozLoadingFix)){
document.addEventListener("DOMContentLoaded",dj_load_init,null);
}
window.addEventListener("load",dj_load_init,null);
}
if(dojo.render.html.ie&&dojo.render.os.win){
document.attachEvent("onreadystatechange",function(e){
if(document.readyState=="complete"){
dj_load_init();
}
});
}
if(/(WebKit|khtml)/i.test(navigator.userAgent)){
var _timer=setInterval(function(){
if(/loaded|complete/.test(document.readyState)){
dj_load_init();
}
},10);
}
if(dojo.render.html.ie){
dj_addNodeEvtHdlr(window,"beforeunload",function(){
dojo.hostenv._unloading=true;
window.setTimeout(function(){
dojo.hostenv._unloading=false;
},0);
});
}
dj_addNodeEvtHdlr(window,"unload",function(){
dojo.hostenv.unloaded();
if((!dojo.render.html.ie)||(dojo.render.html.ie&&dojo.hostenv._unloading)){
dojo.hostenv.unloaded();
}
});
dojo.hostenv.makeWidgets=function(){
var _d3=[];
if(djConfig.searchIds&&djConfig.searchIds.length>0){
_d3=_d3.concat(djConfig.searchIds);
}
if(dojo.hostenv.searchIds&&dojo.hostenv.searchIds.length>0){
_d3=_d3.concat(dojo.hostenv.searchIds);
}
if((djConfig.parseWidgets)||(_d3.length>0)){
if(dojo.evalObjPath("dojo.widget.Parse")){
var _d4=new dojo.xml.Parse();
if(_d3.length>0){
for(var x=0;x<_d3.length;x++){
var _d6=document.getElementById(_d3[x]);
if(!_d6){
continue;
}
var _d7=_d4.parseElement(_d6,null,true);
dojo.widget.getParser().createComponents(_d7);
}
}else{
if(djConfig.parseWidgets){
var _d7=_d4.parseElement(dojo.body(),null,true);
dojo.widget.getParser().createComponents(_d7);
}
}
}
}
};
dojo.addOnLoad(function(){
if(!dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
});
try{
if(dojo.render.html.ie){
document.namespaces.add("v","urn:schemas-microsoft-com:vml");
document.createStyleSheet().addRule("v\\:*","behavior:url(#default#VML)");
}
}
catch(e){
}
dojo.hostenv.writeIncludes=function(){
};
if(!dj_undef("document",this)){
dj_currentDocument=this.document;
}
dojo.doc=function(){
return dj_currentDocument;
};
dojo.body=function(){
return dojo.doc().body||dojo.doc().getElementsByTagName("body")[0];
};
dojo.byId=function(id,doc){
if((id)&&((typeof id=="string")||(id instanceof String))){
if(!doc){
doc=dj_currentDocument;
}
var ele=doc.getElementById(id);
if(ele&&(ele.id!=id)&&doc.all){
ele=null;
eles=doc.all[id];
if(eles){
if(eles.length){
for(var i=0;i<eles.length;i++){
if(eles[i].id==id){
ele=eles[i];
break;
}
}
}else{
ele=eles;
}
}
}
return ele;
}
return id;
};
dojo.setContext=function(_dc,_dd){
dj_currentContext=_dc;
dj_currentDocument=_dd;
};
dojo._fireCallback=function(_de,_df,_e0){
if((_df)&&((typeof _de=="string")||(_de instanceof String))){
_de=_df[_de];
}
return (_df?_de.apply(_df,_e0||[]):_de());
};
dojo.withGlobal=function(_e1,_e2,_e3,_e4){
var _e5;
var _e6=dj_currentContext;
var _e7=dj_currentDocument;
try{
dojo.setContext(_e1,_e1.document);
_e5=dojo._fireCallback(_e2,_e3,_e4);
}
finally{
dojo.setContext(_e6,_e7);
}
return _e5;
};
dojo.withDoc=function(_e8,_e9,_ea,_eb){
var _ec;
var _ed=dj_currentDocument;
try{
dj_currentDocument=_e8;
_ec=dojo._fireCallback(_e9,_ea,_eb);
}
finally{
dj_currentDocument=_ed;
}
return _ec;
};
}
(function(){
if(typeof dj_usingBootstrap!="undefined"){
return;
}
var _ee=false;
var _ef=false;
var _f0=false;
if((typeof this["load"]=="function")&&((typeof this["Packages"]=="function")||(typeof this["Packages"]=="object"))){
_ee=true;
}else{
if(typeof this["load"]=="function"){
_ef=true;
}else{
if(window.widget){
_f0=true;
}
}
}
var _f1=[];
if((this["djConfig"])&&((djConfig["isDebug"])||(djConfig["debugAtAllCosts"]))){
_f1.push("debug.js");
}
if((this["djConfig"])&&(djConfig["debugAtAllCosts"])&&(!_ee)&&(!_f0)){
_f1.push("browser_debug.js");
}
var _f2=djConfig["baseScriptUri"];
if((this["djConfig"])&&(djConfig["baseLoaderUri"])){
_f2=djConfig["baseLoaderUri"];
}
for(var x=0;x<_f1.length;x++){
var _f4=_f2+"src/"+_f1[x];
if(_ee||_ef){
load(_f4);
}else{
try{
document.write("<scr"+"ipt type='text/javascript' src='"+_f4+"'></scr"+"ipt>");
}
catch(e){
var _f5=document.createElement("script");
_f5.src=_f4;
document.getElementsByTagName("head")[0].appendChild(_f5);
}
}
}
})();
dojo.provide("dojo.lang.common");
dojo.lang.inherits=function(_f6,_f7){
if(!dojo.lang.isFunction(_f7)){
dojo.raise("dojo.inherits: superclass argument ["+_f7+"] must be a function (subclass: ["+_f6+"']");
}
_f6.prototype=new _f7();
_f6.prototype.constructor=_f6;
_f6.superclass=_f7.prototype;
_f6["super"]=_f7.prototype;
};
dojo.lang._mixin=function(obj,_f9){
var _fa={};
for(var x in _f9){
if((typeof _fa[x]=="undefined")||(_fa[x]!=_f9[x])){
obj[x]=_f9[x];
}
}
if(dojo.render.html.ie&&(typeof (_f9["toString"])=="function")&&(_f9["toString"]!=obj["toString"])&&(_f9["toString"]!=_fa["toString"])){
obj.toString=_f9.toString;
}
return obj;
};
dojo.lang.mixin=function(obj,_fd){
for(var i=1,l=arguments.length;i<l;i++){
dojo.lang._mixin(obj,arguments[i]);
}
return obj;
};
dojo.lang.extend=function(_100,_101){
for(var i=1,l=arguments.length;i<l;i++){
dojo.lang._mixin(_100.prototype,arguments[i]);
}
return _100;
};
dojo.inherits=dojo.lang.inherits;
dojo.mixin=dojo.lang.mixin;
dojo.extend=dojo.lang.extend;
dojo.lang.find=function(_104,_105,_106,_107){
if(!dojo.lang.isArrayLike(_104)&&dojo.lang.isArrayLike(_105)){
dojo.deprecated("dojo.lang.find(value, array)","use dojo.lang.find(array, value) instead","0.5");
var temp=_104;
_104=_105;
_105=temp;
}
var _109=dojo.lang.isString(_104);
if(_109){
_104=_104.split("");
}
if(_107){
var step=-1;
var i=_104.length-1;
var end=-1;
}else{
var step=1;
var i=0;
var end=_104.length;
}
if(_106){
while(i!=end){
if(_104[i]===_105){
return i;
}
i+=step;
}
}else{
while(i!=end){
if(_104[i]==_105){
return i;
}
i+=step;
}
}
return -1;
};
dojo.lang.indexOf=dojo.lang.find;
dojo.lang.findLast=function(_10d,_10e,_10f){
return dojo.lang.find(_10d,_10e,_10f,true);
};
dojo.lang.lastIndexOf=dojo.lang.findLast;
dojo.lang.inArray=function(_110,_111){
return dojo.lang.find(_110,_111)>-1;
};
dojo.lang.isObject=function(it){
if(typeof it=="undefined"){
return false;
}
return (typeof it=="object"||it===null||dojo.lang.isArray(it)||dojo.lang.isFunction(it));
};
dojo.lang.isArray=function(it){
return (it&&it instanceof Array||typeof it=="array");
};
dojo.lang.isArrayLike=function(it){
if((!it)||(dojo.lang.isUndefined(it))){
return false;
}
if(dojo.lang.isString(it)){
return false;
}
if(dojo.lang.isFunction(it)){
return false;
}
if(dojo.lang.isArray(it)){
return true;
}
if((it.tagName)&&(it.tagName.toLowerCase()=="form")){
return false;
}
if(dojo.lang.isNumber(it.length)&&isFinite(it.length)){
return true;
}
return false;
};
dojo.lang.isFunction=function(it){
return (it instanceof Function||typeof it=="function");
};
(function(){
if((dojo.render.html.capable)&&(dojo.render.html["safari"])){
dojo.lang.isFunction=function(it){
if((typeof (it)=="function")&&(it=="[object NodeList]")){
return false;
}
return (it instanceof Function||typeof it=="function");
};
}
})();
dojo.lang.isString=function(it){
return (typeof it=="string"||it instanceof String);
};
dojo.lang.isAlien=function(it){
if(!it){
return false;
}
return !dojo.lang.isFunction(it)&&/\{\s*\[native code\]\s*\}/.test(String(it));
};
dojo.lang.isBoolean=function(it){
return (it instanceof Boolean||typeof it=="boolean");
};
dojo.lang.isNumber=function(it){
return (it instanceof Number||typeof it=="number");
};
dojo.lang.isUndefined=function(it){
return ((typeof (it)=="undefined")&&(it==undefined));
};
dojo.provide("dojo.lang.array");
dojo.lang.mixin(dojo.lang,{has:function(obj,name){
try{
return typeof obj[name]!="undefined";
}
catch(e){
return false;
}
},isEmpty:function(obj){
if(dojo.lang.isObject(obj)){
var tmp={};
var _120=0;
for(var x in obj){
if(obj[x]&&(!tmp[x])){
_120++;
break;
}
}
return _120==0;
}else{
if(dojo.lang.isArrayLike(obj)||dojo.lang.isString(obj)){
return obj.length==0;
}
}
},map:function(arr,obj,_124){
var _125=dojo.lang.isString(arr);
if(_125){
arr=arr.split("");
}
if(dojo.lang.isFunction(obj)&&(!_124)){
_124=obj;
obj=dj_global;
}else{
if(dojo.lang.isFunction(obj)&&_124){
var _126=obj;
obj=_124;
_124=_126;
}
}
if(Array.map){
var _127=Array.map(arr,_124,obj);
}else{
var _127=[];
for(var i=0;i<arr.length;++i){
_127.push(_124.call(obj,arr[i]));
}
}
if(_125){
return _127.join("");
}else{
return _127;
}
},reduce:function(arr,_12a,obj,_12c){
var _12d=_12a;
if(arguments.length==1){
dojo.debug("dojo.lang.reduce called with too few arguments!");
return false;
}else{
if(arguments.length==2){
_12c=_12a;
_12d=arr.shift();
}else{
if(arguments.lenght==3){
if(dojo.lang.isFunction(obj)){
_12c=obj;
obj=null;
}
}else{
if(dojo.lang.isFunction(obj)){
var tmp=_12c;
_12c=obj;
obj=tmp;
}
}
}
}
var ob=obj?obj:dj_global;
dojo.lang.map(arr,function(val){
_12d=_12c.call(ob,_12d,val);
});
return _12d;
},forEach:function(_131,_132,_133){
if(dojo.lang.isString(_131)){
_131=_131.split("");
}
if(Array.forEach){
Array.forEach(_131,_132,_133);
}else{
if(!_133){
_133=dj_global;
}
for(var i=0,l=_131.length;i<l;i++){
_132.call(_133,_131[i],i,_131);
}
}
},_everyOrSome:function(_136,arr,_138,_139){
if(dojo.lang.isString(arr)){
arr=arr.split("");
}
if(Array.every){
return Array[_136?"every":"some"](arr,_138,_139);
}else{
if(!_139){
_139=dj_global;
}
for(var i=0,l=arr.length;i<l;i++){
var _13c=_138.call(_139,arr[i],i,arr);
if(_136&&!_13c){
return false;
}else{
if((!_136)&&(_13c)){
return true;
}
}
}
return Boolean(_136);
}
},every:function(arr,_13e,_13f){
return this._everyOrSome(true,arr,_13e,_13f);
},some:function(arr,_141,_142){
return this._everyOrSome(false,arr,_141,_142);
},filter:function(arr,_144,_145){
var _146=dojo.lang.isString(arr);
if(_146){
arr=arr.split("");
}
var _147;
if(Array.filter){
_147=Array.filter(arr,_144,_145);
}else{
if(!_145){
if(arguments.length>=3){
dojo.raise("thisObject doesn't exist!");
}
_145=dj_global;
}
_147=[];
for(var i=0;i<arr.length;i++){
if(_144.call(_145,arr[i],i,arr)){
_147.push(arr[i]);
}
}
}
if(_146){
return _147.join("");
}else{
return _147;
}
},unnest:function(){
var out=[];
for(var i=0;i<arguments.length;i++){
if(dojo.lang.isArrayLike(arguments[i])){
var add=dojo.lang.unnest.apply(this,arguments[i]);
out=out.concat(add);
}else{
out.push(arguments[i]);
}
}
return out;
},toArray:function(_14c,_14d){
var _14e=[];
for(var i=_14d||0;i<_14c.length;i++){
_14e.push(_14c[i]);
}
return _14e;
}});
dojo.provide("dojo.lang.extras");
dojo.lang.setTimeout=function(func,_151){
var _152=window,_153=2;
if(!dojo.lang.isFunction(func)){
_152=func;
func=_151;
_151=arguments[2];
_153++;
}
if(dojo.lang.isString(func)){
func=_152[func];
}
var args=[];
for(var i=_153;i<arguments.length;i++){
args.push(arguments[i]);
}
return dojo.global().setTimeout(function(){
func.apply(_152,args);
},_151);
};
dojo.lang.clearTimeout=function(_156){
dojo.global().clearTimeout(_156);
};
dojo.lang.getNameInObj=function(ns,item){
if(!ns){
ns=dj_global;
}
for(var x in ns){
if(ns[x]===item){
return new String(x);
}
}
return null;
};
dojo.lang.shallowCopy=function(obj,deep){
var i,ret;
if(obj===null){
return null;
}
if(dojo.lang.isObject(obj)){
ret=new obj.constructor();
for(i in obj){
if(dojo.lang.isUndefined(ret[i])){
ret[i]=deep?dojo.lang.shallowCopy(obj[i],deep):obj[i];
}
}
}else{
if(dojo.lang.isArray(obj)){
ret=[];
for(i=0;i<obj.length;i++){
ret[i]=deep?dojo.lang.shallowCopy(obj[i],deep):obj[i];
}
}else{
ret=obj;
}
}
return ret;
};
dojo.lang.firstValued=function(){
for(var i=0;i<arguments.length;i++){
if(typeof arguments[i]!="undefined"){
return arguments[i];
}
}
return undefined;
};
dojo.lang.getObjPathValue=function(_15f,_160,_161){
with(dojo.parseObjPath(_15f,_160,_161)){
return dojo.evalProp(prop,obj,_161);
}
};
dojo.lang.setObjPathValue=function(_162,_163,_164,_165){
dojo.deprecated("dojo.lang.setObjPathValue","use dojo.parseObjPath and the '=' operator","0.6");
if(arguments.length<4){
_165=true;
}
with(dojo.parseObjPath(_162,_164,_165)){
if(obj&&(_165||(prop in obj))){
obj[prop]=_163;
}
}
};
dojo.provide("dojo.lang.func");
dojo.lang.hitch=function(_166,_167){
var fcn=(dojo.lang.isString(_167)?_166[_167]:_167)||function(){
};
return function(){
return fcn.apply(_166,arguments);
};
};
dojo.lang.anonCtr=0;
dojo.lang.anon={};
dojo.lang.nameAnonFunc=function(_169,_16a,_16b){
var nso=(_16a||dojo.lang.anon);
if((_16b)||((dj_global["djConfig"])&&(djConfig["slowAnonFuncLookups"]==true))){
for(var x in nso){
try{
if(nso[x]===_169){
return x;
}
}
catch(e){
}
}
}
var ret="__"+dojo.lang.anonCtr++;
while(typeof nso[ret]!="undefined"){
ret="__"+dojo.lang.anonCtr++;
}
nso[ret]=_169;
return ret;
};
dojo.lang.forward=function(_16f){
return function(){
return this[_16f].apply(this,arguments);
};
};
dojo.lang.curry=function(_170,func){
var _172=[];
_170=_170||dj_global;
if(dojo.lang.isString(func)){
func=_170[func];
}
for(var x=2;x<arguments.length;x++){
_172.push(arguments[x]);
}
var _174=(func["__preJoinArity"]||func.length)-_172.length;
function gather(_175,_176,_177){
var _178=_177;
var _179=_176.slice(0);
for(var x=0;x<_175.length;x++){
_179.push(_175[x]);
}
_177=_177-_175.length;
if(_177<=0){
var res=func.apply(_170,_179);
_177=_178;
return res;
}else{
return function(){
return gather(arguments,_179,_177);
};
}
}
return gather([],_172,_174);
};
dojo.lang.curryArguments=function(_17c,func,args,_17f){
var _180=[];
var x=_17f||0;
for(x=_17f;x<args.length;x++){
_180.push(args[x]);
}
return dojo.lang.curry.apply(dojo.lang,[_17c,func].concat(_180));
};
dojo.lang.tryThese=function(){
for(var x=0;x<arguments.length;x++){
try{
if(typeof arguments[x]=="function"){
var ret=(arguments[x]());
if(ret){
return ret;
}
}
}
catch(e){
dojo.debug(e);
}
}
};
dojo.lang.delayThese=function(farr,cb,_186,_187){
if(!farr.length){
if(typeof _187=="function"){
_187();
}
return;
}
if((typeof _186=="undefined")&&(typeof cb=="number")){
_186=cb;
cb=function(){
};
}else{
if(!cb){
cb=function(){
};
if(!_186){
_186=0;
}
}
}
setTimeout(function(){
(farr.shift())();
cb();
dojo.lang.delayThese(farr,cb,_186,_187);
},_186);
};
dojo.provide("dojo.event.common");
dojo.event=new function(){
this._canTimeout=dojo.lang.isFunction(dj_global["setTimeout"])||dojo.lang.isAlien(dj_global["setTimeout"]);
function interpolateArgs(args,_189){
var dl=dojo.lang;
var ao={srcObj:dj_global,srcFunc:null,adviceObj:dj_global,adviceFunc:null,aroundObj:null,aroundFunc:null,adviceType:(args.length>2)?args[0]:"after",precedence:"last",once:false,delay:null,rate:0,adviceMsg:false};
switch(args.length){
case 0:
return;
case 1:
return;
case 2:
ao.srcFunc=args[0];
ao.adviceFunc=args[1];
break;
case 3:
if((dl.isObject(args[0]))&&(dl.isString(args[1]))&&(dl.isString(args[2]))){
ao.adviceType="after";
ao.srcObj=args[0];
ao.srcFunc=args[1];
ao.adviceFunc=args[2];
}else{
if((dl.isString(args[1]))&&(dl.isString(args[2]))){
ao.srcFunc=args[1];
ao.adviceFunc=args[2];
}else{
if((dl.isObject(args[0]))&&(dl.isString(args[1]))&&(dl.isFunction(args[2]))){
ao.adviceType="after";
ao.srcObj=args[0];
ao.srcFunc=args[1];
var _18c=dl.nameAnonFunc(args[2],ao.adviceObj,_189);
ao.adviceFunc=_18c;
}else{
if((dl.isFunction(args[0]))&&(dl.isObject(args[1]))&&(dl.isString(args[2]))){
ao.adviceType="after";
ao.srcObj=dj_global;
var _18c=dl.nameAnonFunc(args[0],ao.srcObj,_189);
ao.srcFunc=_18c;
ao.adviceObj=args[1];
ao.adviceFunc=args[2];
}
}
}
}
break;
case 4:
if((dl.isObject(args[0]))&&(dl.isObject(args[2]))){
ao.adviceType="after";
ao.srcObj=args[0];
ao.srcFunc=args[1];
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
if((dl.isString(args[0]))&&(dl.isString(args[1]))&&(dl.isObject(args[2]))){
ao.adviceType=args[0];
ao.srcObj=dj_global;
ao.srcFunc=args[1];
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
if((dl.isString(args[0]))&&(dl.isFunction(args[1]))&&(dl.isObject(args[2]))){
ao.adviceType=args[0];
ao.srcObj=dj_global;
var _18c=dl.nameAnonFunc(args[1],dj_global,_189);
ao.srcFunc=_18c;
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
if((dl.isString(args[0]))&&(dl.isObject(args[1]))&&(dl.isString(args[2]))&&(dl.isFunction(args[3]))){
ao.srcObj=args[1];
ao.srcFunc=args[2];
var _18c=dl.nameAnonFunc(args[3],dj_global,_189);
ao.adviceObj=dj_global;
ao.adviceFunc=_18c;
}else{
if(dl.isObject(args[1])){
ao.srcObj=args[1];
ao.srcFunc=args[2];
ao.adviceObj=dj_global;
ao.adviceFunc=args[3];
}else{
if(dl.isObject(args[2])){
ao.srcObj=dj_global;
ao.srcFunc=args[1];
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
ao.srcObj=ao.adviceObj=ao.aroundObj=dj_global;
ao.srcFunc=args[1];
ao.adviceFunc=args[2];
ao.aroundFunc=args[3];
}
}
}
}
}
}
break;
case 6:
ao.srcObj=args[1];
ao.srcFunc=args[2];
ao.adviceObj=args[3];
ao.adviceFunc=args[4];
ao.aroundFunc=args[5];
ao.aroundObj=dj_global;
break;
default:
ao.srcObj=args[1];
ao.srcFunc=args[2];
ao.adviceObj=args[3];
ao.adviceFunc=args[4];
ao.aroundObj=args[5];
ao.aroundFunc=args[6];
ao.once=args[7];
ao.delay=args[8];
ao.rate=args[9];
ao.adviceMsg=args[10];
break;
}
if(dl.isFunction(ao.aroundFunc)){
var _18c=dl.nameAnonFunc(ao.aroundFunc,ao.aroundObj,_189);
ao.aroundFunc=_18c;
}
if(dl.isFunction(ao.srcFunc)){
ao.srcFunc=dl.getNameInObj(ao.srcObj,ao.srcFunc);
}
if(dl.isFunction(ao.adviceFunc)){
ao.adviceFunc=dl.getNameInObj(ao.adviceObj,ao.adviceFunc);
}
if((ao.aroundObj)&&(dl.isFunction(ao.aroundFunc))){
ao.aroundFunc=dl.getNameInObj(ao.aroundObj,ao.aroundFunc);
}
if(!ao.srcObj){
dojo.raise("bad srcObj for srcFunc: "+ao.srcFunc);
}
if(!ao.adviceObj){
dojo.raise("bad adviceObj for adviceFunc: "+ao.adviceFunc);
}
if(!ao.adviceFunc){
dojo.debug("bad adviceFunc for srcFunc: "+ao.srcFunc);
dojo.debugShallow(ao);
}
return ao;
}
this.connect=function(){
if(arguments.length==1){
var ao=arguments[0];
}else{
var ao=interpolateArgs(arguments,true);
}
if(dojo.lang.isString(ao.srcFunc)&&(ao.srcFunc.toLowerCase()=="onkey")){
if(dojo.render.html.ie){
ao.srcFunc="onkeydown";
this.connect(ao);
}
ao.srcFunc="onkeypress";
}
if(dojo.lang.isArray(ao.srcObj)&&ao.srcObj!=""){
var _18e={};
for(var x in ao){
_18e[x]=ao[x];
}
var mjps=[];
dojo.lang.forEach(ao.srcObj,function(src){
if((dojo.render.html.capable)&&(dojo.lang.isString(src))){
src=dojo.byId(src);
}
_18e.srcObj=src;
mjps.push(dojo.event.connect.call(dojo.event,_18e));
});
return mjps;
}
var mjp=dojo.event.MethodJoinPoint.getForMethod(ao.srcObj,ao.srcFunc);
if(ao.adviceFunc){
var mjp2=dojo.event.MethodJoinPoint.getForMethod(ao.adviceObj,ao.adviceFunc);
}
mjp.kwAddAdvice(ao);
return mjp;
};
this.log=function(a1,a2){
var _196;
if((arguments.length==1)&&(typeof a1=="object")){
_196=a1;
}else{
_196={srcObj:a1,srcFunc:a2};
}
_196.adviceFunc=function(){
var _197=[];
for(var x=0;x<arguments.length;x++){
_197.push(arguments[x]);
}
dojo.debug("("+_196.srcObj+")."+_196.srcFunc,":",_197.join(", "));
};
this.kwConnect(_196);
};
this.connectBefore=function(){
var args=["before"];
for(var i=0;i<arguments.length;i++){
args.push(arguments[i]);
}
return this.connect.apply(this,args);
};
this.connectAround=function(){
var args=["around"];
for(var i=0;i<arguments.length;i++){
args.push(arguments[i]);
}
return this.connect.apply(this,args);
};
this.connectOnce=function(){
var ao=interpolateArgs(arguments,true);
ao.once=true;
return this.connect(ao);
};
this._kwConnectImpl=function(_19e,_19f){
var fn=(_19f)?"disconnect":"connect";
if(typeof _19e["srcFunc"]=="function"){
_19e.srcObj=_19e["srcObj"]||dj_global;
var _1a1=dojo.lang.nameAnonFunc(_19e.srcFunc,_19e.srcObj,true);
_19e.srcFunc=_1a1;
}
if(typeof _19e["adviceFunc"]=="function"){
_19e.adviceObj=_19e["adviceObj"]||dj_global;
var _1a1=dojo.lang.nameAnonFunc(_19e.adviceFunc,_19e.adviceObj,true);
_19e.adviceFunc=_1a1;
}
_19e.srcObj=_19e["srcObj"]||dj_global;
_19e.adviceObj=_19e["adviceObj"]||_19e["targetObj"]||dj_global;
_19e.adviceFunc=_19e["adviceFunc"]||_19e["targetFunc"];
return dojo.event[fn](_19e);
};
this.kwConnect=function(_1a2){
return this._kwConnectImpl(_1a2,false);
};
this.disconnect=function(){
if(arguments.length==1){
var ao=arguments[0];
}else{
var ao=interpolateArgs(arguments,true);
}
if(!ao.adviceFunc){
return;
}
if(dojo.lang.isString(ao.srcFunc)&&(ao.srcFunc.toLowerCase()=="onkey")){
if(dojo.render.html.ie){
ao.srcFunc="onkeydown";
this.disconnect(ao);
}
ao.srcFunc="onkeypress";
}
if(!ao.srcObj[ao.srcFunc]){
return null;
}
var mjp=dojo.event.MethodJoinPoint.getForMethod(ao.srcObj,ao.srcFunc,true);
mjp.removeAdvice(ao.adviceObj,ao.adviceFunc,ao.adviceType,ao.once);
return mjp;
};
this.kwDisconnect=function(_1a5){
return this._kwConnectImpl(_1a5,true);
};
};
dojo.event.MethodInvocation=function(_1a6,obj,args){
this.jp_=_1a6;
this.object=obj;
this.args=[];
for(var x=0;x<args.length;x++){
this.args[x]=args[x];
}
this.around_index=-1;
};
dojo.event.MethodInvocation.prototype.proceed=function(){
this.around_index++;
if(this.around_index>=this.jp_.around.length){
return this.jp_.object[this.jp_.methodname].apply(this.jp_.object,this.args);
}else{
var ti=this.jp_.around[this.around_index];
var mobj=ti[0]||dj_global;
var meth=ti[1];
return mobj[meth].call(mobj,this);
}
};
dojo.event.MethodJoinPoint=function(obj,_1ae){
this.object=obj||dj_global;
this.methodname=_1ae;
this.methodfunc=this.object[_1ae];
this.squelch=false;
};
dojo.event.MethodJoinPoint.getForMethod=function(obj,_1b0){
if(!obj){
obj=dj_global;
}
if(!obj[_1b0]){
obj[_1b0]=function(){
};
if(!obj[_1b0]){
dojo.raise("Cannot set do-nothing method on that object "+_1b0);
}
}else{
if((!dojo.lang.isFunction(obj[_1b0]))&&(!dojo.lang.isAlien(obj[_1b0]))){
return null;
}
}
var _1b1=_1b0+"$joinpoint";
var _1b2=_1b0+"$joinpoint$method";
var _1b3=obj[_1b1];
if(!_1b3){
var _1b4=false;
if(dojo.event["browser"]){
if((obj["attachEvent"])||(obj["nodeType"])||(obj["addEventListener"])){
_1b4=true;
dojo.event.browser.addClobberNodeAttrs(obj,[_1b1,_1b2,_1b0]);
}
}
var _1b5=obj[_1b0].length;
obj[_1b2]=obj[_1b0];
_1b3=obj[_1b1]=new dojo.event.MethodJoinPoint(obj,_1b2);
obj[_1b0]=function(){
var args=[];
if((_1b4)&&(!arguments.length)){
var evt=null;
try{
if(obj.ownerDocument){
evt=obj.ownerDocument.parentWindow.event;
}else{
if(obj.documentElement){
evt=obj.documentElement.ownerDocument.parentWindow.event;
}else{
if(obj.event){
evt=obj.event;
}else{
evt=window.event;
}
}
}
}
catch(e){
evt=window.event;
}
if(evt){
args.push(dojo.event.browser.fixEvent(evt,this));
}
}else{
for(var x=0;x<arguments.length;x++){
if((x==0)&&(_1b4)&&(dojo.event.browser.isEvent(arguments[x]))){
args.push(dojo.event.browser.fixEvent(arguments[x],this));
}else{
args.push(arguments[x]);
}
}
}
return _1b3.run.apply(_1b3,args);
};
obj[_1b0].__preJoinArity=_1b5;
}
return _1b3;
};
dojo.lang.extend(dojo.event.MethodJoinPoint,{unintercept:function(){
this.object[this.methodname]=this.methodfunc;
this.before=[];
this.after=[];
this.around=[];
},disconnect:dojo.lang.forward("unintercept"),run:function(){
var obj=this.object||dj_global;
var args=arguments;
var _1bb=[];
for(var x=0;x<args.length;x++){
_1bb[x]=args[x];
}
var _1bd=function(marr){
if(!marr){
dojo.debug("Null argument to unrollAdvice()");
return;
}
var _1bf=marr[0]||dj_global;
var _1c0=marr[1];
if(!_1bf[_1c0]){
dojo.raise("function \""+_1c0+"\" does not exist on \""+_1bf+"\"");
}
var _1c1=marr[2]||dj_global;
var _1c2=marr[3];
var msg=marr[6];
var _1c4;
var to={args:[],jp_:this,object:obj,proceed:function(){
return _1bf[_1c0].apply(_1bf,to.args);
}};
to.args=_1bb;
var _1c6=parseInt(marr[4]);
var _1c7=((!isNaN(_1c6))&&(marr[4]!==null)&&(typeof marr[4]!="undefined"));
if(marr[5]){
var rate=parseInt(marr[5]);
var cur=new Date();
var _1ca=false;
if((marr["last"])&&((cur-marr.last)<=rate)){
if(dojo.event._canTimeout){
if(marr["delayTimer"]){
clearTimeout(marr.delayTimer);
}
var tod=parseInt(rate*2);
var mcpy=dojo.lang.shallowCopy(marr);
marr.delayTimer=setTimeout(function(){
mcpy[5]=0;
_1bd(mcpy);
},tod);
}
return;
}else{
marr.last=cur;
}
}
if(_1c2){
_1c1[_1c2].call(_1c1,to);
}else{
if((_1c7)&&((dojo.render.html)||(dojo.render.svg))){
dj_global["setTimeout"](function(){
if(msg){
_1bf[_1c0].call(_1bf,to);
}else{
_1bf[_1c0].apply(_1bf,args);
}
},_1c6);
}else{
if(msg){
_1bf[_1c0].call(_1bf,to);
}else{
_1bf[_1c0].apply(_1bf,args);
}
}
}
};
var _1cd=function(){
if(this.squelch){
try{
return _1bd.apply(this,arguments);
}
catch(e){
dojo.debug(e);
}
}else{
return _1bd.apply(this,arguments);
}
};
if((this["before"])&&(this.before.length>0)){
dojo.lang.forEach(this.before.concat(new Array()),_1cd);
}
var _1ce;
try{
if((this["around"])&&(this.around.length>0)){
var mi=new dojo.event.MethodInvocation(this,obj,args);
_1ce=mi.proceed();
}else{
if(this.methodfunc){
_1ce=this.object[this.methodname].apply(this.object,args);
}
}
}
catch(e){
if(!this.squelch){
dojo.debug(e,"when calling",this.methodname,"on",this.object,"with arguments",args);
dojo.raise(e);
}
}
if((this["after"])&&(this.after.length>0)){
dojo.lang.forEach(this.after.concat(new Array()),_1cd);
}
return (this.methodfunc)?_1ce:null;
},getArr:function(kind){
var type="after";
if((typeof kind=="string")&&(kind.indexOf("before")!=-1)){
type="before";
}else{
if(kind=="around"){
type="around";
}
}
if(!this[type]){
this[type]=[];
}
return this[type];
},kwAddAdvice:function(args){
this.addAdvice(args["adviceObj"],args["adviceFunc"],args["aroundObj"],args["aroundFunc"],args["adviceType"],args["precedence"],args["once"],args["delay"],args["rate"],args["adviceMsg"]);
},addAdvice:function(_1d3,_1d4,_1d5,_1d6,_1d7,_1d8,once,_1da,rate,_1dc){
var arr=this.getArr(_1d7);
if(!arr){
dojo.raise("bad this: "+this);
}
var ao=[_1d3,_1d4,_1d5,_1d6,_1da,rate,_1dc];
if(once){
if(this.hasAdvice(_1d3,_1d4,_1d7,arr)>=0){
return;
}
}
if(_1d8=="first"){
arr.unshift(ao);
}else{
arr.push(ao);
}
},hasAdvice:function(_1df,_1e0,_1e1,arr){
if(!arr){
arr=this.getArr(_1e1);
}
var ind=-1;
for(var x=0;x<arr.length;x++){
var aao=(typeof _1e0=="object")?(new String(_1e0)).toString():_1e0;
var a1o=(typeof arr[x][1]=="object")?(new String(arr[x][1])).toString():arr[x][1];
if((arr[x][0]==_1df)&&(a1o==aao)){
ind=x;
}
}
return ind;
},removeAdvice:function(_1e7,_1e8,_1e9,once){
var arr=this.getArr(_1e9);
var ind=this.hasAdvice(_1e7,_1e8,_1e9,arr);
if(ind==-1){
return false;
}
while(ind!=-1){
arr.splice(ind,1);
if(once){
break;
}
ind=this.hasAdvice(_1e7,_1e8,_1e9,arr);
}
return true;
}});
dojo.provide("dojo.event.topic");
dojo.event.topic=new function(){
this.topics={};
this.getTopic=function(_1ed){
if(!this.topics[_1ed]){
this.topics[_1ed]=new this.TopicImpl(_1ed);
}
return this.topics[_1ed];
};
this.registerPublisher=function(_1ee,obj,_1f0){
var _1ee=this.getTopic(_1ee);
_1ee.registerPublisher(obj,_1f0);
};
this.subscribe=function(_1f1,obj,_1f3){
var _1f1=this.getTopic(_1f1);
_1f1.subscribe(obj,_1f3);
};
this.unsubscribe=function(_1f4,obj,_1f6){
var _1f4=this.getTopic(_1f4);
_1f4.unsubscribe(obj,_1f6);
};
this.destroy=function(_1f7){
this.getTopic(_1f7).destroy();
delete this.topics[_1f7];
};
this.publishApply=function(_1f8,args){
var _1f8=this.getTopic(_1f8);
_1f8.sendMessage.apply(_1f8,args);
};
this.publish=function(_1fa,_1fb){
var _1fa=this.getTopic(_1fa);
var args=[];
for(var x=1;x<arguments.length;x++){
args.push(arguments[x]);
}
_1fa.sendMessage.apply(_1fa,args);
};
};
dojo.event.topic.TopicImpl=function(_1fe){
this.topicName=_1fe;
this.subscribe=function(_1ff,_200){
var tf=_200||_1ff;
var to=(!_200)?dj_global:_1ff;
return dojo.event.kwConnect({srcObj:this,srcFunc:"sendMessage",adviceObj:to,adviceFunc:tf});
};
this.unsubscribe=function(_203,_204){
var tf=(!_204)?_203:_204;
var to=(!_204)?null:_203;
return dojo.event.kwDisconnect({srcObj:this,srcFunc:"sendMessage",adviceObj:to,adviceFunc:tf});
};
this._getJoinPoint=function(){
return dojo.event.MethodJoinPoint.getForMethod(this,"sendMessage");
};
this.setSquelch=function(_207){
this._getJoinPoint().squelch=_207;
};
this.destroy=function(){
this._getJoinPoint().disconnect();
};
this.registerPublisher=function(_208,_209){
dojo.event.connect(_208,_209,this,"sendMessage");
};
this.sendMessage=function(_20a){
};
};
dojo.provide("dojo.event.browser");
dojo._ie_clobber=new function(){
this.clobberNodes=[];
function nukeProp(node,prop){
try{
node[prop]=null;
}
catch(e){
}
try{
delete node[prop];
}
catch(e){
}
try{
node.removeAttribute(prop);
}
catch(e){
}
}
this.clobber=function(_20d){
var na;
var tna;
if(_20d){
tna=_20d.all||_20d.getElementsByTagName("*");
na=[_20d];
for(var x=0;x<tna.length;x++){
if(tna[x]["__doClobber__"]){
na.push(tna[x]);
}
}
}else{
try{
window.onload=null;
}
catch(e){
}
na=(this.clobberNodes.length)?this.clobberNodes:document.all;
}
tna=null;
var _211={};
for(var i=na.length-1;i>=0;i=i-1){
var el=na[i];
try{
if(el&&el["__clobberAttrs__"]){
for(var j=0;j<el.__clobberAttrs__.length;j++){
nukeProp(el,el.__clobberAttrs__[j]);
}
nukeProp(el,"__clobberAttrs__");
nukeProp(el,"__doClobber__");
}
}
catch(e){
}
}
na=null;
};
};
if(dojo.render.html.ie){
dojo.addOnUnload(function(){
dojo._ie_clobber.clobber();
try{
if((dojo["widget"])&&(dojo.widget["manager"])){
dojo.widget.manager.destroyAll();
}
}
catch(e){
}
if(dojo.widget){
for(var name in dojo.widget._templateCache){
if(dojo.widget._templateCache[name].node){
dojo.dom.destroyNode(dojo.widget._templateCache[name].node);
dojo.widget._templateCache[name].node=null;
delete dojo.widget._templateCache[name].node;
}
}
}
try{
window.onload=null;
}
catch(e){
}
try{
window.onunload=null;
}
catch(e){
}
dojo._ie_clobber.clobberNodes=[];
});
}
dojo.event.browser=new function(){
var _216=0;
this.normalizedEventName=function(_217){
switch(_217){
case "CheckboxStateChange":
case "DOMAttrModified":
case "DOMMenuItemActive":
case "DOMMenuItemInactive":
case "DOMMouseScroll":
case "DOMNodeInserted":
case "DOMNodeRemoved":
case "RadioStateChange":
return _217;
break;
default:
return _217.toLowerCase();
break;
}
};
this.clean=function(node){
if(dojo.render.html.ie){
dojo._ie_clobber.clobber(node);
}
};
this.addClobberNode=function(node){
if(!dojo.render.html.ie){
return;
}
if(!node["__doClobber__"]){
node.__doClobber__=true;
dojo._ie_clobber.clobberNodes.push(node);
node.__clobberAttrs__=[];
}
};
this.addClobberNodeAttrs=function(node,_21b){
if(!dojo.render.html.ie){
return;
}
this.addClobberNode(node);
for(var x=0;x<_21b.length;x++){
node.__clobberAttrs__.push(_21b[x]);
}
};
this.removeListener=function(node,_21e,fp,_220){
if(!_220){
var _220=false;
}
_21e=dojo.event.browser.normalizedEventName(_21e);
if((_21e=="onkey")||(_21e=="key")){
if(dojo.render.html.ie){
this.removeListener(node,"onkeydown",fp,_220);
}
_21e="onkeypress";
}
if(_21e.substr(0,2)=="on"){
_21e=_21e.substr(2);
}
if(node.removeEventListener){
node.removeEventListener(_21e,fp,_220);
}
};
this.addListener=function(node,_222,fp,_224,_225){
if(!node){
return;
}
if(!_224){
var _224=false;
}
_222=dojo.event.browser.normalizedEventName(_222);
if((_222=="onkey")||(_222=="key")){
if(dojo.render.html.ie){
this.addListener(node,"onkeydown",fp,_224,_225);
}
_222="onkeypress";
}
if(_222.substr(0,2)!="on"){
_222="on"+_222;
}
if(!_225){
var _226=function(evt){
if(!evt){
evt=window.event;
}
var ret=fp(dojo.event.browser.fixEvent(evt,this));
if(_224){
dojo.event.browser.stopEvent(evt);
}
return ret;
};
}else{
_226=fp;
}
if(node.addEventListener){
node.addEventListener(_222.substr(2),_226,_224);
return _226;
}else{
if(typeof node[_222]=="function"){
var _229=node[_222];
node[_222]=function(e){
_229(e);
return _226(e);
};
}else{
node[_222]=_226;
}
if(dojo.render.html.ie){
this.addClobberNodeAttrs(node,[_222]);
}
return _226;
}
};
this.isEvent=function(obj){
return (typeof obj!="undefined")&&(obj)&&(typeof Event!="undefined")&&(obj.eventPhase);
};
this.currentEvent=null;
this.callListener=function(_22c,_22d){
if(typeof _22c!="function"){
dojo.raise("listener not a function: "+_22c);
}
dojo.event.browser.currentEvent.currentTarget=_22d;
return _22c.call(_22d,dojo.event.browser.currentEvent);
};
this._stopPropagation=function(){
dojo.event.browser.currentEvent.cancelBubble=true;
};
this._preventDefault=function(){
dojo.event.browser.currentEvent.returnValue=false;
};
this.keys={KEY_BACKSPACE:8,KEY_TAB:9,KEY_CLEAR:12,KEY_ENTER:13,KEY_SHIFT:16,KEY_CTRL:17,KEY_ALT:18,KEY_PAUSE:19,KEY_CAPS_LOCK:20,KEY_ESCAPE:27,KEY_SPACE:32,KEY_PAGE_UP:33,KEY_PAGE_DOWN:34,KEY_END:35,KEY_HOME:36,KEY_LEFT_ARROW:37,KEY_UP_ARROW:38,KEY_RIGHT_ARROW:39,KEY_DOWN_ARROW:40,KEY_INSERT:45,KEY_DELETE:46,KEY_HELP:47,KEY_LEFT_WINDOW:91,KEY_RIGHT_WINDOW:92,KEY_SELECT:93,KEY_NUMPAD_0:96,KEY_NUMPAD_1:97,KEY_NUMPAD_2:98,KEY_NUMPAD_3:99,KEY_NUMPAD_4:100,KEY_NUMPAD_5:101,KEY_NUMPAD_6:102,KEY_NUMPAD_7:103,KEY_NUMPAD_8:104,KEY_NUMPAD_9:105,KEY_NUMPAD_MULTIPLY:106,KEY_NUMPAD_PLUS:107,KEY_NUMPAD_ENTER:108,KEY_NUMPAD_MINUS:109,KEY_NUMPAD_PERIOD:110,KEY_NUMPAD_DIVIDE:111,KEY_F1:112,KEY_F2:113,KEY_F3:114,KEY_F4:115,KEY_F5:116,KEY_F6:117,KEY_F7:118,KEY_F8:119,KEY_F9:120,KEY_F10:121,KEY_F11:122,KEY_F12:123,KEY_F13:124,KEY_F14:125,KEY_F15:126,KEY_NUM_LOCK:144,KEY_SCROLL_LOCK:145};
this.revKeys=[];
for(var key in this.keys){
this.revKeys[this.keys[key]]=key;
}
this.fixEvent=function(evt,_230){
if(!evt){
if(window["event"]){
evt=window.event;
}
}
if((evt["type"])&&(evt["type"].indexOf("key")==0)){
evt.keys=this.revKeys;
for(var key in this.keys){
evt[key]=this.keys[key];
}
if(evt["type"]=="keydown"&&dojo.render.html.ie){
switch(evt.keyCode){
case evt.KEY_SHIFT:
case evt.KEY_CTRL:
case evt.KEY_ALT:
case evt.KEY_CAPS_LOCK:
case evt.KEY_LEFT_WINDOW:
case evt.KEY_RIGHT_WINDOW:
case evt.KEY_SELECT:
case evt.KEY_NUM_LOCK:
case evt.KEY_SCROLL_LOCK:
case evt.KEY_NUMPAD_0:
case evt.KEY_NUMPAD_1:
case evt.KEY_NUMPAD_2:
case evt.KEY_NUMPAD_3:
case evt.KEY_NUMPAD_4:
case evt.KEY_NUMPAD_5:
case evt.KEY_NUMPAD_6:
case evt.KEY_NUMPAD_7:
case evt.KEY_NUMPAD_8:
case evt.KEY_NUMPAD_9:
case evt.KEY_NUMPAD_PERIOD:
break;
case evt.KEY_NUMPAD_MULTIPLY:
case evt.KEY_NUMPAD_PLUS:
case evt.KEY_NUMPAD_ENTER:
case evt.KEY_NUMPAD_MINUS:
case evt.KEY_NUMPAD_DIVIDE:
break;
case evt.KEY_PAUSE:
case evt.KEY_TAB:
case evt.KEY_BACKSPACE:
case evt.KEY_ENTER:
case evt.KEY_ESCAPE:
case evt.KEY_PAGE_UP:
case evt.KEY_PAGE_DOWN:
case evt.KEY_END:
case evt.KEY_HOME:
case evt.KEY_LEFT_ARROW:
case evt.KEY_UP_ARROW:
case evt.KEY_RIGHT_ARROW:
case evt.KEY_DOWN_ARROW:
case evt.KEY_INSERT:
case evt.KEY_DELETE:
case evt.KEY_F1:
case evt.KEY_F2:
case evt.KEY_F3:
case evt.KEY_F4:
case evt.KEY_F5:
case evt.KEY_F6:
case evt.KEY_F7:
case evt.KEY_F8:
case evt.KEY_F9:
case evt.KEY_F10:
case evt.KEY_F11:
case evt.KEY_F12:
case evt.KEY_F12:
case evt.KEY_F13:
case evt.KEY_F14:
case evt.KEY_F15:
case evt.KEY_CLEAR:
case evt.KEY_HELP:
evt.key=evt.keyCode;
break;
default:
if(evt.ctrlKey||evt.altKey){
var _232=evt.keyCode;
if(_232>=65&&_232<=90&&evt.shiftKey==false){
_232+=32;
}
if(_232>=1&&_232<=26&&evt.ctrlKey){
_232+=96;
}
evt.key=String.fromCharCode(_232);
}
}
}else{
if(evt["type"]=="keypress"){
if(dojo.render.html.opera){
if(evt.which==0){
evt.key=evt.keyCode;
}else{
if(evt.which>0){
switch(evt.which){
case evt.KEY_SHIFT:
case evt.KEY_CTRL:
case evt.KEY_ALT:
case evt.KEY_CAPS_LOCK:
case evt.KEY_NUM_LOCK:
case evt.KEY_SCROLL_LOCK:
break;
case evt.KEY_PAUSE:
case evt.KEY_TAB:
case evt.KEY_BACKSPACE:
case evt.KEY_ENTER:
case evt.KEY_ESCAPE:
evt.key=evt.which;
break;
default:
var _232=evt.which;
if((evt.ctrlKey||evt.altKey||evt.metaKey)&&(evt.which>=65&&evt.which<=90&&evt.shiftKey==false)){
_232+=32;
}
evt.key=String.fromCharCode(_232);
}
}
}
}else{
if(dojo.render.html.ie){
if(!evt.ctrlKey&&!evt.altKey&&evt.keyCode>=evt.KEY_SPACE){
evt.key=String.fromCharCode(evt.keyCode);
}
}else{
if(dojo.render.html.safari){
switch(evt.keyCode){
case 25:
evt.key=evt.KEY_TAB;
evt.shift=true;
break;
case 63232:
evt.key=evt.KEY_UP_ARROW;
break;
case 63233:
evt.key=evt.KEY_DOWN_ARROW;
break;
case 63234:
evt.key=evt.KEY_LEFT_ARROW;
break;
case 63235:
evt.key=evt.KEY_RIGHT_ARROW;
break;
case 63236:
evt.key=evt.KEY_F1;
break;
case 63237:
evt.key=evt.KEY_F2;
break;
case 63238:
evt.key=evt.KEY_F3;
break;
case 63239:
evt.key=evt.KEY_F4;
break;
case 63240:
evt.key=evt.KEY_F5;
break;
case 63241:
evt.key=evt.KEY_F6;
break;
case 63242:
evt.key=evt.KEY_F7;
break;
case 63243:
evt.key=evt.KEY_F8;
break;
case 63244:
evt.key=evt.KEY_F9;
break;
case 63245:
evt.key=evt.KEY_F10;
break;
case 63246:
evt.key=evt.KEY_F11;
break;
case 63247:
evt.key=evt.KEY_F12;
break;
case 63250:
evt.key=evt.KEY_PAUSE;
break;
case 63272:
evt.key=evt.KEY_DELETE;
break;
case 63273:
evt.key=evt.KEY_HOME;
break;
case 63275:
evt.key=evt.KEY_END;
break;
case 63276:
evt.key=evt.KEY_PAGE_UP;
break;
case 63277:
evt.key=evt.KEY_PAGE_DOWN;
break;
case 63302:
evt.key=evt.KEY_INSERT;
break;
case 63248:
case 63249:
case 63289:
break;
default:
evt.key=evt.charCode>=evt.KEY_SPACE?String.fromCharCode(evt.charCode):evt.keyCode;
}
}else{
evt.key=evt.charCode>0?String.fromCharCode(evt.charCode):evt.keyCode;
}
}
}
}
}
}
if(dojo.render.html.ie){
if(!evt.target){
evt.target=evt.srcElement;
}
if(!evt.currentTarget){
evt.currentTarget=(_230?_230:evt.srcElement);
}
if(!evt.layerX){
evt.layerX=evt.offsetX;
}
if(!evt.layerY){
evt.layerY=evt.offsetY;
}
var doc=(evt.srcElement&&evt.srcElement.ownerDocument)?evt.srcElement.ownerDocument:document;
var _234=((dojo.render.html.ie55)||(doc["compatMode"]=="BackCompat"))?doc.body:doc.documentElement;
if(!evt.pageX){
evt.pageX=evt.clientX+(_234.scrollLeft||0);
}
if(!evt.pageY){
evt.pageY=evt.clientY+(_234.scrollTop||0);
}
if(evt.type=="mouseover"){
evt.relatedTarget=evt.fromElement;
}
if(evt.type=="mouseout"){
evt.relatedTarget=evt.toElement;
}
this.currentEvent=evt;
evt.callListener=this.callListener;
evt.stopPropagation=this._stopPropagation;
evt.preventDefault=this._preventDefault;
}
return evt;
};
this.stopEvent=function(evt){
if(window.event){
evt.cancelBubble=true;
evt.returnValue=false;
}else{
evt.preventDefault();
evt.stopPropagation();
}
};
};
dojo.provide("dojo.event.*");
dojo.provide("dojo.string.common");
dojo.string.trim=function(str,wh){
if(!str.replace){
return str;
}
if(!str.length){
return str;
}
var re=(wh>0)?(/^\s+/):(wh<0)?(/\s+$/):(/^\s+|\s+$/g);
return str.replace(re,"");
};
dojo.string.trimStart=function(str){
return dojo.string.trim(str,1);
};
dojo.string.trimEnd=function(str){
return dojo.string.trim(str,-1);
};
dojo.string.repeat=function(str,_23c,_23d){
var out="";
for(var i=0;i<_23c;i++){
out+=str;
if(_23d&&i<_23c-1){
out+=_23d;
}
}
return out;
};
dojo.string.pad=function(str,len,c,dir){
var out=String(str);
if(!c){
c="0";
}
if(!dir){
dir=1;
}
while(out.length<len){
if(dir>0){
out=c+out;
}else{
out+=c;
}
}
return out;
};
dojo.string.padLeft=function(str,len,c){
return dojo.string.pad(str,len,c,1);
};
dojo.string.padRight=function(str,len,c){
return dojo.string.pad(str,len,c,-1);
};
dojo.provide("dojo.string");
dojo.provide("dojo.io.common");
dojo.io.transports=[];
dojo.io.hdlrFuncNames=["load","error","timeout"];
dojo.io.Request=function(url,_24c,_24d,_24e){
if((arguments.length==1)&&(arguments[0].constructor==Object)){
this.fromKwArgs(arguments[0]);
}else{
this.url=url;
if(_24c){
this.mimetype=_24c;
}
if(_24d){
this.transport=_24d;
}
if(arguments.length>=4){
this.changeUrl=_24e;
}
}
};
dojo.lang.extend(dojo.io.Request,{url:"",mimetype:"text/plain",method:"GET",content:undefined,transport:undefined,changeUrl:undefined,formNode:undefined,sync:false,bindSuccess:false,useCache:false,preventCache:false,load:function(type,data,_251,_252){
},error:function(type,_254,_255,_256){
},timeout:function(type,_258,_259,_25a){
},handle:function(type,data,_25d,_25e){
},timeoutSeconds:0,abort:function(){
},fromKwArgs:function(_25f){
if(_25f["url"]){
_25f.url=_25f.url.toString();
}
if(_25f["formNode"]){
_25f.formNode=dojo.byId(_25f.formNode);
}
if(!_25f["method"]&&_25f["formNode"]&&_25f["formNode"].method){
_25f.method=_25f["formNode"].method;
}
if(!_25f["handle"]&&_25f["handler"]){
_25f.handle=_25f.handler;
}
if(!_25f["load"]&&_25f["loaded"]){
_25f.load=_25f.loaded;
}
if(!_25f["changeUrl"]&&_25f["changeURL"]){
_25f.changeUrl=_25f.changeURL;
}
_25f.encoding=dojo.lang.firstValued(_25f["encoding"],djConfig["bindEncoding"],"");
_25f.sendTransport=dojo.lang.firstValued(_25f["sendTransport"],djConfig["ioSendTransport"],false);
var _260=dojo.lang.isFunction;
for(var x=0;x<dojo.io.hdlrFuncNames.length;x++){
var fn=dojo.io.hdlrFuncNames[x];
if(_25f[fn]&&_260(_25f[fn])){
continue;
}
if(_25f["handle"]&&_260(_25f["handle"])){
_25f[fn]=_25f.handle;
}
}
dojo.lang.mixin(this,_25f);
}});
dojo.io.Error=function(msg,type,num){
this.message=msg;
this.type=type||"unknown";
this.number=num||0;
};
dojo.io.transports.addTransport=function(name){
this.push(name);
this[name]=dojo.io[name];
};
dojo.io.bind=function(_267){
if(!(_267 instanceof dojo.io.Request)){
try{
_267=new dojo.io.Request(_267);
}
catch(e){
dojo.debug(e);
}
}
var _268="";
if(_267["transport"]){
_268=_267["transport"];
if(!this[_268]){
dojo.io.sendBindError(_267,"No dojo.io.bind() transport with name '"+_267["transport"]+"'.");
return _267;
}
if(!this[_268].canHandle(_267)){
dojo.io.sendBindError(_267,"dojo.io.bind() transport with name '"+_267["transport"]+"' cannot handle this type of request.");
return _267;
}
}else{
for(var x=0;x<dojo.io.transports.length;x++){
var tmp=dojo.io.transports[x];
if((this[tmp])&&(this[tmp].canHandle(_267))){
_268=tmp;
break;
}
}
if(_268==""){
dojo.io.sendBindError(_267,"None of the loaded transports for dojo.io.bind()"+" can handle the request.");
return _267;
}
}
this[_268].bind(_267);
_267.bindSuccess=true;
return _267;
};
dojo.io.sendBindError=function(_26b,_26c){
if((typeof _26b.error=="function"||typeof _26b.handle=="function")&&(typeof setTimeout=="function"||typeof setTimeout=="object")){
var _26d=new dojo.io.Error(_26c);
setTimeout(function(){
_26b[(typeof _26b.error=="function")?"error":"handle"]("error",_26d,null,_26b);
},50);
}else{
dojo.raise(_26c);
}
};
dojo.io.queueBind=function(_26e){
if(!(_26e instanceof dojo.io.Request)){
try{
_26e=new dojo.io.Request(_26e);
}
catch(e){
dojo.debug(e);
}
}
var _26f=_26e.load;
_26e.load=function(){
dojo.io._queueBindInFlight=false;
var ret=_26f.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
var _271=_26e.error;
_26e.error=function(){
dojo.io._queueBindInFlight=false;
var ret=_271.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
dojo.io._bindQueue.push(_26e);
dojo.io._dispatchNextQueueBind();
return _26e;
};
dojo.io._dispatchNextQueueBind=function(){
if(!dojo.io._queueBindInFlight){
dojo.io._queueBindInFlight=true;
if(dojo.io._bindQueue.length>0){
dojo.io.bind(dojo.io._bindQueue.shift());
}else{
dojo.io._queueBindInFlight=false;
}
}
};
dojo.io._bindQueue=[];
dojo.io._queueBindInFlight=false;
dojo.io.argsFromMap=function(map,_274,last){
var enc=/utf/i.test(_274||"")?encodeURIComponent:dojo.string.encodeAscii;
var _277=[];
var _278=new Object();
for(var name in map){
var _27a=function(elt){
var val=enc(name)+"="+enc(elt);
_277[(last==name)?"push":"unshift"](val);
};
if(!_278[name]){
var _27d=map[name];
if(dojo.lang.isArray(_27d)){
dojo.lang.forEach(_27d,_27a);
}else{
_27a(_27d);
}
}
}
return _277.join("&");
};
dojo.io.setIFrameSrc=function(_27e,src,_280){
try{
var r=dojo.render.html;
if(!_280){
if(r.safari){
_27e.location=src;
}else{
frames[_27e.name].location=src;
}
}else{
var idoc;
if(r.ie){
idoc=_27e.contentWindow.document;
}else{
if(r.safari){
idoc=_27e.document;
}else{
idoc=_27e.contentWindow;
}
}
if(!idoc){
_27e.location=src;
return;
}else{
idoc.location.replace(src);
}
}
}
catch(e){
dojo.debug(e);
dojo.debug("setIFrameSrc: "+e);
}
};
dojo.provide("dojo.string.extras");
dojo.string.substituteParams=function(_283,hash){
var map=(typeof hash=="object")?hash:dojo.lang.toArray(arguments,1);
return _283.replace(/\%\{(\w+)\}/g,function(_286,key){
if(typeof (map[key])!="undefined"&&map[key]!=null){
return map[key];
}
dojo.raise("Substitution not found: "+key);
});
};
dojo.string.capitalize=function(str){
if(!dojo.lang.isString(str)){
return "";
}
if(arguments.length==0){
str=this;
}
var _289=str.split(" ");
for(var i=0;i<_289.length;i++){
_289[i]=_289[i].charAt(0).toUpperCase()+_289[i].substring(1);
}
return _289.join(" ");
};
dojo.string.isBlank=function(str){
if(!dojo.lang.isString(str)){
return true;
}
return (dojo.string.trim(str).length==0);
};
dojo.string.encodeAscii=function(str){
if(!dojo.lang.isString(str)){
return str;
}
var ret="";
var _28e=escape(str);
var _28f,re=/%u([0-9A-F]{4})/i;
while((_28f=_28e.match(re))){
var num=Number("0x"+_28f[1]);
var _292=escape("&#"+num+";");
ret+=_28e.substring(0,_28f.index)+_292;
_28e=_28e.substring(_28f.index+_28f[0].length);
}
ret+=_28e.replace(/\+/g,"%2B");
return ret;
};
dojo.string.escape=function(type,str){
var args=dojo.lang.toArray(arguments,1);
switch(type.toLowerCase()){
case "xml":
case "html":
case "xhtml":
return dojo.string.escapeXml.apply(this,args);
case "sql":
return dojo.string.escapeSql.apply(this,args);
case "regexp":
case "regex":
return dojo.string.escapeRegExp.apply(this,args);
case "javascript":
case "jscript":
case "js":
return dojo.string.escapeJavaScript.apply(this,args);
case "ascii":
return dojo.string.encodeAscii.apply(this,args);
default:
return str;
}
};
dojo.string.escapeXml=function(str,_297){
str=str.replace(/&/gm,"&amp;").replace(/</gm,"&lt;").replace(/>/gm,"&gt;").replace(/"/gm,"&quot;");
if(!_297){
str=str.replace(/'/gm,"&#39;");
}
return str;
};
dojo.string.escapeSql=function(str){
return str.replace(/'/gm,"''");
};
dojo.string.escapeRegExp=function(str){
return str.replace(/\\/gm,"\\\\").replace(/([\f\b\n\t\r[\^$|?*+(){}])/gm,"\\$1");
};
dojo.string.escapeJavaScript=function(str){
return str.replace(/(["'\f\b\n\t\r])/gm,"\\$1");
};
dojo.string.escapeString=function(str){
return ("\""+str.replace(/(["\\])/g,"\\$1")+"\"").replace(/[\f]/g,"\\f").replace(/[\b]/g,"\\b").replace(/[\n]/g,"\\n").replace(/[\t]/g,"\\t").replace(/[\r]/g,"\\r");
};
dojo.string.summary=function(str,len){
if(!len||str.length<=len){
return str;
}
return str.substring(0,len).replace(/\.+$/,"")+"...";
};
dojo.string.endsWith=function(str,end,_2a0){
if(_2a0){
str=str.toLowerCase();
end=end.toLowerCase();
}
if((str.length-end.length)<0){
return false;
}
return str.lastIndexOf(end)==str.length-end.length;
};
dojo.string.endsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.endsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.startsWith=function(str,_2a4,_2a5){
if(_2a5){
str=str.toLowerCase();
_2a4=_2a4.toLowerCase();
}
return str.indexOf(_2a4)==0;
};
dojo.string.startsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.startsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.has=function(str){
for(var i=1;i<arguments.length;i++){
if(str.indexOf(arguments[i])>-1){
return true;
}
}
return false;
};
dojo.string.normalizeNewlines=function(text,_2ab){
if(_2ab=="\n"){
text=text.replace(/\r\n/g,"\n");
text=text.replace(/\r/g,"\n");
}else{
if(_2ab=="\r"){
text=text.replace(/\r\n/g,"\r");
text=text.replace(/\n/g,"\r");
}else{
text=text.replace(/([^\r])\n/g,"$1\r\n").replace(/\r([^\n])/g,"\r\n$1");
}
}
return text;
};
dojo.string.splitEscaped=function(str,_2ad){
var _2ae=[];
for(var i=0,_2b0=0;i<str.length;i++){
if(str.charAt(i)=="\\"){
i++;
continue;
}
if(str.charAt(i)==_2ad){
_2ae.push(str.substring(_2b0,i));
_2b0=i+1;
}
}
_2ae.push(str.substr(_2b0));
return _2ae;
};
dojo.provide("dojo.dom");
dojo.dom.ELEMENT_NODE=1;
dojo.dom.ATTRIBUTE_NODE=2;
dojo.dom.TEXT_NODE=3;
dojo.dom.CDATA_SECTION_NODE=4;
dojo.dom.ENTITY_REFERENCE_NODE=5;
dojo.dom.ENTITY_NODE=6;
dojo.dom.PROCESSING_INSTRUCTION_NODE=7;
dojo.dom.COMMENT_NODE=8;
dojo.dom.DOCUMENT_NODE=9;
dojo.dom.DOCUMENT_TYPE_NODE=10;
dojo.dom.DOCUMENT_FRAGMENT_NODE=11;
dojo.dom.NOTATION_NODE=12;
dojo.dom.dojoml="http://www.dojotoolkit.org/2004/dojoml";
dojo.dom.xmlns={svg:"http://www.w3.org/2000/svg",smil:"http://www.w3.org/2001/SMIL20/",mml:"http://www.w3.org/1998/Math/MathML",cml:"http://www.xml-cml.org",xlink:"http://www.w3.org/1999/xlink",xhtml:"http://www.w3.org/1999/xhtml",xul:"http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul",xbl:"http://www.mozilla.org/xbl",fo:"http://www.w3.org/1999/XSL/Format",xsl:"http://www.w3.org/1999/XSL/Transform",xslt:"http://www.w3.org/1999/XSL/Transform",xi:"http://www.w3.org/2001/XInclude",xforms:"http://www.w3.org/2002/01/xforms",saxon:"http://icl.com/saxon",xalan:"http://xml.apache.org/xslt",xsd:"http://www.w3.org/2001/XMLSchema",dt:"http://www.w3.org/2001/XMLSchema-datatypes",xsi:"http://www.w3.org/2001/XMLSchema-instance",rdf:"http://www.w3.org/1999/02/22-rdf-syntax-ns#",rdfs:"http://www.w3.org/2000/01/rdf-schema#",dc:"http://purl.org/dc/elements/1.1/",dcq:"http://purl.org/dc/qualifiers/1.0","soap-env":"http://schemas.xmlsoap.org/soap/envelope/",wsdl:"http://schemas.xmlsoap.org/wsdl/",AdobeExtensions:"http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/"};
dojo.dom.isNode=function(wh){
if(typeof Element=="function"){
try{
return wh instanceof Element;
}
catch(e){
}
}else{
return wh&&!isNaN(wh.nodeType);
}
};
dojo.dom.getUniqueId=function(){
var _2b2=dojo.doc();
do{
var id="dj_unique_"+(++arguments.callee._idIncrement);
}while(_2b2.getElementById(id));
return id;
};
dojo.dom.getUniqueId._idIncrement=0;
dojo.dom.firstElement=dojo.dom.getFirstChildElement=function(_2b4,_2b5){
var node=_2b4.firstChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.nextSibling;
}
if(_2b5&&node&&node.tagName&&node.tagName.toLowerCase()!=_2b5.toLowerCase()){
node=dojo.dom.nextElement(node,_2b5);
}
return node;
};
dojo.dom.lastElement=dojo.dom.getLastChildElement=function(_2b7,_2b8){
var node=_2b7.lastChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.previousSibling;
}
if(_2b8&&node&&node.tagName&&node.tagName.toLowerCase()!=_2b8.toLowerCase()){
node=dojo.dom.prevElement(node,_2b8);
}
return node;
};
dojo.dom.nextElement=dojo.dom.getNextSiblingElement=function(node,_2bb){
if(!node){
return null;
}
do{
node=node.nextSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_2bb&&_2bb.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.nextElement(node,_2bb);
}
return node;
};
dojo.dom.prevElement=dojo.dom.getPreviousSiblingElement=function(node,_2bd){
if(!node){
return null;
}
if(_2bd){
_2bd=_2bd.toLowerCase();
}
do{
node=node.previousSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_2bd&&_2bd.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.prevElement(node,_2bd);
}
return node;
};
dojo.dom.moveChildren=function(_2be,_2bf,trim){
var _2c1=0;
if(trim){
while(_2be.hasChildNodes()&&_2be.firstChild.nodeType==dojo.dom.TEXT_NODE){
_2be.removeChild(_2be.firstChild);
}
while(_2be.hasChildNodes()&&_2be.lastChild.nodeType==dojo.dom.TEXT_NODE){
_2be.removeChild(_2be.lastChild);
}
}
while(_2be.hasChildNodes()){
_2bf.appendChild(_2be.firstChild);
_2c1++;
}
return _2c1;
};
dojo.dom.copyChildren=function(_2c2,_2c3,trim){
var _2c5=_2c2.cloneNode(true);
return this.moveChildren(_2c5,_2c3,trim);
};
dojo.dom.replaceChildren=function(node,_2c7){
var _2c8=[];
if(dojo.render.html.ie){
for(var i=0;i<node.childNodes.length;i++){
_2c8.push(node.childNodes[i]);
}
}
dojo.dom.removeChildren(node);
node.appendChild(_2c7);
for(var i=0;i<_2c8.length;i++){
dojo.dom.destroyNode(_2c8[i]);
}
};
dojo.dom.removeChildren=function(node){
var _2cb=node.childNodes.length;
while(node.hasChildNodes()){
dojo.dom.removeNode(node.firstChild);
}
return _2cb;
};
dojo.dom.replaceNode=function(node,_2cd){
return node.parentNode.replaceChild(_2cd,node);
};
dojo.dom.destroyNode=function(node){
if(node.parentNode){
node=dojo.dom.removeNode(node);
}
if(node.nodeType!=3){
if(dojo.evalObjPath("dojo.event.browser.clean",false)){
dojo.event.browser.clean(node);
}
if(dojo.render.html.ie){
node.outerHTML="";
}
}
};
dojo.dom.removeNode=function(node){
if(node&&node.parentNode){
return node.parentNode.removeChild(node);
}
};
dojo.dom.getAncestors=function(node,_2d1,_2d2){
var _2d3=[];
var _2d4=(_2d1&&(_2d1 instanceof Function||typeof _2d1=="function"));
while(node){
if(!_2d4||_2d1(node)){
_2d3.push(node);
}
if(_2d2&&_2d3.length>0){
return _2d3[0];
}
node=node.parentNode;
}
if(_2d2){
return null;
}
return _2d3;
};
dojo.dom.getAncestorsByTag=function(node,tag,_2d7){
tag=tag.toLowerCase();
return dojo.dom.getAncestors(node,function(el){
return ((el.tagName)&&(el.tagName.toLowerCase()==tag));
},_2d7);
};
dojo.dom.getFirstAncestorByTag=function(node,tag){
return dojo.dom.getAncestorsByTag(node,tag,true);
};
dojo.dom.isDescendantOf=function(node,_2dc,_2dd){
if(_2dd&&node){
node=node.parentNode;
}
while(node){
if(node==_2dc){
return true;
}
node=node.parentNode;
}
return false;
};
dojo.dom.innerXML=function(node){
if(node.innerXML){
return node.innerXML;
}else{
if(node.xml){
return node.xml;
}else{
if(typeof XMLSerializer!="undefined"){
return (new XMLSerializer()).serializeToString(node);
}
}
}
};
dojo.dom.createDocument=function(){
var doc=null;
var _2e0=dojo.doc();
if(!dj_undef("ActiveXObject")){
var _2e1=["MSXML2","Microsoft","MSXML","MSXML3"];
for(var i=0;i<_2e1.length;i++){
try{
doc=new ActiveXObject(_2e1[i]+".XMLDOM");
}
catch(e){
}
if(doc){
break;
}
}
}else{
if((_2e0.implementation)&&(_2e0.implementation.createDocument)){
doc=_2e0.implementation.createDocument("","",null);
}
}
return doc;
};
dojo.dom.createDocumentFromText=function(str,_2e4){
if(!_2e4){
_2e4="text/xml";
}
if(!dj_undef("DOMParser")){
var _2e5=new DOMParser();
return _2e5.parseFromString(str,_2e4);
}else{
if(!dj_undef("ActiveXObject")){
var _2e6=dojo.dom.createDocument();
if(_2e6){
_2e6.async=false;
_2e6.loadXML(str);
return _2e6;
}else{
dojo.debug("toXml didn't work?");
}
}else{
var _2e7=dojo.doc();
if(_2e7.createElement){
var tmp=_2e7.createElement("xml");
tmp.innerHTML=str;
if(_2e7.implementation&&_2e7.implementation.createDocument){
var _2e9=_2e7.implementation.createDocument("foo","",null);
for(var i=0;i<tmp.childNodes.length;i++){
_2e9.importNode(tmp.childNodes.item(i),true);
}
return _2e9;
}
return ((tmp.document)&&(tmp.document.firstChild?tmp.document.firstChild:tmp));
}
}
}
return null;
};
dojo.dom.prependChild=function(node,_2ec){
if(_2ec.firstChild){
_2ec.insertBefore(node,_2ec.firstChild);
}else{
_2ec.appendChild(node);
}
return true;
};
dojo.dom.insertBefore=function(node,ref,_2ef){
if((_2ef!=true)&&(node===ref||node.nextSibling===ref)){
return false;
}
var _2f0=ref.parentNode;
_2f0.insertBefore(node,ref);
return true;
};
dojo.dom.insertAfter=function(node,ref,_2f3){
var pn=ref.parentNode;
if(ref==pn.lastChild){
if((_2f3!=true)&&(node===ref)){
return false;
}
pn.appendChild(node);
}else{
return this.insertBefore(node,ref.nextSibling,_2f3);
}
return true;
};
dojo.dom.insertAtPosition=function(node,ref,_2f7){
if((!node)||(!ref)||(!_2f7)){
return false;
}
switch(_2f7.toLowerCase()){
case "before":
return dojo.dom.insertBefore(node,ref);
case "after":
return dojo.dom.insertAfter(node,ref);
case "first":
if(ref.firstChild){
return dojo.dom.insertBefore(node,ref.firstChild);
}else{
ref.appendChild(node);
return true;
}
break;
default:
ref.appendChild(node);
return true;
}
};
dojo.dom.insertAtIndex=function(node,_2f9,_2fa){
var _2fb=_2f9.childNodes;
if(!_2fb.length||_2fb.length==_2fa){
_2f9.appendChild(node);
return true;
}
if(_2fa==0){
return dojo.dom.prependChild(node,_2f9);
}
return dojo.dom.insertAfter(node,_2fb[_2fa-1]);
};
dojo.dom.textContent=function(node,text){
if(arguments.length>1){
var _2fe=dojo.doc();
dojo.dom.replaceChildren(node,_2fe.createTextNode(text));
return text;
}else{
if(node.textContent!=undefined){
return node.textContent;
}
var _2ff="";
if(node==null){
return _2ff;
}
for(var i=0;i<node.childNodes.length;i++){
switch(node.childNodes[i].nodeType){
case 1:
case 5:
_2ff+=dojo.dom.textContent(node.childNodes[i]);
break;
case 3:
case 2:
case 4:
_2ff+=node.childNodes[i].nodeValue;
break;
default:
break;
}
}
return _2ff;
}
};
dojo.dom.hasParent=function(node){
return Boolean(node&&node.parentNode&&dojo.dom.isNode(node.parentNode));
};
dojo.dom.isTag=function(node){
if(node&&node.tagName){
for(var i=1;i<arguments.length;i++){
if(node.tagName==String(arguments[i])){
return String(arguments[i]);
}
}
}
return "";
};
dojo.dom.setAttributeNS=function(elem,_305,_306,_307){
if(elem==null||((elem==undefined)&&(typeof elem=="undefined"))){
dojo.raise("No element given to dojo.dom.setAttributeNS");
}
if(!((elem.setAttributeNS==undefined)&&(typeof elem.setAttributeNS=="undefined"))){
elem.setAttributeNS(_305,_306,_307);
}else{
var _308=elem.ownerDocument;
var _309=_308.createNode(2,_306,_305);
_309.nodeValue=_307;
elem.setAttributeNode(_309);
}
};
dojo.provide("dojo.undo.browser");
try{
if((!djConfig["preventBackButtonFix"])&&(!dojo.hostenv.post_load_)){
document.write("<iframe style='border: 0px; width: 1px; height: 1px; position: absolute; bottom: 0px; right: 0px; visibility: visible;' name='djhistory' id='djhistory' src='"+(dojo.hostenv.getBaseScriptUri()+"iframe_history.html")+"'></iframe>");
}
}
catch(e){
}
if(dojo.render.html.opera){
dojo.debug("Opera is not supported with dojo.undo.browser, so back/forward detection will not work.");
}
dojo.undo.browser={initialHref:(!dj_undef("window"))?window.location.href:"",initialHash:(!dj_undef("window"))?window.location.hash:"",moveForward:false,historyStack:[],forwardStack:[],historyIframe:null,bookmarkAnchor:null,locationTimer:null,setInitialState:function(args){
this.initialState=this._createState(this.initialHref,args,this.initialHash);
},addToHistory:function(args){
this.forwardStack=[];
var hash=null;
var url=null;
if(!this.historyIframe){
this.historyIframe=window.frames["djhistory"];
}
if(!this.bookmarkAnchor){
this.bookmarkAnchor=document.createElement("a");
dojo.body().appendChild(this.bookmarkAnchor);
this.bookmarkAnchor.style.display="none";
}
if(args["changeUrl"]){
hash="#"+((args["changeUrl"]!==true)?args["changeUrl"]:(new Date()).getTime());
if(this.historyStack.length==0&&this.initialState.urlHash==hash){
this.initialState=this._createState(url,args,hash);
return;
}else{
if(this.historyStack.length>0&&this.historyStack[this.historyStack.length-1].urlHash==hash){
this.historyStack[this.historyStack.length-1]=this._createState(url,args,hash);
return;
}
}
this.changingUrl=true;
setTimeout("window.location.href = '"+hash+"'; dojo.undo.browser.changingUrl = false;",1);
this.bookmarkAnchor.href=hash;
if(dojo.render.html.ie){
url=this._loadIframeHistory();
var _30e=args["back"]||args["backButton"]||args["handle"];
var tcb=function(_310){
if(window.location.hash!=""){
setTimeout("window.location.href = '"+hash+"';",1);
}
_30e.apply(this,[_310]);
};
if(args["back"]){
args.back=tcb;
}else{
if(args["backButton"]){
args.backButton=tcb;
}else{
if(args["handle"]){
args.handle=tcb;
}
}
}
var _311=args["forward"]||args["forwardButton"]||args["handle"];
var tfw=function(_313){
if(window.location.hash!=""){
window.location.href=hash;
}
if(_311){
_311.apply(this,[_313]);
}
};
if(args["forward"]){
args.forward=tfw;
}else{
if(args["forwardButton"]){
args.forwardButton=tfw;
}else{
if(args["handle"]){
args.handle=tfw;
}
}
}
}else{
if(dojo.render.html.moz){
if(!this.locationTimer){
this.locationTimer=setInterval("dojo.undo.browser.checkLocation();",200);
}
}
}
}else{
url=this._loadIframeHistory();
}
this.historyStack.push(this._createState(url,args,hash));
},checkLocation:function(){
if(!this.changingUrl){
var hsl=this.historyStack.length;
if((window.location.hash==this.initialHash||window.location.href==this.initialHref)&&(hsl==1)){
this.handleBackButton();
return;
}
if(this.forwardStack.length>0){
if(this.forwardStack[this.forwardStack.length-1].urlHash==window.location.hash){
this.handleForwardButton();
return;
}
}
if((hsl>=2)&&(this.historyStack[hsl-2])){
if(this.historyStack[hsl-2].urlHash==window.location.hash){
this.handleBackButton();
return;
}
}
}
},iframeLoaded:function(evt,_316){
if(!dojo.render.html.opera){
var _317=this._getUrlQuery(_316.href);
if(_317==null){
if(this.historyStack.length==1){
this.handleBackButton();
}
return;
}
if(this.moveForward){
this.moveForward=false;
return;
}
if(this.historyStack.length>=2&&_317==this._getUrlQuery(this.historyStack[this.historyStack.length-2].url)){
this.handleBackButton();
}else{
if(this.forwardStack.length>0&&_317==this._getUrlQuery(this.forwardStack[this.forwardStack.length-1].url)){
this.handleForwardButton();
}
}
}
},handleBackButton:function(){
var _318=this.historyStack.pop();
if(!_318){
return;
}
var last=this.historyStack[this.historyStack.length-1];
if(!last&&this.historyStack.length==0){
last=this.initialState;
}
if(last){
if(last.kwArgs["back"]){
last.kwArgs["back"]();
}else{
if(last.kwArgs["backButton"]){
last.kwArgs["backButton"]();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("back");
}
}
}
}
this.forwardStack.push(_318);
},handleForwardButton:function(){
var last=this.forwardStack.pop();
if(!last){
return;
}
if(last.kwArgs["forward"]){
last.kwArgs.forward();
}else{
if(last.kwArgs["forwardButton"]){
last.kwArgs.forwardButton();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("forward");
}
}
}
this.historyStack.push(last);
},_createState:function(url,args,hash){
return {"url":url,"kwArgs":args,"urlHash":hash};
},_getUrlQuery:function(url){
var _31f=url.split("?");
if(_31f.length<2){
return null;
}else{
return _31f[1];
}
},_loadIframeHistory:function(){
var url=dojo.hostenv.getBaseScriptUri()+"iframe_history.html?"+(new Date()).getTime();
this.moveForward=true;
dojo.io.setIFrameSrc(this.historyIframe,url,false);
return url;
}};
dojo.provide("dojo.io.BrowserIO");
if(!dj_undef("window")){
dojo.io.checkChildrenForFile=function(node){
var _322=false;
var _323=node.getElementsByTagName("input");
dojo.lang.forEach(_323,function(_324){
if(_322){
return;
}
if(_324.getAttribute("type")=="file"){
_322=true;
}
});
return _322;
};
dojo.io.formHasFile=function(_325){
return dojo.io.checkChildrenForFile(_325);
};
dojo.io.updateNode=function(node,_327){
node=dojo.byId(node);
var args=_327;
if(dojo.lang.isString(_327)){
args={url:_327};
}
args.mimetype="text/html";
args.load=function(t,d,e){
while(node.firstChild){
dojo.dom.destroyNode(node.firstChild);
}
node.innerHTML=d;
};
dojo.io.bind(args);
};
dojo.io.formFilter=function(node){
var type=(node.type||"").toLowerCase();
return !node.disabled&&node.name&&!dojo.lang.inArray(["file","submit","image","reset","button"],type);
};
dojo.io.encodeForm=function(_32e,_32f,_330){
if((!_32e)||(!_32e.tagName)||(!_32e.tagName.toLowerCase()=="form")){
dojo.raise("Attempted to encode a non-form element.");
}
if(!_330){
_330=dojo.io.formFilter;
}
var enc=/utf/i.test(_32f||"")?encodeURIComponent:dojo.string.encodeAscii;
var _332=[];
for(var i=0;i<_32e.elements.length;i++){
var elm=_32e.elements[i];
if(!elm||elm.tagName.toLowerCase()=="fieldset"||!_330(elm)){
continue;
}
var name=enc(elm.name);
var type=elm.type.toLowerCase();
if(type=="select-multiple"){
for(var j=0;j<elm.options.length;j++){
if(elm.options[j].selected){
_332.push(name+"="+enc(elm.options[j].value));
}
}
}else{
if(dojo.lang.inArray(["radio","checkbox"],type)){
if(elm.checked){
_332.push(name+"="+enc(elm.value));
}
}else{
_332.push(name+"="+enc(elm.value));
}
}
}
var _338=_32e.getElementsByTagName("input");
for(var i=0;i<_338.length;i++){
var _339=_338[i];
if(_339.type.toLowerCase()=="image"&&_339.form==_32e&&_330(_339)){
var name=enc(_339.name);
_332.push(name+"="+enc(_339.value));
_332.push(name+".x=0");
_332.push(name+".y=0");
}
}
return _332.join("&")+"&";
};
dojo.io.FormBind=function(args){
this.bindArgs={};
if(args&&args.formNode){
this.init(args);
}else{
if(args){
this.init({formNode:args});
}
}
};
dojo.lang.extend(dojo.io.FormBind,{form:null,bindArgs:null,clickedButton:null,init:function(args){
var form=dojo.byId(args.formNode);
if(!form||!form.tagName||form.tagName.toLowerCase()!="form"){
throw new Error("FormBind: Couldn't apply, invalid form");
}else{
if(this.form==form){
return;
}else{
if(this.form){
throw new Error("FormBind: Already applied to a form");
}
}
}
dojo.lang.mixin(this.bindArgs,args);
this.form=form;
this.connect(form,"onsubmit","submit");
for(var i=0;i<form.elements.length;i++){
var node=form.elements[i];
if(node&&node.type&&dojo.lang.inArray(["submit","button"],node.type.toLowerCase())){
this.connect(node,"onclick","click");
}
}
var _33f=form.getElementsByTagName("input");
for(var i=0;i<_33f.length;i++){
var _340=_33f[i];
if(_340.type.toLowerCase()=="image"&&_340.form==form){
this.connect(_340,"onclick","click");
}
}
},onSubmit:function(form){
return true;
},submit:function(e){
e.preventDefault();
if(this.onSubmit(this.form)){
dojo.io.bind(dojo.lang.mixin(this.bindArgs,{formFilter:dojo.lang.hitch(this,"formFilter")}));
}
},click:function(e){
var node=e.currentTarget;
if(node.disabled){
return;
}
this.clickedButton=node;
},formFilter:function(node){
var type=(node.type||"").toLowerCase();
var _347=false;
if(node.disabled||!node.name){
_347=false;
}else{
if(dojo.lang.inArray(["submit","button","image"],type)){
if(!this.clickedButton){
this.clickedButton=node;
}
_347=node==this.clickedButton;
}else{
_347=!dojo.lang.inArray(["file","submit","reset","button"],type);
}
}
return _347;
},connect:function(_348,_349,_34a){
if(dojo.evalObjPath("dojo.event.connect")){
dojo.event.connect(_348,_349,this,_34a);
}else{
var fcn=dojo.lang.hitch(this,_34a);
_348[_349]=function(e){
if(!e){
e=window.event;
}
if(!e.currentTarget){
e.currentTarget=e.srcElement;
}
if(!e.preventDefault){
e.preventDefault=function(){
window.event.returnValue=false;
};
}
fcn(e);
};
}
}});
dojo.io.XMLHTTPTransport=new function(){
var _34d=this;
var _34e={};
this.useCache=false;
this.preventCache=false;
function getCacheKey(url,_350,_351){
return url+"|"+_350+"|"+_351.toLowerCase();
}
function addToCache(url,_353,_354,http){
_34e[getCacheKey(url,_353,_354)]=http;
}
function getFromCache(url,_357,_358){
return _34e[getCacheKey(url,_357,_358)];
}
this.clearCache=function(){
_34e={};
};
function doLoad(_359,http,url,_35c,_35d){
if(((http.status>=200)&&(http.status<300))||(http.status==304)||(location.protocol=="file:"&&(http.status==0||http.status==undefined))||(location.protocol=="chrome:"&&(http.status==0||http.status==undefined))){
var ret;
if(_359.method.toLowerCase()=="head"){
var _35f=http.getAllResponseHeaders();
ret={};
ret.toString=function(){
return _35f;
};
var _360=_35f.split(/[\r\n]+/g);
for(var i=0;i<_360.length;i++){
var pair=_360[i].match(/^([^:]+)\s*:\s*(.+)$/i);
if(pair){
ret[pair[1]]=pair[2];
}
}
}else{
if(_359.mimetype=="text/javascript"){
try{
ret=dj_eval(http.responseText);
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=null;
}
}else{
if(_359.mimetype=="text/json"||_359.mimetype=="application/json"){
try{
ret=dj_eval("("+http.responseText+")");
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=false;
}
}else{
if((_359.mimetype=="application/xml")||(_359.mimetype=="text/xml")){
ret=http.responseXML;
if(!ret||typeof ret=="string"||!http.getResponseHeader("Content-Type")){
ret=dojo.dom.createDocumentFromText(http.responseText);
}
}else{
ret=http.responseText;
}
}
}
}
if(_35d){
addToCache(url,_35c,_359.method,http);
}
_359[(typeof _359.load=="function")?"load":"handle"]("load",ret,http,_359);
}else{
var _363=new dojo.io.Error("XMLHttpTransport Error: "+http.status+" "+http.statusText);
_359[(typeof _359.error=="function")?"error":"handle"]("error",_363,http,_359);
}
}
function setHeaders(http,_365){
if(_365["headers"]){
for(var _366 in _365["headers"]){
if(_366.toLowerCase()=="content-type"&&!_365["contentType"]){
_365["contentType"]=_365["headers"][_366];
}else{
http.setRequestHeader(_366,_365["headers"][_366]);
}
}
}
}
this.inFlight=[];
this.inFlightTimer=null;
this.startWatchingInFlight=function(){
if(!this.inFlightTimer){
this.inFlightTimer=setTimeout("dojo.io.XMLHTTPTransport.watchInFlight();",10);
}
};
this.watchInFlight=function(){
var now=null;
if(!dojo.hostenv._blockAsync&&!_34d._blockAsync){
for(var x=this.inFlight.length-1;x>=0;x--){
try{
var tif=this.inFlight[x];
if(!tif||tif.http._aborted||!tif.http.readyState){
this.inFlight.splice(x,1);
continue;
}
if(4==tif.http.readyState){
this.inFlight.splice(x,1);
doLoad(tif.req,tif.http,tif.url,tif.query,tif.useCache);
}else{
if(tif.startTime){
if(!now){
now=(new Date()).getTime();
}
if(tif.startTime+(tif.req.timeoutSeconds*1000)<now){
if(typeof tif.http.abort=="function"){
tif.http.abort();
}
this.inFlight.splice(x,1);
tif.req[(typeof tif.req.timeout=="function")?"timeout":"handle"]("timeout",null,tif.http,tif.req);
}
}
}
}
catch(e){
try{
var _36a=new dojo.io.Error("XMLHttpTransport.watchInFlight Error: "+e);
tif.req[(typeof tif.req.error=="function")?"error":"handle"]("error",_36a,tif.http,tif.req);
}
catch(e2){
dojo.debug("XMLHttpTransport error callback failed: "+e2);
}
}
}
}
clearTimeout(this.inFlightTimer);
if(this.inFlight.length==0){
this.inFlightTimer=null;
return;
}
this.inFlightTimer=setTimeout("dojo.io.XMLHTTPTransport.watchInFlight();",10);
};
var _36b=dojo.hostenv.getXmlhttpObject()?true:false;
this.canHandle=function(_36c){
return _36b&&dojo.lang.inArray(["text/plain","text/html","application/xml","text/xml","text/javascript","text/json","application/json"],(_36c["mimetype"].toLowerCase()||""))&&!(_36c["formNode"]&&dojo.io.formHasFile(_36c["formNode"]));
};
this.multipartBoundary="45309FFF-BD65-4d50-99C9-36986896A96F";
this.bind=function(_36d){
if(!_36d["url"]){
if(!_36d["formNode"]&&(_36d["backButton"]||_36d["back"]||_36d["changeUrl"]||_36d["watchForURL"])&&(!djConfig.preventBackButtonFix)){
dojo.deprecated("Using dojo.io.XMLHTTPTransport.bind() to add to browser history without doing an IO request","Use dojo.undo.browser.addToHistory() instead.","0.4");
dojo.undo.browser.addToHistory(_36d);
return true;
}
}
var url=_36d.url;
var _36f="";
if(_36d["formNode"]){
var ta=_36d.formNode.getAttribute("action");
if((ta)&&(!_36d["url"])){
url=ta;
}
var tp=_36d.formNode.getAttribute("method");
if((tp)&&(!_36d["method"])){
_36d.method=tp;
}
_36f+=dojo.io.encodeForm(_36d.formNode,_36d.encoding,_36d["formFilter"]);
}
if(url.indexOf("#")>-1){
dojo.debug("Warning: dojo.io.bind: stripping hash values from url:",url);
url=url.split("#")[0];
}
if(_36d["file"]){
_36d.method="post";
}
if(!_36d["method"]){
_36d.method="get";
}
if(_36d.method.toLowerCase()=="get"){
_36d.multipart=false;
}else{
if(_36d["file"]){
_36d.multipart=true;
}else{
if(!_36d["multipart"]){
_36d.multipart=false;
}
}
}
if(_36d["backButton"]||_36d["back"]||_36d["changeUrl"]){
dojo.undo.browser.addToHistory(_36d);
}
var _372=_36d["content"]||{};
if(_36d.sendTransport){
_372["dojo.transport"]="xmlhttp";
}
do{
if(_36d.postContent){
_36f=_36d.postContent;
break;
}
if(_372){
_36f+=dojo.io.argsFromMap(_372,_36d.encoding);
}
if(_36d.method.toLowerCase()=="get"||!_36d.multipart){
break;
}
var t=[];
if(_36f.length){
var q=_36f.split("&");
for(var i=0;i<q.length;++i){
if(q[i].length){
var p=q[i].split("=");
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+p[0]+"\"","",p[1]);
}
}
}
if(_36d.file){
if(dojo.lang.isArray(_36d.file)){
for(var i=0;i<_36d.file.length;++i){
var o=_36d.file[i];
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}else{
var o=_36d.file;
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}
if(t.length){
t.push("--"+this.multipartBoundary+"--","");
_36f=t.join("\r\n");
}
}while(false);
var _378=_36d["sync"]?false:true;
var _379=_36d["preventCache"]||(this.preventCache==true&&_36d["preventCache"]!=false);
var _37a=_36d["useCache"]==true||(this.useCache==true&&_36d["useCache"]!=false);
if(!_379&&_37a){
var _37b=getFromCache(url,_36f,_36d.method);
if(_37b){
doLoad(_36d,_37b,url,_36f,false);
return;
}
}
var http=dojo.hostenv.getXmlhttpObject(_36d);
var _37d=false;
if(_378){
var _37e=this.inFlight.push({"req":_36d,"http":http,"url":url,"query":_36f,"useCache":_37a,"startTime":_36d.timeoutSeconds?(new Date()).getTime():0});
this.startWatchingInFlight();
}else{
_34d._blockAsync=true;
}
if(_36d.method.toLowerCase()=="post"){
if(!_36d.user){
http.open("POST",url,_378);
}else{
http.open("POST",url,_378,_36d.user,_36d.password);
}
setHeaders(http,_36d);
http.setRequestHeader("Content-Type",_36d.multipart?("multipart/form-data; boundary="+this.multipartBoundary):(_36d.contentType||"application/x-www-form-urlencoded"));
try{
http.send(_36f);
}
catch(e){
if(typeof http.abort=="function"){
http.abort();
}
doLoad(_36d,{status:404},url,_36f,_37a);
}
}else{
var _37f=url;
if(_36f!=""){
_37f+=(_37f.indexOf("?")>-1?"&":"?")+_36f;
}
if(_379){
_37f+=(dojo.string.endsWithAny(_37f,"?","&")?"":(_37f.indexOf("?")>-1?"&":"?"))+"dojo.preventCache="+new Date().valueOf();
}
if(!_36d.user){
http.open(_36d.method.toUpperCase(),_37f,_378);
}else{
http.open(_36d.method.toUpperCase(),_37f,_378,_36d.user,_36d.password);
}
setHeaders(http,_36d);
try{
http.send(null);
}
catch(e){
if(typeof http.abort=="function"){
http.abort();
}
doLoad(_36d,{status:404},url,_36f,_37a);
}
}
if(!_378){
doLoad(_36d,http,url,_36f,_37a);
_34d._blockAsync=false;
}
_36d.abort=function(){
try{
http._aborted=true;
}
catch(e){
}
return http.abort();
};
return;
};
dojo.io.transports.addTransport("XMLHTTPTransport");
};
}
dojo.provide("dojo.io.cookie");
dojo.io.cookie.setCookie=function(name,_381,days,path,_384,_385){
var _386=-1;
if((typeof days=="number")&&(days>=0)){
var d=new Date();
d.setTime(d.getTime()+(days*24*60*60*1000));
_386=d.toGMTString();
}
_381=escape(_381);
document.cookie=name+"="+_381+";"+(_386!=-1?" expires="+_386+";":"")+(path?"path="+path:"")+(_384?"; domain="+_384:"")+(_385?"; secure":"");
};
dojo.io.cookie.set=dojo.io.cookie.setCookie;
dojo.io.cookie.getCookie=function(name){
var idx=document.cookie.lastIndexOf(name+"=");
if(idx==-1){
return null;
}
var _38a=document.cookie.substring(idx+name.length+1);
var end=_38a.indexOf(";");
if(end==-1){
end=_38a.length;
}
_38a=_38a.substring(0,end);
_38a=unescape(_38a);
return _38a;
};
dojo.io.cookie.get=dojo.io.cookie.getCookie;
dojo.io.cookie.deleteCookie=function(name){
dojo.io.cookie.setCookie(name,"-",0);
};
dojo.io.cookie.setObjectCookie=function(name,obj,days,path,_391,_392,_393){
if(arguments.length==5){
_393=_391;
_391=null;
_392=null;
}
var _394=[],_395,_396="";
if(!_393){
_395=dojo.io.cookie.getObjectCookie(name);
}
if(days>=0){
if(!_395){
_395={};
}
for(var prop in obj){
if(obj[prop]==null){
delete _395[prop];
}else{
if((typeof obj[prop]=="string")||(typeof obj[prop]=="number")){
_395[prop]=obj[prop];
}
}
}
prop=null;
for(var prop in _395){
_394.push(escape(prop)+"="+escape(_395[prop]));
}
_396=_394.join("&");
}
dojo.io.cookie.setCookie(name,_396,days,path,_391,_392);
};
dojo.io.cookie.getObjectCookie=function(name){
var _399=null,_39a=dojo.io.cookie.getCookie(name);
if(_39a){
_399={};
var _39b=_39a.split("&");
for(var i=0;i<_39b.length;i++){
var pair=_39b[i].split("=");
var _39e=pair[1];
if(isNaN(_39e)){
_39e=unescape(pair[1]);
}
_399[unescape(pair[0])]=_39e;
}
}
return _399;
};
dojo.io.cookie.isSupported=function(){
if(typeof navigator.cookieEnabled!="boolean"){
dojo.io.cookie.setCookie("__TestingYourBrowserForCookieSupport__","CookiesAllowed",90,null);
var _39f=dojo.io.cookie.getCookie("__TestingYourBrowserForCookieSupport__");
navigator.cookieEnabled=(_39f=="CookiesAllowed");
if(navigator.cookieEnabled){
this.deleteCookie("__TestingYourBrowserForCookieSupport__");
}
}
return navigator.cookieEnabled;
};
if(!dojo.io.cookies){
dojo.io.cookies=dojo.io.cookie;
}
dojo.provide("dojo.io.*");

