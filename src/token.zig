const std = @import("std");

pub const Token = struct {
    @"type": TokenType,
    literal: []const u8,
    line_info: struct {
        row: u32,
        file_name: []const u8 = "",
    },
};

pub const TokenType = enum {
    TK_EOF,
    // 标识符
    TK_IDENT,
    // 字面量
    TK_INT_CONST,
    TK_FLOAT_CONST,
    TK_STR_CONST,

    // 运算符
    TK_ASSIGN, // =
    TK_PLUS, // +
    TK_MINUS, // -
    TK_SLASH, // *
    TK_BANG, // !
    TK_ASTERISK, // /
    TK_LT, // <
    TK_GT, // >
    Tk_LEQ, // <=
    TK_GEQ, // >=
    TK_EQ, // ==
    TK_NOT_EQ, // <> | !=
    TK_AT, // @
    TK_POINTER,
    TK_ASSIGN_COL, // :=
    // 分隔符
    TK_COMMA, // ,
    TK_SEMICOLON, // ;
    TK_LPAREN, // (
    TK_RPAREN,
    TK_LBRACE, // [
    TK_RBRACE,
    // TK_LBRACKET, // {
    // TK_RBRACKET,
    TK_COLON, // :
    TK_DOT, // .
    TK_DOT2, // ..
    // 关键字
    TK_ASM,
    TK_BYTE,
    TK_CONST,
    TK_IF,
    TK_ELSE,
    TK_FUNCTION,
    TK_LABEL,
    TK_OF,
    TK_RECORD,
    TK_SHR,
    TK_TO,
    TK_WITH,
    TK_AND,
    TK_OR,
    TK_BREAK,
    TK_CONTINUE,
    TK_END,
    TK_GOTO,
    TK_LONGWORD,
    TK_REPEAT,
    TK_SINGLE,
    TK_TYPE,
    TK_WHILE,
    TK_ARRAY,
    TK_CARDINAL,
    TK_DIV,
    TK_FILE,
    TK_MOD,
    TK_PROCEDURE,
    TK_SET,
    TK_SMALLINT,
    TK_UNTIL,
    TK_WORD,
    TK_BEGIN,
    TK_CASE,
    TK_DO,
    TK_FOR,
    TK_IN,
    TK_NIL,
    TK_PROGRAM,
    TK_SHL,
    TK_STRING,
    TK_USES,
    TK_XOR,
    TK_BOOLEAN,
    TK_CHAR,
    TK_DOWNTO,
    TK_FORWARD,
    TK_INTEGER,
    TK_NOT,
    TK_REAL,
    TK_SHORTINT,
    TK_THEN,
    TK_VAR,
};

pub const TokenError = error{
    NotFound,
};

pub const KeyWordTable = struct {
    map: std.StringHashMap(TokenType),

    pub fn initMap(allocator: std.mem.Allocator) !KeyWordTable {
        var map = std.StringHashMap(TokenType).init(allocator);
        const KeyMap = struct { key: []const u8, token_type: TokenType };
        const Array = [_]KeyMap{
            .{ .key = "repeat", .token_type = .TK_REPEAT },
            .{ .key = "single", .token_type = .TK_SINGLE },
            .{ .key = "type", .token_type = .TK_TYPE },
            .{ .key = "while", .token_type = .TK_WHILE },
            .{ .key = "if", .token_type = .TK_IF },
            .{ .key = "asm", .token_type = .TK_ASM },
            .{ .key = "byte", .token_type = .TK_BYTE },
            .{ .key = "const", .token_type = .TK_CONST },
            .{ .key = "else", .token_type = .TK_ELSE },
            .{ .key = "label", .token_type = .TK_LABEL },
            .{ .key = "of", .token_type = .TK_OF },
            .{ .key = "record", .token_type = .TK_RECORD },
            .{ .key = "shr", .token_type = .TK_SHR },
            .{ .key = "to", .token_type = .TK_TO },
            .{ .key = "with", .token_type = .TK_WITH },
            .{ .key = "and", .token_type = .TK_AND },
            .{ .key = "break", .token_type = .TK_BREAK },
            .{ .key = "continue", .token_type = .TK_CONTINUE },
            .{ .key = "end", .token_type = .TK_END },
            .{ .key = "goto", .token_type = .TK_GOTO },
            .{ .key = "longword", .token_type = .TK_LONGWORD },
            .{ .key = "or", .token_type = .TK_OR },
            .{ .key = "array", .token_type = .TK_ARRAY },
            .{ .key = "cardinal", .token_type = .TK_CARDINAL },
            .{ .key = "div", .token_type = .TK_DIV },
            .{ .key = "file", .token_type = .TK_FILE },
            .{ .key = "mod", .token_type = .TK_MOD },
            .{ .key = "procedure", .token_type = .TK_PROCEDURE },
            .{ .key = "set", .token_type = .TK_SET },
            .{ .key = "smallint", .token_type = .TK_SMALLINT },
            .{ .key = "until", .token_type = .TK_UNTIL },
            .{ .key = "word", .token_type = .TK_WORD },
            .{ .key = "begin", .token_type = .TK_BEGIN },
            .{ .key = "case", .token_type = .TK_CASE },
            .{ .key = "do", .token_type = .TK_DO },
            .{ .key = "for", .token_type = .TK_FOR },
            .{ .key = "in", .token_type = .TK_IN },
            .{ .key = "nil", .token_type = .TK_NIL },
            .{ .key = "program", .token_type = .TK_PROGRAM },
            .{ .key = "shl", .token_type = .TK_SHL },
            .{ .key = "string", .token_type = .TK_STRING },
            .{ .key = "uses", .token_type = .TK_USES },
            .{ .key = "xor", .token_type = .TK_XOR },
            .{ .key = "boolean", .token_type = .TK_BOOLEAN },
            .{ .key = "char", .token_type = .TK_CHAR },
            .{ .key = "downto", .token_type = .TK_DOWNTO },
            .{ .key = "forward", .token_type = .TK_FORWARD },
            .{ .key = "integer", .token_type = .TK_INTEGER },
            .{ .key = "not", .token_type = .TK_NOT },
            .{ .key = "real", .token_type = .TK_REAL },
            .{ .key = "shortint", .token_type = .TK_SHORTINT },
            .{ .key = "then", .token_type = .TK_THEN },
            .{ .key = "var", .token_type = .TK_VAR },
        };

        for (Array) |item| {
            try map.put(item.key, item.token_type);
        }

        return KeyWordTable{
            .map = map,
        };
    }

    pub fn keyDeinit(self: *KeyWordTable) void {
        self.map.deinit();
    }

    pub fn lookUp(self: *KeyWordTable, key: []const u8) ?TokenType {
        var result = self.map.get(key);
        // if (result) |ret| {
        //     return ret;
        // }
        return result;
    }

    pub fn lexerError(self: *KeyWordTable, msg: []const u8) void {
        _ = self;
        std.debug.print("{s}", .{msg});
    }
};

pub fn newToken(ty: TokenType, lit: []const u8, line: anytype) Token {
    return .{
        .@"type" = ty,
        .literal = lit,
        .line_info = line,
    };
}

test "token.zig" {
    var map = try KeyWordTable.initMap(std.testing.allocator);
    defer map.keyDeinit();
    const tif = map.lookUp("var") orelse .TK_IDENT;
    try std.testing.expect(@as(TokenType, tif) == TokenType.TK_VAR);
}
