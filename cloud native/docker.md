# 一、Docker 介绍
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

| 特性        | Docker 容器 | 传统虚拟机  |
| --------- | --------- | ------ |
| **启动速度**​ | 秒级启动      | 分钟级启动  |
| **资源消耗**​ | 极低资源占用    | 较高资源开销 |
| **性能损耗**​ | 接近原生性能    | 明显性能损耗 |
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

- Docker 主机(Host): 一个物理机或虚拟机，用于运行 Docker 服务进程和容器，也称为宿主机，node 节点
- Docker 服务端(Server): Docker 守护进程，运行 docker 容器 docker engine
- Docker 客户端(Client): 客户端使用 docker 命令或其他工具调用 docker API
- Docker 镜像(Images): 镜像可以理解为创建实例使用的模板,本质上就是一些程序文件的集合
- Docker 仓库(Registry): 保存镜像的仓库，官方仓库: https://hub.docker.com
	 可以搭建私有仓库 harbor
- Docker 容器(Container): 容器是从镜像生成对外提供服务的一个或一组服务,其本质就是将镜像中的程序启动后生成的进程
## 1.2 Namespace
https://man7.org/linux/man-pages/man7/namespaces.7.html
https://en.wikipedia.org/wiki/Linux_namespaces

>[!question] 一个宿主机运行了 N 个容器，多个容器公用一个 OS，必然带来以下问题：
> - 怎么样保证每个容器都有不同的文件系统并且能互不影响？
> - 一个docker主进程内的各个容器都是其子进程，那么如果实现同一个主进程下不同类型的子进程？各个容器子进程间能相互通信(内存数据)吗？
> - 多个容器怎么解决 IP 及端口分配问题
> - 多个容器的主机名能一样吗
> - 每个容器都要不要有 root，怎么解决账户重名问题

![](assets/docker/file-20260213141126392.png)
Namespace 是 Linux 系统的底层核心概念，其实现逻辑位于 Linux 内核层 —— 内核中部署了多种不同类型的命名空间，为容器隔离提供了基础能力。
Docker 容器的运行机制有一个关键特征：所有容器都运行在宿主机的同一个 Docker 主进程下，并且共用宿主机的系统内核，容器自身仅运行在宿主机的**用户空间**中。尽管容器不像虚拟机那样拥有独立的内核，但仍需要实现与其他容器相互隔离的运行环境。
容器技术的核心是**在单个进程内为指定服务构建独立的运行环境**，同时确保宿主机内核不受容器内进程的干扰和影响（比如文件读写、网络请求、进程调度等层面）。

Linux Namespace 隔离类型详情表

|隔离类型|英文全称 / 简称|核心功能|系统调用参数|内核版本|
|---|---|---|---|---|
|MNT Namespace|mount|提供磁盘挂载点和文件系统的隔离能力|CLONE_NEWNS|2.4.19|
|PID Namespace|Process Identification|提供进程隔离能力（容器内进程 ID 独立编号，无法感知宿主机 / 其他容器进程）|CLONE_NEWPID|2.6.24|
|IPC Namespace|Inter-Process Communication|提供进程间通信的隔离能力，包括信号量、消息队列和共享内存|CLONE_NEWIPC|2.6.19|
|Net Namespace|network|提供网络隔离能力，包括网络设备、网络栈、端口等|CLONE_NEWNET|2.6.29|
|UTS Namespace|UNIX Timesharing System|提供内核、主机名和域名的隔离能力|CLONE_NEWUTS|2.6.19|
|User Namespace|user|提供用户隔离能力，包括用户和用户组的独立映射|CLONE_NEWUSER|3.8|
### 1. MNT Namespace（挂载命名空间）

#### 核心定义

MNT（Mount）Namespace 是最早实现的 Linux 命名空间（内核 2.4.19），核心作用是为每个容器提供**独立的文件系统挂载视图**。

#### 工作原理

- 每个 MNT Namespace 有自己的挂载点列表，容器内执行 `mount`/`umount` 操作仅影响自身的挂载表，不会改变宿主机或其他容器的文件系统挂载状态；
- 容器的根目录（`/`）会被挂载为独立的文件系统（如镜像层 + 可写层），使得容器 “看到” 的文件目录与宿主机、其他容器完全隔离。

#### 实际应用

- 容器可以拥有独立的 `/etc`、`/usr` 等目录，比如容器 A 的 `/etc/passwd` 和容器 B 的完全不同，互不干扰；
- 宿主机的磁盘分区可以按需挂载到容器内（如 `-v /host/data:/container/data`），但容器内的挂载操作不会反向影响宿主机。

### 2. PID Namespace（进程命名空间）

#### 核心定义

PID（Process Identification）Namespace（内核 2.6.24）实现**进程 ID 的隔离**，让每个容器拥有独立的进程编号空间。

#### 工作原理

- 每个 PID Namespace 内的第一个进程 PID 为 1（通常是容器的入口进程，如 `nginx`/`bash`），相当于容器内的 “init 进程”，负责回收子进程；
- 容器内只能看到自己 Namespace 内的进程，无法感知宿主机或其他容器的进程（即使宿主机的 PID 1000 在容器内可能显示为 PID 2）；
- PID Namespace 是层级化的，父 Namespace 可以看到子 Namespace 的进程（但 PID 编号不同），子 Namespace 无法看到父 Namespace 的进程。

#### 实际应用

- 容器内执行 `ps -ef` 只能看到容器自身的进程，避免进程 ID 冲突和误操作；
- 容器内杀死 PID 1 会直接导致容器退出（类似宿主机杀死 init 进程），保证容器的进程生命周期独立。

### 3. IPC Namespace（进程间通信命名空间）

#### 核心定义

IPC（Inter-Process Communication）Namespace（内核 2.6.19）隔离**进程间的通信方式**，防止不同容器的 IPC 资源互相干扰。

#### 工作原理

- IPC 资源包括：信号量（semaphores）、消息队列（message queues）、共享内存（shared memory）；
- 每个 IPC Namespace 有独立的 IPC 资源标识符，容器 A 创建的共享内存，容器 B 无法访问或修改。

#### 实际应用

- 多进程容器内的进程可以通过 IPC 通信（如共享内存传输数据），但不会和其他容器的 IPC 资源冲突；
- 避免不同容器的 IPC 资源耗尽对方的资源（比如一个容器的消息队列占满，不影响其他容器）。

### 4. Net Namespace（网络命名空间）

#### 核心定义

Net（Network）Namespace（内核 2.6.29）是容器网络隔离的核心，为每个容器提供**独立的网络栈**。

#### 工作原理

- 每个 Net Namespace 有独立的网络设备（如 `eth0`）、IP 地址、端口号、路由表、防火墙规则（iptables）、套接字（socket）；
- 宿主机通过虚拟网桥（如 `docker0`）连接所有容器的 Net Namespace，实现容器间 / 容器与外网的通信；
- 端口映射（如 `-p 8080:80`）本质是在宿主机的 Net Namespace 和容器的 Net Namespace 之间做 NAT 转发。

#### 实际应用

- 多个容器可以同时监听 80 端口（容器内），通过宿主机不同端口映射对外提供服务（如容器 A:80→宿主机：8080，容器 B:80→宿主机：8081）；
- 容器可以配置独立的 IP 地址（如 172.17.0.2），与其他容器或外网通信，网络故障仅影响自身。

### 5. UTS Namespace（主机名命名空间）

#### 核心定义

UTS（UNIX Timesharing System）Namespace（内核 2.6.19）隔离**主机名和域名**，让每个容器有独立的主机标识。

#### 工作原理

- UTS 是 “UNIX 分时系统” 的缩写，核心作用是让容器可以设置自己的 `hostname` 和 `domainname`，且仅在自身 Namespace 内生效；
- 宿主机执行 `hostname` 看到的是宿主机名，容器内执行 `hostname` 看到的是容器自定义的名称（如 `docker run --hostname my-container`）。

#### 实际应用

- 依赖主机名的应用（如集群软件、日志系统）可以在容器内独立配置主机名，无需修改宿主机；
- 不同容器可以使用相同的主机名，互不冲突。

### 6. User Namespace（用户命名空间）

#### 核心定义

User Namespace（内核 3.8）实现**用户和用户组的隔离与映射**，是容器安全的重要保障。

#### 工作原理

- 每个 User Namespace 有独立的 UID/GID（用户 / 组 ID）空间，容器内的 root 用户（UID 0）可以映射到宿主机的普通用户（如 UID 1000）；
- 容器内的 root 仅在自己的 Namespace 内拥有最高权限，在宿主机上仅拥有映射后的普通用户权限，即使容器内进程逃逸到宿主机，也无法获得 root 权限。

#### 实际应用

- 容器内以 root 运行应用（满足应用权限需求），但宿主机层面无 root 风险，提升容器安全性；
- 不同容器可以有独立的用户体系，比如容器 A 的 UID 1000 是普通用户，容器 B 的 UID 1000 可以是管理员，互不影响。

```bash
╭─[root@lnxguru] ~
╰─➤ grep -A10 CONFIG_NAMESPACES /boot/config-5.15.0-52-generic
grep: /boot/config-5.15.0-52-generic: No such file or directory
╭─[root@lnxguru] ~
╰─➤ grep -A10 CONFIG_NAMESPACES /boot/config-6.14.0-37-generic 
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_TIME_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_SCHED_AUTOGROUP=y
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
```

