const std = @import("std");
const ArrayList = std.ArrayList;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Operation = enum { add, list, remove, set, rename, help, unknown, exit };

const Command = struct { operation: Operation, params: [][]const u8 };

const Task = struct {
    id: u32,
    name: []u8,
    done: bool,
};

pub fn readInput() ![]u8 {
    const stdin = std.io.getStdIn();

    std.debug.print("\nCommand: ", .{});

    var input = ArrayList(u8).init(allocator);
    defer input.deinit();

    try stdin.reader().streamUntilDelimiter(input.writer(), '\n', 1024);

    return input.toOwnedSlice();
}

pub fn eql(a: []const u8, b: []const u8) bool {
    return std.ascii.eqlIgnoreCase(a, b);
}

// TODO: Switch?!?
pub fn getOperation(op: []const u8) Operation {
    if (eql(op, "add")) {
        return Operation.add;
    }

    if (eql(op, "exit")) {
        return Operation.exit;
    }

    if (eql(op, "help")) {
        return Operation.help;
    }

    if (eql(op, "list")) {
        return Operation.list;
    }

    if (eql(op, "remove")) {
        return Operation.remove;
    }

    if (eql(op, "rename")) {
        return Operation.rename;
    }

    if (eql(op, "set")) {
        return Operation.set;
    }

    return Operation.unknown;
}

pub fn parseInput(input: []u8) !*const Command {
    var split = std.mem.splitSequence(u8, input, " ");
    var op = split.first();
    var params_list = ArrayList([]const u8).init(allocator);
    defer params_list.deinit();

    while (split.next()) |param| {
        try params_list.append(param);
    }

    return &Command{ .operation = getOperation(op), .params = try params_list.toOwnedSlice() };
}

pub fn handleCommand(cmd: *const Command) void {
    switch (cmd.operation) {
        Operation.exit => std.os.exit(0),
        else => std.debug.print("Comando desconhecido.", .{}),
    }
}

pub fn main() !void {
    var exit = false;

    var task_list = ArrayList(Task).init(allocator);
    defer task_list.deinit();

    while (!exit) {
        var input = try readInput();

        var cmd = parseInput(input);

        std.debug.print("Res: {any}", .{cmd});
    }

    defer _ = gpa.deinit();
}
