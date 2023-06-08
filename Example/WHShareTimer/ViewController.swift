//
//  ViewController.swift
//  WHShareTimer
//
//  Created by wanghonggit on 06/08/2023.
//  Copyright (c) 2023 wanghonggit. All rights reserved.
//

import UIKit
import WHShareTimer
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    deinit {
        // 添加时没有指定target的
//        WHShareTimer.removeTask(forKey: "task1")
        // 添加时指定target的,在target上移除
//        WHShareTimer.removeTask(on: self, forKey: "task2")
        // 移除所有定时器
//        WHShareTimer.removeAllTasks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

