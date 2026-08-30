package efs.task.oop;

import org.junit.Test;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

public class MonsterTest
{

    final Class<?> clazz = Class.forName("efs.task.oop.Monster");

    public MonsterTest() throws ClassNotFoundException
    {
    }

    @Test
    public void shouldHaveCorrectFields()
    {
        // given

        // when
        Field[] fields = clazz.getDeclaredFields();
        record Pair(String fieldName, Class<?> type)
        {
        }

        assertThat(Arrays.stream(fields).map(field -> new Pair(field.getName(), field.getType())).collect(Collectors.toList()))
                .containsExactlyInAnyOrder(
                        new Pair("health", int.class),
                        new Pair("damage", int.class)
                );
    }

    @Test
    public void shouldImplementFighterInterface() throws Exception
    {
        // given
        Class<?> interfaze = Class.forName("efs.task.oop.Fighter");
        // when
        Class<?>[] interfaces = clazz.getInterfaces();

        // then
        assertThat(interfaces).containsExactly(interfaze);
    }

    @Test
    public void shouldHaveCorrectConstructor()
    {
        // when
        Constructor<?>[] constructors = clazz.getConstructors();

        // then
        assertThat(constructors.length).isEqualTo(1);
        assertThat(Arrays.asList(constructors[0].getParameterTypes())).containsExactlyInAnyOrder(int.class, int.class);
    }
}
