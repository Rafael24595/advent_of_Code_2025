const std = @import("std");
const helper = @import("helper.zig");
const configuration = @import("configuration.zig");
const exercise_01 = @import("exercise_01.zig");
const exercise_02 = @import("exercise_02.zig");
const exercise_03 = @import("exercise_03.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var env = try helper.readEnvsWithFile(allocator, ".env");
    defer env.deinit();

     if (env.get("EXPLAIN")) |val| {
        if (std.mem.eql(u8, val, "true")) {
            configuration.explain = true;
        }
    }

    if (env.get("EXERCISE_01")) |val| {
        if (std.mem.eql(u8, val, "true")) {
            try exercise_01.execute();
        }
    }

    if (env.get("EXERCISE_02")) |val| {
        if (std.mem.containsAtLeast(u8, val, 1, "01")) {
            try exercise_02.execute_01();
        }
        if (std.mem.containsAtLeast(u8, val, 1, "02")) {
            try exercise_02.execute_02();
        }
    }

    if (env.get("EXERCISE_03")) |val| {
        if (std.mem.containsAtLeast(u8, val, 1, "01")) {
            try exercise_03.execute_01();
        }
        if (std.mem.containsAtLeast(u8, val, 1, "02")) {
            try exercise_03.execute_02();
        }
    }

}
