const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

const max_children = 26;

const Trie = struct {
    children: [26]?*Trie = .{null} ** 26,
    word_end: bool = false,
};

pub fn trieCreate(allocator: Allocator) !*Trie {
    var trie: *Trie = try allocator.create(Trie);
    for (0..26) |i| {
        trie.children[i] = null;
    }
    trie.word_end = false;
    return trie;
}

// TODO: return error union
pub fn trieInsert(allocator: Allocator, root: *const Trie, word: []const u8) bool {
    var curr: *Trie = @constCast(root);
    for (0..word.len) |i| {
        const index = word[i] - 'a';
        if (curr.children[index] == null) {
            curr.children[index] = trieCreate(allocator) catch return false;
        }
        curr = curr.children[index].?;
    }
    curr.word_end = true;
    return true;
}

// TODO: return error union
pub fn trieSearch(root: *const Trie, word: []const u8) bool {
    var curr: *Trie = @constCast(root);
    for (0..word.len) |i| {
        const index = word[i] - 'a';
        if (curr.children[index] == null) {
            return false;
        }
        curr = curr.children[index].?;
    }
    return curr.word_end;
}

pub fn trieStartsWith(root: *const Trie, prefix: []const u8) bool {
    var curr: *Trie = @constCast(root);
    for (0..prefix.len) |i| {
        const index = prefix[i] - 'a';
        if (curr.children[index] == null) {
            return false;
        }
        curr = curr.children[index].?;
    }
    return true;
}

pub fn triePrint(allocator: Allocator, root: *const Trie, buffer: *std.ArrayList(u8)) !void {
    const curr: *Trie = @constCast(root);

    if (curr.word_end) {
        std.debug.print("{s}\n", .{buffer.items});
    }

    for (0..26) |i| {
        if (curr.children[i] != null) {
            const value: u8 = @intCast(i + 'a');
            try buffer.append(allocator, value);
            try triePrint(allocator, curr.children[i].?, buffer);
            _ = buffer.pop();
        }
    }
}


pub fn trieFree(allocator: Allocator, trie: *const Trie) void {
    for (0..26) |index| {
        if (trie.children[index] != null) {
            const curr: *const Trie = trie.children[index].?;
            trieFree(allocator, curr);
        }
    }
    allocator.destroy(trie);
}

pub fn hahaha() u8 {
    return 0;
}

test "basic functionality" {
    const allocator = std.testing.allocator;
    const root: *const Trie = try trieCreate(allocator);
    {
        try testing.expect(trieInsert(allocator, root, "and") == true);
        try testing.expect(trieInsert(allocator, root, "ant") == true);
        try testing.expect(trieInsert(allocator, root, "dad") == true);
    }
    {
        try testing.expect(trieSearch(root, "and") == true);
        try testing.expect(trieSearch(root, "ant") == true);
        try testing.expect(trieSearch(root, "dad") == true);
        try testing.expect(trieSearch(root, "an") == false);
        try testing.expect(trieSearch(root, "d") == false);
        try testing.expect(trieSearch(root, "andz") == false);
    }
    {
        try testing.expect(trieStartsWith(root, "an") == true);
        try testing.expect(trieStartsWith(root, "a") == true);
        try testing.expect(trieStartsWith(root, "da") == true);
        try testing.expect(trieStartsWith(root, "t") == false);
    }
    var buffer = try std.ArrayList(u8).initCapacity(allocator, 100);
    defer buffer.deinit(allocator);
    try triePrint(allocator, root, &buffer);
    trieFree(allocator, root);
}
