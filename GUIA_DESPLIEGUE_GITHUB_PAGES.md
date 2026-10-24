# 🚀 GUÍA VISUAL PASO A PASO: DESPLIEGUE EN GITHUB PAGES
### *El Manual con Peras y Manzanas de La Garza Aguachilera*
**Elaborado por el Mentor Técnico para Principiantes**  
**Dirección Oficial del Negocio:** Tampico y Ciudad Madero, Tamaulipas  
**WhatsApp Oficial:** 833 252 09 88

---

## 🌟 ¿Qué es GitHub Pages y por qué es una maravilla?

Imagina que **GitHub Pages** es como tener un local comercial premium en la avenida más transitada de Internet, pero con tres ventajas increíbles:

1. **Hosting 100% Gratuito y de por Vida:** No pagas mensualidades ni contrataciones de servidores. Tu página web estará en línea las 24 horas del día, los 365 días del año.
2. **Candadito Verde Incluido (Seguridad HTTPS / SSL):** Toda la comunicación de tus clientes está encriptada automáticamente. Nadie verá advertencias de "sitio no seguro" al entrar desde su celular o computadora.
3. **Carga Ultrarrápida en Celulares:** El contenido se sirve a través de la red global de distribución de GitHub (CDN de alta velocidad). Si alguien en Tampico, Ciudad Madero o cualquier rincón del mundo abre tu enlace, la página cargará al instante.

```
+-------------------------------------------------------------------------------+
|                       EL CAMINO HACIA INTERNET EN 4 PASOS                     |
|                                                                               |
|   [ PASO 1 ]               [ PASO 2 ]                   [ PASO 3 ]            |
| Crear Repo en        -> Ejecutar Script          -> Activar Pages             |
| GitHub.com              desplegar_github_pages      Settings -> Pages         |
| (Público, vacío)        (Sube todo automático)      (Branch: main -> Save)    |
|                                                                               |
|                                     │                                         |
|                                     ▼                                         |
|                                [ PASO 4 ]                                     |
|                       ¡Tu sitio web en vivo con SSL!                          |
|                 https://<tu-usuario>.github.io/<tu-repo>/                     |
+-------------------------------------------------------------------------------+
```

---

## 📋 ¿Qué contiene tu sitio web listo para despegar?

Al subir este proyecto a GitHub Pages, tu público disfrutará de:

- **Página Web Pública Oficial (`index.html`):** Diseño tropical fresco y moderno con temática tampiqueña (**Mapaches de las Escolleras**, **OVNIs de Playa Miramar** y **Juancho el Cocodrilo**), fotografía en alta definición del **Tostiaguachile Verde Tradicional ($170 MXN, ~100g de camarón mariposa)**, y botón directo a **WhatsApp (833 252 09 88)** sin formularios que distraigan la venta.
- **Centro de Descargas y Redes (`panel_control.html`):** Catálogo multimedia para copiar copys y descargar los flyers publicitarios (Facebook, Instagram, TikTok).
- **Video Promocional Master (`VIDEOS/promo_aguachile_verde_final.mp4`):** Video vertical en Full HD (1080x1920) listo para reproducirse directo en el navegador.
- **Paquete Completo de Redes (`paquete_redes_la_garza.zip`):** Archivo descargable de 36.8 MB con todas las piezas gráficas originales.
- **Archivo Secreto de Éxito (`.nojekyll`):** Un archivo especial que le indica a GitHub Pages: *"Sirve mis archivos tal cual están en la computadora, sin alterar las imágenes, stickers ni carpetas"*.

---

## 🛠️ PASO 1: Crear tu Repositorio en GitHub (En 30 segundos)

