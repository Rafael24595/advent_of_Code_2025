const std = @import("std");
const utils = @import("utils.zig");

pub fn execute() !void {
    std.debug.print("\n------------------------", .{});
    std.debug.print("\n|  Exercise 1.1 / 1.2  |", .{});
    std.debug.print("\n------------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const steps = try parse_input(alloc);
    defer alloc.free(steps);

    const positions: u8 = 100;
    var cursor: u8 = 50;

    var loops: u16 = 0;
    var count: u16 = 0;

    const start_ms = std.time.milliTimestamp();
    for (steps) |step| {
        const loop = rotations(0, positions, cursor, step);

        cursor = move(positions, cursor, step);
        if (cursor == 0) {
            count += 1;
        }

        loops += loop;

        var direction: []const u8 = "left";
        if (step < 0) {
            direction = "right";
        }

        std.debug.print("|  Move {d:<3} clicks to {s:<5}: {d:<2}  |  Loops: {d}  |\n", .{ @abs(step), direction, cursor, loops });
    }
    const end_ms = std.time.milliTimestamp();

    const time = try utils.formatTime(alloc, end_ms - start_ms);
    defer alloc.free(time);

    std.debug.print("\nZeroes: {d}\n", .{count});
    std.debug.print("Loops: {d}\n", .{loops});
    std.debug.print("Time: {d}ms\n\n", .{end_ms - start_ms});
}

fn parse_input(allocator: std.mem.Allocator) ![]i64 {
    var file = try std.fs.cwd().openFile("src/source/source_01_00.txt", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;

    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    var list = try std.ArrayList(i64).initCapacity(allocator, 0);

    while (reader.takeDelimiterExclusive('\n')) |line| {
        var mult: i8 = 1;
        if (line.len > 0 and line[0] == 'L') {
            mult = -1;
        }

        const number_slice = std.mem.trim(u8, line[1..], " \t\r");
        const value = try std.fmt.parseInt(i64, number_slice, 10);
        try list.append(allocator, value * mult);
    } else |_| {}

    return list.items;
}

fn move(positions: u8, cursor: u8, movement: i64) u8 {
    const new_cursor = @mod(cursor + movement, positions);
    return @intCast(new_cursor);
}

fn rotations(target: u8, positions: u8, cursor: u8, movement: i64) u8 {
    const i_target: i8 = @intCast(target);
    const i_cursor: i8 = @intCast(cursor);
    const i_positions: i8 = @intCast(positions);

    if (movement > 0) {
        const after = @divFloor(i_cursor - i_target + movement, i_positions);
        const before = @divFloor(i_cursor - i_target, i_positions);
        return @intCast(@abs(after - before));
    }

    if (movement < 0) {
        const after = @divFloor(i_target - i_cursor, i_positions);
        const before = @divFloor(i_target - (i_cursor + movement), i_positions);
        return @intCast(@abs(after - before));
    }

    if (i_cursor == i_target) {
        return 1;
    }

    return 0;
}
