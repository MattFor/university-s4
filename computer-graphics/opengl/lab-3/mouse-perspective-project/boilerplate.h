//
// Created by mattfor on 4/23/26.
//

#ifndef MOUSEPERSPECTIVEPROJECT_BOILERPLATE_H
#define MOUSEPERSPECTIVEPROJECT_BOILERPLATE_H

#define RUNTIME 0

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

// LOL
static auto teapot_data = R"(
# The Utah Teapot
#
# Number of Vertices
#
306
#
# Vertex Coordinates
#
# Syntax: Vertex number - X - Y - Z
#
  1   1.40000   0.00000   2.40000
  2   1.40000  -0.78400   2.40000
  3   0.78000  -1.40000   2.40000
  4   0.00000  -1.40000   2.40000
  5   1.33750   0.00000   2.53125
  6   1.33750  -0.74900   2.53125
  7   0.74900  -1.33750   2.53125
  8   0.00000  -1.33750   2.53125
  9   1.43750   0.00000   2.53125
 10   1.43750  -0.80500   2.53125
 11   0.80500  -1.43750   2.53125
 12   0.00000  -1.43750   2.53125
 13   1.50000   0.00000   2.40000
 14   1.50000  -0.84000   2.40000
 15   0.84000  -1.50000   2.40000
 16   0.00000  -1.50000   2.40000
 17  -0.78400  -1.40000   2.40000
 18  -1.40000  -0.78400   2.40000
 19  -1.40000   0.00000   2.40000
 20  -0.74900  -1.33750   2.53125
 21  -1.33750  -0.74900   2.53125
 22  -1.33750   0.00000   2.53125
 23  -0.80500  -1.43750   2.53125
 24  -1.43750  -0.80500   2.53125
 25  -1.43750   0.00000   2.53125
 26  -0.84000  -1.50000   2.40000
 27  -1.50000  -0.84000   2.40000
 28  -1.50000   0.00000   2.40000
 29  -1.40000   0.78400   2.40000
 30  -0.78400   1.40000   2.40000
 31   0.00000   1.40000   2.40000
 32  -1.33750   0.74900   2.53125
 33  -0.74900   1.33750   2.53125
 34   0.00000   1.33750   2.53125
 35  -1.43750   0.80500   2.53125
 36  -0.80500   1.43750   2.53125
 37   0.00000   1.43750   2.53125
 38  -1.50000   0.84000   2.40000
 39  -0.84000   1.50000   2.40000
 40   0.00000   1.50000   2.40000
 41   0.78400   1.40000   2.40000
 42   1.40000   0.78400   2.40000
 43   0.74900   1.33750   2.53125
 44   1.33750   0.74900   2.53125
 45   0.80500   1.43750   2.53125
 46   1.43750   0.80500   2.53125
 47   0.84000   1.50000   2.40000
 48   1.50000   0.84000   2.40000
 49   1.75000   0.00000   1.87500
 50   1.75000  -0.98000   1.87500
 51   0.98000  -1.75000   1.87500
 52   0.00000  -1.75000   1.87500
 53   2.00000   0.00000   1.35000
 54   2.00000  -1.12000   1.35000
 55   1.12000  -2.00000   1.35000
 56   0.00000  -2.00000   1.35000
 57   2.00000   0.00000   0.90000
 58   2.00000  -1.12000   0.90000
 59   1.12000  -2.00000   0.90000
 60   0.00000  -2.00000   0.90000
 61  -0.98000  -1.75000   1.87500
 62  -1.75000  -0.98000   1.87500
 63  -1.75000   0.00000   1.87500
 64  -1.12000  -2.00000   1.35000
 65  -2.00000  -1.12000   1.35000
 66  -2.00000   0.00000   1.35000
 67  -1.12000  -2.00000   0.90000
 68  -2.00000  -1.12000   0.90000
 69  -2.00000   0.00000   0.90000
 70  -1.75000   0.98000   1.87500
 71  -0.98000   1.75000   1.87500
 72   0.00000   1.75000   1.87500
 73  -2.00000   1.12000   1.35000
 74  -1.12000   2.00000   1.35000
 75   0.00000   2.00000   1.35000
 76  -2.00000   1.12000   0.90000
 77  -1.12000   2.00000   0.90000
 78   0.00000   2.00000   0.90000
 79   0.98000   1.75000   1.87500
 80   1.75000   0.98000   1.87500
 81   1.12000   2.00000   1.35000
 82   2.00000   1.12000   1.35000
 83   1.12000   2.00000   0.90000
 84   2.00000   1.12000   0.90000
 85   2.00000   0.00000   0.45000
 86   2.00000  -1.12000   0.45000
 87   1.12000  -2.00000   0.45000
 88   0.00000  -2.00000   0.45000
 89   1.50000   0.00000   0.22500
 90   1.50000  -0.84000   0.22500
 91   0.84000  -1.50000   0.22500
 92   0.00000  -1.50000   0.22500
 93   1.50000   0.00000   0.15000
 94   1.50000  -0.84000   0.15000
 95   0.84000  -1.50000   0.15000
 96   0.00000  -1.50000   0.15000
 97  -1.12000  -2.00000   0.45000
 98  -2.00000  -1.12000   0.45000
 99  -2.00000   0.00000   0.45000
