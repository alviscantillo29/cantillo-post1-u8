# cantillo-post1-u8

## Descripción General
El presente repositorio documenta el laboratorio guiado de la Unidad 8 de Arquitectura de Computadores en NASM sobre DOSBox. En la Parte 1 (`post1.asm`, `post1c.asm`, `post1d.asm` y `post1e.asm`), el estudiante implementa rutinas de copia, búsqueda, comparación y transformación de cadenas mediante instrucciones de cadena x86 y el control explícito del flag de dirección `DF`. En la Parte 2 (`post2.asm`, `post2b.asm`, `post2c.asm` y `post2d.asm`), se desarrollan operaciones aritméticas de 32 bits con propagación de acarreo (`ADC`/`SBB`), ajustes BCD empaquetados (`DAA`/`DAS`), una calculadora de dígitos (`MUL`/`DIV`) y ajustes BCD desempaquetados (`AAA`/`AAS`).

## Compilación y Ejecución en DOSBox
```bat
nasm -f bin post1.asm -o post1.com
nasm -f bin post1c.asm -o post1c.com
nasm -f bin post1d.asm -o post1d.com
nasm -f bin post1e.asm -o post1e.com

nasm -f bin post2.asm -o post2.com
nasm -f bin post2b.asm -o post2b.com
nasm -f bin post2c.asm -o post2c.com
nasm -f bin post2d.asm -o post2d.com
```

## Diseño Técnico de las Rutinas

### Parte 1: Cadenas y el Rol del Flag `DF`
En todas las rutinas de la Parte 1 se inicializa `ES = DS` y se ejecuta `CLD` (`DF = 0`) para garantizar que los punteros implícitos `SI` y `DI` avancen de direcciones bajas a altas; omitir `CLD` dejaría el programa expuesto a un `DF = 1` heredado, provocando decrementos erróneos. `post1.asm` combina `REP MOVSW` (`CX >> 1` palabras) y `MOVSB` condicional para el byte impar restante. `post1c.asm` emplea `REPNE SCASB` para localizar `'d'` en `"Arquitectura de Computadores"`, calculando el índice base-0 como `DI - cadena - 1`. `post1d.asm` compara cadenas mediante `REPE CMPSB` con `CX = 8`, deteniéndose en el primer carácter diferente. Finalmente, `post1e.asm` combina `LODSB` y `STOSB` en un bucle manual para restar `20h` a las letras minúsculas `'a'..'z'` durante la copia.

### Parte 2: Precisión Múltiple, Acarreo y Ajuste BCD
En `post2.asm`, los enteros de 32 bits se dividen en pares `DX:AX`: `ADD`/`SUB` operan sobre los 16 bits bajos generando el bit `CF` (acarreo o préstamo), el cual es consumido automáticamente por `ADC`/`SBB` sobre los 16 bits altos. En `post2b.asm`, `DAA` y `DAS` corrigen el byte de resultado binario sumando o restando `6` por nibble cuando supera `9` o se activa `AF`/`CF`. En `post2c.asm`, `MUL` y `DIV` operan en binario puro tras restar `30h` a la entrada ASCII, y `imprimirAX` extrae dígitos decimales mediante divisiones sucesivas por `10`. Por último, `post2d.asm` utiliza `AAA` y `AAS` para ajustar dígitos desempaquetados (`07h + 08h -> AH=01, AL=05` y `03h - 08h -> AL=05, CF=1`).

---

## Decisiones Técnicas Justificadas

