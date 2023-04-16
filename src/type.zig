pub const NeoType = struct {
    kind: Kind,
    u: ?union(enum) {
        Named: struct {
            type_name: []const u8,
            ty: NeoType,
        },
        Array: NeoType,
        Record: TypeFileldList,
    },
};

pub const Kind = enum { T_Record, T_Nil, T_Int, T_String, T_Array, T_Named, T_Undefined };

pub const TypeFileld = struct {
    name: []const u8,
    ty: NeoType,
};

pub const TypeFileldList = struct {
    head: TypeFileld,
    tail: ?*TypeFileldList,
};

pub const TypeList = struct {
    head: NeoType,
    tail: ?*TypeList,
};

///类型环境
pub const Env = struct {
    kind: enum { E_VarEntry, E_FunEntry },
    u: union(enum) {
        Var: struct {
            ty: NeoType,
        },
        Fun: struct {
            formals: TypeList,
            result: NeoType,
        },
    },
};

pub const ExpAndType = struct {
    // exp: type //已转换为中间表达式
    ty: NeoType,
};

//Tables-> 标识符表+类型表
// 环境：符号表
// 类型检查阶段需要同时使用类型环境和值环境
// 实现一个类型检查器
