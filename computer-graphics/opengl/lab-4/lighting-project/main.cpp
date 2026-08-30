#include <random>

#include "boilerplate.h"

/**
 * Stores all lighting parameters and animation state
 */
struct LightingState
{
    std::array<GLfloat, 4> ambient{ .0f, .0f, .0f, 1.f };   ///< Ambient light colour RGBA
    std::array<GLfloat, 4> diffuse{ 1.f, 1.f, 1.f, 1.f };   ///< Diffuse light colour RGBA
    std::array<GLfloat, 4> specular{ .0f, .0f, .0f, 1.f };  ///< Specular light colour RGBA

    std::array<GLfloat, 4> position{ 10.f, .0f, .0f, 1.f }; ///< Light position in world space

    std::array<GLfloat, 3> ambient_target{ .0f, .0f, .0f }; ///< Target ambient colour for smooth transition

    double next_ambient_change = .0; ///< Time when the next ambient change happens
};

LightingState g_light;

float g_scale  = 1.f;
float g_theta  = .0f;
float g_phi    = .0f;
float g_radius = 10.f;

bool g_wireframe = false;

int g_left_pressed  = 0;
int g_right_pressed = 0;

double g_x_last = .0;
double g_y_last = .0;

float g_pixels2angle = 1.f;

/**
 * Returns global random number generator
 *
 * @return Reference to static RNG engine
 */
std::mt19937& rng()
{
    static std::mt19937 engine{ std::random_device{}() };
    return engine;
}

/**
 * Clamps value to range [0, 1]
 *
 * @param value Value to clamp
 *
 * @return Clamped value
 */
float clamp01(const float value)
{
    return std::clamp(value, .0f, 1.f);
}

/**
 * Configures and applies the lighting parameters for the scene
 * The lighting properties are taken from the global object and are set for the primary light source (GL_LIGHT0)
 */
void apply_light()
{
    glLightfv(GL_LIGHT0, GL_AMBIENT, g_light.ambient.data());
    glLightfv(GL_LIGHT0, GL_DIFFUSE, g_light.diffuse.data());
    glLightfv(GL_LIGHT0, GL_SPECULAR, g_light.specular.data());
    glLightfv(GL_LIGHT0, GL_POSITION, g_light.position.data());
}

/**
 * Represents a point on the surface with position and normal
 */
struct SurfacePoint
{
    [[maybe_unused]] float x{};
    [[maybe_unused]] float y{};
    [[maybe_unused]] float z{};
    [[maybe_unused]] float nx{};
    [[maybe_unused]] float ny{};
    [[maybe_unused]] float nz{};
};


/**
 * Evaluates a Bezier patch and computes surface point and normal
 *
 * @param patch Control point indices of a patch
 * @param u Parameter in U direction
 * @param v Parameter in V direction
 *
 * @return Surface point with normal
 */
SurfacePoint make_surface_point(const std::array<int, 16>& patch, const float u, const float v)
{
    // Get the global teapot model that has the necessary points
    const auto& model = get_teapot_model();

    // Accumulated position of evaluated point
    float px = .0f;
    float py = .0f;
    float pz = .0f;

    // Partial derivatives with respect to U direction
    float dux = .0f, duy = .0f, duz = .0f;

    // Partial derivatives with respect to V direction
    float dvx = .0f, dvy = .0f, dvz = .0f;

    // Loop over rows of points
    for (int i = 0; i < 4; ++i)
    {
        // Bernstein basis value and its derivative for U
        const float bu  = B(i, u);
        const float dbu = dB(i, u);

        // Loop over columns of points
        for (int j = 0; j < 4; ++j)
        {
            // Bernstein basis value and its derivative for V
            const float bv  = B(j, v);
            const float dbv = dB(j, v);

            // Get point from model
            const auto& [x, y, z] = model.points.at(patch[i * 4 + j]);

            // Weight for position contribution
            const float w = bu * bv;

            // Weight for derivative in U direction
            const float wu = dbu * bv;

            // Weight for derivative in V direction
            const float wv = bu * dbv;

            // Accumulate weighted position
            px += x * w;
            py += y * w;
            pz += z * w;

            // Accumulate partial derivative in U direction
            dux += x * wu;
            duy += y * wu;
            duz += z * wu;

            // Accumulate partial derivative in V direction
            dvx += x * wv;
            dvy += y * wv;
            dvz += z * wv;
        }
    }

    // Compute normal using cross-product of tangent vectors
    float nx = duy * dvz - duz * dvy;
    float ny = duz * dvx - dux * dvz;
    float nz = dux * dvy - duy * dvx;

    // Normalize normal vector to unit length
    if (const float len = std::sqrt(nx * nx + ny * ny + nz * nz); len > .0f)
    {
        nx /= len;
        ny /= len;
        nz /= len;
    }
    else
    {
        // Fallback normal
        nx = .0f;
        ny = .0f;
        nz = 1.f;
    }

    // Return final surface point with position and normal
    return { px, py, pz, nx, ny, nz };
}

