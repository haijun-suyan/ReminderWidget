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
struct Provider: IntentTimelineProvider {
    //占位:小组件的首次显示(尚未准备好渲染数据)
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), obj1: Model(title: "yanhaijun"))
    }

    //获取Widget组件的简介(如在组件库中预览时会触发)
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        //(入口)简录
        let entry = SimpleEntry(date: Date(), configuration: configuration, obj1: Model(title: "yanhaijun"))
        completion(entry)
    }

    //这个方法来获取当前时间和（可选）未来时间的时间线的小组件数据以更新小部件。也就是说你在这个方法中设置在什么时间显示什么内容。
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        //新建涵盖5个目录(按小时分割)的时间线且从当前日期开始更新
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, obj1: Model(title: "yanhaijun"))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

//小组件的数据模型
//SimpleEntry简单分录
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    //(自定义)补充属性
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
