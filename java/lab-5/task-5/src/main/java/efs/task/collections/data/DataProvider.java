package efs.task.collections.data;

import efs.task.collections.entity.Hero;
import efs.task.collections.entity.Town;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class DataProvider
{
    public static final String DATA_SEPARATOR = ",";

    public List<Town> getTownsList()
    {
        List<Town> towns = new ArrayList<>();

        for (String row : Data.baseTownsArray)
        {
            String[] parts = row.split(DATA_SEPARATOR);
            String townName = parts[0].trim();
            List<String> heroClasses = Arrays.asList(parts[1].trim(), parts[2].trim());
            towns.add(new Town(townName, heroClasses));
        }

        return towns;
    }

    public List<Town> getDLCTownsList()
    {
        List<Town> towns = new ArrayList<>();

        for (String row : Data.dlcTownsArray)
        {
            String[] parts = row.split(DATA_SEPARATOR);
            String townName = parts[0].trim();
            List<String> heroClasses = Arrays.asList(parts[1].trim(), parts[2].trim());
            towns.add(new Town(townName, heroClasses));
        }

        return towns;
    }

    public Set<Hero> getHeroesSet()
    {
        Set<Hero> heroes = new LinkedHashSet<>();

        for (String row : Data.baseCharactersArray)
        {
            String[] parts = row.split(DATA_SEPARATOR);
            heroes.add(new Hero(parts[0].trim(), parts[1].trim()));
        }

        return heroes;
    }

    public Set<Hero> getDLCHeroesSet()
    {
        Set<Hero> heroes = new LinkedHashSet<>();

        for (String row : Data.dlcCharactersArray)
        {
            String[] parts = row.split(DATA_SEPARATOR);
            heroes.add(new Hero(parts[0].trim(), parts[1].trim()));
        }

        return heroes;
    }
}