100  -0.84000  -1.50000   0.22500
101  -1.50000  -0.84000   0.22500
102  -1.50000   0.00000   0.22500
103  -0.84000  -1.50000   0.15000
104  -1.50000  -0.84000   0.15000
105  -1.50000   0.00000   0.15000
106  -2.00000   1.12000   0.45000
107  -1.12000   2.00000   0.45000
108   0.00000   2.00000   0.45000
109  -1.50000   0.84000   0.22500
110  -0.84000   1.50000   0.22500
111   0.00000   1.50000   0.22500
112  -1.50000   0.84000   0.15000
113  -0.84000   1.50000   0.15000
114   0.00000   1.50000   0.15000
115   1.12000   2.00000   0.45000
116   2.00000   1.12000   0.45000
117   0.84000   1.50000   0.22500
118   1.50000   0.84000   0.22500
119   0.84000   1.50000   0.15000
120   1.50000   0.84000   0.15000
121  -1.60000   0.00000   2.02500
122  -1.60000  -0.30000   2.02500
123  -1.50000  -0.30000   2.25000
124  -1.50000   0.00000   2.25000
125  -2.30000   0.00000   2.02500
126  -2.30000  -0.30000   2.02500
127  -2.50000  -0.30000   2.25000
128  -2.50000   0.00000   2.25000
129  -2.70000   0.00000   2.02500
130  -2.70000  -0.30000   2.02500
131  -3.00000  -0.30000   2.25000
132  -3.00000   0.00000   2.25000
133  -2.70000   0.00000   1.80000
134  -2.70000  -0.30000   1.80000
135  -3.00000  -0.30000   1.80000
136  -3.00000   0.00000   1.80000
137  -1.50000   0.30000   2.25000
138  -1.60000   0.30000   2.02500
139  -2.50000   0.30000   2.25000
140  -2.30000   0.30000   2.02500
141  -3.00000   0.30000   2.25000
142  -2.70000   0.30000   2.02500
143  -3.00000   0.30000   1.80000
144  -2.70000   0.30000   1.80000
145  -2.70000   0.00000   1.57500
146  -2.70000  -0.30000   1.57500
147  -3.00000  -0.30000   1.35000
148  -3.00000   0.00000   1.35000
149  -2.50000   0.00000   1.12500
150  -2.50000  -0.30000   1.12500
151  -2.65000  -0.30000   0.93750
152  -2.65000   0.00000   0.93750
153  -2.00000  -0.30000   0.90000
154  -1.90000  -0.30000   0.60000
155  -1.90000   0.00000   0.60000
156  -3.00000   0.30000   1.35000
157  -2.70000   0.30000   1.57500
158  -2.65000   0.30000   0.93750
159  -2.50000   0.30000   1.12500
160  -1.90000   0.30000   0.60000
161  -2.00000   0.30000   0.90000
162   1.70000   0.00000   1.42500
163   1.70000  -0.66000   1.42500
164   1.70000  -0.66000   0.60000
165   1.70000   0.00000   0.60000
166   2.60000   0.00000   1.42500
167   2.60000  -0.66000   1.42500
168   3.10000  -0.66000   0.82500
169   3.10000   0.00000   0.82500
170   2.30000   0.00000   2.10000
171   2.30000  -0.25000   2.10000
172   2.40000  -0.25000   2.02500
173   2.40000   0.00000   2.02500
174   2.70000   0.00000   2.40000
175   2.70000  -0.25000   2.40000
176   3.30000  -0.25000   2.40000
177   3.30000   0.00000   2.40000
178   1.70000   0.66000   0.60000
179   1.70000   0.66000   1.42500
180   3.10000   0.66000   0.82500
181   2.60000   0.66000   1.42500
182   2.40000   0.25000   2.02500
183   2.30000   0.25000   2.10000
184   3.30000   0.25000   2.40000
185   2.70000   0.25000   2.40000
186   2.80000   0.00000   2.47500
187   2.80000  -0.25000   2.47500
188   3.52500  -0.25000   2.49375
189   3.52500   0.00000   2.49375
190   2.90000   0.00000   2.47500
191   2.90000  -0.15000   2.47500
192   3.45000  -0.15000   2.51250
193   3.45000   0.00000   2.51250
194   2.80000   0.00000   2.40000
195   2.80000  -0.15000   2.40000
196   3.20000  -0.15000   2.40000
197   3.20000   0.00000   2.40000
198   3.52500   0.25000   2.49375
199   2.80000   0.25000   2.47500
200   3.45000   0.15000   2.51250
201   2.90000   0.15000   2.47500
202   3.20000   0.15000   2.40000
203   2.80000   0.15000   2.40000
204   0.00000   0.00000   3.15000
205   0.00000  -0.00200   3.15000
206   0.00200   0.00000   3.15000
207   0.80000   0.00000   3.15000
208   0.80000  -0.45000   3.15000
209   0.45000  -0.80000   3.15000
210   0.00000  -0.80000   3.15000
211   0.00000   0.00000   2.85000
212   0.20000   0.00000   2.70000
213   0.20000  -0.11200   2.70000
214   0.11200  -0.20000   2.70000
215   0.00000  -0.20000   2.70000
216  -0.00200   0.00000   3.15000
217  -0.45000  -0.80000   3.15000
218  -0.80000  -0.45000   3.15000
219  -0.80000   0.00000   3.15000
220  -0.11200  -0.20000   2.70000
221  -0.20000  -0.11200   2.70000
222  -0.20000   0.00000   2.70000
223   0.00000   0.00200   3.15000
224  -0.80000   0.45000   3.15000
225  -0.45000   0.80000   3.15000
226   0.00000   0.80000   3.15000
227  -0.20000   0.11200   2.70000
228  -0.11200   0.20000   2.70000
229   0.00000   0.20000   2.70000
230   0.45000   0.80000   3.15000
231   0.80000   0.45000   3.15000
232   0.11200   0.20000   2.70000
233   0.20000   0.11200   2.70000
234   0.40000   0.00000   2.55000
235   0.40000  -0.22400   2.55000
236   0.22400  -0.40000   2.55000
237   0.00000  -0.40000   2.55000
238   1.30000   0.00000   2.55000
239   1.30000  -0.72800   2.55000
240   0.72800  -1.30000   2.55000
241   0.00000  -1.30000   2.55000
242   1.30000   0.00000   2.40000
243   1.30000  -0.72800   2.40000
244   0.72800  -1.30000   2.40000
245   0.00000  -1.30000   2.40000
246  -0.22400  -0.40000   2.55000
247  -0.40000  -0.22400   2.55000
248  -0.40000   0.00000   2.55000
249  -0.72800  -1.30000   2.55000
250  -1.30000  -0.72800   2.55000
251  -1.30000   0.00000   2.55000
252  -0.72800  -1.30000   2.40000
253  -1.30000  -0.72800   2.40000
254  -1.30000   0.00000   2.40000
255  -0.40000   0.22400   2.55000
256  -0.22400   0.40000   2.55000
257   0.00000   0.40000   2.55000
258  -1.30000   0.72800   2.55000
259  -0.72800   1.30000   2.55000
260   0.00000   1.30000   2.55000
261  -1.30000   0.72800   2.40000
262  -0.72800   1.30000   2.40000
263   0.00000   1.30000   2.40000
264   0.22400   0.40000   2.55000
265   0.40000   0.22400   2.55000
266   0.72800   1.30000   2.55000
267   1.30000   0.72800   2.55000
268   0.72800   1.30000   2.40000
269   1.30000   0.72800   2.40000
270   0.00000   0.00000   0.00000
271   1.50000   0.00000   0.15000
272   1.50000   0.84000   0.15000
273   0.84000   1.50000   0.15000
274   0.00000   1.50000   0.15000
275   1.50000   0.00000   0.07500
276   1.50000   0.84000   0.07500
277   0.84000   1.50000   0.07500
278   0.00000   1.50000   0.07500
279   1.42500   0.00000   0.00000
280   1.42500   0.79800   0.00000
281   0.79800   1.42500   0.00000
282   0.00000   1.42500   0.00000
283  -0.84000   1.50000   0.15000
284  -1.50000   0.84000   0.15000
285  -1.50000   0.00000   0.15000
286  -0.84000   1.50000   0.07500
287  -1.50000   0.84000   0.07500
288  -1.50000   0.00000   0.07500
289  -0.79800   1.42500   0.00000
290  -1.42500   0.79800   0.00000
291  -1.42500   0.00000   0.00000
292  -1.50000  -0.84000   0.15000
293  -0.84000  -1.50000   0.15000
294   0.00000  -1.50000   0.15000
295  -1.50000  -0.84000   0.07500
296  -0.84000  -1.50000   0.07500
297   0.00000  -1.50000   0.07500
298  -1.42500  -0.79800   0.00000
299  -0.79800  -1.42500   0.00000
300   0.00000  -1.42500   0.00000
301   0.84000  -1.50000   0.15000
302   1.50000  -0.84000   0.15000
303   0.84000  -1.50000   0.07500
304   1.50000  -0.84000   0.07500
305   0.79800  -1.42500   0.00000
306   1.42500  -0.79800   0.00000
#
# Body (Bezier Patches)
#
# Syntax: Patch number - Vertex indices (16)
#
 1	  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16
 2	  4  17  18  19   8  20  21  22  12  23  24  25  16  26  27  28
 3	 19  29  30  31  22  32  33  34  25  35  36  37  28  38  39  40
 4	 31  41  42   1  34  43  44   5  37  45  46   9  40  47  48  13
 5	 13  14  15  16  49  50  51  52  53  54  55  56  57  58  59  60
 6	 16  26  27  28  52  61  62  63  56  64  65  66  60  67  68  69
 7	 28  38  39  40  63  70  71  72  66  73  74  75  69  76  77  78
 8	 40  47  48  13  72  79  80  49  75  81  82  53  78  83  84  57
 9	 57  58  59  60  85  86  87  88  89  90  91  92  93  94  95  96
