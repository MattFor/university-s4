#include <print>
#include <cmath>
#include <fstream>
#include <climits>
#include <sstream>
#include <iostream>
#include <functional>

#include <GL/gl.h>
#include <GLFW/glfw3.h>

constexpr int WINDOW_W = 700;
constexpr int WINDOW_H = 700;

struct settings
{
    // ReSharper disable once CppDeclaratorNeverUsed
    GLFWwindow* window = nullptr;

    float x_angle = 0.;
    float y_angle = 0.;
    float v_angle = 0.35;
    float scale   = 1.;
};

std::string get_task_name(const int task_id)
{
    return std::format("Laboratorium 2 - Zadanie {} - REDACTED 155197", task_id);
}

/**
 * @brief Draws the 3D coordinate axes (X, Y, Z) in the scene
 *
 * It sets the colour for each axis and draws lines along them
 * After drawing, the colour is reset to grey for later rendering
 */
static void draw_scene_axes()
{
    using point_3d = float[3];

    constexpr point_3d x_beg = { -100., 0., 0. };
    constexpr point_3d x_end = { 100., 0., 0. };

    constexpr point_3d y_beg = { 0., -100., 0. };
    constexpr point_3d y_end = { 0., 100., 0. };

    constexpr point_3d z_beg = { 0., 0., -100. };
    constexpr point_3d z_end = { 0., 0., 100. };

    glBegin(GL_LINES);

    glColor3f(1., 0., 0.);
    glVertex3fv(x_beg);
    glVertex3fv(x_end);

    glColor3f(0., 1., 0.);
    glVertex3fv(y_beg);
    glVertex3fv(y_end);

    glColor3f(0., 0., 1.);
    glVertex3fv(z_beg);
    glVertex3fv(z_end);

    glEnd();

    glColor3f(.5, .5, .5);
}

/**
 * @brief Initializes OpenGL settings for rendering
 */
static void init_opengl()
{
    glClearColor(0., 0., 0., 1.);
    glEnable(GL_DEPTH_TEST);
}

/**
 * @brief Adjusts the viewport and projection matrix when the window is resized
 *
 * @param width New width of the window
 * @param height New height of the window
 */
