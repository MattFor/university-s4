package efs.task.oop;

import org.junit.Rule;
import org.junit.Test;
import org.junit.contrib.java.lang.system.SystemOutRule;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

public class ExtraordinaryVillagerTest
{
    @Rule
    public final SystemOutRule systemOutRule = new SystemOutRule().enableLog();

    final Class<?> clazz = Class.forName("efs.task.oop.ExtraordinaryVillager");
    final Class<?> innerClazz = Class.forName("efs.task.oop.ExtraordinaryVillager$Skill");
    final Class<?> superClazz = Class.forName("efs.task.oop.Villager");

    final Object skill = innerClazz.getEnumConstants()[0];

    public ExtraordinaryVillagerTest() throws Exception
    {
    }

    @Test
    public void shouldHaveCorrectName()
    {
        assertThat(clazz.getSimpleName()).isEqualTo("ExtraordinaryVillager");
    }

    @Test
    public void shouldBeSubclassOfVillager()
    {
        assertThat(clazz.getSuperclass()).isEqualTo(superClazz);
    }

    @Test
    public void shouldContainInnerClass()
    {
        assertThat(clazz.getClasses()[0]).isEqualTo(innerClazz);
    }

    @Test
    public void shouldContainCorrectValuesInInnerClass()
    {
        // when
        Object[] enumConstants = innerClazz.getEnumConstants();
        List<String> enumConstantsString = List.of(enumConstants[0].toString(), enumConstants[1].toString());

        // then
        assertThat(enumConstantsString).containsExactlyInAnyOrder("IDENTIFY", "SHELTER");
    }

    @Test
    public void shouldHaveSkillField()
    {
        // when
        Field[] fields = clazz.getDeclaredFields();

        // then
        assertThat(fields.length).isEqualTo(1);
        assertThat(fields[0].getName()).isEqualTo("skill");
        assertThat(fields[0].getType()).isEqualTo(innerClazz);
    }

    @Test
    public void shouldHaveCorrectConstructor()
    {
        // when
        Constructor<?>[] constructors = clazz.getConstructors();

        // then
        assertThat(constructors.length).isEqualTo(1);
        assertThat(Arrays.asList(constructors[0].getParameterTypes())).containsExactlyInAnyOrder(String.class, int.class, innerClazz);
    }

    @Test
    public void shouldPrintCorrectTextForSayHelloMethod() throws Exception
    {
        // given
        Method sayHello = clazz.getMethod("sayHello");
        Constructor<?> constructor = clazz.getConstructor(String.class, int.class, innerClazz);
        Object staszek = constructor.newInstance("Staszek", 52, skill);

        // when
        sayHello.invoke(staszek);

        // then
        assertThat(systemOutRule.getLog()).contains("Greetings traveler... I'm Staszek and I'm 52 years old. " + "I will identify items for you at no charge");
    }

    @Test
    public void shouldAttackWithZeroDamage() throws Exception
    {
        // given
        Method attack = clazz.getMethod("attack", Class.forName("efs.task.oop.Fighter"));
        Method getHealth = clazz.getMethod("getHealth");
        Constructor<?> constructor = clazz.getConstructor(String.class, int.class, innerClazz);
        Constructor<?> superConstructor = superClazz.getConstructor(String.class, int.class);
        Object staszek = constructor.newInstance("Staszek", 100, skill);
        Object jurek = superConstructor.newInstance("Jurek", 100);

        // when
        attack.invoke(staszek, jurek);

        // then
        assertThat(getHealth.invoke(jurek)).isEqualTo(100);
    }

    @Test
    public void shouldDieAfterOneHit() throws Exception
    {
        // given
        Method attack = clazz.getMethod("attack", Class.forName("efs.task.oop.Fighter"));
        Method getHealth = clazz.getMethod("getHealth");
        Constructor<?> constructor = clazz.getConstructor(String.class, int.class, innerClazz);
        Object staszek = constructor.newInstance("Staszek", 100, skill);
        Object jurek = constructor.newInstance("Jurek", 100, skill);

        // when
        attack.invoke(jurek, staszek);

        // then
        assertThat(getHealth.invoke(staszek)).isEqualTo(0);
    }
}