10	 60  67  68  69  88  97  98  99  92 100 101 102  96 103 104 105
11	 69  76  77  78  99 106 107 108 102 109 110 111 105 112 113 114
12	 78  83  84  57 108 115 116  85 111 117 118  89 114 119 120  93
#
# Handle (Bezier Patches)
#
# Syntax: Patch number - Vertex indices (16)
#
13	121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136
14	124 137 138 121 128 139 140 125 132 141 142 129 136 143 144 133
15	133 134 135 136 145 146 147 148 149 150 151 152  69 153 154 155
16	136 143 144 133 148 156 157 145 152 158 159 149 155 160 161  69
#
# Spout (Bezier Patches)
#
# Syntax: Patch number - Vertex indices (16)
#
17	162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177
18	165 178 179 162 169 180 181 166 173 182 183 170 177 184 185 174
19	174 175 176 177 186 187 188 189 190 191 192 193 194 195 196 197
20	177 184 185 174 189 198 199 186 193 200 201 190 197 202 203 194
#
# Lid (Bezier Patches)
#
# Syntax: Patch number - Vertex indices (16)
#
21	204 204 204 204 207 208 209 210 211 211 211 211 212 213 214 215
22	204 204 204 204 210 217 218 219 211 211 211 211 215 220 221 222
23	204 204 204 204 219 224 225 226 211 211 211 211 222 227 228 229
24	204 204 204 204 226 230 231 207 211 211 211 211 229 232 233 212
25	212 213 214 215 234 235 236 237 238 239 240 241 242 243 244 245
26	215 220 221 222 237 246 247 248 241 249 250 251 245 252 253 254
27	222 227 228 229 248 255 256 257 251 258 259 260 254 261 262 263
28	229 232 233 212 257 264 265 234 260 266 267 238 263 268 269 242
#
# Bottom (Bezier Patches)
#
# Syntax: Patch number - Vertex indices (16)
#
29	270 270 270 270 279 280 281 282 275 276 277 278  93 120 119 114
30	270 270 270 270 282 289 290 291 278 286 287 288 114 113 112 105
31	270 270 270 270 291 298 299 300 288 295 296 297 105 104 103  96
32	270 270 270 270 300 305 306 279 297 303 304 275  96  95  94  93
)";

