package efs.task.oop;

import org.junit.Test;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

import static org.assertj.core.api.Assertions.assertThat;

public class MonstersTest
{

    @Test
    public void shouldHaveCorrectFields() throws Exception
    {
        // given
        Class<?> monsterClass = Class.forName("efs.task.oop.Monster");
        Class<?> clazz = Class.forName("efs.task.oop.Monsters");

        // when
        Field[] fields = clazz.getDeclaredFields();

        // then
        assertThat(fields.length).isEqualTo(3);
        assertThat(fields[0].getName()).isEqualTo("andariel");
        assertThat(fields[0].getType()).isEqualTo(monsterClass);
        assertThat(Modifier.isStatic(fields[0].getModifiers())).isEqualTo(true);
        assertThat(Modifier.isFinal(fields[0].getModifiers())).isEqualTo(true);
        assertThat(fields[1].getName()).isEqualTo("blacksmith");
        assertThat(fields[1].getType()).isEqualTo(monsterClass);
        assertThat(Modifier.isStatic(fields[1].getModifiers())).isEqualTo(true);
        assertThat(Modifier.isFinal(fields[1].getModifiers())).isEqualTo(true);
        assertThat(fields[2].getName()).isEqualTo("monstersHealth");
        assertThat(fields[2].getType()).isEqualTo(int.class);
    }
}