/**
 * Renders teapot using computed normals and OpenGL lighting
 *
 * @param steps Number of subdivisions per patch
 */
void draw_lit_teapot(const int steps)
{
    // Get the global teapot model that has the needed points
    const auto& model = get_teapot_model();

    // Save current transformation state
    glPushMatrix();

    // Rotate teapot to match standard orientation
    glRotated(270.0, 1.0, .0, .0);

    // Scale teapot to desired size
    glScaled(2.0, 2.0, 2.0);

    // Move teapot so it is centered correctly
    glTranslated(.0, .0, -1.5);

    // Iterate over all Bezier patches
    for (const auto& patch : model.patches)
    {
        // Subdivide patch along U direction
        for (int iu = 0; iu < steps; ++iu)
        {
            // Compute U coordinates of current quad
            const float u0 = static_cast<float>(iu) / static_cast<float>(steps);
            const float u1 = static_cast<float>(iu + 1) / static_cast<float>(steps);

            // Subdivide patch along V direction
            for (int iv = 0; iv < steps; ++iv)
            {
                // Compute V coordinates of current quad
                const float v0 = static_cast<float>(iv) / static_cast<float>(steps);
                const float v1 = static_cast<float>(iv + 1) / static_cast<float>(steps);

                // Evaluate 4 corners of current grid cell with normals
                const auto [x00, y00, z00, nx00, ny00, nz00] = make_surface_point(patch, u0, v0);
                const auto [x10, y10, z10, nx10, ny10, nz10] = make_surface_point(patch, u1, v0);
                const auto [x11, y11, z11, nx11, ny11, nz11] = make_surface_point(patch, u1, v1);
                const auto [x01, y01, z01, nx01, ny01, nz01] = make_surface_point(patch, u0, v1);

                // Draw quad as two triangles for proper rasterization (GPU likes it)
                glBegin(GL_TRIANGLES);

                // First triangle
                glNormal3f(nx00, ny00, nz00);
                glVertex3f(x00, y00, z00);

                glNormal3f(nx10, ny10, nz10);
                glVertex3f(x10, y10, z10);

                glNormal3f(nx11, ny11, nz11);
                glVertex3f(x11, y11, z11);

                // Second triangle
                glNormal3f(nx00, ny00, nz00);
                glVertex3f(x00, y00, z00);

                glNormal3f(nx11, ny11, nz11);
                glVertex3f(x11, y11, z11);

                glNormal3f(nx01, ny01, nz01);
                glVertex3f(x01, y01, z01);

                glEnd();
            }
        }
    }

    // Restore previous transformation state
    glPopMatrix();
}

/**
 * Generates new random ambient target colour
 */
void update_ambient_target()
{
    std::uniform_real_distribution dist(0.f, 1.f);
    g_light.ambient_target = { dist(rng()), dist(rng()), dist(rng()) };
}

/**
 * Smoothly interpolates ambient colour over time
 */
void step_ambient()
{
    const double now = glfwGetTime();

    if (g_light.next_ambient_change == .0)
    {
        g_light.next_ambient_change = now + 4.;
        update_ambient_target();
    }

    if (now >= g_light.next_ambient_change)
    {
        g_light.next_ambient_change = now + 4.;
        update_ambient_target();
    }

    for (int i = 0; i < 3; ++i)
    {
        g_light.ambient[i] += ( g_light.ambient_target[i] - g_light.ambient[i] ) * .01f;
        g_light.ambient[i] = clamp01(g_light.ambient[i]);
    }

    g_light.ambient[3] = 1.f;
}

/**
 * Adjusts a selected diffuse light component
 *
 * @param idx Index of component R G B
 * @param delta Amount to add or subtract
 */
void adjust_light_component(const int idx, const float delta)
{
    g_light.diffuse[idx] = clamp01(g_light.diffuse[idx] + delta);
}