struct settings
{
    // ReSharper disable once CppDeclaratorNeverUsed
    GLFWwindow* window = nullptr;

    float x_angle = 0.;
    float y_angle = 0.;
    float v_angle = 0.35;
    float scale   = 1.;
};

inline std::string get_task_name(const int task_id)
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

struct TeapotModel
{
    struct P
    {
        float x, y, z;
    };

    std::vector<P>                   points;
    std::vector<std::array<int, 16>> patches;

    bool loaded = false;
};

static TeapotModel& get_teapot_model()
{
    static TeapotModel model;

    // If already loaded, skip reloading
    if (model.loaded)
    {
        return model;
    }

    // Open teapot data (it has vertices + Bezier patch information)
    std::stringstream data(teapot_data);

    // Preallocate space for all possible vertex indices 0 – 306
    // This allows direct indexing without resizing which would be EXPENSIVE
    model.points.assign(307, TeapotModel::P{});

    // Clear any previous patch data
    model.patches.clear();

    std::string line;
    while (std::getline(data, line))
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
            const std::size_t offset = nums.size() == 17 ? 1 : 0;

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
        std::print("Teapot failed to load!\n");
    }

    return model;
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

    // Get the model in a new way
    const auto& model = get_teapot_model();

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

inline bool init_program(GLFWwindow*& window, const char* title)
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

    glfwSwapInterval(0);

    init_opengl();

    glfwSetFramebufferSizeCallback(window, reshape_window);

    int fbw = 0;
    int fbh = 0;
    glfwGetFramebufferSize(window, &fbw, &fbh);
    reshape_window(window, fbw, fbh);

    return true;
}

