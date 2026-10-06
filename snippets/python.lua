local ls = require("luasnip")
local s, i = ls.snippet, ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- Ponto de entrada padrão
    s({ trig = "main", dscr = "Bloco if __name__ == '__main__':" }, fmt(
        'def main() -> None:\n    {}\n\n\nif __name__ == "__main__":\n    main()\n',
        { i(0, "pass") }
    )),

    -- FastAPI: Inicialização de aplicação
    s({ trig = "fapp", dscr = "Instância padrão de FastAPI" }, fmt(
        'from fastapi import FastAPI\n\napp = FastAPI(\n    title="{}",\n    version="{}",\n)\n\n@app.get("/")\nasync def root():\n    return {{"message": "Hello World"}}\n',
        { i(1, "API"), i(2, "0.1.0") }
    )),

    -- FastAPI: Rota GET
    s({ trig = "get", dscr = "Endpoint GET FastAPI" }, fmt(
        '@app.get("{}")\nasync def {}({}) -> {}:\n    {}\n',
        { i(1, "/"), i(2, "get_item"), i(3), i(4, "dict"), i(0, 'return {"status": "ok"}') }
    )),

    -- FastAPI: Rota POST
    s({ trig = "post", dscr = "Endpoint POST FastAPI com schema Pydantic" }, fmt(
        '@app.post("{}", status_code=201)\nasync def {}(payload: {}) -> {}:\n    {}\n',
        { i(1, "/"), i(2, "create_item"), i(3, "ItemSchema"), i(4, "dict"), i(0, "return payload.model_dump()") }
    )),

    -- Pydantic: BaseModel
    s({ trig = "model", dscr = "Modelo Pydantic BaseModel" }, fmt(
        'from pydantic import BaseModel\n\nclass {}(BaseModel):\n    {}: {}\n',
        { i(1, "Item"), i(2, "id"), i(0, "int") }
    )),

    -- Dataclass
    s({ trig = "dc", dscr = "Python Dataclass" }, fmt(
        'from dataclasses import dataclass\n\n@dataclass\nclass {}:\n    {}: {}\n',
        { i(1, "Item"), i(2, "id"), i(0, "int") }
    )),

    -- Pytest: Teste síncrono
    s({ trig = "test", dscr = "Função de teste pytest" }, fmt(
        'def test_{}() -> None:\n    {}\n',
        { i(1, "should_succeed"), i(0, "assert True") }
    )),

    -- Pytest: Teste assíncrono
    s({ trig = "atest", dscr = "Função de teste assíncrono com pytest" }, fmt(
        'import pytest\n\n@pytest.mark.anyio\nasync def test_{}() -> None:\n    {}\n',
        { i(1, "should_succeed"), i(0, "assert True") }
    )),

    -- Pytest: Fixture
    s({ trig = "fixture", dscr = "Fixture do Pytest" }, fmt(
        'import pytest\n\n@pytest.fixture\ndef {}():\n    {}\n',
        { i(1, "sample_data"), i(0, "return {}") }
    )),
}
