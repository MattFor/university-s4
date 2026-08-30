package efs.task.functional;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class PersonSpeakersTest
{

    Person tim = new Person("Tim", 24, "Miami", Country.USA);
    Person julka = new Person("Julka", 22, "Bydgoszcz", Country.PL);
    Person gertruda = new Person("Gertruda", 27, "Berlin", Country.DE);

    private final PersonSpeakers underTest = new PersonSpeakers();

    @Test
    public void canGreet()
    {
        String returnedText = underTest.createGreetSpeaker().say(julka);

        assertThat(returnedText)
                .describedAs("Niepoprawny tekst zwrócony po wywołaniu metody say() " +
                        "Speaker'a utworzonego w metodzie createGreetSpeaker(). Upewnij się, że została użyta stała HELLO," +
                        " imię osoby oraz, że nie zostały dodane zbędne białe znaki.")
                .contains("Hello. I'm Julka");
    }

    @Test
    public void canGreetInShoutingWay()
    {
        String returnedText = underTest.createShoutingSpeaker().say(julka);

        assertThat(returnedText)
                .describedAs("Niepoprawny tekst zwrócony po wywołaniu metody say() " +
                        "Speaker'a utworzonego w metodzie createShoutingSpeaker(). Upewnij się, że została użyta stała HELLO," +
                        " imię osoby, zostały one prawidłowo sformatowane oraz, że nie zostały dodane zbędne znaki.")
                .contains("HELLO. I'M JULKA");
    }

    @Test
    public void canGreetLocalPL()
    {
        String returnedText = underTest.createGreetLocalSpeaker().say(julka);

        assertThat(returnedText)
                .describedAs("Niepoprawny tekst zwrócony po wywołaniu metody say() " +
                        "Speaker'a utworzonego w metodzie createGreetLocalSpeaker() dla języka polskiego. " +
                        "Upewnij się, że została użyta odpowiednia stała, imię osoby, oraz że nie zostały dodane zbędne znaki.")
                .contains("Czesc. Jestem Julka");
    }

    @Test
    public void canGreetLocalUSA()
    {
        String returnedText = underTest.createGreetLocalSpeaker().say(tim);

        assertThat(returnedText)
                .describedAs("Niepoprawny tekst zwrócony po wywołaniu metody say() " +
                        "Speaker'a utworzonego w metodzie createGreetLocalSpeaker() dla języka angielskiego. " +
                        "Upewnij się, że została użyta odpowiednia stała, imię osoby, oraz że nie zostały dodane zbędne znaki.")
                .contains("Hello. I'm Tim");
    }

    @Test
    public void canGreetLocalDE()
    {
        String returnedText = underTest.createGreetLocalSpeaker().say(gertruda);

        assertThat(returnedText)
                .describedAs("Niepoprawny tekst zwrócony po wywołaniu metody say() " +
                        "Speaker'a utworzonego w metodzie createGreetLocalSpeaker() dla języka niemieckiego. " +
                        "Upewnij się, że została użyta odpowiednia stała, imię osoby, oraz że nie zostały dodane zbędne znaki.")
                .contains("Hallo, ich heiBe Gertruda");
    }
}
