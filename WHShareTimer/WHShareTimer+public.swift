//
//  XJKShareTimer+public.swift
//  XJKShareTimer
//
//  Created by wanghong on 2023/6/8.
//

import UIKit

public extension WHShareTimer {
    // 任务执行回调当前执行的时间和总共执行的时间(毫秒级)
    typealias Handler = (_ currentDate: Date, _ duration: UInt) -> Void

    /// 添加or获取任务,添加一个任务后timer会自动开始
    /// - parameter target:      任务的目标对象，不指定就是默认在单例中执行，target销毁后，任务自动清除
    /// - parameter key:         任务的名字
    /// - parameter interval:    任务执行的间隔，单位秒
    /// - parameter queue:       任务执行的队列
    /// - parameter action:      具体任务
    class func task(on target: AnyObject = WHShareTimer.shared,
                       forKey key: String,
                       interval: TimeInterval,
                       queue: DispatchQueue = .main,
                       action: @escaping Handler) {
        shared.addTask(on: target,
                       forKey: key,
                       interval: interval,
                       queue: queue,
                       action: action)
    }

    /// 判断target对象上是否有key任务
    class func hasTask(on target: AnyObject? = nil,
                       forKey key: String) -> Bool {
        shared.hasTask(on: target, forKey: key)
    }

    /// 移除任务，没有任务的话timer会自动停止
    class func removeTask(on target: AnyObject? = nil,
                          forKey key: String? = nil) {
        shared.removeTask(on: target, forKey: key)
    }

    /// 暂停任务
    class func pauseTask(on target: AnyObject? = nil,
                         forKey key: String) {
        shared.pauseTask(on: target, forKey: key)
    }

    /// 恢复任务
    class func resumeTask(on target: AnyObject? = nil,
                          forKey key: String) {
        shared.resumeTask(on: target, forKey: key)
    }

    /// 移除所有任务
    class func removeAllTasks() {
        shared.removeAllTask()
    }
}
