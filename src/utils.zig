const std = @import("std");

pub fn formatTime(alloc: std.mem.Allocator, ms: i64) ![]const u8 {
    const hours = @divFloor(ms, 3_600_000);
    const minutes = @divFloor(@mod(ms , 3_600_000), 60_000);
    const seconds = @divFloor(@mod(ms , 60_000), 1000);
    const milliseconds = @mod(ms , 1000);

    var buffer = try std.ArrayList(u8).initCapacity(alloc, 0);

    if (hours != 0) {
        const time = try std.fmt.allocPrint(alloc, "{}h ", .{hours});
        try buffer.appendSlice(alloc, time);
    }

    if (minutes != 0) {
        const time = try std.fmt.allocPrint(alloc, "{}m ", .{minutes});
        try buffer.appendSlice(alloc, time);
    }

    if (seconds != 0) {
        const time = try std.fmt.allocPrint(alloc, "{}s ", .{seconds});
        try buffer.appendSlice(alloc, time);
    }
    if (milliseconds != 0) {
        const time = try std.fmt.allocPrint(alloc, "{}ms", .{milliseconds});
        try buffer.appendSlice(alloc, time);
    }

    return std.mem.trim(u8, buffer.items, " \n\t\r");
}
