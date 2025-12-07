const std = @import("std");

const helper = @import("helper.zig");
const utils = @import("utils.zig");

const FilePath = "src/source/source_01_00.txt";

pub fn execute_01() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 1.1  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const steps = try parse_input(alloc);
    defer alloc.free(steps);

    const start_ms = std.time.milliTimestamp();

    const result = try countLoops(steps, 100, 50);

    const end_ms = std.time.milliTimestamp();

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("Total: {d}\n", .{result.@"0"});
    std.debug.print("Time  : {s}\n\n", .{time});
}

pub fn execute_02() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 1.2  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const steps = try parse_input(alloc);
    defer alloc.free(steps);

    const start_ms = std.time.milliTimestamp();
    const result = try countLoops(steps, 100, 50);
    const end_ms = std.time.milliTimestamp();

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("Total: {d}\n", .{result.@"1"});
    std.debug.print("Time : {s}\n\n", .{time});
}

fn parse_input(allocator: std.mem.Allocator) ![]i64 {
    var file = try std.fs.cwd().openFile(FilePath, .{});
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

pub fn countLoops(steps: []i64, positions: u8, cursor: u8) !struct { u16, u16 } {
    var loops: u16 = 0;
    var count: u16 = 0;

    var new_cursor = cursor;

    for (steps) |step| {
        const loop = rotations(0, positions, new_cursor, step);

        new_cursor = move(positions, new_cursor, step);
        if (new_cursor == 0) {
            count += 1;
        }

        loops += loop;

        var direction: []const u8 = "left";
        if (step < 0) {
            direction = "right";
        }

        helper.printExp("|  Move {d:<3} clicks to {s:<5}: {d:<2}  |  Loops: {d}  |\n", .{ @abs(step), direction, cursor, loops });
    }

    helper.printExp("\n", .{});

    return .{ count, loops };
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
