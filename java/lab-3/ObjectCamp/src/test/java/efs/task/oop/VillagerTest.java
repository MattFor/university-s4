package efs.task.oop;

import org.junit.Rule;
import org.junit.Test;
import org.junit.contrib.java.lang.system.SystemOutRule;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

public class VillagerTest
{

    @Rule
    public final SystemOutRule systemOutRule = new SystemOutRule().enableLog();
    final Class<?> clazz = Class.forName("efs.task.oop.Villager");

    public VillagerTest() throws Exception
    {
    }

    @Test
    public void shouldHaveCorrectName()
    {
        assertThat(clazz.getSimpleName()).isEqualTo("Villager");
    }

    @Test
    public void shouldHaveCorrectFields()
    {
        // given
        record Pair(String fieldName, Class<?> type)
        {
        }

        // when
        Field[] fields = clazz.getDeclaredFields();

        // then
        assertThat(Arrays.stream(fields).map(field -> new Pair(field.getName(), field.getType())).collect(Collectors.toList()))
                .containsExactlyInAnyOrder(
                        new Pair("name", java.lang.String.class),
                        new Pair("age", int.class),
                        new Pair("health", int.class)
                );
    }

    @Test
    public void shouldHaveCorrectConstructor()
    {
        // given

        // when
        Constructor<?>[] constructors = clazz.getConstructors();

        // then
        assertThat(constructors.length).isEqualTo(1);
        assertThat(Arrays.asList(constructors[0].getParameterTypes())).containsExactlyInAnyOrder(String.class, int.class);
    }

    @Test
    public void shouldPrintCorrectTextForSayHelloMethod() throws Exception
    {
        // given
        Method sayHello = clazz.getMethod("sayHello");
        Constructor<?> constructor = clazz.getConstructor(String.class, int.class);
        Object staszek = constructor.newInstance("Staszek", 52);

        // when
        sayHello.invoke(staszek);

        // then
        assertThat(systemOutRule.getLog()).contains("Greetings traveler... I'm Staszek and I'm 52 years old");
    }

    @Test
    public void shouldConstructObjectWithCorrectHealth() throws Exception
    {
        // given
        Method getHealth = clazz.getMethod("getHealth");
        Constructor<?> constructor = clazz.getConstructor(String.class, int.class);
        Object staszek = constructor.newInstance("Staszek", 52);

        // when
        int health = (int) getHealth.invoke(staszek);

        // then
        assertThat(health).isEqualTo(100);
    }

    @Test
    public void shouldImplementFighterInterface() throws Exception
    {
        // given
        Class<?> interfaze = Class.forName("efs.task.oop.Fighter");
        // when
        Class<?>[] interfaces = clazz.getInterfaces();

        // then
        assertThat(interfaces.length).isEqualTo(1);
        assertThat(interfaces[0]).isEqualTo(interfaze);
    }

    @Test
    public void shouldAttackWithCorrectDamage() throws Exception
    {
        // given
        Method attack = clazz.getMethod("attack", Class.forName("efs.task.oop.Fighter"));
        Method getHealth = clazz.getMethod("getHealth");
        Constructor<?> constructor = clazz.getConstructor(String.class, int.class);
        Object staszek = constructor.newInstance("Staszek", 100);
        Object jurek = constructor.newInstance("Jurek", 100);

        // when
        attack.invoke(staszek, jurek);

        // then
        assertThat(getHealth.invoke(jurek)).isEqualTo(95);
    }
}
