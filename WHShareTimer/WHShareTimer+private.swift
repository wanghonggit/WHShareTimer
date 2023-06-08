//
//  XJKShareTimer+private.swift
//  XJKShareTimer
//
//  Created by wanghong on 2023/6/8.
//

import UIKit

// MARK: -  Thread & Timer
extension WHShareTimer {
    func addTimerThread() {
        thread.start()
    }
    // 默认添加的线程
    @objc func threadTask() {
        autoreleasepool {
            thread.name = "XJKShareTimerThread"
            RunLoop.current.add(timer, forMode: .common)
            RunLoop.current.run()
        }
    }
    // timer执行的函数
    @objc func timerTask() {
        let currentDate = Date()
        var hasTask = false
        // 保证任务的执行顺序
        semaphore.wait()
        targetTasksDict.forEach { _, targetDict in
            targetDict.forEach { _, task in
                /// 目标对象释放掉，删除target上的所有任务
                if task.target == nil {
                    targetTasksDict.removeValue(forKey: task.targetName)
                } else {
                    /// 只有duration是任务执行间隔时间的倍数时，才执行该任务
                    if task.duration >= 0,
                        !task.isPaused,
                        task.duration % task.interval == 0 {
                        let execute = {
                            if task.target != nil {
                                // 回调本次任务执行的时间
                                task.task(currentDate, task.duration)
                                task.duration += UInt(task.interval)
                            }
                        }

                        task.queue.async(execute: execute)
                    }
                    hasTask = true
                }
            }
        }
        // 如果target没有了，上面的任务也没移除了，停止timer
        if !hasTask {
            pause()
        }
        semaphore.signal()
    }
}

// MARK: - Add & Remove Task
extension WHShareTimer {
    typealias Millisecond = UInt

    class Task {
        weak var target: AnyObject?
        var isPaused = false
        var targetName: String // 任务所在target
        var task: Handler // 任务回调
        var taskName: String // 任务名称
        var queue: DispatchQueue // 任务执行的队列
        var interval: Millisecond // 任务的执行间隔，毫秒
        var duration: Millisecond = 0 // 任务执行的总时间
        init(target: AnyObject,
             targetName: String,
             task: @escaping Handler,
             taskName: String,
             queue: DispatchQueue,
             interval: Millisecond) {
            self.target = target
            self.targetName = targetName
            self.task = task
            self.taskName = taskName
            self.queue = queue
            self.interval = interval
        }
    }

    func addTask(on target: AnyObject,
                 forKey key: String,
                 interval: TimeInterval,
                 queue: DispatchQueue = .main,
                 action: @escaping Handler) {
        let target = target
        let targetKey = _targetKey(for: target)

        /// 转换成对应的毫秒
        let intervalMS = UInt((floor(interval * 10.0) / 10) * 1000)

        let task = Task(target: target,
                        targetName: targetKey,
                        task: action,
                        taskName: key,
                        queue: queue,
                        interval: intervalMS)
        addTask(task)
    }

    func addTask(_ task: Task) {
        semaphore.wait()
        /// 有task就直接获取，没有就新创建
        if var targetDict = targetTasksDict[task.targetName] {
            if let oldTask = targetDict[task.taskName] {
                // 只将已经存在的task的计时和时间间隔更新进去，避免回调也被覆盖
                task.duration = oldTask.duration
                _ = targetDict.updateValue(task, forKey: task.taskName)
            } else {
                // 如果新的key没有创建，创建以后添加进去
                targetDict[task.taskName] = task
            }
            // 有target的时候，更新
            self.targetTasksDict.updateValue(targetDict, forKey: task.targetName)
        } else {
            let targetTasksDict = [task.taskName: task]
            // 没有对应target的时候，新添加
            self.targetTasksDict[task.targetName] = targetTasksDict
        }
        startIfNeeded()
        semaphore.signal()
    }

    // 移除task，target默认为本单例
    func removeTask(on target: AnyObject? = WHShareTimer.shared, forKey key: String? = nil) {
        if target == nil, key == nil {
            return
        }

        let targetKey = _targetKey(for: target)

        semaphore.wait()
        if let taskKey = key {
            /// 删除target上指定任务
            _ = targetTasksDict[targetKey]?.removeValue(forKey: taskKey)
        } else {
            /// 删除target上的所有任务
            targetTasksDict.removeValue(forKey: targetKey)
        }
        pauseIfNeeded()

        semaphore.signal()
    }

    func removeAllTask() {
        semaphore.wait()

        targetTasksDict.removeAll()
        pause()

        semaphore.signal()
    }

    func task(on target: AnyObject?, forKey key: String) -> Task? {
        var task: Task?
        let targetKey = _targetKey(for: target)
        semaphore.wait()
        task = targetTasksDict[targetKey]?[key]
        semaphore.signal()

        return task
    }

    func hasTask(on target: AnyObject?, forKey key: String) -> Bool {
        return task(on: target, forKey: key) != nil
    }

    /// 暂停任务
    func pauseTask(on target: AnyObject?,
                   forKey key: String) {
        task(on: target, forKey: key)?.isPaused = true
    }

    /// 恢复任务
    func resumeTask(on target: AnyObject?,
                    forKey key: String) {
        task(on: target, forKey: key)?.isPaused = false
    }

    func _targetKey(for target: AnyObject?) -> String {
        return "\(target ?? self)"
    }
}

// MARK: - Start & Pause
private extension WHShareTimer {
    // 启动
    func startIfNeeded() {
        if !isRunning, targetTasksDict.values.count > 0 {
            start()
        }
    }
    // 停止
    func pauseIfNeeded() {
        if isRunning, targetTasksDict.values.count == 0 {
            pause()
        }
    }
    func start() {
        timer.fireDate = .init()
    }
    func pause() {
        timer.fireDate = .distantFuture
    }
}
