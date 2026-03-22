# todo template

`todo.md` 用于管理性能优化候选项、执行状态和审计记录。

每个优化项必须是“单轮可执行、可验证、可回滚”的最小单位。

## 1. 字段要求

每个优化项至少包含以下字段：

- `id`：唯一且稳定的优化项标识，例如 `OPT-P1-003`
- `title`：一句话说明优化目标
- `priority`：建议使用 `P0` / `P1` / `P2`
- `category`：必须属于主 skill 规定的允许值
- `expected_gain`：预期收益，禁止只写“提升性能”
- `target_metric`：例如 `throughput`、`p95`、`cpu`、`allocs/op`
- `scope`：涉及模块、路径或子系统
- `evidence`：当前已掌握证据，允许列命令、文件、图、数据
- `validation`：计划如何做 benchmark 与功能验证
- `risk`：`low` / `medium` / `high`
- `rollback`：如何快速撤回本轮修改
- `status`：必须属于主 skill 规定的允许值
- `notes`：额外限制、阻塞项、历史结论

## 2. 编写要求

- 每项只对应一个主导瓶颈
- 每项必须能明确“做完后如何判断成败”
- `scope` 不能写成“全仓重构”
- `rollback` 不能为空
- `evidence` 不能为空；没有证据的项只能做候选，不得直接执行

## 3. 推荐格式

```md
# 性能优化 TODO

## P0

### OPT-P0-001

- id: `OPT-P0-001`
- title: 降低解码热路径中的重复拷贝
- priority: `P0`
- category: `copy`
- expected_gain: P99 延迟下降 8% 到 15%
- target_metric: `p99 latency`
- scope: `module-scope(src/decoder)`
- evidence:
  - `bench decode_frame` 显示目标路径稳定复现
  - flamegraph 显示 `CopyPayload` 占热点 21%
- validation:
  - benchmark: `make bench BENCH=decode_frame`
  - test: `make test TEST=decoder`
- risk: `low`
- rollback: 还原 `src/decoder/*` 本轮补丁即可
- status: `proposed`
- notes: 不改协议接口，不改线程模型

## P1

### OPT-P1-001

- id: `OPT-P1-001`
- title: 收缩发送队列批量刷写阈值
- priority: `P1`
- category: `batching`
- expected_gain: 吞吐提升 5% 左右，尾延迟不回退
- target_metric: `throughput`
- scope: `module-scope(service/queue)`
- evidence:
  - 压测下队列积压与 flush 次数异常相关
- validation:
  - benchmark: `<repo-command>`
  - test: `<repo-command>`
- risk: `medium`
- rollback: 回退阈值配置与本轮补丁
- status: `proposed`
- notes: 若尾延迟增大则直接放弃
```

## 4. 状态流转建议

推荐状态流转：

`proposed -> selected -> baseline-ready -> in-progress -> success`

失败分支：

- `in-progress -> not-proven`
- `in-progress -> regressed`
- `in-progress -> failed`
- 任意状态 -> `blocked`
- 任意未执行项 -> `deferred`

## 5. 选择纪律

- `manual-selection`：必须由用户按 `id` 选择
- `recommended-single-step`：agent 推荐后等待确认
- `auto-pilot-low-risk`：仅允许 `risk=low` 且证据充分的项自动进入执行
