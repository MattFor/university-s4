package efs.task.functional;

import org.junit.jupiter.api.Test;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static efs.task.functional.Country.DE;
import static efs.task.functional.Country.PL;
import static efs.task.functional.Country.USA;

class PeopleProcessorTests
{

    PeopleProcessor underTest = new PeopleProcessor();

    @Test
    void canFilter()
    {
        List<String> namesAbove23 = underTest.namesOfPeopleWhoseAgeIsGreaterThan(TEST_DATA);

        assertThat(namesAbove23)
                .describedAs("Uzyskane imiona są niepoprawne. " +
                        "Upewnij się, że filtrowanie odbywa się na podstawie wieku.")
                .containsExactlyInAnyOrder("Tim", "Tom", "Gertruda");
    }

    @Test
    void canSort()
    {
        List<String> bydgoszczansSortedByAge = underTest.namesOfPeopleSortedByAgeLivingIn(TEST_DATA);

        assertThat(bydgoszczansSortedByAge)
                .describedAs("Uzyskane imiona są niepoprawne. " +
                        "Upewnij się, że zarówno filtrowanie jak i sortowanie odbywa się na podstawie wieku, " +
                        "oraz że brane jest pod uwagę przekazane w argumencie miasto.")
                .containsExactly("Janek", "Mirek", "Julka");
    }

    @Test
    void canCalculateAverage()
    {
        var averages = underTest.averageAgeByCityOfLiving(TEST_DATA);

        assertThat(averages)
                .describedAs("Uzyskane wartości są niepoprawne. " +
                        "Upewnij się, że metoda dokonuje mapowania na zasadzie miasto -> średni wiek osób w mieście.")
                .containsExactlyInAnyOrderEntriesOf(Map.of(
                        "Miami", 25d,
                        "Bydgoszcz", 21d,
                        "Berlin", 27d
                ));
    }

    static final Collection<Person> TEST_DATA = List.of(
            new Person("Tim", 24, "Miami", PL),
            new Person("Julka", 22, "Bydgoszcz", USA),
            new Person("Janek", 20, "Bydgoszcz", PL),
            new Person("Tom", 26, "Miami", USA),
            new Person("Mirek", 21, "Bydgoszcz", PL),
            new Person("Gertruda", 27, "Berlin", DE)
    );
}
