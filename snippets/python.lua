local ls = require("luasnip")
local s, i = ls.snippet, ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- Ponto de entrada padrão (__name__ == '__main__')
    s({ trig = "main", dscr = "Bloco padrão if __name__ == '__main__':" }, fmt([[
def main() -> None:
    {}


if __name__ == "__main__":
    main()
]], { i(0, "pass") })),

    -- Definição de função tipada
    s({ trig = "fn", dscr = "Definição de função com tipagem PEP 484" }, fmt([[
def {}({}) -> {}:
    {}
]], { i(1, "function_name"), i(2), i(3, "None"), i(0, "pass") })),

    -- Definição de classe padrão
    s({ trig = "cl", dscr = "Definição de classe com __init__" }, fmt([[
class {}:
    def __init__(self{}) -> None:
        {}
]], { i(1, "ClassName"), i(2), i(0, "pass") })),

    -- Dataclass
    s({ trig = "dc", dscr = "Dataclass do Python 3.7+" }, fmt([[
from dataclasses import dataclass


@dataclass
class {}:
    {}
]], { i(1, "ClassName"), i(0, "pass") })),

    -- Tratamento de exceção try/except
    s({ trig = "try", dscr = "Bloco try / except" }, fmt([[
try:
    {}
except {} as e:
    {}
]], { i(1, "pass"), i(2, "Exception"), i(0, "raise") })),

    -- Teste pytest
    s({ trig = "test", dscr = "Função de teste pytest" }, fmt([[
def test_{}() -> None:
    {}
]], { i(1, "something"), i(0, "pass") })),

    -- Fixture pytest
    s({ trig = "fix", dscr = "Fixture do pytest" }, fmt([[
import pytest


@pytest.fixture
def {}():
    {}
]], { i(1, "my_fixture"), i(0, "pass") })),
}
