package efs.task.functional;

class Person
{

    private final String name;
    private final int age;
    private final Country countryOfLiving;
    private final String cityOfLiving;


    Person(String name, int age, String cityOfLiving, Country countryOfLiving)
    {
        this.name = name;
        this.age = age;
        this.cityOfLiving = cityOfLiving;
        this.countryOfLiving = countryOfLiving;
    }

    String getName()
    {
        return name;
    }

    int getAge()
    {
        return age;
    }

    String getCityOfLiving()
    {
        return cityOfLiving;
    }

    Country getCountryOfLiving()
    {
        return countryOfLiving;
    }
}