static void reshape_window(GLFWwindow*, int width, int height)
{
    if (height == 0)
    {
        height = 1;
    }

    if (width == 0)
    {
        width = 1;
    }

    constexpr GLdouble nRange = 15.;

    glViewport(0, 0, width, height);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    /**
     * Set up projection that preserves aspect ratio
     * So everything looks the same regardless of window size
     * So basically:
     * Window is taller than wider: x stays the same, y scaled up
     * Window is wider than tall: x is scaled up, y is the same
     * This is to make sure nothing is SQUASHED, like a BURGER
     */
    if (width <= height)
    {
        glOrtho(-nRange, nRange, -nRange * static_cast<GLdouble>(height) / static_cast<GLdouble>(width), nRange * static_cast<GLdouble>(height) / static_cast<GLdouble>(width), -50., 50.);
    }
    else
    {
        glOrtho(-nRange * static_cast<GLdouble>(width) / static_cast<GLdouble>(height), nRange * static_cast<GLdouble>(width) / static_cast<GLdouble>(height), -nRange, nRange, -50., 50.);
    }

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

/**
 * @brief Renders a 3D teapot
 *
 * So this was basically the hardest part of this entire task
 * Because of course FreeGLUT has a built-in option
 * And of course GLFW doesn't (that I know of)
 *
 * So this entire thing is just horrors beyond all comprehension
 * In order to mimic the teapot to a tee
 */
static void draw_teapot(const bool filled = false)
{
    struct P
    {
        float x, y, z;
    };

    struct Model
    {
        // Points of the teapot surface
        // Each point is (x, y, z) indexed from teapot.data
        // Allocate in such a way so 1-based indexing is possible (from teapot.data)
        std::vector<P> points;

        // 4x4 grid of a "bicubic Bezier surface" (thanks internet, I still have no clue what that is)
        // From what I understand, we define the points, and the plane is kind of "pulled" towards these points
        // So that they curve nicely in the teapot shape
        std::vector<std::array<int, 16>> patches;

        bool loaded = false;
    };

    // First time finding a use for this keyword.
    // It makes it so that the variable does NOT go out of memory when the function stops
    // Makes it so there's no need to load it AGAIN even after the user chooses to run f.e task1
    // But really it makes it so that the model is not loaded into memory EVERY SINGLE FRAME
    static Model model;

    // Load teapot model from file only once and cache it
    auto load_model = [&]() -> bool
    {
        // If already loaded, skip reloading
        if (model.loaded)
        {
            return true;
        }

        // Open teapot data file (it has vertices + Bezier patch information)
        std::ifstream file("../teapot.data");
        if (!file)
        {
            std::print("Cannot open ../teapot.data!\n");
            return false;
        }

        // Preallocate space for all possible vertex indices 0 – 306
        // This allows direct indexing without resizing which would be EXPENSIVE
        model.points.assign(307, P{});

        // Clear any previous patch data
        model.patches.clear();

        std::string line;
        while (std::getline(file, line))
        {
            // Skip empty lines and comments
            if (const auto first = line.find_first_not_of(" \t\r\n"); first == std::string::npos || line[first] == '#')
            {
                continue;
            }

            // Parse all numbers from the line into a temporary array
            std::stringstream   ss(line);
            std::vector<double> nums;
            double              v = 0.;
            while (ss >> v)
            {
                nums.push_back(v);
            }

            // Vertex definition: index x y z
            if (nums.size() == 4)
            {
                // Store vertex only if index is within valid range
                if (const int idx = static_cast<int>(nums[0]); idx >= 0 && idx < static_cast<int>(model.points.size()))
                {
                    model.points[idx] = { static_cast<float>(nums[1]), static_cast<float>(nums[2]), static_cast<float>(nums[3]) };
                }
            }
            // Patch definition: 16 control point indices (optionally preceded by patch id)
            // These define a single bicubic Bezier surface patch (4x4 control points)
            // Those 16 points from the 4x4 grid I've talked about before
            // But here it can also be 17 because in the teapot.data file it's indexed so we have to see the index as well
            else if (nums.size() == 17 || nums.size() == 16)
            {
                std::array<int, 16> patch{};

                // If 17 numbers -> first one is patch ID. It is skipped
                const std::size_t offset = ( nums.size() == 17 ) ? 1 : 0;

                // Copy 16 control point indices into patch array
                for (int i = 0; i < 16; ++i)
                {
                    patch[i] = static_cast<int>(nums[i + offset]);
                }

                // Store patch in model
                model.patches.push_back(patch);
            }
        }

        // Mark model as loaded if at least one patch was read
        model.loaded = !model.patches.empty();

        // Warn if file was read but contained no useful data (bad)
        if (!model.loaded)
        {
            std::print("teapot.data loaded, but no patches were found!\n");
        }

        return model.loaded;
    };

    /**
     * I'm gonna be honest, I cannot explain this that well
     * I took it off the internet and here's what I *can* understand:
     * This is the cubic Bernstein basis
     * It gives the weights used to blend the 4 points in one direction
     * In other words, this is the thing that makes the Bezier surface bend nicely
     * Basically decides how much each point matters
     */
    auto B = [](const int i, const float t) -> float
    {
        const float u = 1.f - t;
        switch (i)
        {
            case 0:
            {
                // (1 - t)^3
                return u * u * u;
            }

            case 1:
            {
                // 3t(1 - t)^2
                return 3.f * t * u * u;
            }

            case 2:
            {
                // 3t^2(1 - t)
                return 3.f * t * t * u;
            }

            case 3:
            {
                // t^3
                return t * t * t;
            }

            default:
            {
                // Should never happen,
                return 0.;
            }
        }
    };

    /**
     * Take the 4x4 grid of points (the patch) and blend them together using weights
     * To get that smooth shape for the TEAPOT
     *
     * u and v are within [0; 1] and indicate where on the patch we are located
     */
    auto eval_patch = [&](const std::array<int, 16>& patch, const float u, const float v) -> P
    {
        P out{ 0., 0., 0. };

        // Loop over the 4 points
        for (int i = 0; i < 4; ++i)
        {
            // How much does this *row* influence the result (horizontal blending)
            const float bu = B(i, u);
            for (int j = 0; j < 4; ++j)
            {
                // How much does this *column* influence the result (vertical blending)
                const float bv = B(j, v);

                // Get the point from the model
                const auto& [x, y, z] = model.points.at(patch[i * 4 + j]);

                // Compute the weight (influence)
                // Based on the vertical and horizontal direction
                // So it's a smooth blend
                const float w = bu * bv;

                // Weighted mix of all 16 points
                // Each point pulls the plane towards itself like a black hole
                out.x += x * w;
                out.y += y * w;
                out.z += z * w;
            }
        }

        return out;
    };

    /**
     * Stole this from my raytracer project
     * But this is a much more simple version of Lambert lighting
     * So when the teapot is filled in, you can see what direction it's rotating in
     *
     * TLDR:
     * 1. Find normal vector of the triangle
     * 2. Compare it with the lighting direction
     * 3. Return is how much the surface is in the direction of the light
     * Output also is used directly even if grayscale let's not overengineer this EVEN MORE.
     */
    auto compute_light = [](const P& a, const P& b, const P& c) -> float
    {
        /**
         * Build edges of the triangle
         * With 2 vectors on its surface
         * So the normal vector can be built later
         */
        const float ux = b.x - a.x;
        const float uy = b.y - a.y;
        const float uz = b.z - a.z;

        const float vx = c.x - a.x;
        const float vy = c.y - a.y;
        const float vz = c.z - a.z;

        /**
         * Vector cross product -> _|_
         * Tells where the triangle is facing
         */
        float nx = uy * vz - uz * vy;
        float ny = uz * vx - ux * vz;
        float nz = ux * vy - uy * vx;

        // Normalize
        const float len = std::sqrt(nx * nx + ny * ny + nz * nz);

        // All points on the same line / point (bad)
        if (len == 0.)
        {
            return .5;
        }

        nx /= len;
        ny /= len;
        nz /= len;

        // Light direction
        constexpr float lx = 0;
        constexpr float ly = 0;
        constexpr float lz = -1.;

        /**
         * Dot product is brightness
         * 1 = bright
         * 0 = dim
         * <= 0 = dark
         */
        const float dot = nx * lx + ny * ly + nz * lz;

        // Prevent blackout
        return std::max(0.1f, dot);
    };

    /**
     * Get points at coords (u; v)
     * Connect them and produce a wireframe grid
     */
    auto draw_patch_wire = [&](const std::array<int, 16>& patch, const int steps) -> void
    {
        // Pass #1 draw lines along V direction
        for (int iu = 0; iu <= steps; ++iu)
        {
            const float u = static_cast<float>(iu) / static_cast<float>(steps);
            glBegin(GL_LINE_STRIP);

            for (int iv = 0; iv <= steps; ++iv)
            {
                const float v         = static_cast<float>(iv) / static_cast<float>(steps);
                const auto  [x, y, z] = eval_patch(patch, u, v);
                glVertex3f(x, y, z);
            }

            glEnd();
        }

        // Pass #2 draw lines along U direction
        for (int iv = 0; iv <= steps; ++iv)
        {
            const float v = static_cast<float>(iv) / static_cast<float>(steps);
            glBegin(GL_LINE_STRIP);

            for (int iu = 0; iu <= steps; ++iu)
            {
                const float u         = static_cast<float>(iu) / static_cast<float>(steps);
                const auto  [x, y, z] = eval_patch(patch, u, v);
                glVertex3f(x, y, z);
            }

            glEnd();
        }
    };

    /**
     * Basically the same as wireframe
     * But convert the wireframe grid into cells divided into 2 triangles
     * Then apply the simplest of lighting on each triangle
     */
    auto draw_patch_filled = [&](const std::array<int, 16>& patch, const int steps) -> void
    {
        // This time looping over wireframe grid CELLS not POINTS (quads)
        for (int iu = 0; iu < steps; ++iu)
        {
            // Left / Right of the quad
            const float u0 = static_cast<float>(iu) / static_cast<float>(steps);
            const float u1 = static_cast<float>(iu + 1) / static_cast<float>(steps);

            for (int iv = 0; iv < steps; ++iv)
            {
                // Bottom / Top of the quad
                const float v0 = static_cast<float>(iv) / static_cast<float>(steps);
                const float v1 = static_cast<float>(iv + 1) / static_cast<float>(steps);

                /**
                 * Evaluate 4 corners of quad
                 *
                 * p01 ---- p11
                 * |         |
                 * |         |
                 * p00 ---- p10
                 * Drawing helps
                 */
                auto p00 = eval_patch(patch, u0, v0);
                auto p10 = eval_patch(patch, u1, v0);
                auto p11 = eval_patch(patch, u1, v1);
                auto p01 = eval_patch(patch, u0, v1);

                // Draw as two triangles

                // Triangle 1
                const float light1 = compute_light(p00, p10, p11);
                glColor3f(light1, light1, light1);

                glBegin(GL_TRIANGLES);
                glVertex3f(p00.x, p00.y, p00.z);
                glVertex3f(p10.x, p10.y, p10.z);
                glVertex3f(p11.x, p11.y, p11.z);
                glEnd();

                // Triangle 2
                const float light2 = compute_light(p00, p11, p01);
                glColor3f(light2, light2, light2);

                glBegin(GL_TRIANGLES);
                glVertex3f(p00.x, p00.y, p00.z);
                glVertex3f(p11.x, p11.y, p11.z);
                glVertex3f(p01.x, p01.y, p01.z);
                glEnd();
            }
        }
    };

    if (!load_model())
    {
        return;
    }

    glPushMatrix();

    // Imitate that freeglut placement
    glRotated(270., 1., 0., 0.);
    glScaled(2., 2., 2.);
    glTranslated(0., 0., -1.5);

    glColor3f(.5, .5, .5);

    for (const auto& patch : model.patches)
    {
        // Can be 30 steps if the PC is good enough
        if (filled)
        {
            draw_patch_filled(patch, 15);
        }
        else
        {
            draw_patch_wire(patch, 15);
        }
    }

    glPopMatrix();
}

bool init_program(GLFWwindow*& window, const char* title)
{
    if (!glfwInit())
    {
        std::print("Failed to initialize GLFW!\n");
        return false;
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

    window = glfwCreateWindow(WINDOW_W, WINDOW_H, title, nullptr, nullptr);
    if (!window)
    {
        std::print("Failed to create window!\n");
        glfwTerminate();
        return false;
    }

    glfwMakeContextCurrent(window);

    // Whatever, let's go for 144 fps (well, uncapped). My pc can do it
    glfwSwapInterval(0);

    init_opengl();

    glfwSetFramebufferSizeCallback(window, reshape_window);

    int fbw = 0;
    int fbh = 0;
    glfwGetFramebufferSize(window, &fbw, &fbh);
    reshape_window(window, fbw, fbh);

    return true;
}

static void key_quit_only(GLFWwindow* window, const int key, int, const int action, int)
{
    if (action == GLFW_PRESS && key == GLFW_KEY_ESCAPE)
    {
        glfwSetWindowShouldClose(window, GLFW_TRUE);
    }
}

static void begin_frame()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    draw_scene_axes();
}

static void run_windowed(const char* title, const std::function<void(GLFWwindow*)>& frame)
{
    GLFWwindow* window = nullptr;
    if (!init_program(window, title))
    {
        return;
    }

    glfwSetKeyCallback(window, key_quit_only);

    while (!glfwWindowShouldClose(window))
    {
        frame(window);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    if (window)
    {
        glfwDestroyWindow(window);
    }

    glfwTerminate();
}

void run_task1()
{
    run_windowed(get_task_name(1).c_str(), [](GLFWwindow*)
    {
        begin_frame();

        glPushMatrix();
        glColor3f(.5f, .5f, .5f);
        draw_teapot();
        glPopMatrix();
    });
}

void run_task2()
{
    run_windowed(get_task_name(2).c_str(), [](GLFWwindow*)
    {
        begin_frame();

        glPushMatrix();
        glColor3f(.5f, .5f, .5f);
        draw_teapot(true);
        glPopMatrix();
    });
}

void run_task3()
{
    run_windowed(get_task_name(3).c_str(), [](GLFWwindow*)
    {
        begin_frame();

        glPushMatrix();
        glTranslatef(1.8f, .5f, 0.f);
        glRotatef(-20.f, 1.f, 0.3f, 0.f);
        glScalef(0.8f, 0.8f, 0.8f);
        draw_teapot(true);
        glPopMatrix();
    });
}

void run_task4()
{
    settings ctx{};

    int  timeout   = 0;
    bool wireframe = false;

    double accelerator = .0033;

    run_windowed(get_task_name(4).c_str(), [&ctx, &wireframe, &timeout, &accelerator](GLFWwindow* window)
    {
        if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS)
        {
            if (timeout <= 0)
            {
                wireframe = !wireframe;
                timeout   = 65;
            }
        }

        static double last_time = glfwGetTime();

        const double now   = glfwGetTime();
        const double delta = now - last_time;
        last_time          = now;

        ctx.x_angle += static_cast<float>(ctx.v_angle * delta * 60.0 + ( accelerator += 0.000033 ));
        ctx.y_angle += static_cast<float>(ctx.v_angle * delta * 60.0 + ( accelerator += 0.000033 ));

        if (ctx.x_angle >= 360.f)
        {
            ctx.x_angle -= 360.f;
        }

        if (ctx.y_angle >= 360.f)
        {
            ctx.y_angle -= 360.f;
        }

        begin_frame();

        glPushMatrix();
        glRotatef(ctx.x_angle, 1.f, 0.f, 0.f);
        glRotatef(ctx.y_angle, 0.f, 1.f, 0.f);
        glColor3f(.5f, .5f, .5f);
        draw_teapot(wireframe);
        glPopMatrix();

        if (timeout > 0)
        {
            timeout -= 2;
        }
    });
}

void run_task5()
{
    settings ctx{};
    bool     wireframe = false;
    int      timeout   = 0;

    run_windowed(get_task_name(5).c_str(), [&ctx, &wireframe, &timeout](GLFWwindow* window)
    {
        static double last_time = glfwGetTime();

        const double now   = glfwGetTime();
        const double delta = now - last_time;
        last_time          = now;

        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        {
            glfwSetWindowShouldClose(window, GLFW_TRUE);
        }

        if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        {
            ctx.v_angle += static_cast<float>(0.05 * delta * 60.0);
        }

        if (glfwGetKey(window, GLFW_KEY_E) == GLFW_PRESS)
        {
            ctx.v_angle = std::max(0.f, ctx.v_angle - static_cast<float>(0.05 * delta * 60.0));
        }

        if (glfwGetKey(window, GLFW_KEY_R) == GLFW_PRESS)
        {
            ctx.scale *= 1.01f;
        }

        if (glfwGetKey(window, GLFW_KEY_T) == GLFW_PRESS)
        {
            ctx.scale *= 0.99f;
            if (ctx.scale < 0.05f)
            {
                ctx.scale = 0.05f;
            }
        }

        if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS)
        {
            // Sometimes can go oob on a good PC so need to have <= 0 here
            if (timeout <= 0)
            {
                wireframe = !wireframe;
                timeout   = 65;
            }
        }

        ctx.x_angle += static_cast<float>(ctx.v_angle * delta * 60.0);
        ctx.y_angle += static_cast<float>(ctx.v_angle * delta * 60.0);

        if (ctx.x_angle >= 360.f)
        {
            ctx.x_angle -= 360.f;
        }

        if (ctx.y_angle >= 360.f)
        {
            ctx.y_angle -= 360.f;
        }

        begin_frame();

        glPushMatrix();
        glScalef(ctx.scale, ctx.scale, ctx.scale);
        glRotatef(ctx.x_angle, 1.f, 0.f, 0.f);
        glRotatef(ctx.y_angle, 0.f, 1.f, 0.f);
        glColor3f(.5f, .5f, .5f);
        draw_teapot(wireframe);
        glPopMatrix();

        if (timeout > 0)
        {
            timeout -= 2;
        }
    });
}

