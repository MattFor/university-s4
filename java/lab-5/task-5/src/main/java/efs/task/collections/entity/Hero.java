package efs.task.collections.entity;

import java.util.Objects;

public class Hero implements Comparable<Hero>
{
    private String name;
    private String heroClass;

    public Hero(String name, String heroClass)
    {
        this.name = name;
        this.heroClass = heroClass;
    }

    public String getName()
    {
        return name;
    }

    public String getHeroClass()
    {
        return heroClass;
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o)
        {
            return true;
        }

        if (!(o instanceof Hero hero))
        {
            return false;
        }

        return Objects.equals(name, hero.name) && Objects.equals(heroClass, hero.heroClass);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(name, heroClass);
    }

    @Override
    public int compareTo(Hero other)
    {
        int byName = name.compareTo(other.name);
        if (byName != 0)
        {
            return byName;
        }

        return heroClass.compareTo(other.heroClass);
    }

    @Override
    public String toString()
    {
        return "My name is " + name + "and I am " + heroClass;
    }
}