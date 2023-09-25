const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;

const Task = struct {
    id: u32,
    name: []const u8,
    done: bool = false,
};

pub const App = struct {
    task_list: ArrayList(Task),
    next_id: u32,

    pub fn init(allocator: std.mem.Allocator) App {
        var task_list = ArrayList(Task).init(allocator);

        var app = App{
            .task_list = task_list,
            .next_id = 1,
        };

        return app;
    }

    pub fn deinit(self: *App) void {
        self.task_list.deinit();
    }

    // TODO: Number overflow
    fn getId(self: *App) u32 {
        var n = self.*.next_id;
        self.*.next_id += 1;

        return n;
    }

    pub fn add(self: *App, params: [][]const u8) void {
        if (params.len == 0) {
            print("Error: Please type a name for the task", .{});
        }

        var new_task = Task{ .name = params[0], .id = self.*.getId() };

        self.task_list.append(new_task) catch {
            print("\nError adding task. Not enough memory.\n", .{});
        };
    }

    pub fn list(self: App) void {
        print("\n == Task list ==\n", .{});
        print("ID\tNAME\tDONE\n", .{});

        for (self.task_list.items) |item| {
            var status = if (item.done) "done" else "pending";
            print("{d}\t{s}\t{s}\n", .{ item.id, item.name, status });
        }

        print("\n", .{});
    }
};
