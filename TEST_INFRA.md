# E2E Test Infra: La Garza Aguachilera — Campaña Aguacate & Salsas Especiales

## Test Philosophy
- Requirement-driven, opaque-box and forensic verification.
- Validates brand shield ($170 MXN strictly, Colonia Flores, 0 forbidden words).
- Validates new gastronomy attributes (aguacate fresco cremoso en toda porción, baño de salsas de la casa en bolsa).
- Validates visual presentation, 4 complements, 2 modalities, ZIP integrity (< 100 MB), and GitHub Pages live response (200 OK).

## Feature Inventory & Test Matrix
| # | Feature | Source | Tier 1 (Unit/Presence) | Tier 2 (Boundary/Integrity) | Tier 3 (Cross-Feature) | Tier 4 (E2E/Deploy) |
|---|---------|--------|:----------------------:|:---------------------------:|:----------------------:|:-------------------:|
| 1 | Aguacate Fresco en Toda Porción | ORIGINAL_REQUEST R1 | Regex in `index.html` & copies | Case-insensitive & formatting | Sabor Jaibo 4-pillar balance | Web presentation & QA script |
| 2 | Baño de Salsas de la Casa en Bolsa | ORIGINAL_REQUEST R1 | Regex in `index.html` & copies | Exact phrase matching | Ensamble en bolsa interaction | Web presentation & QA script |
| 3 | Precio Único $170 MXN | ORIGINAL_REQUEST R1, R4 | >=5 in index, >=20 in panel | 0 mentions of $150 / other | Combos scale ($340 duo) | Brand shield in QA suites |
| 4 | Ubicación Colonia Flores | ORIGINAL_REQUEST R4 | Literal check in footer/hero | 0 mentions of Rosa 210 | Delivery zone validation | Brand shield in QA suites |
| 5 | Cero Palabras Prohibidas | ORIGINAL_REQUEST R1, R4 | Global scan for 13 patterns | No unencoded literals in tools | Content & metadata clean | Exit code 0 in audit scripts |
| 6 | 4 Complementos & 2 Modalidades | ORIGINAL_REQUEST R1, R2 | Selectors and text check | Default active choices | WhatsApp URL generation | Interactive selector testing |
| 7 | Los 4 Pilares del Sabor Jaibo | ORIGINAL_REQUEST R2 | 4 cards in `index.html` | Grid syntax (no extra </div>) | Responsive cols (1, 2, 4) | Visual audit |
| 8 | Paquete Redes ZIP (< 100 MB) | ORIGINAL_REQUEST R3 | File existence | Size >= 20 MB & < 100 MB | Internal folder structure | Deployment packaging check |
| 9 | Publicación GitHub Pages | ORIGINAL_REQUEST R4 | Git status clean & pushed | `.nojekyll` present | Remote origin/main | Live HTTP 200 OK |

## Test Runners
- `py herramientas/ejecutar_empresa_qa.py` (Exit code 0, 0 deficiencies)
- `powershell -ExecutionPolicy Bypass -File herramientas/auditar_multimedia_qa.ps1` (Exit code 0, 0 inconformidades)
- Live check: `(Invoke-WebRequest -Uri 'https://lagarzaaguachilera.github.io/' -Method Head).StatusCode == 200`
