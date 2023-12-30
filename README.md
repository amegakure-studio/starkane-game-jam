<p align="center">
  <img alt="Dojo logo" width="650" src="https://github.com/amegakure-starknet/unity-Starkane/assets/58611754/ab701ac0-a1f3-4048-b40f-8234c6f662fe">
</p>

# Starkane

## Introducción

Starkane es un RPG por turnos en el que los jugadores lideran un grupo de héroes a través de un mundo de mapa general y participan en batallas estratégicas en cuadrícula, tomando decisiones tácticas para derrotar a enemigos. Durante la exploración, reclutas y mejora personajes, mientras que en las batallas, el posicionamiento y la selección de acciones son clave para el éxito.

Starkane es un emocionante juego RPG de estrategia por turnos en un mapa grilla 2D. Sumérgete en batallas épicas, desafiando a tus amigos o enfrentándote a la IA. En este juego, la clave para la victoria radica en tu habilidad estratégica para eliminar a todos los personajes enemigos. ¡Prepárate para vivir una experiencia única donde cada decisión cuenta y el destino de tu equipo está en tus manos!

## Desarrollo Actual

El juego cuenta con un frontend implementado en Unity, mientras que el backend se ha construido con Dojo en Starknet. En Unity, disfruta de un mundo libre para explorar, pero cuando la acción comienza, la lógica del combate se traslada completamente a Dojo. Actualmente, el juego se juega de forma local mediante un instalador, pero la visión es llevarlo a la web. El bot, implementado como un algoritmo en Unity, brinda desafíos incluso en partidas de un solo jugador, y ademas podrias retar a tus amigos a jugar una partida de Starkane.

### Development

Abre dos terminales y ejecuta los siguientes comandos:

Terminal 1
```bash
make katana
```

Terminal 2
```bash
make setup
```

Copia la dirección del mundo y úsala como parámetro
```bash
make torii <WORLD_ADDRESS>
```

Visita el [Playground de GraphQL](http://localhost:8080/graphql).

¡El ambiente está configurado y listo para la acción!

## Características del Juego

### Personajes (Characters)

Cada jugador elige 3 personajes de su pool para la batalla. Los personajes tienen atributos como ataque, defensa, movimiento y puntos de vida.
Cada personaje tiene habilidades que pueden ser ofensivas y defensivas. Ataques magicos especiales y basicos.

### Mapa

Los mapas son grillas 2D de tamaño N*M, donde cada casilla afecta positiva o negativamente al mecha en esa posición. Actualmente, contamos con un único mapa de 25 x 25.

### Libs Utilizadas

* C&C para la construcción del mapa.
* Dojo.Unity para conectar Dojo con Unity.

## Acciones del Juego

Ejecuta los siguientes comandos para realizar acciones en el juego:

```bash
sozo execute ${character_system} init
```

```bash
sozo execute ${skill_system} init
```

```bash
sozo execute ${map_system} init
```

## Mecánicas del Juego

Las partidas se juegan por turnos. Cada jugador puede mover a sus personajes y realizar dos acciones por turno: moverse y/o realizar una accion(magia/ataque/uso de item). Las acciones son independientes y dependen de la estrategia del jugador.

## Adicionales

* Juega 5 combates y mintea un mapa de C&C.
* Haste famoso en Starkane recibiendo recomendaciones de otros jugadores y mintea un personaje exclusivo.

## Game Loop

![Diagrama del juego](link_al_diagrama_del_juego)

## Diseño del Juego

Hemos dividido el juego en 3 secciones:

1. **State**: Representa el estado actual del juego.
2. **Game**: Gestiona el desarrollo del juego.
3. **Estadísticas**: Proporciona información detallada sobre el progreso y rendimiento.

## Supporters
Unete como Supporters

## Futuro del Juego

* Agregar modo multijugador para enfrentamientos más desafiantes.
* Implementar una inteligencia artificial mejorada utilizando Orion (ejemplo: tic-tac-toe).
* Agregar mas personajes y habilidades
* Construir un mundo abierto donde puedas realizar quest y obtener recompensas
* Subir de niveles y aprender nuevas habilidades
* Tener un hilo argumental para mejorar la esencia del juego