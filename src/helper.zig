const std = @import("std");

const configuration = @import("configuration.zig");

pub const Pair = struct {
    a: usize,
    b: usize,
};

pub fn readEnvsWithFile(allocator: std.mem.Allocator, path: []const u8) !std.process.EnvMap {
    var env = try std.process.getEnvMap(allocator);

    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        if (err == std.fs.File.OpenError.FileNotFound) {
            return env;
        } else {
            return err;
        }
    };

    defer file.close();

    var buffer: [1024]u8 = undefined;

    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    while (reader.takeDelimiterExclusive('\n')) |line| {
        const eq_index = std.mem.indexOf(u8, line, "=");
        if (eq_index) |i| {
            const key = std.mem.trim(u8, line[0..i], " \n\t\r");
            const value = std.mem.trim(u8, line[i + 1 ..], " \n\t\r");
            try env.put(key, value);
        }
    } else |_| {}

    return env;
}

pub fn parseInputLines(alloc: std.mem.Allocator, sub_path: []const u8) ![][]u8 {
    var file = try std.fs.cwd().openFile(sub_path, .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;

    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    var list = try std.ArrayList([]u8).initCapacity(alloc, 0);

    while (reader.takeDelimiterExclusive('\n')) |line| {
        const clean_line = try alloc.dupe(u8, std.mem.trim(u8, line, " \n\t\r"));
        try list.append(alloc, clean_line);
    } else |_| {}

    return list.items;
}

pub fn printExp(comptime fmt: []const u8, args: anytype) void {
    if (!configuration.explain) {
        return;
    }

    std.debug.print(fmt, args);
}
