local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

local function snip(trig, desc, body, nodes)
  return s({ trig = trig, desc = desc }, fmta(body, nodes))
end

return {
  s({ trig = "np", desc = "import numpy as np" }, t("import numpy as np")),
  s({ trig = "pd", desc = "import pandas as pd" }, t("import pandas as pd")),
  s({ trig = "plt", desc = "import matplotlib.pyplot as plt" }, t("import matplotlib.pyplot as plt")),
  s({ trig = "imp", desc = "numpy, pandas, matplotlib" }, t({
    "import numpy as np",
    "import pandas as pd",
    "import matplotlib.pyplot as plt",
  })),

  snip("csv", "read a CSV into a DataFrame", 'df = pd.read_csv("<>")', { i(1) }),

  snip("plot", "matplotlib figure", [[
plt.figure(figsize=(<>, <>))
plt.plot(<>, <>, label="<>")
plt.xlabel("<>")
plt.ylabel("<>")
plt.title("<>")
plt.legend()
plt.grid(True)
plt.show()]], { i(1, "8"), i(2, "5"), i(3, "x"), i(4, "y"), i(5), i(6), i(7), i(8) }),

  snip("test", "pytest test function", "def test_<>():\n\t<>", { i(1, "name"), i(0) }),
  snip("approx", "assert with tolerance", "assert <> == pytest.approx(<><>)",
    { i(1), i(2), i(3, ", rel=1e-6") }),
  snip("raises", "expect an exception", "with pytest.raises(<>):\n\t<>",
    { i(1, "ValueError"), i(0) }),

  snip("cp", "competitive programming template", [[
import sys
input = sys.stdin.readline


def main():
	<>


main()]], { i(0) }),
  snip("ri", "read one int", "<> = int(input())", { i(1, "n") }),
  snip("rl", "read a list of ints", "<> = list(map(int, input().split()))", { i(1, "a") }),
  snip("rm", "read several ints", "<> = map(int, input().split())", { i(1, "n, m") }),
}