namespace
```bash
╭─[root@lnxguru] ~
╰─➤ lsns --help 

Usage:
 lsns [options] [<namespace>]

List system namespaces.

Options:
 -J, --json             use JSON output format
 -l, --list             use list format output
 -n, --noheadings       don't print headings'
 -o, --output <list>    define which output columns to use
     --output-all       output all columns
 -P, --persistent       namespaces without processes
 -p, --task <pid>       print process namespaces
 -r, --raw              use the raw output format
 -u, --notruncate       don't truncate text in columns
 -W, --nowrap           don't use multi-line representation
 -t, --type <name>      namespace type (mnt, net, ipc, user, pid, uts, cgroup, time)
 -T, --tree <rel>       use tree format (parent, owner, or process)

 -h, --help             display this help
 -V, --version          display version

Available output columns:
          NS  namespace identifier (inode number)
        TYPE  kind of namespace
        PATH  path to the namespace
      NPROCS  number of processes in the namespace
         PID  lowest PID in the namespace
        PPID  PPID of the PID
     COMMAND  command line of the PID
         UID  UID of the PID
        USER  username of the PID
     NETNSID  namespace ID as used by network subsystem
        NSFS  nsfs mountpoint (usually used network subsystem)
         PNS  parent namespace identifier (inode number)
         ONS  owner namespace identifier (inode number)

For more details see lsns(8).


╭─[root@lnxguru] ~
╰─➤ lsns -l 
        NS TYPE   NPROCS   PID USER             COMMAND
4026531834 time      369     1 root             /sbin/init splash
4026531835 cgroup    369     1 root             /sbin/init splash
4026531836 pid       369     1 root             /sbin/init splash
4026531837 user      367     1 root             /sbin/init splash
4026531838 uts       361     1 root             /sbin/init splash
4026531839 ipc       369     1 root             /sbin/init splash
4026531840 net       367     1 root             /sbin/init splash
4026531841 mnt       350     1 root             /sbin/init splash
4026531862 mnt         1    71 root             kdevtmpfs
4026532553 mnt         1   518 root             /usr/lib/systemd/systemd-udevd
4026532554 uts         1   518 root             /usr/lib/systemd/systemd-udevd
4026532555 mnt         1   932 systemd-timesync /usr/lib/systemd/systemd-timesyncd
4026532556 mnt         1   906 systemd-resolve  /usr/lib/systemd/systemd-resolved
4026532557 mnt         1   862 systemd-oom      /usr/lib/systemd/systemd-oomd
4026532585 uts         1   862 systemd-oom      /usr/lib/systemd/systemd-oomd
4026532586 uts         1   932 systemd-timesync /usr/lib/systemd/systemd-timesyncd
4026532587 mnt         1  1374 root             /usr/lib/systemd/systemd-logind
4026532589 uts         1  1374 root             /usr/lib/systemd/systemd-logind
4026532591 uts         1  1411 syslog           /usr/sbin/rsyslogd -n -iNONE
4026532592 mnt         1  1320 polkitd          /usr/lib/polkit-1/polkitd --no-debug
4026532602 mnt         1  1485 root             /usr/sbin/NetworkManager --no-daemon
4026532603 uts         1  1320 polkitd          /usr/lib/polkit-1/polkitd --no-debug
4026532606 mnt         1  1560 root             /usr/sbin/ModemManager
4026532613 mnt         1  4672 root             /usr/libexec/fwupd/fwupd
4026532642 mnt         1  1322 root             /usr/libexec/power-profiles-daemon
4026532644 net         1  1345 root             /usr/libexec/accounts-daemon
4026532698 uts         1  1322 root             /usr/libexec/power-profiles-daemon
4026532700 mnt         1  1345 root             /usr/libexec/accounts-daemon
4026532701 mnt         1  1356 root             /usr/libexec/switcheroo-control
4026532727 mnt         2  3748 xuruizhao        /snap/snapd-desktop-integration/343/usr/bin/snapd-desktop-integration
4026532729 mnt         1  1734 root             /usr/libexec/bluetooth/bluetoothd
4026532777 net         1  2453 rtkit            /usr/libexec/rtkit-daemon
4026532832 mnt         1  2453 rtkit            /usr/libexec/rtkit-daemon
4026532833 mnt         0       root             
4026532834 mnt         1  2616 colord           /usr/libexec/colord
4026532835 uts         1  2616 colord           /usr/libexec/colord
4026532836 user        1  2616 colord           /usr/libexec/colord
4026532894 mnt         1  2662 root             /usr/libexec/upowerd
4026532895 user        1  2662 root             /usr/libexec/upowerd


╭─[root@lnxguru] ~
╰─➤ lsns -t  net
        NS TYPE NPROCS   PID USER     NETNSID NSFS COMMAND
4026531840 net     368     1 root  unassigned      /sbin/init splash
4026532644 net       1  1345 root  unassigned      ├─/usr/libexec/accounts-daemon
4026532777 net       1  2453 rtkit unassigned      └─/usr/libexec/rtkit-daemon


╭─[root@lnxguru] ~
╰─➤ nsenter --help 

Usage:
 nsenter [options] [<program> [<argument>...]]

Run a program with namespaces of other processes.

Options:
 -a, --all              enter all namespaces
 -t, --target <pid>     target process to get namespaces from
 -m, --mount[=<file>]   enter mount namespace
 -u, --uts[=<file>]     enter UTS namespace (hostname etc)
 -i, --ipc[=<file>]     enter System V IPC namespace
 -n, --net[=<file>]     enter network namespace
 -p, --pid[=<file>]     enter pid namespace
 -C, --cgroup[=<file>]  enter cgroup namespace
 -U, --user[=<file>]    enter user namespace
 -T, --time[=<file>]    enter time namespace
 -S, --setuid[=<uid>]   set uid in entered namespace
 -G, --setgid[=<gid>]   set gid in entered namespace
     --preserve-credentials do not touch uids or gids
 -r, --root[=<dir>]     set the root directory
 -w, --wd[=<dir>]       set the working directory
 -W, --wdns <dir>       set the working directory in namespace
 -e, --env              inherit environment variables from target process
 -F, --no-fork          do not fork before exec'ing <program>
 -Z, --follow-context   set SELinux context according to --target PID

 -h, --help             display this help
 -V, --version          display version

For more details see nsenter(1).'


# 说明:5387 为容器在宿主机的 Pid,下面表示进入5387容器的对应网络名称空间执行命令
╭─[root@lnxguru] ~
╰─➤ ls -l /proc/5387/ns
total 0
lrwxrwxrwx 1 root root 0 Feb 13 14:40 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 Feb 13 14:40 ipc -> 'ipc:[4026531839]'
lrwxrwxrwx 1 root root 0 Feb 13 14:40 mnt -> 'mnt:[4026531841]'
lrwxrwxrwx 1 root root 0 Feb 13 14:40 net -> 'net:[4026531840]'
lrwxrwxrwx 1 root root 0 Feb 13 14:40 pid -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 Feb 13 14:40 pid_for_children -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 Feb 13 14:40 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 Feb 13 14:40 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 Feb 13 14:40 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 Feb 13 14:40 uts -> 'uts:[4026531838]'

╭─[root@lnxguru] ~
╰─➤ nsenter -t 5387 -n ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:f7:69:7c brd ff:ff:ff:ff:ff:ff
    altname enp2s1
    inet 192.168.121.197/24 brd 192.168.121.255 scope global dynamic noprefixroute ens33
       valid_lft 1155sec preferred_lft 1155sec
    inet6 fe80::20c:29ff:fef7:697c/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 36:6a:33:d7:f8:fd brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::346a:33ff:fed7:f8fd/64 scope link 
       valid_lft forever preferred_lft forever
4: veth4f8bbb4@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether 92:9c:a9:4c:70:7c brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::909c:a9ff:fe4c:707c/64 scope link 
       valid_lft forever preferred_lft forever

```
## 1.3 Control groups
Linux Cgroups 的全称是 Linux Control Groups,是 Linux 内核的一个功能.最早是由 Google 的工程师（主要是 Paul Menage 和 Rohit Seth）在2006年发起，最早的名称为进程容器（process containers）。
在2007年时，因为在 Linux 内核中，容器（container）这个名词有许多不同的意义，为避免混乱，被重命名为 cgroup，并且被合并到2.6.24版的内核中去。自那以后，又添加了很多功能。

如果不对一个容器做任何资源限制，则宿主机会允许其占用无限大的内存空间，有时候会因为代码 bug 程序会一直申请内存，直到把宿主机内存占完，为了避免此类的问题出现，宿主机有必要对容器进行资源分配限制，比如 CPU、内存等
Cgroups 最主要的作用，就是限制一个进程组能够使用的资源上限，包CPU、内存、磁盘、网络带宽等等。此外，还能够对进程进行优先级设置，资源的计量以及资源的控制(比如:将进程挂起和恢复等操作)。
Cgroups 在内核层默认已经开启，从 CentOS 和 Ubuntu 不同版本对比，显然内核较新的支持的功能更多。
```bash
╭─[root@lnxguru] ~
╰─➤ grep CGROUP /boot/config-6.14.0-37-generic 
CONFIG_CGROUPS=y
# CONFIG_CGROUP_FAVOR_DYNMODS is not set
CONFIG_BLK_CGROUP=y
CONFIG_CGROUP_WRITEBACK=y
CONFIG_CGROUP_SCHED=y
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
CONFIG_CGROUP_DMEM=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_BPF=y
CONFIG_CGROUP_MISC=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_BLK_CGROUP_RWSTAT=y
CONFIG_BLK_CGROUP_PUNT_BIO=y
# CONFIG_BLK_CGROUP_IOLATENCY is not set
CONFIG_BLK_CGROUP_FC_APPID=y
CONFIG_BLK_CGROUP_IOCOST=y
CONFIG_BLK_CGROUP_IOPRIO=y
# CONFIG_BFQ_CGROUP_DEBUG is not set
CONFIG_NETFILTER_XT_MATCH_CGROUP=m
CONFIG_NET_CLS_CGROUP=m
CONFIG_CGROUP_NET_PRIO=y
CONFIG_CGROUP_NET_CLASSID=y
# CONFIG_DEBUG_CGROUP_REF is not set
```
## 1.4 容器管理工具
有了以上的 namespace、cgroups 就具备了基础的容器运行环境，但是还需要有相应的容器创建与删除的管理工具、以及怎么样把容器运行起来、容器数据怎么处理、怎么进行启动与关闭等问题需要解决，于是容器管理技术出现了。目前主要是使用 docker，containerd 等，早期使用 LXC

## 1.5 Docker 优势
- **极速部署交付**：支持短时间内批量部署成百上千个应用，大幅缩短从开发到上线的交付周期，快速响应业务需求。
- **高效轻量虚拟化**：无需额外 hypervisor 虚拟化层，基于 Linux 内核原生技术实现应用级虚拟化，相比传统虚拟机，减少资源冗余开销，性能和运行效率显著提升。
- **显著节省开支**：通过提高服务器资源利用率（支持多容器高密度部署），减少物理服务器采购、运维及能耗成本，降低整体 IT 支出。
- **配置简化便捷**：将应用运行环境（依赖、配置、代码等）整体打包为容器镜像，使用时直接启动镜像即可快速部署，无需重复配置环境。
- **环境标准化统一**：实现开发、测试、生产全流程环境的标准化，彻底解决 “开发环境能跑、测试 / 生产环境报错” 的环境不一致问题，减少调试成本。
- **灵活迁移与扩展**：容器具备良好的跨平台兼容性，可无缝运行在物理机、虚拟机、公有云、私有云等不同环境，支持应用在不同宿主机、不同平台间快速迁移；同时支持横向弹性扩展，满足业务流量波动需求。
- **适配微服务架构**：推荐 “一个容器运行一个应用” 的部署模式，天然契合面向服务的架构（SOA）和微服务理念，实现应用的分布式部署。这种模式符合 “高内聚、低耦合” 的开发原则，可降低不同服务间的相互干扰，便于独立升级、维护和横向扩展。
## 1.6 容器相关技术
### 1.6.1 容器规范
![](assets/docker/file-20260213145045609.png)

OCI 官网:https://opencontainers.org/

容器技术除了的 docker 之外，还有 coreOS 的 rkt，还有阿里的 Pouch 等等
为了保证容器生态的标准性和健康可持续发展，包括 Linux 基金会、Docker、微软、红帽、谷歌和 IBM 等公司在2015年6月共同成立了一个叫 Open Container Initiative（OCI）的组织，其目的就是制定开放的标准的容器规范
目前 OCI 一共发布了两个规范，分别是 runtime spec 和 image format spec，有了这两个规范，不同的容器公司开发的容器只要兼容这两个规范，就可以保证容器的可移植性和相互可操作性。
### 1.6.2 容器 runtime
runtime 是真正运行容器的地方，因此为了运行不同的容器 runtime 需要和操作系统内核紧密合作相互在支持，以便为容器提供相应的运行环境
对于容器运行时主要有两个级别：Low Level (使用接近内核层) 和 High Level (使用接近用户层)目前，市面上常用的容器引擎有很多，主要有下图的那几种。
```mermaid
graph TD
    A[容器运行时 Runtime] --> B[Low Level 运行时<br/>(接近内核层)]
    A --> C[High Level 运行时<br/>(接近用户层)]
    
    %% 底层运行时（贴近内核，提供基础容器运行能力）
    B --> B1[runc<br/>（OCI 标准，Docker/Containerd 底层）]
    B --> B2[crun<br/>（轻量级，替代 runc，性能更优）]
    B --> B3[kata-runtime<br/>（安全隔离型，结合轻量虚拟机）]
    B --> B4[runv<br/>（基于 Hypervisor 的虚拟化运行时）]
    
    %% 高层运行时（贴近用户，提供更友好的封装和管理能力）
    C --> C1[Containerd<br/>（Docker 剥离的核心，K8s 默认）]
    C --> C2[Docker Engine<br/>（经典引擎，包含完整工具链）]
    C --> C3[CRI-O<br/>（专为 K8s CRI 设计的轻量引擎）]
    C --> C4[Podman<br/>（无守护进程，兼容 Docker 命令）]
    C --> C5[LXD/LXC<br/>（系统级容器，侧重完整系统环境）]
    
    %% 标注核心特性
    B1 -. OCI 规范标准实现 .-> A
    C1 -. 对接 K8s CRI 接口 .-> A
    C2 -. 一站式容器管理（含镜像/网络/存储） .-> A
```
查看 docker  的 runtime
```bash
╭─[root@lnxguru] ~
╰─➤ docker info  | grep Runtimes
 Runtimes: io.containerd.runc.v2 runc

```
### 1.6.3 镜像仓库 Registry
统一保存镜像而且是多个不同镜像版本的地方，叫做镜像仓库

