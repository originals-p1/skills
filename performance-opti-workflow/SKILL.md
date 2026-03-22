---
name: performance-opti-workflow
description: Use when the user needs an evidence-driven performance optimization workflow with scoped scanning, TODO-based execution, baseline-before-change discipline, validation, rollback, and report artifacts.
---

# 性能优化工作流

## 1. 定位

这是一个面向 Codex/CLI agent 的性能工程工作流。

目标不是“尝试优化”，而是以证据驱动方式完成一次可审计的性能优化闭环：

1. 先控制扫描范围
2. 生成或更新 `todo.md`
3. 选择一个优化项
4. 明确目标与约束
5. 检查 benchmark / test 覆盖
6. 先跑 baseline
7. 基于证据诊断瓶颈
8. 实施最小高收益改动
9. 复测并对比
10. 失败立即回滚
11. 成功后做功能验证
12. 生成 perf report

没有 baseline，不得宣称成功。
没有前后对比，不得宣称成功。
没有证据，不得做大改。

## 2. 输出语言

- 默认使用中文沟通、记录和报告。
- 允许保留英文的内容仅限：代码标识符、命令、路径、环境变量、第三方工具原始输出、协议字段名。
- 若用户明确要求其他语言，遵循用户要求。

## 3. 路径与工具解析顺序

禁止写死目录、工具链和报告位置。所有路径和工具按以下优先级解析：

1. 用户显式指定
2. 仓库现有约定
3. 默认候选项

默认候选项只用于“找不到明确信号时的回退”，不得伪装成仓库标准。

### 3.1 约定发现

执行前优先检查：

- 根目录文档：`README*`、`CONTRIBUTING*`、`docs/**`
- 构建与任务文件：`Makefile`、`Taskfile*`、`package.json`、`pyproject.toml`、`Cargo.toml`、`go.mod`、`CMakeLists.txt`
- CI 配置：`.github/workflows/**`、其他 CI 文件
- 现有 benchmark / test / report 目录

### 3.2 默认候选路径

若仓库未给出明确约定，可按下列候选顺序查找：

- 测试目录：`tests/`、`test/`、`spec/`、`__tests__/`
- benchmark 目录：`benchmarks/`、`benchmark/`、`perf/`、`performance/`
- 报告目录：`reports/`、`perf-reports/`、`artifacts/`、`docs/reports/`

### 3.3 默认候选工具

工具选择顺序：

1. 用户指定工具
2. 仓库现有工具链
3. 与当前语言/构建系统匹配的默认工具

示例：

- C/C++：Google Benchmark、CTest、自定义压测目标
- Rust：Criterion、`cargo bench`、`cargo test`
- Go：`go test -bench`、`go test`
- Python：`pytest-benchmark`、`pytest`
- Java：JMH、JUnit
- Node.js：`benchmark.js`、`vitest` / `jest` / 项目现有测试命令

若仓库已有稳定基准工具，优先复用，不要平移到别的工具。

## 4. 执行模式

支持以下三种模式：

### 4.1 `manual-selection`

- 必须先生成或更新 `todo.md`
- 必须等待用户按 TODO ID 选择
- 未收到合法 ID 前，不得进入代码修改

### 4.2 `recommended-single-step`

- agent 输出推荐项与理由
- 等待用户确认后执行单个 TODO
- 未确认前，不得修改代码

### 4.3 `auto-pilot-low-risk`

- 仅允许执行同时满足以下条件的 TODO：
  - `risk` 为 low
  - `rollback` 清晰且可快速执行
  - `evidence` 充分
  - 预期收益明确
  - 改动范围局部且不改变外部语义
- 一次只执行一个 TODO
- 一旦出现回退、噪声内结果或功能风险，立即退出自动模式

### 4.4 默认模式

- 默认使用 `recommended-single-step`
- 若用户明确要求手选，切换到 `manual-selection`
- 若用户明确授权低风险自动推进，才可使用 `auto-pilot-low-risk`

## 5. TODO 规范

`todo.md` 是本工作流的控制面，必须存在。

若不存在则创建；若存在则更新，不要覆盖用户已有记录。

每个优化项至少包含以下字段：