/**
 * Moves light in a given axis
 *
 * @param idx Axis index X Y Z
 * @param delta Movement amount
 */
void adjust_light_position(const int idx, const float delta)
{
    g_light.position[idx] += delta;
}

/**
 * Resets scene and lighting to the initial state
 */
void reset_scene()
{
    g_scale  = 1.f;
    g_theta  = .0f;
    g_phi    = .0f;
    g_radius = 10.f;

    g_light.next_ambient_change = .0;

    g_light.ambient_target = { .0f, .0f, .0f };
    g_light.ambient        = { .0f, .0f, .0f, 1.f };
    g_light.diffuse        = { 1.f, 1.f, 1.f, 1.f };
    g_light.specular       = { .0f, .0f, .0f, 1.f };
    g_light.position       = { 10.f, .0f, .0f, 1.f };
}

/**
 * Draws visual marker at the light position
 */
void draw_light_marker()
{
    glPushMatrix();

    // Move to light position
    glTranslatef(-g_light.position[0], -g_light.position[1], -g_light.position[2]);

    // Make it small
    glScalef(.1f, .1f, .1f);

    // Disable lighting so it's always visible
    glDisable(GL_LIGHTING);
    glColor3f(g_light.diffuse[0], g_light.diffuse[1], g_light.diffuse[2]);

    // Placeholder lol I'm not making a sphere
    draw_teapot(false);

    glEnable(GL_LIGHTING);
    glPopMatrix();
}

// Allow multiple keys being pressed at once
bool g_keys[1024] = {};

/**
 * Check what keys are being pressed and do the corresponding action
 *
 * @param dt DeltaTime: how much time has passed each frame
 */
void update_input(const float dt)
{
    constexpr float speed = 7.5f; // units per second

    // X axis
    if (g_keys[GLFW_KEY_A])
    {
        g_light.position[0] += speed * dt;
    }
    if (g_keys[GLFW_KEY_D])
    {
        g_light.position[0] -= speed * dt;
    }

    // Y axis
    if (g_keys[GLFW_KEY_W])
    {
        g_light.position[1] -= speed * dt;
    }
    if (g_keys[GLFW_KEY_S])
    {
        g_light.position[1] += speed * dt;
    }

    // Z axis
    if (g_keys[GLFW_KEY_Q])
    {
        g_light.position[2] -= speed * dt;
    }
    if (g_keys[GLFW_KEY_E])
    {
        g_light.position[2] += speed * dt;
    }

    constexpr float cs = 1.0f;

    if (g_keys[GLFW_KEY_Y])
    {
        adjust_light_component(0, +cs * dt);
    }
    if (g_keys[GLFW_KEY_H])
    {
        adjust_light_component(0, -cs * dt);
    }

    if (g_keys[GLFW_KEY_U])
    {
        adjust_light_component(1, +cs * dt);
    }
    if (g_keys[GLFW_KEY_J])
    {
        adjust_light_component(1, -cs * dt);
    }

    if (g_keys[GLFW_KEY_I])
    {
        adjust_light_component(2, +cs * dt);
    }
    if (g_keys[GLFW_KEY_K])
    {
        adjust_light_component(2, -cs * dt);
    }
}