- Docker hub: docker 官方的公共仓库，已经保存了大量的常用镜像，可以方便大家直接使用
- 阿里云，网易等第三方镜像的公共仓库
- Image registry: docker 官方提供的私有仓库部署工具，无 web 管理界面，目前使用较少
- Harbor: vmware 提供的自带 web 界面自带认证功能的镜像私有仓库，目前有很多公司使用
```ini
docker.io/library/alpine

harbor.wang.org/project/centos:7.2.1511

registry.cn-hangzhou.aliyuncs.com/wangxiaochun/busybox:v1.0

172.18.200.101/project/centos: latest

172.18.200.101/project/java-7.0.59:v1
```
### 1.6.4 容器编排工具
当多个容器在多个主机运行的时候，单独管理容器是相当复杂而且很容易出错，而且也无法实现某一台主机宕机后容器自动迁移到其他主机从而实现高可用的目的，也无法实现动态伸缩的功能，因此需要有一种工具可以实现统一管理、动态伸缩、故障自愈、批量执行等功能，这就是容器编排引擎

容器编排通常包括容器管理、调度、集群定义和服务发现等功能

- Docker compose : docker 官方实现单机的容器的编排工具
- Docker swarm: docker 官方开发的容器编排引擎,支持overlay network
- Mesos+Marathon: Mesos 是 Apache 下的开源分布式资源管理框架，它被称为是分布式系统的内核。Mesos 最初是由加州大学伯克利分校的 AMPLab 开发的，后在 Twitter 得到广泛使用。通用的集群组员调度平台，mesos(资源分配)与 marathon(容器编排平台)一起提供容器编排引擎功能
- Kubernetes: google 领导开发的容器编排引擎，内部项目为 Borg，且其同时支持 docker 和CoreOS,当前已成为容器编排工具事实上的标准
# 二、Docker 部署
官方网址: https://www.docker.com/
OS系统版本选择:

Docker 目前已经支持多种操作系统的安装运行，比如 Ubuntu、CentOS、Redhat、Debian、Fedora，甚至是还支持了 Mac 和 Windows，在 linux 系统上需要内核版本在3.10或以上

Docker 版本选择
github 地址: https://github.com/moby/moby
## 2.1 docker 安装和删除
官方文档 : https://docs.docker.com/engine/install/
阿里云文档: https://developer.aliyun.com/mirror/docker-ce?spm=a2c6h.13651102.0.0.3221b11guHCWE

安装方法
- 内置仓库
- 官方仓库（国内镜像）
- 二进制安装（离线）
- 官方脚本
### 2.1.1 Linux 二进制离线安装
官方文档: https://docs.docker.com/install/linux/docker-ce/ubuntu/
本方法适用于无法上网或无法通过包安装方式安装的主机上安装docker
安装文档: https://docs.docker.com/install/linux/docker-ce/binaries/

二进制安装下载路径
https://download.docker.com/linux/
https://mirrors.aliyun.com/docker-ce/linux/static/stable/x86_64/
你希望将这段在CentOS 8上手动安装Docker 19.03.5并验证运行的操作日志，整理成**结构清晰、步骤明确、关键信息突出**的文档形式，我会按“操作步骤+关键输出+核心说明”的逻辑重新梳理，方便查阅和理解。

>[!info] CentOS 8 手动安装 Docker 19.03.5 完整操作记录
#### 2.1.1.1操作环境
- 系统版本：CentOS 8
- Docker版本：19.03.5（静态二进制包方式安装）

#### 2.1.1.2 核心操作步骤
##### 1. 下载Docker静态二进制包
```bash
[root@centos8 ~]# wget https://download.docker.com/linux/static/stable/x86_64/docker-19.03.5.tgz
```

##### 2. 解压二进制包
解压后生成`docker`目录，包含Docker核心组件（如dockerd、docker、runc、containerd等）：
```bash
[root@centos8 ~]# tar xvf docker-19.03.5.tgz 
docker/
docker/docker-init
docker/docker
docker/dockerd
docker/runc
docker/ctr
docker/docker-proxy
docker/containerd
docker/containerd-shim
```

##### 3. 复制核心组件到系统可执行目录
将解压后的Docker组件复制到`/usr/local/bin`（系统PATH路径），确保可全局调用：
```bash
[root@centos8 ~]# cp docker/* /usr/local/bin/
```

##### 4. 启动Docker守护进程（dockerd）
后台启动dockerd，并重定向日志到空设备（不输出终端）：
```bash
[root@centos8 ~]# dockerd &>/dev/null &
```

##### 5. 验证Docker版本与安装状态
查看客户端和服务端版本信息，确认核心组件（containerd、runc、docker-init）正常：
```bash
[root@centos8 ~]# docker version
Client: Docker Engine - Community
 Version:           19.03.5
 API version:       1.40
 Go version:        go1.12.12
 Git commit:        633a0ea838
 Built:             Wed Nov 13 07:22:05 2019
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.5
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.12
  Git commit:       633a0ea838
  Built:            Wed Nov 13 07:28:45 2019
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.2.10
  GitCommit:        b34a5c8af56e510852c35414db4c1f4fa6172339
 runc:
  Version:          1.0.0-rc8+dev
  GitCommit:        3e425f80a8c931f88e6d94a8c831b9d5aa481657
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

##### 6. 运行测试容器验证功能
通过`hello-world`镜像验证Docker完整运行流程（拉取镜像→创建容器→运行→输出结果）：
```bash
[root@centos8 ~]# docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete 
Digest: sha256:9572f7cdcee8591948c2963463447a53466950b3fc15a247fcad1917ca215a2f
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
1. The Docker client contacted the Docker daemon.
2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
   (amd64)
3. The Docker daemon created a new container from that image which runs the
   executable that produces the output you are currently reading.
4. The Docker daemon streamed that output to the Docker client, which sent it
   to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
$ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

##### 7. 查看Docker相关进程树
通过`pstree -p`确认Docker核心进程（dockerd、containerd）正常运行，且隶属于systemd（PID 1）：
```bash
[root@centos8 ~]# pstree -p
systemd(1)─┬─NetworkManager(660)─┬─{NetworkManager}(669)
           │                     └─{NetworkManager}(671)
           ├─VGAuthService(662)
           ├─agetty(718)
           ├─atd(712)
           ├─auditd(625)───{auditd}(627)
           ├─automount(905)─┬─{automount}(912)
           │                 ├─{automount}(913)
           │                 ├─{automount}(930)
           │                 └─{automount}(937)
           ├─containerd(679)─┬─{containerd}(693)
           │                 ├─{containerd}(694)
           │                 ├─{containerd}(696)
           │                 ├─{containerd}(704)
           │                 ├─{containerd}(705)
           │                 ├─{containerd}(707)
           │                 └─{containerd}(708)
           ├─crond(713)
           ├─dbus-daemon(658)
           ├─dockerd(908)─┬─{dockerd}(922)
           │               ├─{dockerd}(923)
           │               ├─{dockerd}(925)
           │               ├─{dockerd}(944)
           │               ├─{dockerd}(1028)
           │               ├─{dockerd}(1100)
           │               └─{dockerd}(1114)
           ├─polkitd(659)─┬─{polkitd}(670)
           │               ├─{polkitd}(672)
           │               ├─{polkitd}(677)
           │               ├─{polkitd}(678)
           │               └─{polkitd}(701)
           ├─rngd(664)───{rngd}(666)
           ├─rsyslogd(906)─┬─{rsyslogd}(911)
           │                 └─{rsyslogd}(914)
           ├─sshd(675)───sshd(1370)───sshd(1382)───bash(1383)───pstree(1441)
           ├─sssd(661)─┬─sssd_be(688)
           │             └─sssd_nss(703)
           ├─systemd(1373)───(sd-pam)(1376)
           ├─systemd-journal(551)
           ├─systemd-logind(709)
           ├─systemd-udevd(580)
           ├─tuned(674)─┬─{tuned}(915)
           │             ├─{tuned}(934)
           │             └─{tuned}(948)
           └─vmtoolsd(663)
```

#### 2.1.1.3关键信息说明
1. **安装方式特点**：本次为“静态二进制包安装”，无需依赖包管理器（yum），直接解压即可使用，适合离线环境；
2. **核心进程关系**：
   - `dockerd`：Docker守护进程（服务端），处理容器创建/运行请求；
   - `containerd`：底层容器运行时管理进程，dockerd通过它调用runc；
   - `runc`：OCI标准的Low Level运行时，直接与内核交互创建容器；
3. **验证结果**：`hello-world`容器正常运行，说明Docker客户端、服务端、镜像拉取、容器运行全流程均正常。
### 2.1.2 ubuntu 包安装 Docker
官方文档: https://docs.docker.com/install/linux/docker-ce/ubuntu/
#### 方式一：安装最新版 Docker-CE
```bash
# Step 1: 更新系统包并安装必要依赖
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

# Step 2: 添加 Docker 官方 GPG 证书（阿里云镜像）
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

# Step 3: 添加阿里云 Docker 软件源
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

# Step 4: 更新源并安装最新版 Docker-CE
sudo apt-get -y update
sudo apt-get -y install docker-ce
```

---

#### 方式二：安装指定版本 Docker-CE
```bash
# Step 1: 先执行方式一的 Step 1-3（安装依赖、添加证书和源）

# Step 2: 查看可安装的 Docker-CE 版本列表
apt-cache madison docker-ce

# Step 3: 安装指定版本（替换 [VERSION] 为实际版本号）
# 格式：sudo apt-get -y install docker-ce=[版本号] docker-ce-cli=[版本号]

# 示例1：Ubuntu 18.04 (bionic) 安装 5:18.09.9~3-0~ubuntu-bionic
sudo apt-get -y install docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic

# 示例2：Ubuntu 22.04 (jammy) 安装 5:24.0.6-1~ubuntu.22.04~jammy
sudo apt-get -y install docker-ce=5:24.0.6-1~ubuntu.22.04~jammy docker-ce-cli=5:24.0.6-1~ubuntu.22.04~jammy
```

---

#### 关键补充说明
1. **版本号获取**：`apt-cache madison docker-ce` 命令输出的第一列后紧跟的字符串即为完整版本号（如 `5:24.0.6-1~ubuntu.22.04~jammy`），需完整复制使用，不能省略部分内容。
2. **架构适配**：命令中 `[arch=amd64]` 适用于 x86_64 架构，若为 arm 架构（如树莓派），需改为 `[arch=arm64]` 或 `[arch=armhf]`。
3. **权限验证**：安装完成后可执行 `sudo docker --version` 验证版本，执行 `sudo docker run hello-world` 验证是否能正常运行容器。
4. **换行符修正**：原命令中部分换行导致的断行（如 `softwareproperties-common`）已修正为正确的 `software-properties-common`，避免执行报错。
## 2.2 Docker 相关信息和优化配置
### 2.2.1 查看 docker 版本
```bash
╭─[root@lnxguru] ~
╰─➤ docker version
Client:
 Version:           29.1.1
 API version:       1.52
 Go version:        go1.25.4
 Git commit:        0aedba5
 Built:             Fri Nov 28 11:32:24 2025
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          29.1.1
  API version:      1.52 (minimum version 1.44)
  Go version:       go1.25.4
  Git commit:       9a84135
  Built:            Fri Nov 28 11:34:50 2025
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v2.2.0
  GitCommit:        1c4457e00facac03ce1d75f7b6777a7a851e5c41
 runc:
  Version:          1.3.3
  GitCommit:        v1.3.3-0-gd842d77
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0

```
### 2.2.2 查看 docker 详解信息
```bash
docker info
```

