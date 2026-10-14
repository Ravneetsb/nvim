# Superscript and subscript reference

Complete reference for the character mappings in this Neovim configuration’s `bin/markdown-math` renderer. This lists every supported mapping, not every phonetic or modifier character in Unicode. A dash (—) means no compact mapping is configured; the renderer preserves readable `^{...}` or `_{...}` notation.

Write ordinary LaTeX inside math delimiters, such as `$x_{ij}^{2}$` → xᵢⱼ². The glyphs below are literal Unicode characters, so you can also copy them directly. Your terminal font must contain the glyphs; newer characters such as 𐞥, ꟲ, ꟳ, and ꟴ may require font fallback.

## Digits

| Input | Superscript | Subscript |
|---|---|---|
| `0` | ⁰ | ₀ |
| `1` | ¹ | ₁ |
| `2` | ² | ₂ |
| `3` | ³ | ₃ |
| `4` | ⁴ | ₄ |
| `5` | ⁵ | ₅ |
| `6` | ⁶ | ₆ |
| `7` | ⁷ | ₇ |
| `8` | ⁸ | ₈ |
| `9` | ⁹ | ₉ |

## Lowercase Latin letters

| Input | Superscript | Subscript |
|---|---|---|
| `a` | ᵃ | ₐ |
| `b` | ᵇ | — |
| `c` | ᶜ | — |
| `d` | ᵈ | — |
| `e` | ᵉ | ₑ |
| `f` | ᶠ | — |
| `g` | ᵍ | — |
| `h` | ʰ | ₕ |
| `i` | ⁱ | ᵢ |
| `j` | ʲ | ⱼ |
| `k` | ᵏ | ₖ |
| `l` | ˡ | ₗ |
| `m` | ᵐ | ₘ |
| `n` | ⁿ | ₙ |
| `o` | ᵒ | ₒ |
| `p` | ᵖ | ₚ |
| `q` | 𐞥 | — |
| `r` | ʳ | ᵣ |
| `s` | ˢ | ₛ |
| `t` | ᵗ | ₜ |
| `u` | ᵘ | ᵤ |
| `v` | ᵛ | ᵥ |
| `w` | ʷ | — |
| `x` | ˣ | ₓ |
| `y` | ʸ | — |
| `z` | ᶻ | — |

## Uppercase Latin letters

| Input | Superscript | Subscript |
|---|---|---|
| `A` | ᴬ | — |
| `B` | ᴮ | — |
| `C` | ꟲ | — |
| `D` | ᴰ | — |
| `E` | ᴱ | — |
| `F` | ꟳ | — |
| `G` | ᴳ | — |
| `H` | ᴴ | — |
| `I` | ᴵ | — |
| `J` | ᴶ | — |
| `K` | ᴷ | — |
| `L` | ᴸ | — |
| `M` | ᴹ | — |
| `N` | ᴺ | — |
| `O` | ᴼ | — |
| `P` | ᴾ | — |
| `Q` | ꟴ | — |
| `R` | ᴿ | — |
| `S` | — | — |
| `T` | ᵀ | — |
| `U` | ᵁ | — |
| `V` | ⱽ | — |
| `W` | ᵂ | — |
| `X` | — | — |
| `Y` | — | — |
| `Z` | — | — |

## Operators and parentheses

| Input | Superscript | Subscript |
|---|---|---|
| `+` | ⁺ | ₊ |
| `-` | ⁻ | ₋ |
| `=` | ⁼ | ₌ |
| `(` | ⁽ | ₍ |
| `)` | ⁾ | ₎ |

## Greek letters

Use the LaTeX command shown, for example `$x_{\beta}^{\theta}$` → xᵦᶿ. Uppercase Greek letters have no configured compact mappings.

| Letter / LaTeX input | Superscript | Subscript |
|---|---|---|
| α / `\alpha` | — | — |
| β / `\beta` | ᵝ | ᵦ |
| γ / `\gamma` | ᵞ | ᵧ |
| δ / `\delta` | ᵟ | — |
| ε / `\epsilon` | — | — |
| ζ / `\zeta` | — | — |
| η / `\eta` | — | — |
| θ / `\theta` | ᶿ | — |
| ι / `\iota` | — | — |
| κ / `\kappa` | — | — |
| λ / `\lambda` | — | — |
| μ / `\mu` | — | — |
| ν / `\nu` | — | — |
| ξ / `\xi` | — | — |
| ο / literal `ο` | — | — |
| π / `\pi` | — | — |
| ρ / `\rho` | — | ᵨ |
| σ / `\sigma` | — | — |
| τ / `\tau` | — | — |
| υ / `\upsilon` | — | — |
| φ / `\phi` | ᵠ | ᵩ |
| χ / `\chi` | ᵡ | ᵪ |
| ψ / `\psi` | — | — |
| ω / `\omega` | — | — |

## Examples

| LaTeX math | Compact display |
|---|---|
| `$x_i^2$` | xᵢ² |
| `$a_{ij}$` | aᵢⱼ |
| `$e^{n+1}$` | eⁿ⁺¹ |
| `$x^{AB}$` | xᴬᴮ |
| `$x_{\beta}$` | xᵦ |
| `$x^{\theta}$` | xᶿ |
| `$x_c$` | x_{c} |
| `$x_{foo}$` | x_{foo} |

Every character in a script must have a mapping for the entire script to convert. For example, `i` and `j` both work in a subscript, but `foo` stays as `_{foo}` because subscript `f` is unavailable.

## Already raised symbols

These work directly after a variable; do not wrap them in `^{...}` with this renderer.

| Meaning | Input | Display |
|---|---|---|
| Prime | `$x\prime$` or `$x′$` | x′ |
| Double prime | `$x″$` | x″ |
| Degree | `$x°$` | x° |

Common operators such as `∞`, `±`, `×`, `≤`, `∑`, and `∂` have no configured compact script mappings. They retain readable notation when used in scripts. PDF export uses LaTeX-rendered images and is not restricted to this character set.
