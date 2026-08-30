package efs.task.collections.game;

import efs.task.collections.data.DataProvider;
import efs.task.collections.entity.Hero;
import efs.task.collections.entity.Town;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Set;
import java.util.TreeMap;

public class GameLobby
{

    public static final String HERO_NOT_FOUND = "Nie ma takiego bohatera ";
    public static final String NO_SUCH_TOWN = "Nie ma takiego miasta ";

    private final DataProvider dataProvider;
    private final Map<Town, List<Hero>> playableTownsWithHeroesList;

    public GameLobby()
    {
        this.dataProvider = new DataProvider();
        this.playableTownsWithHeroesList = mapHeroesToStartingTowns(dataProvider.getTownsList(), dataProvider.getHeroesSet());
    }

    public Map<Town, List<Hero>> getPlayableTownsWithHeroesList()
    {
        return playableTownsWithHeroesList;
    }

    public void enableDLC()
    {
        Map<Town, List<Hero>> dlcMap = mapHeroesToStartingTowns(dataProvider.getDLCTownsList(), dataProvider.getDLCHeroesSet());

        for (Map.Entry<Town, List<Hero>> entry : dlcMap.entrySet())
        {
            playableTownsWithHeroesList.putIfAbsent(entry.getKey(), entry.getValue());
        }
    }

    public void disableDLC()
    {
        for (Town town : dataProvider.getDLCTownsList())
        {
            playableTownsWithHeroesList.remove(town);
        }
    }

    public List<Hero> getHeroesFromTown(Town town)
    {
        if (!playableTownsWithHeroesList.containsKey(town))
        {
            throw new NoSuchElementException(NO_SUCH_TOWN + town.townName());
        }

        return playableTownsWithHeroesList.get(town);
    }

    public Map<Town, List<Hero>> mapHeroesToStartingTowns(List<Town> availableTowns, Set<Hero> availableHeroes)
    {
        Map<Town, List<Hero>> result = new TreeMap<>();

        for (Town town : availableTowns)
        {
            List<Hero> heroesForTown = new ArrayList<>();

            for (Hero hero : availableHeroes)
            {
                if (town.startingHeroClasses().contains(hero.getHeroClass()))
                {
                    heroesForTown.add(hero);
                }
            }

            Collections.sort(heroesForTown);
            result.put(town, heroesForTown);
        }

        return result;
    }

    public Hero selectHeroByName(Town heroTown, String name)
    {
        List<Hero> heroes = getHeroesFromTown(heroTown);

        for (int i = 0; i < heroes.size(); i++)
        {
            Hero hero = heroes.get(i);
            if (hero.getName().equals(name))
            {
                heroes.remove(i);
                return hero;
            }
        }

        throw new NoSuchElementException(HERO_NOT_FOUND + name);
    }
}