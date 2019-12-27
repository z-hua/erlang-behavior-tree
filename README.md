行为树
=====

## 控制节点

### 序列节点

- 节点说明
    + 若子节点返回 failure, 停止迭代, 并向父节点返回 failure
    + 若子节点返回 success, 继续执行下一子节点
    + 若所有子节点都返回 success, 则向父节点返回 success

- 节点属性
    + 无

---

### 选择节点

- 节点说明
    + 若子节点返回 success, 停止迭代, 并向父节点返回 success
    + 若子节点返回 failure, 继续执行下一子节点
    + 若所有子节点都返回 failure, 则向父节点返回 failure

- 节点属性
    + 无

---

### 并行节点

- 节点说明
    + 执行所有子节点，根据 type 属性向父节点返回结果

- 节点属性
    + type(必须)
        * one_succ : 若有一个子节点返回 success, 则向父节点返回 success
        * one_fail : 若有一个子节点返回 failure, 则向父节点返回 failure
        * all_succ : 若所有子节点都返回 success, 则向父节点返回 success
        * all_fail : 若所有子节点都返回 failure, 则向父节点返回 failure

---

### 随机节点

- 节点说明
    + 随机选择一个子节点执行，并向父节点返回子节点的结果

- 节点属性
    + weight(可选，默认为 false)
        * true  : 子节点中应包含 weight 属性，按权重选择子节点
        * false : 子节点中不包含 weight 属性，随机选择子节点

---

### 循环节点

- 节点说明
    + 循环执行子节点，根据 loop 属性向父节点返回结果

- 节点属性
    + loop(必须)
        * until_succ : 直到子节点返回 success 时，终止循环，并向父节点返回 success
        * until_fail : 直到子节点返回 failure 时，终止循环，并向父节点返回 failure
        * infinity : 无限循环
        * N(N>0) : 循环 N 次

---

### 计数节点

- 节点说明
    + 未达到指定次数时，执行子节点，子节点返回时，根据 count 属性增加次数，并向父节点返回子节点的结果
    + 达到指定次数时，不执行子节点，并向父节点返回 failure
- 节点属性
    + times(必须)
        * N(N>0) : 执行 N 次
    + count(可选，默认为 always)
        * when_succ : 子节点返回 success 时 +1
        * when_fail : 子节点返回 failure 时 +1
        * always : 总是 +1

>>> 注意：与循环节点不同，循环节点中的计数器是一直循环执行子节点，直到执行 N 次，而计数节点中的计数器是会跳出子节点的

---

## 装饰节点

### 成功节点

- 节点说明
    + 总是向父节点返回 success

- 节点属性
    + 无

---

### 失败节点

- 节点说明
    + 总是向父节点返回 failure

- 节点属性
    + 无

---

### 取反节点

- 节点说明
    + 对子节点结果进行取反

- 节点属性
    + 无

---

## 叶子节点

### 条件节点

- 节点说明
    + 若函数返回 true ，则向父节点返回 success
    + 若函数返回 false ，则向父节点返回 failure

- 节点属性
    + action(必须)
        * {M,F,A},
        * fun() -> do_something end

---

### 动作节点

- 节点说明
    + 执行具体行为的函数，返回值可以是 success, failure, running
- 节点属性
    + action
        * {M,F,A}
        * fun() -> do_something end