const std = @import("std");
const ArrayList = std.ArrayList;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    var exit = false;

    while (!exit) {
        var input = try readCmd();
        defer allocator.free(input);
        handleCmd(input);
    }

    defer _ = gpa.deinit();
}

pub fn readCmd() ![]u8 {
    const stdin = std.io.getStdIn();

    std.debug.print("\ncommand: ", .{});

    var input = ArrayList(u8).init(allocator);
    defer input.deinit();

    try stdin.reader().streamUntilDelimiter(input.writer(), '\n', 1024);

    return input.toOwnedSlice();
}

pub fn handleCmd(input: []u8) void {
    if (std.mem.eql(u8, input, "exit")) {
        std.os.exit(0);
    } else {
        std.debug.print("\nUnknown command.\n", .{});
    }
}