- `id`
- `title`
- `priority`
- `category`
- `expected_gain`
- `target_metric`
- `scope`
- `evidence`
- `validation`
- `risk`
- `rollback`
- `status`
- `notes`

### 5.1 `category` 允许值

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

### 5.2 `status` 允许值

- `proposed`
- `selected`
- `baseline-ready`
- `in-progress`
- `success`
- `not-proven`
- `regressed`
- `failed`
- `blocked`
- `deferred`

详细模板见 [todo-template](references/todo-template.md)。

## 6. 状态机

本工作流必须按以下状态流转执行：

`scan -> plan -> baseline -> diagnose -> patch -> validate -> rollback -> report`

允许的常见路径：

- 成功路径：`scan -> plan -> baseline -> diagnose -> patch -> validate -> report`
- 失败路径：`scan -> plan -> baseline -> diagnose -> patch -> validate -> rollback -> report`
- 提前终止路径：`scan -> plan` 后因缺少选择、缺少基准、缺少权限或证据不足而停止

### 6.1 `scan`

输入：

- 用户目标
- 用户指定范围，或待确认范围
- 仓库结构与现有文档

动作：

- 确认扫描范围，只允许以下两类：
  - `entire-project`
  - `module-scope(<path-or-module>)`
- 若范围不明确，先要求确认，不做大范围扫描
- 识别仓库中的 benchmark、test、性能相关文档、现有报告、可疑热点模块
- 生成或更新 `todo.md`

产出：

- 已确认的扫描范围
- `todo.md` 初稿或更新结果
- 可执行模式建议

进入下一步条件：

- 已有至少一个可执行 TODO
- 执行模式已确定

失败处理：

- 范围不明确：停止，等待用户确认
- 找不到可执行线索：记录为 `blocked`，说明缺少 benchmark / 指标 / 复现路径

### 6.2 `plan`

输入：

- 选中的 TODO ID
- 目标指标与成功阈值
- 正确性、兼容性、资源、发布风险等约束

动作：

- 按执行模式选择一个 TODO
- 明确目标指标，例如吞吐、P95、P99、CPU、内存、分配次数、队列长度、错误率
- 明确成功阈值和不可退化项
- 检查 benchmark/test 是否能覆盖目标路径
- 若覆盖不足，先补最小可复现 benchmark 或 test

产出：

- 选中的 TODO
- 明确的目标、约束、成功阈值
- 覆盖检查结论

进入下一步条件：

- TODO 状态更新为 `selected` 或 `baseline-ready`
- 已具备可执行 baseline 的命令和环境说明

失败处理：

- 用户未确认：保持在 `selected` 前状态
- 缺少可复现 benchmark：停止并先补 benchmark
- 缺少功能验证：停止并先补 test

详细基准策略见 [benchmark-policy](references/benchmark-policy.md)。

### 6.3 `baseline`

输入：

- 已选 TODO
- 基准命令
- 运行环境约束

动作：

- 在代码修改前运行 baseline
- 固定 workload、输入规模、线程/并发、构建模式、关键环境变量
- 优先重复运行并记录波动
- 保存原始结果、汇总结果、执行命令和环境说明

产出：

- baseline 数据
- 可复现执行命令
- TODO 状态更新为 `baseline-ready`

进入下一步条件：

- baseline 成功产出且可复现

失败处理：

- baseline 失败：停止修改代码，记录原因
- 结果不稳定且无法解释：标记 `blocked`，先治理 benchmark 噪声

### 6.4 `diagnose`

输入：

- baseline 数据
- profiler / flamegraph / perf / tracing / alloc / lock / queue 等证据
- 业务关键指标（若项目存在）

动作：

- 按证据优先级定位主导瓶颈
- 形成结构化诊断结论
- 明确“不建议改什么”
- 选择本轮最小切入点

产出：

- 结构化诊断结论
- 拟实施的最小改动方案

进入下一步条件：

- 主导瓶颈明确
- 证据与 TODO 的目标指标一致

失败处理：

- 没有足够证据：不得进入 `patch`
- 证据相互冲突：补充采样或降低结论强度，必要时标记 `not-proven` 或 `blocked`

详细诊断协议见 [diagnosis-protocol](references/diagnosis-protocol.md)。

