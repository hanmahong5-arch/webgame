# Data Directory Index

This directory contains centralized data files for the lurus-www website.
Edit these files to update website content without modifying component code.

## Files

| File | Purpose | Used By |
|------|---------|---------|
| `navItems.ts` | Navigation menu items and CTA links | `TopBar.vue` |
| `products.ts` | Product information (7 products), icons, colors, URLs | `Home.vue`, audience pages |
| `stats.ts` | Statistics and trust badges | `Home.vue` |
| `externalRoutes.ts` | External URL redirect mappings | `main.ts` |
| `chatModels.ts` | AI models and quick prompts | `useAIChat.ts` |
| `apiHealth.ts` | API health check config | `useApiHealth.ts` |
| `pageSidebarConfig.ts` | Per-page sidebar TOC, products, links, CTAs | `PageSidebar.vue` |
| `downloadableProducts.ts` | Downloadable product definitions | `Download.vue`, `Releases.vue` |
| `about.ts` | About page data (values, advantages, timeline) | `About.vue` subcomponents |
| `team.ts` | Team member data | `TeamSection.vue` |
| `partners.ts` | Partner logos and links | `Home.vue` |

## Architecture Decision

This data centralization follows ADR-006 and ADR-007:
- All configurable content in `src/data/`
- TypeScript interfaces for type safety
- `as const satisfies` pattern for readonly arrays
