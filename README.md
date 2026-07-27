# Trie

An implementation of a Trie data structure (also known as Prefix tree) in zig.

## Usage

``` zig
    const allocator = std.testing.allocator;
    const trie = try Trie().init(allocator);
    defer trie.deinit();
    
    trie.insert("and");
    trie.insert("ant");
    
    var buffer = try std.ArrayList(u8).initCapacity(allocator, 100);
    defer buffer.deinit(allocator);
    try trie.print(&buffer);
```
