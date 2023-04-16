const std = @import("std");
const token = @import("token.zig");
const KeyWordTable = token.KeyWordTable;

pub const Lexer = struct {
    input_source: [:0]const u8,
    ch: u8,
    line_num: u32 = 1,
    pos: u32 = 0,
    read_pos: u32 = 0,

    pub fn newLexer(input: [:0]const u8) Lexer {
        var lexer = Lexer{
            .input_source = input,
            .ch = '0',
            .line_num = 1,
            .pos = 0,
            .read_pos = 0,
        };
        lexer.readChar();
        return lexer;
    }

    pub fn nextToken(self: *Lexer) !token.Token {
        // skip space
        self.skipWithSpace();

        // if (self.ch == '\n') {
        //     self.line_num += 1;
        //     self.readChar();
        // }

        const ch = self.ch;
        self.readChar();

        const tok = switch (ch) {
            '+' => token.newToken(.TK_PLUS, "+", .{ .row = self.line_num, .file_name = "" }),
            '-' => token.newToken(.TK_MINUS, "-", .{ .row = self.line_num, .file_name = "" }),
            '*' => token.newToken(.TK_SLASH, "*", .{ .row = self.line_num, .file_name = "" }),
            '/' => token.newToken(.TK_ASTERISK, "/", .{ .row = self.line_num, .file_name = "" }),
            '(' => token.newToken(.TK_LPAREN, "(", .{ .row = self.line_num, .file_name = "t" }),
            ')' => token.newToken(token.TokenType.TK_RPAREN, ")", .{ .row = self.line_num, .file_name = "t" }),
            '[' => token.newToken(token.TokenType.TK_LBRACE, "[", .{ .row = self.line_num, .file_name = "t" }),
            ']' => token.newToken(token.TokenType.TK_RBRACE, "]", .{ .row = self.line_num, .file_name = "t" }),
            ':' => blk: {
                if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk token.newToken(token.TokenType.TK_ASSIGN_COL, ":=", .{ .row = self.line_num, .file_name = "t" });
                } else {
                    break :blk token.newToken(token.TokenType.TK_COLON, ":", .{ .row = self.line_num, .file_name = "t" });
                }
            },
            '=' => blk: {
                if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk token.newToken(token.TokenType.TK_EQ, "==", .{ .row = self.line_num, .file_name = "t" });
                } else {
                    break :blk token.newToken(token.TokenType.TK_ASSIGN, "=", .{ .row = self.line_num, .file_name = "t" });
                }
            },
            '.' => blk: {
                if (self.peekChar() == '.') {
                    self.readChar();
                    break :blk token.newToken(token.TokenType.TK_DOT2, "..", .{ .row = self.line_num, .file_name = "" });
                } else {
                    break :blk token.newToken(token.TokenType.TK_DOT, ".", .{ .row = self.line_num, .file_name = "" });
                }
            },
            '<' => blk: {
                if (self.peekChar() == '>') {
                    self.readChar();
                    break :blk token.newToken(token.TokenType.TK_NOT_EQ, "<>", .{ .row = self.line_num, .file_name = "" });
                } else if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk token.newToken(token.TokenType.Tk_LEQ, "<=", .{ .row = self.line_num, .file_name = "" });
                } else {
                    break :blk token.newToken(token.TokenType.TK_LT, "<", .{ .row = self.line_num, .file_name = "" });
                }
            },
            '>' => blk: {
                // self.ch == '='
                if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk token.newToken(.TK_GEQ, ">=", .{ .row = self.line_num, .file_name = "" });
                } else {
                    break :blk token.newToken(.TK_GT, ">", .{ .row = self.line_num, .file_name = "" });
                }
            },
            '\'' => try self.string(),
            ',' => token.newToken(.TK_COLON, ",", .{ .row = self.line_num, .file_name = "" }),
            ';' => token.newToken(.TK_SEMICOLON, ";", .{ .row = self.line_num, .file_name = "" }),
            '@' => token.newToken(.TK_AT, "@", .{ .row = self.line_num, .file_name = "" }),
            '^' => token.newToken(.TK_POINTER, "^", .{ .row = self.line_num, .file_name = "" }),
            // '\n' => blk: {
            //     self.line_num += 1;
            //     break :blk self.nextToken();
            // },
            '#' => token.newToken(.TK_EOF, "#", .{ .row = self.line_num, .file_name = "" }),
            else => blk: {
                if (isDigit(ch)) {
                    break :blk self.number();
                } else if (isAlpha(ch)) {
                    break :blk self.identifier();
                } else {
                    // break :blk token.newToken(.TK_EOF, "#", .{ .row = self.line_num, .file_name = "" });
                    break :blk error.UnKnownChar;
                }
            },
        };

        return tok;
    }

    pub fn isAnd(self: *Lexer) bool {
        return self.ch == '#';
    }

    pub fn skipWithSpace(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\r' or self.ch == '\n') {
            if (self.ch == '\n') self.line_num += 1;
            self.readChar();
        }
    }

    fn isDigit(ch: u8) bool {
        return ch >= '0' and ch <= '9';
    }

    fn isAlpha(ch: u8) bool {
        return (ch >= 'A' and ch <= 'Z') or (ch >= 'a' and ch <= 'z') or ch == '_';
    }

    pub fn number(self: *Lexer) token.Token {
        const pos = self.pos - 1;
        var flval: []const u8 = undefined;
        while (isDigit(self.ch)) {
            self.readChar();
        }

        if (self.ch == '.' and isDigit(self.peekChar())) {
            self.readChar();
            while (isDigit(self.ch)) {
                self.readChar();
            }
            flval = self.input_source[pos .. self.read_pos - 1];
            return token.newToken(.TK_FLOAT_CONST, flval, .{ .row = self.line_num, .file_name = "" });
        } else {
            flval = self.input_source[pos .. self.read_pos - 1];
            return token.newToken(.TK_INT_CONST, flval, .{ .row = self.line_num, .file_name = "" });
        }
    }

    pub fn identifier(self: *Lexer) !token.Token {
        var map = try KeyWordTable.initMap(std.heap.page_allocator);
        defer map.keyDeinit();
        const pos = self.pos - 1;
        while (isAlpha(self.ch) or isDigit(self.ch)) {
            self.readChar();
        }

        const ident = self.input_source[pos .. self.read_pos - 1];
        const token_type = map.lookUp(ident) orelse token.TokenType.TK_IDENT;

        return token.newToken(token_type, ident, .{ .row = self.line_num, .file_name = "" });
    }

    pub fn string(self: *Lexer) !token.Token {
        const pos = self.pos;
        while (self.ch != '\'' and self.ch != '\n' and !self.isAnd()) {
            self.readChar();
        }
        if (self.ch == '\n' or self.isAnd()) {
            // @painc("error not newline.");
            return error.NotNewLine;
        } else {
            // "'abc'" [pos, read_pos - 1) => abc
            const str = self.input_source[pos .. self.read_pos - 1];
            return token.newToken(.TK_STR_CONST, str, .{ .row = self.line_num, .file_name = "" });
        }
    }

    pub fn readChar(self: *Lexer) void {
        self.pos = self.read_pos;
        self.ch = if (self.read_pos >= self.input_source.len) blk: {
            break :blk '#';
        } else blk: {
            const ch = self.input_source[self.read_pos];
            self.read_pos = self.read_pos + 1;
            break :blk ch;
        };
    }

    pub fn peekChar(self: *Lexer) u8 {
        if (self.read_pos > self.input_source.len) {
            return '#';
        } else {
            return self.input_source[self.read_pos - 1];
        }
    }
};

test "lexer" {
    var lexer = Lexer.newLexer("<>"); //self.ch='<' read_pos => 1,pos=0
    var tk = try lexer.nextToken(); //ch=self.ch = '<' -> self.ch ='>', read_pos = 2, pos=1; self.readChar() ->self.ch='>', read_pos=3,pos=2;
    var tk2 = try lexer.nextToken(); //ch=self.ch='>' -> self.readChar() -> self.ch = '#', read_pos=4, pos=3
    try std.testing.expect(std.mem.eql(u8, "<>", tk.literal));
    // try std.testing.expect(std.mem.eql(u8, ">", tk2.literal));
    try std.testing.expect(tk2.type == .TK_EOF);
}
