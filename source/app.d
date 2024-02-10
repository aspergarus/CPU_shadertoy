import std.stdio;
import std.math;
import std.parallelism;
import bindbc.loader;
import bindbc.sfml;

sfVector2f normiliseUV(sfVector2f fragCoord, sfVector2f iResolution) {
	sfVector2f uv;
    uv.x = fragCoord.x * 2.0;
    uv.y = fragCoord.y * 2.0;

    uv.x -= iResolution.x;
    uv.y -= iResolution.y;

    // normilise resolution. If we don't do this we will have not circle but ellipse
    uv.x /= iResolution.y;
    uv.y /= iResolution.y;

    return uv;
}

float length(sfVector2f vec) {
    return sqrt(vec.x^^2 + vec.y^^2);
}

void print(sfVector2f vec) {
    printf("(%f, %f)\n", vec.x, vec.y);
}

float clamp(float x, float a, float b) {
    if (a > b) {
        float tmp = a;
        a = b;
        b = tmp;
    }

    return x < a ? a : (x > b ? b : x);
}

float smoothstep(float edge0, float edge1, float x) {
    x = clamp((x - edge0) / (edge1 - edge0), 0.0f, 1.0f);

    return x * x * (3 - 2 * x);
}

sfVector3f shader(sfVector2f fragCoord, sfVector2f iResolution, float iTime) {
	sfVector2f uv = normiliseUV(fragCoord, iResolution);

    float d = length(uv);

    sfVector3f col = sfVector3f(0.3, 0.6, 0.9);

    d = sin(d * 8.0 + iTime) / 1.0; // -1.0 .. 1.0
    // printf("d");
    d = abs(d); // 0.0 .. 1.0
    if (d <= 0.02) d = 0.02; // 0.02 .. 1.0
    d = 0.02 / d; // 1 .. 0.02

    // making circle without smoothstep
    // if (d < 0.3) d = 0.0;
    // else d = 1.0;
    
    // making circle with smoothstep
    // d = smoothstep(0.0, 0.1, d);

    col.x *= d;
    col.y *= d;
    col.z *= d;

    return col;
}

sfColor normilizeColor(sfVector3f vec) {
    return sfColor_fromRGB(cast(ubyte) (vec.x * 255), cast(ubyte) (vec.y * 255), cast(ubyte) (vec.z * 255));
}

void main()
{
    writeln("Edit source/app.d to start your project.");

	if (loadSFML() != 0) {
	 	writeln("sfml doesn't support");
    }

	if (loadSFMLGraphics() != 1) {
		writeln("sfml graphics doesn't support");
	}

    int winW = 900;
    int winH = 700;

	auto window = sfRenderWindow_create(sfVideoMode(winW, winH), "SFML CPU shadertoy", sfWindowStyle.sfDefaultStyle, null);

    scope(exit) { sfRenderWindow_destroy(window); }

	// configure window
    sfRenderWindow_setFramerateLimit(window, 30);
    sfRenderWindow_setVerticalSyncEnabled(window, true);

    // create rectangle shape(just 1 pixel)
	auto shape = sfRectangleShape_create();
    sfRectangleShape_setSize(shape, sfVector2f(1, 1));

    sfVector2f iResolution = {winW, winH};
    float iTime = 0.0;

    // part of paralel, which doesn't work
    // auto pixelMap = new int[winW * winH];

    while (sfRenderWindow_isOpen(window)) {
        // handle events
        sfEvent event;
        while (sfRenderWindow_pollEvent(window, &event)) {
			switch(event.type) with(sfEvent) {
                case sfEvtClosed:
                    sfRenderWindow_close(window);
                    break;
                case sfEvtKeyPressed:
                    if(event.key.code == sfKeyCode.sfKeyEscape) {
                        sfRenderWindow_close(window);
                    }
                    break;
                default: 
                    break;
            }
        }

        iTime += 0.05;

        // clear window with black color
        sfRenderWindow_clear(window, sfColor_fromRGBA(0, 0, 0, 0));

        // tried to make paralel, doesn't work
        // foreach (i, ref elem; taskPool.parallel(pixelMap, 100)) {
        //     ulong x = i % winW;
        //     ulong y = i / winW;
        //     sfVector2f fragCoord = {x, winH - y};
        //     sfColor color = normilizeColor(shader(fragCoord, iResolution, iTime));
            
        //     sfRectangleShape_setFillColor(shape, color);
        //     sfRectangleShape_setPosition(shape, fragCoord);
        //     sfRenderWindow_drawRectangleShape(window, shape, null);
        // }
        
        // not paralel
        // simulates shadertoy. Pass each pixel as coordinate, resolution of screen and current time(just a increment number)
        for (int x = 0; x < winW; x++) {
            for (int y = 0; y < winH; y++) {
                // make 0,0 at the left bottom of screen
                sfVector2f fragCoord = {x, winH - y};
                
                // calculate color of current pixel and convert it to regular sfColor for sfml
                sfColor color = normilizeColor(shader(fragCoord, iResolution, iTime));
                
                sfRectangleShape_setFillColor(shape, color);
                sfRectangleShape_setPosition(shape, fragCoord);
                sfRenderWindow_drawRectangleShape(window, shape, null);
            }
        }

        scope(exit) { sfRenderWindow_display(window); }
    }
}
