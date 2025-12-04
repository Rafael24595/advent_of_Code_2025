const std = @import("std");
const helper = @import("helper.zig");
const utils = @import("utils.zig");

const str_nums: [10]u8 = .{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };

pub fn execute_01() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 3.1  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const lines = try helper.parseInputLines(alloc, "src/source/source_03_00.txt");
    defer alloc.free(lines);

    try execute(alloc, lines, 2);
}

pub fn execute_02() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 3.2  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const lines = try helper.parseInputLines(alloc, "src/source/source_03_00.txt");
    defer alloc.free(lines);

    try execute(alloc, lines, 12);
}

fn execute(alloc: std.mem.Allocator, lines: [][]u8, limit: usize) !void {
    const start_ms = std.time.milliTimestamp();

    var total: usize = 0;
    for (lines) |line| {
        helper.printExp("\nProcessing line: {s}\n", .{line});

        const number = try findMaxSubsequence(alloc, line, limit);
        total += number;

        helper.printExp("\nCompleted line: {s} | Number: {d}.\n\n", .{ line, number });
    }

    const end_ms = std.time.milliTimestamp();

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("Total: {d}\n", .{total});
    std.debug.print("Time: {s}\n\n", .{time});
}

fn findMaxSubsequence(alloc: std.mem.Allocator, line: []u8, limit: usize) !usize {
    var buffer = try alloc.alloc(u8, limit);
    defer alloc.free(buffer);

    @memset(buffer, '.');

    const line_len = line.len;
    var cursor: usize = 0;

    for (0..line_len) |i| {
        const digit = line[i];

        helper.printExp("\n Evalue line digit index {d} ({c}).\n\n", .{ i, digit });

        while (cursor > 0 and
            buffer[cursor - 1] < digit and
            cursor - 1 + (line_len - i) >= limit)
        {
            helper.printExp("  Pop digit {c}, digits remaining to reach limit {d}.\n", .{ buffer[cursor - 1], cursor - 1 + (line_len - i) });
            helper.printExp("  Move cursor to left, from {d} to {d}.\n", .{ cursor, cursor - 1 });

            cursor -= 1;
            buffer[cursor] = '.';
        }

        if (cursor < limit) {
            helper.printExp("  Move cursor to right, from {d} to {d}.\n", .{ cursor, cursor + 1 });
            helper.printExp("  Push digit {c}, to the buffer.\n", .{digit});

            buffer[cursor] = digit;
            cursor += 1;
        }

        helper.printExp("\n Buffer status: {s} | Limit: {d} | Space remain: {d} | Cursor: {d}.\n", .{ buffer, limit, line_len - i - 1, cursor });
    }

    return try std.fmt.parseInt(usize, buffer, 10);
}

fn _executeFixedTo2(alloc: std.mem.Allocator, lines: [][]u8) !void {
    var total: usize = 0;
    for (lines) |line| {
        var batery_focus: usize = 0;

        var bateries_index = try alloc.alloc(u8, 2);
        var cursor: usize = str_nums.len - 1;
        var line_copy = try alloc.dupe(u8, line);

        helper.printExp("\nProcessing line: {s}\n", .{line_copy});

        while (batery_focus < 2 and cursor >= 0) {
            var i: usize = cursor;
            while (i > 0) : (i -= 1) {
                helper.printExp("\n Searching for '{c}' in remaining line: {s}\n", .{ str_nums[i], line_copy });

                const eq_index = std.mem.indexOfScalar(u8, line_copy, str_nums[i]);
                if (eq_index == null) {
                    helper.printExp("\n  '{c}' not found. Continuing to next candidate.\n", .{str_nums[i]});
                    continue;
                }

                helper.printExp("\n  Found '{c}' at index {d}.\n", .{ str_nums[i], eq_index.? });

                bateries_index[batery_focus] = line_copy[eq_index.?];
                cursor = str_nums.len - 1;
                batery_focus += 1;

                line_copy = line_copy[eq_index.? + 1 ..];

                if (line_copy.len == 0 and batery_focus < 2) {
                    helper.printExp("\n  Line exhausted before finding 2 batteries. Resetting sequence.\n", .{});
                    alloc.free(bateries_index);
                    bateries_index = try alloc.alloc(u8, 2);
                    cursor = i - 1;
                    batery_focus = 0;
                    line_copy = try alloc.dupe(u8, line);
                }

                if (batery_focus == 2) {
                    helper.printExp("\n  All positions are found.\n", .{});
                    break;
                }

                helper.printExp("\n  Current bateries_index: [{s}], batery_focus: {d}.\n", .{ bateries_index, batery_focus });
                helper.printExp("  Starting search from {d}.\n", .{cursor});
                helper.printExp("  Remaining line to scan: {s}.\n", .{line_copy});

                break;
            }
        }

        const number = try std.fmt.parseInt(usize, bateries_index, 10);
        total += number;

        helper.printExp("\nCompleted line: {s} | Positions: [{c}, {c}] | Number: {d}.\n", .{ line, bateries_index[0], bateries_index[1], number });

        alloc.free(bateries_index);
    }

    helper.printExp("\nTotal: {d}.\n", .{total});
}
