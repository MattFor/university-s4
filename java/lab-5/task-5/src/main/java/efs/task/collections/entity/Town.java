package efs.task.collections.entity;

import java.util.List;
import java.util.Objects;

public record Town(String townName, List<String> startingHeroClasses) implements Comparable<Town>
{
    @Override
    public boolean equals(Object o)
    {
        if (this == o)
        {
            return true;
        }

        if (!(o instanceof Town town))
        {
            return false;
        }

        return Objects.equals(townName, town.townName);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(townName);
    }

    @Override
    public int compareTo(Town other)
    {
        return townName.compareTo(other.townName);
    }

    @Override
    public String toString()
    {
        return "Miasto :" + townName;
    }
}