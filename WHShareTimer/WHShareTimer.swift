//
//  XJKShareTimer.swift
//  XJKShareTimer
//
//  Created by wanghong on 2023/6/8.
//

import UIKit

public final class WHShareTimer {
    public static let shared = WHShareTimer()
    public var isRunning: Bool { timer.fireDate == .distantFuture }
    /// 任务容器
    typealias TaskDict = [String: Task]
    var targetTasksDict = [String: TaskDict]()
    /// 线程
    lazy var thread = Thread(target: self,
                                     selector: #selector(threadTask),
                                     object: nil)
    lazy var semaphore = DispatchSemaphore(value: 1)
    /// 全局timer
    lazy var timer = Timer(fireAt: .distantFuture,
                           interval: TimeInterval(interval),
                           target: self,
                           selector: #selector(timerTask),
                           userInfo: nil,
                           repeats: true)

    /// timer每次开始运行的总时间，毫秒，每次start都会清0
//    var duration: Millisecond = 0
    /// 内部定时器间隔时间，默认1秒
    let interval = 1
    init() {
        addTimerThread()
    }
}