### 6.5 `patch`

输入：

- 结构化诊断结论
- 最小改动方案
- 回滚路径

动作：

- 只实施与当前瓶颈直接相关的最小高收益改动
- 保持外部行为不变，除非用户明确授权调整行为
- 避免顺手重构、顺手清理、顺手改风格
- 改动前确认回滚路径清晰

产出：

- 最小补丁
- TODO 状态更新为 `in-progress`

进入下一步条件：

- 补丁可构建、可运行、可复测

失败处理：

- 改动扩大、行为漂移、回滚路径不清：停止并收缩方案

### 6.6 `validate`

输入：

- baseline 数据
- 修改后 benchmark 结果
- 功能验证结果

动作：

- 使用与 baseline 相同的方法复测
- 先做性能对比，再做功能验证
- 判断结果属于 `success`、`not-proven`、`regressed`、`failed` 之一

产出：

- before / after 对比
- 结论状态
- 功能验证记录

进入下一步条件：

- 若 `success`，进入 `report`
- 若 `not-proven`、`regressed` 或 `failed`，进入 `rollback`

失败处理：

- 没有可比对数据：不得宣称成功
- 结果落在噪声内：标记 `not-proven`
- 有性能退化或功能异常：进入 `rollback`

详细验证纪律见 [validation-policy](references/validation-policy.md)。

### 6.7 `rollback`

输入：

- 本轮补丁
- 失败原因
- 当前 TODO

动作：

- 立即回滚本轮补丁
- 更新 `todo.md` 状态和原因
- 记录失败类型：证据不足、结果未证实、性能回退、功能失败、环境不稳定

产出：

- 已回滚代码
- 已更新 TODO 状态与说明

进入下一步条件：

- 回滚完成后进入 `report`

失败处理：

- 若无法安全回滚，立即停止并明确说明风险，不得继续叠加改动

### 6.8 `report`

输入：

- TODO 状态
- baseline / after 数据
- 功能验证结论
- 回滚信息（若有）

动作：

- 生成性能报告
- 记录命令、环境、数据、诊断、变更摘要、验证结论、风险与后续建议

产出：

- 一份可审计、可复现的 perf report

进入下一步条件：

- 本轮工作流结束

失败处理：

- 报告缺少命令、环境、数据或结论时，不得结束本轮工作流

报告模板见 [report-template](references/report-template.md)。

## 7. 关键执行纪律

### 7.1 范围控制

- 未确认扫描范围前，不做全仓分析
- 未选择 TODO 前，不做代码优化
- 一次只推进一个 TODO

### 7.2 证据优先

- benchmark 数据优先于主观判断
- profiler / flamegraph / perf / tracing 热点优先于猜测
- alloc / lock / queue / syscall / cache miss 等辅助证据用于解释，不用于替代主指标

### 7.3 baseline before change

- 任何性能改动前必须先跑 baseline
- baseline 与 after 的命令、输入、环境必须尽量一致

### 7.4 minimal patch

- 从最小改动开始
- 优先可快速回滚的方案
- 禁止把“性能优化”扩展成重构项目

### 7.5 rollback on failure

- `not-proven`、`regressed`、`failed` 默认都要回滚
- 回滚后必须更新 TODO 状态与原因
- 未回滚完成前，不得切换到下一个优化项

### 7.6 功能验证晚于性能复测

- 先确认性能结论
- 对可接受结果再运行功能验证
- 功能失败视为本轮失败，必须回滚

## 8. 最终回复要求

每次完成本工作流后，对用户的最终回复至少包含：

1. 本轮执行的 TODO ID 与标题
2. 是否成功、未证实、回退或失败
3. baseline 与 after 的关键对比
4. 功能验证结论
5. 报告文件位置
6. 剩余待优化项清单

若无剩余项，必须明确写出“无剩余待优化项”。

## 9. 参考文件

- 基准策略：[benchmark-policy](references/benchmark-policy.md)
- 诊断协议：[diagnosis-protocol](references/diagnosis-protocol.md)
- 验证纪律：[validation-policy](references/validation-policy.md)
- 报告模板：[report-template](references/report-template.md)
- TODO 模板：[todo-template](references/todo-template.md)
