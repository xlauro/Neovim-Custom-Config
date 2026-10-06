local ls = require("luasnip")
local s, i = ls.snippet, ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
    s({ trig = "std", dscr = "Importar a biblioteca padrão" }, fmt('const std = @import("std");\n{}', { i(0) })),
    s({ trig = "imp", dscr = "Importar módulo" }, fmt('const {} = @import("{}");', { i(1, "module"), i(2, "module.zig") })),
    s({ trig = "fn", dscr = "Função" }, fmt("fn {}({}) {} {{\n    {}\n}}", {
        i(1, "name"), i(2), i(3, "void"), i(0),
    })),
    s({ trig = "pfn", dscr = "Função pública" }, fmt("pub fn {}({}) {} {{\n    {}\n}}", {
        i(1, "name"), i(2), i(3, "void"), i(0),
    })),
    s({ trig = "test", dscr = "Teste unitário" }, fmt('test "{}" {{\n    {}\n}}', {
        i(1, "description"), i(0, "try std.testing.expect(true);"),
    })),
    s({ trig = "struct", dscr = "Struct" }, fmt("const {} = struct {{\n    {}\n}};", { i(1, "Name"), i(0) })),
    s({ trig = "enum", dscr = "Enum" }, fmt("const {} = enum {{\n    {},\n}};", { i(1, "Name"), i(0, "value") })),
    s({ trig = "for", dscr = "Iterar uma coleção" }, fmt("for ({}) |{}| {{\n    {}\n}}", {
        i(1, "items"), i(2, "item"), i(0),
    })),
    s({ trig = "fori", dscr = "Iterar com índice" }, fmt("for ({}, 0..) |{}, {}| {{\n    {}\n}}", {
        i(1, "items"), i(2, "item"), i(3, "index"), i(0),
    })),
    s({ trig = "ifopt", dscr = "Capturar valor opcional" }, fmt("if ({}) |{}| {{\n    {}\n}}", {
        i(1, "optional"), i(2, "value"), i(0),
    })),
    s({ trig = "defer", dscr = "Executar ao sair do escopo" }, fmt("defer {};", { i(1, "resource.deinit()") })),
    s({ trig = "errdefer", dscr = "Executar ao retornar erro" }, fmt("errdefer {};", { i(1, "resource.deinit()") })),
    s({ trig = "alloc", dscr = "Alocar e liberar uma fatia" }, fmt("const {} = try {}.alloc({}, {});\ndefer {}.free({});", {
        i(1, "buffer"), i(2, "allocator"), i(3, "u8"), i(4, "len"), rep(2), rep(1),
    })),
}
