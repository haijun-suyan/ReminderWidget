//  IncludeConfigurationIntent 添加(动态)配置意图(备忘作用/)
//  .intentdefinition 意图定义文件
//  IntentTimelineProvider意图同步时间线供应方
//  参考文档https://zhuanlan.zhihu.com/p/661980240
//  MyWidget.swift
//  MyWidget
//  Image(systemName:)获取系统的图标(资源)
//  Image()获取自定义的图标(资源)
//  Created by haijunyan on 2023/12/28.
//  SwiftUI(辅助(层))弹性布局
//  body根主图(辅助)
//  VStack(布局)垂直(辅助(层))
//  HStack(布局)水平(辅助(层))
//  ZStack(布局)Z堆叠(辅助(层))
//  ScrollView
//  supportedFamilies已支持尺寸家族：
//  3大基础尺寸：.systemSmall小, .systemMedium中, .systemLarge大
//  iOS15：.systemExtraLarge超大(iPad使用)
//  iOS16：.accessoryCircular附属圆形 、 .accessoryRectangular附属圆角矩形 、.accessoryInline附属内置线 (手表/锁屏)

import WidgetKit
import SwiftUI
import Intents

//(供应方)Provider为小组件提供渲染数据
//配置placeholder > 配置getSnapshot > 配置getTimeline 业务层(我)负责配置准备,底层系统在合适的时机会自动进行API触发调用
struct Provider: IntentTimelineProvider {
    //配置占位:小组件的首次显示(尚未准备好渲染数据)
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), time: .morning)
//        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), obj1: Model(title: "yanhaijun"))
    }

    //配置Widget组件的简介(如在组件库中预览时会触发)
    //
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        //(入口)简录/条目
        //异步返回一个与小组件渲染有关的时间线条目
        if context.isPreview {//search预览
            //保底数据
            let entry = SimpleEntry(date: Date(), configuration: configuration, time: .morning)
            completion(entry)
            //目标数据(耗时超几秒)

        } else {
            //目标数据
            let entry = SimpleEntry(date: Date(), configuration: configuration, time: .morning)
            completion(entry)

        }

    }

    //配置啥时间显示啥内容(配置(大量)时间条目(刷新时间点))
    //组件刷新频率(非固定)：1.
//    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//        //新建涵盖5个目录(按小时分割)的时间线且从当前日期开始更新
//        let currentDate = Date()
//        //定义了从现在起未来5个小时内的5个时间条目
//        //时间条目的间隔过短导致加重系统的负担
//        //24小时周期内刷新频率因素：1.用户查看组件的频率 2.组件上次重新载入时间点 3.组件所属App 是否处于活跃状态
//        //用户频繁查看的组件，底层系统刷新上限阈值为40-70次/24h(换算约莫40分钟间隔)
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration, time: .morning)
//            entries.append(entry)
//        }
//
//        //atEnd：在时间线中的最后时间条目生效后，底层系统再次重新获取新时间线(默认策略)
//        //after(Date)：可指定在未来的某个时间点后，底层系统再次重新获取新时间线
//        //never：永远不会向组件请求新的时间线
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 8..<12:
            entries.append(SimpleEntry(date: Date(), configuration: configuration, time: .morning))
            entries.append(SimpleEntry(date: getDate(in: 12), configuration: configuration, time: .afternoon))
            entries.append(SimpleEntry(date: getDate(in: 18), configuration: configuration, time: .night))
        case 12..<18:
            entries.append(SimpleEntry(date: Date(), configuration: configuration, time: .afternoon))
            entries.append(SimpleEntry(date: getDate(in: 18), configuration: configuration, time: .night))
        default:
            entries.append(SimpleEntry(date: Date(), configuration: configuration, time: .night))
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func getDate(in hour: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year,.month,.day], from: Date())
        components.hour = hour
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
}

//TimelineEntry小组件的刷新机制：时间线条目
//小组件的数据模型
//SimpleEntry简单分录
struct SimpleEntry: TimelineEntry {
    //时间点
    let date: Date
    //configuration配置文件下的参数属性可获取用户动态配置的数据
    let configuration: ConfigurationIntent

    enum Time {
    case morning,afternoon,night
    }
    //(自定义)补充属性(内容)
//    let obj1: Model?
    //表示上午、下午、晚上
    let time: Time
}

struct Model {
    let title: String
}

extension SimpleEntry.Time {
    var text: String {
        switch self {
        case .morning:
            return "上午"
        case .afternoon:
            return "下午"
        case .night:
            return "晚上"
        }
    }

    var icon: String {
        switch self {
        case .morning:
            return "sunrise"
        case .afternoon:
            return "sun.max.fill"
        case .night:
            return "sunset"
        }
    }
}

//小组件的入口视图(Search页面内Widget入口渲染)
//UI更新:时刻条目entry对应的UI绘制
//层(器皿)渲染区
//UI对应的条目entry绘制
struct MyWidgetEntryView : View {
    //环境变量获取当前组件的类型
    @Environment(\.widgetFamily) var family: WidgetFamily

    var entry: Provider.Entry

    //声明计算属性(懒(载))
    var familyString: String {
        switch family {
        case .systemSmall:
            return "小组件"
        case .systemMedium:
            return "中等组件"
        case .systemLarge:
            return "大号组件"
        case .systemExtraLarge:
            return "超大组件"
        @unknown default:
            return "其他类型小组件"
        }
    }
    //渲染体body(内嵌具体视觉渲染)
//    var body: some View {
//        Text(entry.date, style: .time)
////        Text(entry.obj1!.title)
////        Text("具体视觉渲染")
//    }
    var body: some View {
        let configuration = entry.configuration
        VStack(alignment: .center,spacing: 10) {
            Image("custom_fish").imageScale(.small)
            Image(systemName: entry.time.icon)
                    .imageScale(.large)
                    .foregroundColor(.red)
                    .font(Font.largeTitle.weight(.medium))
            HStack {
                Text("现在是:")
                Text(entry.time.text)
            }
                .font(.subheadline)
            Text("这是:\(familyString)")
            Text("姓名：\(configuration.name ?? "无")")
            Text("年龄：\(configuration.age ?? 0)")
            Text("性别：\(getGender())")
            }
        }

    func getGender() -> String {
        switch entry.configuration.gender {
                case .man:
                    return "男"
                case .woman:
                    return "女"
                case .unknown:
                    return "未知"
                }
    }
}

@main
//小组件的配置
//  “动态配置”菜单：编辑小组件、编辑主屏幕、移除小组件
//动态配置页>动态配置项
//ConfigurationIntent配置意图
struct MyWidget: Widget {
    let kind: String = "MyWidget"//小组件唯一标识

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("意图显示")
        .description("组件的意图描述")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// 提供小组件的预览
struct MyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), time: .morning))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
