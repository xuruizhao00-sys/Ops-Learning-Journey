# 一、Docker 介绍和基础管理
## 1.1 Docker 介绍
### 1.1.1 容器技术简史：Docker 并非起点
#### 1.1.1.1 `chroot` Jail（1979）
- **出现时间**：1979 年（Unix Version 7）
- **原理**：通过 `chroot` 系统调用，将进程的根目录（`/`）重定向到指定子目录，实现**文件系统级别的隔离**。
- **意义**：被广泛认为是**最早的容器化技术雏形**，虽无进程、网络、用户等隔离能力，但开启了“环境隔离”的先河。

---

#### 1.1.1.2 FreeBSD Jail（2000）
- **发布**：随 FreeBSD 4.0 一同推出
- **特点**：
  - 实现了**操作系统级虚拟化**（OS-level virtualization）
  - 每个 “Jail” 拥有独立的 IP 地址、用户账户、进程空间和文件系统
- **地位**：是首个成熟的、生产可用的容器化方案，被视为现代容器技术的**重要先驱**。

---

#### 1.1.1.3 Linux-VServer（2003）
- **发布时间**：2003 年 11 月 1 日（v1.0）
- **官网**：[http://linux-vserver.org/](http://linux-vserver.org/)
- **机制**：通过向 Linux 内核打补丁，实现**系统级虚拟化**，允许多个虚拟专用服务器（VPS）在单台物理机上并行运行。
- **能力**：
  - 每个 VPS 拥有独立的 root 用户、用户数据库、网络配置
  - 可直接运行标准服务（如 SSH、Web、数据库），几乎无需修改
  - **共享底层硬件资源**，性能开销极低

---

#### 1.1.1.4 Solaris Containers（2004）
- **平台**：Oracle Solaris（支持 SPARC 和 x86）
- **组成**：结合 **Zones（区域）** 与 **Resource Controls（资源控制）**
- **特性**：
  - 提供强隔离的执行环境（Zone）
  - 支持 CPU、内存、网络等资源配额管理
- **优势**：企业级稳定性与安全性，适用于高可靠场景。

---

#### 1.1.1.5 OpenVZ（2005）
- **类型**：基于 Linux 内核的**操作系统级虚拟化**
- **功能**：
  - 创建多个安全隔离的 Linux 容器（称为 VPS）
  - 共享同一个内核，但拥有独立的文件系统、用户、进程、网络栈
- **影响**：曾是主流 VPS 提供商（如早期 HostGator）的技术基础。

---

#### 1.1.1.6 Process Containers → cgroups（2006–2007）
- **开发者**：Google 工程师
- **演进**：最初名为 *Process Containers*，后因命名冲突更名为 **cgroups**（Control Groups）
- **作用**：Linux 内核功能，用于**限制、记录和隔离进程组的资源使用**（CPU、内存、I/O 等）
- **地位**：成为后续所有 Linux 容器技术（包括 LXC 和 Docker）的**核心依赖**。

---

#### 1.1.1.7 LXC（Linux Containers，2008）
- **全称**：Linux Container
- **原理**：结合 **cgroups + namespaces**，实现轻量级虚拟化
- **特点**：
  - 无需 Hypervisor，直接在宿主机 OS 上运行隔离环境
  - 提供类似虚拟机的体验（独立 init 进程、网络、用户空间），但启动更快、资源开销更小
- **定位**：Docker 早期版本（0.x）的默认运行时。

---

#### 1.1.1.8 Warden（2011）
- **背景**：Cloud Foundry 项目中的容器管理组件
- **初期实现**：基于 LXC
- **后续**：被更现代的容器运行时取代，现已不再维护。

---

#### 1.1.1.9 LMCTFY（2013）
- **全称**：*Let Me Contain That For You*
- **发起者**：Google
- **目标**：开源 Google 内部容器管理技术
- **现状**：项目已归档，其核心思想融入了后来的 **libcontainer**（Docker 的底层引擎）及 **Kubernetes**。

---

#### 1.1.1.10 Docker（2013）
- **发布**：2013 年
- **突破**：
  - 引入**镜像分层**、**Dockerfile**、**Registry** 等概念
  - 极大简化了容器的构建、分发与运行
- **影响**：引爆 DevOps 与云原生革命，成为**最广为人知的容器平台**，但**并非技术首创者**。

---

#### 1.1.1.11 rkt（Rocket，2014）
- **发起者**：CoreOS
- **理念**：强调**安全性**、**可组合性** 和 **开放标准**（推动 OCI 规范）
- **现状**：已停止维护，但其设计思想影响了后续容器生态。
### 1.1.2 Docker 是什么
2010年，Solomon Hykes（现任 Docker CTO）与几位合伙人在美国旧金山联合创立了 dotCloud 公司。该公司主要业务是提供平台即服务（PaaS）解决方案，为开发者提供技术服务平台。

**Docker**（中文常译为"码头工人"）作为一个开源项目，正式诞生于 **2013 年 3 月 27 日**。该项目最初是 dotCloud 公司内部的一个业余性质的开源 PaaS 服务项目。由于 Docker 开源后获得了业界广泛关注和热烈反响，dotCloud 公司于 **2013 年 10 月**正式更名为 **Docker Inc**，并将总部设在美国加州旧金山。

|特性|Docker 容器|传统虚拟机|
|---|---|---|
|**启动速度**​|秒级启动|分钟级启动|
|**资源消耗**​|极低资源占用|较高资源开销|
|**性能损耗**​|接近原生性能|明显性能损耗|
Docker 服务设计
- **客户端/服务端架构**：采用 C/S 模式，通过远程 API 进行管理和控制
- **轻量级设计**：创建轻量级、可移植、自包含的容器环境
- **核心理念**：构建（Build）、运输（Ship）、运行（Run）三大核心哲学

Docker 服务安全隔离机制
- **命名空间隔离**（namespace）：提供进程、网络、文件系统等资源的隔离
- **控制组限制**（cgroup）：实现资源配额和限制管理
- **安全保证**：确保容器间的安全边界和资源隔离

**Docker 主要目标**
```mermaid
mindmap
  root((Docker 主要目标))
    应用容器化
      标准化打包
        : 应用代码
        : 运行环境
        : 系统工具
        : 依赖库
      镜像分层结构
        : 只读层 (Read-only Layers)
        : 可写层 (Writable Layer)
        : 联合文件系统 (Union FS)
      轻量级虚拟化
        : 进程级隔离
        : 资源限制 (CPU/内存)
        : 命名空间隔离
    环境一致性
      开发-测试-生产环境统一
        : 消除环境差异
        : 配置一致性
      跨平台运行
        : 云环境 (AWS/Azure/GCP)
        : 物理服务器
        : 虚拟机
        : 本地开发机
    快速部署与扩展
      秒级启动
        : 容器运行时优化
        : 最小化启动开销
      弹性伸缩
        : 水平扩展 (Horizontal Scaling)
        : 自动扩缩容
      滚动更新
        : 零停机部署
        : 版本回滚
    资源高效利用
      共享内核
        : 减少内存占用
        : 降低 CPU 开销
      高密度部署
        : 更多实例 per 主机
        : 资源超配 (Overcommitment)
     DevOps 集成
      持续集成/持续部署
        : Jenkins/GitLab CI 集成
        : 自动化流水线
      基础设施即代码
        : Dockerfile 定义环境
        : docker-compose 编排
    微服务架构支持
      服务解耦
        : 独立部署单元
        : 明确接口契约
      服务发现与负载均衡
        : Docker Swarm 模式
        : Kubernetes 集成
    安全隔离
      命名空间隔离
        : PID 命名空间
        : 网络命名空间
        : 用户命名空间
      Cgroups 资源控制
        : CPU 配额
        : 内存限制
        : I/O 控制
    生态系统与工具链
      容器编排
        : Kubernetes
        : Docker Swarm
        : Apache Mesos
      监控与日志
        : Prometheus 监控
        : ELK 日志收集
        : 分布式追踪
```
**使用 Docker 容器化封装应用程序的意义**

```mermaid
graph LR
    A[Docker Application Containerization Significance] --> B1[Environment Standardization & Consistency]
    A --> B2[Application Isolation & Security]
    A --> B3[Resource Efficiency & Cost Optimization]
    A --> B4[Agile Development & DevOps]
    A --> B5[Portability & Cloud Native]
    A --> B6[Fault Recovery & High Availability]
    A --> B7[Monitoring & Observability]
    A --> B8[Ecosystem & Toolchain]
    
    B1 --> C1_1[Development Environment Consistency]
    B1 --> C1_2[Testing Environment Consistency]
    B1 --> C1_3[Production Environment Consistency]
    
    C1_1 --> D1_1_1[Eliminate Environment-Specific Issues]
    C1_1 --> D1_1_2[Unified Dependency Management]
    C1_1 --> D1_1_3[Standardized Configuration Management]
    
    C1_2 --> D1_2_1[Automated Test Environment Setup]
    C1_2 --> D1_2_2[Reproducible Test Results]
    C1_2 --> D1_2_3[Parallel Testing Environment Isolation]
    
    C1_3 --> D1_3_1[Standardized Deployment Environment]
    C1_3 --> D1_3_2[Configuration Drift Prevention]
    C1_3 --> D1_3_3[Version Control Traceability]
    
    B2 --> C2_1[Process-Level Isolation]
    B2 --> C2_2[Security Boundary Enhancement]
    B2 --> C2_3[Multi-Tenant Environment Support]
    
    C2_1 --> D2_1_1[Namespace Isolation]
    C2_1 --> D2_1_2[Control Groups Resource Limits]
    C2_1 --> D2_1_3[Filesystem Isolation]
    
    C2_2 --> D2_2_1[Principle of Least Privilege]
    C2_2 --> D2_2_2[Vulnerability Impact Containment]
    C2_2 --> D2_2_3[Centralized Security Policy Management]
    
    C2_3 --> D2_3_1[Resource Competition Avoidance]
    C2_3 --> D2_3_2[Failure Propagation Isolation]
    C2_3 --> D2_3_3[Performance Interference Elimination]
    
    B3 --> C3_1[Lightweight Virtualization]
    B3 --> C3_2[Resource Utilization Improvement]
    B3 --> C3_3[Cost Effectiveness]
    
    C3_1 --> D3_1_1[Shared OS Kernel]
    C3_1 --> D3_1_2[Fast Startup and Shutdown]
    C3_1 --> D3_1_3[Low Memory Overhead]
    
    C3_2 --> D3_2_1[High-Density Deployment Capability]
    C3_2 --> D3_2_2[Dynamic Resource Allocation]
    C3_2 --> D3_2_3[Idle Resource Recovery]
    
    C3_3 --> D3_3_1[Hardware Investment Reduction]
    C3_3 --> D3_3_2[Energy Consumption Reduction]
    C3_3 --> D3_3_3[Operational Cost Decrease]
    
    B4 --> C4_1[CI/CD Integration]
    B4 --> C4_2[Microservices Architecture Support]
    B4 --> C4_3[Infrastructure as Code]
    
    C4_1 --> D4_1_1[Automated Build Pipeline]
    C4_1 --> D4_1_2[Standardized Deployment Process]
    C4_1 --> D4_1_3[Fast Rollback Mechanism]
    
    C4_2 --> D4_2_1[Service Decoupling & Independent Deployment]
    C4_2 --> D4_2_2[Technology Stack Diversity Support]
    C4_2 --> D4_2_3[Service Mesh Integration]
    
    C4_3 --> D4_3_1[Dockerfile Version Control]
    C4_3 --> D4_3_2[Immutable Infrastructure]
    C4_3 --> D4_3_3[Environment Configuration as Code]
    
    B5 --> C5_1[Cross-Platform Runtime Capability]
    B5 --> C5_2[Cloud-Native Application Foundation]
    B5 --> C5_3[Standardized Packaging Format]
    
    C5_1 --> D5_1_1[Seamless Dev-to-Production Migration]
    C5_1 --> D5_1_2[Multi-Cloud Deployment Strategy Support]
    C5_1 --> D5_1_3[Hybrid Cloud Environment Compatibility]
    
    C5_2 --> D5_2_1[Kubernetes Native Support]
    C5_2 --> D5_2_2[Service Discovery & Load Balancing]
    C5_2 --> D5_2_3[Auto-Scaling Capability]
    
    C5_3 --> D5_3_1[Image Registry Ecosystem]
    C5_3 --> D5_3_2[Image Signing & Verification]
    C5_3 --> D5_3_3[Supply Chain Security Assurance]
    
    B6 --> C6_1[Fast Fault Recovery]
    B6 --> C6_2[Rolling Updates & Blue-Green Deployment]
    B6 --> C6_3[Disaster Recovery Strategy]
    
    C6_1 --> D6_1_1[Container Self-Healing Capability]
    C6_1 --> D6_1_2[Health Check Mechanism]
    C6_1 --> D6_1_3[Service Mesh Fault Tolerance]
    
    C6_2 --> D6_2_1[Zero-Downtime Deployment]
    C6_2 --> D6_2_2[Instant Version Rollback]
    C6_2 --> D6_2_3[Canary Release Support]
    
    C6_3 --> D6_3_1[Image Backup & Recovery]
    C6_3 --> D6_3_2[Cross-Region Deployment]
    C6_3 --> D6_3_3[Data Persistence Solutions]
    
    B7 --> C7_1[Standardized Log Management]
    B7 --> C7_2[Performance Monitoring Metrics]
    B7 --> C7_3[Distributed Tracing]
    
    C7_1 --> D7_1_1[Centralized Log Collection]
    C7_1 --> D7_1_2[Structured Log Output]
    C7_1 --> D7_1_3[Pluggable Log Drivers]
    
    C7_2 --> D7_2_1[Resource Usage Monitoring]
    C7_2 --> D7_2_2[Application Performance Metrics]
    C7_2 --> D7_2_3[Custom Metrics Exposure]
    
    C7_3 --> D7_3_1[Request Chain Tracing]
    C7_3 --> D7_3_2[Service Dependency Visualization]
    C7_3 --> D7_3_3[Performance Bottleneck Identification]
    
    B8 --> C8_1[Rich Tool Ecosystem]
    B8 --> C8_2[Community & Market Support]
    B8 --> C8_3[Standardized Interfaces]
    
    C8_1 --> D8_1_1[Docker Compose Multi-Container Orchestration]
    C8_1 --> D8_1_2[Docker Swarm Cluster Management]
    C8_1 --> D8_1_3[Third-Party Tool Integration]
    
    C8_2 --> D8_2_1[Docker Hub Image Registry]
    C8_2 --> D8_2_2[Enterprise Image Registry]
    C8_2 --> D8_2_3[Open Source Project Containerization]
    
    C8_3 --> D8_3_1[OCI Open Container Initiative Standards]
    C8_3 --> D8_3_2[CNCF Cloud Native Foundation Support]
    C8_3 --> D8_3_3[Multi-Runtime Compatibility]
    
    %% 样式定义
    classDef level1 fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef level2 fill:#f3e5f5,stroke:#4a148c,stroke-width:1.5px
    classDef level3 fill:#e8f5e8,stroke:#1b5e20,stroke-width:1px
    classDef level4 fill:#fff3e0,stroke:#e65100,stroke-width:1px
    
    class A level1
    class B1,B2,B3,B4,B5,B6,B7,B8 level2
    class C1_1,C1_2,C1_3,C2_1,C2_2,C2_3,C3_1,C3_2,C3_3,C4_1,C4_2,C4_3,C5_1,C5_2,C5_3,C6_1,C6_2,C6_3,C7_1,C7_2,C7_3,C8_1,C8_2,C8_3 level3
    class D1_1_1,D1_1_2,D1_1_3,D1_2_1,D1_2_2,D1_2_3,D1_3_1,D1_3_2,D1_3_3,D2_1_1,D2_1_2,D2_1_3,D2_2_1,D2_2_2,D2_2_3,D2_3_1,D2_3_2,D2_3_3,D3_1_1,D3_1_2,D3_1_3,D3_2_1,D3_2_2,D3_2_3,D3_3_1,D3_3_2,D3_3_3,D4_1_1,D4_1_2,D4_1_3,D4_2_1,D4_2_2,D4_2_3,D4_3_1,D4_3_2,D4_3_3,D5_1_1,D5_1_2,D5_1_3,D5_2_1,D5_2_2,D5_2_3,D5_3_1,D5_3_2,D5_3_3,D6_1_1,D6_1_2,D6_1_3,D6_2_1,D6_2_2,D6_2_3,D6_3_1,D6_3_2,D6_3_3,D7_1_1,D7_1_2,D7_1_3,D7_2_1,D7_2_2,D7_2_3,D7_3_1,D7_3_2,D7_3_3,D8_1_1,D8_1_2,D8_1_3,D8_2_1,D8_2_2,D8_2_3,D8_3_1,D8_3_2,D8_3_3 level4
```

### 1.1.3 Docker 虚拟机和物理主机
- 传统虚拟机是虚拟出一个主机硬件,并且运行一个完整的操作系统 ,然后在这个系统上安装和运行软件
- 容器内的应用直接运行在宿主机的内核之上,容器并没有自己的内核,也不需要虚拟硬件,相当轻量化
- 每个容器间是互相隔离,每个容器内都有一个属于自己的独立文件系统,独立的进程空间,网络空间,用户空间等,所以在同一个宿主机上的多个容器之间彼此不会相互影响


```mermaid
graph LR
    %% 标题
    T[Docker容器 vs 虚拟机 vs 物理主机 对比分析] --> C1[资源利用率对比]
    T --> C2[性能对比]
    T --> C3[启动速度对比]
    T --> C4[隔离性对比]
    T --> C5[可移植性对比]
    T --> C6[安全性对比]
    T --> C7[部署复杂度对比]
    T --> C8[成本对比]
    T --> C9[适用场景对比]
    
    %% 资源利用率
    C1 --> D1[Docker容器]
    C1 --> V1[虚拟机]
    C1 --> P1[物理主机]
    
    D1 --> D1_1[高密度部署]
    D1 --> D1_2[共享内核]
    D1 --> D1_3[资源超分]
    D1 --> D1_4[快速伸缩]
    
    V1 --> V1_1[中等密度]
    V1 --> V1_2[独立内核]
    V1 --> V1_3[固定分配]
    V1 --> V1_4[较慢伸缩]
    
    P1 --> P1_1[单实例]
    P1 --> P1_2[专用资源]
    P1 --> P1_3[无虚拟化开销]
    P1 --> P1_4[硬件限制]
    
    %% 性能
    C2 --> D2[Docker容器]
    C2 --> V2[虚拟机]
    C2 --> P2[物理主机]
    
    D2 --> D2_1[接近原生性能]
    D2 --> D2_2[低CPU开销<1-2%]
    D2 --> D2_3[低内存开销]
    D2 --> D2_4[高效I/O]
    
    V2 --> V2_1[有性能损耗]
    V2 --> V2_2[较高CPU开销5-15%]
    V2 --> V2_3[内存开销大]
    V2 --> V2_4[I/O性能较低]
    
    P2 --> P2_1[最佳性能]
    P2 --> P2_2[零虚拟化开销]
    P2 --> P2_3[直接硬件访问]
    P2 --> P2_4[最优I/O性能]
    
    %% 启动速度
    C3 --> D3[Docker容器]
    C3 --> V3[虚拟机]
    C3 --> P3[物理主机]
    
    D3 --> D3_1[秒级启动]
    D3 --> D3_2[快速扩缩容]
    D3 --> D3_3[即时销毁]
    D3 --> D3_4[高效生命周期]
    
    V3 --> V3_1[分钟级启动]
    V3 --> V3_2[较慢伸缩]
    V3 --> V3_3[关闭较慢]
    V3 --> V3_4[较重生命周期]
    
    P3 --> P3_1[小时级启动]
    P3 --> P3_2[物理部署]
    P3 --> P3_3[无法快速伸缩]
    P3 --> P3_4[硬件依赖]
    
    %% 隔离性
    C4 --> D4[Docker容器]
    C4 --> V4[虚拟机]
    C4 --> P4[物理主机]
    
    D4 --> D4_1[进程级隔离]
    D4 --> D4_2[命名空间隔离]
    D4 --> D4_3[共享内核风险]
    D4 --> D4_4[Cgroups限制]
    
    V4 --> V4_1[完整系统隔离]
    V4 --> V4_2[硬件级隔离]
    V4 --> V4_3[独立内核]
    V4 --> V4_4[强安全边界]
    
    P4 --> P4_1[物理隔离]
    P4 --> P4_2[完全独立]
    P4 --> P4_3[无共享风险]
    P4 --> P4_4[最高隔离级别]
    
    %% 可移植性
    C5 --> D5[Docker容器]
    C5 --> V5[虚拟机]
    C5 --> P5[物理主机]
    
    D5 --> D5_1[高度可移植]
    D5 --> D5_2[跨环境一致]
    D5 --> D5_3[镜像标准化]
    D5 --> D5_4[云原生支持]
    
    V5 --> V5_1[中等可移植性]
    V5 --> V5_2[格式转换需求]
    V5 --> V5_3[较大文件体积]
    V5 --> V5_4[兼容性要求]
    
    P5 --> P5_1[低可移植性]
    P5 --> P5_2[硬件绑定]
    P5 --> P5_3[迁移复杂]
    P5 --> P5_4[物理限制]
    
    %% 安全性
    C6 --> D6[Docker容器]
    C6 --> V6[虚拟机]
    C6 --> P6[物理主机]
    
    D6 --> D6_1[命名空间隔离]
    D6 --> D6_2[内核共享风险]
    D6 --> D6_3[安全策略]
    D6 --> D6_4[镜像安全扫描]
    
    V6 --> V6_1[强隔离性]
    V6 --> V6_2[Hypervisor安全]
    V6 --> V6_3[完整沙箱]
    V6 --> V6_4[虚拟机逃逸防护]
    
    P6 --> P6_1[物理安全]
    P6 --> P6_2[网络隔离]
    P6 --> P6_3[硬件级安全]
    P6 --> P6_4[直接攻击面]
    
    %% 部署复杂度
    C7 --> D7[Docker容器]
    C7 --> V7[虚拟机]
    C7 --> P7[物理主机]
    
    D7 --> D7_1[简单部署]
    D7 --> D7_2[编排工具]
    D7 --> D7_3[自动化支持]
    D7 --> D7_4[DevOps友好]
    
    V7 --> V7_1[中等复杂度]
    V7 --> V7_2[模板部署]
    V7 --> V7_3[配置管理]
    V7 --> V7_4[资源规划]
    
    P7 --> P7_1[高复杂度]
    P7 --> P7_2[硬件配置]
    P7 --> P7_3[物理安装]
    P7 --> P7_4[维护成本高]
    
    %% 成本对比
    C8 --> D8[Docker容器]
    C8 --> V8[虚拟机]
    C8 --> P8[物理主机]
    
    D8 --> D8_1[低资源成本]
    D8 --> D8_2[高密度节省]
    D8 --> D8_3[运维自动化]
    D8 --> D8_4[快速ROI]
    
    V8 --> V8_1[中等成本]
    V8 --> V8_2[许可费用]
    V8 --> V8_3[管理工具]
    V8 --> V8_4[资源预留]
    
    P8 --> P8_1[高资本支出]
    P8 --> P8_2[硬件投资]
    P8 --> P8_3[维护费用]
    P8 --> P8_4[空间能耗成本]
    
    %% 适用场景
    C9 --> D9[Docker容器]
    C9 --> V9[虚拟机]
    C9 --> P9[物理主机]
    
    D9 --> D9_1[微服务架构]
    D9 --> D9_2[CI/CD流水线]
    D9 --> D9_3[云原生应用]
    D9 --> D9_4[开发测试环境]
    
    V9 --> V9_1[传统应用]
    V9 --> V9_2[Windows应用]
    V9 --> V9_3[混合环境]
    V9 --> V9_4[合规要求]
    
    P9 --> P9_1[高性能计算]
    P9 --> P9_2[数据库系统]
    P9 --> P9_3[GPU计算]
    P9 --> P9_4[安全敏感应用]
    
    %% 样式定义
    classDef title fill:#2e7d32,stroke:#1b5e20,stroke-width:3px,color:white
    classDef category fill:#1565c0,stroke:#0d47a1,stroke-width:2px,color:white
    classDef docker fill:#4caf50,stroke:#2e7d32,stroke-width:1.5px,color:white
    classDef vm fill:#ff9800,stroke:#f57c00,stroke-width:1.5px,color:black
    classDef physical fill:#f44336,stroke:#d32f2f,stroke-width:1.5px,color:white
    classDef detail fill:#e3f2fd,stroke:#90caf9,stroke-width:1px
    
    class T title
    class C1,C2,C3,C4,C5,C6,C7,C8,C9 category
    class D1,D2,D3,D4,D5,D6,D7,D8,D9 docker
    class V1,V2,V3,V4,V5,V6,V7,V8,V9 vm
    class P1,P2,P3,P4,P5,P6,P7,P8,P9 physical
    class D1_1,D1_2,D1_3,D1_4,D2_1,D2_2,D2_3,D2_4,D3_1,D3_2,D3_3,D3_4,D4_1,D4_2,D4_3,D4_4,D5_1,D5_2,D5_3,D5_4,D6_1,D6_2,D6_3,D6_4,D7_1,D7_2,D7_3,D7_4,D8_1,D8_2,D8_3,D8_4,D9_1,D9_2,D9_3,D9_4 detail
    class V1_1,V1_2,V1_3,V1_4,V2_1,V2_2,V2_3,V2_4,V3_1,V3_2,V3_3,V3_4,V4_1,V4_2,V4_3,V4_4,V5_1,V5_2,V5_3,V5_4,V6_1,V6_2,V6_3,V6_4,V7_1,V7_2,V7_3,V7_4,V8_1,V8_2,V8_3,V8_4,V9_1,V9_2,V9_3,V9_4 detail
    class P1_1,P1_2,P1_3,P1_4,P2_1,P2_2,P2_3,P2_4,P3_1,P3_2,P3_3,P3_4,P4_1,P4_2,P4_3,P4_4,P5_1,P5_2,P5_3,P5_4,P6_1,P6_2,P6_3,P6_4,P7_1,P7_2,P7_3,P7_4,P8_1,P8_2,P8_3,P8_4,P9_1,P9_2,P9_3,P9_4 detail
```

### 1.1.4 Docker 的组成
Docker 官网: http://www.docker.com

帮助文档链接: https://docs.docker.com/

Docker 镜像: https://hub.docker.com/

Docker 中文网站: http://www.docker.org.cn/

- Docker 主机(Host): 一个物理机或虚拟机，用于运行Docker服务进程和容器，也称为宿主机，node 节点
- Docker 服务端(Server): Docker 守护进程，运行 docker 容器 docker engine
- Docker 客户端(Client): 客户端使用 docker 命令或其他工具调用 docker API
- Docker 镜像(Images): 镜像可以理解为创建实例使用的模板,本质上就是一些程序文件的集合
- Docker 仓库(Registry): 保存镜像的仓库，官方仓库: https://hub.docker.com
	 可以搭建私有仓库 harbor
- Docker 容器(Container): 容器是从镜像生成对外提供服务的一个或一组服务,其本质就是将镜像中的程序启动后生成的进程
### 1.1.5 Namespace
