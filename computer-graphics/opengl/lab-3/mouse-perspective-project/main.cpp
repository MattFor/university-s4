#include "boilerplate.h"

int main(const int argc, char** argv)
{
    T tasks(
        []
        {
            static float theta  = 0.0f;
            static float phi    = 0.0f;
            static float radius = 10.0f;

            static float pixels2angle = 1.0f;

            static int left_pressed  = 0;
            static int right_pressed = 0;

            static double x_last = 0.0;
            static double y_last = 0.0;

            static float scale = 1.0f;

            static bool initialized = false;

            static int  timeout   = 0;
            static bool wireframe = false;

            if (!initialized)
            {
                initialized = true;

                glfwSetScrollCallback(window, [](GLFWwindow*, double, const double y_offset)
                {
                    scale += static_cast<float>(y_offset) * 0.1f;

                    if (scale < 0.1f)
                    {
                        scale = 0.1f;
                    }

                    if (scale > 10.0f)
                    {
                        scale = 10.0f;
                    }
                });

                glfwSetMouseButtonCallback(window, [](GLFWwindow* w, int const button, int const action, int)
                {
                    if (button == GLFW_MOUSE_BUTTON_LEFT)
                    {
                        left_pressed = action == GLFW_PRESS;
                    }

                    if (button == GLFW_MOUSE_BUTTON_RIGHT)
                    {
                        right_pressed = action == GLFW_PRESS;
                    }

                    double x, y;
                    glfwGetCursorPos(w, &x, &y);
                    x_last = x;
                    y_last = y;
                });

                glfwSetCursorPosCallback(window, [](GLFWwindow*, const double x, const double y)
                {
                    const double dx = x - x_last;
                    const double dy = y - y_last;

                    x_last = x;
                    y_last = y;

                    if (left_pressed)
                    {
                        theta += static_cast<float>(dx) * pixels2angle;
                        phi   += static_cast<float>(dy) * pixels2angle;
                    }

                    if (right_pressed)
                    {
                        radius += static_cast<float>(dy) * 0.05f;
                        if (radius < 2.0f)
                        {
                            radius = 2.0f;
                        }
                    }
                });

                glfwSetKeyCallback(window, [](GLFWwindow*, const int key, int, const int action, int)
                {
                    if (action == GLFW_PRESS && key == GLFW_KEY_R)
                    {
                        scale = 1.0f;
                        theta  = 0.0f;
                        phi    = 0.0f;
                        radius = 10.0f;
                    }
                });
            }

            int width, height;
            glfwGetFramebufferSize(window, &width, &height);
            pixels2angle = 360.0f / static_cast<float>(width);

            glLoadIdentity();
            glTranslatef(0.0f, 0.0f, -radius);

            // Rotation
            glRotatef(phi, 1.0f, 0.0f, 0.0f);
            glRotatef(theta, 0.0f, 1.0f, 0.0f);

            glColor3f(.5f, .5f, .5f);
            glPushMatrix();

            if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS)
            {
                if (timeout <= 0)
                {
                    wireframe = !wireframe;
                    timeout   = 65;
                }
            }

            glScalef(scale, scale, scale);
            draw_teapot(wireframe);

            glPopMatrix();

            timeout -= ( timeout > 0 ) * 2;
        }
    );

    return menu(tasks, "Press 1 to start the task.\n - SPACE to toggle between filled and wireframe\n - Use the mouse to rotate the object while Mouse1 is held\nAnything else to quit...\n", argc, argv);
}
