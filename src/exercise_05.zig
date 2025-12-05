const std = @import("std");
const helper = @import("helper.zig");
const utils = @import("utils.zig");

pub fn execute_01() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 5.1  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const result = try parseInput(alloc);
    defer alloc.free(result.@"0");
    defer alloc.free(result.@"1");

    try countValidValues(alloc, result.@"0", result.@"1");
}

pub fn execute_02() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 5.2  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const result = try parseInput(alloc);
    defer alloc.free(result.@"0");
    defer alloc.free(result.@"1");

    try countTotalRanges(alloc, result.@"0");
}

fn parseInput(alloc: std.mem.Allocator) !struct { []helper.Pair, []u64 } {
    var file = try std.fs.cwd().readFileAlloc(alloc, "src/source/source_05_00.txt", 1_000_000);

    var eq_index = std.mem.indexOf(u8, file, "\n\n");
    if (eq_index == null) {
        eq_index = std.mem.indexOf(u8, file, "\r\n\r\n");
    }

    const ranges = try parseInputRanges(alloc, file[0..eq_index.?]);
    const values = try parseInputValues(alloc, file[eq_index.? + 1 ..]);

    return .{ ranges, values };
}

fn parseInputRanges(alloc: std.mem.Allocator, block: []const u8) ![]helper.Pair {
    var list = try std.ArrayList(helper.Pair).initCapacity(alloc, 0);

    var iter = std.mem.splitScalar(u8, block, '\n');
    while (iter.next()) |line| {
        const clean = std.mem.trim(u8, line, " \n\t\r");

        const eq_index = std.mem.indexOf(u8, clean, "-");
        if (eq_index == null) {
            continue;
        }

        const min = try std.fmt.parseInt(usize, clean[0..eq_index.?], 10);
        const max = try std.fmt.parseInt(usize, clean[eq_index.? + 1 ..], 10);

        try list.append(alloc, .{ .a = min, .b = max });
    }

    return list.items;
}

fn parseInputValues(alloc: std.mem.Allocator, block: []const u8) ![]u64 {
    var list = try std.ArrayList(u64).initCapacity(alloc, 0);

    var iter = std.mem.splitScalar(u8, block, '\n');
    while (iter.next()) |line| {
        const clean = std.mem.trim(u8, line, " \n\t\r");
        if (clean.len == 0) {
            continue;
        }

        const number = try std.fmt.parseInt(u64, clean, 10);
        try list.append(alloc, number);
    }

    return list.items;
}

fn countValidValues(alloc: std.mem.Allocator, rngs: []helper.Pair, values: []u64) !void {
    const start_ms = std.time.milliTimestamp();

    const norm = try normalizeRanges(alloc, rngs);
    defer alloc.free(norm);

    helper.printExp("Ranges raw ({d}): {any}\n", .{rngs.len, rngs});
    helper.printExp("Ranges fix ({d}): {any}\n", .{norm.len, norm});
    helper.printExp("\nGlobal range: [{d}, {d}]\n", .{ norm[0].a, norm[norm.len - 1].b });

    var total: u64 = 0;
    for (values) |value| {
        helper.printExp("\nChecking value: {d}\n", .{value});


        if (norm[0].a > value or norm[norm.len - 1].b < value) {
            helper.printExp(" - Value is out of global range [{d}, {d}].\n", .{ norm[0].a, norm[norm.len - 1].b });
            continue;
        }

        for (norm) |range| {
            helper.printExp(" - Current range: [{d:<2}, {d:<2}]\n", .{ range.a, range.b });

            if (range.a <= value and range.b >= value) {
                helper.printExp(" - Matched!\n", .{});
                total += 1;
                break;
            }
        }
    }

    const end_ms = std.time.milliTimestamp();

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("\nTotal: {d}\n", .{total});
    std.debug.print("Time: {s}\n\n", .{time});
}

fn countTotalRanges(alloc: std.mem.Allocator, rngs: []helper.Pair) !void {
    const start_ms = std.time.milliTimestamp();

    const norm = try normalizeRanges(alloc, rngs);
    defer alloc.free(norm);

    helper.printExp("Ranges raw ({d}): {any}\n", .{rngs.len, rngs});
    helper.printExp("Ranges fix ({d}): {any}\n", .{norm.len, norm});

    var total: u64 = 0;
    for (norm) |rng| {
        total += rng.b - rng.a + 1;
    }

    const end_ms = std.time.milliTimestamp();

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("\nTotal: {d}\n", .{total});
    std.debug.print("Time: {s}\n\n", .{time});
}

fn normalizeRanges(alloc: std.mem.Allocator, ranges: []helper.Pair) ![]helper.Pair {
    std.mem.sort(helper.Pair, ranges, {}, helper.comparePairAsc);

    var list = try std.ArrayList(helper.Pair).initCapacity(alloc, 0);

    for (ranges) |range| {
        if (list.items.len == 0) {
            try list.append(alloc, range);
        }

        var last = &list.items[list.items.len - 1];
        if (last.b >= range.a) {
            if (last.b < range.b) {
                last.b = range.b;
            }
            continue;
        }

        try list.append(alloc, range);
    }

    return list.items;
}
