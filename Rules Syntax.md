# .rules File Format

## Overview

`.rules` files are human-readable, hierarchical data files used throughout Cosmoteer to define game content including ships, parts, weapons, UI, effects, and game modes. They use the **ObjectText** format, a custom text-based serialization format parsed by the Halfling engine.

## File Structure

### Entry Point
- `Data/cosmoteer.rules` - Root file that references (almost) all other game data files

### Basic Syntax

```
// Single-line comment
/* Multi-line
   comment */

FieldName = value
FieldName = "string value"
FieldName = [1, 2, 3]  // Array

ObjectName
{
    Field1 = value1
    Field2 = value2

    NestedObject
    {
        NestedField = value
    }
}
```

## Data Types

### Primitives

Technically, ObjectText only supports strings, and it is up to the application to interpret those strings however it wants. The presence or absence of quotes (`""`) or verbatim-quotes (`@""`) only affects how ObjectText parses the string; the end result returned to the application is always still a string. However, here are most of the common interpretations used by Halfling/Cosmoteer:

| Type | Example | Description |
|------|---------|-------------|
| Integer | `42`, `-10` | Whole numbers |
| Float | `3.14`, `-0.5` | Decimal numbers |
| String | `"text"` | Quoted text with escape sequences |
| Verbatim String | `@"C:\path"` | Raw string without escape processing |
| Word | NameOfSomething | A single word string without quotes, typically used to refer to a code element by name |
| Boolean | `true`, `false` | Boolean values |
| Degrees | `45d`, `360d` | Angle values (converted to radians) |
| Percentage | `50%`, `125%` | Percentage values (converted to decimal) |

### Collections

**Lists (aka Arrays):**

```
Resources = [steel, coil]
Position = [1, 2, 3]
Color = [255, 128, 0, 255]  // RGBA color
Range = [0, 100]            // Min/max range
Ships
[
    &<ships/terran/terran.rules>/Terran
    &<ships/asteroid/asteroid.rules>/Asteroid
]
```

The `=` symbol is optional and has no affect on behavior. (By convention, it is only used for single-line lists.)

**Groups (aka Objects):**

```
Camera
{
    MinScale = 1
    MaxScale = 4000
    DefaultScale = 4
}
```

The `=` symbol is optional and has no affect on behavior. (By convention, it is only used for single-line groups.)

## References and Paths

References are denoted by starting the value with a `&` character. Example:

```
Resources = &<resources/resources.rules>/Resources
```

**Reference syntax meanings:**

