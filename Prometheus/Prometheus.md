[TOC]



# 一、Prometheus 介绍

## 1.1 监控系统组成

监控是运维的第一道防线，业务系统可以不做运维自动化，可以不做 DevOps，但一定不能不做监控。监控是业务的"眼睛"，能在第一时间发现对应的异常问题，只有这样才能第一时间去解决问题。

"无监控、不运维"，没了监控，什么基础运维，业务运维都是"瞎子"。监控是运维岗位的基本要求。运维工作做的好不好，更多的是看监控有没有做好。

一个完整的监控系统需要包括如下功能：数据产生、数据采集、数据存储、数据处理、数据展示分析、告警

### 1.1.1 数据来源

我们如果要监控数据，首先得有数据，也就是说，这些数据应该可以被记录下来，或者被暴露出来，数据常见的产生、直接或间接暴露方式的方式如下

- 硬件本身的记录信息 - 以文件或者以内存属性的方式存在
- 应用业务的接口 - 主动暴露软件本身的运行状态，比如 redis info、各种status等
- 相关的信息采集工具 - 方便收集数据或者采集数据的 系统级别的命令等

注意：这些数据在长时间的运行过程中，都是以固定的"属性指标"来描述他们，我们把这些称为metric。

监控系统就需要对每个环境的每一个指标都要进行数据的获取，并且按照用户需要的方式提供给用户来使用。

### 1.1.2 数据采集

对于上面所说的Metric指标数据，我们通常不会只获取一次，而是需要持续性、周期性的方式来采集。

根据数据采集方式的不同划分为了两个分类：

- 软件方式：

  agent: 专用的软件的一种应用机制。

  http: 基于http 协议实现数据采集

  ssh: 系统常见的一种应用通信机制，但是并非所有系统都支持。

  SNMP: 简单网络管理协议(Simple Network Management Protocol),是工作在各种网络设备中的一种机制。

- 硬件方式：

  IPMI: 智慧平台管理接口(Intelligent Platform Management Interface)是一种工业标准用于采集硬件设备的各种物理健康状态数据，如温度、电压、风扇工作状态、电源状态等。

注意：由于每个业务场景，需要采集的指标数量是不确定的，有时只是一个业务场景，就需要采集数百个指标，如果按照上述所说的周期性采集的方式来说，数据的采集量是相当大的

### 1.1.3 数据存储

由于我们采集到的"样本数据"，不是一次性使用的，尤其是单个数据是没有意义的，我们需要将这些数据存储下来，在后续的工作场景中进行聚合操作，从而来满足我们的需求。所以这些数据的存储也是一个非常重要的点。同时，我们在后续使用这些数据的时候，不仅仅要知道这些数据，还要知道这些数据的时间属性--什么时候的数据。所以这些数据在存储的时候，必须有一个重要的时间维度。所以我们一般将这种用于监控场景的数据，称为时间序列数据 - TS(Time series data),专门用于存储这些数据的数据库，称其为时序数据库(TSDB Time series database)

时序列数据库是用来存储时序列（time-series）数据并以时间（点或区间）建立索引的软件

一般时序列数据都具备以下特点

- 数据结构简单：某一度量指标在某一时间点只会有一个值，没有复杂的结构（嵌套、层次等）和关系（关联、主外键等）
- 数据量大：由于时序列数据由所监控的大量数据源来产生、收集和发送，比如主机、IoT设备、终端或App等

### 1.1.4 数据处理

如果仅仅采集到的是原始的数据，本身往往没有太大的意义，通常还需要对数据进行各种聚合和处理操作才可以正常的用于工作分析场景

### 1.1.5 数据分析展示

对于各种聚合操作之后的数据，我们也需要进行分析和展示

无论是采集到的时序数据，还是经过聚合分析之后的统计数据，由于数据量巨大,用肉眼观察很难能够看得情楚，尤其是通过表格来查看成千上万条数据，来分析其内在的逻辑趋势关系更是如此。

所以，对于监控系统来说，其本身的数据可视化功能是非常重要的，以各种图形演示的方式展示数据的发展趋势，方便进行分析。

### 1.1.6 告警

需要在某些特殊情况下，提醒我们去看相关的数据，所以我们就需要根据日常工作中采集到的数据，来分析出正常的状态值，然后将其作为一个阈值指标。

接下来在后续数据采集的时候，让实时的数据，与阈值进行比较，一旦超出阈值判断机制，就通过告警机制通知给我们,从而及进行处理, 

采集到的数据达到一定的条件,比如磁盘空间满等,应该自动触发告警提示,比如:微信,邮件,短信等,方便及时发现问题并解决

## 1.2 监控内容和方法

### 1.2.1 监控内容

#### 1.2.1.1 资源数据

硬件设备：服务器、路由器、交换机、IO系统等

系统资源：OS、网络、容器、VM实例

应用软件：Nginx、MySQL、Java应用等

#### 1.2.1.2 业务服务

业务状态：服务通信、服务运行、服务下线、性能指标、QPS、DAU(Daily Active User )日活、转化率、业务接口(登陆，注册，聊天，留⾔)、产品转化率、充值额度、⽤户投诉等

一般故障：访问缓慢、存储空间不足，数据同步延迟，主机宕机、主机不可达

严重故障：服务不可用、集群故障

### 1.2.2 监控方法

Google的四个黄金指标

常用于在服务级别帮助衡量终端用户体验、服务中断、业务影响等层面的问题，适用于应用及服务监控

- 延迟(Latency)

  服务请求所需要的时长，例如HTTP请求平均延迟

  应用程序响应时间会受到所有核心系统资源（包括网络、存储、CPU和内存）延迟的影响

  需要区分失败请求和成功请求

- 流量(Traffic)，也称为吞吐量

  衡量服务的容量需求，例如每秒处理的HTTP请求数QPS或者数据库系统的事务数量TPS

  吞吐量指标包括每秒Web请求、API调用等示例，并且被描述为通常表示为每秒请求数的需求

- 错误(Errors)

  失败的请求（流量)的数量，通常以绝对数量或错误请求占请求总数的百分比表示，请求失败的速率，用于衡量错误发生的情况

  例如：HTTP 500错误数等显式失败，返回错误内容或无效内容等隐式失败，以及由策略原因导致的失败(例如强制要求响应时间超过30毫秒的请求视为错误)

- 饱和度(Saturation)

  衡量资源的使用情况,用于表达应用程序有多"满"

  资源的整体利用率，包括CPU（容量、配额、节流)、内存(容量、分配)、存储（容量、分配和 I/O吞吐量)和网络

  例如：内存、CPU、I/O、磁盘等资源的使用量

## 1.3 监控实施实现方式

对于Linux系统来说，它的系统监控的实现方式很多，主要有系统命令、开源软件、监控平台等

### 1.3.1 系统命令

![image-20250915113204776](Prometheus.assets/image-20250915113204776.png)

### 1.3.2 开源软件

对于传统的业务数据监控来说，Zabbix 监控软件是优秀的，由于 Zabbix 诞生的时代业务数据量相对不是太多，所以它默认采取的是关系型数据库作为后端存储。

所以随着业务场景的发展，尤其是微服务、云原生场景的发展，大量数据的存储和动态容器的监控缺失成为了 Zabbix 本身的限制。所以就出现了另外一种监控软件 Prometheus。

### 1.3.3 监控平台

一些云服务商提供了监控平台可以实现监控功能

![image-20250915132917020](Prometheus.assets/image-20250915132917020.png)

## 1.4 时序数据库

### 1.4.1 什么是时序数据库

https://db-engines.com/en/ranking/time+series+dbms

![image-20250915133025831](Prometheus.assets/image-20250915133025831.png)

时间序列数据(TimeSeries Data) : 按照时间顺序记录系统、设备状态变化的数据被称为时序数据。

时序数据库记录的数据以时间为横座标,纵坐标为数据

时间序列数据库 (Time Series Database , 简称 TSDB) 是一种高性能、低成本、稳定可靠的在线时间序列数据库服务，提供高效读写、高压缩比存储、时序数据插值及聚合计算等服务，广泛应用于物联网（IoT）设备监控系统、企业能源管理系统（EMS）、生产安全监控系统和电力检测系统等行业场景；除此以外，还提供时空场景的查询和分析的能力。

TSDB 具备秒级写入百万级时序数据的性能，提供高压缩比低成本存储、预降采样、插值、多维聚合计算、可视化查询结果等功能，解决由设备采集点数量巨大、数据采集频率高造成的存储成本高、写入和查询分析效率低的问题。

TSDB是一个分布式时间序列数据库，具备多副本高可用能力。同时在高负载大规模数据量的情况下可以方便地进行弹性扩容，方便用户结合业务流量特点进行动态规划与调整。

应用的场景：

- 物联网设备无时无刻不在产生海量的设备状态数据和业务消息数据，这些数据有助于进行设备监控、业务分析预测和故障诊断。
- 传统电力化工以及工业制造行业需要通过实时的监控系统进行设备状态检测，故障发现以及业务趋势分析。
- 系统运维和业务实时监控,通过对大规模应用集群和机房设备的监控，实时关注设备运行状态、资源利用率和业务趋势，实现数据化运营和自动化开发运维。

### 1.4.2 时间序列数据特点

- 大部分时间都是顺序写入操作，很少涉及修改数据

  删除操作都是删除一段时间的数据，而不涉及到删除无规律数据

  读操作一般都是升序或者降序

- 高效的压缩算法，节省存储空间，有效降低 IO,存储成本低

  TSDB 使用高效的数据压缩技术，将单个数据点的平均使用存储空间降为1~2个字节，可以降低90%存储使用空间，同时加快数据写入的速度。

- 高性能读写, 每秒百万级数据点写入，亿级数据点聚合结果秒级返回

## 1.5 Prometheus 简介

### 1.5.1 Prometheus 简介

![image-20250915133212306](Prometheus.assets/image-20250915133212306.png)

Prometheus 是一款时序(time series）数据库TSDB，也是一款设计用于实现基于目标(Target)的监控系统的关键组件，结合其它组件，例如Pushgateway、Altermanager和Grafana等，可构成一个完整的监控系统

Prometheus 启发于 Google 的 borgmon 监控系统，在一定程度上可以理解为，是Google BorgMon监控系统的开源版本。

该软件由工作在 SoundCloud 的 google 前员工在 2012 年创建，作为社区开源项目进行开发，并于2015 年正式发布。2016 年，Prometheus 正式加入 CNCF(Cloud Native Computing Foundation)，成为继 Kubernetes之后第二个在CNCF托管的项目, 现已广泛用于在容器和微服务领域中得到了广泛的应用，当然不仅限于此

云原生: https://landscape.cncf.io/

Prometheus 本身基于Go语言开发的一套开源的系统监控报警框架和时序列数据库(TSDB)。

Prometheus 的监控功能很完善和全面，性能也足够支撑上万台规模的集群。

网站：https://prometheus.io/

github：https://github.com/prometheus

其特点主要如下：

- 支持多维数据模型：由度量名和键值对组成的时间序列数据
- 内置时间序列数据库 TSDB(Time Series Database )
- 支持PromQL(Prometheus Query Language)查询语言，可以完成非常复杂的查询和分析，对图表展示和告警非常有意义
- 支持 HTTP 的 Pull 方式采集时间序列数据
- 支持 PushGateway 采集瞬时任务的数据
- 支持静态配置和服务发现两种方式发现目标
- 多种可视化和仪表盘,支持第三方 Dashboard,比如:Graf

![image-20250915133401767](Prometheus.assets/image-20250915133401767.png)

数据特点

- 监控指标，采用独创的指标格式，我们称之为Prometheus格式，这个格式在监控场景中很常见。
- 数据标签，支持多维度标签，每个独立的标签组合都代表一个独立的时间序列
- 数据处理，Prometheus内部支持多种数据的聚合、切割、切片等功能。
- 数据存储，Prometheus支持双精度浮点型数据存储和字符串

适用场景

Prometheus 非常适合记录任何纯数字时间序列。它既适合以机器为中心的监控场景，也适合于高度动态的面向服务的体系结构的监控场景。尤其是在微服务世界中，它对多维数据收集和查询的支持是一种特别的优势。

Prometheus的设计旨在提高可靠性，使其成为中断期间要使用的系统，以使您能够快速诊断问题。每个Prometheus服务器都是独立的，而不依赖于网络存储或其他远程服务。当基础结构的其他部分故障时，您可以依靠它，并且无需设置广泛的基础结构即可使用它。

由于Prometheus重视可靠性。在故障情况下，我们可以查看有关系统的可用统计信息。但是如果您需要100％的准确性，则Prometheus并不是一个不错的选择，因为所收集的数据可能不会足够详细和完整。在这种情况下，最好使用其他系统来收集和分析数据以进行计费，并使用Prometheus进行其余的。

**Prometheus 不足**

- 不支持集群化
- 被监控集群规模过大后本身性能有一定瓶颈
- 中文支持不好

### 1.5.2 Prometheus 架构

~~~shell
https://prometheus.io/docs/ 
https://prometheus.io/docs/introduction/overview/
~~~

#### 1.5.2.1 数据获取逻辑

Prometheus 同其它TSDB相比有一个非常典型的特性：它主动从各 Target上 "拉取（pull)"数据，相当于 Zabbix 里的被动模式,而非等待被监控端的"推送（push）"

两个方式各有优劣，其中，Pull模型的优势在于：集中控制：有利于将配置集在 Prometheus Server上完成，包括指标及采取速率等,Prometheus的根本目标在于收集在Target上预先完成聚合的聚合型数据，而非一款由事件驱动的存储系统

![image-20250915133612747](Prometheus.assets/image-20250915133612747.png)

#### 1.5.2.2 Prometheus 架构

https://github.com/prometheus/prometheus

![image-20250915133720376](Prometheus.assets/image-20250915133720376.png)

Prometheus 的主要模块包括：

- prometheus 

  时序数据存储、监控指标管理

- 可视化

  Prometheus web UI : 集群状态管理、promQL 

  Grafana:非常全面的可视化套件

- 数据采集

  Exporter: 为当前的客户端暴露出符合 Prometheus 规格的数据指标,Exporter 以守护进程的模式运行井开始采集数据,Exporter 本身也是一个http_server 可以对http请求作出响应返回数据 (K/V形式的metrics)

  Pushgateway : 拉模式下数据的采集工具

- 监控目标

  服务发现 :文件方式、dns方式、console方式、k8s方式

- 告警: 

  alertmanager 

Prometheus 由几个主要的软件组件组成，其职责概述如下

| 组件                 | 解析                                                                                                                                        |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Prometheus server  | 彼此独立运行，仅依靠其本地存储来实现其核心功能：抓取时序数据，规则处理和报警                                                                                                    |
| Client Library     | 客户端库，为需要监控的服务生成相应的 metrics 并暴露给 Prometheus server。当 Prometheus server 来 pull 时，直接返回实时状态的 metrics。                                         |
| Push Gateway       | exporter 采集类型已经很丰富，但是依然需要很多自定义的监控数据,用 pushgateway 可以实现自定义的监控数据,任意灵活想做什么都可以做到 exporter 的开发需要使用真正的编程语言，不支持shell这种快速脚本,而pushgateway 开发就容易的多。 |
| exporters          | 部署到第三方软件主机上，用于暴露已有的第三方服务的 metrics 给 Prometheus。                                                                                           |
| Alertmanager       | 从 Prometheus server 端接收到 alerts 后，会进行去除重复数据，分组，并路由到对应的接受方式，以高效向用户完成告警信息发送。常见的接收方式有：电子邮件，pagerduty，OpsGenie, webhook 等,一些其他的工具。            |
| Data Visualization | Prometheus Web UI （Prometheus Server内建），及Grafana等                                                                                         |
| Service Discovery  | 动态发现待监控的 Target，从而完成监控配置的重要组件，在容器化环境中尤为有用；该组件目前由 Prometheus Server 内建支持；                                                                  |

在上述的组件中，大多数都是用Go编写的，因此易于构建和部署为静态二进制文件。

#### 1.5.2.3 工作流程

- Prometheus server 定期从配置好的 jobs 或者 exporters 中拉 metrics，或者接收来自Pushgateway 发过来的 metrics，或者从其他的 Prometheus server 中拉 metrics。
- Prometheus server 在本地存储收集到的 metrics，并运行已定义好的 alert.rules，记录新的时间序列或者向 Alertmanager 推送警报，实现一定程度上的完全冗余功能。
- Alertmanager 根据配置文件，对接收到的警报进行去重分组，根据路由配置，向对应主机发出告警。
- 集成 Grafana 或其他 API 作为图形界面，用于可视化收集的数据。

#### 1.5.2.4 生态组件

Prometheus 只负责时序型指标数据的采集及存储

其它的功能,如: 数据的分析、聚合及直观展示以及告警等功能并非由 Prometheus Server 所负责,需要配合其它组件实现

支持丰富的 Exporter 实现各种应用的监控

https://prometheus.io/docs/instrumenting/exporters/

![image-20250915134649713](Prometheus.assets/image-20250915134649713.png)

### 1.5.3 Prometheus 数据模型

Prometheus 中存储的数据为时间序列，即基于同一度量标准或者同一时间维度的数据流。

除了时间序列数据的正常存储之外，Prometheus 还会基于原始数据临时生成新的时间序列数据，用于后续查询的依据或结果。

每个时间序列都由 metric 名称(表示某项指标或者度量)和标签(键值对形式,表示属性,其为可选项)组合成唯一标识。

#### 1.5.3.1 Metrics 名字

该指标Metric名字应该有意义，用于表示 metric 的一般性功能，例如：http_requests_total 表示 http 请求的总数。

metric 名字由 ASCII 字符，数字，下划线，以及冒号组成，且必须满足正则表达式 \[a-zA-Z\_:][azA-Z0-9_:]* 的查询需求。

注意：冒号是为用户定义的记录规则保留的。

![image-20250915135120527](Prometheus.assets/image-20250915135120527.png)

#### 1.5.3.2 标签

- 标签是以键值对的样式而存在，不同的标签用于表示时间序列的不同维度标识

- 基本格式：

- ~~~shell
  <metric name>{<label name>=<label value>, …}
  #示例样式：
  
  http_requests_total{method="POST",endpoint="/api/tracks"}
  解析： http_requests_total{method="POST"} 表示所有 http 请求中的 POST 请求，
  endpoint="/api/tracks"表示请求的url地址是/api/tracks。当 method="GET" 时，则为新的一个 metric
  ~~~

- 标签中的键名由 ASCII 字符，数字，以及下划线组成，且必须满足正则表达式 [a-zA-Z_:\][a-zA-Z0-9\_:]*。以__开头的标签名称保留供内部使用

- 标签值可以包含任何Unicode字符，标签值为空的标签被认为等同于不存在的标签

查询语言允许基于这些维度进行过滤和聚合。更改任何标签值，包括添加或删除标签，都会创建一个新  的时间序列

![image-20250915135628790](Prometheus.assets/image-20250915135628790.png)

#### 1.5.3.3 数据格式

Prometheus 对收集的数据有一定的格式要求，本质上就是将收集的数据转化为对应的文本格式，并提供响应给Prometheus Server的 http 请求。

Exporter 收集的数据转化的文本内容以行 (\n) 为单位，空行将被忽略, 文本内容最后一行为空行

文本内容，如果以 # 开头通常表示注释。

以 # HELP 开头表示 metric 帮助说明。

以 # TYPE 开头表示定义 metric 类型，包含 counter, gauge, histogram, summary, 和 untyped 类型。

其他表示一般注释，供阅读使用，将被 Prometheus 忽略

#### 1.5.3.4 任务 Job 和实例 Instance

一个单独 scrape(\<host>:\<port>) 的目标 Target 也称为一个实例 instance，通常为 IP:PORT 形式,对应于单个应用的进程。

一组同种类型的 instances 集合称为一个 job，主要用于保证可扩展性和可靠性。

![image-20250915171028247](Prometheus.assets/image-20250915171028247.png)

例如：一个 API 服务 job 包含四个 instances

~~~shell
job: api-server
instance 1: 1.2.3.4:5670
instance 2: 1.2.3.4:5671
instance 3: 5.6.7.8:5670
instance 4: 5.6.7.8:5671
~~~

对于任务实例来说，还可以借助于特殊的字符串来表示通用的功能，常见的使用样式如下

~~~shell
#判断任务是否健康，1代表正常，0代表不正常
up{job="<job-name>", instance="<instance-id>"} 

#获取任务的持续时间
scrape_duration_seconds{job="<job-name>", instance="<instance-id>"} 

#任务执行后剩余的样本数
scrape_samples_post_metric_relabeling{job="<job-name>", instance="<instance-id>"} 

#暴露的样本数量
scrape_samples_scraped{job="<job-name>", instance="<instance-id>"} 

#样本的大概数量
scrape_series_added{job="<job-name>", instance="<instance-id>"}
~~~

**总结**

- 数据模型：metric名称+标签
- 数据类型：Counter+Gauge+Histogram+Summary
- 任务：多个instances组成一个jobs

### 1.5.4 Prometheus 数据处理

#### 1.5.4.1 数据获取

这些 metric 数据，是基于 HTTP call 方式来进行获取的，从对方的配置文件中指定的网络端点(endpoint,即 IP:Port,表示一个应用)上周期性获取指标数据。每一个端点上几乎不可能只有一个数据指标。

Prometheus 的 Metric 指标都必须以 http 的方式暴露出来，因此 prometheus 无法直接获取内核等相关数据的原因，只能借助于其他的机制才可以。

prometheus 默认支持通过三种类型的途径从目标上"抓取（Scrape）"指标数据

![image-20250915171306596](Prometheus.assets/image-20250915171306596.png)

| 方式            | 解析                                                         |
| --------------- | ------------------------------------------------------------ |
| Instrumentation | 指附加到应用程序中形成内置的检测系统，采集数据并暴露出来的客户端库，暴露的方式也是http方式，常用于较新出现的自身天然就支持 Prometheus 的应用 |
| Exporters       | 部署到对应节点上，负责从目标应用程序上采集和聚合原始格式的数据，并转换或聚合为 Prometheus 格式的指标，以http方式向外暴露本地节点数据后，常用于较早期出现的原本并不支持 Prometheus 的应用 |
| Pushgateway     | 执行被监控节点的作业任务（通常不是持续执行的守护进程，而是周期性的作业）主动 Push 数据到 Pushgateway,并转换成 Prometheus 格式数据，然后 Prometheus 再 pull 此数据 |

#### 1.5.4.2 数据存储

Prometheus 采用的是time-series(时间序列)的方式以一种自定义的格式存储在本地硬盘上

Prometheus的本地T-S(time-series)数据库以每两小时为间隔, 分成Block为单位存储，每一个Block中又分为多个Chunk文件

Chunk是作为存储的基本单位,用来存放采集过来的数据的T-S数据,包括metadata和索引文件(index)。

Index文件是对metrics(对应一次KV采集数据)和 labels(标签)进行索引之后存储在chunk文件中

Prometheus平时是将采集过来的数据先都存放在内存之中, 以类似缓存的方式用于加快搜索和访问。

Prometheus提供一种保护机制叫做WAL( Write-Ahead Logging )可以将数据存入硬盘中的chunk文件，当出现宕机时，重新启动时利用此日志系统来恢复加载至内存

~~~shell
[root@prometheus ~]#tree /usr/local/prometheus/data
/usr/local/prometheus/data
├── 01G9RSD61ZEF16T5YGE91K49MZ
│   ├── chunks
│   │   └── 000001
│   ├── index
│   ├── meta.json
│   └── tombstones
├── 01G9RZ8VXF2FHHB18CW0594P8T
│   ├── chunks
│   │   └── 000001
│   ├── index
│   ├── meta.json
│   └── tombstones
├── chunks_head
│   ├── 000002
│   └── 000003
├── lock
├── queries.active
└── wal
   ├── 00000000
   ├── 00000001
   └── 00000002
6 directories, 15 files
~~~

#### 1.5.4.3 数据分析

Prometheus 提供了数据查询语言 PromQL（全称为 Prometheus Query Language），支持用户进行实时的数据查询及聚合操作；

PromQL 支持处理两种向量，并内置提供了一组用于数据处理的函数

- 即时向量：在最近一次的单个时间戳上采集和跟踪的数据指标,即时间点数据
- 时间范围向量：指定时间范围内的所有时间戳上的数据指标,即时间段数据

#### 1.5.4.4 数据告警

抓取到异常值后，Prometheus 支持通过告警（Alert）机制向用户发送反馈或警示，以触发用户能够及时采取应对措施；但是Prometheus Server仅负责生成告警指示，具体的告警行为由另一个独立的应用程序 AlertManager 负责

- 告警指示由Prometheus Server基于用户提供的告警规则周期性计算生成
- Alertmanager接收到Prometheus Server 发来的告警指示后，基于用户定义的告警路由(route)向告警接收人发送告警信息；

![image-20250915171623408](Prometheus.assets/image-20250915171623408.png)

# 二、Prometheus 部署和监控

Prometheus部署相关软件版本

为了更好的更全面的演示 Prometheus 功能，我们将相关的组件也安装起来，以实现业务环境的全监控，相关软件版本信息如下

| 软件            | 地址                                                         |
| --------------- | ------------------------------------------------------------ |
| Prometheus      | https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-amd64.tar.gz |
| altermanager    | https://github.com/prometheus/alertmanager/releases/download/v0.23.0/alertmanager-0.23.0.linux-amd64.tar.gz |
| node_exporter   | https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz |
| mysqld_exporter | https://github.com/prometheus/mysqld_exporter/releases/download/v0.13.0/mysqld_exporter-0.13.0.linux-amd64.tar.gz |
| grafana         | https://dl.grafana.com/enterprise/release/grafana-enterprise_8.2.1_amd64.deb |

## 2.1 Prometheus 部署和配置

### 2.1.1 常见部署方式

https://prometheus.io/docs/prometheus/latest/installation/

- 包安装

  RedHat 系统

  ~~~shell
  https://packagecloud.io/app/prometheus-rpm/release/search
  ~~~

  Ubuntu 和 Debian

  可直接使用apt命令使用内置仓库直接安装

- 二进制安装

  ~~~shell
  https://prometheus.io/download/
  ~~~

- 基于 docker 运行

  https://prometheus.io/docs/prometheus/latest/installation/

- 基于 docker compose 运行

  https://github.com/mohamadhoseinmoradi/Docker-Compose-Prometheus-andGrafana/blob/master/docker-compose.yml

- 基于 Kubernetes Operator 安装

  https://github.com/coreos/kube-prometheus

  https://github.com/prometheus-operator/kube-prometheus

### 2.1.2 包安装

#### 2.1.2.1 Ubuntu 包安装

~~~shell
# 2204
root@prometheus-221:~ 17:23:57 # apt list prometheus
Listing... Done
prometheus/jammy-security,jammy-updates 2.31.2+ds1-1ubuntu1.22.04.3 amd64

root@prometheus-221:~ 17:24:08 # apt install -y prometheus

# 安装完成，服务启动
root@prometheus-221:~ 17:26:26 # systemctl status prometheus
● prometheus.service - Monitoring system and time series database
     Loaded: loaded (/lib/systemd/system/prometheus.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-09-15 17:26:07 CST; 24s ago
       Docs: https://prometheus.io/docs/introduction/overview/
             man:prometheus(1)
   Main PID: 3539 (prometheus)
      Tasks: 9 (limit: 4514)
     Memory: 20.3M
        CPU: 555ms
     CGroup: /system.slice/prometheus.service
             └─3539 /usr/bin/prometheus

Sep 15 17:26:08 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:08.142Z caller=head.go:481 level=info component=tsdb msg="Replaying on-disk memory>
Sep 15 17:26:08 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:08.142Z caller=head.go:515 level=info component=tsdb msg="On-disk memory mappable >
Sep 15 17:26:08 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:08.143Z caller=head.go:521 level=info component=tsdb msg="Replaying WAL, this may >
Sep 15 17:26:08 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:08.153Z caller=head.go:592 level=info component=tsdb msg="WAL segment loaded" segm>
Sep 15 17:26:08 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:08.153Z caller=head.go:598 level=info component=tsdb msg="WAL replay completed" ch>
Sep 15 17:26:08 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:08.159Z caller=main.go:850 level=info fs_type=EXT4_SUPER_MAGIC
Sep 15 17:26:08 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:08.159Z caller=main.go:853 level=info msg="TSDB started"
Sep 15 17:26:08 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:08.160Z caller=main.go:980 level=info msg="Loading configuration file" filename=/e>
Sep 15 17:26:13 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:13.616Z caller=main.go:1017 level=info msg="Completed loading of configuration fil>
Sep 15 17:26:13 prometheus-221 prometheus[3539]: ts=2025-09-15T09:26:13.617Z caller=main.go:795 level=info msg="Server is ready to receive web requests>
root@prometheus-221:~ 17:26:33 #


# 内置了node exporter
root@prometheus-221:~ 17:26:33 # systemctl status prometheus-node-exporter
● prometheus-node-exporter.service - Prometheus exporter for machine metrics
     Loaded: loaded (/lib/systemd/system/prometheus-node-exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-09-15 17:25:49 CST; 1min 9s ago
       Docs: https://github.com/prometheus/node_exporter
   Main PID: 2780 (prometheus-node)
      Tasks: 9 (limit: 4514)
     Memory: 8.9M
        CPU: 884ms
     CGroup: /system.slice/prometheus-node-exporter.service
             └─2780 /usr/bin/prometheus-node-exporter

Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.003Z caller=node_exporter.go:115 level=info collector=thermal_zone
Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.003Z caller=node_exporter.go:115 level=info collector=time
Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.003Z caller=node_exporter.go:115 level=info collector=timex
Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.003Z caller=node_exporter.go:115 level=info collector=udp_queues
Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.003Z caller=node_exporter.go:115 level=info collector=uname
Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.003Z caller=node_exporter.go:115 level=info collector=vmstat
Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.003Z caller=node_exporter.go:115 level=info collector=xfs
Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.003Z caller=node_exporter.go:115 level=info collector=zfs
Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.004Z caller=node_exporter.go:199 level=info msg="Listening on" ad>
Sep 15 17:25:50 prometheus-221 prometheus-node-exporter[2780]: ts=2025-09-15T09:25:50.004Z caller=tls_config.go:195 level=info msg="TLS is disabled." h>
root@prometheus-221:~ 17:27:01 #



# 查看端口和进程
root@prometheus-221:~ 17:27:01 # ss -tunlp | grep prometheus
tcp   LISTEN 0      4096               *:9100            *:*    users:(("prometheus-node",pid=2780,fd=3))
tcp   LISTEN 0      4096               *:9090            *:*    users:(("prometheus",pid=3539,fd=4))     
root@prometheus-221:~ 17:27:24 # ps -ef | grep prometheus
prometh+    2780       1  1 17:25 ?        00:00:01 /usr/bin/prometheus-node-exporter
prometh+    3539       1  0 17:26 ?        00:00:00 /usr/bin/prometheus
root        3800    1314  0 17:27 pts/0    00:00:00 grep --color=auto prometheus
root@prometheus-221:~ 17:27:35 # 


# 访问如下链接可以看到如下显示
http://<prometheus服务器IP>:9090
~~~

![image-20250915172814990](Prometheus.assets/image-20250915172814990.png)

#### 2.1.2.2 RedHat/Rocky/Centos

RHEL/Rocky/CentOS 上默认没有 Prometheus 的仓库，可自行配置基于 yum repository 安装 Prometheus-Server

https://packagecloud.io/app/prometheus-rpm/release/search

~~~shell
# repo 文件配置
[prometheus]
name=prometheus
baseurl=https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch
repo_gpgcheck=1
enabled=1
gpgkey=https://packagecloud.io/prometheus-rpm/release/gpgkey
       https://raw.githubusercontent.com/lest/prometheus-rpm/master/RPM-GPG-KEYprometheus-rpm
gpgcheck=1
metadata_expire=300
~~~

### 2.1.3 二进制安装 Prometheus

#### 2.1.3.1 下载二进制包并解压

https://prometheus.io/download/

https://github.com/prometheus/prometheus/releases

~~~shell
root@prometheus-221:~ 17:33:32 # wget https://github.com/prometheus/prometheus/releases/download/v2.19.2/prometheus-2.19.2.linux-amd64.tar.gz


root@prometheus-221:~ 17:45:57 # tar xf prometheus-2.19.2.linux-amd64.tar.gz -C /usr/local/
root@prometheus-221:~ 17:46:15 # cd /usr/local/
root@prometheus-221:/usr/local 17:46:22 # ln -sv prometheus-2.19.2.linux-amd64 prometheus
'prometheus' -> 'prometheus-2.19.2.linux-amd64'
root@prometheus-221:/usr/local 17:46:36 # ls -l prometheus
lrwxrwxrwx 1 root root 29 Sep 15 17:46 prometheus -> prometheus-2.19.2.linux-amd64
root@prometheus-221:/usr/local 17:46:40 # 
root@prometheus-221:/usr/local 17:46:40 # ls -l prometheus/
total 150564
drwxr-xr-x 2 3434 3434     4096 Jun 26  2020 console_libraries
drwxr-xr-x 2 3434 3434     4096 Jun 26  2020 consoles
-rw-r--r-- 1 3434 3434    11357 Jun 26  2020 LICENSE
-rw-r--r-- 1 3434 3434     3184 Jun 26  2020 NOTICE
-rwxr-xr-x 1 3434 3434 88382754 Jun 26  2020 prometheus
-rw-r--r-- 1 3434 3434      926 Jun 26  2020 prometheus.yml
-rwxr-xr-x 1 3434 3434 50644081 Jun 26  2020 promtool
-rwxr-xr-x 1 3434 3434 15117787 Jun 26  2020 tsdb
root@prometheus-221:/usr/local 17:46:55 #

# 由于初始的 Prometheus 目录比较混乱，因此我们给他调整一下
# 创建相关目录（data、bin、conf）,data 目录是默认的存放数据目录,可以不创建,系统会自动创建,可以通过选项--storage.tsdb.path="data/" 修改
# 将 prometheus、prometools 放到 bin 目录下，将 prometheus.yaml 放到 conf 目录
root@prometheus-221:/usr/local/prometheus 10:58:28 # ls -l
total 14800
drwxr-xr-x 2 prometheus prometheus     4096 Sep 15 22:18 bin
drwxr-xr-x 2 prometheus prometheus     4096 Sep 15 22:18 conf
drwxr-xr-x 2 prometheus prometheus     4096 Jun 26  2020 console_libraries
drwxr-xr-x 2 prometheus prometheus     4096 Jun 26  2020 consoles
drwxr-xr-x 5 prometheus prometheus     4096 Sep 16 10:53 data
-rw-r--r-- 1 prometheus prometheus    11357 Jun 26  2020 LICENSE
-rw-r--r-- 1 prometheus prometheus     3184 Jun 26  2020 NOTICE
-rwxr-xr-x 1 prometheus prometheus 15117787 Jun 26  2020 tsdb
root@prometheus-221:/usr/local/prometheus 10:58:30 # 


# 创建 Prometheus 的启动用户
root@prometheus-221:/usr/local/prometheus 10:58:30 # useradd -r -s /sbin/nologin prometheus

# 修改文件的属主和属组
root@prometheus-221:/usr/local/prometheus 10:58:30 # chown -R prometheus.prometheus /usr/local/prometheus/

# 配置环境变量
root@prometheus-221:~ 11:01:25 # cat /etc/profile.d/prometheus.sh 
############################
# File Name: /etc/profile.d/prometheus.sh
# Author: xuruizhao
# mail: xuruizhao00@163.com
# Created Time: Mon 15 Sep 2025 10:22:10 PM CST
############################
#!/bin/bash
export PROMETHEUS_HOME=/usr/local/prometheus
export PATH=${PROMETHEUS_HOME}/bin:$PATH
root@prometheus-221:~ 11:01:30 # source /etc/profile.d/prometheus.sh 


# 查看默认的配置文件
root@prometheus-221:~ 11:01:30 # grep -Ev "^ *#|^$" /usr/local/prometheus/conf/prometheus.yml
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
alerting:
  alertmanagers:
  - static_configs:
    - targets:
rule_files:
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']
root@prometheus-221:~ 11:02:15 #


# 检查配置文件是否正确
root@prometheus-221:~ 11:02:15 # promtool check config /usr/local/prometheus/conf/prometheus.yml 
Checking /usr/local/prometheus/conf/prometheus.yml
  SUCCESS: 0 rule files found

root@prometheus-221:~ 11:02:54 #

~~~

#### 2.1.3.2 创建 service 文件

~~~shell
root@prometheus-221:~ 11:02:54 # cat /lib/systemd/system/prometheus.service 
#配置解析：
#需要将定制的 prometheus 的配置文件和数据目录作为启动参数配置好
#其它的参数，可以基于 prometheus --help 查看更多
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
Restart=on-failure
User=prometheus
Group=prometheus
WorkingDirectory=/usr/local/prometheus/
ExecStart=/usr/local/prometheus/bin/prometheus --config.file=/usr/local/prometheus/conf/prometheus.yml --web.enable-lifecycle
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
root@prometheus-221:~ 11:03:25 # systemctl daemon-reload
root@prometheus-221:~ 11:03:25 # systemctl enable --now prometheus.service
root@prometheus-221:~ 11:04:06 # ss -tnlp |grep prometheus
LISTEN 0      4096               *:9090            *:*    users:(("prometheus",pid=1893,fd=7))     
root@prometheus-221:~ 11:04:12 # 

# 选项--web.enable-lifecycle支持reload加载修改过的配置
root@prometheus-221:~ 11:04:12 # curl -X POST http://192.168.121.221:9090/-/reload
root@prometheus-221:~ 11:04:37 # systemctl reload prometheus
~~~

#### 2.1.3.3 测试访问

~~~shell
#浏览器访问:
http://192.168.121.221:9090/
~~~

![image-20250916110638909](Prometheus.assets/image-20250916110638909.png)

![image-20250916110649434](Prometheus.assets/image-20250916110649434.png)

~~~shell
#浏览器访问:
http://192.168.121.221:9090/metrics
~~~

![image-20250916110720075](Prometheus.assets/image-20250916110720075.png)

~~~shell
root@prometheus-221:~ 11:05:58 # curl http://localhost:9090/metrics
# HELP go_gc_duration_seconds A summary of the pause duration of garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 2.3502e-05
go_gc_duration_seconds{quantile="0.25"} 3.0639e-05
go_gc_duration_seconds{quantile="0.5"} 0.00014196
go_gc_duration_seconds{quantile="0.75"} 0.000495603
go_gc_duration_seconds{quantile="1"} 0.002020684
go_gc_duration_seconds_sum 0.006821508
go_gc_duration_seconds_count 22
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 40
# HELP go_info Information about the Go environment.
# TYPE go_info gauge
go_info{version="go1.14.4"} 1
....

~~~

#### 2.1.3.4 Dashboard 菜单说明

~~~shell
#一级目录解析
Alerts  #Prometheus的告警信息菜单
Graph   #Prometheus的图形展示界面，这是prometheus默认访问的界面
Status  #Prometheus的状态数据界面
Help    #Prometheus的帮助信息界面

#Status子菜单,在Status菜单下存在很多的子选项，其名称和功能效果如下：
Runtime & Build Information 		# 服务主机的运行状态信息及内部的监控项基本信息
Command-Line Flags 					# 启动时候从配置文件中加载的属性信息
Configuration 						# 配置文件的具体内容(yaml格式)
Rules 								# 查询、告警、可视化等数据分析动作的规则记录
Targets 							# 监控的目标对象，包括主机、服务等以endpoint形式存在
Service Discovery 					# 自动发现的各种Targets对象列表
~~~

我们选择监控项的作用就是生成规则表达式，当然，规则表达式的功能远远超过选择监控项的功能。但是这些定制采集数据的表达式，在刷新的时候，就没有了，这也是我们需要可视化插件的原因。我们选择一个监控项"scrape_duration_seconds"，然后点击"Execute"，查看效果

#### 2.1.3.5 API 访问

Prometheus提供了一组管理API，以简化自动化和集成。

需要加载 `--web.enable-lifecycle` 参数

注意：{ip:port} 是Prometheus所在的IP和端口

- 健康检查

  GET {ip:port}/-/healthy

  该端点始终返回200，应用于检查Prometheus的运行状况。

- 准备检查

  GET {ip:port}/-/ready

  当Prometheus准备服务流量（即响应查询）时，此端点返回200。

- 加载配置

  PUT {ip:port}/-/reload

  POST {ip:port}/-/reload

- 关闭服务

  PUT {ip:port}/-/quit

  POST {ip:port}/-/quit

~~~shell
root@prometheus-221:~ 13:02:17 # cat /lib/systemd/system/prometheus.service  | grep '\-\-web.enable-lifecycle'
ExecStart=/usr/local/prometheus/bin/prometheus --config.file=/usr/local/prometheus/conf/prometheus.yml --web.enable-lifecycle
root@prometheus-221:~ 13:02:21 # 


# 修改配置后可以加载服务而无需重启服务
root@prometheus-221:~ 13:02:21 # curl -X POST http://localhost:9090/-/reload

# 关闭服务
root@prometheus-221:~ 13:02:53 # curl -X POST http://localhost:9090/-/quit
Requesting termination... Goodbye
root@prometheus-221:~ 13:03:19 # systemctl is-active prometheus.service 
inactive
root@prometheus-221:~ 13:03:25 # 

~~~

**如果在启动时没有加载`--web.enable-lifecycle` 参数，关闭API中的Load和quit功能，仍然支持healthy和ready**

#### 2.1.3.6 优化配置

~~~shell
root@prometheus-221:~ 13:03:25 # /usr/local/prometheus/bin/prometheus --help
.......
--web.enable-lifecycle #可以支持http方式实现reload和shutdown功能，可以被远程关毕服务，有安全风险，不建议开启，默认关闭
--web.read-timeout=5m  #Maximum duration before timing out read of the request, and closing idle connections. 请求连接的最⼤等待时间,可以防⽌太多的空闲连接占⽤资源
--web.max-connections=512 #Maximum number of simultaneous connections. 最⼤链接数
--storage.tsdb.retention=15d #How long to retain samples in the storage.prometheus开始采集监控数据后 会存在内存中和硬盘中对于保留期限的设置,太长硬盘和内存都吃不消,太短要查历史数据就没有了,企业中设置15天为宜,默认值为0
--storage.tsdb.path="data/" #Base path for metrics storage. 存储数据路径,建议独立分区,防止把根⽬录塞满,默认data/目录
--query.timeout=2m #Maximum time a query may take before being aborted.此为默认值2m
--query.max-concurrency=20 #Maximum number of queries executed concurrently.此为默认值20
~~~

查看配置

![image-20250916130627524](Prometheus.assets/image-20250916130627524.png)

### 2.1.4 容器化启动

https://prometheus.io/docs/prometheus/latest/installation/

#### 2.1.4.1 Docker 启动

~~~shell
#简单启动
[root@prometheus ~]# docker run -d --name prometheus -p 9090:9090 prom/prometheus
#定制配置文件启动，默认容器的配置文件路径/etc/prometheus/prometheus.yml
[root@prometheus ~]# docker run -d  --name=prometheus -p 9090:9090 -v ./prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus --web.enable-lifecycle

#定制启动
[root@prometheus ~]# docker run -d  --name=prometheus -p 9090:9090 -v /root/prometheus.yml:/prometheus-config/prometheus.yml prom/prometheus --web.enable-lifecycle --config.file=/prometheus-config/prometheus.yml


#浏览器访问:http://prometheus服务器:9090/
~~~

#### 2.1.4.2 Docker compose

~~~yaml
version: '3.6'
volumes:
   prometheus_data: {}
networks:
 monitoring:
   driver: bridge
services:
 prometheus:
   image: prom/prometheus:v2.40.2
   volumes:
      - ./prometheus/:/etc/prometheus/
      - prometheus_data:/prometheus
   command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
      - '--web.enable-lifecycle'
   networks:
      - monitoring
   ports:
      - 9090:9090
    restart: always
~~~

### 2.1.5 配置文件说明

Prometheus可以通过命令行或者配置文件的方式对服务进行配置。

- 命令行方式一般用于不可变的系统参数配置，例如存储位置、要保留在磁盘和内存中的数据量等；

  配置文件用于定义与数据动态获取相关的配置选项和文件等内容。

  命令行方式的配置属性可以通过 prometheus -h 的方式来获取，这些配置属性主要在服务启动时候设置.

- 配置文件方式，需要在prometheus.yml 文件中修改配置属性，该配置文件的内容是以YAML格式编写的。

官方文档:

https://prometheus.io/docs/prometheus/latest/configuration/configuration/

默认情况下，Prometheus 的配置文件有四部分组成，效果如下：

~~~shell
root@prometheus-221:~ 13:05:09 #  egrep -v '^#| #|^$' /usr/local/prometheus/conf/prometheus.yml
global:
alerting:
  alertmanagers:
  - static_configs:
    - targets:
rule_files:
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']

~~~

配置解析

~~~shell
#核心配置：
global 			#全局配置内容
alerting 		#触发告警相关的配置，主要是与 Alertmanager 相关的设置。
rule_files 		#各种各样的外置规则文件配置，包含了各种告警表达式、数据查询表达式等
scrape_configs 	#监控项的配置列表，这是最核心的配置

#除了默认的四项配置之外，prometheus还有另外可选的其它配置如下
#扩展配置(8项)
tls_config、static_config、relabel_config、metric_relabel_configs、
alert_relabel_configs、alertmanager_config、remote_write、remote_read
#平台集成配置(12项)
azure_sd_config、consul_sd_config、dns_sd_config、ec2_sd_config、
openstack_sd_config、file_sd_config、gce_sd_config、kubernetes_sd_config、
marathon_sd_config、nerve_sd_config、serverset_sd_config、triton_sd_config
~~~

scrape_configs 管理

scrape_configs 是操作最多的一个配置段，它指定了一组监控目标及其细节配置参数，这些目标和参数描述了如何获取指定主机上的时序数据。配置样例如下：

~~~shell
scrape_configs:  
  - job_name: '<job_name>'
    static_configs:
      - targets: [ '<host_ip:host_port>', ... ]
        labels: { <labelname>: <labelvalue> ... }
#配置解析：
#在一般情况下，一个scrape_configs配置需要指定一个或者多个job，根据我们之前对基本概念的了解，每一个job都是一系列的instance/实例集合，借助job我们可以将目标主机进行分组管理。
#对于job内部的每一个instance的配置，都需要借助于static_configs参数获取目标列表，只要在该列表位置的目标，都可以被Prometheus动态服务自动发现。
#static_configs可以借助于 targets 以 ip+port 方式发现目标，也可以使用 labels 以标签方式发现目标。
~~~

**语法检查**

~~~shell
root@prometheus-221:~ 13:14:58 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
  SUCCESS: 0 rule files found

root@prometheus-221:~ 13:15:13 #
~~~

## 2.2 Node Exporter 安装

安装 Node Exporter 用于收集各 node 主机节点上的监控指标数据，监听端口为 9100

github 链接

https://github.com/prometheus/node_exporter

官方下载: 

https://prometheus.io/download/

### 2.2.1 下载并安装

在需要监控的所有节点主机上进行安装

~~~shell
root@prometheus-221:~ 11:35:22 # wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz

root@node1-111:~ 11:38:57 # tar xf node_exporter-1.9.1.linux-amd64.tar.gz -C /usr/local/
root@node1-111:~ 11:39:08 # cd /usr/local/
root@node1-111:/usr/local 11:39:13 # ln -sv node_exporter-1.9.1.linux-amd64 node_exporter
'node_exporter' -> 'node_exporter-1.9.1.linux-amd64'
root@node1-111:/usr/local 11:39:26 # cd node_exporter
root@node1-111:/usr/local/node_exporter 11:39:27 # mkdir bin
root@node1-111:/usr/local/node_exporter 11:39:29 # mv node_exporter  bin/
root@node1-111:/usr/local/node_exporter 11:39:35 # useradd -r -s /sbin/nologin prometheus
root@node1-111:/usr/local/node_exporter 11:39:41 # chown -R prometheus.prometheus /usr/local/node_exporter/
root@node1-111:/usr/local/node_exporter 11:39:47 # vim  /lib/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/node_exporter/bin/node_exporter --collector.zoneinfo
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
User=prometheus
Group=prometheus

[Install]
WantedBy=multi-user.target

root@node1-111:/usr/local/node_exporter 11:40:22 # systemctl enable --now node_exporter.service 
root@node1-111:/usr/local/node_exporter 18:11:30 # systemctl status  node_exporter.service 
● node_exporter.service - Prometheus Node Exporter
     Loaded: loaded (/lib/systemd/system/node_exporter.service; disabled; vendor preset: enabled)
     Active: active (running) since Wed 2025-09-17 18:11:30 CST; 4s ago
   Main PID: 1975 (node_exporter)
      Tasks: 6 (limit: 4514)
     Memory: 2.8M
        CPU: 55ms
     CGroup: /system.slice/node_exporter.service
             └─1975 /usr/local/node_exporter/bin/node_exporter --collector.zoneinfo
root@node1-111:/usr/local/node_exporter 18:11:49 # ss -tunlp | grep 9100
tcp   LISTEN 0      4096               *:9100            *:*    users:(("node_exporter",pid=1975,fd=3)) 
~~~

### 2.2.2 Node Exporter 常见指标

~~~ini
node_boot_time：系统自启动以后的总计时间
node_cpu：系统CPU使用量
node_disk*：磁盘IO
node_filesystem*：系统文件系统用量
node_load1：系统CPU负载
node_memeory*：内存使用量
node_network*：网络带宽指标
node_time：当前系统时间
go_*：node exporter中go相关指标
process_*：node exporter自身进程相关运行指标
~~~

### 2.2.3 shell 脚本一键安装

~~~shell
#!/bin/bash
#
#********************************************************************
#Author:            xuruizhao
#FileName:          install_node_exporter.sh
#E-mail:            xuruizhao00@163.com
#********************************************************************

#支持在线和离线安装，建议离线安装

NODE_EXPORTER_VERSION=1.7.0
#NODE_EXPORTER_VERSION=1.5.0
#NODE_EXPORTER_VERSION=1.4.0
#NODE_EXPORTER_VERSION=1.3.1
#NODE_EXPORTER_VERSION=1.2.2
NODE_EXPORTER_FILE="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
NODE_EXPORTER_URL=https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_FILE}
INSTALL_DIR=/usr/local

HOST=`hostname -I|awk '{print $1}'`


. /etc/os-release

msg_error() {
  echo -e "\033[1;31m$1\033[0m"
}

msg_info() {
  echo -e "\033[1;32m$1\033[0m"
}

msg_warn() {
  echo -e "\033[1;33m$1\033[0m"
}


color () {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "    
    elif [ $2 = "failure" -o $2 = "1"  ] ;then 
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo 
}


install_node_exporter () {
    if [ ! -f  ${NODE_EXPORTER_FILE} ] ;then
        wget ${NODE_EXPORTER_URL} ||  { color "下载失败!" 1 ; exit ; }
    fi
    [ -d $INSTALL_DIR ] || mkdir -p $INSTALL_DIR
    tar xf ${NODE_EXPORTER_FILE} -C $INSTALL_DIR
    cd $INSTALL_DIR &&  ln -s node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter
    mkdir -p $INSTALL_DIR/node_exporter/bin
    cd $INSTALL_DIR/node_exporter &&  mv node_exporter bin/ 
	id prometheus &> /dev/null || useradd -r -s /sbin/nologin prometheus
	chown -R prometheus.prometheus ${INSTALL_DIR}/node_exporter/
	
      
    cat >  /etc/profile.d/node_exporter.sh <<EOF
export NODE_EXPORTER_HOME=${INSTALL_DIR}/node_exporter
export PATH=\${NODE_EXPORTER_HOME}/bin:\$PATH
EOF

}


node_exporter_service () {
    cat > /lib/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/node_exporter/bin/node_exporter
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
User=prometheus
Group=prometheus

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now node_exporter.service
}


start_node_exporter() { 
    systemctl is-active node_exporter.service
    if [ $?  -eq 0 ];then  
        echo 
        color "node_exporter 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        msg_info "http://$HOST:9100/metrics" 
    else
        color "node_exporter 安装失败!" 1
        exit
    fi 
}

install_node_exporter

node_exporter_service

start_node_exporter
~~~

### 2.2.4 访问 Node Exporter 界面

浏览器访问

http://192.168.121.111:9100/

![image-20250917181810400](Prometheus.assets/image-20250917181810400.png)

![image-20250917181830228](Prometheus.assets/image-20250917181830228.png)

## 2.3 Prometheus 采集 Node Exporter 数据

配置 prometheus 通过 node exporter 组件采集node节点的监控指标数据

### 2.3.1 修改 Prometheus 配置文件

https://prometheus.io/docs/prometheus/latest/configuration/configuration

~~~shell
root@prometheus-221:~ 18:25:16 # cat /usr/local/prometheus/conf/prometheus.yml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
       # The label name is added as a label `label_name=<label_value>` to any timeseries scraped from this config.
        labels:
          app: "prometheus"
  - job_name: "node-exporter"				# 添加以下行,指定监控的node exporter节点

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:              
      - targets: 
        - 192.168.121.111:9100
        - 192.168.121.112:9100
        - 192.168.121.113:9100
        - 192.168.121.221:9100
# 属性解析：
# 新增一个 job_name 和 static_configs 的属性
# 每一个 target 即前面基本提到的实例 instance，格式就是"ip:port"
root@prometheus-221:~ 18:25:18 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 18:25:23 # systemctl restart prometheus.service 

~~~

### 2.3.2 Prometheus 验证 Node 节点状态

浏览器访问如下地址

http://192.168.121.221:9090/targets

~~~shell
# 结果显示：当我们把鼠标放到 Labels 部位的时候，就会将改 target 的属性信息标识出来，其中"__*"开头的就是该对象的私有属性，当我们点击 Endpoint 的时候，就可以看到该 node节点上的所有定制好的监控项。

~~~

![image-20250917182847023](Prometheus.assets/image-20250917182847023.png)

### 2.3.3 Prometheus 验证 Node 节点监控数据

点上面页面的主机链接,可以直接跳转至对应节点的页面

![image-20250917182943382](Prometheus.assets/image-20250917182943382.png)

![image-20250917183043242](Prometheus.assets/image-20250917183043242.png)

![image-20250917183351576](Prometheus.assets/image-20250917183351576.png)

## 2.4 Grafana 展示 Prometheus 数据

### 2.4.1 Grafana 简介

Grafana是一个开源的度量分析与可视化套件，它基于go语言开发。经常被用作基础设施的时间序列数据和应用程序分析的可视化，应用场景非常多。

Grafana不仅仅支持很多类型的时序数据库数据源，比如Graphite、InfluxDB、Prometheus、Elasticsearch等，虽然每种数据源都有独立的查询语言和能力，但是Grafana的查询编辑器支持所有的数据源，而且能很好的支持每种数据源的特性。

通过该查询编辑器可以对所有数据进行整合，而且还可以在同一个dashboard上进行综合展示。

Grafana最具特色的就是各种各样漂亮的可视化界面，在Grafana提供了各种定制好的，可以直接给各种软件直接使用的展示界面模板

Grafana 默认监听于TCP协议的3000端口，支持集成其他认证服务，且能够通过/metrics输出内建指标

可以在 https://grafana.com/dashboards/ 页面查询到我们想要的各种dashboard模板

### 2.4.2 Grafana 部署

Grafana官方下载链接

https://grafana.com/grafana/download

在 prometheus 服务器同时也安装 grafana

#### 2.4.2.1 基于包安装

~~~shell
# 下载软件
root@prometheus-221:~ 20:26:48 # wget https://dl.grafana.com/enterprise/release/grafana-enterprise_12.0.0_amd64.deb


# 安装软件
root@prometheus-221:~ 20:42:39 # apt update
# 注意：安装的是本地文件，所以要加文件路径
root@prometheus-221:~ 20:42:39 # apt -y install ./grafana-enterprise_12.0.0_amd64.deb 

#如果安装失败,解决依赖关系
root@prometheus-221:~ 20:42:39 # apt -y --fix-broken install

# 查看插件列表
root@prometheus-221:~ 20:47:02 # grafana-cli plugins list-remote


# 安装饼状图的插件,如果安装失败,多试几次(此步可选)
root@prometheus-221:~ 20:47:08 # grafana-cli plugins install grafana-piechart-panel
root@prometheus-221:~ 20:47:08 # grafana-cli plugins ls

# 安装的插件存放在如下目录中
root@prometheus-221:~ 20:47:40 # ls -l /var/lib/grafana/plugins/
total 20
drwxr-x--- 5 grafana grafana 4096 Sep 17 20:46 grafana-exploretraces-app
drwxr-x--- 3 grafana grafana 4096 Sep 17 20:46 grafana-lokiexplore-app
drwxr-x--- 3 grafana grafana 4096 Sep 17 20:46 grafana-metricsdrilldown-app
drwxr-xr-x 4 root    root    4096 Sep 17 20:47 grafana-piechart-panel
drwxr-x--- 5 grafana grafana 4096 Sep 17 20:46 grafana-pyroscope-app
root@prometheus-221:~ 20:48:13 # 


# 启动服务
root@prometheus-221:~ 20:44:43 # systemctl daemon-reload
root@prometheus-221:~ 20:45:25 # systemctl enable --now grafana-server.service


# 查看
root@prometheus-221:~ 20:45:55 # ss -ntulp|grep 3000
tcp   LISTEN 0      4096               *:3000            *:*    users:(("grafana",pid=3707,fd=17))  
~~~

#### 2.4.2.2 容器安装

https://hub.docker.com/r/grafana/grafana

~~~shell
docker run -d --name=grafana -p 3000:3000 grafana/grafana
~~~

### 2.4.3 配置 Prometheus 数据源

#### 2.4.3.1 登录 Grafana Web

~~~shell
#浏览器访问 http://192.168.121.221:3000/，查看效果
#输入用户名和密码：admin/admin，就会进入到更改密码的页面，查看效果
~~~

![image-20250917205100426](Prometheus.assets/image-20250917205100426.png)

输入更改后的密码后，此处为了方便密码使用 123456, 点击"Submit"后，就会进入到首页，查看效果

#### 2.4.3.2 添加 Prometheus 数据源

添加数据源: 点击 "Add your first data source" 

![image-20250917205207439](Prometheus.assets/image-20250917205207439.png)

选择 "Prometheus" 出现添加界面

![image-20250917205232584](Prometheus.assets/image-20250917205232584.png)

按照如下配置信息，在 Settings 界面对 Prometheus 进行配置 ，效果如下

输入 Prometheus 的地址(192.168.121.221:9090或者localhost:9090)，其它没有做任何变动。

![image-20250917205318214](Prometheus.assets/image-20250917205318214.png)

其它信息不用设置，点击最下面的 "Save & Test" 查看效果

![image-20250917205405528](Prometheus.assets/image-20250917205405528.png)

#### 2.4.3.3 使用数据源中内置的 Dashboard

点 Dashboards 页签内的 import,导入内置的三个模板

![image-20250917205515900](Prometheus.assets/image-20250917205515900.png)

查看默认的三个模板

![image-20250917205537335](Prometheus.assets/image-20250917205537335.png)

注意: 由于没有将 grafana 纳入到 prometheus 监控的 target,所以以下没有数据

![image-20250917205615866](Prometheus.assets/image-20250917205615866.png)

### 2.4.4 导入指定模板展示 Node Exporter 数据

上面内置的模板不太理想,导入指定的网络上比较合适的 Dashboard 模板

#### 2.4.4.1 登录 Grafana 官网查找模板

https://grafana.com/grafana/dashboards/

![image-20250917205819427](Prometheus.assets/image-20250917205819427.png)

![image-20250917205929742](Prometheus.assets/image-20250917205929742.png)

#### 2.4.4.2 导入指定模板

**导入8919（中文）,1860,11074,13978模板**

点击"import",将"https://grafana.com/dashboards/8919或1860或11074"添加到如下位置，点Load 后效果如下

![image-20250917210038587](Prometheus.assets/image-20250917210038587.png)

![image-20250917210120775](Prometheus.assets/image-20250917210120775.png)

在Prometheus Data Source右侧选择刚才配置的Prometheus数据源即可，然后点击"Import",查看效果

![image-20250917210147253](Prometheus.assets/image-20250917210147253.png)

结果显示：node_exporter部署完毕后，节点的信息立刻就展示出来了。

如果看不到数据的话

- 没有安装节点监控 NodePort软件
- 浏览器的时间与服务器的时间误差超过3s以上

## 2.5 监控 Grafana

Grafana 内置了支持 Prometheus 监控接口

### 2.5.1 配置 Prometheus 监控 Grafana

~~~yaml
# 添加以下行,指定监控的grafan节点
- job_name: "Grafana"
  static_configs:
    - targets: ["192.168.121.221:3000"]

~~~

~~~shell
root@prometheus-221:~ 21:04:24 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 21:05:15 # systemctl restart prometheus.service 
root@prometheus-221:~ 21:05:24 # 
~~~

### 2.5.2 Grafana 展示 Grafana

在 Grafana 的数据源 Prometheus 中内置模板 Grafana metrics 中即可展示 Grafana 的状态

![image-20250917210713325](Prometheus.assets/image-20250917210713325.png)

## 2.6 监控 zookeeper

监控的指标可以通过下面方式提供

- Prometheus 内置
- instrumentation 程序仪表: 应用内置的指标功能,比如: Zookeeper,Gitlab,Grafana 等
- 额外的 exporter,使用第三方开发的功能
- Pushgateway 提供
- 通过自行编程实现的功能代码,需要开发能力

### 2.6.1 安装配置 zookeeper

~~~shell
# 安装过程略

# zookeeper 内置了 Prometheus 配置
root@ubuntu2204:/usr/local/zookeeper 20:37:37 # tail /usr/local/zookeeper/conf/zoo.cfg 
# https://prometheus.io Metrics Exporter
#metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
#metricsProvider.httpHost=0.0.0.0
#metricsProvider.httpPort=7000
#metricsProvider.exportJvmInfo=true

metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
metricsProvider.httpHost=0.0.0.0
metricsProvider.httpPort=7000
metricsProvider.exportJvmInfo=true  # true为默认值
root@ubuntu2204:/usr/local/zookeeper 21:08:33 # 
root@ubuntu2204:/usr/local/zookeeper 21:08:33 # systemctl restart zookeeper.service
~~~

### 2.6.2 修改 Prometheus 配置

~~~yaml
- job_name: "zookeeper"
  static_configs:
    - targets: ["192.168.121.220:7000"]
root@prometheus-221:~ 21:09:42 # systemctl restart prometheus.service 
~~~

### 2.6.3 查看 Prometheus 监控数据

![image-20250917211046070](Prometheus.assets/image-20250917211046070.png)

### 2.6.4 配置 Grafana

搜索 zookeeper 模板  10465

点击 import ，注意：选择正确的 Cluster 名称才能正常显示

![image-20250917211229176](Prometheus.assets/image-20250917211229176.png)

## 2.7 Pushgateway 采集自定义数据

### 2.7.1 Pushgateway 简介

官方连接

https://prometheus.io/docs/practices/pushing/

![image-20250918120858556](Prometheus.assets/image-20250918120858556.png)

Pushgateway 是一项中介服务，允许您从无法抓取的作业中推送指标

虽然有很多的 Exporter 提供了丰富的数据,但生产环境中仍需要采集用户自定义的数据,可以利用Pushgateway实现

Pushgateway 是另⼀种采⽤客户端主动推送数据的⽅式,也可以获取监控数据的 prometheus 

Pushgateway与exporter 不同, Exporter 是被动采集数据

Pushgateway 是可以单独运⾏在 任何节点上的插件，并不⼀定要在被监控客户端

⽤户⾃定义的脚本或程序将需要监控的数据推送给 Pushgateway ,然后 prometheus server 再向 pushgateway 拉取数据

Pushgateway 缺点 

- Pushgateway 会形成⼀个单点瓶颈，假如好多个应用同时发送给⼀个 pushgateway 的进程,如果这个进程有故障，那么监控数据也就无法获取了
- 将失去 Prometheus 通过 up 指标（每次抓取时生成）的自动实例运行状况监控。
- Pushgateway 永远不会忘记推送给它的数据，并将它们永远暴露给 Prometheus，除非这些系列通过 Pushgateway 的 API 手动删除。
- Pushgateway 并不能对发送过来的数据进⾏更智能的判断,假如脚本中间采集出问题,那么有问题的数据 pushgateway⼀样照单全收发送给prometheus

### 2.7.2 安装 Pushgateway

https://prometheus.io/download/

https://github.com/prometheus/pushgateway/releases

~~~shell
root@prometheus-221:~ 14:04:43 # wget https://github.com/prometheus/pushgateway/releases/download/v1.11.1/pushgateway-1.11.1.linux-amd64.tar.gz

root@prometheus-221:~ 14:06:37 # tar xf pushgateway-1.11.1.linux-amd64.tar.gz -C /usr/local
root@prometheus-221:~ 14:06:50 # cd /usr/local
root@prometheus-221:/usr/local 14:06:52 # ln -sv  pushgateway-1.11.1.linux-amd64  pushgateway
'pushgateway' -> 'pushgateway-1.11.1.linux-amd64'
root@prometheus-221:/usr/local 14:07:07 # cd pushgateway
root@prometheus-221:/usr/local/pushgateway 14:07:09 # mkdir bin
root@prometheus-221:/usr/local/pushgateway 14:07:12 # ls -l
total 20916
drwxr-xr-x 2 root root     4096 Sep 18 14:07 bin
-rw-r--r-- 1 1001 1002    11357 Apr  9 21:26 LICENSE
-rw-r--r-- 1 1001 1002      487 Apr  9 21:26 NOTICE
-rwxr-xr-x 1 1001 1002 21394840 Apr  9 21:24 pushgateway
root@prometheus-221:/usr/local/pushgateway 14:07:14 # mv pushgateway bin/

root@prometheus-221:/usr/local/pushgateway 14:07:17 # id prometheus > /dev/null || useradd -r -s /sbin/nologin prometheus
root@prometheus-221:~ 20:23:28 # chown -R prometheus:prometheus /usr/local/pushgateway/

root@prometheus-221:/usr/local/pushgateway 14:08:27 # ldd /usr/local/pushgateway/bin/pushgateway
	not a dynamic executable
root@prometheus-221:/usr/local/pushgateway 14:08:30 #

# 配置环境变量
root@prometheus-221:/usr/local/pushgateway 14:10:00 # cat /etc/profile.d/pushgateway.sh
############################
# File Name: /etc/profile.d/pushgateway.sh
# Author: xuruizhao
# mail: xuruizhao00@163.com
# Created Time: Thu 18 Sep 2025 02:09:16 PM CST
############################
#!/bin/bash
export PUSH_HOME=/usr/local/pushgateway
export PATH=$PATH:$PUSH_HOME/bin
root@prometheus-221:/usr/local/pushgateway 14:10:03 # source /etc/profile.d/pushgateway.sh


# 配置 service 文件
root@prometheus-221:~ 14:11:11 # cat /lib/systemd/system/pushgateway.service
[Unit]
Description=Prometheus Pushgateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/pushgateway/bin/pushgateway
Restart=on-failure
User=prometheus
Group=prometheus

[Install]
WantedBy=multi-user.target
root@prometheus-221:~ 14:11:12 # systemctl daemon-reload 
root@prometheus-221:~ 14:11:18 # systemctl enable --now pushgateway.service 
Created symlink /etc/systemd/system/multi-user.target.wants/pushgateway.service → /lib/systemd/system/pushgateway.service.
root@prometheus-221:~ 14:11:23 # 
root@prometheus-221:~ 14:11:23 # ss -tunlp | grep 9091
tcp   LISTEN 0      4096               *:9091            *:*    users:(("pushgateway",pid=57630,fd=3))    
root@prometheus-221:~ 14:11:43 # 

~~~

![image-20250918141159300](Prometheus.assets/image-20250918141159300.png)

![image-20250918141214148](Prometheus.assets/image-20250918141214148.png)

### 2.7.3 配置 Prometheus 收集 Pushgateway 数据

~~~shell
root@prometheus-221:~ 14:13:55 # tail -3 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "pushgateway"
    static_configs:
      - targets: ["192.168.121.221:9091"]
root@prometheus-221:~ 14:14:01 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 14:14:11 # systemctl restart prometheus.service 
root@prometheus-221:~ 14:14:20 #
~~~

### 2.7.4 客户端发送数据给 Pushgateway

https://github.com/prometheus/pushgateway/blob/master/README.md

Examples:

- Push a single sample into the group identified by `{job="some_job"}`:

  ```
    echo "some_metric 3.14" | curl --data-binary @- http://pushgateway.example.org:9091/metrics/job/some_job
  ```

  

  Since no type information has been provided, `some_metric` will be of type `untyped`.

- Push something more complex into the group identified by `{job="some_job",instance="some_instance"}`:

  ```
    cat <<EOF | curl --data-binary @- http://pushgateway.example.org:9091/metrics/job/some_job/instance/some_instance
    # TYPE some_metric counter
    some_metric{label="val1"} 42
    # TYPE another_metric gauge
    # HELP another_metric Just an example.
    another_metric 2398.283
    EOF
  ```

  

  Note how type information and help strings are provided. Those lines are optional, but strongly encouraged for anything more complex.

- Delete all metrics in the group identified by `{job="some_job",instance="some_instance"}`:

  ```
    curl -X DELETE http://pushgateway.example.org:9091/metrics/job/some_job/instance/some_instance
  ```

  

- Delete all metrics in the group identified by `{job="some_job"}` (note that this does not include metrics in the `{job="some_job",instance="some_instance"}` group from the previous example, even if those metrics have the same job label):

  ```
    curl -X DELETE http://pushgateway.example.org:9091/metrics/job/some_job
  ```

  

- Delete all metrics in all groups (requires to enable the admin API via the command line flag `--web.enable-admin-api`):

  ```
    curl -X PUT http://pushgateway.example.org:9091/api/v1/admin/wipe
  ```

要推送一个度量值，需要使用以下 URL 路径定义向 Pushgateway 端点发送一个内容为"name =value"HTTP请求

推送 Metric 格式

~~~shell
http://<pushgateway_address>:<push_port>/metrics/job/<job_name>/[<label_name1>/<label_value1>]/[<label_nameN>/<label_valueN>]

#<job_name> 在Prometheus中指标的新加标签exported_<job_name>的值，在Pushgateway中是job名称
#<label_name>/<label_value〉将成为额外的标签/值对。
~~~

删除 Metric 命令格式，或者通过Pushgateway 图形删除

~~~shell
#删除指定 job_name中的所有 metric
curl -X DELETE http://<pushgateway_address>:<push_port/metrics/job/<job_name>
#删除指定实例的 metric
curl -X DELETE http://<pushgateway_address>:<push_port/metrics/job/<job_name>/instance/<instance_name>
~~~

范例: 命令

~~~shell
root@prometheus-221:~ 14:18:06 # echo "age 18" | curl --data-binary @- http://192.168.121.221:9091/metrics/job/pushgateway/instance/`hostname -I`

#说明
192.168.121.221:9091  #安装为 Pushgateway 主机的 IP和端口
pushgateway   #指定 jobname,会自动添加一个新标签名称为 exported_pushgateway
`hostname -I` #取当前主机的 IP为 instance 名称
@file 表示从file中读取数据
@-   表示从标准输入读取数据


~~~

![image-20250918142342451](Prometheus.assets/image-20250918142342451.png)

![image-20250918142421136](Prometheus.assets/image-20250918142421136.png)

范例: 通用脚本

~~~shell
root@prometheus-221:~ 14:29:54 # cat pushgateway_metric.sh
#!/bin/bash
#
#********************************************************************
#Author:            xuruizhao
#FileName:          pushgateway_metric.sh
#E-mail             xuruizhao00@163.com
#********************************************************************

METRIC_NAME=mem_free
METRIC_VALUE_CMD="free -b  | awk 'NR==2{print \$4}'"
#METRIC_VALUE_CMD="free -b  | awk 'NR==2'| tr  -s ' ' | cut -d' ' -f4"
METRIC_TYPE=gauge
METRIC_HELP="free memory"

PUSHGATEWAY_HOST=192.168.121.221:9091
EXPORTED_JOB=pushgateway_test
INSTANCE=`hostname -I|awk '{print $1}'`
SLEEP_TIME=1


CURL_URL="curl --data-binary @- http://${PUSHGATEWAY_HOST}/metrics/job/${EXPORTED_JOB}/instance/${INSTANCE}"

push_metric()  {
    while true ;do
        VALUE=`eval "$METRIC_VALUE_CMD"`
        echo $VALUE
        cat  <<EOF |  $CURL_URL
# HELP ${METRIC_NAME} ${METRIC_HELP}
# TYPE ${METRIC_NAME} ${METRIC_TYPE}
${METRIC_NAME} ${VALUE}
EOF
        sleep $SLEEP_TIME
    done
}

push_metric
~~~

# 三、PromQL

## 3.1 指标数据

### 3.1.1 数据基础

时间序列数据：

- 按照时间顺序记录系统、设备状态变化的数据，每个数据称为一个样本
- 数据采集以特定的时间周期进行，随着时间将这些样本数据记录下来，将生成一个离散的样本数据序列,该序列也称为向量（Vector）
- 将多个序列放在同一个坐标系内（以时间为横轴，以序列为纵轴），将形成一个由数据点组成的矩阵

![image-20250918160032492](Prometheus.assets/image-20250918160032492.png)

Prometheus基于指标名称（metrics name）以及附属的标签集（labelset）唯一定义一条时间序列

- 指标名称代表着监控目标上某类可测量属性的基本特征标识
- 标签则是这个基本特征上再次细分的多个可测量维度

### 3.1.2 数据模型

Prometheus中，每个时间序列都由指标名称（Metric Name）和标签（Label）来唯一标识

Metric Name的表示方式有下面两种

~~~ini
<metric name>{<label name>=<label value>, …}
{__name__="metric name",<label name>=<label value>, …} #通常用于Prometheus内部
~~~

![image-20250918160354388](Prometheus.assets/image-20250918160354388.png)

- 指标名称：

  通常用于描述系统上要测定的某个特征

  支持使用字母、数字、下划线和冒号，且必须能匹配RE2规范的正则表达式

  例如：http_requests_total表示接收到的HTTP请求总数

- 标签：

  键值型数据，附加在指标名称之上，从而让指标能够支持更多细化的多纬度特征；此为可选项

  标签名称可使用字母、数字和下划线，且必须能匹配RE2规范的正则表达式

  注意：以两个下划线 "__" 为前缀的名称为Prometheus系统预留使用

例如: 下面代表着两个不同的时间序列

~~~
http_requests_total{method=GET}
http_requests_total{method=POST}
~~~

### 3.1.3 样本数据

Prometheus的每个数据样本由两部分组成

- key: 包括三部分Metric 名称,Label, Timestamp(毫秒精度的时间戳)
- value: float64格式的数据

![image-20250918160521460](Prometheus.assets/image-20250918160521460.png)

PromQL支持基于定义的指标维度进行过滤，统计和聚合

- 指标名称和标签的特定组合代表着一个时间序列
- 不同的指标名称代表着不同的时间序列
- 指标名称相同，但标签不同的组合分别代表着不同的时间序列
- 更改任何标签值，包括添加或删除标签，都会创建一个新的时间序列
- 应该尽可能地保持标签的稳定性，否则，则很可能创建新的时间序列，更甚者会生成一个动态的数
- 据环境，并使得监控的数据源难以跟踪，从而导致建立在该指标之上的图形、告警及记录规则变得无效

## 3.2 PromQL 基础

### 3.2.1 PromQL 简介

Prometheus 提供一个内置的函数式的表达式语言PromQL(Prometheus Query Language)，可以帮助用户实现实时地查找和聚合时间序列数据。

PromQL表达式计算结果可以在图表中展示，也可以在Prometheus表达式浏览器中以表格形式展示，或者作为数据源, 以HTTP API的方式提供给外部系统使用。

==注意：默认情况下，是以当前时间为基准点，来进行数据的获取操作==

### 3.2.2 表达式形式

https://prometheus.io/docs/prometheus/latest/querying/basics/

每一个PromQL其实都是一个表达式，这些语句表达式或子表达式的计算结果可以为以下四种类型：

- instant vector 即时向量,瞬时数据

  具有相同时间戳的一组样本值的集合

  在某一时刻，抓取的所有监控项数据。这些度量指标数据放在同一个key中。

  一组时间序列，包含每个时间序列的单个样本，所有时间序列共享相同的时间戳

- range vector 范围向量

  指定时间范围内的所有时间戳上的数据指标，即在一个时间段内，抓取的所有监控项数据。

  一组时间序列，其中包含每个时间序列随时间变化的一系列数据点

- scalar 标量

  一个简单的浮点类型数值

- string 字符串

  一个简单字符串类型, 当前并没有使用, a simple string value; currently unused

日常图形展示中用到的数据就是基于上面四种样式组合而成的综合表达式,效果如下

![image-20250918160917704](Prometheus.assets/image-20250918160917704.png)

PromQL的查询操需要针对有限个时间序列上的样本数据进行，挑选出目标时间序列是构建表达式时最为关键的一步,然后根据挑选出给定指标名称下的所有时间序列或部分时间序列的即时（当前）样本值或至过去某个时间范围内的样本值。

范例: 利用API查询数据

~~~shell
# 即时数据,指定时间点的数据
# time 指的是时间戳
root@prometheus-221:~ 16:11:58 # curl --data 'query=prometheus_http_requests_total{app="prometheus", code="200", handler="/", instance="localhost:9090", job="prometheus"}' --data time=1758183084 'http://192.168.121.221:9090/api/v1/query'
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"prometheus_http_requests_total","app":"prometheus","code":"200","handler":"/","instance":"localhost:9090","job":"prometheus"},"value":[1758183084,"0"]}]}}
root@prometheus-221:~ 16:12:28 #

# 范围数据,指定时间前1分钟的数据
curl --data 'query=node_memory_MemFree_bytes{instance=~"192.168.121.(111|113):9100"}[1m]' --data time=1758183084 'http://192.168.121.221:9090/api/v1/query'


# 标量数据,利用scalar()函数将即时数据转换为标量
curl --data 'query=scalar(sum(node_memory_MemFree_bytes{instance=~"192.168.121.(111|113):9100"}))' --data time=1758183084 'http://192.168.121.221:9090/api/v1/query'
~~~

**基本语法**

数值

对于数值来说，主要记住两种类型的数值：字符串和数字。

字符串

~~~shell
# 字符串可以用单引号，双引号或反引号指定为文字，如果字符串内的特殊符号想要生效，可以使用反引号。
"this is a string"
'these are unescaped: n t'
`these are not unescaped: n ' " t
~~~

数字

~~~shell
# 对于数据值的表示，可以使用我们平常时候的书写方法 "[-](digits)[.(digits)]"
2、2.43、-2.43等
~~~

### 3.2.3 表达式使用要点

表达式的返回值类型是即时向量、范围向量、标量或字符串4种数据类型其中之一，但是，有些使用场景要求表达式返回值必须满足特定的条件，例如

- 需要将返回值绘制成图形时,仅支持即时向量类型的数据
- 对于诸如rate一类的速率函数来说，其要求使用的却又必须是范围向量型的数据

由于范围向量选择器的返回的是范围向量型数据，它不能用于表达式浏览器中图形绘制功能，否则，表达式浏览器会返回"Error executing query: invalid expressiontype "range vector" for range query,must be Scalar or instant Vector"一类的错误

范围向量选择几乎总是结合速率类的函数 rate 一同使用

### 3.2.4 数据选择器

所谓的数据选择器，其实指的是获取实时数据或者历史数据的一种方法

样式：

~~~shell
metrics_name{筛选label=值,...}[<时间范围>] offset <偏移>
~~~

**数据选择器主要以下几种分类：**

#### 3.2.4.1 即时向量选择器 Instant Vector Selector

Instant Vector Selector 获取0个，1个或多个时间序列的即时样本值

即时向量选择器由两部分组成

- 指标名称:用于限定特定指标下的时间序列，即负责过滤指标;可选
- 匹配器(Matcher) :或称为标签选择器，用于过滤时间序列上的标签;定义在{}之中;可选
- 定义即时向量选择器时，以上两个部分应该至少给出一个

根据数据的精确度，可以有以下几种使用方法：

- 根据监控项名称获取最新值

  仅给定指标名称，或在标签名称上使用了空值的匹配器

  返回给定的指标下的所有时间序列各自的即时样本

  例如：http_requests_total和http_requests_total{} 的功能相同，都是用于返回

  http_requests_total 指标下各时间序列的即时样本

  ~~~shell
  node_filefd_allocated
  prometheus_http_requests_total
  ~~~

- 通过 _\_name__ 匹配多个监控项的名称

  ~~~shell
  {__name__="prometheus_http_requests_total"}
  {__name__=~"^prometheus_http_.*"}
  ~~~

- 仅给定匹配器

  返回所有符合给定的匹配器的所有时间序列上的即时样本

  注意:这些时间序列可能会有很多的不同的指标名称

  例如：{job=".*", method="get"}

- 指标名称和匹配器的组合

  通过 name{key=value,...}样式获取符合条件的数据值

  返回给定的指定下的，且符合给定的标签过滤器的所有时间序列上的即时样本

  例如： http_requests_total{method="get"}

~~~shell
{__name__="prometheus_http_requests_total",handler="/-/reload"}
prometheus_http_requests_total{handler="/-/reload"}
~~~

**匹配器** **Matcher** **使用规则**

**匹配器用于定义标签过滤条件，目前支持如下4种匹配操作符**

~~~shell
=  #精确匹配
!= #不匹配
=~ #正则匹配,全部匹配，而非包含
!~ #正则不匹配
~~~

**匹配到空标签值的匹配器时，所有未定义该标签的时间序列同样符合条件**

例如：

http_requests_total (env="")，则该指标名称上所有未使用该标签 env 的时间序列或者 env 的值为空的都

符合条件

比如时间序列 http_requests_total {method ="get"} 

**正则表达式将执行完全锚定机制，它需要匹配指定的标签的整个值**

例如：

http_requests_total {method =~"^ge"} 是错误的，应该是 http_requests_total {method =~"^ge.*"} 

**多个条件间可以使用逗号","隔开，每个条件内部可以通过多种符号，表示不同含义**

**如果条件中存在多值，可以使用"|"表示或**

比如：env=~"staging|testing|development"

**向量选择器至少要包含一个指标名称,或者条件中至少包含一个非空标签值的选择器**

例如：不能写成{job=~".*"}和{job=""}

**使用\_\_name\_\_做为标签名称，能够对指标名称进行过滤**

~~~shell
#示例：
{__name__=~"http_requests_.*"} #能够匹配所有以"http_requests_"为前缀的所有指标
~~~

~~~shell
#示例
prometheus_http_requests_total{instance="localhost:9090", job="prometheus"}
prometheus_http_requests_total{handler=~".*meta.*"}
node_memory_MemFree_bytes{instance=~"192.168.121.(101|102):9100"} 
#注意：指标 prometheus_http_requests_total 默认情况下，针对的是 localhost:9090 的 target，其他无效
~~~

#### 3.2.4.2 范围选择器 Range Vector Selector

Range Vector Selector 工作方式与瞬时向量选择器一样，区别在于时间范围长一些

返回0个、1个或多个时间序列上在给定时间范围内的各自的一组样本值

主要是在瞬时选择器多了一个[]格式的时间范围后缀

在[]内部可以采用多个单位表示不同的时间范围，比如s(秒)、m(分)、h(时)、d(日)、w(周)、y(年)

必须使用整数时间单位，且能够将多个不同级别的单位进行串联组合，以时间单位由大到小为顺序

例如：1h30m，但不能使用1.5h

~~~shell
prometheus_http_requests_total{job="prometheus"}[5m]
# 属性解析：这表示过去5分钟内的监控数据值，这些数据一般以表格方式展示，而不是列表方式展示
~~~

注意：

- 范围向量选择器返回的是一定时间范围内的数据样本，虽然不同时间序列的数据抓取时间点相同，但它们的时间戳并不会严格对齐
- 多个Target上的数据抓取需要分散在抓取时间点前后一定的时间范围内，以均衡Prometheus Server的负载
- 因而，Prometheus在趋势上准确，但并非绝对精准

#### 3.2.4.3 偏移修饰符 offset

默认情况下，即时向量选择器和范围向量选择器都以当前时间为基准时间点，而偏移量修改器能够修改该基准

对于某个历史时间段中的数据，需要通过offset时间偏移的方式来进行获取

偏移量修改器的使用方法是紧跟在选择器表达式之后使用"offset"关键字指定

注意：offset与数据选择器是一个整体，不能分割，offset 偏移的是时间基点

~~~shell
prometheus_http_requests_total offset 5m #表示获取以 prometheus_http_requests_total 为指标名称的所有时间序列在过去5分钟之时的即时样本

prometheus_http_requests_total{code="200"} offset 5m
#如果既有偏移又有范围,先偏移后再取范围,如[5m] offset 3m 表示取当前时间的3分钟前的5m范围的值

http_requests_total[5m] offset 1d #表示获取距此刻1天时间之前的5分钟之内的所有样本
http_requests_total{handler="/metrics"}[5m] offset 3m
~~~

### 3.2.5指标类型

Prometheus客户端库提供了四种核心度量标准类型。

官方说明

https://prometheus.io/docs/concepts/metric_types/

https://prometheus.io/docs/practices/histograms/

~~~shell
root@prometheus-221:~ 16:48:20 # curl -s http://192.168.121.221:9090/metrics| awk '/TYPE/ {type[$NF]++}END{for( i in type ){print type[i],i}}'
89 gauge
15 histogram
12 summary
109 counter
root@prometheus-221:~ 16:48:28 #
~~~

| 类型             | 解析                                                         |
| ---------------- | ------------------------------------------------------------ |
| Counter-计数器   | counter是一个累加的计数器，代表一个从0开始累积单调递增的计数器，其值只能在重新启动时增加或重置为零。典型的应用如：用户的访问量,请求的总个数，任务的完成数量或错误的总数量等。不能使用Counter来表示递减值。但可以重置为0，即重新计数 |
| Gauge-计量器     | Gauge是一种度量标准，只有一个简单的返回值，或者叫瞬时状态，可以代表可以任意metric的上下波动的数值。通常用于指定时间的测量值，例如，硬盘剩余空间,当前的内存使用量,一个待处理队列中任务的个数等，还用于可能上升和下降的“计数”，例如, 并发请求数。 |
| Histogram-直方图 | Histogram统计数据的分布情况。比如最小值，最大值，中间值，还有中位数，75百分位,90百分位, 95百分位.98百分位,99百分位,和9.9百分位的值(percenties ,代表着近似的百分比估算数值）<br />比如: 每天1000万请中,统计http_response_time不同响应时间的分布情况,响应时间在0-0.05s有多少,0.05s到2s有多少,10s以上有多少<br />每个存储桶都以"_BucketFuncName{...}" 样式来命名.例如 hist_sum、hist_count 等<br />可以基于histogram_quantile()函数对直方图甚至是直方图的聚合来进行各种分析计算。<br />比如: 统计考试成绩在0-60分之间有多少,60-80之间有多少个,80-100分之间有多少个<br />示例:prometheus_tsdb_compaction_chunk_range_seconds_bucket_histogram中位数由服务端计算完成，对于分位数的计算而言，Histogram则会消耗更多的资源 |
| Summary-摘要     | 和Histogram类似，用于表示一段时间内的数据采样结果,典型的应用如：请求持续时间，响应大小。它直接存储了分位数(将一个随机变量的概率分布范围分为几个等份的数值点，常用的有中位数即二分位数、四分位数、百分位数等)，而不是通过区间来计算。类似于直方图，摘要会基于阶段性的采样观察结果进行信息描述。它还提供了观测值的累计计算、百分位计算等功能，每个摘要的命名与Histogram 类似，例如：summary_sum、summary_count等<br />示例: go_gc_duration_seconds<br />Sumamry的分位数则是直接在客户端计算完成，对于分位数的计算而言，Summary在通过PromQL进行查询时有更好的性能表现 |

**Counter和Gauge**

通常情况不会直接使用 Counter 总数，而是需要借助于 rate、topk、incrcase 和 irate 等函数来生成样本数据的变化状况(增长率)

~~~shell
topk(3, http_requests_total)， #获取该指标下http请求总数排名前3的时间序列
rate(http_requests_total[2h])，#获取2小时内，各时间序列上的http总请求数的增长速率，此为平均值，无法反映近期的精确情况

irate(http_requests_total[2h]) #高灵敏度函数，用于计算指标的瞬时速率，基于样本范围内的最后两个样本进行计算，相较于rate函数来说，irate更适用于精准反映出短期时间范围内的变化速率
~~~

Gauge用于存储其值可增可减的指标的样本数据，常用于进行求和、取平均值、最小值、最大值等聚合计算

也会经常结合PromQL的predict_linear和delta函数使用

predict_linear(v range-vector, t, scalar)函数可以预测时间序列v在t秒后的值，它通过线性回归的方式来预测样本数据的Gauge变化趋势

delta(v range-vector)函数计算范围向量中每个时间序列元素的第一个值与最后一个值之差，从而展示不同时间点上的样本值的差值

```shell
delta(cpu_temp_celsius {host="prometheus.wang.org"[2h) # 返回该服务器上的 CPU 温度与2小时之前的差异
```

## 3.3 PromQL 运算

对于PromQL来说，它的操作符号主要有以下两类：

- 二元运算符
- 聚合运算

### 3.3.1 二元运算符

https://prometheus.io/docs/prometheus/latest/querying/operators/ 

二元运算符是prometheus进行数据可视化或者数据分析操作的时候，应用非常多的一种功能

对于二元运算符来说，它主要包含三类：算术、比较、逻辑

~~~shell
#算术运算符：
+ (addition)
- (subtraction)
* (multiplication)
/ (division)
% (modulo)
^ (power/exponentiation)

#比较运算符：
== (equal)
!= (not-equal)
> (greater-than)
< (less-than)
>= (greater-or-equal)
<= (less-or-equal)

#逻辑运算符：
and、or、unless 
#目前该运算符仅允许在两个即时向量之间进行操作，不支持标量(标量只有一个数字，没有时序)参与运算

#运算符从高到低的优先级
1 ^ 
2 *, /, %
3 +, - 4 ==, !=, <=, <, >=, >
5 and, unless
6 or
#注意：
#具有相同优先级的运算符满足结合律（左结合)，但幂运算除外，因为它是右结合机制
#可以使用括号()改变运算次序
~~~

范例：取GC平均值

~~~shell
go_gc_duration_seconds_sum{instance="192.168.121.111:9100",job="prometheus"} / go_gc_duration_seconds_count{instance="192.168.121.111:9100",job="prometheus"}
~~~

~~~bash
#正则表达式
node_memory_MemAvailable_bytes{instance =~ "192.168.121.20.:9100"}
node_memory_MemAvailable_bytes{instance =~ "192.168.121.20[12]:9100"}
node_memory_MemAvailable_bytes{instance =~ "192.168.121.20[1-3]:9100"}
node_memory_MemAvailable_bytes{instance =~ "192.168.121.20.*:9100"}
node_memory_MemAvailable_bytes{instance =~ "192.168.121.20[0-9]:9100"}
node_memory_MemAvailable_bytes{instance =~ "192.168.121.20[^01]:9100"}
node_memory_MemAvailable_bytes{instance !~ "192.168.121.20[12]:9100"}

# 单位换算
node_memory_MemFree_bytes / (1024*1024*1024)

# 可用内存占用率
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100


# 内存使用率
(node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100

# 磁盘使用率
(node_filesystem_size_bytes{mountpoint="/"} -node_filesystem_free_bytes{mountpoint="/"}) / node_filesystem_size_bytes * 100

# 阈值判断
(node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes > 0.9

# 内存利用率是否超过 80
( 1 - node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes ) * 100 > bool 80

# 布尔值,当超过1000为1,否则为0
prometheus_http_requests_total > bool 1000

#注意：
对于比较运算符来说，条件成立有结果输出，否则没有结果输出
使用 bool 运算符后，布尔运算不会对时间序列进行过滤，而是直接依次瞬时向量中的各个样本数据与标量的比较结果0或者1。从而形成一条新的时间序列。
~~~

集合处理

~~~shell
# 并集 or
node_memory_MemTotal_bytes{instance="192.168.121.111:9100"} or node_memory_MemTotal_bytes{instance="192.168.121.112:9100"}

# 交集 and
node_memory_MemTotal_bytes{instance="192.168.121.111:9100"} and node_memory_MemTotal_bytes{instance="192.168.121.112:9100"}

# 补集 unless
node_memory_MemTotal_bytes{job_name="k8s-node"} unless node_memory_MemTotal_bytes{instance="10.0.0.104:9100"}

#注意：
and、or、unless 主要是针对获取的数据值进行条件选集合用的
and、or、unless 针对的对象是一个完整的表达式
~~~

向量匹配关健字

~~~shell
# https://prometheus.io/docs/prometheus/latest/querying/operators/#one-to-one-vector-matches
# ignoring 定义匹配检测时要忽略的标签
# on 定义匹配检测时只使用的标签
~~~

组修饰符

~~~shell
#https://prometheus.io/docs/prometheus/latest/querying/operators/#groupmodifiers
group_left  #多对一
group_right #一对多

#left和right表示哪一侧为多
~~~

一对一向量匹配

~~~shell
#https://prometheus.io/docs/prometheus/latest/querying/operators/#one-to-one-vector-matches
<vector expr> <bin-op> ignoring(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) <vector expr>
~~~

~~~shell
#https://prometheus.io/docs/prometheus/latest/querying/operators/#one-to-one-vector-matches
#Example input:
method_code:http_errors:rate5m{method="get", code="500"}  24
method_code:http_errors:rate5m{method="get", code="404"}  30
method_code:http_errors:rate5m{method="put", code="501"}  3
method_code:http_errors:rate5m{method="post", code="500"} 6
method_code:http_errors:rate5m{method="post", code="404"} 21
method:http_requests:rate5m{method="get"}  600
method:http_requests:rate5m{method="del"}  34
method:http_requests:rate5m{method="post"} 120

# 一对一
method_code:http_errors:rate5m{code="500"} / ignoring(code) method:http_requests:rate5m
#这将返回一个结果向量，其中包含每个方法状态代码为 500 的 HTTP 请求的比例（在过去 5 分钟内测量）。 没有“ignoring(code) ”不共享同一组标签的指标则不会有匹配，使用“put”和“del”方法的条目没有匹配项，不会显示在结果中：
{method="get"}  0.04           //  24 / 600
{method="post"} 0.05           //   6 / 120

#一对多
method_code:http_errors:rate5m / ignoring(code) group_left method:http_requests:rate5m
#在这种情况下，左侧向量包含每个方法标签值多个条目。 因此，我们使用group_left表示。 现在，右侧的元素与左侧具有相同方法标签的多个元素匹配：
{method="get", code="500"}  0.04           //  24 / 600
{method="get", code="404"}  0.05           //  30 / 600
{method="post", code="500"} 0.05           //   6 / 120
{method="post", code="404"} 0.175           //  21 / 120
~~~

### 3.3.2 聚合操作

https://prometheus.io/docs/prometheus/latest/querying/operators/

一般说来，单个指标的价值不大，监控场景中往往需要联合并可视化一组指标，这种联合机制是指"聚 合"操作，例如，将计数、求和、平均值、分位数、标准差及方差等统计函数应用于时间序列的样本之上生成具有统计学意义的结果等

对查询结果事先按照某种分类机制进行分组(groupby）并将查询结果按组进行聚合计算也是较为常见的需求，例如分组统计、分组求平均值、分组求和等

聚合操作由聚合函数也称为聚合操作符针对一组值进行计算并返回单个值或少量值作为结果

聚合操作符 aggregation operators 虽然是一个个的功能，但是并不属于功能函数，仅仅代表对数据进行简单的功能处理。

常见的11种聚合操作：

~~~shell
sum、min、max、avg、count、count_values(值计数)
stddev(标准差)、stdvar(标准差异)、bottomk(最小取样)、topk(最大取样，即取前几个)、quantile(分布统计)

sum() #对样本值求和
avg() #对样本值求平均值，这是进行指标数据分析的标准方法
count()#对分组内的时间序列进行数量统计
min()#求取样本值中的最小者
max()#求取样本值中的最大者
topk()#逆序返回分组内的样本值最大的前k个时间序列及其值
bottomk()#顺序返回分组内的样本值最小的前k个时间序列及其值
quantile()#分位数用于评估数据的分布状态，该函数会返回分组内指定的分位数的值，即数值落在小于等于指定的分位区间的比例
count_values()#对分组内的时间序列的样本值进行数量统计
stddev() #对样本值求标准差，以帮助用户了解数据的波动大小(或称之为波动程度) 
stdvar() #对样本值求方差，它是求取标准差过程中的中间状态

聚合操作符(metric表达式) sum、min、max、avg、count等
聚合操作符(描述信息，metric) count_values、bottomk、topk等
~~~

可以借助于 without 和 by 功能获取数据集中的一部分进行分组统计

~~~shell
# without 表示显示信息的时候，排除此处指定的标签列表，对以外的标签进行分组统计，即：使用除此标签之外的其它标签进行分组统计
# by表示显示信息的时候，仅显示指定的标签的分组统计，即针对哪些标签分组统计
~~~

without 和 by 格式如下

~~~shell
# 两种格式：先从所有数据中利用数据选择表达式过滤出部分数据，进行分组后，再进行聚合运算，最终得出来结果
# 格式1
聚合操作符(数据选择表达式) without|by (<label list>)
<aggr-op>([parameter,] <vector expression>) [without|by (<label list>)]
# 格式2
聚合操作符 without|by (<label list>) (数据选择表达式) 
<aggr-op> [without|by (<label list>)] ([parameter,] <vector expression>)
~~~

示例

~~~shell
# 显示系统版本
# 统计Ubuntu系统主机数
count(node_os_version{id="ubuntu"})

# 分别统计不同OS的数量
# 按node_os_version返回值value分组统计个数,将不同value加个新标签为os_version
count_values("os_version",node_os_version)
{os_version="22.04"}  4
{os_version="20.04"}  2

# 内存总量
sum(node_memory_MemTotal_bytes)

# 按instance分组统计内存总量
sum(node_memory_MemTotal_bytes) by (instance)

# 确认所有主机的CPU的总个数
count(node_cpu_seconds_total{mode='system'})
# 确认每个主机的CPU的总个数
count(node_cpu_seconds_total{mode="system"}) by (instance)


#获取最大的值
max(prometheus_http_requests_total)

#按 handler,instance 分组统计
max(prometheus_http_requests_total) by (handler,instance)

#分组统计计数
count_values("counts",node_filesystem_size_bytes)
#获取前5个最大值
topk(5, prometheus_http_requests_total)
#获取前5个最小值
bottomk(5, prometheus_http_requests_total)
#对除了 instance 和 job 以外的标签分组求和
sum(prometheus_http_requests_total) without (instance,job)
#仅对 mode 标签进行分组求和
sum(node_cpu_seconds_total) by (mode)
#多个分组统计
count(prometheus_http_requests_total) by (code,instance,job)

#查出200响应码占全部的百分比
prometheus_http_requests_total{code="200", handler="/-/ready", instance="localhost:9090"} / sum (prometheus_http_requests_total{handler="/-/ready", instance="localhost:9090"}) by (handler,instance)

#查出200响应码占全部的百分比
nginx_http_requests_total{path="/api",method="GET",code="200"}/ sum (nginx_http_requests_total{path="/api",method="GET"}) by (path,method)
~~~

### 3.3.3 功能函数

https://prometheus.io/docs/prometheus/latest/querying/functions/

计算相关

~~~shell
绝对值abs()、导数deriv()、指数exp()、对数ln()、二进制对数log2()、10进制对数log10()、平方根sqrt()
向上取整ceil()、向下取整floor()、四舍五入round()
样本差idelta()、差值delta()、递增值increase()、重置次数resets()
递增率irate()、变化率rate()、平滑值holt_winters()、直方百分位histogram_quantile()
预测值predict_linear()、参数vector()
范围最小值min_over_time()、范围最大值max_over_time()、范围平均值avg_over_time()、范围求
和值sum_over_time()、范围计数值count_over_time()、范围分位数quantile_over_time()、范围
标准差stddev_over_time()、范围标准方差stdvar_over_time()
~~~

取样相关

~~~shell
获取样本absent()、升序sort()、降序sort_desc()、变化数changes()
即时数据转换为标量scalar()、判断大clamp_max()、判断小clamp_min()
范围采样值absent_over_time()，
~~~

时间相关

~~~shell
day_of_month()、day_of_week()、days_in_month()、hour()、minute()、month()、time()、
timestamp()、year()
~~~

标签相关

~~~shell
标签合并label_join()、标签替换labelreplace()
~~~

示例

~~~shell
ceil()：向上取整
floor():向下取整
round():四舍五入

ceil(node_load15 * 10)
floor(node_load15 * 10)
round(node_load15 * 10)

increase(): 增长量,即last值-last前一个值
#示例:最近1分钟内CPU处于空闲状态时间
increase(node_cpu_seconds_total{cpu="0",mode="idle"}[1m])

#示例:CPU利用率
(1 - sum(increase(node_cpu_seconds_total{mode="idle"}[1m])) by (instance) / 
sum(increase(node_cpu_seconds_total[1m])) by (instance)) * 100


#示例:CPU利用率
(1 - sum(increase(node_cpu_seconds_total{mode="idle"}[1m])) by (instance) / 
sum(increase(node_cpu_seconds_total[1m])) by (instance)) * 100


rate():
#平均变化率,计算在指定时间范围内计数器每秒增加量的平均值,即(last值-first值)/时间差的秒数，常用于counter的数据
#示例:过去一分钟每次磁盘读的变化率
rate(node_disk_read_bytes_total[1m])
#示例:一分钟内网卡传输的字节数(MB)
rate(node_network_transmit_bytes_total{device="eth0"}[1m]) /1024 /1024
#判断在过去5分钟内HTTP请求状态码以"5"开头的请求的速率是否大于所有HTTP请求速率的10%。
rate(http_requests_total{status_code=~"5.*"}[5m]) > 
rate(http_requests_total[5m])*0.1
#每台主机CPU在5分钟内的平均使用率
(1- avg(irate(node_cpu_seconds_total{mode='idle'}[5m])) by (instance))*100


irate()：查看瞬时变化率,即:(last值-last前一个值)/时间戳差值
#高灵敏度函数，用于计算指标的瞬时速率，常用于counter的数据
#示例:查看CPU最近5m内最多的增长率
irate(node_cpu_seconds_total{instance="10.0.0.101:9100",mode="idle"}[5m])


#irate和rate都会用于计算某个指标在一定时间间隔内的变化速率。但是它们的计算方法有所不同：irate 取的是在指定时间范围内的最近两个数据点来算速率，而rate会取指定时间范围内所有数据点，算出一组速率，然后取平均值作为结果。所以官网文档说：irate适合快速变化的计数器（counter），而 rate 适合缓慢变化的计数器（counter）。对于快速变化的计数器，如果使用rate，因为使用了平均值，很容易把峰值削平。除非我们把时间间隔设置得足够小，就能够减弱这种效应。


time(): 获取当前时间值
#示例:计算当前每个主机的运行时间
(time() - node_boot_time_seconds) / 3600
#示例:计算所有主机的总运行时间
sum(time() - node_boot_time_seconds) / 3600
 
histogram_quantile(): 百分取样值
#示例:计算过去10m内请求持续时间的第90个百分位数
histogram_quantile(0.9, 
rate(prometheus_http_request_duration_seconds_bucket[10m]))
#absent 有值返回空,无值返回1,可用于告警判断
absent(node_memory_SwapTotal_bytes)
absent(node_memory_SwapTotal_byte)
~~~

**rate** **和** **irate** **函数**

都表示变化速率，但有所不同。

rate函数可以用来求指标的平均变化速率

rate函数=时间区间前后两个点的差 / 时间范围

一般rate函数可以用来求某个时间区间内的请求速率，也就是我们常说的 QPS



但是rate函数只是算出来了某个时间区间内的平均速率，没办法反映突发变化，假设在一分钟的时间区间里，前50秒的请求量都是0到10左右，但是最后10秒的请求量暴增到100以上，这时候算出来的值可能无法很好的反映这个峰值变化。这个问题可以通过irate函数解决

irate函数求出来的就是瞬时变化率

irate函数=时间区间内最后两个样本点的差 / 最后两个样本点的时间差

![image-20250919161756140](Prometheus.assets/image-20250919161756140.png)

一般情况下，irate函数的图像峰值变化大，rate函数变化较为平缓

## 3.4 定制 Exporter

### 3.4.1 定制 Exporter 说明

Prometheus 监控的指标可以通过下面方式提供

- Prometheus 内置
- instrumentation 程序仪表: 应用内置的指标功能,比如: Zookeeper,Gitlab,Grafana 等
- 额外的 exporter,使用第三方开发的功能
- Pushgateway 提供
- 通过自行编程实现的功能代码,需要开发能力

Prometheus 对于监控功能的核心要素就是 metric 的监控项是否正常工作

Metric 本质就是对应的服务启动后自动生成的一个基于http协议URL地址，通过该地址可以获取想要的监控项。

实际生产环境中，想要监控好多指标，但是prometheus 可能并没有提供相应的metric监控项条目，比如: 某业务指标、转化率等，所以就需要实现自定义的metric条目。

开发应用服务的时候，就需要根据metric的数据格式，定制标准的/metric接口。

各种语言帮助手册：

~~~shell
https://github.com/prometheus/client_golang
https://github.com/prometheus/client_python
https://github.com/prometheus/client_java
https://github.com/prometheus/client_rust
~~~

以python项目，可以借助于prometheus_client模块在python类型的web项目中定制metric接口。

~~~shell
https://prometheus.github.io/client_python/instrumenting/exemplars/
~~~

~~~python
Three Step Demo
One: Install the client:
pip install prometheus-client
Two: Paste the following into a Python interpreter:
from prometheus_client import start_http_server, Summary
import random
import time
# Create a metric to track time spent and requests made.
REQUEST_TIME = Summary('request_processing_seconds', 'Time spent processing request')

# Decorate function with metric.
@REQUEST_TIME.time()
def process_request(t):
    """A dummy function that takes some time."""
    time.sleep(t)
if __name__ == '__main__':
    # Start up the server to expose the metrics.
    start_http_server(8000)
    # Generate some requests.
    while True:
        process_request(random.random())
        
Three: Visit http://localhost:8000/ to view the metrics.
~~~

### 3.4.2 定制 Exporter 案例：python 实现

#### 3.4.2.1 准备 python 开发 web 环境

~~~python
# apt安装python3
#  apt update && apt install -y python3
# 安装Python包管理器，默认没有安装
#  apt update && apt install -y python3-pip
root@prometheus-221:~ 22:30:22 # python3
Python 3.10.12 (main, Aug 15 2025, 14:32:43) [GCC 11.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> exit()
root@prometheus-221:~ 22:30:22 #


#############################如何不安装虚拟环境下面不需要执行#################################
#安装虚拟环境软件
~# pip3 install pbr virtualenv
~# pip3 install --no-deps stevedore virtualenvwrapper
#创建用户
~# useradd -m -s /bin/bash python
#准备目录
~# mkdir -p /data/venv
~# chown python.python /data/venv
#修改配置文件(可选) ~# su - python
~# vim .bashrc
force_color_prompt=yes #取消此行注释,清加颜色显示
#配置加速
~# mkdir ~/.pip
~# vim .pip/pip.conf 
[global] 
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install] 
trusted-host=pypi.douban.com
#配置虚拟软件
echo 'export WORKON_HOME=/data/venv' >> .bashrc
echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3' >> .bashrc
echo 'export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv' >> .bashrc
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> .bashrc
source .bashrc
#注意：virtualenv 和 virtualenvwrapper.sh 的路径位置
#创建新的虚拟环境并自动进入
~# mkvirtualenv -p python3 flask_env
#进入已创建的虚拟环境
~# su - python
~# workon flask_env
#虚拟环境中安装相关模块库
~# pip install flask prometheus_client
~# pip list
#################################如何不安装虚拟环境上面不需要执行##########################



#实际环境中安装相关模块库
# pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
# cat /root/.config/pip/pip.conf
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
# pip3 install flask prometheus_client
# pip3 list
#创建代码目录
# mkdir -p /data/code
~~~

#### 3.4.2.2 项目代码

~~~python
from prometheus_client import Counter, Gauge, Summary
from prometheus_client.core import CollectorRegistry
class Monitor:
   def __init__(self):
    # 注册收集器
   self.collector_registry = CollectorRegistry(auto_describe=False)
    # summary类型监控项设计
   self.summary_metric_name = Summary(name="summary_metric_name",
                                   documentation="summary_metric_desc",
                                   labelnames=("label1", "label2", "label3"),
                                   registry=self.collector_registry)
    # gauge类型监控项设计
   self.gauge_metric_name = Gauge(name="gauge_metric_name",
                                  documentation="summary_gauge_desc",
                                  labelnames=("method", "code", "uri"),
                                  registry=self.collector_registry)
    # counter类型监控项设计
   self.counter_metric_name = Counter(name="counter_metric_name",
                                      documentation="summary_counter_desc",
                                      labelnames=("method", "code", "uri"),
                                      registry=self.collector_registry)
#属性解析：上面是几个常用的标准metric数据格式设计
~~~

定制 flask web 项目

~~~python
root@prometheus-221:~ 12:49:49 # cat /data/code/flask_metric.py 
from prometheus_client import start_http_server,Counter, Summary
from flask import Flask, jsonify
from wsgiref.simple_server import make_server
import time
app = Flask(__name__)
# Create a metric to track time spent and requests made

REQUEST_TIME = Summary('request_processing_seconds', 'Time spent processingrequest')
COUNTER_TIME = Counter("request_count", "Total request count of the host")
@app.route("/metrics")
@REQUEST_TIME.time()
def requests_count():
    COUNTER_TIME.inc()
    return jsonify({"return": "success OK!"})


if __name__ == "__main__":
    start_http_server(8000)
    httpd = make_server( '0.0.0.0', 8001, app )
    httpd.serve_forever()

    
    
    
#代码解析：
.inc() 表示递增值为 1
start_http_server(8000)             #用于提供数据收集的端口 Prometheus可以通过此端口8000的/metrics 收集指标
make_server( '0.0.0.0', 8001, app ) #表示另开启一个web服务的/metrics 链接专门用于接收访问请求并生成对应的指标数据

#启动项目: 
]# python flask_meric.py
#浏览器访问 192.168.121.221:8000/metrics 可以看到大量的监控项，下面的几项就是自己定制的
...
# HELP request_processing_seconds Time spent processing request
# TYPE request_processing_seconds summary
request_processing_seconds_count 0.0
request_processing_seconds_sum 0.0
# TYPE request_processing_seconds_created gauge
request_processing_seconds_created 1.5851566329768722e+09
# HELP request_count_total Total request count of the host
# TYPE request_count_total counter
request_count_total 0.0
# TYPE request_count_created gauge
request_count_created 1.5851566329769313e+09
~~~

当每访问一次链接 http://192.168.121.221:8001/metrics 时，192.168.121.221:8000/metrics 的 request_count_toal 值就会增加1

 ~~~shell
 # 如果希望持续性的进行接口访问的话，我们可以编写一个脚本来实现：
 root@prometheus-221:/data/code 12:56:21 # cat curl_metrics.sh 
 ############################
 # File Name: curl_metrics.sh
 # Author: xuruizhao
 # mail: xuruizhao00@163.com
 # Created Time: Sat 20 Sep 2025 12:53:08 PM CST
 ############################
 #!/bin/bash
 while true;do
     sleep_num=$(($RANDOM%3+1))
     curl_num=$(($RANDOM%50+1))
     for c_num in  `seq $curl_num`
     do
         curl -s http://192.168.121.221:8001/metrics >> /dev/null 2>&1
     done
     sleep $sleep_num
 done
 
 ~~~

#### 3.4.2.3 Prometheus 集成

修改 prometheus 配置, 增加 job 任务

~~~shell
root@prometheus-221:~ 12:58:17 # tail /usr/local/prometheus/conf/prometheus.yml
  - job_name: "my_metrics"
    metrics_path: '/metrics'
    scheme: 'http'
    static_configs:
      - targets: ["192.168.121.221:8000"]
root@prometheus-221:~ 12:58:20 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 12:58:29 # systemctl restart prometheus.service
~~~

浏览器访问 prometheus 的 target 界面

![image-20250920125924442](Prometheus.assets/image-20250920125924442.png)

进入到graph界面查看数据效果

![image-20250920125954008](Prometheus.assets/image-20250920125954008.png)

结果显示：在prometheus上面可以看到正常的数据收集

rate(request_count_total{instance="127.0.0.1:8000", job="my_metric"}[5m])

![image-20250920130155545](Prometheus.assets/image-20250920130155545.png)

irate(request_count_total{instance="127.0.0.1:8000", job="my_metric"}[5m])

![image-20250920130222723](Prometheus.assets/image-20250920130222723.png)

## 3.5 基于 PromQL 实现 Grafana 展示

### 3.5.1 Grafana 基础

Grafana 是一款基于 go 语言开发的通用可视化工具，支持从多种不同的数据源加载并展示数据，

可作为其数据源的部分存储系统,如下所示

- TSDB: Prometheus、 InfluxDB、 OpenTSDB和Graphit
- 日志和文档存储: Loki和ElasitchSearch
- 分布 式请求跟踪: Zipkin、 Jaeger和SkyWalking等
- SQL DB: MySQL、PostgreSQL和Microsoft SQL Server

Grafana基础

- 默认监听于TCP协议的 3000 端口，支持集成其他认证服务，且能够通过/metrics输出内建指标
- 数据源(Data Source) :提供用于展示的数据的存储系统
- 仪表盘(Dashboard) :组织和管 理数据的可视化面板 (Panel) 
- 团队和用户:提供了面向企业组织层级的管理能力

Grafana是一个可视化的集成套件，可以借助于现成的dashboard模板进行通用的界面展示，但是对于一些特殊的监控项的展示来说，我们还是需要实现独有的界面展示，而这就需要借助于Grafana的图形类型来实现特定的展示效果，对于绘图时候用到的可视化功能主要有两种方式：默认可视化方式和可视化插件

默认可视化方式

默认的可视化方式，我们可以点击左侧边栏的"+"，然后选择"Dashboard",再选择"Choose virtualization"就可以看到默认的可视化样式，效果如下：

![image-20250920130449606](Prometheus.assets/image-20250920130449606.png)

可视化插件

对于可视化插件来说，我们就需要借助于grafana-cli plugins命令从https://grafana.com/plugins/页面下载我们想要的可视化插件，每种插件中都集成了一些特定的可视化样式，我们可以点击左侧变量的"齿 轮"，点击"Plugins"，就可以看到我们所安装的插件样式集，效果如下

![image-20250920130555391](Prometheus.assets/image-20250920130555391.png)

**图形展示**

接下来我们通过现有的模板页面来学习一下Grafana中图形的展示方式以及制作流程。点击我们之前加载好的prometheus的模板页面，效果如下

![image-20250920130825683](Prometheus.assets/image-20250920130825683.png)

以折线图为例，当把鼠标放在图形的标题位置右侧三个点的位置，就会出现图形的操作信息，效果如下

![image-20250920130935496](Prometheus.assets/image-20250920130935496.png)

~~~shell
View     #当前Graph的综合展示
Edit     #Graph的属性编辑
Share    #表示当前Graph对外分享时候的一些配置属性
explore  #类似于view,综合展示更详细的信息
More     #这部分包含了对当前图形的一些扩展信息，比如切割、复制、json数据展示、数据导出、触发器
~~~

点击View或者键盘输入缩写"x",进入到图形综合展示界面，效果如下

![image-20250920131026918](Prometheus.assets/image-20250920131026918.png)

点击Explore进入到图形详情展示界面

![image-20250920131134159](Prometheus.assets/image-20250920131134159.png)

点击Edit或者键盘输入缩写"e",进入到图形编辑界面

![image-20250920131207309](Prometheus.assets/image-20250920131207309.png)

**配置解析**

在Edit的界面最下面有该图形的配置方式，左侧有四个图标，分别表示：

~~~shell
Query          #图形中展示的具体数据的查询表达式，每类数据一个查询语句
Virtualization #图形的可视化样式配置
General        #可选配置
Alert          #触发器、告警配置
~~~

数据查询语句界面

![image-20250920132450399](Prometheus.assets/image-20250920132450399.png)

**实践流程**

如果要制作一个Graph，需要按照如下步骤进行操作：

- 了解业务，分析指标
- 创建 Dashboard
- 创建 Graph
- 完善 Graph
- 其他信息,比如告警等

### 3.5.2 绘图案例

#### 3.5.2.1 案例说明

在上一节，我们通过自定义的metric的方式，做好了一个监控项，那么接下来我们就需要完成以下绘图要求

- 绘制每分钟请求数量的曲线 QPS
- 绘制每分钟请求量变化率曲线
- 绘制每分钟请求处理平均耗时

需求分析如下

~~~shell
#上面的三个需求基本上都是曲线图，所以我们在Graph中选择折线图就可以了，而在绘图的时候，第一步需要做的就是获取数据，所以我们现在需要做的就是在prometheus上，将这三个需求的PromQL写出来，效果如下

#绘制每分钟请求数量的曲线 QPS
increase(request_count_total{job="my_metric"}[1m])
increase(request_count_total{instance="10.0.0.101:8000",job="my_metric"}[1m])
#绘制每分钟请求量变化率曲线
irate(request_count_total{job="my_metric"}[1m])
irate(request_count_total{instance="10.0.0.101:8000",job="my_metric"}[1m])
#绘制每分钟请求处理平均耗时
request_processing_seconds_sum{job="my_metric"} / 
request_processing_seconds_count{job="my_metric"}
request_processing_seconds_sum{instance="10.0.0.101:8000",job="my_metric"} / 
request_processing_seconds_count{instance="10.0.0.101:8000",job="my_metric"}

~~~

#### 3.5.2.2 绘图实现

创建图形

点击graph右侧的"+",点击"Dashboard",选择"Query",就可以进入到图形制作的界面，效果如下

设置语句 : 首选选择数据源，选择我们之前定制的"prometheus"，效果如下

接下来开始配置查询语句，按照我们之前定制好的PromQL，然后复制到Metrics右侧的输入框中，配置好图例名称，然后点击右侧的"小眼睛"，就可以看具体的效果，我们以"绘制每分钟请求数量的曲线QPS"为例，效果如下，

![image-20250920135213504](Prometheus.assets/image-20250920135213504.png)

![image-20250920135737467](Prometheus.assets/image-20250920135737467.png)

![image-20250920141727976](Prometheus.assets/image-20250920141727976.png)

# 四、Prometheus 标签管理

## 4.1 标签简介

标签功能: 用于对数据分组和分类,利用标签可以将数据进行过滤筛选

标签管理的常见场景:

- 删除不必要的指标
- 从指标中删除敏感或不需要的标签
- 添加、编辑或修改指标的标签值或标签格式

标签分类：

- 默认标签: Prometheus 自身内置

  形式: \_\_keyname__

- 应用标签: 应用本身内置

  形式: keyname

- 自定义标签: 用户定义

  形式: keyname

范例: 添加主机节点查看默认标签

![image-20250920141929424](Prometheus.assets/image-20250920141929424.png)

应用默认的标签如下形式

![image-20250920142005129](Prometheus.assets/image-20250920142005129.png)

添加主机标签

~~~shell
root@prometheus-221:~ 18:10:14 # tail -11 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "label_test"
    metrics_path: '/metrics'
    scheme: 'http'
    static_configs:
      - targets: 
          - 192.168.121.111:9100
          - 192.168.121.112:9100
          - 192.168.121.113:9100
        labels:
          node: "worker"
          type: "test"
# labels: {app: 'zookeeper', type: 'dev'} 也支持这种格式

root@prometheus-221:~ 18:10:16 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 18:10:18 # systemctl restart prometheus.service 
~~~

![image-20250920181243542](Prometheus.assets/image-20250920181243542.png)

## 4.2 指标的生命周期

标签主要有两种表现形式：

- 私有标签

  ~~~ini
  私有标签以"__*"样式存在，用于获取监控目标的默认元数据属性，比如__address__用于获取目标的地址，__scheme__用户获取目标的请求协议方法，__metrics_path__获取请求的url地址等
  ~~~

- 普通标签

  ~~~ini
  对个监控主机节点上的监控指标进行各种灵活的管理操作，常见的操作有，删除不必要|敏感指标，添加、编辑或者修改指标的标签值或者标签格式。
  ~~~

在 prometheus 的配置选项中，有两个与监控指标密切相关的配置，relabel_config、metric_relabel_configs，它们的作用就是监控目标上面的监控项进行标签管理和设置，便于在 prometheus 上设置更灵活的时序数据。

**Prometheus 对数据的处理流程：**

![image-20250920181705385](Prometheus.assets/image-20250920181705385.png)

在每个scrape_interval期间，Prometheus都会检查执行的作业 Job

- 这些作业首先会根据Job上指定的发现配置生成target列表，此即服务发现过程

- 服务发现会返回一个Target列表，其中包含一组称为元数据的标签，这些标签都以 "_\_meta\_\_" 为前缀__

  服务发现还会根据目标配置来设置其它标签，这些标签带有 "_\_" 前缀和后缀，包括如下：

  ~~~SAS
  "__scheme__"  #协议http或https，默认为http
  "__address__"  #target的地址
  "__metrics_path__" #target指标的URI路径（默认为/metrics） #若URI路径中存在任何参数，则它们的前缀会设置为 "__param__"
  ~~~

  这些目标列表和标签会返回给Prometheus，其中的一些标签也可以配置为被覆盖或替换为其它标签

- 配置标签会在抓取的生命周期中被利用以生成其他标签

  例如：指标上的instance标签的默认值就来自于 _\_address__ 标签的值

- 对于发现的各个目标，Prometheus提供了可以重新标记(relabel_config) 目标的机会它定义在 Job 配置段的relabel_config配置中，常用于实现如下功能

  - 将来自服务发现的元数据标签中的信息附加到指标的标签上
  - 过滤目标

- 数据抓取、以及指标返回的过程

  抓取而来的指标在保存之前，还允许用户对指标重新打标并过滤的方式

  它定义在job配置段的metric_relabel_configs配置中，常用于实现如下功能

  - 删除不必要的指标

  - 从指标中删除敏感或不需要的标签

  - 添加、编辑或修改指标的标签值或标签格式

## 4.3 relabel_configs 和 metrics_relabel_configs

relabel_config、metric_relabel_configs 这两个配置虽然在作用上类似，但是还是有本质上的区别的，这些区别体现在两个方面：执行顺序和数据处理上。

| 区别     | 解析                                                         |
| -------- | ------------------------------------------------------------ |
| 执行顺序 | relabel_configs用与scrape目标上metric前的标签设置，也就是说在scrape_configs前生效，针对的是target对象本身<br />metric_relabel_configs 作用于scrape_configs 生效后，即针对target对象上的metric监控数据 |
| 数据处理 | metric_relabel_configs 是 prometheus 在保存数据前的最后一步标签重新编辑，针对的是metric对象<br />默认情况下，它将监控不需要的数据，直接丢掉，不在prometheus 中保存 |

**对 target 重新打标**

对 target 重新打标是在数据抓取之前动态重写 target 标签的强大工具

在每个数据抓取配置中，可以定义多个 relabel 步骤，它们将按照定义的顺序依次执行

对于发现的每个 target，Prometheus 默认会执行如下操作

~~~shell
job 的标签设定为配置文件中其所属的 job_name 的值
__address__ 标签的值为该target的套接字地址"<host>:<port>"
instance 标签的值为 __address__ 的值
__scheme__ 标签的值为抓取该 target 上指标时使用的协议(http或https) 
__metrics_path__ 标签的值为抓取该 target 上的指标时使用URI路径，默认为/metrics
__param_<name> 标签的值为传递的 URL 参数中第一个名称 <name> 的参数的值，此项依赖于 URL 中是否存在参数
~~~

重新标记期间，还可以使用该target上以 "_\_meta\_\_" 开头的元标签,各服务发现机制为其target添加的元标签会有所不同

重新标记完成后，该target上以 "_\_" 开头的所有标签都会被移除,若在relabel的过程中需要临时存储标签值，则要使用 __tmp 标签名称为前缀进行保存，以避免同Prometheus的内建标签冲突

**对抓取到的 metric 重新打标**

对metric重新打标是在数据抓取之后动态重写metric标签的工具，在每个数据抓取配置中，可以定义多个metric relabel的步骤

对metric重新打标的配置格式与target重新打标的格式相同，但前者要定义在专用的 metric_relabel_configs 字段中

它们将按照定义的顺序依次执行

- 删除不必要的指标
- 从指标中删除敏感或不需要的标签
- 添加、编辑或修改指标的标签值或标签格式

要注意的是，更改或添加标签会创建新的时间序列

- 应该明确地使用各个标签，并尽可能保持不变，以避免创建出一个动态的数据环境
- 标签是时间序列的唯一性约束，删除标签并导致时间序列重复时，可能会导致系统出现问题

## 4.4 标签管理

对于一些全局性的标签，可以在 global 部分通过属性来设置，格式如下：

~~~shell
global:
 ...
  # 与外部系统通信时添加到任何时间序列或警报的标签
 external_labels:
   [ <labelname>: <labelvalue> ... ]
~~~

https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config

https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs

relabel_config、metric_relabel_configs 的使用格式基本上一致

常见配置如下

~~~yaml
#配置示例如下：
scrape_configs:
  - job_name: 'prometheus'
    relabel_configs|metric_relabel_configs:
      - source_labels: [<labelname> [, ...]]
        separater: '<string> | default = ;'
        regex: '<regex> | default = (.*)'
        replacement: '<string> | default = $1'
        target_label: '<labelname>'
        action: '<relabel_action> | default = replace'
#属性解析：
action #对标签或指标进行管理，常见的动作有replace|keep|drop|labelmap|labeldrop等,默认为replace
source_labels #指定正则表达式匹配成功的Label进行标签管理,此为列表
target_label #在进行标签替换的时候，可以将原来的source_labels替换为指定修改后的label
separator           #指定用于联接多个source_labels为一个字符串的分隔符,默认为分号
regex #表示source_labels对应Label的名称或者值(和action有关)进行匹配此处指定的正则表达式
replacement #替换标签时,将 target_label对应的值进行修改成此处的值


# action 说明
#1）替换标签的值:
replace   #此为默认值，首先将source labels中指定的各标签的值使用separator指定的字符进行串连,如果串连后的值和regex匹配，则使用replacement指定正则表达式模式或值对target_label字段进行赋值，如果target_label不存在，也可以用于创建新的标签名为target_label
hashmod  #将target_label的值设置为一个hash值，该hash是由modules字段指定的hash模块算法对source_labels上各标签的串连值进行hash计算生成

#2）保留或删除指标: 该处的每个指标名称对应一个target或metric
keep   #如果获取指标的source_labels的各标签的值串连后的值与regex匹配时,则保留该指标,反之则删除该指标
drop   #如果获取指标的source_labels的各标签的值串连后的值与regex匹配时,则删除该指标,反之则保留该指标，即与keep相反

#3）创建或删除标签
labeldrop  #如果source labels中指定的标签名称和regex相匹配,则删除此标签,相当于标签黑名单
labelkeep  #如果source labels中指定的标签名称和regex相匹配,则保留,不匹配则删除此标签,相当于标签白名单
labelmap   #一般用于生成新标签，将regex对source labels中指定的标签名称进行匹配，而后将匹配到的标签的值赋值给replacement字段指定的标签；通常用于取出匹配的标签名的一部分生成新标签,旧的标签仍会存在

#4）大小写转换
lowercase #将串联的 source_labels 映射为其对应的小写字母
uppercase #将串联的 source_labels 映射到其对应的大写字母
~~~

示例

~~~shell
# 删除示例
# 匹配名字以 "node_network_receive" 开头的 metrics ，删除
metric_relabel_configs:
  - source_labels: [__name__]
    regex: 'node_network_receive.*'
    action: drop
    
# 替换示例
# 查找名字叫做 id 且值为以 "/" 开头的 metrics，将值替换为 "123456"，并将 key 替换为 replace_id
metric_relabel_configs:
  - source_labels: [id]
    regex: '/.*'
    replacement: '123456'
    target_label: replace_id
~~~

## 4.5 案例

范例：基于Target上已存在的标签名称进行匹配生成新标签，然后进行删除旧标签

~~~yaml
- job_name: "label_test"
  metrics_path: '/metrics'
  scheme: 'http'
  static_configs:
    - targets: 
        - 192.168.121.111:9100
        - 192.168.121.112:9100
        - 192.168.121.113:9100
      labels: {app: "worker"}
  relabel_configs:
    - source_labels:
        - __scheme__
        - __address__
        - __metrics_path__
      regex: "(http|https)(.*)"
      separator: ""
      target_label: "endpoint"
      replacement: "${1}://${2}"
      action: replace
      # 所有名称为job或app的标签修改其标签名称加后缀 _name,但旧的标签还存在
    - regex: "(app|job)"
      replacement: "${1}_name"
      action: labelmap
      # 则删除所有名称为job或app的旧标签,注意上面修改和此删除的前后顺序
    - regex: "(app|job)"
      action: labeldrop
    - source_labels: [endpoint]
      target_label: myendpoint

~~~

![image-20250920184404333](Prometheus.assets/image-20250920184404333.png)

![image-20250920185247951](Prometheus.assets/image-20250920185247951.png)

用于在相应的job上，删除发现的各target之上面以"go"为前名称前缀的指标

~~~yaml
- job_name: "label_test"
  metrics_path: '/metrics'
  scheme: 'http'
  static_configs:
    - targets: 
        - 192.168.121.111:9100
        - 192.168.121.112:9100
        - 192.168.121.113:9100
      labels: {app: "worker"}
  relabel_configs:
    - source_labels:
        - __scheme__
        - __address__
        - __metrics_path__
      regex: "(http|https)(.*)"
      separator: ""
      target_label: "endpoint"
      replacement: "${1}://${2}"
      action: replace
    - regex: "(app|job)"
      replacement: "${1}_name"
      action: labelmap
    - regex: "(app|job)"
      action: labeldrop
    - source_labels: [endpoint]
      target_label: myendpoint
  # 默认有很多go开头的指标，下面删除此类指标
  metric_relabel_configs:
    - source_labels:
        - __name__
      regex: "go.*"
      action: drop
# 再访问以go开头的指标，不会再生成新的采集数据
~~~

![image-20250920185640815](Prometheus.assets/image-20250920185640815.png)

# 五、记录和告警规则

![image-20250920190337081](Prometheus.assets/image-20250920190337081.png)

## 5.1 记录规则

### 5.1.1 规则简介

Prometheus 支持两种类型的规则：

- 记录规则

  PromQL 别名

- 警报规则

它们可以进行配置，然后定期进行评估。 要将规则包含在Prometheus中，需要先创建一个包含必要规则语句的文件，并让Prometheus通过Prometheus配置中的rule_fies字段加载该文件。 默认情况下，prometheus的规则文件使用YAML格式

规则的使用流程：

- 首先创建一个满足规则标准的规则语句，然后发送SIGHUP给Prometheus进程
- prometheus在运行时重新加载规则文件，从而让规则在prometheus运行环境中生效。

规则语法检查：

~~~shell
promtool check rules prometheus_rues_fie.yml

# 说明：
当该文件在语法上有效时，检查器将已解析规则的文本表示形式打印到标准输出，然后以0返回状态退出。
如果有任何语法错误或无效的输入参数，它将打印一条错误消息为标准错误，并以1返回状态退出。
~~~

~~~yaml
rule_files:
  - "first_rules.yml"
  - "second_rules.yml"
  - "../rules/*.yml"   
  
#注意: 如果用相对路径是指相对于prometheus.yml配置文件的路径
~~~

### 5.1.2 记录规则说明

https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/

在Prometheus的表达式浏览器进行的查询会生成的新的数据序列，但其结果仅会临时保存于Prometheus Server上

在样本数据量较大、工作较为繁忙的Prometheus Server上，对于那些查询频率较高且运算较为复杂的查询来说，实时查询可能会存在一定程度的响应延迟

记录规则的作用其实将之前的监控命令采用配置文件的方式进行编写，从而大大减轻工作量

记录规则(Recording rule）能够预先运行频繁用到或计算消耗较大的表达式，并将其结果保存为一组新的时间序列

记录规则是定义在Prometheus配置文件中的查询语句，由Server加载后以类似批处理任务的方式在后台周期性(evaluation_interval)的执行并记录查询结果

客户端只需要查询由记录规则生成的结果序列上的样本数据即可，速度远快于实时查询;常用于跨多个时间序列生成聚合数据，或者计算消耗较大的查询等场景中

多见于同可视化工具结合使用的需求中，也可用于生成可产生告警信息的时间序列

记录规则常用的场景：

- 将预先计算经常需要或计算量大的复杂的PromQL语句指定为一个独立的metric监控项，这样在查询的时候就非常方便，而且查询预计算结果通常比每次需要原始表达式都要快得多，尤其是对于仪表板特别有用，仪表板每次刷新时都需要重复查询相同的表达式。
- 此外在告警规则中也可以引用记录规则
- 记录规则效果与shell中的别名相似

The syntax of a rule file is:

```yaml
groups:
  [ - <rule_group> ]
```

A simple example rules file would be:

```yaml
groups:
  - name: example
    rules:
    - record: code:prometheus_http_requests_total:sum
      expr: sum by (code) (prometheus_http_requests_total)
      
```

属性解析：

~~~shell
name 		#规则组名，必须是唯一的
interval 	#定制规则执行的间隔时间,默认值为prometheus.yml配置文件中的 global.evaluation_interval
limit:      #限制条件，对于记录规则用于限制其最多可生成序列数量，对于告警规则用于限制最多可生成的告警数量
rules 		#设定规则具体信息
record 		#定制指标的名称
expr 		#执行成功的PromQL
labels 		#为该规则设定标签
~~~

### 5.1.3 记录规则案例

#### 5.1.3.1 案例说明

~~~shell
# 在 Prometheus 查询部分指标时需要通过将现有的规则组合成一个复杂的表达式，才能查询到对应的指标结果，比如在查询"自定义的指标请求处理时间"，参考如下
request_processing_seconds_sum{instance="192.168.121.221:8000",job="my_metric"} / 
request_processing_seconds_count{instance="192.168.121.221:8000",job="my_metric"} 
#以上的查询语句写起来非常长，在我们graph绘图的时候，每次输入命令都是非常繁琐,很容易出现问题。
~~~

#### 5.1.3.2 记录规则实现

```shell
# 创建规则记录文件
root@prometheus-221:~ 22:11:33 # cat /usr/local/prometheus/rules/prometheus_record_rules.yaml
groups:
  - name: myrules
    rules:
      - record: "request_process_per_time"
        expr: request_processing_seconds_sum{job="my_metrics"} / request_processing_seconds_count{job="my_metrics"}
        labels:
          app: "flask"
          role: "web"
      - record: "request_count_per_minute"
        expr: increase(request_count_total{job="my_metrics"}[1m])
        labels:
          app: "flask"
          role: "web"

# 在 Prometheus 配置文件中配置规则
rule_files:
  - "../rules/*.yaml"
  # - "first_rules.yml"
  # - "second_rules.yml"


# 检测文件有效性
root@prometheus-221:~ 22:13:59 # promtool check rules /usr/local/prometheus/rules/prometheus_record_rules.yaml
Checking /usr/local/prometheus/rules/prometheus_record_rules.yaml
  SUCCESS: 2 rules found

root@prometheus-221:~ 22:14:07 # promtool check config /usr/local/prometheus/conf/prometheus.yml 
Checking /usr/local/prometheus/conf/prometheus.yml
  SUCCESS: 1 rule files found
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

Checking /usr/local/prometheus/rules/prometheus_record_rules.yaml
  SUCCESS: 2 rules found


# 重启服务，加载prometheus配置
root@prometheus-221:~ 22:15:48 # systemctl restart prometheus.service 

```

![image-20250920221759730](Prometheus.assets/image-20250920221759730.png)

![image-20250920221824005](Prometheus.assets/image-20250920221824005.png)

点击Status下面的Rules，查看效果

![image-20250920221852619](Prometheus.assets/image-20250920221852619.png)

在 Grafana 图形使用记录规则

![image-20250920224000495](Prometheus.assets/image-20250920224000495.png)

范例：系统相关指标的记录规则

~~~yaml
root@prometheus-221:~ 22:44:10 # cat /usr/local/prometheus/rules/sys_rules.yaml
groups:
  - name: custom_rules
    interval: 5s
    rules:
      - record: instance:node_cpu:avg_rate5m
        expr: 100 - avg(irate(node_cpu_seconds_total{job="node", mode="idle"}[5m])) by (instance) * 100
      - record: instace:node_memory_MemFree_percent
        expr: 100 - (100 * node_memory_MemFree_bytes / node_memory_MemTotal_bytes)
      - record: instance:root:node_filesystem_free_percent
        expr: 100 * node_filesystem_free_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}
root@prometheus-221:~ 22:44:18 #

root@prometheus-221:~ 22:44:09 # promtool check rules  /usr/local/prometheus/rules/sys_rules.yaml
Checking /usr/local/prometheus/rules/sys_rules.yaml
  SUCCESS: 3 rules found

~~~

## 5.2 告警说明和 Alertmanager 部署

### 5.2.1 告警介绍

https://prometheus.io/docs/alerting/latest/overview/

Prometheus作为一个大数据量场景下的监控平台来说，数据收集是核心功能，虽然监控数据可视化了，也非常容易观察到运行状态。但是最能产生价值的地方就是对数据分析后的告警处理措施，因为我们很难做到时刻盯着监控并及时做出正确的决策，所以程序来帮巡检并自动告警，是保障业务稳定性的决定性措施。可以说任何一个监控平台如果没有告警平台，那么他就逊色不少甚至都不能称之为平台。

Prometheus报警功能主要是利用Alertmanager这个组件来实现功能的。Alertmanager作为一个独立的组件，负责接收并处理来自Prometheus Server(也可以是其它的客户端程序)的告警信息。

Alertmanager可以对这些告警信息进行进一步的处理，比如当接收到大量重复告警时能够消除重复的告警信息，同时对告警信息进行分组并且路由到正确的通知方，Prometheus 内置了对邮件，Slack 等多种通知方式的支持，同时还支持与 Webhook 的集成，以支持更多定制化的场景。

### 5.2.2 告警组件

告警能力在Prometheus的架构中被划分成两个独立的部分。

- 通过在Prometheus中定义AlertRule(告警规则)，Prometheus会周期性的对告警规则进行计算，如果满足告警触发条件就会向Alertmanager发送告警信息。
- 然后，Alertmanager管理这些告警，包括进行重复数据删除，分组和路由，以及告警的静默和抑制 

当Alertmanager接收到 Prometheus 或者其它应用发送过来的 Alerts 时，Alertmanager 会对 Alerts 进行去重复，分组，按标签内容发送不同报警组，包括：邮件，微信，Webhook。AlertManager还提供了静默和告警抑制机制来对告警通知行为进行优化。

### 5.2.3 告警特性

https://prometheus.io/docs/alerting/latest/alertmanager/

- 去重

  将多个相同的告警,去掉重复的告警,只保留不同的告警

- 分组 Grouping

  分组机制可以将相似的告警信息合并成一个通知。

- 在某些情况下，比如由于系统宕机导致大量的告警被同时触发，在这种情况下分组机制可以将这些被触发的告警合并为一个告警通知，避免一次性接受大量的告警通知，而无法对问题进行快速定位。

  告警分组，告警时间，以及告警的接受方式可以通过Alertmanager的配置文件进行配置。

- 抑制 Inhibition

  系统中某个组件或服务故障，那些依赖于该组件或服务的其它组件或服务可能也会因此而触发告警，抑制便是避免类似的级联告警的一种特性，从而让用户能将精力集中于真正的故障所在

  抑制可以避免当某种问题告警产生之后用户接收到大量由此问题导致的一系列的其它告警通知

  抑制的关键作用在于，同时存在的两组告警条件中，其中一组告警如果生效，能使得另一组告警失效，同样通过Alertmanager的配置文件进行设置

- 静默 Silent

  静默提供了一个简单的机制可以快速根据标签在一定的时间对告警进行静默处理。

  如果接收到的告警符合静默的配置，Alertmanager则不会发送告警通知。

  比如：通常在系统例行维护期间，需要激活告警系统的静默特性

  静默设置可以在Alertmanager的Web页面上进行设置。

- 路由 Route

  将不同的告警定制策略路由发送至不同的目标，比如：不同的接收人或接收媒介

### 5.2.4 Alertmanager 部署

#### 5.2.4.1 二进制部署

Alertmanager 下载链接

https://github.com/prometheus/alertmanager/releases

~~~shell
# 获取安装包
root@prometheus-221:~ 22:51:56 # wget https://github.com/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz

# 部署软件
root@prometheus-221:~ 22:52:55 # tar xf alertmanager-0.28.1.linux-amd64.tar.gz  -C /usr/local
root@prometheus-221:~ 22:53:24 # cd /usr/local
root@prometheus-221:/usr/local 23:01:03 # ln -sv alertmanager-0.28.1.linux-amd64 alertmanager
'alertmanager' -> 'alertmanager-0.28.1.linux-amd64'
root@prometheus-221:/usr/local 23:01:22 # cd alertmanager
root@prometheus-221:/usr/local/alertmanager 23:01:24 # mkdir {bin,conf,data}
root@prometheus-221:/usr/local/altermanager 22:53:40 # ls
alertmanager  alertmanager.yml  amtool  LICENSE  NOTICE
root@prometheus-221:/usr/local/altermanager 22:53:43 # mv alertmanager amtool  bin/
root@prometheus-221:/usr/local/altermanager 22:53:43 # mv alertmanager.yml  conf/
root@prometheus-221:/usr/local/alertmanager 23:01:34 # tree 
.
├── bin
│   ├── alertmanager
│   └── amtool
├── conf
│   └── alertmanager.yml
├── data
├── LICENSE
└── NOTICE

3 directories, 5 files


# 配置环境变量
root@prometheus-221:~ 23:03:25 # cat /etc/profile.d/alertmanager.sh
############################
# File Name: /etc/profile.d/altermanager.sh
# Author: xuruizhao
# mail: xuruizhao00@163.com
# Created Time: Sat 20 Sep 2025 10:54:30 PM CST
############################
#!/bin/bash
export ALERT_HOME=/usr/local/alertmanager
export PATH=$PATH:$ALERT_HOME/bin
root@prometheus-221:~ 23:03:28 # source /etc/profile.d/alertmanager.sh


# 配置权限
root@prometheus-221:~ 23:03:31 # chown -R prometheus:prometheus  /usr/local/alertmanager/


# 创建 service 文件
root@prometheus-221:~ 23:04:33 # cat /lib/systemd/system/alertmanager.service
[Unit]
Description=alertmanager project
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/alertmanager/bin/alertmanager --config.file=/usr/local/alertmanager/conf/alertmanager.yml --storage.path=/usr/local/alertmanager/data --web.listen-address=0.0.0.0:9093
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
User=prometheus
Group=prometheus
[Install]
WantedBy=multi-user.target

root@prometheus-221:~ 23:04:35 # systemctl daemon-reload 
root@prometheus-221:~ 23:04:43 # systemctl enable --now alertmanager.service 
Created symlink /etc/systemd/system/multi-user.target.wants/alertmanager.service → /lib/systemd/system/alertmanager.service.
root@prometheus-221:~ 23:05:01 # ss -tunlp | grep alertmanager
udp   UNCONN 0      0                  *:9094            *:*    users:(("alertmanager",pid=251398,fd=6))   
tcp   LISTEN 0      4096               *:9093            *:*    users:(("alertmanager",pid=251398,fd=7))   
tcp   LISTEN 0      4096               *:9094            *:*    users:(("alertmanager",pid=251398,fd=3))   
root@prometheus-221:~ 23:05:35 # 
# 结果显示：当前主机上出现了两个端口9093(与prometheus交互端口)和9094(Alertmanager集群HA mode使用)
# 查看AlertManager也会暴露指标
root@prometheus-221:~ 23:06:11 # curl 192.168.121.221:9093/metrics

# 可以通过访问 http://192.168.121.221:9093/ 来看 alertmanager 提供的 Web 界面
~~~

![image-20250920230645566](Prometheus.assets/image-20250920230645566.png)

![image-20250920230658587](Prometheus.assets/image-20250920230658587.png)

#### 5.2.4.2 shell 脚本一键部署

```shell
#!/bin/bash
#
#********************************************************************
#Author:            xuruizhao
#FileName:          install_alertmanager.sh
#Email:				xuruizhao00@163.com
#********************************************************************

#支持在线和离线安装，在线下载可能很慢,建议离线安装

ALERTMANAGER_VERSION=0.27.0
#ALERTMANAGER_VERSION=0.25.0
#ALERTMANAGER_VERSION=0.24.0
#ALERTMANAGER_VERSION=0.23.0

ALERTMANAGER_FILE="alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
ALERTMANAGE_URL="https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/${ALERTMANAGER_FILE}"
INSTALL_DIR=/usr/local

HOST=`hostname -I|awk '{print $1}'`
. /etc/os-release

msg_error() {
  echo -e "\033[1;31m$1\033[0m"
}

msg_info() {
  echo -e "\033[1;32m$1\033[0m"
}

msg_warn() {
  echo -e "\033[1;33m$1\033[0m"
}


color () {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "    
    elif [ $2 = "failure" -o $2 = "1"  ] ;then 
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo 
}


install_alertmanager () {
    if [ ! -f  ${ALERTMANAGER_FILE} ] ;then
        wget ${ALERTMANAGE_URL}  || { color "下载失败!" 1 ; exit ; }
    fi
    [ -d $INSTALL_DIR ] || mkdir -p $INSTALL_DIR
    tar xf ${ALERTMANAGER_FILE} -C $INSTALL_DIR
    cd $INSTALL_DIR &&  ln -s alertmanager-${ALERTMANAGER_VERSION}.linux-amd64 alertmanager
    mkdir -p $INSTALL_DIR/alertmanager/{bin,conf,data}
    cd $INSTALL_DIR/alertmanager && { mv alertmanager.yml conf/;  mv alertmanager amtool bin/; }
	id prometheus &> /dev/null ||useradd -r -g prometheus -s /sbin/nologin prometheus
    chown -R prometheus.prometheus $INSTALL_DIR/alertmanager/
      
    cat >>  /etc/profile <<EOF
export ALERTMANAGER_HOME=${INSTALL_DIR}/alertmanager
export PATH=\${ALERTMANAGER_HOME}/bin:\$PATH
EOF

}

alertmanager_service () {
    cat > /lib/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Prometheus alertmanager
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/alertmanager/bin/alertmanager --config.file=${INSTALL_DIR}/alertmanager/conf/alertmanager.yml --storage.path=${INSTALL_DIR}/alertmanager/data --web.listen-address=0.0.0.0:9093
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
User=prometheus
Group=prometheus

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now alertmanager.service
}


start_alertmanager() { 
    systemctl is-active alertmanager.service
    if [ $?  -eq 0 ];then
        echo
        color "alertmanager 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        msg_info "http://$HOST:9093"
    else
        color "alertmanager 安装失败!" 1
        exit
    fi

}

install_alertmanager

alertmanager_service

start_alertmanager
```

### 5.2.5 Prometheus 集成

~~~yaml
- job_name: "alertmanager"
  static_configs:
    - targets: ["192.168.121.221:9093"]

~~~

~~~shell
root@prometheus-221:~ 13:14:48 # systemctl restart prometheus.service 
~~~

### 5.2.6 Alertmanager 配置文件

#### 5.2.6.1 Alertmanager 配置文件说明

https://prometheus.io/docs/alerting/latest/configuration/

Alertmanager 通过yml格式的配置文件

Alertmanager 配置文件格式说明

~~~shell
# 配置文件总共定义了五个模块，global、templates、route，receivers，inhibit_rules
global:
  resolve_timeout: 1m 
  smtp_smarthost: 'localhost:25'
  smtp_from: 'ops@example.com'
  smtp_require_tls: false
  
templates:
  - '/etc/alertmanager/template/*.tmpl'

route:
  receiver: 'wang'   
  group_by: ['alertname'] 
  group_wait: 20s
  group_interval: 10m 
  repeat_interval: 3h 
    
receivers:
  - name: 'admin'
    email_configs:
      - to: 'admin@example.com'
      
#说明
global 
#用于定义Alertmanager的全局配置。
#相关配置参数
resolve_timeout #定义持续多长时间未接收到告警标记后，就将告警状态标记为resolved
smtp_smarthost  #指定SMTP服务器地址和端口
smtp_from #定义了邮件发件的的地址
smtp_require_tls #配置禁用TLS的传输方式
templates
#用于指定告警通知的信息模板，如邮件模板等。由于Alertmanager的信息可以发送到多种接收介质，如邮件、微信等，通常需要能够自定义警报所包含的信息，这个就可以通过模板来实现。

route
#用于定义Alertmanager接收警报的处理方式，根据规则进行匹配并采取相应的操作。路由是一个基于标签匹配规则的树状结构，所有的告警信息都会从配置中的顶级路由(route)进入路由树。从顶级路由开始，根据标签匹配规则进入到不同的子路由，并且根据子路由设置的接收者发送告警。在示例配置中只定义了顶级路由，并且配置的接收者为wang，因此，所有的告警都会发送给到admin的接收者。
#相关参数
group_by        #用于定义分组规则，使用告警名称做为规则，满足规则的告警将会被合并到一个通知中
group_wait      #当 Alertmanager 收到一个告警组时，它会在 group_wait 时间内等待是否还有其他属于同一组的告警。如果在这个时间内没有收到其他属于同一组的告警，Alertmanager 将认为该组的告警已经完整，并开始进行通知操作。这样做可以在一定程度上避免频繁发送不完整的告警通知，而是等待一段时间后再一起发送
group_interval #用于控制在一段时间内收集这些相同告警规则的实例，并将它们组合成一个告警组。在这个时间间隔内，如果相同的告警规则再次触发，它们将被添加到同一个告警组中。这样做可以避免过于频繁地发送重复的告警通知，从而避免对接收者造成困扰。配置分组等待的时间间隔，在这个时间内收到的告警，会根据前面的规则做合并
repeat_interval #参数定义了重复发送告警通知的时间间隔。如果告警状态在 repeat_interval 时间内持续存在（即告警没有被解决），Alertmanager 会定期重复发送相同的告警通知。这样做可以确保接收者持续得到告警的提醒，直到告警状态得到解决为止。

receivers
#用于定义相关接收者的地址信息
#告警的方式支持如下
email_configs  #配置相关的邮件地址信息
wechat_configs  #指定微信配置
webhook_configs #指定webhook配置,比如:dingtalk
~~~

alertmanager配置文件语法检查命令

~~~shell
amtool check-config /usr/local/alertmanager/conf/alertmanager.yml
~~~

#### 5.6.2.2 Alertmanager 启用邮件告警

https://prometheus.io/docs/alerting/latest/configuration/#email_config

##### 5.6.2.2.1 启用邮箱

邮箱服务器开启smtp的授权码，每个邮箱开启授权码操作不同

**网易邮箱开启邮件通知功能**

![image-20250921201740627](Prometheus.assets/image-20250921201740627.png)

##### 5.6.2.2.2 Alertmanager 实现邮件告警

~~~shell
root@prometheus-221:~ 20:25:35 # cat /usr/local/alertmanager/conf/alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.qq.com:25'		# 基于全局块指定发件人信息
  smtp_from: 'xuruizhao00@163.com'
  smtp_auth_username: 'xuruizhao00@163.com'
  smtp_auth_password: 'XKqavNdyKr4c8wvN'
  smtp_hello: '163.com'
  smtp_require_tls: false			# 启用tls安全,默认true

# 路由配置
route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 10s			# 此值不要过低，否则短期内会收到大量告警通知
  receiver: 'email'				# 指定接收者名称

# 收信人员
receivers:
  - name: 'email'
    email_configs:
      - to: "929695792@qq.com"
        send_resolved: true			# 问题解决后也会发送恢复通知


###################################################
# 抑制规则，此为可选
inhibit_rules:
  - source_match:
     severity: 'critical'
   target_match:
     severity: 'warning'
   equal: ['alertname', 'dev', 'instance']
#属性解析：repeat_interval配置项，用于降低告警收敛，减少报警，发送关键报警，对于email来说，此项不可以设置过低，否则将会由于邮件发送太多频繁，被smtp服务器拒绝

#语法检查
amtool check-config /usr/local/alertmanager/conf/alertmanager.yml
#重启服务
systemctl restart alertmanager.service
~~~

![image-20250921202819811](Prometheus.assets/image-20250921202819811.png)

## 5.3 告警规则

### 5.3.1 告警规则说明

https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/

警报规则可以实现基于Prometheus表达式语言定义警报条件，并将有关触发警报的通知发送到外部服务。 只要警报表达式在给定的时间点生成一个或多个动作元素，警报就被视为这些元素的标签集处于活动状态。

告警规则中使用的查询语句较为复杂时，可将其保存为记录规则，而后通过查询该记录规则生成的时间序列来参与比较，从而避免实时查询导致的较长时间延迟

警报规则在Prometheus中的基本配置方式与记录规则基本一致。

在Prometheus中一条告警规则主要由以下几部分组成：

- 告警名称：用户需要为告警规则命名，当然对于命名而言，需要能够直接表达出该告警的主要内容
- 告警规则：告警规则实际上主要由PromQL进行定义，其实际意义是当表达式（PromQL）查询结果持续多长时间（During）后出发告警

在Prometheus中，还可以通过Group（告警组）对一组相关的告警进行统一定义。这些定义都是通过YAML文件来统一管理的

告警规则文件示例

~~~yaml
groups:
- name: example
  rules:
  - alert: HighRequestLatency
    #expr: up == 0  
    expr: job:request_latency_seconds:mean5m{job="myjob"} > 0.5
    for: 10m
    labels:
     severity: warning
     project: myproject
    annotations:
     summary: "Instance {{ $labels.instance }} down"
     description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minutes."

#属性解析：
alert       #定制告警的动作名称
expr        #是一个布尔型的条件表达式，一般表示满足此条件时即为需要告警的异常状态
for         #条件表达式被触发后，一直持续满足该条件长达此处时长后才会告警，即发现满足expr表达式后，在告警前的等待时长，默认为0，此时间前为pending状态，之后为firing，此值应该大于抓取间隔时长，避免偶然性的故障
labels      #指定告警规则的标签，若已添加，则每次告警都会覆盖前一次的标签值
labels.severity #自定义的告警级别的标签
annotations     #自定义注释信息，注释信息中的变量需要从模板中或者系统中读取，最终体现在告警通知的信息中
~~~

### 5.3.2 告警规则案例：邮件告警

#### 5.3.2.1 案例说明

编写一个检查自定义metrics的接口的告警规则，在prometheus中我们可以借助于up指标来获取对应的状态效果，查询语句如下：

~~~shell
up{job="my_metric"} 
#注意：如果结果是1表示服务正常，否则表示该接口的服务出现了问题。
~~~

#### 5.3.2.2 配置告警规则

编写规则定义文件

~~~yaml
root@prometheus-221:~ 20:52:02 # cat /usr/local/prometheus/rules/node_rules.yaml 
groups:
  - name: flask_web
    rules:
      - alert: InstanceDown
        expr: up{job="my_metrics"} == 0
        for: 1m
        labels:
          severity: 1
        annotations:
          summary: "Instance {{ $labels.instance }} 停止工作"
          description: "{{ $labels.instance }} job {{ $labels.job }} 已经停止1m以上"
#属性解析：
- name: flask_web  #指定分组名称,在一个组中可以有多个 alert ,只要其中一个alert条件满足,就会触发告警
{{ $labels.<labelname> }} 要插入触发元素的标签值
{{ $value }} 要插入触发元素的数值表达式值
#这里的 $name 都是来源于模板文件中的定制内容，如果不需要定制的变动信息，可以直接写普通的字符串


#检查语法
promtool check rules prometheus_alert_rules.yml 
  
#重启prometheus服务
systemctl reload prometheus.service
~~~

![image-20250921205333048](Prometheus.assets/image-20250921205333048.png)

告警状态

- Inactive：正常效果
- Pending：已触发阈值，但未满足告警持续时间（即rule中的for字段）
- Firing：已触发阈值且满足告警持续时间。

#### 5.3.2.3 验证结果

停止自定义的 flask 服务，稍等1分钟后，查看告警效果

![image-20250921212627242](Prometheus.assets/image-20250921212627242.png)

查看 Alertmanager 界面

![image-20250921212654762](Prometheus.assets/image-20250921212654762.png)

邮件告警效果

![image-20250921213903056](Prometheus.assets/image-20250921213903056.png)

恢复正常后，也会收到恢复通知邮件，如下界面

![image-20250921213936876](Prometheus.assets/image-20250921213936876.png)

## 5.4 告警模板

### 5.4.1 告警模板说明

默认的告警信息界面有些简单，可以借助于告警的模板信息，对告警信息进行丰富。需要借助于 alertmanager 的模板功能来实现。

使用流程：

- 分析关键信息
- 定制模板内容
- alertmanager 加载模板文件
- 告警信息使用模板内容属性

### 5.4.2 定制模板案例

#### 5.4.2.1 定制模板

模板文件使用标准的 Go 语法，并暴露一些包含时间标签和值的变量

~~~shell
标签引用： {{ $labels.<label_name> }}
指标样本值引用： {{ $value }}
#示例：若要在description注解中引用触发告警的时间序列上的instance和iob标签的值，可分别使用
{{$label.instance}}和{{$label.j
~~~

为了更好的显示效果,需要了解html相关技术,参考链接

https://www.w3school.com.cn/html/html_tables.asp

**准备告警模板**

~~~shell
root@prometheus-221:~ 15:42:59 # mkdir /usr/local/alertmanager/tmpl
root@prometheus-221:~ 15:46:26 # vim /usr/local/alertmanager/tmpl/email.tmpl
root@prometheus-221:~ 15:46:45 # cat /usr/local/alertmanager/tmpl/email.tmpl
{{ define "test.html" }}
<table border="1">
        <tr>
                <th>报警项</th>
                <th>实例</th>
                <th>报警阀值</th>
                <th>开始时间</th>
        </tr>
        {{ range $i, $alert := .Alerts }}
                <tr>
                        <td>{{ index $alert.Labels "alertname" }}</td>
                        <td>{{ index $alert.Labels "instance" }}</td>
                        <td>{{ index $alert.Annotations "value" }}</td>
                        <td>{{ $alert.StartsAt }}</td>
                </tr>
        {{ end }}
</table>
{{ end }}

#属性解析
{{ define "test.html" }} 表示定义了一个 test.html 模板文件，通过该名称在配置文件中应用上边模板文件就是使用了大量的 jinja2 模板语言。
$alert.xxx 其实是从默认的告警信息中提取出来的重要信息

root@prometheus-221:~ 15:46:47 # cat /usr/local/alertmanager/tmpl/email_template.tmpl
cat: /usr/local/alertmanager/tmpl/email_template.tmpl: No such file or directory
root@prometheus-221:~ 15:51:34 # vim  /usr/local/alertmanager/tmpl/email_template.tmpl
root@prometheus-221:~ 15:51:42 # cat /usr/local/alertmanager/tmpl/email_template.tmpl
{{ define "email.html" }}
{{- if gt (len .Alerts.Firing) 0 -}}
{{ range .Alerts }}
=========start==========<br>
告警程序: prometheus_alert <br>
告警级别: {{ .Labels.severity }} <br>
告警类型: {{ .Labels.alertname }} <br>
告警主机: {{ .Labels.instance }} <br>
告警主题: {{ .Annotations.summary }}  <br>
告警详情: {{ .Annotations.description }} <br>
触发时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }} <br>
=========end==========<br>
{{ end }}{{ end -}}
 
{{- if gt (len .Alerts.Resolved) 0 -}}
{{ range .Alerts }}
=========start==========<br>
告警程序: prometheus_alert <br>
告警级别: {{ .Labels.severity }} <br>
告警类型: {{ .Labels.alertname }} <br>
告警主机: {{ .Labels.instance }} <br>
告警主题: {{ .Annotations.summary }} <br>
告警详情: {{ .Annotations.description }} <br>
触发时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }} <br>
恢复时间: {{ .EndsAt.Format "2006-01-02 15:04:05" }} <br>
=========end==========<br>
{{ end }}{{ end -}}
{{- end }}

root@prometheus-221:~ 15:51:44 #

#说明
"2006-01-02 15:04:05"是一个特殊的日期时间格式化模式，在Golang中，日期和时间的格式化是通过指定特定的模式来实现的。它用于表示日期和时间的具体格式
~~~

#### 5.4.2.2 应用模板

~~~shell
# 配置 alertmanager 指定，模板位置
root@prometheus-221:~ 15:51:44 # vim /usr/local/alertmanager/conf/alertmanager.yml
root@prometheus-221:~ 16:09:18 # cat /usr/local/alertmanager/conf/alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.163.com:465'
  smtp_from: 'xuruizhao00@163.com'
  smtp_auth_username: 'xuruizhao00@163.com'
  smtp_auth_password: 'XKqavNdyKr4c8wvN'
  smtp_hello: '163.com'
  smtp_require_tls: false
templates:					# 加下面两行加载模板文件
  - '../tmpl/*.tmpl'		# 相对路径是相对于 altermanager.yml 文件的路径
route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 10s
  receiver: 'email'

receivers:
  - name: 'email'
    email_configs:
      - to: "929695792@qq.com"
        send_resolved: true
        headers: { Subject: "[WARN] 报警邮件"}		 # 添加此行,定制邮件标题
        html: '{{ template "test.html" .}}'			# 添加此行,调用模板显示邮件正文
root@prometheus-221:~ 16:09:15 # systemctl restart alertmanager.service 
root@prometheus-221:~ 16:09:16 # systemctl status  alertmanager.service 

~~~

#### 5.4.2.3 测试结果

![image-20250923163351585](Prometheus.assets/image-20250923163351585.png)

## 5.5 告警路由

### 5.5.1 告警路由说明

Alertmanager 的 route 配置段支持定义"树"状路由表，入口位置称为根节点，每个子节点可以基于匹配条件定义出一个独立的路由分支

- 所有告警都将进入路由根节点，而后进行子节点遍历
- 若路由上的 continue 字段的值为 false，则遇到第一个匹配的路由分支后即终止；否则，将继续匹配后续的子节点

![image-20250923163537255](Prometheus.assets/image-20250923163537255.png)

上图所示：Alertmanager中的第一个Route是根节点，每一个match 都是子节点。

比如，我们之前定义的告警策略中，只有一个route，这意味着所有由Prometheus产生的告警在发送到Alertmanager之后都会通过名为email的receiver接收。

**注意:新版中使用指令 matchers 替换了 match 和 match_re 指令**

https://prometheus.io/docs/alerting/latest/configuration/#route

https://prometheus.io/docs/alerting/latest/configuration/#matcher

范例: 路由示例

~~~yaml
route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 10s
  receiver: 'email'

~~~

通过在 Prometheus 中给不同的告警规则添加不同的 label,再在 Alertmanager 中添加针对不同的lable使用不同的路由至不同的 receiver,即可以实现路由的分组功能

Alertmanager 的相关配置参数

~~~shell
# 默认信息的接收者，这一项是必须选项，否则程序启动不成功
[ receiver: <string> ]
# 分组时使用的标签，默认情况下，所有的告警都组织在一起，而一旦指定分组标签，则Alertmanager将按这些标签进行分组

[ group_by: '[' <labelname>, ... ']' ]
# 在匹配成功的前提下，是否继续进行深层次的告警规则匹配

[ continue: <boolean> | default = false ]
# 基于字符串验证，判断当前告警中是否存在标签labelname并且其值等于label value，满足则进行内部的后续处理。
#新版使用指令matchers替换match和match_re
matchers:
  - alertname = Watchdog
  - severity =~ "warning|critical"
#One of =, !=, =~, or !~. = means equals, != means that the strings are not equal, =~ is used for equality of regex expressions and !~ is used for un-equality of regexexpressions. They have the same meaning as known from PromQL selectors.

match:
 [ <labelname>: <labelvalue>, ... ]
# 基于正则表达式验证，判断当前告警标签的值是否满足正则表达式的内容，满足则进行内部的后续处理

match_re:
 [ <labelname>: <regex>, ... ]
# 发出一组告警通知的初始等待时长；允许等待一个抑制告警到达或收集属于同一组的更多初始告警，通常是0到数分钟
[ group_wait: <duration> | default = 30s ]
# 发送关于新告警的消息之前，需要等待多久；新告警将被添加到已经发送了初始通知的告警组中；一般在5分钟或以上
[ group_interval: <duration> | default = 5m ]
# 成功发送了告警后再次发送告警信息需要等待的时长，一般至少为3个小时
[ repeat_interval: <duration> | default = 4h ]

# 子路由配置
routes:
  [ - <route> ... ]
#注意：每一个告警都会从配置文件中顶级的route进入路由树，需要注意的是顶级的route必须匹配所有告警, 不能有 match 和 match_re
~~~

### 5.5.2 告警路由案例

定制的 metric 要求如下

- 如果是每分钟的QPS超过 500 的时候，将告警发给运维团队
- 如果是服务终止的话，发给管理团队

#### 5.5.2.1 定制告警规则

~~~yaml
root@prometheus-221:~ 16:45:40 # cat /usr/local/prometheus/rules/route.yaml
groups:
- name: flask_web
  rules:
  - alert: InstanceDown
    expr: up{job="my_metrics"} == 0
    for: 30s
    labels:
      severity: critical
    annotations:
      summary: "Instance {{ $labels.instance  }} 停止工作"
      description: "{{ $labels.instance  }} job {{ $labels.job  }} 已经停止1分钟以上"
      value: "{{$value}}"
- name: flask_QPS
  rules:
  - alert: InstanceQPSIsHight
    expr: increase(request_count_total{job="my_metrics"}[1m]) 
    for: 30s
    labels:
      severity: warning
    annotations:
      summary: "Instance {{ $labels.instance  }} QPS 持续过高"
      description: "{{ $labels.instance  }} job {{ $labels.job  }} QPS 持续过高"
      value: "{{$value}}"
root@prometheus-221:~ 16:45:47 # 
root@prometheus-221:~ 16:45:47 # systemctl restart prometheus.service 
root@prometheus-221:~ 16:46:00 #
# 查看prometheus上的路由规则效果
~~~

![image-20250923164658410](Prometheus.assets/image-20250923164658410.png)

![image-20250923164708989](Prometheus.assets/image-20250923164708989.png)

#### 5.5.2.2 定制路由分组

~~~yaml
root@prometheus-221:~ 16:53:03 # cat /usr/local/alertmanager/conf/alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.163.com:465'
  smtp_from: 'xuruizhao00@163.com'
  smtp_auth_username: 'xuruizhao00@163.com'
  smtp_auth_password: 'XKqavNdyKr4c8wvN'
  smtp_hello: '163.com'
  smtp_require_tls: false
templates:
  - '../tmpl/*.tmpl'
route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 10s
  receiver: 'email'
  routes:
    - receiver: 'leader-team'
      matchers:
        - severity = "critical"
    - receiver: 'ops-team'
      matchers:
        - severity =~ "^(warning)$"

receivers:
  - name: 'email'
    email_configs:
      - to: "929695792@qq.com"
        send_resolved: true
        headers: { Subject: "[WARN] 报警邮件"}
        html: '{{ template "test.html" .}}'
  - name: 'leader-team'
    email_configs:
      - to: "929695792@qq.com"
        send_resolved: true
        headers: { Subject: "[WARN] cirtical 报警邮件"}
        html: '{{ template "test.html" .}}'
  - name: 'ops-team'
    email_configs:
      - to: "929695792@qq.com"
        send_resolved: true
        headers: { Subject: "[WARN] QPS 报警邮件"}
        html: '{{ template "email.html" .}}'
root@prometheus-221:~ 16:53:06 # amtool check-config /usr/local/alertmanager/conf/alertmanager.yml
Checking '/usr/local/alertmanager/conf/alertmanager.yml'  SUCCESS
Found:
 - global config
 - route
 - 0 inhibit rules
 - 3 receivers
 - 1 templates
  SUCCESS

root@prometheus-221:~ 16:53:08 # systemctl restart alertmanager.service 

~~~

#### 5.5.2.3 测试效果

![image-20250923170148901](Prometheus.assets/image-20250923170148901.png)

![image-20250923170738276](Prometheus.assets/image-20250923170738276.png)

## 5.6 告警抑制

### 5.6.1 告警抑制说明

对于一种业务场景，有相互依赖的两种服务：A服务和B服务，一旦A服务异常，依赖A服务的B服务也会异常,从而导致本来没有问题的B服务也不断的发出告警。

![image-20250923183659653](Prometheus.assets/image-20250923183659653.png)

Alertmanager的抑制机制可以避免当某种问题告警产生之后用户接收到大量由此问题导致的一系列的其它告警通知。例如当集群不可用时，用户可能只希望接收到一条告警，告知用户这时候集群出现了问题，而不是大量的如集群中的应用异常、中间件服务异常的告警通知。

当已经发送的告警通知匹配到target_match和target_match_re规则，当有新的告警规则如果满足source_match或者定义的匹配规则，并且已发送的告警与新产生的告警中equal定义的标签完全相同，则启动抑制机制，新的告警不会发送。

通过上面的配置，可以在alertname/operations/instance相同的情况下，high的报警会抑制warning级别的报警信息。

抑制是当出现其它告警的时候压制当前告警的通知，可以有效的防止告警风暴。

比如当机房出现网络故障时，所有服务都将不可用而产生大量服务不可用告警，但这些警告并不能反映真实问题在哪，真正需要发出的应该是网络故障告警。当出现网络故障告警的时候，应当抑制服务不可用告警的通知。

配置解析

~~~shell
#源告警信息匹配 -- 报警的来源
source_match:
 [ <labelname>: <labelvalue>, ... ]
source_match_re:
 [ <labelname>: <regex>, ... ]
 
#目标告警信息匹配 - 触发的其他告警
target_match:
 [ <labelname>: <labelvalue>, ... ]
target_match_re:
 [ <labelname>: <regex>, ... ]
  
#目标告警是否是被触发的 - 要保证业务是同一处来源
[ equal: '[' <labelname>, ... ']' ]
#同时告警目标上的标签与之前的告警标签一样，那么就不再告警
~~~

配置示例

~~~yaml
#例如：
集群中的A主机节点异常导致NodeDown告警被触发，该告警会触发一个severity=critical的告警级别。
由于A主机异常导致该主机上相关的服务，会因为不可用而触发关联告警。
根据抑制规则的定义：
如果有新的告警级别为severity=critical，且告警中标签的node值与NodeDown告警的相同
则说明新的告警是由NodeDown导致的，则启动抑制机制,从而停止向接收器发送通知。
  
inhibit_rules:    # 抑制规则
- source_match:        # 源标签警报触发时会抑制含有目标标签的警报
   alertname: NodeDown # 可以针对某一个特定的告警动作规则
   severity: critical # 限定源告警规则的等级
 target_match:        # 定制要被抑制的告警规则的所处位置
   severity: normal    # 触发告警目标标签值的正则匹配规则，可以是正则表达式如: ".*MySQL.*"
 equal:        # 因为源告警和触发告警必须处于同一业务环境下，确保他们在同一个业务中
   - instance    # 源告警和触发告警存在于相同的 instance 时，触发告警才会被抑制。
      # 格式二 equal: ['alertname','operations', 'instance']
#表达式
 up{node="node01.wang.org",...} == 0
 severity: critical
#触发告警
 ALERT{node="node01.wang.org",...,severity=critical}
~~~

### 5.6.2 告警抑制案例

#### 5.6.2.1 案例说明

对于当前的flask应用的监控来说，上面做了两个监控指标：

- 告警级别为 critical 的 服务异常终止
- 告警级别为 warning 的 QPS访问量突然降低为0，这里以服务状态来模拟

当python服务异常终止的时候，不要触发同节点上的 QPS 过低告警动作。

#### 5.6.2.2 告警规则

~~~yaml
root@prometheus-221:/usr/local/prometheus/rules 20:53:33 # cat prometheus_alert_inhibit.yml
groups:
- name: flask_web
  rules:
  - alert: InstanceDown
    expr: up{job="my_metric"} == 0
    for: 30s
    labels:
      severity: critical
    annotations:
      summary: "PromAlert Instance {{ $labels.instance  }} 停止工作"
      description: "PromAlert {{ $labels.instance  }} job {{ $labels.job  }} 已经停止1分钟以上"
      value: "{{$value}}"
- name: flask_QPS
  rules:
  - alert: InstanceQPSIsHight
    expr: increase(request_count_total{job="my_metric"}[1m]) > 500
    for: 1m
    labels:
      severity: warning
    annotations:
      summary: "Instance {{ $labels.instance  }} QPS 持续过高"
      description: "{{ $labels.instance  }} job {{ $labels.job  }} QPS 持续过高"
      value: "{{$value}}"
  - alert: InstanceQPSIsLow                  #判断是否QPS访问为0
    expr: up{job="my_metric"} == 0
    for: 30s
    labels:
      severity: warning
    annotations:
      summary: "PromAlert Instance {{ $labels.instance  }} QPS 异常为零"
      description: "PromAlert {{ $labels.instance  }} job {{ $labels.job  }} QPS 异常为0"
      value: "{{$value}}"

root@prometheus-221:/usr/local/prometheus/rules 20:53:35 # promtool check rules prometheus_alert_inhibit.yml
Checking prometheus_alert_inhibit.yml
  SUCCESS: 3 rules found

root@prometheus-221:/usr/local/prometheus/rules 20:53:45 # 
~~~

#### 5.6.2.3 配置告警抑制

~~~yaml
# 在 alertmanager 配置文件中添加 
inhibit_rules:
  - source_match:
      severity: critical
    target_match:
      severity: warning
    equal:
      - instance
~~~

#### 5.6.2.4 验证结果

关停服务后，查看效果   

结果显示：开启告警抑制之后，因为 critical导致的warning事件就不再告警了，从而减少了告警风暴现象。

## 5.7 微信告警

### 5.7.1 微信告警说明

微信是我们日常使用的通信工具，而且通信的效率非常的高，下面介绍微信的告警方式。

就目前来说，使用微信告警的方式主要有以下三种：

- 用个人号发送告警 - 一般需要借助于专属的开发工具来实现
- 用公众号发送告警 - 借助于软件本身的机制来实现。
- 用企业号发送告警 - 借助于软件本身的机制来实现。此为推荐方式

对于公众号发送告警。但是很多个人公众号并没有开启了相关功能，无法测试很多功能，所以我们在测试微信公众号之前，可以采用官方的测试接口来实现告警功能。

微信公众号测试的接口地址:

https://mp.weixin.qq.com/debug/cgi-bin/sandbox?t=sandbox/login

企业微信目前更为便利和普遍,如下采用企业微信实现告警

企业微信接口

~~~shell
#获取认证token
https://qyapi.weixin.qq.com/cgi-bin/gettoken
#发送告警信息
https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="企业微信token"
#帮助手册：
获取认证：https://developer.work.weixin.qq.com/document/10013
发送消息：https://developer.work.weixin.qq.com/document/path/90236
~~~

实现步骤

- 企业微信后台配置
  - 创建企业微信、自定义告警部门
  - 创建企业应用认证信息
- Alertmanager配置告警通知人和告警模板
- Prometheus配置告警规则

### 5.7.3 微信告警案例

#### 5.7.3.1 企业微信配置

##### 5.7.3.1.1 注册企业微信

微信告警首先得注册一个企业微信，然后才能实现微信告警。

浏览器访问下面链接,注册企业微信

https://work.weixin.qq.com/

使用个人微信扫码登录后，定制自己的企业信息

注意：注册一个企业，没有任何限制，无需认证

![image-20250926161024423](Prometheus.assets/image-20250926161024423.png)

注册好之后需要查看自己的企业 id

##### 5.7.3.1.2 创建部门和人员

###### 5.7.3.1.2.1 创建部门

###### 5.7.3.1.2.2 部门加入人员

方法一：直接微信邀请,让相关人员自行扫码加入

方法二：手动添加人员

##### 5.7.3.1.3 创建微信应用

~~~mermaid
graph LR;
应用管理--->自建--->创建应用;

~~~

上传Logo和指定应用名称,并选择范围

![image-20250926161608580](Prometheus.assets/image-20250926161608580.png)

注意记下以下信息：

~~~shell
应用的 AgentId值
应用的 Secret的值
~~~

#### 5.7.2.2 微信告警消息命令

https://developer.work.weixin.qq.com/document/path/90487

https://work.weixin.qq.com/api/doc/90000/90003/90487

~~~mermaid
graph LR;
client--->注册/登录企业微信--->获取API调用凭证--->调用API发送消息
~~~

官方微信API参考文档

https://developer.work.weixin.qq.com/document/path/91039

https://work.weixin.qq.com/api/doc/90000/90135/91039

需要使用的相关信息

~~~shell
查看到企业ID的值
部门ID的值
应用的 AgentId的值 
应用的 Secret的值
~~~

##### 5.7.2.2.1 获取 Token

~~~shell
#获取通信token格式：
curl -H "Content-Type: application/json" -d '{"corpid":"企业id", "corpsecret": "应 用secret"}'https://qyapi.weixin.qq.com/cgi-bin/gettoken
~~~

范例: 获取 Token

~~~shell
#示例：
[root@prometheus ~]#curl -H "Content-Type: application/json" -d '{"corpid":"ww644a0d95807e476b", "corpsecret": "qYgLlipdHtZidsd8qAZaTKKkGkzIyWxuQSeQOk9Si0M"}' https://qyapi.weixin.qq.com/cgi-bin/gettoken

#返回token
{"errcode":0,"errmsg":"ok","access_token":"NMaWPA8xfYmcN5v8so7TdqsBwym78Vs53X5Os
Oy69-Q6Kv3GGXGU_V-8keGaArYkurIXrKMJGrdFbhYy-QqmKsr5x61-wv6yXZy0kiooXE-QfbDoNRumBSjiJg0AqkEOeBqaT1dc8_DryE-RGVD39J4Iu61TU3HWsyZVkGuRTU6ejM-qauflSOuy5cbDSONNXi9zUPwUmlg4XkAobrLgOw","expires_in":7200}
~~~

##### 5.7.2.2.2 命令发送测试消息

~~~shell
#发送信息信息要求Json格式如下：
   Data = {
        "toparty": 部门id,
        "msgtype": "text",
        "agentid": Agentid,
        "text": {"content": "消息内容主题"},
        "safe": "0"
   }
#格式：
curl -H "Content-Type: application/json" -d '{"toparty": "部门id", "msgtype":"text","agentid": "agentid", "text":{"content":"告警内容"}, "safe": "安全级别"}' https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="企业微信token"
~~~

~~~shell
#利用上面的token发送信息,注意:token有时间期限
[root@prometheus ~]#curl -H "Content-Type: application/json" -d '{"toparty": "2", "msgtype":"text","agentid": "1000004", "text":{"content":"PromAlert - prometheus 告警测试"}, "safe": "0"}' https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token="NMaWPA8xfYmcN5v8so7TdqsBwym78Vs53X5OsOy69-Q6Kv3GGXGU_V-8keGaArYkurIXrKMJGrdFbhYy-QqmKsr5x61-wv6yXZy0kiooXE-QfbDoNRumBSjiJg0AqkEOeBqaT1dc8_DryE-RGVD39J4Iu61TU3HWsyZVkGuRTU6ejM-qauflSOuy5cbDSONNXi9zUPwUmlg4XkAobrLgOw"

#返回成功提示
{"errcode":0,"errmsg":"ok","msgid":"WpLDpQFMGSE843kRbNhgXZcjYGgCPvKRM-uwZsq6dxIpvGVtDq3CVY9BHuCX6fJZxQe0cQ_XbSpKMYUyJtLCgg"}
~~~

手机微信会收到信息

##### 5.7.2.2.3 发送微信告警脚本

发送微信可以使用各种语言,下面使用shell脚本实现

~~~shell
#! /bin/bash

CorpID="ww644a0d95807e476b"
Secret="qYgLlipdHtZidsd8qAZaTKKkGkzIyWxuQSeQOk9Si0M"
agentid=1000004     #改为 AgentId 在创建的应用那里看
PartyID=2           #通讯录中的部门ID
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?
corpid=$CorpID&corpsecret=$Secret"
Token=$(curl -s -G $GURL |awk -F\": '{print $4}'|awk -F\" '{print $2}')
PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Token"
function body(){
       local userid=$1                 #发送的用户位于$1的字符串
       local partyid=$PartyID          
       local msg=$(echo "$@" | cut -d" " -f2-)
       printf '{\n'
       printf '\t"touser": "'"$userid"\"",\n"
       printf '\t"toparty": "'"$PartyID"\"",\n"
       printf '\t"msgtype": "text",\n'
       printf '\t"agentid": "'"$agentid"\"",\n"
       printf '\t"text": {\n'
       printf '\t\t"content": "'"$msg"\""\n"
       printf '\t},\n'
       printf '\t"safe":"0"\n'
       printf '}\n'
}
curl --data-ascii "$(body $*)" $PURL
#添加执行权限
chmod +x wechat.sh
#发送测试微信，其中wangxiaochun为企业微信的帐号，并且不区分大小写
./wechat.sh wangxiaochun 微信告警测试标题 微信告警测试信息内容
{"errcode":0,"errmsg":"ok","msgid":"TGvhsTpDOJtMR4-VhJqudSvxsnPPPXmSuXbb2iXiXw9Hk43lbS1TQ19-MDvEMZmCE02GJL9zRlG49u-hQHaXJg"}
~~~

#### 5.7.2.3 Alertmanager 配置

##### 5.7.2.3.1 定制告警的配置信息

~~~yaml
cat /usr/local/alertmanager/conf/alertmanager.yml
# 全局配置
global:
  resolve_timeout: 5m
   #必须项
  wechat_api_corp_id: 'xxxxxxxxxxxxxxxx'
   #此处的微信信息可省略,下面wechat_configs 也提供了相关信息
  wechat_api_url: 'https://qyapi.weixin.qq.com/cgi-bin/'
  wechat_api_secret: 'xxxxxxxxxxxxxxxxM'
# 模板配置
templates:
  - '../tmpl/*.tmpl'
# 路由配置,分级告警,critical级才发微信告警,一般只发邮件告警
route:
  group_by: ['instance', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 10s
  receiver: 'email'
  routes:
    - match:
        severity: critical
      receiver: 'wechat'
# 收信人员
receivers:
- name: 'wechat'
  wechat_configs:
   - to_party: '2'
     #to_user: '@all' #支持给企业内所有人发送
     agent_id: '1000004'
     #api_secret: 'qYgLlipdHtZidsd8qAZaTKKkGkzIyWxuQSeQOk9Si0M'
     send_resolved: true
     message: '{{ template "wechat.default.message" . }}'
#上面的配置，关键的信息必须准确，否则无法实现告警



group_wait #初次发送告警延时
group_interval #距离第一次发送告警，等待多久再次发送告警
repeat_interval #告警重发时间


#重启alertmanager服务
systemctl restart alertmanager
systemctl status alertmanager
~~~

##### 5.7.2.3.2 定制告警模板

~~~shell
{{ define "wechat.default.message" }}
{{- if gt (len .Alerts.Firing) 0 -}}
{{- range $index, $alert := .Alerts -}}
{{- if eq $index 0 }}
========= 监控报警 =========
告警状态：{{   .Status }}
告警级别：{{ .Labels.severity }}
告警类型：{{ $alert.Labels.alertname }}
故障主机: {{ $alert.Labels.instance }}
告警主题: {{ $alert.Annotations.summary }}
告警详情: {{ $alert.Annotations.message }}{{ $alert.Annotations.description}};
触发阀值：{{ .Annotations.value }}
故障时间: {{ ($alert.StartsAt.Add 28800e9).Format "2006-01-02 15:04:05" }}  #注意:此为golang的时间Format,表示1234567
========= = end =  =========
{{- end }}
{{- end }}
{{- end }}
{{- if gt (len .Alerts.Resolved) 0 -}}
{{- range $index, $alert := .Alerts -}}
{{- if eq $index 0 }}
========= 异常恢复 =========
告警类型：{{ .Labels.alertname }}
告警状态：{{   .Status }}
告警主题: {{ $alert.Annotations.summary }}
告警详情: {{ $alert.Annotations.message }}{{ $alert.Annotations.description}};
故障时间: {{ ($alert.StartsAt.Add 28800e9).Format "2006-01-02 15:04:05" }}
恢复时间: {{ ($alert.EndsAt.Add 28800e9).Format "2006-01-02 15:04:05" }}
{{- if gt (len $alert.Labels.instance) 0 }}
实例信息: {{ $alert.Labels.instance }}
{{- end }}
========= = end =  =========
{{- end }}
{{- end }}
{{- end }}
{{- end }}


~~~

#### 5.7.2.4 Prometheus 集成配置

##### 5.7.2.4.1 定制告警规则

~~~yaml
vim /usr/local/prometheus/rules/prometheus_alert_route.yml
groups:
- name: flask_web
  rules:
    - alert: InstanceDown
      expr: up{job="my_metric"} == 0
      for: 10s
      labels:
        severity: critical  #指定告警级别
      annotations:
        summary: "Instance {{ $labels.instance }} 停止工作"
        description: "{{ $labels.instance }} job {{ $labels.job }} 已经停止1分钟以上"
        value: "{{$value}}"
- name: flask_QPS
  rules:
    - alert: InstanceQPSIsHight
      expr: increase(request_count_total{job="my_metric"}[1m]) > 500
      for: 10s
      labels:
        severity: warning
      annotations:
        summary: "Instance {{ $labels.instance }} QPS 持续过高"
        description: "{{ $labels.instance }} job {{ $labels.job }} QPS 持续过高"
        value: "{{$value}}"
~~~

#### 5.7.2.5 验证结果

## 5.8 钉钉告警

Prometheus 不直接支持钉钉告警, 但对于prometheus来说，它所支持的告警机制非常多，尤其还支持通过 webhook，从而可以实现市面上大部分的实时动态的告警平台。

Alertmanager 的 webhook 集成了钉钉报警，钉钉机器人对文件格式有严格要求，所以必须通过特定的格式转换，才能发送给钉钉的机器人。

在这里使用开源工具 prometheus-webhook-dingtalk 来进行prometheus和dingtalk的环境集成。

Github链接

https://github.com/timonwong/prometheus-webhook-dingtalk

**工作原理**

~~~mermaid
graph LR;
Prometheus--->Alertmanager--->prometheus-webhook-dingtalk--->|Webhook|钉钉
~~~



群机器人是钉钉群的高级扩展功能，通过选择机器人，并对通知群进行设置，就可以自动将机器人消息自动推送到钉钉群中，特别的高级智能化,由于机器人是将消息推送到群，需要预先建立好一个群实现

为了完成钉钉的告警实践，遵循以下的步骤

- 配置 PC 端钉钉机器人
- 测试钉钉环境

### 5.8.1 钉钉环境

#### 5.8.1.1 安装钉钉和创建企业

因为手机端无法进行添加机器人的相关操作，所以需要提前在电脑上下载安装钉钉的 PC 版本

注册并登录钉钉后,创建专属的团队组织

点击右上角的内容，点击"创建企业/组织/团队"

![image-20250926165634907](Prometheus.assets/image-20250926165634907.png)

#### 5.8.1.2 创建钉钉的告警群

![image-20250926165926820](Prometheus.assets/image-20250926165926820.png)

#### 5.8.1.3 告警群中添加配置机器人

群设置 --- 智能群助手 --- 添加机器人 --- 自定义通过webhook接入自定义服务

![image-20250926170048794](Prometheus.assets/image-20250926170048794.png)

![image-20250926170145453](Prometheus.assets/image-20250926170145453.png)

![image-20250926170215566](Prometheus.assets/image-20250926170215566.png)



~~~shell
注意：一定要记住分配的webhook地址：
https://oapi.dingtalk.com/robot/send?access_token=47b6c03464674d955ce2fcb9a6f669252b8306049c4e890224606f697cce5be1
记住告警的错误关键字:PromAlert
~~~

#### 5.8.1.4 钉钉测试

##### 5.8.1.4.1 只采用关键字测试

~~~shell
root@prometheus-221:~ 17:03:10 # WEBHOOK_URL="https://oapi.dingtalk.com/robot/send?access_token=47b6c03464674d955ce2fcb9a6f669252b8306049c4e890224606f697cce5be1"
root@prometheus-221:~ 17:07:51 # curl -H "Content-Type: application/json" -d '{"msgtype":"text","text":{"content":"PromAlert - prometheus 告警测试"}}'   ${WEBHOOK_URL}

# 返回信息
{"errcode":0,"errmsg":"ok"}

#注意：只有包含定制的告警关键字的信息才会被发送成功。否则会提示下面错误,这里面测试的时候，没有开启加签
{"errcode":310000, errmsg":"description:关键词不还配;solution:请联系群管理员查看此机器人的关键词，并在发送的信息中包含此关键词;"}
~~~

可以看到钉钉收到如下信息

![image-20250926170900411](Prometheus.assets/image-20250926170900411.png)

##### 5.8.1.4.2 采用关键字和加签的测试效果

在机器人的安全设置,选择"加签",复制加签信息

![image-20250926171022792](Prometheus.assets/image-20250926171022792.png)

~~~shell
加签信息： SECf180eaf0546d7464334179287f116aac3af58c00b42e733e0b2e32d1d5a2114b
~~~

如果采用了加签，这就要求，不仅仅要满足关键字的内容，还需要满足数据全流程认证加密的要求才可以正常发送

~~~ini
加签校验的特点在于： 基于时间戳的会话认证，所以我们要基于加签的信息，生成配套的时间戳和base64的秘钥生成，最后与我们的token生成标准的url地址
https://oapi.dingtalk.com/robot/send?access_token=钉钉token&timestamp=时间戳信息&sign=生成的秘钥
~~~

~~~python
# py 脚本实现
root@prometheus-221:~ 17:13:42 # cat create_sign.py
#!/usr/bin/python3
import time, hmac, hashlib, base64
import urllib.parse

# 生成时间戳
timestamp = str(round(time.time() * 1000))
# 传递当前的加签内容
secret = 'SECf180eaf0546d7464334179287f116aac3af58c00b42e733e0b2e32d1d5a2114b'
# 对加签内容进行编码
secret_enc = secret.encode('utf-8')

# 对基础内容进行格式化定制,并进行编码
string_to_sign = '{}\n{}'.format(timestamp, secret)
string_to_sign_enc = string_to_sign.encode('utf-8')


# 基于编码后的进入进行digest摘要认证加密
hmac_code = hmac.new(secret_enc, string_to_sign_enc,
digestmod=hashlib.sha256).digest()
sign = urllib.parse.quote_plus(base64.b64encode(hmac_code))
# 打印会话相关的时间戳和认证信息
print("Timestamp:",timestamp)
print("Sign: ",sign)


root@prometheus-221:~ 17:13:39 # python3 create_sign.py
Timestamp: 1758878022872
Sign:  c%2BJr9uqvKtTGflhLoSN%2B0PltSAYewHPV8AKV5xcvU54%3D
root@prometheus-221:~ 17:13:42 # 

~~~

加签情况下测试发送信息

~~~shell
root@prometheus-221:~ 17:16:17 # WEBHOOK_URL="https://oapi.dingtalk.com/robot/send?access_token=47b6c03464674d955ce2fcb9a6f669252b8306049c4e890224606f697cce5be1&timestamp=1758878022872&sign=c%2BJr9uqvKtTGflhLoSN%2B0PltSAYewHPV8AKV5xcvU54%3D"
root@prometheus-221:~ 17:16:34 # curl -H "Content-Type: application/json" -d '{"msgtype":"text","text":{"content":"PromAlert - prometheus 告警测试"}}'   ${WEBHOOK_URL}
{"errcode":0,"errmsg":"ok"}
~~~

![image-20250926171717722](Prometheus.assets/image-20250926171717722-17588782385391.png)

### 5.8.2 钉钉告警实现

#### 5.8.2.1 prometheus-webhook-dingtalk 部署

范例：二进制安装

~~~shell
root@prometheus-221:~ 17:18:13 # wget https://github.com/timonwong/prometheus-webhook-dingtalk/releases/download/v2.1.0/prometheus-webhook-dingtalk-2.1.0.linux-amd64.tar.gz

root@prometheus-221:~ 17:19:25 # tar xf prometheus-webhook-dingtalk-2.1.0.linux-amd64.tar.gz -C /usr/local/
root@prometheus-221:~ 17:19:37 # cd /usr/local/
root@prometheus-221:/usr/local 17:19:41 # ln -sv prometheus-webhook-dingtalk-2.1.0.linux-amd64 dingtalk
'dingtalk' -> 'prometheus-webhook-dingtalk-2.1.0.linux-amd64'
root@prometheus-221:/usr/local 17:20:01 # ls -l dingtalk/
total 18744
-rw-r--r-- 1 3434 3434     1299 Apr 21  2022 config.example.yml
drwxr-xr-x 4 3434 3434     4096 Apr 21  2022 contrib
-rw-r--r-- 1 3434 3434    11358 Apr 21  2022 LICENSE
-rwxr-xr-x 1 3434 3434 19172733 Apr 21  2022 prometheus-webhook-dingtalk
root@prometheus-221:/usr/local 17:20:05 # 

# 准备文件和目录
root@prometheus-221:/usr/local 17:20:05 # cd dingtalk
root@prometheus-221:/usr/local/dingtalk 17:20:28 # mkdir bin conf
root@prometheus-221:/usr/local/dingtalk 17:20:29 # mv prometheus-webhook-dingtalk bin/
root@prometheus-221:/usr/local/dingtalk 17:20:34 # cp config.example.yml conf/config.yml


# 编辑 config.yml
root@prometheus-221:/usr/local/dingtalk 17:24:25 # cat conf/config.yml| grep -Ev "#|^$"
targets:
  webhook1:
    url: https://oapi.dingtalk.com/robot/send?access_token=47b6c03464674d955ce2fcb9a6f669252b8306049c4e890224606f697cce5be1
    secret: SECf180eaf0546d7464334179287f116aac3af58c00b42e733e0b2e32d1d5a2114b
root@prometheus-221:/usr/local/dingtalk 17:24:35 #

# 尝试命令启动后，测试效果
root@prometheus-221:~ 17:27:26 # /usr/local/dingtalk/bin/prometheus-webhook-dingtalk --config.file=/usr/local/dingtalk/conf/config.yml --web.listen-address=0.0.0.0:8060

root@prometheus-221:~ 17:27:58 # ss -tnulp | egrep 'Pro|8060'
Netid State  Recv-Q Send-Q Local Address:Port Peer Address:PortProcess                                     
tcp   LISTEN 0      4096               *:8060            *:*    users:(("prometheus-webh",pid=275062,fd=3))
root@prometheus-221:~ 17:28:00 #

# 测试发送信息,注意:需要取消钉钉中安全设置中的自定义关键字,只保留加签才能成功,否则提示"Unable to talk to DingTalk"发送失败
root@prometheus-221:~ 17:41:52 # curl "http://192.168.121.221:8060/dingtalk/webhook1/send" -H 'Content-Type: application/json' -d '
> {
    "msgtype": "markdown",
    "markdown": {
        "title": "PromAlert 告警信息",
        "text": "## 问题详情 \n### 问题级别: 严重\n### 问题类型: MySQL 服务\n### 查询时间: 2025-02-22"
    }
}'
OK

~~~

#### 5.8.2.2 Alertmanager 配置

~~~yaml
root@prometheus-221:~ 17:46:30 # vim /usr/local/alertmanager/conf/alertmanager.yml
global:
 ...
# 模板配置
templates:
  - '../tmpl/*.tmpl'
# 路由配置,添加下面内容
route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 10s
  receiver: 'dingtalk'
# 收信人员
receivers:
  - name: 'dingtalk'
    webhook_configs:
      - url: 'http://192.168.121.221:8060/dingtalk/webhook1/send'
        send_resolved: true
#重启alertmanager服务
systemctl restart alertmanager
systemctl status alertmanager
#注意:当前此配置不支持钉钉中安全设置中有自定义关键字,只适用于加签
~~~

#### 5.8.2.3 定制钉钉告警模板文件

图片用于在告警模板中显示,图片可以放在自已的网站或者利用云服务(比如: 七牛云)的对象存储功能实现

##### 5.8.2.3.1 配告告警模板

~~~shell
{{ define "__subject" }}[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .GroupLabels.SortedPairs.Values | join " " }} {{ if gt (len .CommonLabels) (len .GroupLabels) }}({{ with .CommonLabels.Remove .GroupLabels.Names }}{{ .Values | join " " }}{{ end }}){{ end }}{{ end }}
{{ define "__alertmanagerURL" }}{{ .ExternalURL }}/#/alerts?receiver={{ .Receiver }}{{ end }}

{{ define "__text_alert_list" }}{{ range . }}
**Labels**
{{ range .Labels.SortedPairs }}> - {{ .Name }}: {{ .Value | markdown | html }}
{{ end }}
**Annotations**
{{ range .Annotations.SortedPairs }}> - {{ .Name }}: {{ .Value | markdown | html }}
{{ end }}
**Source:** [{{ .GeneratorURL }}]({{ .GeneratorURL }})
{{ end }}{{ end }}

{{ define "___text_alert_list" }}{{ range . }}
---
**告警主题:** {{ .Labels.alertname | upper }}
**告警级别:** {{ .Labels.severity | upper }}
**触发时间:** {{ dateInZone "2006-01-02 15:04:05" (.StartsAt) "Asia/Shanghai" }}
**事件信息:** {{ range .Annotations.SortedPairs }} {{ .Value | markdown | html }}
{{ end }}

**事件标签:**
{{ range .Labels.SortedPairs }}{{ if and (ne (.Name) "severity") (ne (.Name) "summary") (ne (.Name) "team") }}> - {{ .Name }}: {{ .Value | markdown | html }}
{{ end }}{{ end }}
{{ end }}
{{ end }}
{{ define "___text_alertresovle_list" }}{{ range . }}
---
**告警主题:** {{ .Labels.alertname | upper }}
**告警级别:** {{ .Labels.severity | upper }}
**触发时间:** {{ dateInZone "2006-01-02 15:04:05" (.StartsAt) "Asia/Shanghai" }}
**结束时间:** {{ dateInZone "2006-01-02 15:04:05" (.EndsAt) "Asia/Shanghai" }}
**事件信息:** {{ range .Annotations.SortedPairs }} {{ .Value | markdown | html }}
{{ end }}

**事件标签:**
{{ range .Labels.SortedPairs }}{{ if and (ne (.Name) "severity") (ne (.Name) "summary") (ne (.Name) "team") }}> - {{ .Name }}: {{ .Value | markdown | html }}
{{ end }}{{ end }}
{{ end }}
{{ end }}

{{/* Default */}}
{{ define "_default.title" }}{{ template "__subject" . }}{{ end }}
{{ define "_default.content" }} [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}\] **[{{ index .GroupLabels "alertname" }}]({{ template "__alertmanagerURL" . }})**
{{ if gt (len .Alerts.Firing) 0 -}}

![警报 图标](http://xxxxx)
**========PromAlert 告警触发========**
{{ template "___text_alert_list" .Alerts.Firing }}
{{- end }}

{{ if gt (len .Alerts.Resolved) 0 -}}
![恢复图标](http://xxxxx)
**========PromAlert 告警恢复========**
{{ template "___text_alertresovle_list" .Alerts.Resolved }}


{{- end }}
{{- end }}

{{/* Legacy */}}
{{ define "legacy.title" }}{{ template "__subject" . }}{{ end }}
{{ define "legacy.content" }} [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}\] **[{{ index .GroupLabels "alertname" }}]({{ template "__alertmanagerURL" . }})**
{{ template "__text_alert_list" .Alerts.Firing }}
{{- end }}

{{/* Following names for compatibility */}}
{{ define "_ding.link.title" }}{{ template "_default.title" . }}{{ end }}
{{ define "_ding.link.content" }}{{ template "_default.content" . }}{{ end }}



#模板语言解析
添加图标格式： ![警报 图标](http://fqdn/url/图片文件名)
该图片地址必须是全网都能够访问的一个地址
日期时间不要乱改，这是golang语言的时间格式
~~~

#### 5.8.2.4 应用告警模板

~~~shell
vim /usr/local/dingtalk/conf/config.yml
......
#添加下面五行
templates:
  - '/usr/local/dingtalk/contrib/templates/dingtalk.tmpl'
default_message:
  title: '{{ template "_ding.link.title" . }}'
  text: '{{ template "_ding.link.content" . }}'

#重启dingtalk服务
~~~

#### 5.8.2.5 验证测试

## 5.9 Alertmanger 高可用

### 5.9.1 负载均衡

![image-20250926180104785](Prometheus.assets/image-20250926180104785.png)

### 5.9.2 Gossip 实现

https://yunlzheng.gitbook.io/prometheus-book/part-ii-prometheus-jinjie/readmd/alertmanager-high-availability

Alertmanager引入了Gossip机制。Gossip机制为多个Alertmanager之间提供了信息传递的机制。确保及时在多个Alertmanager分别接收到相同告警信息的情况下，也只有一个告警通知被发送给Receiver。

![image-20250926180141946](Prometheus.assets/image-20250926180141946.png)

Gossip是分布式系统中被广泛使用的协议，用于实现分布式节点之间的信息交换和状态同步。Gossip协议同步状态类似于流言或者病毒的传播。

Gossip有两种实现方式分别为Push-based和Pull-based。 

在Push-based当集群中某一节点A完成一个工作后，随机的挑选其它节点B并向其发送相应的消息，节点B接收到消息后在重复完成相同的工作，直到传播到集群中的所有节点。

而Pull-based的实现中节点A会随机的向节点B发起询问是否有新的状态需要同步，如果有则返回。

搭建本地集群环境

为了能够让Alertmanager节点之间进行通讯，需要在Alertmanager启动时设置相应的参数。其中主要的参数包括：

~~~shell
--web.listen-address string      #当前实例Web监听地址和端口,默认9093
--cluster.listen-address string  #当前实例集群服务监听地址,默认9094,集群必选
--cluster.peer value             #后续集群实例在初始化时需要关联集群中的已有实例的服务地址,集群的后续节点必选
~~~

范例：在同一个主机用Alertmanager多实例实现

定义Alertmanager实例A1，其中Alertmanager的服务运行在9093端口，集群服务地址运行在8001端口。

~~~shell
alertmanager  --web.listen-address=":9093" --cluster.listen-address="127.0.0.1:8001" --config.file=/etc/prometheus/alertmanager.yml  --storage.path=/data/alertmanager/
~~~

定义Alertmanager实例A2，其中Alertmanager的服务运行在9094端口，集群服务运行在8002端口。为了将A1，A2组成集群。 A2启动时需要定义--cluster.peer参数并且指向A1实例的集群服务地址:8001

~~~shell
alertmanager  --web.listen-address=":9094" --cluster.listen-address="127.0.0.1:8002" --cluster.peer=127.0.0.1:8001 --config.file=/etc/prometheus/alertmanager.yml  --storage.path=/data/alertmanager2/
~~~



## 5.10 其他告警应用

https://github.com/feiyu563/PrometheusAlert

![image-20250926182849865](Prometheus.assets/image-20250926182849865.png)

范例: Docker 部署 prometheus alert

~~~shell
docker run -d \
-p 8080:8080 \
-e PA_LOGIN_USER=prometheusalert \
-e PA_LOGIN_PASSWORD=prometheusalert \
-e PA_TITLE=PrometheusAlert \
-e PA_OPEN_FEISHU=1 \
-e PA_OPEN_DINGDING=1 \
-e PA_OPEN_WEIXIN=1 \
feiyu563/prometheus-alert:latest

~~~

# 六、服务发现

## 6.1 服务发现原理

### 6.1.1 服务发现介绍

Prometheus Server 的数据抓取工作于Pull模型，因而，它必需要事先知道各Target的位置，然后才能从相应的 Exporter 或Instrumentation 中抓取数据。

在不同的场景下，需要结合不同的机制来实现对应的数据抓取目的。

对于小型的系统环境来说，通过 static_configs 指定各 Target 便能解决问题，这也是最简单的配置方法,我们只需要在配置文件中，将每个Targets用一个网络端点（ip:port）进行标识；

~~~yaml
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['10.0.0.101:9100']
~~~

对于中大型的系统环境或具有较强动态性的云计算环境来说，由于场景体量的因素，静态配置显然难以适用。

![image-20250928203033677](Prometheus.assets/image-20250928203033677.png)

因此，Prometheus 为此专门设计了一组服务发现机制，以便于能够基于服务注册中心自动发现、检测、分类可被监控的各 Target，以及更新发生了变动的 Target

各个节点会主动注册相关属性信息到服务注册中心，即使属性发生变动，注册中心的属性也会随之更改。

一旦节点过期了，或者失效了，服务注册中心，会周期性的方式自动将这些信息清理出去。

服务发现机制

https://prometheus.io/docs/prometheus/latest/configuration/configuration/

对于 prometheus 的服务发现机制，这里面提供了二十多种服务发现机制，常见的几种机制如下：

| 方法                   | 解析                                                         |
| ---------------------- | ------------------------------------------------------------ |
| 静态服务发现           | 在 Prometheus 配置文件中通过 static_config 项,手动添加监控的主机实现 |
| 基于文件的服务发现     | 将各 target 记录到文件中，prometheus 启动后，周期性刷新这个文件，从而获取最新的 target |
| 基于 DNS 的服务发现    | 针对一组 DNS 域名进行定期查询，以发现待监控的目标，并持续监视相关资源的变动 |
| 基于 Consul 的服务发现 | 基于 Consul 服务实现动态自动发现                             |
| 基于 HTTP 的服务发现   | 基于 HTTP 的服务发现提供了一种更通用的方式来配置静态目标，并用作插入自定义服务发现机制的接口<br />它从包含零个或多个 <static_config> 列表的 HTTP 端点获取目标。 目标必须回复 HTTP 200 响应。 HTTP header Content-Type 必须是 application/json，body 必须是有效的 JSON。 |
| 基于 API 的服务发现    | 支持将 Kubernetes API Server 中 Node、Service、Endpoint、Pod 和 Ingress 等资源类型下相应的各资源对象视作 target，并持续监视相关资源的变动。 |

### 6.1.2 服务发现原理

发现原理

![image-20250928223847293](Prometheus.assets/image-20250928223847293.png)

Prometheus服务发现机制大致涉及到三个部分：

- 配置处理模块解析的 prometheus.yml 配置中 scrape_configs 部分，将配置的job生成一个个 Discover 服务，不同的服务发现协议都会有各自的 Discoverer 实现方式，它们根据实现逻辑去发现 target，并将其放入到targets列表中
- DiscoveryManager 组件内部有一个定时周期触发任务，每5秒检查 target 列表，如果有变更则将 target 列表中 target 信息放入到 syncCh 消息池中
- scrape 组件会监听 syncCh 消息池，这样需要监控的 target 信息就传递给 scrape 组件，然后 reload 将 target 纳入监控开始抓取监控指标

配置处理部分会根据 scrape_configs 部分配置的不同协议类型生成不同 Discoverer，然后根据它们内部不同的实现逻辑去发现target，discoveryManager 组件则相当于一个搬运工，scrape 组件则是一个使用者，这两个组件都对不同服务发现协议的差异无所感知。

## 6.2 文件服务发现

### 6.2.1 文件服务发现服务说明

基于文件的服务发现是仅仅略优于静态配置的服务发现方式，它不依赖于任何平台或第三方服务，因而也是最为简单和通用的实现方式

文件发现原理

- Target 的文件可由手动创建或利用工具生成，例如Ansible或Saltstack等配置管理系统，也可能是由脚本基于CMDB定期查询生成
- 文件可使用 YAML 和 JSON 格式，它含有定义的 Target 列表，以及可选的标签信息,YAML 适合于运维场景, JSON 更适合于开发场景
- Prometheus Server 定期从文件中加载 Target 信息，根据文件内容发现相应的 Target

参考资料:

https://prometheus.io/blog/2015/06/01/advanced-service-discovery/#custom-servicediscovery

https://prometheus.io/docs/prometheus/latest/configuration/configuration/#file_sd_config

配置过程和格式

~~~yaml
#准备主机节点列表文件,可以支持yaml格式和json格式
#注意：此文件不建议就地编写生成，可能出现加载一部分的情况
cat targets/prometheus*.yaml
- targets:
    - master1:9100
  labels:
    app: prometheus
#修改prometheus配置文件自动加载实现自动发现
cat prometheus.yml
......
  - job_name: 'file_sd_prometheus'
    scrape_interval: 10s                #指定抓取数据的时间间隔,默认继取全局的配置15s
    file_sd_configs:
      - files: #指定要加载的文件列表
          - targets/prometheus*.yaml #要加载的yml或json文件路径，支持glob通配符,相对路径是相对于prometheus.yml配置文件路径
     	refresh_interval: 2m #每隔2分钟重新加载一次文件中定义的Targets，默认为5m
      
#注意：文件格式都是yaml或json格式
~~~

### 6.2.2 文件服务发现案例

#### 6.2.2.1 案例：YAML 格式

范例: 通过yaml格式的文件发现，将所有的节点都采用自动发现机制

~~~yaml
# 配置文件服务发现的文件
root@prometheus-221:/usr/local/prometheus/conf/targets 09:40:31 # cat prometheues-node.yml
- targets:
    - 192.168.121.111:9100
    - 192.168.121.112:9100
    - 192.168.121.113:9100
  labels:
    app: node-exporter
    job: node
- targets:
    - 192.168.121.221:9090
  labels:
    app: prometheus-server
    job: prometheus-server

# 配置 Prometheus 
  - job_name: "filed_sd_node_exporter"
    file_sd_configs:
      - files:
          - targets/prometheues-node.yml
        refresh_interval: 10s
root@prometheus-221:~ 09:39:16 # systemctl restart prometheus.service 
# 稍等几秒钟，到浏览器中查看监控目标
# 结果显示：所有的节点都添加完毕了，而且每个节点都有自己的标签信息
~~~

![image-20250930094045606](Prometheus.assets/image-20250930094045606.png)

~~~shell
# 后续可以自由的编辑文件，无需重启 Prometheus 服务，就可以做到自动发现的效果
root@prometheus-221:/usr/local/prometheus/conf/targets 09:43:19 # cat grafana.yml
- targets:
    - 192.168.121.221:3000
  labels:
    app: grafana
    job: grafana
root@prometheus-221:/usr/local/prometheus/conf/targets 09:45:42 #

# 配置 Prometheus
  - job_name: "filed_sd_grafana"
    file_sd_configs:
      - files:
          - targets/grafana.yml
        refresh_interval: 10s
root@prometheus-221:~ 09:45:05 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 09:45:06 # systemctl restart prometheus.service 

# 文件保存后，稍等几秒钟，会自动加载当前的配置文件里面的信息，查看一下浏览器
# 结果显示：节点的自动服务发现成功了。以后，对所有节点批量管理的时候，借助于ansible等工具，就可以非常轻松的实现
# 如果将文件中的指定的节点行删除，Prometheus也会自动将其从发现列表中删除
~~~

#### 6.2.2.2 案例：JSON 格式

可以利用工具将前面的YAML格式转换为JSON格式

~~~shell
#安装工具
yaml2json
#网站
http://www.json2yaml.com/
~~~

范例: json格式的文件发现

~~~shell
# 安装工具
root@prometheus-221:/usr/local/prometheus/conf/targets 09:47:07 # apt update && apt install -y libghc-yaml-dev jq

# yaml ---> json
root@prometheus-221:/usr/local/prometheus/conf/targets 09:51:36 # yaml2json grafana.yml  | jq > grafana.json
root@prometheus-221:/usr/local/prometheus/conf/targets 09:51:45 # cat grafana.json
[
  {
    "targets": [
      "192.168.121.221:3000"
    ],
    "labels": {
      "app": "grafana",
      "job": "grafana"
    }
  }
]
root@prometheus-221:/usr/local/prometheus/conf/targets 09:51:47 #

# 配置 Prometheus
  - job_name: "filed_sd_grafana_json"
    file_sd_configs:
      - files:
          - targets/grafana.json
        refresh_interval: 10s
root@prometheus-221:~ 09:52:57 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 09:52:59 # systemctl restart prometheus.service
~~~

![image-20250930095347837](Prometheus.assets/image-20250930095347837.png)

## 6.3 DNS 服务发现

### 6.3.1 DNS 服务发现说明

https://prometheus.io/docs/prometheus/latest/configuration/configuration/#dns_sd_config

![image-20250930095738992](Prometheus.assets/image-20250930095738992.png)

基于DNS的服务发现针对一组DNS域名进行定期查询，以发现待监控的目标

- 查询时使用的DNS服务器由 Prometheus 服务器的 /etc/resolv.conf 文件指定
- 该发现机制依赖于 A、AAAA 和 SRV 资源记录，且仅支持该类方法，尚不支持 RFC6763 中的高级 DNS 发现方式

基于DNS服务发现会自动生成的元数据标签：

~~~shell
__meta_dns_name
 the record name that produced the discovered target.
__meta_dns_srv_record_target
 the target field of the SRV record
__meta_dns_srv_record_port
 the port field of the SRV record
~~~

SRV 记录

- SRV 记录是服务器资源记录的缩写，记录服务器提供的服务，SRV记录的作用是说明一个服务器能够提供什么样的服务。
- 在 RFC2052 中才对 SRV 记录进行了定义，很多老版本的DNS服务器并不支持SRV记录。
- SRV 资源记录允许为单个域名使用多个服务器，轻松地将服务从一个主机移动到另一个主机，并将某些主机指定为服务的主服务器，将其他主机指定为备份
- 客户端要求特定域名的特定服务/协议，并获取任何可用服务器的名称

~~~shell
RFC2782中对于SRV的定义格式是：
_Service._Proto.Name TTL Class SRV Priority Weight Port Target

#格式解析：
Service 所需服务的符号名称，在Assigned Numbers或本地定义。服务标识符前面加下划线(_)，以避免与常规出现的DNS标签发生冲突。
Proto 所需协议的符号名称,该名称不区分大小写。_TCP和_UDP目前是该字段最常用的值前面加下划线_，以防止与自然界中出现的DNS标签发生冲突。
Name   此RR所指的域名。在这个域名下SRV RR是唯一的。
Class 定制DNS记录类，它主要有以下三种情况：对于涉及Internet的主机名、IP地址等DNS记录，记录的CLASS设置为IN。其他两类用的比较少，比如CS(CSNET类)、CH(CHAOS类)、HS(Hesiod)等。每个类都是一个独立的名称空间，其中DNS区域的委派可能不同。
Port 服务在目标主机上的端口。范围是0-65535。 这是网络字节顺序中的16位无符号整数。
Target 目标主机的域名。域名必须有一个或多个地址记录，域名绝不能是别名。敦促（但不强求）实现在附加数据部分中返回地址记录。值为"." 表示该域名明确无法提供该服务。
~~~

官方配置示例

~~~shell
#参考资料：https://prometheus.io/blog/2015/06/01/advanced-servicediscovery/#discovery-with-dns-srv-records
#
定制job对象
job {
 name: "api-server"
 sd_name: "telemetry.eu-west.api.srv.example.org"
 metrics_path: "/metrics"
}

#
定制解析记录
scrape_configs:
- job_name: 'myjob'
 dns_sd_configs:
  - names:
    - 'telemetry.eu-west.api.srv.example.org'
    - 'telemetry.us-west.api.srv.example.org'
    - 'telemetry.eu-west.auth.srv.example.org'
    - 'telemetry.us-east.auth.srv.example.org'
 relabel_configs:
  - source_labels: ['__meta_dns_name']
    regex:         'telemetry\.(.+?)\..+?\.srv\.example\.org'
    target_label:  'zone'
    replacement:   '$1'
  - source_labels: ['__meta_dns_name']
    regex:         'telemetry\..+?\.(.+?)\.srv\.example\.org'
    target_label:  'job'
    replacement:   '$1'
~~~

### 6.3.2 DNS 服务发现案例

#### 6.3.2.1 部署 DNS

~~~shell
# 安装软件
root@prometheus-221:~ 10:07:15 # apt install -y bind9 bind9utils bind9-doc bind9-host 
root@prometheus-221:~ 10:16:34 # named -v
BIND 9.18.39-0ubuntu0.22.04.1-Ubuntu (Extended Support Version) <id:>
root@prometheus-221:~ 10:17:44 # dpkg -L bind9 | grep named.conf
/etc/bind/named.conf
/etc/bind/named.conf.default-zones
/etc/bind/named.conf.local
/etc/bind/named.conf.options
/usr/lib/tmpfiles.d/named.conf
/usr/share/man/man5/named.conf.5.gz
root@prometheus-221:~ 10:18:15 #


# 定制正向解析 zone 的配置
root@prometheus-221:~ 10:23:48 # tail -5 /etc/bind/named.conf.default-zones
zone "lnxguru.org" {
	type master;
	file "/etc/bind/lnxguru.org.zone";
};

root@prometheus-221:~ 10:23:53 #
# 定制主域名的zone文件
#定制主域名的zone文件
vim /etc/bind/wang.org.zone
;
; BIND reverse data file for local loopback interface
;
$TTL    604800
@       IN     SOA     ns.lnxguru.org. admin.lnxguru.org. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
       IN     NS     master
master IN     A       10.0.0.100
node1   IN     A       10.0.0.101
node2   IN     A       10.0.0.102
node3   IN     A       10.0.0.103
flask   IN     A       10.0.0.101
#检查配置文件
named-checkconf
#重启dns服务
systemctl restart named
systemctl status named



# 配置 prometheus 服务器使用 DNS 域名服务器
vim /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
  eth0:
      addresses:
       - 10.0.0.101/24
      gateway4: 10.0.0.2
      nameservers:
        search: [wang.org,wang.com]
        addresses: [10.0.0.100] #只保留当前的DNS服务器地址,不要再加其它DNS服务器地址,否则DNS解析有问题
#应用网络配置
netplan apply
#确认dns解析效果
dig node1.lnxguru.org

~~~

#### 6.3.2.2 配置 DNS 服务支持 SRV 记录

~~~shell
#添加SRV记录
# vim /etc/bind/lnxguru.org.zone
... ...
node1   IN     A       10.0.0.101
node2   IN     A       10.0.0.102
node3   IN     A       10.0.0.103
flask   IN     A       10.0.0.101  #只有A记录

#添加下面的SRV记录,对应上面的三条A记录
_prometheus._tcp.wang.org. 1H IN SRV 10 10 9100 node1.lnxguru.org.
_prometheus._tcp.wang.org. 1H IN SRV 10 10 9100 node2.lnxguru.org.
_prometheus._tcp.wang.org. 1H IN SRV 10 10 9100 node3.lnxguru.org.
#检查配置文件lnxguru.org
named-checkconf
#生效
rndc reload
#测试解析
dig srv _prometheus._tcp.lnxguru.org
host -t srv _prometheus._tcp.lnxguru.org
nslookup -q=srv _prometheus._tcp.lnxguru.org
~~~

#### 6.3.2.3 配置 Prometheus 使用 DNS

~~~yaml
# vim /usr/local/prometheus/conf/prometheus.yml
... 
scrape_configs:
  - job_name: "prometheus"
   .......
    
#添加下面所有行
  - job_name: 'dns_sd_flask'             #实现单个主机定制的信息解析，也支持DNS或/etc/hosts文件实现解析
    dns_sd_configs:
      - names: ['flask.wang.org']
        type: A                            #指定记录类型，默认SRV
        port: 8000                         #不是SRV时，需要指定Port号
        refresh_interval: 10s
      
  - job_name: 'dns_sd_node_exporter'          #实现批量主机解析
    dns_sd_configs:
      - names: ['_prometheus._tcp.wang.org']    #SRV记录必须通过DNS的实现
        refresh_interval: 10s                   #指定DNS资源记录的刷新间隔,默认30s
     
#重启prometheus
promtool check config /usr/local/prometheus/conf/prometheus.yml
systemctl reload prometheus
~~~

#### 6.3.2.4 验证

#### 6.3.2.5  添加和删除 SRV 记录

~~~shell
lnxguru.org#删除node2和添加node4对应的SRV和A记录
[root@prometheus ~]#cat /etc/bind/lnxguru.org.zone
$TTL 1D
@ IN SOA master admin (
 1 ; serial
 1D ; refresh
 1H ; retry
 1W ; expire
 3H ) ; minimum
           NS   master
master         A       10.0.0.100         
node1   IN     A       10.0.0.101
node3   IN     A       10.0.0.103
node4   IN     A       10.0.0.104  #修改
flask   IN     A       10.0.0.101
_prometheus._tcp.wang.org. 1H IN SRV 10 10 9100 node1.lnxguru.org.
_prometheus._tcp.wang.org. 1H IN SRV 10 10 9100 node3.lnxguru.org.
_prometheus._tcp.wang.org. 1H IN SRV 10 10 9100 node4.lnxguru.org. #修改
#注意:Ubuntu有DNS缓存,需要清除才能生效
[root@prometheus ~]#rndc reload && netplan apply 
server reload successful
#确认结果
[root@prometheus ~]#host -t srv _prometheus._tcp.wang.org
_prometheus._tcp.wang.org has SRV record 10 10 9100 node1.lnxguru.org.
_prometheus._tcp.wang.org has SRV record 10 10 9100 node3.lnxguru.org.
_prometheus._tcp.wang.org has SRV record 10 10 9100 node4.lnxguru.org.
~~~

## 6.4 Consul 服务发现

### 6.4.1 Cousul 服务介绍

![image-20251004233139685](Prometheus.assets/image-20251004233139685.png)

单体架构逐渐被微服务架构所替代，原本不同功能模被拆分成了多个不同的服务。

原本模块间的通信只需要函数调用就能够实现，现在却做不到了，因为它们不在同一个进程中，甚至服务都可能部署到不同的机房。

![image-20251004233232159](Prometheus.assets/image-20251004233232159.png)

服务间的通信成为了迈向微服务大门的第一道难关：

- ServiceA 如何知道 ServiceB 在哪里
- ServiceB 可能会有多个副本提供服务，其中有些可能会挂掉，如何避免访问到"不健康的"的ServiceB
- 如何控制只有 ServiceA 可以访问到 ServiceB

Consul 是HashiCorp 公司开发的一种服务网格解决方案，使团队能够管理服务之间以及跨本地和多云环境和运行时的安全网络连接。

Consul 提供服务发现、服务网格、流量管理和网络基础设施设备的自动更新

Consul是一个用来实现分布式系统的服务发现与配置的开源工具

Consul采用golang开发

Consul具有高可用和横向扩展特性。

Consul的一致性协议采用更流行的Raft 算法（Paxos的简单版本），用来保证服务的高可用

Consul 使用 GOSSIP 协议（P2P的分布式协议去中心化结构下，通过将信息部分传递，达到全集群的状态信息传播,和 Raft 目标是强一致性不同，Gossip 达到的是最终一致性）管理成员和广播消息, 并且支持 ACL 访问控制

Consul自带一个Web UI管理系统， 可以通过参数启动并在浏览器中直接查看信息。

Consul 提供了一个控制平面，使您能够注册、查询和保护跨网络部署的服务。控制平面是网络基础结构的一部分，它维护一个中央注册表来跟踪服务及其各自的 IP 地址。它是一个分布式系统，在节点集群上运行，例如物理服务器、云实例、虚拟机或容器。

Consul 关键特性：

- service discovery：consul通过DNS或者HTTP接口实现服务注册和服务发现
- health checking：健康检测使consul可以快速的告警在集群中的操作。和服务发现的集成，可以防止服务转发到故障的服务上面。
- key/value storage：一个用来存储动态配置的系统。提供简单的HTTP接口，可以在任何地方操作
- multi-datacenter：无需复杂的配置，即可支持任意数量的区域

官网:

https://www.consul.io/

帮助文档

https://developer.hashicorp.com/consul/docs

**Consul 的工作原理：**

![image-20251004233731337](Prometheus.assets/image-20251004233731337.png)

- Agent 是一直运行在 Consul 集群中每个成员上的守护进程。通过运行 consul agent 来启动。

  Agent可以运行在 client 或者 server 模式。指定节点作为 client 或者 server 是非常简单的，除非有其他 agent 实例。

  所有的 Agent 都能运行 DNS 或者 HTTP 接口，并负责运行时检查和保持服务同步。

- Client 是一个转发所有 RPC 到 server 的代理。这个 client 是相对无状态的。client 唯一执行的后台活动是加入 LAN.

- Server 是一个有一组扩展功能的代理，这些功能包括参与 Raft 选举，维护集群状态，响应 RPC 查询，与其他数据中心交互 WANgossip 和转发查询给 leader 或者远程数据中心。

- Datacenter 数据中心为私有、低延迟和高带宽的网络环境。这不包括通过公共 Internet 进行的通信

- Gossip：consul 是建立在 Serf (一个去中心化的服务发现和编排的解决方案，特点是轻量级和高可用，同时具备容错的特性)之上的，它提供了一个完整的 gossip 协议，用在很多地方。Serf 提供了成员，故障检测和事件广播。Gossip 的节点到节点之间的通信使用了UDP协议。gossip 属于 p2p 协 议,主要功能是去中心化。Gossip 协议就是模拟人类中传播谣言的行为而来。首先要传播谣言就要有种子节点。种子节点每秒都会随机向其他节点发送自己所拥有的节点列表，以及需要传播的消息。任何新加入的节点，就在这种传播方式下很快地被全网所知道。

- LAN Gossip：指在同一局域网或数据中心的节点上的 LAN Gossip 池。

- WAN Gossip：指包含服务器的 WAN Gossip 池，这些服务器在不同的数据中心，通过网络进行通信。

上面显示的两个数据中心，分别标注为 DATACENTER1 和 DATACENTER2，Consul 对多数据中心有非常友好的支持。在两个数据中心分别布署有许多 SERVER 和 CLIENT 节点，节点之间通过 GOSSIP 流行病协议通信，每个节点有两个 GOSSIP 池（LAN 池和 WAN 池），LAN 池用于数据中心内部通讯，WAN 池则对所有数据中心共享，用于跨数据中心通讯。

**关于 SERVER 和 CLIENT 节点**

Consul 规定了所有的节点一律称为 Agent，SERVER 和 CLIENT 分别是 Agent 的两个模式。

在 CLIENT 模式下，Agent 不保存数据，主要面向服务提供者和服务消费者， 提供服务注册、服务查询、健康检测等功能。

在 SERVER 模式下，Agent 除了支持 CLIENT 的所有功能外，还负责节点主从选举、数据存储，并维护数据一致性。

通常在单个数据中心，SERVER 的布署数量在3~5个，而 CLIENT 节点，要求在除布署 SERVER 的机器外，每台都布署 CLIENT。

关于多数据中心，通常情况下，不同的数据中心之间是不会同步数据的，但是当对另一个数据中心的资源进行请求时，本地 SERVER 会将该资源的 RPC 请求转发给 SERVER，并返回结果。

**Prometheus 基于的 Consul 服务发现过程**

- 安装并启动 Consul 服务
- 在Prometheus的配置中关联 Consul服务发现
- 新增服务节点向 Consul 进行注册
- Prometheus 自动添加新增的服务节点的 Target

### 6.4.2 Consul 部署

#### 6.4.2.1 Consul 单机部署

说明

https://developer.hashicorp.com/consul/docs/agent/config

##### 6.4.2.1.1 包安装 Consul

官方安装

https://developer.hashicorp.com/consul/tutorials/production-deploy/deployment-guide

范例: Ubuntu 包安装 Consul

~~~shell
# Ubuntu2204内置consul源，直接安装
root@ubuntu2204:~ 15:46:31 # apt list consul
Listing... Done
consul/jammy 1.8.7+dfsg1-3 amd64
root@ubuntu2204:~ 15:46:40 # 

# 配置 Ubuntu 安装源
root@ubuntu2204:~ 15:46:40 # curl --fail --silent --show-error --location https://apt.releases.hashicorp.com/gpg | \
      gpg --dearmor | \
      sudo dd of=/usr/share/keyrings/hashicorp-archive-keyring.gpg
root@ubuntu2204:~ 15:47:27 # echo "deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
 sudo tee -a /etc/apt/sources.list.d/hashicorp.list
root@ubuntu2204:~ 15:47:48 # sudo apt-get update


# 查看 Consul 版本
root@ubuntu2204:~ 15:49:54 # apt-cache policy consul
consul:
  Installed: (none)
  Candidate: 1.21.5-1
  Version table:
     1.21.5-1 500
        500 https://apt.releases.hashicorp.com jammy/main amd64 Packages
     1.21.4-1 500
        500 https://apt.releases.hashicorp.com jammy/main amd64 Packages
     1.21.3-1 500
        500 https://apt.releases.hashicorp.com jammy/main amd64 Packages
     1.21.2-1 500
        500 https://apt.releases.hashicorp.com jammy/main amd64 Packages
....
root@ubuntu2204:~ 15:49:57 # apt-cache madison consul
    consul |   1.21.5-1 | https://apt.releases.hashicorp.com jammy/main amd64 Packages
    consul |   1.21.4-1 | https://apt.releases.hashicorp.com jammy/main amd64 Packages
    consul |   1.21.3-1 | https://apt.releases.hashicorp.com jammy/main amd64 Packages
    consul |   1.21.2-1 | https://apt.releases.hashicorp.com jammy/main amd64 Packages
    consul |   1.21.1-1 | https://apt.releases.hashicorp.com jammy/main amd64 Packages
    consul |   1.21.0-1 | https://apt.releases.hashicorp.com jammy/main amd64 Packages
    consul |   1.20.6-1 | https://apt.releases.hashicorp.com jammy/main amd64 Packages
....
#安装指定版本
root@ubuntu2204:~ 15:49:57 # apt -y install consul=1.8.3
#安装最新版
root@ubuntu2204:~ 15:49:57 # apt -y install consul

# 验证安装
root@ubuntu2204:~ 15:52:39 # consul version
Consul v1.21.5
Revision 3261d11a
Build Date 2025-09-21T15:22:53Z
Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)

root@ubuntu2204:~ 15:52:45 # 
root@ubuntu2204:~ 15:52:45 # dpkg -L consul
/etc
/etc/consul.d
/etc/consul.d/consul.env
/etc/consul.d/consul.hcl
/usr
/usr/bin
/usr/bin/consul
/usr/lib
/usr/lib/systemd
/usr/lib/systemd/system
/usr/lib/systemd/system/consul.service
/usr/share
/usr/share/doc
/usr/share/doc/consul
/usr/share/doc/consul/LICENSE.txt
root@ubuntu2204:~ 15:52:59 #

root@ubuntu2204:~ 15:52:59 # file /usr/bin/consul
/usr/bin/consul: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, BuildID[sha1]=9572df6aa96071718ccd29d2650d8cf37c3b188d, with debug_info, not stripped
root@ubuntu2204:~ 15:53:17 # ldd /usr/bin/consul
	not a dynamic executable
# 不是动态可执行文件
root@ubuntu2204:~ 15:53:24 # 
root@ubuntu2204:~ 15:53:24 # cat /usr/lib/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://developer.hashicorp.com/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=notify
EnvironmentFile=-/etc/consul.d/consul.env
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

root@ubuntu2204:~ 15:53:56 #
root@ubuntu2204:~ 15:53:56 # cat /etc/consul.d/consul.env
root@ubuntu2204:~ 15:54:12 # cat /etc/consul.d/consul.hcl 
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

# Full configuration options can be found at https://developer.hashicorp.com/docs/agent/config

# datacenter
# This flag controls the datacenter in which the agent is running. If not provided,
# it defaults to "dc1". Consul has first-class support for multiple datacenters, but 
# it relies on proper configuration. Nodes in the same datacenter should be on a 
# single LAN.
#datacenter = "my-dc-1"

# data_dir
# This flag provides a data directory for the agent to store state. This is required
# for all agents. The directory should be durable across reboots. This is especially
# critical for agents that are running in server mode as they must be able to persist
# cluster state. Additionally, the directory must support the use of filesystem
# locking, meaning some types of mounted folders (e.g. VirtualBox shared folders) may
# not be suitable.
data_dir = "/opt/consul"

# client_addr
# The address to which Consul will bind client interfaces, including the HTTP and DNS
# servers. By default, this is "127.0.0.1", allowing only loopback connections. In
# Consul 1.0 and later this can be set to a space-separated list of addresses to bind
# to, or a go-sockaddr template that can potentially resolve to multiple addresses.
#client_addr = "0.0.0.0"

# ui
# Enables the built-in web UI server and the required HTTP routes. This eliminates
# the need to maintain the Consul web UI files separately from the binary.
# Version 1.10 deprecated ui=true in favor of ui_config.enabled=true
#ui_config{
#  enabled = true
#}

# server
# This flag is used to control if an agent is in server or client mode. When provided,
# an agent will act as a Consul server. Each Consul cluster must have at least one
# server and ideally no more than 5 per datacenter. All servers participate in the Raft
# consensus algorithm to ensure that transactions occur in a consistent, linearizable
# manner. Transactions modify cluster state, which is maintained on all server nodes to
# ensure availability in the case of node failure. Server nodes also participate in a
# WAN gossip pool with server nodes in other datacenters. Servers act as gateways to
# other datacenters and forward traffic as appropriate.
#server = true

# Bind addr
# You may use IPv4 or IPv6 but if you have multiple interfaces you must be explicit.
#bind_addr = "[::]" # Listen on all IPv6
#bind_addr = "0.0.0.0" # Listen on all IPv4
#
# Advertise addr - if you want to point clients to a different address than bind or LB.
#advertise_addr = "127.0.0.1"

# Enterprise License
# As of 1.10, Enterprise requires a license_path and does not have a short trial.
#license_path = "/etc/consul.d/consul.hclic"

# bootstrap_expect
# This flag provides the number of expected servers in the datacenter. Either this value
# should not be provided or the value must agree with other servers in the cluster. When
# provided, Consul waits until the specified number of servers are available and then
# bootstraps the cluster. This allows an initial leader to be elected automatically.
# This cannot be used in conjunction with the legacy -bootstrap flag. This flag requires
# -server mode.
#bootstrap_expect=3

# encrypt
# Specifies the secret key to use for encryption of Consul network traffic. This key must
# be 32-bytes that are Base64-encoded. The easiest way to create an encryption key is to
# use consul keygen. All nodes within a cluster must share the same encryption key to
# communicate. The provided key is automatically persisted to the data directory and loaded
# automatically whenever the agent is restarted. This means that to encrypt Consul's gossip
# protocol, this option only needs to be provided once on each agent's initial startup
# sequence. If it is provided after Consul has been initialized with an encryption key,
# then the provided key is ignored and a warning will be displayed.
#encrypt = "..."

# retry_join
# Similar to -join but allows retrying a join until it is successful. Once it joins 
# successfully to a member in a list of members it will never attempt to join again.
# Agents will then solely maintain their membership via gossip. This is useful for
# cases where you know the address will eventually be available. This option can be
# specified multiple times to specify multiple agents to join. The value can contain
# IPv4, IPv6, or DNS addresses. In Consul 1.1.0 and later this can be set to a go-sockaddr
# template. If Consul is running on the non-default Serf LAN port, this must be specified
# as well. IPv6 must use the "bracketed" syntax. If multiple values are given, they are
# tried and retried in the order listed until the first succeeds. Here are some examples:
#retry_join = ["consul.domain.internal"]
#retry_join = ["10.0.4.67"]
#retry_join = ["[::1]:8301"]
#retry_join = ["consul.domain.internal", "10.0.4.67"]
# Cloud Auto-join examples:
# More details - https://developer.hashicorp.com/docs/agent/cloud-auto-join
#retry_join = ["provider=aws tag_key=... tag_value=..."]
#retry_join = ["provider=azure tag_name=... tag_value=... tenant_id=... client_id=... subscription_id=... secret_access_key=..."]
#retry_join = ["provider=gce project_name=... tag_value=..."]
 
root@ubuntu2204:~ 15:54:19 #
root@ubuntu2204:~ 15:54:19 # systemctl enable --now consul.service && systemctl status consul.service 

root@ubuntu2204:~ 15:56:44 # ss -ntlup|grep consul
/udp   UNCONN 0      0          127.0.0.1:8600      0.0.0.0:*    users:(("consul",pid=3418,fd=10))        
udp   UNCONN 0      0                  *:8301            *:*    users:(("consul",pid=3418,fd=9))         
tcp   LISTEN 0      4096       127.0.0.1:8600      0.0.0.0:*    users:(("consul",pid=3418,fd=11))        
tcp   LISTEN 0      4096       127.0.0.1:8500      0.0.0.0:*    users:(("consul",pid=3418,fd=12))        
tcp   LISTEN 0      4096               *:8301            *:*    users:(("consul",pid=3418,fd=8))         
root@ubuntu2204:~ 15:57:17 # 
# 8500 http 端口，用于 http 接口和 web ui
# 8300 server rpc 端口，同一数据中心 consul server 之间通过该端口通信
# 8301 serf lan 端口，同一数据中心 consul client 通过该端口通信
# 8302 serf wan 端口，不同数据中心 consul server 通过该端口通信
# 8600 dns 端口，用于服务发现
~~~

##### 6.4.2.1.2 二进制安装 Consul

下载链接

https://releases.hashicorp.com/consul/

~~~shell
# 获取安装包
root@ubuntu2204:~ 16:00:13 # wget https://releases.hashicorp.com/consul/1.21.5/consul_1.21.5_linux_amd64.zip
root@ubuntu2204:~ 16:05:48 # unzip consul_1.21.5_linux_amd64.zip -d /usr/local/bin/
Archive:  consul_1.21.5_linux_amd64.zip
  inflating: /usr/local/bin/LICENSE.txt  
  inflating: /usr/local/bin/consul 
root@ubuntu2204:~ 16:06:08 # file /usr/local/bin/consul 
/usr/local/bin/consul: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, BuildID[sha1]=9572df6aa96071718ccd29d2650d8cf37c3b188d, with debug_info, not stripped
root@ubuntu2204:~ 16:06:23 # ldd /usr/local/bin/consul
	not a dynamic executable
root@ubuntu2204:~ 16:06:25 #
root@ubuntu2204:~ 16:07:53 # consul version
Consul v1.21.5
Revision 3261d11a
Build Date 2025-09-21T15:22:53Z
Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)

# 查看consul帮助
root@ubuntu2204:~ 16:08:03 # consul  
Usage: consul [--version] [--help] <command> [<args>]

Available commands are:
    acl             Interact with Consul's ACLs
    agent           Runs a Consul agent
    catalog         Interact with the catalog
    config          Interact with Consul's Centralized Configurations
    connect         Interact with Consul Connect
    debug           Records a debugging archive for operators
    event           Fire a new event
    exec            Executes a command on Consul nodes
    force-leave     Forces a member of the cluster to enter the "left" state
    info            Provides debugging information for operators.
    intention       Interact with Connect service intentions
    join            Tell Consul agent to join cluster
    keygen          Generates a new encryption key
    keyring         Manages gossip layer encryption keys
    kv              Interact with the key-value store
    leave           Gracefully leaves the Consul cluster and shuts down
    lock            Execute a command holding a lock
    login           Login to Consul using an auth method
    logout          Destroy a Consul token created with login
    maint           Controls node or service maintenance mode
    members         Lists the members of a Consul cluster
    monitor         Stream logs from a Consul agent
    operator        Provides cluster-level tools for Consul operators
    peering         Create and manage peering connections between Consul clusters
    reload          Triggers the agent to reload configuration files
    resource        Interact with Consul's resources
    rtt             Estimates network round trip time between nodes
    services        Interact with services
    snapshot        Saves, restores and inspects snapshots of Consul server state
    tls             Builtin helpers for creating CAs and certificates
    troubleshoot    CLI tools for troubleshooting Consul service mesh
    validate        Validate config files/directories
    version         Prints the Consul version
    watch           Watch for changes in Consul
# 实现 consul 命令自动补全
root@ubuntu2204:~ 16:08:25 # consul -autocomplete-install
# 重新登录终端生效
root@ubuntu2204:~ 16:09:21 # consul 
acl           debug         intention     leave         members       resource      troubleshoot  
agent         event         join          lock          monitor       rtt           validate      
catalog       exec          keygen        login         operator      services      version       
config        force-leave   keyring       logout        peering       snapshot      watch         
connect       info          kv            maint         reload        tls  

# 创建启动用户
root@ubuntu2204:~ 16:10:07 # useradd -s /sbin/nologin consul
root@ubuntu2204:~ 16:10:08 # mkdir -p /data/consul /etc/consul.d
root@ubuntu2204:~ 16:10:48 # chown -R consul.consul /data/consul /etc/consul.d

# 以 server 模式启动
root@ubuntu2204:~ 16:10:53 # /usr/local/bin/consul agent -server -ui -bootstrap-expect=1 -data-dir=/data/consul -node=consul -client=0.0.0.0 -config-dir=/etc/consul.d
-server  #定义agent运行在server模式
-bootstrap-expect #在一个datacenter中期望提供的server节点数目，当该值提供的时候，consul一直等到达到指定sever数目的时候才会引导整个集群，该标记不能和bootstrap共用
-bind：#该地址用来在集群内部的通讯，集群内的所有节点到地址都必须是可达的，默认是0.0.0.0
-node：#节点在集群中的名称，在一个集群中必须是唯一的，默认是该节点的主机名
-ui    #提供web ui的http功能
-rejoin #使consul忽略先前的离开，在再次启动后仍旧尝试加入集群中。
-config-dir #配置文件目录，里面所有以.json结尾的文件都会被加载
-client  # #consul服务侦听地址，这个地址提供HTTP、DNS、RPC等服务，默认是127.0.0.1，要对外提供服务改成0.0.0.0

# 创建service文件
root@ubuntu2204:~ 16:15:28 # cat /lib/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -server -bind=192.168.121.220 -ui -bootstrap-expect=1 -data-dir=/data/consul -node=consul -client=0.0.0.0 -config-dir=/etc/consul.d
#ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
root@ubuntu2204:~ 16:18:30 #
root@ubuntu2204:~ 16:18:30 # systemctl daemon-reload 
root@ubuntu2204:~ 16:18:30 # systemctl enable --now consul.service
root@ubuntu2204:~ 16:18:30 # systemctl status consul.service 
● consul.service - "HashiCorp Consul - A service mesh solution"
     Loaded: loaded (/lib/systemd/system/consul.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2025-10-05 16:18:32 CST; 179ms ago
       Docs: https://www.consul.io/
   Main PID: 4584 (consul)
      Tasks: 8 (limit: 4514)
     Memory: 15.2M
        CPU: 219ms
     CGroup: /system.slice/consul.service
             └─4584 /usr/local/bin/consul agent -server -bind=192.168.121.220 -ui -bootstrap-expect=1 -data-dir=/data/>

Oct 05 16:18:32 ubuntu2204 systemd[1]: Started "HashiCorp Consul - A service mesh solution".

# 浏览器访问测试
~~~

![image-20251005174220594](Prometheus.assets/image-20251005174220594.png)

范例: 一键安装脚本

~~~shell
#!/bin/bash
#
#********************************************************************
#Author:            wangxiaochun
#FileName:          install_consul.sh
#********************************************************************

#支持在线和离线下载安装

CONSUL_VERSION=1.18.0
#CONSUL_VERSION=1.15.0
#CONSUL_VERSION=1.13.3
#CONSUL_VERSION=1.10.2
CONSUL_FILE=consul_${CONSUL_VERSION}_linux_amd64.zip
CONSUL_URL=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/${CONSUL_FILE}

CONSUL_DATA=/data/consul

LOCAL_IP=`hostname -I|awk '{print $1}'`


msg_error() {
  echo -e "\033[1;31m$1\033[0m"
}

msg_info() {
  echo -e "\033[1;32m$1\033[0m"
}

msg_warn() {
  echo -e "\033[1;33m$1\033[0m"
}

color () {

    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "    
    elif [ $2 = "failure" -o $2 = "1"  ] ;then 
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo 

}

install_consul () {

    if [ ! -f  ${CONSUL_FILE} ] ;then
        wget  ${CONSUL_URL}  ||  { color "下载失败!" 1 ; exit ; }
    fi

    unzip ${CONSUL_FILE} -d /usr/local/bin/

    useradd -s /sbin/nologin consul

    mkdir -p ${CONSUL_DATA} /etc/consul.d

    chown -R consul.consul ${CONSUL_DATA} /etc/consul.d

}

service_consul () {

cat <<EOF > /lib/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -server -ui -bootstrap-expect=1 -data-dir=${CONSUL_DATA} -node=consul -bind=${LOCAL_IP} -client=0.0.0.0 -config-dir=/etc/consul.d
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now consul.service

}


start_consul() { 

    systemctl is-active consul

    if [ $?  -eq 0 ];then  
        echo 
        color "Consul 安装完成!" 0
        echo "-------------------------------------------------------------------"
        echo -e "访问链接: \c"
        msg_info "http://${LOCAL_IP}:8500/" 
    else
        color "Consul 安装失败!" 1
        exit
    fi 
}



install_consul

service_consul

start_consul


~~~

##### 6.4.2.1.3 Docker 启动 Consul

~~~shell
docker pull consul # 默认拉取latest
docker pull consul:1.6.1 # 拉取指定版本
docker run -d -p 8500:8500 --restart=always --name=consul consul:latest agent -server                  -bind=192.168.121.220 -client=0.0.0.0 -bootstrap-expect=1  -ui

#相关参数
–net=host   #docker参数, 使得docker容器越过了netnamespace的隔离，免去手动指定端口映射的步骤
-server     #consul支持以server或client的模式运行, server是服务发现模块的核心, client主要用于转发请求
-advertise  #将本机私有IP传递到consul
-bootstrap-expect #指定consul将等待几个节点连通，成为一个完整的集群
-retry-join #指定要加入的consul节点地址，失败会重试, 可多次指定不同的地址
-bind       #该地址用来在集群内部的通讯，集群内的所有节点到地址都必须是可达的，默认是0.0.0.0,有多个IP需要手动指定,否则会出错
-client     #设置客户端访问的监听地址,此地址提供HTTP、DNS、RPC等服务，默认是127.0.0.1, 0.0.0.0 表示任何地址可以访问
--name      #DOCKER容器的名称
-ui         #提供图形化的界面
~~~

#### 6.4.2.2 部署 Cousul 集群

##### 6.4.2.2.1 Consul 集群说明

帮助

https://developer.hashicorp.com/consul/docs/agent/config/config-files

https://developer.hashicorp.com/consul/docs/agent/config/cli-flags

集群架构说明

https://developer.hashicorp.com/consul/docs/install/glossary

**Consul 集群架构**

![image-20251009194836860](Prometheus.assets/image-20251009194836860.png)

Server 是 consul 服务端高可用集群，Client 是 consul 客户端。

consul 客户端不保存数据，客户端将接收到的请求转发给响应的 Server 端。

Server 之间通过局域网或广域网通信实现数据一致性。

每个 Server 或 Client 都是一个 consul agent。

Consul 集群节点之间使用了 GOSSIP 协议通信和 raft 一致性算法。

**Consul** **集群中的每个** **Agent** **生命周期**

https://developer.hashicorp.com/consul/docs/agent

- Agent 可以手动启动，也可以通过自动化或程序化过程启动。 新启动的 Agent 不知道集群中的其他节点。
- Agent 加入集群，使 Agent 能够发现 Agent 对等点。 当发出加入命令或根据自动加入配置时，Agent 会在启动时加入集群。
- 有关 Agent 的信息被传递到整个集群。 结果，所有节点最终都会相互了解。
- 如果 Agent 是 Server，现有服务器将开始复制到新节点。

##### 6.4.2.2.2 Consul 部署

###### 6.4.2.2.2.1 二进制部署 Consul 集群

官方说明

https://developer.hashicorp.com/consul/docs/agent/config/cli-flags

Consul agent 选项说明

~~~shell
-server    #使用server 模式运行consul 服务,consul支持以server或client的模式运行, server是服务发现模块的核心, client主要用于转发请求
-bootstrap #首次部署使用初始化模式
-bostrap-expect 2 #集群至少两台服务器，才能选举集群leader,默认值为3
-bind #该地址用来在集群内部的通讯，集群内的所有节点到地址都必须是可达的，默认是0.0.0.0,有多个IP需要手动指定,否则可能会出错
-client #设置客户端访问的监听地址,此地址提供HTTP、DNS、RPC等服务，默认是127.0.0.1
-data-dir #指定数据保存路径
-ui #运行 web 控制台,监听8500/tcp端口
-node #此节点的名称,群集中必须唯一
-datacenter=dc1 #数据中心名称，默认是dc1
-retry-join #指定要加入的consul节点地址，失败会重试, 可多次指定不同的地址,代替旧版本中的-join选项
~~~

范例

~~~shell
node 1
consul agent -bind=192.168.121.111 -client=0.0.0.0 -data-dir=/data/consul -node=node1 -ui -server      -bootstrap

node 2
    consul agent -bind=192.168.121.112 -client=0.0.0.0 -data-dir=/data/consul -node=node2 -retry-join=192.168.121.111 -ui -server -bootstrap-expect 2

node 3
consul agent -bind=192.168.121.113 -client=0.0.0.0 -data-dir=/data/consul -node=node3 -retry-join=192.168.121.111 -ui -server -bootstrap-expect 2
~~~

![image-20251010114305400](Prometheus.assets/image-20251010114305400.png)

###### 6.4.2.2.2.2 基于 Docker-compose 部署 Consul 集群

~~~yaml
[root@ubuntu2204 ~]#apt -y install docker-compose
[root@ubuntu2204 ~]#docker-compose -v
docker-compose version 1.29.2, build unknown
[root@ubuntu2204 ~]#mkdir -p /data/consul/
[root@ubuntu2204 ~]#cat > /data/consul/docker-compose.yaml << EOF
version: '2'
networks:
  consul:
services:
  consul1:
    image: consul:1.13.3
    container_name: node1
    volumes: 
      - /data/consul/conf_with_acl:/consul/config
    command: agent -server -ui -bootstrap-expect=2 -node=node1 -bind=0.0.0.0 -client=0.0.0.0 -config-dir=/consul/config
    ports:
      - 8500:8500
    networks:
      - consul
  consul2:
    image: consul:1.13.3
    container_name: node2
    volumes:
      - /data/consul/conf_with_acl:/consul/config
    command: agent -server -retry-join=node1 -node=node2 -bind=0.0.0.0 -client=0.0.0.0 -config-dir=/consul/config
    depends_on:
      - consul1
    networks:
      - consul
  consul3:
    image: consul:1.13.3
    volumes:
      - /data/consul/conf_with_acl:/consul/config
    container_name: node3
    command: agent -server -retry-join=node1 -node=node3 -bind=0.0.0.0 -client=0.0.0.0 -config-dir=/consul/config
    depends_on:
      - consul1
    networks:
      - consul
EOF
[root@ubuntu2204 ~]#cd /data/consul/
[root@ubuntu2204 ~]#docker-compose up -d
~~~

##### 6.4.2.2.3 Consul 集群管理

###### 6.4.2.2.3.1 查看集群成员

`consul members Node`

~~~shell
root@node1-111:~ 11:47:28 # consul members Node
Node   Address               Status  Type    Build   Protocol  DC   Partition  Segment
node1  192.168.121.111:8301  alive   server  1.21.5  2         dc1  default    <all>
node2  192.168.121.112:8301  alive   server  1.21.5  2         dc1  default    <all>
node3  192.168.121.113:8301  alive   server  1.21.5  2         dc1  default    <all>
root@node1-111:~ 11:47:36 #
~~~

` localhost:8500/v1/catalog/nodes`

~~~json
root@node1-111:~ 11:49:22 # curl localhost:8500/v1/catalog/nodes -s | jq
[
  {
    "ID": "e367b201-82d7-1751-50a8-ecd64f7d11e8",
    "Node": "node1",
    "Address": "192.168.121.111",
    "Datacenter": "dc1",
    "TaggedAddresses": {
      "lan": "192.168.121.111",
      "lan_ipv4": "192.168.121.111",
      "wan": "192.168.121.111",
      "wan_ipv4": "192.168.121.111"
    },
    "Meta": {
      "consul-network-segment": "",
      "consul-version": "1.21.5"
    },
    "CreateIndex": 13,
    "ModifyIndex": 14
  },
  {
    "ID": "764ac72b-f66b-762a-95f8-9c0ecd599281",
    "Node": "node2",
    "Address": "192.168.121.112",
    "Datacenter": "dc1",
    "TaggedAddresses": {
      "lan": "192.168.121.112",
      "lan_ipv4": "192.168.121.112",
      "wan": "192.168.121.112",
      "wan_ipv4": "192.168.121.112"
    },
    "Meta": {
      "consul-network-segment": "",
      "consul-version": "1.21.5"
    },
    "CreateIndex": 19,
    "ModifyIndex": 22
  },
  {
    "ID": "786930b1-5f28-2eb3-2812-8245e277aba1",
    "Node": "node3",
    "Address": "192.168.121.113",
    "Datacenter": "dc1",
    "TaggedAddresses": {
      "lan": "192.168.121.113",
      "lan_ipv4": "192.168.121.113",
      "wan": "192.168.121.113",
      "wan_ipv4": "192.168.121.113"
    },
    "Meta": {
      "consul-network-segment": "",
      "consul-version": "1.21.5"
    },
    "CreateIndex": 24,
    "ModifyIndex": 27
  }
]

~~~

###### 6.4.2.2.3.2 在 server 上添加其他 agent

~~~shell
consul join [options] address ...
~~~

###### 6.4.2.2.3.3 在 agent 主机上，该 agent 离开集群则关闭 agent

~~~shell
consul leave
~~~

#####  6.4.2.2.4 Consul 集群测试

###### 6.4.2.2.4.1 向集群中注册服务

~~~shell
root@prometheus-221:~ 11:53:20 # curl -X PUT -d '{"id": "myservice-id","name": "myservice-112","address": "192.168.121.112","port": 9100,"tags": ["service"],"checks": [{"http": "http://192.168.121.112:9100/","interval": "5s"}]}' http://192.168.121.111:8500/v1/agent/service/register

# 集群中每一台 consul 都会有信息
~~~

![image-20251010115620867](Prometheus.assets/image-20251010115620867.png)

![image-20251010115636172](Prometheus.assets/image-20251010115636172.png)

![image-20251010115652564](Prometheus.assets/image-20251010115652564.png)

###### 6.4.2.2.4.2 测试停止一台 consul 其他 consul 服务器可以正常访问

~~~shell
# 停止 leader consul
# 集群会重新选举 leader
~~~

![image-20251010115847997](Prometheus.assets/image-20251010115847997.png)

###### 6.4.2.2.4.3 Prometheus 对接 consul cluster

~~~yaml
root@prometheus-221:~ 12:01:04 # tail -17 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "Consul_sd"
    honor_labels: true
    consul_sd_configs:
      - server: 192.168.121.111:8500
        services: []
      - server: 192.168.121.112:8500
      - server: 192.168.121.113:8500
    relabel_configs:
      - source_labels: ['__meta_consul_service'] #生成新的标签名
        target_label: 'consul_service'
      - source_labels: ['__meta_consul_dc']
        target_label: 'datacenter'
      - source_labels: ['__meta_consul_tags']
        target_label: 'app'
      - source_labels: ['__meta_consul_service']
        regex: "consul"
        action: drop
root@prometheus-221:~ 12:01:07 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 12:01:18 #
~~~

![image-20251010120245152](Prometheus.assets/image-20251010120245152.png)

### 6.4.3 Consul 自动注册和删除服务

#### 6.4.3.1 Consul 常用 API 接口

https://developer.hashicorp.com/consul/api-docs

~~~shell
#列出数据中心
curl http://192.168.121.220:8500/v1/catalog/datacenters
root@ubuntu2204:~ 16:50:09 # curl http://192.168.121.220:8500/v1/catalog/datacenters
["dc1"]
#列出节点
curl http://192.168.121.220:8500/v1/catalog/nodes
root@ubuntu2204:~ 17:50:02 # curl -s  http://192.168.121.220:8500/v1/catalog/nodes | jq
[
  {
    "ID": "4bf6f30b-a6e2-9399-ec35-de7df660b4fa",
    "Node": "consul",
    "Address": "192.168.121.220",
    "Datacenter": "dc1",
    "TaggedAddresses": {
      "lan": "192.168.121.220",
      "lan_ipv4": "192.168.121.220",
      "wan": "192.168.121.220",
      "wan_ipv4": "192.168.121.220"
    },
    "Meta": {
      "consul-network-segment": "",
      "consul-version": "1.21.5"
    },
    "CreateIndex": 13,
    "ModifyIndex": 15
  }
]
root@ubuntu2204:~ 17:52:35 #
#列出服务
curl http://192.168.121.220:8500/v1/catalog/services
root@ubuntu2204:~ 17:52:35 # curl http://192.168.121.220:8500/v1/catalog/services
{"consul":[]}

#指定节点状态
curl http://192.168.121.220:8500/v1/health/node/node2
#列出服务节点
curl http://192.168.121.220:8500/v1/catalog/service/<service_id>


# 提交 Json 格式的数据进行注册服务
root@ubuntu2204:~ 17:55:40 # curl -X PUT -d '{"id": "myservice-id","name": "myservice","address": "192.168.121.111","port": 9100,"tags": ["service"],"checks": [{"http": "http://192.168.121.111:9100/","interval": "5s"}]}' http://192.168.121.220:8500/v1/agent/service/register


# 也可以将注册信息保存在json格式的文件中，再执行下面命令注册
root@ubuntu2204:~ 18:07:30 # cat nodes.json
{
  "id": "myservice-id-1",
  "name": "myservice-1",
  "address": "192.168.121.112",
  "port": 9100,
  "tags": [
    "service"
  ],
  "checks": [
    {
      "http": "http://192.168.121.112:9100/",
      "interval": "5s"
    }
  ]
}
root@ubuntu2204:~ 18:07:53 # curl -X PUT --data @nodes.json http://192.168.121.220:8500/v1/agent/service/register



#查询指定节点以及指定的服务信息
curl http://192.168.121.220:8500/v1/catalog/service/<service_name> 
#删除服务，注意：集群模式下需要在service_id所有在主机节点上执行才能删除该service
curl -X PUT http://192.168.121.220:8500/v1/agent/service/deregister/<service_id>
root@ubuntu2204:~ 19:26:53 # curl -X PUT http://192.168.121.220:8500/v1/agent/service/deregister/myservice-id-1

~~~

范例: 查看节点状态

~~~shell
root@ubuntu2204:~ 19:31:46 # curl http://192.168.121.220:8500/v1/health/node/consul | jq
~~~

#### 6.4.3.2 使用 consul service 命令注册和注销服务

##### 6.4.3.2.1 **注册服务**

consul services register 命令也可用于进行服务注册，只是其使用的配置格式与直接请求HTTP API有所不同。

~~~shell
consul services register /path/file.json
~~~

注册单个服务时，file.json文件使用service进行定义，注册多个服务时，使用 services 以列表格式进行定义。

示例: 定义了单个要注册的服务。

~~~json
root@ubuntu2204:~ 19:36:51 # cat service1.json
{
  "id": "myservice-id-1",
  "name": "myservice-1",
  "address": "192.168.121.112",
  "port": 9100,
  "tags": [
    "service"
  ],
  "checks": [
    {
      "http": "http://192.168.121.112:9100/",
      "interval": "5s"
    }
  ]
}
~~~

示例: 以多个的服务的格式给出了定义

~~~json
root@ubuntu2204:~ 19:45:43 # cat service1.json 
{
  "services": [
    {"id": "myservice-id-1",
    "name": "myservice-1",
    "address": "192.168.121.112",
    "port": 9100,
    "tags": [
      "service"
    ],
    "checks": [
      {
        "http": "http://192.168.121.112:9100/",
        "interval": "5s"
      }]
    },
    {"id": "myservice-id-2",
    "name": "myservice-2",
    "address": "192.168.121.112",
    "port": 9100,
    "tags": [
      "service"
    ],
    "checks": [
      {
        "http": "http://192.168.121.112:9100/",
        "interval": "5s"
      }]
    }
  ]
}

root@ubuntu2204:~ 19:45:46 # consul services register /root/service1.json
Registered service: myservice-1
Registered service: myservice-1

~~~

##### 6.4.3.2.2 **注销服务**

可以使用 consul services deregister 命令实现

~~~shell
consul services deregister -id <SERVICE_ID>

root@ubuntu2204:~ 17:30:18 # consul services deregister -id myservice-id-1
Deregistered service: myservice-id-1
root@ubuntu2204:~ 17:32:04 # 

~~~

### 6.4.4 配置 Prometheus 使用 Counsul 服务发现

官方文档

https://prometheus.io/docs/prometheus/latest/configuration/configuration/#consul_sd_config

默认情况下，当 Prometheus 加载 Target 实例完成后，这些 Target 时候都会包含一些默认的标签：

~~~shell
__address__ #当前Target实例的访问地址<host>:<port>
__scheme__ #采集目标服务访问地址的HTTP Scheme，HTTP或者HTTPS
__metrics_path__ #采集目标服务访问地址的访问路径
__param_<name> #采集任务目标服务的中包含的请求参数
~~~

通过 Consul 动态发现的服务实例还会包含以下 Metadata 标签信息：

~~~shell
__meta_consul_address         #consul地址
__meta_consul_dc              #consul中服务所在的数据中心
__meta_consulmetadata         #服务的metadata
__meta_consul_node            #服务所在consul节点的信息
__meta_consul_service_address #服务访问地址
__meta_consul_service_id      #服务ID
__meta_consul_service_port    #服务端口
__meta_consul_service         #服务名称
__meta_consul_tags            #服务包含的标签信息
~~~

利用 Relabeling 实现基于 Target 实例中包含的 metadata 标签，动态的添加或者覆盖标签。

范例:

~~~yaml
root@prometheus-221:~ 17:28:31 # vim /usr/local/prometheus/conf/prometheus.yml 
  - job_name: "Consul_sd"
    honor_labels: true
    consul_sd_configs:
      - server: 192.168.121.220:8500
        services: []

root@prometheus-221:~ 17:56:58 # promtool check config /usr/local/prometheus/conf/prometheus.yml 
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 17:57:00 # systemctl restart prometheus.service 
root@prometheus-221:~ 17:57:20 # 

~~~

![image-20251008175753275](Prometheus.assets/image-20251008175753275.png)

![image-20251008175803993](Prometheus.assets/image-20251008175803993.png)

由于 192.168.121.220:8500/metrics api 不存在，因此收集时，将其排除

~~~yaml
root@prometheus-221:~ 21:08:34 # cat /usr/local/prometheus/conf/prometheus.yml
  - job_name: "Consul_sd"
    honor_labels: true
    consul_sd_configs:
      - server: 192.168.121.220:8500
        services: []
    relabel_configs:
      - source_labels: ['__meta_consul_service'] #生成新的标签名
        target_label: 'consul_service'
      - source_labels: ['__meta_consul_dc']
        target_label: 'datacenter'
      - source_labels: ['__meta_consul_tags']
        target_label: 'app'
      - source_labels: ['__meta_consul_service'] #删除consul的service,此service是consul内置,但并不提供metrics数据
        regex: "consul"
        action: drop

~~~

![image-20251008211014135](Prometheus.assets/image-20251008211014135.png)

### 6.4.5 验证采集结果

测试修改 consul 服务注册

~~~json
root@ubuntu2204:~ 19:47:59 # cat service1.json 
{
  "services": [
    {"id": "myservice-id-2",
    "name": "myservice-2",
    "address": "192.168.121.112",
    "port": 9100,
    "tags": [
      "node_exporter"
    ],
    "checks": [
      {
        "http": "http://192.168.121.112:9100/",
        "interval": "5s"
      }]
    },
    {"id": "myservice-id-3",
    "name": "myservice-2",
    "address": "192.168.121.113",
    "port": 9100,
    "tags": [
      "node_exporter"
    ],
    "checks": [
      {
        "http": "http://192.168.121.113:9100/",
        "interval": "5s"
      }]
    },
    {"id": "myservice-id-1",
    "name": "myservice-2",
    "address": "192.168.121.111",
    "port": 9100,
    "tags": [
      "node_exporter"
    ],
    "checks": [
      {
        "http": "http://192.168.121.111:9100/",
        "interval": "5s"
      }]
}
  ]
}

root@ubuntu2204:~ 19:47:58 # consul services register service1.json
Registered service: myservice-2
Registered service: myservice-2
Registered service: myservice-2
~~~

查看 Prometheus 监控情况

![image-20251008194928873](Prometheus.assets/image-20251008194928873.png)

# 七、各种 Exporter

Prometheus 指供了大量的 Exporter 实现各种应用的监控功能

Exporter 分类

- 应用内置: 软件内就内置了Exporter,比如: Grafana,Zookeeper,Gitlab,MinIO等
- 应用外置: 应用安装后,还需要单独安装对应的 Exporter,比如: MySQL,Redis,MongoDB,PostgreSQL等
- 定制开发: 如有特殊需要,用户自行开发

Exporter 官方文档

https://prometheus.io/docs/instrumenting/exporters/

## 7.1 Node Exporter 监控服务

### 7.1.1 服务监控说明

对于一些服务应用来说，我们可以通过对于node_exporter的启动参数改造来实现更多功能的获取。

参数分析

~~~shell
root@prometheus-221:~ 11:29:43 # /usr/local/node_exporter/bin/node_exporter --help
usage: node_exporter [<flags>]


Flags:
  -h, --[no-]help                Show context-sensitive help (also try --help-long and --help-man).
      --collector.arp.device-include=COLLECTOR.ARP.DEVICE-INCLUDE  
                                 Regexp of arp devices to include (mutually exclusive to device-exclude).
      --collector.arp.device-exclude=COLLECTOR.ARP.DEVICE-EXCLUDE  
                                 Regexp of arp devices to exclude (mutually exclusive to device-include).
      --[no-]collector.arp.netlink  
                                 Use netlink to gather stats instead of /proc/net/arp.
      --[no-]collector.bcache.priorityStats  
                                 Expose expensive priority stats.
      --[no-]collector.cpu.guest  
                                 Enables metric node_cpu_guest_seconds_total
      --[no-]collector.cpu.info  Enables metric cpu_info
      --collector.cpu.info.flags-include=COLLECTOR.CPU.INFO.FLAGS-INCLUDE  
                                 Filter the `flags` field in cpuInfo with a value that must be a regular expression
      --collector.cpu.info.bugs-include=COLLECTOR.CPU.INFO.BUGS-INCLUDE  
                                 Filter the `bugs` field in cpuInfo with a value that must be a regular expression
      --collector.diskstats.device-exclude="^(z?ram|loop|fd|(h|s|v|xv)d[a-z]|nvme\\d+n\\d+p)\\d+$"  
                                 Regexp of diskstats devices to exclude (mutually exclusive to device-include).
      --collector.diskstats.device-include=COLLECTOR.DISKSTATS.DEVICE-INCLUDE  
                                 Regexp of diskstats devices to include (mutually exclusive to device-exclude).
      --collector.ethtool.device-include=COLLECTOR.ETHTOOL.DEVICE-INCLUDE  
                                 Regexp of ethtool devices to include (mutually exclusive to device-exclude).
      --collector.ethtool.device-exclude=COLLECTOR.ETHTOOL.DEVICE-EXCLUDE  
                                 Regexp of ethtool devices to exclude (mutually exclusive to device-include).
      --collector.ethtool.metrics-include=".*"  
                                 Regexp of ethtool stats to include.
      --collector.filesystem.mount-points-exclude="^/(dev|proc|run/credentials/.+|sys|var/lib/docker/.+|var/lib/containers/storage/.+)($|/)"  
                                 Regexp of mount points to exclude for filesystem collector. (mutually exclusive to mount-points-include)
      --collector.filesystem.mount-points-include=COLLECTOR.FILESYSTEM.MOUNT-POINTS-INCLUDE  
                                 Regexp of mount points to include for filesystem collector. (mutually exclusive to mount-points-exclude)
      --collector.filesystem.fs-types-exclude="^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"  
                                 Regexp of filesystem types to exclude for filesystem collector. (mutually exclusive to fs-types-include)
      --collector.filesystem.fs-types-include=COLLECTOR.FILESYSTEM.FS-TYPES-INCLUDE  
                                 Regexp of filesystem types to exclude for filesystem collector. (mutually exclusive to fs-types-exclude)
      --collector.hwmon.chip-include=COLLECTOR.HWMON.CHIP-INCLUDE  
                                 Regexp of hwmon chip to include (mutually exclusive to device-exclude).
      --collector.hwmon.chip-exclude=COLLECTOR.HWMON.CHIP-EXCLUDE  
                                 Regexp of hwmon chip to exclude (mutually exclusive to device-include).
      --collector.hwmon.sensor-include=COLLECTOR.HWMON.SENSOR-INCLUDE  
                                 Regexp of hwmon sensor to include (mutually exclusive to sensor-exclude).
      --collector.hwmon.sensor-exclude=COLLECTOR.HWMON.SENSOR-EXCLUDE  
                                 Regexp of hwmon sensor to exclude (mutually exclusive to sensor-include).
      --collector.interrupts.name-include=COLLECTOR.INTERRUPTS.NAME-INCLUDE  
                                 Regexp of interrupts name to include (mutually exclusive to --collector.interrupts.name-exclude).
      --collector.interrupts.name-exclude=COLLECTOR.INTERRUPTS.NAME-EXCLUDE  
                                 Regexp of interrupts name to exclude (mutually exclusive to --collector.interrupts.name-include).
      --[no-]collector.interrupts.include-zeros  
                                 Include interrupts that have a zero value
      --collector.ipvs.backend-labels="local_address,local_port,remote_address,remote_port,proto,local_mark"  
                                 Comma separated list for IPVS backend stats labels.
      --collector.netclass.ignored-devices="^$"  
                                 Regexp of net devices to ignore for netclass collector.
      --[no-]collector.netclass.ignore-invalid-speed  
                                 Ignore devices where the speed is invalid. This will be the default behavior in 2.x.
      --[no-]collector.netclass.netlink  
                                 Use netlink to gather stats instead of /proc/net/dev.
      --[no-]collector.netclass_rtnl.with-stats  
                                 Expose the statistics for each network device, replacing netdev collector.
      --collector.netdev.device-include=COLLECTOR.NETDEV.DEVICE-INCLUDE  
                                 Regexp of net devices to include (mutually exclusive to device-exclude).
      --collector.netdev.device-exclude=COLLECTOR.NETDEV.DEVICE-EXCLUDE  
                                 Regexp of net devices to exclude (mutually exclusive to device-include).
      --[no-]collector.netdev.address-info  
                                 Collect address-info for every device
      --[no-]collector.netdev.enable-detailed-metrics  
                                 Use (incompatible) metric names that provide more detailed stats on Linux
      --[no-]collector.netdev.netlink  
                                 Use netlink to gather stats instead of /proc/net/dev.
      --[no-]collector.netdev.label-ifalias  
                                 Add ifAlias label
      --collector.netstat.fields="^(.*_(InErrors|InErrs)|Ip_Forwarding|Ip(6|Ext)_(InOctets|OutOctets)|Icmp6?_(InMsgs|OutMsgs)|TcpExt_(Listen.*|Syncookies.*|TCPSynRetrans|TCPTimeouts|TCPOFOQueue|TCPRcvQDrop)|Tcp_(ActiveOpens|InSegs|OutSegs|OutRsts|PassiveOpens|RetransSegs|CurrEstab)|Udp6?_(InDatagrams|OutDatagrams|NoPorts|RcvbufErrors|SndbufErrors))$"  
                                 Regexp of fields to return for netstat collector.
      --collector.ntp.server="127.0.0.1"  
                                 NTP server to use for ntp collector
      --collector.ntp.server-port=123  
                                 UDP port number to connect to on NTP server
      --collector.ntp.protocol-version=4  
                                 NTP protocol version
      --[no-]collector.ntp.server-is-local  
                                 Certify that collector.ntp.server address is not a public ntp server
      --collector.ntp.ip-ttl=1   IP TTL to use while sending NTP query
      --collector.ntp.max-distance=3.46608s  
                                 Max accumulated distance to the root
      --collector.ntp.local-offset-tolerance=1ms  
                                 Offset between local clock and local ntpd time to tolerate
      --path.procfs="/proc"      procfs mountpoint.
      --path.sysfs="/sys"        sysfs mountpoint.
      --path.rootfs="/"          rootfs mountpoint.
      --path.udev.data="/run/udev/data"  
                                 udev data path.
      --collector.perf.cpus=""   List of CPUs from which perf metrics should be collected
      --collector.perf.tracepoint=COLLECTOR.PERF.TRACEPOINT ...  
                                 perf tracepoint that should be collected
      --[no-]collector.perf.disable-hardware-profilers  
                                 disable perf hardware profilers
      --collector.perf.hardware-profilers=COLLECTOR.PERF.HARDWARE-PROFILERS ...  
                                 perf hardware profilers that should be collected
      --[no-]collector.perf.disable-software-profilers  
                                 disable perf software profilers
      --collector.perf.software-profilers=COLLECTOR.PERF.SOFTWARE-PROFILERS ...  
                                 perf software profilers that should be collected
      --[no-]collector.perf.disable-cache-profilers  
                                 disable perf cache profilers
      --collector.perf.cache-profilers=COLLECTOR.PERF.CACHE-PROFILERS ...  
                                 perf cache profilers that should be collected
      --collector.powersupply.ignored-supplies="^$"  
                                 Regexp of power supplies to ignore for powersupplyclass collector.
      --collector.qdisc.fixtures=""  
                                 test fixtures to use for qdisc collector end-to-end testing
      --collector.qdisc.device-include=COLLECTOR.QDISC.DEVICE-INCLUDE  
                                 Regexp of qdisc devices to include (mutually exclusive to device-exclude).
      --collector.qdisc.device-exclude=COLLECTOR.QDISC.DEVICE-EXCLUDE  
                                 Regexp of qdisc devices to exclude (mutually exclusive to device-include).
      --[no-]collector.rapl.enable-zone-label  
                                 Enables service unit metric unit_start_time_seconds
      --collector.runit.servicedir="/etc/service"  
                                 Path to runit service directory.
      --collector.slabinfo.slabs-include=".*"  
                                 Regexp of slabs to include in slabinfo collector.
      --collector.slabinfo.slabs-exclude=""  
                                 Regexp of slabs to exclude in slabinfo collector.
      --[no-]collector.stat.softirq  
                                 Export softirq calls per vector
      --collector.supervisord.url="http://localhost:9001/RPC2"  
                                 XML RPC endpoint. ($SUPERVISORD_URL)
      --collector.sysctl.include=COLLECTOR.SYSCTL.INCLUDE ...  
                                 Select sysctl metrics to include
      --collector.sysctl.include-info=COLLECTOR.SYSCTL.INCLUDE-INFO ...  
                                 Select sysctl metrics to include as info metrics
      --collector.systemd.unit-include=".+"  
                                 Regexp of systemd units to include. Units must both match include and not match exclude to be included.
      --collector.systemd.unit-exclude=".+\\.(automount|device|mount|scope|slice)"  
                                 Regexp of systemd units to exclude. Units must both match include and not match exclude to be included.
      --[no-]collector.systemd.enable-task-metrics  
                                 Enables service unit tasks metrics unit_tasks_current and unit_tasks_max
      --[no-]collector.systemd.enable-restarts-metrics  
                                 Enables service unit metric service_restart_total
      --[no-]collector.systemd.enable-start-time-metrics  
                                 Enables service unit metric unit_start_time_seconds
      --collector.tapestats.ignored-devices="^$"  
                                 Regexp of devices to ignore for tapestats.
      --collector.textfile.directory= ...  
                                 Directory to read text files with metrics from, supports glob matching. (repeatable)
      --collector.vmstat.fields="^(oom_kill|pgpg|pswp|pg.*fault).*"  
                                 Regexp of fields to return for vmstat collector.
      --collector.wifi.fixtures=""  
                                 test fixtures to use for wifi collector metrics
      --[no-]collector.arp       Enable the arp collector (default: enabled).
      --[no-]collector.bcache    Enable the bcache collector (default: enabled).
      --[no-]collector.bonding   Enable the bonding collector (default: enabled).
      --[no-]collector.btrfs     Enable the btrfs collector (default: enabled).
      --[no-]collector.buddyinfo  
                                 Enable the buddyinfo collector (default: disabled).
      --[no-]collector.cgroups   Enable the cgroups collector (default: disabled).
      --[no-]collector.conntrack  
                                 Enable the conntrack collector (default: enabled).
      --[no-]collector.cpu       Enable the cpu collector (default: enabled).
      --[no-]collector.cpu_vulnerabilities  
                                 Enable the cpu_vulnerabilities collector (default: disabled).
      --[no-]collector.cpufreq   Enable the cpufreq collector (default: enabled).
      --[no-]collector.diskstats  
                                 Enable the diskstats collector (default: enabled).
      --[no-]collector.dmi       Enable the dmi collector (default: enabled).
      --[no-]collector.drbd      Enable the drbd collector (default: disabled).
      --[no-]collector.drm       Enable the drm collector (default: disabled).
      --[no-]collector.edac      Enable the edac collector (default: enabled).
      --[no-]collector.entropy   Enable the entropy collector (default: enabled).
      --[no-]collector.ethtool   Enable the ethtool collector (default: disabled).
      --[no-]collector.fibrechannel  
                                 Enable the fibrechannel collector (default: enabled).
      --[no-]collector.filefd    Enable the filefd collector (default: enabled).
      --[no-]collector.filesystem  
                                 Enable the filesystem collector (default: enabled).
      --[no-]collector.hwmon     Enable the hwmon collector (default: enabled).
      --[no-]collector.infiniband  
                                 Enable the infiniband collector (default: enabled).
      --[no-]collector.interrupts  
                                 Enable the interrupts collector (default: disabled).
      --[no-]collector.ipvs      Enable the ipvs collector (default: enabled).
      --[no-]collector.ksmd      Enable the ksmd collector (default: disabled).
      --[no-]collector.lnstat    Enable the lnstat collector (default: disabled).
      --[no-]collector.loadavg   Enable the loadavg collector (default: enabled).
      --[no-]collector.logind    Enable the logind collector (default: disabled).
      --[no-]collector.mdadm     Enable the mdadm collector (default: enabled).
      --[no-]collector.meminfo   Enable the meminfo collector (default: enabled).
      --[no-]collector.meminfo_numa  
                                 Enable the meminfo_numa collector (default: disabled).
      --[no-]collector.mountstats  
                                 Enable the mountstats collector (default: disabled).
      --[no-]collector.netclass  Enable the netclass collector (default: enabled).
      --[no-]collector.netdev    Enable the netdev collector (default: enabled).
      --[no-]collector.netstat   Enable the netstat collector (default: enabled).
      --[no-]collector.network_route  
                                 Enable the network_route collector (default: disabled).
      --[no-]collector.nfs       Enable the nfs collector (default: enabled).
      --[no-]collector.nfsd      Enable the nfsd collector (default: enabled).
      --[no-]collector.ntp       Enable the ntp collector (default: disabled).
      --[no-]collector.nvme      Enable the nvme collector (default: enabled).
      --[no-]collector.os        Enable the os collector (default: enabled).
      --[no-]collector.perf      Enable the perf collector (default: disabled).
      --[no-]collector.powersupplyclass  
                                 Enable the powersupplyclass collector (default: enabled).
      --[no-]collector.pressure  Enable the pressure collector (default: enabled).
      --[no-]collector.processes  
                                 Enable the processes collector (default: disabled).
      --[no-]collector.qdisc     Enable the qdisc collector (default: disabled).
      --[no-]collector.rapl      Enable the rapl collector (default: enabled).
      --[no-]collector.runit     Enable the runit collector (default: disabled).
      --[no-]collector.schedstat  
                                 Enable the schedstat collector (default: enabled).
      --[no-]collector.selinux   Enable the selinux collector (default: enabled).
      --[no-]collector.slabinfo  Enable the slabinfo collector (default: disabled).
      --[no-]collector.sockstat  Enable the sockstat collector (default: enabled).
      --[no-]collector.softirqs  Enable the softirqs collector (default: disabled).
      --[no-]collector.softnet   Enable the softnet collector (default: enabled).
      --[no-]collector.stat      Enable the stat collector (default: enabled).
      --[no-]collector.supervisord  
                                 Enable the supervisord collector (default: disabled).
      --[no-]collector.sysctl    Enable the sysctl collector (default: disabled).
      --[no-]collector.systemd   Enable the systemd collector (default: disabled).
      --[no-]collector.tapestats  
                                 Enable the tapestats collector (default: enabled).
      --[no-]collector.tcpstat   Enable the tcpstat collector (default: disabled).
      --[no-]collector.textfile  Enable the textfile collector (default: enabled).
      --[no-]collector.thermal_zone  
                                 Enable the thermal_zone collector (default: enabled).
      --[no-]collector.time      Enable the time collector (default: enabled).
      --[no-]collector.timex     Enable the timex collector (default: enabled).
      --[no-]collector.udp_queues  
                                 Enable the udp_queues collector (default: enabled).
      --[no-]collector.uname     Enable the uname collector (default: enabled).
      --[no-]collector.vmstat    Enable the vmstat collector (default: enabled).
      --[no-]collector.watchdog  Enable the watchdog collector (default: enabled).
      --[no-]collector.wifi      Enable the wifi collector (default: disabled).
      --[no-]collector.xfrm      Enable the xfrm collector (default: disabled).
      --[no-]collector.xfs       Enable the xfs collector (default: enabled).
      --[no-]collector.zfs       Enable the zfs collector (default: enabled).
      --[no-]collector.zoneinfo  Enable the zoneinfo collector (default: disabled).
      --web.telemetry-path="/metrics"  
                                 Path under which to expose metrics.
      --[no-]web.disable-exporter-metrics  
                                 Exclude metrics about the exporter itself (promhttp_*, process_*, go_*).
      --web.max-requests=40      Maximum number of parallel scrape requests. Use 0 to disable.
      --[no-]collector.disable-defaults  
                                 Set all collectors to disabled by default.
      --runtime.gomaxprocs=1     The target number of CPUs Go will run on (GOMAXPROCS) ($GOMAXPROCS)
      --[no-]web.systemd-socket  Use systemd socket activation listeners instead of port listeners (Linux only).
      --web.listen-address=:9100 ...  
                                 Addresses on which to expose metrics and web interface. Repeatable for multiple addresses. Examples: `:9100` or `[::1]:9100` for
                                 http, `vsock://:9100` for vsock
      --web.config.file=""       Path to configuration file that can enable TLS or authentication. See:
                                 https://github.com/prometheus/exporter-toolkit/blob/master/docs/web-configuration.md
      --log.level=info           Only log messages with the given severity or above. One of: [debug, info, warn, error]
      --log.format=logfmt        Output format of log messages. One of: [logfmt, json]
      --[no-]version             Show application version.

root@prometheus-221:~ 11:30:12 # 

--collector.systemd               #显示当前系统中所有的服务状态信息
--collector.systemd.unit-include  #仅仅显示符合条件的systemd服务条目
--collector.systemd.unit-exclude  #显示排除列表范围之外的服务条目
#注意：
上面三条仅显示已安装的服务条目，没有安装的服务条目是不会被显示的。
而且后面两个属性是依赖于第一条属性的
这些信息会被显示在 node_systemd_unit_state 对应的 metrics 中
~~~

### 7.1.2 实战案例

#### 7.1.2.1 修改 node_exporter 配置文件

~~~shell
root@node1-111:~ 11:42:39 # cat /lib/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/node_exporter/bin/node_exporter --collector.systemd --collector.systemd.unit-include=".*(ssh|nginx|mysql|node_exporter).*"
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
User=prometheus
Group=prometheus

[Install]
WantedBy=multi-user.target
root@node1-111:~ 11:42:40 # systemctl daemon-reload 
root@node1-111:~ 11:43:12 # systemctl enable --now node_exporter.service
root@node1-111:~ 11:43:23 # systemctl status node_exporter.service

~~~

#### 7.1.2.2 配置 Prometheus 

~~~yaml
root@prometheus-221:~ 11:30:12 # vim /usr/local/prometheus/conf/prometheus.yml 
  - job_name: "node_exporter"
    static_configs:
      - targets: 
        - 192.168.121.111:9100
        - 192.168.121.112:9100
        - 192.168.121.113:9100
root@prometheus-221:~ 11:45:32 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 11:45:37 # systemctl restart prometheus.service 
#结果显示：
每个服务都有五种状态，只有成功的状态才会显示值为1，其他状态为0
只有已安装的服务才会在这里显示，否则不显示
~~~

![image-20251011115551276](Prometheus.assets/image-20251011115551276.png)

~~~shell
#在node1节点安装nginx服务后,再次观察可以看到下面结果
[root@node1 ~]#apt -y install nginx
~~~

![image-20251011120017300](Prometheus.assets/image-20251011120017300.png)

## 7.2 MySQL 监控

### 7.2.1 MySQL 监控说明

prometheus 提供了专属于 MySQL 的服务监控工具 mysqld_exporter，可以借助于该模块，来实现数据库的基本监控。

~~~shell
#下载链接
https://prometheus.io/download/
#使用说明
https://github.com/prometheus/mysqld_exporter
~~~

### 7.2.2 二进制安装

#### 7.2.2.1 MySQL 数据库环境说准备

~~~shell
# 安装数据库
root@node1-111:~ 14:37:05 # apt update  && apt install -y mysql-server

# 更新mysql配置，如果 MySQL和 MySQL exporter 不在同一个主机，需要修改如下配置
sed -i 's#127.0.0.1#0.0.0.0#' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

# 为 mysqld_exporter 配置获取数据库信息的用户并授权
root@node1-111:~ 14:40:40 # mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.43-0ubuntu0.22.04.2 (Ubuntu)

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>  CREATE USER 'exporter'@'localhost' IDENTIFIED BY '123456' WITH MAX_USER_CONNECTIONS 3;
Query OK, 0 rows affected (0.04 sec)

mysql> GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
Query OK, 0 rows affected (0.01 sec)

mysql>  flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> exit
Bye

~~~

#### 7.2.2.2 安装 mysql_exporter

~~~shell
# 获取软件
root@node1-111:~ 14:41:37 # wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.18.0/mysqld_exporter-0.18.0.linux-amd64.tar.gz


# 解压、配置软件
root@node1-111:~ 14:43:59 # tar xf mysqld_exporter-0.18.0.linux-amd64.tar.gz  -C /usr/local/
root@node1-111:~ 14:44:11 # cd /usr/local/
root@node1-111:/usr/local 14:44:12 # ln -sv mysqld_exporter-0.18.0.linux-amd64 mysql_exporter 
'mysql_exporter' -> 'mysqld_exporter-0.18.0.linux-amd64'
root@node1-111:/usr/local 14:44:21 # cd mysql_exporter/
root@node1-111:/usr/local/mysql_exporter 14:44:23 # ls
LICENSE  mysqld_exporter  NOTICE
root@node1-111:/usr/local/mysql_exporter 14:44:24 # mkdir bin 
root@node1-111:/usr/local/mysql_exporter 14:44:30 # mv mysqld_exporter  bin/
root@node1-111:/usr/local/mysql_exporter 14:44:33 # tree 
.
├── bin
│?? └── mysqld_exporter
├── LICENSE
└── NOTICE

1 directory, 3 files
root@node1-111:/usr/local/mysql_exporter 14:44:36 #

# 在 mysql_exporter 的服务目录下，创建 .my.cnf 隐藏文件，为 mysql_exporter 配置获取数据库信息的基本属性
root@node1-111:~ 14:46:54 # cat /usr/local/mysql_exporter/.my.cnf
[client]
host=127.0.0.1
port=3306
user=exporter
password=123456
root@node1-111:~ 14:46:56 # 

# 配置 service 文件
root@node1-111:~ 14:49:56 # cat /lib/systemd/system/mysqld_exporter.service
[Unit]
Description=mysqld exporter project
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/mysql_exporter/bin/mysqld_exporter --config.my-cnf="/usr/local/mysql_exporter/.my.cnf"
Restart=on-failure
[Install]
WantedBy=multi-user.target

root@node1-111:~ 14:49:59 # systemctl enable --now mysqld_exporter.service
root@node1-111:~ 14:50:03 # systemctl status mysqld_exporter.service
● mysqld_exporter.service - mysqld exporter project
     Loaded: loaded (/lib/systemd/system/mysqld_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2025-10-11 14:50:03 CST; 2s ago
   Main PID: 20478 (mysqld_exporter)
      Tasks: 5 (limit: 4514)
     Memory: 2.0M
        CPU: 32ms
     CGroup: /system.slice/mysqld_exporter.service
             └─20478 /usr/local/mysql_exporter/bin/mysqld_exporter --config.my-cnf=/usr/local/mysql_exporter/.my.cnf

Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.250+08:00 level=INFO source=mysqld_exporter.go:256 msg="Starting mysqld_exp>
Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.251+08:00 level=INFO source=mysqld_exporter.go:257 msg="Build context" buil>
Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.251+08:00 level=INFO source=mysqld_exporter.go:269 msg="Scraper enabled" sc>
Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.251+08:00 level=INFO source=mysqld_exporter.go:269 msg="Scraper enabled" sc>
Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.251+08:00 level=INFO source=mysqld_exporter.go:269 msg="Scraper enabled" sc>
Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.251+08:00 level=INFO source=mysqld_exporter.go:269 msg="Scraper enabled" sc>
Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.251+08:00 level=INFO source=mysqld_exporter.go:269 msg="Scraper enabled" sc>
Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.251+08:00 level=INFO source=mysqld_exporter.go:269 msg="Scraper enabled" sc>
Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.255+08:00 level=INFO source=tls_config.go:346 msg="Listening on" address=[:>
Oct 11 14:50:03 node1-111 mysqld_exporter[20478]: time=2025-10-11T14:50:03.256+08:00 level=INFO source=tls_config.go:349 msg="TLS is disabled." http2=>
root@node1-111:~ 14:50:06 # ss -tunlp  |grep 9104
tcp   LISTEN 0      4096               *:9104             *:*    users:(("mysqld_exporter",pid=20478,fd=3))                                                                                          

root@node1-111:~ 14:50:21 # ss -tunlp  |grep 3306
tcp   LISTEN 0      151        127.0.0.1:3306       0.0.0.0:*    users:(("mysqld",pid=19746,fd=23))                                                                                                  
tcp   LISTEN 0      70         127.0.0.1:33060      0.0.0.0:*    users:(("mysqld",pid=19746,fd=21))                                                                                                  
root@node1-111:~ 14:50:23 #
~~~

![image-20251011145105492](Prometheus.assets/image-20251011145105492.png)

#### 7.2.2.3 配置 Prometheus

~~~yaml
root@prometheus-221:~ 14:52:28 # tail -6 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "mysql_exporter"
    static_configs: 
      - targets:
        - 192.168.121.111:9104
        labels:
          app: mysql
root@prometheus-221:~ 14:52:35 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 14:52:44 # systemctl restart prometheus.service
~~~

![image-20251011145311022](Prometheus.assets/image-20251011145311022.png)

#### 7.2.2.4 Grafana 图形展示

17320 14057 7362  

![image-20251011145452160](Prometheus.assets/image-20251011145452160.png)

### 7.2.3 docker-compose 实现

~~~yaml
[root@ubuntu2204 mysql]#tree
.
├── docker-compose.yml
└── mysql
   └── docker.cnf
1 directory, 2 files
[root@ubuntu2204 mysql]#cat mysql/docker.cnf 
[mysqld]
skip-host-cache
skip-name-resolve

[root@ubuntu2204 mysql]#cat docker-compose.yml 
version: '3.6'
volumes:
  mysqld_data: {}
networks:
  monitoring:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.0.0/24
services:
  mysqld:
    image: mysql:8.0
    #image: mysql:5.7
    volumes:
      - ./mysql:/etc/mysql/conf.d
      - mysqld_data:/var/lib/mysql
    environment:
      - MYSQL_ALLOW_EMPTY_PASSWORD=true
    networks:
      - monitoring
    ports:
      - 3306:3306
  # CREATE USER 'exporter'@'172.31.%.%' IDENTIFIED BY 'exporter';
  # GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'172.31.%.%';
  # GRANT SELECT ON performance_schema.* TO 'exporter'@'172.31.%.%';
  mysqld-exporter:
    image: prom/mysqld-exporter:v0.14.0
    command:
      - --collect.info_schema.innodb_metrics
      - --collect.info_schema.innodb_tablespaces
      - --collect.perf_schema.eventsstatementssum
      - --collect.perf_schema.memory_events
      - --collect.global_status
      - --collect.engine_innodb_status
      - --collect.binlog_size
    environment:
      - DATA_SOURCE_NAME=exporter:exporter@(mysqld:3306)/
    ports:
      - 9104:9104
    networks:
      - monitoring
    depends_on:
      - mysqld
      
#启动
[root@ubuntu2204 mysql]#docker-compose up -d
#验证服务
[root@ubuntu2204 mysql]#docker-compose ps
[root@ubuntu2204 mysql]#docker-compose logs mysqld-exporter
#创建用户和授权
[root@ubuntu2204 mysql]#docker-compose exec mysqld /bin/sh
sh-4.2#mysql
>CREATE USER 'exporter'@'172.31.%.%' IDENTIFIED BY 'exporter';
>GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'172.31.%.%';
>GRANT SELECT ON performance_schema.* TO 'exporter'@'172.31.%.%';
>\q
sh-4.2#exit
[root@ubuntu2204 ~]#curl http://localhost:9194/metrics
#修改 Prometheus 监控 mysql
[root@ubuntu2204 ~]#vim /usr/local/prometheus/conf/prometheus.yml
.....
  - job_name: "mysqld-exporter"
   static_configs:
      - targets: ["mysqld-exporter服务器地址:9104"]
.....
[root@ubuntu2204 ~]#systemctl reload prometheus
#查看状态
~~~

## 7.3 Haproxy 监控

Haproxy的监控有两种实现方式

- 借助于专用的haproxy_exporter组件来采集 haproxy的csv数据

  haproxy_exporter 可以和 haproxy 处于不同的环境，不同主机等

- 借助于 haproxy本身的机制，暴露metrics指标

  /metrics 和 /haproxy-status 是同时配置的

  相当于 zookeeper 的 /metrics 

### 7.3.1 Haproxy_exporter 监控

#### 7.3.1.1 Haproxy_exporter 介绍

对于负载均衡软件来说，prometheus 提供了专用的监控组件 haproxy-exporter 来实现对于 haproxy 负载均衡软件的代理工作。

haproxy-exporter 本质上，它是根据对 haproxy 的状态页面uri地址获取到的 csv 内容进行了解析，从而获取我们需要监控到的数据。

下载链接: https://prometheus.io/download/

官网地址：https://github.com/prometheus/haproxy_exporter

#### 7.3.1.2 实战案例

##### 7.3.1.2.1 准备 Haproxy 环境

~~~shell
# 安装 haproxy
root@node1-111:~ 14:50:23 # apt -y install haproxy

# 配置 haproxy
root@node1-111:~ 15:08:09 # cat /etc/haproxy/haproxy.cfg
global
...
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
...

listen stats
    mode http
    bind 0.0.0.0:9999
    stats enable
    log global
    stats uri /haproxy-status
    stats auth admin:123456
root@node1-111:~ 15:08:10 # systemctl restart haproxy.service
root@node1-111:~ 15:08:24 # ss -tunlp | grep 9999
tcp   LISTEN 0      4096         0.0.0.0:9999       0.0.0.0:*    users:(("haproxy",pid=20964,fd=6))                                                                                                  
root@node1-111:~ 15:08:31 # 
~~~

![image-20251011150927258](Prometheus.assets/image-20251011150927258.png)

csv 格式显示

![image-20251011150953986](Prometheus.assets/image-20251011150953986.png)

##### 7.3.1.2.2 安装 Haproxy exporter 

https://github.com/prometheus/haproxy_exporter

haproxy_exporter 支持通过两种方式监控: stats 状态和 socket 文件

~~~shell
# 安装软件
root@node1-111:~ 15:08:31 # wget https://github.com/prometheus/haproxy_exporter/releases/download/v0.15.0/haproxy_exporter-0.15.0.linux-amd64.tar.gz


# 解压配置软件
root@node1-111:~ 15:12:30 # tar xf haproxy_exporter-0.15.0.linux-amd64.tar.gz -C /usr/local/
root@node1-111:~ 15:14:05 # cd /usr/local/
root@node1-111:/usr/local 15:14:06 # ln -sv haproxy_exporter-0.15.0.linux-amd64 haproxy_exporter
'haproxy_exporter' -> 'haproxy_exporter-0.15.0.linux-amd64'
root@node1-111:/usr/local 15:14:17 # cd haproxy_exporter/
root@node1-111:/usr/local/haproxy_exporter 15:14:20 # ls
haproxy_exporter  LICENSE  NOTICE
root@node1-111:/usr/local/haproxy_exporter 15:14:22 # mkdir bin 
root@node1-111:/usr/local/haproxy_exporter 15:14:25 # mv haproxy_exporter bin/
root@node1-111:/usr/local/haproxy_exporter 15:14:29 # tree
.
├── bin
│   └── haproxy_exporter
├── LICENSE
└── NOTICE

1 directory, 3 files
root@node1-111:/usr/local/haproxy_exporter 15:14:31 #

# 修改 haproxy_exporter 的服务启动文件
root@node1-111:~ 15:16:15 # cat /lib/systemd/system/haproxy_exporter.service
[Unit]
Description=haproxy exporter project
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/haproxy_exporter/bin/haproxy_exporter --haproxy.scrape-uri="http://admin:123456@127.0.0.1:9999/haproxy-status;csv"
#也支持通过socket文件实现
#ExecStart=/usr/local/haproxy_exporter/bin/haproxy_exporter --haproxy.scrapeuri=unix:/run/haproxy/admin.sock
Restart=on-failure
[Install]
WantedBy=multi-user.target
root@node1-111:~ 15:16:18 # systemctl daemon-reload 
root@node1-111:~ 15:16:21 # systemctl enable --now haproxy_exporter.service 
root@node1-111:~ 15:16:25 # systemctl status haproxy_exporter.service
● haproxy_exporter.service - haproxy exporter project
     Loaded: loaded (/lib/systemd/system/haproxy_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2025-10-11 15:16:25 CST; 12s ago
   Main PID: 21204 (haproxy_exporte)
      Tasks: 5 (limit: 4514)
     Memory: 1.8M
        CPU: 30ms
     CGroup: /system.slice/haproxy_exporter.service
             └─21204 /usr/local/haproxy_exporter/bin/haproxy_exporter "--haproxy.scrape-uri=http://admin:123456@127.0.0.1:9999/haproxy-status;csv"

Oct 11 15:16:25 node1-111 systemd[1]: Started haproxy exporter project.
Oct 11 15:16:25 node1-111 haproxy_exporter[21204]: ts=2025-10-11T07:16:25.316Z caller=haproxy_exporter.go:602 level=info msg="Starting haproxy_exporter" version="(ve>
Oct 11 15:16:25 node1-111 haproxy_exporter[21204]: ts=2025-10-11T07:16:25.319Z caller=haproxy_exporter.go:603 level=info msg="Build context" context="(go=go1.19.5, p>
Oct 11 15:16:25 node1-111 haproxy_exporter[21204]: ts=2025-10-11T07:16:25.322Z caller=tls_config.go:232 level=info msg="Listening on" address=[::]:9101
Oct 11 15:16:25 node1-111 haproxy_exporter[21204]: ts=2025-10-11T07:16:25.322Z caller=tls_config.go:235 level=info msg="TLS is disabled." http2=false address=[::]:91>
root@node1-111:~ 15:16:38 # ss -tunlp | grep 9101
tcp   LISTEN 0      4096               *:9101             *:*    users:(("haproxy_exporte",pid=21204,fd=3))                                                                                          
root@node1-111:~ 15:16:50 #
~~~

##### 7.3.1.2.3 配置 Prometheus

~~~yaml
root@prometheus-221:~ 15:17:54 # tail -6 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "haproxy_exporter"
    static_configs: 
      - targets:
        - 192.168.121.111:9101
        labels:
          app: haproxy
root@prometheus-221:~ 15:17:56 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 15:17:58 # systemctl restart prometheus.service 
root@prometheus-221:~ 15:18:00 # 
~~~

![image-20251011151830235](Prometheus.assets/image-20251011151830235.png)

##### 7.3.1.2.4 Grafana 展示

364

![image-20251011152222304](Prometheus.assets/image-20251011152222304.png)

### 7.3.2 Haproxy 内置功能实现监控

haproxy自从2.X 版本开始，就提供了专用的暴露数据的功能，只需要在编译安装haproxy的时候，开启该功能即可，然后，就可以按照传统的prometheus监控目标的方式来进行监控了。

#### 7.3.2.1 安装 Haproxy 开启内置监控 exporter 功能

##### 7.3.2.1.1 包安装 haproxy

Ubuntu 22.04 包安装默认内置了 /metrics 的接口，无需编译安装

~~~shell
root@node2-112:~ 15:24:11 # apt update && apt install haproxy -y
root@node2-112:~ 15:26:35 # haproxy -vv
HAProxy version 2.4.24-0ubuntu0.22.04.3 2025/10/01 - https://haproxy.org/
Status: long-term supported branch - will stop receiving fixes around Q2 2026.
Known bugs: http://www.haproxy.org/bugs/bugs-2.4.24.html
Running on: Linux 5.15.0-140-generic #150-Ubuntu SMP Sat Apr 12 06:00:09 UTC 2025 x86_64
Build options :
  TARGET  = linux-glibc
  CPU     = generic
  CC      = cc
  CFLAGS  = -O2 -g -O2 -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -Wall -Wextra -Wdeclaration-after-statement -fwrapv -Wno-address-of-packed-member -Wno-unused-label -Wno-sign-compare -Wno-unused-parameter -Wno-clobbered -Wno-missing-field-initializers -Wno-cast-function-type -Wtype-limits -Wshift-negative-value -Wshift-overflow=2 -Wduplicated-cond -Wnull-dereference
  OPTIONS = USE_PCRE2=1 USE_PCRE2_JIT=1 USE_OPENSSL=1 USE_LUA=1 USE_SLZ=1 USE_SYSTEMD=1 USE_PROMEX=1
  DEBUG   = 

Feature list : -51DEGREES +ACCEPT4 +BACKTRACE -CLOSEFROM +CPU_AFFINITY +CRYPT_H -DEVICEATLAS +DL +EPOLL -EVPORTS +FUTEX +GETADDRINFO -KQUEUE +LIBCRYPT +LINUX_SPLICE +LINUX_TPROXY +LUA -MEMORY_PROFILING +NETFILTER +NS -OBSOLETE_LINKER +OPENSSL -OT -PCRE +PCRE2 +PCRE2_JIT -PCRE_JIT +POLL +PRCTL -PRIVATE_CACHE -PROCCTL +PROMEX -PTHREAD_PSHARED -QUIC +RT +SLZ -STATIC_PCRE -STATIC_PCRE2 +SYSTEMD +TFO +THREAD +THREAD_DUMP +TPROXY -WURFL -ZLIB

Default settings :
  bufsize = 16384, maxrewrite = 1024, maxpollevents = 200

Built with multi-threading support (MAX_THREADS=64, default=4).
Built with OpenSSL version : OpenSSL 3.0.2 15 Mar 2022
Running on OpenSSL version : OpenSSL 3.0.2 15 Mar 2022
OpenSSL library supports TLS extensions : yes
OpenSSL library supports SNI : yes
OpenSSL library supports : TLSv1.0 TLSv1.1 TLSv1.2 TLSv1.3
Built with Lua version : Lua 5.3.6
Built with the Prometheus exporter as a service
Built with network namespace support.
Built with libslz for stateless compression.
Compression algorithms supported : identity("identity"), deflate("deflate"), raw-deflate("deflate"), gzip("gzip")
Built with transparent proxy support using: IP_TRANSPARENT IPV6_TRANSPARENT IP_FREEBIND
Built with PCRE2 version : 10.39 2021-10-29
PCRE2 library supports JIT : yes
Encrypted password support via crypt(3): yes
Built with gcc compiler version 11.4.0

Available polling systems :
      epoll : pref=300,  test result OK
       poll : pref=200,  test result OK
     select : pref=150,  test result OK
Total: 3 (3 usable), will use epoll.

Available multiplexer protocols :
(protocols marked as <default> cannot be specified using 'proto' keyword)
              h2 : mode=HTTP       side=FE|BE     mux=H2       flags=HTX|CLEAN_ABRT|HOL_RISK|NO_UPG
            fcgi : mode=HTTP       side=BE        mux=FCGI     flags=HTX|HOL_RISK|NO_UPG
              h1 : mode=HTTP       side=FE|BE     mux=H1       flags=HTX|NO_UPG
       <default> : mode=HTTP       side=FE|BE     mux=H1       flags=HTX
            none : mode=TCP        side=FE|BE     mux=PASS     flags=NO_UPG
       <default> : mode=TCP        side=FE|BE     mux=PASS     flags=

Available services : prometheus-exporter
Available filters :
	[SPOE] spoe
	[CACHE] cache
	[FCGI] fcgi-app
	[COMP] compression
	[TRACE] trace

~~~

##### 7.3.2.1.2 编译安装 haproxy

~~~shell
#安装依赖软件
apt update
apt -y install  gcc make libssl-dev libpcre3 libpcre3-dev zlib1g-dev 
libreadline-dev libsystemd-dev
#获取lua软件
wget http://www.lua.org/ftp/lua-5.4.3.tar.gz
tar zxf lua-5.4.3.tar.gz -C /usr/local/
cd /usr/local/lua-5.4.3
make all test 
cd
#获取软件
wget https://www.haproxy.org/download/2.5/src/haproxy-2.5.0.tar.gz
tar xf haproxy-2.5.0.tar.gz -C /usr/local/src 
cd /usr/local/src/haproxy-2.5.0/
#定制编译变量
make -j $(nproc) ARCH=x86_64 TARGET=linux-glibc USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_CPU_AFFINITY=1 USE_PROMEX=1 USE_LUA=1 LUA_INC=/usr/local/lua-5.4.3/src/ LUA_LIB=/usr/local/lua-5.4.3/src/

#解析：
-j $(nproc) 指的是cpu的核数
#在 HAProxy 2.0.x - 2.3.x ，使用 EXTRA_OBJS 参数来进行 make 构建
EXTRA_OBJS="contrib/prometheus-exporter/service-prometheus.o"
#在 HAProxy 2.4.x 版本 ，使用 USE_PROMEX 参数来进行 make 构建：
make TARGET=linux-glibc USE_PROMEX=1 
 
#编译安装
make install PREFIX=/usr/local/haproxy
#定制命令软连接
ln -s /usr/local/haproxy/sbin/haproxy /usr/local/sbin/
/usr/local/sbin/haproxy -v
~~~

#### 7.3.2.2 定制 haproxy 服务功能

~~~shell
root@node2-112:~ 15:30:22 # cat /etc/haproxy/haproxy.cfg
global
	...

defaults
	...
frontend stats
    bind *:9999
    stats enable
    stats uri /haproxy-status
    stats refresh 10s
    # 添加此行实现 /metrics 暴露
    http-request use-service prometheus-exporter if { path /metrics }
# 配置解析：http-request 属性表明，开启了一个专属的metrics的url地址

root@node2-112:~ 15:30:47 # systemctl restart haproxy.service 
root@node2-112:~ 15:31:00 # ss -tunlp  | grep 9999
tcp   LISTEN 0      4096           0.0.0.0:9999      0.0.0.0:*    users:(("haproxy",pid=102471,fd=6))         
root@node2-112:~ 15:31:09 # 
~~~

![image-20251011153238481](Prometheus.assets/image-20251011153238481.png)

#### 7.3.2.3 修改 Prometheus 配置

~~~yaml
root@prometheus-221:~ 15:33:47 # tail -6 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "haproxy_buildin"
    static_configs: 
      - targets:
        - 192.168.121.112:9999
        labels:
          app: haproxy-buildin
root@prometheus-221:~ 15:33:50 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 15:33:53 # systemctl restart prometheus.service 
~~~

![image-20251011153418924](Prometheus.assets/image-20251011153418924.png)

## 7.4 Redis 监控

prometheus 提供了专属于 Redis 的服务监控工具 redis_exporter，我们可以借助于该模块，来实现 Redis 的基本监控。

https://github.com/oliver006/redis_exporter

### 7.4.1 基于二进制实现 redis_exporter

~~~shell
root@node2-112:~ 15:31:09 # apt update && apt -y install redis
root@node2-112:~ 15:37:30 # vim /etc/redis/redis.conf
bind 0.0.0.0
requirepass 123456

root@node2-112:~ 15:42:18 # wget https://github.com/oliver006/redis_exporter/releases/download/v1.78.0/redis_exporter-v1.78.0.linux-amd64.tar.gz
root@node2-112:~ 15:44:00 # tar xf redis_exporter-v1.78.0.linux-amd64.tar.gz  -C /usr/local/
root@node2-112:~ 15:44:13 # cd /usr/local/
root@node2-112:/usr/local 15:44:14 # ln -sv redis_exporter-v1.78.0.linux-amd64 redis_exporter 
'redis_exporter' -> 'redis_exporter-v1.78.0.linux-amd64'
root@node2-112:/usr/local 15:44:23 # cd redis_exporter/
root@node2-112:/usr/local/redis_exporter 15:44:26 # ls
LICENSE  README.md  redis_exporter
root@node2-112:/usr/local/redis_exporter 15:44:26 # mkdir bin 
root@node2-112:/usr/local/redis_exporter 15:44:28 # mv redis_exporter  bin/
root@node2-112:/usr/local/redis_exporter 15:44:31 # cd bin/
root@node2-112:/usr/local/redis_exporter/bin 15:44:44 # ./redis_exporter -redis.password 123456
INFO[0000] Redis Metrics Exporter v1.78.0    build date: 2025-10-07-03:23:23    sha1: 58a27ee694f71d747a8ca4eaff143a598ccf3871    Go: go1.25.1    GOOS: linux    GOARCH: amd64 
INFO[0000] Setting log level to "info"                  
INFO[0000] Providing metrics at :9121/metrics
~~~

### 7.4.2 配置 Prometheus 

~~~yaml
root@prometheus-221:~ 15:46:20 # tail -6 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "redis_buildin"
    static_configs: 
      - targets:
        - 192.168.121.112:9121
        labels:
          app: redis
root@prometheus-221:~ 15:46:22 # systemctl restart prometheus.service 
~~~

![image-20251011154653754](Prometheus.assets/image-20251011154653754.png)

## 7.5 nginx 监控

Nginx 默认自身没有提供 Json 格式的指标数据,可以通过下两种方式实现 Prometheus 监控

方法1：

通过nginx/nginx-prometheus-exporter容器配合nginx的stub状态页实现nginx的监控

方法2

需要先编译安装一个模块nginx-vts,将状态页转换为Json格式

再利用nginx-vts-exporter采集数据到Prometheus

### 7.5.1 nginx-prometheus-exporter 容器实现

#### 7.5.1.1 部署 nginx 和 docker

https://hub.docker.com/r/nginx/nginx-prometheus-exporter

![image-20251011154829341](Prometheus.assets/image-20251011154829341.png)

范例：基于 docker 实现

~~~shell
root@node3-113:~ 15:49:21 # apt install docker.io nginx -y

# 配置 nginx 开启状态页
root@node3-113:~ 15:56:44 # vim /etc/nginx/sites-enabled/default
   location /stub_status {
         stub_status;
   }
root@node3-113:~ 15:59:36 # nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@node3-113:~ 15:59:38 # 
root@node3-113:~ 16:00:05 # curl 127.1/stub_status
Active connections: 1 
server accepts handled requests
 1 1 1 
Reading: 0 Writing: 1 Waiting: 0 
root@node3-113:~ 16:00:17 #


# 运行 nginx-prometheus-exporter
root@node3-113:~ 16:08:03 # docker run -p 9113:9113 nginx/nginx-prometheus-exporter:latest --nginx.scrape-uri=http://localhost/stub_status
time=2025-10-11T08:08:09.946Z level=INFO source=exporter.go:126 msg=nginx-prometheus-exporter version="(version=1.5.0, branch=HEAD, revision=b14979c9f3634dcd5a2b158874e713beb3aca3d7)"
time=2025-10-11T08:08:09.947Z level=INFO source=exporter.go:127 msg="build context" build_context="(go=go1.25.1, platform=linux/amd64, user=goreleaser, date=2025-10-07T15:37:41Z, tags=unknown)"
time=2025-10-11T08:08:09.956Z level=INFO source=tls_config.go:347 msg="Listening on" address=[::]:9113
time=2025-10-11T08:08:09.959Z level=INFO source=tls_config.go:350 msg="TLS is disabled." http2=false address=[::]:9113




root@node3-113:~ 16:08:35 # curl -s 127.0.0.1:9113/metrics|grep nginx
# HELP nginx_exporter_build_info A metric with a constant '1' value labeled by version, revision, branch, goversion from which nginx_exporter was built, and the goos and goarch for the build.
# TYPE nginx_exporter_build_info gauge
nginx_exporter_build_info{branch="HEAD",goarch="amd64",goos="linux",goversion="go1.25.1",revision="b14979c9f3634dcd5a2b158874e713beb3aca3d7",tags="unknown",version="1.5.0"} 1
# HELP nginx_up Status of the last metric scrape
# TYPE nginx_up gauge
nginx_up 0
root@node3-113:~ 16:08:37 #
~~~

#### 7.5.1.2 配置 Prometheus

~~~yaml
[root@prometheus ~]#vim /usr/local/prometheus/conf/prometheus.yml
 - job_name: 'nginx_exporter'
   static_configs:
   - targets: ["192.168.121.113:9113"]
[root@prometheus ~]#systemctl reload prometheus.service
~~~

### 7.5.2 nginx-vts-exporter 实现

#### 7.5.2.1 编译安装 nginx 添加模块

https://github.com/vozlt/nginx-module-vts

#### 7.5.2.2 安装 nginx-vts-exporter

https://github.com/hnlq715/nginx-vts-exporter

范例：二进制安装 nginx-vts-exporter

~~~shell
[root@ubuntu2204 ~]#cd /usr/local/src/
[root@ubuntu2204 src]#wget https://github.com/hnlq715/nginx-vts-exporter/releases/download/v0.10.3/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz
[root@ubuntu2204 src]#tar xf nginx-vts-exporter-0.10.3.linux-amd64.tar.gz 
[root@ubuntu2204 src]#ls
nginx-vts-exporter-0.10.3.linux-amd64 nginx-vts-exporter-0.10.3.linuxamd64.tar.gz
[root@ubuntu2204 src]#cd nginx-vts-exporter-0.10.3.linux-amd64/
[root@ubuntu2204 nginx-vts-exporter-0.10.3.linux-amd64]#ls
LICENSE nginx-vts-exporter
[root@ubuntu2204 nginx-vts-exporter-0.10.3.linux-amd64]#mv nginx-vts-exporter 
/usr/local/bin/
#启动
[root@ubuntu2204 ~]#nginx-vts-exporter -
nginx.scrape_uri=http://10.0.0.200/status/format/json
2022/10/30 17:54:57 Starting nginx_vts_exporter (version=0.10.3, branch=HEAD, 
revision=8aa2881c7050d9b28f2312d7ce99d93458611d04)
2022/10/30 17:54:57 Build context (go=go1.10, user=root@56ca8763ee48, 
date=20180328-05:47:47)
2022/10/30 17:54:57 Starting Server at : :9913
2022/10/30 17:54:57 Metrics endpoint: /metrics
2022/10/30 17:54:57 Metrics namespace: nginx
2022/10/30 17:54:57 Scraping information from : 
http://10.0.0.200/status/format/json
#浏览器访问
http://10.0.0.200:9913/
~~~

#### 7.5.1.3 配置 Prometheus

~~~yaml
[root@ubuntu2204 ~]#vim /usr/local/prometheus/conf/prometheus.yml
.....
  - job_name: "nginx-vts-exporter"
   static_configs:
      - targets: ["10.0.0.200:9913"]
.....
[root@ubuntu2204 ~]#systemctl reload prometheus
~~~

#### 7.5.2.4 Grafana 展示

模板 2949

## 7.6 Consul 监控

Consul Exporter 可以实现对 Consul 的监控

需要为每个Consul实例部署consul-exporter，它负责将Consul的状态信息转为 Prometheus 兼容的指标格式并予以暴露。

### 7.6.1 部署 Consul

### 7.6.2 部署 Consul exporter

~~~shell
root@node1-111:~ 16:15:22 # wget https://github.com/prometheus/consul_exporter/releases/download/v0.13.0/consul_exporter-0.13.0.linux-amd64.tar.gz

root@node1-111:~ 19:13:35 # tar xf consul_exporter-0.13.0.linux-amd64.tar.gz -C /usr/local/
root@node1-111:~ 19:13:57 # cd /usr/local/
root@node1-111:/usr/local 19:14:00 # ln -sv consul_exporter-0.13.0.linux-amd64 consul_exporter 
'consul_exporter' -> 'consul_exporter-0.13.0.linux-amd64'
root@node1-111:/usr/local 19:14:12 # 


# 创建启动用户
root@node1-111:/usr/local/consul_exporter 19:14:40 # useradd -r consul
root@node1-111:/usr/local/consul_exporter 19:15:08 # getent passwd consul 
consul:x:997:997::/home/consul:/bin/sh
root@node1-111:/usr/local/consul_exporter 19:15:14 # 


# 创建 consul_exporter  service 文件
root@node1-111:~ 19:20:39 # cat /lib/systemd/system/consul_exporter.service
[Unit]
Description=consul_exporter
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target
[Service]
Type=simple
User=consul
EnvironmentFile=-/etc/default/consul_exporter
# 具体使用时，若consul_exporter与consul server不在同一主机时，consul server要指向实际的地址；
ExecStart=/usr/local/consul_exporter/consul_exporter\
            --consul.server="http://localhost:8500" \
            --web.listen-address=":9107" \
            --web.telemetry-path="/metrics" \
            --log.level=info \
            $ARGS
ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
Restart=always
[Install]
WantedBy=multi-user.target
root@node1-111:~ 19:20:43 # systemctl daemon-reload 
root@node1-111:~ 19:20:47 # systemctl restart consul_exporter.service 
root@node1-111:~ 19:20:59 # systemctl status consul_exporter.service 

~~~

![image-20251011192410948](Prometheus.assets/image-20251011192410948.png)

### 7.6.3 Prometheus 监控 consul

~~~yaml
vim /usr/local/prometheus/conf/prometheus.yml
.....
  - job_name: "consul_exporter"
   static_configs:
      - targets: ["10.0.0.203:9107"]
.....
systemctl reload prometheus.service
~~~

## 7.7 黑盒监控

### 7.7.1 黑盒监控说明

![image-20251011192533594](Prometheus.assets/image-20251011192533594.png)

黑盒监视也称远端探测，监测应用程序的外部，可以查询应用程序的外部特征

比如：是否开放相应的端口,并返回正确的数据或响应代码，执行icmp或者echo检查并确认收到响应

prometheus探测工具是通过运行一个blackbox exporter来探测远程目标，并公开在本地端点上

blackbox_exporter允许通过HTTP、HTTPS、DNS、TCP和ICMP等协议来探测端点状态

blackbox_exporter中，定义一系列执行特定检查的模块，例:检查正在运行的web服务器，或者DNS解析记录

blackbox_exporter运行时，它会在URL上公开这些模块和API

blackbox_exporter是一个二进制Go应用程序，默认监听端口9115

Github 链接

https://github.com/prometheus/blackbox_exporter

https://github.com/prometheus/blackbox_exporter/blob/master/blackbox.yml

https://github.com/prometheus/blackbox_exporter/blob/master/example.yml

### 7.7.2 black_exporter 安装

https://prometheus.io/download/#blackbox_exporter

#### 7.7.2.1 二进制安装

~~~shell
root@prometheus-221:~ 11:54:46 # wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.27.0/blackbox_exporter-0.27.0.linux-amd64.tar.gz

root@prometheus-221:~ 11:56:44 # tar xf blackbox_exporter-0.27.0.linux-amd64.tar.gz -C /usr/local 
root@prometheus-221:~ 11:56:52 # cd /usr/local
root@prometheus-221:/usr/local 11:57:22 # ln -sv blackbox_exporter-0.27.0.linux-amd64 blackbox_exporter
'blackbox_exporter' -> 'blackbox_exporter-0.27.0.linux-amd64'
root@prometheus-221:/usr/local 11:57:29 # cd blackbox_exporter/
root@prometheus-221:/usr/local/blackbox_exporter 11:57:32 # ls
blackbox_exporter  blackbox.yml  LICENSE  NOTICE
root@prometheus-221:/usr/local/blackbox_exporter 11:57:33 # mkdir bin conf 
root@prometheus-221:/usr/local/blackbox_exporter 11:57:39 # mv blackbox_exporter  bin/
root@prometheus-221:/usr/local/blackbox_exporter 11:57:47 # mv blackbox.yml conf/
root@prometheus-221:/usr/local/blackbox_exporter 11:57:52 # tree 
.
├── bin
│?? └── blackbox_exporter
├── conf
│?? └── blackbox.yml
├── LICENSE
└── NOTICE

2 directories, 4 files
root@prometheus-221:/usr/local/blackbox_exporter 11:57:56 #

# 默认配置文件无需修改
root@prometheus-221:~ 11:58:39 # cat /usr/local/blackbox_exporter/conf/blackbox.yml
modules:
  http_2xx:					# 名字
    prober: http			# 协议
    http:
      preferred_ip_protocol: "ip4"
  http_post_2xx:
    prober: http
    http:
      method: POST		# 支持 GET、POST，默认 GET
  tcp_connect:
    prober: tcp
  pop3s_banner:
    prober: tcp
    tcp:
      query_response:
      - expect: "^+OK"
      tls: true
      tls_config:
        insecure_skip_verify: false	# 启用远程探测证书检
  grpc:
    prober: grpc
    grpc:
      tls: true
      preferred_ip_protocol: "ip4"	# 探测的ip协议版本
  grpc_plain:
    prober: grpc
    grpc:
      tls: false
      service: "service1"
  ssh_banner:
    prober: tcp
    tcp:
      query_response:
      - expect: "^SSH-2.0-"
      - send: "SSH-2.0-blackbox-ssh-check"
  ssh_banner_extract:
    prober: tcp
    timeout: 5s
    tcp:
      query_response:
      - expect: "^SSH-2.0-([^ -]+)(?: (.*))?$"
        labels:
        - name: ssh_version
          value: "${1}"
        - name: ssh_comments
          value: "${2}"
  irc_banner:
    prober: tcp
    tcp:
      query_response:
      - send: "NICK prober"
      - send: "USER prober prober prober :prober"
      - expect: "PING :([^ ]+)"
        send: "PONG ${1}"
      - expect: "^:[^ ]+ 001"
  icmp:
    prober: icmp
  icmp_ttl5:
    prober: icmp
    timeout: 5s
    icmp:
      ttl: 5


# 创建 service 文件
root@prometheus-221:~ 12:01:44 # cat /lib/systemd/system/blackbox_exporter.service
[Unit]
Description=Prometheus Black Exporter
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/blackbox_exporter/bin/blackbox_exporter --config.file=/usr/local/blackbox_exporter/conf/blackbox.yml --web.listen-address=:9115
Restart=on-failure
LimitNOFILE=100000
[Install]
WantedBy=multi-user.target
root@prometheus-221:~ 12:01:47 # systemctl daemon-reload 
root@prometheus-221:~ 12:01:51 # systemctl enable --now blackbox_exporter.service 
Created symlink /etc/systemd/system/multi-user.target.wants/blackbox_exporter.service → /lib/systemd/system/blackbox_exporter.service.
root@prometheus-221:~ 12:02:01 # systemctl status blackbox_exporter.service 
● blackbox_exporter.service - Prometheus Black Exporter
     Loaded: loaded (/lib/systemd/system/blackbox_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2025-10-12 12:02:01 CST; 6s ago
   Main PID: 88046 (blackbox_export)
      Tasks: 8 (limit: 4514)
     Memory: 3.2M
        CPU: 50ms
     CGroup: /system.slice/blackbox_exporter.service
             └─88046 /usr/local/blackbox_exporter/bin/blackbox_exporter --config.file=/usr/local/blackbox_exporter/conf/blackbox.yml --web.listen-address=:9115

Oct 12 12:02:01 prometheus-221 systemd[1]: Started Prometheus Black Exporter.
Oct 12 12:02:01 prometheus-221 blackbox_exporter[88046]: time=2025-10-12T12:02:01.547+08:00 level=INFO source=main.go:88 msg="Starting blackbox_exporter" version="(v>
Oct 12 12:02:01 prometheus-221 blackbox_exporter[88046]: time=2025-10-12T12:02:01.547+08:00 level=INFO source=main.go:89 msg="(go=go1.24.4, platform=linux/amd64, use>
Oct 12 12:02:01 prometheus-221 blackbox_exporter[88046]: time=2025-10-12T12:02:01.549+08:00 level=INFO source=main.go:101 msg="Loaded config file"
Oct 12 12:02:01 prometheus-221 blackbox_exporter[88046]: time=2025-10-12T12:02:01.552+08:00 level=INFO source=tls_config.go:347 msg="Listening on" address=[::]:9115
Oct 12 12:02:01 prometheus-221 blackbox_exporter[88046]: time=2025-10-12T12:02:01.553+08:00 level=INFO source=tls_config.go:350 msg="TLS is disabled." http2=false ad>

# 监听 9115 端口
root@prometheus-221:~ 12:02:08 # ss -tunlp | grep 9115
tcp   LISTEN 0      4096                                  *:9115            *:*    users:(("blackbox_export",pid=88046,fd=3)) 
root@prometheus-221:~ 12:02:14 #
~~~

![image-20251012120505834](Prometheus.assets/image-20251012120505834.png)

> 同时其自身也暴露了 /metrics 接口

![image-20251012120546250](Prometheus.assets/image-20251012120546250.png)

#### 7.7.2.2 Docker 启动

~~~shell
docker run --rm -d -p 9115:9115 -v pwd:/config prom/blackbox-exporter:master --config.file=/config/blackbox.yml
~~~

### 7.7.3 Prometheus 配置定义监控规则

在 Prometheus 上定义实现具体的业务的监控规则的配置

#### 7.7.3.1 网络连通性监控

~~~yaml
root@prometheus-221:~ 13:41:22 # tail -16 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "ping_status_blackbox"
    metrics_path: "/probe"
    params:
      module: [icmp]
    static_configs: 
      - targets: 	# 探测的目标主机地址
        - www.baidu.com
        - www.google.com
    relabel_configs: 
      - source_labels: [__address__]	# 修改目标URL地址的标签[__address__]为__param_target,用于发送给blackbox使用
        target_label: __param_target
      - target_label: __address__		# 添加新标签.用于指定black_exporter服务器地址,此为必须项
        replacement: 192.168.121.221:9115 # 指定black_exporter服务器地址
      - source_labels: [__param_target]	# Grafana 使用此标签进行显示
        target_label: ipaddr

root@prometheus-221:~ 13:41:25 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 13:41:34 # systemctl restart prometheus.service 
~~~

![image-20251012134343841](Prometheus.assets/image-20251012134343841.png)

#### 7.7.3.2 TCP 端口连通性监控

~~~yaml
root@prometheus-221:~ 13:45:07 # tail -16 /usr/local/prometheus/conf/prometheus.yml

  - job_name: "tcp_status_blackbox"
    metrics_path: "/probe"
    params:
      module: [tcp_connect]
    static_configs: 
      - targets: 
        - www.baidu.com:80
    relabel_configs: 
      - source_labels: [__address__]
        target_label: __param_target
      - target_label: __address__
        replacement: 192.168.121.221:9115
      - source_labels: [__param_target]
        target_label: ipaddr

root@prometheus-221:~ 13:45:10 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 13:45:16 # systemctl restart prometheus.service 

~~~

![image-20251012134551513](Prometheus.assets/image-20251012134551513.png)

![image-20251012134606754](Prometheus.assets/image-20251012134606754.png)

#### 7.7.3.3 http/https 网站监控

~~~yaml
root@prometheus-221:~ 13:50:03 # tail -18 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "http_status_blackbox"
    metrics_path: "/probe"
    params:
      module: [http_2xx]
    static_configs: 
      - targets: 
        - https://www.baidu.com
        labels:
          instance: http_status
          group: web
    relabel_configs: 
      - source_labels: [__address__]
        target_label: __param_target
      - target_label: __address__
        replacement: 192.168.121.221:9115
      - source_labels: [__param_target]
        target_label: url

~~~

![image-20251012135042104](Prometheus.assets/image-20251012135042104.png)

![image-20251012134946433](Prometheus.assets/image-20251012134946433.png)

### 7.7.4 Grafana 展示

**Grafana** **导入模板** **9965 13587**

![image-20251012135358338](Prometheus.assets/image-20251012135358338.png)

# 八、Prometheus 实现容器监控

## 8.1 cAdvisor 介绍

![image-20251012135502698](Prometheus.assets/image-20251012135502698.png)

对于物理主机可以在其上安装Node Exporter实现监控，但是对于容器的监控并不适用

对于一些容器类型的服务应用来说，可以借助于一些专用工具的方式来实现监控，比如docker类型的容器应用，可以通过 cAdvisor 的方式来进行监控。

cadvisor(Container Advisor容器顾问) 是 Google 开源的一个容器监控工具，它以守护进程方式运行，用于收集、聚合、处理和导出正在运行容器的有关信息。具体来说，该组件对每个容器都会记录其资源隔离参数、历史资源使用情况、完整历史资源使用情况的直方图和网络统计信息。它不仅可以搜集一台机器上所有运行的容器信息，还提供基础查询界面和http接口，方便其他组件如Prometheus进行数据抓取

cAdvisor使用Go语言开发，对Node机器上的资源及容器进行实时监控和性能数据采集，包括CPU使用情况、内存使用情况、网络吞吐量及文件系统使用情况，利用Linux的cgroups获取容器的资源使用信息，可用于对容器资源的使用情况和性能进行监控。

在Kubernetes1.10之前cAdvisor内置在kubelet,通过启动参数–cadvisor-port可以定义cAdvisor对外提供服务的端口，默认为4194。可以通过浏览器访问,Kubernetes1.11之后不再内置,需自行安装

https://github.com/kubernetes/kubernetes/pull/65707

安装 cAdvisor 后,通过 http://cAdvisor-server:8080/metrics 暴露metrics

注意：一个 cAdvisor 仅对一台主机进行监控。在Kubernetes集群中可以通过DaemonSet方式自行安装在每个节点主机

项目主页：http://github.com/google/cadvisor

下载地址：

https://github.com/google/cadvisor/releases/latest

https://github.com/google/cadvisor/archive/refs/tags/v0.39.3.tar.gz

**cAdvisor** **工作原理**

![image-20251012135853975](Prometheus.assets/image-20251012135853975.png)

## 8.2 cAdvisor

在需要被监控 docker 的主机准备 docker 环境

~~~shell
root@node3-113:~ 13:59:58 # docker info
Client:
 Version:    28.2.2
 Context:    default
 Debug Mode: false


~~~

### 8.2.1 源码编译安装 cAdvisor

官方文档

https://github.com/google/cadvisor/blob/master/docs/development/build.md

范例: 编译安装cadvisor

~~~shell
# 安装 go 环境，必须在 1.14+ 版本,注意:不要使用 1.18 以上版
root@node3-113:~ 14:00:05 # wget https://studygolang.com/dl/golang/go1.17.6.linux-amd64.tar.gz
root@node3-113:~ 14:03:39 # tar xf go1.17.6.linux-amd64.tar.gz  -C /usr/local/
root@node3-113:~ 14:04:08 # ls -l /usr/local/go/
total 232
drwxr-xr-x  2 root root   4096 Jan  7  2022 api
-rw-r--r--  1 root root  55782 Jan  7  2022 AUTHORS
drwxr-xr-x  2 root root   4096 Jan  7  2022 bin
-rw-r--r--  1 root root     52 Jan  7  2022 codereview.cfg
-rw-r--r--  1 root root   1339 Jan  7  2022 CONTRIBUTING.md
-rw-r--r--  1 root root 107225 Jan  7  2022 CONTRIBUTORS
drwxr-xr-x  2 root root   4096 Jan  7  2022 doc
drwxr-xr-x  3 root root   4096 Jan  7  2022 lib
-rw-r--r--  1 root root   1479 Jan  7  2022 LICENSE
drwxr-xr-x 12 root root   4096 Jan  7  2022 misc
-rw-r--r--  1 root root   1303 Jan  7  2022 PATENTS
drwxr-xr-x  6 root root   4096 Jan  7  2022 pkg
-rw-r--r--  1 root root   1480 Jan  7  2022 README.md
-rw-r--r--  1 root root    397 Jan  7  2022 SECURITY.md
drwxr-xr-x 48 root root   4096 Jan  7  2022 src
drwxr-xr-x 26 root root  12288 Jan  7  2022 test
-rw-r--r--  1 root root      8 Jan  7  2022 VERSION

# 配置环境变量
root@node3-113:~ 14:05:49 # cat /etc/profile.d/go.sh
############################
# File Name: /etc/profile.d/go.sh
# Author: xuruizhao
# mail: xuruizhao00@163.com
# Created Time: Sun 12 Oct 2025 02:05:05 PM CST
############################
#!/bin/bash
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
root@node3-113:~ 14:05:51 # source /etc/profile.d/go.sh
root@node3-113:~ 14:05:52 # go version
go version go1.17.6 linux/amd64
root@node3-113:~ 14:05:55 #


# 获取源代码
root@node3-113:~ 14:05:55 # wget https://github.com/google/cadvisor/archive/refs/tags/v0.39.3.tar.gz
root@node3-113:~ 14:08:38 # tar xf v0.39.3.tar.gz -C /usr/local/
root@node3-113:~ 14:08:53 # cd /usr/local/
root@node3-113:/usr/local 14:08:57 # ln -sv cadvisor-0.39.3 cadvisor
'cadvisor' -> 'cadvisor-0.39.3'
root@node3-113:/usr/local 14:09:06 # cd cadvisor/
root@node3-113:/usr/local/cadvisor 14:09:11 # ls
accelerators  CHANGELOG.md  container        doc.go  go.mod       LICENSE   manager  README.md  summary        validate
AUTHORS       client        CONTRIBUTING.md  docs    go.sum       logo.png  metrics  resctrl    test.htdigest  version
build         cmd           deploy           events  info         machine   nvm      stats      test.htpasswd  watcher
cache         collector     devicemapper     fs      integration  Makefile  perf     storage    utils          zfs
root@node3-113:/usr/local/cadvisor 14:09:13 # 

# 获取软件依赖
# go env -w GOPROXY=https://goproxy.cn
root@node3-113:/usr/local/cadvisor 14:09:13 # go get -d github.com/google/cadvisor

# 查看go环境变量
go env


#Ubuntu系统
apt -y install gcc make libpfm4 libpfm4-dev jq
#rhel系列
yum -y install gcc make
#编译安装cadvisor
make build

# 确认效果
root@node3-113:/usr/local/cadvisor 14:16:49 # ./cadvisor --help
Usage of ./cadvisor:
  -add_dir_header
    	If true, adds the file directory to the header of the log messages
  -allow_dynamic_housekeeping
    	Whether to allow the housekeeping interval to be dynamic (default true)
  -alsologtostderr
    	log to standard error as well as files
  -application_metrics_count_limit int
    	Max number of application metrics to store (per container) (default 100)
  -boot_id_file string
    	Comma-separated list of files to check for boot-id. Use the first one that exists. (default "/proc/sys/kernel/random/boot_id")
  -bq_account string
    	Service account email
  -bq_credentials_file string
    	Credential Key file (pem)

# 启动cadvisor
root@node3-113:/usr/local/cadvisor 14:18:05 # ./cadvisor ?-port=8080 &>>/var/log/cadvisor.log &
[1] 67041
root@node3-113:/usr/local/cadvisor 14:18:36 # 
~~~

![image-20251012141859894](Prometheus.assets/image-20251012141859894.png)

![image-20251012141935469](Prometheus.assets/image-20251012141935469.png)

### 8.2.2 Docker 方式安装 cAdvisor

安装说明

https://github.com/google/cadvisor/

cAdvisor 版本
https://github.com/google/cadvisor/releases

~~~shell
# 拉取镜像
#从google下载最新版的docker镜像,需要科学上网
docker pull gcr.io/cadvisor/cadvisor:v0.49.1
docker pull gcr.io/cadvisor/cadvisor:v0.47.0
docker pull gcr.io/cadvisor/cadvisor:v0.37.0
#从国内镜像下载
docker pull wangxiaochun/cadvisor:v0.49.1
docker pull wangxiaochun/cadvisor:v0.47.0
docker pull wangxiaochun/cadvisor:v0.45.0
docker pull wangxiaochun/cadvisor:v0.37.0
#代理网站下载:https://dockerproxy.com/
docker pull gcr.dockerproxy.com/cadvisor/cadvisor:v0.49.1
#第三方镜像
https://hub.docker.com/r/zcube/cadvisor/tags
~~~

~~~bash
# 运行容器
root@node3-113:~ 18:16:39 # docker image ls
REPOSITORY                        TAG       IMAGE ID       CREATED        SIZE
nginx/nginx-prometheus-exporter   latest    0ba32d7c37e7   4 days ago     14.4MB
gcr.io/cadvisor/cadvisor-amd64    v0.52.1   de1f4a4d7753   6 months ago   80.7MB
root@node3-113:~ 18:16:54 #  docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor-amd64:v0.52.1
37a2c86fec63184ceb11d2e705d0afccd193bbc6900b926f86b796f365407918
root@node3-113:~ 18:17:24 # docker ps -l
CONTAINER ID   IMAGE                                    COMMAND                  CREATED          STATUS                             PORTS                                         NAMES
37a2c86fec63   gcr.io/cadvisor/cadvisor-amd64:v0.52.1   "/usr/bin/cadvisor -…"   12 seconds ago   Up 11 seconds (health: starting)   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp   cadvisor
root@node3-113:~ 18:17:34 # ss -tunlp | grep 8080
tcp   LISTEN 0      4096           0.0.0.0:8080       0.0.0.0:*    users:(("docker-proxy",pid=67652,fd=7))                                                                                             
tcp   LISTEN 0      4096              [::]:8080          [::]:*    users:(("docker-proxy",pid=67660,fd=7))                                                                                             
root@node3-113:~ 18:17:41 #


# API
http://192.168.121.113:8080/
http://192.168.121.113:8080/metrics
~~~

## 8.3 Prometheus 配置

```shell

root@prometheus-221:~ 18:20:34 # tail -4 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "cAdvisor"
    static_configs:
      - targets:
        - 192.168.121.113:8080
root@prometheus-221:~ 18:20:39 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 18:20:47 # systemctl restart prometheus.service 
root@prometheus-221:~ 18:20:52 # 
```

![image-20251012182112045](Prometheus.assets/image-20251012182112045.png)

## 8.4 cAdvisor 常见指标

https://github.com/google/cadvisor/blob/master/metrics/testdata/prometheus_metrics

指标说明

```shell
container_tasks_state  # gauge类型，容器特定状态的任务数,根据不同的pod_name和state有600+的不同label.
container_memory_failures_total  #counter类型，内存分配失败的累积计数,根据不同的pod_name和state有600+的不同label.
container_network_receive_errors_total  #counter类型，容器网络接收时遇到的累计错误数。
container_network_transmit_bytes_total  #counter类型，容器发送传输的累计字节数。
container_network_transmit_packets_dropped_total  #counter类型，容器传输时丢弃的累计包数
container_network_transmit_packets_total  #counter类型，传输数据包的累计计数
container_network_transmit_errors_total  #counter类型，传输时遇到的累积错误数
container_network_receive_bytes_total  #counter类型，收到的累计字节数
container_network_receive_packets_dropped_total  #counter类型，接收时丢弃的累计数据包数
container_network_receive_packets_total  #counter类型，收到的累计数据包数
container_spec_cpu_period  #gauge类型，容器的CPU period。
container_spec_memory_swap_limit_bytes  #容器swap内存交换限制字节
container_memory_failcnt  #counter类型，内存使用次数达到限制
container_spec_memory_reservation_limit_bytes  #容器规格内存预留限制字节
container_spec_cpu_shares  #gauge类型，
container_spec_memory_limit_bytes  #容器规格内存限制字节
container_memory_max_usage_bytes  #gauge类型，以字节为单位记录的最大内存使用量
container_cpu_load_average_10s  #gauge类型，最近10秒钟内的容器CPU平均负载值。
container_memory_rss  #gauge类型，容器RSS的大小（以字节为单位）
container_start_time_seconds  #gauge类型，从Unix纪元开始的容器开始时间（以秒为单位）。
container_memory_mapped_file  #gauge类型，内存映射文件的大小（以字节为单位）
container_cpu_user_seconds_total  #conter类型，累计CPU user 时间（以秒为单位）
container_memory_cache  #gauge类型，内存的cache字节数。
container_memory_working_set_bytes  #gague类型，当前工作集（以字节为单位）
container_cpu_system_seconds_total  #conter类型，累计CPU system时间（以秒为单位）
container_memory_swap  #gauge类型，容器交换使用量（以字节为单位）
container_memory_usage_bytes  #gauge类型，当前内存使用情况（以字节为单位），包括所有内存，无论何时访问
container_last_seen  #gauge类型，上一次export看到此容器的时间
container_fs_writes_total  #counter类型，累计写入次数
container_fs_reads_total   #counter类型，类型读取次数
container_cpu_usage_seconds_total  #counter类型，累计消耗CPU的总时间
container_fs_reads_bytes_total  #容器读取的总字节数
container_fs_writes_bytes_total  #容器写入的总字节数
container_fs_sector_reads_total  #counter类型，扇区已完成读取的累计计数
container_fs_inodes_free  #gauge类型，可用的Inode数量
container_fs_io_current  #gauge类型，当前正在进行的I/O数
container_fs_io_time_weighted_seconds_total  #counter类型，累积加权I/O时间（以秒为单位）
container_fs_usage_bytes  #gauge类型，此容器在文件系统上使用的字节数
container_fs_limit_bytes  #gauge类型，此容器文件系统上可以使用的字节数
container_fs_inodes_total  #gauge类型，inode数
container_fs_sector_writes_total  #counter类型，扇区写入累计计数
container_fs_io_time_seconds_total  #counter类型，I/O花费的秒数累计
container_fs_writes_merged_total  #counter类型，合并的累计写入数
container_fs_reads_merged_total  #counter类型，合并的累计读取数
container_fs_write_seconds_total  #counter类型，写花费的秒数累计
container_fs_read_seconds_total   #counter类型，读花费的秒数累计
container_cpu_cfs_periods_total  #counter类型，执行周期间隔时间数
container_cpu_cfs_throttled_periods_total  #counter类型，节流周期间隔数
container_cpu_cfs_throttled_seconds_total  #counter类型，容器被节流的总时间
container_spec_cpu_quota  #gauge类型，容器的CPU配额
machine_memory_bytes  #gauge类型，机器上安装的内存量
scrape_samples_post_metric_relabeling
cadvisor_version_info
scrape_duration_seconds
machine_cpu_cores  #gauge类型，机器上的CPU核心数
container_scrape_error  #gauge类型，如果获取容器指标时出错，则为1，否则为0
scrape_samples_scraped
```

常见指标

https://www.bookstack.cn/read/prometheus-book/exporter-use-prometheus-monitorcontainer.md

| 指标名称                               | 类型    | 含义                                        |
| -------------------------------------- | ------- | ------------------------------------------- |
| container_cpu_load_average_10s         | gauge   | 过去10秒容器CPU的平均负载                   |
| container_cpu_usage_seconds_total      | counter | 容器在每个CPU内核上的累积占用时间(单位：秒) |
| container_cpu_system_seconds_total     | counter | System CPU累积占用时间（单位：秒）          |
| container_cpu_user_seconds_total       | counter | User CPU累积占用时间（单位：秒）            |
| container_fs_usage_bytes               | gauge   | 容器中文件系统的使用量(单位：字节)          |
| container_fs_limit_bytes               | gauge   | 容器可以使用的文件系统总量(单位：字节)      |
| container_fs_reads_bytes_total         | counter | 容器累积读取数据的总量(单位：字节)          |
| container_fs_writes_bytes_total        | counter | 容器累积写入数据的总量(单位：字节)          |
| container_memory_max_usage_bytes       | gauge   | 容器的最大内存使用量（单位：字节）          |
| container_memory_usage_bytes           | gauge   | 容器当前的内存使用量（单位：字节)           |
| container_spec_memory_limit_bytes      | gauge   | 容器的内存使用量限制                        |
| machine_memory_bytes                   | gauge   | 当前主机的内存总量                          |
| container_network_receive_bytes_total  | counter | 容器网络累积接收数据总量（单位：字节）      |
| container_network_transmit_bytes_total | counter | 容器网络累积传输数据总量（单位：字节）      |

范例：

容器CPU使用率

```shell
sum(irate(container_cpu_usage_seconds_total{image!="",name="redis"}[1m]))without (cpu)
```

## 8.5 Grafana 展示

193或14282

# 九、Prometheus Federation

## 9.1 Prometheus Federation 说明

https://prometheus.io/docs/prometheus/latest/federation/

在生产环境中，一个Prometheus服务节点所能接管的主机数量有限。只使用一个prometheus节点，随着监控数据的持续增长，将会导致压力越来越大

可以采用prometheus的集群联邦模式，即在原有 Prometheus的Master 节点基础上,再部署多个prometheus的Slave 从节点，分别负责不同的监控数据采集，而Master节点只负责汇总数据与Grafana 数据展示

联邦模式允许 Prometheus 服务器从另一个 Prometheus 服务器抓取特定数据。

联邦有不同的用例。 通常，它用于实现可扩展的Prometheus监控设置或将相关指标从一个服务的Prometheus拉到另一个服务。

联邦模式有分层联邦和跨服务联邦两种模式，分层联邦较为常用，且配置简单。

**分层联邦**

分层联合允许Prometheus扩展到具有数十个数据中心和数百万个节点的环境。 在此用例中，联合拓扑类似于树，较高级别的Prometheus服务器从较大数量的从属服务器收集聚合时间序列数据。

例如：设置可能包含许多高度详细收集数据的每个数据中心Prometheus服务器（实例级深入分析），以及一组仅收集和存储聚合数据的全局Prometheus服务器（作业级向下钻取） ）来自那些本地服务器。 这提供了聚合全局视图和详细的本地视图。

**跨服务联邦**

在跨服务联合中，一个服务的 Prometheus 服务器配置为从另一个服务的Prometheus服务器中提取所选数据，以便对单个服务器中的两个数据集启用警报和查询。

例如：运行多个服务的集群调度程序可能会暴露有关在集群上运行的服务实例的资源使用情况信息（如内存和CPU使用情况）。 另一方面，在该集群上运行的服务仅公开特定于应用程序的服务指标。 通常，这两组指标都是由单独的Prometheus服务器抓取的。 使用联合，包含服务级别度量标准的Prometheus服务器可以从群集Prometheus中提取有关其特定服务的群集资源使用情况度量标准，以便可以在该服务器中使用这两组度量标准。

**全球跨数据中心的可观测性**

全球化布局的大型集群的可观测性，对于k8s集群的日常保障至关重要。如何在纷繁复杂的网络环境下高效、合理、安全、可扩展的采集各个数据中心中目标集群的实时状态指标，是可观测性设计的关键与核心。我们需要兼顾区域化数据中心、单元化集群范围内可观测性数据的收集，以及全局视图的可观测性和可视化。基于这种设计理念和客观需求，全球化可观测性必须使用多级联合方式，也就是边缘层的可观测性实现下沉到需要观测的集群内部，中间层的可观测性用于在若干区域内实现监控数据的汇聚，中心层可观测性进行汇聚、形成全局化视图以及告警。样设计的好处在于可以灵活的在每一级别层内进行扩展以及调整，适合于不断增长的集群规模，相应的其他级别只需调整参数，层次结构清晰；网络结构简单，可以实现内网数据穿透到公网并汇聚。

针对该全球化布局的大型集群的监控系统设计，对于保障集群的高效运转至关重要，我们的设计理念是在全球范围内将各个数据中心的数据实时收集并聚合，实现全局视图查看和数据可视化，以及故障定位、告警通知。进入云原生时代，Prometheus作为CNCF中第二个毕业的项目，天生适用于容器场景，Prometheus 与 Kubernetes 结合一起，实现服务发现和对动态调度服务的监控，在各种监控方案中具有很大的优势，实际上已经成为容器监控方案的标准，所以我们也选择了Prometheus作为方案的基础。

针对每个集群，需要采集的主要指标类别包括：

- OS指标，例如节点资源（CPU, 内存，磁盘等）水位以及网络吞吐
- 元集群以及用户集群K8s master指标，例如kube-apiserver, kube-controller-manager, kubescheduler等指标
- K8s组件（kubernetes-state-metrics，cadvisor）采集的关于K8s集群状态
- etcd指标，例如etcd写磁盘时间，DB size，Peer之间吞吐量等等。

当全局数据聚合后，AlertManager对接中心Prometheus，驱动各种不同的告警通知行为，例如钉钉、邮件、短信等方式。

**监控告警架构**

为了合理的将监控压力负担分到到多个层次的Prometheus并实现全局聚合，我们使用了联邦Federation的功能。在联邦集群中，每个数据中心部署单独的Prometheus，用于采集当前数据中心监控数据，并由一个中心的Prometheus负责聚合多个数据中心的监控数据。基于Federation的功能，我们设计的全球监控架构图如下，包括监控体系、告警体系和展示体系三部分。监控体系按照从元集群监控向中心监控汇聚的角度，呈现为树形结构，可以分为三层：

**边缘** **Prometheus**

为了有效监控元集群K8s和用户集群K8s的指标、避免网络配置的复杂性，将Prometheus下沉到每个元集群内

**级联** **Prometheus**

级联Prometheus的作用在于汇聚多个区域的监控数据。级联Prometheus存在于每个大区域，例如中国区，欧洲美洲区，亚洲区。每个大区域内包含若干个具体的区域，例如北京，上海，东京等。随着每个大区域内集群规模的增长，大区域可以拆分成多个新的大区域，并始终维持每个大区域内有一个级联Prometheus，通过这种策略可以实现灵活的架构扩展和演进。

**中心** **Prometheus**

中心Prometheus用于连接所有的级联 Prometheus，实现最终的数据聚合、全局视图和告警。为提高可靠性，中心Prometheus使用双活架构，也就是在不同可用区布置两个Prometheus中心节点，都连接相同的下一级Prometheus。

![image-20251012183551624](Prometheus.assets/image-20251012183551624.png)

## 9.2 实战案例：Prometheus Federation 部署

![image-20251012184029454](Prometheus.assets/image-20251012184029454.png)

| 地址            | 角色                                   |
| --------------- | -------------------------------------- |
| 192.168.121.221 | Prometheus Master                      |
| 192.168.121.111 | Prometheus Federation1、Node Exporter1 |
| 192.168.121.112 | Prometheus Federation2、Node Exporter2 |
| 192.168.121.113 | Node Exporter3                         |
| 192.168.121.114 | Node Exporter4                         |

### 9.2.1 部署 Prometheus Master

所有联邦节点和Prometheus的主节点安装方法是一样的

~~~shell
bash install_prometheus.sh
~~~

### 9.2.2 部署 Prometheus Federation

所有联邦节点和Prometheus的主节点安装方法是一样的

~~~shell
bash install_prometheus.sh
~~~

### 9.2.3 部署 Node Exporter

在所有被监控的节点上安装 Node Exporter,安装方式一样

```shell
bash  install_node_exporter.sh
```

### 9.2.4 配置 Prometheus Federation 监控 Node Exporter

**Prometheus Federation1**

```yaml
root@node1-111:~ 18:52:43 # tail -4 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "node-exporter"
    static_configs:
      - targets:
        - 192.168.121.111:9100
root@node1-111:~ 18:52:47 # /usr/local/prometheus/bin/promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@node1-111:~ 18:53:08 # systemctl restart prometheus.service 
root@node1-111:~ 18:53:14 # 
```

**Prometheus Federation2**

~~~shell
root@node2-112:~ 18:54:07 # tail -5 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "node-exporter"
    static_configs:
      - targets:
        - 192.168.121.112:9100

root@node2-112:~ 18:54:11 # /usr/local/prometheus/bin/promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@node2-112:~ 18:54:19 # systemctl restart prometheus.service 
root@node2-112:~ 18:54:26 #
~~~

### 9.2.5 配置 Prometheus Master 管理 Prometheus Federation

在任何给定的Prometheus 服务器上，/federate端点允许检索该服务器中所选时间序列集的当前值。

必须至少指定一个match[] URL参数才能选择要公开的系列。 每个match[]参数都需要指定一个即时向量选择器。 如果提供了多个match[]参数，则选择所有匹配系列的并集。

要将指标从一个服务器采集至另一个服务器，需要将目标Prometheus服务器配置为从源服务器的/federate端点进行刮取，同时还启用honor_labels scrape选项（以不覆盖源服务器公开的任何标签）并传入所需的 match[]参数。

范例: 配置 Prometheus 主节点管理 Prometheus 联邦节点

~~~yaml
root@prometheus-221:~ 18:59:29 # tail -24 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "federation-111"
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate   # 指定采集端点的路径,默认为/federate
    params:
      'match[]':
        - '{job="prometheus"}'
        - '{job="node-exporter"}'
        - '{__name__=~"job:.*"}'
    static_configs:
      - targets:
        - 192.168.121.111:9090
        # 指定联邦节点prometheus节点地址,如果在k8s集群内,需要指定k8s的SVC的NodePort的地址信息  
  - job_name: "federation-112"
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
      # 指定只采集指定联邦节点的Job名称对应的数据,默认不指定不会采集任何联邦节点的采集的数据
        - '{job="prometheus"}'
        - '{job="node-exporter"}'
      # 指定采集联邦节点的job名称,和联邦节点配置的job_name必须匹配，如果不匹配则不会采集
        - '{__name__=~"job:.*"}'
      # 指定采集job:开头的job_name，多个匹配条件是或的关系
    static_configs:
      - targets:
        - 192.168.121.112:9090
root@prometheus-221:~ 18:59:32 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 18:59:42 # systemctl restart prometheus.service 
root@prometheus-221:~ 18:59:49 # 
~~~

### 9.2.6 Prometheus Federation 验证

![image-20251012190308064](Prometheus.assets/image-20251012190308064.png)

查看指定指标node_os_info,可以看到Node节点上的数据如下

![image-20251012190624743](Prometheus.assets/image-20251012190624743.png)

Grafana导入**8919**模板

### 9.2.7 在联邦节点添加新的主机

在联邦节点再添加新的node exporter,观察数据

```yaml
root@node1-111:~ 19:07:19 # tail -5 /usr/local/prometheus/conf/prometheus.yml
  - job_name: "node-exporter"
    static_configs:
      - targets:
        - 192.168.121.111:9100
        - 192.168.121.113:9100
root@node1-111:~ 19:07:24 # systemctl restart prometheus.service 

```

![image-20251012190820090](Prometheus.assets/image-20251012190820090.png)

# 十、Prometheus 存储

## 10.1 Prometheus 本地存储

### 10.1.1 Prometheus TSDB 数据库

Prometheus 默认提供了本地存储（TSDB）时序型数据库的存储方式

早期是一个单独的TSDB项目 ，从2.1.x版本后不单独维护这个项目，直接将这个项目合并到了 prometheus 的主干上。

Prometheus内置TSDB经历了三个版本

- v1.0: 基于LevelDB数据库(Google基于C实现的K/V数据库)，性能不高，每秒只能接收50000个样本
- v2.0: 基于LevelDB数据库，但使用了Facebook的Gorilla压缩算法，极大地压缩了单个样本的大小，每个采样数据仅仅占用3.5byte左右空间，每秒可接收的样本提升到80000个
- v3.0: 基于自研的Prometheus数据库,由Prometheus 2.0时引入，是一个独立维护的TSDB开源项目;在单机上，每秒可处理数百万个样本

### 10.1.2 Prometheus TSDB 数据存储机制

Prometheus的存储结构 TSDB是参考了Facebook的Gorilla之后自行实现的。

参考文章《Gorilla: A Fast, Scalable, In-Memory Time Series Database》可以对Prometheus为何采用这样的存储结构有着更为清晰的理解

![image-20251013164931859](Prometheus.assets/image-20251013164931859.png)

- 最新的数据是保存在内存中的，并同时写入至预写日志（WAL）
- 以每2小时为一个时间窗口，将内存中的数据存储为一个单独的 Block
- Block会被压缩及合并历史Block块，压缩合并后Block数量会减少
- Block的大小并不固定，但最小会保存两个小时的数据
- 后续生成的新数据保存在内存和WAL中，重复以上过程

### 10.1.3 Prometheus 数据目录结构

![image-20251013165028224](Prometheus.assets/image-20251013165028224.png)

PTSDB本地存储使用自定义的文件结构。

Prometheus 默认将数据存储在安装目录下的./data/目录

在./data/目录下类似如01GH5S5W4PDFXCS40VF7NZCP0G形式的目录为2小时块Block目录

每个Block块都有独立的目录,这些目录叫做2小时块。

每个2小时块目录包含一个chunks子目录（包含那个时间窗口里的所有时间序列）、元数据文件meta.json、索引文件index、tombstones

- chunks 目录

  用于保存时序数据文件

  chunks目录中的样例被分组到一个或多个段文件中，各Chunk文件以数字编号,比如:000001

  每个chunk文件的默认最大上限为512MB，如果达到上限则截断并创建为另一 个Chunk

- index 文件

  索引文件，它是Prometheus TSDB实现高效查询的基础

  可以通过Metrics Name和Labels查找时间序列数据在chunk文件中的位置

  索引文件指标名称和标签索引到chunks目录中的时间序列上

- tombstones 文件

  用于对数据进行软删除，不会立即删除块段（chunk segment）中的数据，即“ 标记删除”，以降低删除操作的开销

  删除的记录并保存于墓碑 tombstones文件中，而读取时间序列上的数据时，会基于tombstones进行过滤已经删除的部分

- meta.json 文件

  block的元数据信息，这些元数据信息是block的合并、删除等操作的基础依赖

范例: 查看本地存储数据

~~~shell
root@prometheus-221:~ 17:11:30 # tree /usr/local/prometheus/data/ -L 1
/usr/local/prometheus/data/
├── 01K69SM65TYB1N0YVBKJPA2QWF
├── 01K6AJ29M5CZJ6ZVV0FHATWXNG
├── 01K6CFW05FPWPXYFX585SA54X2
├── 01K6QVDHTJDB4QC8Z677PRHT2W
├── 01K6SEZYD4S2SBBSBZG9YVD2C1
├── 01K6T0ERNYX6SYXCQ92QFPV0JD
├── 01K71YGF6HH54C599CVZAHMPKH
├── 01K762GAWB5FGE5990R1R2Q4YY
├── 01K76BD6NVFFC7256NTHGEAB1J
├── 01K7913GKZH6Q7BA5ZT2BEJR8A
├── 01K79EV17YB2K9ES1P7W0CYX99
├── 01K7BKGCJ4FBF03RDSX4NSJF0V
├── 01K7C17MBRC6MQ1ZZSX0RH5F4P
├── 01K7CEZ7Y13ZZNDH4QSF9BAY03
├── 01K7ECN7R207H97F6J87W8GK7P
├── 01K7ECNDCNFW6H0VGQT886HY7G
├── 01K7ECNF81J7V2V84JXGEJK3WT
├── chunks_head
├── lock
├── queries.active
└── wal
~~~

### 10.1.4 WAL Write-Ahead Logging

Head块是数据库位于内存中的部分，Block 是磁盘上不可更改的持久块,而预写日志(WAL) 用于辅助完成持久写入

传入的样本(k/v)首先会进入Head，并在内存中停留一段时间默认2小时，然后即会被刷写到磁盘并映射回内存中(M-map) 

内存存储的只是引用而已。使用内存映射，我们可以在需要的时候使用该引用将 chunk 动态加载到内存

当这些内存映射的块Chunks 或内存中的Chunks 块老化到一定程度时，它会将作为持久块刷入到磁盘

随着它们的老化进程，将合并更多的块，最在超过保留期限后被删除

WAL是数据库中发生的事件的顺序日志，在写入/修改/删除数据库中的数据之前，首先将事件记录附加) 到WAL中，然后在数据库中执行必要的操作

WAL用于帮助TSDB先写日志，再写磁盘上的Block

使用WAL技术可以方便地保证原子性、重试等

WAL被分割为默认为128MB大小的文件段，它们都位于WAL目录下

WAL日志的数量及截断的位置则保存于checkpoint文件中，该文件的内容要同步写入磁盘，以确保其可靠性

### 10.1.5 Prometheus 压缩机制

![image-20251013165256214](Prometheus.assets/image-20251013165256214.png)

Prometheus将最近的数据保存在内存中，这样查询最近的数据会变得非常快，然后通过一个compactor定时将数据打包到磁盘。

数据在内存中最少保留2个小时(storage.tsdb.min-block-duration)。

之所以设置2小时这个值，应该是Gorilla那篇论文中上图观察得出的结论

即压缩率在2小时时候达到最高，如果保留的时间更短，就无法最大化的压缩

最新的数据是保存在内存中的，并同时写入至磁盘上的预写日志（WAL），每一次动作都会记录到预写日志中。

预写日志文件被保存在wal目录中，以128MB的段形式存在

这些预写日志文件包含尚未压缩的原始数据，因此它们比常规的块文件大得多

prometheus至少保留3个预写日志文件

高流量的服务器可能会保留多于3个的预写日志文件，以至少保留2个小时的原始数据。

如果prometheus 崩溃时，就会重放这些日志，因此就能恢复数据

2小时块最终在后台会被压缩成更长久的块

### 10.1.6 Prometheus 配置本地存储相关选项

```shell

--storage.tsdb.path           #数据存储位置，默认是安装和录下的data子目录。
--storage.tsdb.retention.time #保留时间，默认是15天，过15天之后就删除。该配置会覆盖--storage.tsdb.retention的值。
--storage.tsdb.retention.size #要保留的块Block的最大字节数(不包括WAL大小)。比如:100GB,支持单位: B,KB, MB, GB, TB, PB, EB如果达到指定大小,则最旧的数据会首先被删除。默认为0或禁用，注意：此值不是指定每个段文件chunk的大小
#注意：上面两个参数值retention.time和retention.size只要有一个满足条件，就会删除旧的数据
--storage.tsdb.wal-compression #开启预写日志的压缩,默认开启

磁盘空间公式
needed_disk_space = retention_time_seconds * ingested_samples_per_second * bytes_per_sample
#retention_time_seconds：保留时间
#ingested_samples_per_second：样本数
#bytes_per_sample：每个样本大小
```

磁盘的最小尺寸主要取决于：wal目录（wal和checkpoint）和chunks_head目录（m-mapped head chunks）的峰值空间（每2小时会达到一次峰值）。

单节点情况下可以满足大部分用户的需求，但本地存储阻碍了prometheus集群化的实现，因此在集群中可以采用其他时序性数据库来替代，比如victoriametrics,thanos和influxdb 等

## 10.2 Prometheus 远程存储 VictoriaMetrics

### 10.2.1VictoriaMetrics 介绍

Prometheus 默认的本地存储存在单点的可用性和性能瓶颈问题

Prometheus的远程存储可以解决以上问题，远程存储有多种方案，比如：VictoriaMetrics，Thanos（灭霸） 和 influxdb，也可以通过adapter适配器间接的 存储在Elasticsearch或PostgreSQL中

VictoriaMetrics(VM) 是一个支持高可用、经济高效且可扩展的监控解决方案和时间序列数据库，可用于Prometheus 监控数据做长期远程存储。Thanos 方案也可以用来解决 Prometheus 的高可用和远程存储的问题

相对于 Thanos，VictoriaMetrics 主要是一个可水平扩容的本地全量持久化存储方案，性能比thanos性能要更好

而 Thanos不是本地全量的，它很多历史数据是存放在对象存储当中的，如果要查询历史数据都要从对象存储当中去拉取，这肯定比本地获取数据要慢，VictoriaMetrics要比Thanos性能要好

VictoriaMetrics具有以下突出特点：

https://github.com/VictoriaMetrics/VictoriaMetrics

官网

https://victoriametrics.com/

https://github.com/VictoriaMetrics/VictoriaMetrics

官方文档

https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html

VictoriaMetrics 分为单节点和集群两个方案

官方建议如果采集数据点(data points)低于 100w/s时推荐单节点，但不支持告警。

- 集群支持数据水平拆分
- 常见部署方式

基于二进制单机安装

- 基于集群安装
- 基于 Docker 运行
- 基于 Docker Compose 安装

### 10.2.2 VictoriaMetrics 单机部署

#### 10.2.2.1 基于二进制单机部署

##### 10.2.2.1.1 基于二进制安装

下载

https://github.com/VictoriaMetrics/VictoriaMetrics/releases

~~~shell
root@node1-111:/usr/local 17:24:18 #  wget https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.82.1/victoria-metrics-linux-amd64-v1.82.1.tar.gz

root@node1-111:~ 17:23:35 # tar xf victoria-metrics-linux-amd64-v1.82.1.tar.gz -C /usr/local
root@node1-111:~ 17:23:45 # cd /usr/local
root@node1-111:/usr/local 17:23:59 # ls
bin                                 games                                lib                                 node_exporter                    sbin
consul_exporter                     haproxy_exporter                     man                                 node_exporter-1.7.0.linux-amd64  share
consul_exporter-0.13.0.linux-amd64  haproxy_exporter-0.15.0.linux-amd64  mysqld_exporter-0.18.0.linux-amd64  prometheus                       src
etc                                 include                              mysql_exporter                      prometheus-3.5.0.linux-amd64     victoria-metrics-prod
root@node1-111:/usr/local 17:23:59 # mv victoria-metrics-prod /usr/local/bin/
root@node1-111:/usr/local 17:24:10 # ls -l  /usr/local/bin/victoria-metrics-prod 
-rwxr-xr-x 1 xuruizhao xuruizhao 18627904 Oct 14  2022 /usr/local/bin/victoria-metrics-prod
root@node1-111:/usr/local 17:24:18 # 

# 查看支持的选项
root@node1-111:/usr/local 17:24:18 # victoria-metrics-prod --help

# 准备用户和数据目录
root@node1-111:~ 17:25:27 # useradd -r -s /sbin/nologin victoriametrics
root@node1-111:~ 17:25:32 # mkdir -p /data/victoriametrics
root@node1-111:~ 17:25:39 # chown victoriametrics.victoriametrics /data/victoriametrics
root@node1-111:~ 17:25:45 # 


# 创建 service 文件
root@node1-111:~ 17:26:23 # cat /lib/systemd/system/victoriametrics.service
[Unit]
Description=VictoriaMetrics
Documentation=https://docs.victoriametrics.com/Single-serverVictoriaMetrics.html
After=network.target
[Service]
Restart=on-failure
User=victoriametrics
Group=victoriametrics
ExecStart=/usr/local/bin/victoria-metrics-prod -httpListenAddr=0.0.0.0:8428 -storageDataPath=/data/victoriametrics -retentionPeriod=12
#ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
#说明
-httpListenAddr string #监听地址和端口,默认为0.0.0.0:8428
-storageDataPath string #指定数据存储路径,默认当前目录下的victoria-metrics-data
-retentionPeriod value  #指定数据保存时长,支持h (hour), d (day), w (week), y (year). If suffix isn't set, then the duration is counted in months (default 1)


root@node1-111:~ 17:26:25 # systemctl daemon-reload 
root@node1-111:~ 17:26:31 # systemctl enable --now victoriametrics.service
Created symlink /etc/systemd/system/multi-user.target.wants/victoriametrics.service → /lib/systemd/system/victoriametrics.service.
root@node1-111:~ 17:29:35 # systemctl status victoriametrics.service
● victoriametrics.service - VictoriaMetrics
     Loaded: loaded (/lib/systemd/system/victoriametrics.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-10-13 17:29:35 CST; 3s ago
       Docs: https://docs.victoriametrics.com/Single-serverVictoriaMetrics.html
   Main PID: 66952 (victoria-metric)
      Tasks: 9 (limit: 4514)
     Memory: 6.5M
        CPU: 189ms
     CGroup: /system.slice/victoriametrics.service
             └─66952 /usr/local/bin/victoria-metrics-prod -httpListenAddr=0.0.0.0:8428 -storageDataPath=/data/victoriametrics -retentionPeriod=12

Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.403Z        info        VictoriaMetrics/lib/mergeset/table.go:259        opening table "/>
Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.414Z        info        VictoriaMetrics/lib/mergeset/table.go:295        table "/data/vic>
Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.421Z        info        VictoriaMetrics/lib/mergeset/table.go:259        opening table "/>
Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.433Z        info        VictoriaMetrics/lib/mergeset/table.go:295        table "/data/vic>
Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.464Z        info        VictoriaMetrics/app/vmstorage/main.go:127        successfully ope>
Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.468Z        info        VictoriaMetrics/app/vmselect/promql/rollup_result_cache.go:114   >
Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.471Z        info        VictoriaMetrics/app/vmselect/promql/rollup_result_cache.go:142   >
Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.472Z        info        VictoriaMetrics/app/victoria-metrics/main.go:63        started Vi>
Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.472Z        info        VictoriaMetrics/lib/httpserver/httpserver.go:96        starting h>
Oct 13 17:29:35 node1-111 victoria-metrics-prod[66952]: 2025-10-13T09:29:35.472Z        info        VictoriaMetrics/lib/httpserver/httpserver.go:97        pprof hand>


root@node1-111:~ 17:29:39 # ss -tunlp | grep 8428
tcp   LISTEN 0      4096         0.0.0.0:8428       0.0.0.0:*    users:(("victoria-metric",pid=66952,fd=10))   



# 数据目录自动生成相关数据
root@node1-111:~ 17:29:50 # ls /data/victoriametrics/
data  flock.lock  indexdb  metadata  snapshots  tmp
root@node1-111:~ 17:32:17 #
~~~

![image-20251013173248665](Prometheus.assets/image-20251013173248665.png)

![image-20251013173302218](Prometheus.assets/image-20251013173302218.png)

##### 10.2.2.1.2 修改 Prometheus 使用 Victoriametrics 远程存储

```yaml
root@prometheus-221:~ 17:34:43 # head /usr/local/prometheus/conf/prometheus.yml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).
remote_write:
  - url: http://192.168.121.111:8428/api/v1/write

root@prometheus-221:~ 17:34:48 # promtool check config /usr/local/prometheus/conf/prometheus.yml
Checking /usr/local/prometheus/conf/prometheus.yml
 SUCCESS: /usr/local/prometheus/conf/prometheus.yml is valid prometheus config file syntax

root@prometheus-221:~ 17:34:57 # systemctl restart prometheus.service 
root@prometheus-221:~ 17:35:01 # 

```

##### 10.2.2.1.3 访问 Victoriametrics Web UI 查看数据

![image-20251013173637565](Prometheus.assets/image-20251013173637565.png)

##### 10.2.2.1.4 Grafana 展示

在Grafana 添加新的数据源,类型为 **Prometheus**,URL为 **victoriametrics** **的地址和端口**

导入模板8919,1860,11074等模板,指定使用上面创建的数据源

#### 10.2.2.2 基于 docker 部署

https://hub.docker.com/r/victoriametrics/victoria-metrics

~~~shell
docker run -it --rm -v /path/to/victoria-metrics-data:/victoria-metrics-data -p8428:8428 victoriametrics/victoria-metrics
#This will run the service on port 8428, all the data will be stored at /path/to/victoria-metrics-data . To verify VictoriaMetrics is healthy and running check the /metrics page:
curl -v http://<victoriametrics-addr>:8428/metrics
~~~

### 10.2.3 VictoriaMetrics 集群部署

#### 10.2.3.1 VictoriaMetrics 集群说明

VictoriaMetrics 集群可以解决单机的单点可用性和性能瓶颈问题

https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html

![image-20251013173954607](Prometheus.assets/image-20251013173954607.png)

集群版的victoriametrics有下面主要服务组成：

![image-20251013174028377](Prometheus.assets/image-20251013174028377.png)

- vmstorage

  数据存储节点，负责存储时序数据,默认使用3个端口

  API Server的端口: 8482/tcp，由选项 -httpListenAddr 指定

  从vminsert接收并存入数据的端口:8400/ tcp，由选项-vminsertAddr指定

  从vmselect接收查询并返回数据的端口:8401 / tcp，由选项-vmselectAddr指定vmstorage节点间不进行任何交互，都是独立的个体, 使用上层的vminsert产生副本和分片有状态，一个vmstorage节点故障，会丢失约1/N的历史数据(N为vmstorage节点的数量)

  数据存储于选项-storageDataPath指定的目录中，默认为./vmstorage-data/

  vmstorage的节点数量,需要真实反映到vminsert和vmselect之上

  支持单节点和集群模式:集群模式支持多租户，其API端点也有所不同

- vminsert

  数据插入节点，负责接收用户插入请求，基于metric名称和label使用一致性Hash算法向不同的vmstorage写入时序数据

  负责接收来自客户端的数据写入请求，并转发到选定的vmstorage节点，监听一个端口接收数据存入请求的端口:8480/ tcp，由选项-httpListenAddr指定

  它是Prometheus remote_write协议的一个实现，可接收和解析通过该协议远程写入的数据若接入的是VM存储集群时

  其调用端点的URL格式为

  ~~~shell
  http: //<vminsert>:8480 /insert/<accountID>/<suffix>
  #<accountID>是租户标识
  #<suffix>中，值/prometheus和/prometheus/api/v1/write的作用相同，专用于接收prometheus写入请求
  ~~~

- vmselect

  数据查询节点，负责接收用户查询请求，向vmstorage查询时序数据

  负责接收来自客户端的数据查询请求，转发到各vmstorage节点完成查询，并将结果合并后返回给客户端监听一个端口

  基于metric名称和label使用一致性Hash算法向不同的vmstorage查询时序数据

  接收数据查询请求的端口:8481/tcp，可由选项-httpListenAddr指定

  它是prometheus remote_read协议的一个实现，可接收和解析通过该协议传入的远程查询请求专用于prometheus的URL格式为

  ```shell
  http://<vmselect>:8481/select/<accountID>/prometheus
  #<accountID>是租户标识
  ```

- vmagent

  可以用来替换 Prometheus，实现数据指标抓取，支持多种后端存储，会占用本地磁盘缓存

  相比于 Prometheus 抓取指标来说具有更多的灵活性，支持pull和push指标

  默认端口 8429

- vmalert

  报警相关组件，如果不需要告警功能可以不使用，默认端口为 8880

以上组件中 vminsert 以及 vmselect（几乎）都是无状态的，所以扩展很简单，只有 vmstorage 是有状态的。

在部署时可以按照需求，不同的微服务部署不同的副本，以应对业务需求：

- 若数据量比较大，部署较多的vmstorage副本
- 若查询请求比较多，部署较多的vmselect副本
- 若插入请求比较多，部署较多的vminsert副本

#### 10.2.3.2 VictoriaMetrics 集群二进制部署

以下实现部署一个三节点的 VictoriaMetrics 集群，且三节点同时都提供vmstorage，vminsert和vmselect角色

![image-20251013174341072](Prometheus.assets/image-20251013174341072.png)

##### 10.2.3.2.1 下载集群二进制程序文件

在所有三个节点下载集群的二进制程序文件

~~~shell
root@node1-111:~ 17:49:16 #  wget https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.82.1/victoria-metrics-linux-amd64-v1.82.1-cluster.tar.gz

root@node1-111:~ 17:50:18 # tar xf  victoria-metrics-linux-amd64-v1.82.1-cluster.tar.gz  -C /usr/local/bin
~~~

##### 10.2.3.2.2 配置和启动 vmstorage

~~~shell
root@node1-111:~ 17:52:59 # mkdir -p /data/vmstorage

# 创建 service 文件
[root@ubuntu2204 ~]#cat > /lib/systemd/system/vmstorage.service <<EOF
[Unit]
Description=VictoriaMetrics Cluster Vmstorage
Documentation=https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html
After=network.target
[Service]
Restart=on-failure
ExecStart=/usr/local/bin/vmstorage-prod  -httpListenAddr :8482 -vminsertAddr
:8400 -vmselectAddr :8401 -storageDataPath /data/vmstorage -loggerTimezone
Asia/Shanghai
#ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
#主要参数说明：
-loggerTimezone string
#Timezone to use for timestamps in logs. Timezone must be a valid IANA Time Zone. 
For example: America/New_York, Europe/Berlin, Etc/GMT+3 or Local (default "UTC")
-httpListenAddr string
#Address to listen for http connections (default ":8482")
-vminsertAddr string
#TCP address to accept connections from vminsert services (default ":8400")
-vmselectAddr string
#TCP address to accept connections from vmselect services (default ":8401")


[root@ubuntu2204 ~]#systemctl daemon-reload;systemctl enable --now vmstorage;systemctl status vmstorage


[root@ubuntu2204 ~]#ss -nltp |grep vmstorage
LISTEN 0      4096               0.0.0.0:8400       0.0.0.0:*   users:
(("vmstorage-prod",pid=2415,fd=10))
LISTEN 0      4096               0.0.0.0:8401       0.0.0.0:*   users:
(("vmstorage-prod",pid=2415,fd=11))
LISTEN 0      4096               0.0.0.0:8482       0.0.0.0:*   users:
(("vmstorage-prod",pid=2415,fd=12))
[root@ubuntu2204 ~]#pstree -p |grep vmstorage-prod
           `-vmstorage-prod(2415)-+-{vmstorage-prod}(2416)
                                 |-{vmstorage-prod}(2417)
                                 |-{vmstorage-prod}(2418)
                                 |-{vmstorage-prod}(2419)
                                 |-{vmstorage-prod}(2420)
                                  `-{vmstorage-prod}(2421)
[root@ubuntu2204 ~]#ls /data/vmstorage/
data flock.lock indexdb metadata snapshots
#测试访问
http://10.0.0.201:8482/metrics
http://10.0.0.202:8482/metrics
http://10.0.0.203:8482/metrics
~~~

##### 10.2.3.2.3 配置和启动 vminsert

在所有三个节点部署 vminsert

~~~shell
#查看选项
[root@ubuntu2204 ~]#vminsert-prod --help
[root@ubuntu2204 ~]#cat > /lib/systemd/system/vminsert.service <<EOF
[Unit]
Description=VictoriaMetrics Cluster Vminsert
Documentation=https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html
After=network.target
[Service]
Restart=on-failure
ExecStart=/usr/local/bin/vminsert-prod -httpListenAddr :8480 -
storageNode=10.0.0.201:8400,10.0.0.202:8400,10.0.0.203:8400
#ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
#主要参数说明：
-httpListenAddr string
#Address to listen for http connections (default ":8480")
-storageNode array
#Comma-separated addresses of vmstorage nodes; usage: -storageNode=vmstorage-host1,...,vmstorage-hostN,Supports an array of values separated by comma or specified via multiple flags.
-replicationFactor int  
#此选项可以实现多副本,实现数据高用性

#Replication factor for the ingested data, i.e. how many copies to make among distinct -storageNode instances. Note that vmselect must run with -dedup.minScrapeInterval=1ms for data de-duplication when replicationFactor is greater than 1. Higher values for -dedup.minScrapeInterval at vmselect is OK (default 1)
https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html#replication-and-data-safety
[root@ubuntu2204 ~]#systemctl daemon-reload;systemctl enable --now vminsert
[root@ubuntu2204 ~]#systemctl status vminsert
[root@ubuntu2204 ~]#ss -nltp |grep vminsert
LISTEN 0      4096                           0.0.0.0:8480       0.0.0.0:*   
users:(("vminsert-prod",pid=2182,fd=3)) 
[root@ubuntu2204 ~]#pstree -p |grep vminsert-prod
           |-vminsert-prod(2182)-+-{vminsert-prod}(2183)
           |                     |-{vminsert-prod}(2184)
           |                     |-{vminsert-prod}(2185)
           |                     |-{vminsert-prod}(2186)
           |                     |-{vminsert-prod}(2187)
           |                     |-{vminsert-prod}(2188)
           |                     `-{vminsert-prod}(2189)
#测试访问
http://10.0.0.201:8480/metrics
http://10.0.0.202:8480/metrics
http://10.0.0.203:8480/metrics
~~~

##### 10.2.3.2.4 配置和启动 vmselect

在所有三个节点部署 vmselect

```shell
#查看选项
[root@ubuntu2204 ~]#vmselect-prod --help
[root@ubuntu2204 ~]#cat > /lib/systemd/system/vmselect.service <<EOF
[Unit]
Description=VictoriaMetrics Cluster Vmselect
Documentation=https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html
After=network.target
[Service]
Restart=on-failure
ExecStart=/usr/local/bin/vmselect-prod  -httpListenAddr :8481 -
storageNode=10.0.0.201:8401,10.0.0.202:8401,10.0.0.203:8401
#ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
#主要参数说明：
-httpListenAddr string
#Address to listen for http connections (default ":8481")
-storageNode array
#Comma-separated addresses of vmstorage nodes; usage: -storageNode=vmstoragehost1,...,vmstorage-hostN,Supports an array of values separated by comma or 
specified via multiple flags.
[root@ubuntu2204 ~]#systemctl daemon-reload;systemctl enable --now vmselect
[root@ubuntu2204 ~]#systemctl status vmselect
[root@ubuntu2204 ~]#ss -nltp |grep vmselect
LISTEN 0      4096               0.0.0.0:8481       0.0.0.0:*   users:
(("vmselect-prod",pid=2592,fd=9))
[root@ubuntu2204 ~]#pstree -p |grep vmselect-prod
           |-vmselect-prod(2592)-+-{vmselect-prod}(2593)
           |                     |-{vmselect-prod}(2594)
           |                     |-{vmselect-prod}(2595)
           |                     |-{vmselect-prod}(2596)
           |                     |-{vmselect-prod}(2597)
           |                     |-{vmselect-prod}(2598)
           |                     `-{vmselect-prod}(2599)
#查看端口
[root@ubuntu2204 ~]#ss -ntl|grep 84
LISTEN 0      4096               0.0.0.0:8480       0.0.0.0:*          
LISTEN 0      4096               0.0.0.0:8481       0.0.0.0:*          
LISTEN 0      4096               0.0.0.0:8482       0.0.0.0:*          
LISTEN 0      4096               0.0.0.0:8400       0.0.0.0:*          
LISTEN 0      4096               0.0.0.0:8401       0.0.0.0:*  
#测试访问
http://10.0.0.201:8481/metrics
http://10.0.0.202:8481/metrics
http://10.0.0.203:8481/metrics

```

##### 10.2.3.2.5 配置 Prometheus 使用 VictoriaMetrics 实现集群存储

```shell
[root@ubuntu2204 ~]#vim /usr/local/prometheus/conf/prometheus.yml
# my global config
global:
 scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is 
every 1 minute.
 evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is 
every 1 minute.
  # scrape_timeout is set to the global default (10s).
#加下面集群地址的行
remote_write:
  - url: http://10.0.0.201:8480/insert/0/prometheus
  - url: http://10.0.0.202:8480/insert/0/prometheus
  - url: http://10.0.0.203:8480/insert/0/prometheus
remote_read:
  - url: http://10.0.0.201:8481/select/0/prometheus
  - url: http://10.0.0.202:8481/select/0/prometheus
  - url: http://10.0.0.203:8481/select/0/prometheus  
#说明
10.0.0.20[1-3]:8480为 三个集群节点的IP和vminsert组件端口
0表示租户ID,即逻辑名称空间,用于区分不同的prometheus集群
[root@ubuntu2204 ~]#systemctl resload prometheus.service
```



# 面试题

## 1 Prometheus 监控主机流程

~~~ini
1、安装 exporter（node exporter、mysql exporter...），暴露 http://0.0.0.0:9100/metrics
2、在 Prometheus 配置文件中添加 exporter 地址信息，加一个 job 和 instance

~~~

## 2 Prometheus 监控服务流程

~~~shell
1、服务要暴露一个 API 
	一些服务原生支持 Prometheus 监控
	不支持的服务可以通过安装 exporter
2、Prometheus 配置文件添加相关服务地址，配置 job 和 instance
~~~

## 3 Prometheus架构及各个组件的作用？

- Prometheus server
  - 是 Prometheus 的核心组件
  - 负责数据采集、存储和查询、并持久化存储在时序数据库中
- Grafana
  - 负责数据展示
- push-geteway
  - 一个中间代理
  - 收集使用推送方式发送指标的任务
  - 存储生命周期较短的指标发送的任务
- altermanager
  - 用于处理告警通知
- exporters
  - 用于监控原生不支持 Prometheus 的服务

## 4 Prometheus server的监听端口？

9100

## 5 你们 Prometheus 都监控了哪些中间件(组件)？

- **数据库中间件**：MySQL
- **消息中间件**：Kafka
- **缓存中间件**：Redis
- **Web 服务**：Nginx
- **其他服务**： 监控容器



## 6 Prometheus 如何发现 target 呢？

1. 基于文件的服务发现
2. 动态服务发现，例如：基于 Consul、nacos 的服务发现
3. 静态配置，手动指定

## 7 Prometheus如何存储数据？

1. 本地存储

   使用本地的时序数据库，数据先写入内存和 WAL（预写日志），在写入硬盘

2. 远程存储

   在 Prometheus 配置文件中通过 `remote_write` 指定接口，可以将采集到的数据推送到远端存储系统，例如 VictoriaMertics

## 8 当集群规模较大时，Prometheus如何减轻压力呢？

- 采用 Prometheus Federation 模式



## 9 当grafana查询不到数据时，请简单陈述下你的排查思路？

1. **检查数据源连接**：进入「Configuration → Data sources」，测试数据源连接状态，确认网络可达、认证信息正确。
2. **验证查询语句**：在面板的 Query 编辑器中，将查询语句复制到数据源原生工具（如 Prometheus 的 Web UI）中执行，判断是否为语句错误。
3. **确认时间范围**：检查 Dashboard 右上角的时间选择器，确保所选时间范围内数据源实际有数据。
4. **查看指标 / 标签是否存在**：通过数据源元数据接口（如 Prometheus 的`/metrics`）确认查询的指标名、标签键值是否正确存在。
5. **检查权限与过滤条件**：确认数据源是否有访问限制，以及查询中的过滤条件（如标签匹配）是否过于严格导致无结果。
6. **查看日志与错误信息**：在 Grafana 的「Server Admin → Logs」或浏览器开发者工具的 Network 面板中，检查是否有查询错误提示（如权限拒绝、语法错误）。

## 10 简单陈述下Prometheus和zabbix的区别？

1. **数据模型**：
   - Prometheus 采用时序数据模型，基于指标（metric）+ 标签（label），适合存储和分析数值型时间序列数据。
   - Zabbix 基于键值对（key-value）模型，支持更丰富的数据类型（如字符串、日志），但时序分析能力较弱。
2. **部署与扩展性**：
   - Prometheus 轻量易部署，通过联邦（federation）和远程存储支持水平扩展，适合云原生和动态环境。
   - Zabbix 架构较重型（Server+Agent+DB），扩展相对复杂，更适合传统静态环境。
3. **监控方式**：
   - Prometheus 以**主动拉取（Pull）** 为主，适合监控短暂存在的实例（如容器），也支持推送（PushGateway）。
   - Zabbix 以**被动推送（Agent 主动上报）** 为主，依赖 Agent 部署，对无 Agent 场景支持较弱。
4. **告警与可视化**：
   - Prometheus 告警规则灵活，需配合 Grafana 实现可视化，适合自定义告警逻辑。
   - Zabbix 内置告警和基础可视化，配置简单但定制化能力有限。
5. **适用场景**：
   - Prometheus 更适合 K8s、微服务等动态环境，侧重指标分析和趋势预测。
   - Zabbix 适合传统服务器、网络设备监控，侧重全面的设备状态监控和告警。

## 11 简单陈述下node-exporter的黑白名单机制？

- **黑名单（blacklist）**：指定需要**排除**的指标，匹配的指标将不被采集。

  例如：`--collector.processes.whitelist=".*"`（实际为反向逻辑，此处仅为示例格式）。

- **白名单（whitelist）**：指定仅允许**保留**的指标，仅匹配的指标会被采集。

  例如：`--collector.cpu.whitelist="cpu_time_.*"` 只采集以 `cpu_time_` 开头的 CPU 指标。

## 12 Prometheus如何监控一个网站的证书有效期呢？简单陈述下流程？

1. **部署证书监控工具**：使用`blackbox_exporter`（黑盒监控工具），它支持 HTTPS 证书检测。
2. **配置 blackbox_exporter**：在其配置文件中定义 HTTPS 模块，启用证书过期时间检查（默认已包含）。
3. **配置 Prometheus 目标**：在 Prometheus 的`prometheus.yml`中添加监控任务，指定目标网站 URL，并通过`blackbox_exporter`作为代理采集数据。
4. **获取证书指标**：通过`probe_ssl_earliest_cert_expiry`指标获取证书过期时间戳。
5. **计算有效期**：在 Grafana 中或通过 PromQL 计算剩余天数（`(probe_ssl_earliest_cert_expiry - time()) / 86400`），设置阈值告警（如剩余 30 天时触发）。

## 13 Prometheus如何自定义监控呢？

	- pushgateway
	- 自研exporter



## 14 Prometheus如何监控etcd集群呢？

1. **启用 etcd 监控接口**：etcd 默认暴露`/metrics`端点（需确保启动时开启`--metrics`相关参数，如`--metrics=basic`或`--metrics=extensive`），提供自身运行指标。
2. **配置 Prometheus 目标**：在`prometheus.yml`中添加 etcd 集群监控任务，指定所有 etcd 节点的`/metrics`地址（如`http://etcd-ip:2379/metrics`）。
3. **关键指标采集**：获取 etcd 核心指标，如集群健康状态（`etcd_cluster_health`）、成员状态（`etcd_server_is_leader`）、性能指标（`etcd_disk_wal_fsync_duration_seconds`）、数据同步（`etcd_network_peer_round_trip_time_seconds`）等。
4. **配置告警规则**：基于指标设置告警（如集群不健康、 leader 频繁切换、磁盘 IO 延迟过高等）。
5. **可视化展示**：通过 Grafana 导入 etcd 专用仪表盘（如官方提供的模板），直观呈现集群状态。
