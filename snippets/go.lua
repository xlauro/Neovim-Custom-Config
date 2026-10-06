local ls = require("luasnip")
local s, i = ls.snippet, ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- Ponto de entrada padrão
    s({ trig = "main", dscr = "Pacote main e função main()" }, fmt([[
package main

func main() {{
	{}
}}
]], { i(0) })),

    -- Tratamento padrão de erro
    s({ trig = "err", dscr = "Verificação padrão de erro (if err != nil)" }, fmt([[
if err != nil {{
	return {}
}}
]], { i(1, "err") })),

    -- Tratamento de erro com wrapping (fmt.Errorf)
    s({ trig = "ferr", dscr = "Tratamento de erro com fmt.Errorf wrapping" }, fmt([[
if err != nil {{
	return fmt.Errorf("{}: %w", err)
}}
]], { i(1, "failed to execute") })),

    -- Declaração de função padrão
    s({ trig = "fn", dscr = "Declaração de função padrão" }, fmt([[
func {}({}) {} {{
	{}
}}
]], { i(1, "name"), i(2), i(3), i(0) })),

    -- Método em struct (receiver com ponteiro ou valor)
    s({ trig = "meth", dscr = "Método associado a struct receiver" }, fmt([[
func ({} *{}) {}({}) {} {{
	{}
}}
]], { i(1, "s"), i(2, "Struct"), i(3, "Method"), i(4), i(5), i(0) })),

    -- Definição de struct
    s({ trig = "st", dscr = "Definição de struct" }, fmt([[
type {} struct {{
	{}
}}
]], { i(1, "Name"), i(0) })),

    -- Definição de interface
    s({ trig = "iface", dscr = "Definição de interface" }, fmt([[
type {} interface {{
	{}
}}
]], { i(1, "Name"), i(0) })),

    -- Teste unitário simples
    s({ trig = "test", dscr = "Função de teste unitário TestXxx(t *testing.T)" }, fmt([[
func Test{}(t *testing.T) {{
	{}
}}
]], { i(1, "Name"), i(0) })),

    -- Teste orientado a tabelas (table-driven test)
    s({ trig = "table", dscr = "Template de teste orientado a tabelas com t.Run" }, fmt([[
func Test{}(t *testing.T) {{
	tests := []struct {{
		name string
		{}
	}}{{
		{{
			name: "{}",
			{},
		}},
	}}

	for _, tt := range tests {{
		t.Run(tt.name, func(t *testing.T) {{
			{}
		}})
	}}
}}
]], {
        i(1, "Name"),
        i(2, "// campos"),
        i(3, "caso inicial"),
        i(4, "// valores"),
        i(0),
    })),

    -- Função de benchmark
    s({ trig = "bench", dscr = "Função de benchmark BenchmarkXxx(b *testing.B)" }, fmt([[
func Benchmark{}(b *testing.B) {{
	for i := 0; i < b.N; i++ {{
		{}
	}}
}}
]], { i(1, "Name"), i(0) })),

    -- Definição de tipo / Type alias
    s({ trig = "type", dscr = "Definição de tipo / Type alias" }, fmt([[
type {} {}
]], { i(1, "Name"), i(2, "string") })),

    -- Função de inicialização do pacote init()
    s({ trig = "init", dscr = "Função de inicialização do pacote init()" }, fmt([[
func init() {{
	{}
}}
]], { i(0) })),

    -- Parâmetro context.Context
    s({ trig = "ctx", dscr = "Parâmetro context.Context" }, fmt("ctx context.Context{}", { i(0) })),

    -- Goroutine anônima
    s({ trig = "go", dscr = "Goroutine com função anônima" }, fmt([[
go func() {{
	{}
}}()
]], { i(0) })),

    -- Handler HTTP (net/http)
    s({ trig = "handler", dscr = "Handler HTTP func(w http.ResponseWriter, r *http.Request)" }, fmt([[
func {}(w http.ResponseWriter, r *http.Request) {{
	{}
}}
]], { i(1, "handler"), i(0) })),

    -- Middleware HTTP
    s({ trig = "mw", dscr = "Middleware HTTP func(next http.Handler) http.Handler" }, fmt([[
func {}(next http.Handler) http.Handler {{
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {{
		{}
		next.ServeHTTP(w, r)
	}})
}}
]], { i(1, "Middleware"), i(0) })),
}
