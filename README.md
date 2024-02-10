IDEA
====

Create analogue of shadertoy(https://www.shadertoy.com/) but only based on CPU(no GPU involved). For test purposes was chosen SFML library to draw window and pixels. Tried repeat something cool like this: https://www.youtube.com/watch?v=f4s1h2YETNY, but can't do calculation in paralel execution, as result is really slow(~ 1 frame per sec).

Screenshot
----------

![CPU shader](/screen.png "CPU shader")

How to run
----------

1. Install dlang sfml wrapper (https://code.dlang.org/packages/bindbc-sfml)
2. In the project folder run `dub` command
