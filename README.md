# WHShareTimer

[![CI Status](https://img.shields.io/travis/wanghonggit/WHShareTimer.svg?style=flat)](https://travis-ci.org/wanghonggit/WHShareTimer)
[![Version](https://img.shields.io/cocoapods/v/WHShareTimer.svg?style=flat)](https://cocoapods.org/pods/WHShareTimer)
[![License](https://img.shields.io/cocoapods/l/WHShareTimer.svg?style=flat)](https://cocoapods.org/pods/WHShareTimer)
[![Platform](https://img.shields.io/cocoapods/p/WHShareTimer.svg?style=flat)](https://cocoapods.org/pods/WHShareTimer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

WHShareTimer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WHShareTimer'
```
创建和获取：
```ruby
// 不指定target，添加为全局的，默认在主线程添加
WHShareTimer.task(forKey: "task1", interval: 1) { currentDate, duration  in
    print("task1  当前时间:\(currentDate)  时长：\(duration / 1000)  所在线程：\(Thread.current)")
}
// 指定target，在指定target添加，指定添加到的队列
WHShareTimer.task(on: self, forKey: "task2", interval: 2, queue: .global()) { currentDate, duration in
    print("task2  时间:\(currentDate)  时长：\(duration / 1000)  所在线程：\(Thread.current)")
}

WHShareTimer.task(on: self, forKey: "task3", interval: 3) { currentDate, duration in
    print("task3  时间:\(currentDate)  时长：\(duration / 1000)  所在线程：\(Thread.current)")
}
```
移除：
```ruby
// 添加时没有指定target的
WHShareTimer.removeTask(forKey: "task1")
// 添加时指定target的,在target上移除
WHShareTimer.removeTask(on: self, forKey: "task2")
// 移除所有定时器
WHShareTimer.removeAllTasks()
```
## Author

wanghonggit, 995406924@qq.com

## License

WHShareTimer is available under the MIT license. See the LICENSE file for more info.
