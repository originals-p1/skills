# diagnosis-protocol

## 1. 目标

性能诊断必须基于证据，不基于直觉。

诊断的输出不是“感觉这里慢”，而是结构化结论，能明确说明：

- 主指标问题是什么
- 主导瓶颈是什么
- 证据来自哪里
- 本轮不该改什么
- 本轮最小切入点是什么

## 2. 证据优先级

按以下顺序使用证据：

1. benchmark 数据
2. profiler / flamegraph / `perf` / tracing 的热点证据
3. alloc / lock / queue / syscall / cache miss 等辅助证据
4. 业务关键指标或线上近线指标（若项目存在）

解释规则：

- benchmark 负责证明“问题存在且可测”
- profiler / flamegraph / `perf` 负责证明“时间花在哪里”
- alloc / lock / queue / syscall / cache miss 负责解释“为什么会这样”
- 业务指标负责证明“这个热点值得优化”

## 3. 常见瓶颈类型

诊断时优先归类到以下类别之一：

- `algo`
- `alloc`
- `copy`
- `lock`
- `io`
- `batching`
- `cache-locality`
- `syscall`
- `queue`
- `config`

若无法归类，不要强行贴标签，写明证据不足。

## 4. 结构化诊断结论

每轮诊断必须输出以下结构：

### 4.1 主指标问题

- 当前问题指标
- 观测值
- 目标值或可接受范围

### 4.2 主导瓶颈

- 最主要瓶颈点
- 影响该瓶颈的直接因素
- 该瓶颈与目标指标的关系

### 4.3 证据来源

- benchmark 文件或命令
- profiler / flamegraph / tracing / `perf` 证据
- 辅助统计或日志

### 4.4 不建议改什么

必须写出本轮不建议修改的部分，例如：

- 与热点无关的大模块重构
- 无证据支持的数据结构替换
- 会改变外部语义的激进缓存
- 会扩大回滚面的并发模型重写

### 4.5 本轮最小切入点

必须明确：

- 改动范围
- 预期收益
- 主要风险
- 回滚方式

## 5. 决策纪律

- 没有 benchmark 支撑，不进入 patch
- 没有热点证据，不做“猜测性重写”
- 证据冲突时，先补证据，不扩大改动
- 若主瓶颈不在本轮 scope，更新 TODO，不要强行处理

## 6. 常见反模式

- 看到 alloc 高就直接上对象池
- 看到函数热点就直接内联或重写
- 只看 CPU 热点，不看锁等待或队列堆积
- 只看微基准，不看业务关键指标
- 把多个可疑点打成一个大补丁

## 7. 最终格式示例

```md
主指标问题：
- P99 延迟高于目标 18%，baseline 稳定复现

主导瓶颈：
- 请求解码路径存在重复拷贝与短生命周期分配
- 热点集中在 `DecodeFrame -> CopyPayload -> BuildBuffer`

证据来源：
- benchmark: `make bench BENCH=decode_frame`
- flamegraph: `artifacts/flamegraph-decode-frame.svg`
- alloc 统计: 每请求分配次数高于基线目标

不建议改什么：
- 不改协议层接口
- 不改线程模型
- 不引入跨请求缓存

本轮最小切入点：
- 合并 payload 拼接中的一次中间复制
- 保持外部接口不变
- 风险低，可通过单点回滚恢复
```