#### 一、客户端（Client）信息

|字段|取值|说明|
|---|---|---|
|Debug Mode|false|客户端是否开启调试模式（开启后会输出更详细的日志）|

#### 二、服务端（Server）核心运行信息

|类别|字段|取值|说明|
|---|---|---|---|
|容器统计|Containers|2|主机上所有容器总数（运行 + 暂停 + 停止）|
||Running|0|正在运行的容器数量|
||Paused|0|暂停状态的容器数量|
||Stopped|2|停止状态的容器数量|
|镜像信息|Images|4|主机上本地存储的 Docker 镜像总数|
|版本信息|Server Version|19.03.5|Docker 服务端（daemon）版本|
||containerd version|b34a5c8af56e510852c35414db4c1f4fa6172339|容器运行时底层 containerd 版本|
||runc version|3e425f80a8c931f88e6d94a8c831b9d5aa481657|默认运行时 runc 的版本|
||init version|fec3683|容器初始化进程（pid=1）的版本|

#### 三、存储与运行时配置

|类别|字段|取值|说明|
|---|---|---|---|
|存储驱动|Storage Driver|overlay2|Docker 使用的存储引擎（overlay2 是主流高性能引擎）|
||Backing Filesystem|extfs|宿主机底层文件系统（即磁盘格式）|
||Supports d_type|true|是否支持 d_type（overlay2 必需，用于文件类型识别）|
||Native Overlay Diff|true|是否支持原生差异存储（减少磁盘占用）|
|运行时|Runtimes|runc|已安装的容器运行时列表|
||Default Runtime|runc|默认使用的容器运行时（OCI 标准底层运行时）|
||Init Binary|docker-init|容器初始化守护进程（负责容器内 pid=1 进程管理）|
|Cgroup 驱动|Cgroup Driver|cgroupfs|资源限制（内存 / CPU）的管理驱动|

#### 四、网络与插件配置

|类别|字段|取值|说明|
|---|---|---|---|
|插件|Volume|local|已启用的存储卷插件（local 为本地卷）|
||Network|bridge、host、ipvlan、macvlan、null、overlay|已启用的网络插件（overlay 支持跨主机容器通信）|
||Log|awslogs、fluentd、gcplogs、gelf、journald、json-file、local、logentries、splunk、syslog|支持的日志驱动类型|
|日志配置|Logging Driver|json-file|默认日志驱动（日志文件路径：/var/lib/docker/containers/<容器 ID>/< 容器 ID>-json.log）|
|Swarm 模式|Swarm|inactive|是否启用 Swarm 集群模式（inactive 为未启用）|

#### 五、系统环境信息