int main(const int argc, char** argv)
{
    T tasks([]
    {
        static bool initialized = false;

        if (!initialized)
        {
            initialized = true;

            // Enable core OpenGL features required for lighting and depth
            glEnable(GL_LIGHTING);
            glEnable(GL_LIGHT0);
            glEnable(GL_DEPTH_TEST);
            glEnable(GL_NORMALIZE);

            // Use smooth shading for interpolated lighting
            glShadeModel(GL_SMOOTH);

            // Configure light attenuation over distance
            glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 1.f);
            glLightf(GL_LIGHT0, GL_LINEAR_ATTENUATION, .01f);
            glLightf(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, .0001f);

            // Define material properties for rendered objects
            constexpr GLfloat mat_ambient[]  = { 1, 1, 1, 1 };
            constexpr GLfloat mat_diffuse[]  = { 1, 1, 1, 1 };
            constexpr GLfloat mat_specular[] = { 1, 1, 1, 1 };

            // Apply material settings to front faces
            glMaterialfv(GL_FRONT, GL_AMBIENT, mat_ambient);
            glMaterialfv(GL_FRONT, GL_DIFFUSE, mat_diffuse);
            glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);

            // Set shininess factor controlling specular highlight size
            glMaterialf(GL_FRONT, GL_SHININESS, 20.f);

            // Set background clear colour
            glClearColor(0, 0, 0, 1);

            glfwSetKeyCallback(window, [](GLFWwindow*, const int key, int, const int action, int)
            {
                if (key >= 0 && key < 1024)
                {
                    if (action == GLFW_PRESS)
                    {
                        g_keys[key] = true;
                    }
                    else if (action == GLFW_RELEASE)
                    {
                        g_keys[key] = false;
                    }
                }

                if (action == GLFW_PRESS)
                {
                    switch (key)
                    {
                        case GLFW_KEY_ESCAPE:
                        {
                            glfwSetWindowShouldClose(window, true);
                           break;
                        }

                        case GLFW_KEY_SPACE:
                        {
                            g_wireframe = !g_wireframe;
                           break;
                        }

                        case GLFW_KEY_R:
                        {
                            reset_scene();
                           break;
                        }

                        default:
                        {
                            break;
                        }
                    }
                }
            });

            /**
             * Mouse scroll handler
             * Controls object scaling
             */
            glfwSetScrollCallback(window, [](GLFWwindow*, double, const double y)
            {
                g_scale = std::clamp(g_scale + static_cast<float>(y) * .1f, .1f, 10.f);
            });

            /**
             * Mouse button handler
             * Tracks left mouse button state
             */
            glfwSetMouseButtonCallback(window, [](GLFWwindow* w, const int button, const int action, int)
            {
                if (button == GLFW_MOUSE_BUTTON_LEFT)
                {
                    g_left_pressed = action == GLFW_PRESS;
                }

                // Store cursor position for rotation delta
                glfwGetCursorPos(w, &g_x_last, &g_y_last);
            });

            /**
             * Mouse movement handler
             * Rotates camera when left button is pressed
             */
            glfwSetCursorPosCallback(window, [](GLFWwindow*, const double x, const double y)
            {
                const double dx = x - g_x_last;
                const double dy = y - g_y_last;

                g_x_last = x;
                g_y_last = y;

                if (g_left_pressed)
                {
                    g_theta += static_cast<float>(dx) * g_pixels2angle;
                    g_phi   += static_cast<float>(dy) * g_pixels2angle;
                }
            });
        }

        static double last_time = glfwGetTime();
        const double now = glfwGetTime();
        const float dt = static_cast<float>(now - last_time);
        last_time = now;

        // Get current framebuffer size
        int w, h;
        glfwGetFramebufferSize(window, &w, &h);

        // Convert pixels to rotation angle
        g_pixels2angle = 360.f / static_cast<float>(std::max(w, 1));

        // Animate ambient light colour over time
        step_ambient();

        // Get what keys are pressed and do the appropriate action using dt
        update_input(dt);

        // Reset model view matrix
        glLoadIdentity();

        // Apply camera transformations
        glTranslatef(0, 0, -g_radius);
        glRotatef(g_phi, 1, 0, 0);
        glRotatef(g_theta, 0, 1, 0);

        // Apply light parameters in current coordinate system
        apply_light();

        // Draw visual marker (mini teapot)
        draw_light_marker();

        // Draw coordinate axes without applying lighting
        glDisable(GL_LIGHTING);
        glDepthMask(GL_FALSE);
        draw_scene_axes();
        glDepthMask(GL_TRUE);
        glEnable(GL_LIGHTING);

        // Scale entire teapot
        glPushMatrix();
        glScalef(g_scale, g_scale, g_scale);

        if (g_wireframe)
        {
            // Draw wireframe without lighting
            glDisable(GL_LIGHTING);
            glColor3f(0.5f, .5f, .5f);
            draw_teapot(false);
            glEnable(GL_LIGHTING);
        }
        else
        {
            // Draw fully lit teapot :)
            glColor3f(1, 1, 1);
            draw_lit_teapot(18);
        }

        // Restore transformation state
        glPopMatrix();
    });

    return menu(tasks, "Press 1 to start\n - ESC to exit\n - SPACE to toggle wireframe / filled\n - R to reset scene\n - Y/H to increase/decrease RED light\n - U/J to increase/decrease GREEN light\n - I/K to increase/decrease BLUE light\n - A/D to move light LEFT/RIGHT\n - W/S to move light UP/DOWN\n - Q/E to move light FORWARD/BACK\n - LMB + move mouse to rotate camera\n - Scroll to scale object\nAnything else to quit...\n", argc, argv);
}
