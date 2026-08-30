package efs.task.oop;

import org.junit.Rule;
import org.junit.Test;
import org.junit.contrib.java.lang.system.SystemOutRule;

import static org.assertj.core.api.Assertions.assertThat;

public class MainTest
{

    @Rule
    public final SystemOutRule systemOutRule = new SystemOutRule().enableLog();

    @Test
    public void shouldContainCorrectPrintouts()
    {
        // given

        // when
        Main.main(new String[]{});

        // then
        assertThat(systemOutRule.getLog()).contains("Greetings traveler... I'm Kashya and I'm 30 years old");
        assertThat(systemOutRule.getLog()).contains("Greetings traveler... I'm Akara and I'm 40 years old. " + "I can offer you poor shelter");
        assertThat(systemOutRule.getLog()).contains("Greetings traveler... I'm Gheed and I'm 50 years old");
        assertThat(systemOutRule.getLog()).contains("Greetings traveler... I'm Deckard Cain and I'm 85 years old. " + "I will identify items for you at no charge.");
        assertThat(systemOutRule.getLog()).contains("Greetings traveler... I'm Warriv and I'm 35 years old");
        assertThat(systemOutRule.getLog()).contains("Greetings traveler... I'm Flawia and I'm 25 years old");
        assertThat(systemOutRule.getLog()).contains("Potwory posiadaja jeszcze");
        assertThat(systemOutRule.getLog()).contains("Aktualnie walczacy osadnik to");
        assertThat(systemOutRule.getLog()).contains("Obozowisko ocalone!");
        assertThat(systemOutRule.getLog()).contains("Potwory posiadaja jeszcze ");
        assertThat(systemOutRule.getLog()).contains("Aktualnie walczacy osadnik to ");
    }
}
