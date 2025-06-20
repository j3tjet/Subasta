# Subasta 

Este contrato implementa una subasta en Solidity desplegada en la red de prueba Sepolia.

## ✅ Funcionalidades implementadas

- Subasta con duración configurable.
- Ofertas válidas si superan en al menos 5% la más alta.
- Registro de historial de pujas.
- Eventos: `NuevaOferta`, `SubastaFinalizada`.
- Reembolsos parciales (con 2% de comisión).
- Reembolsos completos de (con 2% de comisión).
- Extensión automática si se oferta en los últimos 10 minutos.
- Protección por modificadores y validaciones de errores.

## 🔐 Contrato en Sepolia
🔗 URL: [https://testnet.routescan.io/address/0xd2614bbc13f6bEE1d3B4C837bC0b1F2B08D8929E/contract/11155111/code](https://testnet.routescan.io/address/0xd2614bbc13f6bEE1d3B4C837bC0b1F2B08D8929E/contract/11155111/code)

## 📄 Documentación del Contrato Inteligente de Subasta

Este contrato implementa una subasta básica con depósito de ofertas, lógica de pujas incrementales, reembolsos (completos y parciales), y control de acceso por parte del beneficiario.

---

### ⚙️ Constructor

#### `constructor(uint duracionMinutos)`

Inicializa la subasta.

- 🧾 **Parámetro:**  
  `duracionMinutos` – Duración total de la subasta expresada en minutos.

- 🔐 **Acceso:** Público (el creador del contrato será el beneficiario).

- ⚙️ **Acción:**  
  Establece el tiempo de finalización (`tiempoFinal`) y al beneficiario.

---

### 💸 Pujar

#### `function puja() external payable`

Permite a un usuario realizar una oferta por el artículo en subasta.

- 📌 **Requisitos:**
  - La subasta debe estar activa (`block.timestamp < tiempoFinal`).
  - La oferta debe superar en al menos **5%** la oferta actual más alta.

- 🔄 **Efectos:**
  - Guarda la oferta anterior como pendiente.
  - Almacena la nueva puja.
  - Extiende la subasta 10 minutos si faltan menos de 10 minutos.

- 📢 **Evento Emitido:** `NuevaOferta(address postor, uint valor)`

---

### 🔁 Retiro Parcial

#### `function retiroParcial() external`

Permite al usuario retirar **una única puja anterior**, descontando una comisión del 2%.

- ⚠️ **Requisitos:** Debe tener al menos una puja anterior registrada.

- 💼 **Acción:**
  - Elimina la última puja del historial del usuario.
  - Resta el monto al total pendiente.
  - Envía el valor menos la comisión.

---

### 💰 Retiro Total

#### `function retirar() external`

Retira el monto **total acumulado** de todas las pujas anteriores del usuario (excepto la más alta).

- 🧾 **Descuento:** Comisión del 2%.

- 🔐 **Acceso:** Público, para usuarios con saldo pendiente.

- 🧹 **Limpieza:**  
  Elimina historial de pujas pendientes y actualiza el total.

---

### 📜 Mostrar Historial

#### `function mostrarHistorialPujas() public view returns (Puja[] memory)`

Devuelve todas las pujas realizadas.

- 🧾 **Retorna:** Lista de estructuras `Puja` con:  
  `address postor`, `uint valor`, `uint tiempo`.

---

### 🥇 Mostrar Ganador

#### `function mostrarGanador() public view returns (address, uint)`

Muestra el ganador y el monto más alto ofertado.

- 🛑 **Requiere:** Que la subasta haya finalizado.

---

### 🛑 Finalizar Subasta

#### `function finalizarSubasta() external soloBeneficiario`

Finaliza la subasta oficialmente.

- 🔐 **Solo:** El beneficiario del contrato.

- 📆 **Efecto:**  
  Define `tiempoParaRetiro` (se activa retiro del beneficiario tras 1 día).

- 📢 **Evento Emitido:** `SubastaFinalizada(address ganador, uint valor)`

---

### 🏦 Retirar Ganancia

#### `function retirarGananciaSubastador() external soloBeneficiario`

Permite al beneficiario retirar la ganancia **después de 1 día** de finalizar la subasta.

- 🧾 **Condiciones:**
  - La subasta debe estar finalizada.
  - Debe haberse cumplido el tiempo de espera.
  - Debe existir al menos una puja válida.

---

### 📢 Eventos

- **`event NuevaOferta(address indexed postor, uint valor)`**  
  Emitido cada vez que se registra una oferta válida.

- **`event SubastaFinalizada(address indexed ganador, uint valor)`**  
  Emitido cuando finaliza oficialmente la subasta.

