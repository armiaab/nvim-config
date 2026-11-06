local ls = require("luasnip")
local s, i = ls.snippet, ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local function snip(trig, desc, body, nodes)
  return s({ trig = trig, desc = desc }, fmta(body, nodes))
end

return {
  snip("cp", "template: bits/stdc++, fast I/O", [[
#include <<bits/stdc++.h>>

using namespace std;

int main() {
	ios_base::sync_with_stdio(0);
	cin.tie(0); cout.tie(0);
	<>
	return 0;
}]], { i(0) }),

  snip("cpt", "template with T test cases", [[
#include <<bits/stdc++.h>>

using namespace std;

void solve() {
	<>
}

int main() {
	ios_base::sync_with_stdio(0);
	cin.tie(0); cout.tie(0);
	int t; cin >> t;
	while (t--) solve();
	return 0;
}]], { i(0) }),

  snip("fori", "for i in [0, n)", "for (int <> = 0; <> << <>; <>++) {\n\t<>\n}",
    { i(1, "i"), rep(1), i(2, "n"), rep(1), i(0) }),
  snip("ford", "for i from n-1 down to 0", "for (int <> = <> - 1; <> >>= 0; <>--) {\n\t<>\n}",
    { i(1, "i"), i(2, "n"), rep(1), rep(1), i(0) }),

  snip("rd", "read one value", "<> <>; cin >>>> <>;", { i(1, "int"), i(2, "n"), rep(2) }),
  snip("rdv", "read a vector of n values",
    "vector<<<>>> <>(<>);\nfor (auto &x : <>) cin >>>> x;",
    { i(1, "int"), i(2, "a"), i(3, "n"), rep(2) }),

  snip("all", "a.begin(), a.end()", "<>.begin(), <>.end()", { i(1, "a"), rep(1) }),
  snip("rall", "a.rbegin(), a.rend()", "<>.rbegin(), <>.rend()", { i(1, "a"), rep(1) }),

  snip("pr", "print with newline", "cout <<<< <> <<<< '\\n';", { i(1) }),
  snip("yn", "YES / NO", "cout <<<< (<> ? \"YES\" : \"NO\") <<<< '\\n';", { i(1, "ok") }),

  snip("ll", "short type names", [[
using ll = long long;
using vi = vector<<int>>;
using vll = vector<<ll>>;
using pii = pair<<int, int>>;]], {}),
  snip("mod", "const MOD", "const int MOD = <>;", { i(1, "1e9 + 7") }),

  snip("bs", "binary search on the answer", [[
<> lo = <>, hi = <>;
while (lo << hi) {
	<> mid = lo + (hi - lo) / 2;
	if (<>) hi = mid;
	else lo = mid + 1;
}]], { i(1, "long long"), i(2, "0"), i(3, "1e18"), rep(1), i(4, "ok(mid)") }),

  snip("dbg", "print a variable to stderr", "cerr <<<< \"<> = \" <<<< <> <<<< '\\n';",
    { i(1, "x"), rep(1) }),
}