### Parte 1 — Decisión 1: `REP MOVSB` frente a un bucle manual con `LODSB`/`STOSB`
Para copiar bloques de memoria sin alterar su contenido, `REP MOVSB` es claramente superior en rendimiento frente a un bucle manual con `LODSB`, `STOSB` y `LOOP`, porque el prefijo `REP` ejecuta la transferencia íntegramente dentro del microcódigo del procesador sin decodificar instrucciones ni evaluar saltos condicionales en cada byte. Sin embargo, en `post1e.asm` fue obligatorio abandonar `REP MOVSB` y recurrir al bucle manual `LODSB`/`STOSB`, debido a que `REP MOVSB` traslada bytes directamente de `DS:SI` a `ES:DI` sin exponerlos ni permitir comparaciones o restas intermedias sobre `AL`. Por lo tanto, cuando se requiere copiar una cadena larga sin ninguna transformación por carácter, `REP MOVSB` (o `REP MOVSW`) sigue siendo la opción recomendada, reservando el bucle `LODSB`/`STOSB` exclusivamente para rutinas que transforman datos al vuelo.

### Parte 1 — Decisión 2: `CX` fijo en `REPE CMPSB`/`REPNE SCASB` frente a verificación manual del terminador nulo
Ni `REPE CMPSB` ni `REPNE SCASB` interpretan el byte nulo (`00h`) como fin de cadena: su condición de parada depende exclusivamente de `CX` y del flag `ZF`. Si se compararan dos cadenas terminadas en nulo de 5 y 8 caracteres respectivamente usando `REPE CMPSB` con `CX = 8` fijo, tras coincidir en los primeros bytes la instrucción seguiría leyendo y comparando memoria adyacente fuera de la cadena de 5 caracteres, produciendo resultados inválidos o fallos de lectura. Para cadenas de longitud desconocida, el programador debe adaptar el bucle `LODSB` cargando un carácter de cada cadena, comparándolos y deteniendo la ejecución en cuanto cualquiera sea `00h`. En `post1d.asm`, usar `REPE CMPSB` con `CX = 8` es apropiado únicamente porque las longitudes de `cad1`, `cad2` y `cad3` son constantes conocidas al ensamblar.

### Parte 2 — Decisión 1: `DAA`/`DAS` frente a `AAA`/`AAS` según formato BCD empaquetado o desempaquetado
La elección entre `DAA`/`DAS` y `AAA`/`AAS` está determinada estrictamente por la representación del dato en memoria. `DAA` y `DAS` esperan BCD empaquetado (dos dígitos por byte) y ajustan ambos nibbles conservando el dígito alto; en cambio, `AAA` y `AAS` operan sobre BCD desempaquetado (un dígito en el nibble bajo) y ponen a cero el nibble alto al ajustar. Si se aplicara `AAA` sobre el byte empaquetado `47h`, destruiría el dígito de las decenas (`4`) al limpiar el nibble superior. Inversamente, si la calculadora `post2c.asm` sumara dos dígitos leídos con `AH = 01h` menos `30h` (formato desempaquetado), la instrucción correcta sería `AAA`; aplicar `DAA` sobre `07h + 08h = 0Fh` ajustaría erróneamente a `15h` interpretando ambos nibbles como dígitos válidos en un solo byte en lugar de separar `AH = 01` y `AL = 05`.

### Parte 2 — Decisión 2: `ADC` de precisión fija (32 bits) frente a una cadena de `ADC` en bucle
En `post2.asm`, sumar dos enteros de 32 bits se resuelve de forma directa y veloz con dos instrucciones fijas (`ADD` para la palabra baja y `ADC` para la alta). No obstante, para sumas de 48, 64 o `N` palabras, replicar instrucciones `ADC` manualmente se vuelve rígido y difícil de mantener; la solución escalable es un bucle genérico indexado de menor a mayor peso. En ese bucle, la primera palabra (menor peso) debe sumarse con `ADD` —o con `ADC` tras limpiar `CF` mediante `CLC`— porque no existe acarreo previo que propagar, mientras todas las palabras siguientes deben usar `ADC` para incorporar el `CF` generado por la palabra anterior. Al igual que ocurre al comparar `REP MOVSB` frente al bucle `LODSB`/`STOSB`, el bucle genérico con `ADC` ofrece mantenibilidad para precisión arbitraria a cambio de un ligero costo adicional en instrucciones de control.