- `&Foo` - Refers to a node named `Foo` that is a sibling of the current node.
- `&Foo/Bar` - Refers to a node named `Bar` that is inside a node named `Foo`.
- `&Foo/0` - Refers to the first node (index 0) within a node named `Foo`. (Necessary when referencing inside of lists since list children aren't named.)
- `&../Foo` - Refers to a node named `Foo` that is a sibling of the current node's parent.
- `&~/Foo` - Refers to a node named `Foo` that is at the root level of the current file.
- `&/Foo` - Refers to a node named `Foo` that is at the root level of the `Data/cosmoteer.rules` file.
- `&^/0/` - Refers to the first collection inherited by the current node's parent.
- `&:/Foo` - Refers to a node named `Foo` in the *most derived* inheritor of the current node. (See "Virtual Inheritance" below.)
- `&<path/to/file.rules>` - Refers to the root level of the file within the `<>` brackets. The file will be automatically loaded and parsed during dereferencing. The path is relative to the current file. Always use forward `/` slashes.
- `&<path/to/file.rules>/Path/In/File` - Refers to the node `Path/In/File` within the file `path/to/file.rules`.
- `&<./Data/path/to/file.rules>` - Refers to a file using a path relative to the Cosmoteer root `./Data` directory.

### Global Convenience References
Common reference aliases defined in `cosmoteer.rules`:

```
COMMON_EFFECTS = &<common_effects/common_effects.rules>
COMMON_SOUNDS = &<common_effects/sounds/common_sounds.rules>
BASE_SOUNDS = &<common_effects/sounds/base_sounds.rules>
PRIORITIES = &<ships/priorities.rules>
```

Usage: `&/COMMON_EFFECTS/EffectName`

## Inheritance

Both Groups and Lists can inherit from other Groups/Lists using `:` syntax and then using a reference path (the leading `&` may be and typically is omitted):

### Group Inheritance

When a group inherits another group, any fields defined in the child group will add to and (if already existing) override the fields in the parent group:

```
Part : <../base_med_part_terran.rules>/Part
{
    NameKey = "Parts/CannonMed"
    ID = cosmoteer.cannon_med
    Size = [2, 2]
    MaxHealth = 12000
}
```

### List Inheritance

When a list inherits another list, any fields defined in the child list will be appended to the fields in the parent list.

```
List : ParentList
[
	100
	200
	300
]
```

### Multiple Inheritance

Multiple inheritance is supported by specifying multiple paths separated by commas. With groups, the earlier listed parents will override later parents.

```
Group : ParentGroup1, ParentGroup2, ParentGroup3 {}
```

### Virtual Inheritance

A feature similar to the "virtual inheritance" feature found in object-oriented programming languages can be accessed by using the `:` symbol in a reference path. The `:` symbol goes to the *most-derived* inheritor of the current node (or does nothing if it has no inheritors). Here are a few examples for how this can be used:

**For easily overriding nested values:**

```
Parent
{
    v_Foo = 0 // Default value optional but will crash if there's no inheritor. Suggest using v_ prefix for "virtual" values meant to be overridden.
    Nested1
    {
        Nested2
        {
            Nested3
            {
                Foo = &../../../:/v_Foo
            }
        }
    }
}

Child : Parent
{
    v_Foo = 42
}

TestParent = &Parent/Nested1/Nested2/Nested3/Foo // returns 0
TestChild = &Child/Nested1/Nested2/Nested3/Foo // returns 42
```

**For overriding values or blocks inside [] lists:**

```
Parent
{
    List
    [
        &../:/v_Group0
        &../:/v_Group1
        &../:/v_Group2
    ]

    v_Group0
    {
        Value = 100
    }

    v_Group1
    {
        Value = 200
    }

    v_Group2
    {
        Value = 300
    }
}

Child : Parent
{
    v_Group1 : ^/0/v_Group1
    {
        Value = 42
    }
}

TestParent = &Parent/List/1/Value // returns 200
TestChild = &Child/List/1/Value // returns 42
```

**For overriding operands of math equations:**

(See "Math Expressions" below.)

```
Parent
{
    v_A = 1
    v_B = 2
    Sum = (&:/v_A) + (&:/v_B)
}

Child : Parent
{
    v_A = 20
    v_B = 22
}

TestParent = &Parent/Sum // returns 3
TestChild = &Child/Sum // returns 42
```

## Math Expressions

Values can contain mathematical expressions:

```
Five = 2 + 3
```

References can be embedded in math expressions, in which case they MUST be surrounded by parentheses (`()`):

```
MaxValue = (&MinValue) * 2
ScaledSize = (&BaseSize) + 10
HalfWidth = (&Width) / 2
Combined = (&Value1) + (&Value2) - (&Value3)
```

### Expression Examples

```
// Reference and multiply
MapTransitionSimZoomFactor = (&~/Simulation/Camera/MaxScale) * 2

// Percentage calculation
PartRepairCost = (1 - (&PlayerPartDestroyed)) / 2

// Complex expression with multiple references
EXTRA_INTERVAL = (&~/Part/Components/Turret/FireInterval) * ((&FIRE_INTERVAL_FACTOR) - 100%)

// Array with expression
StasisPreloadRange = (&StasisLiveRange) * 1.5
```

## Inline Object Syntax

Objects and arrays can be defined inline within their parent:

```
GameSpeeds
[
    { Speed=.125; NameKey="Hud/SpeedEighth"; DecreaseToSound { Sound="sounds/decrease.wav" } }
    { Speed=.25; NameKey="Hud/SpeedQuarter" }
    { Speed=1; NameKey="Hud/Speed1" }
]

GameValues
{
	MoneyIncrements = [100, 200, 300]
}
```

Semicolons (`;`) and commas (`,`) separate fields within the same lines. By convention, `;` is used to separate elements within `{}` groups and `,` is used to separate elements within `[]` lists. 

With a regular `Name = Value` field, a newline will be interpreted as the end of the field. However, if the line ends with a `\` then the field will continue on to the next line:

```
LongString = "The quick brown fox "\
             "jumped over the laxy dog."
```

## Best Practices

1. **File Organization**: Group related definitions in separate files and reference them from main files
2. **Inheritance**: Use inheritance to avoid duplication and maintain consistency
3. **References**: Use references for shared values to maintain single source of truth
4. **Comments**: Document complex values and non-obvious design decisions
5. **Expressions**: Use expressions to derive values from other fields when appropriate
6. **Formatting**: Indent nested structures consistently (typically tabs)

