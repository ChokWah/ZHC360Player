# ZHC360Player
下载360视频观看(GoogleCardboardSDK,HTY360Player)，被半废弃的项目，当课后练习


#### 学习城觅开源项目的UINavigationController框架，Sqlite做永久保存

- 最费劲是下载模块，仿了一个百度云的下载页面，使用NSURLSessionDataDelegate作为断点续下，设置不同的NSURLSessionConfigurationID，作同步多线程下载，未完善：HTTP响应码，断网时任务的持久化保存

- VC加了一个timer做每秒的进度更新，总算初步了解了NSRunLoop，cell的实时更新

- 下载管理器用了代理，把NSURLSessionDataTask的代理传过来，再用通知告诉VC下载状态

- 每次刷新tableview，如果section或者row的数目变化，记得在reload前确保section的存在

- 下载完成后永久保存模型到sqlite，程序再次启动从sqlite拿数据
