const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub fn Trie() type {
    return struct {
        const Node = struct {
            word_end: bool = false,
            children: [26]?*Node = .{null} ** 26,
        };
        const Self = @This();

        root: ?*Node = null,
        allocator: Allocator,

        fn _create_node(allocator: Allocator) !*Node {
            const node: *Node = try allocator.create(Node);
            for (0..26) |i| {
                node.children[i] = null;
            }
            node.word_end = false;
            return node;
        }

        fn init(allocator: Allocator) !Self {
            const node: *Node  = try _create_node(allocator);
            return .{ .allocator = allocator, .root = node };
        }

        fn insert(self: Self, word: []const u8) !void {
            var current: *Node = self.root.?;
            for (0..word.len) |i| {
                const index = word[i] - 'a';
                if (current.children[index] == null) {
                    current.children[index] = try _create_node(self.allocator);
                }
                current = current.children[index].?;
            }
            current.word_end = true;
            return;
        }

        fn searchWord(self: Self, word: []const u8) bool {
            var current: *Node = self.root;
            for (0..word.len) |i| {
                const index = word[i] - 'a';
                if (current.children[index] == null) {
                    return false;
                }
                current = current.children[index].?;
            }
            return current.word_end;
        }

        fn searchPrefix(self: Self, prefix: []const u8) bool {
            var current: *Node = self.root;
            for (0..prefix.len) |i| {
                const index = prefix[i] - 'a';
                if (current.children[index] == null) {
                    return false;
                }
                current = current.children[index].?;
            }
            return true;
        }

        fn _print(allocator: Allocator, buffer: *std.ArrayList(u8), current: *Node) !void {
            if (current.word_end) {
                std.debug.print("{s}\n", .{buffer.items});
            }

            for (0..26) |i| {
                if (current.children[i] != null) {
                    const value: u8 = @intCast(i + 'a');
                    try buffer.append(allocator, value);
                    try _print(allocator, buffer, current.children[i].?);
                    _ = buffer.pop();
                }
            }
        }

        fn print(self: Self, buffer: *std.ArrayList(u8)) !void {
            return _print(self.allocator, buffer, self.root.?);
        }

        fn _deinit(self: Self, current: *Node) void {
            for (0..26) |index| {
                if (current.children[index] != null) {
                    self._deinit(current.children[index].?);
                }
            }
            self.allocator.destroy(current);
        }

        fn deinit(self: Self) void {
            return _deinit(self, self.root.?);
        }
    };
}

test "basic functionality" {
    const allocator = std.testing.allocator;
    const trie = try Trie().init(allocator);
    defer trie.deinit();
    {
        try trie.insert("and");
        try trie.insert("ant");
        try trie.insert("dad");
    }
    var buffer = try std.ArrayList(u8).initCapacity(allocator, 100);
    defer buffer.deinit(allocator);
    try trie.print(&buffer);
}
