const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;
const App = @import("app.zig").App;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Operation = enum { add, list, remove, set, rename, help, unknown, exit };

const Command = struct { operation: Operation, params: [][]const u8 };

pub fn readInput() ![]u8 {
    const stdin = std.io.getStdIn();

    std.debug.print("-> ", .{});

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

    var cmd = Command{ .operation = getOperation(op), .params = try params_list.toOwnedSlice() };

    return &cmd;
}

pub fn handleCommand(app: *App, cmd: *const Command) void {
    switch (cmd.operation) {
        .exit => {
            std.os.exit(0);
        },

        .unknown => {
            std.debug.print("Unknown command.\n", .{});
        },

        .add => {
            if (cmd.params.len == 0) {
                print("Missing task name.\n", .{});
                return;
            }
            var name = cmd.params[0];

            app.add(name);
        },

        .list => {
            app.list();
        },

        .remove => {
            if (cmd.params.len == 0) {
                print("Missing id.\n", .{});
                return;
            }

            var id_to_remove = std.fmt.parseInt(u32, cmd.params[0], 10) catch {
                print("Invalid id format. ({s})\n", .{cmd.params[0]});
                return;
            };

            app.remove(id_to_remove);
        },

        .rename => {
            if (cmd.params.len < 2) {
                print("Missing id and/or name.\n", .{});
                return;
            }

            var id_to_rename = std.fmt.parseInt(u32, cmd.params[0], 10) catch {
                print("Invalid id format. ({s})\n", .{cmd.params[0]});
                return;
            };

            var new_name = cmd.params[1];

            app.rename(id_to_rename, new_name);
        },

        else => std.debug.print("Unknown command.\n", .{}),
    }
}

pub fn main() !void {
    var app = App.init(allocator);
    defer app.deinit();

    while (true) {
        var input = try readInput();

        var cmd = try parseInput(input);

        handleCommand(&app, cmd);
    }

    _ = gpa.deinit();
}