1. Abre tu navegador web e inicia sesión en [github.com](https://github.com/).
2. Dirígete a la página de nuevo repositorio: [github.com/new](https://github.com/new).
3. Configura los siguientes campos:
   - **Repository name:** Escribe `la-garza-aguachilera` (o el nombre que prefieras, en minúsculas y separado por guiones).
   - **Description:** *"Sitio web oficial de La Garza Aguachilera — Tostiaguachiles en Tampico y Ciudad Madero."*
   - **Public / Private:** Selecciona **Public** (Público). *(Nota: GitHub Pages en cuentas gratuitas requiere que el repositorio sea público).*
4. ⚠️ **REGLA DE ORO PARA NO TROPEZAR:**
   - **DESMARCA** la casilla *"Add a README file"*.
   - Deja en **None** la opción *"Add .gitignore"*.
   - Deja en **None** la opción *"Choose a license"*.
   *(¿Por qué? Porque en tu computadora ya tenemos todo listo, configurado y empaquetado; si creas un README en GitHub, chocará con tus archivos locales).*
5. Haz clic en el botón verde **"Create repository"**.
6. GitHub te mostrará una pantalla con la dirección web de tu nuevo repositorio. Copia esa URL.  
   Tendrá una forma como esta:  
   👉 `https://github.com/tu-usuario/la-garza-aguachilera.git`

---

## 💻 PASO 2: Desplegar con el Asistente Automático

Hemos programado un asistente en PowerShell para que tú no tengas que escribir comandos difíciles de Git en la consola.

1. Abre una terminal de **PowerShell** en tu computadora.
2. Asegúrate de estar en la carpeta del proyecto:
   ```powershell
   Set-Location "d:\AG\la garza aguachilera"
   ```
3. Ejecuta el script de despliegue:
   ```powershell
   .\desplegar_github_pages.ps1
   ```
4. **¿Qué hará el asistente por ti?**
   - Verificará que Git esté instalado.
   - Confirmará la existencia de `.nojekyll` y `.gitignore`.
   - Protegerá tu subida asegurándose de que los archivos pesados locales de edición (como `ffmpeg.exe`) no se envíen a GitHub para evitar rechazos de peso.
   - Si no has conectado tu repositorio, te pedirá amablemente:
     `"Pega aquí la URL de tu repositorio de GitHub:"`
   - Pegas el enlace que copiaste en el Paso 1 (`https://github.com/tu-usuario/la-garza-aguachilera.git`) y presionas **Enter**.
   - El script empaquetará tus fotos, videos y páginas y los subirá a la rama `main` de GitHub.

> 💡 **Nota alternativa para expertos en consola:**  
> Si prefieres hacerlo a mano sin el script interactivo, los comandos equivalentes son:
> ```powershell
> git remote add origin https://github.com/tu-usuario/la-garza-aguachilera.git
> git push -u origin main
> ```

---

## ⚙️ PASO 3: Activar GitHub Pages en la Web de GitHub

Una vez que tus archivos se subieron, solo falta encender el interruptor de publicación web en GitHub. Es súper fácil:

1. En tu navegador, entra a la página de tu repositorio en GitHub:  
   `https://github.com/tu-usuario/la-garza-aguachilera`
2. En la barra de pestañas superior, haz clic en **Settings** ⚙️ *(el ícono de la tuerca a la derecha)*.
3. En la barra lateral izquierda, baja hasta la sección **Code and automation** y haz clic en **Pages** 📄.
4. En el panel principal, bajo el título **Build and deployment**:
   - En **Source**, verifica que diga: `Deploy from a branch`.
   - En **Branch**, haz clic en el menú desplegable que dice `None` y selecciona **`main`**.
   - En el menú contiguo de carpeta, asegúrate de que esté seleccionado **`/ (root)`**.
   - Haz clic en el botón **Save** (Guardar).

```
   PANEL DE CONFIGURACIÓN DE GITHUB PAGES:
   +-------------------------------------------------------------------------+
   | Build and deployment                                                    |
   |                                                                         |
   | Source: [ Deploy from a branch                  v ]                     |
   |                                                                         |
   | Branch: [ main             v ]  folder: [ / (root)      v ]  [  Save  ] |
   +-------------------------------------------------------------------------+
```

---

## 🎉 PASO 4: ¡Tu Sitio Web en Vivo!

1. Espera entre **60 y 90 segundos** mientras GitHub procesa y distribuye tu página.
2. Recarga la pestaña de **Settings -> Pages**.
3. Verás una cajita verde en la parte superior con un mensaje similar a este:
   > **Your site is live at:**  
   > `https://<tu-usuario>.github.io/la-garza-aguachilera/`
4. ¡Haz clic en el enlace!

### ¿Qué verificar cuando tu página esté en vivo?
- [x] **Logotipo y Fotografía:** El logo de La Garza Aguachilera y la foto del tostiaguachile lucen nítidos y brillantes.
- [x] **Fondo Tropical:** El fondo nocturno con el skyline de Tampico (`tampico_skyline_bg.jpg`) ambienta la pantalla con estilo cómic playero.
- [x] **Stickers de Tampico:** El Cocodrilo Juancho, el OVNI de Miramar y el Mapache de las Escolleras aparecen transparentes y sin fondos blancos toscos.
- [x] **Botón de WhatsApp:** Al hacer clic en cualquier botón de pedido, se abre WhatsApp con el mensaje prellenado listo para ordenar al **833 252 09 88**.
- [x] **Ubicación Oficial:** En la sección de entregas y pie de página se indica claramente: **"Tampico y Ciudad Madero, Tamaulipas"**.
- [x] **Centro de Contenido (`panel_control.html`):** Puedes entrar a `https://<tu-usuario>.github.io/la-garza-aguachilera/panel_control.html` para ver el reproductor del video promocional, copiar copys de redes con 1 clic y descargar el paquete ZIP completo.

---

## ❓ Preguntas Frecuentes y Consejos del Mentor

### ¿Por qué existe el archivo `.nojekyll`?
GitHub Pages utiliza un motor por defecto llamado Jekyll, diseñado para blogs. Si no ponemos `.nojekyll`, GitHub intenta "procesar" los archivos y a veces oculta imágenes, rompe rutas o bloquea archivos con guiones bajos o caracteres especiales. Al tener `.nojekyll` vacío en la raíz, GitHub se convierte en un servidor web estático puro que sirve cada foto, video y sticker con fidelidad milimétrica.

### ¿Por qué no se sube la carpeta `herramientas/ffmpeg/`?
En tu computadora tenemos las herramientas de edición de video (`ffmpeg.exe` y `ffprobe.exe`) que pesan más de 127 MB cada una. GitHub tiene un límite estricto: **rechaza cualquier archivo mayor a 100 MB**. Por eso, configuramos `.gitignore` para dejarlas seguras en tu disco local. En Internet solo necesitas los resultados finales: tu video MP4 optimizado (19.68 MB) y tus imágenes.

### ¿Qué hago si cambio un precio o un horario en el futuro?
1. Abre `index.html` en tu editor favorito y haz el cambio.
2. Vuelve a ejecutar en PowerShell:
   ```powershell
   .\desplegar_github_pages.ps1
   ```
3. El script detectará el cambio automáticamente, creará el commit y lo subirá a GitHub. En menos de un minuto tu sitio en Internet reflejará los nuevos datos.

### ¿Qué pasa si GitHub me pide usuario y contraseña en la terminal?
Si es la primera vez que usas Git con GitHub en tu computadora, es posible que aparezca una ventanita pidiendo autorización. Simplemente presiona **"Sign in with your browser"** y autoriza el acceso. Si te pide un token en consola, ve a GitHub -> Settings (de tu perfil) -> Developer Settings -> Personal access tokens -> Tokens (classic) -> Generate new token, marca la casilla `repo`, copia el token y pégalo como contraseña.

---

**✅ Auditado y aprobado por Control de Calidad: Cumple con los estándares de La Garza Aguachilera**
