# Project: La Garza Aguachilera — Campaña Aguacate & Salsas Especiales

## Architecture
- **Web Storefront & Public App**: `index.html` (Tailwind CSS, Plus Jakarta Sans, interactive selector for WhatsApp, video player, Hero with badges and "Los 4 Pilares del Sabor Jaibo").
- **Asset & Marketing Panel**: `panel_control.html` (43 media cards, filtered by platform/category, 1-click copy captions, product specification).
- **Gastronomic & Social Guides**: `contenido_redes/` (Product guide `05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md`, WhatsApp kit, monthly catalog, viral hooks).
- **Packaging & Delivery Automation**: `herramientas/empaquetar_redes_zip.ps1` -> `paquete_redes_la_garza.zip` (< 100 MB).
- **QA Forensic & Brand Shield Suites**: `herramientas/ejecutar_empresa_qa.py` and `herramientas/auditar_multimedia_qa.ps1`.
- **Public CDN & Hosting**: GitHub Pages at `https://lagarzaaguachilera.github.io/` on branch `main` with `.nojekyll`.

## Code Layout
- `index.html` — Public single-page storefront
- `panel_control.html` — Internal marketing and media dashboard
- `contenido_redes/` — Official copies, product guides, and campaign scripts
- `herramientas/` — Automation, packaging, and QA scripts
- `paquete_redes_la_garza.zip` — Compressed assets bundle for social media distributors (< 100 MB)
- `control_calidad/` — Enterprise QA audit reports and compliance logs

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Aguacate Fresco en Toda Porción (Copy & Guide) | Inclusión garantizada de aguacate fresco y cremoso en cada orden documentado en guías oficiales | M1 | ORIGINAL_REQUEST R1, R3 |
| 2 | Baño Especial de Salsas de la Casa en Bolsa (Copy & Guide) | Documentar el baño de salsas sobre las chips al momento del ensamble en bolsa | M1 | ORIGINAL_REQUEST R1, R3 |
| 3 | Hooks Persuasivos Clase Media/Media-Alta | Ganchos sensoriales sin tecnicismos operativos en guías y copies | M1 | ORIGINAL_REQUEST R1 |
| 4 | Ratificación 4 Complementos & 2 Modalidades | Tostitos Verde, Flamin' Hot, Totopos, Galletas; En ruta en vivo vs Por separado | M1, M2 | ORIGINAL_REQUEST R1, R2 |
| 5 | Insignias Visuales Aguacate y Salsas en Hero | Badges visuales en el hero de `index.html` para aguacate cremoso y baño de salsas | M2 | ORIGINAL_REQUEST R2 |
| 6 | Los 4 Pilares del Sabor Jaibo en `index.html` | Evolución de Trilogía a 4 Pilares (Camarón, Limón/Serrano, Aguacate, Salsa de la Casa) y fix de grid | M2 | ORIGINAL_REQUEST R2 |
| 7 | Actualización de `panel_control.html` | Ficha técnica de producto, badges, captions de venta y corrección de función copyCaption | M2 | ORIGINAL_REQUEST R2 |
| 8 | Regeneración de `paquete_redes_la_garza.zip` | Actualizar `LEEME_PAQUETE_REDES.txt` y empaquetar con `empaquetar_redes_zip.ps1` (< 100 MB) | M3 | ORIGINAL_REQUEST R3 |
| 9 | Actualización de Scripts QA | Integrar assertions de aguacate y salsas de la casa en `ejecutar_empresa_qa.py` y `auditar_multimedia_qa.ps1` | M4 | ORIGINAL_REQUEST R4 |
| 10 | Corrección de Falso Positivo en `auditar_multimedia_qa.ps1` | Excluir `control_calidad/` y `empresa_control_calidad_qa.ps1` del escáner de palabras prohibidas | M4 | ORIGINAL_REQUEST R4 |
| 11 | Validación E2E QA con Salida 0 | Ambos scripts finalizan con código de salida 0 (0 inconformidades) | M4 | ORIGINAL_REQUEST R4 |
| 12 | Despliegue y Verificación en GitHub Pages | Git push a `origin/main` y verificación HTTP 200 OK en `https://lagarzaaguachilera.github.io/` | M4 | ORIGINAL_REQUEST R4 |
| 13 | Sello Oficial de Control de Calidad | Incorporar y validar el sello oficial de auditoría en los reportes finales | M4 | ORIGINAL_REQUEST R4 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Marketing Gastronómico & Contenido | `contenido_redes/05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md`, copys y hooks de WhatsApp | none | DONE |
| M2 | Diseño Gráfico & Arte Web | `index.html` (Hero, badges, 4 Pilares, selector) y `panel_control.html` (badges, captions, JS fix) | M1 | DONE |
| M3 | Empaque de Redes & ZIP | `herramientas/empaquetar_redes_zip.ps1`, regeneración de `paquete_redes_la_garza.zip` (< 100 MB) | M1, M2 | DONE |
| M4 | QA Enterprise, Auditoría & Deploy | `herramientas/ejecutar_empresa_qa.py`, `herramientas/auditar_multimedia_qa.ps1`, git push y 200 OK | M1, M2, M3 | DONE |

## Interface Contracts
### M1 ↔ M2 (Marketing & Copy to Web Design)
- Official phrasing: `"Toda porción incluye aguacate fresco y cremoso"`, `"En preparación en bolsa las chips se bañan con una combinación especial y rica de salsas de la casa"`.
- 4 Complements: `"Tostitos Salsa Verde"`, `"Tostitos Flamin' Hot"`, `"Chips o Totopos Artesanales"`, `"Galletas Saladas"`.
- 2 Modalities: `"Preparado al momento frente a ti"`, `"Con complemento por separado"`.
- Price: Strictly `$150 MXN`.
- Location: `"Colonia Flores, Tampico, Tamaulipas"`.

### M2 ↔ M3 (Web Design to Packaging)
- Updated `05_GUIA_PRODUCTO_COMPLEMENTOS_Y_SERVIDO.md` must be included in root of ZIP.
- `LEEME_PAQUETE_REDES.txt` generated with updated copy and new gastronomy attributes.

### M3 ↔ M4 (Packaging to QA & Deployment)
- `paquete_redes_la_garza.zip` must exist, size must be `>= 20 MB` and `< 100 MB`.
- Git status must be clean before final push to `origin/main`.
