package efs.task.reflection;

import java.util.Set;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashSet;
import java.lang.reflect.Method;
import java.lang.reflect.Constructor;
import java.lang.annotation.Annotation;

public class ClassInspector
{
    /**
     * Metoda powinna wyszukać we wszystkich zadeklarowanych przez klasę polach te które oznaczone
     * są adnotacją podaną jako drugi parametr wywołania tej metody. Wynik powinien zawierać tylko
     * unikalne nazwy pól (bez powtórzeń).
     */
    public static Collection<String> getAnnotatedFields(final Class<?> type, final Class<? extends Annotation> annotation)
    {
        Set<String> result = new LinkedHashSet<>();

        if (type == null || annotation == null)
        {
            return new ArrayList<>(result);
        }

        for (var field : type.getDeclaredFields())
        {
            if (field.isAnnotationPresent(annotation))
            {
                result.add(field.getName());
            }
        }

        return new ArrayList<>(result);
    }

    /**
     * Metoda powinna wyszukać wszystkie zadeklarowane bezpośrednio w klasie metody oraz te
     * implementowane przez nią pochodzące z interfejsów, które implementuje. Wynik powinien zawierać
     * tylko unikalne nazwy metod (bez powtórzeń).
     */
    public static Collection<String> getAllDeclaredMethods(final Class<?> type)
    {
        Set<String> result = new LinkedHashSet<>();

        if (type == null)
        {
            return new ArrayList<>(result);
        }

        for (Method method : type.getDeclaredMethods())
        {
            result.add(method.getName());
        }

        collectInterfaceMethods(type, result);

        return new ArrayList<>(result);
    }

    private static void collectInterfaceMethods(Class<?> type, Set<String> result)
    {
        for (Class<?> iface : type.getInterfaces())
        {
            for (Method method : iface.getDeclaredMethods())
            {
                result.add(method.getName());
            }
            collectInterfaceMethods(iface, result);
        }
    }

    /**
     * Metoda powinna odszukać konstruktor zadeklarowany w podanej klasie który przyjmuje wszystkie
     * podane parametry wejściowe.
     */
    @SuppressWarnings("unchecked")
    public static <T> T createInstance(final Class<T> type, final Object... args) throws Exception
    {
        if (type == null)
        {
            throw new IllegalArgumentException("type cannot be null");
        }

        Object[] parameters = args == null ? new Object[0] : args;

        for (Constructor<?> constructor : type.getDeclaredConstructors())
        {
            Class<?>[] parameterTypes = constructor.getParameterTypes();

            if (parameterTypes.length != parameters.length)
            {
                continue;
            }

            boolean matches = true;

            for (int i = 0; i < parameterTypes.length; i++)
            {
                Object arg = parameters[i];
                Class<?> expectedType = parameterTypes[i];

                if (!isCompatible(expectedType, arg))
                {
                    matches = false;
                    break;
                }
            }

            if (matches)
            {
                constructor.setAccessible(true);
                return (T) constructor.newInstance(parameters);
            }
        }

        throw new NoSuchMethodException("No matching constructor found for " + type.getName());
    }

    private static boolean isCompatible(Class<?> expectedType, Object arg)
    {
        if (arg == null)
        {
            return !expectedType.isPrimitive();
        }

        Class<?> actualType = arg.getClass();

        if (expectedType.isPrimitive())
        {
            return primitiveToWrapper(expectedType).isAssignableFrom(actualType);
        }

        return expectedType.isAssignableFrom(actualType);
    }

    private static Class<?> primitiveToWrapper(Class<?> primitive)
    {
        if (primitive == boolean.class)
        {
            return Boolean.class;
        }

        if (primitive == byte.class)
        {
            return Byte.class;
        }

        if (primitive == char.class)
        {
            return Character.class;
        }

        if (primitive == short.class)
        {
            return Short.class;
        }

        if (primitive == int.class)
        {
            return Integer.class;
        }

        if (primitive == long.class)
        {
            return Long.class;
        }

        if (primitive == float.class)
        {
            return Float.class;
        }

        if (primitive == double.class)
        {
            return Double.class;
        }

        return primitive;
    }
}