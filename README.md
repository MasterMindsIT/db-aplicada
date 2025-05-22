# Bases de datos con Oracle - Bases de datos aplicadas


# 📊 Proyecto Académico: Bases de Datos Aplicadas con Oracle

Este proyecto fue desarrollado como parte del ramo "Bases de Datos Aplicadas" en Duoc UC. Consiste en el diseño e implementación completa de una base de datos relacional para un sistema de postulación de becas, siguiendo buenas prácticas de modelado, seguridad y optimización. Ademas cada semana muestra el avance de todo el contenido generando la semana 9 (S9) el resumen general de lo interiorizado.

---

## 🧩 Contexto

El objetivo fue abordar diferentes problemáticas propias del diseño de sistemas relacionales reales, incluyendo integridad referencial, control de datos y preparación para escenarios de producción. Se trabajó en base al modelo de postulación ANID (Chile) y otros proyectos de casoso reales.

---

## 🛠️ Herramientas Utilizadas

| Herramienta                         | Uso principal                                                                 |
|-------------------------------------|------------------------------------------------------------------------------|
| **Oracle SQL Developer**            | Escritura, ejecución y validación de scripts SQL DDL/DML.                    |
| **Oracle SQL Developer Data Modeler** | Diseño del Modelo Relacional Normalizado (1FN, 2FN, 3FN) y visualización.  |
| **Oracle Cloud + Wallet**           | Conexión a instancia remota para pruebas y ejecución de scripts.            |

---

## 📚 Conocimientos Aplicados

- ✅ Diseño de modelo entidad-relación y normalización hasta 3FN.
- ✅ Implementación de claves primarias, foráneas y restricciones (`CHECK`, `NOT NULL`, `UNIQUE`).
- ✅ Creación de catálogos de referencia jerárquicos (`región → comuna`, `país → ciudad`).
- ✅ Separación y validación de campos como RUT (número + dígito verificador).
- ✅ Estructuración de entidades complejas: `postulante`, `programa`, `institución`, `documento`, `beneficio`, `evaluación`, entre otras.
- ✅ Diseño modular de scripts para claridad y reutilización.
- ✅ Preparación de datos de prueba con escenarios variados para análisis.
- ✅ Optimización de consultas mediante uso de `EXPLAIN PLAN`.
- ✅ Aplicación del principio de mínimo privilegio con roles, usuarios y perfiles.

---

## 📁 Estructura del Repositorio

- `/scripts/`: Contiene los scripts DDL y DML estructurados por entidad.
- `/diagramas/`: Modelo entidad-relación exportado desde Oracle Data Modeler.
- `/pruebas/`: Escenarios con datos de ejemplo y consultas analíticas.

---

## 🧠 Reflexión Final

Este proyecto no solo consolida conocimientos técnicos en bases de datos, sino también buenas prácticas de diseño, seguridad y optimización. Representa un trabajo académico orientado a contextos reales, que puede ser base para sistemas productivos.



