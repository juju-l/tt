





PreVer CurVersion NextVer
今天-2022-01-11(天数)%14=

preCheck 已检验过参数的合规性，确保传入时间标识有效，下面的时间 Parse 才可以忽略错误
默认起始时间小于当前天数，也就是起始时间至少是昨天






global---

cTime = time.Now(); CurVersion = cTime.Format("01-02-2006")
timStart, _: = time.Parse("2021-01-11") // preCheck 已确保起始时间为有效格式，此处不产生 error
pTime = cTime.AddDate(0, 0, -int(cTime.Sub(timStart).Hour()/24)%14) // preCheck 已确保今天不会等于或小于起始时间
PreVer = pTime.Format("01-02-2006")
NextVer = pTime.AddDate(0, 0, 14).Format("01-02-2006")

func IsPublistRls() bool {
	if
}


preCheck---

1.需要做起始时间是否正确的判断，直接使用 Parse 的 err 返回判断
同时得满足当前时间与起始时间差额至少1天，也就大于1，否则退出系统

struct---pageOption

if ! page.IsTest -正式环境 && global.IsPublistRls() -今天是发版日期 &&
	! rwfile.IsExist() -本地版本文件不存在(防止二次重复执行) {
	执行 image 流水线代码中版本信息的修改
	执行 image build
}

...
更新页面
...

if ! page.IsTest -正式环境 && global.IsPublistRls() -今天是发版日期 &&
	! rwfile.IsExist() -本地版本文件不存在(防止二次执行报错等) {
	执行 页面元版本数据文件创建与上传 github
}