| 字段               | 取值                                                          | 说明                             |
| ---------------- | ----------------------------------------------------------- | ------------------------------ |
| Kernel Version   | 4.15.0-29-generic                                           | 宿主机 Linux 内核版本（需兼容 Docker 运行时） |
| Operating System | Ubuntu 18.04.1 LTS                                          | 宿主机操作系统版本                      |
| OSType           | linux                                                       | 宿主机操作系统类型                      |
| Architecture     | x86_64                                                      | 宿主机 CPU 架构（64 位 x86）           |
| CPUs             | 1                                                           | 宿主机 CPU 核心数                    |
| Total Memory     | 962MiB                                                      | 宿主机总内存                         |
| Name             | [ubuntu180                                                  | 宿主机主机名                         |
| ID               | IZHJ:WPIN:BRMC:XQUI:VVVR:UVGK:NZBM:YQXT:JDWB:33RS:45V7:SQWJ | Docker 节点唯一标识                  |

#### 六、安全与仓库配置

|类别|字段|取值|说明|
|---|---|---|---|
|安全选项|Security Options|apparmor、seccomp（Profile: default）|apparmor：系统安全模块；seccomp：限制容器系统调用（默认配置文件）|
|仓库配置|Registry|[https://index.docker.io/v1/](https://index.docker.io/v1/)|默认镜像仓库地址（Docker Hub）|
||Insecure Registries|127.0.0.0/8|非安全镜像仓库（无需 HTTPS 认证）|
||Registry Mirrors|[https://si7y70hh.mirror.aliyuncs.com/](https://si7y70hh.mirror.aliyuncs.com/)|镜像加速地址（阿里云镜像源，提升拉取速度）|
|数据目录|Docker Root Dir|/var/lib/docker|Docker 数据（镜像、容器、日志等）存储根目录（建议挂载独立高性能磁盘）|

#### 七、其他配置与警告


|字段|取值|说明|
|---|---|---|
|Debug Mode（Server）|false|服务端是否开启调试模式|
|Experimental|false|是否启用 Docker 实验性功能|
|Live Restore Enabled|false|重启 Docker 守护进程时是否保留容器运行（false 则重启 daemon 会关闭所有容器）|
|警告信息|WARNING: No swap limit support|系统未开启 swap 资源限制（需修改内核参数启用，否则无法限制容器使用 swap 内存）|


### 2.2.3 查看 docker0 网卡
在 docker 安装启动之后，默认会生成一个名称为 docker0 的网卡并且默认IP地址为172.17.0.1的网卡
```bash
╭─[root@lnxguru] ~
╰─➤ ifconfig docker0
docker0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::346a:33ff:fed7:f8fd  prefixlen 64  scopeid 0x20<link>
        ether 36:6a:33:d7:f8:fd  txqueuelen 0  (Ethernet)
        RX packets 3  bytes 84 (84.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 313  bytes 63741 (63.7 KB)
        TX errors 0  dropped 31 overruns 0  carrier 0  collisions 0
```

### 2.2.4 docker 镜像仓库配置
范例: 支持官方仓库和私有仓库镜像下载
```json
[root@ubuntu2004 ~]#cat /etc/docker/daemon.json

{

"registry-mirrors": [  #只支持docker官方镜像

"https://docker.m.daocloud.io",

"https://docker.1panel.live",

"https://docker.1ms.run",

"https://docker.xuanyuan.me"

  ],

"insecure-registries": ["harbor.wang.org"]

}
```

#### 一、规范的配置文件内容
```json
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://si7y70hh.mirror.aliyuncs.com/"
  ],
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"],
  "insecure-registries": ["harbor.wang.org"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "data-root": "/data/docker",
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5,
  "log-opts": {
    "max-size": "300m",
    "max-file": "2"
  },
  "live-restore": true,
  "proxies": {
    "default": {
      "httpProxy": "http://proxy.example.com:3128",
      "httpsProxy": "https://proxy.example.com:3129",
      "noProxy": "*.test.example.com,.example.org,127.0.0.0/8"
    },
    "tcp://docker-daemon1.example.com": {
      "noProxy": "*.internal.example.net"
    }
  }
}
```

#### 二、核心配置项详解（按功能分类）
| 配置项                        | 取值/示例                                                  | 功能说明                                                                     | 注意事项                                                                                                                                         |
| -------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **镜像加速**                   |                                                        |                                                                          |                                                                                                                                              |
| `registry-mirrors`         | 国内镜像源列表                                                | 配置 Docker 镜像拉取加速地址，提升镜像下载速度                                              | 优先使用阿里云个人专属镜像源（替换示例中的 si7y70hh 为自己的）                                                                                                         |
| **网络配置**                   |                                                        |                                                                          |                                                                                                                                              |
| `hosts`                    | `unix:///var/run/docker.sock`<br/>`tcp://0.0.0.0:2375` | 配置 Docker 守护进程监听地址：<br/>- unix 套接字：本地通信<br/>- TCP 2375：允许远程访问 Docker API | 新版 Docker（20.10+）不推荐直接在 daemon.json 配置 `hosts`，建议修改 `docker.service` 文件（ExecStart 中加 `-H tcp://0.0.0.0:2375`）；<br/>2375 端口无加密，生产环境需配合 TLS 加密 |
| `insecure-registries`      | `harbor.test.org`                                      | 配置非 HTTPS 协议的私有镜像仓库（如 Harbor），允许 Docker 拉取/推送镜像                          | 仅测试/内网环境使用，生产环境建议配置 HTTPS                                                                                                                    |
| **资源与驱动**                  |                                                        |                                                                          |                                                                                                                                              |
| `exec-opts`                | `native.cgroupdriver=systemd`                          | 指定 Docker 的 Cgroup 驱动为 systemd                                           | 适配 Systemd 系统（如 Ubuntu/CentOS 7+），与 k8s 兼容更佳                                                                                                 |
| `data-root`                | `/data/docker`                                         | 指定 Docker 数据根目录（镜像、容器、日志等存储路径）                                           | 旧版字段为 `graph`（Docker 24.0+ 已废弃）；<br/>也可通过 `dockerd --data-root=/data/docker` 启动参数指定                                                          |
| **镜像传输**                   |                                                        |                                                                          |                                                                                                                                              |
| `max-concurrent-downloads` | 10                                                     | 镜像拉取时的最大并发下载数                                                            | 提升多层镜像的下载速度                                                                                                                                  |
| `max-concurrent-uploads`   | 5                                                      | 镜像推送时的最大并发上传数                                                            | 避免上传占用过多网络资源                                                                                                                                 |
| **日志配置**                   |                                                        |                                                                          |                                                                                                                                              |
| `log-opts.max-size`        | 300m                                                   | 单个容器日志文件的最大大小                                                            | 超过该大小会自动切割日志                                                                                                                                 |
| `log-opts.max-file`        | 2                                                      | 容器日志文件的最大保留个数                                                            | 日志文件循环写入（如 container.log.1 → container.log.2），超出则删除最旧的                                                                                       |
| **服务稳定性**                  |                                                        |                                                                          |                                                                                                                                              |
| `live-restore`             | true                                                   | 重启 Docker 守护进程时，不中断正在运行的容器                                               | 提升 Docker 服务升级/重启时的可用性                                                                                                                       |
| **网络代理**                   |                                                        |                                                                          |                                                                                                                                              |
| `proxies`                  | 示例代理配置                                                 | 配置 Docker 拉取镜像时使用的 HTTP/HTTPS 代理                                         | `noProxy` 为无需走代理的域名/IP段；<br/>可针对特定 daemon 地址配置独立代理规则                                                                                         |

#### 三、配置生效命令
修改 `daemon.json` 后，需重新加载配置并重启 Docker 服务使配置生效：
```bash
[root@ubuntu2004 ~]# systemctl daemon-reload && systemctl restart docker.service
```

#### 四、验证配置是否生效
```bash
# 查看 Docker 整体配置
docker info

# 查看具体配置项（如镜像加速、数据目录）
docker info | grep -E "Registry Mirrors|Docker Root Dir"
```
### 2.2.5 docker 实现代理功能
#### 一、问题现象：拉取 k8s 镜像失败
执行 `docker pull` 拉取 ingress-nginx 镜像时，因网络问题无法连接镜像仓库，报错如下：
```bash
[root@ubuntu2204 ~]# docker pull registry.k8s.io/ingress-nginx/controller:v1.7.1
Error response from daemon: Head "https://us-west2-docker.pkg.dev/v2/k8s-artifacts-prod/images/ingress-nginx/controller/manifests/v1.7.1": dial tcp 142.251.170.82:443: connect: connection refused
```

#### 二、解决步骤：配置 Docker 系统级代理
##### 1. 前置准备（网络代理环境）
先安装并配置科学上网软件，确保代理服务正常运行，且开启**局域网连接**（允许本机通过代理 IP:端口 访问外网）。

##### 2. 创建 Docker 服务代理配置目录
```bash
[root@ubuntu2204 ~]# mkdir -p /etc/systemd/system/docker.service.d
```

##### 3. 编写代理配置文件（http-proxy.conf）
```bash
[root@ubuntu2204 ~]# cat >> /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://${PROXY_SERVER_IP}:${PROXY_PORT}/"
Environment="HTTPS_PROXY=http://${PROXY_SERVER_IP}:${PROXY_PORT}/"
Environment="NO_PROXY=127.0.0.0/8,172.17.0.0/16,10.0.0.0/24,10.244.0.0/16,192.168.0.0/16,wang.org,cluster.local"
EOF
```
**配置项说明**：
- `HTTP_PROXY/HTTPS_PROXY`：替换 `${PROXY_SERVER_IP}` 和 `${PROXY_PORT}` 为实际的代理服务器 IP 和端口；
- `NO_PROXY`：无需走代理的地址段/域名，包含：
  - 本地回环（127.0.0.0/8）、Docker 网桥（172.17.0.0/16）；
  - K8s 集群网段（10.0.0.0/24、10.244.0.0/16）、局域网（192.168.0.0/16）；
  - 自定义域名（wang.org）、K8s 集群本地域名（cluster.local）。

##### 4. 重新加载配置并重启 Docker 服务
```bash
[root@ubuntu2204 ~]# systemctl daemon-reload && systemctl restart docker.service
```

#### 三、验证结果：重新拉取镜像成功
```bash
[root@ubuntu2204 ~]# docker pull registry.k8s.io/ingress-nginx/controller:v1.7.1
# 执行后镜像正常拉取，无连接拒绝报错
```

#### 关键补充说明
1. **配置生效原理**：通过修改 Docker 服务的 systemd 配置文件，为 dockerd 进程注入代理环境变量，而非仅给当前终端配置代理（终端代理无法作用于 Docker 守护进程）；
2. **NO_PROXY 必配项**：必须包含集群/局域网网段，否则 Docker 访问本地容器、K8s 集群内部镜像仓库时会走代理，导致通信失败；
3. **变量替换**：实际使用时需将 `${PROXY_SERVER_IP}` 和 `${PROXY_PORT}` 替换为具体值（如 `192.168.1.100:7890`），不能直接使用变量符号。

# 三、docker 镜像管理 
## 3.1 镜像结构和原理
```mermaid
graph TD
    A[Docker 镜像 Image] --> B[Layer 3: 应用程序代码<br><i>（只读）</i>]
    A --> C[Layer 2: 运行时依赖<br><i>（只读）</i>]
    A --> D[Layer 1: 基础操作系统<br><i>（只读）</i>]

    subgraph "联合文件系统 (UnionFS)"
        direction TB
        D --> C --> B
    end

    E[Docker 容器 Container] --> F[可写层 Container Layer<br><i>（读写）</i>]
    F -->|叠加在| B

    style A fill:#e6f7ff,stroke:#333
    style E fill:#ffe6e6,stroke:#333
    style F fill:#ffe0e0,stroke:#d9534f
    style B fill:#f0f8ff,stroke:#4a90e2
    style C fill:#f0f8ff,stroke:#4a90e2
    style D fill:#f0f8ff,stroke:#4a90e2
```

Docker镜像可以理解为创建容器的“模板”，它封装了容器运行所需的完整文件系统和所有依赖内容。正因为如此，镜像的核心价值在于能够让你方便、快速地创建并启动容器。

镜像的内部结构并非单一的文件系统，而是由多层文件系统叠加而成，这种技术被称为**Union FS（联合文件系统）**。你可以把它想象成“千层饼”“洋葱”或“俄罗斯套娃”——联合文件系统会把多个独立的目录层挂载在一起，最终形成一个统一的虚拟文件系统。这个虚拟文件系统的目录结构和普通Linux系统完全一致，镜像依靠这些文件层，再结合宿主机的Linux内核，就能为容器提供一个完整的Linux虚拟运行环境。
镜像中的每一层文件系统都被称为一个**layer（层）**。虽然联合文件系统本身支持为不同层级设置只读（readonly）、读写（readwrite）、写出（whiteout-able）三种权限，但Docker镜像里的每一层文件系统都被设定为**只读**状态。
构建镜像的过程，本质上是从一个最基础的操作系统层（比如Ubuntu、CentOS的基础镜像）开始，每执行一次构建操作并提交，就相当于在现有层级上新增一层文件系统，记录本次的修改内容。这些层级会一层层向上叠加，上层的修改会“覆盖”底层对应位置的内容（仅视觉上的覆盖，底层内容并未被删除）。

当你使用这个镜像创建并运行容器时，你感知到的只是一个完整的、无差别的文件系统整体，完全不需要知道内部包含多少层——这也是Docker设计的初衷，对使用者屏蔽底层复杂的分层结构。

### 1. bootfs（Boot File System，引导文件系统）
bootfs的核心内容包含两部分：**bootloader（引导加载程序）** 和 **kernel（内核）**。
- bootloader的作用是引导并加载内核，当Linux系统启动时，会首先加载bootfs文件系统；
- 待bootloader完成引导、kernel被成功加载到内存并接管整个系统的控制权后，bootfs就完成了它的使命，会被系统卸载（umount），不再占用运行资源。

### 2. rootfs（Root File System，根文件系统）
rootfs是Linux系统的核心文件系统层，包含了标准Linux系统中所有的基础目录和文件，比如 `/dev`（设备文件）、`/proc`（进程信息）、`/bin`（可执行命令）、`/etc`（配置文件）等。
不同Linux发行版（如Ubuntu、CentOS）的核心差异，本质上就体现在rootfs这一层——它们的目录结构框架一致，但内置的命令、配置、软件包等内容各不相同。

### 镜像体积小的核心原因
Docker镜像的体积通常远小于完整的Linux系统镜像（比如官方Ubuntu镜像仅60多MB，CentOS基础镜像约200MB，轻量级的busybox镜像仅1.22MB、alpine镜像仅5MB左右），核心原因在于：
Docker镜像并不会包含完整的Linux内核（bootfs部分），而是直接复用宿主机的Linux内核；镜像中只需要提供rootfs层即可，也就是仅包含运行容器所需的最基础命令、配置文件、程序库等核心文件，无需冗余的引导和内核相关内容，因此体积能做到极致精简。

查看镜像的分层结构
```bash
╭─[root@lnxguru] ~
╰─➤ docker image history openeuler/openeuler:22.03-lts-sp4 
IMAGE          CREATED       CREATED BY                                      SIZE      COMMENT
b8bd2a5778dc   2 weeks ago   CMD ["bash"]                                    0B        buildkit.dockerfile.v0
<missing>      2 weeks ago   RUN |1 TARGETARCH=amd64 /bin/sh -c ln -sf /u…   24.6kB    buildkit.dockerfile.v0
<missing>      2 weeks ago   ADD openEuler-docker-rootfs.amd64.tar.xz / #…   188MB     buildkit.dockerfile.v0
<missing>      2 weeks ago   ARG TARGETARCH=amd64                            0B        buildkit.dockerfile.v0
 
```
## 3.2 搜索镜像
### 3.2.1 搜索镜像
#### 3.2.1.1 官方网站进行镜像的搜索
http://hub.docker.com

http://dockerhub.com

https://hub-stage.docker.com/
在官方的 docker 仓库中搜索指定名称的 docker 镜像，也会有很多三方镜像。
第三方仓库
```go
https://quay.io/ #红帽公司维护

https://registry.k8s.io  #kubernetes 仓库

http://cr.console.aliyun.com #阿里云仓库
```

#### 3.2.1.2 执行 docker search 命令进行搜索
```bash
╭─[root@lnxguru] ~
╰─➤ docker search --help 
Usage:  docker search [OPTIONS] TERM

Search Docker Hub for images

Options:
  -f, --filter filter   Filter output based on conditions provided
      --format string   Pretty-print search using a Go template
      --limit int       Max number of search results
      --no-trunc        Don't truncate output'

说明:  
OFFICIAL: 官方
AUTOMATED: 使用第三方 docker 服务来帮助编译镜像，可以在互联网上面直接拉取到镜像，减少了繁琐的编译过程


# 搜索点赞100个以上的镜像
docker search --filter=starts=100 centos
```
### 3.2.2 Alpine 介绍
![](assets/docker/file-20260214101856981.png)

你希望我把这段关于Alpine Linux系统及对应的Docker镜像的介绍重新梳理优化，让表述更流畅、逻辑更清晰，同时突出核心优势，对吧？我会在保留关键信息的前提下，用更专业且易懂的语言重构内容：

#### 3.2.2.1 Alpine Linux 操作系统：轻量且安全的Linux发行版
Alpine Linux是一款以**安全**为核心设计理念的轻量级Linux发行版，与传统Linux发行版（如Ubuntu、CentOS）有显著区别：
- 它采用`musl libc`（轻量级C标准库）和`busybox`（精简版核心工具集）作为基础组件，大幅降低了系统体积和运行时的资源消耗；同时其功能完整性远优于单纯的busybox，因此在开源社区的应用场景越来越广泛。
- 除了极致轻量化，Alpine还内置了专属的包管理工具`apk`，你既可以通过官方网站（https://pkgs.alpinelinux.org/packages）查询软件包信息，也能直接通过`apk`命令快速查询、安装各类软件，使用体验便捷。
- 该发行版由非商业组织维护，适配多种使用场景，尤其针对资深Linux用户做了深度优化，核心关注**安全性、性能**和**资源利用率**，是一款可直接用于生产环境的优秀基础系统/运行环境。

#### 3.2.2.2 Alpine Docker 镜像：官方推荐的轻量化基础镜像
Alpine的Docker镜像完全继承了其发行版的核心优势，成为Docker生态中极具竞争力的基础镜像：
- **体积极致精简**：镜像大小仅约5 MB（对比Ubuntu系列镜像近200 MB），是目前主流基础镜像中体积最小的之一；
- **包管理友好**：沿用Alpine原生的`apk`包管理机制，安装软件高效且无冗余；
- **官方背书**：Alpine Docker镜像源自`docker-alpine`开源项目，且Docker官方已明确推荐使用Alpine替代传统的Ubuntu作为基础镜像环境。

使用Alpine作为Docker基础镜像，能带来多方面的实际收益：镜像下载速度大幅提升、镜像本身的安全性更高、不同主机间的镜像迁移/切换更便捷，同时还能显著减少磁盘空间占用。

## 3.3 下载镜像
从 docker 仓库将镜像下载到本地，命令格式如下
```bash
╭─[root@lnxguru] ~
╰─➤ docker pull --help
Usage:  docker pull [OPTIONS] NAME[:TAG|@DIGEST]

Download an image from a registry

Aliases:
  docker image pull, docker pull

Options:
  -a, --all-tags          Download all tagged images in the repository
      --platform string   Set platform if server is multi-platform capable
  -q, --quiet             Suppress verbose output

NAME: 是镜像名,格式:仓库服务器:端口/项目名称/镜像名称，仓库服务器:端口/项目名称/可以省略，默认docker.io/library/
TAG: 即版本号,如果不指定:TAG,则下载最新版镜像,即 latest




[root@ubuntu1804 ~]#docker pull hello-world
Using default tag: latest   #默认下载最新版本
latest: Pulling from library/hello-world
1b930d010525: Pull complete  #分层下载
Digest: sha256:9572f7cdcee8591948c2963463447a53466950b3fc15a247fcad1917ca215a2f
#摘要
Status: Downloaded newer image for hello-world:late


# 镜像下载保存的路径
# 在 docker19.03 及更早的存储路径如下
/var/lib/docker/overlay2/镜像 ID
# 在新版的 docker 中镜像的存储路径如下
# 通过 docker info 查询
╭─[root@lnxguru] ~
╰─➤ docker info | grep -E "Docker Root Dir|Storage Driver"
 Storage Driver: overlayfs
 Docker Root Dir: /var/lib/docker
ls -l  /var/lib/docker/containerd/daemon/
```
>[!info]
>注意: 镜像下载完成后，会自动解压缩，比官网显示的可能会大很多，如: centos8.1.1911 下 载时只有 70MB，下载完后显示 237MB

下载公有云镜像
```bash
[root@ubuntu2204 ~]#docker pull registry.cn-beijing.aliyuncs.com/wangxiaochun/alpine:3.20.
```
## 3.4 镜像加速配置和优化
docker 镜像官方的下载站点是: https://hub.docker.com/
从国内下载官方的镜像站点有时候会很慢，因此可以更改 docker 配置文件添加一个加速器，可以通过加速器达到加速下载镜像的目的
国内有许多公司都提供了docker 加速镜像，比如: 阿里云，腾讯云，网易云，以下以阿里云为例
### 3.4.1 阿里云获取加速地址
浏览器打开http://cr.console.aliyun.com，注册或登录阿里云账号，点击左侧的镜像加速器，将会得到一个专属的加速地址，而且下面有使用配置说明
### 3.4.2 Docker 客户端安装与镜像加速器配置
#### 1. 安装/升级 Docker 客户端
推荐安装 **1.10.0 及以上版本** 的 Docker CE（社区版），官方安装文档可参考：[Docker CE 官方文档](https://docs.docker.com/engine/install/)。
不同系统（CentOS/Ubuntu/Debian）的安装命令略有差异，以下是通用指引（以 CentOS 为例）：
```bash
# 卸载旧版本（如有）
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# 设置仓库
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装最新版 Docker CE
yum install -y docker-ce docker-ce-cli containerd.io

# 启动并设置开机自启
systemctl start docker
systemctl enable docker

# 验证安装（查看版本）
docker --version
```

#### 2. 配置 Docker 镜像加速器（核心步骤）
通过修改 `daemon.json` 配置文件，添加镜像加速器、自定义数据目录等配置，**注意修正原配置中的语法错误（中文逗号）**：
```bash
# 1. 创建 docker 配置目录（若不存在）
mkdir -p /etc/docker

# 2. 写入 daemon.json 配置文件（修正中文逗号，规范注释）
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",    # 中科大镜像
    "http://hub-mirror.c.163.com/",         # 网易云镜像
    "https://si7y70hh.mirror.aliyuncs.com"  # 阿里云镜像（需替换为自己的阿里云加速器地址）
  ],
  "live-restore": true,                     # Docker 服务重启时，不重启运行中的容器
  "data-root": "/data/docker",              # 指定 Docker 数据存储目录（新版用 data-root，旧版用 graph）
  "insecure-registries": ["harbor.wang.org"] # 信任的私有镜像仓库（非HTTPS）
}
EOF
```

#### 3. 常用公共镜像加速器列表（备用）
| 服务商 | 加速器地址 |
|--------|------------|
| 中科大 | https://docker.mirrors.ustc.edu.cn |
| 网易云 | http://hub-mirror.c.163.com/ |
| 腾讯云 | https://mirror.ccs.tencentyun.com |
| 七牛云 | https://reg-mirror.qiniu.com |
| 阿里云 | https://<你的ID>.mirror.aliyuncs.com（需登录阿里云获取） |

#### 4. 重启 Docker 服务使配置生效
```bash
# 重新加载 daemon 配置
systemctl daemon-reload

# 重启 Docker 服务
systemctl restart docker

# 验证配置是否生效（查看 registry-mirrors 字段）
docker info | grep -A 5 "Registry Mirrors"
```
## 3.4 查看本地镜像
### 3.4.1 查看本地镜像
docker images 可以查看下载至本地的镜像
docker images 和 docker image ls 是完全等价的命令，作用都是列出本地主机上的 Docker 镜像。docker image ls 是 Docker 官方推荐的 “新式” 写法（按 docker 资源类型 操作 的规范），docker images 是传统简写，两者功能、参数完全一致。
https://docs.docker.com/engine/reference/commandline/images/

```bash
# 两种写法均可
docker images [OPTIONS] [REPOSITORY[:TAG]]
docker image ls [OPTIONS] [REPOSITORY[:TAG]]

[OPTIONS]：可选参数，用于过滤、格式化输出等；
[REPOSITORY[:TAG]]：可选，指定仓库名 + 标签，用于精准查询某一个 / 一类镜像（比如 nginx:1.24 只查 nginx 1.24 版本，nginx 查所有 nginx 镜像）。

# 基础使用，无参数
docker images
# 输出格式（默认列：仓库名、标签、ID、创建时间、大小）
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
nginx        1.24      08b152afcfae   2 months ago   187MB
alpine       latest    7e01a0d0a8fa   3 months ago   7.64MB

# 精准查询某镜像
docker images nginx:1.24
# 仅输出nginx 1.24版本的镜像信息
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
nginx        1.24      08b152afcfae   2 months ago   187MB

# 组合参数
# 显示所有镜像的完整ID，且仅输出ID
docker images -a --no-trunc -q
# 输出示例：
sha256:08b152afcfae0f1fd2716dd5995888960784175fe4bd699f4c891fbf02d9f8f8
sha256:7e01a0d0a8fa06e32bf50b9b807220f9b4d679198f1c03543c2d3f852a87878a
```
执行结果的显示信息说明
```bash
REPOSITORY      #镜像所属的仓库名称
TAG         #镜像版本号（标识符），默认为 latest
IMAGE ID       #镜像唯一 ID 标识,如果 ID 相同,说明是同一个镜像有多个名称
CREATED       #镜像在仓库中被创建时间
VIRTUAL SIZE    #镜像的大小
```

`docker images --format` 的本质是**用 Go 模板语法**自定义 `docker images` 的输出内容，你可以通过指定 “占位符” 筛选、重组镜像的属性，只展示你关心的信息，避免默认输出的冗余内容。

### 3.4.2 --format 格式化输出
格式字符串的基本语法：
```bash
docker images --format "{{.属性名}}"
# 多个属性用空格/符号分隔：
docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}"
```
- 占位符以 `{{.属性名}}` 形式书写，属性名首字母**必须大写**（如 `.Repository` 而非 `.repository`）；
- 可在占位符之间添加任意字符（如冒号、空格、换行、括号），用于格式化输出样式。
以下是最常用的占位符，对应镜像的核心属性，可按需组合使用：

|占位符|含义|示例值|
|---|---|---|
|`.ID`|镜像短 ID（默认输出的精简 ID）|08b152afcfae|
|`.Repository`|镜像仓库名（如 nginx、alpine）|nginx|
|`.Tag`|镜像标签（如 latest、1.24）|1.24|
|`.Digest`|镜像摘要（数字指纹，需配合 --digests）|sha256:xxxxxxx|
|`.CreatedSince`|镜像创建时间（相对时间，如 2 个月前）|2 months ago|
|`.CreatedAt`|镜像创建时间（绝对时间，如具体日期）|2025-10-01 10:20:30|
|`.Size`|镜像体积（易读格式，如 187MB）|187MB|
|`.VirtualSize`|镜像虚拟大小（分层存储的总大小）|187MB|
#### 示例 1：极简输出（仓库：标签）
只显示镜像的 “仓库名 + 标签”，适合快速查看本地镜像列表：
```bash
╭─[root@lnxguru] ~
╰─➤ docker images --format "{{.Repository}}:{{.Tag}}"
openeuler/openeuler:22.03
openeuler/openeuler:22.03-lts-sp4

```
#### 示例 2：带体积的详细列表（自定义表头）
```bash
╭─[root@lnxguru] ~
╰─➤ docker images --format "| {{.Repository}} | {{.Tag}} | {{.ID}} | {{.Size}} |"
| openeuler/openeuler | 22.03 | b8bd2a5778dc | 252MB |
| openeuler/openeuler | 22.03-lts-sp4 | b8bd2a5778dc | 252MB |
```
#### 示例 3：按行分隔的结构化输出
```bash
╭─[root@lnxguru] ~
╰─➤ docker images --format "=== 镜像信息 ===
仓库: {{.Repository}}
标签: {{.Tag}}
ID: {{.ID}}
大小: {{.Size}}
创建时间: {{.CreatedSince}}
"
=== 镜像信息 ===
仓库: openeuler/openeuler
标签: 22.03
ID: b8bd2a5778dc
大小: 252MB
创建时间: 2 weeks ago

=== 镜像信息 ===
仓库: openeuler/openeuler
标签: 22.03-lts-sp4
ID: b8bd2a5778dc
大小: 252MB
创建时间: 2 weeks ago

```
#### 示例 4：结合过滤 + 格式化
先过滤出 `nginx` 相关镜像，再自定义输出格式：
```bash
docker images --filter "reference=nginx*" --format "{{.Repository}}:{{.Tag}} (ID: {{.ID}}) - {{.Size}}"
```
#### 示例 5：显示绝对创建时间（.CreatedAt）
```bash
╭─[root@lnxguru] ~
╰─➤ docker images --format "{{.Repository}}:{{.Tag}} 创建于: {{.CreatedAt}}"
openeuler/openeuler:22.03 创建于: 2026-01-31 07:57:05 +0800 CST
openeuler/openeuler:22.03-lts-sp4 创建于: 2026-01-31 07:57:05 +0800 CST

```
- `--format` 通过 Go 模板的 `{{.属性名}}` 占位符自定义输出，属性名首字母必须大写；
- 常用占位符：`.Repository`（仓库）、`.Tag`（标签）、`.ID`（镜像 ID）、`.Size`（体积）是日常最常用的；
- 可结合 `-f/--filter` 过滤镜像，再用 `--format` 格式化输出，精准获取所需信息，避免冗余
### 3.4.3 repository 镜像仓库
- 由某特定的 docker 镜像的所有迭代版本组成的镜像仓库
- 一个 Registry 中可以存在多个 Repository
- Repository 可分为“顶层仓库”和“用户仓库”
- Repository 用户仓库名称一般格式为“用户名/仓库名”
- 每个 Repository 仓库可以包含多个 Tag (标签),每个标签对应一个镜像

## 3.5 镜像导出
利用 docker save 命令可以将从本地镜像导出为一个打包 tar 文件，然后复制到其他服务器进行导入使用
注意：镜像导出支持多个镜像导出
```bash
docker save [OPTIONS] IMAGE [IMAGE...]

选项:  
-o, --output string   Write to a file, instead of STDOUT

# 说明:
Docker save 使用 IMAGE ID 导出，在导入后的镜像没有 REPOSITORY 和 TAG,显示为 <none>

```
常见用法
```bash
# 导出为 tar 格式
docker save -o /path/file.tar IMAGE1 IMAGE2 ...
docker save IMAGE1 IMAGE2 ... > /path/file.tar

# 导出为压缩格式
docker save IMAGE1 IMAGE2 ... | gzip > /path/file.tar.gz
```

导出指定镜像
```bash
docker save mysql:5.7.30 alpine:3.11.3 -o /data/myimages.tar

# 导出镜像并压缩
docker save rockylinux:9.1-minimal | gzip - > rockylinux-9.1-minimal.tar.gz

# 导出所有镜像至不同的文件中
docker images | awk 'NR!=1{print $1,$2}' | while read repo tag;do docker save   $repo:$tag -o /opt/$repo-$tag.tar ;done

# 导出所有镜像到一个打包文件
[root@ubuntu1804 ~]# docker save `docker images -qa` -o all.tar

```
## 3.6 镜像导入
利用 docker load 命令可以将镜像导出的打包或压缩文件再导入

注意：镜像导入只能支持单个镜像导入，不支持多个镜像导入
```bash
docker load [OPTIONS]

# 选项
-i, --input string   Read from tar archive file, instead of STDIN
-q, --quiet         Suppress the load output

docker load -i /path/file.tar
docker load < /path/file.tar.gz
```
## 3.7 删除镜像
docker rmi 命令可以删除本地镜像
旧版本强制删除正在使用的镜像，也会删除对应的容器，新版本不允许删除正在运行的容器对应的镜像
```bash
docker rmi [OPTIONS] IMAGE [IMAGE...]

docker image rm [OPTIONS] IMAGE [IMAGE...]

# 选项:

-f, --force     Force removal of the image

--no-prune   Do not delete untagged parents
```
## 3.8 清理 dangling 状态的镜像
你想知道“清理dangling状态的镜像”具体是什么意思，以及该怎么操作，对吧？我会先解释核心概念，再说明为什么要清理，最后给出具体的操作方法，让你彻底理解这个知识点。

### 3.8.1 什么是Dangling状态的镜像？
Dangling（直译“悬空”）状态的镜像，也常被称为**虚悬镜像**，本质是：
- 这类镜像的 `REPOSITORY`（仓库名）和 `TAG`（标签）均为 `<none>`；
- 产生原因：当你基于同一个仓库名+标签重新构建/拉取镜像时，旧版本的镜像会失去仓库和标签的关联，变成“无主”的悬空状态（比如你先拉取 `nginx:latest`，之后官方更新了 `nginx:latest`，你重新拉取后，旧的 `nginx:latest` 就会变成 `<none>:<none>`）；
- 识别特征：执行 `docker images` 时，能看到一行/多行 `REPOSITORY` 和 `TAG` 列都是 `<none>` 的镜像。

简单说：**Dangling镜像就是没有名字、没有标签的“无主”镜像，是镜像更新/重建后留下的废弃版本，既无法通过仓库+标签调用，也没有实际用途，只会占用磁盘空间。**

### 3.8.2 为什么要清理Dangling镜像？
1. **释放磁盘空间**：每一个Dangling镜像都占用磁盘（哪怕是Alpine这类轻量镜像，累积多了也会占用大量空间）；
2. **简化镜像列表**：清理后 `docker images` 输出更整洁，避免大量 `<none>` 镜像干扰查看有效镜像；
3. **避免误操作**：减少因镜像ID混淆导致的错误（比如误删有用镜像）。

### 3.8.3 如何清理Dangling镜像？
#### 方法1：专用命令（推荐，安全）
Docker提供了专门清理Dangling镜像的命令，**只会删除`<none>:<none>`的镜像，不会影响有标签的有效镜像**：
```bash
docker image prune
```
执行后会提示确认：
```
WARNING! This will remove all dangling images.
Are you sure you want to continue? [y/N]
```
输入 `y` 回车即可完成清理。

#### 方法2：过滤+删除（手动方式，适合理解原理）
先筛选出Dangling镜像的ID，再删除（效果和方法1一致，但步骤更直观）：
```bash
# 1. 筛选出所有Dangling镜像的ID（-q仅输出ID，-f过滤条件）
docker images -q -f "dangling=true"

# 2. 批量删除这些镜像（组合命令，直接执行）
docker rmi $(docker images -q -f "dangling=true")
```
如果没有Dangling镜像，会输出：`Error: No such image: `（无需担心，是正常提示）。

#### 方法3：清理所有无用资源（进阶）
如果想一次性清理Dangling镜像、停止的容器、无用的网络/卷等所有无用资源，可执行：
```bash
# 加 -a 会删除所有未被容器使用的镜像（包括有标签但没被使用的），谨慎使用！
docker system prune
```
⚠️ 注意：`docker system prune -a` 会删除所有“未被任何容器（包括停止的容器）引用”的镜像，哪怕这些镜像有标签，因此**生产环境慎用 `-a` 参数**。

### 总结
1. **Dangling镜像**：就是`<none>:<none>`的无主镜像，由镜像更新/重建产生，无实际用途且占磁盘；
2. **核心清理命令**：`docker image prune`（仅删Dangling镜像，安全）；
3. **注意事项**：`docker system prune -a` 会删除更多无用镜像，需确认后再执行，避免误删有用镜像。
## 3.9 镜像打标签
docker tag 可以给镜像打标签，类似于起别名,但通常要遵守一定的命名规范,才可以上传到指定的仓库
```bash
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]

# TARGET_IMAGE[:TAG] 格式一般形式

仓库主机 FQDN 或 IP[:端口]/项目名(或用户名)/image名字:版本
```
tag 默认为 lastest
```bash
[root@ubuntu1804 ~]#docker images

REPOSITORY         TAG                 IMAGE ID           CREATED            SIZE
alpine             latest             e7d92cdc71fe        11 days ago        5.59MB
centos             centos7.7.1908     08d05d1d5859        2 months ago      204MB

[root@ubuntu1804 ~]#docker tag alpine alpine:3.11
[root@ubuntu1804 ~]#docker images

REPOSITORY         TAG                 IMAGE ID           CREATED            SIZE
alpine              3.11               e7d92cdc71fe        11 days ago        5.59MB
alpine             latest             e7d92cdc71fe        11 days ago        5.59MB
centos             centos7.7.1908     08d05d1d5859        2 months ago      204MB
```
# 四、容器操作基础命令
容器相关命令
```bash
╭─[root@lnxguru] ~
╰─➤ docker container
Usage:  docker container COMMAND

Manage containers

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  create      Create a new container
  diff        Inspect changes to files or directories on a container's filesystem
  exec        Execute a command in a running container
  export      Export a container's filesystem as a tar archive
  inspect     Display detailed information on one or more containers
  kill        Kill one or more running containers
  logs        Fetch the logs of a container
  ls          List containers
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  prune       Remove all stopped containers
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  run         Create and run a new container from an image
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  wait        Block until one or more containers stop, then print their exit codes

Run 'docker container COMMAND --help' for more information on a command.

```
## 4.1 启动容器
docker run 可以启动容器，进入到容器，并随机生成容器 ID 和名称
### 4.1.1 启动第一个容器
范例: 运行 docker 的 hello world
```bash
╭─[root@lnxguru] ~
╰─➤ docker run hello-world 

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

# 查看下载的镜像
╭─[root@lnxguru] ~
╰─➤ docker image ls hello-world:latest 
                                                                                                                                                        i Info →   U  In Use
IMAGE                ID             DISK USAGE   CONTENT SIZE   EXTRA
hello-world:latest   40dac9b7451f       29.1kB         12.7kB    U   
╭─[root@lnxguru] ~
╰─➤ docker ps -a
CONTAINER ID   IMAGE                       COMMAND                CREATED         STATUS                     PORTS     NAMES
9b237d87efb9   hello-world                 "/hello"               2 minutes ago   Exited (0) 2 minutes ago             flamboyant_matsumoto

```
### 4.1.2 启动容器的流程
![](assets/docker/file-20260214161446130.png)

### 4.1.3 Docker run 命令核心整理
`docker run [OPTIONS] IMAGE [COMMAND] [ARG...]`  
**核心作用**：基于指定镜像创建并启动一个新容器，是 Docker 最常用的命令之一。  
**别名**：`docker container run`（官方推荐的规范写法）

---

#### 4.1.3.1 基础运行控制（最常用）
| 选项 | 完整写法 | 作用说明 | 实用示例 |
|------|----------|----------|----------|
| `-d` | `--detach` | 后台运行容器（守护进程模式），仅输出容器ID | `docker run -d nginx` |
| `-it` | `-i + --tty` | 交互式运行（-i 保持STDIN打开，-t 分配伪终端） | `docker run -it ubuntu /bin/bash` |
| `--name` | `--name string` | 给容器指定自定义名称（默认随机生成） | `docker run --name my-nginx -d nginx` |
| `--rm` | `--rm` | 容器退出后**自动删除**（避免残留无用容器） | `docker run --rm -it alpine` |
| `--restart` | `--restart string` | 容器退出后的重启策略 | `docker run --restart always nginx`（始终重启）<br>`docker run --restart on-failure:3 nginx`（失败重启3次） |
| `-u` | `--user string` | 指定容器运行的用户（UID/GID 或用户名） | `docker run -u root nginx`（root用户）<br>`docker run -u 1000:1000 nginx`（指定UID/GID） |
| `-w` | `--workdir string` | 指定容器内的工作目录（默认/） | `docker run -w /app -it ubuntu` |

---

#### 4.1.3.2 网络配置
| 选项 | 完整写法 | 作用说明 | 实用示例 |
|------|----------|----------|----------|
| `-p` | `--publish list` | 端口映射（主机端口:容器端口） | `docker run -p 8080:80 nginx`（主机8080→容器80） |
| `-P` | `--publish-all` | 随机映射容器所有暴露的端口到主机 | `docker run -P nginx` |
| `--network` | `--network string` | 指定容器连接的网络（默认bridge） | `docker run --network host nginx`（使用主机网络） |
| `--add-host` | `--add-host list` | 添加自定义hosts映射（主机名:IP） | `docker run --add-host mysql:192.168.1.100 nginx` |
| `--dns` | `--dns list` | 设置容器DNS服务器 | `docker run --dns 8.8.8.8 nginx` |
| `-h` | `--hostname string` | 设置容器主机名 | `docker run -h my-container nginx` |

---

#### 4.1.3.3 数据挂载（持久化）
| 选项 | 完整写法 | 作用说明 | 实用示例 |
|------|----------|----------|----------|
| `-v` | `--volume list` | 绑定挂载（主机目录:容器目录） | `docker run -v /host/data:/container/data nginx` |
| `--mount` | `--mount mount` | 更灵活的挂载方式（推荐） | `docker run --mount type=bind,source=/host/data,target=/container/data nginx` |
| `--volumes-from` | `--volumes-from list` | 从其他容器挂载卷 | `docker run --volumes-from my-db nginx` |
| `--tmpfs` | `--tmpfs list` | 挂载临时文件系统（容器内，退出即删） | `docker run --tmpfs /tmp nginx` |

---

#### 4.1.3.4 环境配置
| 选项 | 完整写法 | 作用说明 | 实用示例 |
|------|----------|----------|----------|
| `-e` | `--env list` | 设置容器环境变量 | `docker run -e MYSQL_ROOT_PASSWORD=123456 mysql` |
| `--env-file` | `--env-file list` | 从文件读取环境变量 | `docker run --env-file .env nginx` |
| `--entrypoint` | `--entrypoint string` | 覆盖镜像默认的ENTRYPOINT | `docker run --entrypoint /bin/bash nginx` |

---

#### 4.1.3.5 资源限制（性能管控）
| 选项 | 完整写法 | 作用说明 | 实用示例 |
|------|----------|----------|----------|
| `-m` | `--memory bytes` | 限制容器内存使用（如100m、2g） | `docker run -m 1g nginx` |
| `--cpus` | `--cpus decimal` | 限制容器使用的CPU核心数 | `docker run --cpus 2 nginx`（最多用2核） |
| `--cpuset-cpus` | `--cpuset-cpus string` | 指定容器使用的CPU核心（0-3,0,1） | `docker run --cpuset-cpus 0,1 nginx`（仅用0、1核） |
| `--cpu-shares` | `--cpu-shares int` | CPU权重（相对值，默认1024） | `docker run --cpu-shares 2048 nginx` |

---

#### 4.1.3.6 权限与安全
| 选项 | 完整写法 | 作用说明 | 实用示例 |
|------|----------|----------|----------|
| `--privileged` | `--privileged` | 赋予容器扩展权限（接近主机root） | `docker run --privileged -d nginx` |
| `--cap-add` | `--cap-add list` | 添加Linux内核能力 | `docker run --cap-add NET_ADMIN nginx` |
| `--cap-drop` | `--cap-drop list` | 移除Linux内核能力 | `docker run --cap-drop ALL nginx` |
| `--read-only` | `--read-only` | 将容器根文件系统设为只读 | `docker run --read-only nginx` |
| `--oom-kill-disable` | `--oom-kill-disable` | 禁用OOM Killer（内存不足时不杀容器） | `docker run --oom-kill-disable nginx` |

---

#### 4.1.3.7 其他实用选项
| 选项 | 完整写法 | 作用说明 | 实用示例 |
|------|----------|----------|----------|
| `-a` | `--attach list` | 附加到容器的STDIN/STDOUT/STDERR | `docker run -a stdout -d nginx` |
| `--pull` | `--pull string` | 运行前拉取镜像策略（always/missing/never） | `docker run --pull always nginx`（强制拉取最新版） |
| `--health-cmd` | `--health-cmd string` | 设置容器健康检查命令 | `docker run --health-cmd "curl -f http://localhost || exit 1" nginx` |
| `--stop-timeout` | `--stop-timeout int` | 容器停止超时时间（秒） | `docker run --stop-timeout 30 nginx` |
| `--gpus` | `--gpus gpu-request` | 给容器分配GPU（需宿主机有GPU） | `docker run --gpus all nvidia/cuda` |
### 4.1.4 容器重启策略
--restart 可以指定四种不同的 policy
#### 4.1.4.1 docker run --restart 重启策略全解析
| 策略值 | 核心含义 | 触发重启的场景 | 适用场景 | 实用示例 |
|--------|----------|----------------|----------|----------|
| `no` | **默认值**，容器退出后不重启 | 任何情况都不重启 | 临时测试容器、一次性任务容器（如数据处理） | `docker run --restart no nginx` |
| `on-failure[:max-retries]` | 仅当容器**非0状态退出**时重启（可指定最大重启次数） | 1. 容器异常退出（退出码≠0）<br>2. 手动 `docker stop` 不触发<br>3. 主机重启后不恢复 | 业务容器（需容错，但正常停止不重启），如数据库、应用服务 | `docker run --restart on-failure:3 mysql`（失败最多重启3次） |
| `always` | 容器无论以何种状态退出，始终重启 | 1. 容器正常/异常退出<br>2. 手动 `docker stop` 后，**主机重启/ Docker 服务重启**会重新启动容器 | 核心服务（需一直运行），如Nginx、Redis等基础组件 | `docker run --restart always redis` |
| `unless-stopped` | 始终重启，除非**手动执行 `docker stop`** 或 Docker 服务停止 | 1. 容器正常/异常退出会重启<br>2. 手动 `docker stop` 后，即使主机/Docker重启也不会恢复<br>3. 仅手动 `docker start` 可恢复 | 生产环境核心服务（兼顾稳定性和可控性），避免手动停止后被自动重启 | `docker run --restart unless-stopped nginx` |

如果 docker stop 停止容器后重启宿主机，always 选项以外的其它选项的容器都不会随着宿主机启动而自动启动
注意: 容器启动后,如果容器内没有前台运行的进程,将自动退出停止从容器内退出,并停止容器
```bash
# 从容器内退出并停止容器
exit

# 从容器内退出，且容器不停止
ctrl + p + q
```
#### 4.1.4.2 补充关键说明
1. **最大重启次数**：仅 `on-failure` 支持后缀 `:max-retries`（如 `on-failure:5`），超出次数后停止重启；
2. **主机重启影响**：
   - `always`：主机/Docker重启后，所有该策略的容器会自动启动；
   - `unless-stopped`：仅未被手动 `stop` 的容器会恢复；
   - `on-failure/no`：主机重启后不会自动恢复；
3. **手动干预**：无论哪种策略，`docker stop` 可手动停止容器，`docker start` 可重新启动。

#### 4.1.4.3 总结
1. 临时容器用 `no`，业务容错用 `on-failure`；
2. 核心服务优先选 `unless-stopped`（比 `always` 更可控）；
3. `on-failure` 建议指定最大重启次数，避免无限重启占用资源。


你想深入理解 `docker run --privileged` 这个选项的作用、使用场景和风险，对吧？我会从核心含义、工作原理、适用场景、风险提示等维度，用通俗易懂的方式解析这个选项。

### 4.1.5 --privileged
#### 4.1.5.1 `--privileged` 核心含义
`--privileged` 是 Docker 赋予容器**最高级别的系统权限**的选项，开启后：
- 容器内的进程会获得宿主机的 `root` 权限（接近宿主机 root 用户的所有能力）；
- 容器可以访问宿主机的所有设备（如 `/dev` 目录下的磁盘、网卡、USB 设备等）；
- 容器可以修改内核参数、挂载宿主机文件系统、操作网络栈等原本被 Docker 隔离的系统资源。

简单说：**默认情况下 Docker 容器是“受限的沙箱”，加了 `--privileged` 后，这个沙箱几乎被拆除，容器能直接操作宿主机的核心资源**。

#### 4.1.5.2 工作原理（新手易懂版）
Docker 本质是通过 Linux 的 `cgroup`（资源限制）和 `namespace`（资源隔离）实现容器隔离，默认会：
1. 限制容器的内核能力（如不能修改主机网络、不能访问物理设备）；
2. 隔离容器的文件系统、网络、进程空间等。

而 `--privileged` 会：
- 给容器添加**所有 Linux 内核能力**（相当于 `--cap-add ALL`）；
- 解除设备访问限制（容器可读写 `/dev` 下的所有设备）；
- 允许容器挂载宿主机的任意文件系统（如 `proc`、`sysfs`）。

#### 4.1.5.3 适用场景（必须用的情况）
只有当容器需要操作宿主机核心资源时，才需要开启，常见场景：

| 场景                             | 示例命令                                                                               | 说明                        |
| ------------------------------ | ---------------------------------------------------------------------------------- | ------------------------- |
| 容器内操作宿主机磁盘（如格式化、分区）            | `docker run --privileged -v /dev:/dev centos fdisk -l`                             | 需访问 `/dev/sda` 等磁盘设备      |
| 容器内修改主机网络（如添加路由、修改 iptables）   | `docker run --privileged --net host ubuntu iptables -L`                            | 需操作主机网络栈                  |
| 容器内运行 Docker（Docker-in-Docker） | `docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock docker:dind` | 需创建嵌套容器，操作宿主机 Docker 守护进程 |
| 访问宿主机 USB 设备（如串口、摄像头）          | `docker run --privileged -v /dev/ttyUSB0:/dev/ttyUSB0 python`                      | 需读写 USB 串口设备              |
| 容器内挂载宿主机文件系统                   | `docker run --privileged -v /:/host ubuntu mount /host/sda1 /mnt`                  | 需挂载主机磁盘分区                 |

#### 4.1.5.4 风险提示（重点！）
`--privileged` 是**高风险选项**，生产环境需极度谨慎：
1. **安全风险**：如果容器被入侵，攻击者可通过容器直接控制宿主机（删除主机文件、修改内核参数、甚至格式化磁盘）；
2. **稳定性风险**：容器内误操作（如 `rm -rf /` 挂载了主机根目录）会直接破坏宿主机系统；
3. **违背容器隔离原则**：Docker 的核心价值是“隔离”，`--privileged` 几乎消除了隔离，失去容器的安全边界。

#### 4.1.5.5 替代方案（优先用，避免全特权）
除非必须，否则不要直接用 `--privileged`，可通过更精细的权限控制满足需求：
1. **仅添加需要的内核能力**（推荐）：
   ```bash
   # 仅添加网络管理能力，而非所有权限
   docker run --cap-add NET_ADMIN --net host nginx
   ```
   常用能力：`NET_ADMIN`（网络管理）、`SYS_ADMIN`（系统管理）、`DEVICE_MAPPER`（设备管理）。

2. **仅挂载需要的设备**：
   ```bash
   # 仅允许访问 /dev/sda1，而非所有设备
   docker run --device /dev/sda1:/dev/sda1 centos
   ```

3. **限制容器用户**：
   即使开启 `--privileged`，也尽量指定非 root 用户运行（减少风险）：
   ```bash
   docker run --privileged -u 1000:1000 ubuntu
   ```

#### 4.1.5.6 示例对比（默认 vs --privileged）
##### 4.1.5.6.1 默认情况（无特权）
```bash
# 容器内尝试查看主机磁盘，会提示权限不足
docker run centos fdisk -l /dev/sda
# 输出：fdisk: cannot open /dev/sda: Permission denied
```

##### 4.1.5.6.2 开启 --privileged
```bash
# 能正常查看主机磁盘信息
docker run --privileged centos fdisk -l /dev/sda
# 输出：Disk /dev/sda: 100 GiB, 107374182400 bytes, 209715200 sectors...
```

## 4.2 查看容器信息
### 4.2.1 查看当前存在的容器
`docker ps` 命令
https://docs.docker.com/engine/reference/commandline/ps/

#### 🐳 `docker ps` / `docker container ls` 常用选项

| 选项 | 全称 | 说明 |
|------|------|------|
| `-a` | `--all` | 显示 **所有容器**（默认仅显示运行中的） |
| `-q` | `--quiet` | 仅输出容器的 **短 ID**（适合脚本中使用） |
| `-s` | `--size` | 显示容器的 **磁盘占用大小**（包括可写层和日志） |
| `-f` | `--filter` | 根据条件过滤输出，例如：• `status=exited`• `ancestor=image_name`• `label=key=value` |
| `-l` | `--latest` | 显示 **最新创建的容器**（无论状态） |
| `-n` | `--last int` | 显示最近创建的 **前 N 个容器**（默认 `-1` 表示全部） |
| `--format` | — | 自定义输出格式（使用 Go 模板），例如：```--format "table {{.ID}}\t{{.Names}}\t{{.Status}}"``` |

---

#### 💡 常用组合示例

```python
# 仅列出所有容器的 ID（用于批量操作）
docker ps -aq

# 查看最近 3 个创建的容器（包括已停止的）
docker ps -n 3

# 过滤出已退出的容器
docker ps -a --filter "status=exited"

# 自定义表格输出：ID、名称、状态、镜像
#以下是一些常用的占位符：
{{.ID}}：容器的ID。
{{.Image}}：容器使用的映像名称。
{{.Command}}：容器的启动命令。
{{.CreatedAt}}：容器的创建时间。
{{.RunningFor}}：容器运行的时间。
{{.Ports}}：容器的端口映射信息。
{{.Status}}：容器的状态。
{{.Size}}：容器的大小。
{{.Names}}：容器的名称。
{{.Label}}：容器的标签。
╭─[root@lnxguru] /home/xuruizhao
╰─➤ docker ps --all  --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"
CONTAINER ID   NAMES                  STATUS                      IMAGE
8363480e70dd   asda                   Exited (0) 10 seconds ago   hello-world:latest
9b237d87efb9   flamboyant_matsumoto   Exited (0) 10 days ago      hello-world
c9661a9834da   op                     Exited (255) 10 days ago    openeuler/openeuler:22.03
```

---

> ✅ 提示：`docker ps` 是 `docker container ls` 的别名，两者功能完全相同。
