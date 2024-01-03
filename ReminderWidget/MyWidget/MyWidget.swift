//  参考文档https://zhuanlan.zhihu.com/p/661980240
//  MyWidget.swift
//  MyWidget
//
//  Created by haijunyan on 2023/12/28.
//

import WidgetKit
import SwiftUI
import Intents

//(供应方)Provider为小组件提供渲染数据
//配置placeholder > 配置getSnapshot > 配置getTimeline 业务层(我)负责配置准备,底层系统在合适的时机会自动进行API触发调用
struct Provider: IntentTimelineProvider {
    //配置占位:小组件的首次显示(尚未准备好渲染数据)
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), obj1: Model(title: "yanhaijun"))
    }

    //配置Widget组件的简介(如在组件库中预览时会触发)
    //
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        //(入口)简录/条目
        //异步返回一个与小组件渲染有关的时间线条目
        if context.isPreview {//search预览
            //保底数据
            let entry = SimpleEntry(date: Date(), configuration: configuration, obj1: Model(title: "yanhaijun保底数据"))
            completion(entry)
            //目标数据(耗时超几秒)

        } else {
            //目标数据
            let entry = SimpleEntry(date: Date(), configuration: configuration, obj1: Model(title: "yanhaijun目标数据"))
            completion(entry)

        }

    }

    //配置啥时间显示啥内容(配置(大量)时间条目(刷新时间点))
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        //新建涵盖5个目录(按小时分割)的时间线且从当前日期开始更新
        let currentDate = Date()
        //定义了从现在起未来5个小时内的5个时间条目
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, obj1: Model(title: "yanhaijun"))
            entries.append(entry)
        }

        //atEnd：在时间线中的最后时间条目生效后，底层系统再次重新获取新时间线(默认策略)
        //after(Date)：可指定在未来的某个时间点后，底层系统再次重新获取新时间线
        //never：永远不会向小组件请求新的时间线
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

//TimelineEntry小组件的刷新机制：时间线条目
//小组件的数据模型
//SimpleEntry简单分录
struct SimpleEntry: TimelineEntry {
    //时间点
    let date: Date
    let configuration: ConfigurationIntent
    //(自定义)补充属性(内容)
    let obj1: Model
}

struct Model {
    let title: String
}

//小组件的入口视图(Search页面内Widget入口渲染)
struct MyWidgetEntryView : View {
    var entry: Provider.Entry

    //渲染体body(内嵌具体视觉渲染)
    var body: some View {
        Text(entry.date, style: .time)
        Text(entry.obj1.title)
        Text("具体视觉渲染")
    }
}

@main
//小组件的配置
struct MyWidget: Widget {
    let kind: String = "MyWidget"//小组件唯一标识

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("小组件的名称")
        .description("这是小组件的描述.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// 提供小组件的预览
struct MyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), obj1: Model(title: "yanhaijun")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
