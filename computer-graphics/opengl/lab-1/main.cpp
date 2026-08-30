#include <print>
#include <climits>
#include <iostream>

#include <GL/gl.h>
#include <GLFW/glfw3.h>

constexpr int WINDOW_W = 700;
constexpr int WINDOW_H = 700;

void setup_2d(const int width, int height)
{
    if (height <= 0)
    {
        height = 1;
    }

    glViewport(0, 0, width, height);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-100.0, 100.0, -100.0, 100.0, -1.0, 1.0);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

void framebuffer_size_callback(GLFWwindow*, const int width, const int height)
{
    setup_2d(width, height);
}

bool init_window(GLFWwindow*& window, const char* title)
{
    if (!glfwInit())
    {
        std::print("Error: glfwInit() failed!\n");
        return false;
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

    window = glfwCreateWindow(WINDOW_W, WINDOW_H, title, nullptr, nullptr);
    if (!window)
    {
        std::print("Error: glfwCreateWindow() failed!\n");
        glfwTerminate();
        return false;
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);

    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    int fbw = 0, fbh = 0;
    glfwGetFramebufferSize(window, &fbw, &fbh);
    setup_2d(fbw, fbh);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glShadeModel(GL_SMOOTH);

    return true;
}

void draw_task1()
{
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();

    constexpr float left_x   = -55.0f;
    constexpr float right_x  = 55.0f;
    constexpr float bottom_y = -30.0f;
    constexpr float top_y    = 55.0f;

    glBegin(GL_TRIANGLES);

    // Red
    glColor3f(1.0f, 0.0f, 0.0f);
    glVertex2f(left_x, bottom_y);

    // Green
    glColor3f(0.0f, 1.0f, 0.0f);
    glVertex2f(0.0f, top_y);

    // Blue
    glColor3f(0.0f, 0.0f, 1.0f);
    glVertex2f(right_x, bottom_y);

    glEnd();
    glFlush();
}

void draw_square(const float x, const float y, const float size)
{
    const float left   = x;
    const float right  = x + size;
    const float bottom = y;
    const float top    = y + size;

    glBegin(GL_QUADS);

    glVertex2f(left, bottom);
    glVertex2f(right, bottom);
    glVertex2f(right, top);
    glVertex2f(left, top);

    glEnd();
}

void sierpinski_carpet(const float x, const float y, const float size, const int depth)
{
    if (depth <= 0)
    {
        draw_square(x, y, size);
        return;
    }

    const float step = size / 3.0f;
    for (int row = 0; row < 3; ++row)
    {
        for (int col = 0; col < 3; ++col)
        {
            // Delete middle square
            if (row == 1 && col == 1)
            {
                continue;
            }

            sierpinski_carpet(x + static_cast<float>(col) * step, y + static_cast<float>(row) * step, step, depth - 1);
        }
    }
}

void draw_task2(const int iterations)
{
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();

    glColor3f(0.75f, 0.30f, 0.05f);
    sierpinski_carpet(-60.0f, -60.0f, 120.0f, iterations);

    glFlush();
}

int run_task1()
{
    GLFWwindow* window = nullptr;

    if (!init_window(window, "Lab 1 - Zad 1 - REDACTED 155197"))
    {
        return 1;
    }

    while (!glfwWindowShouldClose(window))
    {
        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        {
            glfwSetWindowShouldClose(window, GLFW_TRUE);
        }

        draw_task1();
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}

int run_task2()
{
    int iterations = 0;
    std::print("Input iteration count for Sierpiński's carpet (max 9): ");
    std::cin >> iterations;

    iterations = std::clamp(iterations, 0, 9);

    GLFWwindow* window = nullptr;

    if (!init_window(window, "Lab 1 - Zad 2 - REDACTED 155197"))
    {
        return 1;
    }

    while (!glfwWindowShouldClose(window))
    {
        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        {
            glfwSetWindowShouldClose(window, GLFW_TRUE);
        }

        draw_task2(iterations);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}

#if defined(LAB1_ZAD1)
int main()
{
    run_task1();
}
#elif defined(LAB1_ZAD2)
int main()
{
    run_task2();
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
            std::print("Invalid argument!");
            return 1;
        }
    }
    else
    {
        std::print("Choose lab:\n" "1 -> Ex1 (triangle)\n" "2 -> Ex2 (carpet)\n");

        if (!( std::cin >> choice ))
        {
            std::print("Error reading input!");
            return 1;
        }
    }

    switch (choice)
    {
        case 1:
        {
            return run_task1();
        }
        case 2:
        {
            return run_task2();
        }
        default:
        {
            std::print("Wrong choice!");
        }
    }
}
#endif
