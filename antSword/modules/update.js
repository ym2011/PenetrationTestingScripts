/**
 * 中国蚁剑::更新程序
 * 开写: 2016/05/31
 * 更新: 2016/06/19
 * 说明: 从2.0.0起，取消在线更新程序的方式，改为程序启动一分钟后，检测github->release最新的版本更新信息，然后提示手动更新
 */

const config = require('./config');
const superagent = require('superagent');
const fs = require("fs");
const path = require('path');
const through = require("through");
const tar = require('tar');

class Update {
  constructor(electron) {
    this.logger = new electron.Logger('Update');
    electron.ipcMain
    .on('check-update', this.checkUpdate.bind(this))
    .on('update-download', this.onDownlaod.bind(this));
  }

  /**
   * 检查更新
   * 如果有更新，则以通知的方式提示用户手动更新，用户点击跳转到更新页面
   * @return {[type]} [description]
   */
  checkUpdate(event) {
    this.logger.debug('checkUpdate..');
    superagent
      .get('https://api.github.com/repos/antoor/antSword/releases/latest')
      .end((err, ret) => {
        try {
          let lastInfo = JSON.parse(ret.text);
          let newVersion = lastInfo['tag_name'];
          let curVersion = config['package'].version;
          // 比对版本
          if (this.CompVersion(curVersion, newVersion)) {
            this.logger.info('Found a new version', newVersion);
            event.sender.send('notification-update', {
              ver: newVersion,
              url: lastInfo['html_url']
            });
          } else {
            this.logger.warn('No new version.', newVersion, curVersion);
          }
        } catch(e) {
          this.logger.fatal('ERR', e);
        }
      });
  }

  /**
   * 版本比对
   * @param {String} curVer 当前版本
   * @param {String} newVer 新的版本
   * @return {Boolean}
   */
  CompVersion(curVer, newVer) {
    // 如果版本相同
    if (curVer === newVer) { return false }
    let currVerArr = curVer.split(".");
    let promoteVerArr = newVer.split(".");
    let len = Math.max(currVerArr.length, promoteVerArr.length);
    for (let i = 0; i < len; i++) {
        let proVal = ~~promoteVerArr[i],
            curVal = ~~currVerArr[i];
        if (proVal < curVal) {
            return false;
        } else if (proVal > curVal) {
            return true;
        }
    }
    return false;
  }

  /**
   * 监听下载请求
   * @param  {Object} event ipcMain事件对象
   * @param  {Object} opts  下载配置
   * @return {[type]}       [description]
   */
  onDownlaod(event, opt) {
    const hash = opt['hash'];
    if (!hash) {
      return
    }
    let that = this;

    let savePath = path.join(config.tmpPath, "antsword.tar.gz");

    let tempData = [];
    let totalsize = 0;
    let downsize = 0;
    let url="https://github.com/AntSwordProject/AntSword/archive/master.tar.gz";
    superagent.head(url)
    .set('User-Agent', "antSword/v2.0")
    .redirects(5)
    .timeout(30000)
    .end((err, res)=>{
      if(err){
        event.sender.send(`update-error-${hash}`, err);
      }else{
        totalsize = parseInt(res.header['content-length']);
        superagent
        .get(url)
        .set('User-Agent', "antSword/v2.0")
        .redirects(5)
        // .proxy(APROXY_CONF['uri'])
        // 设置超时会导致文件过大时写入出错
        // .timeout(timeout)
        .pipe(through(
          (chunk) => {
            downsize += chunk.length;
            var progress = parseInt(downsize/totalsize*100);
            tempData.push(chunk);
            event.sender.send(`update-dlprogress-${hash}`, progress);
          },
          () => {
            that.logger.debug("Download end.");
            let tempDataBuffer = Buffer.concat(tempData);

            if (downsize != totalsize) {
              event.sender.send(`update-error-${hash}`, "Download Error.");
              return
            }
            event.sender.send(`update-dlend-${hash}`, tempDataBuffer.length);
            // 同步写入文件
            fs.writeFileSync(savePath, tempDataBuffer);
            // 删除内存数据
            tempDataBuffer = tempData = null;

            // TODO: 需不需要备份?
            // TODO: 删除原来的 node_modules 目录
            // 解压数据
            tar.x({
              file: savePath,
              strip: 1,
              C: process.env.AS_WORKDIR,
            }).then(_=>{
              that.logger.info("update success.");
              event.sender.send(`update-success`);
              fs.unlink(savePath);
            }, err=>{
              event.sender.send(`update-error-${hash}`, err);
              fs.unlink(savePath);
            });
          }
        ));
      }
    });
  }
}

module.exports = Update;
