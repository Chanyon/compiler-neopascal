### step
- lexer => tokens
- parse => AST
- AST => IR
- IR => codegen
- 汇编链接 => bin

### 语法
```
const a = 2;
```

### KISS(Keep It Stupid Simple)
- 变量(创建/赋值)
- 当前只实现整数的[加/减/乘/除]功能
