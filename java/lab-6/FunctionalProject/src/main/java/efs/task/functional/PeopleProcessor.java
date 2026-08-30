package efs.task.functional;

import java.util.*;
import java.util.stream.Collectors;

class PeopleProcessor
{

    List<String> namesOfPeopleWhoseAgeIsGreaterThan(Collection<Person> people)
    {
        return people.stream()
                .filter(person -> person.getAge() > 23)
                .map(Person::getName)
                .toList();
    }

    List<String> namesOfPeopleSortedByAgeLivingIn(Collection<Person> people)
    {
        return people.stream()
                .filter(person -> person.getCityOfLiving().equals("Bydgoszcz"))
                .sorted(Comparator.comparingInt(Person::getAge))
                .map(Person::getName)
                .toList();
    }

    Map<String, Double> averageAgeByCityOfLiving(Collection<Person> people)
    {
        return people.stream()
                .collect(Collectors.groupingBy(
                        Person::getCityOfLiving,
                        Collectors.averagingInt(Person::getAge)
                ));
    }
}
