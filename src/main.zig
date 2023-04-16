const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const token = @import("token.zig");
// const Counter = struct {
//     a: u32 = 0,
//     b: u32 = 0,
//     pub fn new() *Counter {
//         return &Counter{};
//     }
//     pub fn add(self: *Counter) void {
//         if (self.a >= 3) {
//             self.a = 3;
//         } else {
//             self.a += 1;
//         }
//         self.b = self.a;
//     }
// };

pub fn main() !void {
    var lexer = Lexer.newLexer("=");
    var tk: token.Token = undefined;

    if (lexer.nextToken()) |ret| {
        tk = ret;
    } else |err| switch (err) {
        error.UnKnownChar => {
            std.debug.print("error unknown char.\n", .{});
        },
        error.NotNewLine => {
            std.debug.print("error not newline.\n", .{});
        },
        error.OutOfMemory => {
            std.debug.print("error out of memory.\n", .{});
        },
    }
    std.debug.print("{s} ", .{tk.literal});
    std.debug.print("{} ", .{lexer.pos});
}

test "simple test" {
    const a = "";
    _ = a;
}