inline GLFWwindow* window = nullptr;

static void run_windowed(const char* title, const std::function<void(GLFWwindow*)>& frame)
{
    GLFWwindow* local_window = nullptr;

    if (!init_program(local_window, title))
    {
        return;
    }

    window = local_window;

    glfwSetKeyCallback(local_window, [](GLFWwindow* w, const int key, int, const int action, int)
    {
        if (action == GLFW_PRESS && key == GLFW_KEY_ESCAPE)
        {
            glfwSetWindowShouldClose(w, GLFW_TRUE);
        }
    });

    while (!glfwWindowShouldClose(local_window))
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

        // Make axes always on the back
        glDepthMask(GL_FALSE);
        draw_scene_axes();
        glDepthMask(GL_TRUE);

        frame(local_window);

        glfwSwapBuffers(local_window);
        glfwPollEvents();
    }

    glfwDestroyWindow(local_window);
    glfwTerminate();

    window = nullptr;
}

inline bool running = true;

#if RUNTIME
class T
{
    std::vector<std::function<void()>> frames;

public:
    T(const std::initializer_list<std::function<void()>> init)
        : frames(init)
    {}

    std::function<void()> operator[](const int choice) const
    {
        if (choice >= 1 && choice <= static_cast<int>(frames.size()))
        {
            const int idx = choice - 1;

            return [this, idx]
            {
                run_windowed(get_task_name(idx + 1).c_str(), [this, idx](GLFWwindow*)
                {
                    frames[idx]();
                });
            };
        }

        return []
        {
            std::print("Stopping program...\n");
            running = false;
        };
    }
};
#else
template <typename... Fs>
class T
{
    std::tuple<Fs...> frames;

public:
    explicit constexpr T(Fs... fs)
        : frames(std::move(fs)...)
    {}

    auto operator[](int choice) const
    {
        return [this, choice]
        {
            if (choice >= 1 && choice <= sizeof...(Fs))
            {
                std::apply([&](auto const&... fns)
                {
                    int i = 1;
                    (( i++ == choice
                           ? run_windowed(get_task_name(i - 1).c_str(), [&](GLFWwindow*)
                           {
                               fns();
                           })
                           : void() ), ...);
                }, frames);
            }
            else
            {
                std::print("Stopping program...\n");
                running = false;
            }
        };
    }
};
#endif

inline bool parse_choice_arg(const int argc, char** argv, int& choice)
{
    if (argc < 2)
    {
        return true;
    }

    errno     = 0;
    char* end = nullptr;

    if (const long value = std::strtol(argv[1], &end, 10); end != argv[1] && *end == '\0' && errno != ERANGE && value >= INT_MIN && value <= INT_MAX)
    {
        choice = static_cast<int>(value);
        return true;
    }

    std::print("Invalid argument!\n");
    return false;
}

template <class TaskList>
int menu(TaskList& tasks, const std::string& menu, const int argc, char** argv)
{
    int choice = 0;

    if (!parse_choice_arg(argc, argv, choice))
    {
        return 1;
    }

    if (argc >= 2)
    {
        tasks[choice]();
        return 0;
    }

    while (running)
    {
        std::print("{}", menu);

        if (!( std::cin >> choice ))
        {
            std::print("Invalid input, quitting!\n");
            return 1;
        }

        tasks[choice]();
    }

    return 0;
}

#endif //MOUSEPERSPECTIVEPROJECT_BOILERPLATE_H