#if defined(LAB2_ZAD1)
int main()
{
    return run_task1();
}
#elif defined(LAB2_ZAD2)
int main()
{
    return run_task2();
}
#elif defined(LAB2_ZAD3)
int main()
{
    return run_task3();
}
#elif defined(LAB2_ZAD4)
int main()
{
    return run_task4();
}
#elif defined(LAB2_ZAD5)
int main()
{
    return run_task5();
}
#else
int main(const int argc, char** argv)
{
    int choice = 0;

    if (argc >= 2)
    {
        errno     = 0;
        char* end = nullptr;

        if (const long value = std::strtol(argv[1], &end, 10); end != argv[1] && *end == '\0' && errno != ERANGE && value >= INT_MIN && value <= INT_MAX)
        {
            choice = static_cast<int>(value);
        }
        else
        {
            std::print("Invalid argument!\n");
            return 1;
        }
    }

    while (true)
    {
        std::print("Choose lab:\n1 -> Ex1\n2 -> Ex2\n3 -> Ex3\n4 -> Ex4\n - SPACE to toggle between filled and wireframe\n5 -> Ex5\n - W to speed up\n - E to slow down\n - R to make it bigger\n - T to make it smaller\n - SPACE to toggle between filled and wireframe\n\n\nAny other option than 1, 2, 3, 4, 5 to quit.\n");

        if (!( std::cin >> choice ))
        {
            std::print("Error reading input!\n");
            return 1;
        }

        switch (choice)
        {
            case 1:
            {
                run_task1();
            }
            break;

            case 2:
            {
                run_task2();
            }
            break;

            case 3:
            {
                run_task3();
            }
            break;

            case 4:
            {
                run_task4();
            }
            break;

            case 5:
            {
                run_task5();
            }
            break;

            default:
            {
                std::print("Stopping program...\n");
                return 0;
            }
        }
    }
}
#endif
