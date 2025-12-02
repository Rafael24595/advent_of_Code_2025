const std = @import("std");
const helper = @import("helper.zig");
const exercise_01 = @import("exercise_01.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var env = try helper.readEnvsWithFile(allocator, ".env");
    defer env.deinit();

    if (env.get("EXERCISE_01")) |val| {
        if (std.mem.eql(u8, val, "true")) {
            try exercise_01.execute();
        }
    }
}
