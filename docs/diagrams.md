# Blog diagrams

Use `/svg-diagram` (skill: `.agents/skills/svg-diagram/SKILL.md`) to create or change post SVGs. Do not hand-write the SVG files in this repo.

## Build

Needs [Bun](https://bun.sh).

```sh
cd ~/code/diagrams
bun install          # first time only
bun run build
```

That writes `{name}-light.svg` and `{name}-dark.svg`.

Default output:

- `~/code/static_sites/posts/images/`
- `~/code/static_sites/priv/static/images/posts/`

Post diagrams that belong under `images/posts/` in this repo must set `outputDirs` in `build.ts`. Coldcard figures already write here:

- `~/code/blog-posts/images/posts/`
- `~/code/static_sites/posts/images/posts/`

## Add a diagram

1. Create `~/code/diagrams/<name>.tsx`.
2. Export a default component that takes `{ theme: "light" | "dark" }`.
3. Use `tw=` for Tailwind. Use flexbox only. Do not use CSS grid.
4. Put labels in `Text` or `Kicker`. Do not put a long string in a raw `<span>` inside a row. `Box` clips overflow. The build fails if anything draws outside the canvas.
5. Register the component in `~/code/diagrams/build.ts`.
6. Run `bun run build`.
7. Embed the pair in the post. Do not edit the generated SVG by hand.

Shared pieces live in `~/code/diagrams/shared/`:

- `Text`, `Kicker`, `Box`, `Row`, and `Shell` — wrap-safe layout
- `getColors(theme)` for Tailwind theme classes
- `hex(theme)` for raw colors
- `Panel`, `Card`, `Pill`, `IconBox`, and heroicons

Use `fontFamily: "Inter"` or `"JetBrains Mono"`. Stick to characters those fonts contain. Symbols such as `⊕` and `≈` become missing glyphs.

Post size for this site is 1500×720.

## Embed in a post

From a year folder such as `2026/`:

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../images/posts/my-diagram-dark.svg">
  <img src="../images/posts/my-diagram-light.svg" alt="Short factual description">
</picture>
```
